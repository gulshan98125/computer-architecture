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
           i_decoded_out: out std_logic_vector(4 downto 0);
           R0 : out std_logic_vector(31 downto 0);
           R1 : out std_logic_vector(31 downto 0);
           R2 : out std_logic_vector(31 downto 0);
           R3 : out std_logic_vector(31 downto 0);
           R4 : out std_logic_vector(31 downto 0);
           R5 : out std_logic_vector(31 downto 0);
           R6 : out std_logic_vector(31 downto 0);
           R7 : out std_logic_vector(31 downto 0);
           R8 : out std_logic_vector(31 downto 0);
           R9 : out std_logic_vector(31 downto 0);
           R10 : out std_logic_vector(31 downto 0);
           R11 : out std_logic_vector(31 downto 0);
           R12 : out std_logic_vector(31 downto 0);
           R13 : out std_logic_vector(31 downto 0);
           R14 : out std_logic_vector(31 downto 0);
           R15 : out std_logic_vector(31 downto 0);
           DR_out : out std_logic_vector(31 downto 0);
           A_out : out std_logic_vector(31 downto 0);
           B_out : out std_logic_vector(31 downto 0);
           D_out : out std_logic_vector(31 downto 0);
           RES_out : out std_logic_vector(31 downto 0);
           flags_out : out std_logic_vector(3 downto 0);
           RF_write_enable: out std_logic;
           dm_wr_enable1: out std_logic;
           dm_wr_enable2: out std_logic;
           dm_wr_enable3: out std_logic;
           dm_wr_enable4: out std_logic;
           data_to_dm : out std_logic_vector(31 downto 0);
           X_out : out std_logic_vector(4 downto 0)
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
    r0 : out std_logic_vector(31 downto 0);
    r1 : out std_logic_vector(31 downto 0);
    r2 : out std_logic_vector(31 downto 0);
    r3 : out std_logic_vector(31 downto 0);
    r4 : out std_logic_vector(31 downto 0);
    r5 : out std_logic_vector(31 downto 0);
    r6 : out std_logic_vector(31 downto 0);
    r7 : out std_logic_vector(31 downto 0);
    r8 : out std_logic_vector(31 downto 0);
    r9 : out std_logic_vector(31 downto 0);
    r10 : out std_logic_vector(31 downto 0);
    r11 : out std_logic_vector(31 downto 0);
    r12 : out std_logic_vector(31 downto 0);
    r13 : out std_logic_vector(31 downto 0);
    r14 : out std_logic_vector(31 downto 0);
    r15 : out std_logic_vector(31 downto 0);
    clock: in std_logic
    );
end component;

--signal carry: std_logic_vector(32 downto 0);
component ALU_and_flags is
Port(
    operand1: in std_logic_vector(31 downto 0);
    operand2: in std_logic_vector(31 downto 0);
    result : out std_logic_vector(31 downto 0);
    carry :   in STD_LOGIC;
    carry_from_shifter: in STD_LOGIC;
    control_operation: in std_logic_vector(3 downto 0);     --considering instructions are less than equal to 16
    write_enable_flag: in std_logic;                        -- change flags only when this is equal to 1
    flags_out: out std_logic_vector(3 downto 0)     --ZCNV
    );
    
end component;

component instruction_decoder is
Port(
    instruction: in std_logic_vector(31 downto 0);
    class: out std_logic_vector(1 downto 0);           -- DP=00, DT=01, branch=10, others = 11
    i_decoded : out std_logic_vector(4 downto 0)  -- add,sub,cmp,etc
    );
    
end component;

component shifter is
Port(
    shift_input: in std_logic_vector(31 downto 0);
    shift_type: in std_logic_vector(1 downto 0);
    shift_amt: in std_logic_vector(4 downto 0);
    shift_output: out std_logic_vector(31 downto 0);
    carry: out std_logic
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

------- 4 memories with 8 bit wide data each and single input, gives 8 bit output-----
--dm1 leftmost 8 bits, dm2 2nd leftmost 8 bits, dm3 2nd rightmost 8 bits, dm4 rightmost 8 bits
component data_memory1 is 
Port (     a : in std_logic_vector(9 downto 0);
           d : in std_logic_vector(7 downto 0);
           clk : in std_logic;
           we: in std_logic;
           spo : out std_logic_vector(7 downto 0)
           );
end component;
component data_memory2 is 
Port (     a : in std_logic_vector(9 downto 0);
           d : in std_logic_vector(7 downto 0);
           clk : in std_logic;
           we: in std_logic;
           spo : out std_logic_vector(7 downto 0)
           );
end component;
component data_memory3 is 
Port (     a : in std_logic_vector(9 downto 0);
           d : in std_logic_vector(7 downto 0);
           clk : in std_logic;
           we: in std_logic;
           spo : out std_logic_vector(7 downto 0)
           );
end component;
component data_memory4 is 
Port (     a : in std_logic_vector(9 downto 0);
           d : in std_logic_vector(7 downto 0);
           clk : in std_logic;
           we: in std_logic;
           spo : out std_logic_vector(7 downto 0)
           );
end component;
---------------------------------------------------------

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
signal X : std_logic_vector(4 downto 0); -- shift amount 5 bits
signal RES : std_logic_vector(31 downto 0);
signal PC : std_logic_vector(31 downto 0);
signal D : std_logic_vector(31 downto 0);
-------------------------------------------

signal execution_state: integer := 0; -- 0=initial state, 1=onestep, 2=oneinstr, 3=cont, 4=done
signal control_state:   integer := 0; 
--0=fetch, 1=decode, 2=arith, 3=addr, 4=brn, 5=halt, 6=res2RF, 7=mem_wr, 8=mem_rd, 9=mem2RF
-- RED STATES = 4,5,6,7,9
signal red_state : STD_LOGIC := '0';

signal i_decoded : std_logic_vector(4 downto 0);
signal instr_class : std_logic_vector(1 downto 0);

signal ALU_in1 : std_logic_vector(31 downto 0);
signal ALU_in2 : std_logic_vector(31 downto 0);
signal ALU_out : std_logic_vector(31 downto 0);
signal ALU_carry_in: STD_LOGIC;
signal ALU_operation: std_logic_vector(3 downto 0);
signal ALU_write_enable_flag: std_logic;
signal ALU_flags_out: std_logic_vector(3 downto 0);

signal DM_write_enable1: STD_LOGIC;
signal DM_write_enable2: STD_LOGIC;
signal DM_write_enable3: STD_LOGIC;
signal DM_write_enable4: STD_LOGIC;
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


signal shifter_input: std_logic_vector(31 downto 0);
signal shifter_type: std_logic_vector(1 downto 0);
signal shifter_amt: std_logic_vector(4 downto 0);
signal shifter_output: std_logic_vector(31 downto 0);
signal shifter_carry_out: std_logic;


signal sign_extended_IR: std_logic_vector(31 downto 0);

signal selected_byte_to_memory : std_logic_vector(7 downto 0);
signal selected_half_word_to_memory : std_logic_vector(15 downto 0);

signal selected_byte_to_reg : std_logic_vector(7 downto 0);
signal selected_half_word_to_reg : std_logic_vector(15 downto 0);
signal isbyte_or_hw: std_logic_vector(1 downto 0);

signal L_bit: std_logic;
signal I_bit: std_logic;
signal U_bit: std_logic;
signal S_bit : std_logic;
signal P_bit : std_logic;
begin

--signals to simulate managing--
flags_out <= ALU_flags_out;
IR_out <= IR;
PC_out <= PC;
ES_out <= execution_state;
CS_out <= control_state;
instr_class_out <= instr_class;
i_decoded_out <= i_decoded;
DR_out <= DR;
A_out <= A;
B_out <= B;
D_out <= D;
RES_out <= RES;

RF_write_enable <= '1' when (control_state=6 and ((i_decoded /= "00011") and (i_decoded/="01111") and (i_decoded/="10000") and (i_decoded/="10001"))) else  --not to change when cmp,tst,teq,cmn
                      '1' when control_state=9 else
                      '0';
dm_wr_enable1 <= DM_write_enable1;
dm_wr_enable2 <= DM_write_enable2;
dm_wr_enable3 <= DM_write_enable3;
dm_wr_enable4 <= DM_write_enable4;
data_to_dm <= DM_data;                 
X_out <= X;
--------------------------------


--red state management--
red_state <= '1' when (control_state=4 or control_state=5 or control_state=6 or control_state=7 or control_state=9) else
             '0';
------------------------

-------instruction class and i_decoded fetching---------------------------------

L_bit <= IR(20);
I_bit <= IR(25);
U_bit <= IR(23);
S_bit <= IR(20);
P_bit <= IR(24);

--11 = byte, 00 = hw else 10
isbyte_or_hw <= "11" when i_decoded="10101" and IR(6 downto 5)="10" else  -- signed byte
          "11" when instr_class="01" and IR(22)='1' else --B_bit = 1 means unsigned byte
          "00" when i_decoded="10101" and ( IR(6 downto 5)="01" or IR(6 downto 5)="11" ) else  --half word from DT_SH
          "10";

-----------------------------------------------------------------------------------


---combinational circuit--
selected_byte_to_memory <=  B(7 downto 0) when (control_state=7) else  --selecting the lowest byte
                            --B(31 downto 24) when (RES(1 downto 0)="00" and control_state=7) else --all below useful for STR_SH byte
                            --B(23 downto 16) when (RES(1 downto 0)="01" and control_state=7) else
                            --B(15 downto 8)  when (RES(1 downto 0)="10" and control_state=7) else
                            --B(7 downto 0)   when (RES(1 downto 0)="11" and control_state=7) else 
                           (others => '0');

selected_half_word_to_memory <= B(15 downto 0) when (control_state=7) else --selecting the lowest half word
                                --B(31 downto 16) when (RES(1)='0' and control_state=7) else --all below useful for STR_SH half word
                                --B(15 downto 0) when (RES(1)='1' and control_state=7) else 
                                (others => '0');

selected_byte_to_reg <=    DM_output(7 downto 0)   when (RES(1 downto 0)="11" and control_state=8) else  --all below useful for LDR_SH byte
                           DM_output(15 downto 8)  when (RES(1 downto 0)="10" and control_state=8) else
                           DM_output(23 downto 16) when (RES(1 downto 0)="01" and control_state=8) else
                           DM_output(31 downto 24) when (RES(1 downto 0)="00" and control_state=8) else
                           (others => '0');

selected_half_word_to_reg <=    DM_output(31 downto 16) when (RES(1)='0' and control_state=8) else --all below useful for STR_SH half word
                                DM_output(15 downto 0) when (RES(1)='1' and control_state=8) else 
                                (others => '0');


RF_addr1 <= IR(19 downto 16); --A=RF[IR[19-16]]

RF_addr2 <= IR(3 downto 0) when control_state=1 else
            IR(15 downto 12) when control_state=3 else
            IR(11 downto 8) when control_state=10 else
            "0000";

--DT_SH instr
DM_write_enable1 <= '0' when control_state=7 and isbyte_or_hw="11" and RES(1 downto 0)/="00" else
                    '0' when control_state=7 and isbyte_or_hw="00" and RES(1)/='0' else  
                    '1' when control_state=7 else
                    '0';
DM_write_enable2 <= '0' when control_state=7 and isbyte_or_hw="11" and RES(1 downto 0)/="01" else
                    '0' when control_state=7 and isbyte_or_hw="00" and RES(1)/='0' else
                    '1' when control_state=7 else
                    '0';

DM_write_enable3 <= '0' when control_state=7 and isbyte_or_hw="11" and RES(1 downto 0)/="10" else
                    '0' when control_state=7 and isbyte_or_hw="00" and RES(1)/='1' else
                    '1' when control_state=7 else
                    '0';

DM_write_enable4 <= '0' when control_state=7 and isbyte_or_hw="11" and RES(1 downto 0)/="11" else
                    '0' when control_state=7 and isbyte_or_hw="00" and RES(1)/='1' else
                    '1' when control_state=7 else
                    '0';

DM_data <=  B when (control_state=7 and i_decoded /= "10101") else --not a DT_SH instr, simple str
            (selected_byte_to_memory&selected_byte_to_memory&selected_byte_to_memory&selected_byte_to_memory) when (control_state=7 and isbyte_or_hw="11") else --when byte
            (selected_half_word_to_memory&selected_half_word_to_memory) when (control_state=7 and isbyte_or_hw="00") else -- when half word
            --"000000000000000000000000"&selected_byte_to_memory when (control_state=7 and selected_byte_to_memory(7)='0' and IR(6 downto 5)="10" and i_decoded="10101") else
            --"111111111111111111111111"&selected_byte_to_memory when (control_state=7 and selected_byte_to_memory(7)='1' and IR(6 downto 5)="10" and i_decoded="10101") else
            --"0000000000000000"&selected_half_word_to_memory when (control_state=7 and selected_half_word_to_memory(15)='0' and IR(6 downto 5)="11" and i_decoded="10101") else
            --"1111111111111111"&selected_half_word_to_memory when (control_state=7 and selected_half_word_to_memory(15)='1' and IR(6 downto 5)="11" and i_decoded="10101") else
            --"0000000000000000"&selected_half_word_to_memory when (control_state=7 and IR(6 downto 5)="01" and i_decoded="10101") else
            (others => '0');

DM_address <= RES when (control_state=7 and P_bit='1') else
              A when (control_state=7 and P_bit='0') else
              RES when (control_state=8 and P_bit='1') else
              A when (control_state=8 and P_bit='0') else
              (others => '0');

RF_addr_in_wp <= IR(15 downto 12) when control_state=9 else
                 IR(15 downto 12) when control_state=6 else
                 IR(19 downto 16) when (control_state=7 and P_bit='0') else
                 IR(19 downto 16) when (control_state=8 and P_bit='0') else
                (others => '0');

RF_data_in_wp <= DR when control_state=9 else
                 RES when control_state=6 else
                 RES when (control_state=7 and P_bit='0') else
                 RES when (control_state=8 and P_bit='0') else
                 (others => '0'); 

RF_write_enable_wp <= '1' when (control_state=6 and ((i_decoded /= "00011") and (i_decoded/="01111") and (i_decoded/="10000") and (i_decoded/="10001"))) else  --not to change when cmp,tst,teq,cmn
                      '1' when control_state=9 else
                      '1' when P_bit='0' and (control_state=7 or control_state=8) else
                      '0';

ALU_in1 <= PC when (control_state=0) else
           A when (control_state=2 or control_state=3) else
           "00"&PC(31 downto 2) when control_state=4 else
           (others => '0');

ALU_in2 <= "00000000000000000000000000000100" when control_state=0 else
            D when (control_state=2 or control_state=3) else
            --"00000000000000000000"&IR(11 downto 0) when control_state=3 else --old
            "00"&sign_extended_IR(31 downto 2) when (control_state=4 and sign_extended_IR(31)='0') else
            "11"&sign_extended_IR(31 downto 2) when (control_state=4 and sign_extended_IR(31)='1') else
            (others => '0');

ALU_write_enable_flag <= '1' when (i_decoded="00011" and control_state=2) else  --CMP instruciton
                         '1' when (i_decoded="10001" and control_state=2) else  -- CMN
                         '1' when (i_decoded="01111" and control_state=2) else  --TST
                         '1' when (i_decoded="10000" and control_state=2) else  --TEQ
                         '1' when (S_bit='1' and instr_class="00" and control_state=2) else  -- DP instruction when S=1 and control state=2
                         '0';

ALU_operation <= IR(24 downto 21) when (control_state=2) else  -- ALU operation is basically opcode of DP
                 "0100" when (control_state=0 ) else
                 "0100" when (control_state=3 and U_bit='1') else --ADD
                 "0010" when (control_state=3 and U_bit='0') else --SUB
                 "0101" when (control_state=4) else
                 "1111"; -- None

ALU_carry_in <= '1' when control_state=4 else   --useful for PC=PC+S2+4
                '0';




sign_extended_IR <= "00000000"&IR(23 downto 0) when IR(23)='0' else
                    "11111111"&IR(23 downto 0);


shifter_type  <= "11" when (I_bit='1' and instr_class="00") else--ROTSPEC when DP immediate
                 IR(6 downto 5) when (I_bit='0' and instr_class="00") else
                 IR(6 downto 5) when (I_bit='1' and instr_class="01") else -- DT
                 "00";
shifter_amt <= X;
shifter_input <= B;


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
        
DM_MAP1: data_memory1 port map (
        a => DM_address(9 downto 0),
        d => DM_data(31 downto 24),
        clk => clock,
        we => DM_write_enable1,
        spo => DM_output(31 downto 24)
        );
DM_MAP2: data_memory2 port map (
        a => DM_address(9 downto 0),
        d => DM_data(23 downto 16),
        clk => clock,
        we => DM_write_enable2,
        spo => DM_output(23 downto 16)
        );
DM_MAP3: data_memory3 port map (
        a => DM_address(9 downto 0),
        d => DM_data(15 downto 8),
        clk => clock,
        we => DM_write_enable3,
        spo => DM_output(15 downto 8)
        );
DM_MAP4: data_memory4 port map (
        a => DM_address(9 downto 0),
        d => DM_data(7 downto 0),
        clk => clock,
        we => DM_write_enable4,
        spo => DM_output(7 downto 0)
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
        r3 => R3,
        r4 => R4,
        r5 => R5,
        r6 => R6,
        r7 => R7,
        r8 => R8,
        r9 => R9,
        r10 => R10,
        r11 => R11,
        r12 => R12,
        r13 => R13,
        r14 => R14,
        r15 => R15,
        clock => clock
        );

ALU_MAP: ALU_and_flags port map(
            operand1 => ALU_in1,
            operand2=> ALU_in2,
            result => ALU_out,
            carry => ALU_carry_in,
            carry_from_shifter => shifter_carry_out,
            control_operation => ALU_operation,
            write_enable_flag => ALU_write_enable_flag,
            flags_out=>ALU_flags_out
        );

SHIFTER_MAP: shifter port map(
            shift_input => shifter_input,
            shift_type => shifter_type,
            shift_amt => shifter_amt,
            shift_output => shifter_output,
            carry => shifter_carry_out
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
                                if instr_class="00" and i_decoded /= "10101" and IR(24 downto 23)="10" and S_bit /= '1' then --dp
                                    --dont change state
                                elsif i_decoded = "10101" and L_bit='0' and IR(6 downto 5) /= "01" then
                                   --dont change state
                                elsif instr_class="01" and P_bit='0' and IR(21)/='0' then
                                   --dont change state
                                else
                                    control_state <= 1;
                                end if;
                            when 1 => 
                                if (instr_class = "00" and i_decoded/="10101") then    --DP
                                    control_state <= 10;
                                elsif (instr_class = "01" or i_decoded="10101") then     --DT or DT_SH
                                    control_state <= 12;
                                elsif (instr_class = "10") then --branch
                                    control_state <= 4;
                                elsif (instr_class = "11") then  --HALT
                                    control_state <= 5;
                                end if;
                            when 12 =>
                                control_state <= 3;
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
                            when 10 =>
                                control_state <= 11;
                            when 11 =>
                                control_state <= 2;
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
                                A <= RF_output1;
                                if (instr_class="01" and I_bit='1') then --useful for DT shift imm
                                    X <= IR(11 downto 7);
                                else
                                    X <= "00000";
                                end if;

                                if (i_decoded ="10101" and IR(22)='0') then --DT_SH imm
                                    B <= ("000000000000000000000000"&IR(11 downto 8)&IR(3 downto 0));
                                elsif (i_decoded ="10101" and IR(22)='1') then --DT_SH reg
                                    B <= RF_output2;

                                elsif (instr_class="01" and I_bit='0') then --DT imm
                                    B <= ("00000000000000000000"&IR(11 downto 0));
                                elsif (instr_class="01" and I_bit='1') then --DT reg
                                    B <= RF_output2;

                                elsif (I_bit='0') then  --DP reg
                                    B <= RF_output2;
                                else
                                    B <= ("000000000000000000000000"&IR(7 downto 0));      --DP imm
                                end if;

                            when 12 =>
                                D <= shifter_output;

                            when 10 =>
                                if (I_bit='0' and IR(4)='1') then
                                    X <= RF_output2(4 downto 0);
                                elsif (I_bit='0' and IR(4)='0') then
                                    X <= IR(11 downto 7);
                                elsif (I_bit='1') then
                                    X <= IR(11 downto 8)&"0"; --ROTSPEC
                                    --something something   
                                end if;
                            when 11 =>
                                D <= shifter_output;

                            when 2 =>
                                RES <= ALU_out;
                            when 3 =>
                                RES <= ALU_out;
                                B <= RF_output2;
                            when 4 =>
                                if (instr_class="10" and i_decoded="00111" and ALU_flags_out(0)='1') then -- beq
                                    PC <= ALU_out(29 downto 0)&"00";
                                elsif (instr_class="10" and i_decoded="01000" and ALU_flags_out(0)='0') then  --bne
                                    PC <= ALU_out(29 downto 0)&"00";
                                elsif (instr_class="10" and i_decoded="00110") then  --b
                                    PC <= ALU_out(29 downto 0)&"00";
                                end if;
                                
                            when 5 =>
                                -- HALT state, do nothing
                            when 6 =>
                                -- do nothing because RF is automatically storing
                            when 7 =>
                                -- do nothing because DM and RF is automatically storing
                            when 8 =>
                                if (i_decoded="10101" and IR(6 downto 5)="10") then-- signed byte
                                    if selected_byte_to_reg(7)='0' then
                                        DR <= "000000000000000000000000"&selected_byte_to_reg;
                                    else
                                        DR <= "111111111111111111111111"&selected_byte_to_reg;
                                    end if;

                                elsif (i_decoded="10101" and IR(6 downto 5)="11") then-- signed half word
                                    if selected_half_word_to_reg(15)='0' then
                                        DR <= "0000000000000000"&selected_half_word_to_reg;
                                    else
                                        DR <= "1111111111111111"&selected_half_word_to_reg;
                                    end if;

                                elsif (i_decoded="10101" and IR(6 downto 5)="01") then-- unsigned half word
                                    DR <= "0000000000000000"&selected_half_word_to_reg;

                                elsif (instr_class="01" and IR(22)='1') then --DT instr with B bit = 1
                                    DR <= "000000000000000000000000"&selected_byte_to_reg;
                                else
                                    DR <= DM_output;
                                end if;
                                
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