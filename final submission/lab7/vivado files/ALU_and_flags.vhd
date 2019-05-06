Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity ALU_and_flags is
Port(
	operand1: in std_logic_vector(31 downto 0);
	operand2: in std_logic_vector(31 downto 0);
	result : out std_logic_vector(31 downto 0);
	carry : in std_logic;
	control_operation: in std_logic_vector(3 downto 0);		--considering instructions are less than equal to 16
	write_enable_flag: in std_logic;						-- change flags only when this is equal to 1
	flags_out: out std_logic_vector(3 downto 0)		--VNCZ
	);
end ALU_and_flags;

architecture behavioural of ALU_and_flags is
signal FLAGS: std_logic_vector(3 downto 0):="0000";     --VNCZ
signal thirty3_bit_result : std_logic_vector(32 downto 0);
begin
	flags_out <= FLAGS;
	result <= thirty3_bit_result(31 downto 0);

	thirty3_bit_result <= (("0"&operand1) + ("0"&operand2)) when (control_operation="0100") else 	--add
						  (("0"&operand1) + (("0"&(not operand2)) + "00000000000000000000000000000001")) when (control_operation="0010") else 	--sub
						  ((("0"&operand1) + ("0"&operand2)) + ("00000000000000000000000000000000"&carry)) when (control_operation="0101") else --addc
						  (("0"&operand1) + (("0"&(not operand2)) + "00000000000000000000000000000001")+ ("00000000000000000000000000000000"&carry)) when (control_operation="0110") else 	--subc
						  (("0"&operand1) + (("0"&(not operand2)) + "00000000000000000000000000000001")) when (control_operation="1010") else --cmp
						  ("0"&operand2) when (control_operation="1101") else
						  (others => '0');
	FLAGS(1) <= thirty3_bit_result(32) when write_enable_flag='1' else
				FLAGS(1);

	FLAGS(0) <= '1' when ((thirty3_bit_result(31 downto 0)="00000000000000000000000000000000") and write_enable_flag='1') else
				'0' when ((thirty3_bit_result(31 downto 0)/="00000000000000000000000000000000") and write_enable_flag='1') else
				FLAGS(0);

	--process(operand1,operand2)
	--	begin
	--		case control_operation is
	--			when "0000" => 			-- ADD
	--				thirty3_bit_result <= (("0"&operand1) + ("0"&operand2)) + ("00000000000000000000000000000000"&carry);
	--				if (write_enable_flag='1') then
	--					if thirty3_bit_result(32)='1' then
	--						FLAGS(1) <= '1';	-- C=1
	--					else
	--						FLAGS(1) <= '0';	-- C=0
	--					end if;
	--				end if;
	--			when "0001" =>			-- SUB
	--				thirty3_bit_result <= ("0"&operand1) + (("0"&(not operand2)) + "00000000000000000000000000000001")+ ("00000000000000000000000000000000"&carry);
	--				if (write_enable_flag='1') then
	--					if(thirty3_bit_result(31 downto 0)="00000000000000000000000000000000") then
	--						FLAGS(0) <= '1';	-- Z=1
	--					else
	--						FLAGS(0) <= '0';	-- Z=0
	--					end if;
	--				end if;
	--			when others =>			-- currently others
	--				thirty3_bit_result <= (others => '0');
	--		end case;
	--end process;	
end behavioural; 