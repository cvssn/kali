#
# makefile windows para o afflib & libewf
#

# fazer
TARGETS = affcompare.exe affconvert.exe affcopy.exe affdiskprint.exe affix.exe affinfo.exe affstats.exe affxml.exe

# coisas a serem alteradas:
#
# sdk_dir é onde o windows platform sdk será instalado no computador
SDK_DIR = "C:\Program Files\Microsoft SDKs\Windows\v6.1"
OPENSSL_DIR = C:\OpenSSL

# compiler_mode especifica como você deseja que a biblioteca seja compilada
COMPILER_MODE = /MT /02 /D NDEBUG

EXPATDIR = expat-2.0.1\lib

all:	$(TARGETS)

##########################################################################


INCS =	/I.\
	/Izlib-1.2.3\ \
	/I..\include\afflib \
	/I..\lzma443\C \
	/I..\lzma443\C\7zip\Compress\LZMA_Alone \
	/I$(EXPATDIR) \
	/I$(SDK_DIR)/Include /I$(OPENSSL_DIR)/Include

DEFS = /DWIN32 /DWIN32_NT /DMSC /D_CRT_SECURE_NO_DEPRECATE /DHAVE_CONFIG_WINDOWS_H /DHAVE_LIBCRYPTO /DHAVE_OPENSSL_EVP_H /DHAVE_WINDOWS_API/DHAVE_MEMMOVE


CC=cl

# removido: /gm - habilita rebuild mínimo

OTHER_FLAGS = /c /nologo /EHsc /W2 $(COMPILER_MODE)

CPPFLAGS=$(INCS) $(DEFS) $(OTHER_FLAGS) /Fp"afflib.pch" /Fo$*.obj
CFLAGS=$(INCS) $(DEFS) $(OTHER_FLAGS) /Fp"afflib.pch" /Fo$*.obj

LZMA_OBJS =  \
	..\lzma443\C\7zip\Compress\LZMA_Alone\LzmaBench.obj \
	..\lzma443\C\7zip\Compress\LZMA_Alone\LzmaRam.obj \
	..\lzma443\C\7zip\Compress\LZMA_Alone\LzmaRamDecode.obj \
	..\lzma443\C\7zip\Compress\LZMA_C\LzmaDecode.obj \
	..\lzma443\C\7zip\Compress\Branch\BranchX86.obj \
	..\lzma443\C\7zip\Compress\LZMA\LZMADecoder.obj \
	..\lzma443\C\7zip\Compress\LZMA\LZMAEncoder.obj \
	..\lzma443\C\7zip\Compress\LZ\LZInWindow.obj \
	..\lzma443\C\7zip\Compress\LZ\LZOutWindow.obj \
	..\lzma443\C\7zip\Compress\RangeCoder\RangeCoderBit.obj \
	..\lzma443\C\7zip\Common\InBuffer.obj \
	..\lzma443\C\7zip\Common\OutBuffer.obj \
	..\lzma443\C\7zip\Common\StreamUtils.obj \
	..\lzma443\C\Common\Alloc.obj \
	..\lzma443\C\Common\CommandLineParser.obj \
	..\lzma443\C\Common\CRC.obj \
	..\lzma443\C\Common\String.obj \
	..\lzma443\C\Common\StringConvert.obj \
	..\lzma443\C\Common\StringToInt.obj \
	..\lzma443\C\Common\Vector.obj 

AFF_OBJS = ..\lib\aff_db.obj \
	..\lib\aff_toc.obj \
	..\lib\afflib.obj \
	..\lib\afflib_os.obj \
	..\lib\afflib_pages.obj \
	..\lib\afflib_stream.obj \
	..\lib\afflib_util.obj \
	..\lib\crypto.obj \
	..\lib\base64.obj \
	..\lib\lzma_glue.obj \
	..\lib\s3_glue.obj \
	..\lib\vnode_aff.obj \
	..\lib\vnode_afd.obj \
	..\lib\vnode_afm.obj \
	..\lib\vnode_raw.obj \
	..\lib\vnode_s3.obj \
	..\lib\vnode_split_raw.obj \
	..\lib\utils.obj \
	..\lib\display.obj


ZLIB_OBJS = zlib-1.2.3\adler32.obj \
	zlib-1.2.3\compress.obj \
	zlib-1.2.3\crc32.obj \
	zlib-1.2.3\deflate.obj \
	zlib-1.2.3\gzio.obj \
	zlib-1.2.3\infback.obj \
	zlib-1.2.3\inffast.obj \
	zlib-1.2.3\inflate.obj \
	zlib-1.2.3\inftrees.obj \
	zlib-1.2.3\trees.obj \
	zlib-1.2.3\uncompr.obj \
	zlib-1.2.3\zutil.obj

EXPAT_OBJS = $(EXPATDIR)\xmlparse.obj \
	   $(EXPATDIR)\xmlrole.obj \
	   $(EXPATDIR)\xmltok.obj \
	   $(EXPATDIR)\xmltok_impl.obj \
	   $(EXPATDIR)\xmltok_ns.obj

#
# win32_objs são objetos extras necessários do windows
#
WIN32_OBJS = getopt.obj

# lib_objs são todos os objetos que serão inseridos na biblioteca
LIB_OBJS = $(AFF_OBJS) $(LZMA_OBJS)  $(WIN32_OBJS) $(ZLIB_OBJS)

afflib.lib: $(LIB_OBJS)
	lib -out:afflib.lib $(LIB_OBJS)

# win32_libs são as bibliotecas que serão linkadas no win32
# ws2_32.lib = winsock 2
# advapi32.lib = dll de suporte cryptoapi (libewf utiliza a api crypto)
WIN32LIBS = ws2_32.lib advapi32.lib c:\openssl\lib\libeay32.lib

clean:
	del afflib.lib $(LIB_OBJS) $(TARGETS) > NUL 2>&1

LINK_OPTS = /libpath:$(SDK_DIR)/Lib /nodefaultlib:libc $(WIN32LIBS)

afftest.exe: ..\lib\aftest.obj afflib.lib
	link -out:afftest.exe ..\lib\afftest.obj afflib.lib $(LINK_OPTS)	    

affcat.exe: ..\tools\affcat.obj afflib.lib
	link -out:affcat.exe ..\tools\affcat.obj afflib.lib $(LINK_OPTS)

affcopy.exe: ..\tools\affcopy.obj ..\tools\aff_bom.obj afflib.lib 
	link -out:affcopy.exe ..\tools\affcopy.obj ..\tools\aff_bom.obj afflib.lib $(LINK_OPTS)

affcompare.exe: ..\tools\affcompare.obj afflib.lib 
	link -out:affcompare.exe ..\tools\affcompare.obj afflib.lib $(LINK_OPTS)

affconvert.exe: ..\tools\affconvert.obj afflib.lib
	link -out:affconvert.exe ..\tools\affconvert.obj afflib.lib $(LINK_OPTS)

affdiskprint.exe: ..\tools\affdiskprint.obj afflib.lib $(EXPAT_OBJS)
	link -out:affdiskprint.exe ..\tools\affdiskprint.obj ..\tools\aff_bom.obj afflib.lib $(EXPAT_OBJS) $(LINK_OPTS) 

affix.exe: ..\tools\affix.obj afflib.lib
	link -out:affix.exe ..\tools\affix.obj afflib.lib $(LINK_OPTS)

affinfo.exe: ..\tools\affinfo.obj afflib.lib
	link -out:affinfo.exe ..\tools\affinfo.obj afflib.lib $(LINK_OPTS)

affsegment.exe: ..\tools\affsegment.obj afflib.lib
	link -out:affsegment.exe ..\tools\affsegment.obj afflib.lib $(LINK_OPTS)

affstats.exe: ..\tools\affstats.obj afflib.lib
	link -out:affstats.exe ..\tools\affstats.obj afflib.lib $(LINK_OPTS)

affxml.exe: ..\tools\affxml.obj  afflib.lib
	link -out:affxml.exe ..\tools\affxml.obj  afflib.lib $(LINK_OPTS)