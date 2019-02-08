    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;

    entity CPU is
        Port ( clock : in STD_LOGIC;
               reset : in STD_LOGIC;
               instruction : in std_logic_vector(31 downto 0);
               data_from_data_mem: in std_logic_vector(31 downto 0);
               addr_to_prog_mem : out std_logic_vector(31 downto 0);
               addr_to_data_mem : out std_logic_vector(31 downto 0);
               data_to_data_mem : out std_logic_vector(31 downto 0);
               wr_enable_to_dm : out STD_LOGIC
               );
    end CPU;

    architecture Behavioral of CPU is

    type instr_class_type is (DP, DT, branch, unknown);
    type i_decoded_type is (add,sub,cmp,mov,ldr,str,beq,bne,b,unknown);


    component Adder is
    Port(
        adder_in1: in std_logic_vector(31 downto 0);
        adder_in2: in std_logic_vector(31 downto 0);
        adder_sum_out: out std_logic_vector(31 downto 0)
        );
    end component;


    signal instr_class : instr_class_type;
    signal i_decoded : i_decoded_type;
    signal cond : std_logic_vector (3 downto 0);
    signal F_field : std_logic_vector (1 downto 0);
    signal shift_spec : std_logic_vector (7 downto 0);
    signal opcode : std_logic_vector (3 downto 0);
    signal L_bit : std_logic;
    signal I_bit : std_logic;
    signal U_bit : std_logic;
    signal Rn : std_logic_vector(3 downto 0):= (others => '0');
    signal Rd : std_logic_vector(3 downto 0):= (others => '0');
    signal Rm : std_logic_vector(3 downto 0):= (others => '0');
    signal Rn_val : std_logic_vector(31 downto 0):= (others => '0');
    signal Rd_val : std_logic_vector(31 downto 0);
    signal Rm_val : std_logic_vector(31 downto 0):= (others => '0');
    signal FLAGS: std_logic_vector(3 downto 0):="0000";     --ZCNV

    type register_list is array (0 to 14) of std_logic_vector(31 downto 0);
    signal registers : register_list:=(others=>x"00000000");
    signal PC: std_logic_vector(31 downto 0):= (others => '0');
    signal register_index1 : integer := 0; --Rn
    signal register_index2 : integer := 0; --Rd
    signal register_index3 : integer := 0; --Rm

    begin
        
        cond <= instruction(31 downto 28);
        F_field <= instruction(27 downto 26);
        shift_spec <= instruction (11 downto 4);
        opcode <= instruction (24 downto 21);
        L_bit <= instruction(20);

        instr_class <=  DP when F_field="00" else
                        DT when F_field="01" else
                        branch when F_field="10" else
                        unknown;
        i_decoded <=    add when instr_class=DP and opcode="0100" else
                        sub when instr_class=DP and opcode="0010" else
                        mov when instr_class=DP and opcode="1101" else
                        cmp when instr_class=DP and opcode="1010" else
                        str when instr_class=DT and L_bit='0' else
                        ldr when instr_class=DT and L_bit='1' else
                        b when instr_class=branch and cond="1110" else
                        beq when instr_class=branch and cond="0000" else
                        bne when instr_class=branch and cond="0001" else
                        unknown;
        I_bit <= instruction(25);
        U_bit <= instruction(23);
        Rn <= instruction(19 downto 16);
        Rd <= instruction(15 downto 12);
        Rm <= instruction(3 downto 0);
        register_index1 <= to_integer(unsigned(Rn));
        register_index2 <= to_integer(unsigned(Rd));
        register_index3 <= to_integer(unsigned(Rm));

        process(clock, reset)
            variable temp1 : std_logic_vector(31 downto 0);
            variable offset : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
            variable PC_VAR: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
            begin
                if rising_edge(clock) then
                    if (reset = '1') then
                        PC <= (others => '0'); 
                    else
                        case(instr_class) is
                            when DP =>
                                case(i_decoded) is
                                    when add =>
                                        if I_bit='1' then
                                            --add immediate
                                            --Rn_val <= registers(register_index1);
                                            --Rm_val(7 downto 0) <= instruction(7 downto 0);  -- copying only 8 bits to immediate, Rm_val is imm8 here
                                            --Rm_val(31 downto 8) <= (others => '0');
                                            --Rd_val <= Rn_val + Rm_val;
                                            registers(register_index2) <= registers(register_index1) + ("000000000000000000000000"&instruction(7 downto 0));
                                            wr_enable_to_dm <= '0';

                                        else
                                            --normal add
                                            registers(register_index2) <= registers(register_index1) + registers(register_index3);
                                            wr_enable_to_dm <= '0';
                                            
                                        end if;
                                    when sub =>
                                        if I_bit='1' then
                                            --sub immediate
                                            registers(register_index2) <= registers(register_index1) + (not ("000000000000000000000000"&instruction(7 downto 0))) + "00000000000000000000000000000001";
                                            wr_enable_to_dm <= '0';

                                        else
                                            --normal sub
                                            registers(register_index2) <= registers(register_index1) + (not registers(register_index3)) + "00000000000000000000000000000001";
                                            wr_enable_to_dm <= '0';

                                        end if;
                                    when cmp =>
                                        if I_bit='1' then
                                            --cmp immediate     --cmp me ignoring Rd
                                            Rd_val <= registers(register_index1) + (not ("000000000000000000000000"&instruction(7 downto 0))) + "00000000000000000000000000000001";
                                            wr_enable_to_dm <= '0';
                                            temp1 := registers(register_index1) + (not ("000000000000000000000000"&instruction(7 downto 0))) + "00000000000000000000000000000001"; 
                                            if (temp1="00000000000000000000000000000000") then
                                                --equal
                                                FLAGS(0)<='1';
                                            else
                                                FLAGS(0)<='0';
                                            end if;

                                        else
                                            --normal cmp
                                            Rd_val <= registers(register_index1) + (not registers(register_index3)) + "00000000000000000000000000000001";
                                            wr_enable_to_dm <= '0';
                                            temp1 := registers(register_index1) + (not registers(register_index3)) + "00000000000000000000000000000001";
                                            if (temp1="00000000000000000000000000000000") then
                                                --equal
                                                FLAGS(0)<='1';
                                            else
                                                FLAGS(0)<='0';
                                            end if;
                                            
                                        end if;
                                    when mov =>
                                        if I_bit='1' then    --mov me ignoring Rn
                                            --mov immediate
                                            registers(register_index2) <= ("000000000000000000000000"&instruction(7 downto 0));
                                            wr_enable_to_dm <= '0';

                                        else
                                            --normal mov
                                            registers(register_index2) <= registers(register_index3);
                                            wr_enable_to_dm <= '0';
                                            
                                        end if;
                                    when others =>
                                        --do nothing
                                end case;
                            
                            when DT =>
                                case(i_decoded) is
                                    when ldr =>
                                        if U_bit='1' then
                                            --ldr immediate offset +
                                            addr_to_data_mem <= registers(register_index1) + ("00000000000000000000"&instruction(11 downto 0));
                                            wr_enable_to_dm <= '0';
                                            --after memory gets address--
                                            --registers(register_index2) <= data_from_data_mem;

                                        else
                                            --ldr immediate offset -
                                            addr_to_data_mem <= registers(register_index1) + ((not ("00000000000000000000"&instruction(11 downto 0))) + "00000000000000000000000000000001");
                                            wr_enable_to_dm <= '0';
                                            --after getting address--
                                            --registers(register_index2) <= data_from_data_mem;
                                            
                                        end if;
                                    when str =>
                                        if U_bit='1' then
                                            --str immediate offset +
                                            wr_enable_to_dm <= '1';
                                            addr_to_data_mem <= registers(register_index1) + ("00000000000000000000"&instruction(11 downto 0));
                                            data_to_data_mem <= registers(register_index2);
                                        else
                                            --str immediate offset -
                                            wr_enable_to_dm <= '1';
                                            addr_to_data_mem <= registers(register_index1) + ((not ("00000000000000000000"&instruction(11 downto 0))) + "00000000000000000000000000000001");
                                            data_to_data_mem <= registers(register_index2);
                                        end if;
                                    when others =>
                                        --do nothing

                                end case;
                            
                            when branch =>
                                case(i_decoded) is
                                    when beq =>
                                        if FLAGS(0)='1' then
                                            if (instruction(23)='1') then
                                                offset := ("11111111"&instruction(23 downto 0));
                                            else
                                                offset := ("00000000"&instruction(23 downto 0));
                                            end if;
                                        else
                                            -- do nothing
                                        end if;
                                        
                                    when bne =>
                                        if FLAGS(0)='0' then
                                            if (instruction(23)='1') then
                                                offset := ("11111111"&instruction(23 downto 0));
                                            else
                                                offset := ("00000000"&instruction(23 downto 0));
                                            end if;
                                        else
                                            --do nothing
                                        end if;
                                    when b =>
                                        if (instruction(23)='1') then
                                            offset := ("11111111"&instruction(23 downto 0));
                                        else
                                            offset := ("00000000"&instruction(23 downto 0));
                                        end if;
                                    when others =>
                                        --do nothing
                                end case;
                            when unknown =>
                                --do nothing
                        end case;
                        --PC_VAR := PC + offset + "00000000000000000000000000000100";
                    end if;              
                    -- Now using the filtered variables
                addr_to_prog_mem <= PC ;
                PC <= PC + offset + "00000000000000000000000000000100";
                end if;
        
        
        end process;

    end Behavioral;
                    --case(F_field) is
                    --    when "00" => 
                    --        instr_class <= DP;
                    --            case(opcode) is
                    --                when "0100" => --add
                    --                    i_decoded <= add;
                    --                when "0010" => --sub
                    --                    i_decoded <= sub;
                    --                when "1101" => --mov
                    --                    i_decoded <= mov;
                    --                when "1010" => --cmp
                    --                    i_decoded <= cmp;
                    --                when others => --others
                    --                    i_decoded <= unknown;
                    --            end case;
                    --    when "01" =>
                    --        instr_class <= DT;
                    --            case(L_bit) is
                    --                when '0' => --str
                    --                    i_decoded <= str;
                    --                when '1' => --ldr
                    --                    i_decoded <= ldr;
                    --                when others =>
                    --                    i_decoded <= unknown;
                    --            end case;
                    --    when "10" =>
                    --        instr_class <= branch;
                    --            case(cond) is
                    --            when "1110" => --b
                    --                i_decoded <= b;
                    --            when "0000" => --beq
                    --                i_decoded <= beq;
                    --            when "0001" => --bne
                    --                i_decoded <= bne;
                    --            when others =>
                    --                i_decoded <= unknown;
                    --        end case;
                    --    when others =>
                    --        instr_class <= unknown;
                    --        i_decoded <= unknown;
                    --end case;
