#include <setjmp.h>
#include "compress.h"

//--------------------------------------------------------------------------------

#ifndef __KEIL__
 #ifdef __BORLANDC__
 #pragma warn -8065
 #endif	//__BORLANDC__
#endif	//__KEIL__

//--------------------------------------------------------------------------------

/*
    (C) �. ���������, "�������", N1, 1994.
    ��������� ������ ����������
*/

// ���������� ����� � ��������
#define BITS_IN_REGISTER 16

// ����������� ��������� �������� � ��������
#define TOP_VALUE (((long) 1 << BITS_IN_REGISTER) - 1)

// ���������
#define FIRST_QTR (TOP_VALUE / 4 + 1)
#define HALF      (2 * FIRST_QTR)
#define THIRD_QTR (3 * FIRST_QTR)

// ���������� �������� ��������
#define NO_OF_CHARS 256
// ����������� ������ ����������
#define EOF_SYMBOL    (NO_OF_CHARS + 1)
// ����� �������� � ������
#define NO_OF_SYMBOLS (NO_OF_CHARS + 1)

// ����� ������� ��� ���������������
#define MAX_FREQUENCY 16383

// ������� �������������
static unsigned char index_to_char [NO_OF_SYMBOLS];
static int char_to_index [NO_OF_CHARS];

// ������� ������
static int cum_freq [NO_OF_SYMBOLS + 1];
static int freq[NO_OF_SYMBOLS + 1];

// �������� ������ � ����
static long low, high;
static long value;

// ��������� ��������� �������� � �������
static long bits_to_follow;
static int	buffer;
static int	bits_to_go;
static int  garbage_bits;

// ������� � �������� ������
static unsigned long inbuf_pos;
static unsigned long inbuf_size;
static unsigned char *outbuf;
static unsigned long outbuf_pos;

static read_func_type read_byte_func;

// setjmp/longjmp
static jmp_buf mark;

int input_bit();
void start_model();


//////////////////////////////////////////////////
// ������������� ���������� ������

static void start_model()
{
    int i;

    for ( i = 0; i < NO_OF_CHARS; i++)
    {
        char_to_index[i] = i + 1;
        index_to_char[i + 1] = i;
    }
    for (i = 0; i <= NO_OF_SYMBOLS; i++)
    {
        freq[i] = 1;
        cum_freq[i] = NO_OF_SYMBOLS - i;
    }
    freq [0] = 0;
}

//////////////////////////////////////////////////
// ���������� ������ ��������� ��������

static void update_model (int symbol)
{
    int i;
    int ch_i, ch_symbol;
    int cum;

    // �������� �� ������������ �������� �������
    if (cum_freq [0] == MAX_FREQUENCY)
    {
        cum = 0;
        // ��������������� ������ ��� ������������
        for ( i = NO_OF_SYMBOLS; i >= 0; i--)
        {
            freq [i] = (freq [i] + 1) / 2;
            cum_freq [i] = cum;
            cum += freq [i];
        }
    }
    for ( i = symbol; freq [i] == freq [i - 1]; i--);
    if (i < symbol)
    {
        ch_i                      = index_to_char [i];
        ch_symbol                 = index_to_char [symbol];
        index_to_char [i]         = ch_symbol;
        index_to_char [symbol]    = ch_i;
        char_to_index [ch_i]      = symbol;
        char_to_index [ch_symbol] = i;
    }
    // ���������� �������� � �������� ������
    freq [i] += 1;
    while (i > 0)
    {
        i -= 1;
        cum_freq [i] += 1;
    }
}

//////////////////////////////////////////////////
// ������������� ���������� �����

void start_inputing_bits()
{
    bits_to_go = 0;
    garbage_bits = 0;
}

//////////////////////////////////////////////////
// ���� ���������� ���� ������ ����������

static int input_bit()
{
    int t;

    if (bits_to_go == 0)
    {
        buffer = (*read_byte_func)(inbuf_pos++);
        if (inbuf_pos == inbuf_size)
        {
            garbage_bits += 1;
            if (garbage_bits > BITS_IN_REGISTER - 2)
            {
                longjmp(mark, -1);
            }
        }
        bits_to_go = 8;
    }
    t = buffer & 1;
    buffer >>= 1;
    bits_to_go -= 1;
    return t;
}

#ifndef	__KEIL__

//////////////////////////////////////////////////
// ������������� ���������� ������

static void start_outputing_bits()
{
    buffer = 0;
    bits_to_go = 8;
}

//////////////////////////////////////////////////
// ����� ���������� ���� ������ ����������

static void output_bit(int bt)
{
    buffer >>= 1;
    if (bt)
        buffer |= 0x80;
    bits_to_go -= 1;
    if (bits_to_go == 0)
    {
        outbuf[outbuf_pos++] = buffer;
        bits_to_go = 8;
    }
}

//////////////////////////////////////////////////
// ������� ������ ���������� ������

static void done_outputing_bits()
{
    outbuf[outbuf_pos++] = buffer >> bits_to_go;
}

//////////////////////////////////////////////////
// ����� ���������� ���� � ���������� �����

static void output_bit_plus_follow(int bt)
{
    output_bit(bt);
    while (bits_to_follow > 0)
    {
        output_bit(!bt);
        bits_to_follow--;
    }
}

//////////////////////////////////////////////////
// ������������� ��������� ������ � ���� ����� ������� ������

static void start_encoding()
{
    low = 0l;
    high = TOP_VALUE;
    bits_to_follow = 0l;
}

//////////////////////////////////////////////////
// ������� ���������� ������

static void done_encoding()
{
    bits_to_follow++;
    if (low < FIRST_QTR)
        output_bit_plus_follow(0);
    else
        output_bit_plus_follow(1);
}

//////////////////////////////////////////////////
// ����������� ���������� �������

static void encode_symbol ( int symbol)
{
    long range;

    // �������� �������� ������
    range = (long) (high - low) + 1;
    high = low + (range * cum_freq [symbol - 1]) / cum_freq [0] - 1;
    low = low + (range * cum_freq [symbol]) / cum_freq [0];
    // ���������� ��������� �����
    for (;;)
    {
        if (high < HALF)
            output_bit_plus_follow(0);
        else if (low >= HALF)
        {
            output_bit_plus_follow(1);
            low -= HALF;
            high -= HALF;
        }
        else if (low >= FIRST_QTR && high < THIRD_QTR)
        {
            bits_to_follow += 1;
            low -= FIRST_QTR;
            high -= FIRST_QTR;
        }
        else
            break;
        // ����� ����� � "�����������" ���������� ����
        low = 2 * low;
        high = 2 * high + 1;
    }
}
#endif	//__KEIL__

//////////////////////////////////////////////////
// ������������� ��������� ����� ��������������.
// �������� ������ ������� ���������

static void start_decoding()
{
    int i;

    value = 0l;
    for ( i = 1; i <= BITS_IN_REGISTER; i++)
        value = 2 * value + input_bit ();
    low = 0l;
    high = TOP_VALUE;
}

//////////////////////////////////////////////////
// ������������� ���������� �������

static int decode_symbol()
{
    long range;
    int cum, symbol;

    // ����������� �������� �������� ������
    range = (long) (high - low) + 1;
    // ��������������� �������� � �������� ����
    cum = (int)
        ((((long) (value - low) + 1) * cum_freq [0] - 1) / range);
    // ����� ���������������� ������� � ������� ������
    for (symbol = 1; cum_freq [symbol] > cum; symbol++);
    // �������� ������
    high = low + (range * cum_freq [symbol - 1]) / cum_freq [0] - 1;
    low = low + (range * cum_freq [symbol]) / cum_freq [0];
    // �������� ���������� ������� �� �������� ������
    for (;;)
    {
        if (high < HALF)
        {
        }
        else if (low >= HALF)
        {
            value -= HALF;
            low -= HALF;
            high -= HALF;
        }
        else if (low >= FIRST_QTR && high < THIRD_QTR)
        {
            value -= FIRST_QTR;
            low -= FIRST_QTR;
            high -= FIRST_QTR;
        }
        else
            break;
        // ����� ����� � "����������� ���������� ����
        low = 2 * low;
        high = 2 * high + 1;
        value = 2 * value + input_bit ();
    }
    return symbol;
}

#ifndef	__KEIL__
//////////////////////////////////////////////////
// ���������� �������������� �����������
// ���������:
// buf - ������� �����;
// buf_size - ������ �������� ������;
// cbuf - ����� ��� ������ ������;
// cbuf_size - ������ ������ ������.

void arithmetic_compress(const unsigned char* buf, unsigned long buf_size, unsigned char* cbuf, unsigned long* cbuf_size)
{
    unsigned long i;
    int ch, symbol;

    outbuf = cbuf;
    outbuf_pos = 0;

    start_model();
    start_outputing_bits();
    start_encoding();

    for (i = 0; i < buf_size; i++)
    {
        ch = buf[i];
        symbol = char_to_index[ch];
        encode_symbol(symbol);
        update_model(symbol);
    }

    encode_symbol(EOF_SYMBOL);
    done_encoding();
    done_outputing_bits();

    *cbuf_size = outbuf_pos;
}

#endif	//__KEIL__

//////////////////////////////////////////////////
// arithmetic_decompress_init()
// ������������� ��������
// read_func - ������ ������ �� ������ �� ������� �������;
//
// !!!! KEIL C WORKAROUND !!!
// ��������� �� ������� ������� ������� ���������:
// http://www.keil.com/appnotes/files/apnt_129.pdf
// !!!! END OF WORKAROUND !!!
//
// cbuf_size - ������ ������ �� ������� �������.

unsigned char arithmetic_decompress_init(read_func_type read_func, unsigned long cbuf_size)
{
    if (setjmp(mark) != 0)
    {
        return 0;
    }

    read_byte_func = read_func;
    inbuf_pos = 0;
    inbuf_size = cbuf_size;

    start_model();
    start_inputing_bits();
    start_decoding();

    return 1;
}

//////////////////////////////////////////////////
// arithmetic_decompress_done
// 

void arithmetic_decompress_done()
{
    // nothing to do
}

//////////////////////////////////////////////////
// ���������� �������������� �������������
// ���������:
// chunk - ����� ��� �������� ������;
// chunk_size - ������ ������;
// decompressed - ������ �������� ������.

void arithmetic_decompress_chunk(unsigned char* chunk, volatile unsigned int chunk_size, unsigned int* decompressed)
{
    unsigned long i;
    int ch, symbol;

	if (inbuf_pos >= inbuf_size)
	{
        *decompressed = 0;
        return;
	}

    if (setjmp(mark) != 0)
    {
        *decompressed = 0;
        return;
    }

    outbuf = chunk;
    outbuf_pos = 0;

    for (i = 0; i < chunk_size; i++)
    {
        symbol = decode_symbol();
        if (symbol == EOF_SYMBOL)
            break;
        ch = index_to_char[symbol];
        outbuf[outbuf_pos++] = ch;
        update_model(symbol);
    }

    *decompressed = outbuf_pos;
}

//////////////////////////////////////////////////

