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
        ac_pbdat    : out std_logic; -- Playback data
        ac_pblrc    : out std_logic; -- Playback channel clock, LEFT (0) or RIGHT (1)
        ac_recdat   : in std_logic;  -- Record data, unpack audio signals from this
        ac_reclrc   : out std_logic; -- Record channel clock
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

component mclk_gen
    Port (
        sysclk      : in std_logic;
        mclk_out    : out std_logic
    );
end component;

signal mclk     : std_logic;

begin
    -- Start SSM2603 in master mode
    i2cConf: i2c_configurator port map(sysclk, btn(0), ac_scl, ac_sda);    
    
    codecMCLKGen: mclk_gen port map(sysclk, mclk)
    
    ac_muten <= sw(0);   -- mute switch
    led6_r <= not sw(0); -- red when muted

    -- Implementation here


end Behavioral;
