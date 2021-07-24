#define IP x23
#define PSP x24
.equ STACK_SIZE, 1024
.equ UART_BASE, 0x10000000

.global _start

.macro push sr
	sw \sr, 0(PSP)
	addi PSP, PSP, 4
.endm

.macro pop dr
	lw \dr, -4(PSP)
	addi PSP, PSP, -4
.endm

.macro loadipword dr
	# load from instruction stream
	lw \dr, 0(IP)
	# bump the instruction pointer
	add IP, IP, 4
.endm

_start:
    # setup stacks per hart
    csrr t0, mhartid                # read current hart id
    slli t0, t0, 10                 # shift left the hart id by 1024
    la   sp, stacks + STACK_SIZE    # set the initial stack pointer
				    # to the end of the stack space
    add  sp, sp, t0                 # move the current hart stack pointer
				    # to its place in the stack space

    # park harts with id != 0
    csrr a0, mhartid                # read current hart id
    bnez a0, PARK                   # if we're not on the hart 0
				    # we park the hart
	# setup the thing
	la PSP, parmstack
	# do the actual thing
	la IP, program
	j NEXT

PARK:
    wfi
    j PARK

NEXT:
	loadipword t0
	# jump to the next 'forth' instruction
	jr t0

# instruction: destination, source, value
PRINT:
	pop x10
	li x11, 10         # load a hardcoded base into the second register / parameter
	jal print          # lowercase C version
	j NEXT

PLUS:
	pop t1
	pop t2
	add t1, t2, t1
	push t1
	j NEXT

MINUS:
	pop t1
	pop t2
	sub t1, t2, t1
	push t1
	j NEXT

DOLIT:
	# consume next word in the instruction stream and push it onto the stack
	loadipword t0
	push t0
	j NEXT


KEY:
    li t0, UART_BASE
    lb t1, 5(t0)
    andi t1, t1, 0x1
    beqz t1, KEY
    lb t1, 0(t0)
    push t1
    j NEXT

BRANCH:
	loadipword t0
	add IP, IP, t0
	j NEXT

program:
	.word DOLIT, 5, DOLIT, 1, MINUS, PRINT
	.word DOLIT, 1971, DOLIT, 1987, PLUS, PRINT
	.word KEY, PRINT, BRANCH, -16
	.word PARK

stacks:
    .skip STACK_SIZE * 4            # allocate 1024 * 4 space for the harts stacks

parmstack:
	.skip STACK_SIZE * 4  # allocate 1024 * 4 space for OUR OWN stack
