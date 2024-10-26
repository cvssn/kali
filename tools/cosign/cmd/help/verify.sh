set -e

# verifica se a documentação em markdown gerada está atualizada
tmpdir=$(mktemp -d)
go run -tags pivkey,pkcs11key,cgo cmd/help/main.go --dir "$tmpdir"
echo "##################################################"
echo "se forem encontradas diferenças, rode: make docgen"
echo "##################################################"
diff -Naur "$tmpdir" doc/