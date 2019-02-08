library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity declaration for your testbench. 
--Notice that the entity port list is empty here.
entity tb_CPU is
end tb_CPU;

architecture behavior of tb_CPU is

-- component declaration for the unit under test (uut)
component CPU is
Port (     clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           instruction : in std_logic_vector(31 downto 0);
           data_from_data_mem: in std_logic_vector(31 downto 0);
           addr_to_prog_mem : out std_logic_vector(31 downto 0);
           addr_to_data_mem : out std_logic_vector(31 downto 0);
           data_to_data_mem : out std_logic_vector(31 downto 0);
           wr_enable_to_dm : out STD_LOGIC);
end component;

component data_memory is 
Port (     a : in std_logic_vector(13 downto 0);
           d : in std_logic_vector(31 downto 0);
           clk : in std_logic;
           we: in std_logic;
           spo : out std_logic_vector(31 downto 0)
           );
end component;

component program_memory is 
Port (     a : in std_logic_vector(7 downto 0);
           spo : out std_logic_vector(31 downto 0)
           );
end component;

--declare inputs and initialize them to zero.
signal clock : std_logic := '0';
signal reset : std_logic := '0';
signal instruction : std_logic_vector(31 downto 0);
signal data_from_data_mem: std_logic_vector(31 downto 0);

--declare outputs

signal addr_to_prog_mem : std_logic_vector(31 downto 0);
signal addr_to_data_mem : std_logic_vector(31 downto 0);
signal data_to_data_mem : std_logic_vector(31 downto 0);
signal wr_enable_to_dm : STD_LOGIC;

-- define the period of clock here.
-- It's recommended to use CAPITAL letters to define constants.
constant CLK_PERIOD : time := 30 ns;

begin

    -- instantiate the unit under test (uut)
   IM_MAP: program_memory port map (
           a => addr_to_prog_mem(9 downto 2),
           spo => instruction
           );
           
   DM_MAP: data_memory port map (
           a => addr_to_data_mem(13 downto 0),
           d => data_to_data_mem,
           clk => clock,
           we => wr_enable_to_dm,
           spo => data_from_data_mem
           );
           
   CPU_MAP : CPU port map (
            clock => clock,
            reset => reset, 
            instruction => instruction,
            data_from_data_mem => data_from_data_mem,
            addr_to_prog_mem => addr_to_prog_mem,
            addr_to_data_mem => addr_to_data_mem,
            data_to_data_mem => data_to_data_mem,
            wr_enable_to_dm => wr_enable_to_dm  
        );

   -- Clock process definitions( clock with 50% duty cycle is generated here.
   Clk_process :process
   begin
        clock <= '0';
        wait for CLK_PERIOD/2;  --for half of clock period clk stays at '0'.
        clock <= '1';
        wait for CLK_PERIOD/2;  --for next half of clock period clk stays at '1'.
   end process;
    
   -- Stimulus process, Apply inputs here.
  stim_proc: process
   begin
   		reset <= '1'
   		wait for CLK_PERIOD*2
   		reset <= '0'        
        wait;
  end process;

end;