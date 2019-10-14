module CONTROL_UNIT #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12,
    parameter INSTRUCTION_WIDTH = 16
    ) (
        //input
        input clk, reset,
        input [(DATA_WIDTH-1):0] INSTR_IN, ARG_IN,
        input COMPARE_IN, OVERFLOW_IN,
        input [(ADDR_WIDTH-1):0] TOS_IN,
        //outputs
        output reg CTRL_REG_TOS_FUNCTION, SEL_SOMADOR_SUBTRATOR, CTRL_STACK_FUNCTION, CTRL_REG_DATA_RETURN,
        output reg SEL_PC_UPDATER, SEL_TOS_UPDATER,
        output reg CTRL_STACK, CTRL_MEM_EXT,
        output reg CTRL_REG_OP1, CTRL_REG_OP2,
        output reg CTRL_STACK_COMP,
        output reg [3:0] SEL_ULA,
        output reg CTRL_REG_READ_STACK, CTRL_REG_WRITE_STACK,
        output reg CTRL_REG_READ_MEMORY, CTRL_REG_WRITE_MEMORY,
        output reg CTRL_REG_ARG, CTRL_REG_INSTR, CTRL_REG_JUMP, CTRL_REG_PC,
        output reg SEL_MUX_TOS,
        output reg CTRL_REG_TOS,
        output reg [2:0] SEL_MUX_STACK,
        output reg [1:0] SEL_MUX_PC
    );

    // states
    parameter FIRST = 0, SECOND = 1, PT1 = 2, PT2 = 3;
    parameter RT1 = 4, RT2 = 5, RT3 = 6, RT4 = 7, RT5 = 8, RT6_LC3_LF5_U4_B6_CO6 = 9;
    parameter LC1 = 10, LC2 = 11, LF1 = 12, LF2 = 13, LF3 = 14, LF4 = 15;
    parameter SF1 = 16, SF2 = 17, SF3 = 18, U1_B1_CO1 = 19, U2 = 20, U3 = 21;
    parameter B2_CO2 = 22, B3_CO3 = 23, B4_CO4 = 24, B5 = 25, CO5 = 26;
    parameter JF1_JA1_CF1 = 27, JF2 = 28, JF3 = 29, JA2 = 30, JA3_CF5 = 31;
    parameter CF2 = 32, CF3 = 33, CF4 = 34, RV1 = 35, RV2 = 36, RV3 = 37, RV4 = 38, RV5 = 39;
    // states pop_jump and error
    parameter PJ_FICA1 = 40, PJ_FICA2 = 41, PJ_PULA1 = 42, PJ_PULA2 = 43, PJ_PULA3 = 44;
    parameter ERROR = 99;
    reg [31:0] STATE;

    always @ (posedge clk) begin
        if(reset == 1'b1)
            STATE <= FIRST;
        else
        begin
            case (STATE)
                FIRST: STATE <= SECOND;
                SECOND: begin
                    case (INSTR_IN)
                        8'b00000000: STATE <= FIRST;        //NOP
                        8'b00000001: STATE <= PT1;          // POP_TOP
                        8'b00000011: STATE <= RT1;          // ROT_TWO
                        8'b00001100: STATE <= LC1;          // LOAD_CONST
                        8'b00001101: STATE <= LF1;          // LOAD_FAST
                        8'b00001111: STATE <= SF1;          // STORE_FAST
                        8'b01111100: STATE <= U1_B1_CO1;    //UNARY_NOT
                        8'b00100000: STATE <= U1_B1_CO1;    //BINARY_ADD
                        8'b00100001: STATE <= U1_B1_CO1;    //BINARY_SUBTRACT
                        8'b00100010: STATE <= U1_B1_CO1;    //BINARY_MULTIPLY
                        8'b00101101: STATE <= U1_B1_CO1;    //BINARY_AND
                        8'b00101110: STATE <= U1_B1_CO1;    //BINARY_OR
                        8'b00101111: STATE <= U1_B1_CO1;    //BINARY_XOR
                        8'b01010000: STATE <= U1_B1_CO1;    //BINARY_LSHIFT
                        8'b01010001: STATE <= U1_B1_CO1;    //BINARY_RSHIFT
                        8'b11000000: STATE <= U1_B1_CO1;    //COMPARE_OP
                        8'b00110010: STATE <= JF1_JA1_CF1;  //JUMP_FORWARD
                        8'b00110011: STATE <= JF1_JA1_CF1;
                        8'b00110000: begin                  // POP_JUMP_IF_FALSE
                            if(COMPARE_IN == 1'b0)
                                STATE <= PJ_PULA1;
                            else
                                STATE <= PJ_FICA1;
                        end
                        8'b00110001: begin                  // POP_JUMP_IF_TRUE
                            if(COMPARE_IN == 1'b1)
                                STATE <= PJ_PULA1;
                            else
                                STATE <= PJ_FICA1;
                        end
                        8'b01100000: STATE <= JF1_JA1_CF1;
                        8'b01100001: STATE <= RV1;
                        default: STATE <= ERROR;
                    endcase
                end
                //POP_TOP
                PT1: STATE <= PT2;
                PT2: STATE <= SECOND;
                //ROT_TWO
                RT1: STATE <= RT2;
                RT2: STATE <= RT3;
                RT3: STATE <= RT4;
                RT4: STATE <= RT5;
                RT5: STATE <= RT6_LC3_LF5_U4_B6_CO6;
                // multiple states
                RT6_LC3_LF5_U4_B6_CO6: STATE <= SECOND;
                // ---------
                // LOAD_CONST
                LC1: STATE <= LC2;
                LC2: STATE <= RT6_LC3_LF5_U4_B6_CO6;
                // LOAD_FAST
                LF1: STATE <= LF2;
                LF2: STATE <= LF3;
                LF3: STATE <= LF4;
                LF4: STATE <= RT6_LC3_LF5_U4_B6_CO6;
                //STORE_FAST
                SF1: STATE <= SF2;
                SF2: STATE <= SF3;
                SF3: STATE <= RT6_LC3_LF5_U4_B6_CO6;
                //UNARY
                //multiple states
                U1_B1_CO1:  if(INSTR_IN == 1'b01111100)      // UNARY_NOT
                                STATE <= U2;
                            else
                                STATE <= B2_CO2;            // BINARY or COMPARE_OP
                //-------
                U2: STATE <= U3;
                U3: STATE <= RT6_LC3_LF5_U4_B6_CO6;
                //BINARY or COMPARE_OP
                B2_CO2: STATE <= B3_CO3;
                B3_CO3: STATE <= B4_CO4;
                B4_CO4: if(INSTR_IN == 1'b11000000)       // COMPARE_OP
                            STATE <= CO5;
                        else
                            STATE <= B5;
                B5: STATE <= RT6_LC3_LF5_U4_B6_CO6;
                CO5: STATE <= RT6_LC3_LF5_U4_B6_CO6;
                // JUMP_FORWARD or JUMP_ABSOLUTE or CALL_FUNCTION
                JF1_JA1_CF1:    if(INSTR_IN == 1'b00110010)    // JUMP_FORWARD
                                    STATE <= JF2;
                                else if(INSTR_IN == 1'b00110011) // JUMP_ABSOLUTE
                                    STATE <= JA2;
                                else
                                    STATE <= CF2;
                // JUMP_FORWARD
                JF2: STATE <= JF3;
                JF3: STATE <= FIRST;
                // JUMP_ABSOLUTE;
                JA2: STATE <= JA3_CF5;
                JA3_CF5: STATE <= FIRST;
                // POP_JUMP
                PJ_FICA1: STATE <= PJ_FICA2;
                PJ_FICA2: STATE <= FIRST;
                PJ_PULA1: STATE <= PJ_PULA2;
                PJ_PULA2: STATE <= PJ_PULA3;
                PJ_PULA3: STATE <= FIRST;
                // CALL_FUNCTION
                CF2: STATE <= CF3;
                CF3: STATE <= CF4;
                CF4: STATE <= JA3_CF5;
                // RETURN_VALUE
                RV1: STATE <= RV2;
                RV2: STATE <= RV3;
                RV3: STATE <= RV4;
                RV4: STATE <= RV5;
                RV5: STATE <= SECOND;
                // ERROR
                ERROR: STATE <= ERROR;
                default: STATE <= ERROR;
            endcase
        end
    end
    always @ (*) begin
        case (STATE)
            FIRST: begin
                CTRL_REG_ARG <= 1'b1;
                CTRL_REG_INSTR <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            SECOND: begin
                SEL_MUX_PC <= 2'b00;
                SEL_PC_UPDATER <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            // -----------------------------------------------------------------------
            // POP_TOP
            PT1: begin
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b1;
                CTRL_REG_PC <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            PT2: begin
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b1;
                CTRL_REG_INSTR <= 1'b1;
                CTRL_REG_ARG <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                SEL_MUX_STACK <= 3'b000;
            end
            // -----------------------------------------------------------------------
            RT1: begin
                CTRL_REG_READ_STACK <= 1'b1;
                SEL_MUX_STACK <= 3'b100;
                SEL_TOS_UPDATER <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_TOS <= 1'b0;
            end
            RT2: begin
                SEL_MUX_STACK <= 3'b100;
                CTRL_REG_WRITE_STACK <= 1'b1;
                CTRL_REG_TOS <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
            end
            RT3: begin
                CTRL_REG_READ_STACK <= 1'b1;
                SEL_MUX_STACK <= 3'b100;
                SEL_PC_UPDATER <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
            end
            RT4: begin
                CTRL_STACK <= 1'b1;
                SEL_MUX_STACK <= 3'b100;
                CTRL_REG_PC <= 1'b1;
                SEL_TOS_UPDATER <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
            end
            RT5: begin
                CTRL_REG_WRITE_STACK <= 1'b1;
                SEL_MUX_STACK <= 3'b100;
                CTRL_REG_TOS <= 1'b1;
                SEL_TOS_UPDATER <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_PC <= 2'b00;
            end
            RT6_LC3_LF5_U4_B6_CO6: begin
                CTRL_STACK <= 1'b1;
                CTRL_REG_INSTR <= 1'b1;
                CTRL_REG_ARG <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            // ------------------------------------------------------------------
            LC1: begin
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                SEL_MUX_STACK <= 3'b011;
                CTRL_REG_PC <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
            end
            LC2: begin
                SEL_TOS_UPDATER <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b1;
                CTRL_REG_WRITE_STACK <= 1'b1;
                SEL_MUX_STACK <= 3'b011;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_PC <= 2'b00;
            end
            // -------------------------------------------------------------------
            LF1: begin
                SEL_PC_UPDATER <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_PC <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            LF2: begin
                CTRL_REG_JUMP <= 1'b1;
                SEL_MUX_PC <= 2'b00;
                SEL_MUX_TOS <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            LF3: begin
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_PC <= 1'b1;
                CTRL_REG_TOS <= 1'b1;
                SEL_MUX_STACK <= 3'b001;
                CTRL_REG_READ_MEMORY <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
            end
            LF4: begin
                SEL_MUX_STACK <= 3'b001;
                CTRL_REG_WRITE_STACK <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_TOS <= 1'b0;
            end
            // ------------------------------------------------------------------
            SF1: begin
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b1;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_READ_STACK <= 1'b1;
                CTRL_REG_PC <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            SF2: begin
                CTRL_REG_JUMP <= 1'b1;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b1;
                CTRL_REG_TOS <= 1'b1;
                CTRL_REG_WRITE_MEMORY <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            SF3: begin
                SEL_MUX_PC <= 2'b00;
                SEL_PC_UPDATER <= 1'b0;
                CTRL_REG_PC <= 1'b1;
                CTRL_MEM_EXT <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            // ------------------------------------------------------------------
            U1_B1_CO1: begin
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b1;
                CTRL_REG_READ_STACK <= 1'b1;
                CTRL_REG_PC <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            U2: begin
                CTRL_REG_OP1 <= 1'b1;
                SEL_ULA <= 4'b1000;     // NOT
                SEL_MUX_STACK <= 3'b000;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_TOS <= 1'b0;
            end
            U3: begin
                SEL_ULA <= 4'b1000;     // NOT
                SEL_MUX_STACK <= 3'b000;
                CTRL_REG_WRITE_STACK <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_TOS <= 1'b0;
            end
            // ================================================
            B2_CO2: begin
                SEL_TOS_UPDATER <= 1'b1;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_OP1 <= 1'b1;
                CTRL_REG_TOS <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                SEL_MUX_STACK <= 3'b000;
            end
            B3_CO3: begin
                CTRL_REG_READ_STACK <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            B4_CO4: begin
                CTRL_REG_OP2 <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
                case (INSTR_IN)
                    8'b11000000: begin   // COMPARE_OP
                        case (ARG_IN)
                            8'b0001_1000: SEL_ULA <= 4'b1001;           // ==
                            8'b0001_1001: SEL_ULA <= 4'b1010;           // !=
                            8'b0001_1010: SEL_ULA <= 4'b1100;           // <
                            8'b0001_1011: SEL_ULA <= 4'b1011;           // >
                            8'b0001_1100: SEL_ULA <= 4'b1101;           // >=
                            8'b0001_1101: SEL_ULA <= 4'b1110;           // <=
                            default: SEL_ULA <= 4'b1001;                // ==
                        endcase
                    end
                    8'b0010_0000: SEL_ULA <= 4'b0000;                       // BINARY_ADD
                    8'b0010_0001: SEL_ULA <= 4'b0001;                       // BINARY_SUBTRACT
                    8'b0010_0010: SEL_ULA <= 4'b0010;                       // BINARY_MULTIPLY
                    8'b0010_1101: SEL_ULA <= 4'b0110;                       // BINARY_AND
                    8'b0010_1110: SEL_ULA <= 4'b0101;                       // BINARY_OR
                    8'b0010_1111: SEL_ULA <= 4'b0111;                       // BINARY_XOR
                    8'b0101_0000: SEL_ULA <= 4'b0011;                       // BINARY_LSHIFT
                    8'b0101_0001: SEL_ULA <= 4'b0100;                       // BINARY_RSHIFT
                    default: SEL_ULA <= 4'b0000;                            // BINARY_ADD
                endcase
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_TOS <= 1'b0;
            end
            B5: begin
                SEL_MUX_STACK <= 3'b000;
                CTRL_REG_WRITE_STACK <= 1'b1;
                case (INSTR_IN)
                    8'b0010_0000: SEL_ULA <= 4'b0000;                       // BINARY_ADD
                    8'b0010_0001: SEL_ULA <= 4'b0001;                       // BINARY_SUBTRACT
                    8'b0010_0010: SEL_ULA <= 4'b0010;                       // BINARY_MULTIPLY
                    8'b0010_1101: SEL_ULA <= 4'b0110;                       // BINARY_AND
                    8'b0010_1110: SEL_ULA <= 4'b0101;                       // BINARY_OR
                    8'b0010_1111: SEL_ULA <= 4'b0111;                       // BINARY_XOR
                    8'b0101_0000: SEL_ULA <= 4'b0011;                       // BINARY_LSHIFT
                    8'b0101_0001: SEL_ULA <= 4'b0100;                       // BINARY_RSHIFT
                    default: SEL_ULA <= 4'b0000;                            // BINARY_ADD
                endcase
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_TOS <= 1'b0;
            end
            CO5: begin
                SEL_MUX_STACK <= 3'b000;
                CTRL_STACK_COMP <= 1'b1;
                CTRL_REG_WRITE_STACK <= 1'b1;
                case (ARG_IN)
                    8'b0001_1000: SEL_ULA <= 4'b1001;           // ==
                    8'b0001_1001: SEL_ULA <= 4'b1010;           // !=
                    8'b0001_1010: SEL_ULA <= 4'b1100;           // <
                    8'b0001_1011: SEL_ULA <= 4'b1011;           // >
                    8'b0001_1100: SEL_ULA <= 4'b1101;           // >=
                    8'b0001_1101: SEL_ULA <= 4'b1110;           // <=
                    default: SEL_ULA <= 4'b1001;                // ==
                endcase
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_TOS <= 1'b0;
            end
            // -------------------------------------------------------------------
            JF1_JA1_CF1: begin
                SEL_PC_UPDATER <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_PC <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            JF2: begin
                CTRL_REG_JUMP <= 1'b1;
                SEL_MUX_PC <= 2'b10;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            JF3: begin
                CTRL_REG_PC <= 1'b1;
                SEL_MUX_PC <= 2'b10;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            // =================================================
            JA2: begin
                CTRL_REG_JUMP <= 1'b1;
                SEL_MUX_PC <= 2'b01;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            JA3_CF5: begin
                SEL_MUX_PC <= 2'b01;
                CTRL_REG_PC <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            // ======================================================
            CF2: begin
                CTRL_REG_JUMP <= 1'b1;
                SEL_PC_UPDATER <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_TOS_FUNCTION <= 1'b1;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                // ---------------------------------
                CTRL_REG_PC <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            CF3: begin
                SEL_PC_UPDATER <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_PC <= 1'b1;
                // ---------------------------------
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            CF4: begin
                CTRL_STACK_FUNCTION <= 1'b1;
                SEL_MUX_PC <= 2'b01;
                // ---------------------------------
                CTRL_REG_PC <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            // ------------------------------------------------------------------
            RV1: begin
                CTRL_REG_DATA_RETURN <= 1'b1;
                SEL_MUX_PC <= 2'b11;
                SEL_MUX_TOS <= 1'b1;
                // ---------------------------------
                CTRL_REG_PC <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            RV2: begin
                SEL_MUX_PC <= 2'b11;
                SEL_MUX_TOS <= 1'b1;
                SEL_MUX_STACK <= 3'b010;
                CTRL_REG_PC <= 1'b1;
                CTRL_REG_TOS <= 1'b1;
                SEL_TOS_UPDATER <= 1'b0;
                // ---------------------------------
                SEL_PC_UPDATER <= 1'b0;
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
            end
            RV3: begin
                SEL_MUX_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b010;
                CTRL_REG_WRITE_STACK <= 1'b1;
                SEL_SOMADOR_SUBTRATOR <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS <= 1'b0;
                CTRL_REG_PC <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
            end
            RV4: begin
                CTRL_REG_ARG <= 1'b1;
                CTRL_REG_INSTR <= 1'b1;
                CTRL_REG_TOS <= 1'b1;
                SEL_TOS_UPDATER <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b1;
                CTRL_REG_TOS_FUNCTION <= 1'b1;
                // ---------------------------------
                CTRL_REG_PC <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            RV5: begin
                CTRL_STACK <= 1'b1;
                // ---------------------------------
                CTRL_REG_PC <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            // -------------------------------------------------------------------
            PJ_FICA1: begin
                SEL_MUX_PC <= 2'b00;
                SEL_PC_UPDATER <= 1'b1;
                // ---------------------------------
                CTRL_REG_PC <= 1'b0;
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            PJ_FICA2: begin
                SEL_PC_UPDATER <= 1'b1;
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_PC <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            PJ_PULA1: begin
                SEL_MUX_PC <= 2'b00;
                SEL_PC_UPDATER <= 1'b0;
                CTRL_REG_PC <= 1'b1;
                // ---------------------------------
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            PJ_PULA2: begin
                CTRL_REG_JUMP <= 1'b1;
                SEL_MUX_PC <= 2'b01;
                // ---------------------------------
                CTRL_REG_PC <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            PJ_PULA3: begin
                SEL_MUX_PC <= 2'b01;
                CTRL_REG_PC <= 1'b1;
                // ---------------------------------
                SEL_PC_UPDATER <= 1'b0;
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
            default: begin
                // ---------------------------------
                SEL_MUX_PC <= 2'b00;
                CTRL_REG_PC <= 1'b0;
                SEL_PC_UPDATER <= 1'b0;
                CTRL_REG_TOS_FUNCTION <= 1'b0;
                SEL_SOMADOR_SUBTRATOR <= 1'b0;
                CTRL_REG_JUMP <= 1'b0;
                CTRL_STACK_FUNCTION <= 1'b0;
                CTRL_REG_DATA_RETURN <= 1'b0;
                SEL_TOS_UPDATER <= 1'b0;
                CTRL_STACK <= 1'b0;
                CTRL_MEM_EXT <= 1'b0;
                CTRL_REG_OP1 <= 1'b0;
                CTRL_REG_OP2 <= 1'b0;
                CTRL_STACK_COMP <= 1'b0;
                SEL_ULA <= 4'b0000;
                CTRL_REG_READ_STACK <= 1'b0;
                CTRL_REG_WRITE_STACK <= 1'b0;
                CTRL_REG_READ_MEMORY <= 1'b0;
                CTRL_REG_WRITE_MEMORY <= 1'b0;
                CTRL_REG_ARG <= 1'b0;
                CTRL_REG_INSTR <= 1'b0;
                SEL_MUX_TOS <= 1'b0;
                CTRL_REG_TOS <= 1'b0;
                SEL_MUX_STACK <= 3'b000;
            end
        endcase
    end

endmodule
