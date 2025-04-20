// ps2.h
#include <LPC23xx.h>
#include <stdbool.h>

#define kuku 1

#define clr_clk FIO1SET	|= (1 << 25); // clk --|__	
#define clr_data FIO1SET	|= (1 << 29); // data --|__		
#define set_clk FIO1CLR	|= (1 << 25); // clk __|--
#define read_bit read_data_bit = ~(FIO1PIN >> 28) & 1;
#define set_data_bit FIO1CLR |= (1 << 29);
#define clear_data_bit FIO1SET |= (1 << 29);

#define mouse_answer_timeout_const 20000
#define ps2_transmit_delay 3

const unsigned char zx_key_byte[] = {
    0x12, 0x1c, 0x15, 0x16, 0x45, 0x4d, 0x5a, 0x29, 
//  cs    a     q     1     0     p     enter space
    0x1a, 0x1b, 0x1d, 0x1e, 0x46, 0x44, 0x4b, 0x11, 
//  z     s     w     2     9     o     l     ss
    0x22, 0x23, 0x24, 0x26, 0x3e, 0x43, 0x42, 0x3a, 
//  x     d     e     3     8     i     k     m
    0x21, 0x2b, 0x2d, 0x25, 0x3d, 0x3c, 0x3b, 0x31, 
//  c     f     r     4     7     u     j     n
    0x2a, 0x34, 0x2c, 0x2e, 0x36, 0x35, 0x33, 0x32 };
//  v     g     t     5     6     y     h     b
		
volatile unsigned char keyarray[5] = {0xff, 0xff, 0xff, 0xff, 0xff};
volatile unsigned char bit_counter = 0;
volatile unsigned char scan_code = 0;
volatile bool unpush = false;
volatile bool long_scan_code = false;
volatile bool klava = false;
volatile bool reset = false;
volatile bool magic = false;
volatile bool keyboard_error = false;

void translate(unsigned char scode);

volatile bool shift_flag;
volatile bool ctrl_flag;
volatile bool backspace_flag = false;

volatile unsigned char mouse_ok = 0;

volatile unsigned int mouse = 0;
volatile bool myshko_flag;
volatile unsigned char m_bit_counter;
volatile unsigned char m_code;
volatile unsigned int mouse_answer_timeout = 0;
volatile unsigned char mouse_last_data = 0;
volatile char m_x;
volatile char m_y;
volatile unsigned char m_b;
volatile unsigned char y_s;
volatile unsigned char x_s;
volatile unsigned char ps2_transmit_flag0 = 0;
volatile unsigned char ps2_transmit_flag1 = 0;
volatile bool mouse_wheel = 0;
volatile unsigned char mouse_data;
volatile unsigned char ps2_parity_num;
volatile bool mouse_read_error=0;
volatile bool mouse_write_error=0;
volatile unsigned int m_timeout = 0;
volatile unsigned char mouse_stop_timeout = 10;
volatile unsigned char keyboard_stop_timeout = 10;
volatile unsigned char antiopt = 0;

volatile unsigned char m_byte_number;
volatile unsigned char new_byte_timeout = 0;
void ps2_init(void);
void mouse_transaction(void);
bool mouse_data_transmit(unsigned char data);
void mouse_restart(void);
char m_parser(char mc);
void caps_shift(void);
void symbol_shift(void);
void ctrl(void);
void obrabotka(unsigned char scode);
void interrupt(unsigned char input_bit);
void reset_error(void);
bool mouse_setup(void);

extern volatile unsigned int timeout;
extern volatile bool keyboard_switch_flag;
extern void additional_action(unsigned char unpush, unsigned char scode);

