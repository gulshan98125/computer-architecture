Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity ALU is
Port(
	operand1: in std_logic_vector(31 downto 0);
	operand2: in std_logic_vector(31 downto 0);
	result : out std_logic_vector(31 downto 0);
	control_operation: in std_logic_vector(3 downto 0);		--considering instructions are less than equal to 16
	write_enable_flag: in std_logic;						-- change flags only when this is equal to 1

	flags_out: out std_logic_vector(3 downto 0);		--ZCNV
	
end ALU;

architecture behavioural of ALU is
signal FLAGS: std_logic_vector(3 downto 0):="0000";     --ZCNV
begin
	flags_out <= FLAGS;
	process(operand1,operand2)
		begin
			case control_operation is
				when "0000" => 			-- ADD
					result <= operand1 + operand2;
				when "0001" =>			-- SUB
					result <= operand1 + ((not operand2) + "00000000000000000000000000000001");
				when others =>			-- currently others
					result <= "00000000000000000000000000000000";
			end case;
	end process;	
end behavioural; 