#!/bin/sh

# Removendo as versões anteriores do docker
# Removing all older docker versions

echo "Removendo as versões anteriores do docker..."
yum remove docker \
    docker-common \
    docker-selinux \
    docker-engine

# Instalando as dependências de sistema necessárias
# Installing all system's dependencies

echo "Instalando dependências..."

subscription-manager repos --enable=rhel-7-server-extras-rpms

yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# Instalando o docker
# Installing docker

echo "Instalando docker..."

# Primeiro atualiza os índices em modo silencioso e, após, instala o docker CE
# First refresh all update indexes in quiet mode, then installs docker CE

yum -qq update

yum install docker-ce -yq

# Ativando o processo do docker
# Activating docker process

echo "Ativando docker..."
systemctl start docker

# Escolha de ativar o docker assim que iniciar o sistema
# Asks if user wants to start docker on system boot

while true; do
read -p "Você deseja ativar o docker assim que o sistema iniciar?" sn
    case $sn in
        [Ss]* ) systemctl enable docker; break;;
        [Nn]* ) exit;;
        * ) echo "Por favor, apenas sim ou não.";;
    esac
done

# Verifica se o grupo docker já existe no /etc/group, se não, cria o grupo
# Verifies if docker group already exists, if not, creates the docker group

echo "Configurando docker..."
if ! grep -q docker /etc/group
then
    groupadd docker
fi

# Adiciona o usuário atual ao grupo docker para permitir execução dos comandos sem precisar do sudo
# Adds current user to docker group to enable docker command execution without sudo

usermod -aG docker $USER

echo "Docker instalado com sucesso!"
