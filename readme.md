# Script de Criação de Domínios Simples  Locais para Nginx

## Descrição

Este script cria domínios locais configurados para o Nginx, criando automaticamente as páginas de erro e diretórios necessários basicos .

## Pré-requisitos

Antes de executar o script, certifique-se de que você tem o Nginx instalado e o Apache2 parado (caso esteja usando):

### Instalar o Nginx

```bash
sudo apt-get install nginx

### NOTA
esse script não configura nada no arquivo nginx.conf caso necessário editar manualmente

### Como Executar

sudo chmod +x criar_dominio_nginx.sh

### Executar 
sudo ./criar_dominio_nginx.sh

### Funcionalidades do Script
Cria diretórios para o domínio especificado
  /var/www/{dominio}/html
  /var/www/{dominio}/status-pages
  /var/www/{dominio}/logs
  /var/www/{dominio}/maintenance

Cria páginas HTML:
index.html (Página inicial)
404.html (Página de erro 404)
503.html (Página de manutenção 503) 

Configura o Nginx para o domínio especificado
Adiciona o domínio ao arquivo /etc/hosts
Testa a configuração do Nginx e recarrega o serviço

### Paginas Criadas
index.html: Página de boas-vindas
404.html: Página de erro 404
503.html: Página de manutenção 503


