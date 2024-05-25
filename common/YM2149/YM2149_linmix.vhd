--
-- YM2149 vhdl core

-- Copyright (c) MikeJ - Jan 2005
-- Copyleft :) koe - Sept 2oo9

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity YM2149 is
  port (
  -- data bus
  I_DA                : in  std_logic_vector(7 downto 0);
  O_DA                : out std_logic_vector(7 downto 0);
  
  output	          : out std_logic_vector(7 downto 0);
  
  strobe_a          : out std_logic;
  strobe_b          : out std_logic;
  strobe_c          : out std_logic;
  
  RESET_L             : in  std_logic;
  CLK                 : in  std_logic;  -- note 6 Mhz
  wr_addr			  : in std_logic;
  wr_data			  : in std_logic;
  rd_data			  : in std_logic;
  state				: out std_logic_vector(1 downto 0)

);
end;

architecture RTL of YM2149 is
  type  array_16x8   is array (0 to 15) of std_logic_vector(7 downto 0);
  type  array_3x12   is array (1 to 3) of std_logic_vector(11 downto 0);

  signal cnt_div              : std_logic_vector(3 downto 0) := (others => '0');
  signal noise_div            : std_logic := '0';
  signal ena_div              : std_logic;
  signal ena_div_noise        : std_logic;
  signal poly17               : std_logic_vector(16 downto 0) := (others => '0');

  -- registers
  signal addr                 : std_logic_vector(7 downto 0);
  signal busctrl_addr         : std_logic;
  signal busctrl_we           : std_logic;
  signal busctrl_re           : std_logic;

  signal reg                  : array_16x8;
  signal env_reset            : std_logic;
  signal ioa_inreg            : std_logic_vector(7 downto 0);
  signal iob_inreg            : std_logic_vector(7 downto 0);

  signal noise_gen_cnt        : std_logic_vector(4 downto 0);
  signal noise_gen_op         : std_logic;
  signal tone_gen_cnt         : array_3x12 := (others => (others => '0'));
  signal tone_gen_op          : std_logic_vector(3 downto 1) := "000";

  signal env_gen_cnt          : std_logic_vector(15 downto 0);
  signal env_ena              : std_logic;
  signal env_hold             : std_logic;
  signal env_inc              : std_logic;
  signal env_vol              : std_logic_vector(4 downto 0);

  signal tone_ena_l           : std_logic;
  signal tone_src             : std_logic;
  signal noise_ena_l          : std_logic;
  signal chan_vol             : std_logic_vector(4 downto 0);

  signal dac_amp              : std_logic_vector(7 downto 0);
  signal audio_mix            : std_logic_vector(9 downto 0);


begin


  -- схватываем номер регистра ("адрес")
  p_waddr                : process(wr_addr, RESET_L)
  begin
    if (RESET_L = '0') then
      addr <= (others => '0');
    elsif (falling_edge(wr_addr)) then
      addr <= I_DA;
    end if;
  end process;

  -- схватываем данные в выбранный регистр
  p_wdata                : process(wr_data, RESET_L, addr)
  begin
    if (RESET_L = '0') then
      reg <= (others => (others => '0'));
    elsif (falling_edge(wr_data)) then
        case addr(3 downto 0) is
          when x"0" => reg(0)  <= I_DA;
          when x"1" => reg(1)  <= I_DA;
          when x"2" => reg(2)  <= I_DA;
          when x"3" => reg(3)  <= I_DA;
          when x"4" => reg(4)  <= I_DA;
          when x"5" => reg(5)  <= I_DA;
          when x"6" => reg(6)  <= I_DA;
          when x"7" => reg(7)  <= I_DA;
          when x"8" => reg(8)  <= I_DA;
          when x"9" => reg(9)  <= I_DA;
          when x"A" => reg(10) <= I_DA;
          when x"B" => reg(11) <= I_DA;
          when x"C" => reg(12) <= I_DA;
          when x"D" => reg(13) <= I_DA;
   
          when others => null;
        end case;
    end if;

-- здесь тоже я правил

    env_reset <= '0';
    if (wr_data = '0') and (addr(3 downto 0) = x"D") then
      env_reset <= '1';
    end if;
  end process;

  p_rdata                : process(rd_data, busctrl_re, RESET_L, addr, reg)
  begin
    
if (RESET_L = '0') then
O_DA <= (others => '0'); 

    elsif (falling_edge(rd_data)) then 
      case addr(3 downto 0) is
        when x"0" => O_DA <= reg(0) ;
        when x"1" => O_DA <= "0000" & reg(1)(3 downto 0) ;
        when x"2" => O_DA <= reg(2) ;
        when x"3" => O_DA <= "0000" & reg(3)(3 downto 0) ;
        when x"4" => O_DA <= reg(4) ;
        when x"5" => O_DA <= "0000" & reg(5)(3 downto 0) ;
        when x"6" => O_DA <= "000"  & reg(6)(4 downto 0) ;
        when x"7" => O_DA <= reg(7) ;
        when x"8" => O_DA <= "000"  & reg(8)(4 downto 0) ;
        when x"9" => O_DA <= "000"  & reg(9)(4 downto 0) ;
        when x"A" => O_DA <= "000"  & reg(10)(4 downto 0) ;
        when x"B" => O_DA <= reg(11);
        when x"C" => O_DA <= reg(12);
        when x"D" => O_DA <= "0000" & reg(13)(3 downto 0);
        when others => null;
      end case;
    end if;
  end process;
  --
  p_divider              : process
  begin
    wait until rising_edge(CLK);
    -- / 8 when SEL is high and /16 when SEL is low
      ena_div <= '0';
      ena_div_noise <= '0';
      if (cnt_div = "0000") then
       -- cnt_div <= (not I_SEL_L) & "111";
        cnt_div <= "1111";
       	ena_div <= '1';

        noise_div <= not noise_div;
        if (noise_div = '1') then
          ena_div_noise <= '1';
        end if;
      else
        cnt_div <= cnt_div - "1";
      end if;
  end process;

  p_noise_gen            : process
    variable noise_gen_comp : std_logic_vector(4 downto 0);
    variable poly17_zero : std_logic;
  begin
    wait until rising_edge(CLK);

    if (reg(6)(4 downto 0) = "00000") then
      noise_gen_comp := "00000";
    else
      noise_gen_comp := (reg(6)(4 downto 0) - "1");
    end if;

    poly17_zero := '0';
    if (poly17 = "00000000000000000") then poly17_zero := '1'; end if;

      if (ena_div_noise = '1') then -- divider ena

        if (noise_gen_cnt >= noise_gen_comp) then
          noise_gen_cnt <= "00000";
          poly17 <= (poly17(0) xor poly17(2) xor poly17_zero) & poly17(16 downto 1);
        else
          noise_gen_cnt <= (noise_gen_cnt + "1");
        end if;
      end if;
  end process;
  noise_gen_op <= poly17(0);

  p_tone_gens            : process
    variable tone_gen_freq : array_3x12;
    variable tone_gen_comp : array_3x12;
  begin
    wait until rising_edge(CLK);

    -- looks like real chips count up - we need to get the Exact behaviour ..
    tone_gen_freq(1) := reg(1)(3 downto 0) & reg(0);
    tone_gen_freq(2) := reg(3)(3 downto 0) & reg(2);
    tone_gen_freq(3) := reg(5)(3 downto 0) & reg(4);
    -- period 0 = period 1
    for i in 1 to 3 loop
      if (tone_gen_freq(i) = x"000") then
        tone_gen_comp(i) := x"000";
      else
        tone_gen_comp(i) := (tone_gen_freq(i) - "1");
      end if;
    end loop;

      for i in 1 to 3 loop
        if (ena_div = '1') then -- divider ena

          if (tone_gen_cnt(i) >= tone_gen_comp(i)) then
            tone_gen_cnt(i) <= x"000";
            tone_gen_op(i) <= not tone_gen_op(i);
          else
            tone_gen_cnt(i) <= (tone_gen_cnt(i) + "1");
          end if;
        end if;
      end loop;
  end process;

  p_envelope_freq        : process
    variable env_gen_freq : std_logic_vector(15 downto 0);
    variable env_gen_comp : std_logic_vector(15 downto 0);
  begin
    wait until rising_edge(CLK);
    env_gen_freq := reg(12) & reg(11);
    -- envelope freqs 1 and 0 are the same.
    if (env_gen_freq = x"0000") then
      env_gen_comp := x"0000";
    else
      env_gen_comp := (env_gen_freq - "1");
    end if;
      env_ena <= '0';
      if (ena_div = '1') then -- divider ena
        if (env_gen_cnt >= env_gen_comp) then
          env_gen_cnt <= x"0000";
          env_ena <= '1';
        else
          env_gen_cnt <= (env_gen_cnt + "1");
        end if;
      end if;
  end process;

  p_envelope_shape       : process(env_reset, reg, CLK)
    variable is_bot    : boolean;
    variable is_bot_p1 : boolean;
    variable is_top_m1 : boolean;
    variable is_top    : boolean;
  begin
        -- envelope shapes
        -- C AtAlH
        -- 0 0 x x  \___
        --
        -- 0 1 x x  /___
        --
        -- 1 0 0 0  \\\\
        --
        -- 1 0 0 1  \___
        --
        -- 1 0 1 0  \/\/
        --           ___
        -- 1 0 1 1  \
        --
        -- 1 1 0 0  ////
        --           ___
        -- 1 1 0 1  /
        --
        -- 1 1 1 0  /\/\
        --
        -- 1 1 1 1  /___
    if (env_reset = '1') then
      -- load initial state
      if (reg(13)(2) = '0') then -- attack
        env_vol <= "11111";
        env_inc <= '0'; -- -1
      else
        env_vol <= "00000";
        env_inc <= '1'; -- +1
      end if;
      env_hold <= '0';

    elsif rising_edge(CLK) then
      is_bot    := (env_vol = "00000");
      is_bot_p1 := (env_vol = "00001");
      is_top_m1 := (env_vol = "11110");
      is_top    := (env_vol = "11111");

        if (env_ena = '1') then
          if (env_hold = '0') then
            if (env_inc = '1') then
              env_vol <= (env_vol + "00001");
            else
              env_vol <= (env_vol + "11111");
            end if;
          end if;

          -- envelope shape control.
          if (reg(13)(3) = '0') then
            if (env_inc = '0') then -- down
              if is_bot_p1 then env_hold <= '1'; end if;
            else
              if is_top then env_hold <= '1'; end if;
            end if;
          else
            if (reg(13)(0) = '1') then -- hold = 1
              if (env_inc = '0') then -- down
                if (reg(13)(1) = '1') then -- alt
                  if is_bot    then env_hold <= '1'; end if;
                else
                  if is_bot_p1 then env_hold <= '1'; end if;
                end if;
              else
                if (reg(13)(1) = '1') then -- alt
                  if is_top    then env_hold <= '1'; end if;
                else
                  if is_top_m1 then env_hold <= '1'; end if;
                end if;
              end if;

            elsif (reg(13)(1) = '1') then -- alternate
              if (env_inc = '0') then -- down
                if is_bot_p1 then env_hold <= '1'; end if;
                if is_bot    then env_hold <= '0'; env_inc <= '1'; end if;
              else
                if is_top_m1 then env_hold <= '1'; end if;
                if is_top    then env_hold <= '0'; env_inc <= '0'; end if;
              end if;
            end if;

          end if;
        end if;
    end if;
  end process;

  p_chan_mixer           : process(cnt_div, reg, tone_gen_op)
  begin
    tone_ena_l  <= '1'; tone_src <= '1';
    noise_ena_l <= '1'; chan_vol <= "00000";
    case cnt_div(1 downto 0) is
      when "00" =>
        tone_ena_l  <= reg(7)(0);
		tone_src    <= tone_gen_op(1); 
		chan_vol    <= reg(8)(4 downto 0);
        noise_ena_l <= reg(7)(3);
      when "01" =>
        tone_ena_l  <= reg(7)(1);
        tone_src    <= tone_gen_op(2);
        chan_vol    <= reg(9)(4 downto 0);
        noise_ena_l <= reg(7)(4);
      when "10" =>
        tone_ena_l  <= reg(7)(2);
        tone_src    <= tone_gen_op(3);
        chan_vol    <= reg(10)(4 downto 0);
        noise_ena_l <= reg(7)(5);
      when "11" => null; -- tone gen outputs become valid on this clock
      when others => null;
    end case;
  end process;

  p_op_mixer             : process
    variable chan_mixed : std_logic;
    variable chan_amp : std_logic_vector(4 downto 0);
  begin
    wait until rising_edge(CLK);
    
      chan_mixed := (tone_ena_l or tone_src) and (noise_ena_l or noise_gen_op);

      chan_amp := (others => '0');
      if (chan_mixed = '1') then
        if (chan_vol(4) = '0') then
          if (chan_vol(3 downto 0) = "0000") then -- nothing is easy ! make sure quiet is quiet
            chan_amp := "00000";
          else
            chan_amp := chan_vol(3 downto 0) & '1'; -- make sure level 31 (env) = level 15 (tone)
          end if;
        else
          chan_amp := env_vol(4 downto 0);
        end if;
      end if;

      dac_amp <= x"00";
      case chan_amp is
    --    when "11111" => dac_amp <= x"FF";
      --  when "11110" => dac_amp <= x"D9";
      --  when "11101" => dac_amp <= x"BA";
      --  when "11100" => dac_amp <= x"9F";
      --  when "11011" => dac_amp <= x"88";
      --  when "11010" => dac_amp <= x"74";
      --  when "11001" => dac_amp <= x"63";
      --  when "11000" => dac_amp <= x"54";
      --  when "10111" => dac_amp <= x"48";
      --  when "10110" => dac_amp <= x"3D";
      --  when "10101" => dac_amp <= x"34";
      --  when "10100" => dac_amp <= x"2C";
      --  when "10011" => dac_amp <= x"25";
      --  when "10010" => dac_amp <= x"1F";
      --  when "10001" => dac_amp <= x"1A";
      --  when "10000" => dac_amp <= x"16";
      --  when "01111" => dac_amp <= x"13";
      --  when "01110" => dac_amp <= x"10";
      --  when "01101" => dac_amp <= x"0D";
      --  when "01100" => dac_amp <= x"0B";
      --  when "01011" => dac_amp <= x"09";
      --  when "01010" => dac_amp <= x"08";
      --  when "01001" => dac_amp <= x"07";
       -- when "01000" => dac_amp <= x"06";
      --  when "00111" => dac_amp <= x"05";
      --  when "00110" => dac_amp <= x"04";
     --   when "00101" => dac_amp <= x"03";
     --   when "00100" => dac_amp <= x"03";
     --   when "00011" => dac_amp <= x"02";
     --   when "00010" => dac_amp <= x"02";
     --   when "00001" => dac_amp <= x"01";
     --   when "00000" => dac_amp <= x"00";
     --   when others => null;

		when "11111" => dac_amp <= x"3f";
        when "11110" => dac_amp <= x"35";
        when "11101" => dac_amp <= x"2c";
        when "11100" => dac_amp <= x"25";
        when "11011" => dac_amp <= x"1f";
        when "11010" => dac_amp <= x"1a";
        when "11001" => dac_amp <= x"16";
        when "11000" => dac_amp <= x"12";
        when "10111" => dac_amp <= x"0f";
        when "10110" => dac_amp <= x"0d";
        when "10101" => dac_amp <= x"0b";
        when "10100" => dac_amp <= x"09";
        when "10011" => dac_amp <= x"07";
        when "10010" => dac_amp <= x"06";
        when "10001" => dac_amp <= x"05";
        when "10000" => dac_amp <= x"04";
        when "01111" => dac_amp <= x"04";
        when "01110" => dac_amp <= x"03";
        when "01101" => dac_amp <= x"03";
        when "01100" => dac_amp <= x"02";
        when "01011" => dac_amp <= x"02";
        when "01010" => dac_amp <= x"01";
        when "01001" => dac_amp <= x"01";
        when "01000" => dac_amp <= x"01";
        when "00111" => dac_amp <= x"01";
        when "00110" => dac_amp <= x"01";
        when "00101" => dac_amp <= x"01";
        when "00100" => dac_amp <= x"01";
        when "00011" => dac_amp <= x"00";
        when "00010" => dac_amp <= x"00";
        when "00001" => dac_amp <= x"00";
        when "00000" => dac_amp <= x"00";

      end case;

	  if (cnt_div(1 downto 0) = "10") then
        audio_mix   <= (others => '0');
        --audio_final <= audio_mix;
      else
        audio_mix   <= audio_mix + ("00" & dac_amp);
      end if;

  end process;

strobe: process
begin
    wait until rising_edge(CLK);
    output(7 downto 0) <= dac_amp(7 downto 0);
end process; 

final_output: process
begin
    wait until falling_edge(CLK);
		case cnt_div(1 downto 0) is
    		when "00" =>strobe_c <= '1'; 								 
			when "01" =>strobe_a <= '0'; 								 
			when "10" =>strobe_b<='0'; strobe_a <= '1'; 								
			when "11" =>strobe_b <= '1';strobe_c <='0';				 
		end case;
end process; 

state(1 downto 0) <= cnt_div(1 downto 0);

end architecture RTL;