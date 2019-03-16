Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity adder_subtractor is
Port(
	adder_input1: in std_logic_vector(31 downto 0);
	adder_input2: in std_logic_vector(31 downto 0);
	operation: in std_logic;	--0 means add, 1 means subtract
	adder_out: out std_logic_vector(31 downto 0);
	carry_in: in std_logic;
	carry_out: out std_logic
	);
end adder_subtractor;

architecture behavioural of adder_subtractor is

signal actual_operation: std_logic_vector(32 downto 0);

begin
	process(adder_input1,adder_input2,carry_in,operation)
		begin
			if operation='0' then	--add
				if carry_in='0' then 
					-- without carry additon
					actual_operation <= "0"&adder_input1 + "0"&adder_input2;
					adder_out <= actual_operation(31 downto 0);
					carry_out <= actual_operation(32);
				else
					-- with carry addition
					actual_operation <= ("0"&adder_input1 + "0"&adder_input2) + ("000000000000000000000000000000001");
					adder_out <= actual_operation(31 downto 0);
					carry_out <= actual_operation(32);
				end if;
			else
				if carry_in='0' then
					-- adder_input1 + not(adder_input_2) + 1
					actual_operation <= "0"&adder_input1 + "0"&(not adder_input2 + "00000000000000000000000000000001");
					adder_out <= actual_operation(31 downto 0);
					carry_out <= actual_operation(32);
				else
					-- adder_input1 + not(adder_input_2) + 1 + 1
					actual_operation <= "0"&adder_input1 + "0"&(not adder_input2 + "00000000000000000000000000000010");
					adder_out <= actual_operation(31 downto 0);
					carry_out <= actual_operation(32);
				end if;
			end if;
	end process;
end behavioural;