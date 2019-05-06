Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Shifter is
Port(
	shift_input: in std_logic_vector(31 downto 0);
	shift_type: in std_logic_vector(1 downto 0);
	shift_amt: in std_logic_vector(4 downto 0);
	shift_output: out std_logic_vector(31 downto 0);
	carry: out std_logic
	);
end Shifter;

architecture behavioural of Shifter is

signal shift_val : integer;

signal signed_input: signed(31 downto 0);
signal unsigned_input: unsigned(31 downto 0);

signal signed_output: signed(32 downto 0);
signal unsigned_output: unsigned(32 downto 0);
signal rotate_output : unsigned(31 downto 0);


begin

	signed_input <= signed(shift_input);
	unsigned_input <= unsigned(shift_input);
	
	shift_val <= to_integer(unsigned(shift_amt));

	with shift_type select 
	unsigned_output <= 	SHIFT_LEFT(unsigned("0"&unsigned_input), shift_val) when "00", --LSL
						SHIFT_RIGHT(unsigned(unsigned_input&"0"), shift_val) when "01", --LSR
						(others => '0') when others;

	with shift_type select 
	signed_output <= 	SHIFT_RIGHT(signed(signed_input&"0"), shift_val) when "10", --ASR
						(others => '0') when others;

	with shift_type select 
	rotate_output <= 	ROTATE_RIGHT(unsigned(unsigned_input), shift_val) when "11", --ROR
						(others => '0') when others; 

	with shift_type	select 
	shift_output <= 	std_logic_vector(unsigned_output(31 downto 0)) when "00", --LSL
						std_logic_vector(unsigned_output(32 downto 1)) when "01", --LSR
						std_logic_vector(signed_output(32 downto 1)) when "10", --ASR
						std_logic_vector(rotate_output) when others; --ROR

	with shift_type select 
	carry <= 	unsigned_output(32) when "00", --LSL
				unsigned_output(0) when "01", --LSR
				signed_output(0) when "10", --ASR
				rotate_output(31) when others; --ROR


	--process(shift_input,shift_amt,shift_type)
	--begin
	--	case(shift_type) is
	--		when "00"=> --LSL
	--			unsigned_output <= SHIFT_LEFT(unsigned("0"&unsigned_input), shift_val);
	--			shift_output <= std_logic_vector(unsigned_output(31 downto 0));
	--			carry <= unsigned_output(32);
	--		when "01"=> --LSR
	--			unsigned_output <= SHIFT_RIGHT(unsigned(unsigned_input&"0"), shift_val);
	--			shift_output <= std_logic_vector(unsigned_output(32 downto 1));
	--			carry <= unsigned_output(0);
	--		when "10"=> --ASR
	--			signed_output <= SHIFT_RIGHT(signed(signed_input&"0"), shift_val);
	--			shift_output <= std_logic_vector(signed_output(32 downto 1));
	--			carry <= signed_output(0);
	--		when others=> --ROR
	--			rotate_output <= ROTATE_RIGHT(unsigned(unsigned_input), shift_val);
	--			shift_output <= std_logic_vector(rotate_output);
	--			carry <= rotate_output(31);
	--	end case;	
	
	--end process;
end behavioural;