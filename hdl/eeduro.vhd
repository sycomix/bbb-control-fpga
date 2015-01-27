library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package eeduro_pkg is

	constant drive_count : integer := 4;

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

	component eeduro
		port
		(
    		clk		: in	std_logic;
	    	clkfqd	: in	std_logic;
	    	reset	: in	std_logic;

			cs		: in	std_logic;
			sck		: in	std_logic;
			mosi	: in	std_logic;
			miso	: out	std_logic;

			ctrl	: out	bridge_ctrl_block_t;
			bridge	: out	bridge_block_t;
			fault	: in	std_logic_vector(1 downto 0);

			enc		: in	enc_block_t;

			power	: out	std_logic_vector(1 downto 0);

			button	: in	std_logic_vector(2 downto 0);
			led		: out	std_logic_vector(3 downto 0);

			enable	: out	std_logic_vector(drive_count-1 downto 0)
		);
	end component eeduro;

end package eeduro_pkg;


------ entity ------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.eeduro_pkg.all;
use work.sync_pkg.all;
use work.spi_slave_pkg.all;
use work.fqd_pkg.all;
use work.pwm_pkg.all;

entity eeduro is
	port
	(
    	clk		: in	std_logic;
    	clkfqd	: in	std_logic;
    	reset	: in	std_logic;

		cs		: in	std_logic;
		sck		: in	std_logic;
		mosi	: in	std_logic;
		miso	: out	std_logic;

		ctrl	: out	bridge_ctrl_block_t;
		bridge	: out	bridge_block_t;
		fault	: in	std_logic_vector(1 downto 0);

		enc		: in	enc_block_t;

		power	: out	std_logic_vector(1 downto 0);

		button	: in	std_logic_vector(2 downto 0);
		led		: out	std_logic_vector(3 downto 0);

		enable	: out	std_logic_vector(drive_count-1 downto 0)
	);
end eeduro;


architecture rtl of eeduro is

	type pwm_duty_t is array(0 to drive_count-1) of std_logic_vector(15 downto 0);
	signal pwm_sig : std_logic_vector( drive_count-1 downto 0 );


	type enc_counter_block_t is array(0 to drive_count-1) of unsigned(15 downto 0);
	signal enc_counter : enc_counter_block_t;

	signal cs_sync		: std_logic;
	signal sck_sync		: std_logic;
	signal mosi_sync	: std_logic;

	signal trg	: std_logic;
	signal rx	: std_logic_vector(31 downto 0);

--	type motor_t is record
--		enalbe	: std_logic;
--		duty	: std_logic_vector(15 downto 0);
--	end record motor_t;
--	type motor_block_t is array (0 to drive_count-1) of motor_t;

	type bridge_limit_block_t is array (0 to drive_count-1) of std_logic_vector(1 downto 0);

	type reg_t is record
		tx		: std_logic_vector(31 downto 0);
		dir		: std_logic_vector(drive_count-1 downto 0);
		axis	: std_logic_vector(3 downto 0);
		led		: std_logic_vector(3 downto 0);
		enable	: std_logic_vector(drive_count-1 downto 0);
		power	: std_logic_vector(1 downto 0);
		reset	: std_logic_vector(1 downto 0);
		lim		: bridge_limit_block_t;
--		motor	: motor_block_t;
		pwm_duty : pwm_duty_t;
	end record reg_t;

	constant reg_default : reg_t :=
	(
		(others => '0'), -- tx
		(others => '1'), -- dir
		(others => '0'), -- axis
		(others => '0'), -- led
		(others => '0'), -- enable
		(others => '0'), -- power
		(others => '1'), -- reset
		( others => (others => '0') ), -- lim
--		( others => ( '00, others => '0') ), -- motor
		( others => (others => '0') )  -- pwm_duty
	);

	signal last_trg : std_logic;

	signal r		: reg_t := reg_default;
	signal r_next	: reg_t := reg_default;

	signal init	: std_logic := '1';

begin

	power  <= r.power;
	led    <= r.led;

	ctrl: for i in 0 to drive_count/2-1
	generate
		ctrl(i).reset <= r.reset(i);
		ctrl(i).decay <= '0';
		ctrl(i).sleep <= '0';
	end generate;

	bridge: for i in 0 to drive_count-1
	generate
		enable(i) <= r.enable(i);
		bridge(i).pwm_a <= r.enable(i) and ( pwm_sig(i) and      r.dir(i)  );
		bridge(i).pwm_b <= r.enable(i) and ( pwm_sig(i) and (not r.dir(i)) );
		bridge(i).i_lim <= "00";
	end generate;

----------------------------------------------------------------------

	fqd: for i in 0 to drive_count-1
	generate
		fqdi: fqd
		generic map ( gi_pos_length => 16 )
		port map
		(
			isl_clk			=> clkfqd,
			isl_reset_n		=> not reset,
			isl_enc_A		=> enc(i).a,
			isl_enc_B		=> enc(i).b,
			ousig_pos		=> enc_counter(i)
		);
	end generate;

	pwm: for i in 0 to drive_count-1
	generate
		pwmi: pwm
		generic map ( width => 16 )
		port map
		(
			clk		=> clk,
			duty	=> r.pwm_duty(i),
			y		=> pwm_sig(i)
		);
	end generate;

----------------------------------------------------------------------

	-- synchronization
	sync_cs:	sync port map( clk, cs,   cs_sync );
	sync_sck:	sync port map( clk, sck,  sck_sync );
	sync_mosi:	sync port map( clk, mosi, mosi_sync );

	spi: spi_slave
	generic map ( width => 32 )
	port map
	(
		clk		=> clk,

		cs		=> cs_sync,
		sck		=> sck_sync,
		mosi	=> mosi_sync,
		miso	=> miso,

		tx		=> r.tx,
		rx		=> rx,
		trg		=> trg
	);


	S: process (clk)
		variable v : reg_t;
	begin
		v := r;

		if (rising_edge(clk)) then
			if (init = '1' or reset = '1') then
				v.tx       := (others => '0');
				v.dir      := (others => '0');
				v.axis     := (others => '0');
				v.led      := (others => '0');
				v.enable   := (others => '0');
				v.power    := (others => '0');
				v.reset    := (others => '1');
				v.lim      := (others => (others => '0'));
				v.pwm_duty := (others => (others => '0'));

				r <= v;
				init <= '0';
			else
				if (last_trg = '0' and trg = '1') then
					r <= r_next;
				end if;
			end if;
			last_trg <= trg;
		end if;
	end process;


	F: process (r, rx, button, fault)
		variable v : reg_t;
		variable i : integer;
	begin
		v := r;
		i := to_integer(unsigned(v.axis));

		v.tx := (others => '0');

		v.tx(31 downto 28) := v.axis;
		v.tx(22 downto 20) := button;
		v.tx(17 downto 16) := v.power;

		if ( i >= 0 and i <= 3 ) then
			v.tx(15 downto 0) := enc_counter(i);
--			v.tx(15 downto 0) := v.pwm_duty(i);

			v.tx(27) := v.enable(i);
			v.tx(26) := v.dir(i);
			if ( i >= 0 and i <= 1 ) then
				-- bridge 01
				v.tx(25) := fault(0);
				v.tx(19 downto 18) := v.lim(0);
			else
				-- bridge 23
				v.tx(25) := fault(1);
				v.tx(19 downto 18) := v.lim(1);
			end if;
		else
			v.tx(15 downto 0)  := (others => '0');
			v.tx(27) := '0';
			v.tx(26) := '0';
			v.tx(25) := '1';
			v.tx(19 downto 18) := (others => '1');
		end if;

		-----------------------------------------------

		v.axis  := rx(31 downto 28);
		v.led   := rx(25 downto 22);
		v.reset := rx(21 downto 20);
		v.power := rx(17 downto 16);

		i := to_integer(unsigned(v.axis));

		if ( i >= 0 and i <= 3 ) then
			v.enable(i) := rx(27);
			v.dir(i)    := rx(26);

			if ( v.enable(i) = '1' ) then
				v.pwm_duty(i) := rx(15 downto 0);
			else
				v.pwm_duty(i) := (others => '0');
			end if;

			if ( i >= 0 and i <= 1 ) then
				-- bridge 01
				v.lim(0) := rx(19 downto 18);
			else
				-- bridge 23
				v.lim(1) := rx(19 downto 18);
			end if;
		end if;

		r_next <= v;
	end process F;

end rtl;
