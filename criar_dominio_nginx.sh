
#Peterson Henrique de Padua 
#Pett97

#!/bin/bash

#  o nome do domínio
echo -e "\033[33mDigite o nome do domínio (exemplo: meu_dominio.local): \033[0m"
read dominio

# Definir o diretório onde os arquivos do site serão armazenados
diretorio="/var/www/$dominio"

# Verificar se o diretório já existe
if [ -d "$diretorio" ]; then
  echo -e "\033[31mO diretório $diretorio já existe!\033[0m"
  exit 1
else
  # Criar o diretório para o domínio
  mkdir -p "$diretorio"
  echo -e "\033[32mDiretório $diretorio criado!\033[0m"
fi

# Criar uma página de teste simples
echo "<html><body><h1>Bem-vindo ao $dominio!</h1></body></html>" > "$diretorio/index.html"

# Definir a configuração do Nginx para o domínio
config_file="/etc/nginx/sites-available/$dominio"

cat <<EOL > $config_file
server {
    listen 80;
    server_name $dominio;

    root $diretorio;
    index index.html;

    access_log /var/log/nginx/$dominio.access.log;
    error_log /var/log/nginx/$dominio.error.log;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

# Criar um link simbólico no diretório sites-enabled
ln -s $config_file /etc/nginx/sites-enabled/

# Adicionar o domínio ao arquivo /etc/hosts
if ! grep -q "$dominio" /etc/hosts; then
    echo "127.0.0.1   $dominio" >> /etc/hosts
    echo -e "\033[32mDomínio $dominio adicionado ao /etc/hosts\033[0m"  # Mensagem verde
else
    echo -e "\033[31mO domínio $dominio já está presente no /etc/hosts\033[0m"  # Mensagem vermelha
fi

#  testa configuracao
nginx -t

# testa se esta certo a configuracao
if [ $? -eq 0 ]; then
  systemctl reload nginx
  echo -e "\033[32mDomínio $dominio configurado com sucesso!\033[0m"  # Mensagem verde
else
  echo -e "\033[31mErro na configuração do Nginx. Não foi possível recarregar o serviço.\033[0m"  # Mensagem vermelha
  exit 1
fi

