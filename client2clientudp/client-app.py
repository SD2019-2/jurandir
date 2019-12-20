# encoding: utf-8
import argparse
import getpass
from socket import gethostbyname, gethostname
from client.client import Client


# Função que trata os parâmetros de linha de comando
def arg_parse():
    host_name = gethostname()
    host_ip = gethostbyname(host_name)
    desc = """Software for connecting and communicating with other clients.
    Hostname: {host_name}
    Host IP: {host_ip}
    """.format(host_name = host_name, host_ip=host_ip)
    parser = argparse.ArgumentParser(description=desc, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('--port', 
                        dest='port', 
                        default=12001,
                        help='Port to open for UDP connection (default: 12001)')
    args = parser.parse_args()
    return args

def register(client):
    print()
    print('__________________________')
    user = input('User: ')
    password = getpass.getpass(prompt="Password: ")
    
    r = client.register(user, password)
    return r

def send_message(client):
    pass

# Função que exibe um menu
def menu(client):
    global reg
    print('__________________________')
    print('|1 - Login              %s|' % reg)
    print('|2 - Send message        |')
    opc = input('|> > ')

    if opc == '1':
        r = register(client)
        if r is not None:
            reg = """✔️"""
        else:
            print("Username or password are incorrect. Try again.")  # TODO usar logging
    if opc == '2':
        if client.logged():
            client.send_message()
        else:
            print("First, sign in!")

if __name__ == "__main__":
    args = arg_parse()
    udp_port = args.port
    reg = ' '
    
    client = Client(udp_port)
    
    while True:
        menu(client)
