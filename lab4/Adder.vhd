library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Adder is
Port(
	adder_in1: in std_logic_vector(31 downto 0);
	adder_in2: in std_logic_vector(31 downto 0);
	adder_sum_out: out std_logic_vector(31 downto 0)
	);
end Adder;

architecture behavioural of Adder is

component Single_Adder_Unit is
Port(
	a: in std_logic;
	b: in std_logic;
	cin: in std_logic;
	cout: out std_logic;
	sum: out std_logic
	);
end component;

signal carry: std_logic_vector(32 downto 0);

begin

	carry(0)<='0';
	
	GEN_REG: 
   for I in 0 to 31 generate
      addUnit : Single_Adder_Unit port map (
      a=> adder_in1(I),
      b=> adder_in2(I),
      cin=> carry(I),
      cout=>carry(I+1),
      sum=> adder_sum_out(I));
   end generate GEN_REG;

end behavioural;