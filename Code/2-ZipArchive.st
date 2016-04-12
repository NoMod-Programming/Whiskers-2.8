Archive subclass: #ZipArchive
	instanceVariableNames: 'centralDirectorySize centralDirectoryOffsetWRTStartingDiskNumber zipFileComment writeCentralDirectoryOffset writeEOCDOffset '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Compression-Archives'!
!ZipArchive commentStamp: '<historical>' prior: 0!
A ZipArchive represents an archive that is read and/or written using the PKZIP file format.

ZipArchive instances know how to read and write such archives; their members are subinstances of ZipArchiveMember.!


!ZipArchive methodsFor: 'accessing' stamp: 'ar 3/1/2006 23:21'!
hasMemberSuchThat: aBlock
	"Answer whether we have a member satisfying the given condition"
	^self members anySatisfy: aBlock! !

!ZipArchive methodsFor: 'accessing' stamp: 'nk 3/27/2002 11:23'!
prependedDataSize
	"Answer the size of whatever data exists before my first member.
	Assumes that I was read from a file or stream (i.e. the first member is a ZipFileMember)"
	^members isEmpty
		ifFalse: [ members first localHeaderRelativeOffset ]
		ifTrue: [ centralDirectoryOffsetWRTStartingDiskNumber ]! !

!ZipArchive methodsFor: 'accessing' stamp: 'nk 2/24/2001 13:44'!
zipFileComment
	^zipFileComment asString! !

!ZipArchive methodsFor: 'accessing' stamp: 'nk 2/24/2001 13:43'!
zipFileComment: aString
	zipFileComment := aString! !


!ZipArchive methodsFor: 'archive operations' stamp: 'ar 3/1/2006 23:21'!
addDeflateString: aString as: aFileName
	"Add a verbatim string under the given file name"
	| mbr |
	mbr := self addString: aString as: aFileName.
	mbr desiredCompressionMethod: CompressionDeflated.
	^mbr! !

!ZipArchive methodsFor: 'archive operations' stamp: 'EMP 12/1/2015 13:50'!
extractAllTo: aDirectory
	"Extract all elements to the given directory"
	Utilities informUserDuring:[:bar|self extractAllTo: aDirectory informing: nil]. "replace nil with bar if you want a loading bar"! !

!ZipArchive methodsFor: 'archive operations' stamp: 'ar 2/6/2004 13:20'!
extractAllTo: aDirectory informing: bar
	"Extract all elements to the given directory"
	^self extractAllTo: aDirectory informing: bar overwrite: false! !

!ZipArchive methodsFor: 'archive operations' stamp: 'ar 2/6/2004 13:20'!
extractAllTo: aDirectory informing: bar overwrite: allOverwrite
	"Extract all elements to the given directory"
	| dir overwriteAll response |
	overwriteAll := allOverwrite.
	self members do:[:entry|
		entry isDirectory ifTrue:[
			bar ifNotNil:[bar value: 'Creating ', entry fileName].
			dir := (entry fileName findTokens:'/') 
					inject: aDirectory into:[:base :part| base directoryNamed: part].
			dir assureExistence.
		].
	].
	self members do:[:entry|
		entry isDirectory ifFalse:[
			bar ifNotNil:[bar value: 'Extracting ', entry fileName].
			response := entry extractInDirectory: aDirectory overwrite: overwriteAll.
			response == #retryWithOverwrite ifTrue:[
				overwriteAll := true.
				response := entry extractInDirectory: aDirectory overwrite: overwriteAll.
			].
			response == #abort ifTrue:[^self].
			response == #failed ifTrue:[
				(self confirm: 'Failed to extract ', entry fileName, '. Proceed?') ifFalse:[^self].
			].
		].
	].
! !

!ZipArchive methodsFor: 'archive operations' stamp: 'EMP 12/1/2015 16:23'!
extractZipTo: aDirectory withDialog: progressDialog
	"Extract all elements to the given directory, updating the progressDialog each time I do everything"
	| dir overwriteAll response totalMembers usedMembers |
	overwriteAll := false.
	totalMembers _ self members size.
	usedMembers _ 0.
	self members do:[:entry|
		entry isDirectory ifTrue:[
			dir := (entry fileName findTokens:'/') 
					inject: aDirectory into:[:base :part| base directoryNamed: part].
			dir assureExistence.
		].
	].
	self members do:[:entry|
		entry isDirectory ifFalse:[
			response := entry extractInDirectory: aDirectory overwrite: overwriteAll.
			response == #retryWithOverwrite ifTrue:[
				overwriteAll := true.
				response := entry extractInDirectory: aDirectory overwrite: overwriteAll.
			].
			response == #abort ifTrue:[^self].
			response == #failed ifTrue:[
				(self confirm: 'Failed to extract ', entry fileName, '. Proceed?') ifFalse:[^self].
			].
	usedMembers _ usedMembers + 1.
	progressDialog percentDone: (((usedMembers * 47) / totalMembers) rounded + 3). "Get the progress bar to 50 percent. The next 50 percent will be spent importing the sprites and what not"
	World displayWorldSafely.
	World doOneCycleNoInput.
		].
	].
! !


!ZipArchive methodsFor: 'initialization' stamp: 'ar 3/2/2001 18:47'!
close
	self members do:[:m| m close].! !

!ZipArchive methodsFor: 'initialization' stamp: 'nk 2/22/2001 17:20'!
initialize
	super initialize.
	writeEOCDOffset := writeCentralDirectoryOffset := 0.
	zipFileComment := ''.
! !


!ZipArchive methodsFor: 'reading' stamp: 'EMP 11/20/2015 11:59'!
readFrom: aStreamOrFileName
	| stream name eocdPosition |
	stream := aStreamOrFileName isStream
		ifTrue: [name := aStreamOrFileName name. aStreamOrFileName]
		ifFalse: [(StandardFileStream readOnlyFileNamedOrNil: (name := aStreamOrFileName))].
	stream ifNil: [name := aStreamOrFileName isoLatinToMac asUTF8. stream := FileStream readOnlyFileNamedOrNil: name. stream ifNil: [^ self error: 'can''t open file']].
	stream binary.
	eocdPosition := self class findEndOfCentralDirectoryFrom: stream.
	eocdPosition <= 0 ifTrue: [self error: 'can''t find EOCD position'].
	self readEndOfCentralDirectoryFrom: stream.
	stream position: eocdPosition - centralDirectorySize.
	self readMembersFrom: stream named: name! !


!ZipArchive methodsFor: 'writing' stamp: 'nk 2/23/2001 10:29'!
writeTo: stream
	stream binary.
	members do: [ :member |
		member writeTo: stream.
		member endRead.
	].
	writeCentralDirectoryOffset := stream position.
	self writeCentralDirectoryTo: stream.
	! !

!ZipArchive methodsFor: 'writing' stamp: 'nk 3/27/2002 10:42'!
writeTo: stream prepending: aString
	stream binary.
	stream nextPutAll: aString.
	members do: [ :member |
		member writeTo: stream.
		member endRead.
	].
	writeCentralDirectoryOffset := stream position.
	self writeCentralDirectoryTo: stream.
	! !

!ZipArchive methodsFor: 'writing' stamp: 'nk 3/27/2002 12:41'!
writeTo: stream prependingFileNamed: aFileName
	| prepended buffer |
	stream binary.
	prepended := StandardFileStream readOnlyFileNamed: aFileName.
	prepended binary.
	buffer := ByteArray new: (prepended size min: 32768).
	[ prepended atEnd ] whileFalse: [ | bytesRead |
		bytesRead := prepended readInto: buffer startingAt: 1 count: buffer size.
		stream next: bytesRead putAll: buffer startingAt: 1
	].
	members do: [ :member |
		member writeTo: stream.
		member endRead.
	].
	writeCentralDirectoryOffset := stream position.
	self writeCentralDirectoryTo: stream.
	! !

!ZipArchive methodsFor: 'writing' stamp: 'nk 3/27/2002 12:45'!
writeToFileNamed: aFileName prepending: aString
	| stream |
	"Catch attempts to overwrite existing zip file"
	(self canWriteToFileNamed: aFileName)
		ifFalse: [ ^self error: (aFileName, ' is needed by one or more members in this archive') ].
	stream := StandardFileStream forceNewFileNamed: aFileName.
	self writeTo: stream prepending: aString.
	stream close.! !

!ZipArchive methodsFor: 'writing' stamp: 'nk 3/27/2002 12:58'!
writeToFileNamed: aFileName prependingFileNamed: anotherFileName
	| stream |
	"Catch attempts to overwrite existing zip file"
	(self canWriteToFileNamed: aFileName)
		ifFalse: [ ^self error: (aFileName, ' is needed by one or more members in this archive') ].
	stream := StandardFileStream forceNewFileNamed: aFileName.
	self writeTo: stream prependingFileNamed: anotherFileName.
	stream close.! !


!ZipArchive methodsFor: 'private' stamp: 'nk 2/21/2001 18:26'!
memberClass
	^ZipArchiveMember! !

!ZipArchive methodsFor: 'private' stamp: 'EMP 11/20/2015 12:42'!
readEndOfCentralDirectoryFrom: aStream
	"Read EOCD, starting from position before signature."
	| signature zipFileCommentLength |
	signature := self readSignatureFrom: aStream.
	signature = (ZipFileConstants associationAt: #EndOfCentralDirectorySignature) ifFalse: [ ^self error: 'bad signature at ', aStream position printString ].

	aStream nextLittleEndianNumber: 2. "# of this disk"
	aStream nextLittleEndianNumber: 2. "# of disk with central dir start"
	aStream nextLittleEndianNumber: 2. "# of entries in central dir on this disk"
	aStream nextLittleEndianNumber: 2. "total # of entries in central dir"
	centralDirectorySize := aStream nextLittleEndianNumber: 4. "size of central directory"
	centralDirectoryOffsetWRTStartingDiskNumber := aStream nextLittleEndianNumber: 4. "offset of start of central directory"
	zipFileCommentLength := aStream nextLittleEndianNumber: 2. "zip file comment"
	zipFileComment := aStream next: zipFileCommentLength.
! !

!ZipArchive methodsFor: 'private' stamp: 'EMP 11/20/2015 12:42'!
readMembersFrom: stream named: fileName
	| newMember signature |
	[
		newMember := self memberClass newFromZipFile: stream named: fileName.
		signature := self readSignatureFrom: stream.
		signature = (ZipFileConstants associationAt: #EndOfCentralDirectorySignature) ifTrue: [ ^self ].
		signature = (ZipFileConstants associationAt: #CentralDirectoryFileHeaderSignature)
			ifFalse: [ self error: 'bad CD signature at ', (stream position - 4) printStringHex ].
		newMember readFrom: stream.
		newMember looksLikeDirectory ifTrue: [ newMember := newMember asDirectory ].
		self addMember: newMember.
	] repeat.! !

!ZipArchive methodsFor: 'private' stamp: 'EMP 11/20/2015 12:41'!
readSignatureFrom: stream
	"Returns next signature from given stream, leaves stream positioned afterwards."

	| signatureData | 
	signatureData := ByteArray new: 4.
	stream next: 4 into: signatureData.
	({ (ZipFileConstants associationAt: #CentralDirectoryFileHeaderSignature) . (ZipFileConstants associationAt: #LocalFileHeaderSignature) . (ZipFileConstants associationAt: #EndOfCentralDirectorySignature) }
		includes: signatureData)
			ifFalse: [ ^self error: 'bad signature ', signatureData asString asHex, ' at position ', (stream position - 4) asString ].
	^signatureData
! !

!ZipArchive methodsFor: 'private' stamp: 'nk 2/21/2001 20:19'!
writeCentralDirectoryTo: aStream
	| offset |
	offset := writeCentralDirectoryOffset.
	members do: [ :member |
		member writeCentralDirectoryFileHeaderTo: aStream.
		offset := offset + member centralDirectoryHeaderSize.
	].
	writeEOCDOffset := offset.
	self writeEndOfCentralDirectoryTo: aStream.

! !

!ZipArchive methodsFor: 'private' stamp: 'nk 2/21/2001 21:02'!
writeEndOfCentralDirectoryTo: aStream

	aStream nextPutAll: EndOfCentralDirectorySignature.
	aStream nextLittleEndianNumber: 2 put: 0. "diskNumber"
	aStream nextLittleEndianNumber: 2 put: 0. "diskNumberWithStartOfCentralDirectory"
	aStream nextLittleEndianNumber: 2 put: members size. "numberOfCentralDirectoriesOnThisDisk"
	aStream nextLittleEndianNumber: 2 put: members size. "numberOfCentralDirectories"
	aStream nextLittleEndianNumber: 4 put: writeEOCDOffset - writeCentralDirectoryOffset. "size of central dir"
	aStream nextLittleEndianNumber: 4 put: writeCentralDirectoryOffset. "offset of central dir"
	aStream nextLittleEndianNumber: 2 put: zipFileComment size. "zip file comment"
	zipFileComment isEmpty ifFalse: [ aStream nextPutAll: zipFileComment ].

! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ZipArchive class
	instanceVariableNames: ''!

!ZipArchive class methodsFor: 'constants' stamp: 'nk 2/22/2001 14:13'!
compressionDeflated
	^CompressionDeflated! !

!ZipArchive class methodsFor: 'constants' stamp: 'nk 2/22/2001 14:12'!
compressionLevelDefault
	^CompressionLevelDefault! !

!ZipArchive class methodsFor: 'constants' stamp: 'nk 2/22/2001 14:12'!
compressionLevelNone
	^CompressionLevelNone ! !

!ZipArchive class methodsFor: 'constants' stamp: 'nk 2/22/2001 14:13'!
compressionStored
	^CompressionStored! !

!ZipArchive class methodsFor: 'constants' stamp: 'EMP 11/20/2015 12:40'!
findEndOfCentralDirectoryFrom: stream
	"Seek in the given stream to the end, then read backwards until we find the
	signature of the central directory record. Leave the file positioned right
	before the signature.

	Answers the file position of the EOCD, or 0 if not found."

	| data fileLength seekOffset pos maxOffset |
	stream setToEnd.
	fileLength := stream position.
	"If the file length is less than 18 for the EOCD length plus 4 for the signature, we have a problem"
	fileLength < 22 ifTrue: [^ self error: 'file is too short'].
	
	seekOffset := 0.
	pos := 0.
	data := ByteArray new: 4100.
	maxOffset := 40960 min: fileLength.	"limit search range to 40K"

	[
		seekOffset := (seekOffset + 4096) min: fileLength.
		stream position: fileLength - seekOffset.
		data := stream next: (4100 min: seekOffset) into: data startingAt: 1.
		pos := data lastIndexOfPKSignature: (ZipFileConstants associationAt: #EndOfCentralDirectorySignature).
		pos = 0 and: [seekOffset < maxOffset]
	] whileTrue.

	^ pos > 0
		ifTrue: [ | newPos | stream position: (newPos := (stream position + pos - seekOffset - 1)). newPos]
		ifFalse: [0]! !

!ZipArchive class methodsFor: 'constants' stamp: 'ar 2/27/2001 13:38'!
validSignatures
	"Return the valid signatures for a zip file"
	^Array 
		with: LocalFileHeaderSignature
		with: CentralDirectoryFileHeaderSignature
		with: EndOfCentralDirectorySignature! !


!ZipArchive class methodsFor: 'file format' stamp: 'EMP 11/20/2015 11:35'!
isZipArchive: aStreamOrFileName
	"Answer whether the given filename represents a valid zip file."

	| stream eocdPosition |
	stream _ aStreamOrFileName isStream
		ifTrue: [aStreamOrFileName]
		ifFalse: [StandardFileStream oldFileNamed: aStreamOrFileName].
	stream ifNil: [^ false].
	"nil happens sometimes somehow"
	stream size < 22 ifTrue: [^ false].
	stream binary.
	eocdPosition _ self findEndOfCentralDirectoryFrom: stream.
	stream ~= aStreamOrFileName ifTrue: [stream close].
	^ eocdPosition > 0! !
