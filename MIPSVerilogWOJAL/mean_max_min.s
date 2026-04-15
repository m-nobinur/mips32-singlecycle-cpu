.data
// Expected: sum = 146, mean = 14, max = 30, min = 3.
numbers: .word 12, 7, 25, 3, 18, 30, 9, 21, 15, 6

.text
main:
    // Register map:
    // $t0 = ptr (points to numbers[i])
    // $t1 = n0 (first value)
    // $t2 = sum
    // $t3 = max
    // $t4 = min
    // $t5 = left (remaining values to process)
    // $t6 = n (current value)
    // $t7 = flag for max update
    // $t8 = flag for min update
    // $t9 = rem (remainder accumulator for division)
    // $s0 = mean (quotient)
    // $s1 = divisor (10)
    // $s2 = stop flag in division loop
    
    la $t0, numbers       // ptr = &numbers[0]
    lw $t1, 0($t0)        // n0 = numbers[0]
    add $t2, $t1, $0      // sum = n0
    add $t3, $t1, $0      // max = n0
    add $t4, $t1, $0      // min = n0

    // We already used numbers[0], so process numbers[1..9].
    addi $t5, $0, 9       // left = 9

loopa:
    // i += 1 (move pointer to next number)
    addi $t0, $t0, 1
    lw $t6, 0($t0)        // n = numbers[i]

    // sum += n
    add $t2, $t2, $t6

    // if (max < n) max = n
    slt $t7, $t3, $t6
    beq $t7, $0, skipmax
    add $t3, $t6, $0

skipmax:
    // if (n < min) min = n
    slt $t8, $t6, $t4
    beq $t8, $0, skipmin
    add $t4, $t6, $0

skipmin:
    // left -= 1
    addi $t5, $t5, -1
    // if (left != 0) keep looping
    bne $t5, $0, loopa

    // mean = sum / 10 (integer division via repeated subtraction)
    add $t9, $t2, $0      // rem = sum
    addi $s0, $0, 0       // mean = 0
    addi $s1, $0, 10      // divisor = 10

divloop:
    // stop when rem < 10
    slt $s2, $t9, $s1
    bne $s2, $0, store

    // rem -= 10
    sub $t9, $t9, $s1
    // mean += 1
    addi $s0, $s0, 1
    j divloop

store:
    // DMEM[100] = mean, DMEM[120] = max, DMEM[140] = min.
    sw $s0, 100($0)
    sw $t3, 120($0)
    sw $t4, 140($0)

halt:
    j halt
