library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package eeduro_pkg is

	constant drive_count		: integer	:= 4;

	type enc_t is record
		a : std_logic;
		b : std_logic;
		i : std_logic;
	end record enc_t;
	
	type bridge_t is record
		pwm_a	: std_logic;
		pwm_b	: std_logic;
		i_lim	: std_logic_vector(1 downto 0);
	end record bridge_t;

	type bridge_ctrl_t is record
		reset	: std_logic;
		decay	: std_logic;
		sleep	: std_logic;
	end record bridge_ctrl_t;

	type enc_block_t is array( 0 to (drive_count-1) ) of enc_t;
	type bridge_block_t is array( 0 to (drive_count-1) ) of bridge_t;
	type bridge_ctrl_block_t is array( 0 to (drive_count/2-1) ) of bridge_ctrl_t;

	constant bridge_default			: bridge_t		:= ( '0', '0', "00" );
	constant bridge_ctrl_default	: bridge_ctrl_t	:= ( '1', '0', '0' );

	constant bridge_block_default		: bridge_block_t		:= ( bridge_default, bridge_default, bridge_default, bridge_default );
	constant bridge_ctrl_block_default	: bridge_ctrl_block_t	:= ( bridge_ctrl_default, bridge_ctrl_default );

end package eeduro_pkg;
