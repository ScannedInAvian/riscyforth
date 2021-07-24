#define IP x23
#define PSP x24
.equ STACK_SIZE, 1024

.global _start

.macro push sr
	sw \sr, 0(PSP)
	addi PSP, PSP, 4
.endm

.macro pop dr
	lw \dr, -4(PSP)
	addi PSP, PSP, -4
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
	# load from instruction stream
	lw t0, 0(IP)
	# bump the instruction pointer
	add IP, IP, 4
	# jump to the next 'forth' instruction
	jr t0

# instruction: destination, source, value
PRINT:
	pop x10
	li x11, 10         # load a hardcoded base into the second register / parameter
	jal print          # lowercase C version
	j NEXT

FOUR:
	li t0, 4       # store the thing
	push t0
	j NEXT         # special thing here!

PLUS:
	pop t1
	pop t2
	add t1, t1, t2
	push t1
	j NEXT

program:
    .word FOUR, FOUR, FOUR, PLUS, PLUS, PRINT, PARK

stacks:
    .skip STACK_SIZE * 4            # allocate 1024 * 4 space for the harts stacks

parmstack:
	.skip STACK_SIZE * 4  # allocate 1024 * 4 space for OUR OWN stack
