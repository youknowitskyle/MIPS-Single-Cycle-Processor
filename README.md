# MIPS-Single-Cycle-Processor

A 32-bit single cycle MIPS processor implemented using Verilog.

Instructions are read from a file named "memfile.dat". Two test files are included.

### Second Testfile in Assembly
`    main: ori $t0, $0, 0x8000
         addi $t1, $0, -32768
         ori $t2, $t0, 0x8001
         beq $t0, $t1, there
         slt $t3, $t1, $t0
         bne $t3, $0, here
         j there
     here: sub $t2, $t2, $t0
         ori $t0, $t0, 0xFF
     there: add $t3, $t3, $t2
         sub $t0, $t2, $t0
         sw $t0, 82($t3)
`

## Supported Instructions:
`
  add
  sub
  and
  or
  slt
  lw
  sw
  beq
  addi
  j
  ori
  bne
`
  
