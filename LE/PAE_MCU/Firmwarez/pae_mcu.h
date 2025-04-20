#ifndef __pae_mcu_H
#define __pae_mcu_H

#include <LPC23xx.h>
#include <STDLIB.h>
#include <absacc.h>
#include "compress.h"
#include "type.h"
#include "usb.h"
#include "usbcfg.h"
#include "usbhw.h"
#include "usbcore.h"
#include "hiduser.h"
#include <stdbool.h>
#include <stdint.h>
#include "string.h"	// ��� ������ �� ��������, strlen
#include "integer.h"
#include "diskio.h"
#include "ff.h"

#define pll_pause \
{	\
		volatile int i;	\
		for(i = 0; i < 100000; i++);	\
}

#define fpga_pause \
{ \
	fpga_timing = 0; \
	while(fpga_timing < fpga_timing_const) {}; \
} 

#define	BUFSIZE 512
static unsigned char buffer[BUFSIZE];
		
#define condition_1 ((cycle_counter == 0) && (send_data_flag == 0xff) && get_fpga_data_flag && get_cmos_status_flag && fpga_data_transmit_flag == 0xff)
#define condition_2 ((cycle_counter == 1) && timer_flag)
#define condition_3 ((send_data_flag == 0xff) && get_fpga_data_flag && get_cmos_status_flag && ((fpga_data_transmit_flag == 0xff) || myshko_flag))		
#define condition_4	((cycle_counter == 2) && (send_data_flag == 0xff) && get_fpga_data_flag && get_cmos_status_flag && (fpga_data_transmit_flag == 0xff))
#define condition_5 ((cycle_counter == 3) && (send_data_flag == 0xff) && get_fpga_data_flag && get_cmos_status_flag && (fpga_data_transmit_flag == 0xff))
#define condition_6 ((cycle_counter == 4) && print_flag && (send_data_flag == 0xff ) && get_fpga_data_flag && get_cmos_status_flag && (fpga_data_transmit_flag == 0xff))
#define condition_7 ((cycle_counter == 5) && (send_data_flag == 0xff) && get_fpga_data_flag && get_cmos_status_flag)
		
#define fpga_timing_const 3
volatile unsigned char fpga_timing = 0;	

#define pll_timing_const 5000
volatile unsigned int pll_timing = 0;	

#define mcu_firmware_date "20.04.2025"

volatile UINT Timer_div = 0;		/* Performance timer (1kHz increment) */
volatile UINT Timer = 0;		/* Performance timer (1kHz increment) */
		
volatile unsigned char test_counter=0;		
		
volatile unsigned long mojno_boot __at (0x40007FF8);
volatile unsigned long cmos __at (0xE0084000);

volatile unsigned long *cmos_a;
unsigned long cmos_d;

unsigned char *data_base_addr = 0;

unsigned char ReadAddrFnc(unsigned long addr);

extern unsigned char basic48[];	
extern unsigned long basic48_size;
extern unsigned char basic128[];	
extern unsigned long basic128_size;
extern unsigned char trdos[];	
extern unsigned long trdos_size;
extern unsigned char gluk[];	
extern unsigned long gluk_size;
extern unsigned char logo[];	
extern unsigned long logo_size;
extern unsigned char fpga[];	
extern unsigned long fpga_size;
extern unsigned char fatall[];	
extern unsigned long fatall_size;

#define ps2_transmit_delay 3
extern volatile unsigned char bit_counter;

void rom_from_rom(unsigned char page, unsigned long size);

char trd_to_ram(char* filename);

void upload_firmwarez(void);

void fpga_send_data(char data, unsigned int skoka);
void fpga_send_command(char command);
void upload_from_rom(void);
char upload_from_sd(char* filename);
char screen_from_sd(char* filename);
char rom_from_sd(unsigned char page, char* filename);

void sd_spi_unsetup(void);
char sd_error;
#define	i2c_bufsize 16384

volatile unsigned char fpga_data_transmit_flag;

volatile unsigned char get_cmos_data_flag;
volatile bool cmos_ready = false;

void get_fpga_data(void);

void timer0_irq(void) __irq;	// priority = 0
void timer1_irq(void) __irq;	// priority = 1
void i2c_irq(void) __irq; 		// priority = 14
void start_bootloader(void);
volatile bool bootloader =false;

void sd_spi_setup(void);
void sd_spi_unsetup(void);


void short_pause(void);
void very_short_pause(void);
void spi_fpga_init(void);
void fpga_init(void);
char fpga_spi_send(unsigned char spi_data);
char upload_from_sd(char* filename);
void pll_setup(void);
void pwm_setup(void);
void timer0_setup(void);
void timer1_setup(void);
DWORD get_fattime (void);


extern bool mouse_data_transmit(unsigned char data);
extern volatile unsigned char new_byte_timeout;
extern volatile bool unpush;
extern volatile bool long_scan_code;
void upload_data(void);
void klava_int(void);
void mouse_int(void);
void caps_shift(void);
void symbol_shift(void);
void z80_reset(void);


void gpio_i2c_setup(void);
void gpio_fpga_send_command(char command);
void gpio_fpga_send_data(char data, unsigned int skoka);

void get_cmos_status(void);

void rtc_setup(void);

void led0_on(void);
void led0_off(void);
void led1_on(void);
void led1_off(void);
void get_cmos_data(unsigned char status);
void transmit_cmos_data(void);

void GetInReport(void);
void SetOutReport(void);

void kempston_setup(void);
unsigned char kempston_read(void);
void pentagon_init(void);
void system_cycle(void);
extern void mouse_transaction(void);
extern void mouse_restart(void);
extern void ps2_init(void);

void adc_setup(void);
unsigned int in_l_measure(void);
unsigned int in_r_measure(void);
unsigned int in_l;
unsigned int in_r;


extern volatile bool myshko_flag;
extern volatile unsigned int mouse_answer_timeout;
extern volatile unsigned char mouse_last_data;

extern bool mouse_setup(void);
  
unsigned char int_delay;



extern volatile unsigned char m_byte_number;
extern volatile unsigned char m_x;
extern volatile unsigned char m_y;
extern volatile unsigned char m_b;
extern volatile unsigned int mouse;
extern volatile unsigned char scan_code_number;
extern volatile unsigned char mouse_stop_timeout;
extern volatile unsigned char keyboard_stop_timeout;
extern volatile unsigned char m_bit_counter;

extern volatile unsigned char ps2_transmit_flag1;

//unsigned char ps2_parity_num;





unsigned char i2c_command;
unsigned char i2c_data;

unsigned short addr;
unsigned short a;


volatile unsigned int buffer4cmos[256];
volatile unsigned char i2c_buffer[16384];
volatile unsigned int fpga_data_array[16];
volatile unsigned int i2c_byte_number;
volatile unsigned int i2c_number_of_bytes;
volatile bool timer_flag;
volatile unsigned char send_command_flag;
volatile unsigned char send_data_flag;
volatile bool get_cmos_status_flag;
volatile bool get_fpga_data_flag;
volatile unsigned char cmos_counter;

volatile unsigned char received_status;


volatile unsigned char int_status = 0;
volatile unsigned char clk_status_in = 0;
volatile unsigned char clk_status_out = 0;
volatile unsigned char k_noint = 0;
volatile unsigned char m_noint = 0;
volatile unsigned char k_int_flag = 0;
volatile unsigned char m_int_flag = 0;



unsigned char txtbuffrac;

void i2c_setup(void);

unsigned long e;
unsigned long k;

// 80x24 mode
// text mode attributes byte
// 7654  3210
// ibgr  ibgr
// paper ink

unsigned char text_x;
unsigned char text_y;
unsigned char text_attr;
unsigned char text_mojno;
bool print_flag;

unsigned char input_x, input_y, input_x_b, input_y_b, input_len, input_number, input_flag, input_breakpoint_flag, input_done;
char input_string[16]="                ";
unsigned int input;

unsigned char breakpoint_number;


#define	textbufsize	2560
unsigned char textbuffer[5121];

char lastkey[2]={' ',0}; 

unsigned char unshifted[][2] = {0x0d,9,0x0e,'|',0x15,'q',0x16,'1',0x1a,'z',0x1b,'s',0x1c,'a',
0x1d,'w',0x1e,'2',0x21,'c',0x22,'x',0x23,'d',0x24,'e',0x25,'4',0x26,'3',0x29,' ',0x2a,'v',0x2b,'f',
0x2c,'t',0x2d,'r',0x2e,'5',0x31,'n',0x32,'b',0x33,'h',0x34,'g',0x35,'y',0x36,'6',0x39,',',0x3a,'m',
0x3b,'j',0x3c,'u',0x3d,'7',0x3e,'8',0x41,',',0x42,'k',0x43,'i',0x44,'o',0x45,'0',0x46,'9',0x49,'.',
0x4a,'-',0x4b,'l',0x4c,'�',0x4d,'p',0x4e,'+',0x52,'�',0x54,'�',0x55,'\\',0x5a,13,0x5b,'�',0x5d,'\'',
0x61,'<',0x66,8,0x69,'1',0x6b,'4',0x6c,'7',0x70,'0',0x71,',',0x72,'2',0x73,'5',0x74,'6',0x75,'8',
0x79,'+',0x7a,'3',0x7b,'-',0x7c,'*',0x7d,'9',0,0};

unsigned char shifted[][2] = {0x0d,9,0x0e,'�',0x15,'Q',0x16,'!',0x1a,'Z',0x1b,'S',0x1c,'A',
0x1d,'W',0x1e,'"',0x21,'C',0x22,'X',0x23,'D',0x24,'E',0x25,'�',0x26,'#',0x29,' ',0x2a,'V',0x2b,'F',
0x2c,'T',0x2d,'R',0x2e,'%',0x31,'N',0x32,'B',0x33,'H',0x34,'G',0x35,'Y',0x36,'&',0x39,'L',0x3a,'M',
0x3b,'J',0x3c,'U',0x3d,'/',0x3e,'(',0x41,';',0x42,'K',0x43,'I',0x44,'O',0x45,'=',0x46,')',0x49,':',
0x4a,'_',0x4b,'L',0x4c,'�',0x4d,'P',0x4e,'?',0x52,'�',0x54,'�',0x55,'`',0x5a,13,0x5b,'^',0x5d,'*',
0x61,'>',0x66,8,0x69,'1',0x6b,'4',0x6c,'7',0x70,'0',0x71,',',0x72,'2',0x73,'5',0x74,'6',0x75,'8',
0x79,'+',0x7a,'3',0x7b,'-',0x7c,'*',0x7d,'9',0,0};


void ctrl(void);

void additional_action(unsigned char unpush, unsigned char scode);

#define error_timeout 5

volatile unsigned int timeout = 0;
volatile unsigned int reset_timeout = 0;

extern volatile bool mouse_read_error;
extern volatile bool mouse_write_error;
extern volatile bool mouse_wheel;

extern volatile unsigned int m_timeout;

extern void interrupt(unsigned char input_bit);
extern void reset_error(void);
extern volatile unsigned char keyarray[5];//= {0xff, 0xff, 0xff, 0xff, 0xff};
extern volatile bool klava;
extern volatile bool reset;
extern volatile bool magic;
extern volatile bool keyboard_error;
extern bool shift_flag;
extern bool ctrl_flag;
extern volatile bool backspace_flag;

unsigned char cycle_counter=0;


#endif
