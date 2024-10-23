package cosign

import (
	"context"
	"crypto"
	"io"

	"github.com/sigstore/cosign/v2/pkg/oci"
)

// dsseattestor cria atestações na forma de `oci.signature`
type DSSEAttestor interface {
	DSSEAttest(ctx context.Context, payload io.Reader) (oci.Signature, crypto.PublicKey, error)
}