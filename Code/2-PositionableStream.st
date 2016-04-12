Stream subclass: #PositionableStream
	instanceVariableNames: 'collection position readLimit '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Streams'!
!PositionableStream commentStamp: '<historical>' prior: 0!
I represent an accessor for a sequence of objects (a collection) that are externally named by indices so that the point of access can be repositioned. I am abstract in that I do not implement the messages next and nextPut: which are inherited from my superclass Stream.!


!PositionableStream methodsFor: 'accessing'!
contents
	"Answer with a copy of my collection from 1 to readLimit."

	^collection copyFrom: 1 to: readLimit! !

!PositionableStream methodsFor: 'accessing' stamp: 'sw 3/10/98 13:55'!
contentsOfEntireFile
	"For non-file streams"
	^ self contents! !

!PositionableStream methodsFor: 'accessing'!
last
	"Return the final element in the receiver.  Put in at Alan's request.  2/2/96 sw"

	^ collection at: (position - 1)! !

!PositionableStream methodsFor: 'accessing' stamp: 'sw 3/10/98 13:55'!
next: anInteger 
	"Answer the next anInteger elements of my collection. Must override 
	because default uses self contents species, which might involve a large 
	collection."

	| newArray |
	newArray _ collection species new: anInteger.
	1 to: anInteger do: [:index | newArray at: index put: self next].
	^newArray! !

!PositionableStream methodsFor: 'accessing' stamp: 'ar 12/23/1999 14:58'!
next: n into: aCollection
	"Read n objects into the given collection.
	Return aCollection or a partial copy if less than
	n elements have been read."
	^self next: n into: aCollection startingAt: 1! !

!PositionableStream methodsFor: 'accessing' stamp: 'ar 12/23/1999 14:54'!
next: n into: aCollection startingAt: startIndex
	"Read n objects into the given collection. 
	Return aCollection or a partial copy if less than
	n elements have been read."
	| obj |
	0 to: n-1 do:[:i|
		(obj _ self next) == nil ifTrue:[^aCollection copyFrom: 1 to: startIndex+i-1].
		aCollection at: startIndex+i put: obj].
	^aCollection! !

!PositionableStream methodsFor: 'accessing' stamp: 'ar 1/2/2000 15:32'!
next: anInteger putAll: aCollection
	"Store the next anInteger elements from the given collection."
	^self next: anInteger putAll: aCollection startingAt: 1! !

!PositionableStream methodsFor: 'accessing' stamp: 'ar 1/2/2000 15:32'!
next: anInteger putAll: aCollection startingAt: startIndex
	"Store the next anInteger elements from the given collection."
	0 to: anInteger-1 do:[:i|
		self nextPut: (aCollection at: startIndex + i).
	].
	^aCollection! !

!PositionableStream methodsFor: 'accessing' stamp: 'ar 12/23/1999 14:53'!
nextInto: aCollection
	"Read the next elements of the receiver into aCollection.
	Return aCollection or a partial copy if less than aCollection
	size elements have been read."
	^self next: aCollection size into: aCollection startingAt: 1.! !

!PositionableStream methodsFor: 'accessing' stamp: 'EMP 11/20/2015 12:18'!
nextLittleEndianNumber: n 
	"Answer the next n bytes as a positive Integer or LargePositiveInteger, where the bytes are ordered from least significant to most significant."

	| bytes s |
	bytes := self next: n.
	s := 0.
	n to: 1 by: -1 do: [:i | s := (s bitShift: 8) bitOr: (bytes at: i)].
	^ s
! !

!PositionableStream methodsFor: 'accessing' stamp: 'EMP 11/20/2015 12:18'!
nextLittleEndianNumber: n put: value
	"Answer the next n bytes as a positive Integer or LargePositiveInteger, where the bytes are ordered from least significant to most significant."
	| bytes |
	bytes := ByteArray new: n.
	1 to: n do: [: i | bytes at: i put: (value digitAt: i)].
	self nextPutAll: bytes! !

!PositionableStream methodsFor: 'accessing' stamp: 'EMP 11/20/2015 12:18'!
nextNumber: n 
	"Answer the next n bytes as a positive Integer or LargePositiveInteger."
	| s |
	s := 0.
	1 to: n do: 
		[:i | s := (s bitShift: 8) bitOr: self next asInteger].
	^ s normalize! !

!PositionableStream methodsFor: 'accessing' stamp: 'EMP 11/20/2015 12:18'!
nextNumber: n put: v 
	"Append to the receiver the argument, v, which is a positive 
	SmallInteger or a LargePositiveInteger, as the next n bytes.
	Possibly pad with leading zeros."

	1 to: n do: [:i | self nextPut: (v digitAt: n+1-i)].
	^ v
! !

!PositionableStream methodsFor: 'accessing' stamp: 'jm 12/3/2003 08:44'!
nextWordsInto: aBitmap 
	"Fill the word based buffer from my collection. Stored on stream as little-endian. Optimized for speed."

	| blt pos mainX mainY frontX frontY little source |
	(collection class isBytes) ifTrue: [
		"1 to: aBitmap size do: [:index | aBitmap at: index put: (self nextNumber: 4)]"
		little _ Smalltalk isBigEndian not.
		collection basicSize \\ 4 = 0 
			ifTrue: [source _ collection. 
					pos _ self position.
					self skip: aBitmap size * aBitmap bytesPerElement "1, 2, or 4"]
			ifFalse: [source _ self next: aBitmap size * aBitmap bytesPerElement.
						"forced to copy it into a buffer"
					pos _ 0].
		mainX _ pos \\ 4.
		mainY _ pos // 4.	"two Blts required if not word aligned"
		frontX _ 0.
		frontY _ mainY + 1.
		blt _ (BitBlt toForm: (Form new hackBits: aBitmap)) 
					sourceForm: (Form new hackBits: source).
		blt combinationRule: Form over.  "store"
		blt sourceX: mainX; sourceY: mainY; height: aBitmap basicSize; width: 4-mainX.
		blt destX: 0; destY: 0.
		little ifTrue: [blt sourceX: 0; destX: mainX].	"just happens to be this way!!"
		blt copyBits.
		mainX = 0 ifTrue: [^ aBitmap].

		"second piece when not word aligned"
		blt sourceX: frontX; sourceY: frontY; height: aBitmap size; width: mainX.
		blt destX: 4-mainX; destY: 0.
		little ifTrue: [blt sourceX: 4-mainX; destX: frontX].	"draw picture to understand this"
		blt copyBits.
		^ aBitmap].

	^ self next: aBitmap size into: aBitmap startingAt: 1
! !

!PositionableStream methodsFor: 'accessing'!
originalContents
	"Answer the receiver's actual contents collection, NOT a copy.  1/29/96 sw"

	^ collection! !

!PositionableStream methodsFor: 'accessing'!
peek
	"Answer what would be returned if the message next were sent to the 
	receiver. If the receiver is at the end, answer nil."

	| nextObject |
	self atEnd ifTrue: [^nil].
	nextObject _ self next.
	position _ position - 1.
	^nextObject! !

!PositionableStream methodsFor: 'accessing'!
peekFor: anObject 
	"Answer false and do not move over the next element if it is not equal to 
	the argument, anObject, or if the receiver is at the end. Answer true 
	and increment the position for accessing elements, if the next element is 
	equal to anObject."

	| nextObject |
	self atEnd ifTrue: [^false].
	nextObject _ self next.
	"peek for matching element"
	anObject = nextObject ifTrue: [^true].
	"gobble it if found"
	position _ position - 1.
	^false! !

!PositionableStream methodsFor: 'accessing'!
upTo: anObject 
	"Answer a subcollection from the current access position to the 
	occurrence (if any, but not inclusive) of anObject in the receiver. If 
	anObject is not in the collection, answer the entire rest of the receiver."
	| newStream element |
	newStream _ WriteStream on: (collection species new: 100).
	[self atEnd or: [(element _ self next) = anObject]]
		whileFalse: [newStream nextPut: element].
	^newStream contents! !

!PositionableStream methodsFor: 'accessing' stamp: 'tk 7/18/1999 17:10'!
upToAll: aCollection
	"Answer a subcollection from the current access position to the occurrence (if any, but not inclusive) of aCollection. If aCollection is not in the stream, answer the entire rest of the stream."

	| startPos endMatch result |
	startPos _ self position.
	(self match: aCollection) 
		ifTrue: [endMatch _ self position.
			self position: startPos.
			result _ self next: endMatch - startPos - aCollection size.
			self position: endMatch.
			^ result]
		ifFalse: [self position: startPos.
			^ self upToEnd]! !

!PositionableStream methodsFor: 'accessing'!
upToEnd
	"Answer a subcollection from the current access position through the last element of the receiver."

	| newStream el |
	newStream _ WriteStream on: (collection species new: 100).
	[(el _ self next) == nil] whileFalse: [ newStream nextPut: el ].
	^ newStream contents! !


!PositionableStream methodsFor: 'testing'!
atEnd
	"Primitive. Answer whether the receiver can access any more objects.
	Optional. See Object documentation whatIsAPrimitive."

	<primitive: 67>
	^position >= readLimit! !

!PositionableStream methodsFor: 'testing' stamp: 'EMP 3/8/2016 15:15'!
bytesAvailable
	^ self size - self position! !

!PositionableStream methodsFor: 'testing' stamp: 'ar 1/2/2000 17:24'!
isBinary
	"Return true if the receiver is a binary byte stream"
	^collection class == ByteArray! !

!PositionableStream methodsFor: 'testing'!
isEmpty
	"Answer whether the receiver's contents has no elements."

	^position = 0! !


!PositionableStream methodsFor: 'positioning' stamp: 'hmm 10/22/1999 21:18'!
match: subCollection
	"Set the access position of the receiver to be past the next occurrence of the subCollection. Answer whether subCollection is found.  No wildcards, and case does matter."

	| pattern startMatch |
	pattern _ ReadStream on: subCollection.
	startMatch _ nil.
	[pattern atEnd] whileFalse: 
		[self atEnd ifTrue: [^ false].
		(self next) = (pattern next) 
			ifTrue: [pattern position = 1 ifTrue: [startMatch _ self position]]
			ifFalse: [pattern position: 0.
					startMatch ifNotNil: [
						self position: startMatch.
						startMatch _ nil]]].
	^ true

! !

!PositionableStream methodsFor: 'positioning'!
position
	"Answer the current position of accessing the sequence of objects."

	^position! !

!PositionableStream methodsFor: 'positioning'!
position: anInteger 
	"Set the current position for accessing the objects to be anInteger, as long 
	as anInteger is within the bounds of the receiver's contents. If it is not, 
	create an error notification."

	anInteger >= 0 & (anInteger <= readLimit)
		ifTrue: [position _ anInteger]
		ifFalse: [self positionError]! !

!PositionableStream methodsFor: 'positioning'!
reset
	"Set the receiver's position to the beginning of the sequence of objects."

	position _ 0! !

!PositionableStream methodsFor: 'positioning' stamp: 'sw 3/10/98 13:55'!
resetContents
	"Set the position and limits to 0."

	position _ 0.
	readLimit _ 0! !

!PositionableStream methodsFor: 'positioning'!
setToEnd
	"Set the position of the receiver to the end of the sequence of objects."

	position _ readLimit! !

!PositionableStream methodsFor: 'positioning'!
skip: anInteger 
	"Set the receiver's position to be the current position+anInteger. A 
	subclass might choose to be more helpful and select the minimum of the 
	receiver's size and position+anInteger, or the maximum of 1 and 
	position+anInteger for the repositioning."

	self position: position + anInteger! !

!PositionableStream methodsFor: 'positioning'!
skipTo: anObject 
	"Set the access position of the receiver to be past the next occurrence of 
	anObject. Answer whether anObject is found."

	[self atEnd]
		whileFalse: [self next = anObject ifTrue: [^true]].
	^false! !


!PositionableStream methodsFor: 'fileIn/Out'!
command: aString
	"Overridden by HtmlFileStream to append commands directly without translation.  4/5/96 tk"
	"We ignore any HTML commands.  Do nothing"! !

!PositionableStream methodsFor: 'fileIn/Out' stamp: 'di 2/3/98 14:44'!
copyMethodChunkFrom: aStream
	"Copy the next chunk from aStream (must be different from the receiver)."
	| chunk |
	chunk _ aStream nextChunkText.
	chunk runs values size = 1 "Optimize for unembellished text"
		ifTrue: [self nextChunkPut: chunk asString]
		ifFalse: [self nextChunkPutWithStyle: chunk]! !

!PositionableStream methodsFor: 'fileIn/Out' stamp: 'di 6/28/97 09:16'!
copyPreamble: preamble from: aStream
	"Look for a changeStamp for this method by peeking backward.
	Write a method preamble, with that stamp if found."
	| terminator methodPos p last50 stamp i |
	terminator _ $!!.

	"Look back to find stamp in old preamble, such as...
	Polygon methodsFor: 'private' stamp: 'di 6/25/97 21:42' prior: 34957598!! "
	methodPos _ aStream position.
	aStream position: (p _ 0 max: methodPos-50).
	last50 _ aStream next: methodPos - p.
	stamp _ String new.
	(i _ last50 findString: 'stamp:' startingAt: 1) > 0 ifTrue:
		[stamp _ (last50 copyFrom: i+8 to: last50 size) copyUpTo: $'].

	"Write the new preamble, with old stamp if any."
	self cr; nextPut: terminator.
	self nextChunkPut: (String streamContents:
		[:strm |
		strm nextPutAll: preamble.
		stamp size > 0 ifTrue:
			[strm nextPutAll: ' stamp: '; print: stamp]]).
	self cr! !

!PositionableStream methodsFor: 'fileIn/Out'!
header
	"If the stream requires a standard header, override this message.  See HtmlFileStream"! !

!PositionableStream methodsFor: 'fileIn/Out' stamp: 'di 2/3/98 14:29'!
nextChunk
	"Answer the contents of the receiver, up to the next terminator character. Doubled terminators indicate an embedded terminator character."
	| terminator out ch |
	terminator _ $!!.
	out _ WriteStream on: (String new: 1000).
	self skipSeparators.
	[(ch _ self next) == nil] whileFalse: [
		(ch == terminator) ifTrue: [
			self peek == terminator ifTrue: [
				self next.  "skip doubled terminator"
			] ifFalse: [
				^ out contents  "terminator is not doubled; we're done!!"
			].
		].
		out nextPut: ch.
	].
	^ out contents! !

!PositionableStream methodsFor: 'fileIn/Out' stamp: 'di 1/13/98 16:54'!
nextChunkText
	"Deliver the next chunk as a Text.  Decode the following ]style[ chunk if present.  Position at start of next real chunk."
	| string runsRaw strm runs peek |
	"Read the plain text"
	string _ self nextChunk.
	
	"Test for ]style[ tag"
	peek _ self skipSeparatorsAndPeekNext.
	peek = $] ifFalse: [^ string asText].  "no tag"
	(self upTo: $[) = ']style' ifFalse: [^ string asText].  "different tag"

	"Read and decode the style chunk"
	runsRaw _ self nextChunk.	"style encoding"
	strm _ ReadStream on: runsRaw from: 1 to: runsRaw size.
	runs _ RunArray scanFrom: strm.

	^ Text basicNew setString: string setRunsChecking: runs.
! !

!PositionableStream methodsFor: 'fileIn/Out' stamp: 'di 6/13/97 12:00'!
skipSeparators
	[self atEnd]
		whileFalse:
		[self next isSeparator ifFalse: [^ self position: self position-1]]! !

!PositionableStream methodsFor: 'fileIn/Out' stamp: 'di 1/13/98 16:08'!
skipSeparatorsAndPeekNext
	"A special function to make nextChunk fast"
	| peek |
	[self atEnd]
		whileFalse:
		[(peek _ self next) isSeparator
			ifFalse: [self position: self position-1. ^ peek]]! !

!PositionableStream methodsFor: 'fileIn/Out' stamp: 'tk 12/29/97 12:37'!
skipStyleChunk
	"Get to the start of the next chunk that is not a style for the previous chunk"

	| pos |
	pos _ self position.
	self skipSeparators.
	self peek == $] 
		ifTrue: [(self upTo: $[) = ']text' 	"old -- no longer needed"
				"now positioned past the open bracket"
			ifFalse: [self nextChunk]]	"absorb ]style[ and its whole chunk"
				
		ifFalse: [self position: pos]	"leave untouched"
! !

!PositionableStream methodsFor: 'fileIn/Out'!
trailer
	"If the stream requires a standard trailer, override this message.  See HtmlFileStream"! !

!PositionableStream methodsFor: 'fileIn/Out'!
unCommand
	"If this read stream is at a <, then skip up to just after the next >.  For removing html commands."
	| char |
	[self peek = $<] whileTrue: ["begin a block"
		[self atEnd == false and: [self next ~= $>]] whileTrue.
		"absorb characters"
		].
 ! !

!PositionableStream methodsFor: 'fileIn/Out'!
verbatim: aString
	"Do not attempt to translate the characters.  Use to override nextPutAll:"
	^ self nextPutAll: aString! !


!PositionableStream methodsFor: 'data get/put' stamp: 'jm 10/5/2001 12:09'!
boolean
	"Answer the next boolean value from this (binary) stream."

	^ self next ~= 0
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 10/5/2001 12:11'!
boolean: aBoolean
	"Store the given boolean value on this (binary) stream."

	self nextPut: (aBoolean ifTrue: [1] ifFalse: [0]).
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 7/16/2001 14:43'!
int16
	"Answer the next signed, 16-bit integer from this (binary) stream."

	| n |
	n _ self next.
	n _ (n bitShift: 8) + (self next).
	n >= 16r8000 ifTrue: [n _ n - 16r10000].
	^ n
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 7/16/2001 14:44'!
int16: anInteger
	"Store the given signed, 16-bit integer on this (binary) stream."

	| n |
	(anInteger < -16r8000) | (anInteger >= 16r8000)
		ifTrue: [self error: 'outside 16-bit integer range'].

	anInteger < 0
		ifTrue: [n _ 16r10000 + anInteger]
		ifFalse: [n _ anInteger].
	self nextPut: (n digitAt: 2).
	self nextPut: (n digitAt: 1).
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 7/16/2001 15:15'!
int32
	"Answer the next signed, 32-bit integer from this (binary) stream."
	"Details: As a fast check for negative number, check the high bit of the first digit"

	| n firstDigit |
	n _ firstDigit _ self next.
	n _ (n bitShift: 8) + self next.
	n _ (n bitShift: 8) + self next.
	n _ (n bitShift: 8) + self next.
	firstDigit >= 128 ifTrue: [n _ -16r100000000 + n].  "decode negative 32-bit integer"
	^ n
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 7/16/2001 14:46'!
int32: anInteger
	"Store the given signed, 32-bit integer on this (binary) stream."

	| n |
	(anInteger < -16r80000000) | (anInteger >= 16r80000000)
		ifTrue: [self error: 'outside 32-bit integer range'].

	anInteger < 0
		ifTrue: [n _ 16r100000000 + anInteger]
		ifFalse: [n _ anInteger].
	self nextPut: (n digitAt: 4).
	self nextPut: (n digitAt: 3).
	self nextPut: (n digitAt: 2).
	self nextPut: (n digitAt: 1).
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 12/3/2003 14:31'!
littleEndianUint16
	"Answer the next unsigned, little-endian 16-bit integer from this (binary) stream."

	| n |
	n _ self next.
	^ (self next bitShift: 8) + n
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 12/3/2003 14:33'!
littleEndianUint16: anInteger
	"Store the given unsigned, 16-bit integer on this (binary) stream least-significant byte first."

	(anInteger < 0) | (anInteger >= 16r10000)
		ifTrue: [self error: 'outside unsigned 16-bit integer range'].

	self nextPut: (anInteger digitAt: 1).
	self nextPut: (anInteger digitAt: 2).
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 12/3/2003 16:03'!
littleEndianUint24
	"Answer the next unsigned, little-endian 24-bit integer from this (binary) stream."

	| bytes |
	bytes _ self next: 3.
	^ (bytes at: 1) + ((bytes at: 2) bitShift: 8) + ((bytes at: 3) bitShift: 16)
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 12/3/2003 16:02'!
littleEndianUint24: anInteger
	"Store the given unsigned, 24-bit integer on this (binary) stream least-significant byte first."

	(anInteger < 0) | (anInteger >= 16r1000000)
		ifTrue: [self error: 'outside unsigned 24-bit integer range'].

	self nextPut: (anInteger digitAt: 1).
	self nextPut: (anInteger digitAt: 2).
	self nextPut: (anInteger digitAt: 3).

! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 12/3/2003 14:46'!
littleEndianUint32
	"Answer the next unsigned, little-endian 32-bit integer from this (binary) stream."
	"Add the most-signficant byte in last to avoid extra large-integer operations."

	| bytes |
	bytes _ self next: 4.
	^ ((bytes at: 1) + ((bytes at: 2) bitShift: 8) + ((bytes at: 3) bitShift: 16)) +
		((bytes at: 4) bitShift: 24)
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 12/3/2003 14:34'!
littleEndianUint32: anInteger
	"Store the given unsigned, 32-bit integer on this (binary) stream least-significant byte first."

	(anInteger < 0) | (anInteger >= 16r100000000)
		ifTrue: [self error: 'outside unsigned 32-bit integer range'].

	self nextPut: (anInteger digitAt: 1).
	self nextPut: (anInteger digitAt: 2).
	self nextPut: (anInteger digitAt: 3).
	self nextPut: (anInteger digitAt: 4).
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 9/5/2001 07:35'!
string
	"Answer the next string from this (binary) stream."

	| size |
	size _ self uint16.
	^ (self next: size) asString
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 9/5/2001 12:09'!
string: aString
	"Store the given string on this (binary) stream. The string must contain 65535 or fewer characters."

	aString size > 16rFFFF ifTrue: [self error: 'string too long for this format'].
	self uint16: aString size.
	self nextPutAll: aString asByteArray.
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 8/20/2001 07:53'!
uint16
	"Answer the next unsigned, 16-bit integer from this (binary) stream."

	| n |
	n _ self next.
	n _ (n bitShift: 8) + (self next).
	^ n
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 8/20/2001 07:53'!
uint16: anInteger
	"Store the given unsigned, 16-bit integer on this (binary) stream."

	(anInteger < 0) | (anInteger >= 16r10000)
		ifTrue: [self error: 'outside unsigned 16-bit integer range'].

	self nextPut: (anInteger digitAt: 2).
	self nextPut: (anInteger digitAt: 1).
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 8/20/2001 08:07'!
uint24
	"Answer the next unsigned, 24-bit integer from this (binary) stream."

	| n |
	n _ self next.
	n _ (n bitShift: 8) + self next.
	n _ (n bitShift: 8) + self next.
	^ n
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 8/20/2001 08:07'!
uint24: anInteger
	"Store the given unsigned, 24-bit integer on this (binary) stream."

	(anInteger < 0) | (anInteger >= 16r1000000)
		ifTrue: [self error: 'outside unsigned 24-bit integer range'].

	self nextPut: (anInteger digitAt: 3).
	self nextPut: (anInteger digitAt: 2).
	self nextPut: (anInteger digitAt: 1).
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 8/20/2001 07:53'!
uint32
	"Answer the next unsigned, 32-bit integer from this (binary) stream."

	| n |
	n _ self next.
	n _ (n bitShift: 8) + self next.
	n _ (n bitShift: 8) + self next.
	n _ (n bitShift: 8) + self next.
	^ n
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'jm 8/20/2001 07:52'!
uint32: anInteger
	"Store the given unsigned, 32-bit integer on this (binary) stream."

	(anInteger < 0) | (anInteger >= 16r100000000)
		ifTrue: [self error: 'outside unsigned 32-bit integer range'].

	self nextPut: (anInteger digitAt: 4).
	self nextPut: (anInteger digitAt: 3).
	self nextPut: (anInteger digitAt: 2).
	self nextPut: (anInteger digitAt: 1).
! !

!PositionableStream methodsFor: 'data get/put' stamp: 'EMP 3/9/2016 11:57'!
uint4
	"Answer the next unsigned, 4-bit integer from this (binary) stream."

	| n |
	n _ self next.
	n >= 8 ifTrue: [n _ n - 16].
	^ n
! !


!PositionableStream methodsFor: 'private' stamp: 'jm 12/3/2003 16:14'!
on: aCollection

	collection _ aCollection.
	readLimit _ aCollection size.
	position _ 0.
	self reset.
! !

!PositionableStream methodsFor: 'private' stamp: 'jm 12/3/2003 16:14'!
positionError
	"Since I am not necessarily writable, it is up to my subclasses to override position: if expanding the collection is preferrable to giving this error."

	self error: 'Attempt to set the position of a PositionableStream out of bounds'
! !

!PositionableStream methodsFor: 'private' stamp: 'jm 12/3/2003 16:14'!
setFrom: newStart to: newStop

	position _ newStart - 1.
	readLimit _ newStop.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

PositionableStream class
	instanceVariableNames: ''!

!PositionableStream class methodsFor: 'instance creation'!
on: aCollection 
	"Answer an instance of me, streaming over the elements of aCollection."

	^self basicNew on: aCollection! !

!PositionableStream class methodsFor: 'instance creation'!
on: aCollection from: firstIndex to: lastIndex 
	"Answer an instance of me, streaming over the elements of aCollection 
	starting with the element at firstIndex and ending with the one at 
	lastIndex."

	^self basicNew on: (aCollection copyFrom: firstIndex to: lastIndex)! !
