LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ram_cmos IS
	PORT
	(
		clock			: IN  std_logic;
		data			: IN  std_logic_vector(7 DOWNTO 0);
		address		: IN  std_logic_vector(7 DOWNTO 0);
		we				: IN  std_logic;
		q				: OUT std_logic_vector(7 DOWNTO 0)
	);
END ram_cmos;

ARCHITECTURE rtl OF ram_cmos IS
	TYPE RAM IS ARRAY(0 TO 255) OF std_logic_vector(7 DOWNTO 0);

	SIGNAL ram_block : RAM;
BEGIN
	PROCESS (clock)
	BEGIN
		IF (clock'event AND clock = '1') THEN
			IF (we = '0') THEN
			    ram_block(to_integer(unsigned(address))) <= data;
			END IF;

			q <= ram_block(to_integer(unsigned(address)));
		END IF;
	END PROCESS;
END rtl;
