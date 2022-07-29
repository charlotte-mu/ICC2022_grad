/******************************************************************/
//MODULE:		JAM
//FILE NAME:	JAM.v
//VERSION:		1.0
//DATE:			March,2022
//AUTHOR: 		charlotte-mu
//CODE TYPE:	RTL
//DESCRIPTION:	2022 Cell-Based IC Design Category for Graduate Level
//
//MODIFICATION HISTORY:
// VERSION Date Description
// 1.0 03/30/2022 Cell-Based IC Design Category for Graduate Level ,test pattern all pass
/******************************************************************/
module JAM (
input CLK,
input RST,
output [2:0] W,
output [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output [9:0] MinCost,
output Valid );

reg [2:0]dataN[7:0];
reg [2:0]dataN_reg[7:0];
reg [2:0]countA,countA_next;
reg [3:0]countC,countC_next;
reg [2:0]fsm1,fsm1_next;
reg [2:0]fsm2,fsm2_next;
reg [9:0]sum;
reg mod,mod_next;
reg [10:0]MinCost1,MinCost1_next;
reg [3:0]MatchCount_next;
reg [2:0]dataA,dataA_next;
reg [2:0]dataB,dataB_next;
reg ch;
reg [2:0]dataC;

wire [9:0]sum_add_cost;

assign W = countC[2:0];
assign J = dataN_reg[0];
assign Valid  = (fsm2 == 3'd2)? 1'b1:1'b0;
assign MinCost = MinCost1[9:0];
assign sum_add_cost = sum + Cost;

always @(posedge CLK,posedge RST) 
begin
    if(RST)
    begin
        dataN[0] <= 3'd0;
        dataN[1] <= 3'd1;
        dataN[2] <= 3'd2;
        dataN[3] <= 3'd3;
        dataN[4] <= 3'd4;
        dataN[5] <= 3'd5;
        dataN[6] <= 3'd6;
        dataN[7] <= 3'd7;
        dataN_reg[0] <= 3'd0;
        dataN_reg[1] <= 3'd1;
        dataN_reg[2] <= 3'd2;
        dataN_reg[3] <= 3'd3;
        dataN_reg[4] <= 3'd4;
        dataN_reg[5] <= 3'd5;
        dataN_reg[6] <= 3'd6;
        dataN_reg[7] <= 3'd7;

        countA <= 3'd7;

        countC <= 4'd0;
        fsm1 <= 3'd0;
        fsm2 <= 3'd7;
        mod <= 1'b0;
        MinCost1 <= 11'h400;
        MatchCount <= 4'd1;

        dataA <= 3'd7;
        dataB <= 3'd0;
        sum <= 10'd0;
    end
    else 
    begin
        if(fsm2 == 3'b0 && countC <= 4'd8 &&  countC != 4'd0)
            sum <= sum_add_cost;
        if(fsm2 == 3'b1)
            sum <= 10'd0;
              
        if(ch == 1'b1)
        begin
            dataN[dataC] <= dataN[dataB];
            dataN[dataB] <= dataN[dataC];
        end
        if(fsm1 == 3'd1)
        begin
            case(dataA)
                3'd0:
                begin
                    dataN[1] <= dataN[7];
                    dataN[7] <= dataN[1];
                    dataN[2] <= dataN[6];
                    dataN[6] <= dataN[2];
                    dataN[3] <= dataN[5];
                    dataN[5] <= dataN[3];
                end
                3'd1:
                begin
                    dataN[2] <= dataN[7];
                    dataN[7] <= dataN[2];
                    dataN[3] <= dataN[6];
                    dataN[6] <= dataN[3];
                    dataN[4] <= dataN[5];
                    dataN[5] <= dataN[4];
                end
                3'd2:
                begin
                    dataN[3] <= dataN[7];
                    dataN[7] <= dataN[3];
                    dataN[4] <= dataN[6];
                    dataN[6] <= dataN[4];
                end
                3'd3:
                begin
                    dataN[4] <= dataN[7];
                    dataN[7] <= dataN[4];
                    dataN[5] <= dataN[6];
                    dataN[6] <= dataN[5];
                end
                3'd4:
                begin
                    dataN[5] <= dataN[7];
                    dataN[7] <= dataN[5];
                end
                3'd5:
                begin
                    dataN[6] <= dataN[7];
                    dataN[7] <= dataN[6];
                end
            endcase
            
        end 
        if(mod == 1'b1)
        begin
            dataN_reg[0] <= dataN[0];
            dataN_reg[1] <= dataN[1];
            dataN_reg[2] <= dataN[2];
            dataN_reg[3] <= dataN[3];
            dataN_reg[4] <= dataN[4];
            dataN_reg[5] <= dataN[5];
            dataN_reg[6] <= dataN[6];
            dataN_reg[7] <= dataN[7];
        end
        else if(fsm2 == 3'd0 && countC != 4'd8)
        begin
            dataN_reg[0] <= dataN_reg[1];
            dataN_reg[1] <= dataN_reg[2];
            dataN_reg[2] <= dataN_reg[3];
            dataN_reg[3] <= dataN_reg[4];
            dataN_reg[4] <= dataN_reg[5];
            dataN_reg[5] <= dataN_reg[6];
            dataN_reg[6] <= dataN_reg[7];
            dataN_reg[7] <= dataN_reg[0];
        end
        if(mod == 1'b1)
            mod <= 1'b0;
        else
            mod <= mod_next;
        countA <= countA_next;
        countC <= countC_next;
        fsm1 <= fsm1_next;
        fsm2 <= fsm2_next;
        MinCost1 <= MinCost1_next;
        MatchCount <= MatchCount_next;

        dataA <= dataA_next;
        dataB <= dataB_next;

    end
end


always@(*)
begin
    case(fsm2)
        3'd7:
        begin
            fsm2_next = 3'd0;
            countC_next = 4'd0; 
            MinCost1_next = MinCost1;
            MatchCount_next = MatchCount;
        end
        3'd0:
        begin
            if(countC == 4'd8)
            begin
                fsm2_next = 3'd1;
                countC_next = 4'd0;
                if(MinCost1 > sum_add_cost)
                begin
                    MinCost1_next = sum_add_cost;
                    MatchCount_next = 4'd1;
                end
                else if(MinCost1 == sum_add_cost)
                begin
                    MatchCount_next = MatchCount + 4'd1;
                    MinCost1_next = MinCost1;
                end 
                else
                begin
                    MinCost1_next = MinCost1;
                    MatchCount_next = MatchCount;
                end
            end
            else
            begin
                if(MinCost1 != 11'h400 && MinCost1 < sum_add_cost)
                    fsm2_next = 3'd1;
                else
                    fsm2_next = fsm2;
                countC_next = countC + 4'd1; 
                MinCost1_next = MinCost1;
                MatchCount_next = MatchCount;
            end
        end
        3'd1:
        begin
            if(
                dataN[0] == 3'd7 &&
                dataN[1] == 3'd6 &&
                dataN[2] == 3'd5 &&
                dataN[3] == 3'd4 &&
                dataN[4] == 3'd3 &&
                dataN[5] == 3'd2 &&
                dataN[6] == 3'd1 &&
                dataN[7] == 3'd0
            )
            begin
                fsm2_next = 3'd2;
                countC_next =  4'd0;
                MinCost1_next = MinCost1;
                MatchCount_next = MatchCount;
            end
            else
            begin
                if(mod)
                begin
                    fsm2_next = 3'd0;
                    countC_next = 4'd0; 
                    MinCost1_next = MinCost1;
                    MatchCount_next = MatchCount;
                end
                else
                begin
                    fsm2_next = fsm2;
                    countC_next = countC; 
                    MinCost1_next = MinCost1;
                    MatchCount_next = MatchCount;
                end
            end
        end
        default:
        begin
            fsm2_next = fsm2;
            countC_next = countC; 
            MinCost1_next = MinCost1;
            MatchCount_next = MatchCount;
        end
    endcase
end

always@(*)
begin
    if(dataN[6] < dataN[7])
    begin
        dataC = 3'd6;
    end
    else if(dataN[5] < dataN[6])
    begin
        dataC = 3'd5;
    end
    else if(dataN[4] < dataN[5])
    begin
        dataC = 3'd4;
    end
    else if(dataN[3] < dataN[4])
    begin
        dataC = 3'd3;
    end
    else if(dataN[2] < dataN[3])
    begin
        dataC = 3'd2;
    end
    else if(dataN[1] < dataN[2])
    begin
        dataC = 3'd1;
    end
    else
    begin
        dataC = 3'd0;
    end
end

always@(*)
begin
    case(fsm1)
        3'd0:
        begin
            mod_next = mod;
            if(countA == dataC)
            begin
                countA_next = countA;
                dataA_next = dataC;
                dataB_next = dataB;
                fsm1_next = 3'd1;
                ch = 1'b1;
            end
            else
            begin
                countA_next = countA - 3'd1;
                fsm1_next = fsm1;
                ch = 1'b0;

                if(dataN[dataC] < dataN[countA] && dataN[countA] <= dataA)
                begin
                    dataA_next = dataN[countA];
                    dataB_next = countA;
                end
                else
                begin
                    dataA_next = dataA;
                    dataB_next = dataB;
                end
            end
        end
        3'd1:
        begin
            countA_next = countA;
            dataA_next = dataA;
            dataB_next = dataB;
            fsm1_next = 3'd2;
            mod_next = mod;
            ch = 1'b0;
        end
        3'd2:
        begin
            ch = 1'b0;
            if(fsm2 != 3'd0)
            begin
                fsm1_next = 3'd0;
                countA_next = 3'd7;
                dataA_next = 3'd7;
                dataB_next = 3'd0;
                mod_next = 1'b1;
            end
            else
            begin
                fsm1_next = fsm1;
                countA_next = countA;
                dataA_next = dataA;
                dataB_next = dataB;
                mod_next = mod;
            end
        end 
        default:
        begin
            countA_next = countA;
            dataA_next = dataA;
            dataB_next = dataB;
            fsm1_next = fsm1;
            mod_next = mod;
            ch = 1'b0;
        end 
    endcase
end

endmodule


