    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;

    entity CPU is
        Port ( clock : in STD_LOGIC;
               reset : in STD_LOGIC;
               instruction : in std_logic_vector(31 downto 0);
               data_from_data_mem: in std_logic_vector(31 downto 0);
               step_button : in std_logic;
               go_button : in std_logic;
               address_to_pc: in std_logic_vector(11 downto 0);
               addr_to_prog_mem : out std_logic_vector(31 downto 0);
               addr_to_data_mem : out std_logic_vector(31 downto 0);
               data_to_data_mem : out std_logic_vector(31 downto 0);
               wr_enable_to_dm : out STD_LOGIC
               );
    end CPU;

    architecture Behavioral of CPU is

    type instr_class_type is (DP, DT, branch, unknown, HALT);
    type i_decoded_type is (add,sub,cmp,mov,ldr,str,beq,bne,b,unknown);

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
    signal state : integer := 0; -- 0=initial state, 1=onestep, 2=cont, 3=done

    begin
        
        cond <= instruction(31 downto 28);
        F_field <= instruction(27 downto 26);
        shift_spec <= instruction (11 downto 4);
        opcode <= instruction (24 downto 21);
        L_bit <= instruction(20);
        I_bit <= instruction(25);
        U_bit <= instruction(23);
        Rn <= instruction(19 downto 16);
        Rd <= instruction(15 downto 12);
        Rm <= instruction(3 downto 0);
        register_index1 <= to_integer(unsigned(Rn));
        register_index2 <= to_integer(unsigned(Rd));
        register_index3 <= to_integer(unsigned(Rm));
        

        instr_class <=  HALT when instruction="00000000000000000000000000000000" else
                        DP when F_field="00" else
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
        Rd_val <=   (registers(register_index1) + ((not registers(register_index3)) + "00000000000000000000000000000001")) when i_decoded=cmp and I_bit='0' else
                    (registers(register_index1) + ((not ("000000000000000000000000"&instruction(7 downto 0))) + "00000000000000000000000000000001")) when i_decoded=cmp and I_bit='1' else
                    (others => '1')
                    ;

        addr_to_prog_mem <= "00"&PC(31 downto 2);  -- dividing pc by 4 because memory is word addressable
        addr_to_data_mem <= (registers(register_index1) + ("00000000000000000000"&instruction(11 downto 0))) when i_decoded=ldr and U_bit='1' else
                            (registers(register_index1) + ((not ("00000000000000000000"&instruction(11 downto 0))) + "00000000000000000000000000000001")) when i_decoded=ldr and U_bit='0' else
                            (registers(register_index1) + ("00000000000000000000"&instruction(11 downto 0))) when i_decoded=str and U_bit='1' else
                            (registers(register_index1) + ((not ("00000000000000000000"&instruction(11 downto 0))) + "00000000000000000000000000000001")) when i_decoded=str and U_bit='0' else
                            (others => '0')
                             ;
        data_to_data_mem <= registers(register_index2) when i_decoded=str else (others => '0');
        wr_enable_to_dm <= '1' when i_decoded=str else '0';

        process(clock,reset) -- state changing process
            begin
                if rising_edge(clock) then
                    if (state=0 and (reset='1' or (step_button='0' and go_button='0'))) then
                        state <= 0;
                    elsif (state=0 and step_button='1') then
                        state <= 1;
                    elsif (state=0 and go_button='1') then
                        state <= 2;
                    elsif (state=2 and instr_class /= HALT) then
                        state <= 2;
                    elsif (state=2 and instr_class = HALT) then
                        state <= 3;
                    elsif (state=3 and (step_button='1' or go_button='1')) then
                        state <= 3;
                    elsif (state=3 and step_button='0' and go_button='0') then
                        state <= 0;
                    elsif (state=1) then
                        state <= 3;
                    end if;
                end if;
        end process;

        

        process(clock, reset)
            variable offset : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
            begin
                if rising_edge(clock) then

                    if(state=0) then
                        if (reset='1') then
                            PC <= "00000000000000000000"&address_to_pc; -- address_to_pc came from switches
                        else
                            -- initial state, do nothing
                        end if;
                    elsif (state=1 or state=2) then
                        -- main process
                        case(instr_class) is
                            when HALT =>
                                if (state=1) then
                                -- do nothing ,only pc change
                                PC <= PC + "00000000000000000000000000000100";
                                else
                                    --do nothing
                                end if;
                            when DP =>
                                case(i_decoded) is
                                    when add =>
                                        if I_bit='1' then
                                            registers(register_index2) <= registers(register_index1) + ("000000000000000000000000"&instruction(7 downto 0));
                                        else
                                            registers(register_index2) <= registers(register_index1) + registers(register_index3);
                                        end if;

                                    when sub =>
                                        if I_bit='1' then
                                            registers(register_index2) <= registers(register_index1) + ((not ("000000000000000000000000"&instruction(7 downto 0))) + "00000000000000000000000000000001");
                                        else
                                            registers(register_index2) <= registers(register_index1) + ((not registers(register_index3)) + "00000000000000000000000000000001");
                                        end if;

                                    when cmp =>
                                        if I_bit='1' then
                                            --cmp immediate, Rd_val = Rn_val - offset, offset is written at top
                                            if (Rd_val="00000000000000000000000000000000") then
                                                --equal
                                                FLAGS(0)<='1';
                                            else
                                                FLAGS(0)<='0';
                                            end if;

                                        else
                                            --normal cmp,, Rd_val = Rn_val - Rm, Rm is written at top
                                            if (Rd_val="00000000000000000000000000000000") then
                                                --equal
                                                FLAGS(0)<='1';
                                            else
                                                FLAGS(0)<='0';
                                            end if;
                                            
                                        end if;

                                    when mov =>
                                        if I_bit='1' then    --mov me ignoring Rn
                                            registers(register_index2) <= ("000000000000000000000000"&instruction(7 downto 0));
                                        else
                                            registers(register_index2) <= registers(register_index3);
                                        end if;

                                    when others =>
                                        --do nothing
                                end case;
                                PC <= PC + "00000000000000000000000000000100";
                            
                            when DT =>
                                case(i_decoded) is
                                    when ldr =>
                                        --address calculation in done in combinatorial, which is used by data mem
                                        if U_bit='1' then
                                            registers(register_index2) <= data_from_data_mem;

                                        else
                                            registers(register_index2) <= data_from_data_mem;
                                            
                                        end if;
                                    when str =>
                                        if U_bit='1' then
                                            --do nothing, combinatorial circuit is enough
                                        else
                                            --do nothing, combinatorial circuit is enough
                                        end if;
                                    when others =>
                                        --do nothing
                                end case;
                                PC <= PC + "00000000000000000000000000000100";
                            
                            when branch =>
                                case(i_decoded) is
                                    when beq =>
                                        
                                        if FLAGS(0)='1' then
                                            if (instruction(23)='1') then
                                                offset := ("11111111"&(instruction(21 downto 0)&"00"));
                                            else
                                                offset := ("00000000"&(instruction(21 downto 0)&"00"));
                                            end if;
                                            PC <= PC + offset + "00000000000000000000000000001000"; -- pc = pc+offset+8
                                        else
                                            PC <= PC + "00000000000000000000000000000100";
                                        end if;
                                        
                                    when bne =>
                                        
                                        if FLAGS(0)='0' then
                                            if (instruction(23)='1') then
                                                offset := ("11111111"&(instruction(21 downto 0)&"00"));
                                            else
                                                offset := ("00000000"&(instruction(21 downto 0)&"00"));
                                            end if;
                                            PC <= PC + offset + "00000000000000000000000000001000"; -- pc = pc+offset+8
                                        else
                                            PC <= PC + "00000000000000000000000000000100";
                                        end if;
                                    when b =>
                                        
                                        if (instruction(23)='1') then
                                            offset := ("11111111"&(instruction(21 downto 0)&"00")); -- offset = 4*value
                                        else
                                            offset := ("00000000"&(instruction(21 downto 0)&"00"));
                                        end if;
                                        PC <= PC + offset + "00000000000000000000000000001000"; -- pc = pc+offset+8
                                    when others =>
                                        PC <= PC + "00000000000000000000000000000100";
                                        --do nothing
                                end case;
                            when unknown =>
                                PC <= PC + "00000000000000000000000000000100";
                                --do nothing
                        end case;
                    end if;              
                end if;
      
        end process;

    end Behavioral;
