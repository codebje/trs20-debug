	.thumb
	.syntax		unified
	.cpu		cortex-m4

.section	.vectors

vectors:
@ Vector table start
	.long		0x20010000	// stack
	.long		_start		// reset
	.long		_error		// NMI
	.long		_error		// hard fault
	.long		_error		// memory fault
	.long		_error		// bus fault
	.long		_error		// usage fault
@ Vector table end

.section	.text.error

	.global		_error
	.type 		_error, %function
_error:
	b		_error

	.size		_error, . - _error
