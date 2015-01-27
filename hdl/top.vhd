library IEEE;
use IEEE.std_logic_1164.all;

use work.eeduro_pkg.all;


entity top is
	port
	(
    	clk48			: in	std_logic;
		clk_en			: out	std_logic;
    	reset			: in	std_logic;

		-- SPI:
		cs				: in	std_logic;
		sck				: in	std_logic;
		mosi			: in	std_logic;
		miso			: out	std_logic;

		-- I2C:
--		sda				: inout	std_logic;
--		scl				: in	std_logic;

		enc_a			: in	std_logic_vector(3 downto 0);
		enc_b			: in	std_logic_vector(3 downto 0);
		enc_i			: in	std_logic_vector(3 downto 0);

		bridge_pwm_a	: out	std_logic_vector(3 downto 0);
		bridge_pwm_b	: out	std_logic_vector(3 downto 0);
		bridge_i_lim_h	: out	std_logic_vector(3 downto 0);
		bridge_i_lim_l	: out	std_logic_vector(3 downto 0);

		bridge_fault	: in	std_logic_vector(1 downto 0);
		bridge_reset	: out	std_logic_vector(1 downto 0);
		bridge_decay	: out	std_logic_vector(1 downto 0);
		bridge_sleep	: out	std_logic_vector(1 downto 0);

--		-- BeagleBone Black
--		bbb_not_reset	: in	std_logic;
--		bbb_power		: in	std_logic;
--
		not_power_out	: out	std_logic_vector(1 downto 0);
--
--		gpio			: inout	std_logic_vector(15 downto 0);

		button			: in	std_logic_vector(2 downto 0);

		led				: out	std_logic_vector(3 downto 0);
		led_clone		: out	std_logic_vector(2 downto 0)
	);
end top;


architecture rtl of top is

	signal enc			: enc_block_t;
	signal bridge		: bridge_block_t		:= bridge_block_default;
	signal bridge_ctrl	: bridge_ctrl_block_t	:= bridge_ctrl_block_default;

	signal power  : std_logic_vector(1 downto 0);
	signal enable : std_logic_vector(drive_count-1 downto 0);

	signal clk250 : std_logic;
	signal locked : std_logic;
	component pll250
	    port
		(
			POWERDOWN	: in	std_logic;
			CLKA		: in	std_logic;
			LOCK		: out	std_logic;
			GLA			: out	std_logic
        );
	end component pll250;

begin

	not_power_out <= not power;

	led(0) <= not ( (bridge_fault(0)) and not bridge_ctrl(0).reset and enable(0) );
	led(1) <= not ( (bridge_fault(0)) and not bridge_ctrl(0).reset and enable(1) );
--	led(2) <= not ( (bridge_fault(1)) and not bridge_ctrl(1).reset and enable(2) );
--	led(3) <= not ( (bridge_fault(1)) and not bridge_ctrl(1).reset and enable(3) );
	led(2) <= not locked;
	led(3) <= not clk250;

--	led_clone(0) <= not ( (bridge_fault(0)) and not bridge_ctrl(0).reset and enable(0) );
--	led_clone(1) <= not ( (bridge_fault(0)) and not bridge_ctrl(0).reset and enable(1) );
--	led_clone(2) <= not ( (bridge_fault(1)) and not bridge_ctrl(1).reset and enable(2) );

	pll: pll250 port map ( '0', clk48, locked, clk250 );


	bridge_connections: for i in 0 to 3 generate
		enc(i).a <= enc_a(i);
		enc(i).b <= enc_b(i);
		enc(i).i <= enc_i(i);

		bridge_pwm_a(i)   <= bridge(i).pwm_a;
		bridge_pwm_b(i)   <= bridge(i).pwm_b;
		bridge_i_lim_l(i) <= bridge(i).i_lim(0);
		bridge_i_lim_h(i) <= bridge(i).i_lim(1);
	end generate bridge_connections;

	bridge_ctrl_connections: for i in 0 to 1 generate
		bridge_reset(i) <= not bridge_ctrl(i).reset;
		bridge_decay(i) <=     bridge_ctrl(i).decay;
		bridge_sleep(i) <= not bridge_ctrl(i).sleep;
	end generate bridge_ctrl_connections;

-----------------------------------------------------------------------------------------------------


	-- enable external oscillator
	clk_en <= '1';

	-- main component
	main: eeduro
	port map
	(
		clk		=> clk48,
		clkfqd	=> clk48,
		reset	=> not reset,

		cs		=> cs,
		sck		=> sck,
		mosi	=> mosi,
		miso	=> miso,

		ctrl	=> bridge_ctrl,
		bridge	=> bridge,
		fault	=> not bridge_fault,

		enc		=> enc,

		power	=> power,
		button	=> not button,
		led(0)	=> led_clone(0),
		led(1)	=> led_clone(1),
		led(2)	=> led_clone(2),
		enable	=> enable
	);

end rtl;
