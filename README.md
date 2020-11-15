# MIPS-Single-Cycle-Processor

A 32-bit single cycle MIPS processor implemented using Verilog.

Instructions are read from a file named "memfile.dat". Two test files are included.

### First Test File (memfile.dat) in Assembly
```
main: 
    addi $2, $0, 5 
    addi $3, $0, 12
    addi $7, $3, −9
    or $4, $7, $2
    and $5, $3, $4
    add $5, $5, $4
    beq $5, $7, end
    slt $4, $3, $4
    beq $4, $0, around
    addi $5, $0, 0
around: 
    slt $4, $7, $2
    add $7, $4, $5
    sub $7, $7, $2
    sw $7, 68($3)
    lw $2, 80($0)
    j end
    addi $2, $0, 1
end: 
    sw $2, 84($0)
```

### Second Test File (memfile2.dat) in Assembly
```
main: 
    ori $t0, $0, 0x8000
    addi $t1, $0, -32768
    ori $t2, $t0, 0x8001
    beq $t0, $t1, there
    slt $t3, $t1, $t0
    bne $t3, $0, here
    j there
here: 
    sub $t2, $t2, $t0
    ori $t0, $t0, 0xFF
there: 
    add $t3, $t3, $t2
    sub $t0, $t2, $t0
    sw $t0, 82($t3)
```

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
  
