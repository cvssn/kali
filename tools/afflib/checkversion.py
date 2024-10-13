import sys


server_version = open(sys.argv[1], "r").read().strip()

print "versão do servidor:", server_version

if (server_version == sys.argv[2]):
    print "\n\nversão", sys.argv[1], "já está no servidor.\n\n"
    
    sys.exit(-1)
    
sys.exit(0)