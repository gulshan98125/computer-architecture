library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity main_processor is
end main_processor;

architecture behavioural of main_processor is

component register_file is
Port(
	read_address1: in std_logic_vector(3 downto 0);		-- 1st read port
	data_output1: out std_logic_vector(31 downto 0);

	read_address2: in std_logic_vector(3 downto 0);		-- 2nd read port
	data_output2: out std_logic_vector(31 downto 0);

	address_input_wp: in std_logic_vector(3 downto 0);		-- write port
	data_input_wp: in std_logic_vector(31 downto 0);
	write_enable_wp: in std_logic;

	data_input_pc: in std_logic_vector(31 downto 0);		-- PC port
	data_output_pc: out std_logic_vector(31 downto 0);
	write_enable_pc: in std_logic
	);
end component;

--signal carry: std_logic_vector(32 downto 0);
component ALU is
Port(
	operand1: in std_logic_vector(31 downto 0);
	operand2: in std_logic_vector(31 downto 0);
	result : out std_logic_vector(31 downto 0);
	control_operation: in std_logic_vector(3 downto 0);		--considering instructions are less than equal to 16
	write_enable_flag: in std_logic;						-- change flags only when this is equal to 1

	flags_out: out std_logic_vector(3 downto 0);		--ZCNV
	
end component;

component instruction_decoder is
Port(
	instruction: in std_logic_vector(31 downto 0);
	class: out std_logic_vector(1 downto 0);		   -- DP=00, DT=01, branch=10, others = 11
	i_decoded : out std_logic_vector(3 downto 0);  -- add,sub,cmp,etc
	
end component;

component Adder is
Port(
	adder_input1: in std_logic_vector(31 downto 0);
	adder_input2: in std_logic_vector(31 downto 0);
	operation: in std_logic;	--0 means add, 1 means subtract
	adder_out: out std_logic_vector(31 downto 0);
	carry_in: in std_logic;
	carry_out: out std_logic
	);
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

--signals below
signal i_decoded : std_logic_vector(3 downto 0);
signal instr_class : std_logic_vector(1 downto 0);
signal instruction : std_logic_vector(31 downto 0);
signal data_input_pc : std_logic_vector(31 downto 0);
signal data_output_pc : std_logic_vector(31 downto 0);
signal write_enable_pc : std_logic;

begin
--port map below
ID_MAP: instruction_decoder port map (
           instruction => instruction,
           class => instr_class,
           i_decoded => i_decoded
           );

IM_MAP: program_memory port map (
        a => data_output_pc(9 downto 2),
        spo => instruction
        );
        
DM_MAP: data_memory port map (
        a => addr_to_data_mem(13 downto 0),
        d => data_to_data_mem,
        clk => clock,
        we => wr_enable_to_dm,
        spo => data_from_data_mem
        );

end behavioural;