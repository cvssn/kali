package main

import (
	"fmt"
	"os"

	"github.com/sigstore/cosign/v2/cmd/cosign/cli"
	"github.com/sigstore/cosign/v2/cmd/cosign/cli/templates"
	errors "github.com/sigstore/cosign/v2/cmd/cosign/errors"
	"github.com/spf13/cobra"
	"github.com/spf13/cobra/doc"
)

func main() {
	var dir string

	root := &cobra.Command{
		Use:          "gendoc",
		Short:        "gera uma documentação de ajuda do cosign",
		SilenceUsage: true,
		Args:         cobra.NoArgs,
		RunE: func(*cobra.Command, []string) error {
			err := errors.GenerateExitCodeDocs(dir)

			if err != nil {
				fmt.Println(err)

				os.Exit(1)
			}

			return doc.GenMarkdownTree(cli.New(), dir)
		},
	}

	root.Flags().StringVarP(&dir, "dir", "d", "doc", "caminho para o diretório no qual gerar documentos")

	templates.SetCustomUsageFunc(root)

	if err := root.Execute(); err != nil {
		fmt.Println(err)

		os.Exit(1)
	}
}