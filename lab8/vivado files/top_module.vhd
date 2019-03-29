library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity declaration for your testbench. 
--Notice that the entity port list is empty here.
entity top_module is
--Port (
--        switch_val : in std_logic_vector(15 downto 0);
--        step_val: in std_logic;
--        go_val: in std_logic;
--        reset_val: in std_logic;
--        instr_val: in std_logic;
--        clk_tm : in std_logic;
--        led_val: out std_logic_vector(15 downto 0)  
--);
end top_module;

architecture behavior of top_module is

-- component declaration for the unit under test (uut)
component main_processor is
Port (     clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           step  : in STD_LOGIC;
           instr  : in STD_LOGIC;
           go  : in STD_LOGIC;
           IR_out : out std_logic_vector(31 downto 0);
           PC_out : out std_logic_vector(31 downto 0);
           ES_out : out integer;
           CS_out : out integer;
           instr_class_out: out std_logic_vector(1 downto 0);
           i_decoded_out: out std_logic_vector(4 downto 0);
           R0 : out std_logic_vector(31 downto 0);
           R1 : out std_logic_vector(31 downto 0);
           R2 : out std_logic_vector(31 downto 0);
           R3 : out std_logic_vector(31 downto 0);
           DR_out : out std_logic_vector(31 downto 0);
           A_out : out std_logic_vector(31 downto 0);
           B_out : out std_logic_vector(31 downto 0);
           RES_out : out std_logic_vector(31 downto 0);
           flags_out : out std_logic_vector(3 downto 0);
           RF_write_enable: out std_logic;
           X_out: out std_logic_vector(4 downto 0)
           );
end component;

--declaring signals.
signal clock_signal : std_logic := '0';
signal reset_signal: std_logic := '0';
signal step_signal : STD_LOGIC := '0';
signal go_signal : STD_LOGIC := '0';
signal instr_signal: std_logic := '0';
signal switch_val_signal : std_logic_vector(15 downto 0) := (others => '0');

signal IR: std_logic_vector(31 downto 0);
signal DR: std_logic_vector(31 downto 0);
signal A: std_logic_vector(31 downto 0);
signal B: std_logic_vector(31 downto 0);
signal RES: std_logic_vector(31 downto 0);
signal PC: std_logic_vector(31 downto 0);
signal ES: integer;
signal CS: integer;
signal instr_class:  std_logic_vector(1 downto 0);
signal i_decoded:  std_logic_vector(4 downto 0);
signal flags: std_logic_vector(3 downto 0);
signal RF_write_enable: std_logic;

signal R0 : std_logic_vector(31 downto 0);
signal R1 : std_logic_vector(31 downto 0);
signal R2 : std_logic_vector(31 downto 0);
signal R3 : std_logic_vector(31 downto 0);
signal X: std_logic_vector(4 downto 0);

-- define the period of clock here.
-- It's recommended to use CAPITAL letters to define constants.
constant CLK_PERIOD : time := 1 ns;

begin
--    step_signal <= step_val;
--    go_signal <= go_val;
--    switch_val_signal <= switch_val;
--    reset_signal <= reset_val;
--    instr_signal <= instr_val;
--    clock_signal <= clk_tm;

    -- instantiate the unit under test (uut)           
   MP_MAP : main_processor port map (
            clock => clock_signal,
            reset => reset_signal, 
            step => step_signal,
            instr => instr_signal,
            go => go_signal,
            IR_out => IR,
            PC_out => PC,
            ES_out => ES,
            CS_out => CS,
            instr_class_out => instr_class,
            i_decoded_out => i_decoded,
            R0 => R0,
            R1 => R1,
            R2 => R2,
            R3 => R3,
            DR_out => DR,
            A_out => A,
            B_out => B,
            RES_out => RES,
            flags_out => flags,
            RF_write_enable => RF_write_enable,
            X_out => X
        );

    --Clock process definitions( clock with 50% duty cycle is generated here.
   Clk_process :process
   begin
        clock_signal <= '0';
        wait for CLK_PERIOD/2;  --for half of clock period clk stays at '0'.
        clock_signal <= '1';
        wait for CLK_PERIOD/2;  --for next half of clock period clk stays at '1'.
   end process;
    
    --Stimulus process, Apply inputs here.
  stim_proc: process
   begin
      wait for CLK_PERIOD;
      
      reset_signal <= '1';
      wait for CLK_PERIOD;
      
      reset_signal <= '0';
      
      
      go_signal <= '1';
      wait for CLK_PERIOD*5;
      go_signal <= '0';
      
      wait;
   end process;

end;