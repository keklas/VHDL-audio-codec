library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;

entity top_tb is
end entity;

architecture Behavioral of top_tb is
    signal s_btn: std_logic_vector(3 downto 0) := (others => '0');
    signal s_sw: std_logic_vector(3 downto 0) := (others => '0');
    signal s_r_led : std_logic;     
    signal s_sysclk, s_ac_bclk, s_ac_mclk, s_ac_muten, s_ac_pbdat, s_ac_recdat, s_ac_scl, s_ac_sda, s_ac_reclrc, s_ac_pblrc: std_logic := 'Z';
    signal reclrc, pblrc, csv_mclk: std_logic := '0';
    signal count : INTEGER range 0 to 249 := 0;
    file input_buf : text;   
    
    begin
        uut: entity work.top port map(
            btn => s_btn,
            sw => s_sw,
            led6_r => s_r_led,
            sysclk => s_sysclk,
            ac_bclk => s_ac_bclk,
            ac_mclk => s_ac_mclk,
            ac_muten => s_ac_muten,
            ac_pbdat => s_ac_pbdat,
            ac_pblrc => s_ac_pblrc,
            ac_recdat => s_ac_recdat,
            ac_reclrc => s_ac_reclrc,
            ac_scl => s_ac_scl,
            ac_sda => s_ac_sda
            );
      
        s_ac_scl <= 'H';
        s_ac_sda <= 'H';
        
        -- 125 MHz sysclock
        sysclockGen: process begin
            s_sysclk <= '0';
            wait for 4ns;
            s_sysclk <= '1';
            wait for 4ns;
        end process;
        
        -- Generate PBLRC and RECLRC clocks = MCLK / 250
        reclrcGen: process(s_ac_mclk) begin
            if rising_edge(s_ac_mclk) then
                if count = 249 then
                    reclrc <= NOT reclrc;
                    pblrc <= NOT pblrc;
                    count <= 0;
                else
                    count <= count + 1;
                end if;
            end if;                    
        end process;
        
        -- Simulate mute switch
        testMute: process begin
            s_sw(0) <= '0';
            wait for 1ms;
            s_sw(0) <= '1';
            wait;
        end process;
        
        -- Simulate enable switch
        testEnable: process begin
            s_sw(1) <= '0';
            wait for 1200us;
            s_sw(1) <= '1';
            wait;
        end process;
        
        getAudio: process
            variable inLine : line;
            variable RECDAT, MCLK : std_logic := '0';
            variable colTmp : character;
        begin
            file_open(input_buf, "testdata.csv",  read_mode);
            readline(input_buf, inLine);
            while not endfile(input_buf) loop
                readline(input_buf, inLine);
                read(inLine, RECDAT);
                read(inLine, colTmp);
                read(inLine, MCLK);
                read(inLine, colTmp);

                s_ac_recdat <= RECDAT;
                csv_mclk <= MCLK;
                wait until rising_edge(s_ac_mclk); 
            end loop;
            file_close(input_buf);
        wait;      
    end process;
end Behavioral;