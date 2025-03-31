`timescale 1ns / 1ps

module mod (
    input logic clk,
    input logic reset,
    input logic [15:0] samp,
    output logic pull,
    output logic pdata
);
    // Represents 1.4CCCCC recurring which is approximating 1.3
    localparam logic signed [39:0] THRESHOLD = 28'h14CCCCC;
    
    typedef enum logic {
        RESET = 1'b0,
        SET = 1'b1
    } set_rest;
    set_rest state, next_state;
    
    logic [7:0] oversample_counter, next_oversample_oversample_counter;
    logic signed [39:0] sample_reg, next_sample_reg;
    logic dout, next_dout;
    
    logic signed [39:0] integrator_1, next_integrator_1;
    logic signed [39:0] integrator_2, next_integrator_2;
    logic signed [39:0] delta_1, delta_2;
    
    
    initial begin
        delta_1 = 0;
        delta_2 = 0;
    end
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= RESET;
            oversample_counter <= 0;
            sample_reg <= 0;
            integrator_1 <= 0;
            integrator_2 <= 0;
            dout <= 0;
        end else begin
            state <= next_state;
            oversample_counter <= next_oversample_oversample_counter;
            sample_reg <= next_sample_reg;
            integrator_1 <= next_integrator_1;
            integrator_2 <= next_integrator_2;
            dout <= next_dout;
        end
    end
    
    always @(*) begin
        next_state = state;
        
        // State transition updates
        if (state == RESET) begin
            next_state = SET;
        end 
    end
    
    always @(*) begin
        next_oversample_oversample_counter = oversample_counter;
        next_sample_reg = sample_reg;
        
        // Oversample and internal sample register updates
        if (state == RESET) begin
            next_sample_reg = {16'b0, samp, 8'b0};
        end else if (state == SET) begin
            if (oversample_counter == 8'b11111111) begin
                next_oversample_oversample_counter = '0;
                next_sample_reg = {16'b0, samp, 8'b0};
            end else begin
                next_oversample_oversample_counter = oversample_counter + 1;
            end
        end
    end
    
    always @(*) begin
        next_integrator_1 = integrator_1;
        next_integrator_2 = integrator_2;
        next_dout = dout;
        
        // Integrator and delta calculation updates
        if (state == SET) begin
            if (integrator_2 >= THRESHOLD) begin
                delta_2 = -THRESHOLD;
                delta_1 = -(2**24);
                next_dout = 1;
            end else begin
                delta_2 = 0;
                delta_1 = 0;
                next_dout = 0;
        end
        
        // Apparently there's a latch if I dont do this
        next_integrator_2 = integrator_2 + integrator_1 + delta_2;
        next_integrator_1 = integrator_1 + sample_reg + delta_1;
         
        end
    end
    
    assign pull = (state == RESET) || (oversample_counter == 8'hFF);
    assign pdata = dout;
    
endmodule