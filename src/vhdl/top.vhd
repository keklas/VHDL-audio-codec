library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port (
        btn         : in std_logic_vector(3 downto 0);
        sw          : in std_logic_vector(3 downto 0);
        led6_r      : out std_logic;
        
        sysclk      : in std_logic;
        ac_bclk     : out std_logic;
        ac_mclk     : out std_logic;
        ac_muten    : out std_logic;
        
        -- HANDLE THESE VARIABLES --
        ac_pbdat    : out std_logic;
        ac_pblrc    : out std_logic;
        ac_recdat   : in std_logic;  -- Unpack audio signals from this
        ac_reclrc   : out std_logic;
        -- HANDLE THESE VARIABLES --
        -- Create a signal that's 16 bits long
        -- Collect data into the signal
        -- Perform transformations
        -- Write back to the codec
        
        ac_scl      : out std_logic;
        ac_sda      : inout std_logic
        
        );
end top;

architecture Behavioral of top is

component i2c_configurator
    Port (
        sysclk  : in std_logic;
        rst     : in std_logic;
        scl     : out std_logic;
        sda     : inout std_logic
    );
end component;

signal clk_mclk : std_logic := '0'; -- SSM2603 MCLK. 12.5 MHz
signal clk_bclk : std_logic := '0'; -- SSM2603 BCLK. 3.125 MHz

begin

    i2cConf: i2c_configurator port map(sysclk, btn(0), ac_scl, ac_sda);    
    
    -- The SSM2603 needs mclk to work. Maximum frequency is about 18 MHz.
    -- Let's divide the 125 MHz clock by 10.
    codecMCLKClockGen: process(sysclk)
        constant cnt_max : integer := 10/2;
        variable cnt : integer range 0 to cnt_max := 0; 
    begin
        if rising_edge(sysclk) then
            if btn(0) = '1' then
                cnt := 0;
            end if;
            
            if cnt < cnt_max-1 then
                cnt := cnt + 1;
            else
                cnt := 0;
                clk_mclk <= not clk_mclk;
            end if;
        end if;
    end process;
    
    -- For 48kHz in/out the BCLK must be MCLK/4
    codecBCLKClockGen: process(clk_mclk)
        constant cnt_max : integer := 4/2;
        variable cnt : integer range 0 to cnt_max := 0; 
    begin
        if rising_edge(clk_mclk) then
            if btn(0) = '1' then
                cnt := 0;
            end if;
            
            if cnt < cnt_max-1 then
                cnt := cnt + 1;
            else
                cnt := 0;
                clk_bclk <= not clk_bclk;
            end if;
        end if;
    end process;
    
    ac_mclk <= clk_mclk;
    ac_bclk <= clk_bclk;
    
    ac_muten <= sw(0);   -- mute switch
    led6_r <= not sw(0); -- red when muted

end Behavioral;
