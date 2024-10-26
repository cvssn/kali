package oci

import v1 "github.com/google/go-containerregistry/pkg/v1"

// signedimage representa uma imagem oci
type SignedImage interface {
	v1.Image
	SignedEntity
}