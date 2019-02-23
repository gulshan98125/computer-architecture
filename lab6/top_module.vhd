library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity declaration for your testbench. 
--Notice that the entity port list is empty here.
entity top_module is
Port (
        switch_val : in std_logic_vector(15 downto 0);
        step: in std_logic;
        go: in std_logic;
        reset_val: in std_logic;
        clk_tm : in std_logic;
        led_val: out std_logic_vector(15 downto 0)  
);
end top_module;

architecture behavior of top_module is

-- component declaration for the unit under test (uut)
component CPU is
Port (     clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           instruction : in std_logic_vector(31 downto 0);
           step_button : in STD_LOGIC;
           go_button : in STD_LOGIC;
           address_to_pc : in std_logic_vector(11 downto 0);
           data_from_data_mem: in std_logic_vector(31 downto 0);
           addr_to_prog_mem : out std_logic_vector(31 downto 0);
           addr_to_data_mem : out std_logic_vector(31 downto 0);
           data_to_data_mem : out std_logic_vector(31 downto 0);
           wr_enable_to_dm : out STD_LOGIC);
end component;

component data_memory is 
Port (     a : in std_logic_vector(9 downto 0);
           d : in std_logic_vector(31 downto 0);
           clk : in std_logic;
           we: in std_logic;
           spo : out std_logic_vector(31 downto 0)
           );
end component;

component instruction_memory is 
Port (     a : in std_logic_vector(7 downto 0);
           spo : out std_logic_vector(31 downto 0)
           );
end component;

--declaring signals.
signal clock_signal : std_logic := '0';
signal reset_signal: std_logic := '0';
signal instruction : std_logic_vector(31 downto 0) := (others => '0');
signal data_from_data_mem: std_logic_vector(31 downto 0) := (others => '0');

signal addr_to_prog_mem : std_logic_vector(31 downto 0) := (others => '0');
signal addr_to_data_mem : std_logic_vector(31 downto 0) := (others => '0');
signal data_to_data_mem : std_logic_vector(31 downto 0) := (others => '0');
signal wr_enable_to_dm : STD_LOGIC := '0';
signal program_address : std_logic_vector(11 downto 0) := (others => '0'); -- address to program memory which switches will provide
signal step_signal : STD_LOGIC := '0';
signal go_signal : STD_LOGIC := '0';
signal switch_val_signal : std_logic_vector(15 downto 0) := (others => '0');

-- define the period of clock here.
-- It's recommended to use CAPITAL letters to define constants.
constant CLK_PERIOD : time := 20 ns;

begin
    step_signal <= step;
    go_signal <= go;
    switch_val_signal <= switch_val;
    reset_signal <= reset_val;
    clock_signal <= clk_tm;
    
    led_val<= data_from_data_mem(15 downto 0) when switch_val(15 downto 12)=  "0000" else 
              data_from_data_mem(31 downto 16) when switch_val(15 downto 12)= "1111" else 
               
              addr_to_prog_mem(15 downto 0) when switch_val(15 downto 12) = "1000" else 
              addr_to_prog_mem(31 downto 16) when switch_val(15 downto 12)= "0111" else 
                
              addr_to_data_mem(15 downto 0) when switch_val(15 downto 12) = "0100" else
              addr_to_data_mem(31 downto 16) when switch_val(15 downto 12)= "1011" else
                
              data_to_data_mem(15 downto 0) when switch_val(15 downto 12) = "0010" else
              data_to_data_mem(31 downto 16) when switch_val(15 downto 12)= "1101" else
              "0000000000000000";

    program_address <= switch_val(11 downto 0);

    -- instantiate the unit under test (uut)
   IM_MAP: instruction_memory port map (
           a => addr_to_prog_mem(7 downto 0),
           spo => instruction
           );
           
   DM_MAP: data_memory port map (
           a => addr_to_data_mem(9 downto 0),
           d => data_to_data_mem,
           clk => clock_signal,
           we => wr_enable_to_dm,
           spo => data_from_data_mem
           );
           
   CPU_MAP : CPU port map (
            clock => clock_signal,
            reset => reset_signal, 
            instruction => instruction,
            data_from_data_mem => data_from_data_mem,
            step_button => step_signal,
            go_button => go_signal,
            address_to_pc => program_address,
            addr_to_prog_mem => addr_to_prog_mem,
            addr_to_data_mem => addr_to_data_mem,
            data_to_data_mem => data_to_data_mem,
            wr_enable_to_dm => wr_enable_to_dm  
        );

   -- Clock process definitions( clock with 50% duty cycle is generated here.
  -- Clk_process :process
  -- begin
   --     clock <= '0';
     --   wait for CLK_PERIOD/2;  --for half of clock period clk stays at '0'.
     --   clock <= '1';
       -- wait for CLK_PERIOD/2;  --for next half of clock period clk stays at '1'.
   --end process;
    
   -- Stimulus process, Apply inputs here.
  --stim_proc: process
  -- begin
    --  wait;
  -- end process;

end;