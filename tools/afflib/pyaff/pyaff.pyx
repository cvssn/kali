import sys
from cpython.version cimport PY_MAJOR_VERSION
cimport afflib

"""abrir arquivo afflib (ou configurar arquivos)"""
def open(filename):
    return affile(filename)

"""objeto file do afflib"""
cdef class affile(object):
    def __cinit__(self, basestring filename):
        self.af = afflib.af_open(filename.encode(sys.getfilesystemencoding()), afflib.O_RDONLY, 0)

        if self.af == NULL:
            raise IOError("falha ao inicializar o afflib")

        self.size = afflib.af_get_imagesize(self.af)

    """ler dado do arquivo"""
    def read(self, int size=-1):
        readlen = size if 0 <= size <= self.size else self.size

        retdata = bytearray(readlen)
        written = afflib.af_read(self.af, retdata, size)

        if written != readlen:
            raise IOError("falha ao ler todos os dados: wanted {}, got {}".format(readlen, written))

        return bytes(retdata)

    """procurar dentro de um arquivo"""
    def seek(self, int offset, int whence=0):
        if afflib.af_seek(self.af, offset, whence) < 0:
            raise IOError("libaff_seek_offset failed")

    """recuperar um segmento aff por nome"""
    def get_seg(self, basestring segname):
        cdef size_t buflen = 0
        cdef _segname = segname.encode('ascii')

        if afflib.af_get_seg(self.af, _segname, NULL, NULL, &buflen) != 0:
            raise IOError("erro ao ler o segmento libaff")

        print(buflen)

        retdata = bytearray(buflen)

        if afflib.af_get_seg(self.af, _segname, NULL, retdata, &buflen) != 0:
            raise IOError("erro ao ler o segmento libaff")

        return bytes(retdata)

    """recuperar uma lista de segmentos presentes"""
    def get_seg_names(self):
        headers = []

        segname = bytearray(afflib.AF_MAX_NAME_LEN)

        afflib.af_rewind_seg(self.af)

        while afflib.af_get_next_seg(self.af, segname, len(segname), NULL, NULL, NULL) == 0:
            if PY_MAJOR_VERSION < 3:
                headers.append(<char*> segname)
            else:
                headers.append((<char*> segname).decode('ascii'))

        return headers

    """posição de retorno dentro do arquivo"""
    def tell(self):
        return afflib.af_tell(self.af)

    """fechar o arquivo"""
    def close(self):
        afflib.af_close(self.af)