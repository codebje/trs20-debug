; TRS-20 basic ROM

.z180

#target rom

; Code sections
#code	RESTARTS,$0000		; RESTART vector table
#code	BOOT			; BOOT code

; Registers
RCR	equ	$36

; Define the RESTART vector table. This table is the target of both the RST instructions
; and the CPU's hard reset.

#code	RESTARTS

reset:	.org	$0000
	ld	a, 0
	out0	(RCR), A	; disable the DRAM refresh
	jp	_start

rst_08:	.org	$0008
rst_10:	.org	$0010
rst_18:	.org	$0018
rst_20:	.org	$0020
rst_28:	.org	$0028
rst_30:	.org	$0030
rst_38:	.org	$0038

#code	BOOT

_start:
	nop
	jp	_start
