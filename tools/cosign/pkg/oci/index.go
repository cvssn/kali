package oci

import v1 "github.com/google/go-containerregistry/pkg/v1"

// signedindex representa uma imageindex oci
type SignedImageIndex interface {
	v1.ImageIndex
	SignedEntity

	// signedimage é o mesmo que a imagem
	SignedImage(v1.Hash) (SignedImage, error)

	// signedimageindex é o mesmo que imageindex
	SignedImageIndex(v1.Hash) (SignedImageIndex, error)
}