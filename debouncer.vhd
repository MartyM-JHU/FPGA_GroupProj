------------------------------------------------------------------
--
-- Author: Marty McConnell
--
-- Description:
--		JHU Course EN.525.642 FPGA Design using VHDL
--		Course Module 5
--		10/09/19
--		Switch Debouncer
--      This component debounces toggle switches for both states "high" and "low"
--		Used on a Digilent Nexys4 DDR FPGA Demonstration board
--
------------------------------------------------------------------


library IEEE; 
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;


entity sw_debouncer is
    Port (CLK100MHZ : in std_logic;
	      SW_IN : in std_logic;
	      DB_OUT : out std_logic);
end sw_debouncer;

architecture Behavioral of sw_debouncer is
    signal db_count : unsigned(23 downto 0) := (others => '0');
    signal db_detected : std_logic;
    signal input : std_logic;
    signal input_delay : std_logic;
    signal debounce_done : std_logic;
    signal edge_detect : std_logic;
     
-- counter process to montior 100ms debounce time    
begin

    process (CLK100MHZ, SW_IN, input)  -- register the switch or button input so an transistion can be detected
        begin
            if (rising_edge(CLK100MHZ)) then
                input <= SW_IN;
                input_delay <= input;
            end if;
    end process;
    
    edge_detect <= '1' when ((input_delay = '0') and (input = '1')) or ((input_delay = '1') and (input = '0')) else '0';
    
    process (CLK100MHZ, edge_detect, db_count)
        begin
            if (rising_edge(CLK100MHZ)) then
                if (edge_detect = '1') then                         -- found rising edge of switch activity
                    db_count <= "000011110100001001000000";
                elsif (to_integer(db_count) > 0) then               -- a down counter is used for debouncing
                    db_count <= db_count - 1;
                else
                    db_count <= (others => '0');
                end if;
            end if;
    end process;
 
    debounce_done <= '1' when (db_count = "000000000000000000000000") else '0';
 
 -- process that outputs the debounced switch state
    process (CLK100MHZ, debounce_done, SW_IN)    
        begin
            if (rising_edge(CLK100MHZ)) then
                if (debounce_done = '1') then
                    DB_OUT <= SW_IN;
                else 
                    DB_OUT <= '0';
                end if;
            end if;
       end process;
                
end Behavioral;
