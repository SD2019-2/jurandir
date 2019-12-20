from server.Server import Server
from server.Server import gethostbyname
from server.Server import gethostname
import argparse

if __name__ == "__main__":
    host_name = gethostname()
    host_ip = gethostbyname(host_name)
    desc = """Server for connecting and distributing client identifiers.
    Hostname: {host_name}
    Host IP: {host_ip}
    """.format(host_name = host_name, host_ip=host_ip)

    parser = argparse.ArgumentParser(description=desc, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('--port', 
                        dest='port', 
                        default=12000,
                        help='Port to open for TCP connection (default: 12000)')
    args = parser.parse_args()
    tcp_port = args.port

    server = Server()    
    server.run(port = tcp_port)    