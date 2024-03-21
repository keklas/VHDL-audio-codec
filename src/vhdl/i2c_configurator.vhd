library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity i2c_configurator is
    Port ( 
        sysclk  : in std_logic;
        rst     : in std_logic;
        scl     : out std_logic;
        sda     : inout std_logic
    );
end i2c_configurator;

architecture Behavioral of i2c_configurator is
    
    ---------- Types ----------
    
    
    -- Types for SSM2603 registers
    subtype register_t is std_logic_vector(15 downto 9);
    type config_t is array(integer range <>) of std_logic_vector(15 downto 0);
    
    -- Type for the high level i2c state machine
    type i2c_t is (idle, start, addr1, rw, ack1, addr2, ack2, data, ack3, stop, done);
    
    -- Type for the SSM2603 setup sequence state machine
    type ssm_setup_t is (idle, start, stop);
    
    ---------- Constants ----------
    
    -- Audio codec SSM2603 I2C address
    constant devAddr : std_logic_vector(0 to 6) := "0011010";
    
    -- SSM2603 I2C register addresses
    constant R00 : register_t := "0000000";
    constant R01 : register_t := "0000001";
    constant R02 : register_t := "0000010";
    constant R03 : register_t := "0000011";
    constant R04 : register_t := "0000100";
    constant R05 : register_t := "0000101";
    constant R06 : register_t := "0000110";
    constant R07 : register_t := "0000111";
    constant R08 : register_t := "0001000";
    constant R09 : register_t := "0001001";
    constant R15 : register_t := "0001111";
    constant R16 : register_t := "0010000";
    constant R17 : register_t := "0010001";
    constant R18 : register_t := "0010010";

    
    constant regLength: integer := 15;
    
    -- SSM2603 I2C register values
    constant registers : config_t(0 to regLength) :=
        ( R15 & B"0_0000_0000"
        , R06 & B"0_0011_0000"
        , R00 & B"0_0001_0111"
        , R01 & B"0_0001_0111"
        , R02 & B"1_0111_1001"
        , R03 & B"1_0111_1001"
        , R05 & B"0_0000_0000"
        , R07 & B"0_0100_1010" -- enable master mode
        , R08 & B"0_0000_0000"
        , R16 & B"0_0111_1011"
        , R17 & B"0_0000_0000"
        , R18 & B"0_1111_0011"
        , R09 & B"0_0000_0001"
        , R06 & B"0_0010_0000"
        , R04 & B"0_0001_0100" -- to test bypass, change to 0_0001_1100
        , R05 & B"0_0000_0000"
        );
    
    ---------- Signals ----------
    
    -- I2C clocks
    signal clk_scl  : std_logic := '0'; -- 250 kHz
    signal clk_data : std_logic := '0'; -- 1.0 MHz
    
    -- I2C
    signal scl_out : std_logic := 'Z';
    signal sda_out : std_logic := 'Z';
    
    signal active_reg : std_logic_vector(0 to 15) := registers(0);
    
    -- State machine signals
    signal i2c_sm: i2c_t := idle;
    
    
    -- Wait And Hold
    procedure wnh(
        signal signalIn: out std_logic;
        constant dir: in std_logic;
        signal clkIn: in std_logic;
        constant cntStart: in integer;
        constant cntStop: in integer;
        variable cnt: in integer
        ) is
        variable prevClkVal : std_logic := '0';
    begin
        if prevClkVal = '0' and clkIn = '1' then
            if cnt <= cntStart then
                signalIn <= not dir;
            end if;
            if cnt < cntStop then
                null;    
            else
                signalIn <= dir;
            end if;
        end if;
        prevClkVal := clkIn;
    end procedure;
    
    
begin
    
    -- 1250 kHz data clock generation from 125 MHz clock
    -- Used for syncing the I2C data write operations
    -- When divided by 5, a 250kHz SCL clock is created
    process(sysclk)
        constant cnt_max : integer := 125000000/250000/10; -- 50 rising edges
        variable cnt : integer range 0 to cnt_max := 0;
    begin
        if rising_edge(sysclk) then
            if rst = '1' then
                cnt := 0;
            end if;
            
            if cnt < cnt_max-1 then
                cnt := cnt + 1;
            else
                cnt := 0;
                clk_data <= not clk_data;
            end if;
        end if;
    end process;
    
    
    -- I2C transaction state machine
    i2cTransaction_p: process(sysclk, clk_data)
        -- Variable to count cycles (5 per SCL)
        variable cnt : integer range 0 to 5 := 0;
        variable cnt_prev : integer range 0 to 5 := 0;
        
        -- Variable for counting data and address bits
        variable cnt2: integer range 0 to 9 := 0;
        
        -- Variable to count how many adresses have been written
        variable run_cnt : integer range 0 to regLength+1 := 0;
    begin
        if rising_edge(clk_data) then
            cnt := cnt + 1;
            if cnt = 5 then
                cnt := 0;
            end if;
        end if;
    
    -- Cycle through I2C write sequence. Reading data is not implemented
        if rising_edge(sysclk) then
            -- type i2c_t is (idle, start, addr1, rw, ack1, addr2, ack2, data, stop);
            case i2c_sm is
            when idle =>
            
                if (run_cnt <= regLength) then
                    i2c_sm <= start;
                else
                    i2c_sm <= done;
                end if;
            
            
            when start =>
                -- first SDA must be pulled down, then SCL
                wnh(scl_out,'0',clk_data,0,3, cnt);
                wnh(sda_out,'0',clk_data,0,2, cnt);
                
                if cnt = 4 and cnt_prev /= 4 then
                    i2c_sm <= addr1;
                end if;           
            
            when addr1 =>
                 -- Slave reads the SDA when SCL is HIGH
                -- Do the operation for all the device address bits;
                wnh(scl_out,'0',clk_data,1,2, cnt);
                sda_out <= devAddr(cnt2);
                if cnt = 4 and cnt_prev /= 4 then
                    cnt2 := cnt2 + 1;
                end if;
                
                if cnt2 = 7 then
                    cnt2 := 0;
                    i2c_sm <= rw;
                end if;
            
            
            when rw =>
                
                wnh(scl_out,'0',clk_data,1,2, cnt);
                sda_out <= '0';
            
                if cnt = 4 and cnt_prev /= 4 then
                    i2c_sm <= ack1;
                end if;
            
            
            when ack1 =>
                
                wnh(scl_out,'0',clk_data,1,2, cnt);
                sda_out <= '0';
                
                if cnt = 4 and cnt_prev /= 4 then
                    i2c_sm <= addr2;
                end if;
            
            
            when addr2 =>
                wnh(scl_out,'0',clk_data,1,2, cnt);
                sda_out <= active_reg(cnt2);
                if cnt = 4 and cnt_prev /= 4 then
                    cnt2 := cnt2 + 1;
                end if;
                
                if cnt2 = 7 then
                    cnt2 := 0;
                    i2c_sm <= ack2;
                end if;
            
            when ack2 =>
                
                wnh(scl_out,'0',clk_data,1,2, cnt);
                sda_out <= '0';
            
                if cnt = 4 and cnt_prev /= 4 then
                    i2c_sm <= data;
                end if;
            
            
            when data =>
                wnh(scl_out,'0',clk_data,1,2, cnt);
                sda_out <= active_reg(cnt2+7);
                if cnt = 4 and cnt_prev /= 4 then
                    cnt2 := cnt2 + 1;
                end if;
                
                if cnt2 = 9 then
                    cnt2 := 0;
                    i2c_sm <= ack3;
                end if;
            
            when ack3 =>
                
                wnh(scl_out,'0',clk_data,1,2, cnt);
                sda_out <= '0';
            
                if cnt = 4 and cnt_prev /= 4 then
                    i2c_sm <= stop;
                end if;
            
            when stop =>
                sda_out <= '1'; 
                scl_out <= '1';
                
                if cnt = 4 and cnt_prev /= 4 then
                    cnt2 := cnt2 + 1;
                end if;
                
                if cnt2 = 7 then
                    cnt2 := 0;
                    i2c_sm <= idle;
                    run_cnt := run_cnt + 1;
                end if;
                
            
            when others => null;
            end case;
        cnt_prev := cnt;
        end if;
    
    end process;
    
    
    
    -- SSM2603 configuration state machine
    configuration_p: process(clk_data, sysclk)
        variable regN : integer := 1;
        variable prevState : i2c_t;
    begin
    
    -- Cycle through the registers    
    if rising_edge(clk_data) then
        if i2c_sm = stop and i2c_sm /= prevState then
            if regN <= 15 then
                active_reg <= registers(regN);
                regN := regN + 1;
            end if;
        end if;
        prevState := i2c_sm;
    end if;
        
    end process;
    

    scl <= '0' when scl_out = '0' else 'Z';
    sda <= '0' when sda_out = '0' else 'Z';

end Behavioral;
