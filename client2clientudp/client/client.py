from common import config
import json
import pickle
import rsa
from threading import Thread
import client.client_messages as message_models
from socket import *

class Client:
    def __init__(self, udp_port):
        self.user = None
        self.__logged = False
        self.contacts = None
        self.udp_port = udp_port
        self.udpserver_sckt = socket (AF_INET, SOCK_DGRAM)
        self.udpclient_sckt = socket (AF_INET, SOCK_DGRAM)
        self.tcpserver_sckt = socket(AF_INET, SOCK_STREAM)
        self.udpserver_thread = None
        self.udpserver_stop = False
        self.pub_key, self.priv_key = rsa.newkeys(nbits=256)
        self.run_udp_server()
    
    def __del__(self):
        print("Disconnecting...")
        self.udpserver_stop = True
        self.udpserver_sckt.close()
        self.udpclient_sckt.close()
        self.tcpserver_sckt.close()


    def decrypt(self, crypt):
        message = rsa.decrypt(crypt, self.priv_key)
        message = message.decode('utf8')
        return message
    
    def encrypt(self, message, pub_key):
        if isinstance(pub_key, list):
            pub_key = rsa.PublicKey(pub_key[0], pub_key[1])
        message = message.encode('utf8')
        crypt = rsa.encrypt(message, pub_key)
        return crypt

    def register(self, user, password):
        server_name = config['client2server']['server_name']
        server_port = config['client2server']['server_port']
        
        
        self.tcpserver_sckt.connect((server_name, server_port))  # Feito apenas uma vez
        sentence = message_models.msg_register(user, password, self.udp_port, self.pub_key)
        response = self._message2server(str_message=sentence)
        response = self.json2dict(response)

        if response is not None:
            self.__logged = True
            self.user = user
            self.contacts = response
            print('* Successfully authenticated.')  
            return True
        else:
            return False
    
    def json2dict(self, content):
        try:
            d = json.loads(content)
            return d
        except ValueError as e:
            raise e
            return None

    def logged(self):
        return self.__logged

    def send_message(self):
        # TODO separar método de busca de usuário destinatário do método de envio de mensagem
        print()
        print('__________________________')
        print('Who do you want to send a message to?')
        name = input('Name: ')

        found = {}
        counter = 1
        for k, v in self.contacts.items():
            if name.lower() in v['name'].lower():
                print('%d - %s (%s)' % (counter, v['name'], v['username']))
                found[counter] = v['username']
        
        opc = input('>> ')
        if int(opc) not in found:
            return

        sentence = {}
        sentence['type'] = 'search_user'
        sentence['user'] = found[int(opc)]
        sentence = json.dumps(sentence)
        json_receiver = self._message2server(sentence)
        receiver = self.json2dict(json_receiver)

        if receiver.keys() == {'user', 'address', 'port', 'pub_key'}:
            print('User is registered (%s). \nWrite the message:' % receiver)
            message = input('\nMessage: ')
            message_encrypt = self.encrypt(message, receiver['pub_key'])
            message2send = message_models.msd_send(self.user, self.pub_key, message_encrypt)

            self.udpclient_sckt.sendto(bytes(message2send.encode()),(receiver['address'], int(receiver['port'])))
            # response, serverAddress = self.udpclient_sckt.recvfrom(2048)
            # print(response)
        else:
            print('(!) Unregistered user. Try again.')
    
    def _message2server(self, str_message):
        if not isinstance(str_message, bytes):
            str_message = bytes(str_message.encode())
        encoded_message = str_message
        self.tcpserver_sckt.send(encoded_message)
        response = self.tcpserver_sckt.recv(2048000)
        return response
    
    def run_udp_server(self):
        self.udpserver_sckt.bind(('', int(self.udp_port)))
        self.udpserver_thread = Thread(target=self.udp_server, args=([]))
        self.udpserver_thread.start()

    def udp_server(self):
        # print ("The server is ready to receive")
        while True:
            if self.udpserver_stop:
                break
            json_message, sender = self.udpserver_sckt.recvfrom(2048)
            try:
                message = self.json2dict(json_message)
                # print(message)
                if message['type'] == 'message' and message.keys() == {'type', 'sender', 'message', 'pub_key_sender'}:
                    print('__________________________')
                    print('New message from %s. Do you want to read? (Y/n)' % message['sender'])
                    new = input()
                    if new != 'n' and new != 'N':
                        reply = self.notification(message)
                        self.udpserver_sckt.sendto(message_models.msd_send(self.user, self.pub_key, self.encrypt(reply, message['pub_key_sender'])), sender)
                else:
                    self.udpserver_sckt.sendto('error', sender)
            except Exception as e:
                print(e)
                pass
    
    def notification(self, message):
        print()
        print('__________________________')
        print('##     New Message     ##')
        print('Sender:   %s' % message['sender'])
        print('Message:  %s' % self.decrypt(bytes(message['message'].encode())))
        print()
        reply = input('Reply >> ')
        return reply        
