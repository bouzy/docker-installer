#!/bin/sh

docker_installer(){
  sudo apt update -y && sudo apt autoremove -y && sudo apt autoclean -y
  sudo apt install -y ca-certificates curl gnupg lsb-release

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose
}

portainer_installer(){
  sudo docker volume create portainer_data

  sudo docker run -d \
    -p 8000:8000 \
    -p 9443:9443 \
    --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data portainer/portainer-ee:latest
}

portainer_agent_installer(){
  sudo docker run -d \
    -p 9001:9001 \
    --name portainer_agent \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    portainer/agent:latest
}

portainer_agent_update(){
  sudo docker stop portainer_agent
  sudo docker rm portainer_agent
  sudo docker rmi portainer/agent

  sudo docker run -d \
    -p 9001:9001 \
    --name portainer_agent \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    portainer/agent:latest
}

help(){
  echo "Options:"
  echo "help                        Show this help message"
  echo "install-docker              Install the complete docker package"
  echo "install-portainer           Install the portainer pacakge"
  echo "install-portainer-agent     Install the portainer agent"
  echo "update-portainer-agent      Update the portainer agent"
}

call_switch(){
  case "$1" in
    help)
      help
      ;;
    install-docker)
      docker_installer
      ;;
    install-portainer)
      portainer_installer
      ;;
    install-portainer-agent)
      portainer_agent_installer
      ;;
    update-portainer-agent)
      portainer_agent_update
      ;;
    *)
      break
      ;;
  esac
}

call_switch "$1"