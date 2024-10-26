package oci

import "fmt"

type MaxLayersExceeded struct {
	value   int64
	maximum int64
}

func NewMaxLayersExceeded(value, maximum int64) *MaxLayersExceeded {
	return &MaxLayersExceeded{value, maximum}
}

func (e *MaxLayersExceeded) Error() string {
	return fmt.Sprintf("o número de camadas (%d) excedeu o limite (%d)", e.value, e.maximum)
}