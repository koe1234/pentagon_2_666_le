library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity zx_main is
  port (
    pixel_clock         : in  std_logic;
    ym_clk              : out std_logic;
    main_state_counter  : out std_logic_vector(1 downto 0);
    blk0_d              : in std_logic_vector(7 downto 0);
    portfe              : in std_logic_vector(3 downto 0);
    gfx_mode            : in std_logic_vector(5 downto 0); --atm (5..3), pent (2..0)
    int_strobe          : out std_logic;
    int_delay           : in std_logic_vector(9 downto 0);
    ssii                : out std_logic;
    ksii                : out std_logic;
    vidr                : out std_logic_vector(4 downto 0);
    vidg                : out std_logic_vector(4 downto 0);
    vidb                : out std_logic_vector(4 downto 0);
    pixelc              : out std_logic_vector(9 downto 0);
    linec               : out std_logic_vector(9 downto 0);
    flash               : in std_logic;
    video_address       : out std_logic_vector(12 downto 0);
    alco_address        : out std_logic_vector(14 downto 0);
    pollitra_a          : out std_logic_vector(3 downto 0);
    pollitra_awr        : out std_logic_vector(3 downto 0);
    pollitra_d          : in std_logic_vector(15 downto 0);
    border3             : in std_logic;
    ega_address         : out std_logic_vector(12 downto 0);
    otmtxt_address      : out std_logic_vector(16 downto 0)
);
end;

architecture koe_z of zx_main is

component ram
  port (
        clock           : IN  std_logic;
        data            : IN  std_logic_vector(15 DOWNTO 0);
        write_address   : IN  std_logic_vector(8 DOWNTO 0);
        read_address    : IN  std_logic_vector(8 DOWNTO 0);
        we              : IN  std_logic;
        q               : OUT std_logic_vector(15 DOWNTO 0)

);
end component;

component ram_border
  port (
        clock           : IN  std_logic;
        data            : IN  std_logic_vector(3 DOWNTO 0);
        write_address   : IN  std_logic_vector(8 DOWNTO 0);
        read_address    : IN  std_logic_vector(8 DOWNTO 0);
        we          	: IN  std_logic;
        q           	: OUT std_logic_vector(3 DOWNTO 0)
    );
end component;

component otmfnt_rom 
    port
    (
        address     : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        clock       : IN STD_LOGIC  := '1';
        q           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
end component;

-- VGA screen constants
constant horizontal_pixels			: natural:=896;
constant vertical_pixels			: natural:=640;
constant shadow_horizont			: natural:=120;
constant shadow_vertical			: natural:=16;
constant horizontal_size			: natural:=768;
constant vertical_size				: natural:=608;
constant screen_hor				: natural:=512;
constant screen_vert				: natural:=384;
constant ramka_ega_vert				: natural:=192;
constant ramka_ega_goriz			: natural:=128;
constant ssi_start				: natural:=891;
constant ssi_stop				: natural:=38;
constant hor_blank_start			: natural:=849;
constant hor_blank_stop				: natural:=73;

signal	ym_counter				: std_logic_vector (4 downto 0):=b"00000";  
signal	main_state				: std_logic_vector(3 downto 0):=b"0000";
signal	zx_screen_counter			: std_logic_vector(17 downto 0):=b"000000000000000000";
signal	zx_screen_counter_low			: std_logic_vector(16 downto 0):=b"00000000000000000";
signal	alco_addr				: std_logic_vector(2 downto 0);
signal	adr_zx_video_attr			: std_logic_vector(9 downto 0);
signal	adr_zx_video_data			: std_logic_vector(12 downto 0);
signal	pixel_c					: std_logic_vector(9 downto 0):=b"0000000000";
signal	line_c					: std_logic_vector(9 downto 0):=b"0000000000";
signal	multic_buf0_clk				: std_logic;
signal	multic_buf0_data_in			: std_logic_vector(15 downto 0);
signal	multic_buf0_addr			: std_logic_vector(8 downto 0);
signal	multic_buf0_we				: std_logic;
signal	multic_buf0_data_out			: std_logic_vector(15 downto 0);
signal	int_str					: std_logic;
signal	multic_buf1_clk				: std_logic;
signal	multic_buf1_data_in			: std_logic_vector(15 downto 0);
signal	multic_buf1_addr			: std_logic_vector(8 downto 0);
signal	multic_buf1_we				: std_logic;
signal	multic_buf1_data_out			: std_logic_vector(15 downto 0);
signal	goriz_border				: std_logic;
signal	zx_goriz_border				: std_logic;
signal	vert_border				: std_logic;
signal	border_buf0_clk				: std_logic;
signal	border_buf0_data_in			: std_logic_vector(15 downto 0);
signal	border_buf0_addr			: std_logic_vector(8 downto 0);
signal	border_buf0_we				: std_logic;
signal	border_buf0_data_out			: std_logic_vector(15 downto 0);
signal	border_buf_addr				: std_logic_vector(8 downto 0);
signal	border_buf1_clk				: std_logic;
signal	border_buf1_data_in			: std_logic_vector(15 downto 0);
signal	border_buf1_addr			: std_logic_vector(8 downto 0);
signal	border_buf1_we				: std_logic;
signal	border_buf1_data_out			: std_logic_vector(15 downto 0);
signal	pixel_data_buffer			: std_logic_vector(7 downto 0);
signal	pixel_data				: std_logic_vector(7 downto 0);
signal	attr_data_buffer			: std_logic_vector(7 downto 0);
signal	attr_data				: std_logic_vector(7 downto 0);
signal	mc_attr_data				: std_logic_vector(7 downto 0);
signal	mc_pixel_data				: std_logic_vector(7 downto 0);
signal	mc_future_data				: std_logic_vector(7 downto 0);
signal	border_data				: std_logic_vector(3 downto 0);
signal	border_delaybuffer			: std_logic_vector(3 downto 0);
signal	border_c				: std_logic_vector(7 downto 0);
signal	alco					: std_logic_vector(12 downto 0);
signal	alco_buff				: std_logic_vector(7 downto 0);
signal	alco_r					: std_logic;
signal	alco_g					: std_logic;
signal	alco_b					: std_logic;
signal	alco_i					: std_logic;
signal	alco_hor_sdvig				: std_logic_vector(3 downto 0);
signal	alco_vert_sdvig				: std_logic_vector(1 downto 0);
signal	alco_sdvig				: std_logic_vector(7 downto 0);
signal	igrb					: std_logic_vector(3 downto 0);
signal	vblank					: std_logic;
signal	ena_x					: std_logic;
signal	ena_y					: std_logic;
signal	border					: std_logic;
signal	line_ega				: std_logic_vector(7 downto 0);
signal	pixel_ega_vga				: std_logic_vector(9 downto 0); 
signal	ega_adr_shift				: std_logic_vector(12 downto 0);
signal	ega_adr_x				: std_logic_vector(5 downto 0);
signal	otm_text_mojno				: std_logic;
signal	otm_fnt_out				: std_logic_vector(7 downto 0);
signal	otm_txt					: std_logic_vector(7 downto 0);
signal	otmtxt_attr				: std_logic_vector(7 downto 0);
signal	otmtxt_addr_dobavka			: std_logic_vector(10 downto 0);
signal	otmtxt_addr				: std_logic_vector(16 downto 0);
signal	otm_fnt_clk				: std_logic;
signal	otm_fnt_addr				: std_logic_vector(10 downto 0);
signal	otmtxt_symbol_code			: std_logic_vector(7 downto 0);
signal	pixel_txt				: std_logic_vector(6 downto 0);
signal	pixel_data_strobe			: std_logic:='0'; -- for modelsim only
signal	attr_data_strobe			: std_logic:='0'; -- for modelsim only
signal	zx_s_c					: std_logic_vector(13 downto 0);
signal	zx_pixel_c				: std_logic_vector(8 downto 0);

begin

-- pixel_clock (114 MHz)
--  _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _
--   |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_|
--
-- main_state_counter0 (57 MHz)
--  ___     ___     ___     ___     ___     ___     ___     ___     ___ 
--     |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |
--
-- main_state_counter1 (28.5 MHz)
--  ___  video  _______  video  _______  video  _______  video  _______ 
--     |_______|  cpu  |_______|  cpu  |_______|  cpu  |_______|  cpu  |
--
-- main_state_counter:        _|10_|11_|00_|01_|10_|11_|00_|01_|10_|11_|00_|01_|10_ |11
--__ video oe _________          ______________________________________  
--                     \________/ fpga delay
--   video data strobe          |-|____________________________________                    
--________________________________/         
--__ cpu oe ____________________         ______________________________
--                              \_______/
--__ cpu we ____________________         ______________________________ 
--                              \_______/ fpga delay
--   cpu data strobe                    |-|____________________________ 
--________________________________________/
--
-- zx_screen_counter bits:
-- 0 - x2 horizontal pixels, 512 VGA pixels => 256 ZX pixels
-- 1...3 - 8 ZX pixels => 1 ZX symbol
-- 4...8 - 32 symbols per line
-- 9 - x2 vertical(384 VGA lines => 192 ZX lines)
-- 10...17 - 192 lines

process (pixel_clock, border, gfx_mode)
begin
    if (pixel_clock'event and pixel_clock = '1') then 
        -- ym clk generation
        ym_counter <= ym_counter + '1'; 
        if (ym_counter > 29) then ym_counter <= (others =>'0'); ym_clk <= '1'; end if;
        if (ym_counter = 15) then ym_clk <= '0'; end if;
			-- pixel data address generation
        adr_zx_video_data(12 downto 11) <= zx_screen_counter_low(15 downto 14);
        adr_zx_video_data(10 downto 8) <= zx_screen_counter_low(10 downto 8);
        adr_zx_video_data(7 downto 5) <= zx_screen_counter_low(13 downto 11);
        adr_zx_video_data(4 downto 0) <= zx_screen_counter_low(7 downto 3); 
        -- attributes address generation
        adr_zx_video_attr(9 downto 8) <= zx_screen_counter_low(15 downto 14);
        adr_zx_video_attr(7 downto 5) <= zx_screen_counter_low(13 downto 11);
        adr_zx_video_attr(4 downto 0) <= zx_screen_counter_low(7 downto 3);
			-- moving right 16c Alco screen by 5.5 ZX pixels
			case (zx_screen_counter(3 downto 0)) is
            when b"0000" => alco_addr(1 downto 0) <= b"10";
            when b"0001" => alco_addr(1 downto 0) <= b"10";
            when b"0010" => alco_addr(1 downto 0) <= b"10";
            when b"0011" => alco_addr(1 downto 0) <= b"01";
            when b"0100" => alco_addr(1 downto 0) <= b"01";
            when b"0101" => alco_addr(1 downto 0) <= b"01";
            when b"0110" => alco_addr(1 downto 0) <= b"01";
            when b"0111" => alco_addr(1 downto 0) <= b"11";
            when b"1000" => alco_addr(1 downto 0) <= b"11";
            when b"1001" => alco_addr(1 downto 0) <= b"11";
            when b"1010" => alco_addr(1 downto 0) <= b"11";
            when b"1011" => alco_addr(1 downto 0) <= b"00";
            when b"1100" => alco_addr(1 downto 0) <= b"00";
            when b"1101" => alco_addr(1 downto 0) <= b"00";
            when b"1110" => alco_addr(1 downto 0) <= b"00";
            when b"1111" => alco_addr(1 downto 0) <= b"10";
            when others => null;
        end case;
	-- final video address generation
        if (zx_screen_counter(3 downto 0) = b"0000" and main_state(1 downto 0) = b"10")
            then video_address(9 downto 0) <= adr_zx_video_attr(9 downto 0); video_address(12 downto 10) <= b"110";
                elsif (zx_screen_counter(3 downto 0) = b"0001" and main_state(1 downto 0) = b"10")
                    then video_address(12 downto 0) <= adr_zx_video_data(12 downto 0);
        end if;
        
        main_state(3 downto 0) <= main_state(3 downto 0) + '1';
        if (main_state(1 downto 0) = b"11") then pixel_c <= pixel_c + '1';
        		  
        if (pixel_c(3 downto 0) = b"1100") then
            if((pixel_c < (((horizontal_pixels-screen_hor)/2)-65+0))) then ega_adr_x(5 downto 0) <= (others => '0');
                else ega_adr_x(5 downto 0) <= ega_adr_x(5 downto 0) + '1';
            end if;
        end if;
    
        if (pixel_c > (horizontal_pixels-2)) then pixel_c <= (others => '0'); line_c <= line_c+'1';
            if (line_c > (vertical_pixels-2)) then line_c <= (others => '0'); end if;
        end if;

        if(line_c < ((vertical_pixels-screen_vert)/2)-0) then ega_adr_shift(12 downto 0) <= (others => '0');
            elsif ((pixel_c = (horizontal_pixels-(horizontal_pixels-screen_hor)/2+64+4)) and line_c(0)='1')
                then ega_adr_shift(12 downto 0) <= ega_adr_shift(12 downto 0) + b"000000101000";
        end if;     

        if ((pixel_c >= hor_blank_start) or (pixel_c <= hor_blank_stop)) then ena_x <= '1';
           else ena_x <= '0'; -- active 0
        end if;

        if ((line_c >= (vertical_pixels-(shadow_vertical+16))) or (line_c <= shadow_vertical)) then ena_y <='1';
				else ena_y <='0';
        end if;

        if ((pixel_c >= ssi_start) or (pixel_c < (ssi_stop+1))) then ssii <='0'; -- 97
				else ssii <= '1';
        end if;

        if ((line_c >= 0) and (line_c < 3)) then ksii <='0';
				else ksii <='1';
        end if;
        
        if (line_c = (vertical_pixels-1-32) and (( (pixel_c >(int_delay(9 downto 0))) and (pixel_c < (int_delay(9 downto 0)+2)) ) )) --16 25
				then    int_str<='0'; 
            else int_str<='1';
        end if;

		  case(line_c(0)) is
				when '0' => zx_pixel_c(8 downto 0) <= '0' & pixel_c(9 downto 2);
				when '1' => zx_pixel_c(8 downto 0) <= b"011100000" + pixel_c(9 downto 2);
				when others => null;
		  end case;
		  
		  if ((zx_pixel_c(8 downto 0) >= b"001011000") and (zx_pixel_c(8 downto 0) < b"101100000"))
				then zx_screen_counter_low(8 downto 0) <= zx_pixel_c(8 downto 0) - b"001011000";
						zx_screen_counter_low(16 downto 8) <= line_c(9 downto 1) - b"001000000";
			end if;
		  
        zx_screen_counter(3 downto 0) <= zx_screen_counter(3 downto 0) + '1';
			
        if ((line_c = (((vertical_pixels-screen_vert)/2)+0+0)) and (pixel_c = (((horizontal_pixels-screen_hor)/2)-16)) )
				then zx_screen_counter <= (others => '0');
					elsif (((pixel_c >= ((horizontal_pixels-screen_hor)/2))) and (pixel_c < (((horizontal_pixels+screen_hor)/2))) and (zx_screen_counter(3 downto 0)=15))
					then zx_screen_counter(17 downto 4) <= zx_screen_counter(17 downto 4) + '1';
        end if;   
 
        if (zx_screen_counter(10)='0')
				then    multic_buf1_we <= '1';
                    multic_buf0_addr(4 downto 0) <= zx_screen_counter(9 downto 5);
                    multic_buf1_addr(4 downto 0) <= zx_screen_counter(8 downto 4);
                    multic_buf0_we <= '0';
            else    multic_buf0_we <= '1';
                    multic_buf1_addr(4 downto 0) <= zx_screen_counter(9 downto 5);
                    multic_buf0_addr(4 downto 0) <= zx_screen_counter(8 downto 4);
                    multic_buf1_we <= '0';
        end if;

		  case line_c(0) is
				when '0' => border_buf_addr(8 downto 0) <= '0' & pixel_c(9 downto 2); 		-- from 0 to 223
				when '1' => border_buf_addr(8 downto 0) <= b"011100000"+pixel_c(9 downto 2); 	-- from 224 to 447
				when others => null;
		  end case;

		  -- line_c(1) changes the value every 2 vga lines
        	if (line_c(1)='0') then -- buf0 - write; buf1 - read
			border_buf0_addr(8 downto 0) <= border_buf_addr(8 downto 0); 
			border_buf1_addr(8 downto 0) <= pixel_c(9 downto 1) - 6;			
				
				border_buf1_we <= '1';
            			border_buf0_we <= '0';
				if (main_state(2) = '0') then border_delaybuffer(3 downto 0) <= border_buf1_data_out(3 downto 0); end if;
	
				multic_buf0_addr(8 downto 0) <= border_buf_addr(8 downto 0);
				multic_buf1_addr(8 downto 0) <= pixel_c(9 downto 1);   
            multic_buf1_we <= '1';
            multic_buf0_we <= '0';
            
        else -- buf0 - read; buf1 - write
		
				border_buf1_addr(8 downto 0) <= border_buf_addr(8 downto 0);
				border_buf0_addr(8 downto 0) <= pixel_c(9 downto 1) - 6; 
			
				border_buf0_we <= '1';
            border_buf1_we <= '0';
				if (main_state(2) = '0') then border_delaybuffer(3 downto 0) <= border_buf0_data_out(3 downto 0); end if;
				
				multic_buf1_addr(8 downto 0) <= border_buf_addr(8 downto 0);
				multic_buf0_addr(8 downto 0) <= pixel_c(9 downto 1); 
            multic_buf0_we <= '1';
            multic_buf1_we <= '0';
            
        end if;
		  
          if (zx_screen_counter(3 downto 0) = b"1111") then 
            if (line_c(1)='0') then pixel_data(7 downto 0) <= multic_buf1_data_out(15 downto 8);--multic_buf1_data_out(15 downto 8);
                attr_data(7 downto 0) <= multic_buf1_data_out(7 downto 0); --multic_buf1_data_out(7 downto 0);
                else    pixel_data(7 downto 0) <= multic_buf0_data_out(15 downto 8);--multic_buf0_data_out(15 downto 8);
                        attr_data(7 downto 0) <= multic_buf0_data_out(7 downto 0);--multic_buf0_data_out(7 downto 0);
            end if;
        elsif (zx_screen_counter(0) = '1') then pixel_data(7 downto 1) <= pixel_data(6 downto 0);
        end if;
        -- moving down 16c Alco screen by 1 line
        if (zx_screen_counter(9 downto 0)) = b"1111111111" then
            alco_sdvig(7 downto 0) <= (zx_screen_counter(17 downto 16) & zx_screen_counter(12 downto 10) &  zx_screen_counter(15 downto 13));
        end if;
        -- accounting the horizontal shift of the 16c Alco screen with a vertical shift (+ another delay of 6 pixels)
        if (zx_screen_counter(3 downto 0) = b"1010") then 
            alco(12 downto 5) <= alco_sdvig(7 downto 0);
            alco(4 downto 0) <= zx_screen_counter(8 downto 4); 
        end if;
        
        if (zx_screen_counter(2 downto 0) = b"001") then --111
            mc_future_data(7 downto 0) <= alco_buff(7 downto 0);
        end if;
        if (zx_screen_counter(2 downto 0) = b"110") then   -- 011
            mc_pixel_data(7 downto 0) <= alco_buff(7 downto 0);
            mc_attr_data(7 downto 0) <= mc_future_data(7 downto 0);
            else mc_pixel_data(7 downto 1) <= mc_pixel_data(6 downto 0);
        end if;
        
        if ((zx_screen_counter(1 downto 0) = b"11") or (zx_screen_counter(1 downto 0) = b"00"))
            then    alco_r <= alco_buff(1);
                    alco_g <= alco_buff(2);
                    alco_b <= alco_buff(0);
                    alco_i <= alco_buff(6);
            else
                    alco_r <= alco_buff(4);
                    alco_g <= alco_buff(5);
                    alco_b <= alco_buff(3);
                    alco_i <= alco_buff(7);
        end if;
        if (ena_x = '0' and ena_y ='0') then
            if      (border='1') then 
                if (gfx_mode(3) = '0') then igrb(3 downto 0) <= (border3 & portfe(2 downto 0));
                    else igrb(3 downto 0) <= border_data(3 downto 0);
                end if;
            else
                case (gfx_mode(5 downto 0)) is
                    when b"011000" =>
                            igrb(3) <= attr_data(6);
                            if ((pixel_data(7) xor (attr_data(7) and flash)) ='0') then
                                igrb(2 downto 0) <= attr_data(5 downto 3);
                                else    
                                igrb(2 downto 0) <= attr_data(2 downto 0);
                            end if; 
                    when b"011001" =>  
                            igrb(3 downto 0) <= alco_i & alco_g & alco_r & alco_b; 
                    when b"000000" =>  --ega
                            igrb(3 downto 0) <= alco_i & alco_g & alco_r & alco_b; 
                    when b"010000" =>  --mc 640x200
                            if (mc_pixel_data(7) = '0') then
                                igrb(3 downto 0) <= mc_attr_data(7) & mc_attr_data(5 downto 3);
                                else    
                                igrb(3 downto 0) <= mc_attr_data(6) & mc_attr_data(2 downto 0);
                            end if; 
                    when b"110000" => --otm textmode
                            if (otm_text_mojno='0') then
                                case (otm_txt(7)) is
                                    when '0' => igrb(3) <= otmtxt_attr(7); igrb(2 downto 0) <= otmtxt_attr(5 downto 3);
                                    when '1' => igrb(3) <= otmtxt_attr(6); igrb(2 downto 0) <= otmtxt_attr(2 downto 0);
                                    when others => null;
                                end case;
                                else igrb(3 downto 0) <= b"0000";
                            end if;
                    when others => null;
                end case;
            end if;
            vblank <= '1';
        else
            vblank <= '0';
        end if;
    
    -----------------------------------------------------------------------------
    -- ATM textmode
    -----------------------------------------------------------------------------
    
        if (pixel_c > 127 and pixel_c < 769 and line_c > 61 and line_c < 576)
            then otm_text_mojno <= '0';
                else otm_text_mojno <= '1';
        end if;
    
        if (pixel_c(2 downto 0) = b"001") --001 --111
            then otm_txt(7 downto 0) <= otm_fnt_out(7 downto 0);
                else otm_txt(7 downto 1) <= otm_txt(6 downto 0);
        end if;
    
        if (line_c < 128 or line_c > 576) 
            then otmtxt_addr_dobavka <= (others => '0');
                else
                    if ((line_c(3 downto 0) = b"1111") and (pixel_c = 768))
                        then otmtxt_addr_dobavka(10 downto 0) <= otmtxt_addr_dobavka(10 downto 0) + b"1000000"; 
                    end if;
        end if; 
   
    end if; 
	    
            case (main_state(1 downto 0)) is
                when b"00" =>   otm_fnt_clk <= '0'; 
                when b"10" =>
                                    if(pixel_c(3)='1') -- zx_screen_counter(3)
                                        then 
                                            case (zx_screen_counter(1 downto 0)) is
                                                when b"00" => otmtxt_addr(16 downto 0) <= b"001" & (pixel_txt(6 downto 1) - b"1000" + b"00000111000000" + otmtxt_addr_dobavka(10 downto 0)); -- odd column attributes
                                                when b"01" => otmtxt_addr(16 downto 0) <= b"101" & (pixel_txt(6 downto 1) - b"1000" + b"00000111000000" + otmtxt_addr_dobavka(10 downto 0)); -- even column data
                                                when others => null;
                                            end case;
                                        else 
                                            case (zx_screen_counter(1 downto 0)) is
                                                when b"00" => otmtxt_addr(16 downto 0) <= b"001" & (pixel_txt(6 downto 1) - b"1000" + b"10000111000000" + otmtxt_addr_dobavka(10 downto 0)); -- even column attributes
                                                when b"01" => otmtxt_addr(16 downto 0) <= b"101" & (pixel_txt(6 downto 1) - b"1000" + b"10000111000000" + otmtxt_addr_dobavka(10 downto 0)); -- odd column data
                                                when others => null;
                                            end case;
                                    end if;                     
                        
                                    if(zx_screen_counter(1 downto 0)=b"10") then otm_fnt_addr(10 downto 3) <= otmtxt_symbol_code(7 downto 0); otm_fnt_addr(2 downto 0) <= line_c(3 downto 1); end if; -- +1
                when b"11" => if(zx_screen_counter(1 downto 0)=b"10") then otm_fnt_clk <= '1'; end if;
                when others => null;
            end case;
   
    -----------------------------------------------------------------------------
    -- end ATM textmode
    -----------------------------------------------------------------------------
 
        pollitra_a(3 downto 0) <= igrb(3 downto 0);
        pollitra_awr(3 downto 0) <= border3 & portfe(2 downto 0);

        if (main_state(2 downto 0) = b"10")
            then border_buf0_clk <= '1'; border_buf1_clk <= '1'; 
                else border_buf0_clk <= '0'; border_buf1_clk <= '0'; 
        end if;
        
		  if (main_state(2 downto 0) = b"100") then border_data(3 downto 0) <= border_delaybuffer(3 downto 0); end if;
		  
        if (main_state(1 downto 0) = b"10") then
            if zx_screen_counter(2 downto 0) = b"0110"
                then multic_buf0_clk <= '1'; multic_buf1_clk <= '1';
                    else multic_buf0_clk <= '0'; multic_buf1_clk <= '0';
            end if;
            
            case (gfx_mode(5 downto 0)) is
                when b"000000" => -- ega
                    if (line_c < ((vertical_pixels-screen_vert)/2)) or (line_c > ((vertical_pixels-(vertical_pixels-screen_vert)/2)+4+4 +4+3))
                        then vert_border <= '1';           
                        else vert_border <='0';
                    end if;

                    if ((pixel_c < (((horizontal_pixels-screen_hor)/2)-64+1)) or (pixel_c > (horizontal_pixels-(horizontal_pixels-screen_hor)/2+64+0)))
                        then goriz_border <= '1';                         
                        else goriz_border <= '0';
                    end if;
            
                when b"010000" => -- mc640x200
                    if (line_c < ((vertical_pixels-screen_vert)/2)) or (line_c > ((vertical_pixels-(vertical_pixels-screen_vert)/2)+4+4 +4+3))
                        then vert_border <= '1';           
                        else vert_border <='0';
                    end if;

                    if ((pixel_c < (((horizontal_pixels-screen_hor)/2)-64+1+7)) or (pixel_c > (horizontal_pixels-(horizontal_pixels-screen_hor)/2+64+0+7)))
                        then goriz_border <= '1';                         
                        else goriz_border <= '0';
                    end if;
                    
                when b"110000" => -- otm textmode       
                    if (line_c < ((vertical_pixels-screen_vert)/2)) or (line_c > ((vertical_pixels-(vertical_pixels-screen_vert)/2)+4+4 +4+3))
                        then vert_border <= '1';           
                        else vert_border <='0';
                    end if;

                    if ((pixel_c < (((horizontal_pixels-screen_hor)/2)-64+2)) or (pixel_c > (horizontal_pixels-(horizontal_pixels-screen_hor)/2+64+0)))
                        then goriz_border <= '1';                         
                        else goriz_border <= '0';
                    end if;
                
                when others => --zx ðàìêà
                    if (line_c < ((vertical_pixels-screen_vert)/2)+0+2) or (line_c > ((vertical_pixels-(vertical_pixels-screen_vert)/2)+0+1))
                        then vert_border <= '1';
                        else vert_border <='0';
                    end if;

                    if ((pixel_c < (((horizontal_pixels-screen_hor)/2)+1)) or (pixel_c > (horizontal_pixels-(horizontal_pixels-screen_hor)/2)))
                        then goriz_border <= '1'; -- horizontal VGA border
                        else goriz_border <= '0';
                    end if;
                    if ((border_buf_addr < 88) or (border_buf_addr > 351)) 
								then zx_goriz_border <= '1'; -- horizontal ZX border
								else zx_goriz_border <= '0';
						  end if;
            end case;
            
        end if; 

ega_address(12 downto 0) <= (ega_adr_shift(12 downto 0)) + (b"0000000" & ega_adr_x(5 downto 0));

end if;
end process;

pixel_txt(6 downto 0) <= pixel_c(9 downto 3)+'1';

zx_s_c(13 downto 0) <= zx_screen_counter(17 downto 4);

process (pixel_clock, vblank)
begin
    if (pixel_clock'event and pixel_clock = '1') then 
        if (vblank='1') then
                vidr(4 downto 0) <= not (pollitra_d(1) & pollitra_d(6) & pollitra_d(9) & pollitra_d(14) & '1');
                vidg(4 downto 0) <= not (pollitra_d(4) & pollitra_d(7) & pollitra_d(12) & pollitra_d(15) & '1');
                vidb(4 downto 0) <= not (pollitra_d(0) & pollitra_d(5) & pollitra_d(8) & pollitra_d(13) & '1');
                
        else
                vidb(4 downto 0) <= (others =>'0');
                vidr(4 downto 0) <= (others =>'0');
                vidg(4 downto 0) <= (others =>'0');
        end if; 
end if;
end process;

border <= vert_border or goriz_border; 

process (pixel_clock, main_state, zx_screen_counter)
begin
if (pixel_clock'event and pixel_clock='1') then
    if (main_state(1 downto 0)=b"01" and zx_screen_counter(3 downto 0) = b"0010")
        then pixel_data_buffer(7 downto 0) <= blk0_d(7 downto 0); pixel_data_strobe <= '1'; attr_data_strobe <= '0';
            elsif (main_state(1 downto 0)=b"01" and zx_screen_counter(3 downto 0) = b"0001")
                then attr_data_buffer(7 downto 0) <= blk0_d(7 downto 0); attr_data_strobe <= '1'; pixel_data_strobe <= '0';
    end if;

    if (main_state(1 downto 0)=b"01" and zx_screen_counter(1 downto 0) = b"11") 
        then alco_buff(7 downto 0) <= blk0_d(7 downto 0);
    end if;
    
    if (main_state(1 downto 0)=b"01") then
        case (zx_screen_counter(1 downto 0)) is  
            when b"01" => otmtxt_attr(7 downto 0) <= blk0_d(7 downto 0); --b"11010110";--
            when b"10" => otmtxt_symbol_code(7 downto 0) <= blk0_d(7 downto 0);-- b"10001001";--
            when others => null;
        end case;
    end if;         
    
end if;
end process;

process (pixel_clock, main_state)
begin
    if (pixel_clock'event and pixel_clock='0') then
    if (main_state(1 downto 0)=b"00") then border_c(3 downto 0) <= border3 & portfe(2 downto 0);
end if;
end if;
end process;

otmfontbuffer: otmfnt_rom port map (otm_fnt_addr(10 downto 0), otm_fnt_clk, otm_fnt_out);

pixelc <= pixel_c;
linec <= line_c;

border_c(7 downto 4) <= b"1010";
main_state_counter(1 downto 0) <= main_state(1 downto 0);
int_strobe <= int_str;

multicolor_buffer0: ram port map (multic_buf0_clk, multic_buf0_data_in(15 downto 0), multic_buf0_addr(8 downto 0), multic_buf0_addr(8 downto 0), multic_buf0_we, multic_buf0_data_out(15 downto 0));        
multicolor_buffer1: ram port map (multic_buf1_clk, multic_buf1_data_in(15 downto 0), multic_buf1_addr(8 downto 0), multic_buf1_addr(8 downto 0), multic_buf1_we, multic_buf1_data_out(15 downto 0));        

border_buf0_data_in(3 downto 0) <= border3 & portfe(2 downto 0);
border_buf1_data_in(3 downto 0) <= border3 & portfe(2 downto 0);
    
multic_buf0_data_in(15 downto 8) <= pixel_data_buffer(7 downto 0); 
multic_buf0_data_in(7 downto 0) <= attr_data_buffer(7 downto 0); 
multic_buf1_data_in(15 downto 8) <= pixel_data_buffer(7 downto 0); 
multic_buf1_data_in(7 downto 0) <= attr_data_buffer(7 downto 0); 

border_buffer0: ram_border port map (border_buf0_clk, border_buf0_data_in(3 downto 0), border_buf0_addr(8 downto 0), border_buf0_addr(8 downto 0), border_buf0_we, border_buf0_data_out(3 downto 0));
border_buffer1: ram_border port map (border_buf1_clk, border_buf1_data_in(3 downto 0), border_buf1_addr(8 downto 0), border_buf1_addr(8 downto 0), border_buf1_we, border_buf1_data_out(3 downto 0));

alco_address(14 downto 13) <= alco_addr(1 downto 0);
alco_address(12 downto 0) <= alco(12 downto 0);

otmtxt_address(16 downto 0) <= otmtxt_addr(16 downto 0);
    
end koe_z;
