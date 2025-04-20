-- PENTAGON ver. 2.666 (LE) by koe
-- top level design entity, started on 12.07.2008

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
USE ieee.numeric_std.ALL;
library work;  
use work.all;

-- **************************************************************

entity PaE is

	port (
		clk									: in std_logic;								
		r_adr									: out std_logic_vector(18 downto 0);	
		blk0_d								: inout std_logic_vector(7 downto 0);	
		blk1_d								: inout std_logic_vector(7 downto 0);	
		snd									: inout std_logic_vector(7 downto 0);
		str_r									: out std_logic;
		str_l									: out std_logic;
		led							: out std_logic;								
		ssi									: out std_logic;
		ksi									: out std_logic;
		vid_r									: out std_logic_vector(4 downto 0);
		vid_g									: out std_logic_vector(4 downto 0);
		vid_b									: out std_logic_vector(4 downto 0);
		we_blk0chp0							: out std_logic;
		oe_blk0chp0							: out std_logic;
		we_blk0chp1							: out std_logic;
		oe_blk0chp1							: out std_logic;
		we_blk1chp0							: out std_logic;
		oe_blk1chp0							: out std_logic;
		we_blk1chp1							: out std_logic;
		oe_blk1chp1							: out std_logic;
		i2c_scl								: in std_logic;
		i2c_sda								: inout std_logic:='Z';
		fpga_clk_output					: out std_logic;
		fpga_mreq_output					: out std_logic;
		fpga_rfsh_output					: out std_logic;
		fpga_wr_output						: out std_logic;
		fpga_iorq_output					: out std_logic;
		fpga_halt_output					: out std_logic;
		fpga_busack_output				: out std_logic;
		fpga_m1_output						: out std_logic;
		fpga_rd_output						: out std_logic;
		fpga_dos_output					: out std_logic;
		fpga_f_output						: out std_logic;
		fpga_int_output					: out std_logic;
		fpga_csr_output					: out std_logic;
		fpga_rs_output						: out std_logic;
		fpga_rs_in							: in std_logic;
		fpga_rdrom_input					: in std_logic;
		fpga_nmi_input						: in std_logic;
		fpga_busrq_input					: in std_logic;
		fpga_res_input						: in std_logic;
		fpga_wait_input					: in std_logic;
		fpga_int_input						: in std_logic;
		zetneg_oe							: out std_logic;
		dbusoe								: out std_logic;
		fpga_dir								: out std_logic;
		fpga_a								: out std_logic_vector(15 downto 0);
		fpga_d								: inout std_logic_vector(7 downto 0);
		fpga_io0								: in std_logic;
		fpga_io1								: in std_logic;
		fpga_io2								: in std_logic;
		fpga_ebl								: out std_logic;
		fpga_ior								: out std_logic;
		fpga_iow								: out std_logic;
		fpga_wrh								: out std_logic;
		fpga_rdh								: out std_logic;
		sd_clk								: out std_logic;
		sd_dataout							: inout std_logic;
		sd_datain							: in std_logic;
		sd_cs									: out std_logic;
		uart_tx_o							: out std_logic;
		uart_rx_i							: in std_logic;
		uart_rts_o							: out std_logic;
		uart_cts_i							: in std_logic
    );
    
end PaE;

-- **************************************************************

architecture koe of PaE is

-- videocontroller
component zx_main is
	port(
		mainclk								: in  std_logic;
		ym_clk_ena							: out std_logic;
		main_state_counter				: out std_logic_vector(4 downto 0);
		video_data							: in std_logic_vector(15 downto 0);
		portfe								: in std_logic_vector(3 downto 0);
		gfx_mode								: in std_logic_vector(5 downto 0);
		int_strobe							: out std_logic;
		int_delay							: in std_logic_vector(9 downto 0);
		screen_delay						: in std_logic_vector(7 downto 0);
		border_delay						: in std_logic_vector(7 downto 0);
		ssii									: out std_logic;
		ksii									: out std_logic;
		vidr									: out std_logic_vector(4 downto 0);
		vidg									: out std_logic_vector(4 downto 0);
		vidb									: out std_logic_vector(4 downto 0);
		pixelc								: out std_logic_vector(9 downto 0);
		linec									: out std_logic_vector(9 downto 0);
		pollitra_a							: out std_logic_vector(3 downto 0);
		pollitra_awr						: out std_logic_vector(3 downto 0);
		pollitra_d							: in std_logic_vector(15 downto 0);
		border3								: in std_logic;
		video_full_addr					: out std_logic_vector(20 downto 0);
		port7ffd								: in std_logic_vector(7 downto 0)
);
end component;

component pll1 is
	port(
		inclk0								: in std_logic := '0';
		c0										: out std_logic;
		c1										: out std_logic 	
			);
end component;

component T80a
port		(
		RESET_n								: in std_logic;
		CLK_n									: in std_logic;
		WAIT_n								: in std_logic;
		INT_n									: in std_logic;
		NMI_n									: in std_logic;
		BUSRQ_n								: in std_logic;
		M1_n									: out std_logic;
		MREQ_n								: out std_logic;
		IORQ_n								: out std_logic;
		RD_n									: out std_logic;
		WR_n									: out std_logic;
		RFSH_n								: out std_logic;
		HALT_n								: out std_logic;
		BUSAK_n								: out std_logic;
		A										: out std_logic_vector(15 downto 0);
		DOUT            					: out std_logic_vector(7 downto 0);
		DIN             					: in std_logic_vector(7 downto 0);
		IOcycle								: out std_logic;
		MEMcycle								: out std_logic
		);
end component;

component ym2149
	port(
	CLK										: in  std_logic;  
	CLK_ena									: in std_logic;
	RESET_L									: in std_logic;
	wr_addr									: in std_logic;
	wr_data									: in std_logic;
	rd_data									: in std_logic;
	I_DA										: in std_logic_vector(7 downto 0);
	O_DA										: out std_logic_vector(7 downto 0);
	output_a									: out std_logic_vector(7 downto 0);
	output_b									: out std_logic_vector(7 downto 0);
	output_c									: out std_logic_vector(7 downto 0)
				);
end component;

component ram_cmos
	port(
		clock									: IN  std_logic;
		data									: IN  std_logic_vector(7 DOWNTO 0);
		address								: IN  std_logic_vector(7 DOWNTO 0);
		we										: IN  std_logic;
		q										: OUT std_logic_vector(7 DOWNTO 0)
				);
end component;

component ram_pollitra is
	port(
		clock									: IN STD_LOGIC ;
		data									: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdaddress							: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		wraddress							: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		wren									: IN STD_LOGIC  := '1';
		q										: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
				);
end component;

component rom_pollitra is
	port(
		address								: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		clock									: IN STD_LOGIC ;
		q										: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
				);
end component;

component betadisk is
	port(
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
    cpu_rd         		: in std_logic;
    cpu_wr         		: in std_logic;
    cpu_a          		: in std_logic_vector(15 downto 0);
    cpu_d          		: in std_logic_vector(7 downto 0);
    mainclk         		: in std_logic;
    hardware_reset      : in std_logic;
    vg93_data_for_cpu_o : out std_logic_vector(7 downto 0);
    vg93_data_for_r    	: out std_logic_vector(7 downto 0);
	 index					: out std_logic 
				);
end component;

component uart is
    generic (
        maxbaud					: positive;
        clk_frequency			: positive;
		  fifo_size 				: positive;
		  rts_threshold			: positive
    );
    port (  
			clk						: in std_logic;
			reset						: in std_logic;    
			reg_data_in				: in std_logic_vector(7 downto 0);
			reg_data_out			: out std_logic_vector(7 downto 0);
			reg_stb_n				: in std_logic;
			reg_addr					: in std_logic_vector(2 downto 0);
			reg_wr_n					: in std_logic;
			uart_int					: out std_logic;
			tx							: out std_logic;
			rx							: in std_logic;
			cts						: in std_logic;
			rts						: out std_logic
    );
end component;

signal	mainclk							: std_logic;
signal	main_state_counter			: std_logic_vector(4 downto 0);
signal	radr								: std_logic_vector(18 downto 0);
signal 	ram_blk							: std_logic;
signal 	pollitra_data_in				: std_logic_vector (15 downto 0);
signal 	pollitra_rdaddress			: std_logic_vector (3 downto 0);
signal 	pollitra_wraddress			: std_logic_vector (3 downto 0);
signal 	pollitra_data_out				: std_logic_vector (15 downto 0);
signal 	pollitra_a						: std_logic_vector(3 downto 0);
signal 	pollitra_awr					: std_logic_vector(3 downto 0);
signal 	pollitra_ena					: std_logic;
signal	pollitra_strobe				: std_logic;
signal	old_pollitra_strobe			: std_logic;
signal	border3							: std_logic;
signal	weblk0chp0						: std_logic;
signal	oeblk0chp0						: std_logic;
signal	weblk0chp1						: std_logic;
signal	oeblk0chp1						: std_logic;
signal	weblk1chp0						: std_logic;
signal	oeblk1chp0						: std_logic;
signal	weblk1chp1						: std_logic;
signal	oeblk1chp1						: std_logic;
signal	oldm1								: std_logic:='1';
signal	oldiorq							: std_logic:='1';
signal	wr_cond							: std_logic:='1';
signal	rd_cond							: std_logic:='1';
signal	memwr1time						: std_logic:='0';
signal	memrd1time						: std_logic:='0';
signal	memwr_done						: std_logic:='0';
signal	mcu_write_ena					: std_logic;
signal	memrd_done						: std_logic:='0';
signal	buf_update1time				: std_logic:='0';
signal	romprotect						: std_logic:='0';
signal	mem_data_ena					: std_logic:='0';
signal	io_data_ena						: std_logic:='0';
signal	z80_full_adr					: std_logic_vector(20 downto 0);
signal	video_full_adr					: std_logic_vector(20 downto 0);
signal	full_adr							: std_logic_vector(20 downto 0);
signal	ram_outdata						: std_logic_vector(7 downto 0);
signal	command_from_mcu				: std_logic_vector(6 downto 0);
signal	data_from_mcu					: std_logic_vector(7 downto 0); 
signal	shifted_clock					: std_logic;
signal	ssii				            : std_logic;
signal	ksii								: std_logic;
signal	pixel_c							: std_logic_vector(9 downto 0);
signal	line_c							: std_logic_vector(9 downto 0);
signal	mcu_ram_addr					: std_logic_vector(13 downto 0);
signal	upload							: std_logic;
signal	oldupload						: std_logic;
signal	oldweblk							: std_logic;
signal	upload_in_process				: std_logic;
signal	led_on					: std_logic;
signal	led_off					: std_logic;
signal	download							: std_logic;
signal	olddownload						: std_logic;
signal	download_in_process			: std_logic;
signal	download_strobe				: std_logic;
signal	hardware_reset					: std_logic;
signal	page_number						: std_logic_vector(7 downto 0);
signal	pagenum							: std_logic;
signal	oldpagenum						: std_logic;
signal	idle								: std_logic;
signal	z80_to_ram						: std_logic;
signal	sram_data_buffer				: std_logic_vector(7 downto 0);
signal	video_data						: std_logic_vector(15 downto 0);
signal	portfe							: std_logic_vector(7 downto 0) := (others => '1');
signal	cmd02								: std_logic;
signal	keymatrix0						: std_logic_vector(7 downto 0):=b"11111111";
signal	keymatrix1						: std_logic_vector(7 downto 0):=b"11111111";
signal	keymatrix2						: std_logic_vector(7 downto 0):=b"11111111";
signal	keymatrix3						: std_logic_vector(7 downto 0):=b"11111111";
signal	keymatrix4						: std_logic_vector(7 downto 0):=b"11111111";
signal	key_byte_number				: std_logic_vector(6 downto 0);
signal	port7ffd							: std_logic_vector(7 downto 0);
signal	port7ffdadd						: std_logic_vector(7 downto 0);
signal	atmwindow						: std_logic_vector(2 downto 0);
signal	atmpage							: std_logic_vector(9 downto 0);
signal	rampage							: std_logic_vector(6 downto 0);
signal	porteff7							: std_logic_vector(7 downto 0);
signal	portxx77							: std_logic_vector(7 downto 0);
signal	portbf							: std_logic_vector(7 downto 0):=b"00000000"; --Savelij
signal	cpu3_0							: std_logic_vector(9 downto 0);
signal	cpu3_1							: std_logic_vector(9 downto 0);
signal	cpu2_0							: std_logic_vector(9 downto 0);
signal	cpu2_1							: std_logic_vector(9 downto 0);
signal	cpu1_0							: std_logic_vector(9 downto 0);
signal	cpu1_1							: std_logic_vector(9 downto 0);
signal	cpu0_0							: std_logic_vector(9 downto 0);
signal	cpu0_1							: std_logic_vector(9 downto 0);
signal	cpm								: std_logic:='1'; --Savelij
signal	pen2								: std_logic;
signal	rom								: std_logic;
signal	romram							: std_logic;
signal	dos								: std_logic:='1'; --from dosen and cp/m --Savelij
signal	fpgadir							: std_logic;
signal	z80_reset_from_arm			: std_logic;
signal	ioycle							: std_logic;
signal	klovetura						: std_logic_vector(7 downto 0);
signal	int_ack_cycle					: std_logic;
signal	int_ack_ena						: std_logic:='0';
signal	int_counter						: std_logic_vector(4 downto 0);
signal	vsync_int_flag					: std_logic := '0';
signal	m1									: std_logic;
signal	iorq_after_bus					: std_logic;
signal	read_ports						: std_logic;
signal	weblk								: std_logic;
signal	oeblk								: std_logic;
signal	int_strobe						: std_logic;
signal	i2c_scl_b						: std_logic;
signal	i2c_sda_b						: std_logic;
signal	old_scl							: std_logic;
signal	old_sda							: std_logic;
signal	i2c_outdata1time				: std_logic;
signal	i2c_bit_counter				: std_logic_vector(3 downto 0);
signal	i2c_data_buffer				: std_logic_vector(7 downto 0);
signal	i2c_command_buffer			: std_logic_vector(6 downto 0);
signal	i2c_start_condition			: std_logic;
signal	i2c_command_strobe			: std_logic;
signal	i2c_data_ena					: std_logic;
signal	i2c_data_strobe				: std_logic;
signal	old_i2c_data_strobe			: std_logic;
signal	i2c_to_m_flag					: std_logic;
signal	i2c_to_master					: std_logic := '1';
signal	i2c_to_master_shifted		: std_logic := '1';
signal	i2c_out_data					: std_logic_vector(7 downto 0);
signal	data_from_fpga					: std_logic_vector(7 downto 0);
signal	transmit_ack					: std_logic := '1';
signal	receive_ack						: std_logic := '1';
signal	i2c_out_ena						: std_logic := '1';
signal	i2c_out_data_strobe			: std_logic;
signal	i2c_command1time				: std_logic;
signal	ebl								: std_logic;
signal	ebl_iorq							: std_logic;
signal	ior								: std_logic;
signal	rdh								: std_logic; 
signal	seconds							: std_logic_vector(7 downto 0);
signal	minutes							: std_logic_vector(7 downto 0);
signal	hours								: std_logic_vector(7 downto 0);
signal	week								: std_logic_vector(7 downto 0);
signal	days								: std_logic_vector(7 downto 0);
signal	month								: std_logic_vector(7 downto 0);
signal	year								: std_logic_vector(7 downto 0);
signal	portdff7							: std_logic_vector(7 downto 0);
signal	portbff7							: std_logic_vector(7 downto 0);
signal	addr_bff7						: std_logic;
signal	addr_bff7_b						: std_logic;
signal	beeper							: std_logic;
signal	kempston							: std_logic_vector(4 downto 0);
signal	in_l								: std_logic_vector(9 downto 0);
signal	in_r								: std_logic_vector(9 downto 0);
signal	mouse_x							: std_logic_vector(7 downto 0);
signal	mouse_y							: std_logic_vector(7 downto 0);
signal	mouse_b							: std_logic_vector(7 downto 0);
--vg93
signal	vg93_ram_addr					: std_logic_vector(19 downto 0);
signal	fpga_data_transfer			: std_logic;
signal	fpga_data_counter				: std_logic_vector(5 downto 0);
signal	write_byte_number				: std_logic_vector(7 downto 0);
signal	write_sector_num				: std_logic_vector(7 downto 0);
signal	read_sector_num				: std_logic_vector(7 downto 0);
signal	read_byte_number				: std_logic_vector(7 downto 0);
signal	vg93_O_data						: std_logic_vector(7 downto 0);
signal	track_flag						: std_logic;
signal	sector_flag						: std_logic;
signal	restore_flag					: std_logic;
signal	force_interrupt_flag			: std_logic;
signal	track_position					: std_logic_vector(7 downto 0);
signal	track_reg						: std_logic_vector(7 downto 0);
signal	sector_reg						: std_logic_vector(7 downto 0);
signal	status_reg						: std_logic_vector(7 downto 0);
signal	betadisk_reg					: std_logic_vector(7 downto 0):=b"11111111";
signal	seek_flag						: std_logic;
signal	vg93_intrq						: std_logic;
signal	step_flag						: std_logic;
signal	vg93_drq							: std_logic;
signal	step_direction					: std_logic;
signal	read_addr_flag					: std_logic;
signal	read_flag						: std_logic;
signal	write_flag						: std_logic;
signal	vg93_cs							: std_logic;
signal	read_trz							: std_logic;
signal	write_trz						: std_logic;
signal	vg93_data_for_cpu				: std_logic_vector(7 downto 0);
signal	betadisk_r						: std_logic_vector(7 downto 0);
signal	vg93_transaction				: std_logic;
signal	vg93_transaction_old			: std_logic;
signal	betadisk_full_adr				: std_logic_vector(20 downto 0);
signal	mcu_full_adr					: std_logic_vector(20 downto 0);
signal	vg93_data_for_ram				: std_logic_vector(7 downto 0);
signal	vg_tormoz		            : std_logic;
signal	betadisk_flags					: std_logic_vector(11 downto 0);
signal	vg93_data_from_ram			: std_logic_vector(7 downto 0);
--cmos
signal	cmos_clk							: std_logic;
signal	cmos_data_in					: std_logic_vector(7 downto 0);
signal	cmos_addr						: std_logic_vector(7 downto 0);
signal	cmos_we							: std_logic;
signal	cmos_start						: std_logic;
signal	cmos_data_out					: std_logic_vector(7 downto 0);
signal	cmos_cpuread					: std_logic;
signal	cmos_cpuwrite					: std_logic;
signal	cmos_mode						: std_logic_vector(3 downto 0);
signal	cmos_mcu_update				: std_logic:='0';
signal	cmos_upload						: std_logic:='1';
signal	cmos_download					: std_logic :='1';
signal	cmos_upload_counter			: std_logic_vector(8 downto 0);
signal	cmos_download_counter		: std_logic_vector(8 downto 0);
signal	cmos_next						: std_logic;
signal	old_cmos_next					: std_logic;
signal	cmos_ready						: std_logic;
signal	seconds_flag					: std_logic:='0';
signal	minutes_flag					: std_logic:='0';
signal	hours_flag						: std_logic:='0';
signal	week_flag						: std_logic:='0';
signal	days_flag						: std_logic:='0';
signal	month_flag						: std_logic:='0';
signal	year_flag						: std_logic:='0';
signal	cmos_flags						: std_logic_vector(7 downto 0);
signal	cmos_download_buffer			: std_logic_vector(7 downto 0);
signal	cmos_data_buffer				: std_logic_vector(7 downto 0);
signal	fromcmos2fpga					: std_logic;
signal	fromfpga2cmos					: std_logic;
signal	fromfpga2cpu					: std_logic;
signal	fromcpu2fpga					: std_logic;
signal	iorq_onetime					: std_logic;
signal	cmos_start1						: std_logic_vector(3 downto 0);
signal	i2c_dataonetime				: std_logic;
signal	i2c_mcudataonetime			: std_logic;
-- z80 core signals:
signal	cpu_din							: std_logic_vector(7 downto 0);
signal	cpu_dout							: std_logic_vector(7 downto 0);
signal	cpu_a								: std_logic_vector(15 downto 0);
signal	cpu_int							: std_logic;
signal	cpu_nmi							: std_logic;
signal	cpu_mreq							: std_logic;
signal	cpu_iorq							: std_logic;
signal	cpu_rd							: std_logic;
signal	cpu_notrd						: std_logic;
signal	cpu_wr							: std_logic;
signal	cpu_wait							: std_logic;
signal	cpu_busrq						: std_logic;
signal	cpu_busack						: std_logic;
signal	cpu_res							: std_logic;
signal	cpu_m1							: std_logic;
signal	cpu_rfsh							: std_logic;
signal	cpu_halt							: std_logic;
signal	cpu_clk							: std_logic;
signal	iocycle							: std_logic:='0';
signal	memcycle							: std_logic:='0';
signal	cpu_speed						: std_logic_vector(2 downto 0);
signal	cpu_clk_b 						: std_logic:= '0';
signal	tormoz							: std_logic;
signal	addr_buf							: std_logic_vector(15 downto 0);
signal	vsync_int						: std_logic := '1';
signal	internal_int					: std_logic := '1';
signal	cpu_clk_old						: std_logic := '0';
signal	cpu_iowr							: std_logic;
signal	cpu_iord							: std_logic;
signal	cpu_memrd						: std_logic;
signal	cpu_memwr						: std_logic;
-- ym2149 
signal	ym_number						: std_logic;
signal	ym0_wr_data						: std_logic;
signal	ym0_rd_data						: std_logic;
signal	ym0_wr_addr						: std_logic;
signal	ym1_wr_data						: std_logic;
signal	ym1_rd_data						: std_logic;
signal	ym1_wr_addr						: std_logic;
signal	ym0_do							: std_logic_vector(7 downto 0);
signal	ym1_do							: std_logic_vector(7 downto 0);
signal	ym_do								: std_logic_vector(7 downto 0);
signal	ym0a								: std_logic_vector(7 downto 0);
signal	ym0b								: std_logic_vector(7 downto 0);
signal	ym0c								: std_logic_vector(7 downto 0);
signal	ym1a								: std_logic_vector(7 downto 0);
signal	ym1b								: std_logic_vector(7 downto 0);
signal	ym1c								: std_logic_vector(7 downto 0);
signal	snd_right						: std_logic_vector(7 downto 0);
signal	snd_left							: std_logic_vector(7 downto 0);
signal	ym0_state						: std_logic_vector(1 downto 0);
signal	ym1_state						: std_logic_vector(1 downto 0);
signal	ym_clk_ena						: std_logic;
signal	covox								: std_logic_vector(7 downto 0);
-- sd-card
signal	spi_enable						: std_logic := '1';
signal	spi_cmd							: std_logic;
signal	port57wr							: std_logic;
signal	port57rd							: std_logic;
signal	spi_wr_data						: std_logic_vector(7 downto 0);
signal	spi_rd_data						: std_logic_vector(7 downto 0);
signal	port57buffer					: std_logic_vector(7 downto 0);
signal	sd_config						: std_logic_vector(7 downto 0);
signal	sd_counter						: std_logic_vector(3 downto 0);
signal	sd_readflag						: std_logic;
signal	sd_writeflag					: std_logic;
signal	sd_active_flag					: std_logic;
signal	sd_clk_ena						: std_logic;
signal	sd_clk_b							: std_logic;
signal	vidr								: std_logic_vector(4 downto 0);
signal	vidg								: std_logic_vector(4 downto 0);
signal	vidb								: std_logic_vector(4 downto 0);
signal	gfx_mode							: std_logic_vector(5 downto 0); --atm (5..3). pent (2..0)
-- gfx_mode(2 downto 0):
-- 000: standard zx screen
-- 001: alco
-- 010..111 reserved
-- gfx_mode(5 downto 3):
-- 000: ega
-- 010: multicolor 640x200
-- 011: pentagon modes
signal	int_delay						: std_logic_vector(9 downto 0):=b"1011000000";--:=b"1010111111";--:=b"1100101111"; --b"1100101110";--:=b"1101000101";--:=b"1100111001";
signal	border_delay					: std_logic_vector(7 downto 0):= "00000000";--:=b"00101110";--:=b"00101110";--:=b"00101010";
signal 	screen_delay					: std_logic_vector(7 downto 0):= "00000000";--:=b"00101110";--:=b"00101110";--:=b"00101010";
signal	index								: std_logic;
signal	read_fe							: std_logic:='1'; 
signal	tapeout							: std_logic:='0'; 
signal	addiction						: std_logic_vector(1 downto 0):=b"00";
signal	wr_ports_single				: std_logic:='0';
signal	dos_1								: std_logic:='1';
signal	reg_data_in						: std_logic_vector(7 downto 0);
signal	reg_data_out					: std_logic_vector(7 downto 0);
signal	reg_stb_n						: std_logic := '0';
signal	reg_addr							: std_logic_vector(2 downto 0);
signal	reg_wr_n							: std_logic := '1';
signal	uart_int							: std_logic;
signal	uart_tx							: std_logic;
signal	uart_rx							: std_logic;
signal	uart_cts							: std_logic;
signal	uart_rts							: std_logic;

constant uart_maxbaud 					: positive:=115200;
constant uart_clk_frequency			: positive:=114000000;
constant uart_fifo_size					: positive:=16;
constant uart_rts_threshold			: positive:= 8;

constant key_byte_number_max			: natural:= 120;
            
begin
  
pll_config: pll1 port map (clk, mainclk, shifted_clock);
--clk_phase_shift: ram_clk_phase port map(clk, shifted_clock);

cpu: T80a port map (cpu_res, cpu_clk, cpu_wait, cpu_int, cpu_nmi,
    cpu_busrq, cpu_m1, cpu_mreq, cpu_iorq, cpu_rd, cpu_wr,
    cpu_rfsh, cpu_halt, cpu_busack, cpu_a, cpu_dout, cpu_din, iocycle, memcycle); 

cmos: ram_cmos port map (cmos_clk, cmos_data_in(7 downto 0), cmos_addr(7 downto 0), cmos_we, cmos_data_out(7 downto 0));

video_main: zx_main port map (mainclk, ym_clk_ena, main_state_counter, video_data,
    portfe(3 downto 0), gfx_mode, int_strobe, int_delay, screen_delay, border_delay, ssii, ksii,
    vidr, vidg, vidb, pixel_c, line_c, 
    pollitra_a, pollitra_awr, pollitra_data_out, border3, video_full_adr, port7ffd);

pollitra: ram_pollitra port map (mainclk, pollitra_data_in, pollitra_rdaddress,
    pollitra_wraddress, pollitra_ena, pollitra_data_out);

bdi: betadisk port map(vg93_cs, vg93_ram_addr,
		fpga_data_transfer, write_byte_number, write_sector_num,
    read_sector_num, read_byte_number, track_flag, sector_flag, restore_flag, vg93_O_data,
    force_interrupt_flag, track_position, track_reg, sector_reg, status_reg,
    betadisk_reg, vg93_intrq, seek_flag, vg93_drq, step_flag, step_direction,
    read_addr_flag, read_flag, write_flag, vg93_data_from_ram,
    vg_tormoz, read_trz, write_trz, cpu_rd, cpu_wr, cpu_a,
    cpu_dout, mainclk, hardware_reset, vg93_data_for_cpu, vg93_data_for_ram, index);
 
ym2149_0: ym2149 port map (mainclk, ym_clk_ena, cpu_res, ym0_wr_addr, ym0_wr_data, ym0_rd_data, cpu_dout(7 downto 0), ym0_do(7 downto 0), ym0a(7 downto 0), ym0b(7 downto 0), ym0c(7 downto 0));       
ym2149_1: ym2149 port map (mainclk, ym_clk_ena, cpu_res, ym1_wr_addr, ym1_wr_data, ym1_rd_data, cpu_dout(7 downto 0), ym1_do(7 downto 0), ym1a(7 downto 0), ym1b(7 downto 0), ym1c(7 downto 0));       

uart_inst: uart generic map(uart_maxbaud, uart_clk_frequency, uart_fifo_size, uart_rts_threshold) port map(mainclk, cpu_res, reg_data_in, reg_data_out,
reg_stb_n, reg_addr, reg_wr_n, uart_int, uart_tx, uart_rx, uart_cts, uart_rts);

led <= data_from_mcu(7);--int_ack_ena;--memcycle1;--(1);--(not(delitel(25)) and delitel(24) and delitel(23) and delitel(22) and delitel(19));      

-- i2c command/data transfer (slave mode)
process (mainclk, main_state_counter, i2c_sda_b, i2c_scl_b)
begin
if(mainclk'event and mainclk = '1') then
	i2c_scl_b <= i2c_scl; i2c_sda_b <= i2c_sda;
	old_scl <= i2c_scl_b; old_sda <= i2c_sda_b; 
	-- start condition: scl = 1; sda 1-> 0
	if(old_sda = '1' and i2c_sda_b = '0' and old_scl = '1' and i2c_scl_b = '1') then
		i2c_start_condition <= '0';
		i2c_command_strobe <= '0';
		i2c_data_strobe <= '0';
		i2c_data_ena <= '1';
		i2c_to_master <= '1';
		i2c_to_master_shifted <= '1';
		i2c_to_m_flag <= '1';
		transmit_ack <='1';
		receive_ack <= '1';
	end if;
	if(i2c_scl_b = '0') then i2c_start_condition <= '1'; end if;
	if(i2c_start_condition='0') then
		i2c_bit_counter(3 downto 0) <= (others => '0');
	else
		-- scl 0 -> 1
		if(old_scl = '0' and i2c_scl_b = '1') then
			if(i2c_bit_counter(3 downto 0) /= b"0111") then
				i2c_out_data_strobe <= '0';
				if(i2c_command_strobe = '0') then
					i2c_command_buffer(6 downto 1) <= i2c_command_buffer(5 downto 0);
					i2c_command_buffer(0) <= i2c_sda_b;
				end if;
			else
				i2c_out_data_strobe <= '1';
				if(i2c_to_m_flag ='1' and i2c_sda_b = '1') then i2c_to_master <= '0'; end if;
			end if;
			if(i2c_bit_counter(3 downto 0) = b"0110") then i2c_command_strobe <= '1'; end if;
			if(i2c_bit_counter(3 downto 0) /= b"1000") then
				i2c_bit_counter(3 downto 0) <= i2c_bit_counter(3 downto 0)+'1';
				i2c_data_buffer(7 downto 1) <= i2c_data_buffer(6 downto 0);
				i2c_data_buffer(0) <= i2c_sda_b; 
			else
				i2c_bit_counter(3 downto 0) <= (others => '0');
				i2c_data_ena <= '0';
				if(i2c_sda_b = '1' and i2c_out_ena = '0') then
					-- mcu returned nack;
					i2c_to_master <= '1'; i2c_to_master_shifted <= '1'; i2c_out_ena <= '1';
				else
					i2c_to_master_shifted <= i2c_to_master;
				end if;
				if(i2c_to_m_flag = '1') then i2c_to_m_flag <= '0'; end if;
			end if;
		end if;
		-- scl 1 -> 0
		if(old_scl = '1' and i2c_scl_b = '0') then
			if(i2c_bit_counter = b"1000") then    
				if(i2c_data_ena = '0') then
					data_from_mcu(7 downto 0) <= i2c_data_buffer(7 downto 0);
					i2c_data_strobe <= '1';
				end if;
				i2c_out_data(7 downto 0) <= data_from_fpga(7 downto 0);
				if(i2c_to_master_shifted = '1') then
					transmit_ack <= '0';
				else
					receive_ack <= '0';
				end if;
			else
				i2c_data_strobe <= '0';
				transmit_ack <= '1';
				receive_ack <= '1';
				i2c_out_ena <= i2c_to_master_shifted;
			end if;
			if ((i2c_bit_counter /= b"0000") and (i2c_bit_counter /= b"1000")) then
				i2c_out_data(7 downto 1) <= i2c_out_data(6 downto 0);
			end if;
		end if;
	end if;
end if;
end process;

i2c_sda <= '0' when (transmit_ack = '0')
else i2c_out_data(7) when (i2c_out_ena = '0' and receive_ack /= '0')
else 'Z';

cmos_flags(7 downto 0) <= (year_flag & month_flag & days_flag & week_flag & hours_flag & minutes_flag & seconds_flag & cmos_mcu_update);
betadisk_flags(11 downto 0) <= (track_flag & force_interrupt_flag & vg93_intrq & vg93_drq & restore_flag & seek_flag & step_flag & step_direction & read_addr_flag & read_flag & write_flag & sector_flag);

process(mainclk, old_scl, i2c_scl_b, i2c_command_buffer, i2c_bit_counter, cmos_flags, fpga_data_transfer, 
			betadisk_reg, status_reg, sector_reg, track_reg, track_position, vg93_O_data, betadisk_flags,
			read_byte_number, read_sector_num, write_byte_number, write_sector_num, cpu_a, 
			cmos_download_counter, fpga_data_counter, cmos_data_out, cmos_ready, sram_data_buffer)
begin
if(mainclk'event and mainclk = '1') then
	if(old_scl = '1' and i2c_scl_b = '0') then
		if(i2c_bit_counter = b"0111") then
			if(download_in_process = '0') then data_from_fpga(7 downto 0) <= sram_data_buffer(7 downto 0); end if;
			if(i2c_command_buffer = 9) then data_from_fpga(7 downto 0) <= cmos_flags(7 downto 0); end if;
			if(fpga_data_transfer = '0') then
				case fpga_data_counter(5 downto 0) is
					when b"000000" => data_from_fpga(7 downto 0) <= betadisk_reg(7 downto 0);
					when b"000001" => data_from_fpga(7 downto 0) <= status_reg(7 downto 0);
					when b"000010" => data_from_fpga(7 downto 0) <= sector_reg(7 downto 0); 
					when b"000011" => data_from_fpga(7 downto 0) <= track_reg(7 downto 0);
					when b"000100" => data_from_fpga(7 downto 0) <= track_position(7 downto 0);
					when b"000101" => data_from_fpga(7 downto 0) <= vg93_O_data(7 downto 0);
					when b"000110" => data_from_fpga(7 downto 0) <= betadisk_flags(7 downto 0);
					when b"000111" => data_from_fpga(7 downto 0) <= (betadisk_flags(11 downto 8) & "0000");
					when b"001000" => data_from_fpga(7 downto 0) <= read_byte_number(7 downto 0);
					when b"001001" => data_from_fpga(7 downto 0) <= read_sector_num(7 downto 0);
					when b"001010" => data_from_fpga(7 downto 0) <= write_byte_number(7 downto 0);
					when b"001011" => data_from_fpga(7 downto 0) <= write_sector_num(7 downto 0);
					when b"001100" => data_from_fpga(7 downto 0) <= cpu_a(15 downto 8);
					when b"001101" => data_from_fpga(7 downto 0) <= cpu_a(7 downto 0);
					when b"001111" => data_from_fpga(7 downto 0) <= cmos_download_counter(5 downto 0) & '0' & cmos_ready;
					when b"010000" => data_from_fpga(7 downto 0) <= cmos_download_buffer(7 downto 0);
					when others => null;
				end case;
			end if;
		end if;	
	end if;
end if;
end process;

-- передача в контроллер массива оперативных данных
process (mainclk, i2c_out_data_strobe, hardware_reset, fpga_data_transfer)
begin
if(mainclk'event and mainclk = '1') then
	if(hardware_reset = '0' or fpga_data_transfer = '1') then
		fpga_data_counter(5 downto 0) <= (others =>'0');
	else
		i2c_outdata1time <= i2c_out_data_strobe;
		if(i2c_outdata1time = '0' and i2c_out_data_strobe = '1') then
			if((fpga_data_transfer = '0') and (fpga_data_counter(5 downto 0) /= b"100000")) then
				fpga_data_counter(5 downto 0) <= fpga_data_counter(5 downto 0) + '1';
			end if;
		end if;
	end if;
end if;
end process;

process(mainclk, i2c_command_strobe, i2c_command_buffer, data_from_mcu)
begin
if(mainclk'event and mainclk = '1') then
	if(i2c_command_strobe = '0') then
		i2c_command1time <= '0';
	else
		i2c_command1time <= '1';
		if(i2c_command1time = '0') then
			command_from_mcu(6 downto 0) <= i2c_command_buffer(6 downto 0);
			if(i2c_command_buffer = 0) then idle <= '0'; fpga_data_transfer <= '1'; else idle <= '1'; end if;
			if(i2c_command_buffer = 1) then hardware_reset <= '0'; page_number <= (others => '1'); z80_to_ram <= '1'; z80_reset_from_arm <= '0'; else hardware_reset <= '1'; end if;
			if(i2c_command_buffer = 2) then cmd02 <= '0'; else cmd02 <= '1'; end if;   
			if(i2c_command_buffer = 3) then upload <= '1'; else upload <= '0'; end if;
			if(i2c_command_buffer = 4) then download <= '1'; else download <= '0'; end if;
			if(i2c_command_buffer = 5) then z80_reset_from_arm <= '1'; end if;
			if(i2c_command_buffer = 6) then page_number(7 downto 0) <= data_from_mcu(7 downto 0 ); end if;
			if(i2c_command_buffer = 7) then z80_to_ram <='0'; end if;
			if(i2c_command_buffer = 8) then spi_cmd <= '0'; else spi_cmd <= '1'; end if;   
			if(i2c_command_buffer = 13) then if(border_delay(7 downto 0) < 80) then border_delay(7 downto 0)<= border_delay(7 downto 0)+'1'; end if; end if;
			if(i2c_command_buffer = 14) then if(border_delay(7 downto 0) > 0) then border_delay(7 downto 0)<= border_delay(7 downto 0)-'1'; end if; end if;
			if(i2c_command_buffer = 15) then if(int_delay(9 downto 0) < 1023) then int_delay(9 downto 0)<= int_delay(9 downto 0)+b"0000000001"; end if; end if; --890
			if(i2c_command_buffer = 16) then if(int_delay(9 downto 0) > 100) then int_delay(9 downto 0)<= int_delay(9 downto 0)-b"0000000001"; end if; end if; --800
			if(i2c_command_buffer = 17) then fpga_data_transfer <= '0'; end if;
			if(i2c_command_buffer = 29) then led_on <= '0'; else led_on <= '1'; end if;
			if(i2c_command_buffer = 30) then led_off <= '0'; else led_off <= '1'; end if;
			if(i2c_command_buffer = 31) then cmos_next <= '1'; else cmos_next <= '0'; end if;
		end if;
	end if;
end if;
end process;

--  ram upload/download !!download not tested
process(mainclk, i2c_data_strobe, i2c_outdata1time, i2c_out_data_strobe)
begin
if(mainclk'event and mainclk = '1') then
	old_i2c_data_strobe <= i2c_data_strobe;
	oldupload <= upload;
	oldweblk <= weblk;
	olddownload <= download;
	if(hardware_reset = '0') then
		download_in_process <= '1';
		upload_in_process <= '1';
		mcu_write_ena <= '1';
	end if;
	if(i2c_start_condition = '0') then
		mcu_ram_addr(13 downto 0) <= (others => '1');
	elsif((old_i2c_data_strobe = '0' and i2c_data_strobe = '1') ) then
		--or (i2c_outdata1time = '0' and i2c_out_data_strobe = '1')
		mcu_ram_addr(13 downto 0) <= mcu_ram_addr(13 downto 0) + '1';
		if(upload_in_process = '0') then mcu_write_ena <= '0'; end if;
	end if;
	if(oldweblk = '0' and weblk = '1') then mcu_write_ena <= '1'; end if;
	if(oldupload = '0' and upload = '1') then	upload_in_process <= '0'; end if;
	if(olddownload = '0' and download = '1') then download_in_process <= '0'; end if;
	if(mcu_ram_addr(13 downto 0) = b"11111111111111") then
		if(oeblk = '0') then download_in_process <= '1'; end if;
		if(weblk = '0') then upload_in_process <= '1'; end if;
	end if;
end if;
end process;

weblk <= weblk0chp0 and weblk0chp1 and weblk1chp0 and weblk1chp1;
oeblk <= oeblk0chp0 and oeblk0chp1 and oeblk1chp0 and oeblk1chp1;

-- cmos
addr_bff7 <= '0' when (cpu_a = x"bff7") else '1';
cmos_mode(3 downto 0) <= cmos_upload & cmos_download & cmos_cpuread & cmos_cpuwrite;  
cmos_start1(3 downto 0) <= fromcmos2fpga & fromfpga2cmos & fromfpga2cpu & fromcpu2fpga;
process(mainclk, hardware_reset, cmos_mode, fpga_data_counter, cmos_data_buffer)
begin
if(hardware_reset = '0') then
	cmos_upload <= '1';
	cmos_download <= '1';
	cmos_download_counter(5 downto 0) <= b"111111";
	cmos_ready <= '0';
	cmos_we <= '1';
	cmos_start <= '0';
	cmos_clk <= '0';
	fromcmos2fpga <= '0';
	fromfpga2cmos <= '0';
	fromfpga2cpu <= '0';
	fromcpu2fpga <= '0';
	cmos_mcu_update <= '0';
	seconds_flag <= '0';
	minutes_flag <= '0';
	hours_flag <= '0';
	week_flag <= '0';
	days_flag <= '0';
	month_flag <= '0';
	year_flag <= '0';
	cmos_cpuread <= '1';
	cmos_cpuwrite <= '1';
	elsif(mainclk'event and mainclk = '1') then
		if(fromcmos2fpga = '1') then cmos_upload <= '1'; end if;
		if(i2c_data_strobe = '0') then i2c_dataonetime <= '0'; end if;
		if(i2c_dataonetime = '0' and i2c_data_strobe = '1') then			
			i2c_dataonetime <= '1';
			if(i2c_command_buffer /= 11) then
				cmos_upload_counter(8 downto 0) <= b"111111111";
			else
				if(cmos_upload_counter(8 downto 0) /= b"000111111") then
					cmos_upload_counter(8 downto 0) <= cmos_upload_counter(8 downto 0) + '1';
					cmos_upload <= '0';
				end if;
			end if;
		end if;
		old_cmos_next <= cmos_next; 
		if(old_cmos_next = '0' and cmos_next = '1') then			
			cmos_download_counter(5 downto 0) <= cmos_download_counter(5 downto 0) + '1';
			cmos_ready <= '0';
		end if;
		if(fromfpga2cmos = '1') then
			cmos_download <= '1';
			elsif(oldm1 = '1' and cpu_m1 = '0' and iorq_after_bus = '1' and cpu_mreq = '1' and cmos_ready = '0') then
				cmos_download <= '0';
		end if;
		if(cmos_clk = '1') then	cmos_ready <= '1'; end if;
		if(fromfpga2cpu = '1' or fromcpu2fpga = '1') then
			cmos_cpuread <= '1';
			cmos_cpuwrite <= '1';
		end if;
		iorq_onetime <= iorq_after_bus;
		if(iorq_onetime = '1' and cpu_iord = '0' and ebl='1' and addr_bff7 = '0' and porteff7(7) = '1') then
			cmos_cpuread <= '0';
		end if;
		if(iorq_onetime = '1' and cpu_iowr = '0' and ebl = '1' and addr_bff7 = '0' and porteff7(7) = '1') then
			cmos_cpuwrite <= '0'; portbff7(7 downto 0) <= cpu_dout(7 downto 0);
		end if;
		if(cmos_start1 = b"0000") then
			case cmos_mode(3 downto 0) is
				when b"0111" => 
					cmos_addr(7 downto 0) <= b"00" & cmos_upload_counter(5 downto 0);
					cmos_we <= '0'; 
					cmos_data_in(7 downto 0) <= data_from_mcu(7 downto 0);--cmos_data_buffer(7 downto 0);              
					cmos_start <= '1';
					fromcmos2fpga <= '1';
				when b"1011" => 
					cmos_addr(7 downto 0) <= b"00" & cmos_download_counter(5 downto 0);               
					cmos_start <= '1';  
					fromfpga2cmos <= '1';							
				when b"1101" =>                            
					cmos_addr(7 downto 0) <= portdff7(7 downto 0);
					cmos_start <= '1';
					fromfpga2cpu <= '1';
				when b"1110" => 
					cmos_addr(7 downto 0) <= portdff7(7 downto 0);
					cmos_we <= '0';
					cmos_data_in(7 downto 0) <= portbff7(7 downto 0);
					cmos_start <= '1';
					fromcpu2fpga <= '1';
				when b"1111" => null;
				when others => 
					fromfpga2cpu <= '1';
					fromfpga2cmos <= '1';
					fromcmos2fpga <= '1';
					cmos_start <= '1';
					cmos_we <= '1';
			end case;
		end if;
		if(cmos_start = '1') then cmos_start <= '0'; cmos_clk <= '1';
		else cmos_clk <= '0'; 
		end if;
		if(cmos_clk = '1') then
			cmos_we <= '1';
			if(fromfpga2cpu = '1') then fromfpga2cpu <= '0'; end if;
			if(fromfpga2cmos = '1') then fromfpga2cmos <= '0'; cmos_download_buffer(7 downto 0) <= cmos_data_out(7 downto 0); end if; 
			if(fromcmos2fpga = '1') then fromcmos2fpga <= '0'; end if;
			if(fromcpu2fpga = '1') then fromcpu2fpga <= '0'; end if;
		end if;
		if(iorq_onetime = '1' and cpu_iowr = '0' and ebl='1') then
			if(addr_bff7='0' and porteff7(7) = '1') then cmos_mcu_update <= '1'; end if;
		end if;
		if(command_from_mcu = 10) then
			cmos_mcu_update <= '0'; 
			seconds_flag <= '0';
			minutes_flag <= '0';
			hours_flag <= '0';
			week_flag <= '0';
			days_flag <= '0';
			month_flag <= '0';
			year_flag <= '0';
		end if;
		if(cmos_cpuwrite = '0') then
			if(portdff7(7 downto 4) = b"0000") then
				case portdff7(3 downto 0) is
					when b"0000" => seconds_flag <= '1';
					when b"0010" => minutes_flag <= '1';
					when b"0100" => hours_flag <= '1';
					when b"0110" => week_flag <= '1';
					when b"0111" => days_flag <= '1';
					when b"1000" => month_flag <= '1';
					when b"1001" => year_flag <= '1';
					when others => null;
				end case;
			end if;     
		end if;
end if;
end process;

-- spi sd-card
process(mainclk, spi_cmd, cpu_a, ebl, dos, iorq_after_bus, cpu_wr, cpu_m1, port57buffer, main_state_counter)
begin
if(mainclk'event and mainclk = '1') then
	if(spi_cmd = '1') then spi_enable <= '0'; end if;
	if(cpu_a(7 downto 0) = x"57" and ebl = '1' and iorq_after_bus = '0' and cpu_wr = '1' and cpu_m1 = '1') then
		port57rd <= '0';
	else port57rd <= '1';
	end if;
	if(((dos = '1' and cpu_a(7 downto 0) = x"57") or (dos = '0' and cpu_a(7 downto 0) = x"57" and cpu_a(15) = '0'))
	and ebl = '1'
	and iorq_after_bus = '0' and cpu_wr = '0' and cpu_m1 = '1') then
		port57wr <= '0';
	else
		port57wr <= '1';
	end if;
	if(port57wr = '0') then
		spi_wr_data(7 downto 0) <= port57buffer(7 downto 0);
		sd_counter(3 downto 0) <= (others => '0');
		sd_writeflag <= '1'; sd_clk_ena <= '1'; sd_clk_b <= '0'; 
	elsif(port57rd = '0') then
		spi_wr_data(7 downto 0) <= (others => '1'); 
		sd_counter(3 downto 0) <= (others => '0');
		sd_readflag <= '1'; sd_clk_ena <= '1'; sd_clk_b <= '0';
	elsif((sd_writeflag or sd_readflag) = '1') then
		if(main_state_counter(2 downto 0) = b"011") then
			-- sd_clock _|-
			if(sd_counter(3 downto 0) /= b"1000") then
				sd_counter(3 downto 0) <= sd_counter(3 downto 0) + '1';
				spi_rd_data(7 downto 1) <= spi_rd_data(6 downto 0);
				spi_rd_data(0) <= sd_datain;
				if(sd_clk_ena = '1') then 
					sd_clk_b <= '1';
				else
					sd_clk_b <= '0';
				end if;
			end if;
		end if;
		if(main_state_counter(2 downto 0) = b"111") then
			-- sd_clock -|_
			if(sd_counter(3 downto 0) /= b"0000" and sd_counter(3 downto 0) /= b"1000") then
				spi_wr_data(7 downto 1) <= spi_wr_data(6 downto 0);
			end if;
			if(sd_counter(3 downto 0) = b"1000") then
				sd_writeflag <= '0';
				sd_readflag <= '0';
				sd_clk_ena <= '0';
			end if;
			sd_clk_b <= '0';
		end if;
	end if;
end if;
end process;

sd_clk <= sd_clk_b when (spi_enable = '0') else 'Z';
sd_dataout <= spi_wr_data(7) when (spi_enable = '0') else 'Z';
sd_cs <= sd_config(1) when (spi_enable = '0') else 'Z';
sd_active_flag <= sd_writeflag or sd_readflag;

-- ext_ram memory mapper
romram <= porteff7(3);
atmwindow(2 downto 0) <= port7ffd(4) & cpu_a(15 downto 14);
atmpage(9 downto 0) <= cpu3_0 when (atmwindow(2 downto 0) = b"011")
    else cpu3_1 when (atmwindow(2 downto 0) = b"111")
    else cpu2_0 when (atmwindow(2 downto 0) = b"010")
    else cpu2_1 when (atmwindow(2 downto 0) = b"110")
    else cpu1_0 when (atmwindow(2 downto 0) = b"001")
    else cpu1_1 when (atmwindow(2 downto 0) = b"101")
    else cpu0_0 when (atmwindow(2 downto 0) = b"000")
    else cpu0_1 when (atmwindow(2 downto 0) = b"100");
rampage(6 downto 0) <= not(atmpage(8) & atmpage(5 downto 0)) when (atmpage(7) = '0' and atmpage(6) = '1') --atm ram
    else b"10010" & atmpage(0) & atmpage(1) when (atmpage(7) = '0' and atmpage(6) = '0') --atm rom
    else port7ffdadd(0) & port7ffd(5) & port7ffd(7 downto 6) & port7ffd(2 downto 0) when (atmpage(7) = '1' and cpu_a(15 downto 14) = b"11")
    else b"0000010" when (atmpage(7) = '1' and cpu_a(15 downto 14) = b"10")
    else b"0000101" when (atmpage(7) = '1' and cpu_a(15 downto 14) = b"01")
    else b"10010" & dos & fpga_rs_in when (atmpage(7) = '1' and cpu_a(15 downto 14) = b"00" and romram ='0')
	 else b"0000000" when (atmpage(7) = '1' and cpu_a(15 downto 14) = b"00" and romram ='1');

z80_full_adr(20 downto 0) <= rampage(6 downto 0) & cpu_a(13 downto 0);	 
betadisk_full_adr(20 downto 0) <= '1' & vg93_ram_addr(19 downto 0);
mcu_full_adr(20 downto 0) <= page_number(6 downto 0) & mcu_ram_addr(13 downto 0);
full_adr(20 downto 0) <= z80_full_adr(20 downto 0) when (z80_to_ram ='0' and vg93_transaction = '1')
    else betadisk_full_adr(20 downto 0) when (z80_to_ram ='0' and vg93_transaction = '0')
    else mcu_full_adr(20 downto 0) when (z80_to_ram ='1');
ram_outdata(7 downto 0) <= cpu_dout(7 downto 0) when (z80_to_ram ='0' and vg93_transaction = '1')
    else vg93_data_for_ram(7 downto 0) when (z80_to_ram ='0' and vg93_transaction = '0')
    else data_from_mcu(7 downto 0) when (z80_to_ram ='1');

cpu_memwr <= cpu_mreq or cpu_wr;
cpu_memrd <= cpu_mreq or cpu_rd;
cpu_iowr <= iorq_after_bus or cpu_wr;
cpu_iord <= iorq_after_bus or cpu_rd;
	 
wr_cond <= (not(z80_to_ram) or mcu_write_ena) and (z80_to_ram or ((vg93_transaction or write_flag or not(vg_tormoz)) and (cpu_mreq or not(cpu_rd) or not(cpu_rfsh) or romprotect)));
romprotect <= '1' when ((rampage(6 downto 2)=b"10010") or (rampage(6 downto 0)=b"1001100"))
else '0';
rd_cond <= (not(z80_to_ram) or download_in_process) and (z80_to_ram or ((cpu_m1 or not(cpu_iorq)) and cpu_memrd and (vg93_transaction or read_flag or not(vg_tormoz))));

process(mainclk, main_state_counter, wr_cond, memwr1time)
begin
if(mainclk'event and mainclk = '1') then
	-- video
	if(main_state_counter(1 downto 0) = b"11") then
		weblk0chp0 <= '1';
		weblk0chp1 <= '1';
		weblk1chp0 <= '1';
		weblk1chp1 <= '1';
		memwr_done <= memwr1time;
		memrd_done <= memrd1time;
		radr(18 downto 0) <= video_full_adr(18 downto 0); 
		blk0_d(7 downto 0) <= (others => 'Z');
		blk1_d(7 downto 0) <= (others => 'Z');
		case video_full_adr(20 downto 19) is
			when b"00" => oeblk0chp0 <= '0'; oeblk0chp1 <= '1'; oeblk1chp0 <= '1'; oeblk1chp1 <= '1'; 
			when b"01" => oeblk0chp0 <= '1'; oeblk0chp1 <= '0'; oeblk1chp0 <= '1'; oeblk1chp1 <= '1'; 
			when b"10" => oeblk0chp0 <= '1'; oeblk0chp1 <= '1'; oeblk1chp0 <= '0'; oeblk1chp1 <= '1'; 
			when b"11" => oeblk0chp0 <= '1'; oeblk0chp1 <= '1'; oeblk1chp0 <= '1'; oeblk1chp1 <= '0'; 
			when others => null;
		end case;
	end if;
	-- data
	if(wr_cond = '1') then memwr1time <= '0'; memwr_done <= '0'; end if;
	if(rd_cond = '1') then memrd1time <= '0'; memrd_done <= '0'; end if;
	if(main_state_counter(1 downto 0) = b"01") then 
		radr(18 downto 0) <= full_adr(18 downto 0); 
		if(wr_cond = '0' and memwr1time = '0') then -- wr
			memwr1time <= '1';
			oeblk0chp0 <= '1';
			oeblk0chp1 <= '1';
			oeblk1chp0 <= '1';
			oeblk1chp1 <= '1';
			--if(full_adr(20) = '0') then
				blk0_d(7 downto 0) <= ram_outdata(7 downto 0);
			--else
				blk1_d(7 downto 0) <= ram_outdata(7 downto 0);
			--end if;         
			case full_adr(20 downto 19) is
				when b"00" => weblk0chp0 <= '0';
				when b"01" => weblk0chp1 <= '0';
				when b"10" => weblk1chp0 <= '0';
				when b"11" => weblk1chp1 <= '0';
				when others => null;
			end case;
		end if;
		-- rd
		if(rd_cond = '0' and memrd1time = '0') then
			memrd1time <= '1';
			case full_adr(20 downto 19) is
				when b"00" => oeblk0chp0 <= '0'; oeblk0chp1 <= '1'; oeblk1chp0 <= '1'; oeblk1chp1 <= '1'; ram_blk <= '0';
				when b"01" => oeblk0chp0 <= '1'; oeblk0chp1 <= '0'; oeblk1chp0 <= '1'; oeblk1chp1 <= '1'; ram_blk <= '0';
				when b"10" => oeblk0chp0 <= '1'; oeblk0chp1 <= '1'; oeblk1chp0 <= '0'; oeblk1chp1 <= '1'; ram_blk <= '1';
				when b"11" => oeblk0chp0 <= '1'; oeblk0chp1 <= '1'; oeblk1chp0 <= '1'; oeblk1chp1 <= '0'; ram_blk <= '1';
				when others => null;
			end case;
		else 
			oeblk0chp0 <= '1';
			oeblk0chp1 <= '1';
			oeblk1chp0 <= '1';
			oeblk1chp1 <= '1';
		end if;
	end if;
end if;
end process;

process(mainclk, main_state_counter, vg93_transaction, read_flag, ram_blk, buf_update1time, rd_cond, memrd1time)
begin
if(mainclk'event and mainclk = '1') then
	if(main_state_counter(1 downto 0) = b"01") then
		video_data(15 downto 0) <= blk1_d(7 downto 0) & blk0_d(7 downto 0);
	end if;
end if;

if(mainclk'event and mainclk = '1') then
    vg93_transaction_old <= vg93_transaction;
    if(rd_cond = '1') then buf_update1time <= '0'; end if;
    if(main_state_counter(1 downto 0) = b"11") then
        if(memrd1time = '1' and buf_update1time = '0') then
            buf_update1time <= '1';
            case ram_blk is
                when '0' => sram_data_buffer(7 downto 0) <= blk0_d(7 downto 0);
                when '1' => sram_data_buffer(7 downto 0) <= blk1_d(7 downto 0);
                when others => null;
            end case;
        end if;
    end if;
    if(vg93_transaction_old = '0') then
        vg93_data_from_ram(7 downto 0) <= sram_data_buffer(7 downto 0);
    end if;
end if;
end process;

process (mainclk, i2c_data_strobe, cmd02, old_i2c_data_strobe)
begin
if(cmd02 = '1') then key_byte_number <= (others => '0');
elsif(mainclk'event and mainclk = '1') then
	--old_i2c_data_strobe <= i2c_data_strobe;
	if(old_i2c_data_strobe = '0' and i2c_data_strobe = '1') then
		if(key_byte_number < key_byte_number_max) then
			key_byte_number <= key_byte_number + '1';
			if(key_byte_number < 55) then
				case key_byte_number(5 downto 0) is
					when b"000000" => keymatrix0(7 downto 0) <= i2c_data_buffer(7 downto 0);
					when b"000001" => keymatrix1(7 downto 0) <= i2c_data_buffer(7 downto 0); 
					when b"000010" => keymatrix2(7 downto 0) <= i2c_data_buffer(7 downto 0); 
					when b"000011" => keymatrix3(7 downto 0) <= i2c_data_buffer(7 downto 0); 
					when b"000100" => keymatrix4(7 downto 0) <= i2c_data_buffer(7 downto 0);
					when b"000101" => seconds(7 downto 0) <= i2c_data_buffer(7 downto 0); 
					when b"000110" => minutes(7 downto 0) <= i2c_data_buffer(7 downto 0); 
					when b"000111" => hours(7 downto 0) <= i2c_data_buffer(7 downto 0); 
					when b"001000" => week(7 downto 0) <= i2c_data_buffer(7 downto 0); 
					when b"001001" => days(7 downto 0) <= i2c_data_buffer(7 downto 0); 
					when b"001010" => month(7 downto 0) <= i2c_data_buffer(7 downto 0); 
					when b"001011" => year(7 downto 0) <= i2c_data_buffer(7 downto 0); 
					when b"001100" => mouse_b(7 downto 0) <= i2c_data_buffer(7 downto 0); 
					when b"001101" => mouse_x(7 downto 0) <= i2c_data_buffer(7 downto 0);
					when b"001110" => mouse_y(7 downto 0) <= i2c_data_buffer(7 downto 0);
					when b"001111" => kempston(4 downto 0) <= i2c_data_buffer(4 downto 0);
					when b"010000" => in_l(7 downto 0) <= i2c_data_buffer(7 downto 0);
					when b"010001" => in_l(9 downto 8) <= i2c_data_buffer(1 downto 0); 
					when b"010010" => in_r(7 downto 0) <= i2c_data_buffer(7 downto 0); 
					when b"010011" => in_r(9 downto 8) <= i2c_data_buffer(1 downto 0);
					when others => null;
				end case;
			end if;
		end if;
	end if;
end if;
end process;

vid_r(4 downto 0) <= vidr(4 downto 0);
vid_g(4 downto 0) <= vidg(4 downto 0);
vid_b(4 downto 0) <= vidb(4 downto 0);   

rom <= cpu_a(14) or cpu_a(15);    -- 0 => ROM, 1 => RAM

-- dos trigger (4 rom switching)
process(mainclk, cpu_res, m1, cpu_a, port7ffd, cpm, portbf)
begin
if(cpu_res = '0') then dos <= '0';
	elsif(mainclk'event and mainclk = '1') then
		oldm1 <= cpu_m1;
		oldiorq <= cpu_iorq;
		if(oldm1 = '1' and cpu_m1 = '0' and cpu_iorq = '1') then
			if(cpu_a(8)='1' and cpu_a(9)='0' and cpu_a(13 downto 10) = b"1111" and cpu_a(15 downto 14)=b"00" and port7ffd(4)='1')
				then dos <= '0';
			end if;
			if(not(cpu_a(15 downto 14)=b"00")) then
				dos <= dos_1;
			end if;
		end if;
		if(oldiorq = '0' and cpu_iorq = '1' and oldm1 = '1') then
			dos_1 <= cpm and (not(portbf(0))); --Savelij
		end if;
end if;
end process;

-- ports WR
process(mainclk, cpu_res, iorq_after_bus, cpu_iowr, cpu_m1, ebl, cpu_a, porteff7, port7ffd, addr_bff7, portdff7, dos)
begin
if(cpu_res = '0') then
	port7ffd(7 downto 0) <= (others => '0');
	porteff7(7 downto 0) <= (others => '0');
	portdff7(7 downto 0) <= (others => '0');
	port7ffdadd(7 downto 0) <= (others => '0');
	--ATM
	portxx77(7 downto 0) <= b"10101011";
	portbf(0) <= '0'; --Savelij
	cpm <= '0';
	pen2 <= '1'; --access to the palette in dos(0)
	cpu3_0 <= b"1111111111"; --7ffd on
	cpu3_1 <= b"1111111111"; --7ffd on
	cpu2_0 <= b"1111111111"; --7ffd on
	cpu2_1 <= b"1111111111"; --7ffd on
	cpu1_0 <= b"1111111111"; --7ffd on
	cpu1_1 <= b"1111111111"; --7ffd on
	cpu0_0 <= b"1110111111"; --7ffd on
	cpu0_1 <= b"1110111111"; --7ffd on
	covox(7 downto 0) <= (others => '0');
	ym_number <= '0'; ym0_wr_addr<='1'; ym0_wr_data<='1'; ym1_wr_addr<='1'; ym1_wr_data<='1';
	wr_ports_single <= '0';
	elsif(iorq_after_bus = '1') then
		pollitra_strobe <= '0'; vg93_cs<='1'; wr_ports_single <= '0';
		ym0_wr_addr<='1'; ym0_wr_data<='1'; ym1_wr_addr<='1'; ym1_wr_data<='1';
		reg_stb_n <= '1';
		reg_wr_n <= '1';
		elsif(mainclk'event and mainclk = '1') then
			if(cpu_a(15 downto 11) = b"11111" and cpu_a(7 downto 0) = b"11101111") then
				reg_data_in(7 downto 0) <= cpu_dout(7 downto 0);
				reg_stb_n <= iorq_after_bus;
				reg_wr_n <= cpu_iowr;
				reg_addr(2 downto 0) <=	cpu_a(10 downto 8);
			end if;
			if(cpu_iowr='0' and ebl='1' and wr_ports_single = '0') then
				wr_ports_single <= '1';
				-- port fe:
				if(cpu_a(0)='0' and (porteff7(2) = '0' or (porteff7(2) = '1' and cpu_dout(7 downto 0) /= b"00100000"))) then portfe(7 downto 0) <= cpu_dout(7 downto 0); border3 <= not(cpu_a(3)); end if;
				-- port 7ffd (system control 0):
				if(cpu_a(15)='0' and cpu_a(1)='0') then
					if(porteff7(2)='0' or (porteff7(2)='1' and dos = '0')) then
					-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ в досе все равно 1 ћб пам€ти, несмотр€ на ефф7        
						 port7ffd(7 downto 0) <= cpu_dout(7 downto 0);
					else
						if(port7ffd(5)= '0') then port7ffd(5 downto 0) <= cpu_dout(5 downto 0); end if;
						-- ^^^^^^^^^^^^^^^^^^^^^ здесь надо бы посоображать на предмет соответстви€ идеологии,
						-- режим 48к будет действительно 48к, только если установлен бит 2 ефф7 и не включено трдос  
					end if; 
				end if;
				-- port eff7 (system control 1):
				if(cpu_a(3)='0' and cpu_a(5)='1' and cpu_a(12)='0' and cpu_a(15 downto 13) = b"111" and cpu_a(0)='1') then
					porteff7(7 downto 0) <= cpu_dout(7 downto 0);
				end if;
				if(cpu_a(15 downto 0) = x"DFF7" and porteff7(7) = '1') then
					portdff7(7 downto 0) <= cpu_dout(7 downto 0);
				end if;
				-- covox
				if(cpu_a(7 downto 0) = x"FB") then covox(7 downto 0) <= cpu_dout(7 downto 0); end if;
				-- sd-card SPI interface (for Savelij):
				if(((cpu_a(7 downto 0) = x"57") and (dos = '1')) or ((cpu_a(7 downto 0) = x"57") and (dos = '0') and (cpu_a(15) = '0'))) then
					port57buffer(7 downto 0) <= cpu_dout(7 downto 0); 
				end if;
            if(((cpu_a(7 downto 0) = x"77") and (dos = '1')) or ((cpu_a(7 downto 0) = x"57") and (dos = '0') and (cpu_a(15) = '1'))) then
					sd_config(7 downto 0) <= cpu_dout(7 downto 0);
				end if;
            -- port xxFF
            if((cpu_a(7 downto 0) = x"ff") and ((dos = '1') or (pen2 = '0')) and porteff7(2)='0') then
					pollitra_strobe <= '1';
				end if;
            -- ATM
				if((cpu_a(7 downto 0) = x"77") and (dos = '0')) then
					portxx77(7 downto 0) <= cpu_dout(7 downto 0);
					cpm <= cpu_a(9);
					pen2 <= cpu_a(14);
				end if;
				-- Sovelei
				if(cpu_a(7 downto 0) = x"bf") then
					--cpm <= not(cpu_dout(0));
					portbf(0) <= cpu_dout(0);
				end if;
				if(cpu_a(15 downto 14)=b"11" and cpu_a(1 downto 0)=b"01") then
					case cpu_dout(7 downto 0) is
						when b"11111111" => ym_number <= '0';
						when b"11111110" => ym_number <= '1';
						when others => null;
					end case;
					case ym_number is
						when '0' => ym0_wr_addr <='0';
						when '1' => ym1_wr_addr <='0';
						when others => null;
					end case;
				end if;
				if(cpu_a(15 downto 14)=b"10" and cpu_a(1 downto 0)=b"01") then
					case ym_number is
						when '0' => ym0_wr_data <='0';
						when '1' => ym1_wr_data <='0';
						when others => null;
					end case;
				end if;
			end if;
			if(dos = '0' and wr_ports_single = '0') then
				if(cpu_a(0)='1' and cpu_a(1)='1' and cpu_a(7)='0' and cpu_iorq='0' and cpu_m1='1') then
					vg93_cs <= '0';
				end if;
				if(cpu_iowr='0') then
					if(cpu_a(0)='1' and cpu_a(1)='1' and cpu_a(7)='1' and cpu_m1='1') then
						betadisk_reg(7 downto 0) <= cpu_dout(7 downto 0);
					end if;    
					if(cpu_a = x"fff7") then
						if(port7ffd(4)='0') then
							cpu3_0(9 downto 0) <= b"11" & cpu_dout(7 downto 0);
						else
							cpu3_1(9 downto 0) <= b"11" & cpu_dout(7 downto 0);
						end if;
					end if;
					if(cpu_a = x"bff7") then
						if(port7ffd(4)='0') then
							cpu2_0(9 downto 0) <= b"11" & cpu_dout(7 downto 0);
						else
							cpu2_1(9 downto 0) <= b"11" & cpu_dout(7 downto 0);
						end if;
					end if;
					if(cpu_a = x"7ff7") then
						if(port7ffd(4)='0') then
							cpu1_0(9 downto 0) <= b"11" & cpu_dout(7 downto 0);
						else
							cpu1_1(9 downto 0) <= b"11" & cpu_dout(7 downto 0);
						end if;
					end if;
					if(cpu_a = x"3ff7") then
						if(port7ffd(4)='0') then
							cpu0_0(9 downto 0) <= b"11" & cpu_dout(7 downto 0);
						else
							cpu0_1(9 downto 0) <= b"11" & cpu_dout(7 downto 0);
						end if;
					end if;
					if(cpu_a = x"f7f7") then 
						if(port7ffd(4)='0') then
							cpu3_0(9 downto 0) <= cpu_dout(7 downto 6) & b"01" & cpu_dout(5 downto 0);
						else
							cpu3_1(9 downto 0) <= cpu_dout(7 downto 6) & b"01" & cpu_dout(5 downto 0);
						end if;
					end if;
					if(cpu_a = x"b7f7") then 
						if(port7ffd(4)='0') then
							cpu2_0(9 downto 0) <= cpu_dout(7 downto 6) & b"01" & cpu_dout(5 downto 0);
						else
							cpu2_1(9 downto 0) <= cpu_dout(7 downto 6) & b"01" & cpu_dout(5 downto 0);
						end if;
					end if;
					if(cpu_a = x"77f7") then 
						if(port7ffd(4)='0') then
							cpu1_0(9 downto 0) <= cpu_dout(7 downto 6) & b"01" & cpu_dout(5 downto 0);
						else
							cpu1_1(9 downto 0) <= cpu_dout(7 downto 6) & b"01" & cpu_dout(5 downto 0);
						end if;
					end if;
					if(cpu_a = x"37f7") then 
						if(port7ffd(4)='0') then
							cpu0_0(9 downto 0) <= cpu_dout(7 downto 6) & b"01" & cpu_dout(5 downto 0);
						else
							cpu0_1(9 downto 0) <= cpu_dout(7 downto 6) & b"01" & cpu_dout(5 downto 0);
						end if;
					end if;
				end if;
			end if;
end if;
end process;                                    

-- 2 x ym2149
ym0_rd_data <='0' when (ym_number = '0' and cpu_iord = '0' and cpu_a(15 downto 14)=b"11" and cpu_a(1 downto 0)=b"01")
else '1';
ym1_rd_data <='0' when (ym_number = '1' and cpu_iord = '0' and cpu_a(15 downto 14)=b"11" and cpu_a(1 downto 0)=b"01")
else '1';
ym_do(7 downto 0) <= ym0_do(7 downto 0) when ym_number = '0'
else ym1_do(7 downto 0);

addiction <= beeper & tapeout;

snd_right <= ym0a + ym0b + ym1a + ym1b + covox when addiction(1 downto 0) = b"00" 	--beeper = '0'
else ym0a + ym0b + ym1a + ym1b + covox + 50 when addiction(1 downto 0) = b"01" or addiction(1 downto 0) = b"10" --beeper = '1';
else ym0a + ym0b + ym1a + ym1b + covox + 100 when addiction(1 downto 0) = b"11"; --beeper = '1';

snd_left <= ym0b + ym0c + ym1b + ym1c + covox when addiction(1 downto 0) = b"00" --beeper = '0'
else ym0b + ym0c + ym1b + ym1c + covox + 50 when	addiction(1 downto 0) = b"01" or addiction(1 downto 0) = b"10" --beeper = '1';
else ym0b + ym0c + ym1b + ym1c + covox + 100 when	addiction(1 downto 0) = b"11";

process(mainclk, ym_clk_ena, ym0_state, read_fe)
begin
if(read_fe = '0') then snd(0) <= 'Z'; -- tape in
	elsif(mainclk'event and mainclk = '1') then
		if(ym_clk_ena = '1') then
			ym0_state(1 downto 0) <= ym0_state(1 downto 0) + '1';
			case ym0_state(1 downto 0) is
				when b"11" => snd(7 downto 0) <= snd_right(7 downto 0); str_l <= '0';
				when b"10" => str_r <= '1';
				when b"01" => str_r <= '0'; snd(7 downto 0) <= snd_left(7 downto 0); 
				when b"00" => str_l <= '1';
				when others => null;
			end case;
		end if;
end if;
end process; 

process(mainclk, pollitra_strobe)
begin
if(mainclk'event and mainclk = '1') then
	old_pollitra_strobe <= pollitra_strobe;
	if(old_pollitra_strobe = '0' and pollitra_strobe = '1') then
		pollitra_ena <= '1';
	else
		pollitra_ena <= '0';
	end if;
end if;
end process;

pollitra_data_in(15 downto 0) <= cpu_a(15 downto 8) & cpu_dout(7 downto 0);
pollitra_rdaddress(3 downto 0) <= pollitra_a(3 downto 0);
pollitra_wraddress(3 downto 0) <= pollitra_awr(3 downto 0);

gfx_mode(5 downto 0) <= portxx77(2 downto 0) & b"00" & porteff7(0);
beeper <= portfe(4);
tapeout <= portfe(3);
klovetura(0) <= (keymatrix0(0) or cpu_a(8)) and (keymatrix0(1) or cpu_a(9)) and (keymatrix0(2) or cpu_a(10)) and (keymatrix0(3) or cpu_a(11)) and (keymatrix0(4) or cpu_a(12)) and (keymatrix0(5) or cpu_a(13)) and (keymatrix0(6) or cpu_a(14)) and(keymatrix0(7) or cpu_a(15));
klovetura(1) <= (keymatrix1(0) or cpu_a(8)) and (keymatrix1(1) or cpu_a(9)) and (keymatrix1(2) or cpu_a(10)) and (keymatrix1(3) or cpu_a(11)) and (keymatrix1(4) or cpu_a(12)) and (keymatrix1(5) or cpu_a(13)) and (keymatrix1(6) or cpu_a(14)) and(keymatrix1(7) or cpu_a(15));
klovetura(2) <= (keymatrix2(0) or cpu_a(8)) and (keymatrix2(1) or cpu_a(9)) and (keymatrix2(2) or cpu_a(10)) and (keymatrix2(3) or cpu_a(11)) and (keymatrix2(4) or cpu_a(12)) and (keymatrix2(5) or cpu_a(13)) and (keymatrix2(6) or cpu_a(14)) and(keymatrix2(7) or cpu_a(15));
klovetura(3) <= (keymatrix3(0) or cpu_a(8)) and (keymatrix3(1) or cpu_a(9)) and (keymatrix3(2) or cpu_a(10)) and (keymatrix3(3) or cpu_a(11)) and (keymatrix3(4) or cpu_a(12)) and (keymatrix3(5) or cpu_a(13)) and (keymatrix3(6) or cpu_a(14)) and(keymatrix3(7) or cpu_a(15));
klovetura(4) <= (keymatrix4(0) or cpu_a(8)) and (keymatrix4(1) or cpu_a(9)) and (keymatrix4(2) or cpu_a(10)) and (keymatrix4(3) or cpu_a(11)) and (keymatrix4(4) or cpu_a(12)) and (keymatrix4(5) or cpu_a(13)) and (keymatrix4(6) or cpu_a(14)) and(keymatrix4(7) or cpu_a(15));
klovetura(6) <= snd(0);
klovetura(7) <= '1';
klovetura(5) <= '1' when porteff7(2) = '1' else vsync_int_flag;

-- cpu data bus
int_ack_cycle <= cpu_iorq or cpu_m1;
read_ports <= not(ebl) or cpu_iord;
read_fe <= read_ports or cpu_a(0);
process(mainclk, cpu_mreq, cpu_iorq, cpu_m1, cpu_rfsh, cpu_clk, cpu_wait)
begin
if(mainclk'event and mainclk = '1') then
	-- memory read cpu cycles
	if(cpu_mreq = '1') then
		mem_data_ena <= '0';
	else
		if(cpu_rd = '0' and cpu_rfsh = '1' and mem_data_ena = '0') then
			addr_buf(15 downto 0) <= cpu_a(15 downto 0);
			mem_data_ena <= '1';
		end if;
	end if;
	-- i/o read cpu cycles
	if(cpu_iorq = '1') then
		io_data_ena <= '0';
	else
		if(cpu_rd = '0' and cpu_m1 = '1' and io_data_ena = '0') then
			io_data_ena <= '1';
			addr_buf(15 downto 0) <= cpu_a(15 downto 0);
		end if;
	end if;
	int_ack_ena <= int_ack_cycle;
end if;
end process;

addr_bff7_b <= '0' when (addr_buf(15 downto 0) = x"bff7") else '1';

cpu_din(7 downto 0) <= (others =>'1') when (int_ack_ena = '0')
else sram_data_buffer(7 downto 0) when ((mem_data_ena='1' and rom='1') or (mem_data_ena='1' and rom='0' and fpga_rdrom_input='0'))--((mem_data_ena = '1' and rom='1') or (mem_data_ena = '1' and rom='0' and fpga_rdrom_input='0'))
else klovetura(7 downto 0) when (io_data_ena = '1' and addr_buf(0)='0')
else ym_do(7 downto 0) when (io_data_ena = '1' and addr_buf(15 downto 13)=b"111" and addr_buf(1 downto 0)=b"01")
-- cmos: 
else x"AA" when (io_data_ena = '1' and addr_bff7_b='0' and porteff7(7)='1' and portdff7(5 downto 0)=x"11")
else x"20" when (io_data_ena = '1' and addr_bff7_b='0' and porteff7(7)='1' and portdff7(5 downto 0)=x"0A")
else x"02" when (io_data_ena = '1' and addr_bff7_b='0' and porteff7(7)='1' and portdff7(5 downto 0)=x"0B")
else x"00" when (io_data_ena = '1' and addr_bff7_b='0' and porteff7(7)='1' and portdff7(5 downto 0)=x"0C")
else x"80" when (io_data_ena = '1' and addr_bff7_b='0' and porteff7(7)='1' and portdff7(5 downto 0)=x"0D")
else seconds(7 downto 0) when (io_data_ena = '1' and porteff7(7)='1' and addr_bff7_b='0' and portdff7(7 downto 0)=0 and cmos_flags(7 downto 1) = 0)
else minutes(7 downto 0) when (io_data_ena = '1' and porteff7(7)='1' and addr_bff7_b='0' and portdff7(7 downto 0)=2 and cmos_flags(7 downto 1) = 0)
else hours(7 downto 0) when (io_data_ena = '1' and porteff7(7)='1' and addr_bff7_b='0' and portdff7(7 downto 0)=4 and cmos_flags(7 downto 1) = 0)
else days(7 downto 0) when (io_data_ena = '1' and porteff7(7)='1' and addr_bff7_b='0' and portdff7(7 downto 0)=7 and cmos_flags(7 downto 1) = 0)
else week(7 downto 0) when (io_data_ena = '1' and porteff7(7)='1' and addr_bff7_b='0' and portdff7(7 downto 0)=6 and cmos_flags(7 downto 1) = 0)
else month(7 downto 0) when (io_data_ena = '1' and porteff7(7)='1' and addr_bff7_b='0' and portdff7(7 downto 0)=8 and cmos_flags(7 downto 1) = 0)
else year(7 downto 0) when (io_data_ena = '1' and porteff7(7)='1' and addr_bff7_b='0' and portdff7(7 downto 0)=9 and cmos_flags(7 downto 1) = 0)
--else cmos_data_out(7 downto 0) when (io_data_ena = '1' and porteff7(7)='1' and addr_bff7_b='0' and not((portdff7(7 downto 0) > x"30") and (portdff7(7 downto 0) < x"35" )) ) --and portdff7(7 downto 0) > 13 ------  > 0b
else in_l(7 downto 0) when (io_data_ena = '1' and porteff7(7)='1' and addr_bff7_b='0' and portdff7(7 downto 0) = x"31")
else "000000" & in_l(9 downto 8) when (io_data_ena = '1' and porteff7(7)='1' and addr_bff7_b='0' and portdff7(7 downto 0) = x"32")
else in_r(7 downto 0) when (io_data_ena = '1' and porteff7(7)='1' and addr_bff7_b='0' and portdff7(7 downto 0) = x"33")
else "000000" & in_r(9 downto 8) when (io_data_ena = '1' and porteff7(7)='1' and addr_bff7_b='0' and portdff7(7 downto 0) = x"34")
else cmos_data_out(7 downto 0) when (io_data_ena = '1' and porteff7(7)='1' and addr_bff7_b='0') 
-- memory config
else not(cpu0_0(7 downto 0)) when (io_data_ena = '1' and addr_buf(15 downto 0)=x"00be")
else not(cpu1_0(7 downto 0)) when (io_data_ena = '1' and addr_buf(15 downto 0)=x"01be")
else not(cpu2_0(7 downto 0)) when (io_data_ena = '1' and addr_buf(15 downto 0)=x"02be")
else not(cpu3_0(7 downto 0)) when (io_data_ena = '1' and addr_buf(15 downto 0)=x"03be")
else not(cpu0_1(7 downto 0)) when (io_data_ena = '1' and addr_buf(15 downto 0)=x"04be")
else not(cpu1_1(7 downto 0)) when (io_data_ena = '1' and addr_buf(15 downto 0)=x"05be")
else not(cpu2_1(7 downto 0)) when (io_data_ena = '1' and addr_buf(15 downto 0)=x"06be")
else not(cpu3_1(7 downto 0)) when (io_data_ena = '1' and addr_buf(15 downto 0)=x"07be")
else spi_rd_data(7 downto 0) when (io_data_ena = '1' 
                            --and dos = '1' --Savelij
                            and addr_buf(7 downto 0) = x"57")--else ("00000000") when (read_ports='0' and dos = '1' and cpu_a(7 downto 0) = x"1f")
else ("000" & kempston(4 downto 0)) when (io_data_ena = '1' and dos = '1' and addr_buf(7 downto 0) = x"1f")
-- betadisk
else status_reg(7 downto 0) when (dos = '0' and io_data_ena = '1' and addr_buf(7 downto 5) = b"000")
else track_reg(7 downto 0)  when (dos = '0' and io_data_ena = '1' and addr_buf(7 downto 5) = b"001")
else sector_reg(7 downto 0) when (dos = '0' and io_data_ena = '1' and addr_buf(7 downto 5) = b"010")
else vg93_data_for_cpu(7 downto 0) when (dos = '0' and io_data_ena = '1' and addr_buf(7 downto 5) = b"011")
else vg93_intrq & vg93_drq & b"111111" when (dos = '0' and io_data_ena = '1' and addr_buf(7 downto 5) = b"111")
-- mouse
else mouse_x(7 downto 0) when (io_data_ena = '1' and addr_buf(15 downto 0) = x"FBDF")
else mouse_y(7 downto 0) when (io_data_ena = '1' and addr_buf(15 downto 0) = x"FFDF")
else mouse_b(7 downto 0) when (io_data_ena = '1' and addr_buf(15 downto 0) = x"FADF")
-- uart
else reg_data_out(7 downto 0) when (io_data_ena = '1' and addr_buf(15 downto 11) = b"11111" and addr_buf(7 downto 0) = b"11101111")
else fpga_d(7 downto 0);
        
-- vsync int
process(mainclk, cpu_res, int_strobe, int_ack_cycle, cpu_iowr, ebl, wr_ports_single, cpu_a, porteff7, cpu_dout)
begin
if(mainclk'event and mainclk = '1') then
	cpu_clk_old <= cpu_clk;	
	if(cpu_res = '0') then vsync_int <= '1'; int_counter(4 downto 0) <= (others => '0'); end if;
	if(int_strobe = '0') then
		vsync_int <= '0';
		vsync_int_flag <= '1';
		int_counter(4 downto 0) <= (others => '1');
	end if;
	if(cpu_clk_old = '0' and cpu_clk = '1') then
		if(int_counter(4 downto 0) /= b"00000") then
			int_counter(4 downto 0) <= int_counter(4 downto 0) - '1';
		else
			vsync_int <= '1';
		end if;
	end if;
	if(cpu_iowr='0' and ebl='1' and wr_ports_single = '0' and cpu_a(0)='0' and porteff7(2) = '0' and cpu_dout(7 downto 0) = b"00100000") then
		vsync_int_flag <= '0';
	end if;
end if;
end process;

internal_int <= vsync_int and uart_int;
cpu_int <= fpga_int_input;

--	cpu_speed:
--	000 main_state_counter(4) 3.5 MHz
--	001 main_state_counter(4) 3.5 MHz
--	010 main_state_counter(4) 3.5 MHz
--	011 main_state_counter(4) 3.5 MHz
--	100 main_state_counter(2) 14 MHz
--	101 main_state_counter(4) 3.5 MHz
--	110 main_state_counter(1) 28 MHz
--	111 main_state_counter(1) 28 MHz
cpu_speed(2 downto 0) <= not(iocycle) & portxx77(3) & porteff7(4); 

process(mainclk, main_state_counter, cpu_speed, vg_tormoz)
begin
if(mainclk'event and mainclk = '1') then
	case cpu_speed(2 downto 1) is -- 28 MHz
		when b"11" =>
			case main_state_counter(1 downto 0) is
				when b"01" => cpu_clk_b <= '1';  cpu_clk <= '1'; 
				when b"11" => cpu_clk_b <= '0'; if(vg_tormoz = '0') then cpu_clk <= '0'; end if;
				when others => null;
			end case;
		when others => 
			if(cpu_speed(2 downto 0) = b"100") then -- 14 MHz
				case main_state_counter(2 downto 0) is
					when b"011" => cpu_clk_b <= '0'; if(vg_tormoz = '0') then cpu_clk <= '0'; end if;
					when b"111" => cpu_clk_b <= '1'; cpu_clk <= '1';
					when others => null;
				end case;
			else -- 3.5 MHz
				case main_state_counter(4 downto 0) is
					when b"01111" => cpu_clk_b <= '0'; if(vg_tormoz = '0') then cpu_clk <= '0'; end if;
					when b"11111" => cpu_clk_b <= '1'; cpu_clk <= '1';
					when others => null;
				end case;
			end if;
	end case;
end if;
end process;

process(mainclk, cpu_clk_b, hardware_reset, read_trz, write_trz, cpu_wr, cpu_rd, cpu_m1, cpu_mreq, cpu_iorq, main_state_counter)
begin
if(hardware_reset = '0') then
	vg_tormoz <= '0';
	vg93_transaction <= '1'; 
	elsif(mainclk'event and mainclk = '1') then
		if((read_trz = '1' or write_trz = '1') and cpu_rfsh = '0') then
			vg_tormoz <= '1';
		end if;
		if(vg_tormoz = '1' and main_state_counter(1 downto 0)=b"00") then vg93_transaction <= '0'; end if;
		if(vg93_transaction = '0' and main_state_counter(1 downto 0)= b"11") then
			vg_tormoz <= '0';
		end if;
		if(vg93_transaction = '0' and main_state_counter(1 downto 0)= b"00" and vg_tormoz = '0') then
			vg93_transaction <= '1';
		end if;
end if;
end process;

-- Nemobus signals
cpu_res <= z80_reset_from_arm and fpga_res_input;
cpu_wait <= fpga_wait_input;
fpga_clk_output <= cpu_clk;        
fpga_mreq_output <= cpu_mreq when cpu_busack = '1' else 'Z';
fpga_rfsh_output <= cpu_rfsh;
fpga_wr_output <= cpu_wr when cpu_busack = '1' else 'Z';
fpga_iorq_output <= cpu_iorq when cpu_busack = '1' else 'Z';
fpga_halt_output <= cpu_halt;
fpga_busack_output <= cpu_busack;
fpga_m1_output <= cpu_m1;
fpga_rd_output  <= cpu_rd when cpu_busack = '1' else 'Z';
fpga_dos_output <= dos;
fpga_f_output <= cpu_clk;
fpga_int_output <= internal_int;
fpga_rs_output <= port7ffd(4);
fpga_csr_output <= rom;
cpu_nmi <= fpga_nmi_input;
cpu_busrq <= fpga_busrq_input;
fpga_a(15 downto 0) <= cpu_a(15 downto 0) when cpu_busack = '1' else (others => 'Z');
zetneg_oe <= not(cpu_busack);
dbusoe <= not(cpu_busack);
fpgadir <= cpu_rd and (cpu_m1 or cpu_iorq);
fpga_dir <= fpgadir;      
iorq_after_bus <= (cpu_iorq or fpga_io0 or fpga_io1 or fpga_io2);-- or not(ebl)) ;

fpga_d(7 downto 0) <= (others =>'Z') when fpgadir='0'
else cpu_dout(7 downto 0) when fpgadir='1';

-- IDE by Nemo
ebl <= (not(cpu_m1) or cpu_a(1) or cpu_a(2));        
ebl_iorq <= ebl or iorq_after_bus; 
fpga_ebl <= ebl_iorq;
ior <= ebl_iorq or cpu_a(0) or cpu_rd;
fpga_ior <= ior;
rdh <= ebl_iorq or cpu_rd or not(cpu_a(0));
fpga_rdh <= rdh;
fpga_wrh <= cpu_iowr or ebl or not(cpu_a(0));
fpga_iow <= cpu_iowr or ebl or cpu_a(0);

ssi <= ssii;
ksi <= ksii;

r_adr(18 downto 0) <= radr(18 downto 0);

we_blk0chp0 <= weblk0chp0;
oe_blk0chp0 <= oeblk0chp0;
we_blk0chp1 <= weblk0chp1;
oe_blk0chp1 <= oeblk0chp1;
we_blk1chp0 <= weblk1chp0;
oe_blk1chp0 <= oeblk1chp0;
we_blk1chp1 <= weblk1chp1;
oe_blk1chp1 <= oeblk1chp1;

uart_tx_o <= uart_tx;
uart_rx <= uart_rx_i;
uart_rts_o <= uart_rts;
uart_cts <= uart_cts_i;

end koe;