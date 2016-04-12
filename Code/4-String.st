ArrayedCollection variableByteSubclass: #String
	instanceVariableNames: ''
	classVariableNames: 'AsciiOrder CSLineEnders CSNonSeparators CSSeparators CaseInsensitiveOrder CaseSensitiveOrder HtmlEntities LowercasingTable '
	poolDictionaries: ''
	category: 'Collections-Text'!
!String commentStamp: '<historical>' prior: 0!
A String is an indexed collection of Characters, compactly encoded as 8-bit bytes.

String support a vast array of useful methods, which can best be learned by browsing and trying out examples as you find them in the code.

Here are a few useful methods to look at...
	String match:
	String contractTo:

String also inherits many useful methods from its hierarchy, such as
	SequenceableCollection ,
	SequenceableCollection copyReplaceAll:with:!
]style[(269 13 2 18 72 24 2 43)f1,f1LString match:;,f1,f1LString contractTo:;,f1,f1LSequenceableCollection ,;,f1,f1LSequenceableCollection copyReplaceAll:with:;!


!String methodsFor: 'accessing' stamp: 'EMP 11/20/2015 12:20'!
asSqueakPathName

	^ self.
! !

!String methodsFor: 'accessing'!
at: index 
	"Primitive. Answer the Character stored in the field of the receiver
	indexed by the argument. Fail if the index argument is not an Integer or
	is out of bounds. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 63>
	^Character value: (super at: index)! !

!String methodsFor: 'accessing' stamp: 'wod 6/16/1998 15:24'!
at: index put: aCharacter 
	"Primitive. Store the Character in the field of the receiver indicated by
	the index. Fail if the index is not an Integer or is out of bounds, or if
	the argument is not a Character. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 64>
	(aCharacter isKindOf: Character)
		ifTrue: [	
			index isInteger
				ifTrue: [self errorSubscriptBounds: index]
				ifFalse: [self errorNonIntegerIndex]]
		ifFalse: [self error: 'Strings only store Characters']! !

!String methodsFor: 'accessing' stamp: 'ar 12/27/1999 13:44'!
byteAt: index
	<primitive: 60>
	^(self at: index) asciiValue! !

!String methodsFor: 'accessing' stamp: 'ar 12/27/1999 13:44'!
byteAt: index put: value
	<primitive: 61>
	self at: index put: value asCharacter.
	^value! !

!String methodsFor: 'accessing' stamp: 'EMP 2/11/2016 14:22'!
charsAfterLastDigits
	| t1 |
	t1 := self
				findFirst: [:t2 | t2 isDigit not].
	t1 > 0
		ifTrue: [^ self copyFrom: t1 to: self size].
	^ ''! !

!String methodsFor: 'accessing'!
endsWithDigit
	"Answer whether the receiver's final character represents a digit.  3/11/96 sw"

	^ self size > 0 and: [self last isDigit]! !

!String methodsFor: 'accessing' stamp: 'tk 12/26/97 11:09'!
findAnySubStr: delimiters startingAt: start 
	"Answer the index of the character within the receiver, starting at start, that begins a substring matching one of the delimiters.  delimiters is an Array of Strings (Characters are permitted also).  If the receiver does not contain any of the delimiters, answer size + 1."

	| min ind |
	min _ self size + 1.
	delimiters do: [:delim |	"May be a char, a string of length 1, or a substring"
		delim class == Character 
			ifTrue: [ind _ self indexOfSubCollection: (String with: delim) 
						startingAt: start ifAbsent: [min]]
			ifFalse: [ind _ self indexOfSubCollection: delim 
						startingAt: start ifAbsent: [min]].
			min _ min min: ind].
	^ min! !

!String methodsFor: 'accessing' stamp: 'ls 3/19/2000 16:43'!
findCloseParenthesisFor: startIndex
	"assume (self at: startIndex) is $(.  Find the matching $), allowing parentheses to nest."
	" '(1+(2-3))-3.14159' findCloseParenthesisFor: 1 "
	" '(1+(2-3))-3.14159' findCloseParenthesisFor: 4 "
	| pos nestLevel |
	pos := startIndex+1.
	nestLevel := 1.
	[ pos <= self size ] whileTrue: [
		(self at: pos) = $( ifTrue: [ nestLevel := nestLevel + 1 ].
		(self at: pos) = $) ifTrue: [ nestLevel := nestLevel - 1 ].
		nestLevel = 0 ifTrue: [ ^pos ].
		pos := pos + 1.
	].
	^self size + 1! !

!String methodsFor: 'accessing'!
findDelimiters: delimiters startingAt: start 
	"Answer the index of the character within the receiver, starting at start, that matches one of the delimiters. If the receiver does not contain any of the delimiters, answer size + 1."

	start to: self size do: [:i |
		delimiters do: [:delim | delim = (self at: i) ifTrue: [^ i]]].
	^ self size + 1! !

!String methodsFor: 'accessing' stamp: 'ar 4/11/1999 22:15'!
findString: subString
	"Answer the index of subString within the receiver, starting at start. If 
	the receiver does not contain subString, answer 0."
	^self findString: subString startingAt: 1.! !

!String methodsFor: 'accessing' stamp: 'di 11/15/1998 16:43'!
findString: subString startingAt: start 
	"Answer the index of subString within the receiver, starting at start. If 
	the receiver does not contain subString, answer 0."

	^ self findSubstring: subString in: self startingAt: start matchTable: CaseSensitiveOrder! !

!String methodsFor: 'accessing' stamp: 'di 11/15/1998 16:45'!
findString: key startingAt: start caseSensitive: caseSensitive
	"Answer the index in this String at which the substring key first occurs, at or beyond start.  The match can be case-sensitive or not.  If no match is found, zero will be returned."

	caseSensitive
	ifTrue: [^ self findSubstring: key in: self startingAt: start matchTable: CaseSensitiveOrder]
	ifFalse: [^ self findSubstring: key in: self startingAt: start matchTable: CaseInsensitiveOrder]! !

!String methodsFor: 'accessing' stamp: 'tk 12/26/97 10:07'!
findTokens: delimiters
	"Answer the collection of tokens that result from parsing self.  Any character in the String delimiters marks a border.  Several delimiters in a row are considered as just one separation."

	| tokens keyStart keyStop |

	tokens _ OrderedCollection new.
	keyStop _ 1.
	[keyStop <= self size] whileTrue:
		[keyStart _ self skipDelimiters: delimiters startingAt: keyStop.
		keyStop _ self findDelimiters: delimiters startingAt: keyStart.
		keyStart < keyStop
			ifTrue: [tokens add: (self copyFrom: keyStart to: (keyStop - 1))]].
	^tokens! !

!String methodsFor: 'accessing' stamp: 'tk 6/19/97 10:05'!
findTokens: delimiters keep: keepers
	"Answer the collection of tokens that result from parsing self.  The tokens are seperated by delimiters, any of a string of characters.  If a delimiter is also in keepers, make a token for it.  (Very useful for carriage return.  A sole return ends a line, but is also saved as a token so you can see where the line breaks were.)"

	| tokens keyStart keyStop |
	tokens _ OrderedCollection new.
	keyStop _ 1.
	[keyStop <= self size] whileTrue:
		[keyStart _ self skipDelimiters: delimiters startingAt: keyStop.
		keyStop to: keyStart-1 do: [:ii | 
			(keepers includes: (self at: ii)) ifTrue: [
				tokens add: (self copyFrom: ii to: ii)]].	"Make this keeper be a token"
		keyStop _ self findDelimiters: delimiters startingAt: keyStart.
		keyStart < keyStop
			ifTrue: [tokens add: (self copyFrom: keyStart to: (keyStop - 1))]].
	^tokens! !

!String methodsFor: 'accessing' stamp: 'EMP 2/11/2016 14:22'!
findVersionNumber
	| t1 |
	t1 := self size.
	[t1 > 0
		and: [((self at: t1)
				= $v) not]]
		whileTrue: [t1 := t1 - 1].
	^ self copyFrom: t1 + 1 to: self size! !

!String methodsFor: 'accessing' stamp: 'sw 8/12/97 12:37'!
includesSubString: subString
	^ (self findString: subString startingAt: 1) > 0! !

!String methodsFor: 'accessing' stamp: 'di 11/15/1998 16:53'!
includesSubstring: aString caseSensitive: caseSensitive
	
	^ (self findString: aString startingAt: 1 caseSensitive: caseSensitive) > 0! !

!String methodsFor: 'accessing' stamp: 'di 9/1/1999 18:28'!
indexOf: aCharacter

	(aCharacter class == Character) ifFalse: [^ 0].
	^ String indexOfAscii: aCharacter asciiValue inString: self startingAt: 1! !

!String methodsFor: 'accessing' stamp: 'di 9/1/1999 18:28'!
indexOf: aCharacter  startingAt: start

	(aCharacter class == Character) ifFalse: [^ 0].
	^ String indexOfAscii: aCharacter asciiValue inString: self startingAt: start! !

!String methodsFor: 'accessing' stamp: 'di 9/1/1999 18:28'!
indexOf: aCharacter  startingAt: start  ifAbsent: aBlock
	| ans |
	(aCharacter class == Character) ifFalse: [ ^ aBlock value ].
	ans _ String indexOfAscii: aCharacter asciiValue inString: self  startingAt: start.
	ans = 0
		ifTrue: [ ^ aBlock value ]
		ifFalse: [ ^ ans ]! !

!String methodsFor: 'accessing' stamp: 'ls 8/20/1998 05:19'!
indexOfAnyOf: aCharacterSet  ifAbsent: aBlock
	"returns the index of the first character in the given set.  Returns the evaluation of aBlock if none are found"
	^self indexOfAnyOf: aCharacterSet  startingAt: 1  ifAbsent: aBlock! !

!String methodsFor: 'accessing' stamp: 'ls 8/18/1998 00:27'!
indexOfAnyOf: aCharacterSet  startingAt: start ifAbsent: aBlock
	"returns the index of the first character in the given set, starting from start"

	| ans |
	ans _ String findFirstInString: self  inSet: aCharacterSet byteArrayMap startingAt: start.

	ans = 0 
		ifTrue: [ ^aBlock value ]
		ifFalse: [ ^ans ]! !

!String methodsFor: 'accessing' stamp: 'jm 12/6/2006 16:20'!
indexOfSeparatorStartingAt: index
	"Answer the index of the next separator character found starting at the given index. Answer size + 1 if none is found."

	^ self
		indexOfAnyOf: CSSeparators
		startingAt: index 
		ifAbsent: [self size + 1]
! !

!String methodsFor: 'accessing' stamp: 'di 11/15/1998 17:02'!
indexOfSubCollection: sub startingAt: start ifAbsent: exceptionBlock
	| index |
	index _ self findSubstring: sub in: self startingAt: start matchTable: CaseSensitiveOrder.
	index = 0 ifTrue: [^ exceptionBlock value].
	^ index! !

!String methodsFor: 'accessing' stamp: 'EMP 11/20/2015 11:51'!
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

!String methodsFor: 'accessing' stamp: 'EMP 2/11/2016 14:22'!
leadingDigits
	| t1 |
	t1 := self
				findFirst: [:t2 | t2 isDigit not].
	t1 > 0
		ifTrue: [^ self copyFrom: 1 to: t1 - 1].
	^ ''! !

!String methodsFor: 'accessing' stamp: 'jm 3/18/2005 23:22'!
lines
	"Answer a collection of lines for this string. Lines are terminated by a CR or LF character or possibly both. The termination character(s) are not included in the line."

	| cr lf sz result start i ch end |
	self isEmpty ifTrue: [^ #()].
	cr _ Character cr.
	lf _ Character lf.
	sz _ self size.
	result _ OrderedCollection new: 100.
	start _ i _ 1.
	[true] whileTrue: [
		[ch _ self at: i.
		 i < sz and: [(ch ~~ cr) & (ch ~~ lf)]] whileTrue: [
			i _ i + 1].  "scan for line end"

		end _ (ch == cr) | (ch == lf) ifTrue: [i - 1] ifFalse: [i].
		result addLast: (self copyFrom: start to: end).

		(i _ i + 1) <= sz ifTrue: [
			(ch = cr and: [(self at: i) = lf]) ifTrue: [i _ i + 1].  "CR-LF"
			(ch = lf and: [(self at: i) = cr]) ifTrue: [i _ i + 1]].  "LF-CR"

		i > sz ifTrue: [^ result asArray].
		start _ i].
! !

!String methodsFor: 'accessing'!
skipDelimiters: delimiters startingAt: start 
	"Answer the index of the character within the receiver, starting at start, that does NOT match one of the delimiters. If the receiver does not contain any of the delimiters, answer size + 1.  Assumes the delimiters to be a non-empty string."

	start to: self size do: [:i |
		delimiters detect: [:delim | delim = (self at: i)]
				ifNone: [^ i]].
	^ self size + 1! !

!String methodsFor: 'accessing' stamp: 'sw 4/23/1998 10:53'!
startsWithDigit
	"Answer whether the receiver's first character represents a digit"

	^ self size > 0 and: [self first isDigit]! !


!String methodsFor: 'comparing' stamp: 'di 2/27/98 12:16'!
< aString 
	"Answer whether the receiver sorts before aString.
	The collation order is simple ascii (with case differences)."

	^ (self compare: self with: aString collated: AsciiOrder) = 1! !

!String methodsFor: 'comparing' stamp: 'di 2/27/98 12:17'!
<= aString 
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is simple ascii (with case differences)."

	^ (self compare: self with: aString collated: AsciiOrder) <= 2! !

!String methodsFor: 'comparing' stamp: 'di 9/14/1998 16:29'!
= aString 
	"Answer whether the receiver sorts equally as aString.
	The collation order is simple ascii (with case differences)."

	aString species == String ifFalse: [^ false].

	^ (self compare: self with: aString collated: AsciiOrder) = 2! !

!String methodsFor: 'comparing' stamp: 'di 2/27/98 12:17'!
> aString 
	"Answer whether the receiver sorts after aString.
	The collation order is simple ascii (with case differences)."

	^ (self compare: self with: aString collated: AsciiOrder) = 3! !

!String methodsFor: 'comparing' stamp: 'di 2/27/98 12:18'!
>= aString 
	"Answer whether the receiver sorts after or equal to aString.
	The collation order is simple ascii (with case differences)."

	^ (self compare: self with: aString collated: AsciiOrder) >= 2! !

!String methodsFor: 'comparing'!
alike: aString 
	"Answer some indication of how alike the receiver is to the argument,  0 is no match, twice aString size is best score.  Case is ignored."

	| i j k minSize bonus |
	minSize _ (j _ self size) min: (k _ aString size).
	bonus _ (j - k) abs < 2 ifTrue: [ 1 ] ifFalse: [ 0 ].
	i _ 1.
	[(i <= minSize) and: [((super at: i) bitAnd: 16rDF)  = ((aString at: i) asciiValue bitAnd: 16rDF)]]
		whileTrue: [ i _ i + 1 ].
	[(j > 0) and: [(k > 0) and:
		[((super at: j) bitAnd: 16rDF) = ((aString at: k) asciiValue bitAnd: 16rDF)]]]
			whileTrue: [ j _ j - 1.  k _ k - 1. ].
	^ i - 1 + self size - j + bonus. ! !

!String methodsFor: 'comparing' stamp: 'di 11/15/1998 17:25'!
beginsWith: prefix
	"Answer whether the receiver begins with the given prefix string.
	The comparison is case-sensitive."

	self size < prefix size ifTrue: [^ false].
	^ (self findSubstring: prefix in: self startingAt: 1
			matchTable: CaseSensitiveOrder) = 1
! !

!String methodsFor: 'comparing' stamp: 'jm 4/27/2007 13:13'!
caseInsensitiveEqual: aString 
	"Answer whether the receiver is equal to aString ignoring case differences."

	^ (self compare: self with: aString collated: CaseInsensitiveOrder) = 2! !

!String methodsFor: 'comparing' stamp: 'sw 4/19/1999 12:11'!
caseInsensitiveLessOrEqual: aString 
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is case insensitive."

	^ (self compare: self with: aString collated: CaseInsensitiveOrder) <= 2! !

!String methodsFor: 'comparing' stamp: 'di 9/20/1998 14:33'!
caseSensitiveLessOrEqual: aString 
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is case sensitive."

	^ (self compare: self with: aString collated: CaseSensitiveOrder) <= 2! !

!String methodsFor: 'comparing' stamp: 'di 2/27/98 12:41'!
compare: aString 
	"Answer a comparison code telling how the receiver sorts relative to aString:
		1 - before
		2 - equal
		3 - after.
	The collation sequence is ascii with case differences ignored.
	To get the effect of a <= b, but ignoring case, use (a compare: b) <= 2."

	^ self compare: self with: aString collated: CaseInsensitiveOrder! !

!String methodsFor: 'comparing' stamp: 'go 2/11/98 14:59'!
crc16
	"Compute a 16 bit cyclic redundancy check."

	| crc |
	crc := 0.
	self do: [:c |
		crc := (crc bitShift: -8) bitXor: (
		 #(	16r0000	16rC0C1	16rC181	16r0140	16rC301	16r03C0	16r0280	16rC241
			16rC601	16r06C0	16r0780	16rC741	16r0500	16rC5C1	16rC481	16r0440
			16rCC01	16r0CC0	16r0D80	16rCD41	16r0F00	16rCFC1	16rCE81	16r0E40
			16r0A00	16rCAC1	16rCB81	16r0B40	16rC901	16r09C0	16r0880	16rC841
			16rD801	16r18C0	16r1980	16rD941	16r1B00	16rDBC1	16rDA81	16r1A40
			16r1E00	16rDEC1	16rDF81	16r1F40	16rDD01	16r1DC0	16r1C80	16rDC41
			16r1400	16rD4C1	16rD581	16r1540	16rD701	16r17C0	16r1680	16rD641
			16rD201	16r12C0	16r1380	16rD341	16r1100	16rD1C1	16rD081	16r1040
			16rF001	16r30C0	16r3180	16rF141	16r3300	16rF3C1	16rF281	16r3240
			16r3600	16rF6C1	16rF781	16r3740	16rF501	16r35C0	16r3480	16rF441
			16r3C00	16rFCC1	16rFD81	16r3D40	16rFF01	16r3FC0	16r3E80	16rFE41
			16rFA01	16r3AC0	16r3B80	16rFB41	16r3900	16rF9C1	16rF881	16r3840
			16r2800	16rE8C1	16rE981	16r2940	16rEB01	16r2BC0	16r2A80	16rEA41
			16rEE01	16r2EC0	16r2F80	16rEF41	16r2D00	16rEDC1	16rEC81	16r2C40
			16rE401	16r24C0	16r2580	16rE541	16r2700	16rE7C1	16rE681	16r2640
			16r2200	16rE2C1	16rE381	16r2340	16rE101	16r21C0	16r2080	16rE041
			16rA001	16r60C0	16r6180	16rA141	16r6300	16rA3C1	16rA281	16r6240
			16r6600	16rA6C1	16rA781	16r6740	16rA501	16r65C0	16r6480	16rA441
			16r6C00	16rACC1	16rAD81	16r6D40	16rAF01	16r6FC0	16r6E80	16rAE41
			16rAA01	16r6AC0	16r6B80	16rAB41	16r6900	16rA9C1	16rA881	16r6840
			16r7800	16rB8C1	16rB981	16r7940	16rBB01	16r7BC0	16r7A80	16rBA41
			16rBE01	16r7EC0	16r7F80	16rBF41	16r7D00	16rBDC1	16rBC81	16r7C40
			16rB401	16r74C0	16r7580	16rB541	16r7700	16rB7C1	16rB681	16r7640
			16r7200	16rB2C1	16rB381	16r7340	16rB101	16r71C0	16r7080	16rB041
			16r5000	16r90C1	16r9181	16r5140	16r9301	16r53C0	16r5280	16r9241
			16r9601	16r56C0	16r5780	16r9741	16r5500	16r95C1	16r9481	16r5440
			16r9C01	16r5CC0	16r5D80	16r9D41	16r5F00	16r9FC1	16r9E81	16r5E40
			16r5A00	16r9AC1	16r9B81	16r5B40	16r9901	16r59C0	16r5880	16r9841
			16r8801	16r48C0	16r4980	16r8941	16r4B00	16r8BC1	16r8A81	16r4A40
			16r4E00	16r8EC1	16r8F81	16r4F40	16r8D01	16r4DC0	16r4C80	16r8C41
			16r4400	16r84C1	16r8581	16r4540	16r8701	16r47C0	16r4680	16r8641
			16r8201	16r42C0	16r4380	16r8341	16r4100	16r81C1	16r8081	16r4040)
			 at: ((crc bitXor: c asciiValue) bitAnd: 16rFF) + 1) ].
	^crc! !

!String methodsFor: 'comparing' stamp: 'di 11/15/1998 17:25'!
endsWith: suffix
	"Answer whether the tail end of the receiver is the same as suffix.
	The comparison is case-sensitive."
	| extra |
	(extra _ self size - suffix size) < 0 ifTrue: [^ false].
	^ (self findSubstring: suffix in: self startingAt: extra + 1
			matchTable: CaseSensitiveOrder) > 0
"
  'Elvis' endsWith: 'vis'
"! !

!String methodsFor: 'comparing'!
hash

	| l m |
	(l _ m _ self size) <= 2
	  ifTrue:
		[l = 2
		  ifTrue: [m _ 3]
		  ifFalse:
			[l = 1
			  ifTrue: [^((self at: 1) asciiValue bitAnd: 127) * 106].
			^21845]].
	^(self at: 1) asciiValue * 48 + ((self at: (m - 1)) asciiValue + l)! !

!String methodsFor: 'comparing' stamp: 'di 11/19/1998 13:37'!
match: text
	"Answer whether text matches the pattern in this string.
	Matching ignores upper/lower case differences.
	Where this string contains #, text may contain any character.
	Where this string contains *, text may contain any sequence of characters."

	^ self startingAt: 1 match: text startingAt: 1
"
	'*'			match: 'zort' true
	'*baz'		match: 'mobaz' true
	'*baz'		match: 'mobazo' false
	'*baz*'		match: 'mobazo' true
	'*baz*'		match: 'mozo' false
	'foo*'		match: 'foozo' true
	'foo*'		match: 'bozo' false
	'foo*baz'	match: 'foo23baz' true
	'foo*baz'	match: 'foobaz' true
	'foo*baz'	match: 'foo23bazo' false
	'foo'		match: 'Foo' true
	'foo*baz*zort' match: 'foobazort' false
	'foo*baz*zort' match: 'foobazzort' false
	'*foo#zort'	match: 'afoo3zortthenfoo3zort' true
	'*foo*zort'	match: 'afoodezortorfoo3zort' true
"! !

!String methodsFor: 'comparing' stamp: 'di 2/27/98 12:19'!
sameAs: aString 
	"Answer whether the receiver sorts equal to aString. The 
	collation sequence is ascii with case differences ignored."

	^ (self compare: self with: aString collated: CaseInsensitiveOrder) = 2! !

!String methodsFor: 'comparing' stamp: 'di 11/19/1998 13:28'!
startingAt: keyStart match: text startingAt: textStart
	"Answer whether text matches the pattern in this string.
	Matching ignores upper/lower case differences.
	Where this string contains #, text may contain any character.
	Where this string contains *, text may contain any sequence of characters."
	| anyMatch matchStart matchEnd i matchStr j ii jj |
	i _ keyStart.
	j _ textStart.

	"Check for any #'s"
	[i > self size ifTrue: [^ j > text size "Empty key matches only empty string"].
	(self at: i) = $#] whileTrue:
		["# consumes one char of key and one char of text"
		j > text size ifTrue: [^ false "no more text"].
		i _ i+1.  j _ j+1].

	"Then check for *"
	(self at: i) = $*
		ifTrue: [i = self size ifTrue:
					[^ true "Terminal * matches all"].
				"* means next match string can occur anywhere"
				anyMatch _ true.
				matchStart _ i + 1]
		ifFalse: ["Otherwise match string must occur immediately"
				anyMatch _ false.
				matchStart _ i].

	"Now determine the match string"
	matchEnd _ self size.
	(ii _ self indexOf: $* startingAt: matchStart) > 0 ifTrue:
		[ii = 1 ifTrue: [self error: '** not valid -- use * instead'].
		matchEnd _ ii-1].
	(ii _ self indexOf: $# startingAt: matchStart) > 0 ifTrue:
		[ii = 1 ifTrue: [self error: '*# not valid -- use #* instead'].
		matchEnd _ matchEnd min: ii-1].
	matchStr _ self copyFrom: matchStart to: matchEnd.

	"Now look for the match string"
	[jj _ text findString: matchStr startingAt: j caseSensitive: false.
	anyMatch ifTrue: [jj > 0] ifFalse: [jj = j]]
		whileTrue:
		["Found matchStr at jj.  See if the rest matches..."
		(self startingAt: matchEnd+1 match: text startingAt: jj + matchStr size) ifTrue:
			[^ true "the rest matches -- success"].
		"The rest did not match."
		anyMatch ifFalse: [^ false].
		"Preceded by * -- try for a later match"
		j _ j+1].
	^ false "Failed to find the match string"! !


!String methodsFor: 'copying' stamp: 'EMP 11/6/2015 16:11'!
copyReplaceTokens: oldSubstring with: newSubstring 
	"Replace all occurrences of oldSubstring that are surrounded
	by non-alphanumeric characters"
	^ self copyReplaceAll: oldSubstring with: newSubstring asTokens: true
	"'File asFile Files File''s File' copyReplaceTokens: 'File' with: 'Snick'"! !

!String methodsFor: 'copying'!
deepCopy
	"DeepCopy would otherwise mean make a copy of the character;  since 
	characters are unique, just return a shallowCopy."

	^self shallowCopy! !

!String methodsFor: 'copying' stamp: 'di 2/15/98 22:54'!
padded: leftOrRight to: length with: char
	leftOrRight = #left ifTrue:
		[^ (String new: (length - self size max: 0) withAll: char) , self].
	leftOrRight = #right ifTrue:
		[^ self , (String new: (length - self size max: 0) withAll: char)].! !


!String methodsFor: 'converting' stamp: 'di 11/9/1998 12:17'!
adaptToNumber: rcvr andSend: selector
	"If I am involved in arithmetic with a number, convert me to a number."

	^ rcvr perform: selector with: self asNumber! !

!String methodsFor: 'converting' stamp: 'di 11/6/1998 13:49'!
adaptToPoint: rcvr andSend: selector
	"If I am involved in arithmetic with a point, convert me to a number."

	^ rcvr perform: selector with: self asNumber! !

!String methodsFor: 'converting' stamp: 'jm 10/28/2007 19:28'!
allWordsCapitalized
	"Return a copy with the first letter of each word capitalized."

	| result wordStart ch |
	result _ self copy.
	wordStart _ true.
	1 to: self size do: [:i |
		ch _ self at: i.
		ch isSeparator
			ifTrue: [wordStart _ true]
			ifFalse: [
				wordStart ifTrue: [
					result at: i put: ch asUppercase.
					wordStart _ false]]].
	^ result
! !

!String methodsFor: 'converting' stamp: 'EMP 11/30/2015 14:32'!
asBoolean
	^ ((self = 'true') | [(self = '1') | [self = 'not false' ":P little easter egg"]])! !

!String methodsFor: 'converting' stamp: 'tk 1/24/98 11:22'!
asDate
	"Many allowed forms, see Date.readFrom:"
	^ Date readFrom: (ReadStream on: self)! !

!String methodsFor: 'converting'!
asDisplayText
	"Answer a DisplayText whose text string is the receiver."

	^DisplayText text: self asText! !

!String methodsFor: 'converting' stamp: 'sma 3/11/2000 17:25'!
asHtml
	"Do the basic character conversion for HTML.  Leave all original return 
	and tabs in place, so can conver back by simply removing bracked 
	things. 4/4/96 tk"
	| temp |
	temp _ self copyReplaceAll: '&' with: '&amp;'.
	HtmlEntities keysAndValuesDo:
		[:entity :char |
		char = $& ifFalse:
			[temp _ temp copyReplaceAll: char asString with: '&' , entity , ';']].
	temp _ temp copyReplaceAll: '	' with: '	<IMG SRC="tab.gif" ALT="    ">'.
	temp _ temp copyReplaceAll: '
' with: '
<BR>'.
	^ temp

"
	'A<&>B' asHtml
"! !

!String methodsFor: 'converting' stamp: 'sma 6/12/2000 11:40'!
asLowercase
	"Answer a String made up from the receiver whose characters are all 
	lowercase."

	^ self copy asString translateToLowercase! !

!String methodsFor: 'converting' stamp: 'jm 6/29/2008 11:09'!
asMacRoman
	"Squeak strings are encoded as MacRoman."

	^ self
! !

!String methodsFor: 'converting' stamp: 'jm 10/14/2002 19:04'!
asNumber 
	"Answer the Number created by interpreting the receiver as the string  representation of a number."

	^ Number readFrom: (ReadStream on: self)
! !

!String methodsFor: 'converting' stamp: 'jm 6/2/2009 12:12'!
asNumberNoError
	"Convert the given string to a number without giving errors about its format. Ignore non-digit characters and allow a leading '+', which kids sometimes type. Answer zero if empty."

	| s sign ch body |
	self size = 0 ifTrue: [^ 0].
	s _ ReadStream on: self.
	s skipSeparators.

	"read sign character, if any"
	sign _ 1.
	ch _ s peek.
	(ch = $+) | (ch = $-) ifTrue: [
		ch = $- ifTrue: [sign _ -1].
		s skip: 1].

	body _ WriteStream on: (String new: 40).
	body nextPut: $0.
	[s atEnd not and: [s peek isDigit]] whileTrue: [body nextPut: s next].  "read digits before decimal point"
	('.,' includes: s peek) ifTrue: [  "read decimal point (period or comma) and following digits, if any"
		s skip: 1.
		body nextPut: $..
		[s atEnd not and: [s peek isDigit]] whileTrue: [body nextPut: s next]].

	"read exponent"
	(s atEnd not and: ['eE' includes: s peek]) ifTrue: [
		s next.
		body nextPut: $e.
		(s atEnd not and: [s peek = $-]) ifTrue: [body nextPut: s next].		 "exponent sign"
		[s atEnd not and: [s peek isDigit]] whileTrue: [body nextPut: s next]].  "exponent"

	^ sign * (body contents asNumber)
! !

!String methodsFor: 'converting'!
asParagraph
	"Answer a Paragraph whose text string is the receiver."

	^Paragraph withText: self asText! !

!String methodsFor: 'converting' stamp: 'jm 5/14/1998 10:40'!
asString
	"Answer this string."

	^ self
! !

!String methodsFor: 'converting'!
asSymbol
	"Answer the unique Symbol whose characters are the characters of the 
	string."

	^Symbol intern: self! !

!String methodsFor: 'converting' stamp: 'jm 1/19/2007 17:59'!
asTabDelimitedRecord
	"Answer an array of fields separated by tab stops. Useful for converting from spread-sheet tab-delimited data."

	| s fields |
	s _ ReadStream on: self.
	fields _ OrderedCollection new.
	[s atEnd] whileFalse: [fields addLast: (s upTo: Character tab) withBlanksTrimmed].
	fields _ fields asArray.
	^ fields
! !

!String methodsFor: 'converting'!
asText
	"Answer a Text whose string is the receiver."

	^Text fromString: self! !

!String methodsFor: 'converting' stamp: 'jm 6/29/2008 10:31'!
asUTF32
	"Answer this string, assumed be encoded in MacRoman, encoded as UTF-32."

	^ (UTF8 fromMacRoman: self) asUTF32
! !

!String methodsFor: 'converting' stamp: 'jm 1/24/2008 11:45'!
asUTF8
	"Answer this string, assumed be encoded in MacRoman, encoded as UTF-8."

	^ UTF8 fromMacRoman: self
! !

!String methodsFor: 'converting' stamp: 'sma 6/12/2000 11:41'!
asUppercase
	"Answer a String made up from the receiver whose characters are all 
	uppercase."

	^ self collect: [:each | each asUppercase]! !

!String methodsFor: 'converting' stamp: 'jm 9/20/2007 10:40'!
asUrl
	"This escapes the tokens in the path in a URL. For example, in the path /shariables/read/tammy/high score, each of the parts between the slashes should be escaped. It is missing the carrot symbol, which converts to %5E."
	"'high score' asUrl"

	| temp |
	temp _ self copyReplaceAll: '%' with: '%20'.
	temp _ temp copyReplaceAll: ' ' with: '%20'.
	temp _ temp copyReplaceAll: '$' with: '%24'.
	temp _ temp copyReplaceAll: '&' with: '%26'.
	temp _ temp copyReplaceAll: '+' with: '%2B'.
	temp _ temp copyReplaceAll: ',' with: '%2C'.
	temp _ temp copyReplaceAll: '/' with: '%2F'.
	temp _ temp copyReplaceAll: ':' with: '%3A'.
	temp _ temp copyReplaceAll: ';' with: '%3B'.
	temp _ temp copyReplaceAll: '=' with: '%3D'.
	temp _ temp copyReplaceAll: '?' with: '%3F'.
	temp _ temp copyReplaceAll: '@' with: '%40'.
	temp _ temp copyReplaceAll: '<' with: '%3C'.
	temp _ temp copyReplaceAll: '>' with: '%3E'.
	temp _ temp copyReplaceAll: '"' with: '%22'.
	temp _ temp copyReplaceAll: '#' with: '%23'.
	temp _ temp copyReplaceAll: '{' with: '%7B'.
	temp _ temp copyReplaceAll: '}' with: '%7D'.	
	temp _ temp copyReplaceAll: '|' with: '%7C'.
	temp _ temp copyReplaceAll: '\' with: '%5C'.
	temp _ temp copyReplaceAll: '~' with: '%7E'.
	temp _ temp copyReplaceAll: '[' with: '%5B'.
	temp _ temp copyReplaceAll: ']' with: '%5D'.
	temp _ temp copyReplaceAll: '`' with: '%60'.
	^ temp
! !

!String methodsFor: 'converting' stamp: 'di 2/2/98 12:59'!
askIfAddStyle: priorMethod req: requestor
	^ self   "we are a string with no text style"! !

!String methodsFor: 'converting' stamp: 'ls 9/10/1998 08:48'!
capitalized
	"Return a copy with the first letter capitalized"
	| cap |
	self isEmpty ifTrue: [ ^self copy ].
	cap _ self copy.
	cap at: 1 put: (cap at: 1) asUppercase.
	^ cap! !

!String methodsFor: 'converting'!
compressWithTable: tokens
	"Return a string with all substrings that occur in tokens replaced
	by a character with ascii code = 127 + token index.
	This will work best if tokens are sorted by size.
	Assumes this string contains no characters > 127, or that they
	are intentionally there and will not interfere with this process."
	| str null finalSize start result ri c ts |
	null _ Character value: 0.
	str _ self copyFrom: 1 to: self size.  "Working string will get altered"
	finalSize _ str size.
	tokens doWithIndex:
		[:token :tIndex |
		start _ 1.
		[(start _ str findString: token startingAt: start) > 0]
			whileTrue:
			[ts _ token size.
			((start + ts) <= str size
				and: [(str at: start + ts) = $  and: [tIndex*2 <= 128]])
				ifTrue: [ts _ token size + 1.  "include training blank"
						str at: start put: (Character value: tIndex*2 + 127)]
				ifFalse: [str at: start put: (Character value: tIndex + 127)].
			str at: start put: (Character value: tIndex + 127).
			1 to: ts-1 do: [:i | str at: start+i put: null].
			finalSize _ finalSize - (ts - 1).
			start _ start + ts]].
	result _ String new: finalSize.
	ri _ 0.
	1 to: str size do:
		[:i | (c _ str at: i) = null ifFalse: [result at: (ri _ ri+1) put: c]].
	^ result! !

!String methodsFor: 'converting' stamp: 'di 1/16/98 16:33'!
contractTo: smallSize
	"return myself or a copy shortened by ellipsis to smallSize"
	| leftSize |
	self size <= smallSize
		ifTrue: [^ self].  "short enough"
	smallSize < 5
		ifTrue: [^ self copyFrom: 1 to: smallSize].    "First N characters"
	leftSize _ smallSize-2//2.
	^ self copyReplaceFrom: leftSize+1		"First N/2 ... last N/2"
		to: self size - (smallSize - leftSize - 3)
		with: '...'
"
	'A clear but rather long-winded summary' contractTo: 18
"! !

!String methodsFor: 'converting' stamp: 'EMP 11/20/2015 12:22'!
convertFromSystemString

	^ self! !

!String methodsFor: 'converting'!
correctAgainst: wordList
	"Correct the receiver: assume it is a misspelled word and return the (maximum of five) nearest words in the wordList.  Depends on the scoring scheme of alike:"
	| results |
	results _ self correctAgainst: wordList continuedFrom: nil.
	results _ self correctAgainst: nil continuedFrom: results.
	^ results! !

!String methodsFor: 'converting' stamp: 'jm 5/29/2003 18:55'!
correctAgainst: wordList continuedFrom: oldCollection
	"Like correctAgainst:.  Use when you want to correct against several lists, give nil as the first oldCollection, and nil as the last wordList."

	^ wordList isNil
		ifTrue: [self correctAgainstEnumerator: nil continuedFrom: oldCollection]
		ifFalse: [
			self correctAgainstEnumerator: [:action |
					wordList do: [:w | w ifNotNil: [action value: w]]]
				continuedFrom: oldCollection]
! !

!String methodsFor: 'converting'!
correctAgainstDictionary: wordDict continuedFrom: oldCollection
	"Like correctAgainst:continuedFrom:.  Use when you want to correct against a dictionary."

	^ wordDict isNil
		ifTrue: [ self correctAgainstEnumerator: nil
					continuedFrom: oldCollection ]
		ifFalse: [ self correctAgainstEnumerator: [ :action | wordDict keysDo: action ]
					continuedFrom: oldCollection ]! !

!String methodsFor: 'converting' stamp: 'ls 8/12/1998 23:31'!
encodeForHTTP
	"change dangerous characters to their %XX form, for use in HTTP transactions"
	| encodedStream |
	encodedStream _ WriteStream on: (String new).
	
	self do: [ :c |
		c isSafeForHTTP ifTrue: [ encodedStream nextPut: c ] ifFalse: [
			encodedStream nextPut: $%.
			encodedStream nextPut: (c asciiValue // 16) asHexDigit.
			encodedStream nextPut: (c asciiValue \\ 16) asHexDigit.
		]
	].
	^encodedStream contents. ! !

!String methodsFor: 'converting' stamp: 'bf 10/13/1999 09:26'!
findSelector
	"Dan's code for hunting down selectors with keyword parts; while this doesn't give a true parse, in most cases it does what we want, in where it doesn't, we're none the worse for it."
	| sel possibleParens level n |
	sel _ self withBlanksTrimmed.
	(sel includes: $:) ifTrue:
		[possibleParens _ sel findTokens: Character separators.
		sel _ String streamContents:
			[:s | level _ 0.
			possibleParens do:
				[:token |
				(level = 0 and: [token endsWith: ':'])
					ifTrue: [s nextPutAll: token]
					ifFalse: [(n _ token occurrencesOf: $( ) > 0 ifTrue: [level _ level + n].
							(n _ token occurrencesOf: $[ ) > 0 ifTrue: [level _ level + n].
							(n _ token occurrencesOf: $] ) > 0 ifTrue: [level _ level - n].
							(n _ token occurrencesOf: $) ) > 0 ifTrue: [level _ level - n]]]]].

	sel isEmpty ifTrue: [^ nil].
	Symbol hasInterned: sel ifTrue:
		[:aSymbol | ^ aSymbol].
	^ nil! !

!String methodsFor: 'converting' stamp: 'sw 8/20/1999 10:23'!
initialIntegerOrNil
	"Answer the integer represented by the leading digits of the receiver, or nil if the receiver does not begin with a digit"
	| firstNonDigit |
	(self size == 0 or: [self first isDigit not]) ifTrue: [^ nil].
	firstNonDigit _ (self findFirst: [:m | m isDigit not]).
	firstNonDigit = 0 ifTrue: [firstNonDigit _ self size + 1].
	^ (self copyFrom: 1  to: (firstNonDigit - 1)) asNumber
"
'234Whoopie' initialIntegerOrNil
'wimpy' initialIntegerOrNil
'234' initialIntegerOrNil
'2N' initialIntegerOrNil
'2' initialIntegerOrNil
'  89Ten ' initialIntegerOrNil
'78 92' initialIntegerOrNil
"
! !

!String methodsFor: 'converting' stamp: 'jm 9/18/2007 14:49'!
isoLatinToMac
	"Convert this string from ISO-Latin to MacRoman encoding."

	| toMacRoman result ch |
	toMacRoman _ #(173 176 226 196 227 201 160 224 246 228 178 220 206 179 182 183 184 212 213 210 211 165 208 209 247 170 185 221 207 186 189 217 202 193 162 163 219 180 195 164 172 169 187 199 194 197 168 248 161 177 198 215 171 181 166 225 252 218 188 200 222 223 240 192 203 231 229 204 128 129 174 130 233 131 230 232 237 234 235 236 245 132 241 238 239 205 133 249 175 244 242 243 134 250 251 167 136 135 137 139 138 140 190 141 143 142 144 145 147 146 148 149 253 150 152 151 153 155 154 214 191 157 156 158 159 254 255 216).
	result _ self copy.
	1 to: result size do: [:i |
		ch _ self basicAt: i.
		ch > 127 ifTrue: [result basicAt: i put: (toMacRoman at: ch - 127)]].
	^ result
! !

!String methodsFor: 'converting' stamp: 'sma 4/22/2000 17:17'!
keywords
	"Answer an array of the keywords that compose the receiver."

	| answer size last |
	answer _ OrderedCollection new.
	size _ self size.
	last _ 0.
	1 to: size do:
		[:index |
		(self at: index) == $: ifTrue:
			[answer add: (self copyFrom: last + 1 to: index).
			last _ index]].
	last = size ifFalse: [answer add: (self copyFrom: last + 1 to: size)].
	^ answer asArray! !

!String methodsFor: 'converting' stamp: 'ee 4/14/2008 15:25'!
localized
	"Answer myself translated into the current Scratch language. If there is no translation for me, then answer myself."

	| selfAsString |
	selfAsString _ self asString.
	ScratchTranslator addUITranslation: selfAsString.
	^ ScratchTranslator translationFor: selfAsString.
! !

!String methodsFor: 'converting' stamp: 'jm 10/22/2007 16:28'!
localizedMIDI
	"Answer myself translated into the current Scratch language. If there is no translation for me, then answer myself."

	ScratchTranslator addMIDITranslation: self.
	^ ScratchTranslator translationFor: self
! !

!String methodsFor: 'converting' stamp: 'jm 9/18/2007 14:50'!
macToISOLatin
	"Convert this string from MacRoman to ISO-Latin encoding."

	| toISOLatin result ch |
	toISOLatin _ #(196 197 199 201 209 214 220 225 224 226 228 227 229 231 233 232 234 235 237 236 238 239 241 243 242 244 246 245 250 249 251 252 134 176 162 163 167 149 182 223 174 169 153 180 168 128 198 216 129 177 138 141 165 181 142 143 144 154 157 170 186 158 230 248 191 161 172 166 131 173 178 171 187 133 160 192 195 213 140 156 150 151 147 148 145 146 247 179 255 159 185 164 139 155 188 189 135 183 130 132 137 194 202 193 203 200 205 206 207 204 211 212 190 210 218 219 217 208 136 152 175 215 221 222 184 240 253 254).
	result _ self copy.
	1 to: result size do: [:i |
		ch _ self basicAt: i.
		ch > 127 ifTrue: [result basicAt: i put: (toISOLatin at: ch - 127)]].
	^ result
! !

!String methodsFor: 'converting'!
sansPeriodSuffix
	"Return a copy of the receiver up to, but not including, the first period.  If the receiver's *first* character is a period, then just return the entire receiver. "

	| likely |
	likely _ self copyUpTo: $..
	^ likely size == 0
		ifTrue:	[self]
		ifFalse:	[likely]! !

!String methodsFor: 'converting' stamp: 'di 9/24/1999 12:31'!
splitInteger
	"Answer an array that is a splitting of self into a string and an integer.
	'43Sam' ==> #(43 'Sam').  'Try90' ==> #('Try' 90)
	BUT NOTE: 'Sam' ==> #('Sam' 0), and '90' ==> #('' 90)  ie, (<string> <integer>)."

	| pos |
	(pos _ self findFirst: [:d | d isDigit not]) == 0 ifTrue: [^ Array with: '' with: self asNumber].
	self first isDigit ifTrue: [
		^ Array with: (self copyFrom: 1 to: pos - 1) asNumber 
				with: (self copyFrom: pos to: self size)].
	(pos _ self findFirst: [:d | d isDigit]) == 0 ifTrue: [^ Array with: self with: 0].
	^ Array with: (self copyFrom: 1 to: pos - 1)
			with: (self copyFrom: pos to: self size) asNumber! !

!String methodsFor: 'converting' stamp: 'jm 6/12/2008 12:51'!
trailingDigits
	"Answer the trailing digits of a string such as 'foo123' If the string does not end in a digit, answer the empty string."
	"'foo123' trailingDigits"
	"'foo' trailingDigits"

	| i |
	i _ self size.
	[(i > 0) and: [(self at: i) isDigit]] whileTrue: [i _ i - 1].
	^ self copyFrom: i + 1 to: self size
! !

!String methodsFor: 'converting' stamp: 'ls 8/15/1998 10:31'!
translateFrom: start  to: stop  table: table
	"translate the characters in the string by the given table, in place"
	String translate: self  from: start to: stop table: table! !

!String methodsFor: 'converting' stamp: 'ls 8/18/1998 07:44'!
translateToLowercase
	"Translate all characters to lowercase, in place"

	self translateWith: LowercasingTable! !

!String methodsFor: 'converting' stamp: 'ls 8/15/1998 08:30'!
translateWith: table
	"translate the characters in the string by the given table, in place"
	^self translateFrom: 1 to: self size table: table! !

!String methodsFor: 'converting'!
truncateTo: smallSize
	"return myself or a copy shortened to smallSize.  1/18/96 sw"

	^ self size <= smallSize
		ifTrue:
			[self]
		ifFalse:
			[self copyFrom: 1 to: smallSize]! !

!String methodsFor: 'converting' stamp: 'sw 9/2/1998 17:09'!
truncateWithElipsisTo: maxLength
	"Return myself or a copy suitably shortened but with elipsis added"

	^ self size <= maxLength
		ifTrue:
			[self]
		ifFalse:
			[(self copyFrom: 1 to: (maxLength - 3)), '...']


	"'truncateWithElipsisTo:' truncateWithElipsisTo: 20"! !

!String methodsFor: 'converting' stamp: 'jm 5/14/1998 10:26'!
withBlanksTrimmed
	"Return a copy of the receiver from which leading and trailing blanks have been trimmed."

	| first |
	first _ self findFirst: [:c | c isSeparator not].
	first = 0 ifTrue: [^ ''].  "no non-separator character"
	^ self
		copyFrom: first
		to: (self findLast: [:c | c isSeparator not])

	" ' abc  d   ' withBlanksTrimmed"
! !

!String methodsFor: 'converting'!
withCRs
	"Return a copy of the receiver in which backslash (\) characters have been replaced with carriage returns."

	^ self collect: [ :c | c = $\ ifTrue: [ Character cr ] ifFalse: [ c ]].! !

!String methodsFor: 'converting' stamp: 'tk 3/28/1999 22:44'!
withNoLineLongerThan: aNumber
	"Answer a string with the same content as receiver, but rewrapped so that no line has more characters than the given number"
	| listOfLines currentLast currentStart resultString putativeLast putativeLine crPosition |
	aNumber isNumber not | (aNumber < 1) ifTrue: [self error: 'too narrow'].
	listOfLines _ OrderedCollection new.
	currentLast _ 0.
	[currentLast < self size] whileTrue:
		[currentStart _ currentLast + 1.
		putativeLast _ (currentStart + aNumber - 1) min: self size.
		putativeLine _ self copyFrom: currentStart to: putativeLast.
		(crPosition _ putativeLine indexOf: Character cr) > 0 ifTrue:
			[putativeLast _ currentStart + crPosition - 1.
			putativeLine _ self copyFrom: currentStart to: putativeLast].
		currentLast _ putativeLast == self size
			ifTrue:
				[putativeLast]
			ifFalse:
				[currentStart + putativeLine lastSpacePosition - 1].
		currentLast <= currentStart ifTrue:
			["line has NO spaces; baleout!!"
			currentLast _ putativeLast].
		listOfLines add: (self copyFrom: currentStart to: currentLast) withBlanksTrimmed].

	listOfLines size > 0 ifFalse: [^ ''].
	resultString _ listOfLines first.
	2 to: listOfLines size do:
		[:i | resultString _ resultString, String cr, (listOfLines at: i)].
	^ resultString

"#(5 7 20) collect:
	[:i | 'Fred the bear went down to the brook to read his book in silence' withNoLineLongerThan: i]"! !

!String methodsFor: 'converting' stamp: 'ls 8/20/1998 10:43'!
withSeparatorsCompacted
	"replace each sequences of whitespace by a single space character"
	| out pos textEnd |

	self isEmpty ifTrue: [ ^self ].

	out _ WriteStream on: (String new: self size).
	pos _ 1.   "current position in a scan through aString"


	"handle the case of initial separators"
	self first isSeparator ifTrue: [
		out nextPut: Character space.
		pos _ self indexOfAnyOf: CSNonSeparators ifAbsent: [ self size + 1 ] ].


	"central loop: handle a segment of text, followed possibly by a segment of whitespace"
	[ pos <= self size ] whileTrue: [ 
		"handle a segment of text..."

		textEnd _ self 
			indexOfAnyOf: CSSeparators
			startingAt: pos 
			ifAbsent: [ self size + 1 ].

		textEnd _ textEnd - 1.
		out nextPutAll: (self copyFrom: pos to: textEnd).
		pos _ textEnd + 1.

		pos <= self size ifTrue: [
			pos _ self 
				indexOfAnyOf: CSNonSeparators
				startingAt: pos
				ifAbsent: [ self size + 1 ].

			out nextPut: Character space  ] ].

	^out contents! !

!String methodsFor: 'converting' stamp: 'jm 6/10/2008 00:11'!
withoutLeadingBlanks
	"Return a copy of the receiver from which leading blanks have been trimmed."
	"' 	foo' withoutLeadingBlanks"

	| first |
	first _ self findFirst: [:c | c isSeparator not].
	first = 0 ifTrue: [^ ''].  "no non-separator character"
	^ self copyFrom: first to: self size
! !

!String methodsFor: 'converting' stamp: 'sw 1/8/1999 14:45'!
withoutLeadingDigits
	"Answer the portion of the receiver that follows any leading series of digits and blanks.  If the receiver consists entirely of digits and blanks, return an empty string"
	| firstNonDigit |
	firstNonDigit _ (self findFirst: [:m | m isDigit not and: [m ~~ $ ]]).
	^ firstNonDigit > 0
		ifTrue:
			[self copyFrom: firstNonDigit  to: self size]
		ifFalse:
			['']

"
'234Whoopie' withoutLeadingDigits
' 4321 BlastOff!!' withoutLeadingDigits
'wimpy' withoutLeadingDigits
'  89Ten ' withoutLeadingDigits
'78 92' withoutLeadingDigits
"
! !

!String methodsFor: 'converting' stamp: 'bf 11/24/1998 19:58'!
withoutTrailingBlanks
	"Return a copy of the receiver from which trailing blanks have been trimmed."

	| last |
	last _ self findLast: [:c | c isSeparator not].
	last = 0 ifTrue: [^ ''].  "no non-separator character"
	^ self copyFrom: 1 to: last

	" ' abc  d   ' withoutTrailingBlanks"
! !

!String methodsFor: 'converting'!
withoutTrailingDigits
	"Answer the portion of the receiver that precedes any trailing series of digits and blanks.  If the receiver consists entirely of digits and blanks, return an empty string"
	| firstDigit |
	firstDigit _ (self findFirst: [:m | m isDigit or: [m == $ ]]).
	^ firstDigit > 0
		ifTrue:
			[self copyFrom: 1   to: firstDigit-1]
		ifFalse:
			[self]

"
'Whoopie234' withoutTrailingDigits
' 4321 BlastOff!!' withoutLeadingDigits
'wimpy' withoutLeadingDigits
'  89Ten ' withoutLeadingDigits
'78 92' withoutLeadingDigits
"
! !


!String methodsFor: 'displaying' stamp: 'jm 5/30/2003 13:17'!
display
	"Display the receiver on the Display."

	self displayOn: Display at: 0@0.
! !

!String methodsFor: 'displaying' stamp: 'jm 5/25/2003 11:58'!
displayAt: aPoint 
	"Display the receiver at the given point."

	self displayOn: Display at: aPoint.
! !

!String methodsFor: 'displaying' stamp: 'jm 5/25/2003 11:57'!
displayOn: aForm
	"Display the receiver on the given Form."

	self displayOn: aForm at: 0@0.
! !

!String methodsFor: 'displaying' stamp: 'jm 5/25/2003 12:00'!
displayOn: aForm at: aPoint 
	"Display myself at the given point on the given Form."

	(self asDisplayText
		foregroundColor: Color black
		backgroundColor: Color white)
			displayOn: aForm at: aPoint.
! !

!String methodsFor: 'displaying' stamp: 'ee 4/29/2009 10:29'!
displayProgressAt: aPoint from: minVal to: maxVal during: workBlock
	"Display this string as a caption over a progress bar while workBlock is evaluated.

EXAMPLE (Select next 6 lines and Do It)
'Now here''s some Real Progress'
	displayProgressAt: Sensor cursorPoint
	from: 0 to: 10
	during: [:bar |
	1 to: 10 do: [:x | bar value: x.
			(Delay forMilliseconds: 500) wait]].

HOW IT WORKS (Try this in any other language :-)
Since your code (the last 2 lines in the above example) is in a block,
this method gets control to display its heading before, and clean up
the screen after, its execution.
The key, though, is that the block is supplied with an argument,
named 'bar' in the example, which will update the bar image every
it is sent the message value: x, where x is in the from:to: range.
"
	| delta savedArea captionText textFrame barFrame outerFrame result range lastW w |
	barFrame _ aPoint - (75@10) corner: aPoint + (75@10).
	captionText _ DisplayText text: self asUTF8 asText allBold.
	captionText
		foregroundColor: Color black
		backgroundColor: Color white.
	textFrame _ captionText boundingBox insetBy: -4.
	textFrame _ textFrame align: textFrame bottomCenter
					with: barFrame topCenter + (0@2).
	outerFrame _ barFrame merge: textFrame.
	delta _ outerFrame amountToTranslateWithin: Display boundingBox.
	barFrame _ barFrame translateBy: delta.
	textFrame _ textFrame translateBy: delta.
	outerFrame _ outerFrame translateBy: delta.
	savedArea _ Form fromDisplay: outerFrame.
	Display fillBlack: barFrame; fillWhite: (barFrame insetBy: 2).
	Display fillBlack: textFrame; fillWhite: (textFrame insetBy: 2).
	captionText displayOn: Display at: textFrame topLeft + (4@4).
	range _ maxVal = minVal ifTrue: [1] ifFalse: [maxVal - minVal].  "Avoid div by 0"
	lastW _ 0.
	result _ workBlock value:  "Supply the bar-update block for evaluation in the work block"
		[:barVal |
		w _ ((barFrame width-4) asFloat * ((barVal-minVal) asFloat / range min: 1.0)) asInteger.
		w ~= lastW ifTrue: [
			Display fill: (barFrame topLeft + (2@2) extent: w@16) fillColor: Color gray.
			lastW _ w]].
	savedArea displayOn: Display at: outerFrame topLeft.
	^ result
! !


!String methodsFor: 'printing'!
isLiteral

	^true! !

!String methodsFor: 'printing' stamp: 'sma 6/1/2000 09:48'!
printOn: aStream 
	"Print inside string quotes, doubling inbedded quotes."

	self storeOn: aStream! !

!String methodsFor: 'printing'!
storeOn: aStream 
	"Print inside string quotes, doubling inbedded quotes."
	| x |
	aStream nextPut: $'.
	1 to: self size do:
		[:i |
		aStream nextPut: (x _ self at: i).
		x == $' ifTrue: [aStream nextPut: x]].
	aStream nextPut: $'! !


!String methodsFor: 'internet' stamp: 'sma 3/11/2000 20:40'!
isoToSqueak
	^ self collect: [:each | each isoToSqueak]! !

!String methodsFor: 'internet' stamp: 'jm 10/20/2004 12:27'!
replaceHtmlCharRefs

	| outString outPos pos ampIndex newOutPos scIndex special specialValue |
	outString _ String new: self size.
	outPos _ 0.
	pos _ 1.
	[pos <= self size] whileTrue: [
		"read up to the next ampersand"
		ampIndex _ self indexOf: $& startingAt: pos ifAbsent: [0].
		ampIndex = 0 ifTrue: [
			pos = 1 ifTrue: [^ self] ifFalse: [ampIndex _ self size + 1]].

		newOutPos _ outPos + ampIndex - pos.
		outString
			replaceFrom: outPos + 1
			to: newOutPos
			with: self
			startingAt: pos.
		outPos _ newOutPos.
		pos _ ampIndex.

		ampIndex <= self size ifTrue: [
			"find the $;"
			scIndex _ self indexOf: $; startingAt: ampIndex ifAbsent: [self size + 1].
			special _ self copyFrom: ampIndex + 1 to: scIndex - 1.
			specialValue _ String valueOfHtmlEntity: special.
			specialValue
				ifNil: [
					"not a recognized entity. wite it back"
					scIndex > self size ifTrue: [scIndex _ self size].
					newOutPos _ outPos + scIndex - ampIndex + 1.
					outString
						replaceFrom: outPos+1
						to: newOutPos
						with: self
						startingAt: ampIndex.
					outPos _ newOutPos]
				ifNotNil: [
					outPos _ outPos + 1.
					outString at: outPos put: specialValue].
			pos _ scIndex + 1]].
	^ outString copyFrom: 1 to: outPos
! !

!String methodsFor: 'internet' stamp: 'jm 5/17/2005 20:38'!
replaceHtmlHexChars
	"Replace embedded hex characters such as '%20' (a space character) in a string formatted for HTML."

	| in out ch d1 d2 |
	in _ ReadStream on: self.
	out _ WriteStream on: (String new: self size).
	[in atEnd] whileFalse: [
		ch _ in next.
		((ch = $%) and: [in position + 2 <= self size]) ifTrue: [
			d1 _ in next digitValue.
			d2 _ in next digitValue.
			((d1 >= 0) & (d1 <= 15) & (d2 >= 0) & (d2 <= 15))
				ifTrue: [ch _ ((d1 * 16) + d2) asCharacter]
				ifFalse: [in skip: -2]].
		out nextPut: ch].
	^ out contents

! !

!String methodsFor: 'internet' stamp: 'ls 10/27/1998 00:52'!
withSqueakLineEndings
	"assume the string is textual, and that CR, LF, and CRLF are all 
	valid line endings.  Replace each occurence with a single CR"
	| cr lf input c crlf inPos outPos outString lineEndPos newOutPos |
	cr _ Character cr.
	lf _ Character linefeed.
	crlf _ CharacterSet new.
	crlf add: cr; add: lf.

	inPos _ 1.
	outPos _ 1.
	outString _
 String new: self size.

	[ lineEndPos _ self indexOfAnyOf: crlf startingAt: inPos ifAbsent: [0].
		lineEndPos ~= 0 ] whileTrue: [
			newOutPos _ outPos + (lineEndPos - inPos + 1).
			outString replaceFrom: outPos to: newOutPos - 2 with: self startingAt: inPos.
			outString at: newOutPos-1 put: cr.
			outPos _ newOutPos.

			((self at: lineEndPos) = cr and: [ lineEndPos < self size and: [ (self at: lineEndPos+1) = lf ] ]) ifTrue: [
				"CRLF ending"
				inPos _ lineEndPos + 2 ]
			ifFalse: [ 
				"CR or LF ending"
				inPos _ lineEndPos + 1 ]. ].

	"no more line endings.  copy the rest"
	newOutPos _ outPos + (self size - inPos + 1).
	outString replaceFrom: outPos to: newOutPos-1 with: self startingAt: inPos.

	^outString copyFrom: 1 to: newOutPos-1
	! !


!String methodsFor: 'testing' stamp: 'sw 11/5/1998 17:41'!
lastSpacePosition
	"Answer the character position of the final space or other separator character in the receiver, and 0 if none"
	self size to: 1 by: -1 do:
		[:i | ((self at: i) isSeparator) ifTrue: [^ i]].
	^ 0

"
'fred the bear' lastSpacePosition
'ziggie' lastSpacePosition
'elvis ' lastSpacePosition
'wimpy  ' lastSpacePosition
'' lastSpacePosition
"! !


!String methodsFor: 'paragraph support' stamp: 'RAA 8/30/1998 15:20'!
indentationIfBlank: aBlock
	"Answer the number of leading tabs in the receiver.  If there are
	 no visible characters, pass the number of tabs to aBlock and return its value."

	| reader leadingTabs lastSeparator cr tab ch |
	cr _ Character cr.
	tab _ Character tab.
	reader _ ReadStream on: self.
	leadingTabs _ 0.
	[reader atEnd not and: [(ch _ reader next) == tab]]
		whileTrue: [leadingTabs _ leadingTabs + 1].
	lastSeparator _ leadingTabs + 1.
	[reader atEnd not and: [ch isSeparator and: [ch ~~ cr]]]
		whileTrue: [lastSeparator _ lastSeparator + 1. ch _ reader next].
	lastSeparator = self size | (ch == cr)
		ifTrue: [^aBlock value: leadingTabs].
	^leadingTabs! !


!String methodsFor: 'system primitives' stamp: 'jm 2/15/98 18:07'!
compare: string1 with: string2 collated: order
	"Return 1, 2 or 3, if string1 is <, =, or > string2, with the collating order of characters given by the order array."

	| len1 len2 c1 c2 |
	<primitive: 235>
	self var: #string1 declareC: 'unsigned char *string1'.
	self var: #string2 declareC: 'unsigned char *string2'.
	self var: #order declareC: 'unsigned char *order'.

	len1 _ string1 size.
	len2 _ string2 size.
	1 to: (len1 min: len2) do:
		[:i |
		c1 _ order at: (string1 basicAt: i) + 1.
		c2 _ order at: (string2 basicAt: i) + 1.
		c1 = c2 ifFalse: 
			[c1 < c2 ifTrue: [^ 1] ifFalse: [^ 3]]].
	len1 = len2 ifTrue: [^ 2].
	len1 < len2 ifTrue: [^ 1] ifFalse: [^ 3].
! !

!String methodsFor: 'system primitives' stamp: 'di 11/15/1998 16:27'!
findSubstring: key in: body startingAt: start matchTable: matchTable
	"Answer the index in the string body at which the substring key first occurs, at or beyond start.  The match is determined using matchTable, which can be used to effect, eg, case-insensitive matches.  If no match is found, zero will be returned.

	The algorithm below is not optimum -- it is intended to be translated to C which will go so fast that it wont matter."
	| index |
	<primitive: 246>
	self var: #key declareC: 'unsigned char *key'.
	self var: #body declareC: 'unsigned char *body'.
	self var: #matchTable declareC: 'unsigned char *matchTable'.

	key size = 0 ifTrue: [^ 0].
	start to: body size - key size + 1 do:
		[:startIndex |
		index _ 1.
			[(matchTable at: (body at: startIndex+index-1) asciiValue + 1)
				= (matchTable at: (key at: index) asciiValue + 1)]
				whileTrue:
				[index = key size ifTrue: [^ startIndex].
				index _ index+1]].
	^ 0
"
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 1 matchTable: CaseSensitiveOrder 1
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 2 matchTable: CaseSensitiveOrder 7
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 8 matchTable: CaseSensitiveOrder 0
' ' findSubstring: 'abc' in: 'abcdefABcd' startingAt: 2 matchTable: CaseSensitiveOrder 0
' ' findSubstring: 'abc' in: 'abcdefABcd' startingAt: 2 matchTable: CaseInsensitiveOrder 7
"! !

!String methodsFor: 'system primitives' stamp: 'di 4/3/1999 00:37'!
numArgs
	"Answer either the number of arguments that the receiver would take if considered a selector.  Answer -1 if it couldn't be a selector.  Note that currently this will answer -1 for anything begining with an uppercase letter even though the system will accept such symbols as selectors.  It is intended mostly for the assistance of spelling correction."

	| firstChar numColons |
	firstChar _ self at: 1.
	firstChar isLetter ifTrue:
		[ firstChar isUppercase ifTrue: [ ^ -1 ].
		numColons _ 0. 
		self do: [ :ch |
			ch tokenish ifFalse: [ ^ -1 ].
			(ch = $:) ifTrue: [numColons _ numColons + 1] ].
		^ (self last = $:)
			ifTrue: [ numColons > 0 ifTrue: [ numColons ] ifFalse: [ -1 ] ]
			ifFalse: [ numColons > 0 ifTrue: [ -1 ] ifFalse: [ 0 ] ] ].
	firstChar isSpecial ifTrue:
		[self size = 1 ifTrue: [^ 1].
		2 to: self size do: [:i | (self at: i) isSpecial ifFalse: [^ -1]].
		^ 1].
	^ -1.! !


!String methodsFor: 'private'!
correctAgainstEnumerator: wordBlock continuedFrom: oldCollection
	"The guts of correction, instead of a wordList, there is a block that should take abnother block and enumerate over some list with it."

	| choices scoreMin results score |
	scoreMin _ self size // 2 min: 3.
	oldCollection isNil
		ifTrue: [ choices _ SortedCollection sortBlock: [ :x :y | x value > y value ] ]
		ifFalse: [ choices _ oldCollection ].
	wordBlock isNil
		ifTrue:
			[ results _ OrderedCollection new.
			1 to: (5 min: choices size) do: [ :i | results add: (choices at: i) key ] ]
		ifFalse:
			[ wordBlock value: [ :word |
				(score _ self alike: word) >= scoreMin ifTrue:
					[ choices add: (Association key: word value: score).
						(choices size >= 5) ifTrue: [ scoreMin _ (choices at: 5) value] ] ].
			results _ choices ].
	^ results! !

!String methodsFor: 'private'!
replaceFrom: start to: stop with: replacement startingAt: repStart 
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."
	<primitive: 105>
	super replaceFrom: start to: stop with: replacement startingAt: repStart! !

!String methodsFor: 'private'!
stringhash
	^self hash! !


!String methodsFor: '*JSON-writing' stamp: 'tonyg 8/17/2005 16:21'!
jsonWriteOn: aStream
	| replacement |
	aStream nextPut: $".
	self do: [:ch |
		replacement _ Json escapeForCharacter: ch.
		replacement
			ifNil: [ aStream nextPut: ch ]
			ifNotNil: [ aStream nextPut: $\; nextPut: replacement ].
	].
	aStream nextPut: $".
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

String class
	instanceVariableNames: ''!

!String class methodsFor: 'instance creation' stamp: 'jm 5/6/1998 18:39'!
cr
	"Answer a string containing a single carriage return character."

	^ self with: Character cr
! !

!String class methodsFor: 'instance creation' stamp: 'ls 9/10/1998 22:29'!
crlf
	"Answer a string containing a carriage return and a linefeed."

	^ self with: Character cr with: Character lf
! !

!String class methodsFor: 'instance creation' stamp: 'jm 6/27/2008 13:23'!
fromBytes: aCollection
	"Answer a new String containing the given sequence of bytes."
	"self fromBytes: (65 to: 70)"

	| s i |
	s _ self new: aCollection size.
	i _ 0.
	aCollection do: [:byte | s basicAt: (i _ i + 1) put: byte].
	^ s
! !

!String class methodsFor: 'instance creation' stamp: 'di 1/14/98 10:26'!
fromString: aString 
	"Answer an instance of me that is a copy of the argument, aString."
	
	^ aString copyFrom: 1 to: aString size! !

!String class methodsFor: 'instance creation'!
readFrom: inStream
	"Answer an instance of me that is determined by reading the stream, 
	inStream. Embedded double quotes become the quote Character."

	| outStream char done |
	outStream _ WriteStream on: (String new: 16).
	"go to first quote"
	inStream skipTo: $'.
	done _ false.
	[done or: [inStream atEnd]]
		whileFalse: 
			[char _ inStream next.
			char = $'
				ifTrue: 
					[char _ inStream next.
					char = $'
						ifTrue: [outStream nextPut: char]
						ifFalse: [done _ true]]
				ifFalse: [outStream nextPut: char]].
	^outStream contents! !

!String class methodsFor: 'instance creation' stamp: 'sw 6/15/1999 22:59'!
tab
	"Answer a string containing a single tab character."

	^ self with: Character tab
! !


!String class methodsFor: 'examples'!
example
	"To see the string displayed at the cursor point, execute this expression
	and select a point by pressing a mouse button."

	'this is some text' displayOn: Display at: Sensor waitButton! !


!String class methodsFor: 'initialization' stamp: 'di 9/20/1998 14:09'!
initialize  "String initialize"
	| order |
	AsciiOrder _ (0 to: 255) as: ByteArray.

	CaseInsensitiveOrder _ AsciiOrder copy.
	($a to: $z) do:
		[:c | CaseInsensitiveOrder at: c asciiValue + 1
				put: (CaseInsensitiveOrder at: c asUppercase asciiValue +1)].

	"Case-sensitive compare sorts space, digits, letters, all the rest..."
	CaseSensitiveOrder _ ByteArray new: 256 withAll: 255.
	order _ -1.
	' 0123456789' do:  "0..10"
		[:c | CaseSensitiveOrder at: c asciiValue + 1 put: (order _ order+1)].
	($a to: $z) do:     "11-64"
		[:c | CaseSensitiveOrder at: c asUppercase asciiValue + 1 put: (order _ order+1).
		CaseSensitiveOrder at: c asciiValue + 1 put: (order _ order+1)].
	1 to: CaseSensitiveOrder size do:
		[:i | (CaseSensitiveOrder at: i) = 255 ifTrue:
			[CaseSensitiveOrder at: i put: (order _ order+1)]].
	order = 255 ifFalse: [self error: 'order problem'].

	"a table for translating to lower case"
	LowercasingTable _ String new: 256.
	Character allCharacters do: [ :c |
		LowercasingTable at: (c asciiValue+1) put: c asLowercase ].	

	"CR and LF--characters that terminate a line"
	CSLineEnders _ CharacterSet empty.
	CSLineEnders add: Character cr.
	CSLineEnders add: Character lf.

 	"separators and non-separators"
	CSSeparators _ CharacterSet separators.
	CSNonSeparators _ CSSeparators complement.! !

!String class methodsFor: 'initialization' stamp: 'jm 5/24/2003 13:52'!
initializeHtmlEntities
	"String initializeHtmlEntities"

	HtmlEntities _ (Dictionary new: 128)
		at: 'amp'	put: $&;
		at: 'lt'		put: $<;
		at: 'gt'		put: $>;
		at: 'quot'	put: $";
		at: 'euro'	put: (Character value: 219);
		yourself.

	#('nbsp' 'iexcl' 'cent' 'pound' 'curren' 'yen' 'brvbar' 'sect' 'uml' 'copy' 'ordf' 'laquo' 'not' 'shy' 'reg' 'hibar' 'deg' 'plusmn' 'sup2' 'sup3' 'acute' 'micro' 'para' 'middot' 'cedil' 'sup1' 'ordm' 'raquo' 'frac14' 'frac12' 'frac34' 'iquest' 'Agrave' 'Aacute' 'Acirc' 'Atilde' 'Auml' 'Aring' 'AElig' 'Ccedil' 'Egrave' 'Eacute' 'Ecirc' 'Euml' 'Igrave' 'Iacute' 'Icirc' 'Iuml' 'ETH' 'Ntilde' 'Ograve' 'Oacute' 'Ocirc' 'Otilde' 'Ouml' 'times' 'Oslash' 'Ugrave' 'Uacute' 'Ucirc' 'Uuml' 'Yacute' 'THORN' 'szlig' 'agrave' 'aacute' 'acirc' 'atilde' 'auml' 'aring' 'aelig' 'ccedil' 'egrave' 'eacute' 'ecirc' 'euml' 'igrave' 'iacute' 'icirc' 'iuml' 'eth' 'ntilde' 'ograve' 'oacute' 'ocirc' 'otilde' 'ouml' 'divide' 'oslash' 'ugrave' 'uacute' 'ucirc' 'uuml' 'yacute' 'thorn' 'yuml' ) withIndexDo: [:each :index | HtmlEntities at: each put: (index + 159) asCharacter isoToSqueak]! !


!String class methodsFor: 'primitives' stamp: 'ls 9/14/1998 07:50'!
findFirstInString: aString  inSet: inclusionMap  startingAt: start
	| i stringSize |
	<primitive: 244>

	self var: #aString declareC: 'unsigned char *aString'.
	self var: #inclusionMap  declareC: 'char *inclusionMap'.

	inclusionMap size ~= 256 ifTrue: [ ^0 ].

	i _ start.
	stringSize _ aString size.
	[ i <= stringSize and: [ (inclusionMap at: (aString at: i) asciiValue+1) = 0 ] ] whileTrue: [ 
		i _ i + 1 ].

	i > stringSize ifTrue: [ ^0 ].
	^i! !

!String class methodsFor: 'primitives' stamp: 'jm 10/12/1998 18:21'!
indexOfAscii: anInteger inString: aString startingAt: start

	| stringSize |
	<primitive: 245>

	self var: #aCharacter declareC: 'int anInteger'.
	self var: #aString declareC: 'unsigned char *aString'.

	stringSize _ aString size.
	start to: stringSize do: [:pos |
		(aString at: pos) asciiValue = anInteger ifTrue: [^ pos]].

	^ 0
! !

!String class methodsFor: 'primitives' stamp: 'ls 8/15/1998 12:15'!
translate: aString from: start  to: stop  table: table
	"translate the characters in the string by the given table, in place"
	<primitive: 243>
	self var: #table  declareC: 'unsigned char *table'.
	self var: #aString  declareC: 'unsigned char *aString'.

	start to: stop do: [ :i |
		aString at: i put: (table at: (aString at: i) asciiValue+1) ]! !


!String class methodsFor: 'internet' stamp: 'sma 3/11/2000 20:25'!
valueOfHtmlEntity: specialEntity 
	"Please note: the 'min: 255' is a crude fix to silently ignore unicode characters."

	(specialEntity beginsWith: '#')
		ifTrue:
			[^ ((specialEntity
				copyFrom: 2
				to: specialEntity size) asNumber min: 255) asCharacter isoToSqueak].
	^ HtmlEntities at: specialEntity ifAbsent: [nil]! !


String initialize!
