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
               i_decoded_out: out std_logic_vector(4 downto 0);
               R0 : out std_logic_vector(31 downto 0);
               R1 : out std_logic_vector(31 downto 0);
               R2 : out std_logic_vector(31 downto 0);
               R3 : out std_logic_vector(31 downto 0);
               DR_out : out std_logic_vector(31 downto 0);
               A_out : out std_logic_vector(31 downto 0);
               B_out : out std_logic_vector(31 downto 0);
               RES_out : out std_logic_vector(31 downto 0);
               flags_out : out std_logic_vector(3 downto 0);
               RF_write_enable: out std_logic;
               X_out: out std_logic_vector(4 downto 0)
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
    signal i_decoded:  std_logic_vector(4 downto 0);
    signal flags: std_logic_vector(3 downto 0);
    signal RF_write_enable: std_logic;
    
    signal R0 : std_logic_vector(31 downto 0);
    signal R1 : std_logic_vector(31 downto 0);
    signal R2 : std_logic_vector(31 downto 0);
    signal R3 : std_logic_vector(31 downto 0);
    signal X: std_logic_vector(4 downto 0);
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
    
           IR(15 downto 0) when  switch="0000000000000100" else  --IR
           IR(31 downto 16) when switch="1000000000000100" else  --IR
    
           A(15 downto 0) when  switch="0000000000000101" else  --A
           A(31 downto 16) when switch="1000000000000101" else  --A
    
           B(15 downto 0) when  switch="0000000000000110" else  --B
           B(31 downto 16) when switch="1000000000000110" else  --B
    
           RES(15 downto 0) when  switch="0000000000001000" else  --RES
           RES(31 downto 16) when switch="1000000000001000" else  --RES
    
           PC(15 downto 0) when  switch="0000000000001001" else  --PC
           PC(31 downto 16) when switch="1000000000001001" else  --PC
    
           std_logic_vector(to_unsigned(ES, led'length)) when  switch="0000000000001100" else  --ES
           std_logic_vector(to_unsigned(CS, led'length)) when  switch="0000000000001101" else  --CS
    
           "000000000000"&flags when switch="0000000000001110" else --flags
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
             DR_out => DR,
             A_out => A,
             B_out => B,
             RES_out => RES,
             flags_out => flags,
             RF_write_enable => RF_write_enable,
             X_out => X
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