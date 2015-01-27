-- msbfirst = '0' does not work

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package spi_slave_pkg is

	component spi_slave
		generic ( width : integer := 32 );
		port
		(
			clk 		: in	std_logic;

			cs			: in	std_logic;
			sck			: in	std_logic;
			mosi		: in	std_logic;
			miso		: out	std_logic;

			tx			: in	std_logic_vector( width-1 downto 0 );
			rx			: out	std_logic_vector( width-1 downto 0 );
			trg			: out	std_logic;

			cpol		: in	std_logic	:= '1';
			cpha		: in	std_logic	:= '0';
			msbfirst	: in	std_logic	:= '1'
		);
	end component spi_slave;

end package spi_slave_pkg;


------ entity ------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity spi_slave is
	generic ( width : integer := 32 );
	port
	(
		clk 		: in	std_logic;

		cs			: in	std_logic;
		sck			: in	std_logic;
		mosi		: in	std_logic;
		miso		: out	std_logic;

		tx			: in	std_logic_vector( width-1 downto 0 );
		rx			: out	std_logic_vector( width-1 downto 0 );
		trg			: out	std_logic;

		cpol		: in	std_logic	:= '1';
		cpha		: in	std_logic	:= '0';
		msbfirst	: in	std_logic	:= '1'
	);
end spi_slave;

architecture rtl of spi_slave is

	type reg_t is record
		cs		: std_logic;
		sck		: std_logic;
		trg		: std_logic;
		tx		: std_logic_vector( width downto 0 );
		rx		: std_logic_vector( width-1 downto 0 );
	end record reg_t;

	constant reg_default : reg_t :=
	(
		'1', -- cs
		'0', -- sck
		'0', -- trg
		(others => '0'), -- tx
		B"0000_0000_0011_0011_0000_0000_0000_0000" -- rx
	);

	signal r		: reg_t := reg_default;
	signal r_next	: reg_t := reg_default;

begin

	S: process (clk)
	begin
		if ( rising_edge(clk) ) then
			r <= r_next;
		end if;
	end process S;

	F: process(r, cs, sck, mosi, cpol, cpha, tx)
		variable v : reg_t;
	begin
		v := r;

		if ( v.cs = '0' ) then -- cs low: enabled
			if ( cs = '1' ) then
				-- cs rising edge: disable
				v.trg := '1';
			else
				-- cs low: enabled
				if (v.sck /= sck) then
					if (sck = cpol) then
						-- setup
						v.tx := ( v.tx( width-1 downto 0 ) & "0" );
					else
						-- sample
						v.rx := ( v.rx( width-2 downto 0 ) & mosi );
					end if;
				end if;
			end if;
		else
			if ( cs = '0' ) then
				-- cs falling edge: enable
				v.rx := ( others => '0' );
				if ( cpha = '0' ) then
					v.tx := ( tx & "0" );
				else
					v.tx := ( "0" & tx );
				end if;
			else
				-- cs high: disabled
				v.trg := '0';
			end if;
		end if;

		v.cs := cs;
		v.sck := sck;

		r_next <= v;
	end process F;

	G: process ( r, cs )
	begin
		if ( cs = '0' ) then
			miso <= r.tx(width);
		else
			miso <= 'Z';
		end if;
		rx  <= r.rx;
		trg <= r.trg;
	end process G;

end rtl;
