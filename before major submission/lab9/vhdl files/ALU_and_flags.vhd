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
	carry_from_shifter: in std_logic;
	control_operation: in std_logic_vector(3 downto 0);		--considering instructions are less than equal to 16
	write_enable_flag: in std_logic;						-- change flags only when this is equal to 1
	flags_out: out std_logic_vector(3 downto 0)		--VNCZ
	);
end ALU_and_flags;

architecture behavioural of ALU_and_flags is
signal FLAGS: std_logic_vector(3 downto 0):="0000";     --VNCZ
signal thirty3_bit_result : std_logic_vector(32 downto 0);
signal c31: std_logic;
signal c32: std_logic;
signal isArithmetic: std_logic;
begin
	flags_out <= FLAGS;
	result <= thirty3_bit_result(31 downto 0);
	with control_operation select isArithmetic <=
		'1' when "0010"|"0011"|"0100"|"0101"|"0110"|"0111"|"1010"|"1011",
		'0' when others;

	with control_operation select thirty3_bit_result <=
		(("0"&operand1) and ("0"&operand2)) when "0000"|"1000", --and,tst
		(("0"&operand1) xor ("0"&operand2)) when "0001"|"1001", --eor,teq
		(("0"&operand1) + (("0"&(not operand2)) + "00000000000000000000000000000001")) when "0010"|"1010", --sub,cmp
		(("0"&(not operand1))  + (("0"&operand2) +"00000000000000000000000000000001")) when "0011", --rsb
		(("0"&operand1) + ("0"&operand2)) when "0100"|"1011", --add,cmn
		((("0"&operand1) + ("0"&operand2)) + ("00000000000000000000000000000000"&carry)) when "0101", --adc
		(("0"&operand1) + (("0"&(not operand2))+ ("00000000000000000000000000000000"&carry))) when "0110", --sbc
		(("0"&(not operand1)) + (("0"&operand2)+ ("00000000000000000000000000000000"&carry))) when "0111", --rsc
		(("0"&operand1) or ("0"&operand2)) when "1100", -- orr
		("0"&operand2) when "1101", --mov
		(("0"&operand1) and ("0"&(not operand2))) when "1110", --bic
		"0"&(not(operand2)) when "1111", --mvn
		(others => '0') when others;

	c31 <= operand1(31) xor operand2(31) xor thirty3_bit_result(31); -- from lecture 10
	c32 <= (operand1(31) and operand2(31)) or (operand1(31) and c31) or (operand2(31) and c31);

	FLAGS(0) <= '1' when ((thirty3_bit_result(31 downto 0)="00000000000000000000000000000000") and write_enable_flag='1') else
				'0' when ((thirty3_bit_result(31 downto 0)/="00000000000000000000000000000000") and write_enable_flag='1') else
				FLAGS(0); -- Z flag
	FLAGS(3) <= (c31 xor c32) when (write_enable_flag='1' and isArithmetic='1') else
				FLAGS(3);  --V flag
	FLAGS(1) <= c32 when (write_enable_flag='1' and isArithmetic='1') else  --C flag
				carry_from_shifter when (write_enable_flag='1' and isArithmetic='0') else
				FLAGS(1);
	FLAGS(2) <= thirty3_bit_result(31) when (write_enable_flag='1') else -- N flag
				FLAGS(2);
end behavioural; 