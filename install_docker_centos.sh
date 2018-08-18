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

while true; do
read -p "Você deseja ativar o docker assim que o sistema iniciar?" sn
    case $sn in
        [SsYy]* ) systemctl enable docker; break;;
        [Nn]* ) exit;;
        * ) echo "Por favor, apenas sim ou não.";;
    esac
done

# Verifica se o grupo docker existe, se não, cria o grupo
# Verifies if docker group exists, if not, creates it
# Adiciona o usuário ao grupo do docker, permitindo execução dos comandos sem usar sudo
# Adds the user to docker group, allowing docker commands execution without needing sudo

echo "Configurando docker..."
if ! grep -q docker /etc/group
then
    groupadd docker
    usermod -aG docker $USER
fi

echo "Docker instalado com sucesso!"
echo "Reiniciando máquina para concluir instalação em 3 segundos..."
reboot -f
