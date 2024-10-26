package oci

import "github.com/google/go-containerregistry/pkg/v1/types"

type File interface {
	SignedImage

	FileMediaType() (types.MediaType, error)

	Payload() ([]byte, error)
}