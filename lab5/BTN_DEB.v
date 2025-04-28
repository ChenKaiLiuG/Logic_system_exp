module BTN_DEB (
    input clk, rst,
    input btn,
    output btn_deb
);
    reg [1:0] counter;
    reg [1:0] cs, ns;
    localparam stable0 = 2'd0;
    localparam unstable = 2'd1;
    localparam stable1 = 2'd2;

    always @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 2'd0;
        else if (counter == 2'd2)
            counter <= 2'd0;
        else if (cs != ns)
            counter <= counter + 2'd0;
        else
            counter <= counter + 2'd1;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            cs <= stable0;
        else
            cs <= ns;
    end

    always @(*) begin
        case (cs)
            stable0:
                ns = (btn == 1) ? unstable : stable0;
            unstable: begin
                if (btn == 1 && counter == 2'd2)
                    ns = stable1;
                else if (btn == 0 && counter == 2'd2)
                    ns = stable0;
                else
                    ns = unstable;
            end
            stable1:
                ns = (btn == 0) ? unstable : stable1;
            default:
                ns = stable0;
        endcase
    end

    assign btn_deb = (cs == stable1);

endmodule
