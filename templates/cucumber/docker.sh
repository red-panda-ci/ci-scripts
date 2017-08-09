#!/bin/sh

cd "$(dirname $0)"
BASEDIR=$(pwd)
cd "${BASEDIR}/../../.."
WORKSPACE=$(pwd)
cd "${BASEDIR}"
CONTAINER_NAME="bddfire-ci-example-project"
IMAGE_NAME="bddfire-ci"

function stop_container_if_already_running {
  stop_container
}

function check_image_exist {
  echo -e "List of the available images \n"
  docker images
  if docker images | grep -w "bddfire-ci"
  then
    echo -e "\n*** Image already exists. We can run container... ***\n"
  else
    echo -e "\n ** No Image found, please build image"
    build_image
  fi
}

function build_image {
  echo -e "\n*** Building the image ***\n"
  docker build -t ${IMAGE_NAME} .
  echo -e "\n*** Finished building the image ***\n"
}

function check_container_exist {
  echo -e "List of the available containers \n"
  echo docker ps -a
  echo -e "\n*** Checking if the container exists ***\n"

  if docker ps -a | grep ${CONTAINER_NAME}
  then
    echo -e "\n*** Container already exists ***\n"
    docker start ${CONTAINER_NAME}
  else
    echo -e "\n*** Running the container ***\n"
    run_container_with_volume
  fi
}

function run_container_with_volume {
  docker run -it -d -v "$WORKSPACE/":/opt/bddfire --name ${CONTAINER_NAME} ${IMAGE_NAME}
  echo -e "Listing directoy structure of the cucumber project inside container"
  docker exec ${CONTAINER_NAME} ls /opt/bddfire/ci-scripts/test/cucumber
}

function delete_old_reports_screenshots {
  docker exec ${CONTAINER_NAME} rm -rf /opt/bddfire/ci-scripts/test/cucumber/reports
  docker exec ${CONTAINER_NAME} mkdir /opt/bddfire/ci-scripts/test/cucumber/reports
}

function run_cucumber_tests {
  # docker exec ${CONTAINER_NAME}  bundle exec rubocop features
  echo "\n Running Bundler"
  docker exec ${CONTAINER_NAME} bundle install --path vendor/
  #echo "Remove PhantomJS local storage"
  #docker exec ${CONTAINER_NAME} rm -f /root/.local/share/Ofi Labs/PhantomJS/https_dashboard.q.orchextra.io_0.localstorage
  echo "Now running cucumber tests"
  docker exec ${CONTAINER_NAME} bundle exec cucumber -p poltergeist
  return $?
}

function copy_reports_screenshots_to_workspace {
 echo "\n Copying Test Reports back to Workspace"
 echo docker cp ${CONTAINER_NAME}:/opt/bddfire/ci-scripts/test/cucumber/reports "$WORKSPACE/ci-scripts/test/cucumber/reports"
}

function stop_container {
  echo "Restoring file permissions"
  docker exec ${CONTAINER_NAME} chown -R --reference=docker.sh .
  echo "Stoping (and removing) container"
  docker stop ${CONTAINER_NAME}
  docker rm ${CONTAINER_NAME}
}

check_image_exist
check_container_exist
delete_old_reports_screenshots
run_cucumber_tests
rv=$?
copy_reports_screenshots_to_workspace
stop_container
exit $rv
