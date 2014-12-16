;to use these pseudo-random number sequence generators, memory must be
;set aside to hold the last random number, which is used to generate the
;next one so that a randomly distributed (but predictable) sequence of
;number is generated.
rand8reg SET 0x20		;one byte
rand16reg SET 0x21		;two bytes
;generates an 8 bit pseudo-random number which is returned in Acc.
;one byte of memory must be available for rand8reg
code
RAND8:	
    mov	a, rand8reg
	jnz	rand8b
	cpl	a
	mov	rand8reg, a
	rand8b:	
    anl	a, #10111000b
	mov	c, p
	mov	a, rand8reg
	rlc	a
	mov	rand8reg, a
	ret
	;generates a 16 bit pseudo-random number which is returned in Acc (lsb) & B (msb)
;two bytes of memory must be available for rand16reg
code
RAND16:	
    mov	a, rand16reg
	jnz	rand16b
	mov	a, rand16reg+1
	jnz	rand16b
	cpl	a
	mov	rand16reg, a
	mov	rand16reg+1, a
	rand16b:
    anl	a, #11010000b
	mov	c, p
	mov	a, rand16reg
	jnb	acc.3, rand16c
	cpl	c
	rand16c:
    rlc	a
	mov	rand16reg, a
	mov	b, a
	mov	a, rand16reg+1
	rlc	a
	mov	rand16reg+1, a
	xch	a, b
	ret
	