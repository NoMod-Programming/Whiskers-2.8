ReadWriteStream subclass: #RWBinaryOrTextStream
	instanceVariableNames: 'isBinary '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Streams'!
!RWBinaryOrTextStream commentStamp: '<historical>' prior: 0!
A simulation of a FileStream, but living totally in memory.  Hold the contents of a file or web page from the network.  Can then fileIn like a normal FileStream.

Need to be able to switch between binary and text, as a FileStream does, without recopying the whole collection.  Convert to binary upon input and output.  Always keep as text internally.!


!RWBinaryOrTextStream methodsFor: 'as yet unclassified' stamp: 'tk 6/25/97 13:22'!
ascii
	isBinary _ false! !

!RWBinaryOrTextStream methodsFor: 'as yet unclassified' stamp: 'tk 6/20/97 19:46'!
binary
	isBinary _ true! !

!RWBinaryOrTextStream methodsFor: 'as yet unclassified' stamp: 'tk 6/21/97 12:49'!
contents
	"Answer with a copy of my collection from 1 to readLimit."

	| newArray |
	isBinary ifFalse: [^ super contents].	"String"
	readLimit _ readLimit max: position.
	newArray _ ByteArray new: readLimit.
	^ newArray replaceFrom: 1
		to: readLimit
		with: collection
		startingAt: 1.! !

!RWBinaryOrTextStream methodsFor: 'as yet unclassified' stamp: 'jm 11/4/97 08:25'!
contentsOfEntireFile
	"For compatibility with file streams."

	^ self contents! !

!RWBinaryOrTextStream methodsFor: 'as yet unclassified' stamp: 'tk 6/20/97 19:47'!
isBinary
	^ isBinary! !

!RWBinaryOrTextStream methodsFor: 'as yet unclassified' stamp: 'tk 12/13/97 13:07'!
next

	| byte |
	^ isBinary 
			ifTrue: [byte _ super next.
				 byte ifNil: [nil] ifNotNil: [byte asciiValue]]
			ifFalse: [super next].
! !

!RWBinaryOrTextStream methodsFor: 'as yet unclassified' stamp: 'tk 2/7/2000 15:34'!
next: anInteger 
	"Answer the next anInteger elements of my collection. Must override to get class right."

	| newArray |
	newArray _ (isBinary ifTrue: [ByteArray] ifFalse: [String]) new: anInteger.
	^ self nextInto: newArray! !

!RWBinaryOrTextStream methodsFor: 'as yet unclassified' stamp: 'tk 6/20/97 07:38'!
nextPut: charOrByte

	super nextPut: charOrByte asCharacter! !

!RWBinaryOrTextStream methodsFor: 'as yet unclassified' stamp: 'EMP 4/15/2016 14:40'!
peekLast
	^ position > 0
		ifTrue: [self isBinary
				ifTrue: [(collection at: position) asInteger]
				ifFalse: [(collection at: position) asCharacter]]! !

!RWBinaryOrTextStream methodsFor: 'as yet unclassified' stamp: 'tk 6/21/97 13:04'!
reset
	"Set the receiver's position to the beginning of the sequence of objects."

	super reset.
	isBinary ifNil: [isBinary _ false].
	collection class == ByteArray ifTrue: ["Store as String and convert as needed."
		collection _ collection asString.
		isBinary _ true].
! !

!RWBinaryOrTextStream methodsFor: 'as yet unclassified' stamp: 'tk 10/1/1998 11:54'!
setFileTypeToObject
	"do nothing.  We don't have a file type"! !

!RWBinaryOrTextStream methodsFor: 'as yet unclassified' stamp: 'tk 6/20/97 19:47'!
text
	isBinary _ false! !
