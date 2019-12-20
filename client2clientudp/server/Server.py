from socket import socket
from socket import AF_INET
from time import time
from socket import SOCK_STREAM
import os
from socket import gethostname
import pickle
from socket import gethostbyname
import threading
from subprocess import Popen, PIPE, STDOUT
import json
from collections import namedtuple

User = namedtuple('User',['user', 'address', 'port', 'pub_key'])
users_table = {}

def show_all_users():
    print('***** Online Users *****')
    for k, v in users_table.items():
        print('{:30} | {:10} | {:6}'.format(v.user, v.address, v.port))
    print('------------------------')
    print()

class Server:
    def __init__(self):
        self.serverSocket = socket(AF_INET, SOCK_STREAM)
    
    def __del__(self):
        self.serverSocket.close()

    def run(self, port = 12000):
        self.port = port
        self.serverSocket.bind(('', port))
        self.serverSocket.listen(1)
        print ('The server is ready to receive')
        while 1:
            connectionSocket, addr = self.serverSocket.accept()
            print('> Receiving from',addr)
            t = threading.Thread(target=self._keep_connection, args=(connectionSocket, addr))
            t.start()

    def _keep_connection(self, connectionSocket, addr):
        while True:
            sentence = connectionSocket.recv(1024)
            try:
                sentence = sentence.decode()
                # print('Request: %s' % sentence)
                sentence = json.loads(sentence.encode())
            except ValueError as e:
                print(e)
                response = bytes('ValueError'.encode())
                connectionSocket.send(response)
                connectionSocket.close()
                continue
            
            if sentence['type'] == 'register' and sentence.keys() == {'type', 'user', 'port', 'password', 'pub_key'}:
                contacts = self.sigaa_login(sentence['user'], sentence['password'])
                if contacts != 'error':
                    r = self.register_user(sentence['user'], addr[0], sentence['port'], sentence['pub_key'])
                response = bytes(contacts.encode())
                connectionSocket.send(response)
            elif sentence['type'] == 'search_user' and sentence.keys() == {'type', 'user'}:
                if sentence['user'] in users_table:
                    user = json.dumps(users_table[sentence['user']]._asdict())
                    response = bytes(user.encode())
                    connectionSocket.send(response)
                    # connectionSocket.close()
                else:
                    response = bytes('unregistered user'.encode())
                    connectionSocket.send(response)
                    # connectionSocket.close()

    def sigaa_login(self, user, password):

        if not os.path.exists('contacts/'+user+'.json'):
            slave = Popen(['ruby', 'sigaa_crawler.rb', user, password], stdin=PIPE, stdout=PIPE, stderr=STDOUT)
            slave.wait()
        
        try:
            with open('contacts/'+user+'.json', 'r') as F:
                content = F.read()
                content = content.replace(':','"').replace('=>','": ')
                content = json.loads(content)
                contacts = {d['username']: d for d in content['participants']}
        
            contacts_str = json.dumps(contacts)
        except Exception as e:
            raise e
            contacts_str = 'error'
        return contacts_str

    def unregister(self):
        pass
    
    def register_user(self, user, address, port, pub_key):
        if user in users_table:
            del users_table[user]
        new_user = User(user=user, address=address, port=port, pub_key=pub_key)
        users_table[user] = new_user
        print()
        print('*** Register')
        print('* User: %s' % user)
        print('* Address: %s' % address)
        print('* Port: %s' % port)
        print("***")
        print()
        show_all_users()
        return True