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
    
    component ac_audio is   
        Port (
            clk          : in std_logic;
            ac_recdat    : in std_logic;
            int_sample   : out std_logic_vector(15 downto 0)
        );
    end component;
    
    component ac_control
        Port (
            clk                 : in STD_LOGIC;
            enable              : in STD_LOGIC;
            audio_in            : in STD_LOGIC_VECTOR(15 downto 0);
            audio_out           : out std_logic
        );
    end component;
    
    signal int_sample : std_logic_vector(15 downto 0);
    signal s_mclk : std_logic;

begin
    -- Start SSM2603 in master mode
    i2cConf: i2c_configurator port map(
        sysclk=>sysclk,
        rst=>btn(0),
        scl=>ac_scl,
        sda=>ac_sda
    );
    
    ac_muten <= sw(0);   -- mute switch
    led6_r <= not sw(0); -- red when muted

    -- Implementation here
    codecMCLKGen: mclk_gen port map(
        sysclk=>sysclk,
        mclk_out=>s_mclk
    );
    
    codecAudio: ac_audio port map(
        clk => s_mclk,
        ac_recdat => ac_recdat,
        int_sample => int_sample
    );
    
    codecControl: ac_control Port Map (
        clk => s_mclk,
        enable => sw(1),
        audio_in => int_sample,
        audio_out => ac_pbdat
    );
    ac_mclk <= s_mclk;
    ac_bclk <= s_mclk;
end Behavioral;
