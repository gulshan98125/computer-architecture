Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity instruction_decoder is
Port(
	instruction: in std_logic_vector(31 downto 0);
	class: out std_logic_vector(1 downto 0);		   -- DP=00, DT=01, branch=10, others = 11
	i_decoded : out std_logic_vector(4 downto 0)  -- add,sub,cmp,etc
	);
end instruction_decoder;

architecture behavioural of instruction_decoder is

type instr_class_type is (DP, DT, branch, unknown, HALT);
signal instr_class : instr_class_type;

signal cond : std_logic_vector (3 downto 0);
signal F_field : std_logic_vector (1 downto 0);
signal opcode : std_logic_vector (3 downto 0);
signal L_bit : std_logic;
signal is_DT_SH: std_logic;

begin
		
	cond <= instruction(31 downto 28);
    F_field <= instruction(27 downto 26);
    opcode <= instruction (24 downto 21);
    L_bit <= instruction(20);
    class <= "11" when instruction="00000000000000000000000000000000" else F_field;
    
    instr_class <=  HALT when instruction="00000000000000000000000000000000" else
                    DP when F_field="00" else
                    DT when F_field="01" else
                    branch when F_field="10" else
                    unknown;
    is_DT_SH <= '1' when F_field="00" and instruction(25)='0' and instruction(7)='1' and instruction(4)='1' else
                '0';
    
    i_decoded <=    "10101" when is_DT_SH='1' else --DT_SH
                    "00000" when instr_class=DP and opcode="0100" else   --add
                    "00001" when instr_class=DP and opcode="0010" else   --sub
                    "00010" when instr_class=DP and opcode="1101" else   --mov
                    "00011" when instr_class=DP and opcode="1010" else   --cmp
                    "00100" when instr_class=DT and L_bit='0' else       --str
                    "00101" when instr_class=DT and L_bit='1' else       --ldr
                    "00110" when instr_class=branch and cond="1110" else --b
                    "00111" when instr_class=branch and cond="0000" else --beq
                    "01000" when instr_class=branch and cond="0001" else --bne
                    "01001" when instr_class=DP and opcode="0000" else   --and
                    "01010" when instr_class=DP and opcode="0001" else   --eor
                    "01011" when instr_class=DP and opcode="0011" else   --rsb
                    "01100" when instr_class=DP and opcode="0101" else   --adc
                    "01101" when instr_class=DP and opcode="0110" else   --subc
                    "01110" when instr_class=DP and opcode="0111" else   --rsc
                    "01111" when instr_class=DP and opcode="1000" else   --tst
                    "10000" when instr_class=DP and opcode="1001" else   --teq
                    "10001" when instr_class=DP and opcode="1011" else   --cmn
                    "10010" when instr_class=DP and opcode="1100" else   --orr
                    "10011" when instr_class=DP and opcode="1110" else   --bic
                    "10100" when instr_class=DP and opcode="1111" else   --mvn
                    (others => 'U');
--	process(instruction)
--		begin
--			case F_field is
--				when "00" =>		--means DP class
--					case opcode is
--						when "0100" =>
--							i_decoded <= "0000";	--ADD
--						when "0010" =>
--							i_decoded <= "0001";	--SUB
--						when "1101" =>
--							i_decoded <= "0010";	--MOV
--						when "1010" =>
--							i_decoded <= "0011";	--cmp
--						--when "0100" =>
--						--	i_decoded <= "0100";	--AND
--						--when "0101" =>
--						--	i_decoded <= "0101";	--EOR
--						--when "0110" =>
--						--	i_decoded <= "0110";	--ORR
--						--when "0111" =>
--						--	i_decoded <= "0111"; 	--BIC
--						--when "1000" =>
--						--	i_decoded <= "1000";	--ADC
--						--when "1001" =>
--						--	i_decoded <= "1001"; 	--SBC
--						--when "1010" =>
--						--	i_decoded <= "1010";	--RSB
--						--when "1011" =>
--						--	i_decoded <= "1011";	--RSC
--						--when "1100" =>
--						--	i_decoded <= "1100";	--CMN
--						--when "1101" =>
--						--	i_decoded <= "1101";	--TST
--						--when "1110" =>
--						--	i_decoded <= "1110";	--TEQ
--						--when "1111" =>
--						--	i_decoded <= "1111";	--MVN
--						when others =>
--							i_decoded <= (others => 'X');	--UNKNOWN
--					end case;
--				when "01" =>
--					if L_bit='0' then
--						i_decoded <= "0100";		--STR
--					else
--						i_decoded <= "0101";
--					end if;		--LDR
--				when "10" =>
--					case cond is
--						when "1110" =>
--							i_decoded <= "0110"; 	--B
--						when "0000" =>
--							i_decoded <= "0111";	--BEQ
--						when "0001" =>
--							i_decoded <= "1000";	--BNE
--						when others =>
--							i_decoded <= (others => 'X'); 	--UNKNOWN
--					end case;
--				when "11" =>
--					i_decoded <= (others => 'X');			--UNKNOWN
--				when others =>
--					i_decoded <= (others => '1');
--			end case;
--	end process;
end behavioural;