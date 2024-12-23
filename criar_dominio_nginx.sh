#!/bin/bash

#Peterson Henrique de Padua
#Pett97

# Solicitar o nome do domínio
echo -e "\033[33mDigite o nome do domínio (exemplo: meu_dominio.local): \033[0m"
read dominio

# Definir o diretório onde os arquivos do site serão armazenados
diretorio="/var/www/$dominio"
html="$diretorio/html"
status_pages="$diretorio/status-pages"
logs="$diretorio/logs"
maintenance="$diretorio/maintenance"

# Verificar se o diretório já existe
if [ -d "$diretorio" ]; then
  echo -e "\033[31mO diretório $diretorio já existe!\033[0m"
  exit 1
else
  # Criar o diretório principal e a subpastas
  mkdir -p "$html"
  mkdir -p "$status_pages"
  mkdir -p "$maintenance"
  echo -e "\033[32mDiretório $html criado!\033[0m"
  echo -e "\033[32mDiretório $status_page criado!\033[0m"
  echo -e "\033[32mDiretório $maintenance criado!\033[0m"
fi

#verficar diretorio de logs
if [ -d "$diretorio/logs" ]; then
  echo -e "\033[31mO diretório $diretorio logs já existe!\033[0m"
  exit 1
else
  # Criar o diretório logs
  mkdir -p "$logs"
  echo -e "\033[32mDiretório $logs criado!\033[0m"

fi


#criar arquivos de logs para registro
touch "$logs/nginx_access.log"
touch "$logs/nginx_error.log"
echo -e "\033[32mArquivos de log criados!\033[0m"


# Criar uma página de teste simples dentro da pasta html
echo "<html><body><h1>Bem-vindo ao $dominio!</h1></body></html>" > "$html/index.html"

#erros##################################

#Criar Uma pagina de erro 404 
echo "<html><body><h1>Erro 404 :/$dominio!</h1></body></html>" > "$status_pages/404.html"

#Criar pagina manutencao
echo "<html><body><h1>Manutencao 503 :/$dominio!</h1></body></html>" > "$maintenance/503.html"



# Definir a configuração do Nginx para o domínio
config_file="/etc/nginx/sites-available/$dominio"

cat <<EOL > $config_file
server {
    listen 80;
    server_name $dominio;

    root $html;
    index index.html;

    access_log $logs/nginx_access.log;
    error_log $logs/nginx_error.log;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Página de erro personalizada para 404
    error_page 404 /status-pages/404.html;
    location = /status-pages/404.html {
        root $diretorio;
        internal;
    }

    # Página de erro personalizada para 503
    error_page 503 /maintenance/503.html;
    location = /maintenance/503.html {
        root $diretorio;
        internal;
    }

    # Endpoint para ativar a página de manutenção
    location /maintenance {
        return 503;
    }
}
EOL

# Criar um link simbólico no diretório sites-enabled
ln -s $config_file /etc/nginx/sites-enabled/

# Adicionar o domínio ao arquivo /etc/hosts
if ! grep -q "$dominio" /etc/hosts; then
    echo "127.0.0.1   $dominio" >> /etc/hosts
    echo -e "\033[32mDomínio $dominio adicionado ao /etc/hosts\033[0m"
else
    echo -e "\033[31mO domínio $dominio já está presente no /etc/hosts\033[0m"
fi

# Testar a configuração do Nginx
nginx -t

# Verificar se a configuração está correta e recarregar o Nginx
if [ $? -eq 0 ]; then
  systemctl reload nginx
  echo -e "\033[32mDomínio $dominio configurado com sucesso!\033[0m"
else
  echo -e "\033[31mErro na configuração do Nginx. Não foi possível recarregar o serviço.\033[0m"
  exit 1
fi
