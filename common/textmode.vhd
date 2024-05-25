library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity textmode is
  port (
    
    pixel_clock         : in std_logic;
    main_state_counter          : in std_logic_vector(1 downto 0);

    pixel_c             : in std_logic_vector(9 downto 0);
    line_c              : in std_logic_vector(9 downto 0);
    
    textbuffer_rd_addr  : out std_logic_vector(12 downto 0);
    textbuffer_clk      : out std_logic; 
    
    textbuffer_data_out : in std_logic_vector(7 downto 0); 
    
    textmode_r          : out std_logic_vector(1 downto 0);
    textmode_g          : out std_logic_vector(1 downto 0);
    textmode_b          : out std_logic_vector(1 downto 0)
        
    
);
end;

architecture koe_koe of textmode is

component ram
  port (
        clock           : IN  std_logic;
        data            : IN  std_logic_vector(15 DOWNTO 0);
        write_address   : IN  std_logic_vector(4 DOWNTO 0);
        read_address    : IN  std_logic_vector(4 DOWNTO 0);
        we              : IN  std_logic;
        q               : OUT std_logic_vector(15 DOWNTO 0)

);
end component;

component ram_border
  port (
        clock           : IN  std_logic;
        data            : IN  std_logic_vector(3 DOWNTO 0);
        write_address           : IN  std_logic_vector(8 DOWNTO 0);
        read_address            : IN  std_logic_vector(8 DOWNTO 0);
        we          : IN  std_logic;
        q           : OUT std_logic_vector(3 DOWNTO 0)
    );
end component;

component fnt_rom
port
    (
        address     : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        clock       : IN STD_LOGIC ;
        q       : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
end component;

signal text_mojno           : std_logic;
signal scr_data_buffer      : std_logic_vector(7 downto 0);
signal text_data            : std_logic_vector(7 downto 0);
signal textbuffer_addr_dobavka: std_logic_vector(12 downto 0);
signal fnt_rom_clk          : std_logic; 
signal fnt_data_addr        : std_logic_vector(10 downto 0);
signal trtextdata           : std_logic;
signal txt_attr             : std_logic_vector(7 downto 0);


begin

process (pixel_clock, main_state_counter, pixel_c, line_c)
begin
    if (pixel_clock'event and pixel_clock = '1') then 
    

-- текстовой режим
--
--    0   128                         768 896 
--   0+-----------------------------------+
--    |///////////////////////////////////|
-- 128|///+---------------------------+///|
--    |///|                           |///|
--    |///|     bla-bla-bla           |///|
--    |///|                           |///|
-- 512|///+---------------------------+///|
--    |///////////////////////////////////|     
-- 640+-----------------------------------+
--
-- (896-2*128)/8=80 символов в текстовой строке,
-- (640-2*128)/16=24 строки в экране    
--
-- адрес байта данных в текстовом буфере = (80*(номер строки)+(координата_x-128)/8)
-- 80*(номер строки) = textbuffer_addr_dobavka
-- (координата_x-128)/8 = pixel_c(6 downto 3) (без 7-го разряда)
--
-- text mode attributes
-- 7654  3210
-- ibgr  ibgr
-- paper ink
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------


    if (main_state_counter= b"11") then 
        if (pixel_c > 129 and pixel_c < 769 and line_c > 63 and line_c < 576)--127 768
            then text_mojno <= '0';
                else text_mojno <= '1';
        end if;
    
        if (pixel_c(2 downto 0) = b"010") --111
            then scr_data_buffer(7 downto 0) <= text_data(7 downto 0);
                else scr_data_buffer(7 downto 1) <= scr_data_buffer(6 downto 0);
        end if;
    
        if (line_c < 64 or line_c > 576) 
            then textbuffer_addr_dobavka <= (others => '0');
                else
                    if ((line_c(3 downto 0) = b"1111") and (pixel_c = 768))
                        then textbuffer_addr_dobavka(12 downto 0) <= textbuffer_addr_dobavka(12 downto 0) + b"000001010000"; 
                    end if;
        end if; 
    end if; 
    
        if (pixel_c(2 downto 0) = b"010")--111
            then
                case (main_state_counter) is
                    when b"00" => textbuffer_rd_addr(12 downto 0) <= pixel_c(9 downto 3) - b"1111" + textbuffer_addr_dobavka(12 downto 0); --буковки
                    when b"01" => textbuffer_clk <= '1'; 
                    when b"10" => textbuffer_clk <= '0'; fnt_rom_clk <= '1';
                                textbuffer_rd_addr(12 downto 0) <= b"101000000000" + pixel_c(9 downto 3) - b"1111" + textbuffer_addr_dobavka(12 downto 0); -- атрибуты
                    when b"11" => fnt_rom_clk <= '0'; textbuffer_clk <= '1'; 
                    when others => null;
                end case;
            elsif (pixel_c(2 downto 0) = b"011") then txt_attr(7 downto 0) <= textbuffer_data_out(7 downto 0); 
        textbuffer_clk <= '0'; --000
        end if; 
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

end if;
end process;

trtextdata <= scr_data_buffer(7);

process (text_mojno, trtextdata, txt_attr)
begin
    case (text_mojno) is
        when '0' =>
            case trtextdata is
                when '1' =>
                    textmode_r(1) <= txt_attr(3);
                    textmode_r(0) <= txt_attr(0);
                    textmode_g(1) <= txt_attr(3);
                    textmode_g(0) <= txt_attr(1);
                    textmode_b(1) <= txt_attr(3);
                    textmode_b(0) <= txt_attr(2);
                when '0' =>
                    textmode_r(1) <= txt_attr(7);
                    textmode_r(0) <= txt_attr(4);
                    textmode_g(1) <= txt_attr(7);
                    textmode_g(0) <= txt_attr(5);
                    textmode_b(1) <= txt_attr(7);
                    textmode_b(0) <= txt_attr(6);   
            end case;
        when '1' => textmode_r(1 downto 0) <= b"00";
                    textmode_g(1 downto 0) <= b"00";
                    textmode_b(1 downto 0) <= b"00";
        when others => null;
    end case;
end process;

fnt_data_addr(10 downto 3) <= textbuffer_data_out(7 downto 0);
fnt_data_addr(2 downto 0) <= line_c(3 downto 1); -- адрес байта данных, выводимых на экран

fontbuffer: fnt_rom port map (fnt_data_addr(10 downto 0), fnt_rom_clk, text_data(7 downto 0));

end koe_koe;
