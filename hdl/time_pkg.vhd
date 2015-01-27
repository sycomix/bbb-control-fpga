library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package time_pkg is

	-- 250 MHz
--	constant clock_frequency	: integer	:= 250000000;
--	constant sec				: integer	:= 250000000;
--	constant msec				: integer	:= 250000;
--	constant usec				: integer	:= 250;

	-- 48 MHz
	constant clock_frequency	: integer	:= 48000000;
	constant sec				: integer	:= 48000000;
	constant msec				: integer	:= 48000;
	constant usec				: integer	:= 48;

end package time_pkg;
