-- Version: v11.2 11.2.0.26

library ieee;
use ieee.std_logic_1164.all;
library proasic3;
use proasic3.all;

entity pll250 is

    port( POWERDOWN : in    std_logic;
          CLKA      : in    std_logic;
          LOCK      : out   std_logic;
          GLA       : out   std_logic
        );

end pll250;

architecture DEF_ARCH of pll250 is 

  component PLL
    generic (VCOFREQUENCY:real := 0.0);

    port( CLKA      : in    std_logic := 'U';
          EXTFB     : in    std_logic := 'U';
          POWERDOWN : in    std_logic := 'U';
          GLA       : out   std_logic;
          LOCK      : out   std_logic;
          GLB       : out   std_logic;
          YB        : out   std_logic;
          GLC       : out   std_logic;
          YC        : out   std_logic;
          OADIV0    : in    std_logic := 'U';
          OADIV1    : in    std_logic := 'U';
          OADIV2    : in    std_logic := 'U';
          OADIV3    : in    std_logic := 'U';
          OADIV4    : in    std_logic := 'U';
          OAMUX0    : in    std_logic := 'U';
          OAMUX1    : in    std_logic := 'U';
          OAMUX2    : in    std_logic := 'U';
          DLYGLA0   : in    std_logic := 'U';
          DLYGLA1   : in    std_logic := 'U';
          DLYGLA2   : in    std_logic := 'U';
          DLYGLA3   : in    std_logic := 'U';
          DLYGLA4   : in    std_logic := 'U';
          OBDIV0    : in    std_logic := 'U';
          OBDIV1    : in    std_logic := 'U';
          OBDIV2    : in    std_logic := 'U';
          OBDIV3    : in    std_logic := 'U';
          OBDIV4    : in    std_logic := 'U';
          OBMUX0    : in    std_logic := 'U';
          OBMUX1    : in    std_logic := 'U';
          OBMUX2    : in    std_logic := 'U';
          DLYYB0    : in    std_logic := 'U';
          DLYYB1    : in    std_logic := 'U';
          DLYYB2    : in    std_logic := 'U';
          DLYYB3    : in    std_logic := 'U';
          DLYYB4    : in    std_logic := 'U';
          DLYGLB0   : in    std_logic := 'U';
          DLYGLB1   : in    std_logic := 'U';
          DLYGLB2   : in    std_logic := 'U';
          DLYGLB3   : in    std_logic := 'U';
          DLYGLB4   : in    std_logic := 'U';
          OCDIV0    : in    std_logic := 'U';
          OCDIV1    : in    std_logic := 'U';
          OCDIV2    : in    std_logic := 'U';
          OCDIV3    : in    std_logic := 'U';
          OCDIV4    : in    std_logic := 'U';
          OCMUX0    : in    std_logic := 'U';
          OCMUX1    : in    std_logic := 'U';
          OCMUX2    : in    std_logic := 'U';
          DLYYC0    : in    std_logic := 'U';
          DLYYC1    : in    std_logic := 'U';
          DLYYC2    : in    std_logic := 'U';
          DLYYC3    : in    std_logic := 'U';
          DLYYC4    : in    std_logic := 'U';
          DLYGLC0   : in    std_logic := 'U';
          DLYGLC1   : in    std_logic := 'U';
          DLYGLC2   : in    std_logic := 'U';
          DLYGLC3   : in    std_logic := 'U';
          DLYGLC4   : in    std_logic := 'U';
          FINDIV0   : in    std_logic := 'U';
          FINDIV1   : in    std_logic := 'U';
          FINDIV2   : in    std_logic := 'U';
          FINDIV3   : in    std_logic := 'U';
          FINDIV4   : in    std_logic := 'U';
          FINDIV5   : in    std_logic := 'U';
          FINDIV6   : in    std_logic := 'U';
          FBDIV0    : in    std_logic := 'U';
          FBDIV1    : in    std_logic := 'U';
          FBDIV2    : in    std_logic := 'U';
          FBDIV3    : in    std_logic := 'U';
          FBDIV4    : in    std_logic := 'U';
          FBDIV5    : in    std_logic := 'U';
          FBDIV6    : in    std_logic := 'U';
          FBDLY0    : in    std_logic := 'U';
          FBDLY1    : in    std_logic := 'U';
          FBDLY2    : in    std_logic := 'U';
          FBDLY3    : in    std_logic := 'U';
          FBDLY4    : in    std_logic := 'U';
          FBSEL0    : in    std_logic := 'U';
          FBSEL1    : in    std_logic := 'U';
          XDLYSEL   : in    std_logic := 'U';
          VCOSEL0   : in    std_logic := 'U';
          VCOSEL1   : in    std_logic := 'U';
          VCOSEL2   : in    std_logic := 'U'
        );
  end component;

  component PLLINT
    port( A : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component INV
    port( A : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal POWERDOWNP, CLKAP, \VCC\, \GND\ : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;

    Core : PLL
      generic map(VCOFREQUENCY => 250.000)

      port map(CLKA => CLKAP, EXTFB => \GND\, POWERDOWN => 
        POWERDOWNP, GLA => GLA, LOCK => LOCK, GLB => OPEN, YB => 
        OPEN, GLC => OPEN, YC => OPEN, OADIV0 => \GND\, OADIV1
         => \GND\, OADIV2 => \GND\, OADIV3 => \GND\, OADIV4 => 
        \GND\, OAMUX0 => \GND\, OAMUX1 => \GND\, OAMUX2 => \VCC\, 
        DLYGLA0 => \GND\, DLYGLA1 => \GND\, DLYGLA2 => \GND\, 
        DLYGLA3 => \GND\, DLYGLA4 => \GND\, OBDIV0 => \GND\, 
        OBDIV1 => \GND\, OBDIV2 => \GND\, OBDIV3 => \GND\, OBDIV4
         => \GND\, OBMUX0 => \GND\, OBMUX1 => \GND\, OBMUX2 => 
        \GND\, DLYYB0 => \GND\, DLYYB1 => \GND\, DLYYB2 => \GND\, 
        DLYYB3 => \GND\, DLYYB4 => \GND\, DLYGLB0 => \GND\, 
        DLYGLB1 => \GND\, DLYGLB2 => \GND\, DLYGLB3 => \GND\, 
        DLYGLB4 => \GND\, OCDIV0 => \GND\, OCDIV1 => \GND\, 
        OCDIV2 => \GND\, OCDIV3 => \GND\, OCDIV4 => \GND\, OCMUX0
         => \GND\, OCMUX1 => \GND\, OCMUX2 => \GND\, DLYYC0 => 
        \GND\, DLYYC1 => \GND\, DLYYC2 => \GND\, DLYYC3 => \GND\, 
        DLYYC4 => \GND\, DLYGLC0 => \GND\, DLYGLC1 => \GND\, 
        DLYGLC2 => \GND\, DLYGLC3 => \GND\, DLYGLC4 => \GND\, 
        FINDIV0 => \VCC\, FINDIV1 => \VCC\, FINDIV2 => \VCC\, 
        FINDIV3 => \GND\, FINDIV4 => \VCC\, FINDIV5 => \GND\, 
        FINDIV6 => \GND\, FBDIV0 => \GND\, FBDIV1 => \GND\, 
        FBDIV2 => \VCC\, FBDIV3 => \VCC\, FBDIV4 => \VCC\, FBDIV5
         => \VCC\, FBDIV6 => \VCC\, FBDLY0 => \GND\, FBDLY1 => 
        \GND\, FBDLY2 => \GND\, FBDLY3 => \GND\, FBDLY4 => \GND\, 
        FBSEL0 => \VCC\, FBSEL1 => \GND\, XDLYSEL => \GND\, 
        VCOSEL0 => \GND\, VCOSEL1 => \VCC\, VCOSEL2 => \VCC\);
    
    pllint1 : PLLINT
      port map(A => CLKA, Y => CLKAP);
    
    invpdwn : INV
      port map(A => POWERDOWN, Y => POWERDOWNP);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 

-- _Disclaimer: Please leave the following comments in the file, they are for internal purposes only._


-- _GEN_File_Contents_

-- Version:11.2.0.26
-- ACTGENU_CALL:1
-- BATCH:T
-- FAM:PA3LC
-- OUTFORMAT:VHDL
-- LPMTYPE:LPM_PLL_STATIC
-- LPM_HINT:NONE
-- INSERT_PAD:NO
-- INSERT_IOREG:NO
-- GEN_BHV_VHDL_VAL:F
-- GEN_BHV_VERILOG_VAL:F
-- MGNTIMER:F
-- MGNCMPL:T
-- DESDIR:D:/abajric/eeduro/svn/Software/eeduro-fpga/smartgen\pll250
-- GEN_BEHV_MODULE:F
-- SMARTGEN_DIE:IS4X2M1
-- SMARTGEN_PACKAGE:vq100
-- AGENIII_IS_SUBPROJECT_LIBERO:T
-- FIN:48.000000
-- CLKASRC:2
-- FBDLY:1
-- FBMUX:1
-- XDLYSEL:0
-- PRIMFREQ:250.000000
-- PPHASESHIFT:0
-- DLYAVAL:1
-- OAMUX:4
-- POWERDOWN_POLARITY:1
-- LOCK_POLARITY:1
-- LOCK_CTL:0
-- VOLTAGE:1.5

-- _End_Comments_

