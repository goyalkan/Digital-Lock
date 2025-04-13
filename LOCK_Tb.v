`timescale 1ns / 1ps

module digital_lock_tb;

    // Inputs
    reg clk;
    reg reset;
    reg try_again;
    reg [3:0] password;

    // Output
    wire led_output;

    // Instantiate the DUT
    digital_lock uut (
        .clk(clk),
        .reset(reset),
        .try_again(try_again),
        .password(password),
        .led_output(led_output)
    );

    // Clock generation (100 MHz, 10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Clock toggles every 5ns => 10ns full period
    end

    // Monitor all important signals
    always @(posedge clk) begin
        $display("Time = %0t ns || Password = %b | Try Again = %b | Reset = %b | LED = %b",
                 $time, password, try_again, reset, led_output);
    end

    // Stimulus block - synchronized using @(posedge clk)
    initial begin
        // Initialize all signals
        reset = 1;
        try_again = 0;
        password = 4'b0000;

        // === Wait for 2 clock cycles in reset ===
        @(posedge clk);
        @(posedge clk);
        reset = 0;

        // === Test Case 1: Wrong password (LED should stay OFF) ===
        @(posedge clk);
        password = 4'b0011;  // Apply wrong password
        @(posedge clk);      // Wait for response

        // === Test Case 2: Try Again with wrong password ===
        try_again = 1;
        @(posedge clk);      // Wait for TRY_AGAIN response
        try_again = 0;
        @(posedge clk);      // Extra cycle to stabilize

        // === Test Case 3: Correct password (should unlock) ===
        password = 4'b1010;
        @(posedge clk);      // Wait for correct password check

        // === Test Case 4: Wrong password + try_again ===
        password = 4'b1100;
        try_again = 1;
        @(posedge clk);      // Wrong try_again
        try_again = 0;
        @(posedge clk);      // Allow state to update

        // === Test Case 5: Correct password in TRY_AGAIN state ===
        password = 4'b1010;
        @(posedge clk);      // Correct entry again
        @(posedge clk);      // Observe output

        // Wait a bit to observe final state
        @(posedge clk);
        $display("Test completed.");
        $finish;
    end

endmodule
