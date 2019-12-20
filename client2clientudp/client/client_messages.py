import json
import rsa

def msg_register(user, password, udp_port, pub_key):
    mssg = {}
    mssg['type'] = 'register'
    mssg['user'] = user
    mssg['password'] = password
    mssg['port'] = udp_port
    mssg['pub_key'] = [pub_key.n, pub_key.e]
    mssg_string = json.dumps(mssg)
    return mssg_string.encode('utf8')

def msd_send(sender, pub_key_sender, message):
    mssg = {}
    mssg['type'] = 'message'
    mssg['sender'] = sender
    mssg['message'] = message.decode(errors='replace')
    mssg['pub_key_sender'] = [pub_key_sender.n, pub_key_sender.e]
    print(mssg)
    mssg_string = json.dumps(mssg)
    return mssg_string