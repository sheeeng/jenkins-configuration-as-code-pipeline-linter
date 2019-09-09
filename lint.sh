#!/usr/bin/env bash

JENKINSFILE_PATH="\${PWD}/example/Jenkinsfile"
JENKINS_URL="http://localhost:8080"

function usage()
{
    echo "Usage: Lint Jenkinsfile using locally owned Jenkins instance."
    echo ""
    echo "./lint.sh --file=<jenkinsfile>"
    echo "-h, --help"
    echo "-f, --file=$JENKINSFILE_PATH"
    # echo "-u, --url=$JENKINS_URL"
    echo ""
}

if [ "$#" -ne 1 ]; then
    echo "Insufficient arugments provided."
    usage
    exit 41
fi

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        -f | --file)
            JENKINSFILE_PATH=$VALUE
            ;;
        # -u | --url)
        #     JENKINS_URL=$VALUE
        #     ;;
        *)
            echo "Error: Unknown arguments. \"$PARAM\""
            usage
            exit 42
            ;;
    esac
    shift
done

echo \${JENKINSFILE_PATH}="${JENKINSFILE_PATH}"
# echo \${JENKINS_URL}="${JENKINS_URL}"

# Lint Jenkinsfile using Curl (REST API)
# https://jenkins.io/doc/book/pipeline/development/#linter

docker-compose up --detach

# Assuming "anonymous read access" has been enabled on your Jenkins instance.
while [[ $(curl \
    --silent \
    --write-out "%{http_code}" \
    --output /dev/null \
    "${JENKINS_URL}") != "200" ]]; do
    echo "Please wait while Jenkins is getting ready to work...."
    # echo "Your browser will reload automatically when Jenkins is ready."
    sleep 10
done

# JENKINS_CRUMB is needed as Jenkins has CRSF protection enabled by default.
JENKINS_CRUMB=$(curl \
    --show-error \
    --silent \
    "${JENKINS_URL}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")

LINT_RESULTS=$(curl \
    --form "jenkinsfile=<${JENKINSFILE_PATH}" \
    --header $JENKINS_CRUMB \
    --request POST \
    --show-error \
    --silent \
    ${JENKINS_URL}/pipeline-model-converter/validate)
echo \$LINT_RESULTS: "${LINT_RESULTS}"

docker-compose down

# https://stackoverflow.com/a/20460402
stringContain() { [ -z "${2##*$1*}" ]; }

if stringContain 'Errors encountered' "${LINT_RESULTS}"; then
    echo "Errors encountered validating Jenkinsfile."
    exit 1
elif stringContain 'Jenkinsfile successfully validated.' "${LINT_RESULTS}"; then
    echo "Jenkinsfile successfully validated."
    exit 0
else
    echo "Unknown error."
    exit 49
fi
