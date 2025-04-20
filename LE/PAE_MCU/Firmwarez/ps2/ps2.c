// ps2 keyboard/mouse
#include "ps2.h"

void ps2_init(void)
{
unsigned char index;

	for(index = 0; index < 5; index++) keyarray[index] = 0xff;	
	m_bit_counter = 0;
	m_code = 0;
}

void translate(unsigned char scode)
{
unsigned char bitnumber, bytenumber;
bool finish = false;

	scan_code = 0;
	if(scode==0x59) scode=0x12;

	switch (scode)
	{
		case 0xe0: if (!long_scan_code) long_scan_code = true; finish = true;  break; 	
		case 0xf0: if (!unpush) unpush = true;  finish = true; break; 
		case 0x12: if (!unpush) shift_flag = true; else shift_flag = false;  break;
		case 0x66: caps_shift(); scode = 0x45; if (!unpush) backspace_flag=true; else backspace_flag=false;  break; // backspace
		case 0x6b: caps_shift(); scode = 0x2e; break; // left
		case 0x74: caps_shift(); scode = 0x3e; break; // right
		case 0x75: caps_shift(); scode = 0x3d; break; // up
		case 0x72: caps_shift(); scode = 0x36; break; // down
		case 0x58: caps_shift(); scode = 0x1e; break; // capslock
		case 0x71: caps_shift(); scode = 0x46; break; // del = CS+9
		case 0x70: symbol_shift(); scode = 0x1d; break; // ins = SS+W	
		case 0x6c: symbol_shift(); scode = 0x15; break; // home = SS+Q
		case 0x69: symbol_shift(); scode = 0x24; break; // end = SS+E	
		case 0x0d: symbol_shift(); scode = 0x12; break; // tab = SS+CS
		case 0x76: caps_shift(); scode = 0x29; break; // esc = CS+SPACE
		case 0x0e: caps_shift(); scode = 0x16; break; // ` = CS+1
		case 0x14: ctrl(); scode = 0x11; break; // ctrl = SS
		case 0x7d: caps_shift(); scode = 0x26; break; // pgup = CS+3
		case 0x7a: caps_shift(); scode = 0x25; break; // pgdwn = CS+4	
		case 0x54: symbol_shift(); scode = 0x3e; break; // [ = ( 		
		case 0x5b: symbol_shift(); scode = 0x46; break; // ] = ) 		
		case 0x4c: symbol_shift(); scode = 0x44; break; // : = ;
		case 0x5d: symbol_shift(); scode = 0x1a; break; // \ = : 		
		case 0x4e: symbol_shift(); scode = 0x3b; break; // -_
		case 0x55: symbol_shift(); scode = 0x42; break; // 
		case 0x52: symbol_shift(); scode = 0x4D; break; // 
		case 0x41: symbol_shift(); scode = 0x31; break; // ,	
		case 0x49:	symbol_shift(); scode = 0x3a; break; // . symbol_shift(); scode = 0x3a; break; // .
		case 0x4a:  if (!shift_flag) {symbol_shift(); scode = 0x2a; } // /
								else   {keyarray[0] |= kuku; symbol_shift(); scode = 0x21; }  // ?
								break;
		case 0x07: if(!unpush) 
{scode = 0; reset = true; } break; // f12 = reset;
		//case 0x78: if(!unpush) {scode = 0; magic = true; } break; // f11 = magic;
		default: break;
	}
	if(!finish)
	{
		additional_action(unpush, scode);
		long_scan_code = false;
			for(bytenumber = 0; bytenumber < 5; bytenumber++)
			for(bitnumber = 0; bitnumber < 9 ; bitnumber++)
			if(zx_key_byte[(8*bytenumber)+bitnumber]==scode) 
			{
				if (!unpush) // push buttono
				keyarray[bytenumber] &= ~(kuku << bitnumber); 
				else keyarray[bytenumber] |= (kuku << bitnumber); 
			}
			klava = true;			
		unpush = false; 
	}
}

void interrupt(unsigned char input_bit)
{
unsigned char a;
	
	if(mouse) 
	{
		clr_clk;
		T0CCR &= ~(1<<5); // disable interrupt on cap0[1] event
		T0IR |= (1 << 5);
		mouse_stop_timeout = 0;
	}
	
	a = bit_counter-1;
	if ((bit_counter==0) && (input_bit != 0)) keyboard_error = true; 
	if ((bit_counter > 0) && (bit_counter < 9)) scan_code |= (input_bit << a);	
	if (bit_counter != 10) bit_counter++;
	else
	{ 
		if (!input_bit)
		{
			keyboard_error = true; scan_code = 0; 
			long_scan_code = false;
			unpush = false;
			for(a=0; a<5; a++) keyarray[a]=0xff; klava = true;
		}
		else 
		{
			bit_counter = 0; translate(scan_code); 
			if(mouse) {m_bit_counter = 0;  }
		}
	}
}

void reset_error(void)
{
	keyboard_error = false;
	bit_counter = 0;
}

void caps_shift(void)
{
	if (!unpush) keyarray[0] &= ~kuku; 
  else keyarray[0] |= kuku;  
}

void symbol_shift(void)
{
	if (!unpush) keyarray[1] &= ~(kuku << 7); 
	else keyarray[1] |= (kuku << 7);
}

void ctrl(void)
{
	if (!unpush) ctrl_flag = true;
	else ctrl_flag = false;	
}

void mouse_restart(void)
{
	m_bit_counter = 0; m_code = 0; mouse_read_error = 0; mouse_write_error = 0;
}

bool mouse_data_transmit(unsigned char data)
{
bool answer;
	
	mouse_write_error = 0;	
	ps2_transmit_flag0 = 1;	
	ps2_parity_num = 0;	
	m_bit_counter = 0;
	clr_clk; // clk --|__	
	clr_data; // data --|__		
	ps2_transmit_flag1 = 0; 
	while (ps2_transmit_flag1 < ps2_transmit_delay) clr_clk;
	set_clk; // clk __|--
	mouse_data = data;
	mouse_answer_timeout = 0;
	while ((ps2_transmit_flag0==1) && (mouse_answer_timeout != 50)) {antiopt++;};
	if(mouse_answer_timeout == 50) mouse = 0;
	mouse_last_data = 0;
	mouse_answer_timeout = 0;
	while ((mouse_last_data != 0xFA) && (mouse_answer_timeout != 50)) {antiopt++;};
	if (mouse_last_data == 0xFA) answer = 1;
	else answer = 0;
	while(mouse_answer_timeout != 50) {antiopt++;};
	
return answer;	
}

void mouse_transaction(void)
{
unsigned char read_data_bit;	
	if(mouse)
	{
		FIO1SET	|= (1 << 24); // clk --|__
		T0CCR &= ~(1<<2); // disable interrupt on cap0[1] event
		T0IR |= (1 << 4);
		keyboard_stop_timeout = 0;
	}
	
	//!ps2_transmit_flag0 если 1, то передается в мышь, если 0, то читается из мыши
	if (!ps2_transmit_flag0)
	{
		m_timeout=0;
		read_bit; //	 read_data_bit = ~(FIO1PIN >> 28) & 1;
		if ((!m_bit_counter) & read_data_bit)	mouse_read_error = 1;
		if ((m_bit_counter > 0) && (m_bit_counter < 9)) 
		{
			m_code |= read_data_bit << (m_bit_counter - 1);	
			if (read_data_bit) ps2_parity_num++;
		}
		
		if(m_bit_counter == 9)
		{
			if(read_data_bit) ps2_parity_num++;
			ps2_parity_num++; // stop bit
			if(ps2_parity_num & 1)
			{
				mouse_read_error = 1;
			}		
		}
		if (m_bit_counter != 10) m_bit_counter++;
		else
		{ 
			if (!read_data_bit) mouse_read_error = 1;
			ps2_parity_num = 0; m_bit_counter = 0;
			if(mouse)
				{
					bit_counter = 0;
				}
			if (mouse_read_error) m_code = 0;
			
				 m_parser(m_code); mouse_last_data = m_code; m_code = 0;
		}
	}
	else
	{
		m_timeout=0;
		// Смысл бита чётности - сделать так, чтобы кол-во единиц в посылке
		// (с учётом этого бита) было чётным. 	
		if ((m_bit_counter==0) || (m_bit_counter==11)) read_bit; //read_data_bit = ~(FIO1PIN >> 28) & 1;
		if ((!m_bit_counter) & read_data_bit) mouse_write_error = 1;
		if ((m_bit_counter > 0) && (m_bit_counter < 9))
		{
			if((mouse_data >> (m_bit_counter -1)) & 1) 
			{
				set_data_bit;
				ps2_parity_num++;
			}
			else clear_data_bit;
		}
		if (m_bit_counter == 9)
		{
			if (ps2_parity_num & 1) clear_data_bit 
			else set_data_bit;
		}
		if (m_bit_counter == 10) set_data_bit;  
		if (m_bit_counter < 11) m_bit_counter++;
		else
		{	
			ps2_parity_num = 0;
			ps2_transmit_flag0 = 0; m_bit_counter = 0; 
			if (read_data_bit) mouse_write_error = 1 ;
				if(mouse)
				{
					bit_counter = 0;
				}
		}
	} 
}	

char m_parser(char mc)
{
	
		if (!m_byte_number & ((mc >> 3) & 1))
		{
			m_byte_number++; y_s = (mc >> 5) & 1; x_s = (mc >> 4) & 1; m_b = (m_b & 0xf0) + (~mc & 7); return 0;
		}
		if (!m_byte_number & !((mc >> 3) & 1)) return 1; 
		if (m_byte_number == 1) 
		{
			m_byte_number++; 
			m_x += mc;	
			return 0;
		}
		if (m_byte_number == 2)
		{
			if(!mouse_wheel) {m_byte_number=0; myshko_flag = true;} else m_byte_number++; 
			m_y += mc;	
			return 0;
		}
		if (m_byte_number == 3)
		{
			m_byte_number=0;  myshko_flag = true; m_b += ((mc<<4) & 0xF0); return 0;
		}
	new_byte_timeout = 0;
return 0;
} 
 
bool mouse_setup(void)
{
	mouse_ok = mouse_data_transmit(0xff);
	mouse_answer_timeout = 0;	
	while (mouse_answer_timeout != mouse_answer_timeout_const) {};	// !!! ответа от мышки надо ждать не менее 1 секунды!
	mouse_ok = mouse_data_transmit(0xff);
	mouse_answer_timeout = 0;	
	while (mouse_answer_timeout != mouse_answer_timeout_const) {};	// !!! ответа от мышки надо ждать не менее 1 секунды!
	mouse_ok = mouse_data_transmit(0xff);
	mouse_answer_timeout = 0;	
	while (mouse_answer_timeout != mouse_answer_timeout_const) {};	// !!! ответа от мышки надо ждать не менее 1 секунды!
	mouse_ok = mouse_data_transmit(0xf3);	
	mouse_ok = mouse_data_transmit(0xc8);
	mouse_ok = mouse_data_transmit(0xf3);
	mouse_ok = mouse_data_transmit(0x64);
	mouse_ok = mouse_data_transmit(0xf3);
	mouse_ok = mouse_data_transmit(0x50);
	mouse_ok = mouse_data_transmit(0xf2);
	mouse_answer_timeout = 0;	
	while (mouse_answer_timeout != mouse_answer_timeout_const) {};	// !!! ответа от мышки надо ждать не менее 1 секунды!
	if(mouse_last_data ==0x03) mouse_wheel = 1; 
	else mouse_wheel = 0; 
	mouse_ok = mouse_data_transmit(0xe6);
	mouse_ok = mouse_data_transmit(0xea);
	mouse_ok = mouse_data_transmit(0xf6);
	mouse_ok = mouse_data_transmit(0xf3);	
	mouse_ok = mouse_data_transmit(0xc8);
	mouse_ok = mouse_data_transmit(0xf4);
	new_byte_timeout = 0;
return mouse_ok;
}	
