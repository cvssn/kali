ifndef VERBOSE
.SILENT:
endif

# alvo de construção principal. compila o teamserver e o cliente
all: ts-build client-build

# alvo de construção do teamserver
ts-build:
	@ echo "[*] construindo teamserver"
	@ ./teamserver/Install.sh
	@ cd teamserver; GO111MODULE="on" go build -ldflags="-s -w -X cmd.VersionCommit=$(git rev-parse HEAD)" -o ../havoc main.go
	@ sudo setcap 'cap_net_bind_service=+ep' havoc # isso permite que você execute o servidor como um usuário normal

dev-ts-compile:
	@ echo "[*] compilar teamserver"
	@ cd teamserver; GO111MODULE="on" go build -ldflags="-s -w -X cmd.VersionCommit=$(git rev-parse HEAD)" -o ../havoc main.go

ts-cleanup: 
	@ echo "[*] limpeza de teamserver"
	@ rm -rf ./teamserver/bin
	@ rm -rf ./data/loot
	@ rm -rf ./data/x86_64-w64-mingw32-cross 
	@ rm -rf ./data/havoc.db
	@ rm -rf ./data/server.*
	@ rm -rf ./teamserver/.idea
	@ rm -rf ./havoc

# metas de construção e limpeza de clientes
client-build: 
	@ echo "[*] construindo cliente"
	@ git submodule update --init --recursive
	@ mkdir client/Build; cd client/Build; cmake ..
	@ if [ -d "client/Modules" ]; then echo "módulos instalados"; else git clone https://github.com/HavocFramework/Modules client/Modules --single-branch --branch `git rev-parse --abbrev-ref HEAD`; fi
	@ cmake --build client/Build -- -j 4

client-cleanup:
	@ echo "[*] limpeza de cliente"
	@ rm -rf ./client/Build
	@ rm -rf ./client/Bin/*
	@ rm -rf ./client/Data/database.db
	@ rm -rf ./client/.idea
	@ rm -rf ./client/cmake-build-debug
	@ rm -rf ./client/Havoc
	@ rm -rf ./client/Modules

# alvo da limpeza
clean: ts-cleanup client-cleanup
	@ rm -rf ./data/*.db
	@ rm -rf payloads/Demon/.idea