module digital_lock(
    input wire clk,              // Clock input
    input wire reset,            // Reset button
    input wire try_again,        // Try again button
    input wire [3:0] password,   // 4-bit password input via switches
    output reg led_output        // LED output (1 = ON/unlocked, 0 = OFF/locked)
);

    parameter CORRECT_PASSWORD = 4'b1010;  // Example: password is "1010"
    
    // Define states
    parameter LOCKED     = 2'b00;
    parameter TRY_AGAIN  = 2'b01;
    parameter UNLOCKED   = 2'b10;
    
    reg [1:0] current_state;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= LOCKED;
            led_output <= 0;  // Turn LED OFF when reset
        end
        else begin
            case (current_state)
                LOCKED: begin
                    if (password == CORRECT_PASSWORD) begin
                        current_state <= UNLOCKED;
                        led_output <= 1;  // Unlock
                    end
                    else if (try_again) begin
                        current_state <= TRY_AGAIN;
                        led_output <= 0;  // Stay locked, LED OFF
                    end
                    else begin
                        current_state <= LOCKED;
                        led_output <= 0;  // Stay locked, LED OFF
                    end
                end

                TRY_AGAIN: begin
                    if (password == CORRECT_PASSWORD) begin
                        current_state <= UNLOCKED;
                        led_output <= 1;  // Unlock
                    end
                    else if (!try_again) begin
                        current_state <= LOCKED;
                        led_output <= 0;  // Go back to locked
                    end
                    else begin
                        current_state <= TRY_AGAIN;
                        led_output <= 0;  // Stay in try again, LED OFF
                    end
                end

               UNLOCKED: begin
               if (try_again || password != CORRECT_PASSWORD) begin
                 current_state <= LOCKED;
                 led_output <= 0;
               end else begin
               current_state <= UNLOCKED;
               led_output <= 1;
               end
             end

            endcase
        end
    end
endmodule
