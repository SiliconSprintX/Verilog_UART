module uart (
    input        clk,
    input        rst,

    // TX signals
    input        tx_start,
    input [7:0]  tx_data,
    output reg   tx,
    output reg   tx_busy,

    // RX signals
    input        rx,
    output reg [7:0] rx_data,
    output reg       rx_done
);

    parameter CLKS_PER_BIT = 10;

    // -------------------------
    // TX registers
    // -------------------------
    reg [3:0] tx_bit_count;
    reg [7:0] tx_clk_count;
    reg [9:0] tx_shift_reg;

    // -------------------------
    // RX registers
    // -------------------------
    reg [3:0] rx_bit_count;
    reg [7:0] rx_clk_count;
    reg [7:0] rx_shift_reg;
    reg       rx_busy;


    // =================================================
    // TRANSMITTER
    // =================================================

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            tx           <= 1'b1;
            tx_busy      <= 1'b0;
            tx_bit_count <= 0;
            tx_clk_count <= 0;
            tx_shift_reg <= 0;

        end

        else begin

            // Start transmission
            if (tx_start && !tx_busy) begin

                // Frame:
                // Stop + Data + Start
                tx_shift_reg <= {1'b1, tx_data, 1'b0};

                tx_busy      <= 1'b1;
                tx_bit_count <= 0;
                tx_clk_count <= 0;

                // Start bit
                tx <= 1'b0;

            end

            else if (tx_busy) begin

                if (tx_clk_count == CLKS_PER_BIT - 1) begin

                    tx_clk_count <= 0;

                    tx_bit_count <= tx_bit_count + 1;

                    // Shift register
                    tx_shift_reg <= {1'b1, tx_shift_reg[9:1]};

                    // Output next bit
                    tx <= tx_shift_reg[1];

                    // Transmission complete
                    if (tx_bit_count == 9) begin

                        tx_busy <= 1'b0;
                        tx      <= 1'b1;

                    end

                end

                else begin

                    tx_clk_count <= tx_clk_count + 1;

                end

            end

        end

    end


    // =================================================
    // RECEIVER
    // =================================================

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            rx_bit_count <= 0;
            rx_clk_count <= 0;
            rx_shift_reg <= 0;

            rx_data <= 0;
            rx_done <= 0;
            rx_busy <= 0;

        end

        else begin

            rx_done <= 1'b0;

            // Detect start bit
            if (!rx && !rx_busy) begin

                rx_busy      <= 1'b1;
                rx_clk_count <= CLKS_PER_BIT / 2;
                rx_bit_count <= 0;

            end

            else if (rx_busy) begin

                if (rx_clk_count == CLKS_PER_BIT - 1) begin

                    rx_clk_count <= 0;

                    // Receive 8 data bits
                    if (rx_bit_count < 8) begin

                        rx_shift_reg[rx_bit_count] <= rx;

                        rx_bit_count <= rx_bit_count + 1;

                    end

                    // Stop bit
                    else begin

                        rx_busy <= 1'b0;

                        rx_data <= rx_shift_reg;

                        rx_done <= 1'b1;

                    end

                end

                else begin

                    rx_clk_count <= rx_clk_count + 1;

                end

            end

        end

    end

endmodule
