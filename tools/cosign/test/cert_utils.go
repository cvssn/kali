package test

import (
	"crypto"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/asn1"
	"math/big"
	"net"
	"net/url"
	"time"
)

/*
para utilizar:

rootCert, rootKey, _ := GenerateRootCa()
subCert, subKey, _ := GenerateSubordinateCa(rootCert, rootKey)
leafCert, _, _ := GenerateLeafCert("subject", "oidc-issuer", subCert, subKey)

roots := x509.NewCertPool()
subs := x509.NewCertPool()
roots.AddCert(rootCert)
subs.AddCert(subCert)
opts := x509.VerifyOptions{
	Roots:         roots,
	Intermediates: subs,

	KeyUsages: []x509.ExtKeyUsage{
		x509.ExtKeyUsageCodeSigning,
	},
}

_, err := leafCert.Verify(opts)
*/

func createCertificate(template *x509.Certificate, parent *x509.Certificate, pub interface{}, priv crypto.Signer) (*x509.Certificate, error) {
	certBytes, err := x509.CreateCertificate(rand.Reader, template, parent, pub, priv)

	if err != nil {
		return nil, err
	}

	cert, err := x509.ParseCertificate(certBytes)

	if err != nil {
		return nil, err
	}

	return cert, nil
}

func GenerateRootCa() (*x509.Certificate, *ecdsa.PrivateKey, error) {
	rootTemplate := &x509.Certificate{
		SerialNumber: big.NewInt(1),

		Subject: pkix.Name{
			CommonName:   "sigstore",
			Organization: []string{"sigstore.dev"},
		},

		NotBefore:             time.Now().Add(-5 * time.Hour),
		NotAfter:              time.Now().Add(5 * time.Hour),
		KeyUsage:              x509.KeyUsageCertSign | x509.KeyUsageCRLSign,

		BasicConstraintsValid: true,
		IsCA:                  true,
	}

	priv, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	
	if err != nil {
		return nil, nil, err
	}

	cert, err := createCertificate(rootTemplate, rootTemplate, &priv.PublicKey, priv)
	
	if err != nil {
		return nil, nil, err
	}

	return cert, priv, nil
}

func GenerateSubordinateCa(rootTemplate *x509.Certificate, rootPriv crypto.Signer) (*x509.Certificate, *ecdsa.PrivateKey, error) {
	subTemplate := &x509.Certificate{
		SerialNumber: big.NewInt(1),

		Subject: pkix.Name{
			CommonName:   "sigstore-sub",
			Organization: []string{"sigstore.dev"},
		},

		NotBefore:             time.Now().Add(-2 * time.Minute),
		NotAfter:              time.Now().Add(2 * time.Hour),

		KeyUsage:              x509.KeyUsageCertSign | x509.KeyUsageCRLSign,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageCodeSigning},

		BasicConstraintsValid: true,
		IsCA:                  true,
	}

	priv, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)

	if err != nil {
		return nil, nil, err
	}

	cert, err := createCertificate(subTemplate, rootTemplate, &priv.PublicKey, rootPriv)
	
	if err != nil {
		return nil, nil, err
	}

	return cert, priv, nil
}

func GenerateLeafCertWithExpiration(subject string, oidcIssuer string, expiration time.Time, priv *ecdsa.PrivateKey, parentTemplate *x509.Certificate, parentPriv crypto.Signer) (*x509.Certificate, error) {
	certTemplate := &x509.Certificate{
		SerialNumber:   big.NewInt(1),
		EmailAddresses: []string{subject},

		NotBefore:      expiration,
		NotAfter:       expiration.Add(10 * time.Minute),

		KeyUsage:       x509.KeyUsageDigitalSignature,
		ExtKeyUsage:    []x509.ExtKeyUsage{x509.ExtKeyUsageCodeSigning},
		IsCA:           false,

		ExtraExtensions: []pkix.Extension{
			{
				// oid para extensão do emissor oidc
				Id:       asn1.ObjectIdentifier{1, 3, 6, 1, 4, 1, 57264, 1, 1},
				Critical: false,
				Value:    []byte(oidcIssuer),
			},
		},
	}

	cert, err := createCertificate(certTemplate, parentTemplate, &priv.PublicKey, parentPriv)
	
	if err != nil {
		return nil, err
	}

	return cert, nil
}

func GenerateLeafCert(subject string, oidcIssuer string, parentTemplate *x509.Certificate, parentPriv crypto.Signer, exts ...pkix.Extension) (*x509.Certificate, *ecdsa.PrivateKey, error) {
	exts = append(exts, pkix.Extension{
		// oid para extensão do emissor oidc
		Id:       asn1.ObjectIdentifier{1, 3, 6, 1, 4, 1, 57264, 1, 1},
		Critical: false,
		Value:    []byte(oidcIssuer),
	})
	certTemplate := &x509.Certificate{
		SerialNumber:    big.NewInt(1),
		EmailAddresses:  []string{subject},

		NotBefore:       time.Now().Add(-1 * time.Minute),
		NotAfter:        time.Now().Add(time.Hour),

		KeyUsage:        x509.KeyUsageDigitalSignature,
		ExtKeyUsage:     []x509.ExtKeyUsage{x509.ExtKeyUsageCodeSigning},
		IsCA:            false,
		ExtraExtensions: exts,
	}

	priv, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)

	if err != nil {
		return nil, nil, err
	}

	cert, err := createCertificate(certTemplate, parentTemplate, &priv.PublicKey, parentPriv)
	
	if err != nil {
		return nil, nil, err
	}

	return cert, priv, nil
}

func GenerateLeafCertWithGitHubOIDs(subject string, oidcIssuer string, githubWorkflowTrigger, githubWorkflowSha, githubWorkflowName,
	githubWorkflowRepository, githubWorkflowRef string, parentTemplate *x509.Certificate, parentPriv crypto.Signer) (*x509.Certificate, *ecdsa.PrivateKey, error) {
	certTemplate := &x509.Certificate{
		SerialNumber:   big.NewInt(1),
		EmailAddresses: []string{subject},

		NotBefore:      time.Now().Add(-1 * time.Minute),
		NotAfter:       time.Now().Add(time.Hour),

		KeyUsage:       x509.KeyUsageDigitalSignature,
		ExtKeyUsage:    []x509.ExtKeyUsage{x509.ExtKeyUsageCodeSigning},
		IsCA:           false,
		ExtraExtensions: []pkix.Extension{{
			// oid para a extensão do emissor oidc
			Id:       asn1.ObjectIdentifier{1, 3, 6, 1, 4, 1, 57264, 1, 1},
			Critical: false,
			Value:    []byte(oidcIssuer),
		},
			{Id: asn1.ObjectIdentifier{1, 3, 6, 1, 4, 1, 57264, 1, 2}, Value: []byte(githubWorkflowTrigger)},
			{Id: asn1.ObjectIdentifier{1, 3, 6, 1, 4, 1, 57264, 1, 3}, Value: []byte(githubWorkflowSha)},
			{Id: asn1.ObjectIdentifier{1, 3, 6, 1, 4, 1, 57264, 1, 4}, Value: []byte(githubWorkflowName)},
			{Id: asn1.ObjectIdentifier{1, 3, 6, 1, 4, 1, 57264, 1, 5}, Value: []byte(githubWorkflowRepository)},
			{Id: asn1.ObjectIdentifier{1, 3, 6, 1, 4, 1, 57264, 1, 6}, Value: []byte(githubWorkflowRef)}},
	}

	priv, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	
	if err != nil {
		return nil, nil, err
	}

	cert, err := createCertificate(certTemplate, parentTemplate, &priv.PublicKey, parentPriv)
	
	if err != nil {
		return nil, nil, err
	}

	return cert, priv, nil
}

func GenerateLeafCertWithSubjectAlternateNames(dnsNames []string, emailAddresses []string, ipAddresses []net.IP, uris []*url.URL, oidcIssuer string, parentTemplate *x509.Certificate, parentPriv crypto.Signer) (*x509.Certificate, *ecdsa.PrivateKey, error) {
	certTemplate := &x509.Certificate{
		SerialNumber:   big.NewInt(1),
		EmailAddresses: emailAddresses,
		DNSNames:       dnsNames,
		IPAddresses:    ipAddresses,
		URIs:           uris,
		
		NotBefore:      time.Now().Add(-1 * time.Minute),
		NotAfter:       time.Now().Add(time.Hour),

		KeyUsage:       x509.KeyUsageDigitalSignature,
		ExtKeyUsage:    []x509.ExtKeyUsage{x509.ExtKeyUsageCodeSigning},
		IsCA:           false,
		ExtraExtensions: []pkix.Extension{{
			// oid para extensão do emissor oidc
			Id:       asn1.ObjectIdentifier{1, 3, 6, 1, 4, 1, 57264, 1, 1},
			Critical: false,
			Value:    []byte(oidcIssuer),
		}},
	}

	priv, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	
	if err != nil {
		return nil, nil, err
	}

	cert, err := createCertificate(certTemplate, parentTemplate, &priv.PublicKey, parentPriv)
	
	if err != nil {
		return nil, nil, err
	}

	return cert, priv, nil
}