# módulo para localizar a biblioteca de encriptação do crypto++
#
# variáveis customizáveis:
#     cryptopp_root_dir
#         essa variável pontua para o diretório root do cryptopp
#
# variáveis apenas para leitura:
#     cryptopp_found
#         indica se a biblioteca foi encontrada
#
#     cryptopp_include_dirs
#         aponta para o diretório de inclusão do cryptopp
#
#     cryptopp_libraries
#         aponta para as bibliotecas cryptopp que devem ser passadas para target_link_libararies

INCLUDE (FindPackageHandleStandardArgs)

FIND_PATH (CRYPTOPP_ROOT_DIR
    NAMES cryptopp/cryptlib.h include/cryptopp/cryptlib.h
    PATHS ENV CRYPTOPPROOT
    DOC "diretório root cryptopp")

# reutiliza o path anterior
FIND_PATH (CRYPTOPP_INCLUDE_DIR
    NAMES cryptopp/cryptlib.h
    HINTS ${CRYPTOPP_ROOT_DIR}
    PATH_SUFFIXES include
    DOC "cryptopp inclui diretório")

FIND_LIBRARY (CRYPTOPP_LIBRARY_DEBUG
    NAMES cryptlibd cryptoppd
    HINTS ${CRYPTOPP_ROOT_DIR}
    PATH_SUFFIXES lib
    DOC "biblioteca de depuração cryptopp")

FIND_LIBRARY (CRYPTOPP_LIBRARY_RELEASE
    NAMES cryptlib cryptopp
    HINTS ${CRYPTOPP_ROOT_DIR}
    PATH_SUFFIXES lib
    DOC "biblioteca de lançamento cryptopp")

IF (CRYPTOPP_LIBRARY_DEBUG AND CRYPTOPP_LIBRARY_RELEASE)
    SET (CRYPTOPP_LIBRARY
        optimized ${CRYPTOPP_LIBRARY_RELEASE}
        debug ${CRYPTOPP_LIBRARY_DEBUG} CACHE DOC "biblioteca cryptopp")
ELSEIF (CRYPTOPP_LIBRARY_RELEASE)
    SET (CRYPTOPP_LIBRARY ${CRYPTOPP_LIBRARY_RELEASE} CACHE DOC
        "biblioteca cryptopp")
ENDIF (CRYPTOPP_LIBRARY_DEBUG AND CRYPTOPP_LIBRARY_RELEASE)

IF (CRYPTOPP_INCLUDE_DIR)
    SET (_CRYPTOPP_VERSION_HEADER ${CRYPTOPP_INCLUDE_DIR}/cryptopp/config_ver.h)

    IF (NOT EXISTS ${_CRYPTOPP_VERSION_HEADER})
        SET (_CRYPTOPP_VERSION_HEADER ${CRYPTOPP_INCLUDE_DIR}/cryptopp/config.h)
    ENDIF (NOT EXISTS ${_CRYPTOPP_VERSION_HEADER})

    IF (EXISTS ${_CRYPTOPP_VERSION_HEADER})
        FILE (STRINGS ${_CRYPTOPP_VERSION_HEADER} _CRYPTOPP_VERSION_TMP REGEX
            "^#define CRYPTOPP_VERSION[ \t]+[0-9]+$")

        STRING (REGEX REPLACE
            "^#define CRYPTOPP_VERSION[ \t]+([0-9]+)" "\\1" _CRYPTOPP_VERSION_TMP
            ${_CRYPTOPP_VERSION_TMP})

        STRING (REGEX REPLACE "([0-9]+)[0-9][0-9]" "\\1" CRYPTOPP_VERSION_MAJOR
            ${_CRYPTOPP_VERSION_TMP})
        STRING (REGEX REPLACE "[0-9]([0-9])[0-9]" "\\1" CRYPTOPP_VERSION_MINOR
            ${_CRYPTOPP_VERSION_TMP})
        STRING (REGEX REPLACE "[0-9][0-9]([0-9])" "\\1" CRYPTOPP_VERSION_PATCH
            ${_CRYPTOPP_VERSION_TMP})

        SET (CRYPTOPP_VERSION_COUNT 3)
        SET (CRYPTOPP_VERSION
            ${CRYPTOPP_VERSION_MAJOR}.${CRYPTOPP_VERSION_MINOR}.${CRYPTOPP_VERSION_PATCH})
    ENDIF (EXISTS ${_CRYPTOPP_VERSION_HEADER})
ENDIF (CRYPTOPP_INCLUDE_DIR)

SET (CRYPTOPP_INCLUDE_DIRS ${CRYPTOPP_INCLUDE_DIR})
SET (CRYPTOPP_LIBRARIES ${CRYPTOPP_LIBRARY})

MARK_AS_ADVANCED (CRYPTOPP_INCLUDE_DIR CRYPTOPP_LIBRARY CRYPTOPP_LIBRARY_DEBUG
    CRYPTOPP_LIBRARY_RELEASE)

FIND_PACKAGE_HANDLE_STANDARD_ARGS (CryptoPP REQUIRED_VARS CRYPTOPP_ROOT_DIR
    CRYPTOPP_INCLUDE_DIR CRYPTOPP_LIBRARY VERSION_VAR CRYPTOPP_VERSION)