# CuCCo: The Coupled Coil Configurator

CuCCo provides a series of MATLAB scripts that allow for calculation of 2-coil inductive link parameters, based on geometric coil definitions.
Currently, wirewound solenoid coils and PCB-based spiral coils are supported.
CuCCo allows seamless geometric → electrical parameter conversion to allow links to be designed without the need for FEM simulations.
## Current Features

*The following parameters can currently be calculated using CuCCo →*

### Coil Params
- Inductance
- Resistance and Q-factor
- Parallel Capacitance and Self-resonant frequency
- Required capacitance to form a resonant tank

### Link Params
- Link Gain
- Link Efficiency
- Mutual Inductance/Coupling coefficient

## Features to be Added (TODO)

- Currently coils are assumed to be coaxially aligned, need to add methods for lateral and angular misalignment.
- For PCB coils, Rs prediction is sensitive to input variables. Ideally need a better approximation.
- Non-square PCB coils currently use the gap length formula for square coils; this should be updated.
