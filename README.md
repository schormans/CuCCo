# CuCCo: The Coupled Coil Configurator

CuCCo provides a series of MATLAB scripts that allow for calculation of 2-coil inductive link parameters, based on geometric coil definitions.
Currently, wirewound solenoid coils and PCB-based spiral coils are supported.
CuCCo allows seamless geometric → electrical parameter conversion to allow links to be designed without the need for FEM simulations.
## Current Features

Currently an example file `cochlear_example.m` is provided, which shows 
the process for modelling an inductive link for a cochlear implant made 
from identical solenoid coils.

*The following parameters can currently be calculated using CuCCo*

### Coil Params
- Inductance
- Resistance and Q-factor
- Parallel Capacitance and Self-resonant frequency
- Required capacitance to form a resonant tank

### Link Params
- Link Gain
- Link Efficiency
- Mutual Inductance/Coupling coefficient

## Function Descriptions

### Coil Object Definitions

Currently two coil objects classes are implemented `SolWireCoil` and 
`PCBCoil`. Each is constructed from geometric parameters, an input 
frequency, and a predicted source resistance.
Upon construction, the electrical parameters for the coils are 
calculated and held as object properties. Details are summarized below.

#### `SolWireCoil.m`

Implements a single-layer solenoid wirewound coil.

*Inputs*
- *n*: Number of turns
- *r_0*: Wire cross-sectional radius
- *p*: Turn pitch, this can be set to zero to assume a minimum pitch 
(adjacent wires touching)
- *r*: Coil radius
- *f*: Drive frequency (this can be a vector)
- *CP*: Parallel capacitance. If this is set to zero, the constructor 
will attempt to predict a parallel capacitance based on geometry, this 
will lose accuracy for low turn counts and strange geometries.
- *sourceres*: Additional resistance expected to be inherent to the 
design. For a Tx coil this should include the source resistance, for an 
Rx coil this should include connecting trace resistances. This 
can be set to zero, but neglecting to 
include this resistance may produce over-optimistic Q-factor 
predictions. 

*Outputs*
- *l*: Coil length, depends on *n* and *p*.
- *L*: Inductance
- *Rs*: Series loss resistance
- *Q*: Q-factor (Im(Z)/Re(Z))
- *C*: Tank capacitance required for the coil to resonate at the drive 
frequency *f*
- *fSRF*: Self-resonant frequency; either calculated from a 
user-supplied CP value, or predicted from geometry.
- *CP*: If not user supplied, this will be calculated from the predicted 
fSRF.
- *coilZ*: Total coil impedance, considering L, Rs, and CP.

**Note**: If *f* is supplied as a vector, *Rs, Q, C, *and* coilZ* will 
be created as vectors of the same length, with each value corresponding 
to the values of *f* in the input vector.

#### `PCBCoil.m`

Implements a PCB-based spiral coil, assuming standard 1oz copper on FR4 
substrate.

`PCBCoil` objects are generated in the same way as `SolWireCoil` 
objects, the only real difference being the input geometry parameters.

*Inputs*
- *dout*: The outer diameter of the spiral (edge to edge)
- *fillfact*: The 'fill factor', defining the amount of the spiral 
outer diameter that is filled with turns, defining the inner diameter 
*din* in the process.
- *s*: Spacing between turns (edge to edge)
- *w*: Turn track width
- *f*: See `SolWireCoil.m` *f* entry.
- *shape*: String, can be 'square','circ','hex', or 'oct'.
- *sourceres*: See `SolWireCoil.m` *sourceres* entry.

*Outputs*
These are the same as for `SolWireCoil.m`, with *din* instead of *l*.

### Link Parameter Functions

With coils defined, link parameters can be determined with the 
following functions

#### `mutualIdeal.m`

Determines the mutual inductance and coupling factor of two coaxially 
aligned coils, separated by a distance *dist*. The two coil objects must 
currently be of the same class.

*Inputs*
- *coil1, coil2*: The input coil objects, can be `SolWireCoil` or 
`PCBCoil`
- *dist*: The coaxial distance between the two coil objects

*Outputs*
- *M*: Mutual inductance between the coils
- *k*: Coupling factor (*M* normalized to geometric mean of the two coil 
inductances)

#### `zlink.m`

Determines the link impedance of two coupled coils.

*Inputs*
- *config*: can be 'SS','SP','PS', or 'PP', corresponding to each 
possible resonant link arrangement.
- *ZL1, ZL2*: impedances of coil1 and coil2 respectively.
- *M*: mutual inductance between the two coils.
- *omega*: angular drive frequency
- *Zout*: connected output impedance (load)
- *C1, C2*: resonant tank capacitors for coil1 and coil2

*Outputs*
- *zlinkval*: The impedance looking into the link, given as a cartesian 
complex number.

#### `gain.m`

Determines the link gain of two coupled coils

*Inputs*
- *config*: can be 'SS','SP','PS', or 'PP', corresponding to each 
possible resonant link arrangement.
- *ZL1, ZL2*: impedances of coil1 and coil2 respectively.
- *M*: mutual inductance between the two coils.
- *omega*: angular drive frequency
- *Zout*: connected output impedance (load)
- *C1, C2*: resonant tank capacitors for coil1 and coil2
- *Zlink*: Link impedance seen at the input of the link.

*Outputs*
- *gainval*: the gain of the link, either a voltage gain or a 
transimpedance, depending if the input is a voltage or a current.

#### `etamax.m`

Determines the maximum theoretical efficiency of a given link.

*Inputs*
- *k*: coupling factor
- *Q1, Q2*: the Q-factors of the two link coils

*Outputs*
- *max_eff*: the maximum theoretical efficiency of the link with the 
given input parameters.

## Features to be Added (TODO)


- Proper methods for efficiency calculation, currently this is manual 
(see `cochlear_example.m`).
- Currently coils are assumed to be coaxially aligned, need to add methods for lateral and angular misalignment.
- For PCB coils, Rs prediction is sensitive to input variables. Ideally need a better approximation.
- Non-square PCB coils currently use the gap length formula for square 
coils; this should be updated. Non-critical, since this only affects SRF 
calcs.
- Improve user friendliness; implement GUI when all other functions are in place.
