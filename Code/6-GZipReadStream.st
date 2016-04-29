FastInflateStream subclass: #GZipReadStream
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: 'GZipConstants '
	category: 'Compression-Streams'!

!GZipReadStream methodsFor: 'initialize' stamp: 'EMP 4/15/2016 11:15'!
on: aCollection from: firstIndex to: lastIndex
	"Check the header of the GZIP stream."
	| method magic flags length |
	super on: aCollection from: firstIndex to: lastIndex.
	crc := 16rFFFFFFFF.
	magic := self nextBits: 16.
	(magic = GZipMagic) 
		ifFalse:[^self error:'Not a GZipped stream'].
	method := self nextBits: 8.
	(method = GZipDeflated)
		ifFalse:[^self error:'Bad compression method'].
	flags := self nextBits: 8.
	(flags anyMask: GZipEncryptFlag) 
		ifTrue:[^self error:'Cannot decompress encrypted stream'].
	(flags anyMask: GZipReservedFlags)
		ifTrue:[^self error:'Cannot decompress stream with unknown flags'].
	"Ignore stamp, extra flags, OS type"
	self nextBits: 16; nextBits: 16. "stamp"
	self nextBits: 8. "extra flags"
	self nextBits: 8. "OS type"
	(flags anyMask: GZipContinueFlag) "Number of multi-part archive - ignored"
		ifTrue:[self nextBits: 16]. 
	(flags anyMask: GZipExtraField) "Extra fields - ignored"
		ifTrue:[	length := self nextBits: 16.
				1 to: length do:[:i| self nextBits: 8]].
	(flags anyMask: GZipNameFlag) "Original file name - ignored"
		ifTrue:[[(self nextBits: 8) = 0] whileFalse].
	(flags anyMask: GZipCommentFlag) "Comment - ignored"
		ifTrue:[[(self nextBits: 8) = 0] whileFalse].
! !


!GZipReadStream methodsFor: 'crc' stamp: 'ar 2/29/2004 03:30'!
updateCrc: oldCrc from: start to: stop in: aCollection
	"Answer an updated CRC for the range of bytes in aCollection"
	^ZipWriteStream updateCrc: oldCrc from: start to: stop in: aCollection.! !

!GZipReadStream methodsFor: 'crc' stamp: 'ar 2/29/2004 04:20'!
verifyCrc
	| stored |
	stored := 0.
	0 to: 24 by: 8 do: [ :i |
		sourcePos >= sourceLimit ifTrue: [ ^ self crcError: 'No checksum (proceed to ignore)' ].
		stored := stored + (self nextByte bitShift: i) ].
	stored := stored bitXor: 16rFFFFFFFF.
	stored = crc ifFalse: [ ^ self crcError: 'Wrong checksum (proceed to ignore)' ].
	^stored! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GZipReadStream class
	instanceVariableNames: ''!

!GZipReadStream class methodsFor: 'class initialization' stamp: 'ar 12/27/1999 15:37'!
initialize
	"GZipReadStream initialize"
	#(
		(GZipMagic 16r8B1F)		"GZIP magic number"
		(GZipDeflated 8)			"Compression method"

		(GZipAsciiFlag 16r01)		"Contents is ASCII"
		(GZipContinueFlag 16r02)	"Part of a multi-part archive"
		(GZipExtraField 16r04)	"Archive has extra fields"
		(GZipNameFlag 16r08)	"Archive has original file name"
		(GZipCommentFlag 16r10)	"Archive has comment"
		(GZipEncryptFlag 16r20)	"Archive is encrypted"
		(GZipReservedFlags 16rC0)"Reserved" 
	) do:[:spec|
		GZipConstants declare: spec first from: Undeclared.
		GZipConstants at: spec first put: spec last.
	].! !

!GZipReadStream class methodsFor: 'class initialization' stamp: 'SD 11/15/2001 22:21'!
unload

	FileList unregisterFileReader: self ! !


!GZipReadStream class methodsFor: 'fileIn/Out' stamp: 'yo 8/18/2004 20:24'!
fileIn: fullFileName
	"FileIn the contents of a gzipped file"
	| zipped unzipped |
	zipped := self on: (FileStream readOnlyFileNamed: fullFileName).
	unzipped := MultiByteBinaryOrTextStream with: (zipped contents asString).
	unzipped reset.
	unzipped fileIn.
! !

!GZipReadStream class methodsFor: 'fileIn/Out' stamp: 'pk 10/17/2006 09:40'!
fileIntoNewChangeSet: fullFileName
	"FileIn the contents of a gzipped file"
	| zipped unzipped cs |
	cs := Smalltalk at: #ChangesOrganizer ifAbsent: [ ^self ].
	zipped := self on: (FileStream readOnlyFileNamed: fullFileName).
	unzipped := MultiByteBinaryOrTextStream with: zipped contents asString.
	unzipped reset.
	cs newChangesFromStream: unzipped named: (FileDirectory localNameFor: fullFileName)
! !

!GZipReadStream class methodsFor: 'fileIn/Out' stamp: 'pk 10/17/2006 09:41'!
fileReaderServicesForFile: fullName suffix: suffix 
	| services |
	(suffix = 'gz') | (suffix = '*')
		ifFalse: [^ #()].
	services := OrderedCollection new.
	(suffix = '*') | (fullName asLowercase endsWith: '.cs.gz') | (fullName asLowercase endsWith: '.mcs.gz')
		ifTrue: [services add: self serviceFileIn.
			(Smalltalk includesKey: #ChangSet)
				ifTrue: [services add: self serviceFileIntoNewChangeSet]].
	services addAll: self services.
	^ services! !

!GZipReadStream class methodsFor: 'fileIn/Out' stamp: 'LEG 10/24/2001 23:56'!
saveContents: fullFileName
	"Save the contents of a gzipped file"
	| zipped buffer unzipped newName |
	newName := fullFileName copyUpToLast: FileDirectory extensionDelimiter.
	unzipped := FileStream newFileNamed: newName.
	unzipped binary.
	zipped := GZipReadStream on: (FileStream readOnlyFileNamed: fullFileName).
	buffer := ByteArray new: 50000.
	'Extracting ' , fullFileName
		displayProgressAt: Sensor cursorPoint
		from: 0
		to: zipped sourceStream size
		during: 
			[:bar | 
			[zipped atEnd]
				whileFalse: 
					[bar value: zipped sourceStream position.
					unzipped nextPutAll: (zipped nextInto: buffer)].
			zipped close.
			unzipped close].
	^ newName! !

!GZipReadStream class methodsFor: 'fileIn/Out' stamp: 'nk 11/26/2002 12:11'!
serviceDecompressToFile

	^ FileModifyingSimpleServiceEntry 
				provider: self 
				label: 'decompress to file'
				selector: #saveContents:
				description: 'decompress to file'! !

!GZipReadStream class methodsFor: 'fileIn/Out' stamp: 'nk 12/13/2002 11:14'!
serviceFileIn
	"Answer a service for filing in an entire file"

	^ SimpleServiceEntry 
		provider: self 
		label: 'fileIn entire file'
		selector: #fileIn:
		description: 'file in the entire decompressed contents of the file, which is expected to contain Smalltalk code in fileout ("chunk") format'
		buttonLabel: 'filein'

! !

!GZipReadStream class methodsFor: 'fileIn/Out' stamp: 'nk 12/13/2002 11:26'!
serviceFileIntoNewChangeSet
	"Answer a service for filing in an entire file"
	^ SimpleServiceEntry
		provider: self
		label: 'install into new change set'
		selector: #fileIntoNewChangeSet:
		description: 'install the decompressed contents of the file as a body of code in the image: create a new change set and file-in the selected file into it'
		buttonLabel: 'install'! !

!GZipReadStream class methodsFor: 'fileIn/Out' stamp: 'sd 2/1/2002 22:15'!
serviceViewDecompress

	^ SimpleServiceEntry 
				provider: self 
				label: 'view decompressed'
				selector: #viewContents:
				description: 'view decompressed' 
! !

!GZipReadStream class methodsFor: 'fileIn/Out' stamp: 'sd 2/1/2002 22:16'!
services

	^ Array 
		with: self serviceViewDecompress
		with: self serviceDecompressToFile
	! !

!GZipReadStream class methodsFor: 'fileIn/Out' stamp: 'dgd 9/21/2003 17:46'!
uncompressedFileName: fullName
	^((fullName endsWith: '.gz') and: [self confirm: ('{1}
appears to be a compressed file.
Do you want to uncompress it?' translated format:{fullName})])
		ifFalse: [fullName]
		ifTrue:[self saveContents: fullName]! !

!GZipReadStream class methodsFor: 'fileIn/Out' stamp: 'sw 3/12/2002 19:34'!
viewContents: fullFileName
	"Open the decompressed contents of the .gz file with the given name.  This method is only required for the registering-file-list of Squeak 3.3a and beyond, but does no harm in an earlier system"

	(FileStream readOnlyFileNamed: fullFileName) ifNotNilDo:
		[:aStream | aStream viewGZipContents]! !


GZipReadStream initialize!
