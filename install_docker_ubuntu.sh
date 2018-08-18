#!/bin/sh

# Garantindo que o curl esteja instalado...
# Ensuring that curl is installed...

if [! which curl]
then
    apt-get install curl
fi

# Removendo as versões anteriores do docker
# Removing all older docker versions

echo "Removendo as versões anteriores do docker..."
apt-get remove docker docker-engine docker.io

# Atualiza os índices de atualização
# Refresh all update indexes

echo "Configurando índices de autalização..."
apt-get update

# Instalando dependências necessárias para o docker
# Installing all dependencies for docker to work properly

echo "Instalando dependências..."
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y

# Adiciona e verifica autenticidade da chave importada do site do docker
# Add and verify docker's imported key authenticity

echo "Adicionando chave de verificação..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Se após esta linha não exibir nada, entre em contato com o time docker no github informando que a chave não é autêntica. Link: https://github.com/docker/for-linux
# If there's no output after this line, contact docker team on github and notify the key is not authentic. Link: https://github.com/docker/for-linux

echo "Verificando autenticidade..."
apt-key fingerprint 0EBFCD88

# Adiciona o repositório de acordo com a versão do seu SO
# Adds a repository for your OS version

echo "Configurando caminho para instalação do docker..."
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo "Instalando docker..."
# Primeiro atualiza os índices em modo silencioso e após, instala o docker CE
# Refreshes all update indexes first in quiet mode, then install's docker CE
apt-get -qq update

apt-get install docker-ce -y

# Ativa o processo do docker
# Activates docker service

echo "Ativando docker..."
systemctl start docker

# Pergunta se deseja ativar o docker assim que iniciar o sistema e ativa caso sim
# Asks if user want to start docker on OS boot and activates it in case of yes

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
