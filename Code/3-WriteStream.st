PositionableStream subclass: #WriteStream
	instanceVariableNames: 'writeLimit '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Streams'!
!WriteStream commentStamp: '<historical>' prior: 0!
I represent an accessor for a sequence of objects that can only store objects in the sequence.!


!WriteStream methodsFor: 'accessing'!
contents

	readLimit _ readLimit max: position.
	^collection copyFrom: 1 to: position! !

!WriteStream methodsFor: 'accessing'!
next

	self shouldNotImplement! !

!WriteStream methodsFor: 'accessing' stamp: 'di 3/8/1999 09:02'!
nextPut: anObject 
	"Primitive. Insert the argument at the next position in the Stream
	represented by the receiver. Fail if the collection of this stream is not an
	Array or a String. Fail if the stream is positioned at its end, or if the
	position is out of bounds in the collection. Fail if the argument is not
	of the right type for the collection. Optional. See Object documentation
	whatIsAPrimitive."

	<primitive: 66>
	position >= writeLimit
		ifTrue: [^ self pastEndPut: anObject]
		ifFalse: 
			[position _ position + 1.
			^collection at: position put: anObject]! !

!WriteStream methodsFor: 'accessing' stamp: 'ls 8/20/1998 10:19'!
nextPutAll: aCollection
	| newEnd |

	collection class == aCollection class ifFalse: [
		^super nextPutAll: aCollection ].

	newEnd _ position + aCollection size.
	newEnd > writeLimit ifTrue: [
		collection _ collection,
			(collection species new: (newEnd - writeLimit + (collection size max: 20)) ).
		writeLimit _ collection size ].

	collection replaceFrom: position+1 to: newEnd  with: aCollection.
	position _ newEnd.! !

!WriteStream methodsFor: 'accessing' stamp: 'jm 3/23/2007 12:05'!
nextPutString: aString
	"Allows storing of a string onto a binary stream."

	collection class == aString class
		ifTrue: [self nextPutAll: aString]
		ifFalse: [self nextPutAll: aString asByteArray].
! !

!WriteStream methodsFor: 'accessing' stamp: 'EMP 4/15/2016 14:41'!
peekLast
	^ position > 0
		ifTrue: [collection at: position]! !

!WriteStream methodsFor: 'accessing'!
size

	^readLimit _ readLimit max: position! !


!WriteStream methodsFor: 'positioning'!
position: anInteger 
	"Refer to the comment in PositionableStream|position:."

	readLimit _ readLimit max: position.
	super position: anInteger! !

!WriteStream methodsFor: 'positioning'!
reset 
	"Refer to the comment in PositionableStream|reset."

	readLimit _ readLimit max: position.
	position _ 0! !

!WriteStream methodsFor: 'positioning' stamp: 'ar 11/12/1998 21:27'!
resetToStart
	readLimit _ position _ 0.! !


!WriteStream methodsFor: 'character writing'!
cr
	"Append a return character to the receiver."

	self nextPut: Character cr! !

!WriteStream methodsFor: 'character writing' stamp: 'jm 12/9/2005 12:35'!
crlf
	"Append return and linefeed characters to the receiver."

	self nextPutAll: String crlf.
! !

!WriteStream methodsFor: 'character writing'!
crtab
	"Append a return character, followed by a single tab character, to the 
	receiver."

	self nextPut: Character cr.
	self nextPut: Character tab! !

!WriteStream methodsFor: 'character writing'!
crtab: anInteger 
	"Append a return character, followed by anInteger tab characters, to the 
	receiver."

	self nextPut: Character cr.
	anInteger timesRepeat: [self nextPut: Character tab]! !

!WriteStream methodsFor: 'character writing'!
space
	"Append a space character to the receiver."

	self nextPut: Character space! !

!WriteStream methodsFor: 'character writing'!
tab
	"Append a tab character to the receiver."

	self nextPut: Character tab! !

!WriteStream methodsFor: 'character writing' stamp: 'sr 4/8/2000 01:49'!
tab: anInteger 
	"Append anInteger tab characters to the receiver."

	anInteger timesRepeat: [self nextPut: Character tab]! !


!WriteStream methodsFor: 'fileIn/Out'!
nextChunkPut: aString
	"Append the argument, aString, to the receiver, doubling embedded terminators."

	| i remainder terminator |
	terminator _ $!!.
	remainder _ aString.
	[(i _ remainder indexOf: terminator) = 0] whileFalse:
		[self nextPutAll: (remainder copyFrom: 1 to: i).
		self nextPut: terminator.  "double imbedded terminators"
		remainder _ remainder copyFrom: i+1 to: remainder size].
	self nextPutAll: remainder; nextPut: terminator! !

!WriteStream methodsFor: 'fileIn/Out' stamp: 'di 2/2/98 13:03'!
nextChunkPutWithStyle: aStringOrText
	"Append the argument, aText, to the receiver, doubling embedded terminators.  Put out one chunk for the string and one for the style runs.  Mark the style with ]style[."

	aStringOrText class == String ifTrue: [^ self nextChunkPut: aStringOrText].
	aStringOrText runs coalesce.
	aStringOrText unembellished ifTrue: [^ self nextChunkPut: aStringOrText asString].

	self nextChunkPut: aStringOrText asString.
	self cr; nextPutAll: ']style['.
	self nextChunkPut: 
		(String streamContents: [:strm | 
			aStringOrText runs writeScanOn: strm]).

! !


!WriteStream methodsFor: 'printing'!
store: anObject 
	"Have anObject print on the receiver for purposes of rereading."

	anObject storeOn: self! !


!WriteStream methodsFor: 'private' stamp: 'di 11/18/1999 22:55'!
braceArray
	"This method is used in compilation of brace constructs.
	It MUST NOT be deleted or altered."

	^ collection! !

!WriteStream methodsFor: 'private' stamp: 'di 11/18/1999 22:50'!
braceArray: anArray
	"This method is used in compilation of brace constructs.
	It MUST NOT be deleted or altered."

	collection _ anArray.
	position _ 0.
	readLimit _ 0.
	writeLimit _ anArray size.! !

!WriteStream methodsFor: 'private'!
on: aCollection

	super on: aCollection.
	readLimit _ 0.
	writeLimit _ aCollection size! !

!WriteStream methodsFor: 'private'!
on: aCollection from: firstIndex to: lastIndex

	| len |
	collection _ aCollection.
	readLimit _ 
		writeLimit _ lastIndex > (len _ collection size)
						ifTrue: [len]
						ifFalse: [lastIndex].
	position _ firstIndex <= 1
				ifTrue: [0]
				ifFalse: [firstIndex - 1]! !

!WriteStream methodsFor: 'private' stamp: 'di 6/20/97 08:39'!
pastEndPut: anObject
	collection _ collection ,
		(collection class new: ((collection size max: 20) min: 20000)).
	writeLimit _ collection size.
	collection at: (position _ position + 1) put: anObject! !

!WriteStream methodsFor: 'private'!
with: aCollection

	super on: aCollection.
	position _ readLimit _ writeLimit _ aCollection size! !

!WriteStream methodsFor: 'private'!
withAttribute: att do: strmBlock 
	"No-op here is overriden in TextStream for font emphasis"
	^ strmBlock value! !

!WriteStream methodsFor: 'private' stamp: 'djp 11/6/1999 23:15'!
withAttributes: attributes do: strmBlock 
	"No-op here is overriden in TextStream for font emphasis"
	^ strmBlock value! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WriteStream class
	instanceVariableNames: ''!

!WriteStream class methodsFor: 'instance creation'!
on: aCollection from: firstIndex to: lastIndex 
	"Answer an instance of me on a copy of the argument, aCollection, 
	determined by the indices firstIndex and lastIndex. Position the instance 
	at the beginning of the collection."

	^self basicNew
		on: aCollection
		from: firstIndex
		to: lastIndex! !

!WriteStream class methodsFor: 'instance creation'!
with: aCollection 
	"Answer an instance of me on the argument, aCollection, positioned to 
	store objects at the end of aCollection."

	^self basicNew with: aCollection! !

!WriteStream class methodsFor: 'instance creation'!
with: aCollection from: firstIndex to: lastIndex 
	"Answer an instance of me on the subcollection of the argument, 
	aCollection, determined by the indices firstIndex and lastIndex. Position 
	the instance to store at the end of the subcollection."

	^self basicNew with: (aCollection copyFrom: firstIndex to: lastIndex)! !
