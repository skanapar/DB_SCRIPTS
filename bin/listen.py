import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(("127.0.0.1", 1234))
s.listen(5)

while True:
    # now our endpoint knows about the OTHER endpoint.
    clientsocket, address = s.accept()
    print("Connection from {} has been established.".format(address))
    clientsocket.send(bytes("Hey there!!!"))
    clientsocket.close()
