# Loop-Simulator-Interface
Interface between UVa-Padova T1DM simulator and PyLoopKit implementation of Loop algorithm.

## Usage:
- Install pyloopkit via anaconda: instructions https://github.com/tidepool-org/PyLoopKit 
- Find path to anaconda pyloopkit and adjust paths in loop_data_manager_interface.py
- Add loop_data_manager_interface.py to pyloopkit installation next to original loop_data_manager.py
- Write a init and run loop for controller in simulator (check example_code.m for basic implementations)

## Files:

#### Loop_data_manager_interface.py: 
- An adjusted version of the pyloopkit data manager to handle json passing. 
- Adjust the paths inside and place this in the pyloopkit installation, next to the default Loop_data_manager.py. 

#### Loop.m:
- Controller class. Contains constructor with loop model settings and function for calling loopkit.
- To Use: 
    - Call constructor in simulator init with participant-specific settings e.g. ICR, ISF, Basal and times.
    - Check hardcoded model settings in constructor. Adjust target ranges etc. if desired. 
    - Call loop_run in controller loop.

#### loop_example.m 
- Basic example code showing calling loop function for testing installation and understanding input formats and flow.
- To Use: Adjust path to loopkit installation, check settings, run. Set breakpoint on results to see output. 

#### Example_code.m
- Contains basic example code for the init and controller loop. 
- Only provided in a .m for syntax highlighting/convenience. Will not just run. 
