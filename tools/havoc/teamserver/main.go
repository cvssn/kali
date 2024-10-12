package main

import "Havoc/cmd"
import "Havoc/pkg/logger"

func main() {
	err := cmd.HavocCli.Execute()

	if err != nil {
		logger.Error("falha ao executar o havoc")

		return
	}
}