# client2clientudp
#### Serviço de troca de mensagem via protocolo UDP

------------
O sistema client2clientudp provê uma plataforma de de troca de mensagens via protocolo UDP.
É composto por 3 entidades fundamentais: 
1.  Um servidor central, que disponibilidade uma interface para autenticação através da plataforma SIGAA, persistência de dados de rede dos clientes ativos e busca por dados de endereço IP e porta dos servidores UDP criados pelos clientes na rede.
2.  Aplicação cliente, por onde o usuário pode entrar com seus dados de acesso à plataforma SIGAA, tendo então acesso ao sistema. Uma vez registrado no servidor central através da aplicação cliente, o usuário em acesso aos serviços prestados pelo servidor.
3.  Um serviço de Crawler, responsável pela recuperação dos contatos do usuário via plataforma SIGAA

------------

## Servidor Central
O servidor pode ser inciado através da linha de comando:

`$ python3 server-app.py [--port PORT]`

O parâmetro `--port` é usado para configurar a porta que será utilizada pelo servidor. Por *default* (sem a passagem do parâmetro `--port`) a porta utlizada é a 12000.

------------

## Servidor Central via *Docker*
O servidor central também pode ser iniciado utilizando o *Docker* , através do arquivo *Dockerfile* presente no projeto.

- Gerando a imagem do ambiente:

`$ docker build -t client2clientudp .`

- Criando o *container*:

`$ docker run -it --rm -p 12000:12000 --name my-running-app client2clientudp`

------------

## Aplicação Cliente
A aplicação cliente pode ser iniciada através do comando:

`$ python3 client-app.py [--port PORT]`

O parâmetro `--port` é usado para configurar a porta que será utilizada pelo servidor UDP criado pela aplicação.

O servidor UDP é usado para troca de mensagens entre clientes na rede local.

------------

O projeto contém um **ambiente virtual python** pré-configurado com Python 3.6, cujo interpretador pode ser utlizado para rodar os programas, tanto servidor quanto cliente.

O **ambiente virtual python** pode ser iniciado da seguinte forma 

`$ source sd_py36/bin/activate`

Para sair do ambiente basta entrar com o comando:

`$ source deactivate`

------------


------------

