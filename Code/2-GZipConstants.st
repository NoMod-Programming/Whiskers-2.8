SharedPool subclass: #GZipConstants
	instanceVariableNames: ''
	classVariableNames: 'CRCTable GZipAsciiFlag GZipCommentFlag GZipContinueFlag GZipDeflated GZipEncryptFlag GZipExtraField GZipMagic GZipNameFlag GZipReservedFlags '
	poolDictionaries: ''
	category: 'Compression-Streams'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GZipConstants class
	instanceVariableNames: ''!

!GZipConstants class methodsFor: 'pool initialization' stamp: 'EMP 11/20/2015 15:53'!
associationAt: aName
	^ self associationAt: aName ifAbsent: [nil]! !

!GZipConstants class methodsFor: 'pool initialization' stamp: 'EMP 11/20/2015 15:52'!
associationAt: aName ifAbsent: aBlock
	^ classPool at: aName ifAbsent: aBlock! !

!GZipConstants class methodsFor: 'pool initialization' stamp: 'ar 5/18/2003 19:00'!
gzipMagic
	^GZipMagic! !

!GZipConstants class methodsFor: 'pool initialization' stamp: 'ar 5/18/2003 19:00'!
initialize
	"GZipConstants initialize"
	GZipMagic := 16r8B1F.		"GZIP magic number"
	GZipDeflated := 8.			"Compression method"

	GZipAsciiFlag := 16r01.		"Contents is ASCII"
	GZipContinueFlag := 16r02.	"Part of a multi-part archive"
	GZipExtraField := 16r04.		"Archive has extra fields"
	GZipNameFlag := 16r08.		"Archive has original file name"
	GZipCommentFlag := 16r10.	"Archive has comment"
	GZipEncryptFlag := 16r20.	"Archive is encrypted"
	GZipReservedFlags := 16rC0.	"Reserved" ! !


GZipConstants initialize!
