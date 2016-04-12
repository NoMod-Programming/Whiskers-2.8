SharedPool subclass: #ZipFileConstants
	instanceVariableNames: ''
	classVariableNames: 'CentralDirectoryFileHeaderSignature CompressionDeflated CompressionLevelDefault CompressionLevelNone CompressionStored DataDescriptorLength DefaultDirectoryPermissions DefaultFilePermissions DeflatingCompressionFast DeflatingCompressionMaximum DeflatingCompressionNormal DeflatingCompressionSuperFast DirectoryAttrib EndOfCentralDirectorySignature FaMsdos FaUnix FileAttrib IfaBinaryFile IfaTextFile LocalFileHeaderSignature '
	poolDictionaries: ''
	category: 'Compression-Archives'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ZipFileConstants class
	instanceVariableNames: ''!

!ZipFileConstants class methodsFor: 'pool initialization' stamp: 'EMP 11/20/2015 12:39'!
associationAt: aName
	^ self associationAt: aName ifAbsent: [nil]! !

!ZipFileConstants class methodsFor: 'pool initialization' stamp: 'EMP 11/20/2015 12:27'!
associationAt: aName ifAbsent: aBlock
	^ classPool at: aName ifAbsent: aBlock! !

!ZipFileConstants class methodsFor: 'pool initialization' stamp: 'EMP 11/20/2015 12:33'!
associationAt: aName put: aValue
	^ classPool at: aName put: aValue! !

!ZipFileConstants class methodsFor: 'pool initialization' stamp: 'nk 8/21/2004 15:50'!
initialize
	"ZipFileConstants initialize"
	FaMsdos		:= 0.
	FaUnix 		:= 3.
	DeflatingCompressionNormal		:= 0.
	DeflatingCompressionMaximum	:= 2.
	DeflatingCompressionFast		:= 4.
	DeflatingCompressionSuperFast	:= 6.
	CompressionStored				:= 0.
	CompressionDeflated				:= 8.
	CompressionLevelNone			:= 0.
	CompressionLevelDefault			:= 6.
	IfaTextFile						:= 1.
	IfaBinaryFile					:= 0.
	DataDescriptorLength 				:= 12.

	"Unix permission bits"
	DefaultDirectoryPermissions		:= 8r040755.
	DefaultFilePermissions			:= 8r0100666.
	DirectoryAttrib 					:= 8r040000.
	FileAttrib 						:= 8r0100000.

	CentralDirectoryFileHeaderSignature := 
		(ByteArray with: 16r50 with: 16r4B with: 16r01 with: 16r02).
	LocalFileHeaderSignature :=
		(ByteArray with: 16r50 with: 16r4B with: 16r03 with: 16r04).
	EndOfCentralDirectorySignature :=
		(ByteArray with: 16r50 with: 16r4B with: 16r05 with: 16r06).! !


ZipFileConstants initialize!
