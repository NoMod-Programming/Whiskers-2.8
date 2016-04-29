String variableByteSubclass: #UTF8
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Translation'!
!UTF8 commentStamp: '<historical>' prior: 0!
I represent a Unicode string encoded as a sequence of 8-bit bytes using UTF-8 encoding.
!


!UTF8 methodsFor: 'accessing' stamp: 'jm 9/12/2007 09:13'!
atAllPut: value
	"Fill the receiver with the given value."

	<primitive: 145>
	super atAllPut: value.
! !

!UTF8 methodsFor: 'accessing' stamp: 'jm 9/12/2007 09:13'!
byteAt: index

	<primitive: 60>
	^ self at: index
! !

!UTF8 methodsFor: 'accessing' stamp: 'jm 9/12/2007 09:13'!
byteAt: index put: value

	<primitive: 61>
	^ self at: index put: value
! !

!UTF8 methodsFor: 'accessing' stamp: 'jm 6/3/2008 12:58'!
isMacRoman
	"Answer true if I contain only characters from Squeak's Mac Roman character set."

	| decoder uChar |
	decoder _ UTF8Decoder new on: self.
 	[(uChar _ decoder next) notNil] whileTrue: [
		(UTF32 macRomanFor: uChar) = 127 ifTrue: [^ false]].
	^ true
! !

!UTF8 methodsFor: 'accessing' stamp: 'EMP 4/16/2016 11:33'!
isString
	^ true! !

!UTF8 methodsFor: 'accessing' stamp: 'jm 6/2/2008 16:01'!
isUnicode
	"Answer true if I represent a Unicode string."

	^ true
! !


!UTF8 methodsFor: 'comparing' stamp: 'jm 6/12/2008 11:12'!
= aStringOrUTF8 
	"Answer whether the receiver has the exact same contents as the argument."

	(aStringOrUTF8 isKindOf: String) ifFalse: [^ false].

	^ (self compare: self with: aStringOrUTF8 collated: AsciiOrder) = 2! !


!UTF8 methodsFor: 'converting' stamp: 'jm 9/12/2007 09:14'!
asByteArray
	"Convert to a ByteArray."

	^ (ByteArray new: self size) replaceFrom: 1 to: self size with: self
! !

!UTF8 methodsFor: 'converting' stamp: 'jm 10/22/2007 09:16'!
asMacRoman
	"Answer the receiver as a String encoded as well as possible in the MacRoman character set. This transformation loses information if the string contains characters outside of the MacRoman character set."

	^ self asUTF32 asMacRoman
! !

!UTF8 methodsFor: 'converting' stamp: 'jm 9/13/2007 18:21'!
asUTF32
	"Answer this Unicode string encoded as UTF-32."

	| s out n |
	s _ UTF8Decoder new on: self.
	out _ WriteStream on: (UTF32 new: self size).
 	[(n _ s next) notNil] whileTrue: [out nextPut: n].
	^ out contents
! !

!UTF8 methodsFor: 'converting' stamp: 'jm 1/24/2008 11:45'!
asUTF8

	^ self
! !


!UTF8 methodsFor: 'printing' stamp: 'jm 6/10/2008 15:25'!
printOn: aStream

	aStream nextPutAll: 'UTF8['.
	self isMacRoman
		ifTrue: [aStream nextPut:$'; nextPutAll: self asMacRoman; nextPut: $']
		ifFalse: [aStream nextPutAll: self size printString].
	aStream nextPutAll: ']'.

! !


!UTF8 methodsFor: 'private' stamp: 'jm 9/12/2007 09:15'!
replaceFrom: start to: stop with: replacement startingAt: repStart
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 105>
	super replaceFrom: start to: stop with: replacement startingAt: repStart.
! !

!UTF8 methodsFor: 'private' stamp: 'jm 6/12/2008 10:09'!
species

	^ UTF8
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

UTF8 class
	instanceVariableNames: ''!

!UTF8 class methodsFor: 'utilities' stamp: 'jm 5/1/2009 14:44'!
byteOrderMark
	"Return the UTF8 byte order mark. This is a non-printing 3-byte Unicode character sometimes used to indicate that a string is encoded as UTF8."

	^ UTF8 withAll: #(239 187 191) asByteArray asString
! !

!UTF8 class methodsFor: 'utilities' stamp: 'jm 9/13/2007 18:12'!
encode: n on: aStream
	"Append the UTF-8 encoding of the given integer onto the given stream."

	n < 0 ifTrue: [^ self error: 'UTF-8 cannot represent: ', n printString, ' (negative)'].
	n < 128 ifTrue: [aStream nextPut: n. ^ self].
	n < 2048 ifTrue: [
		aStream nextPut: (2r11000000 bitOr: (n bitShift: -6)).
		aStream nextPut: (2r10000000 bitOr: (n bitAnd: 2r111111)).
		^ self].
	n < 65536 ifTrue: [
		aStream nextPut: (2r11100000 bitOr: (n bitShift: -12)).
		aStream nextPut: (2r10000000 bitOr: ((n bitShift: -6) bitAnd: 2r111111)).
		aStream nextPut: (2r10000000 bitOr: (n bitAnd: 2r111111)).
		^ self].
	n < 16r110000 ifTrue: [
		aStream nextPut: (2r11110000 bitOr: (n bitShift: -18)).
		aStream nextPut: (2r10000000 bitOr: ((n bitShift: -12) bitAnd: 2r111111)).
		aStream nextPut: (2r10000000 bitOr: ((n bitShift: -6) bitAnd: 2r111111)).
		aStream nextPut: (2r10000000 bitOr: (n bitAnd: 2r111111)).
		^ self].

	self error: 'UTF-8 cannot represent: ', n printString, ' (out of range)'
! !

!UTF8 class methodsFor: 'utilities' stamp: 'jm 6/12/2008 04:18'!
from: aCollection
	"Answer a new UTF-8 string resulting from encoding the given sequence of positive integers (e.g. a UTF32 object or an Array of Unicode codepoints)."
	"self from: #(1 2 3 1000)"

	| out |
	out _ WriteStream on: (ByteArray new: (4 * aCollection size)).
	aCollection do: [:n | self encode: n on: out].
	^ UTF8 withAll: out contents
! !

!UTF8 class methodsFor: 'utilities' stamp: 'jm 8/11/2008 08:05'!
fromMacRoman: aString
	"Convert the given MacRoman-encoded String into UTF-8."
	"(UTF8 fromMacRoman: (0 to: 255) asByteArray asString) asUTF32"

	| macRomanToUnicode out n |
	macRomanToUnicode _ #(196 197 199 201 209 214 220 225 224 226 228 227 229 231 233 232 234 235 237 236 238 239 241 243 242 244 246 245 250 249 251 252 8224 176 162 163 167 8226 182 223 174 169 8482 180 168 8800 198 216 8734 177 8804 8805 165 181 8706 8721 8719 960 8747 170 186 937 230 248 191 161 172 8730 402 8776 8710 171 187 8230 160 192 195 213 338 339 8211 8212 8220 8221 8216 8217 247 9674 255 376 8260 8364 8249 8250 64257 64258 8225 183 8218 8222 8240 194 202 193 203 200 205 206 207 204 211 212 63743 210 218 219 217 305 710 732 175 728 729 730 184 733 731 711).

	aString isUnicode ifTrue: [^ aString asUTF8].

	out _ WriteStream on: (ByteArray new: (4 * aString size)).
	aString do: [:ch |
		n _ ch asciiValue.
		n > 127 ifTrue: [n _ macRomanToUnicode at: (n - 127)].
		self encode: n on: out].
	^ UTF8 withAll: out contents
! !
