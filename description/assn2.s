.equ SWI_Exit, 0x11
.equ SWI_PrInt,0x6b
.data
        input:  .asciz         "10+(2*(3+(4-(5*(6-(9*7))))))"
        .align

.text
        .global  main

main:

		@ r4 = input address (GLOBAL)
		@ r5 = Index of pointer (GLOBAL)
		@ r6 = pointer_val, latest fetched byte (GLOBAL)

		@ Function   - (Parameter, result)

		@ EXPRESSION - (None, r1)
		@ TERM 	   - (None, r0)
		@ CONSTANT   - (r1, r0)
		@ EXP_TAIL   - (r2, r0)
		@ CONSTAIL   - (r3, r0)

		ldr r4, =input
		mov r10, #10  @ Constant register containing 10
		bl EXPRESSION
		b EXIT

		CONSTAIL:	ldrb r6, [r4, r5]
					sub r6, r6, #48
					cmp r6, #0 		@ checking whether digit or not
					bge if_constail
					
					@else condition below
					mov r0, r3  @ return x
					mov pc, lr

		if_constail:
					mul r3, r10, r3
					add r3, r6
					add r5, r5, #1
					b CONSTAIL
					

		CONSTANT:	
					ldrb r6, [r4, r5]
					sub r6, r6, #48
					mov r3, r6
					add r5, r5, #1
					push {lr}
					push {r1,r2,r3}
					bl CONSTAIL
					pop {r1,r2,r3}
					pop {lr}
					mov pc, lr

		TERM:	
				ldrb r6, [r4, r5]
				cmp r6, #40  @ means pointer_val is '('
				beq if_term

				@else condition below
				push {lr}
				push {r1,r2,r3}
				bl CONSTANT
				pop {r1,r2,r3}
				pop {lr}
				mov pc, lr
		if_term:
				add r5, r5, #1
				push {lr}
				push {r0,r2,r3}
				bl EXPRESSION
				pop {r0,r2,r3}
				pop {lr}
				add r5, r5, #1
				mov r0, r1
				mov pc, lr


		EXP_TAIL:
					ldrb r6, [r4, r5]
					cmp r6, #43
					beq exp_tail_plus
					cmp r6, #45
					beq exp_tail_minus
					cmp r6, #42
					beq exp_tail_multiply

					@else condition below
					mov r0, r2
					mov pc, lr

		exp_tail_plus:
						add r5, r5, #1
						push {lr}
						push {r1,r2,r3}
						bl TERM
						pop {r1,r2,r3}
						pop {lr}
						add r2, r2, r0   @ x = x + term()
						b EXP_TAIL

		exp_tail_minus:
						add r5, r5, #1
						push {lr}
						push {r1,r2,r3}
						bl TERM
						pop {r1,r2,r3}
						pop {lr}
						sub r2, r2, r0   @ x = x - term()
						b EXP_TAIL

		exp_tail_multiply:
						add r5, r5, #1
						push {lr}
						push {r1,r2,r3}
						bl TERM
						pop {r1,r2,r3}
						pop {lr}
						mul r2, r0, r2   @ x = term()*x
						b EXP_TAIL
						


		EXPRESSION: 
					push {lr}
					push {r1,r2,r3}
					bl TERM
					pop {r1,r2,r3}
					pop {lr}

					mov r2, r0
					push {lr}
					push {r1,r2,r3}
					bl EXP_TAIL
					pop {r1,r2,r3}
					pop {lr}

					mov r1, r0
					mov pc, lr

		EXIT:	
				mov R0, r0
				mov R1, r1
				swi SWI_PrInt
				swi SWI_Exit