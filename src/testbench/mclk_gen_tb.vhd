library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mclk_gen_tb is
end mclk_gen_tb;

architecture behavior of mclk_gen_tb is 
    component mclk_gen
    port(
         sysclk : in  std_logic;
         mclk_out : out  std_logic
        );
    end component;
    
    signal sysclk : std_logic := '0';
    signal sysclk_counter : integer := 0;
    signal mclk_out : std_logic;
    signal mclk_counter : integer := 0;

    constant sysclk_period : time := 8 ns;          -- Corresponds to 125 MHz
    constant observation_period : time := 10 us;    -- Observation period

begin 
    uut: mclk_gen port map (
          sysclk => sysclk,
          mclk_out => mclk_out
        );
    sysclk_process : process
    begin
        sysclk <= '0';
        wait for sysclk_period/2;  
        sysclk <= '1';
        wait for sysclk_period/2;
    end process;
    
    count_sysclk_process : process(sysclk)
    begin
        if rising_edge(sysclk) then
            sysclk_counter <= sysclk_counter + 1;
        end if;
    end process;
    
    count_mclk_process : process(mclk_out)
    begin
        if rising_edge(mclk_out) then
            mclk_counter <= mclk_counter + 1;
        end if;
    end process;

    mclk_out_process : process
    variable mclk_frequency_mhz     : real; -- For MHz frequency estimation
    variable sysclk_frequency_mhz   : integer; -- For MHz frequency estimation
    begin
        wait for observation_period; -- wait for the observation period to end
        
        -- Calculate the actual frequency in MHz
        -- Multiply by 100 (to account for the 10 us period in a 1 second timeframe)
        -- This keeps the calculation in the integer domain
        sysclk_frequency_mhz := (sysclk_counter * 10000) / 100000;  -- Adjusting calculation for 10 us 
        mclk_frequency_mhz := real(mclk_counter) * 10000.0 / 100000.0;  -- Adjusting calculation for 10 us observation

        report "Measured system clock frequency:" & integer'image(sysclk_frequency_mhz) & " MHz" severity note;
        report "Measured master clock frequency:" & real'image(mclk_frequency_mhz) & " MHz" severity note;
        --assert false report "end of simulation" severity failure; -- end the simulation
    end process;

end behavior;
