Please refer to html for diagram.
We are keeping the value of B register on the basis of whether its immediate or from register file, considering the instruction.
Register file always gives B=Rm in control_state = 1
While writing a byte to memory or register, in signed case the MSB is copied till 32nd bit
same while writing a half word to memory or register, in signed case the MSB is copied till 32nd bit
In control_state=7, B is the register written to memory and
In control_state=8, DR is the register updated from memory