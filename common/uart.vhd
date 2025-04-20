library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

entity uart is
    generic (
        maxbaud					: positive;
        clk_frequency			: positive;
		  fifo_size 				: positive;
		  rts_threshold			: positive
    );
    port (  
			clk						: in  std_logic;
			reset						: in  std_logic;    
			reg_data_in				: in  std_logic_vector(7 downto 0);
			reg_data_out			: out std_logic_vector(7 downto 0);
			reg_stb_n				: in std_logic;
			reg_addr					: in std_logic_vector(2 downto 0);
			reg_wr_n					: in std_logic;
			uart_int					: out std_logic;
			tx							: out std_logic;
			rx							: in  std_logic;
			cts						: in std_logic;
			rts						: out std_logic
    );
end uart;

architecture rtl of uart is

constant fifo_bits : integer := integer(log2(real(fifo_size))) - 1;
constant tx_fifo_null : std_logic_vector(fifo_bits + 1 downto 0) := (others => '0');
constant rx_fifo_null : std_logic_vector(fifo_bits downto 0) := (others => '0');

-- Baud generation constants
--constant c_tx_div				: integer := clk_frequency / baud;
--constant c_rx_div				: integer := clk_frequency / (baud * 16);

constant c_tx_maxdiv			: integer := clk_frequency / (2 * maxbaud);
constant c_rx_maxdiv			: integer := clk_frequency / (2 * (maxbaud * 16));
-- дополнительно 2 в знаменателе, т.к. один период тактовой частоты соответствует двум битам

constant c_tx_div_width		: integer := integer(log2(real(c_tx_maxdiv))) + 1;   
constant c_rx_div_width		: integer := integer(log2(real(c_rx_maxdiv))) + 1;

-- baud generation signals
signal rx_baud_pr				: std_logic_vector(15 downto 0);
signal tx_baud_pr				: std_logic_vector(15 downto 0);
signal tx_baud_counter		: std_logic_vector(c_tx_div_width - 1 downto 0) := (others => '0');   
signal tx_baud_tick			: std_logic := '0';
signal rx_baud_counter		: std_logic_vector(c_rx_div_width - 1 downto 0) := (others => '0');   
signal rx_baud_tick			: std_logic := '0';
signal number_of_bits		: std_logic_vector(2 downto 0);
signal total_length			: std_logic_vector(7 downto 0);
signal parity_type			: std_logic_vector(1 downto 0);
signal stop_bits				: std_logic;
-- registers
signal uart_dll				: std_logic_vector(7 downto 0):= b"00000001";
signal uart_dlm				: std_logic_vector(7 downto 0):=(others => '0');
signal uart_fcr				: std_logic_vector(7 downto 0):=(others => '0');
signal uart_lcr				: std_logic_vector(7 downto 0):=(others => '0');
signal uart_mcr				: std_logic_vector(7 downto 0):=(others => '0');
signal uart_lsr				: std_logic_vector(7 downto 0):=b"01100000";
signal uart_msr				: std_logic_vector(7 downto 0):=(others => '0');
signal uart_spr				: std_logic_vector(7 downto 0):=(others => '0');
signal uart_ier				: std_logic_vector(7 downto 0):=(others => '0');
signal uart_isr				: std_logic_vector(7 downto 0):= b"00000001";
-- transmitter signals	
type uart_tx_states is (tx_send_start_bit, tx_send_data, tx_send_parity_bit, tx_send_stop_bit0, tx_send_stop_bit1);             
signal uart_tx_state			: uart_tx_states := tx_send_start_bit;
signal uart_tx_data_vec		: std_logic_vector(7 downto 0) := (others => '0');
signal uart_tx_data			: std_logic := '1';
signal uart_tx_end_ena		: std_logic := '0';
signal uart_tx_end			: std_logic := '0';   
signal uart_tx_count			: std_logic_vector(2 downto 0) := (others => '0');
signal uart_rx_data_in_ack : std_logic := '0';
signal tx_parity_counter	: std_logic_vector(3 downto 0) := (others => '0');
-- receiver signals
type uart_rx_states is (rx_get_start_bit, rx_get_data, rx_get_parity_bit, rx_get_stop_bit);            
signal uart_rx_state			: uart_rx_states := rx_get_start_bit;
signal uart_rx_bit			: std_logic := '1';
signal uart_rx_data_vec		: std_logic_vector(7 downto 0) := (others => '0');
signal uart_rx_data_sr		: std_logic_vector(1 downto 0) := (others => '1');
signal uart_rx_filter		: std_logic_vector(1 downto 0) := (others => '1');
signal uart_rx_count			: std_logic_vector(2 downto 0) := (others => '0');
signal uart_rx_data_out_stb: std_logic := '0';
signal uart_rx_bit_spacing	: std_logic_vector (3 downto 0) := (others => '0');
signal uart_rx_bit_tick		: std_logic := '0';
signal rx_parity_counter	: std_logic_vector(3 downto 0) := (others => '0');
signal rx_parity_error		: std_logic := '0';
signal rx_framing_error		: std_logic := '0';
signal rx_overrun_error		: std_logic := '0';
signal rx_break_interrupt	: std_logic := '0';
signal rx_bi_counter			: std_logic_vector(7 downto 0) := (others => '1'); 
-- rx/tx fifo
type fifo_array is array(fifo_size - 1 downto 0) of std_logic_vector (7 downto 0);
signal rx_fifo					: fifo_array;
signal tx_fifo					: fifo_array;
signal rx_in_fifo_pointer	: std_logic_vector(fifo_bits downto 0) := (others => '0');
signal rx_out_fifo_pointer	: std_logic_vector(fifo_bits downto 0) := (others => '0');
signal tx_in_fifo_pointer	: std_logic_vector(fifo_bits downto 0) := (others => '0');
signal tx_out_fifo_pointer	: std_logic_vector(fifo_bits downto 0) := (others => '0');
signal data_stream_in_stb	: std_logic := '0';
signal data_stream_in		: std_logic_vector(7 downto 0);
signal reg_data_out_b			: std_logic_vector(7 downto 0);
signal fifo_in_number_overflow : std_logic := '0';
signal rx_fifo_filled			: std_logic_vector(fifo_bits + 1 downto 0) := (others => '0');
signal tx_fifo_filled			: std_logic_vector(fifo_bits + 1 downto 0) := (others => '0');
signal rts_b					: std_logic := '0';
-- interrupt signals
signal rls_interrupt			: std_logic := '0';
signal rx_data_available	: std_logic := '0';	 
signal tx_reg_empty_int		: std_logic := '0';
signal cts_old					: std_logic := '0';
signal ms_interrupt			: std_logic := '0';
signal fifo_rx_timeout		: std_logic := '0';
signal rx_timeout_counter	: std_logic_vector(9 downto 0) := (others => '1');
signal uart_int_b				: std_logic := '1';
signal receiver_dr			: std_logic := '0';
signal transmitter_empry	: std_logic := '1';
	 
begin

uart_int <= uart_int_b;
tx <= uart_tx_data;
reg_data_out(7 downto 0) <= reg_data_out_b(7 downto 0);
rts <= rts_b or uart_mcr(1);

-- parity_type:	01 => odd parity
--						11 => even parity
--						00 or 01 => no parity
--
-- stop bits:		0 => 1 bit
--						1 => 2 bits 

parity_type(1 downto 0) <= uart_lcr(4 downto 3);
number_of_bits <= '1' & uart_lcr(1 downto 0);
total_length(3 downto 0) <= ('0' & number_of_bits(2 downto 0)) + b"0010" + (b"000" & stop_bits) + (b"000" & parity_type(0));
stop_bits <= uart_lcr(2);

-- generate an oversampled tick (baud * 16)
-- внутренний счетчик считает до константы, определяемой соотношением clk_frequency/maxbaud, внешний до
-- значения 256*dlm + dll. maxbaud обычно 115200, но в принципе может быть иметь любое значение, меньшее чем clk_frequency
-- хотя бы в 16 раз
process(clk, reset)
begin
if(clk'event and clk = '1') then
	if(reset = '0') then
		rx_baud_counter <= (others => '0');
		rx_baud_pr <= (others => '0');	
		rx_baud_tick <= '0';    
	else
		if (rx_baud_counter = c_rx_maxdiv) then
			rx_baud_counter <= (others => '0');
			if(rx_baud_pr(15 downto 0) /= (uart_dlm(7 downto 0) & uart_dll(7 downto 0)) - 1) then
				rx_baud_pr <= rx_baud_pr + '1';
			else
				rx_baud_tick <= '1';
				rx_baud_pr <= (others => '0');
			end if;
		else
			rx_baud_counter <= rx_baud_counter + 1;
			rx_baud_tick <= '0';
		end if;
	end if;
end if;
end process;

-- synchronize rxd to the oversampled baud
process(clk, reset)
begin
if(clk'event and clk = '1') then
	if(reset = '0') then
		uart_rx_data_sr <= (others => '1');
	else
		if rx_baud_tick = '1' then
			uart_rx_data_sr(0) <= rx;
			uart_rx_data_sr(1) <= uart_rx_data_sr(0);
		end if;
	end if;
end if;
end process;

-- filter rxd with a 2 bit counter
process(clk, reset, rx_baud_tick)
begin
if(clk'event and clk = '1') then
	if(reset = '0') then
		uart_rx_filter <= (others => '1');
		uart_rx_bit <= '1';
	else
		if(rx_baud_tick = '1') then
			-- filter rxd
			if(uart_rx_data_sr(1) = '1' and uart_rx_filter < 3) then
				uart_rx_filter <= uart_rx_filter + 1;
			elsif(uart_rx_data_sr(1) = '0' and uart_rx_filter > 0) then
				uart_rx_filter <= uart_rx_filter - 1;
			end if;
			-- set the rx bit
			if(uart_rx_filter = 3) then
				uart_rx_bit <= '1';
			elsif uart_rx_filter = 0 then
				uart_rx_bit <= '0';
			end if;
		end if;
	end if;
end if;
end process;

-- RX_BIT_SPACING
process (clk, rx_baud_tick)
begin
if(clk'event and clk = '1') then
	uart_rx_bit_tick <= '0';
	if(rx_baud_tick = '1') then       
		if(uart_rx_bit_spacing = 15) then
			uart_rx_bit_tick <= '1';
			uart_rx_bit_spacing <= (others => '0');
		else
			uart_rx_bit_spacing <= uart_rx_bit_spacing + 1;
		end if;
		if(uart_rx_state = rx_get_start_bit) then
			uart_rx_bit_spacing <= (others => '0');
		end if; 
	end if;
end if;
end process;

-- UART_RECEIVE_DATA
process(clk, reset, rx_baud_tick, uart_rx_bit, uart_rx_bit_tick, number_of_bits, total_length, reg_stb_n, reg_addr, reg_wr_n, uart_lcr, rx_fifo_filled)
begin
if(clk'event and clk = '1') then
	if(reset = '0') then
		uart_rx_state <= rx_get_start_bit;
		uart_rx_data_vec <= (others => '0');
		uart_rx_count <= (others => '0');
		uart_rx_data_out_stb <= '0';
		rx_parity_counter	<= (others => '0');
		rx_parity_error <= '0';
		rx_framing_error <= '0';
		rx_bi_counter <= (others => '0');
		rx_break_interrupt <= '0';
		fifo_rx_timeout <= '0';
		rx_timeout_counter(9 downto 0) <= (others => '0');
	else
		uart_rx_data_out_stb <= '0';
		if(reg_stb_n = '0' and reg_wr_n = '1') then
			if(reg_addr = b"000" and uart_lcr(7) = '0') then
				fifo_rx_timeout <= '0'; rx_timeout_counter(9 downto 0) <= (others => '0');
			end if;
			if(reg_addr = b"101") then
				-- rd lsr clear interrupt flags
				rx_parity_error <= '0';
				rx_framing_error <= '0';
				rx_break_interrupt <= '0';
			end if;
		end if;
		if(rx_fifo_filled /= rx_fifo_null) then
			if(rx_timeout_counter(7 downto 0) /= total_length(3 downto 0) & b"1111") then
				rx_timeout_counter(7 downto 0) <= rx_timeout_counter(7 downto 0) + '1';
			else 
				if(rx_timeout_counter(9 downto 8) /= b"11") then
					rx_timeout_counter(9 downto 8) <= rx_timeout_counter(9 downto 8) + '1';
					rx_timeout_counter(7 downto 0) <= (others => '0');
				else
					fifo_rx_timeout <= '1';
				end if;
			end if;
		end if;
		if(uart_rx_bit = '1') then
			rx_bi_counter(7 downto 0) <= b"00000000";
		elsif(rx_baud_tick = '1') then
			rx_bi_counter(7 downto 0) <= rx_bi_counter(7 downto 0) + '1';
			if(rx_bi_counter(7 downto 0) = total_length(3 downto 0) & b"0000") then
				rx_break_interrupt <= '1';
			end if;
		end if;
		case uart_rx_state is
			when rx_get_start_bit =>
				if(rx_baud_tick = '1' and uart_rx_bit = '0') then
					uart_rx_state <= rx_get_data;
				end if;
			when rx_get_data =>
				if(uart_rx_bit_tick = '1') then
					uart_rx_data_vec(uart_rx_data_vec'high) <= uart_rx_bit;
					uart_rx_data_vec(uart_rx_data_vec'high-1 downto 0) <= uart_rx_data_vec(uart_rx_data_vec'high downto 1);
					if(uart_rx_bit = '1') then rx_parity_counter <= rx_parity_counter + '1'; end if; 
					if(uart_rx_count /= number_of_bits) then
						uart_rx_count <= uart_rx_count + 1;
					else
						uart_rx_count <= (others => '0');
						if(parity_type(0) = '0') then						
							uart_rx_state <= rx_get_stop_bit;
						else
							uart_rx_state <= rx_get_parity_bit;
						end if;
					end if;
				end if;
			when rx_get_parity_bit =>
				if(uart_rx_bit_tick = '1') then
					case parity_type is
						-- odd
						when b"01" =>
--							if(uart_rx_bit /= rx_parity_counter(0)) then
--								rx_parity_error <= '0';
--							else
--								rx_parity_error <= '1';
--							end if;
							if(uart_rx_bit = rx_parity_counter(0)) then rx_parity_error <= '1'; end if; 
						-- even
						when b"11" =>
--							if(uart_rx_bit = rx_parity_counter(0)) then
--								rx_parity_error <= '0';
--							else
--								rx_parity_error <= '1';
--							end if;
							if(uart_rx_bit /= rx_parity_counter(0)) then rx_parity_error <= '1'; end if;
						when others => null;
					end case;
					uart_rx_state <= rx_get_stop_bit;
					rx_parity_counter	<= (others => '0');
				end if;
			when rx_get_stop_bit =>
				if(uart_rx_bit_tick = '1') then
					if(uart_rx_bit = '1') then
						uart_rx_state <= rx_get_start_bit;
						uart_rx_data_out_stb <= '1';	
						rx_timeout_counter(9 downto 0) <= (others => '0');
					else rx_framing_error <= '1';
					end if;
				end if;                            
			when others =>
				uart_rx_state <= rx_get_start_bit;
		end case;
	end if;
end if;
end process;

-- TX_clk_DIVIDER
-- generate baud ticks at the required rate based on the input clk frequency and baud rate
process (clk, reset)
begin
if(clk'event and clk = '1') then
	if(reset = '0') then
		tx_baud_counter <= (others => '0');
		tx_baud_pr <= (others => '0');
		tx_baud_tick <= '0';
	else
		if(tx_baud_counter = c_tx_maxdiv) then
			tx_baud_counter <= (others => '0');
			if(tx_baud_pr(15 downto 0) /= (uart_dlm(7 downto 0) & uart_dll(7 downto 0)) - 1) then
				tx_baud_pr <= tx_baud_pr + '1';
			else 
				tx_baud_tick <= '1';
				tx_baud_pr <= (others => '0');
			end if;
		else
			tx_baud_counter <= tx_baud_counter + 1;
			tx_baud_tick <= '0';
		end if;
	end if;
end if;
end process;

-- UART_SEND_DATA 
-- get data from data_stream_in and send it one bit at a time upon each 
-- baud tick. send data lsb first.
-- wait 1 tick, send start bit (0), send data 0-7, send stop bit (1)
process(clk, reset, number_of_bits)
begin
if(clk'event and clk = '1') then
	if(reset = '0') then
		uart_tx_data <= '1';
		uart_tx_data_vec <= (others => '0');
		uart_tx_count <= (others => '0');
		uart_tx_state <= tx_send_start_bit;
		uart_rx_data_in_ack <= '0';
		uart_tx_end_ena <= '0';
		tx_parity_counter	<= (others => '0');
	else
		uart_rx_data_in_ack <= '0';
		if(uart_tx_end_ena = '1' and tx_baud_tick = '1') then
			uart_tx_end <= '1';
			uart_tx_end_ena <= '0';
		else
			uart_tx_end <= '0';
		end if;
		case uart_tx_state is
			when tx_send_start_bit =>
				if(tx_baud_tick = '1' and data_stream_in_stb = '1') then
					uart_tx_data  <= '0';
					uart_tx_state <= tx_send_data;
					uart_tx_count <= (others => '0');
					uart_rx_data_in_ack <= '1';
					uart_tx_data_vec <= data_stream_in;
				end if;
			when tx_send_data =>
				if(tx_baud_tick = '1') then
					uart_tx_data <= uart_tx_data_vec(0);
					uart_tx_data_vec(uart_tx_data_vec'high-1 downto 0) <= uart_tx_data_vec(uart_tx_data_vec'high downto 1);
					if(uart_tx_data_vec(0) = '1') then tx_parity_counter <= tx_parity_counter + '1'; end if; 
					if(uart_tx_count /= number_of_bits) then
						uart_tx_count <= uart_tx_count + 1;
					else
						uart_tx_count <= (others => '0');
						if(parity_type(0) = '0') then						
							uart_tx_state <= tx_send_stop_bit0;
						else
							uart_tx_state <= tx_send_parity_bit;
						end if;	
					end if;
				end if;
			when tx_send_parity_bit =>
				if(tx_baud_tick = '1') then
					case parity_type is
						-- odd
						when b"01" =>
							uart_tx_data <= not(tx_parity_counter(0));
						-- even
						when b"11" =>
							uart_tx_data <= tx_parity_counter(0);
						when others => null;
					end case;
					tx_parity_counter	<= (others => '0');
					uart_tx_state <= tx_send_stop_bit0;
				end if;	
			when tx_send_stop_bit0 =>
				if(tx_baud_tick = '1') then
					uart_tx_data <= '1';
					if(stop_bits = '0') then
						uart_tx_state <= tx_send_start_bit;
						uart_tx_end_ena <= '1';
					else 
						uart_tx_state <= tx_send_stop_bit1;
					end if;		
				end if;
			when tx_send_stop_bit1 =>
				if(tx_baud_tick = '1') then
					uart_tx_state <= tx_send_start_bit;
					uart_tx_end_ena <= '1';
				end if;
			when others =>
				uart_tx_data <= '1';
				uart_tx_state <= tx_send_start_bit;
				uart_tx_end_ena <= '0';
		end case;
	end if;
end if;
end process;

-- regs wr
process(clk, reset, reg_data_in, reg_stb_n, reg_wr_n)
begin
if(clk'event and clk = '1') then
	if(reset = '0') then
		uart_dll(7 downto 0) <= b"00000001";
		uart_dlm(7 downto 0) <= (others => '0');
		uart_fcr(7 downto 0) <= (others => '0');
		uart_lcr(7 downto 0) <= (others => '0');
		uart_mcr(7 downto 0) <= (others => '0');
		uart_spr(7 downto 0) <= (others => '0');
		uart_ier(7 downto 0) <= (others => '0');
	elsif(reg_stb_n = '0' and reg_wr_n = '0') then
		if(uart_fcr(2) = '1') then uart_fcr(2) <= '0'; end if; -- self-clearing bit
		if(uart_fcr(1) = '1') then uart_fcr(1) <= '0'; end if; -- self-clearing bit
		case reg_addr(2 downto 0) is
			when b"000" =>
				if(uart_lcr(7) = '1') then uart_dll(7 downto 0) <= reg_data_in(7 downto 0); end if;
			when b"001" => 
				if(uart_lcr(7) = '1') then
					uart_dlm(7 downto 0) <= reg_data_in(7 downto 0);
				else
					uart_ier(7 downto 0) <= reg_data_in(7 downto 0);
				end if;
			when b"010" => uart_fcr(7 downto 0) <= reg_data_in(7 downto 0);
			when b"011" => uart_lcr(7 downto 0) <= reg_data_in(7 downto 0);
			when b"100" => uart_mcr(7 downto 0) <= reg_data_in(7 downto 0);
			when b"111" => uart_spr(7 downto 0) <= reg_data_in(7 downto 0);
			when others => null;
		end case;
	end if;
end if;
end process;

-- transmitter fifo
process(clk, reset, reg_data_in, reg_stb_n, reg_wr_n, uart_lcr, uart_fcr)
begin
if(clk'event and clk = '1') then
	if(reset = '0') then
		tx_in_fifo_pointer <= (others => '0');
		tx_out_fifo_pointer <= (others => '0');
		data_stream_in_stb <= '0';
		tx_fifo_filled <= (others => '0');
		tx_reg_empty_int <= '0';
		transmitter_empry <= '1';
	else
		if(uart_fcr(2) = '1') then
			tx_in_fifo_pointer <= (others => '0');
			tx_out_fifo_pointer <= (others => '0');
			tx_fifo_filled <= (others => '0');
			transmitter_empry <= '1';			
		end if;
		if(tx_fifo_filled = tx_fifo_null and uart_tx_end_ena = '1') then transmitter_empry <= '1'; end if;
		if(reg_stb_n = '0' and reg_addr = b"000" and reg_wr_n = '0' and uart_lcr(7) = '0' and tx_fifo_filled /= fifo_size) then
			tx_fifo(to_integer(unsigned(tx_in_fifo_pointer(fifo_bits downto 0)))) <= reg_data_in(7 downto 0);
			tx_in_fifo_pointer <= tx_in_fifo_pointer + '1';
			tx_fifo_filled <= tx_fifo_filled + '1';
			tx_reg_empty_int <= '0';
			transmitter_empry <= '0';
		elsif(data_stream_in_stb = '0' and uart_tx_end_ena = '0' and cts = '0' and tx_fifo_filled /= tx_fifo_null) then
			data_stream_in(7 downto 0) <= tx_fifo(to_integer(unsigned(tx_out_fifo_pointer(fifo_bits downto 0))));
			data_stream_in_stb <= '1';
			tx_out_fifo_pointer <= tx_out_fifo_pointer + '1';
			tx_fifo_filled <= tx_fifo_filled - '1'; 
			if(tx_fifo_filled = 1) then tx_reg_empty_int <= '1'; end if;
		end if;
		if(data_stream_in_stb = '1' and uart_tx_end_ena = '1') then data_stream_in_stb <= '0'; end if;
		if(reg_stb_n = '0' and reg_addr = b"010" and reg_wr_n = '1') then tx_reg_empty_int <= '0'; end if;
	end if;
end if;
end process;

-- receiver fifo + regs rd
process(clk, reset, uart_rx_data_vec, uart_rx_data_out_stb, reg_stb_n, uart_dll, uart_dlm, uart_isr, uart_lcr, uart_mcr, uart_lsr, uart_msr, uart_spr, uart_fcr)
begin
if(clk'event and clk = '1') then
	if(reset = '0') then
		rx_in_fifo_pointer <= (others => '0');
		rx_out_fifo_pointer <= (others => '0');
		rts_b <= '0';
		rx_fifo_filled <= (others => '0');
		rx_overrun_error <= '0';
		rx_data_available <= '0';
		cts_old <= cts;
		receiver_dr <= '0';
		ms_interrupt <= '0';
	else
		if(cts /= cts_old) then ms_interrupt <= '1'; end if;
		if(uart_fcr(1) = '1') then 
			rx_in_fifo_pointer <= (others => '0');
			rx_out_fifo_pointer <= (others => '0');
			rx_fifo_filled <= (others => '0');
			rx_data_available <= '0';
			receiver_dr <= '0';
		end if;			
		if(rx_fifo_filled /= rx_fifo_null) then
			receiver_dr <= '1';
		else
			receiver_dr <= '0';
		end if;
		-- rx fifo
		if(uart_rx_data_out_stb	= '1' and rx_fifo_filled /= fifo_size) then
			rx_fifo(to_integer(unsigned(rx_in_fifo_pointer(fifo_bits downto 0)))) <= uart_rx_data_vec(7 downto 0);
			rx_in_fifo_pointer <= rx_in_fifo_pointer + '1';
			rx_fifo_filled <= rx_fifo_filled + '1';
			case uart_fcr(7 downto 6) is
				when b"00" => if(rx_fifo_filled = 0) then rx_data_available <= '1'; end if;
				when b"01" => if(rx_fifo_filled = 3) then rx_data_available <= '1'; end if;
				when b"10" => if(rx_fifo_filled = 7) then rx_data_available <= '1'; end if;
				when b"11" => if(rx_fifo_filled = 13) then rx_data_available <= '1'; end if;
				when others => null;
			end case;
			if(rx_fifo_filled = (rts_threshold - 1)) then rts_b <= '1'; end if;
		elsif(uart_rx_data_out_stb	= '1' and rx_fifo_filled = fifo_size) then
			rx_overrun_error <= '1';
		elsif(reg_stb_n = '0' and reg_addr = b"000" and reg_wr_n = '1' and uart_lcr(7) = '0' and (rx_fifo_filled /= rx_fifo_null)) then
			reg_data_out_b(7 downto 0) <= rx_fifo(to_integer(unsigned(rx_out_fifo_pointer(fifo_bits downto 0))));
			rx_out_fifo_pointer <= rx_out_fifo_pointer + '1';
			rx_fifo_filled <= rx_fifo_filled - '1';
			case uart_fcr(7 downto 6) is
				when b"00" => if(rx_fifo_filled = 1) then rx_data_available <= '0'; end if;
				when b"01" => if(rx_fifo_filled = 4) then rx_data_available <= '0'; end if;
				when b"10" => if(rx_fifo_filled = 8) then rx_data_available <= '0'; end if;
				when b"11" => if(rx_fifo_filled = 14) then rx_data_available <= '0'; end if;
				when others => null;
			end case;
			if(rx_fifo_filled = rts_threshold) then rts_b <= '0'; end if;
		end if;
		-- regs rd
		if(reg_stb_n = '0' and reg_wr_n = '1') then
			case reg_addr(2 downto 0) is
				when b"000" => 
					if(uart_lcr(7) = '1') then reg_data_out_b(7 downto 0) <= uart_dll(7 downto 0); end if;
				when b"001" => 
					if(uart_lcr(7) = '0') then
						reg_data_out_b(7 downto 0) <= uart_ier(7 downto 0);
					else
						reg_data_out_b(7 downto 0) <= uart_dlm(7 downto 0);
					end if;
				when b"010" => reg_data_out_b(7 downto 0) <= uart_isr(7 downto 0);
				when b"011" => reg_data_out_b(7 downto 0) <= uart_lcr(7 downto 0);
				when b"100" => reg_data_out_b(7 downto 0) <= uart_mcr(7 downto 0);
				when b"101" => reg_data_out_b(7 downto 0) <= uart_lsr(7 downto 0); rx_overrun_error <= '0';
				when b"110" => reg_data_out_b(7 downto 0) <= uart_msr(7 downto 0); cts_old <= cts; ms_interrupt <= '0';
				when b"111" => reg_data_out_b(7 downto 0) <= uart_spr(7 downto 0);
				when others => null;
			end case;
		end if;
	end if;
end if;
end process;

rls_interrupt <= (rx_parity_error or rx_framing_error or rx_overrun_error or rx_break_interrupt);
uart_int_b <= not((rx_data_available and uart_ier(0)) or (tx_reg_empty_int and uart_ier(1)) or (rls_interrupt and uart_ier(2)) or (ms_interrupt and uart_ier(3)));
uart_isr(0) <= uart_int_b;
uart_isr(3 downto 1) <= b"110" when (rls_interrupt = '1' and uart_ier(2) = '1')
else b"100" when ((rx_data_available = '1' or fifo_rx_timeout = '1') and uart_ier(0) = '1')
else b"010" when (tx_reg_empty_int = '1' and uart_ier(1) = '1')
else b"000" when (ms_interrupt = '1' and uart_ier(3) = '1')
else b"001";
uart_isr(5 downto 4) <= b"00";
uart_isr(7 downto 6) <= uart_fcr(0) & uart_fcr(0);
uart_msr(7 downto 0) <= "101" & cts & b"000" & ms_interrupt;
uart_lsr(7 downto 0) <= (rx_parity_error or rx_framing_error or rx_break_interrupt) & transmitter_empry & tx_reg_empty_int & rx_break_interrupt & rx_framing_error & rx_parity_error & rx_overrun_error & receiver_dr; 

end rtl;