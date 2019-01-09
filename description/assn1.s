.equ SWI_Exit, 0x11
.data
        input:  .asciz         "10+2*3"
        .align

.text
        .global  main

main:
		@Result register = r0
		@Operator register = r1, initialize to #0
		@Latest fetched register = r2
		@ongoing store register = r3
		@Input address = r4
		@Index pointer = r5


		ldr r4, =input
		MOV r1, #0  @ initialize operator register
		MOV r5, #0  @ initialize pointer index
		MOV r3, #0  @ initialize ongoing store register
		MOV r10, #10  @ constant register



		loop:   ldrb r2, [r4, r5]
			
			cmp r2, #0     @ compare latest fetched to null, 0 is decimal for null, if null then perform remaining operations, if left
			beq perform_remaining_operation_and_exit			
			
			cmp r2, #48       @ hex to decimal for 30
			blt is_operator
	
	
			sub r2, r2, #48   @ hex to decimal for 30
			mul r3, r10, r3
			add r3, r3, r2    @ r3 = 10*r3+r2
			add r5, r5, #1	  @ increase byte index
			b loop


		is_operator:    cmp r1, #0
				bne perform_operation
				MOV r1, r2  @ move latest fetched operator to operator register
				MOV r0, r3  @ move ongoing store register value to result
				MOV r3, #0  @ initialize ongoing register back to 0
				add r5, r5, #1	@ increase byte index
				b loop
		

		perform_operation:  	cmp r1, #43  @ hex to decimal for 2B
					beq PLUS
					cmp r1, #45  @ hex to decimal for 2D
					beq MINUS
					bne MULTIPLY

		PLUS:   add r0, r0, r3
			cmp r2, #0     @ we are dealing with null character so exit after operation
			beq EXIT1
			MOV r1, r2
			add r5, r5, #1	@ increase byte index
			MOV r3, #0  @ initialize ongoing register back to 0
			b loop
		MINUS: 	sub r0, r0, r3
			cmp r2, #0     @ we are dealing with null character so exit after operation
			beq EXIT1
			MOV r1, r2
			add r5, r5, #1	@ increase byte index
			MOV r3, #0  @ initialize ongoing register back to 0
			b loop
		MULTIPLY:  	mul r0, r3, r0
				cmp r2, #0
				beq EXIT1
				MOV r1, r2
				add r5, r5, #1	@ increase byte index
				MOV r3, #0  @ initialize ongoing register back to 0
				b loop

		perform_remaining_operation_and_exit: 	cmp r1, #0	@means that no operations are remaining
							beq EXIT2
							b perform_operation
		EXIT2: 
			mov r0, r3	@means that null found and no operator found so simply result is stored number		
			swi SWI_Exit
		EXIT1:
			swi SWI_Exit

