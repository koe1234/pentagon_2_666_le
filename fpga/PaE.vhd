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
		clk								: in std_logic;								
		r_adr								: out std_logic_vector(18 downto 0);	
		blk0_d								: inout std_logic_vector(7 downto 0);	
		blk1_d								: inout std_logic_vector(7 downto 0);	
		snd								: inout std_logic_vector(7 downto 0);
		str_r								: out std_logic;
		str_l								: out std_logic;
		svetodiod							: out std_logic;								
		ssi								: out std_logic;
		ksi								: out std_logic;
		vid_r								: out std_logic_vector(4 downto 0);
		vid_g								: out std_logic_vector(4 downto 0);
		vid_b								: out std_logic_vector(4 downto 0);
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
		fpga_clk_output							: out std_logic;
		fpga_mreq_output						: out std_logic;
		fpga_rfsh_output						: out std_logic;
		fpga_wr_output							: out std_logic;
		fpga_iorq_output						: out std_logic;
		fpga_halt_output						: out std_logic;
		fpga_busack_output						: out std_logic;
		fpga_m1_output							: out std_logic;
		fpga_rd_output							: out std_logic;
		fpga_dos_output							: out std_logic;
		fpga_f_output							: out std_logic;
		fpga_int_output							: out std_logic;
		fpga_csr_output							: out std_logic;
		fpga_rs_output							: out std_logic;
		fpga_rs_in							: in std_logic;
		fpga_rdrom_input						: in std_logic;
		fpga_nmi_input							: in std_logic;
		fpga_busrq_input						: in std_logic;
		fpga_res_input							: in std_logic;
		fpga_wait_input							: in std_logic;
		fpga_int_input							: in std_logic;
		zetneg_oe							: out std_logic;
		dbusoe								: out std_logic;
		fpga_dir							: out std_logic;
		fpga_a								: out std_logic_vector(15 downto 0);
		fpga_d								: inout std_logic_vector(7 downto 0);
		fpga_io0							: in std_logic;
		fpga_io1							: in std_logic;
		fpga_io2							: in std_logic;
		fpga_ebl							: out std_logic;
		fpga_ior							: out std_logic;
		fpga_iow							: out std_logic;
		fpga_wrh							: out std_logic;
		fpga_rdh							: out std_logic;
		sd_clk								: out std_logic;
		sd_dataout							: inout std_logic;
		sd_datain							: in std_logic;
		sd_cs								: out std_logic       
    );
    
end PaE;

-- **************************************************************

architecture koe of PaE is

component zx_main is
	port (
		pixel_clock							: in  std_logic;
		ym_clk								: out std_logic;
		main_state_counter						: out std_logic_vector(1 downto 0);
		blk0_d								: in std_logic_vector(7 downto 0);
		portfe								: in std_logic_vector(3 downto 0);
		gfx_mode							: in std_logic_vector(5 downto 0);
		int_strobe							: out std_logic;
		int_delay							: in std_logic_vector(9 downto 0);
		ssii								: out std_logic;
		ksii								: out std_logic;
		vidr								: out std_logic_vector(4 downto 0);
		vidg								: out std_logic_vector(4 downto 0);
		vidb								: out std_logic_vector(4 downto 0);
		pixelc								: out std_logic_vector(9 downto 0);
		linec								: out std_logic_vector(9 downto 0);
		flash								: in std_logic;
		video_address							: out std_logic_vector(12 downto 0);
		alco_address							: out std_logic_vector(14 downto 0);
		pollitra_a							: out std_logic_vector(3 downto 0);
		pollitra_awr							: out std_logic_vector(3 downto 0);
		pollitra_d							: in std_logic_vector(15 downto 0);
		border3								: in std_logic;
		ega_address							: out std_logic_vector(12 downto 0);
		otmtxt_address							: out std_logic_vector(16 downto 0)
);
end component;

component pll1 is
	port	(
		inclk0								: IN STD_LOGIC  := '0';
		c0								: OUT STD_LOGIC;
		c1								: OUT STD_LOGIC 	
			);
end component;

component T80a
port		(
		RESET_n								: in std_logic;
		CLK_n								: in std_logic;
		WAIT_n								: in std_logic;
		INT_n								: in std_logic;
		NMI_n								: in std_logic;
		BUSRQ_n								: in std_logic;
		M1_n								: out std_logic;
		MREQ_n								: out std_logic;
		IORQ_n								: out std_logic;
		RD_n								: out std_logic;
		WR_n								: out std_logic;
		RFSH_n								: out std_logic;
		HALT_n								: out std_logic;
		BUSAK_n								: out std_logic;
		A								: out std_logic_vector(15 downto 0);
		D								: inout std_logic_vector(7 downto 0);
		IOcycle								: out std_logic;
		MEMcycle							: out std_logic
		);
end component;

component ym2149
	port		(
		I_DA								: in  std_logic_vector(7 downto 0);
		O_DA								: out std_logic_vector(7 downto 0);
		output								: out std_logic_vector(7 downto 0);
		strobe_a							: out std_logic;
		strobe_b							: out std_logic;
		strobe_c							: out std_logic; 
		RESET_L								: in  std_logic;
		CLK								: in std_logic;  -- note 6 Mhz
		wr_addr								: in std_logic;
		wr_data								: in std_logic;
		rd_data								: in std_logic;
		state								: out std_logic_vector(1 downto 0)
				);
end component;

component ram_cmos
	port		(
		clock								: IN  std_logic;
		data								: IN  std_logic_vector(7 DOWNTO 0);
		write_address							: IN  std_logic_vector(7 DOWNTO 0);
		read_address							: IN  std_logic_vector(7 DOWNTO 0);
		we								: IN  std_logic;
		q								: OUT std_logic_vector(7 DOWNTO 0)
				);
end component;

component ram_pollitra is
	port		(
		clock								: IN STD_LOGIC ;
		data								: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdaddress							: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		wraddress							: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		wren								: IN STD_LOGIC  := '1';
		q								: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
				);
end component;

component rom_pollitra is
	port		(
		address								: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		clock								: IN STD_LOGIC ;
		q								: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
				);
end component;

component bdi is
	port		(
		vg93_cs								: in std_logic;
		vg93_ram_addr							: out std_logic_vector(19 downto 0);
		betadisk_transfer						: in std_logic := '1';
		write_byte_n							: out std_logic_vector(7 downto 0);
		write_sector_n							: out std_logic_vector(7 downto 0);
		read_sector_n							: out std_logic_vector(7 downto 0);
		read_byte_n							: out std_logic_vector(7 downto 0);
		track_f								: out std_logic;
		sector_f							: out std_logic;
		restore_f							: out std_logic;
		vg93_O_data							: out std_logic_vector(7 downto 0);
		force_interrupt_f						: out std_logic;
		track_pos							: out std_logic_vector(7 downto 0);
		track_r								: out std_logic_vector(7 downto 0);
		sector_r							: out std_logic_vector(7 downto 0);
		status_r							: out std_logic_vector(7 downto 0);
		betadisk_r							: in std_logic_vector(7 downto 0);
		vg93intrq							: out std_logic;
		seek_f								: out std_logic;
		vg93drq								: out std_logic;
		step_f								: out std_logic;
		step_dir							: out std_logic;
		read_addr_f							: out std_logic;
		read_f								: out std_logic;
		write_f								: out std_logic;
		vg93_data_from_r						: out std_logic_vector(7 downto 0);
		vg_tormoz							: in std_logic;
		read_t								: out std_logic;
		write_t								: out std_logic;
		cpu_rd								: in std_logic;
		cpu_wr								: in std_logic;
		cpu_a								: in std_logic_vector(15 downto 0);
		cpu_d								: in std_logic_vector(7 downto 0);
		pixel_clock							: in std_logic;
		hardware_reset							: in std_logic;
		vg93_data_for_cpu_o						: out std_logic_vector(7 downto 0);
		vg93_data_for_r							: out std_logic_vector(7 downto 0);
		index								: out std_logic    
				);
end component;

signal	main_state_counter							: std_logic_vector(1 downto 0);
signal	radr									: std_logic_vector(18 downto 0);
signal	video_address								: std_logic_vector(12 downto 0);
signal	alco_address								: std_logic_vector(14 downto 0);
signal 	ega_address								: std_logic_vector(12 downto 0);
signal 	ram_blk									: std_logic;
signal 	pollitra_data_in							: std_logic_vector (15 downto 0);
signal 	pollitra_rdaddress							: std_logic_vector (3 downto 0);
signal 	pollitra_wraddress							: std_logic_vector (3 downto 0);
signal 	pollitra_data_out							: std_logic_vector (15 downto 0);
signal 	pollitra_a								: std_logic_vector(3 downto 0);
signal 	pollitra_awr								: std_logic_vector(3 downto 0);
signal 	pollitra_flag0								: std_logic;
signal	pollitra_flag1								: std_logic;
signal	pollitra_strobe								: std_logic;
signal	border3									: std_logic;
signal	weblk0chp0								: std_logic;
signal	oeblk0chp0								: std_logic;
signal	weblk0chp1								: std_logic;
signal	oeblk0chp1								: std_logic;
signal	weblk1chp0								: std_logic;
signal	oeblk1chp0								: std_logic;
signal	weblk1chp1								: std_logic;
signal	oeblk1chp1								: std_logic;
signal	z80_full_adr								: std_logic_vector(20 downto 0);
signal	mcu_full_adr								: std_logic_vector(20 downto 0);
signal	video_full_adr								: std_logic_vector(20 downto 0);
signal	full_adr								: std_logic_vector(20 downto 0);
signal	ram_outdata								: std_logic_vector(7 downto 0);
signal	we_enable								: std_logic;
signal	command_from_mcu							: std_logic_vector(6 downto 0);
signal	data_from_mcu								: std_logic_vector(7 downto 0);
signal	counter									: std_logic_vector(29 downto 0);
signal	pixel_clock								: std_logic; 
signal	shifted_clock								: std_logic;
signal	ssii				            				: std_logic;
signal	ksii									: std_logic;
signal	pixel_c									: std_logic_vector(9 downto 0);
signal	line_c									: std_logic_vector(9 downto 0);
signal	upload_adr								: std_logic_vector(13 downto 0);
signal	download_adr								: std_logic_vector(14 downto 0);
signal	upload									: std_logic;
signal	upload_in_process							: std_logic;
signal	svetodiod_on								: std_logic;
signal	svetodiod_off								: std_logic;
signal	ena									: std_logic;
signal	download								: std_logic;
signal	download_in_process							: std_logic;
signal	download_strobe								: std_logic;
signal	mcu_in_data								: std_logic_vector(7 downto 0);
signal	hardware_reset								: std_logic;
signal	page_number								: std_logic_vector(7 downto 0);
signal	pagenum									: std_logic;
signal	idle									: std_logic;
signal	z80_to_ram								: std_logic;
signal	cmd07									: std_logic;
signal	to_vz80_data								: std_logic_vector(7 downto 0);
signal	cmd05									: std_logic;
signal	portfe									: std_logic_vector(7 downto 0) := (others => '1');
signal	cmd02									: std_logic;
signal	keymatrix0								: std_logic_vector(7 downto 0):=b"11111111";
signal	keymatrix1								: std_logic_vector(7 downto 0):=b"11111111";
signal	keymatrix2								: std_logic_vector(7 downto 0):=b"11111111";
signal	keymatrix3								: std_logic_vector(7 downto 0):=b"11111111";
signal	keymatrix4								: std_logic_vector(7 downto 0):=b"11111111";
signal	key_byte_number								: std_logic_vector(6 downto 0);
signal	port7ffd								: std_logic_vector(7 downto 0);
signal	port7ffdadd								: std_logic_vector(7 downto 0);
signal	atmwindow								: std_logic_vector(2 downto 0);
signal	atmpage									: std_logic_vector(9 downto 0);
signal	rampage									: std_logic_vector(6 downto 0);
signal	porteff7								: std_logic_vector(7 downto 0);
signal	portxx77								: std_logic_vector(7 downto 0);
signal	portbf									: std_logic_vector(7 downto 0):=b"00000000"; --Savelij
signal	cpu3_0									: std_logic_vector(9 downto 0);
signal	cpu3_1									: std_logic_vector(9 downto 0);
signal	cpu2_0									: std_logic_vector(9 downto 0);
signal	cpu2_1									: std_logic_vector(9 downto 0);
signal	cpu1_0									: std_logic_vector(9 downto 0);
signal	cpu1_1									: std_logic_vector(9 downto 0);
signal	cpu0_0									: std_logic_vector(9 downto 0);
signal	cpu0_1									: std_logic_vector(9 downto 0);
signal	cpm									: std_logic:='1'; --Savelij
signal	pen2									: std_logic;
signal	rom_page								: std_logic_vector(1 downto 0);
signal	rom									: std_logic;
signal	romram									: std_logic;
signal	ram_from_c000								: std_logic;
signal	dosen									: std_logic:='1'; --3dxx etc --Savelij
signal	dos									: std_logic:='1'; --from dosen and cp/m --Savelij
signal	fpgadir									: std_logic;
signal	z80_reset_from_mcu							: std_logic;
signal	ioycle									: std_logic;
signal	cpu_iowr								: std_logic;
signal	cpu_iord								: std_logic;
signal	klovetura								: std_logic_vector(7 downto 0);
signal	romadr14								: std_logic;
signal	cpu_memrd								: std_logic;
signal	cpu_memwr								: std_logic;
signal	m1									: std_logic;
signal	iorq_after_bus								: std_logic;
signal	read_ports								: std_logic;
signal	precounter								: std_logic_vector(4 downto 0);
signal	cpu_we_enable_res							: std_logic;
signal	cpu_we_enable								: std_logic;
signal	weblk									: std_logic;
signal	int_strobe								: std_logic;
signal	i2c_scl_b								: std_logic;
signal	i2c_sda_b								: std_logic;
signal	i2c_bit_counter								: std_logic_vector(3 downto 0);
signal	i2c_data_buffer								: std_logic_vector(7 downto 0);
signal	i2c_command_buffer							: std_logic_vector(6 downto 0);
signal	i2c_start_condition							: std_logic;
signal	i2c_strobe								: std_logic;
signal	i2c_data_ena								: std_logic;
signal	i2c_data_strobe								: std_logic;
signal	i2cdstr									: std_logic;
signal	i2c_to_m_flag								: std_logic;
signal	i2c_to_master								: std_logic := '1';
signal	i2c_mode								: std_logic := '1';
signal	i2c_ena_to_m								: std_logic := '1';
signal	i2c_out_data								: std_logic_vector(7 downto 0);
signal	data_from_fpga								: std_logic_vector(7 downto 0);
signal	i2c_ack									: std_logic := '1';
signal	i2c_out_ena								: std_logic := '1';
signal	i2c_out_data_strobe							: std_logic;
signal	i2c_in_data_strobe							: std_logic;
signal	ena_st									: std_logic;
signal	ena_f									: std_logic;
signal	ebl									: std_logic;
signal	ebl_iorq								: std_logic;
signal	ior									: std_logic;
signal	rdh									: std_logic; 
signal	seconds									: std_logic_vector(7 downto 0);
signal	minutes									: std_logic_vector(7 downto 0);
signal	hours									: std_logic_vector(7 downto 0);
signal	week									: std_logic_vector(7 downto 0);
signal	days									: std_logic_vector(7 downto 0);
signal	month									: std_logic_vector(7 downto 0);
signal	year									: std_logic_vector(7 downto 0);
signal	addr_dff7								: std_logic;
signal	addr_bff7								: std_logic;
signal	portdff7								: std_logic_vector(7 downto 0);
signal	portbff7								: std_logic_vector(7 downto 0);
signal	addr_eff7								: std_logic;
signal	int_counter								: std_logic_vector(5 downto 0);
signal	int_flag0								: std_logic;
signal	int_flag1								: std_logic;
signal	beeper									: std_logic;
signal	kempston								: std_logic_vector(4 downto 0);
signal	in_l									: std_logic_vector(9 downto 0);
signal	in_r									: std_logic_vector(9 downto 0);
signal	mouse_x									: std_logic_vector(7 downto 0);
signal	mouse_y									: std_logic_vector(7 downto 0);
signal	mouse_b									: std_logic_vector(7 downto 0);
--bdi
signal	vg93_ram_addr								: std_logic_vector(19 downto 0);
signal	betadisk_transfer							: std_logic;
signal	betadisk_transmit_counter						: std_logic_vector(5 downto 0);
signal	write_byte_number							: std_logic_vector(7 downto 0);
signal	write_sector_num							: std_logic_vector(7 downto 0);
signal	read_sector_num								: std_logic_vector(7 downto 0);
signal	read_byte_number							: std_logic_vector(7 downto 0);
signal	vg93_O_data								: std_logic_vector(7 downto 0);
signal	track_flag								: std_logic;
signal	sector_flag								: std_logic;
signal	restore_flag								: std_logic;
signal	force_interrupt_flag							: std_logic;
signal	track_position								: std_logic_vector(7 downto 0);
signal	track_reg								: std_logic_vector(7 downto 0);
signal	sector_reg								: std_logic_vector(7 downto 0);
signal	status_reg								: std_logic_vector(7 downto 0);
signal	betadisk_reg								: std_logic_vector(7 downto 0);
signal	seek_flag								: std_logic;
signal	vg93_intrq								: std_logic;
signal	step_flag								: std_logic;
signal	vg93_drq								: std_logic;
signal	step_direction								: std_logic;
signal	read_addr_flag								: std_logic;
signal	read_flag								: std_logic;
signal	write_flag								: std_logic;
signal	vg93_data_from_ram							: std_logic_vector(7 downto 0);
signal	vg93_cs									: std_logic;
signal	read_trz								: std_logic;
signal	write_trz								: std_logic;
signal	vg93_data_for_cpu							: std_logic_vector(7 downto 0);
signal	betadisk_r								: std_logic_vector(7 downto 0);
signal	vg93_transaction							: std_logic;
signal	betadisk_full_adr							: std_logic_vector(20 downto 0);
signal	vg93_data_for_ram							: std_logic_vector(7 downto 0);
signal	vg_tormoz		           					: std_logic;
signal	betadisk_flags								: std_logic_vector(11 downto 0);
--cmos
signal	cmos_clk		        					: std_logic;
signal	cmos_data_in								: std_logic_vector(7 downto 0);
signal	cmos_addr								: std_logic_vector(7 downto 0);
signal	cmos_we									: std_logic;
signal	cmos_start			   	  				: std_logic;
signal	cmos_data_out								: std_logic_vector(7 downto 0);
signal	cmos_cpuread								: std_logic;
signal	cmos_cpuwrite								: std_logic;
signal	cmos_mode								: std_logic_vector(3 downto 0);
signal	cmos_nado								: std_logic:='0';
signal	cmos_upload								: std_logic:='1';
signal	cmos_download								: std_logic :='1';
signal	cmos_upload_counter							: std_logic_vector(8 downto 0);
signal	cmos_download_counter							: std_logic_vector(8 downto 0);
signal	seconds_flag								: std_logic:='0';
signal	minutes_flag								: std_logic:='0';
signal	hours_flag								: std_logic:='0';
signal	week_flag								: std_logic:='0';
signal	days_flag								: std_logic:='0';
signal	month_flag								: std_logic:='0';
signal	year_flag								: std_logic:='0';
signal	cmos_upload_strobe							: std_logic:='0';
signal	cmos_download_strobe							: std_logic:='0';
signal	cmos_strobe								: std_logic:='0';
signal	cpu_write_strobe0							: std_logic;
signal	cpu_write_strobe							: std_logic;
signal	cmos_flags								: std_logic_vector(7 downto 0);
signal	cmos_download_reset							: std_logic_vector(1 downto 0);
signal	cmos_download_buffer							: std_logic_vector(7 downto 0);
signal	cmos_cpu_buffer								: std_logic_vector(7 downto 0);
signal	cmos_data_buffer							: std_logic_vector(7 downto 0);
signal	fromcmos2fpga								: std_logic;
signal	fromfpga2cmos								: std_logic;
signal	fromfpga2cpu								: std_logic;
signal	fromcpu2fpga								: std_logic;
signal	iorq_onetime								: std_logic;
signal	cmos_start1								: std_logic_vector(3 downto 0);
signal	i2c_dataonetime								: std_logic;
signal	i2c_mcudataonetime							: std_logic;
-- cpu core signals:
signal	cpu_d									: std_logic_vector(7 downto 0);
signal	cpu_a									: std_logic_vector(15 downto 0);
signal	cpu_int									: std_logic;
signal	cpu_nmi									: std_logic;
signal	cpu_mreq								: std_logic;
signal	cpu_iorq								: std_logic;
signal	cpu_rd									: std_logic;
signal	cpu_notrd								: std_logic;
signal	cpu_wr									: std_logic;
signal	cpu_wait								: std_logic;
signal	cpu_busrq								: std_logic;
signal	cpu_busack								: std_logic;
signal	cpu_res									: std_logic;
signal	cpu_m1									: std_logic;
signal	cpu_rfsh								: std_logic;
signal	cpu_halt								: std_logic;
signal	cpu_clk									: std_logic;
signal	cpu_mc									: std_logic_vector(2 downto 0);
signal	cpu_ts									: std_logic_vector(2 downto 0);
signal	turbo									: std_logic;
signal	cpu_clk_b								: std_logic;
signal	cpu_speed								: std_logic_vector(2 downto 0);
signal	tormoz									: std_logic;
-- ym2149 
signal	ym_number								: std_logic;
signal	ym0_wr_data								: std_logic;
signal	ym0_rd_data								: std_logic;
signal	ym0_wr_addr								: std_logic;
signal	ym1_wr_data								: std_logic;
signal	ym1_rd_data								: std_logic;
signal	ym1_wr_addr								: std_logic;
signal	strobe0_a								: std_logic;
signal	strobe0_b								: std_logic;
signal	strobe0_c								: std_logic;
signal	strobe1_a								: std_logic;
signal	strobe1_b								: std_logic;
signal	strobe1_c								: std_logic;
signal	ym0_do									: std_logic_vector(7 downto 0);
signal	ym1_do									: std_logic_vector(7 downto 0);
signal	ym_do									: std_logic_vector(7 downto 0);
signal	ym0_snd									: std_logic_vector(7 downto 0);
signal	ym1_snd									: std_logic_vector(7 downto 0);
signal	ym0a									: std_logic_vector(7 downto 0);
signal	ym0b									: std_logic_vector(7 downto 0);
signal	ym0c									: std_logic_vector(7 downto 0);
signal	ym1a									: std_logic_vector(7 downto 0);
signal	ym1b									: std_logic_vector(7 downto 0);
signal	ym1c									: std_logic_vector(7 downto 0);
signal	snd_right								: std_logic_vector(7 downto 0);
signal	snd_left								: std_logic_vector(7 downto 0);
signal	ym0_state								: std_logic_vector(1 downto 0);
signal	ym1_state								: std_logic_vector(1 downto 0);
signal	ym_clk									: std_logic;
-- sd-card
signal	spi_enable								: std_logic := '1';
signal	spi_cmd									: std_logic;
signal	sd_clock								: std_logic;
signal	sd_sync									: std_logic;
signal	port57wr								: std_logic;
signal	port57rd								: std_logic;
signal	spi_we_data								: std_logic_vector(7 downto 0);
signal	spi_rd_data								: std_logic_vector(7 downto 0);
signal	port57buffer								: std_logic_vector(7 downto 0);
signal	sd_config								: std_logic_vector(7 downto 0);
signal	sd_counter								: std_logic_vector(3 downto 0);
signal	sd_ena0									: std_logic;
signal	sd_ena1									: std_logic;
signal	sd_readflag								: std_logic;
signal	sd_writeflag								: std_logic;
signal	sd_active_flag								: std_logic;
signal	sd_stop									: std_logic;
signal	vidr									: std_logic_vector(4 downto 0);
signal	vidg									: std_logic_vector(4 downto 0);
signal	vidb									: std_logic_vector(4 downto 0);
signal	gfx_mode								: std_logic_vector(5 downto 0); --atm (5..3). pent (2..0)
-- gfx_mode(2 downto 0):
-- 000: standard zx screen
-- 001: alco
-- 010..111 reserved
-- gfx_mode(5 downto 3):
-- 000: ega
-- 010: multicolor 640x200
-- 110: textmode
-- 011: pentagon modes
signal	otmtxt_addr								: std_logic_vector(16 downto 0);
signal	int_delay								: std_logic_vector(9 downto 0):=b"1011000000";
signal	index									: std_logic;
signal	iorq_tormoz_ena								: std_logic:='1';
signal	iorq_tormoz_flag0							: std_logic:='1';
signal	iorq_tormoz_flag1							: std_logic:='1';
signal	iorq_tormoz_flag							: std_logic:='1';
signal	iorq_tormoz_counter							: std_logic_vector(9 downto 0);
signal	iorq_tormoz_phase							: std_logic:='1';
signal	speed_change								: std_logic:='0';
signal	resync									: std_logic:='0';
signal	iorq_change								: std_logic:='0';
signal	sd_iorq_change								: std_logic:='0';
signal	change_tormoz_flag							: std_logic:='0';
signal	change_tormoz_flag0							: std_logic:='0';
signal	change_tormoz_flag1							: std_logic:='0';
signal	iocycle									: std_logic:='0';
signal	memcycle								: std_logic:='0';
signal	ioflag0									: std_logic:='0';
signal	ioflag1									: std_logic:='0';
signal	ioflag2									: std_logic:='0';
signal	ioflag3									: std_logic:='0';
signal	iocycle1								: std_logic:='0';
signal	iocycle2								: std_logic:='0';
signal	memflag0								: std_logic:='0';
signal	memflag1								: std_logic:='0';
signal	memflag2								: std_logic:='0';
signal	memflag3								: std_logic:='0';
signal	memflag4								: std_logic:='0';
signal	memcycle1								: std_logic:='0';
signal	memcycle2								: std_logic:='0';
signal	memcycle3								: std_logic:='0';
signal	lowclk									: std_logic;
signal	fastclk									: std_logic;
signal	read_fe									: std_logic:='1'; 
signal	tapeout									: std_logic:='0'; 
signal	addiction								: std_logic_vector(1 downto 0):=b"00";
signal	wr_ports_single								: std_logic:='0';
signal	dos_1									: std_logic:='1';

constant key_byte_number_max: natural:= 120;
            
    begin
    
-- led flashing :)
process (clk)
        begin
        if (clk'event and clk='1') then counter(28 downto 0) <= counter(28 downto 0)+'1';
        counter(29) <= spi_we_data(7);
        end if;
        end process;
svetodiod <= (not(counter(25)) and counter(24) and counter(23) and counter(22) and counter(19));      

-----------------------------------------------------------------------------------------------------
-- i2c command/data transfer ------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
process (pixel_clock, i2c_sda, i2c_scl)
begin
if (pixel_clock'event and pixel_clock = '1') then i2c_scl_b <= i2c_scl; i2c_sda_b <= i2c_sda;
end if;
end process;

process (i2c_sda_b, i2c_scl_b)
begin
if (i2c_scl_b = '0') then i2c_start_condition <= '1';
    elsif (i2c_sda_b'event and i2c_sda_b = '0') then i2c_start_condition <= '0';
end if;
end process;

process (i2c_scl_b, i2c_sda_b, i2c_bit_counter, i2c_start_condition, i2c_data_ena)
begin
if ((i2c_start_condition='0') or (i2c_bit_counter = b"1001" and i2c_scl='0')) then i2c_bit_counter <= (others => '0'); 
    elsif (i2c_scl_b'event and i2c_scl_b='1') then
            i2c_bit_counter <= i2c_bit_counter+'1';
        if ((i2c_bit_counter < 7) and (i2c_strobe='0')) then
            i2c_command_buffer(6 downto 1) <= i2c_command_buffer(5 downto 0);
            i2c_command_buffer(0) <= i2c_sda_b; 
        end if;
        if (i2c_bit_counter < 8) then
            i2c_data_buffer(7 downto 1) <= i2c_data_buffer(6 downto 0);
            i2c_data_buffer(0) <= i2c_sda_b; 
        end if;
end if;
if (i2c_start_condition='0') then i2c_strobe <= '0'; 
    elsif (i2c_scl_b'event and i2c_scl_b='0') then
        if (i2c_bit_counter=b"1000") then       
            i2c_strobe <='1';
        end if;
end if;
if (i2c_start_condition='0') then i2c_data_ena <= '1';
    elsif (i2c_scl_b'event and i2c_scl_b='1') then
        if (i2c_bit_counter=b"1000") then
            i2c_data_ena <= '0';
        end if;
    end if;
if (i2c_bit_counter = 0) then i2c_data_strobe <='0';
    elsif (i2c_scl_b'event and i2c_scl_b='0') then
        if (i2c_bit_counter=b"1000" and i2c_data_ena = '0') then
            data_from_mcu(7 downto 0) <= i2c_data_buffer(7 downto 0);
            i2c_data_strobe <='1';
        end if; 
end if;
end process;         

process (i2c_scl_b)
begin
if(i2c_scl_b'event and i2c_scl_b='1') then i2cdstr <= i2c_data_strobe;
end if;
end process;

process (i2c_scl_b, i2c_bit_counter)
begin
if (i2c_scl_b'event and i2c_scl_b = '1') then
    if (i2c_bit_counter = b"0111") then i2c_out_data_strobe <= '1';
    else i2c_out_data_strobe <= '0'; end if;
end if;
end process;

process (i2c_scl_b, i2c_bit_counter)
begin
if (i2c_scl_b'event and i2c_scl_b='0') then
    if (i2c_bit_counter=b"1000") then i2c_in_data_strobe <='1';
    else i2c_in_data_strobe <='0'; end if;
end if;
end process;

process (i2c_scl_b, i2c_start_condition, i2c_to_master, i2c_bit_counter, i2c_ena_to_m)
begin
if (i2c_start_condition = '0' or i2c_to_master = '1') then i2c_ena_to_m <= '1';
    elsif (i2c_scl_b'event and i2c_scl_b='1') then
        if (i2c_bit_counter = b"1000") then
            i2c_ena_to_m <= '0';
        end if;
end if;
    
if(i2c_start_condition = '0') then i2c_to_m_flag <= '1'; 
    elsif (i2c_scl_b'event and i2c_scl_b = '1') then
        if (i2c_bit_counter = b"1000" and i2c_to_m_flag = '1') then
            i2c_to_m_flag <= '0';
        end if;
end if;

if(i2c_start_condition = '0') then i2c_to_master <= '1';
    elsif (i2c_scl_b'event and i2c_scl_b = '1') then 
        if (i2c_bit_counter = b"0111" and i2c_to_m_flag='1' and i2c_sda_b = '1') then i2c_to_master <= '0'; end if;
        if (i2c_bit_counter = b"1000" and i2c_sda_b = '1') then i2c_to_master <= '1'; end if; -- mcu returned nack
end if;

if (i2c_start_condition = '0' or i2c_to_master = '1') then i2c_mode <= '1'; 
    elsif (i2c_scl_b'event and i2c_scl_b='0') then
        if (i2c_ena_to_m = '0') then i2c_mode <= i2c_to_master; 
        end if;
end if; 

if (i2c_scl_b'event and i2c_scl_b='0') then
    if (i2c_bit_counter = b"1000") then i2c_out_data(7 downto 0) <= data_from_fpga(7 downto 0); end if;
    if ((i2c_bit_counter > 0) and (i2c_bit_counter < 8)) then i2c_out_data(7 downto 1) <= i2c_out_data(6 downto 0); end if;
end if;
end process;

process (i2c_scl_b, i2c_bit_counter, i2c_mode, i2c_ena_to_m)
begin
if (i2c_scl_b'event and i2c_scl_b='0') then
    if (i2c_mode ='1' and i2c_bit_counter=b"1000") then i2c_ack <= '0'; else i2c_ack <='1'; end if;
    if (i2c_ena_to_m = '0' and not(i2c_bit_counter = b"1000")) then i2c_out_ena <='0'; else i2c_out_ena <='1'; end if;
end if;
end process;

i2c_sda <= '0' when (i2c_ack = '0')
else i2c_out_data(7) when (i2c_out_ena = '0')
else 'Z';

cmos_flags(7 downto 0) <= (year_flag & month_flag & days_flag & week_flag & hours_flag & minutes_flag & seconds_flag & cmos_nado);
betadisk_flags(11 downto 0) <= (track_flag & force_interrupt_flag & vg93_intrq & vg93_drq & restore_flag & seek_flag & step_flag & step_direction & read_addr_flag & read_flag & write_flag & sector_flag);

process (i2c_scl_b, i2c_command_buffer, i2c_bit_counter, cmos_flags, betadisk_transfer, 
			betadisk_reg, status_reg, sector_reg, track_reg, track_position, vg93_O_data, betadisk_flags,
			read_byte_number, read_sector_num, write_byte_number, write_sector_num, cpu_a, 
			 cmos_download_counter, cmos_download_buffer)
begin
	if (i2c_scl_b'event and i2c_scl_b = '0') then
		if (i2c_bit_counter = b"0111") then
			if(i2c_command_buffer = 9) then data_from_fpga(7 downto 0) <= cmos_flags(7 downto 0); end if;
			
			if (betadisk_transfer = '0') then
				case betadisk_transmit_counter(5 downto 0) is
					when b"000000" => data_from_fpga(7 downto 0) <= betadisk_reg(7 downto 0);
					when b"000001" => data_from_fpga(7 downto 0) <= status_reg(7 downto 0);
					when b"000010" => data_from_fpga(7 downto 0) <= sector_reg(7 downto 0); 
					when b"000011" => data_from_fpga(7 downto 0) <= cmos_flags(7 downto 0);
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
--					when b"001110" => data_from_fpga(7 downto 0) <= breakpoints_status(7 downto 0);
					when b"001111" => data_from_fpga(7 downto 0) <= cmos_download_counter(5 downto 0) & b"00";
					when b"010000" => data_from_fpga(7 downto 0) <= cmos_download_buffer(7 downto 0);
					when others => null;
				end case;
				
			end if;
		end if;	
	end if;
end process;

---------------------------------------------------------------------------------------------------
-- cmos -------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- from mcu to fpga
process (pixel_clock, i2c_in_data_strobe, hardware_reset, fromfpga2cmos, fromcmos2fpga, i2c_data_buffer)
begin
if (hardware_reset = '0' or fromcmos2fpga = '1') then cmos_upload <= '1';
	elsif (i2c_in_data_strobe = '0') then i2c_dataonetime <= '0';
		elsif(pixel_clock'event and pixel_clock = '1') then
			if (i2c_dataonetime = '0' and i2c_in_data_strobe = '1') then			
				i2c_dataonetime <= '1';
				if (i2c_command_buffer = 11) then cmos_upload_counter(8 downto 0) <= b"111111110"; end if; -- from mcu
					if (i2c_command_buffer = 12) then
						if (not(cmos_upload_counter(8 downto 0) = b"000111111"))
							then cmos_upload_counter(8 downto 0) <= cmos_upload_counter(8 downto 0) + '1'; cmos_upload <= '0';
						end if;
					end if;
			end if;
end if;
end process;

-- from fpga to mcu
process (pixel_clock, i2c_out_data_strobe, hardware_reset, betadisk_transmit_counter, betadisk_transfer, fromfpga2cmos, fromcmos2fpga)
begin
if (hardware_reset = '0') then cmos_download <= '1'; cmos_download_counter(5 downto 0) <= b"111111"; 
	elsif (fromfpga2cmos = '1') then cmos_download <= '1';
		elsif (i2c_out_data_strobe = '0') then i2c_mcudataonetime <= '0';
			elsif (pixel_clock'event and pixel_clock = '1') then
				if (i2c_mcudataonetime = '0' and i2c_out_data_strobe = '1') then
					i2c_mcudataonetime <= '1';
					if(betadisk_transfer = '0') then
						if ((betadisk_transmit_counter(5 downto 0) = b"001110") and (cmos_download = '1')) then 
							cmos_download_counter(5 downto 0) <= cmos_download_counter(5 downto 0) + '1';
							cmos_download <= '0'; 
						end if;
					end if;
				end if;
end if;
end process;

process (hardware_reset, pixel_clock, cpu_iorq, cpu_rd, ebl, addr_bff7, cpu_iowr, cpu_res, fromfpga2cpu, fromcpu2fpga, cpu_d, dos)
begin
if(hardware_reset = '0' or fromfpga2cpu = '1' or fromcpu2fpga = '1') then cmos_cpuread <= '1'; cmos_cpuwrite <= '1';
	elsif(cpu_iorq = '1') then iorq_onetime <= '0';
		elsif (pixel_clock'event and pixel_clock = '1') then
			if (iorq_onetime = '0' and cpu_res = '1' and cpu_iorq = '0' and cpu_rd= '0' and ebl='1' and addr_bff7 = '0' and dos = '1')
				then iorq_onetime <= '1'; cmos_cpuread <= '0';
			end if;
			if (iorq_onetime = '0' and cpu_iowr='0' and cpu_res ='1' and ebl='1' and addr_bff7 = '0' and dos = '1')
				then iorq_onetime <= '1'; cmos_cpuwrite <= '0'; portbff7(7 downto 0) <= cpu_d(7 downto 0);
			end if;
end if;
end process;

cmos_mode(3 downto 0) <= cmos_upload & cmos_download & cmos_cpuread & cmos_cpuwrite;  
cmos_start1(3 downto 0) <= fromcmos2fpga & fromfpga2cmos & fromfpga2cpu & fromcpu2fpga;

process (pixel_clock, hardware_reset, cmos_mode, cmos_upload_counter, cmos_download_counter, cpu_write_strobe, betadisk_transmit_counter, cmos_data_buffer)
begin
    if(hardware_reset='0') then cmos_we <= '1'; cmos_start <= '0'; 
		elsif (pixel_clock'event and pixel_clock='0') then
			if(cmos_start1 = b"0000") then
            case cmos_mode(3 downto 0) is
                when b"0111" => -- from cmos to fpga buffer
                        cmos_addr(7 downto 0) <= b"00" & cmos_upload_counter(5 downto 0);
                        cmos_we <= '0'; 
                        cmos_data_in(7 downto 0) <= data_from_mcu(7 downto 0);             
			cmos_start <= '1';
			fromcmos2fpga <= '1';
                when b"1011" => -- from fpga buffer to cmos
                        cmos_addr(7 downto 0) <= b"00" & cmos_download_counter(5 downto 0);
                        cmos_we <= '1';                
			cmos_start <= '1';
			cmos_download_reset(1 downto 0) <= b"11";  
			fromfpga2cmos <= '1';							
                when b"1101" => -- to z80 from fpga buffer              
                        cmos_addr(7 downto 0) <= portdff7(7 downto 0);
                        cmos_we <= '1';
                        cmos_start <= '1';
			fromfpga2cpu <= '1';
                when b"1110" => -- from z80 to fpga buffer
                        cmos_addr(7 downto 0) <= portdff7(7 downto 0);
                        cmos_we <= '0';
                        cmos_data_in(7 downto 0) <= portbff7(7 downto 0);
                        cmos_start <= '1';
			fromcpu2fpga <= '1';
                when others => null;
            end case;
			end if;
            if (cmos_start = '1') then cmos_start <= '0'; cmos_we <= '1'; end if;
				if (fromcmos2fpga = '1' and cmos_clk = '0') then fromcmos2fpga <= '0'; end if;
				if (fromfpga2cmos = '1' and cmos_clk = '0') then fromfpga2cmos <= '0'; cmos_download_buffer(7 downto 0) <= cmos_data_out(7 downto 0); end if;
				if (fromfpga2cpu = '1' and cmos_clk = '0') then fromfpga2cpu <= '0'; cmos_cpu_buffer(7 downto 0) <= cmos_data_out(7 downto 0); end if;
				if (fromcpu2fpga = '1' and cmos_clk = '0') then fromcpu2fpga <= '0'; end if;
			   if (cmos_download_reset > 0) then cmos_download_reset(1 downto 0) <= cmos_download_reset(1 downto 0)-'1'; end if;
    end if;
    if (hardware_reset='0') then cmos_clk <= '0';
        elsif(pixel_clock'event and pixel_clock = '1') then
            if (cmos_start = '1') then cmos_clk <= '1';
                else cmos_clk <= '0'; 
            end if;
    end if;
end process;

process (command_from_mcu, cpu_clk, hardware_reset, cpu_iowr, ebl, addr_bff7, porteff7)
begin
if(hardware_reset='0' or command_from_mcu = 10) then cmos_nado <= '0';
	elsif (cpu_clk'event and cpu_clk='0') then
		if(cpu_iowr='0' and ebl='1') then
			if (addr_bff7='0' and porteff7(7) = '1') then cmos_nado <= '1'; end if;
		end if;
end if;
end process;                     

process (cmos_cpuwrite, command_from_mcu, portdff7) 
begin   
    if (command_from_mcu = 10) then seconds_flag <= '0';
                                    minutes_flag <= '0';
                                    hours_flag <= '0';
                                    week_flag <= '0';
                                    days_flag <= '0';
                                    month_flag <= '0';
                                    year_flag <= '0';
        elsif (cmos_cpuwrite'event and cmos_cpuwrite = '0') then
            if (portdff7(7 downto 4) = b"0000") then
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
end process;

process (i2c_strobe, i2c_command_buffer)
begin
    if (i2c_strobe'event and i2c_strobe='1') then
        command_from_mcu(6 downto 0) <= i2c_command_buffer(6 downto 0);
		  
		  if (i2c_command_buffer = 0) then idle <= '0'; betadisk_transfer <= '1'; else idle <= '1'; end if;
		  if (i2c_command_buffer = 1) then hardware_reset <= '0'; else hardware_reset <= '1'; end if;
        if (i2c_command_buffer = 2) then cmd02 <= '0'; else cmd02 <= '1'; end if;   
		  if (i2c_command_buffer = 3) then upload <= '0'; else upload <= '1'; end if;
        if (i2c_command_buffer = 4) then download <= '0'; else download <= '1'; end if;
        if (i2c_command_buffer = 5) then cmd05 <= '0'; else cmd05 <= '1'; end if;
		  if (i2c_command_buffer = 6) then pagenum <= '0'; else pagenum <= '1'; end if;
		  if (i2c_command_buffer = 7) then cmd07 <= '0'; else cmd07 <= '1'; end if;
		  if (i2c_command_buffer = 8) then spi_cmd <= '0'; else spi_cmd <= '1'; end if;   
		  if (i2c_command_buffer = 17) then betadisk_transfer <= '0'; end if;
		  if (i2c_command_buffer = 29) then svetodiod_on <= '0'; else svetodiod_on <= '1'; end if;
        if (i2c_command_buffer = 30) then svetodiod_off <= '0'; else svetodiod_off <= '1'; end if;
        
    end if;
end process;

-------------------------------------------------
-- spi sd-card

process (hardware_reset, spi_cmd, z80_to_ram)
begin
    if (hardware_reset = '0' or z80_to_ram = '1') then spi_enable <= '1';
        elsif (spi_cmd'event and spi_cmd = '1') then spi_enable <= '0';
    end if;
end process;

process (cpu_clk, dos, ebl, cpu_a, iorq_after_bus, cpu_wr, cpu_m1)
begin
-- for Savelij
if (cpu_clk'event and cpu_clk = '1') then 
    if (
    -- dos = '1' and
    cpu_a(7 downto 0) = x"57"
    and ebl = '1'
    and iorq_after_bus='0' and cpu_wr ='1' and cpu_m1='1')
        then port57rd <='0';
        else port57rd <='1';
    end if;
    if (((dos = '1' and cpu_a(7 downto 0) = x"57") or (dos = '0' and cpu_a(7 downto 0) = x"57" and cpu_a(15) = '0'))
    and ebl = '1'
    and iorq_after_bus='0' and cpu_wr ='0' and cpu_m1='1')
        then port57wr <='0';
        else port57wr <='1';
    end if;
end if;
end process;
sd_clock <= precounter(2);
sd_sync <= port57wr and port57rd;

process (sd_clock, port57wr, port57rd, sd_writeflag, sd_readflag, sd_counter, port57buffer)
begin
    if (port57wr = '0') then spi_we_data(7 downto 0) <= port57buffer(7 downto 0);  sd_counter <= (others => '0');
                            sd_ena0 <= '0'; sd_writeflag <= '1';  
        elsif (port57rd = '0') then sd_counter <= (others => '0');
                            sd_ena0 <= '0'; sd_readflag <= '1';  
        elsif (sd_clock'event and sd_clock = '1') then
              if ((sd_writeflag = '1' or sd_readflag = '1') and sd_counter < 8) then
                   sd_ena0 <= '1'; sd_counter <= sd_counter + '1'; spi_rd_data(7 downto 1) <= spi_rd_data(6 downto 0); spi_rd_data(0) <= sd_datain;
              end if;
        elsif (sd_clock'event and sd_clock = '0') then
  				  if (sd_writeflag = '1' and sd_counter > 0 and sd_counter < 8) then spi_we_data(7 downto 1) <= spi_we_data(6 downto 0); end if;
              if (sd_counter = 8) then sd_writeflag <= '0'; sd_readflag <= '0'; sd_stop <='0'; end if;
              if (sd_stop = '0') then sd_stop <= '1'; end if;
    end if;
end process;

process (sd_clock, sd_sync, sd_counter)
begin
    if(sd_sync = '0') then sd_ena1 <= '1';
        elsif (sd_clock'event and sd_clock = '0' and sd_counter = 8) then sd_ena1 <= '0';
    end if;
end process;
sd_clk <= (sd_ena0 and sd_ena1 and sd_clock) when (spi_enable = '0') else 'Z';
sd_dataout <= spi_we_data(7) when (spi_enable = '0') else 'Z';
sd_cs <= sd_config(1) when (spi_enable = '0') else 'Z';

sd_active_flag <= sd_writeflag or sd_readflag;

------------------------------------------------------------
process (i2c_data_strobe, i2c_start_condition)
begin
    if (i2c_start_condition = '0') then upload_adr <= (others => '1');
        elsif (i2c_data_strobe'event and i2c_data_strobe = '1') then
              if (not(upload_adr = 16384)) then upload_adr <= upload_adr + '1'; end if;
    end if;
end process;

process (upload, hardware_reset, upload_adr, weblk)
begin
    if ((hardware_reset = '0') or (upload_adr = 16383 and weblk='0')) then upload_in_process <= '1';
        elsif (upload'event and upload = '1') then upload_in_process <= '0'; -- active low
    end if;
end process;

process (i2cdstr, ena, upload_in_process)
begin
    if (ena='0') then ena_st <= '0';
        elsif (i2cdstr'event and i2cdstr='1') then
              if (upload_in_process = '0') then ena_st <='1'; end if;
    end if;
end process;

weblk <= weblk0chp0 and weblk0chp1 and weblk1chp0 and weblk1chp1;

process (weblk, ena_st)
begin
    if (ena_st='1') then ena <= '0';
        elsif (weblk'event and weblk ='1') then
              if (ena='0') then ena <= '1'; end if;
    end if;
end process;
process (pixel_clock)
begin
    if (pixel_clock'event and pixel_clock='0') then ena_f <= ena;
end if;
end process;

---------------------------------------------------------
-- ext_ram

-- memory mapper
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

-- address bus
z80_full_adr(13 downto 0) <= cpu_a(13 downto 0);
z80_full_adr(20 downto 14) <= rampage(6 downto 0);
  
process (pixel_clock, upload_in_process, download_in_process, page_number, upload_adr, download_adr)
begin  
	if (pixel_clock'event and pixel_clock='0') then
		if (upload_in_process ='0') then
			mcu_full_adr(20 downto 0) <= page_number(6 downto 0) & upload_adr(13 downto 0);
		end if;
		if (download_in_process ='0') then
			mcu_full_adr(20 downto 0) <= page_number(6 downto 0) & download_adr(13 downto 0);
		end if;
		
		case gfx_mode(5 downto 0) is
			when b"011000" => video_full_adr(20 downto 0) <= (b"00001" & port7ffd(3) & b"10" & video_address(12 downto 0)); -- standard zx screen
			when b"011001" => video_full_adr(20 downto 0) <= (b"00001" & port7ffd(3) & alco_address(14 downto 0)); -- pentagon-1024 16 colour
			when b"000000" => video_full_adr(20 downto 0) <= (b"0000" & alco_address(14) & port7ffd(3) & '1' & alco_address(13) & ega_address(12 downto 0)); -- ega
			when b"010000" => video_full_adr(20 downto 0) <= (b"0000" & alco_address(14) & port7ffd(3) & '1' & alco_address(13) & ega_address(12 downto 0)); -- mc 640x200
			when b"110000" => video_full_adr(20 downto 0) <= (b"0000" & otmtxt_addr(16) & port7ffd(3) & '1' & otmtxt_addr(13 downto 0)); -- otm textmode
			when others => null;
		end case;
	end if;
end process;
	 
betadisk_full_adr(20 downto 0) <= '1' & vg93_ram_addr(19 downto 0);
        
full_adr(20 downto 0) <= z80_full_adr(20 downto 0) when (z80_to_ram ='0' and vg93_transaction = '1')
    else betadisk_full_adr(20 downto 0) when (z80_to_ram ='0' and vg93_transaction = '0')
    else mcu_full_adr(20 downto 0) when (z80_to_ram ='1');

ram_outdata(7 downto 0) <= cpu_d(7 downto 0) when (z80_to_ram ='0' and vg93_transaction = '1')
    else vg93_data_for_ram(7 downto 0) when (z80_to_ram ='0' and vg93_transaction = '0')
    else data_from_mcu(7 downto 0) when (z80_to_ram ='1');

process (pixel_clock, main_state_counter)
begin
	if (pixel_clock'event and pixel_clock = '1') then
		if (main_state_counter(1 downto 0) = b"11") then
			radr(18 downto 0) <= video_full_adr(18 downto 0); 
			blk0_d(7 downto 0) <= (others => 'Z');
			blk1_d(7 downto 0) <= (others => 'Z');
		end if;
		
		if (main_state_counter(1 downto 0) = b"01" or main_state_counter(1 downto 0) = b"10") then
			radr(18 downto 0) <= full_adr(18 downto 0); 
			if ((z80_to_ram ='0' and cpu_memwr = '0') or (z80_to_ram ='1' and upload_in_process = '0') or (z80_to_ram ='0' and vg93_transaction = '0' and write_flag = '0' )) then -- åñëè â ïàìÿòü ïèøóò

--              if(full_adr(20) = '0') then
                    blk0_d(7 downto 0) <= ram_outdata(7 downto 0);
--                  else
                    blk1_d(7 downto 0) <= ram_outdata(7 downto 0);
--              end if;         
			end if;
		end if;
	end if;
end process;

-- ext ram oe/we
process (cpu_memwr, cpu_we_enable_res)
begin
if(cpu_we_enable_res='0') then cpu_we_enable <= '1';
    elsif(cpu_memwr'event and cpu_memwr = '0') then cpu_we_enable <= '0';
end if;
end process;

process (weblk, cpu_memwr, cpu_we_enable)
begin
if (cpu_memwr = '1') then cpu_we_enable_res <= '1';
    elsif (weblk'event and weblk = '1') then
        if(cpu_we_enable = '0') then cpu_we_enable_res <= '0';
        end if;
end if;
end process;
	
process (pixel_clock, main_state_counter, we_enable, full_adr, z80_to_ram, cpu_memrd, download_in_process, page_number, vg93_transaction, vg_tormoz, read_flag, ena_f, cpu_memwr, rampage, write_flag)
begin
if (pixel_clock'event and pixel_clock='1') then
    if ((main_state_counter(1 downto 0) = b"01" or main_state_counter(1 downto 0) = b"10") and (   (z80_to_ram = '1' and ena_f = '0') or (z80_to_ram = '0' and ((cpu_memwr = '0' and vg93_transaction = '1' and not((rampage(6 downto 2)=b"10010") or rampage(6 downto 0)=b"1001100"))  or    (vg93_transaction = '0' and write_flag = '0' and vg_tormoz = '1') ))  ) ) --we_enable ='0')
        then
            case full_adr(20 downto 19) is
                when b"00" => weblk0chp0 <= '0';
                when b"01" => weblk0chp1 <= '0';
                when b"10" => weblk1chp0 <= '0';
                when b"11" => weblk1chp1 <= '0';
                when others => null;
            end case;
        elsif (main_state_counter(1 downto 0) = b"11") then
                weblk0chp0 <= '1';
                weblk0chp1 <= '1';
                weblk1chp0 <= '1';
                weblk1chp1 <= '1';
    end if;

    if(((main_state_counter(1 downto 0) = b"01" or main_state_counter(1 downto 0) = b"10") and z80_to_ram ='0' and cpu_memrd='0') or (z80_to_ram ='1' and download_in_process = '0') or (z80_to_ram ='0' and vg93_transaction = '0' and read_flag = '0' and vg_tormoz = '1'))
            then
                case full_adr(20 downto 19) is
                    when b"00" => oeblk0chp0 <= '0'; oeblk0chp1 <= '1'; oeblk1chp0 <= '1'; oeblk1chp1 <= '1'; ram_blk <= '0';
                    when b"01" => oeblk0chp0 <= '1'; oeblk0chp1 <= '0'; oeblk1chp0 <= '1'; oeblk1chp1 <= '1'; ram_blk <= '0';
                    when b"10" => oeblk0chp0 <= '1'; oeblk0chp1 <= '1'; oeblk1chp0 <= '0'; oeblk1chp1 <= '1'; ram_blk <= '1';
                    when b"11" => oeblk0chp0 <= '1'; oeblk0chp1 <= '1'; oeblk1chp0 <= '1'; oeblk1chp1 <= '0'; ram_blk <= '1';
                    when others => null;
                end case;
        elsif(main_state_counter(1 downto 0) = b"11" or main_state_counter(1 downto 0) = b"00")
            then
                case video_full_adr(20 downto 19) is
                    when b"00" => oeblk0chp0 <= '0'; oeblk0chp1 <= '1'; oeblk1chp0 <= '1'; oeblk1chp1 <= '1'; 
                    when b"01" => oeblk0chp0 <= '1'; oeblk0chp1 <= '0'; oeblk1chp0 <= '1'; oeblk1chp1 <= '1'; 
                    when b"10" => oeblk0chp0 <= '1'; oeblk0chp1 <= '1'; oeblk1chp0 <= '0'; oeblk1chp1 <= '1'; 
                    when b"11" => oeblk0chp0 <= '1'; oeblk0chp1 <= '1'; oeblk1chp0 <= '1'; oeblk1chp1 <= '0'; 
                    when others => null;
                end case;
        else        oeblk0chp0 <= '1';
                    oeblk0chp1 <= '1';
                    oeblk1chp0 <= '1';
                    oeblk1chp1 <= '1';
    end if; 
end if;     
end process;

process (pixel_clock, main_state_counter, vg93_transaction, read_flag, ram_blk)
begin
if (pixel_clock'event and pixel_clock='0') then 
	if (main_state_counter=b"00") then
		if (ram_blk = '0')
			then to_vz80_data(7 downto 0) <= blk0_d(7 downto 0);
			else to_vz80_data(7 downto 0) <= blk1_d(7 downto 0);
		end if;
	end if;
end if;

if (pixel_clock'event and pixel_clock='1') then 
	if (main_state_counter=b"00") then
		if (vg93_transaction = '0' and read_flag = '0') then vg93_data_from_ram(7 downto 0) <= to_vz80_data(7 downto 0); end if;
	end if;
end if;
end process;

process (i2c_data_strobe, download, upload_adr)
begin
    if (download='0') then download_adr <= (others => '0');
        elsif (i2c_data_strobe'event and i2c_data_strobe = '1') then
              if (not(upload_adr = 16384)) then download_adr <= download_adr + '1'; end if;
    end if;
end process;

process (download, download_adr, hardware_reset)
begin
    if ((hardware_reset = '0') or (download_adr = 16383)) then download_in_process <= '1';
        elsif (download'event and download = '1') then download_in_process <= '0'; -- active low
    end if;
end process;

process (pixel_clock, main_state_counter)
begin
    if (pixel_clock'event and pixel_clock = '0') then
        if (main_state_counter = b"11") then download_strobe <= '1';
        else download_strobe <= '0';
        end if;
    end if;
end process;

process (download_strobe, ram_blk)
begin
    if (download_strobe'event and download_strobe ='1') then
            if (ram_blk = '0')
            then mcu_in_data(7 downto 0) <= blk0_d(7 downto 0);
            else mcu_in_data(7 downto 0) <= blk1_d(7 downto 0);
            end if;
    end if;
end process;

process (pagenum, hardware_reset)
begin
    if (hardware_reset = '0') then page_number <= (others => '1');
        elsif (pagenum'event and pagenum = '1') then
        page_number(7 downto 0) <= data_from_mcu(7 downto 0);
    end if;
end process;

process (cmd07, hardware_reset)
begin
    if (hardware_reset = '0') then z80_to_ram <= '1';
        elsif (cmd07'event and cmd07 = '1') then z80_to_ram <='0';
    end if;
end process;

process (pixel_clock, cmd05, hardware_reset)
begin
    if (hardware_reset = '0') then z80_reset_from_mcu <= '0';
        elsif (pixel_clock'event and pixel_clock='0') then
              if (cmd05 = '0') then z80_reset_from_mcu <= '1'; end if;
    end if;
end process;

cpu_res <= z80_reset_from_mcu and fpga_res_input;

------------------------------------------------------------------------
--  data transfer from mcu to fpga registers

process (i2c_data_strobe, cmd02)--, textbuffer_we)
begin
if (cmd02 = '1') then key_byte_number <= (others => '0');
		elsif (i2c_data_strobe'event and i2c_data_strobe = '1') then
			if (key_byte_number < key_byte_number_max) then key_byte_number <= key_byte_number + '1';
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
end process;
   
pll_config: pll1 port map (clk,pixel_clock, shifted_clock);

cpu: T80a port map (cpu_res, cpu_clk, cpu_wait, cpu_int, cpu_nmi,
    cpu_busrq, cpu_m1, cpu_mreq, cpu_iorq, cpu_rd, cpu_wr,
    cpu_rfsh, cpu_halt, cpu_busack, cpu_a, cpu_d, iocycle, memcycle); 

cmos: ram_cmos port map (cmos_clk, cmos_data_in(7 downto 0), cmos_addr(7 downto 0), cmos_addr(7 downto 0), cmos_we, cmos_data_out(7 downto 0));

video_main: zx_main port map (pixel_clock, ym_clk, main_state_counter, blk0_d,
    portfe(3 downto 0), gfx_mode, int_strobe, int_delay, ssii, ksii,
    vidr, vidg, vidb, pixel_c, line_c, counter(23), video_address, alco_address,
    pollitra_a, pollitra_awr, pollitra_data_out, border3, ega_address, otmtxt_addr);

pollitra: ram_pollitra port map (pixel_clock, pollitra_data_in, pollitra_rdaddress,
    pollitra_wraddress, pollitra_flag0, pollitra_data_out);

bdi_emul: betadisk port map (vg93_cs, vg93_ram_addr,
    betadisk_transfer, write_byte_number, write_sector_num,
    read_sector_num, read_byte_number, track_flag, sector_flag, restore_flag, vg93_O_data,
    force_interrupt_flag, track_position, track_reg, sector_reg, status_reg,
    betadisk_reg, vg93_intrq, seek_flag, vg93_drq, step_flag, step_direction,
    read_addr_flag, read_flag, write_flag, vg93_data_from_ram,
    vg_tormoz, read_trz, write_trz, cpu_rd, cpu_wr, cpu_a,
    cpu_d, pixel_clock, hardware_reset, vg93_data_for_cpu, vg93_data_for_ram, index);
   
---------------------------------------------------------------------------
---------------------------------------------------------------------------

process (cpu_mreq, cpu_wr)
begin
if(cpu_mreq = '1') then cpu_memwr <='1';
elsif(cpu_wr'event and cpu_wr='0') then
    cpu_memwr <= cpu_mreq;
end if;
end process;

cpu_memrd <= cpu_mreq or cpu_rd;
cpu_iowr <= iorq_after_bus or cpu_wr;
cpu_iord <= iorq_after_bus or cpu_rd;

romadr14 <= fpga_rs_in;

ssi <= ssii;
ksi <= ksii;

 vid_r(4 downto 0) <= vidr(4 downto 0);
 vid_g(4 downto 0) <= vidg(4 downto 0);
 vid_b(4 downto 0) <= vidb(4 downto 0);

rom_page(0) <= port7ffd(4);
rom_page(1) <= dos;
rom <= cpu_a(14) or cpu_a(15);    -- 0 => ROM, 1 => RAM
ram_from_c000 <= cpu_a(14) and cpu_a(15);

------------------------------------------------------------------------------
-- dos trigger (4 rom switching)
process (cpu_iorq, cpm, portbf)
begin
if (cpu_iorq'event and cpu_iorq='1') then
   dos_1 <= cpm and (not(portbf(0))); --Savelij
end if; 
end process;

m1 <= cpu_mreq or cpu_m1 or cpu_rd;

process (cpu_res, m1, cpu_a, port7ffd, cpm, portbf)
begin
if (cpu_res = '0') then dosen <= '0';
elsif (m1'event and m1='0') then
    if (cpu_a(8)='1' and cpu_a(9)='0' and cpu_a(13 downto 10) = b"1111" and cpu_a(15 downto 14)=b"00" and port7ffd(4)='1')
    then dosen <= '0'; end if;
    if (not(cpu_a(15 downto 14)=b"00") )
    then dosen <= '1'; end if;
end if;
end process;

process (pixel_clock, dosen, dos_1)
begin
if (pixel_clock'event and pixel_clock='0') then
  dos <=dosen and dos_1;
end if; 
end process;

---------------------------------------------------------------------------------------
-- ports WR
process (cpu_clk, cpu_res, iorq_after_bus, cpu_iowr, cmos_download_reset, cpu_m1, ebl, cpu_a, porteff7, port7ffd, addr_bff7, portdff7, dos)
begin
    if (cpu_res ='0') then port7ffd(7 downto 0) <= (others => '0');
                                porteff7(7 downto 0) <= (others => '0');
                                portdff7(7 downto 0) <= (others => '0');
                                port7ffdadd(7 downto 0) <= (others => '0');
                                ---ATM
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
										  wr_ports_single <= '0';
        elsif (iorq_after_bus = '1') then  pollitra_strobe <= '0'; vg93_cs<='1'; wr_ports_single <= '0';
            
                elsif (cpu_clk'event and cpu_clk='0') then
                    if(cpu_iowr='0' and ebl='1') then
								wr_ports_single <= '1';
                        -- port fe:
                        if (cpu_a(0)='0') then portfe(7 downto 0) <= cpu_d(7 downto 0); border3 <= not(cpu_a(3)); end if;
                        -- port 7ffd (system control 0):
                        if (cpu_a(15)='0' and cpu_a(1)='0') then
                            if (porteff7(2)='0' or (porteff7(2)='1' and dos = '0')) then port7ffd(7 downto 0) <= cpu_d(7 downto 0);
                                else if (port7ffd(5)= '0') then port7ffd(5 downto 0) <= cpu_d(5 downto 0); end if;
                            end if;                        
                        end if;
                        -- port eff7 (system control 1):
                        if (cpu_a(3)='0' and cpu_a(5)='1' and cpu_a(12)='0' and cpu_a(15 downto 13) = b"111" and cpu_a(0)='1') then porteff7(7 downto 0) <= cpu_d(7 downto 0); end if;
                        -- port dff7 (cmos)
                        if (cpu_a(15 downto 0) = x"DFF7" and porteff7(7) = '1') then portdff7(7 downto 0) <= cpu_d(7 downto 0); end if;
                        -- sd-card SPI interface (for Savelij):
                        if (
                            ((cpu_a(7 downto 0) = x"57") and (dos = '1'))
                            or((cpu_a(7 downto 0) = x"57") and (dos = '0') and (cpu_a(15) = '0'))
                        )
                            then port57buffer(7 downto 0) <= cpu_d(7 downto 0); end if;
                        if (
                            ((cpu_a(7 downto 0) = x"77") and (dos = '1') and wr_ports_single = '1')
                            or((cpu_a(7 downto 0) = x"57") and (dos = '0') and (cpu_a(15) = '1'))
                        )
                            then sd_config(7 downto 0) <= cpu_d(7 downto 0); end if;
                        -- port xxFF
                        if ((cpu_a(7 downto 0) = x"ff") and ((dos = '1') or (pen2 = '0')) and porteff7(2)='0') then pollitra_strobe <= '1'; end if;
                        --ATM
                        if ((cpu_a(7 downto 0) = x"77") and (dos = '0') and wr_ports_single = '1') then
                            portxx77(7 downto 0) <= cpu_d(7 downto 0);
                            cpm <= cpu_a(9);
                            pen2 <= cpu_a(14);
                        end if;
                        --Savelij
                        if (cpu_a(7 downto 0) = x"bf") then
                            --cpm <= not(cpu_d(0));
                            portbf(0) <= cpu_d(0);
                        end if;
                    end if;
                    if(dos='0') then
                        if (cpu_a(0)='1' and cpu_a(1)='1' and cpu_a(7)='0' and cpu_iorq='0' and cpu_m1='1') then vg93_cs<='0'; end if;
                        if (cpu_a(0)='1' and cpu_a(1)='1' and cpu_a(7)='1' and cpu_iowr='0' and cpu_m1='1') then betadisk_reg(7 downto 0) <= cpu_d(7 downto 0); end if;
                            
                        if(cpu_a = x"fff7") then
                            if(port7ffd(4)='0') then cpu3_0(9 downto 0) <= b"11" & cpu_d(7 downto 0);
                                else cpu3_1(9 downto 0) <= b"11" & cpu_d(7 downto 0);
                            end if;
                        end if;
                        if(cpu_a = x"bff7") then
                            if(port7ffd(4)='0') then cpu2_0(9 downto 0) <= b"11" & cpu_d(7 downto 0);
                                else cpu2_1(9 downto 0) <= b"11" & cpu_d(7 downto 0);
                            end if;
                        end if;
                        if(cpu_a = x"7ff7") then
                            if(port7ffd(4)='0') then cpu1_0(9 downto 0) <= b"11" & cpu_d(7 downto 0);
                                else cpu1_1(9 downto 0) <= b"11" & cpu_d(7 downto 0);
                            end if;
                        end if;
                        if(cpu_a = x"3ff7") then
                            if(port7ffd(4)='0') then cpu0_0(9 downto 0) <= b"11" & cpu_d(7 downto 0);
                                else cpu0_1(9 downto 0) <= b"11" & cpu_d(7 downto 0);
                            end if;
                        end if;
                        if(cpu_a = x"f7f7") then 
                            if(port7ffd(4)='0') then cpu3_0(9 downto 0) <= cpu_d(7 downto 6) & b"01" & cpu_d(5 downto 0);
                                else cpu3_1(9 downto 0) <= cpu_d(7 downto 6) & b"01" & cpu_d(5 downto 0);
                            end if;
                        end if;
                        if(cpu_a = x"b7f7") then 
                            if(port7ffd(4)='0') then cpu2_0(9 downto 0) <= cpu_d(7 downto 6) & b"01" & cpu_d(5 downto 0);
                                else cpu2_1(9 downto 0) <= cpu_d(7 downto 6) & b"01" & cpu_d(5 downto 0);
                            end if;
                        end if;
                        if(cpu_a = x"77f7") then 
                            if(port7ffd(4)='0') then cpu1_0(9 downto 0) <= cpu_d(7 downto 6) & b"01" & cpu_d(5 downto 0);
                                else cpu1_1(9 downto 0) <= cpu_d(7 downto 6) & b"01" & cpu_d(5 downto 0);
                            end if;
                        end if;
                        if(cpu_a = x"37f7") then 
                            if(port7ffd(4)='0') then cpu0_0(9 downto 0) <= cpu_d(7 downto 6) & b"01" & cpu_d(5 downto 0);
                                else cpu0_1(9 downto 0) <= cpu_d(7 downto 6) & b"01" & cpu_d(5 downto 0);
                            end if;
                        end if;
                        
                    end if;
                end if;
                            
end process;                                    

romram <= porteff7(3);

process (pixel_clock, pollitra_strobe, pollitra_flag1)
begin
if(pollitra_strobe = '0') then pollitra_flag1 <= '0'; 
    elsif(pixel_clock'event and pixel_clock = '0') then
        if (pollitra_flag0 = '1') then pollitra_flag1 <= '1'; end if;
end if;

if(pollitra_flag1 = '1') then pollitra_flag0 <= '0'; 
    elsif(pixel_clock'event and pixel_clock = '0') then
        if(pollitra_strobe = '1' and pollitra_flag0 = '0') then pollitra_flag0 <= '1'; end if;
end if;
end process;

pollitra_data_in(15 downto 0) <= cpu_a(15 downto 8) & cpu_d(7 downto 0);
pollitra_rdaddress(3 downto 0) <= pollitra_a(3 downto 0);
pollitra_wraddress(3 downto 0) <= pollitra_awr(3 downto 0);

gfx_mode(2 downto 0) <= b"000" when porteff7(0) = '0'
else b"001" when porteff7(0) = '1';

gfx_mode(5 downto 3) <= portxx77(2 downto 0);

beeper <= portfe(4);
tapeout <= portfe(3);

r_adr(18 downto 0) <= radr(18 downto 0);

klovetura(0) <= (keymatrix0(0) or cpu_a(8)) and (keymatrix0(1) or cpu_a(9)) and (keymatrix0(2) or cpu_a(10)) and (keymatrix0(3) or cpu_a(11)) and (keymatrix0(4) or cpu_a(12)) and (keymatrix0(5) or cpu_a(13)) and (keymatrix0(6) or cpu_a(14)) and(keymatrix0(7) or cpu_a(15));
klovetura(1) <= (keymatrix1(0) or cpu_a(8)) and (keymatrix1(1) or cpu_a(9)) and (keymatrix1(2) or cpu_a(10)) and (keymatrix1(3) or cpu_a(11)) and (keymatrix1(4) or cpu_a(12)) and (keymatrix1(5) or cpu_a(13)) and (keymatrix1(6) or cpu_a(14)) and(keymatrix1(7) or cpu_a(15));
klovetura(2) <= (keymatrix2(0) or cpu_a(8)) and (keymatrix2(1) or cpu_a(9)) and (keymatrix2(2) or cpu_a(10)) and (keymatrix2(3) or cpu_a(11)) and (keymatrix2(4) or cpu_a(12)) and (keymatrix2(5) or cpu_a(13)) and (keymatrix2(6) or cpu_a(14)) and(keymatrix2(7) or cpu_a(15));
klovetura(3) <= (keymatrix3(0) or cpu_a(8)) and (keymatrix3(1) or cpu_a(9)) and (keymatrix3(2) or cpu_a(10)) and (keymatrix3(3) or cpu_a(11)) and (keymatrix3(4) or cpu_a(12)) and (keymatrix3(5) or cpu_a(13)) and (keymatrix3(6) or cpu_a(14)) and(keymatrix3(7) or cpu_a(15));
klovetura(4) <= (keymatrix4(0) or cpu_a(8)) and (keymatrix4(1) or cpu_a(9)) and (keymatrix4(2) or cpu_a(10)) and (keymatrix4(3) or cpu_a(11)) and (keymatrix4(4) or cpu_a(12)) and (keymatrix4(5) or cpu_a(13)) and (keymatrix4(6) or cpu_a(14)) and(keymatrix4(7) or cpu_a(15));

klovetura(6) <= snd(0);

klovetura(7) <= '1';
klovetura(5) <= '1';

addr_bff7 <= '0' when cpu_a(15 downto 0) = 49143
else '1';
addr_dff7 <= '0' when cpu_a(15 downto 0) = 57335
else '1';
addr_eff7 <= '0' when cpu_a(15 downto 0) = 61431
else '1';

-------------------------------------------------------------------------------------------
-- cpu data bus
read_ports <= not(ebl) or cpu_iord;
read_fe <= read_ports or cpu_a(0);

cpu_d(7 downto 0) <= to_vz80_data(7 downto 0) when ((cpu_memrd='0' and rom='1') or (cpu_memrd='0' and rom='0' and fpga_rdrom_input='0'))
else klovetura(7 downto 0) when (read_ports='0' and cpu_a(0)='0')
else ym_do(7 downto 0) when (read_ports='0' and cpu_a(15 downto 13)=b"111" and cpu_a(1 downto 0)=b"01")
-- cmos: 
else x"AA" when (read_ports='0' and addr_bff7='0' and porteff7(7)='1' and portdff7(5 downto 0)=x"11")
else x"20" when (read_ports='0' and addr_bff7='0' and porteff7(7)='1' and portdff7(5 downto 0)=x"0A")
else x"02" when (read_ports='0' and addr_bff7='0' and porteff7(7)='1' and portdff7(5 downto 0)=x"0B")
else x"00" when (read_ports='0' and addr_bff7='0' and porteff7(7)='1' and portdff7(5 downto 0)=x"0C")
else x"80" when (read_ports='0' and addr_bff7='0' and porteff7(7)='1' and portdff7(5 downto 0)=x"0D")
else seconds(7 downto 0) when (read_ports='0' and porteff7(7)='1' and addr_bff7='0' and portdff7(7 downto 0)=0 and cmos_flags(7 downto 1) = 0)
else minutes(7 downto 0) when (read_ports='0' and porteff7(7)='1' and addr_bff7='0' and portdff7(7 downto 0)=2 and cmos_flags(7 downto 1) = 0)
else hours(7 downto 0) when (read_ports='0' and porteff7(7)='1' and addr_bff7='0' and portdff7(7 downto 0)=4 and cmos_flags(7 downto 1) = 0)
else days(7 downto 0) when (read_ports='0' and porteff7(7)='1' and addr_bff7='0' and portdff7(7 downto 0)=7 and cmos_flags(7 downto 1) = 0)
else week(7 downto 0) when (read_ports='0' and porteff7(7)='1' and addr_bff7='0' and portdff7(7 downto 0)=6 and cmos_flags(7 downto 1) = 0)
else month(7 downto 0) when (read_ports='0' and porteff7(7)='1' and addr_bff7='0' and portdff7(7 downto 0)=8 and cmos_flags(7 downto 1) = 0)
else year(7 downto 0) when (read_ports='0' and porteff7(7)='1' and addr_bff7='0' and portdff7(7 downto 0)=9 and cmos_flags(7 downto 1) = 0)
else cmos_cpu_buffer(7 downto 0) when (read_ports='0' and porteff7(7)='1' and addr_bff7='0' and not((portdff7(7 downto 0) > x"30") and (portdff7(7 downto 0) < x"35" )) ) --and portdff7(7 downto 0) > 13
-- ADC
else in_l(7 downto 0) when (read_ports='0' and porteff7(7)='1' and addr_bff7='0' and portdff7(7 downto 0) = x"31")
else "000000" & in_l(9 downto 8) when (read_ports='0' and porteff7(7)='1' and addr_bff7='0' and portdff7(7 downto 0) = x"32")
else in_r(7 downto 0) when (read_ports='0' and porteff7(7)='1' and addr_bff7='0' and portdff7(7 downto 0) = x"33")
else "000000" & in_r(9 downto 8) when (read_ports='0' and porteff7(7)='1' and addr_bff7='0' and portdff7(7 downto 0) = x"34")
-- memory config
else not(cpu0_0(7 downto 0)) when (read_ports='0' and cpu_a(15 downto 0)=x"00be")
else not(cpu1_0(7 downto 0)) when (read_ports='0' and cpu_a(15 downto 0)=x"01be")
else not(cpu2_0(7 downto 0)) when (read_ports='0' and cpu_a(15 downto 0)=x"02be")
else not(cpu3_0(7 downto 0)) when (read_ports='0' and cpu_a(15 downto 0)=x"03be")
else not(cpu0_1(7 downto 0)) when (read_ports='0' and cpu_a(15 downto 0)=x"04be")
else not(cpu1_1(7 downto 0)) when (read_ports='0' and cpu_a(15 downto 0)=x"05be")
else not(cpu2_1(7 downto 0)) when (read_ports='0' and cpu_a(15 downto 0)=x"06be")
else not(cpu3_1(7 downto 0)) when (read_ports='0' and cpu_a(15 downto 0)=x"07be")
else spi_rd_data(7 downto 0) when (read_ports='0' 
                            --and dos = '1' --Savelij
                            and cpu_a(7 downto 0) = x"57")--else ("00000000") when (read_ports='0' and dos = '1' and cpu_a(7 downto 0) = x"1f")
else ("000" & kempston(4 downto 0)) when (read_ports='0' and dos = '1' and cpu_a(7 downto 0) = x"1f")

-- betadisk
else (status_reg(7 downto 0)) when (dos = '0' and read_ports='0' and cpu_a(7 downto 5) = b"000")
else (track_reg(7 downto 0))  when (dos = '0' and read_ports='0' and cpu_a(7 downto 5) = b"001")
else (sector_reg(7 downto 0)) when (dos = '0' and read_ports='0' and cpu_a(7 downto 5) = b"010")
else (vg93_data_for_cpu(7 downto 0)) when (dos = '0' and read_ports='0' and cpu_a(7 downto 5) = b"011")
else (vg93_intrq & vg93_drq & b"111111") when (dos = '0' and read_ports='0' and cpu_a(7 downto 5) = b"111")
-- mouse
else mouse_x(7 downto 0) when (read_ports='0' and cpu_a(15 downto 0) = x"FBDF")
else mouse_y(7 downto 0) when (read_ports='0' and cpu_a(15 downto 0) = x"FFDF")
else mouse_b(7 downto 0) when (read_ports='0' and cpu_a(15 downto 0) = x"FADF")
-- ide
else (fpga_d(7 downto 0)) when ((ior = '0') or (rdh = '0') or (cpu_iorq='0' and cpu_rd='0') or (cpu_mreq='0' and cpu_rd='0' and rom='0' and fpga_rdrom_input='1'))
else (others =>'1') when (cpu_mreq='1' and cpu_m1='0' and cpu_iorq='0' and cpu_rd='1' and cpu_wr='1')
else (others =>'Z');
       
----------------------------------------------------------------------
-- ym2149 and turbosound
process (cpu_clk, cpu_iowr, cpu_m1, cpu_a, cpu_d, cpu_res)
begin
    if (cpu_res = '0') then ym_number <= '0'; ym0_wr_addr<='1'; ym0_wr_data<='1'; ym1_wr_addr<='1'; ym1_wr_data<='1';
        elsif (cpu_clk'event and cpu_clk ='0') then
            if (cpu_iowr='0' and cpu_m1='1') then
                if (cpu_a(15 downto 14)=b"11" and cpu_a(1 downto 0)=b"01") then
                    case cpu_d(7 downto 0) is
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
                if (cpu_a(15 downto 14)=b"10" and cpu_a(1 downto 0)=b"01") then
                    case ym_number is
                        when '0' => ym0_wr_data <='0';
                        when '1' => ym1_wr_data <='0';
								when others => null;
                    end case;
                end if;
            else ym0_wr_addr<='1'; ym0_wr_data<='1'; ym1_wr_addr<='1'; ym1_wr_data<='1';
            end if;
    end if;
end process;

ym0_rd_data <='0'   when (ym_number = '0' and cpu_iorq='0' and cpu_rd='0' and cpu_a(15 downto 14)=b"11" and cpu_a(1 downto 0)=b"01")
else '1';
ym1_rd_data <='0'   when (ym_number = '1' and cpu_iorq='0' and cpu_rd='0' and cpu_a(15 downto 14)=b"11" and cpu_a(1 downto 0)=b"01")
else '1';

ym2149_0: ym2149 port map (cpu_d(7 downto 0), ym0_do(7 downto 0), ym0_snd(7 downto 0), strobe0_a, strobe0_b, strobe0_c, cpu_res, ym_clk, ym0_wr_addr, ym0_wr_data, ym0_rd_data, ym0_state(1 downto 0));       
ym2149_1: ym2149 port map (cpu_d(7 downto 0), ym1_do(7 downto 0), ym1_snd(7 downto 0), strobe1_a, strobe1_b, strobe1_c, cpu_res, ym_clk, ym1_wr_addr, ym1_wr_data, ym1_rd_data, ym1_state(1 downto 0));       

ym_do(7 downto 0) <= ym0_do(7 downto 0) when ym_number = '0'
else ym1_do(7 downto 0);

process (strobe0_a, cpu_res)
begin
    if(cpu_res = '0') then ym0a(7 downto 0) <= (others => '0');
        elsif(strobe0_a'event and strobe0_a = '1') then ym0a(7 downto 0) <= ym0_snd(7 downto 0);
    end if;
end process;
process (strobe0_b, cpu_res)
begin
    if(cpu_res = '0') then ym0b(7 downto 0) <= (others => '0');
        elsif(strobe0_b'event and strobe0_b = '1') then ym0b(7 downto 0) <= ym0_snd(7 downto 0);
    end if;
end process;
process (strobe0_c, cpu_res)
begin
    if(cpu_res = '0') then ym0c(7 downto 0) <= (others => '0');
        elsif(strobe0_c'event and strobe0_c = '1') then ym0c(7 downto 0) <= ym0_snd(7 downto 0);
    end if;
end process;
process (strobe1_a, cpu_res)
begin
    if(cpu_res = '0') then ym1a(7 downto 0) <= (others => '0');
        elsif(strobe1_a'event and strobe1_a = '1') then ym1a(7 downto 0) <= ym1_snd(7 downto 0);
    end if;
end process;
process (strobe1_b, cpu_res)
begin
    if(cpu_res = '0') then ym1b(7 downto 0) <= (others => '0');
        elsif(strobe1_b'event and strobe1_b = '1') then ym1b(7 downto 0) <= ym1_snd(7 downto 0);
    end if;
end process;
process (strobe1_c, cpu_res)
begin
    if(cpu_res = '0') then ym1c(7 downto 0) <= (others => '0');
        elsif(strobe1_c'event and strobe1_c = '1') then ym1c(7 downto 0) <= ym1_snd(7 downto 0);
    end if;
end process;

addiction <= beeper & tapeout;

snd_right <= ym0a + ym0b + ym1a + ym1b when addiction(1 downto 0) = b"00" 	--beeper = '0'
else ym0a + ym0b + ym1a + ym1b + 50 when addiction(1 downto 0) = b"01" or addiction(1 downto 0) = b"10" --beeper = '1';
else ym0a + ym0b + ym1a + ym1b + 100 when addiction(1 downto 0) = b"11"; --beeper = '1';

snd_left <= ym0b + ym0c + ym1b + ym1c when addiction(1 downto 0) = b"00" --beeper = '0'
else ym0b + ym0c + ym1b + ym1c + 50 when	addiction(1 downto 0) = b"01" or addiction(1 downto 0) = b"10" --beeper = '1';
else ym0b + ym0c + ym1b + ym1c + 100 when	addiction(1 downto 0) = b"11";

process (ym_clk, ym0_state, read_fe)
begin
if (read_fe = '0') then snd(0) <= 'Z';
	elsif (ym_clk'event and ym_clk = '0') then
		case ym0_state(1 downto 0) is
			when b"11" => snd(7 downto 0) <= snd_right(7 downto 0); str_l <= '0';
			when b"10" => str_r <= '1';
			when b"01" => str_r <= '0'; snd(7 downto 0) <= snd_left(7 downto 0); 
			when b"00" => str_l <= '1';
		end case;
end if;
end process; 

-------------------------------------------------------------
-- cpu int
process (cpu_clk, int_flag1)
begin
    if (int_flag1='1') then int_counter(5 downto 0) <= b"011111"; 
        elsif(cpu_clk'event and cpu_clk='0') then
            if (not(int_counter(5 downto 0)=b"000000")) then
                cpu_int <= '0';
                int_counter(5 downto 0) <= int_counter(5 downto 0)-'1';
                else cpu_int <= '1';
            end if;
    end if;
end process;

process(int_strobe, cpu_res, int_flag1)
begin
if (cpu_res='0' or int_flag1='1') then int_flag0 <='0';
    elsif (int_strobe'event and int_strobe = '0') then
    int_flag0 <='1';
end if;
end process;

process (cpu_clk, int_flag0)
begin
if(cpu_clk'event and cpu_clk='1') then
    if(int_flag0 = '1') then int_flag1 <= '1';
        else int_flag1 <= '0';
    end if;
end if;
end process;

------------------------------------------------------------------------
-- cpu clocking and stopping
process (pixel_clock)
begin
	if (pixel_clock'event and pixel_clock = '1') then
		precounter <= precounter + '1';
	end if;
end process;

cpu_speed(2 downto 0) <= dosen & portxx77(3) & porteff7(4); 

resync <= 	precounter(4) when (cpu_speed(1 downto 0)=b"01")
else			(precounter(4) or ioflag0) when (iocycle2 = '1')
else			(precounter(4)) when (memflag2 = '1')
else			(precounter(2) or memflag0) when (cpu_speed(1 downto 0)=b"00" and iocycle2 = '0' and memflag2 = '0')
else			(precounter(1) or memflag0) when (cpu_speed(1)='1' and iocycle2 = '0' and memflag2 = '0');

fastclk <= precounter(2) when (cpu_speed(1 downto 0)=b"00")
else precounter(1) when (cpu_speed(1)='1');

lowclk <= precounter(4);

iocycle1 <= iocycle and cpu_m1;
iocycle2 <= iocycle1 or ioflag2;
memcycle1 <= memcycle and not(cpu_a(15) or cpu_a(14)) and fpga_rdrom_input;

process (pixel_clock, resync, vg_tormoz)
begin
if(pixel_clock'event and pixel_clock = '1') then
cpu_clk_b <= resync;
cpu_clk <= resync or vg_tormoz; 
end if;
end process;

process(iocycle, ioflag1)
begin
if(ioflag1 = '1') then ioflag0 <= '0';
	elsif(iocycle'event and iocycle = '1') then ioflag0 <= '1'; 
end if;
end process;

process(lowclk, ioflag0)
begin
if(ioflag0 = '0') then ioflag1 <= '0';
	elsif(lowclk'event and lowclk = '1') then
		if(ioflag0 = '1') then ioflag1 <= '1'; 
		end if;
end if;
end process;

process(iocycle, ioflag3)
begin
if(ioflag3 = '1') then ioflag2 <= '0';
	elsif(iocycle'event and iocycle = '0') then ioflag2 <= '1'; 
end if;
end process;

process(fastclk, ioflag2)
begin
if(ioflag2 = '0') then ioflag3 <= '0';
	elsif(fastclk'event and fastclk = '1') then
		if(ioflag2 = '1') then ioflag3 <= '1'; 
		end if;
end if;
end process;

process (fastclk, memcycle1, memflag1)
begin
if(memflag1 = '1') then memflag0 <= '0';
	elsif(memflag2 = '1') then memflag0 <= '0'; 
		elsif(fastclk'event and fastclk = '1') then
			if (memcycle1 = '1') then memflag0 <= '1'; end if;
end if;
end process;

process(fastclk, memcycle1, memflag0)
begin
if(memflag0 = '0') then memflag1 <= '0';
	elsif(fastclk'event and fastclk = '0') then
		if(memcycle1 = '0' and memflag0 = '1') then memflag1 <= '1'; end if;
end if;
end process;

process(lowclk, memflag0, memcycle)
begin
if(memcycle = '0') then memflag2 <= '0';
	elsif(lowclk'event and lowclk = '1') then 
		if(memflag0 = '1') then memflag2 <= '1'; end if;
end if;
end process;


process (pixel_clock, cpu_clk_b, hardware_reset, read_trz, write_trz, cpu_wr, cpu_rd, cpu_m1, cpu_mreq, cpu_iorq, main_state_counter)
begin
if (hardware_reset = '0') then vg_tormoz <= '0'; 
    elsif(pixel_clock'event and pixel_clock = '0') then
        if (cpu_clk_b = '1' and (read_trz = '1' or write_trz = '1') and cpu_wr = '1' and cpu_rd = '1' and cpu_m1 = '1' and cpu_mreq = '1' and cpu_iorq ='1' and cpu_rfsh='1')
            then vg_tormoz <= '1'; end if;
        if (vg93_transaction = '0' and main_state_counter=b"11") then vg_tormoz <= '0'; end if;
end if;

if (hardware_reset = '0') then vg93_transaction <= '1';  
elsif(pixel_clock'event and pixel_clock = '1') then
    if (vg_tormoz = '1' and main_state_counter=b"00") then vg93_transaction <= '0'; end if;
    if (vg93_transaction = '0' and main_state_counter=b"01" and vg_tormoz = '0') then vg93_transaction <= '1'; end if;
end if;
end process;

---------------------------------------------------------------------
-- ZX-BUS signals
cpu_wait <= '1';

process (cpu_busack)
begin
if (cpu_busack = '0') then cpu_wr <= '1';
cpu_rd <= '1'; cpu_mreq <= '1'; cpu_iorq <= '1';
else cpu_wr <= 'Z';
cpu_rd <= 'Z'; cpu_mreq <= 'Z'; cpu_iorq <= 'Z';
end if;
end process;

fpga_clk_output <= cpu_clk;        
fpga_mreq_output <= cpu_mreq;
fpga_rfsh_output <= cpu_rfsh;
fpga_wr_output <= cpu_wr;
fpga_iorq_output <= cpu_iorq; 
fpga_halt_output <= cpu_halt;
fpga_busack_output <= cpu_busack;
fpga_m1_output <= cpu_m1;
fpga_rd_output  <= cpu_rd;
fpga_dos_output <= dos;
fpga_f_output <= cpu_clk;
fpga_int_output <= cpu_int;
fpga_rs_output <= port7ffd(4);
fpga_csr_output <= rom;

cpu_nmi <= fpga_nmi_input;
cpu_busrq <= '1' and fpga_busrq_input;

fpga_a(15 downto 0) <= cpu_a(15 downto 0);
zetneg_oe <= not(cpu_busack);
dbusoe <= not(cpu_busack);

fpgadir <= cpu_rd and (cpu_m1 or cpu_iorq);
fpga_dir <= fpgadir;      
 
iorq_after_bus <= (cpu_iorq or fpga_io0 or fpga_io1 or fpga_io2);-- or not(ebl)) ;

fpga_d(7 downto 0) <= (others =>'Z') when fpgadir='0'
else cpu_d(7 downto 0) when fpgadir='1';

--------------------------------
--------------------------------
-- IDE by Nemo

--10 30 50 70 90 b0 d0 f0 - first cs,
--08 28 48 68 88 a8 c8 e8 - second cs.

ebl <= (not(cpu_m1) or cpu_a(1) or cpu_a(2));        

ebl_iorq <= ebl or iorq_after_bus;
fpga_ebl <= ebl_iorq;

ior <= ebl_iorq or cpu_a(0) or cpu_rd;
fpga_ior <= ior;
rdh <= ebl_iorq or cpu_rd or not(cpu_a(0));
fpga_rdh <= rdh;

fpga_wrh <= cpu_iowr or ebl or not(cpu_a(0));
fpga_iow <= cpu_iowr or ebl or cpu_a(0);

we_blk0chp0 <= weblk0chp0;
oe_blk0chp0 <= oeblk0chp0;
we_blk0chp1 <= weblk0chp1;
oe_blk0chp1 <= oeblk0chp1;

we_blk1chp0 <= weblk1chp0;
oe_blk1chp0 <= oeblk1chp0;
we_blk1chp1 <= weblk1chp1;
oe_blk1chp1 <= oeblk1chp1;

end koe;
