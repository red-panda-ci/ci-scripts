#!/bin/bash

# --------------------------------------------- #
#  It is neccesary install jq package in Linux  #
# 	     Ubuntu: sudo apt-get install jq        #
# --------------------------------------------- #
cd "$(dirname $0)/../../../"
WORKSPACE=$(pwd)

token=${1}                    # YaTT token
projectId=${2}
version=${3}
pathFile="${WORKSPACE}/${4}"  # Full path of the application with quotes
callback_url=${5}             # Callback URL
pool_id=${6}
VERSION_NAME=${7}
WORKSPACE=$(pwd)

cd "$(dirname $0)/../.."

# Optional -> If you dont want to use this values, please comment the three final rows of the file
subversion="${VERSION_NAME}"
comments="Branch: ${BRANCH_NAME}, Build #: ${BUILD_NUMBER}, callbackUrl: ${callbackUrl}"
copyLastTestByDefault=true

# Upload artifact
echo -n "Uploading artifact ${pathFile} to YaTT: "
response=$(curl -s "http://api.yatt.io/api/v1/versions/upload" -H "x-access-token:${token}" \
  -F "versionFile=@${pathFile}" \
  -F "projectId=${projectId}" \
  -F "version=${version}" \
  -F "subVersion=${subversion}" \
  -F "comments=${comments}" \
  -F "copyLastTestByDefault=${copyLastTestByDefault}")
echo "[Finished]"
echo "Yatt upload response: ${response}"

# Return 0 only if $result=true
success=`echo $result|jq -r '.success'`
eval $success || exit 1

# Compose planification data
id_version=`echo $response|jq -r '.result.versions[0].id'`
id_pool="24"
json_data='{"pool":'${id_pool}',"version":'${id_version}',"callback_url":"'${callback_url}'"}'

# Execution
echo "Yatt planification data: ${json_data}"
planification_result=$(curl -s "http://api.yatt.io/api/v1/planifications" \
  -H "x-access-token:${token}" \
  -H "Content-Type: application/json" \
  -X POST -d ${json_data})

echo "Yatt planification result: ${planification_result}"
