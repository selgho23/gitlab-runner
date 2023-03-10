### BASH COLOR CODES
RED="\e[91m"
CYAN="\e[96m"
GREEN="\e[92m"
ENDCOLOR="\e[0m"

#################################################
# MAIN
#################################################
function main() {
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      "-d"|"--docker")
        docker_install; return 0
        ;;
      "-gr"|"--gitlab-runner")
        gitlab_runner_install; return 0
        ;;
    esac
    shift
  done
  
  docker_install
  gitlab_runner_install
}

#################################################
# HELPER FUNCTIONS
#################################################
#----------------------------------------------------------
function docker_install() {
  echo -e "${CYAN}\n\nINSTALL DOCKER ENGINE${ENDCOLOR}"
  echo -e "${GREEN}\n\tUninstall old package versions${ENDCOLOR}"
  apt-get remove -y docker docker-engine docker.io containerd runc
  
  echo -e "${GREEN}\n\tUpdate the apt package index and install packages to allow apt to use a repository over HTTPS${ENDCOLOR}"
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg lsb-release
  
  echo -e "${GREEN}\n\tAdd Docker’s official GPG key${ENDCOLOR}"
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  
  echo -e "${GREEN}\n\tSet up the docker repository${ENDCOLOR}"
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update -y
  
  echo -e "${GREEN}\n\tInstall the latest version of docker${ENDCOLOR}"
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  
  echo -e "${GREEN}\n\tConfigure docker to start on booth with systemd${ENDCOLOR}"
  systemctl start docker.service
  systemctl enable docker.service
}

#----------------------------------------------------------
function gitlab_runner_install() {
  echo -e "${CYAN}\n\nINSTALL GITLAB RUNNER${ENDCOLOR}"
  echo -e "${GREEN}\n\tUpdate the apt package index and install packages to allow apt to use a repository over HTTPS${ENDCOLOR}"
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg lsb-release
  
  echo -e "${GREEN}\n\tSet up the official gitlab repository${ENDCOLOR}"
  curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash
  apt-get update -y
  
  echo -e "${GREEN}\n\tInstall the latest version of the gitlab runner${ENDCOLOR}"
  apt-get install -y gitlab-runner
}

#################################################
# RUN MAIN
#################################################
main "$@"
