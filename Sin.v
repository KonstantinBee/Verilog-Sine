module Sin ((*chip_pin="V11"*) input clock, (*chip_pin="AH17"*) input KEY0, (*chip_pin="AH16"*) input KEY1, (*chip_pin="Y24"*) input direction, output [31:0] Sin, 
(*chip_pin="W15"*) output LED_reset, (*chip_pin="AA24"*) output LED_expense);
wire expense;
wire reset;
wire half;
wire [18:0] Limit_quarter;
wire [18:0] Limit_half;
wire [18:0] Limit_period;
wire [18:0] counter_sin_quarter;
wire [31:0] Step;
wire [31:0] Q;
Button Button_R ( .X(KEY0), .C(clock), .TTrigQ(reset));
Button Button_E ( .X(KEY1), .C(clock), .TTrigQ(expense));
Frequency_setup Frequency_setup 
( .expense (expense), .reset (reset), .direction (direction), .Limit_quarter (Limit_quarter), .Limit_half (Limit_half), .Limit_period (Limit_period));
Sin_counter Sin_counter 
( .reset (reset), .clock (clock), .Limit_period (Limit_period), .Limit_half (Limit_half), .Limit_quarter (Limit_quarter), 
.counter_sin_quarter (counter_sin_quarter), .half (half), .Q(Q));
Pi_divider Pi_divider ( .Q(Q), .Step (Step)); 
Taylor_series_for_sin Taylor_series_for_sin ( .Step (Step), .counter_sin_quarter (counter_sin_quarter), .half (half), .Result (Sin));
assign LED_reset = reset;
assign LED_expense = expense;
endmodule

//Change frequency
module Frequency_setup  (input expense, reset, direction, output [18:0] Limit_quarter, output [18:0] Limit_half, output [18:0] Limit_period);   
wire [18:0] Limit_min = 19'd8;
wire [18:0] A = 19'd500000;
reg [18:0] P;
always @(posedge expense or posedge reset) begin
    if (reset) P <= Limit_min;
        else if ( P == Limit_min && direction == 0) P <= Limit_min;
           else if ( P == A && direction == 1) P <= Limit_min;
                 else P <= P + (direction ? 4:(-4));     
end
assign Limit_period = P-1;
assign Limit_half = (P/2)-1;
assign Limit_quarter = (P/4)-1; 
endmodule

module Sin_counter (input reset, clock, input [18:0] Limit_period, input [18:0] Limit_half, input [18:0] Limit_quarter, 
output reg [18:0] counter_sin_quarter, output reg [18:0] Q, output reg half); 
reg quarter;
reg [18:0] counter_part;
reg [18:0] H;
reg [18:0] P;
initial half = 1;
initial quarter = 1;
always @ (posedge clock or posedge reset) begin

    if (reset) begin counter_part <= 0; P <= Limit_period; H <= Limit_half; Q <= Limit_quarter; end
            else if (counter_part == P) begin counter_part <= 0; P <= Limit_period; H <= Limit_half; Q <= Limit_quarter; end
                else counter_part <= counter_part + 1;
end
wire [18:0] T;
assign T = Q + H +1;
always @(posedge clock) begin
    if(reset) begin half = 0; quarter = 1; end
    if (counter_part == H || counter_part == P) half <= ! half;
    if (counter_part == Q || counter_part == H || counter_part == T || counter_part == P) quarter <= !quarter;  
end
always @(posedge clock or posedge reset) begin
    if (reset) counter_sin_quarter <= 0;
    else counter_sin_quarter <= counter_sin_quarter + (quarter ? 1:(-1));  
end
endmodule

module multiplier (input [31:0] A, B, output [31:0] C);
wire [63:0] Result;
reg [6:0] Whole_part;
reg [24:0] Fractional_part;
reg [24:0] Rounded_part;
reg Rounding_operator;
integer i;
assign Result = A*B;
always @(*) begin
for (i = 0; i<=6 ; i=i+1)
Whole_part[i] <= Result[50+i];   
end
always @(*) begin
for (i = 0; i<=24 ; i=i+1)
Fractional_part[i] <= Result[25+i];   
end
always @(*) begin
for (i = 0; i<=24 ; i=i+1)
Rounded_part[i] <= Result[i];   
end
always @(*) begin
if (Rounded_part >= 25'b1000000011011000000000000) Rounding_operator <= 1'd1; else Rounding_operator <= 0;  
end
assign C = {Whole_part, Fractional_part} + Rounding_operator;
endmodule

module Pi_divider (input [18:0] Q, output [31:0] Step);
wire [63:0] Const = 64'd1570796327;
wire [63:0] B;
wire [63:0] D;
wire [63:0] L;
wire [63:0] V = 64'b0_000000000000000000000000000001000100101110000010110000000000000;
reg [63:0] M;
wire [127:0] Result;
reg [6:0] Whole_part;
reg [24:0] Fractional_part;
reg [37:0] Rounded_part;
reg Rounding_operator;
integer i;
wire [18:0] Qa = Q + 1;
assign B = Const/Qa;
assign D = 10*(Const%Qa);
assign L = 5*Qa;
always @(*) begin
    if (Qa == 1) M <= Const;
        else if (D >= L) M <= B + 1;
            else  M <= B;
end
assign Result = V*M;
always @(*) begin
for (i = 0; i<=6 ; i=i+1)
Whole_part[i] <= Result[63+i];   
end
always @(*) begin
for (i = 0; i<=24; i=i+1)
Fractional_part[i] <= Result[38+i];   
end
always @(*) begin
for (i = 0; i<=37 ; i=i+1)
Rounded_part[i] <= Result[i];   
end
always @(*) begin
if (Rounded_part >= 38'b10000000110110000000000000000000000000) Rounding_operator <= 1'd1; else Rounding_operator <= 0;  
end
assign Step = {Whole_part, Fractional_part} + Rounding_operator;
endmodule

module Taylor_series_for_sin (input [31:0] Step, input [18:0] counter_sin_quarter, input half, output [31:0] Result);
// 1/3! (25 characters after the dot)
wire [31:0] CA = 32'b00000000010101010101010101010101;
// 1/5! (25 characters after the dot)
wire [31:0] CB = 32'b00000000000001000100010001000100;
// 1/7! (25 characters after the dot)
wire [31:0] CC = 32'b00000000000000000001101000000001;
wire [50:0] Q;
reg [31:0] R;
integer i;
integer k;
assign Q = Step*counter_sin_quarter;
always @(*) begin
for (i = 0; i<=31; i=i+1)
R[i] <= Q[i];   
end
wire [31:0]AM1;
wire [31:0]AM2;
wire [31:0]AM3;
wire [31:0]AM4;
wire [31:0]AM5;
wire [31:0]AM6;
wire [31:0]AM7;
assign AM1 = R;
multiplier multiplier_AM2 ( .A(AM1), .B(AM1), .C(AM2));
multiplier multiplier_AM3 ( .A(AM1), .B(AM2), .C(AM3));
multiplier multiplier_AM4 ( .A(AM1), .B(AM3), .C(AM4));
multiplier multiplier_AM5 ( .A(AM1), .B(AM4), .C(AM5));
multiplier multiplier_AM6 ( .A(AM1), .B(AM5), .C(AM6));
multiplier multiplier_AM7 ( .A(AM1), .B(AM6), .C(AM7));
wire [31:0]A;
wire [31:0]B;
wire [31:0]C;
multiplier multiplier_A ( .A(AM3), .B(CA), .C(A));
multiplier multiplier_B ( .A(AM5), .B(CB), .C(B));
multiplier multiplier_C ( .A(AM7), .B(CC), .C(C));
wire [31:0]S;
wire [31:0] Sign = 32'd0;
assign S = (AM1-A)+(B-C);
reg [30:0]SA;
always @(*) begin

    for (k = 0; k<=30; k=k+1)
    SA[k] <= S[k];   
end
assign Result = {half, SA};
endmodule

module Button (input X, input C, output reg TTrigQ);
initial TTrigQ <= 1'd1;
reg XQ, BQ;
wire FY = !XQ & BQ;
always @(posedge C) begin
    XQ <= !X;
    BQ <= XQ;
    if (FY) TTrigQ <= !TTrigQ;  
end
endmodule
