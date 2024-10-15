#ifndef ZIP7_INC_7Z_H
#define ZIP7_INC_7Z_H

#include "7zTypes.h"

EXTERN_C_BEGIN

#define k7zStartHeaderSize 0x20
#define k7zSignatureSize 6

extern const Byte k7zSignature[k7zSignatureSize];

typedef struct
{
    const Byte *Data;
    size_t Size;
} CSzData;

/* cszcoderinfo & cszfolder suportam apenas métodos padrões */

typedef struct
{
    size_t PropsOffset;
    UInt32 MethodID;
    Byte NumStreams;
    Byte PropsSize;
} CSzCoderInfo;

typedef struct
{
    UInt32 InIndex;
    UInt32 OutIndex;
} CSzBond;

#define SZ_NUM_CODERS_IN_FOLDER_MAX 4
#define SZ_NUM_BONDS_IN_FOLDER_MAX 3
#define SZ_NUM_PACK_STREAMS_IN_FOLDER_MAX 4

typedef struct
{
    UInt32 NumCoders;
    UInt32 NumBonds;
    UInt32 NumPackStreams;
    UInt32 UnpackStream;

    UInt32 PackStreams[SZ_NUM_PACK_STREAMS_IN_FOLDER_MAX];
    CSzBond Bonds[SZ_NUM_BONDS_IN_FOLDER_MAX];
    CSzCoderInfo Coders[SZ_NUM_CODERS_IN_FOLDER_MAX];
} CSzFolder;


SRes SzGetNextFolderItem(CSzFolder *f, CSzData *sd);

typedef struct
{
    UInt32 Low;
    UInt32 High;
} CNtfsFileTime;

typedef struct
{
    Byte *Defs; /* numeração de bits msb 0 */
    UInt32 *Vals;
} CSzBitUi32s;

typedef struct
{
    Byte *Defs; /* numeração de bits msb 0 */
    // UInt64 *Vals;
    CNtfsFileTime *Vals;
} CSzBitUi64s;

#define SzBitArray_Check(p, i) (((p)[(i) >> 3] & (0x80 >> ((i) & 7))) != 0)

#define SzBitWithVals_Check(p, i) ((p)->Defs && ((p)->Defs[(i) >> 3] & (0x80 >> ((i) & 7))) != 0)

typedef struct
{
    UInt32 NumPackStreams;
    UInt32 NumFolders;

    UInt64 *PackPositions;          // NumPackStreams + 1
    CSzBitUi32s FolderCRCs;         // NumFolders

    size_t *FoCodersOffsets;        // NumFolders + 1
    UInt32 *FoStartPackStreamIndex; // NumFolders + 1
    UInt32 *FoToCoderUnpackSizes;   // NumFolders + 1
    Byte *FoToMainUnpackSizeIndex;  // NumFolders
    UInt64 *CoderUnpackSizes;       // para todos os codificadores em todas as pastas

    Byte *CodersData;

    UInt64 RangeLimit;
} CSzAr;

UInt64 SzAr_GetFolderUnpackSize(const CSzAr *p, UInt32 folderIndex);

SRes SzAr_DecodeFolder(const CSzAr *p, UInt32 folderIndex,
    ILookInStreamPtr stream, UInt64 startPos,
    Byte *outBuffer, size_t outSize,
    ISzAllocPtr allocMain);

typedef struct
{
    CSzAr db;

    UInt64 startPosAfterHeader;
    UInt64 dataPos;
    
    UInt32 NumFiles;

    UInt64 *UnpackPositions;  // NumFiles + 1
    // Byte *IsEmptyFiles;
    Byte *IsDirs;
    CSzBitUi32s CRCs;

    CSzBitUi32s Attribs;
    // CSzBitUi32s Parents;
    CSzBitUi64s MTime;
    CSzBitUi64s CTime;

    UInt32 *FolderToFile;   // NumFolders + 1
    UInt32 *FileToFolder;   // NumFiles

    size_t *FileNameOffsets; /* in 2-byte steps */
    Byte *FileNames;  /* UTF-16-LE */
} CSzArEx;

#define SzArEx_IsDir(p, i) (SzBitArray_Check((p)->IsDirs, i))

#define SzArEx_GetFileSize(p, i) ((p)->UnpackPositions[(i) + 1] - (p)->UnpackPositions[i])

void SzArEx_Init(CSzArEx *p);
void SzArEx_Free(CSzArEx *p, ISzAllocPtr alloc);

UInt64 SzArEx_GetFolderStreamPos(const CSzArEx *p, UInt32 folderIndex, UInt32 indexInFolder);
int SzArEx_GetFolderFullPackSize(const CSzArEx *p, UInt32 folderIndex, UInt64 *resSize);

size_t SzArEx_GetFileNameUtf16(const CSzArEx *p, size_t fileIndex, UInt16 *dest);

/*
size_t SzArEx_GetFullNameLen(const CSzArEx *p, size_t fileIndex);
UInt16 *SzArEx_GetFullNameUtf16_Back(const CSzArEx *p, size_t fileIndex, UInt16 *dest);
*/


SRes SzArEx_Extract(
    const CSzArEx *db,
    ILookInStreamPtr inStream,
    UInt32 fileIndex,         /* index do arquivo */
    UInt32 *blockIndex,       /* index do bloco sólido */
    Byte **outBuffer,         /* ponteiro para ponteiro para buffer de saída (alocado com allocmain) */
    size_t *outBufferSize,    /* tamanho do buffer para buffer de saída */
    size_t *offset,           /* deslocamento do fluxo para o arquivo necessário em *outbuffer */
    size_t *outSizeProcessed, /* tamanho do arquivo em *outbuffer */
    ISzAllocPtr allocMain,
    ISzAllocPtr allocTemp);


/*
SzArEx_Open Errors:
SZ_ERROR_NO_ARCHIVE
SZ_ERROR_ARCHIVE
SZ_ERROR_UNSUPPORTED
SZ_ERROR_MEM
SZ_ERROR_CRC
SZ_ERROR_INPUT_EOF
SZ_ERROR_FAIL
*/

SRes SzArEx_Open(CSzArEx *p, ILookInStreamPtr inStream,
    ISzAllocPtr allocMain, ISzAllocPtr allocTemp);

EXTERN_C_END

#endif