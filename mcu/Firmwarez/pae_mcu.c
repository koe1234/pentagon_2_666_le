#include "pae_mcu.h"

int main(void)
{
	pentagon_init();
	while(1) system_cycle();
}

void system_cycle(void)
{
	if(condition_1) 
	{
		cycle_counter++;
		if(klava) { klava = false; upload_data(); }  
		if(reset)	{	reset = false; z80_reset();	}
		if(received_status == 0) { i2c_get_status(); cmos_ready = 0; } 
		else 
			if((cmos_ready > 128) && (received_status != 0)) { get_cmos_data(received_status); received_status = 0; }
	}
  if(condition_2) 
	{
		cycle_counter++;
		timer_flag = false;
		if((timeout == error_timeout) && keyboard_error) reset_error(); 
		if(mouse_read_error || mouse_write_error) mouse_restart(); 
		in_l = in_l_measure(); in_r = in_r_measure();
		if(condition_3)
		{
			myshko_flag = false; upload_data();
		} 
	}
	if(condition_4)
	{
		cycle_counter++;
	
	}
	if(condition_5) { cycle_counter++;  } 
	if(condition_6) { cycle_counter++; upload_data(); }			
	if(condition_7)
	{
		cycle_counter=0;
	}
}

void pentagon_init(void)
{
unsigned char index;

	PINSEL10 = 0;
	SCS |= 1; // enable fast gpio
	FIO1DIR |= (1<<21);	  // sd_power
	FIO1MASK &=~(1<<21);
	FIO1CLR |=(1<<21);		// always enable
	
	pll_setup();
	pll_pause;
	rtc_setup();
	adc_setup();
	pwm_setup();
	kempston_setup();

	// ps2 keyboard and mouse pins setup
	PINSEL3 |= (1 << 21);
	PINSEL3 |= (1 << 20); // cap0[0] for k_clk_i
	PINSEL3 |= (1 << 23);
	PINSEL3 |= (1 << 22); // cap0[1] for m_clk_i
	PINSEL3 &= ~(1 << 13);
	PINSEL3 &= ~(1 << 12); // gpio for k_data_o
	FIO1DIR |= (1 << 22);
	FIO1MASK &= ~(1 << 22);
	FIO1CLR	|= (1 << 22);
	PINSEL3 &= ~(1 << 15);
	PINSEL3 &= ~(1 << 14); // gpio for k_data_i
	FIO1DIR &= ~(1 << 23);
	FIO1MASK &= ~(1 << 23);
	PINSEL3 &= ~(1 << 17);
	PINSEL3 &= ~(1 << 16); // gpio for k_clk_o
	FIO1DIR |= (1 << 24);
	FIO1MASK &= ~(1 << 24);
	FIO1CLR	|= (1 << 24);
	PINSEL3 &= ~(1 << 19);
	PINSEL3 &= ~(1 << 18); // gpio for m_clk_o
	FIO1DIR |= (1 << 25);
	FIO1MASK &= ~(1 << 25);
	FIO1CLR	|= (1 << 25);
	PINSEL3 &= ~(1 << 25);
	PINSEL3 &= ~(1 << 24); // gpio for m_data_i
	FIO1DIR &= ~(1 << 28);
	FIO1MASK &= ~(1 << 28);
	PINSEL3 &= ~(1 << 27);
	PINSEL3 &= ~(1 << 26); // gpio for m_data_o
	FIO1DIR |= (1 << 29);
	FIO1MASK &= ~(1 << 29);
	FIO1CLR	|= (1 << 29); // data xx|--	
	ps2_init();
	
	timer0_setup(); // timer0 - 50 Hz
	timer1_setup(); // timer1 - 20 kHz

	// led pins	
	FIO2DIR |= (1<<0);
	FIO2DIR |= (1<<1);
	FIO2MASK &= ~(1<<0);
	FIO2MASK &= ~(1<<1);
	
	received_status = 0;
	upload_firmwarez();	// fpga firmwarez upload
	// int adjustment	
	int_delay = 0;
	
	get_status_flag = true;
	get_data_flag = true;
	get_cmos_data_flag = 0xff;

	m_byte_number = 0;
	keyboard_error = false;
	mouse_read_error = 0;
	mouse_write_error = 0;
	mouse_wheel = 0;

	//cmos setup
	transmit_cmos_data();
	cmos_a = &cmos;	cmos_a = cmos_a + 0xC;
	mouse = *cmos_a; mouse = (mouse >> 24) & 0xff;

	///////// if battery low
	mouse = 3;
	///////// if battery low
	mouse_setup();
	if((mouse > 0) && (mouse < 8)) {m_b = 7; m_x = 127; m_y = 127; } else {m_b = 0xff; m_x = 0xff; m_y = 0xff;};
	
	shift_flag = false;
	ctrl_flag = false;

	led0_off();
	led1_off();

	reset = false;
	for(index = 0; index < 5; index++) keyarray[index] = 0xff;	
	z80_reset();
}

void get_cmos_data(unsigned char status)
{
unsigned char index;
unsigned long bf;

	get_cmos_data_flag = 0;
	fpga_send_command(10);
	while(send_command_flag != 0xff) {};
	cmos_a = &cmos;
	for(index = 0; index < 64; index++)
	{
		bf=((buffer4cmos[4*index] << 24) | (buffer4cmos[4*index+1] << 16) | (buffer4cmos[4*index+2] << 8) | (buffer4cmos[4*index+3])); *cmos_a = bf; 
		cmos_a++;	//=cmos_a+1;
		if ((status >> 1) & 1 ) RTC_SEC = ((buffer4cmos[0] & 0xf0) >> 4)*10 + (buffer4cmos[0] & 0x0f);
		if ((status >> 2) & 1 ) RTC_MIN = ((buffer4cmos[2] & 0xf0) >> 4)*10 + (buffer4cmos[2] & 0x0f);
		if ((status >> 3) & 1 ) RTC_HOUR = ((buffer4cmos[4] & 0xf0) >> 4)*10 + (buffer4cmos[4] & 0x0f);
		if ((status >> 4) & 1 ) RTC_DOW = buffer4cmos[6] - 1;
		if ((status >> 5) & 1 ) RTC_DOM = ((buffer4cmos[7] & 0xf0) >> 4)*10 + (buffer4cmos[7] & 0x0f);
		if ((status >> 6) & 1 ) RTC_MONTH = ((buffer4cmos[8] & 0xf0) >> 4)*10 + (buffer4cmos[8] & 0x0f);	
		if ((status >> 7) & 1 ) RTC_YEAR = 2000 + ((buffer4cmos[9] & 0xf0) >> 4)*10 + (buffer4cmos[9] & 0x0f);
		get_cmos_data_flag = 0xff;
	}
}

void transmit_cmos_data(void)
{
unsigned char index;
unsigned long bf;

	index = 0;
	cmos_a = &cmos;
	while(index < 17)
	{
		bf=*cmos_a;
		i2c_buffer[4*index] =  (bf >> 24) & 255;
		i2c_buffer[4*index+1] = (bf >> 16) & 255;
		i2c_buffer[4*index+2] = (bf >> 8) & 255;
		i2c_buffer[4*index+3] = bf & 255;
		index++;
		cmos_a++;
	}
	fpga_send_command(11);
	while(send_command_flag != 0xff) {};
	fpga_send_data(12,67); 
	while(send_data_flag != 0xff) {};
}

void fpga_send_command(char command)
{
	I21CONSET = 1 << 6;
	i2c_command = (command << 1);
	send_command_flag = 0;
	I21CONCLR = 0x000000FF;
	I21CONSET = 0x00000040;
	I21CONSET = 0x00000020;
}

void fpga_send_data(char data, unsigned int skoka)
{
	I21CONSET = 1 << 6;
	i2c_command = (data << 1);
	send_data_flag = 0;
	i2c_byte_number = 0;
	i2c_number_of_bytes = skoka;
	I21CONCLR = 0x000000FF;
	I21CONSET = 0x00000040;
	I21CONSET = 0x00000020;
}

void i2c_get_status(void)
{
	I21CONSET = 1 << 6;
	i2c_command = 9 << 1; 
	get_status_flag = false;
	I21CONCLR = 0x000000FF;
	I21CONSET = 0x00000040;
	I21CONSET = 0x00000020;
}

void i2c_get_data(void)
{

	I21CONSET = 1 << 6;
	i2c_command = 10 << 1; 
	get_data_flag = false;
	i2c_byte_number = 0;
	I21CONCLR = 0x000000FF;
	I21CONSET = 0x00000040;
	I21CONSET = 0x00000020;
}

void gpio_fpga_send_command(char command)
{
unsigned char bitcounter;
unsigned char a;

	command = (command << 1) & 254;
	FIO0DIR |=(1<<0);
	FIO0SET |=(1<<0); // SDA=1
	FIO0SET |=(1<<1); // SCL=1
	FIO0CLR |=(1<<0); // SDA=0 transmitting the start condition
	FIO0CLR |=(1<<1); // SCL=0
	for (bitcounter = 7; bitcounter != 255; bitcounter--) 
	{
		a = (command >> bitcounter) & 1;
		if (a) FIO0SET |= (1 << 0); else FIO0CLR |= (1 << 0);
		FIO0SET |= (1 << 1); // _|- scl
		FIO0CLR |= (1 << 1); // -|_ scl
	}
	FIO0DIR &= ~(1 << 0); // switch sda for read confirm from slave
	FIO0SET |= (1 << 1); // _|- scl
	FIO0CLR |= (1 << 1); // -|_ scl
	FIO0SET |= (1 << 1); // _|- scl
}

void gpio_fpga_send_data(char data, unsigned int skoka)
{
unsigned char bitcounter;
unsigned int bytecounter;
unsigned char index;

	data = (data << 1) & 254;
	FIO0DIR |=(1<<0);
	FIO0SET |=(1<<0); // SDA=1
	FIO0SET |=(1<<1); // SCL=1
	FIO0CLR |=(1<<0); // SDA=0 transmitting the start condition
	FIO0CLR |=(1<<1); // SCL=0
	for (bitcounter = 7; bitcounter != 255; bitcounter--) 
	{
		index = (data >> bitcounter) & 1;
		if (index) FIO0SET |= (1 << 0); else FIO0CLR |= (1 << 0);
		FIO0SET |= (1 << 1); // _|- scl
		FIO0CLR |= (1 << 1); // -|_ scl
	}
	FIO0DIR &= ~(1 << 0); // switch sda for read confirm from slave
	FIO0SET |= (1 << 1); // _|- scl
	FIO0CLR |= (1 << 1); // -|_ scl
	FIO0DIR |= (1 << 0);
	FIO0SET |= (1 << 0);	//?
	for (bytecounter = 0; bytecounter < skoka; bytecounter++)
	{
		for (bitcounter = 7; bitcounter != 255; bitcounter--) 
		{
			index = ((i2c_buffer[bytecounter]) >> bitcounter) & 1;
			if(index) FIO0SET |= (1 << 0); else FIO0CLR |= (1 << 0);
			FIO0SET |= (1<<1); // _|- scl
			FIO0CLR |= (1<<1); // -|_ scl
		}
		FIO0DIR &= ~(1 << 0); // switch sda for read confirm from slave
		FIO0SET |= (1 << 1); // _|- scl
		FIO0CLR |= (1 << 1); // -|_ scl
		FIO0DIR |=(1 << 0);
	}
}

void upload_data(void)
{
unsigned char index;

	for(index = 0; index < 5; index++) i2c_buffer[index] = keyarray[index];
	i2c_buffer[5] = (((RTC_SEC/10) & 0x0f) << 4) | (RTC_SEC%10);
	i2c_buffer[6] = (((RTC_MIN/10) & 0x0f) << 4) | (RTC_MIN%10);
	i2c_buffer[7] = (((RTC_HOUR/10) & 0x0f) << 4) | (RTC_HOUR%10);
	i2c_buffer[8] = RTC_DOW+1; 
	i2c_buffer[9] = (((RTC_DOM/10) & 0x0f) << 4) | (RTC_DOM%10);
	i2c_buffer[10] = (((RTC_MONTH/10) & 0x0f) << 4) | (RTC_MONTH%10);
	i2c_buffer[11] = (((((RTC_YEAR - 2000) & 255)/10) & 0x0f) << 4) | (((RTC_YEAR - 2000) & 255)%10);
	i2c_buffer[12] = m_b;
	i2c_buffer[13] = m_x;
	i2c_buffer[14] = m_y;
	i2c_buffer[15] = kempston_read();
	i2c_buffer[16] = in_l & 0xff;
	i2c_buffer[17] = (in_l >> 8) & 0xff;
	i2c_buffer[18] = in_r & 0xff;
	i2c_buffer[19] = (in_r >> 8) & 0xff;
	fpga_send_command(22);
	while(send_command_flag != 0xff) {};
	fpga_send_data(2,120); 
	while(send_data_flag != 0xff) {};
	fpga_send_command(0);
	while(send_command_flag != 0xff) {};
}

void upload_firmwarez(void)
{
	gpio_i2c_setup();
	if(!upload_from_sd("firmware/PaE.rbf")) upload_from_rom();
	gpio_fpga_send_command(1);
	gpio_fpga_send_command(0);
	if(!screen_from_sd("firmware/logo.rom")) { data_base_addr = logo; rom_from_rom(5, logo_size); }
	if(!rom_from_sd(64 + 8,"firmware/gluk.rom")) { data_base_addr = gluk; rom_from_rom(64 + 8, gluk_size); }
	if(!rom_from_sd(64 + 10,"firmware/basic128.rom"))	{ data_base_addr = basic128; rom_from_rom(64 + 10, basic128_size); }
	if(!rom_from_sd(64 + 9,"firmware/trdos.rom"))	{ data_base_addr = trdos; rom_from_rom(64 + 9, trdos_size); }
	if(!rom_from_sd(64 + 11,"firmware/basic48.rom")) { data_base_addr = basic48; rom_from_rom(64 + 11, basic48_size); }
	if(!rom_from_sd(64 + 12,"firmware/fatall.rom"))	{data_base_addr = fatall; rom_from_rom(64 + 12, fatall_size); }
	trd_to_ram("firmware/test.trd"); 
	sd_spi_unsetup(); 
	i2c_setup();
}

char upload_from_sd(char* filename)
{
FATFS FatFs;		/* FatFs work area needed for each volume */
FIL Fil;			/* File object needed for each open file */	
unsigned int read, index;
	
	fpga_init();
	// Select FPGA to upload
	FIO0CLR |= (1 << 25);					// FPGA_NCE = 0
	fpga_pause;
	if(f_mount(0, &FatFs) != FR_OK) return 0;
	if(f_open (&Fil, filename, FA_READ) != FR_OK) return 0; 
	do
	{
		f_read(&Fil, &buffer, BUFSIZE, &read);
		for(index = 0; index < read; index++) fpga_spi_send(buffer[index]);
	} while (read==BUFSIZE);
	f_close(&Fil);
	fpga_pause;
	return 1;
}

char screen_from_sd(char* filename)
{
FATFS FatFs;		/* FatFs work area needed for each volume */
FIL Fil;			/* File object needed for each open file */	
unsigned int read, index;

	i2c_buffer[0] = 5;	
	gpio_fpga_send_data(6,1); // upnload zx screen, page01, address from 0
	gpio_fpga_send_command(0);
	i2c_byte_number=0;

	if(f_mount(0, &FatFs) != FR_OK) return 0;
	if(f_open (&Fil, filename, FA_READ) != FR_OK) return 0; 
	do
	{
		f_read(&Fil, &buffer, BUFSIZE, &read);
		for(index = 0; index < read; index++) {i2c_buffer[i2c_byte_number] = buffer[index]; i2c_byte_number++;}
	} while (read==BUFSIZE);
	f_close(&Fil);
	gpio_fpga_send_command(3);
	gpio_fpga_send_data(0,16385);
return 0;
}

char rom_from_sd(unsigned char page, char* filename)
{
FATFS FatFs;		/* FatFs work area needed for each volume */
FIL Fil;			/* File object needed for each open file */	
unsigned int read, index;

	i2c_buffer[0] = page;	
	gpio_fpga_send_data(6,1);
	gpio_fpga_send_command(0);
	i2c_byte_number=0;
	if(f_mount(0, &FatFs) != FR_OK) return 0;
	if(f_open (&Fil, filename, FA_READ) != FR_OK) return 0; 
	do
	{
		f_read(&Fil, &buffer, BUFSIZE, &read);
		for(index = 0; index < read; index++) {i2c_buffer[i2c_byte_number] = buffer[index]; i2c_byte_number++;}
	} while (read==BUFSIZE);
	f_close(&Fil);	
	gpio_fpga_send_command(3);
	gpio_fpga_send_data(0,16385);
return 1;
}

char trd_to_ram(char* filename)
{
FATFS FatFs;		/* FatFs work area needed for each volume */
FIL Fil;			/* File object needed for each open file */	
unsigned int read, index;

	a	=	246; addr	=	0;
	i2c_buffer[0]=a;	
	gpio_fpga_send_data(6,1); 
	gpio_fpga_send_command(3);
	if(f_mount(0, &FatFs) != FR_OK) return 0;
	if(f_open (&Fil, filename, FA_READ) != FR_OK) return 0; 
	do
	{
		f_read(&Fil, &buffer, BUFSIZE, &read);
		for(index = 0; index < read; index++)
		{
			i2c_buffer[addr] = buffer[index];
			addr++; 
			if(addr==16384)
			{
				addr=0; a--; if(a==205) a=206;
				gpio_fpga_send_data(0,16385);
				i2c_buffer[0]=a;	
				gpio_fpga_send_data(6,1); 
				gpio_fpga_send_command(3);
			}
	  }
	} while (read==BUFSIZE);
	f_close(&Fil);
	gpio_fpga_send_command(0);	 
	return 1;
}

/////////////////////// interrupts ////////////////////////////////////
void timer0_irq(void) __irq
{
// 50 Hz interrupts + PS2 events interrupts
	
	if ((T0IR >> 4) & 1)
	{
		T0IR |= (1 << 4); timeout = 0; if(!keyboard_error) interrupt(~(FIO1PIN >> 23) & 1);
	}
	if ((T0IR >> 5) & 1) 
	{
		T0IR |= (1 << 5); mouse_transaction(); // mouse interrupt
	} 
	if (T0IR & 1) 
	{
		T0IR |= 1; 
		if(test_counter < 60) test_counter++;
		timer_flag = true; led0_on(); led0_off();
		if(timeout < error_timeout) timeout++;
		if(m_timeout < error_timeout) m_timeout++;
	}
	VICVectAddr =0;
}

void timer1_irq(void) __irq
{
// 20 kHz (50 us)
static uint32_t div10;

	led0_on(); led0_off();
	T1IR |= 1;
	ps2_transmit_flag1++;
	mouse_answer_timeout++;
	fpga_timing++;
	
	Timer_div++;
	if(Timer_div==35999) 
	{
		Timer_div = 0; Timer++;
		if (++div10 >= 10)
			{
		div10 = 0;
		disk_timerproc();		/* Disk timer function (100Hz) */
			}
	}	
VICVectAddr =0;
}

void i2c_irq(void) __irq
{

	switch (I21STAT)
	{
		case (0x08): // start condition has been sent
			I21CONCLR = 0x20; // start_i2c flag reset
			if (!send_command_flag | !send_data_flag)
			{
				I21DAT = i2c_command & ~1; // transmitting the slave address, "command" in our case
				if(!send_command_flag) send_command_flag++;
				if(!send_data_flag) send_data_flag++;
			}
			if (!get_status_flag || !get_data_flag) I21DAT = (i2c_command & ~1);
			break;
		case (0x18): // slave address + W (0 in first byte) has been sent
			if(send_command_flag == 1) { send_command_flag = 0xff; I21CONSET = 0x10; }
			if(send_data_flag == 1)
			{
				I21DAT = i2c_buffer[i2c_byte_number];
				i2c_byte_number++; send_data_flag++;
			} // transmitting the command protocol, "data" in our case
			if (!get_status_flag || !get_data_flag) I21CONSET = 0x20; // repeat start
			break;
		case (0x28): // data has been transmitted, ack received 
			if ((send_data_flag == 2) && (i2c_byte_number <= i2c_number_of_bytes)) 
			{
				I21DAT = i2c_buffer[i2c_byte_number];	 i2c_byte_number++;} // transmitting the data
				if ((send_data_flag == 2) && (i2c_byte_number > i2c_number_of_bytes))
				{
					I21CONSET = 0x10; send_data_flag=0xff;
				} // stop
			break;
		case (0x10): // repeated start has been sent
			I21CONCLR = 0x20; // start_i2c flag reset
			if (!get_status_flag || !get_data_flag) { if (!get_data_flag) I21DAT = 25; else I21DAT = (i2c_command | 1); };
			break;
		case (0x40): // slave address + r was transmitted. ack has been received
			if (!get_status_flag) I21CONCLR = 4; // clear AAC flag. nack will be transmitted
			if (!get_data_flag) I21CONSET = 4; // set AAC flag. ack will be transmitted
		break;
		case (0x48): // slave address + r was transmitted. nack has been received
			I21CONSET = 0x10; // stop i2c
			get_status_flag = true;
			get_data_flag = true;
			break;
		case (0x58): // data has been received, nack has been transmitted
			if (!get_status_flag) {	received_status = I21DAT; get_status_flag = true; }
			if(!get_data_flag)
			{
				if (!get_cmos_data_flag)
				{
					get_data_flag = true; 
				}
			}
			I21CONSET = 0x10; // stop i2c
			break;
		case (0x50): // data has been received, ack has been transmitted
			if (!get_cmos_data_flag)
			{	
				if (i2c_byte_number < 259)
				{
					i2c_byte_number++;
					I21CONSET = 4; // set AAC flag. ack will be transmitted
				}
				else
				{
					i2c_byte_number++;
					I21CONCLR = 4;
				}
			}	
			break;
		default: 	send_data_flag = 0xff;
			send_command_flag = 0xff;
			get_data_flag = true;
			get_status_flag = true;
			break;
	}
	I21CONCLR = 0x08; // clear the i2c interrupt flag
	VICVectAddr =0;
}

void z80_reset(void)
{
	fpga_send_command(1);
	while(send_command_flag != 0xff) {};
	fpga_send_command(7);
	while(send_command_flag != 0xff) {};
	fpga_send_command(8);
	while(send_command_flag != 0xff) {};
	fpga_send_command(5);
	while(send_command_flag != 0xff) {};
	fpga_send_command(0);
	while(send_command_flag != 0xff) {};
}

unsigned char kempston_read(void)
{
	return ((FIO2PIN >> 7) & 1) | (((FIO2PIN >> 6) & 1) << 1) | (((FIO2PIN >> 5) & 1) << 2) | (((FIO2PIN >> 4) & 1) << 3) | (((FIO0PIN >> 11) & 1) << 4);
}

unsigned int in_l_measure(void)
{
	AD0CR &=~(0xff);
	AD0CR |= 1; // select ad0[0]
	AD0CR |= (1 << 24); //start the conversion
	while(!((AD0GDR >> 31) & 1)) {};
	AD0CR &= ~(1 << 24); //stop the conversion
	return ((AD0GDR >> 6) & 1023);
}

unsigned int in_r_measure(void)
{
	AD0CR &= ~(0xff);
	AD0CR |= 2; // select ad0[1]
	AD0CR |= (1 << 24); //start the conversion
	while(!((AD0GDR >> 31) & 1)) {};
	AD0CR &= ~(1 << 24); //stop the conversion
	return ((AD0GDR >> 6) & 1023);
}

void rom_from_rom(unsigned char page, unsigned long size)
{
unsigned int i, decompressed;

	i2c_buffer[0]=page;	
	gpio_fpga_send_data(6,1);
	gpio_fpga_send_command(0);
	i2c_byte_number=0;
	//---------------------------------------------------------------------------------------
	// Prepare decompressing
	arithmetic_decompress_init(ReadAddrFnc, size);
	do
	{
		arithmetic_decompress_chunk(buffer, BUFSIZE, &decompressed);
		for(i = 0; i < decompressed; i++)
		{
			i2c_buffer[i2c_byte_number] = buffer[i]; i2c_byte_number++;
		}
	} while(decompressed > 0);
	arithmetic_decompress_done();
	//---------------------------------------------------------------------------------------
	gpio_fpga_send_command(3);
	gpio_fpga_send_data(0,16384);
}

static unsigned char ReadAddrFnc(unsigned long addr)
{
	return data_base_addr[addr];
}

void upload_from_rom(void)
{
unsigned int i, decompressed;

	fpga_init();
	// Select FPGA to upload
	FIO0CLR |= (1 << 25);	// FPGA_NCE = 0
	fpga_pause;
	data_base_addr = fpga;
	arithmetic_decompress_init(ReadAddrFnc, fpga_size);
	do
	{
		arithmetic_decompress_chunk(buffer, BUFSIZE, &decompressed);
		for(i = 0; i < decompressed; i++)
		{
			fpga_spi_send(buffer[i]);
		}
	} while(decompressed > 0);
	arithmetic_decompress_done();	 
 	fpga_pause;
}

void i2c_setup(void)
{
	PCLKSEL0 &= ~(1 << 15);
	PCLKSEL0 |= (1 << 14);	 // clk for i2c
	PINSEL0 |= (1 << 1);
	PINSEL0 |= (1 << 0);
	PINSEL0 |= (1 << 3);
	PINSEL0 |= (1 << 2);
	I21SCLH = 90;
	I21SCLL = 90; // SCL clock frequency ~400kHz
  
	VICVectCntl19 = 14;	
	VICVectAddr19	= (unsigned)i2c_irq; // address of the interrupt subroutine
	VICIntEnable |= (1<<19);	// enable i2c interrupt

	send_command_flag = 0xff;
	send_data_flag = 0xff;

	fpga_send_command(1);
	while(send_command_flag != 0xff) {};

	fpga_send_command(7);
	while(send_command_flag != 0xff) {};
}

void spi_fpga_init(void)
{
	PINSEL0 |=(0x01UL<<31);
	PINSEL0 |=(1<<30); // P0.15 -> SCK
	PINSEL1 |=(1<<1);
	PINSEL1 |=(1<<0); // P0.16 -> SSEL
	PINSEL1 |=(1<<3);
	PINSEL1 |=(1<<2); // P0.17 -> MISO
	PINSEL1 |=(1<<5);
	PINSEL1 |=(1<<4); // P0.18 -> MOSI
	// enable SPI-Master
	S0SPCR =0x60;  //  Master enable, datatransfer from the lsb, sck is active high 
	// set max speed
	S0SPCCR=8;
}

void fpga_init(void)
{
	spi_fpga_init();
	PINSEL1 &= ~(1 << 23);
	PINSEL1 &= ~(1 << 22);	// GPIO for P0.27 (FPGA_NSTATUS)
	PINSEL1 &= ~(1 << 25);
	PINSEL1 &= ~(1 << 24);	// GPIO for P0.28 (FPGA_CONFDONE)
	PINSEL1 &= ~(1 << 19);
	PINSEL1 &= ~(1 << 18); // GPIO for P0.25 (FPGA_NCE)
	PINSEL3 &= ~(0x01UL << 31);
	PINSEL3 &= ~(1 << 30);	// GPIO for P1.31 (FPGA_NCONFIG)
	FIO0MASK &= ~(1 << 27);
	FIO0DIR &= ~(1 << 27); // input for FPGA_NSTATUS
	FIO0MASK &= ~(1 << 28);
	FIO0DIR &= ~(1 << 28); // input for FPGA_CONFDONE
	FIO0MASK &= ~(1 << 25);
	FIO0DIR |= (1 << 25); // output for FPGA_NCE
	FIO1MASK &= ~(0x01UL << 31);
	FIO1DIR |= (0x01UL << 31); // output for FPGA_NCONFIG
	// unselect fpga before programming
	FIO0SET |= (1 << 25);	// FPGA_NCE = 1
	// Start programming firmware (1->0->1 sequence)
	FIO1SET |= (0x01UL << 31);
	fpga_pause;
	FIO1CLR |= (0x01UL << 31);
	fpga_pause;
	FIO1SET |= (0x01UL << 31);
	fpga_pause;
	// Wait until nSTATUS becomes 1
	while(!(FIO0PIN & (1 << 27)));
}

char fpga_spi_send(unsigned char spi_data)
{
unsigned char incom;

	S0SPDR = spi_data;
	while(!(S0SPSR & (1 << 7)));
	incom = S0SPDR;
	return incom;
}

void pwm_setup(void)
{
	PINSEL4 |= (1 << 4);
	PINSEL4 &= ~(1 << 5);	//p2.2 -> pwm1[3]
	PCLKSEL0 &= ~(1 << 13);
	PCLKSEL0 |= (1 << 12);	// CCLK for PWM
	PWM1PR = 0;
	PWM1PC=0;
	PWM1PCR &=~ (0 << 3); 
	PWM1PCR |=(1 << 11);
	PWM1MR0 = 4; // stop
	PWM1MR3 = 2; //start
	PWM1LER |=(1 << 3);
	PWM1MCR |= (1 << 1);
	PWM1TCR = 0x00000002;
	PWM1TCR = 0x00000009;  
}

void timer0_setup(void)
{
	PCLKSEL0 &= ~(1 << 3);
	PCLKSEL0 |= (1 << 2);
	VICVectCntl4 = 0;	// priority level
	VICVectAddr4	= (unsigned)timer0_irq; // address of interrupt subroutine
	VICIntEnable |= (1 << 4);	// enable timer0 interrupt
	T0MR0 = 1;
	T0PR = 500000; // 50 Hz for timer0
	T0CCR |= (1 << 0); // capture on cap0[0] rising edge
	T0CCR &= ~(1 << 1); // capture on cap0[0] rising edge
	T0CCR |= (1 << 2); // enable interrupt on cap0[0] event
	T0CCR |= (1 << 3); // capture on cap0[1] rising edge
	T0CCR &= ~(1 << 4); // capture on cap0[1] rising edge
	T0CCR |= (1<<5); // enable interrupt on cap0[1] event
	T0TCR = 2; // reset the counter
	T0MCR |= 3; // interrupt
	T0TCR = 1; // start the timer
	timer_flag=false;
	klava=0;
	myshko_flag=false;
}

void timer1_setup(void)
{
	PCLKSEL0 &= ~(1 << 5);
	PCLKSEL0 |= (1 << 4);
	VICVectCntl5 = 1;	// priority level
	VICVectAddr5	= (unsigned)timer1_irq; // address of interrupt subroutine
	VICIntEnable |= (1 << 5);	// enable timer1 interrupt
	T1MR0 = 1;
	T1PR = 1800; // 50 us for timer0
	T1TCR = 2; // reset the counter
	T1MCR |= 3; // interrupt
	T1TCR = 1; // start the timer
}

void pll_setup(void)
{
	CLKSRCSEL = 1;	
	CCLKCFG = 3;
	PLLCFG = 23;
	PLLCFG |= (1 << 16);
	PLLFEED = 0xAA;
	PLLFEED = 0x55;
	PLLCON = 1;
	PLLFEED = 0xAA;
	PLLFEED = 0x55;
	while(!((PLLSTAT>>26) & 1)) {};
	PLLCON |=(1 << 1);
	PLLFEED = 0xAA;
	PLLFEED = 0x55;
}

void sd_spi_setup(void)
{
	PINSEL0 &= ~(1 << 11);
	PINSEL0 &= ~(1 << 10); // GPIO P0.5 for SPI_CS
	PINSEL0 |= (1 << 13);
	PINSEL0 &= ~(1 << 12); // P0.6 -> SSEL1
	PINSEL0 |= (1 << 15);
	PINSEL0 &= ~(1 << 14); // P0.7 -> SCK1
	PINSEL0 |= (1 << 17);
	PINSEL0 &= ~(1 << 16); // P0.8 -> MISO1
	PINSEL0 |= (1 << 19);
	PINSEL0 &= ~(1 << 18); // P0.9 -> MOSI1
	PCONP |= (1 << 8); // enable the SPI
	PCLKSEL0 &= ~(1 << 17);
	PCLKSEL0 &= ~(1 << 16); // PCLK_SPI = CCLK/4
}

void sd_spi_unsetup(void)
{
	PINSEL0 &= ~(1 << 11);
	PINSEL0 &= ~(1 << 10); // GPIO P0.5 for SPI_CS
	FIO0DIR &= ~(1 << 5); // input 
	PINSEL0 &= ~(1 << 13);
	PINSEL0 &= ~(1 << 12); // P0.6 -> GPIO
	FIO0DIR &= ~(1 << 6); // input 
	PINSEL0 &= ~(1 << 15);
	PINSEL0 &= ~(1 << 14); // P0.7 -> GPIO
	FIO0DIR &= ~(1 << 7); // input 
	PINSEL0 &= ~(1 << 17);
	PINSEL0 &= ~(1 << 16); // P0.8 -> GPIO
	FIO0DIR &= ~(1 << 8); // input 
	PINSEL0 &= ~(1 << 19);
	PINSEL0 &= ~(1 << 18); // P0.9 -> GPIO
	FIO0DIR &= ~(1 << 9); // input 
	PCONP &= ~(1 << 8); // disable the SPI
}

void kempston_setup(void)
{
	PINSEL0 &= ~(1 << 23);
	PINSEL0 &= ~(1 << 22); // p0.11 -> gpio (fire) D4
	FIO0DIR &= ~(1 << 11);
	FIO0MASK &= ~(1 << 11);
	PINSEL4 &= ~(1 << 9);
	PINSEL4 &= ~(1 << 8); // p2.4 -> gpio (down) D3
	FIO2DIR &= ~(1 << 4);
	FIO2MASK &= ~(1 << 4);
	PINSEL4 &= ~(1 << 11);
	PINSEL4 &= ~(1 << 10); // p2.5 -> gpio (up) D2
	FIO2DIR &= ~(1 << 5);
	FIO2MASK &= ~(1 << 5);
	PINSEL4 &= ~(1 << 13);
	PINSEL4 &= ~(1 << 12); // p2.6 -> gpio (right) D1
	FIO2DIR &= ~(1 << 6);
	FIO2MASK &= ~(1 << 6);
	PINSEL4 &= ~(1 << 15);
	PINSEL4 &= ~(1 << 14); // p2.7 -> gpio (left)	D0
	FIO2DIR &= ~(1 << 7);
	FIO2MASK &= ~(1 << 7);
}

void adc_setup(void)
{
	PCLKSEL0 &= ~(1 << 25);
	PCLKSEL0 |= (1 << 24);
	PINSEL1 &= ~(1 << 15); // ad0[0]
	PINSEL1 |= (1 << 14);
	PINSEL1 &= ~(1 << 17); // ad0[1]
	PINSEL1 |= (1 << 16);
	PCONP |= (1 << 12); //Enable power to AD block
	AD0CR = 0;
	AD0CR |= (15 << 8);
	AD0CR |= (1 << 21); //disable pdn mode
}

void gpio_i2c_setup(void)
{
	PINSEL0 &= ~(1 << 0);
	PINSEL0 &= ~(1 << 1);
	PINSEL0 &= ~(3 << 0);
	PINSEL0 &= ~(2 << 1);
	FIO0DIR |= (1 << 0);
	FIO0MASK &= ~(1 << 0);
	FIO0SET	|= (1 << 0);
	FIO0DIR |=(1 << 1);
	FIO0MASK &= ~(1 << 1);
	FIO0SET	|= (1 << 1);
}

void rtc_setup(void)
{
	PCONP |= (1 << 9);
	RTC_ILR = 0;
	RTC_CCR = 17; // clk from external circuit 
	RTC_CIIR = 0;
	RTC_CISS = 0;
	RTC_AMR = 255;
}

void led0_on(void) { FIO2SET |= 1; }

void led0_off(void) { FIO2CLR |= 1; }

void led1_on(void) { FIO2SET |= (1 << 1); }

void led1_off(void) { FIO2CLR |= (1 << 1); }

void additional_action(unsigned char unpush, unsigned char scode)
{
unsigned char bitnumber;
	
	if (!unpush && scode == 0x09) { scode = 0; scode = 0; WDCLKSEL = 1; WDTC = 1000; WDFEED = 0xAA; WDFEED = 0x55; WDMOD = 3; while(1); }
	if (!unpush) 
	{ 
		if (shift_flag)
		{
			for(bitnumber = 0; shifted[bitnumber][0] != scode && shifted[bitnumber][0]; bitnumber++);
			if (shifted[bitnumber][0] == scode)  lastkey[0] = shifted[bitnumber][1]; 
		}
		else
		{
			for(bitnumber = 0; unshifted[bitnumber][0] != scode && unshifted[bitnumber][0]; bitnumber++);
			if (unshifted[bitnumber][0] == scode)  lastkey[0] = unshifted[bitnumber][1];	
		}
 	}
}

DWORD get_fattime (void)
{
//	RTCTime rtc;

/* Get local time */
//	rtc_gettime(&rtc);

/* Pack date and time into a DWORD variable */
//	return	  ((DWORD)(rtc.year - 1980) << 25)
//			| ((DWORD)rtc.mon << 21)
//			| ((DWORD)rtc.mday << 16)
//			| ((DWORD)rtc.hour << 11)
//			| ((DWORD)rtc.min << 5)
//			| ((DWORD)rtc.sec >> 1);
	return	  ((DWORD)(2023 - 1980) << 25)
			| ((DWORD)01 << 21)
			| ((DWORD)01 << 16)
			| ((DWORD)01 << 11)
			| ((DWORD)01 << 5)
			| ((DWORD)01 >> 1);
}
