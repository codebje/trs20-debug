; TRS-20 basic ROM

.z180

#target rom

#code	VECTORS,0x0000
#code	BOOT

#code	VECTORS
reset:
	jp	_start

_start:
