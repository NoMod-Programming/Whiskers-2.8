ZipArchiveMember subclass: #ZipFileMember
	instanceVariableNames: 'externalFileName stream localHeaderRelativeOffset dataOffset '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Compression-Archives'!
!ZipFileMember commentStamp: '<historical>' prior: 0!
ZipNewFileMember instances are used to represent files that have been read from a ZipArchive.
Their data stays in the file on disk, so the original Zip file cannot be directly overwritten.!


!ZipFileMember methodsFor: 'initialization' stamp: 'ar 3/2/2001 18:46'!
close
	stream ifNotNil:[stream close].! !

!ZipFileMember methodsFor: 'initialization' stamp: 'nk 2/22/2001 16:52'!
initialize
	super initialize.
	crc32 := 0.
	localHeaderRelativeOffset := 0.
	dataOffset := 0.! !

!ZipFileMember methodsFor: 'initialization' stamp: 'nk 2/22/2001 16:51'!
stream: aStream externalFileName: aFileName
	stream := aStream.
	externalFileName := aFileName.! !


!ZipFileMember methodsFor: 'testing' stamp: 'nk 2/21/2001 21:52'!
looksLikeDirectory
	^fileName last = $/
		and: [ uncompressedSize = 0 ]! !

!ZipFileMember methodsFor: 'testing' stamp: 'nk 2/24/2001 14:07'!
usesFileNamed: aFileName
	"Do I require aFileName? That is, do I care if it's clobbered?"
	^(FileDirectory default fullNameFor: externalFileName) = (FileDirectory default fullNameFor: aFileName)! !


!ZipFileMember methodsFor: 'private' stamp: 'nk 2/21/2001 21:55'!
asDirectory
	^ZipDirectoryMember new copyFrom: self! !


!ZipFileMember methodsFor: 'private-reading' stamp: 'nk 11/11/2002 21:46'!
canonicalizeFileName
	"For security reasons, make all paths relative and remove any ../ portions"

	[fileName beginsWith: '/'] whileTrue: [fileName := fileName allButFirst].
	fileName := fileName copyReplaceAll: '../' with: ''! !

!ZipFileMember methodsFor: 'private-reading' stamp: 'yo 12/19/2003 21:15'!
readCentralDirectoryFileHeaderFrom: aStream
	"Assumes aStream positioned after signature"

	| fileNameLength extraFieldLength fileCommentLength |

	versionMadeBy := aStream nextLittleEndianNumber: 1.
	fileAttributeFormat := aStream nextLittleEndianNumber: 1.

	versionNeededToExtract := aStream nextLittleEndianNumber: 2.
	bitFlag := aStream nextLittleEndianNumber: 2.
	compressionMethod := aStream nextLittleEndianNumber: 2.

	lastModFileDateTime := aStream nextLittleEndianNumber: 4.
	crc32 := aStream nextLittleEndianNumber: 4.
	compressedSize := aStream nextLittleEndianNumber: 4.
	uncompressedSize := aStream nextLittleEndianNumber: 4.

	fileNameLength := aStream nextLittleEndianNumber: 2.
	extraFieldLength := aStream nextLittleEndianNumber: 2.
	fileCommentLength := aStream nextLittleEndianNumber: 2.
	aStream nextLittleEndianNumber: 2. 	"disk number start"
	internalFileAttributes := aStream nextLittleEndianNumber: 2.

	externalFileAttributes := aStream nextLittleEndianNumber: 4.
	localHeaderRelativeOffset := aStream nextLittleEndianNumber: 4.

	fileName := (aStream next: fileNameLength) asString asSqueakPathName.
	cdExtraField := (aStream next: extraFieldLength) asByteArray asString.
	fileComment := (aStream next: fileCommentLength) asString convertFromSystemString.

	self desiredCompressionMethod: compressionMethod! !

!ZipFileMember methodsFor: 'private-reading' stamp: 'nk 11/11/2002 21:48'!
readFrom: aStream 
	"assumes aStream positioned after CD header; leaves stream positioned after my CD entry"

	self readCentralDirectoryFileHeaderFrom: aStream.
	self readLocalDirectoryFileHeaderFrom: aStream.
	self endRead.
	self canonicalizeFileName.
! !

!ZipFileMember methodsFor: 'private-reading' stamp: 'EMP 11/20/2015 12:43'!
readLocalDirectoryFileHeaderFrom: aStream 
	"Positions stream as necessary. Will return stream to its original position"

	| fileNameLength extraFieldLength xcrc32 xcompressedSize xuncompressedSize sig oldPos |

	oldPos := aStream position.

	aStream position: localHeaderRelativeOffset.

	sig := aStream next: 4.
	sig = (ZipFileConstants associationAt: #LocalFileHeaderSignature) asByteArray
		ifFalse: [ aStream position: oldPos.
				^self error: 'bad LH signature at ', localHeaderRelativeOffset printStringHex ].

	versionNeededToExtract := aStream nextLittleEndianNumber: 2.
	bitFlag := aStream nextLittleEndianNumber: 2.
	compressionMethod := aStream nextLittleEndianNumber: 2.

	lastModFileDateTime := aStream nextLittleEndianNumber: 4.
	xcrc32 := aStream nextLittleEndianNumber: 4.
	xcompressedSize := aStream nextLittleEndianNumber: 4.
	xuncompressedSize := aStream nextLittleEndianNumber: 4.

	fileNameLength := aStream nextLittleEndianNumber: 2.
	extraFieldLength := aStream nextLittleEndianNumber: 2.

	fileName := (aStream next: fileNameLength) asString asSqueakPathName.
	localExtraField := (aStream next: extraFieldLength) asByteArray.

	dataOffset := aStream position.

	"Don't trash these fields if we already got them from the central directory"
	self hasDataDescriptor ifFalse: [
		crc32 := xcrc32.
		compressedSize := xcompressedSize.
		uncompressedSize := xuncompressedSize.
	].

	aStream position: oldPos.! !

!ZipFileMember methodsFor: 'private-reading' stamp: 'nk 2/22/2001 20:46'!
readRawChunk: n
	^stream next: n! !

!ZipFileMember methodsFor: 'private-reading' stamp: 'nk 2/23/2001 09:56'!
rewindData
	super rewindData.
	(stream isNil or: [ stream closed ])
		ifTrue: [ self error: 'stream missing or closed' ].
	stream position: (localHeaderRelativeOffset + 4).
	self skipLocalDirectoryFileHeaderFrom: stream.! !

!ZipFileMember methodsFor: 'private-reading' stamp: 'nk 2/23/2001 09:56'!
skipLocalDirectoryFileHeaderFrom: aStream 
	"Assumes that stream is positioned after signature."

	|  extraFieldLength fileNameLength |
	aStream next: 22.
	fileNameLength := aStream nextLittleEndianNumber: 2.
	extraFieldLength := aStream nextLittleEndianNumber: 2.
	aStream next: fileNameLength.
	aStream next: extraFieldLength.
	dataOffset := aStream position.
! !


!ZipFileMember methodsFor: 'private-writing' stamp: 'nk 2/23/2001 11:04'!
copyDataTo: aStream

	self copyRawDataTo: aStream.! !

!ZipFileMember methodsFor: 'private-writing' stamp: 'nk 3/27/2002 11:20'!
localHeaderRelativeOffset
	^localHeaderRelativeOffset! !

!ZipFileMember methodsFor: 'private-writing' stamp: 'nk 3/7/2004 16:08'!
uncompressDataTo: aStream

	| decoder buffer chunkSize crcErrorMessage |
	decoder := ZipReadStream on: stream.
	decoder expectedCrc: self crc32.
	buffer := ByteArray new: (32768 min: readDataRemaining).
	crcErrorMessage := nil.

	[[ readDataRemaining > 0 ] whileTrue: [
		chunkSize := 32768 min: readDataRemaining.
		buffer := decoder next: chunkSize into: buffer startingAt: 1.
		aStream next: chunkSize putAll: buffer startingAt: 1.
		readDataRemaining := readDataRemaining - chunkSize.
	]] on: CRCError do: [ :ex | crcErrorMessage := ex messageText. ex proceed ].

	crcErrorMessage ifNotNil: [ self isCorrupt: true. CRCError signal: crcErrorMessage ]

! !

!ZipFileMember methodsFor: 'private-writing' stamp: 'nk 2/24/2001 17:52'!
uncompressDataTo: aStream from: start to: finish

	| decoder buffer chunkSize |
	decoder := FastInflateStream on: stream.
	readDataRemaining := readDataRemaining min: finish - start + 1.
	buffer := ByteArray new: (32768 min: readDataRemaining).
	decoder next: start - 1.

	[ readDataRemaining > 0 ] whileTrue: [
		chunkSize := 32768 min: readDataRemaining.
		buffer := decoder next: chunkSize into: buffer startingAt: 1.
		aStream next: chunkSize putAll: buffer startingAt: 1.
		readDataRemaining := readDataRemaining - chunkSize.
	].
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ZipFileMember class
	instanceVariableNames: ''!

!ZipFileMember class methodsFor: 'as yet unclassified' stamp: 'nk 2/22/2001 17:31'!
newFrom: stream named: fileName
	^(self new) stream: stream externalFileName: fileName! !
