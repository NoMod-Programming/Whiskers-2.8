ArrayedCollection variableByteSubclass: #ByteArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Arrayed'!
!ByteArray commentStamp: '<historical>' prior: 0!
I represent an ArrayedCollection whose elements are integers between 0 and 255.
!


!ByteArray methodsFor: 'accessing' stamp: 'sma 4/22/2000 17:47'!
atAllPut: value
	"Fill the receiver with the given value"

	<primitive: 145>
	super atAllPut: value! !

!ByteArray methodsFor: 'accessing' stamp: 'ar 12/5/1998 14:52'!
byteAt: index
	<primitive: 60>
	^self at: index! !

!ByteArray methodsFor: 'accessing' stamp: 'ar 12/5/1998 14:52'!
byteAt: index put: value
	<primitive: 61>
	^self at: index put: value! !

!ByteArray methodsFor: 'accessing' stamp: 'tk 3/13/2000 14:46'!
bytesPerElement
	"Number of bytes in each item.  This multiplied by (self size)*8 gives the number of bits stored."
	^ 1! !

!ByteArray methodsFor: 'accessing' stamp: 'EMP 11/20/2015 11:51'!
lastIndexOfPKSignature: aSignature
	"Answer the last index in me where aSignature (4 bytes long) occurs, or 0 if not found"
	| a b c d |
	a := aSignature first.
	b := aSignature second.
	c := aSignature third.
	d := aSignature fourth.
	(self size - 3) to: 1 by: -1 do: [ :i |
		(((self at: i) = a)
			and: [ ((self at: i + 1) = b)
				and: [ ((self at: i + 2) = c)
					and: [ ((self at: i + 3) = d) ]]])
						ifTrue: [ ^i ]
	].
	^0! !


!ByteArray methodsFor: 'converting' stamp: 'sma 5/12/2000 17:35'!
asByteArray
	^ self! !

!ByteArray methodsFor: 'converting'!
asString
	"Convert to a String with Characters for each byte.
	Fast code uses primitive that avoids character conversion"

	^ (String new: self size) replaceFrom: 1 to: self size with: self! !


!ByteArray methodsFor: 'private'!
defaultElement

	^0! !

!ByteArray methodsFor: 'private'!
replaceFrom: start to: stop with: replacement startingAt: repStart 
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."
	<primitive: 105>
	super replaceFrom: start to: stop with: replacement startingAt: repStart! !


!ByteArray methodsFor: 'comparing' stamp: 'jm 8/3/1999 09:33'!
hash
	"Make sure that equal (=) ByteArrays hash equally."

	self size = 0 ifTrue: [^ 2001].
	^ ((self at: 1) bitShift: 8) + (self at: self size)
! !
