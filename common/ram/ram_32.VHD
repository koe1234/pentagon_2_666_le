LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ram IS
	PORT
	(
		clock			: IN  std_logic;
		data			: IN  std_logic_vector(15 DOWNTO 0);
		write_address			: IN  std_logic_vector(8 DOWNTO 0);
		read_address			: IN  std_logic_vector(8 DOWNTO 0);
		we			: IN  std_logic;
		q			: OUT std_logic_vector(15 DOWNTO 0)
	);
END ram;

ARCHITECTURE rtl OF ram IS
	TYPE RAM IS ARRAY(0 TO 511) OF std_logic_vector(15 DOWNTO 0);

	SIGNAL ram_block : RAM;
BEGIN
	PROCESS (clock)
	BEGIN
		IF (clock'event AND clock = '1') THEN
			IF (we = '0') THEN
			    ram_block(to_integer(unsigned(write_address))) <= data;
			END IF;

			q <= ram_block(to_integer(unsigned(read_address)));
		END IF;
	END PROCESS;
END rtl;
