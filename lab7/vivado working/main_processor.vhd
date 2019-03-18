library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity main_processor is
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           step  : in STD_LOGIC;
           instr  : in STD_LOGIC;
           go  : in STD_LOGIC;
           IR_out : out std_logic_vector(31 downto 0);
           PC_out : out std_logic_vector(31 downto 0);
           ES_out : out integer;
           CS_out : out integer;
           instr_class_out: out std_logic_vector(1 downto 0);
           i_decoded_out: out std_logic_vector(3 downto 0);
           R0 : out std_logic_vector(31 downto 0);
           R1 : out std_logic_vector(31 downto 0);
           R2 : out std_logic_vector(31 downto 0);
           R3 : out std_logic_vector(31 downto 0);
           DR_out : out std_logic_vector(31 downto 0);
           A_out : out std_logic_vector(31 downto 0);
           B_out : out std_logic_vector(31 downto 0);
           RES_out : out std_logic_vector(31 downto 0);
           flags_out : out std_logic_vector(3 downto 0)
           );
end main_processor;

architecture behavioural of main_processor is
component register_file is
Port(
    read_address1: in std_logic_vector(3 downto 0);     -- 1st read port
    data_output1: out std_logic_vector(31 downto 0);

    read_address2: in std_logic_vector(3 downto 0);     -- 2nd read port
    data_output2: out std_logic_vector(31 downto 0);

    address_input_wp: in std_logic_vector(3 downto 0);      -- write port
    data_input_wp: in std_logic_vector(31 downto 0);
    write_enable_wp: in std_logic;

    data_input_pc: in std_logic_vector(31 downto 0);        -- PC port
    data_output_pc: out std_logic_vector(31 downto 0);
    write_enable_pc: in std_logic;
    
    r0: out std_logic_vector(31 downto 0);
    r1: out std_logic_vector(31 downto 0);
    r2: out std_logic_vector(31 downto 0);
    r3: out std_logic_vector(31 downto 0)
    );
end component;

--signal carry: std_logic_vector(32 downto 0);
component ALU_and_flags is
Port(
    operand1: in std_logic_vector(31 downto 0);
    operand2: in std_logic_vector(31 downto 0);
    result : out std_logic_vector(31 downto 0);
    carry :   in STD_LOGIC;
    control_operation: in std_logic_vector(3 downto 0);     --considering instructions are less than equal to 16
    write_enable_flag: in std_logic;                        -- change flags only when this is equal to 1
    flags_out: out std_logic_vector(3 downto 0)     --ZCNV
    );
    
end component;

component instruction_decoder is
Port(
    instruction: in std_logic_vector(31 downto 0);
    class: out std_logic_vector(1 downto 0);           -- DP=00, DT=01, branch=10, others = 11
    i_decoded : out std_logic_vector(3 downto 0)  -- add,sub,cmp,etc
    );
    
end component;

--component adder_subtractor is
--Port(
--    adder_input1: in std_logic_vector(31 downto 0);
--    adder_input2: in std_logic_vector(31 downto 0);
--    operation: in std_logic;    --0 means add, 1 means subtract
--    adder_out: out std_logic_vector(31 downto 0);
--    carry_in: in std_logic;
--    carry_out: out std_logic
--    );
--end component;

component data_memory is 
Port (     a : in std_logic_vector(9 downto 0);
           d : in std_logic_vector(31 downto 0);
           clk : in std_logic;
           we: in std_logic;
           spo : out std_logic_vector(31 downto 0)
           );
end component;

component instruction_memory is 
Port (     a : in std_logic_vector(7 downto 0);
           spo : out std_logic_vector(31 downto 0)
           );
end component;

--signals below

-----------storing registers--------------
signal IR : std_logic_vector(31 downto 0);
signal DR : std_logic_vector(31 downto 0);
signal A : std_logic_vector(31 downto 0);
signal B : std_logic_vector(31 downto 0);
signal RES : std_logic_vector(31 downto 0);
signal PC : std_logic_vector(31 downto 0);
-------------------------------------------

signal execution_state: integer := 0; -- 0=initial state, 1=onestep, 2=oneinstr, 3=cont, 4=done
signal control_state:   integer := 0; 
--0=fetch, 1=decode, 2=arith, 3=addr, 4=brn, 5=halt, 6=res2RF, 7=mem_wr, 8=mem_rd, 9=mem2RF
-- RED STATES = 4,5,6,7,9
signal red_state : STD_LOGIC := '0';

signal i_decoded : std_logic_vector(3 downto 0);
signal instr_class : std_logic_vector(1 downto 0);

signal ALU_in1 : std_logic_vector(31 downto 0);
signal ALU_in2 : std_logic_vector(31 downto 0);
signal ALU_out : std_logic_vector(31 downto 0);
signal ALU_carry_in: STD_LOGIC;
signal ALU_operation: std_logic_vector(3 downto 0);
signal ALU_write_enable_flag: std_logic;
signal ALU_flags_out: std_logic_vector(3 downto 0);

signal DM_write_enable: STD_LOGIC;
signal DM_address: std_logic_vector(31 downto 0);
signal DM_data: std_logic_vector(31 downto 0);
signal DM_output: std_logic_vector(31 downto 0);

signal IM_output: std_logic_vector(31 downto 0);

signal RF_addr1: std_logic_vector(3 downto 0);
signal RF_addr2: std_logic_vector(3 downto 0);
signal RF_output1: std_logic_vector(31 downto 0);
signal RF_output2: std_logic_vector(31 downto 0);
signal RF_addr_in_wp: std_logic_vector(3 downto 0);
signal RF_data_in_wp: std_logic_vector(31 downto 0);
signal RF_write_enable_wp: std_logic;
signal RF_data_in_pc: std_logic_vector(31 downto 0);
signal RF_data_out_pc: std_logic_vector(31 downto 0);
signal RF_write_enable_pc: STD_LOGIC;

signal sign_extended_IR: std_logic_vector(31 downto 0);

signal L_bit: std_logic;
signal I_bit: std_logic;

begin

--output signals management---

IR_out <= IR;
PC_out <= PC;
ES_out <= execution_state;
CS_out <= control_state;
instr_class_out <= instr_class;
i_decoded_out <= i_decoded;
DR_out <= DR;
A_out <= A;
B_out <= B;
RES_out <= RES;
flags_out <= ALU_flags_out;
------------------------------



--red state management--
red_state <= '1' when (control_state=4 or control_state=5 or control_state=6 or control_state=7 or control_state=9) else
             '0';
------------------------

-------instruction class and i_decoded fetching---------------------------------

L_bit <= IR(20);
I_bit <= IR(25);
-----------------------------------------------------------------------------------


---combinational circuit--

RF_addr1 <= IR(19 downto 16); --A=RF[IR[19-16]]

RF_addr2 <= IR(3 downto 0) when control_state=1 else
            IR(15 downto 12) when control_state=3 else
            "0000";


DM_write_enable <= '1' when control_state=7 else '0';

DM_data <= B when control_state=7 else
           (others => '0');

DM_address <= RES when control_state=7 else
              RES When control_state=8 else
              (others => '0');

RF_addr_in_wp <= IR(15 downto 12) when control_state=9 else
                 IR(15 downto 12) when control_state=6 else
                (others => '0');

RF_data_in_wp <= DR when control_state=9 else
                 RES when control_state=6 else
                 (others => '0'); 

RF_write_enable_wp <= '1' when control_state=6 and (i_decoded /= "0011") else  --not to change when compare
                      '1' when control_state=9 else
                      '0';

ALU_in1 <= PC when (control_state=0) else
           A when (control_state=2 or control_state=3) else
           "00"&PC(31 downto 2) when control_state=4 else
           (others => '0');

ALU_in2 <= "00000000000000000000000000000100" when control_state=0 else
            B when control_state=2 else
            "00000000000000000000"&IR(11 downto 0) when control_state=3 else
            "00"&sign_extended_IR(31 downto 2) when (control_state=4 and sign_extended_IR(31)='0') else
            "11"&sign_extended_IR(31 downto 2) when (control_state=4 and sign_extended_IR(31)='1') else
            (others => '0');

ALU_write_enable_flag <= '1' when ((instr_class="00" and i_decoded="0011") and control_state=2) else  --CMP instruciton
                         '0';

ALU_operation <= IR(24 downto 21) when (control_state=2) else
                 "0100" when (control_state=0 or control_state=3) else
                 "0101" when (control_state=4) else
                 "1111"; -- None

ALU_carry_in <= '1' when control_state=4 else   --useful for PC=PC+S2+4
                '0';


sign_extended_IR <= "00000000"&IR(23 downto 0) when IR(23)='0' else
                    "11111111"&IR(23 downto 0);
--------------------------



--port map below
ID_MAP: instruction_decoder port map (
           instruction => IR,
           class => instr_class,
           i_decoded => i_decoded
           );

IM_MAP: instruction_memory port map (
        a => PC(9 downto 2),
        spo => IM_output
        );
        
DM_MAP: data_memory port map (
        a => DM_address(9 downto 0),
        d => DM_data,
        clk => clock,
        we => DM_write_enable,
        spo => DM_output
        );

RF_MAP: register_file port map(
        read_address1 => RF_addr1,
        data_output1 => RF_output1,

        read_address2 => RF_addr2,
        data_output2 => RF_output2,

        address_input_wp => RF_addr_in_wp,
        data_input_wp => RF_data_in_wp,
        write_enable_wp => RF_write_enable_wp,

        data_input_pc => RF_data_in_pc,
        data_output_pc => RF_data_out_pc,
        write_enable_pc => RF_write_enable_pc,
        
        r0 => R0,
        r1 => R1,
        r2 => R2,
        r3 => R3
        );

ALU_MAP: ALU_and_flags port map(
            operand1 => ALU_in1,
            operand2=> ALU_in2,
            result => ALU_out,
            carry => ALU_carry_in,
            control_operation => ALU_operation,
            write_enable_flag => ALU_write_enable_flag,
            flags_out=>ALU_flags_out
        );

    --execution state FSM process
    process(clock)
        begin
            if rising_edge(clock) then
                if (reset='1') then
                    execution_state <= 0;
                else
                    
                    if (execution_state=0) then
                        if (step='0' and instr='0' and go='0') then
                            execution_state <= 0;
                        elsif (instr='1') then
                            execution_state<=2;
                        elsif (go='1') then
                            execution_state<=3;
                        elsif (step='1') then
                            execution_state<=1;
                        end if;
                    elsif (execution_state=1) then
                        execution_state<=4;
                    elsif (execution_state=2) then
                        if (red_state='1') then
                            execution_state <= 4;
                        else
                            execution_state <= 2;
                        end if;
                    elsif (execution_state=3) then
                        if (control_state/=5) then
                            execution_state <= 3;
                        elsif (control_state=5) then
                            execution_state <= 4;
                        end if; 
                    elsif (execution_state=4) then
                        if (step='1' or instr='1' or go='1') then
                            execution_state <= 4;
                        elsif (step='0' and instr='0' and go='0') then
                            execution_state <= 0;
                        end if;
                        
                    end if;

                end if;
            end if;
    end process;

    --control state FSM process
    process(clock)
        begin
            if rising_edge(clock) then
                if (reset='1') then
                    control_state <= 0;
                else
                    if (execution_state=1 or execution_state=2 or execution_state=3) then
                        case control_state is
                            when 0 =>
                                control_state <= 1;
                            when 1 => 
                                if (instr_class = "00") then    --DP
                                    control_state <= 2;
                                elsif (instr_class = "01") then     --DT
                                    control_state <= 3;
                                elsif (instr_class = "10") then --branch
                                    control_state <= 4;
                                elsif (instr_class = "11") then  --HALT
                                    control_state <= 5;
                                end if;
                            when 2 =>
                                control_state <= 6;
                            when 3 =>
                                if (L_bit = '0') then
                                    control_state <= 7;
                                else
                                    control_state <= 8;
                                end if;
                            when 4 =>
                                control_state <= 0;
                            when 5 =>
                                control_state <= 0;
                            when 6 =>
                                control_state <= 0;
                            when 7 =>
                                control_state <= 0;
                            when 8 =>
                                control_state <= 9;
                            when 9 =>
                                control_state <= 0;
                            when others =>
                                --do nothing
                        end case;
                    else
                        -- do nothing
                    end if;
                end if;
            end if;
    end process;


    -- main process---
     process(clock)
        begin
            if rising_edge(clock) then
                if (reset='1') then
                    PC <= (others => '0');
                else
                    if (execution_state=1 or execution_state=2 or execution_state=3) then -- only works in execution green states
                        case control_state is 
                            when 0 =>
                                IR <= IM_output;
                                PC <= ALU_out;
                            when 1 =>
                                if (I_bit='0') then
                                    A <= RF_output1;
                                    B <= RF_output2;
                                else
                                    A <= RF_output1;
                                    B <= ("000000000000000000000000"&IR(7 downto 0));
                                end if;
                            when 2 =>
                                RES <= ALU_out;
                            when 3 =>
                                RES <= ALU_out;
                                B <= RF_output2;
                            when 4 =>
                                if (instr_class="10" and i_decoded="0111" and ALU_flags_out(0)='1') then -- beq
                                    PC <= ALU_out(29 downto 0)&"00";
                                elsif (instr_class="10" and i_decoded="1000" and ALU_flags_out(0)='0') then  --bne
                                    PC <= ALU_out(29 downto 0)&"00";
                                elsif (instr_class="10" and i_decoded="0110") then  --b
                                    PC <= ALU_out(29 downto 0)&"00";
                                end if;
                            when 5 =>
                                -- HALT state, do nothing
                            when 6 =>
                                -- do nothing because RF is automatically storing
                            when 7 =>
                                -- again do nothing as DM automatically stores on next clock
                            when 8 =>
                                DR <= DM_output;
                            when 9 =>
                                -- do nothing because RF is automatically storing
                            when others =>
                                --do nothing

                        end case;
                    end if;
                end if;
                
            end if;
    end process;

end behavioural;