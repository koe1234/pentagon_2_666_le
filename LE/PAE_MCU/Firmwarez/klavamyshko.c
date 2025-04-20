#include "pae_mcu.h"

void klava(void)
{
unsigned char read_data_bit, error_blin;

error_blin = 0;
read_data_bit = ~(FIO1PIN >> 23) & 1;
led1_on();
if ((!bit_counter) & read_data_bit)	error_blin = 1;
if ((bit_counter > 0) & (bit_counter < 9)) scan_code |= read_data_bit<<(bit_counter-1);	
if (bit_counter !=10) bit_counter++;
	else	{ 
		if (!read_data_bit) error_blin = 1 ;
			else {bit_counter = 0; obrabotka(scan_code);  klava_flag=1; };
		   };
if(error_blin) {bit_counter = 0;
	scan_code = 0; error_blin = 0; nado_istcho = 0; unpush_scuko = 0;
	for(read_data_bit=0; read_data_bit<5; read_data_bit++) keyarray[read_data_bit]=0xff;  klava_flag=1;};

			};