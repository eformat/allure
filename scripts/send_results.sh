#!/bin/bash

#set -x

usage() {
  cat <<EOF 2>&1
usage: $0 [ -h | -v ] <ALLURE_PROJECT> <DIRECTORY> <ALLURE_USER> <ALLURE_PASS> <ALLURE_HOST>

Send test results to an Allure server instance

Required:
   ALLURE_PROJECT       Allure project name used in /projects create
   DIRECTORY            Directory containing target/allure-results folder (normally '.' or `pwd`)
   ALLURE_USER          Allure user
   ALLURE_PASS          Allure password
   ALLURE_HOST          Allure host

Optional:
   -h  help for the needy
   -v  Enable verbose mode

EOF
  exit 1
}

#trap "cleanup" QUIT EXIT
cleanup () {
    rm -rf /tmp/login.txt;
}

# This directory is where you have all your results locally, generally named as `allure-results`
ALLURE_RESULTS_DIRECTORY='target/allure-results'
# Project ID. Check endpoint for project creation >> `[POST]/projects`
PROJECT_ID=${1}
DIR=${2}
# /login tokens
ALLURE_USER=${3}
ALLURE_PASS=${4}
# This url is where the Allure container is deployed. We are using localhost as example
ALLURE_SERVER=${5:-http://localhost:5050}

while getopts hv c; do
  case $c in
    v)
      set -o xtrace
      ;;
    *)
      usage
      ;;
  esac
done
shift `expr $OPTIND - 1`

if [ -z ${PROJECT_ID} ] || [ -z ${DIR} ] || [ -z ${ALLURE_USER} ] || [ -z ${ALLURE_PASS} ] || [ -z ${ALLURE_SERVER} ]; then
    usage
fi

if [ ! -d "${DIR}/${ALLURE_RESULTS_DIRECTORY}" ]; then
   echo "Could not find directory ${DIR}/${ALLURE_RESULTS_DIRECTORY} exiting."
   exit 0;
fi

# login
curl -sk -X POST "${ALLURE_SERVER}/allure-docker-service/login" -H  "accept: */*" -H  "Content-Type: application/json" -d "{\"username\": \"admin\",\"password\":\"password\"}" -ik | tr -d '\r' | tee /tmp/login.txt
ACCESS_TOKEN=$(cat /tmp/login.txt | grep access_token_cookie | sed 's/Set-Cookie: access_token_cookie=//g' | sed 's/\; HttpOnly\; Path=\///g')
CSRF_TOKEN=$(cat /tmp/login.txt | grep csrf_access_token | sed 's/Set-Cookie: csrf_access_token=//g' | sed 's/\; Path=\///g')

if [ -z ${ACCESS_TOKEN} ] || [ -z ${CSRF_TOKEN} ]; then
    echo "Failed to login?"
    usage
fi

# create project, ok if exists already
curl -X POST -H "X-CSRF-TOKEN: ${CSRF_TOKEN}" --cookie "access_token_cookie=${ACCESS_TOKEN}" "${ALLURE_SERVER}/allure-docker-service/projects" -H  "accept: */*" -H  "Content-Type: application/json" -d "{\"id\":\"${PROJECT_ID}\"}"

FILES_TO_SEND=$(ls -dp $DIR/$ALLURE_RESULTS_DIRECTORY/* | grep -v /$)
if [ -z "$FILES_TO_SEND" ]; then
    echo "Failed to find any files to send?"    
    exit 1
fi

FILES=''
for FILE in $FILES_TO_SEND; do
  FILES+="-F files[]=@$FILE "
done

echo "------------------SEND-RESULTS------------------"
curl -X POST "$ALLURE_SERVER/allure-docker-service/send-results?project_id=$PROJECT_ID" -H "X-CSRF-TOKEN: $CSRF_TOKEN" --cookie "access_token_cookie=${ACCESS_TOKEN}" -H 'Content-Type: multipart/form-data' $FILES -ik

exit $?
