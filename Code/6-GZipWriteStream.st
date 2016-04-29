ZipWriteStream subclass: #GZipWriteStream
	instanceVariableNames: ''
	classVariableNames: 'CrcTable '
	poolDictionaries: 'GZipConstants '
	category: 'Compression-Streams'!

!GZipWriteStream methodsFor: 'initialize-release' stamp: 'ar 12/29/1999 20:07'!
on: aCollection
	crc _ 16rFFFFFFFF.
	crcPosition _ 1.
	bytesWritten _ 0.
	super on: aCollection.
	self writeHeader.
! !

!GZipWriteStream methodsFor: 'initialize-release' stamp: 'ar 1/2/2000 16:36'!
release
	"Write crc and the number of bytes encoded"
	super release.
	self updateCrc.
	crc _ crc bitXor: 16rFFFFFFFF.
	encoder flushBits.
	0 to: 3 do:[:i| encoder nextBytePut: (crc >> (i*8) bitAnd: 255)].
	0 to: 3 do:[:i| encoder nextBytePut: (bytesWritten >> (i*8) bitAnd: 255)].! !

!GZipWriteStream methodsFor: 'initialize-release' stamp: 'nk 2/19/2004 08:31'!
writeFooter
	"Write some footer information for the crc"
	super writeFooter.
	0 to: 3 do:[:i| encoder nextBytePut: (crc >> (i*8) bitAnd: 255)].
	0 to: 3 do:[:i| encoder nextBytePut: (bytesWritten >> (i*8) bitAnd: 255)].! !

!GZipWriteStream methodsFor: 'initialize-release' stamp: 'EMP 4/15/2016 11:15'!
writeHeader
	"Write the GZip header"
	encoder nextBits: 16 put: GZipMagic.
	encoder nextBits: 8 put: GZipDeflated.
	encoder nextBits: 8 put: 0. "No flags"
	encoder nextBits: 32 put: 0. "no time stamp"
	encoder nextBits: 8 put: 0. "No extra flags"
	encoder nextBits: 8 put: 0. "No OS type"
! !


!GZipWriteStream methodsFor: 'private' stamp: 'ar 12/27/1999 17:12'!
moveContentsToFront
	"Need to update crc here"
	self updateCrc.
	super moveContentsToFront.
	crcPosition _ position + 1.! !

!GZipWriteStream methodsFor: 'private' stamp: 'ar 12/29/1999 20:09'!
updateCrc
	crcPosition <= position ifTrue:[
		bytesWritten _ bytesWritten + position - crcPosition + 1.
		crc _ self updateCrc: crc from: crcPosition to: position in: collection.
		crcPosition _ position + 1].! !

!GZipWriteStream methodsFor: 'private' stamp: 'ar 12/27/1999 21:17'!
updateCrc: oldCrc from: start to: stop in: aCollection
	| newCrc |
	<primitive: 'primitiveUpdateGZipCrc32'>
	newCrc _ oldCrc.
	start to: stop do:[:i|
		newCrc _ (CrcTable at: ((newCrc bitXor: (aCollection byteAt: i)) 
				bitAnd: 255) + 1) bitXor: (newCrc bitShift: -8).
	].
	^newCrc! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GZipWriteStream class
	instanceVariableNames: ''!

!GZipWriteStream class methodsFor: 'class initialization' stamp: 'ar 12/30/1999 14:35'!
crcTable
	^CrcTable! !

!GZipWriteStream class methodsFor: 'class initialization' stamp: 'nk 11/26/2002 13:09'!
initialize
	FileList registerFileReader: self! !

!GZipWriteStream class methodsFor: 'class initialization' stamp: 'nk 11/26/2002 13:09'!
unload
	FileList unregisterFileReader: self! !


!GZipWriteStream class methodsFor: 'file list services' stamp: 'sw 11/30/2002 00:11'!
compressFile: fileName
	"Create a compressed file from the file of the given name"

	(FileStream readOnlyFileNamed: fileName) compressFile! !

!GZipWriteStream class methodsFor: 'file list services' stamp: 'st 9/18/2004 23:44'!
fileReaderServicesForFile: fullName suffix: suffix
	"Don't offer to compress already-compressed files
	sjc 3-May 2003-added jpeg extension"

	^({ 'gz' . 'sar' . 'zip' . 'gif' . 'jpg' . 'jpeg'. 'pr'. 'png'} includes: suffix)
		ifTrue: [ #() ]
		ifFalse: [ self services ]
! !

!GZipWriteStream class methodsFor: 'file list services' stamp: 'nk 11/26/2002 13:17'!
serviceCompressFile

	^ FileModifyingSimpleServiceEntry 
				provider: self 
				label: 'compress file'
				selector: #compressFile:
				description: 'compress file using gzip compression, making a new file'! !

!GZipWriteStream class methodsFor: 'file list services' stamp: 'nk 11/26/2002 13:10'!
services
	^ { self serviceCompressFile }! !


GZipWriteStream initialize!
