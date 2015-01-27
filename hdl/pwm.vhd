library IEEE;
use IEEE.std_logic_1164.all;

package pwm_pkg is

	component pwm
		generic
		(
			width		: integer	:= 16;
			frequency	: real		:= 25000.0
		);
		port
		(
			clk		: in	std_logic;
			duty	: in	std_logic_vector( width-1 downto 0 ); 
			y		: out	std_logic
		);
	end component pwm;
	
end package pwm_pkg;


------ entity ------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.time_pkg.all;

entity pwm is
	generic
	(
		width		: integer	:= 16;
		frequency	: real		:= 25000
	);
	port
	(
		clk		: in	std_logic;
		duty	: in	std_logic_vector( width-1 downto 0 ); 
		y		: out	std_logic
	);
end entity pwm;

architecture rtl of pwm is

	constant k : integer := integer( real(clock_frequency) / frequency );
	constant inc : integer := integer( 2**width / k );

	signal ramp		: unsigned( width-1 downto 0 ) := (others => '0');

begin

	S: process(clk)
	begin
		if (rising_edge(clk)) then
			ramp <= ( ramp + inc );
		end if;
	end process S;

	G: process(ramp, duty)
	begin
		if ( ramp <= unsigned(duty) ) then
			y <= '1';
		else
			y <= '0';
		end if;
	end process G;

end architecture rtl;
