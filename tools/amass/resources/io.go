package resources

import (
	"compress/gzip"
	"embed"
	"encoding/csv"
	"fmt"
	"io"
	"io/fs"
	"net"
	"path/filepath"
	"strconv"
)

// go:embed scripts ip2asn-combined.tsv.gz alterations.txt namelist.txt user_agents.txt
var resourceFS embed.FS

// ip2asn é um range fornecido pelo serviço iptoasn.com
type IP2ASN struct {
	FirstIP     net.IP
	LastIP      net.IP
	ASN         int
	CC          string
	Description string
}

// getip2asndata retorna todos os ranges lidos do arquivo 'ip2asn-combined.tsv.gz'
func GetIP2ASNData() ([]*IP2ASN, error) {
	file, err := resourceFS.Open("ip2asn-combined.tsv.gz")

	if err != nil {
		return nil, fmt.Errorf("falha ao abrir o arquivo 'ip2asn-combined.tsv.gz': %v", err)
	}

	defer file.Close()

	zr, err := gzip.NewReader(file)

	if err != nil {
		return nil, fmt.Errorf("falha ao obter o leitor gzip para o arquivo 'ip2asn-combined.tsv.gz': %v", err)
	}

	defer zr.Close()

	var ranges []*IP2ASN

	r := csv.NewReader(zr)
	r.Comma = '\t'
	r.FieldsPerRecord = 5

	for {
		record, err := r.Read()

		if err == io.EOF {
			break
		}

		if err != nil {
			continue
		}

		if asn, err := strconv.Atoi(record[2]); err == nil {
			ranges = append(ranges, &IP2ASN{
				FirstIP:     net.ParseIP(record[0]),
				LastIP:      net.ParseIP(record[1]),

				ASN:         asn,

				CC:          record[3],
				Description: record[4],
			})
		}
	}

	return ranges, nil
}

func GetDefaultScripts() ([]string, error) {
	var scripts []string

	ferr := fs.WalkDir(resourceFS, "scripts", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// esse arquivo não é um script?
		if d.IsDir() || filepath.Ext(d.Name()) != ".ads" {
			return nil
		}

		// obtém o conteúdo do script
		data, err := resourceFS.ReadFile(path)

		if err != nil {
			return err
		}

		scripts = append(scripts, string(data))

		return nil
	})

	return scripts, ferr
}

func GetResourceFile(path string) (io.Reader, error) {
	file, err := resourceFS.Open(path)

	if err != nil {
		return nil, fmt.Errorf("falha ao obter o arquivo embed: %s: %v", path, err)
	}

	return file, err
}