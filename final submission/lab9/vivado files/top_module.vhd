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
           R4 : out std_logic_vector(31 downto 0);
           R5 : out std_logic_vector(31 downto 0);
           R6 : out std_logic_vector(31 downto 0);
           R7 : out std_logic_vector(31 downto 0);
           R8 : out std_logic_vector(31 downto 0);
           R9 : out std_logic_vector(31 downto 0);
           R10 : out std_logic_vector(31 downto 0);
           R11 : out std_logic_vector(31 downto 0);
           R12 : out std_logic_vector(31 downto 0);
           R13 : out std_logic_vector(31 downto 0);
           R14 : out std_logic_vector(31 downto 0);
           R15 : out std_logic_vector(31 downto 0);
           DR_out : out std_logic_vector(31 downto 0);
           A_out : out std_logic_vector(31 downto 0);
           B_out : out std_logic_vector(31 downto 0);
           D_out : out std_logic_vector(31 downto 0);
           RES_out : out std_logic_vector(31 downto 0);
           flags_out : out std_logic_vector(3 downto 0);
           RF_write_enable: out std_logic;
           dm_wr_enable1: out std_logic;
           dm_wr_enable2: out std_logic;
           dm_wr_enable3: out std_logic;
           dm_wr_enable4: out std_logic;
           data_to_dm : out std_logic_vector(31 downto 0);
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
signal D: std_logic_vector(31 downto 0);
signal RES: std_logic_vector(31 downto 0);
signal PC: std_logic_vector(31 downto 0);
signal ES: integer;
signal CS: integer;
signal instr_class:  std_logic_vector(1 downto 0);
signal i_decoded:  std_logic_vector(4 downto 0);
signal flags: std_logic_vector(3 downto 0);
signal RF_write_enable: std_logic;
signal dm_wr_enable1 : std_logic;
signal dm_wr_enable2 : std_logic;
signal dm_wr_enable3 : std_logic;
signal dm_wr_enable4 : std_logic;
signal data_to_dm : std_logic_vector(31 downto 0);

signal R0 : std_logic_vector(31 downto 0);
signal R1 : std_logic_vector(31 downto 0);
signal R2 : std_logic_vector(31 downto 0);
signal R3 : std_logic_vector(31 downto 0);
signal R4 : std_logic_vector(31 downto 0);
signal R5 : std_logic_vector(31 downto 0);
signal R6 : std_logic_vector(31 downto 0);
signal R7 : std_logic_vector(31 downto 0);
signal R8 : std_logic_vector(31 downto 0);
signal R9 : std_logic_vector(31 downto 0);
signal R10 : std_logic_vector(31 downto 0);
signal R11 : std_logic_vector(31 downto 0);
signal R12 : std_logic_vector(31 downto 0);
signal R13 : std_logic_vector(31 downto 0);
signal R14 : std_logic_vector(31 downto 0);
signal R15 : std_logic_vector(31 downto 0);
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
            R4 => R4,
            R5 => R5,
            R6 => R6,
            R7 => R7,
            R8 => R8,
            R9 => R9,
            R10 => R10,
            R11 => R11,
            R12 => R12,
            R13 => R13,
            R14 => R14,
            R15 => R15,
            DR_out => DR,
            A_out => A,
            B_out => B,
            D_out => D,
            RES_out => RES,
            flags_out => flags,
            RF_write_enable => RF_write_enable,
            dm_wr_enable1 => dm_wr_enable1,
            dm_wr_enable2 => dm_wr_enable2,
            dm_wr_enable3 => dm_wr_enable3,
            dm_wr_enable4 => dm_wr_enable4,
            data_to_dm => data_to_dm,
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
      wait for CLK_PERIOD*300;
      
      
      go_signal <= '1';
      wait for CLK_PERIOD*5;
      go_signal <= '0';
      wait for CLK_PERIOD*10;
      wait;
   end process;

end;