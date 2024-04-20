
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.numeric_std.all;

entity ac_audio_tb is 
end ac_audio_tb;

architecture Behavioral of ac_audio_tb is
component ac_audio is   
    Port (
        clk         : in std_logic;
        channel_clk : in std_logic;
        ac_recdat   : in std_logic;
        int_sample  : out signed(29 downto 0):= (others => '0')
    );
end component;
 
signal simClk: std_logic := '0';
signal s_data,s_SDA, s_SCL, s_RECDAT, s_Cha,s_BCLK, s_RECLRC, s_MCLK, s_PBLRC: std_logic :='0'; 
signal int_sample: signed(29 downto 0):= (others => '0');
constant simTime: time := 4ns;
file input_buf : text;
begin
     uut: ac_audio port map(
         clk            => s_BCLK,
         channel_clk    => s_RECLRC,
         ac_recdat      => s_RECDAT,
         int_sample     => int_sample
     );
    clk_process: process 
    begin
        wait for simTime;
        simClk <= not simClk;
    end process;     

    ac_audio_process: process
        variable inLine : line;
        variable SDA, SCL, RECDAT, Cha, BCLK, RECLRC, MCLK, PBLRC : std_logic := '0';
        variable colTmp: character;
    begin   
        file_open(input_buf, "testdata.csv",  read_mode);
        readline(input_buf, inLine);
        while not endfile(input_buf) loop
            readline(input_buf, inLine);
            read(inLine, SDA);
            read(inLine, colTmp);
            read(inLine, SCL);
            read(inLine, colTmp);
            read(inLine, RECDAT);
            read(inLine, colTmp);
            read(inLine, Cha);
            read(inLine, colTmp);
            read(inLine, BCLK);
            read(inLine, colTmp);
            read(inLine, RECLRC);
            read(inLine, colTmp);
            read(inLine, MCLK);
            read(inLine, colTmp);
            read(inLine, PBLRC);
            
            s_SDA <= SDA;
            s_SCL <= SCL;
            s_RECDAT <= RECDAT;
            s_Cha <= Cha;
            s_BCLK <= BCLK;
            s_RECLRC <= RECLRC;
            s_MCLK <= MCLK;
            s_PBLRC <= PBLRC;
            wait until rising_edge(simClk); 
        end loop;
        file_close(input_buf);
        wait;      
    end process;
end Behavioral;