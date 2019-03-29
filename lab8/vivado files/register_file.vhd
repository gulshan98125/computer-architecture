library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity register_File is
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
	write_enable_pc: in std_logic;
	r0 : out std_logic_vector(31 downto 0);
	r1 : out std_logic_vector(31 downto 0);
	r2 : out std_logic_vector(31 downto 0);
	r3 : out std_logic_vector(31 downto 0)
	);
end register_File;

architecture behavioural of register_File is

type register_list is array (0 to 15) of std_logic_vector(31 downto 0);
signal registers : register_list:=(others=>x"00000000");
signal PC: std_logic_vector(31 downto 0):= (others => '0');

begin
	
	data_output_pc <= PC;
	r0 <= registers(0);
	r1 <= registers(1);
	r2 <= registers(2);
	r3 <= registers(3);

	process(read_address1,read_address2,address_input_wp,data_input_wp,write_enable_wp,data_input_pc,write_enable_pc)
		begin
			data_output1 <= registers(to_integer(unsigned(read_address1)));
			data_output2 <= registers(to_integer(unsigned(read_address2)));

			if write_enable_wp='1' then 
				registers(to_integer(unsigned(address_input_wp))) <= data_input_wp;
			else
				--do nothing
			end if;

			if write_enable_pc='1' then
				PC <= data_input_pc;
			else
				--do nothing
			end if;

	end process;

	
end behavioural;