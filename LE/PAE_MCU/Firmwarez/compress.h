#ifndef __COMPRESS_H_
#define __COMPRESS_H_

#ifdef __cplusplus
extern "C" {
#endif

typedef unsigned char (*read_func_type)(unsigned long addr);

void arithmetic_compress(const unsigned char* buf, unsigned long buf_size, unsigned char* cbuf, unsigned long* cbuf_size);
unsigned char arithmetic_decompress_init(read_func_type read_func, unsigned long cbuf_size);
void arithmetic_decompress_chunk(unsigned char* chunk, volatile unsigned int chunk_size, unsigned int* decompressed);
void arithmetic_decompress_done(void);

#ifdef __cplusplus
} // extern "C" 
#endif

#endif // __COMPRESS_H_
