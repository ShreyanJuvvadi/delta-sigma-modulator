# delta-sigma-modulator
An implementation of a two-stage delta sigma modulator in verilog

## Overview

The module (`mod.v`) implements a two-stage Delta-Sigma modulator designed to convert a 16-bit digital input (`samp`) into a 1-bit digital output (`pdata`). The modulator incorporates oversampling to achieve a higher resolution.

## Module Description

### Inputs

-   `clk`: Clock input - tested to work more then 500 MHz
-   `reset`: Asynchronous reset input
-   `samp`: 16-bit digital input sample - theoretical input ranging from 0 to 1 represented in 16 bits

### Outputs

-   `pull`: A signal indicating when (`samp`) is pulled (high when reset or at the end of the oversampling period)
-   `pdata`: 1-bit digital output data

### Parameters

-   `THRESHOLD`: A local parameter representing the threshold value for the second integrator. It is set to `28'h14CCCCC`, which approximates 1.3. Ideally, it will be a number randing from 1.2 to 1.4.

### Design

The input is 16 bits represented by (`samp`), which is then added to (`next_sample_reg`) as (`{16'b0, samp, 8'b0}`). The 8 bits below are to allow for a higher resolution calculations of the two integrators while the 16 bits above are to allow for a ghreater accumulation value.

### Functionality

1.  **Reset State:**
    -      When `reset` is asserted, the state machine enters the `RESET` state.
    -      The internal registers (`oversample_counter`, `sample_reg`, `integrator_1`, `integrator_2`, `dout`) are initialized to zero.
    -      The input sample `samp` is padded and loaded into `sample_reg`.
    -      The `pull` output is asserted high.
2.  **Set State:**
    -      After reset, the state machine transitions to the `SET` state.
    -      The `oversample_counter` increments with each clock cycle.
    -      When `oversample_counter` reaches its maximum value (255), it resets to zero, and a new sample is loaded into `sample_reg`.
    -   The `pull` output is asserted high when the counter is equal to 255.
    -      The two integrators (`integrator_1`, `integrator_2`) accumulate the input sample and feedback values.
    -      If `integrator_2` exceeds the `THRESHOLD`, the output `dout` is set high, and negative feedback values (`delta_1`, `delta_2`) are generated. Otherwise, `dout` is set low, and the feedback values are zero.
3.  **Oversampling:**
    -      The module uses an 8-bit counter for oversampling, allowing for a high oversampling ratio.
4.  **Feedback:**
    -      The feedback mechanism adjusts the integrator values based on the output `dout` and the threshold comparison.

## Dependencies

-   No external libraries are required.

## License

This project is licensed under the [MIT License](LICENSE).
