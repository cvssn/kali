package cosign

import (
	"errors"
	"fmt"
	"os"
	"syscall"

	"golang.org/x/term"
)

func GetPassFromTerm(confirm bool) ([]byte, error) {
	fmt.Fprint(os.Stderr, "insira a senha para a chave privada: ")

	pw1, err := term.ReadPassword(int(syscall.Stdin))

	if err != nil {
		return nil, err
	}

	fmt.Fprintln(os.Stderr)

	if !confirm {
		return pw1, nil
	}

	fmt.Fprint(os.Stderr, "insira a senha para a chave privada novamente: ")

	confirmpw, err := term.ReadPassword(int(syscall.Stdin))
	fmt.Fprintln(os.Stderr)

	if err != nil {
		return nil, err
	}

	if string(pw1) != string(confirmpw) {
		return nil, errors.New("as senhas não coincidem")
	}

	return pw1, nil
}

// todo: mover isso para um pacote interno
func IsTerminal() bool {
	stat, _ := os.Stdin.Stat()

	return (stat.Mode() & os.ModeCharDevice) != 0
}