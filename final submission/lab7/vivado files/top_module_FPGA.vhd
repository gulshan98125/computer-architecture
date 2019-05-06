    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    
    entity top_module_fpga is
    Port (
            switch : in std_logic_vector(15 downto 0);
            step: in std_logic;
            instr: in std_logic;
            go: in std_logic;
            clk_tm : in std_logic;
            led: out std_logic_vector(15 downto 0);
            reset: in std_logic
    );
    end top_module_fpga;
    
    architecture behavioural of top_module_fpga is
    
    -- component declaration for the unit under test (uut)
    component main_processor is
    Port (     clock : in STD_LOGIC;
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
               RES_out : out std_logic_vector(31 downto 0);
               flags_out : out std_logic_vector(3 downto 0);
               RF_write_enable: out std_logic
               );
    end component;
    
    signal clock_signal : std_logic := '0';
    signal reset_signal: std_logic := '0';
    signal step_signal : STD_LOGIC := '0';
    signal go_signal : STD_LOGIC := '0';
    signal instr_signal: std_logic := '0';
    signal switch_val_signal : std_logic_vector(15 downto 0) := (others => '0');
    
    signal IR: std_logic_vector(31 downto 0);
    signal DR: std_logic_vector(31 downto 0);
    signal A: std_logic_vector(31 downto 0);
    signal B: std_logic_vector(31 downto 0);
    signal RES: std_logic_vector(31 downto 0);
    signal PC: std_logic_vector(31 downto 0);
    signal ES: integer;
    signal CS: integer;
    signal instr_class:  std_logic_vector(1 downto 0);
    signal i_decoded:  std_logic_vector(3 downto 0);
    signal flags: std_logic_vector(3 downto 0);
    signal RF_write_enable: std_logic;
    
    signal R0 : std_logic_vector(31 downto 0);
    signal R1 : std_logic_vector(31 downto 0);
    signal R2 : std_logic_vector(31 downto 0);
    signal R3 : std_logic_vector(31 downto 0);
    signal R4 : std_logic_vector(31 downto 0);
    signal R5 : std_logic_vector(31 downto 0);
    signal R6 : std_logic_vector(31 downto 0);
    signal R7 : std_logic_vector(31 downto 0);
    signal R8 : std_logic_vector(31 downto 0);
    signal R9 : std_logic_vector(31 downto 0);
    signal R10 : std_logic_vector(31 downto 0);
    signal R11 : std_logic_vector(31 downto 0);
    signal R12 : std_logic_vector(31 downto 0);
    signal R13 : std_logic_vector(31 downto 0);
    signal R14 : std_logic_vector(31 downto 0);
    signal R15 : std_logic_vector(31 downto 0);
    signal fake_clock: std_logic := '0';
    signal counter : integer := 0;
    
    begin
    
    clock_signal <= clk_tm;
    step_signal <= step;
    go_signal <= go;
    switch_val_signal <= switch;
    reset_signal <= reset;
    instr_signal <= instr;
    
    led <= R0(15 downto 0) when switch="0000000000000000" else  --r0
           R1(15 downto 0) when switch="0000000000000001" else  --r1
           R2(15 downto 0) when switch="0000000000000010" else  --r2
           R3(15 downto 0) when switch="0000000000000011" else  --r3
           R4(15 downto 0) when switch="0000000000000100" else  --r4
           R5(15 downto 0) when switch="0000000000000101" else  --r5
           R6(15 downto 0) when switch="0000000000000110" else  --r6
           R7(15 downto 0) when switch="0000000000000111" else  --r7
           R8(15 downto 0) when switch="0000000000001000" else  --r8
           R9(15 downto 0) when switch="0000000000001001" else  --r9
           R10(15 downto 0) when switch="0000000000001010" else  --r10
           R11(15 downto 0) when switch="0000000000001011" else  --r11
           R12(15 downto 0) when switch="0000000000001100" else  --r12
           R13(15 downto 0) when switch="0000000000001101" else  --r13
           R14(15 downto 0) when switch="0000000000001110" else  --r14
           R15(15 downto 0) when switch="0000000000001111" else  --r15
    
           IR(15 downto 0) when  switch="0000000000010000" else  --IR
           IR(31 downto 16) when switch="1000000000010000" else  --IR
    
           A(15 downto 0) when  switch="0000000000010100" else  --A
           A(31 downto 16) when switch="1000000000010100" else  --A
    
           B(15 downto 0) when  switch="0000000000011000" else  --B
           B(31 downto 16) when switch="1000000000011000" else  --B
    
           RES(15 downto 0) when  switch="0000000000100000" else  --RES
           RES(31 downto 16) when switch="1000000000100000" else  --RES
    
           PC(15 downto 0) when  switch="0000000000001001" else  --PC
           PC(31 downto 16) when switch="1000000000001001" else  --PC
    
           std_logic_vector(to_unsigned(ES, led'length)) when  switch="0000000000110000" else  --ES
           std_logic_vector(to_unsigned(CS, led'length)) when  switch="0000000000110100" else  --CS
    
           "000000000000"&flags when switch="0000000000111000" else --flags
           "0000000000000000";
    
    
    
    MP_MAP : main_processor port map (
             clock => clk_tm,
             reset => reset_signal, 
             step => step_signal,
             instr => instr_signal,
             go => go_signal,
             IR_out => IR,
             PC_out => PC,
             ES_out => ES,
             CS_out => CS,
             instr_class_out => instr_class,
             i_decoded_out => i_decoded,
             R0 => R0,
             R1 => R1,
             R2 => R2,
             R3 => R3,
             R4 => R4,
             R5 => R5,
             R6 => R6,
             R7 => R7,
             R8 => R8,
             R9 => R9,
             R10 => R10,
             R11 => R11,
             R12 => R12,
             R13 => R13,
             R14 => R14,
             R15 => R15,
             DR_out => DR,
             A_out => A,
             B_out => B,
             RES_out => RES,
             flags_out => flags,
             RF_write_enable => RF_write_enable
         );
         
    process(clk_tm)
            begin
                if rising_edge(clk_tm) then
                if (counter=100) then
                    counter <= 0;
                    if fake_clock='1' then
                        fake_clock <= '0';
                    else
                        fake_clock <= '1';
                    end if;
                else
                    counter <= counter + 1;
                end if;
                end if;
        end process;
         
    end behavioural;