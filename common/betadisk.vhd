-- betadisk interface & KR1818VG93 

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity betadisk is
  port (
    vg93_cs             : in std_logic;
    vg93_ram_addr       : out std_logic_vector(19 downto 0);
    fpga_data_transfer  : in std_logic := '1';
    write_byte_n        : out std_logic_vector(7 downto 0);
    write_sector_n      : out std_logic_vector(7 downto 0);
    read_sector_n       : out std_logic_vector(7 downto 0);
    read_byte_n         : out std_logic_vector(7 downto 0);
    track_f             : out std_logic;
    sector_f            : out std_logic;
    restore_f           : out std_logic;
    vg93_O_data         : out std_logic_vector(7 downto 0);
    force_interrupt_f   : out std_logic;
    track_pos           : out std_logic_vector(7 downto 0);
    track_r             : out std_logic_vector(7 downto 0);
    sector_r            : out std_logic_vector(7 downto 0);
    status_r            : out std_logic_vector(7 downto 0);
    betadisk_r          : in std_logic_vector(7 downto 0);
    vg93intrq           : out std_logic;
    seek_f              : out std_logic;
    vg93drq             : out std_logic;
    step_f              : out std_logic;
    step_dir            : out std_logic;
    read_addr_f         : out std_logic;
    read_f              : out std_logic;
    write_f             : out std_logic;
    vg93_data_from_ram  : in std_logic_vector(7 downto 0);
    vg_trm_f            : in std_logic;
    read_t              : out std_logic;
    write_t             : out std_logic;
    cpu_rd         : in std_logic;
    cpu_wr         : in std_logic;
    cpu_a          : in std_logic_vector(15 downto 0);
    cpu_d          : in std_logic_vector(7 downto 0);
    mainclk         : in std_logic;
    hardware_reset      : in std_logic;
    vg93_data_for_cpu_o : out std_logic_vector(7 downto 0);
    vg93_data_for_r    	: out std_logic_vector(7 downto 0);
	 index					: out std_logic
);
end;

architecture bdi of betadisk is

constant bytes_in_sector: natural:=256; 
constant sectors_in_track: natural:=16; 

-- vg93 signals
signal vg93_data_from_cpu: std_logic_vector(7 downto 0);
signal betadisk_reg: std_logic_vector(7 downto 0);
signal status_reg: std_logic_vector(7 downto 0);
signal track_reg: std_logic_vector(7 downto 0);
signal track_position: std_logic_vector(7 downto 0);
signal sector_reg: std_logic_vector(7 downto 0);
signal vg93_I_data: std_logic_vector(7 downto 0);
signal vg93_data_for_cpu : std_logic_vector(7 downto 0);
signal command_reg: std_logic_vector(7 downto 0);
signal vg93_reset: std_logic;

signal vg93_drq: std_logic;
signal command_intrq: std_logic;

signal accept_command_flag: std_logic;
signal vg93_busy_flag: std_logic;
signal step_direction: std_logic;
signal mojno_wait: std_logic_vector(4 downto 0);
signal sync_rdwr_data: std_logic;
signal vg93_start: std_logic;
signal write_sector_flag: std_logic;
signal read_address_flag: std_logic;

signal fi_flag: std_logic;
signal io_sector: std_logic;
signal io_track: std_logic;
signal vg93_clk: std_logic;
signal io_ready: std_logic;
signal current_sector: std_logic_vector(7 downto 0);
signal current_byte: std_logic_vector(7 downto 0);

signal busrq_flag: std_logic;
signal vg_busrq: std_logic;
signal busack_flag: std_logic;
signal mwflag: std_logic;
signal vg93_reset_flags: std_logic := '1';

signal vg93_data_from_ramdisk: std_logic_vector(7 downto 0);

signal vg_state: std_logic_vector(1 downto 0);
signal vg93_io: std_logic;
signal vg93_nrd: std_logic;
signal restore_flag: std_logic;
signal seek_flag: std_logic;
signal step_flag: std_logic;
signal read_start: std_logic;
signal write_start: std_logic;
signal read_addr_flag: std_logic;
signal read_flag: std_logic;
signal write_flag: std_logic;
signal sector_flag: std_logic;
signal vg_delay: std_logic;
signal vg_delay_res: std_logic;
signal radr_intrq_flag: std_logic:='0';

signal mbit: std_logic;
signal track_flag: std_logic;
signal force_interrupt_flag: std_logic;
signal delay_vg:std_logic_vector(30 downto 0);
signal radr_state:std_logic_vector(2 downto 0);
signal radr_flag0:std_logic;
signal radr_delay:std_logic_vector(6 downto 0);
signal radr_nrd:std_logic;
signal radr_out_data:std_logic_vector(7 downto 0);
signal radr_drq:std_logic;
signal read_state:std_logic_vector(1 downto 0);
signal vg93_trm:std_logic;
signal read_byte_number:std_logic_vector(8 downto 0);
signal read_delay:std_logic_vector(6 downto 0);
signal read_trz:std_logic;
signal read_flg0:std_logic;
signal read_flg1:std_logic;
signal read_drq:std_logic;
signal read_nrd:std_logic;
signal read_intrq_flag:std_logic:='0';
signal read_sector_num:std_logic_vector(7 downto 0);
signal read_trm:std_logic;
signal write_state:std_logic_vector(1 downto 0);
signal write_byte_number:std_logic_vector(8 downto 0);
signal write_delay:std_logic_vector(6 downto 0);
signal write_trz:std_logic;
signal write_flg0:std_logic;
signal write_drq:std_logic;
signal write_flg1:std_logic;
signal write_nrd:std_logic;
signal write_intrq_flag:std_logic:='0';
signal write_sector_num:std_logic_vector(7 downto 0);
signal write_trm:std_logic;
signal vg_tormoz:std_logic;
signal tr00:std_logic;
signal index_pulse:std_logic;
signal index_pulse_period: std_logic_vector(24 downto 0);
signal motor_start: std_logic:='1'; -- мотор крутится, когда 0
signal motor_stop: std_logic:='0'; -- мотор крутится, когда 0
signal motor: std_logic;
signal motor_reset: std_logic;
signal motor_flag: std_logic:='0';

signal betadisk_transmit_counter:std_logic_vector(4 downto 0);
signal betadisk_transmit:std_logic;
signal vg_delay_flag0: std_logic;
signal vg_delay_flag1: std_logic;
signal force_interrupt_int: std_logic;
signal vg93_ram_addr0:std_logic_vector(19 downto 0); 
signal all_command_flags: std_logic;
signal vg93_cs1time: std_logic;
signal motor1time: std_logic;
signal vg_delay1time: std_logic;

begin

vg93_reset <= betadisk_reg(2);
motor_stop <= betadisk_reg(3);
vg93_drq <= radr_drq or read_drq or write_drq;
tr00 <= '1' when (track_position(7 downto 0) = b"00000000") else '0';
status_reg(7) <= '0';
status_reg(6) <= '0';
status_reg(5) <= '0' when (read_addr_flag = '0' or read_flag = '0' or write_flag = '0' or all_command_flags = '1') else '1';
status_reg(4) <= '0';
status_reg(3) <= '0';
status_reg(2) <= '0' when (read_addr_flag = '0' or read_flag = '0' or write_flag = '0' or all_command_flags = '1') else tr00;
status_reg(1) <= vg93_drq when (read_addr_flag = '0' or read_flag = '0' or write_flag = '0') else index_pulse;
status_reg(0) <= vg93_nrd;

all_command_flags <= read_addr_flag and read_flag and write_flag and track_flag and sector_flag and seek_flag and step_flag and restore_flag;

process(mainclk, vg93_reset, hardware_reset,
            vg_delay_res, radr_intrq_flag, read_intrq_flag, write_intrq_flag,
            vg93_cs, vg93_clk, cpu_rd, cpu_wr,
            cpu_a, cpu_d, force_interrupt_flag, force_interrupt_int)
begin
if(mainclk'event and mainclk = '1') then 
	if(hardware_reset = '0' or vg93_reset = '0') then
		command_reg(7 downto 0) <= b"00000011";
		sector_reg <= b"00000001";
		track_reg <= b"00000000";
		track_position <= b"00000000";
		restore_flag <= '0';
		command_intrq <= '0';
		vg_delay <= '1';
		step_direction <= '1'; -- направление перемещения головки: 0 - на уменьшение, 1 на увеличение
		vg93_nrd <= '1'; -- not ready flag
		seek_flag <= '1';
		step_flag <= '1';
		read_addr_flag <= '1';
		read_flag <= '1';
		write_flag <= '1';
		sector_flag <= '1';
		track_flag <= '1';
		write_sector_flag <= '1';
		read_address_flag <= '1';
		force_interrupt_flag <= '1';
		force_interrupt_int <= '1';
	end if;
	if(vg_delay_res = '1' or radr_intrq_flag = '1' or read_intrq_flag = '1' or write_intrq_flag = '1' or force_interrupt_flag = '0') then
		vg_delay <= '0';
		motor_start <= '1';
		if(force_interrupt_flag = '0') then
			force_interrupt_flag <= '1';
			read_flag <= '1';
			sector_flag <='1'; 
			track_flag <='1';
			write_flag <= '1';
			read_addr_flag <= '1'; 
			restore_flag <= '1';
			seek_flag <= '1';
			step_flag <= '1'; 
			write_start <= '1';
			read_start <= '1';
			if(force_interrupt_int ='1') then command_intrq <= '1'; end if;
		else
			command_intrq <= '1';
		end if; 
		vg93_nrd <= '0';
		read_addr_flag <= '1'; 
		if(restore_flag = '0') then restore_flag <= '1'; track_reg <= b"00000000"; track_position <= b"00000000"; end if;
		seek_flag <= '1';
		step_flag <= '1'; 
		write_start <= '1';
		read_start <= '1';
	end if;
	if(vg93_cs = '1') then vg93_cs1time <= '0'; end if;
	if(vg93_cs = '0' and vg93_cs1time = '0') then
		vg93_cs1time <= '1';
		if(betadisk_reg(1 downto 0)="00") then -- работаем только на диске A:
			if(cpu_rd = '0') then
				case cpu_a(6 downto 5) is
					when b"00" => vg93_O_data(7 downto 0) <= status_reg(7 downto 0); command_intrq <= '0'; 
					when b"01" => vg93_O_data(7 downto 0) <= track_reg(7 downto 0);
					when b"10" => vg93_O_data(7 downto 0) <= sector_reg(7 downto 0);
					when b"11" => vg93_O_data(7 downto 0) <= vg93_data_for_cpu(7 downto 0);
					when others =>null;
				end case;
			end if;
			if(cpu_wr='0') then
				--vg93_O_data(7 downto 0) <= (others => 'Z');
				case cpu_a(6 downto 5) is -- загрузка кода команды
					when b"00" =>
						command_reg(7 downto 0) <= cpu_d(7 downto 0);
						command_intrq <= '0'; -- надо уточнить, нужно ли
						case cpu_d(7 downto 4) is
							-- restore command
							when "0000" => read_flag <= '1'; write_flag <= '1'; sector_flag <='1'; track_flag <='1'; restore_flag <= '0'; vg_delay <= '1'; vg93_nrd <= '1';
							-- seek command
							when "0001" => read_flag <= '1'; write_flag <= '1'; sector_flag <='1'; track_flag <='1'; seek_flag <= '0'; track_position(7 downto 0) <= vg93_data_from_cpu(7 downto 0); track_reg(7 downto 0) <= vg93_data_from_cpu(7 downto 0); vg_delay <= '1'; vg93_nrd <= '1'; motor_start <= '0';
							-- step command
							when "0010" => read_flag <= '1'; write_flag <= '1'; sector_flag <='1'; track_flag <='1'; step_flag <= '0'; vg_delay <= '1'; vg93_nrd <= '1'; motor_start <= '0';
								if(step_direction = '1') then
									track_position(7 downto 0) <= track_position(7 downto 0) + '1'; 
								else if(track_position(7 downto 0) > b"00000000") then track_position(7 downto 0) <= track_position(7 downto 0) - '1'; end if;
								end if;
							when "0011" => read_flag <= '1'; write_flag <= '1'; sector_flag <='1'; track_flag <='1'; step_flag <= '0'; vg_delay <= '1'; vg93_nrd <= '1'; motor_start <= '0';
								if (step_direction = '1') then
									track_position(7 downto 0) <= track_position(7 downto 0) + '1'; track_reg(7 downto 0) <= track_position(7 downto 0) + '1'; 
								else if(track_position(7 downto 0) > b"00000000") then track_position(7 downto 0) <= track_position(7 downto 0) - '1'; track_reg(7 downto 0) <= track_position(7 downto 0) - '1'; end if;
								end if;
							-- step in command
							when "0100" =>	read_flag <= '1'; write_flag <= '1'; sector_flag <='1'; track_flag <='1'; step_flag <= '0'; step_direction <= '1'; vg_delay <= '1'; vg93_nrd <= '1'; motor_start <= '0';
												track_position(7 downto 0) <= track_position(7 downto 0) + '1'; 
							when "0101" =>	read_flag <= '1'; write_flag <= '1'; sector_flag <='1'; track_flag <='1'; step_flag <= '0'; step_direction <= '1'; vg_delay <= '1'; vg93_nrd <= '1'; motor_start <= '0';
												track_position(7 downto 0) <= track_position(7 downto 0) + '1'; track_reg(7 downto 0) <= (track_position(7 downto 0) + '1'); 
							-- step out command
							when "0110" => read_flag <= '1'; write_flag <= '1'; sector_flag <='1'; track_flag <='1'; step_flag <= '0'; step_direction <= '0'; vg_delay <= '1'; vg93_nrd <= '1'; motor_start <= '0';
								if(track_position > 0) then track_position(7 downto 0) <= track_position(7 downto 0) - '1'; end if;
							when "0111" => read_flag <= '1'; write_flag <= '1'; sector_flag <='1'; track_flag <='1'; step_flag <= '0'; step_direction <= '0'; vg_delay <= '1'; vg93_nrd <= '1'; motor_start <= '0';
								if(track_position > 0) then track_position(7 downto 0) <= track_position(7 downto 0) - '1'; track_reg(7 downto 0) <= (track_position(7 downto 0) - '1'); end if;
							-- read address command
							when "1100" => read_flag <= '1'; write_flag <= '1'; sector_flag <='1'; track_flag <='1'; read_addr_flag <= '0'; vg93_nrd <= '1';
							-- read sector command
							when "1000" => write_flag <= '1'; track_flag <='1'; read_flag <= '0'; sector_flag <='0'; mbit <= '0'; vg93_nrd <= '1'; read_start <= '0';--mbit <= virt_cpu_d(4);
							when "1001" => write_flag <= '1'; track_flag <='1'; read_flag <= '0'; sector_flag <='0'; mbit <= '1'; vg93_nrd <= '1'; read_start <= '0';--mbit <= virt_cpu_d(4);
							-- write sector command
							when "1010" => read_flag <= '1'; track_flag <='1'; write_flag <= '0'; sector_flag <= '0'; mbit <= '0'; vg93_nrd <= '1'; write_start <= '0';
							when "1011" => read_flag <= '1'; track_flag <='1'; write_flag <= '0'; sector_flag <= '0'; mbit <= '1'; vg93_nrd <= '1'; write_start <= '0';
							-- read track command
							when "1110" => write_flag <= '1'; sector_flag <='1'; read_flag <= '0'; track_flag <= '0'; vg93_nrd <= '1'; read_start <= '0';
							-- write track command
							when "1111" => read_flag <= '1'; sector_flag <='1'; write_flag <='0'; track_flag <= '0'; vg93_nrd <= '1'; write_start <= '0';
							-- force interrupt command
							-- при реализации force interrupt в реальном вг93 есть несколько вариантов
							-- генерирования прерываний (в зависимости от готовности дисковода или
							-- прихода индексных меток), есть мнение, что на это все можно смело забить и сгенерировать
							-- прерывание тупо после задержки по времени, при условии, что биты I0,I1,I2,I3 не равны нулю одновременно
							-- (в этом случае прерывание не генерируется)
							when "1101" => force_interrupt_flag <= '0';
												vg93_nrd <= '0'; -- Уточнить !!! 
												vg_delay <= '1';
												force_interrupt_int <= (cpu_d(0) or cpu_d(1) or cpu_d(2) or cpu_d(3));
							when others => null;
						end case;
					when b"01" => track_reg(7 downto 0) <= cpu_d(7 downto 0);
					when b"10" => sector_reg(7 downto 0) <= cpu_d(7 downto 0);
					when b"11" => vg93_data_from_cpu(7 downto 0) <= cpu_d(7 downto 0);
					when others => null;
				end case;
			end if;
		end if;
	end if;
end if;
end process;

-- index pulse: частота врщения диска 5 Гц, длительность индексного импульса 4 мс (в реале около 3 мс для 3.5", около 4 мс для 5.25")

motor <= motor_start or motor_stop;
process (mainclk, motor, motor_reset)
begin
if(mainclk'event and mainclk = '1') then
	if(motor_reset = '1') then
		motor1time <= '0';
		motor_flag <= '0';
	end if;
	if(motor = '0' and motor1time = '0') then
		motor1time <= '1';
		motor_flag <= '1';
	end if;
end if;
end process;

process(mainclk, motor_flag, motor)
begin
if(mainclk'event and mainclk = '1') then
	if(motor_flag = '1' and motor_reset = '0') then motor_reset <= '1'; index_pulse_period(24 downto 0) <= (others => '0');
		else motor_reset <= '0'; 
			if(not(index_pulse_period(24 downto 0) = b"1010110111001010010100011")) then index_pulse_period(24 downto 0) <= index_pulse_period(24 downto 0) + '1';
				else index_pulse_period(24 downto 0) <= (others => '0');
			end if;
	end if;
	if(index_pulse_period(24 downto 0) = b"1010101001010000100000110") then index_pulse <= '1'; 
		elsif(index_pulse_period(24 downto 0) = b"1010110111001010010100010") then index_pulse <= '0';
	end if;
end if;
end process;

-- delays emulation
process(mainclk, vg_delay, vg93_reset, restore_flag)
begin
if(mainclk'event and mainclk = '1') then
	vg_delay1time <= vg_delay;
	if((vg_delay = '1' and vg_delay1time = '0') or vg93_reset = '0') then
		if(restore_flag = '0' or read_address_flag='0') then
			delay_vg(28 downto 0) <= b"00011110101000000000000000000";
		else delay_vg(28 downto 7) <= (others => '0'); delay_vg(6 downto 0) <= b"1111111";
		end if;
	end if;
	if(not(delay_vg = 0)) then delay_vg(28 downto 0) <= delay_vg(28 downto 0) - '1'; end if;
	if(delay_vg(28 downto 0) = b"00000000000000000000000000001") then
		vg_delay_res <= '1';
     else vg_delay_res <= '0';
	end if;
end if;
end process;

-- read addr process
process(mainclk, hardware_reset, vg93_reset, read_addr_flag, vg93_cs, force_interrupt_flag, cpu_rd, cpu_a)
begin
if(hardware_reset = '0' or vg93_reset = '0' or force_interrupt_flag = '0') then
	radr_drq <= '0';
	radr_nrd <= '1';
elsif(read_addr_flag = '1') then
	radr_state(2 downto 0) <= b"110";
	radr_flag0 <= '0';
	radr_delay(6 downto 0) <= (others =>'1');
	radr_intrq_flag <= '0';
	radr_out_data(7 downto 0) <= b"00000000";
elsif(vg93_cs = '0' and cpu_rd='0' and cpu_a(6 downto 5) = b"11") then
	radr_drq <= '0'; -- сбрасываем drq при чтении данных
elsif (mainclk'event and mainclk = '1') then
	if(radr_state(2 downto 0) = b"110") then radr_nrd <='0'; end if;
	if(radr_delay(6 downto 0) > 0) then radr_delay(6 downto 0) <= radr_delay(6 downto 0) - '1'; end if;
	if(radr_delay(6 downto 0) = b"0000010") then
		case radr_state(2 downto 0) is
			when b"110" => radr_out_data(7 downto 0) <= track_position(7 downto 0);--b"11100111"; -- track_addr
			when b"101" => radr_out_data(7 downto 0) <= b"0000000" & betadisk_reg(4);--b"11111110"; -- side
			when b"100" => radr_out_data(7 downto 0) <= sector_reg(7 downto 0);--b"11111100"; -- sector address
			when b"011" => radr_out_data(7 downto 0) <= b"11111111"; -- sector length
			when b"010" => radr_out_data(7 downto 0) <= b"11110000"; -- crc1
			when b"001" => radr_out_data(7 downto 0) <= b"11100000"; -- crc2
			when others => null;
		end case;
	end if;
	if(radr_delay(6 downto 0) = b"0000001" and radr_state > 0) then radr_drq <= '1'; end if;
	if((radr_delay(6 downto 0) = b"0000000") and (radr_state > 0) and (radr_drq = '0') ) then
		radr_delay(6 downto 0) <= (others =>'1');
		radr_state(2 downto 0) <= radr_state(2 downto 0)-'1';
	end if;
	if(radr_state(2 downto 0)=b"000") then
		if(radr_delay = 126) then radr_intrq_flag <= '1'; radr_nrd <= '1'; end if;
	end if;
end if;
end process;

-- read track/sector process
process(mainclk, hardware_reset, vg93_reset, read_start, sector_flag, track_flag, mbit, force_interrupt_flag, sector_reg, vg_tormoz, vg93_cs, cpu_rd, cpu_a)
begin
if(hardware_reset = '0' or vg93_reset = '0' or force_interrupt_flag = '0') then read_drq <= '0'; read_trz <= '0';
elsif(read_start='1') then read_state(1 downto 0) <= b"00"; read_byte_number(8 downto 0) <= (others =>'0'); read_delay(6 downto 0) <= (others =>'1'); read_trz <= '0'; read_flg0 <='0'; read_drq <='0'; read_flg1 <='0'; read_nrd <='0'; read_intrq_flag <='0';
elsif(vg93_cs = '0' and cpu_rd='0' and cpu_a(6 downto 5) = b"11") then read_drq <= '0'; -- сбрасываем drq при чтении данных
elsif(mainclk'event and mainclk = '1') then
	if(read_state = b"00") then
		read_nrd <= '1';
		if(read_nrd = '1') then read_state <= b"01"; end if;
		if(sector_flag = '0') then read_sector_num(7 downto 0) <= sector_reg(7 downto 0); end if;
		if(track_flag = '0') then read_sector_num(7 downto 0) <= b"00000001"; end if;
	end if;
	if(read_delay > 0) then read_delay(6 downto 0) <= read_delay(6 downto 0) - '1'; end if;
	if((read_delay(6 downto 0) = b"0000001") and (read_byte_number < bytes_in_sector)) then read_trz <= '1'; end if;
	if(vg_tormoz = '1' and read_trz='1') then read_trz <='0'; read_flg0 <='1'; end if;
	if(vg_tormoz = '0' and read_flg0 ='1') then read_flg0 <='0'; read_drq <='1'; read_flg1 <='1'; end if;
	if(read_flg1 ='1' and read_drq = '0') then
		read_flg1 <='0';
		if(read_byte_number < bytes_in_sector) then
			read_byte_number(8 downto 0) <= read_byte_number(8 downto 0) + '1';
			read_delay(6 downto 0) <= (others =>'1');
		end if;
	end if;
	if((read_byte_number = bytes_in_sector) and (read_delay(6 downto 0) = b"0000001")) then
		if(mbit = '0' and track_flag='1') then
			read_intrq_flag <= '1';
		else
			if(read_sector_num < sectors_in_track) then
				read_sector_num(7 downto 0) <= read_sector_num(7 downto 0) + '1';
				read_byte_number(8 downto 0) <= (others =>'0');
				read_delay(6 downto 0) <= (others =>'1');
			else
				read_intrq_flag <= '1';
			end if;
		end if;
	end if;
	if(read_intrq_flag='1') then read_intrq_flag<='0'; read_nrd <='0'; end if;
end if;
end process;

-- write track/sector process
process(mainclk, hardware_reset, vg93_reset, write_start, vg93_cs, cpu_wr, cpu_a, mbit, force_interrupt_flag, sector_reg, sector_flag, track_flag, vg_tormoz)
begin
if(hardware_reset = '0' or vg93_reset = '0' or force_interrupt_flag = '0') then
	write_drq <= '0';
	write_trz <= '0';
elsif(write_start='1') then
	write_state(1 downto 0) <= b"00";
	write_byte_number(8 downto 0) <= (others =>'0');
	write_delay(6 downto 0) <= (others =>'1');
	write_trz <= '0';
	write_flg0 <='0';
	write_drq <='0';
	write_flg1 <='0';
	write_nrd <='0';
	write_intrq_flag <='0';
elsif(vg93_cs = '0' and cpu_wr='0' and cpu_a(6 downto 5) = b"11") then
	write_drq <= '0'; -- сбрасываем drq при получении данных
elsif(mainclk'event and mainclk = '1') then
	if(write_state = b"00") then
		write_nrd <= '1';
		if(write_nrd = '1') then write_state <= b"01"; end if;
		if(sector_flag = '0') then write_sector_num(7 downto 0) <= sector_reg(7 downto 0); end if;
		if(track_flag = '0') then write_sector_num(7 downto 0) <= b"00000001"; end if;
	end if;
	if(write_delay > 0) then write_delay(6 downto 0) <= write_delay(6 downto 0) - '1'; end if;
	if((write_delay(6 downto 0) = b"0000001") and (write_byte_number < bytes_in_sector)) then write_drq <= '1'; write_flg0 <='1'; end if;
	if(write_flg0 = '1' and write_drq = '0') then write_flg0 <='0'; write_trz <='1'; end if;
	if(vg_tormoz = '1') then write_trz <='0'; write_flg1 <= '1'; end if;
	if(write_flg1 = '1' and vg_tormoz = '0') then
		write_flg1 <= '0';
		if(write_byte_number < bytes_in_sector) then
			write_byte_number(8 downto 0) <= write_byte_number(8 downto 0) + '1';
			write_delay(6 downto 0) <= (others =>'1');
		end if;
	end if;
	if((write_byte_number = bytes_in_sector) and (write_delay(6 downto 0)=b"0000001")) then
		if(mbit = '0') then
			write_intrq_flag <='1';
		else
			if(write_sector_num < sectors_in_track) then
				write_sector_num(7 downto 0) <= write_sector_num(7 downto 0) + '1';
				write_byte_number(8 downto 0) <= (others =>'0');
				write_delay(6 downto 0) <= (others =>'1');
			else write_intrq_flag <='1';
			end if;
		end if;
	end if;
if(write_intrq_flag ='1') then write_intrq_flag <='0'; write_nrd <= '0'; end if;
end if;
end process;

-- у вг93 дороги нумеруются от 0 до 80 (+ 1 бит верх-низ, итого до 160), сектора от 1 до 16
process(mainclk, track_position, betadisk_reg, read_flag, write_flag, read_sector_num, read_byte_number, write_sector_num, write_byte_number)
begin
if(mainclk'event and mainclk = '1') then
	vg93_ram_addr(19 downto 14) <= b"110110" - track_position(6 downto 1);
	vg93_ram_addr(13 downto 12) <= track_position(0) & not(betadisk_reg(4));
	if(read_flag = '0') then
		vg93_ram_addr(11 downto 0)	<= (read_sector_num(3 downto 0)-'1') & read_byte_number(7 downto 0);
	end if;
	if(write_flag = '0') then
		vg93_ram_addr(11 downto 0)	<= (write_sector_num(3 downto 0)-'1') & write_byte_number(7 downto 0);
	end if;
end if;	
end process;

vg93_data_for_cpu(7 downto 0) <= radr_out_data(7 downto 0) when (read_addr_flag = '0') else vg93_data_from_ram(7 downto 0);

vg93_data_for_r <= vg93_data_from_cpu;
vg93_data_for_cpu_o <= vg93_data_for_cpu;
write_byte_n(7 downto 0) <= write_byte_number(7 downto 0);
write_sector_n <= write_sector_num;
read_sector_n <= read_sector_num;
read_byte_n(7 downto 0) <= read_byte_number(7 downto 0);
track_f <= track_flag;
sector_f <= sector_flag;
restore_f <= restore_flag;
force_interrupt_f <= force_interrupt_flag;
track_pos <= track_position;
track_r <= track_reg;
sector_r <= sector_reg;
status_r <= status_reg;
betadisk_reg <= betadisk_r;
vg93intrq <= command_intrq;
seek_f <= seek_flag;
vg93drq <= vg93_drq;
step_f <= step_flag;
step_dir <= step_direction;
read_addr_f <= read_addr_flag;
read_f <= read_flag;
write_f <= write_flag;
vg_tormoz <= vg_trm_f;
read_t <= read_trz;
write_t <= write_trz;
index <= index_pulse;

end bdi;