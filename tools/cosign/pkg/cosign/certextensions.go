package cosign

import (
	"crypto/x509"
)

type CertExtensions struct {
	Cert *x509.Certificate
}

var (
	CertExtensionOIDCIssuer               = "1.3.6.1.4.1.57264.1.1"
	CertExtensionGithubWorkflowTrigger    = "1.3.6.1.4.1.57264.1.2"
	CertExtensionGithubWorkflowSha        = "1.3.6.1.4.1.57264.1.3"
	CertExtensionGithubWorkflowName       = "1.3.6.1.4.1.57264.1.4"
	CertExtensionGithubWorkflowRepository = "1.3.6.1.4.1.57264.1.5"
	CertExtensionGithubWorkflowRef        = "1.3.6.1.4.1.57264.1.6"

	CertExtensionMap = map[string]string{
		CertExtensionOIDCIssuer:               "oidcIssuer",
		CertExtensionGithubWorkflowTrigger:    "githubWorkflowTrigger",
		CertExtensionGithubWorkflowSha:        "githubWorkflowSha",
		CertExtensionGithubWorkflowName:       "githubWorkflowName",
		CertExtensionGithubWorkflowRepository: "githubWorkflowRepository",
		CertExtensionGithubWorkflowRef:        "githubWorkflowRef",
	}
)

func (ce *CertExtensions) certExtensions() map[string]string {
	extensions := map[string]string{}

	for _, ext := range ce.Cert.Extensions {
		readableName, ok := CertExtensionMap[ext.Id.String()]

		if ok {
			extensions[readableName] = string(ext.Value)
		} else {
			extensions[ext.Id.String()] = string(ext.Value)
		}
	}

	return extensions
}

// retorna o issuer para o certificado
func (ce *CertExtensions) GetIssuer() string {
	return ce.certExtensions()["oidcIssuer"]
}

func (ce *CertExtensions) GetCertExtensionGithubWorkflowTrigger() string {
	return ce.certExtensions()["githubWorkflowTrigger"]
}

func (ce *CertExtensions) GetExtensionGithubWorkflowSha() string {
	return ce.certExtensions()["githubWorkflowSha"]
}

func (ce *CertExtensions) GetCertExtensionGithubWorkflowName() string {
	return ce.certExtensions()["githubWorkflowName"]
}

func (ce *CertExtensions) GetCertExtensionGithubWorkflowRepository() string {
	return ce.certExtensions()["githubWorkflowRepository"]
}

func (ce *CertExtensions) GetCertExtensionGithubWorkflowRef() string {
	return ce.certExtensions()["githubWorkflowRef"]
}