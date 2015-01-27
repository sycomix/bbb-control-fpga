library IEEE;
use IEEE.std_logic_1164.all;

package syncv_pkg is

	component syncv
		generic ( width : integer := 16; level : integer := 1 );
		port
		(
			clk	: in	std_logic;
			d	: in	std_logic_vector(width-1 downto 0); 
			q	: out	std_logic_vector(width-1 downto 0)
		);
	end component syncv;
	
end package syncv_pkg;

--------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity syncv is
	generic ( width : integer := 16; level : integer := 3 );
	port
	(
		clk	: in	std_logic;
		d	: in	std_logic_vector(width-1 downto 0); 
		q	: out	std_logic_vector(width-1 downto 0)
	);
end entity syncv;

architecture rtl of syncv is

	type reg_t is array(0 to level-1) of std_logic_vector(width-1 downto 0);
	constant reg_t_default : reg_t := (others => (others => '0'));
	signal r : reg_t := reg_t_default;

begin

	S: process(clk)
		variable v : reg_t := reg_t_default;
	begin
		if (rising_edge(clk)) then
			v := r;
			q <= r(0);
			if (level > 1) then
				for i in 1 to (level-1) loop
					v(i-1) := v(i);
				end loop;
			end if;
			v(level-1) := d;
			r <= v;
		end if;
	end process S;

end architecture rtl;
