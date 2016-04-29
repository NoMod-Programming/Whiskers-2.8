Magnitude subclass: #Character
	instanceVariableNames: 'value '
	classVariableNames: 'CharacterTable '
	poolDictionaries: ''
	category: 'Collections-Text'!
!Character commentStamp: '<historical>' prior: 0!
I represent a character by storing its associated ASCII code (extended to 256 codes). My instances are created uniquely, so that all instances of a character ($R, for example) are identical.!


!Character methodsFor: 'accessing'!
asciiValue
	"Answer the value of the receiver that represents its ascii encoding."

	^value! !

!Character methodsFor: 'accessing'!
digitValue
	"Answer 0-9 if the receiver is $0-$9, 10-35 if it is $A-$Z, and < 0 
	otherwise. This is used to parse literal numbers of radix 2-36."

	value <= $9 asciiValue 
		ifTrue: [^value - $0 asciiValue].
	value >= $A asciiValue 
		ifTrue: [value <= $Z asciiValue ifTrue: [^value - $A asciiValue + 10]].
	^ -1! !


!Character methodsFor: 'comparing'!
< aCharacter 
	"Answer true if the receiver's value < aCharacter's value."

	^self asciiValue < aCharacter asciiValue! !

!Character methodsFor: 'comparing'!
= aCharacter 
	"Primitive. Answer true if the receiver and the argument are the same
	object (have the same object pointer) and false otherwise. Optional. See
	Object documentation whatIsAPrimitive."

	<primitive: 110>
	^self == aCharacter! !

!Character methodsFor: 'comparing'!
> aCharacter 
	"Answer true if the receiver's value > aCharacter's value."

	^self asciiValue > aCharacter asciiValue! !

!Character methodsFor: 'comparing'!
hash
	"Hash is reimplemented because = is implemented."

	^value! !


!Character methodsFor: 'testing'!
isAlphaNumeric
	"Answer whether the receiver is a letter or a digit."

	^self isLetter or: [self isDigit]! !

!Character methodsFor: 'testing' stamp: 'EMP 4/26/2016 15:31'!
isDigit
	"Answer whether the receiver is a digit."

	^(value >= 48 and: [value <= 57]) or: [value = 46]! !

!Character methodsFor: 'testing'!
isLetter
	"Answer whether the receiver is a letter."

	^(8r141 <= value and: [value <= 8r172])
		or: [8r101 <= value and: [value <= 8r132]]! !

!Character methodsFor: 'testing'!
isLowercase
	"Answer whether the receiver is a lowercase letter.
	(The old implementation answered whether the receiver is not an uppercase letter.)"

	^8r141 <= value and: [value <= 8r172]! !

!Character methodsFor: 'testing' stamp: 'jm 11/9/2006 09:16'!
isSafeForHTTP
	"whether a character is 'safe', or needs to be escaped when used, eg, in a URL"
	^self isAlphaNumeric or: [ '.~-_/' includes: self ]! !

!Character methodsFor: 'testing'!
isSeparator
	"Answer whether the receiver is one of the separator characters--space, 
	cr, tab, line feed, or form feed."

	value = 32 ifTrue: [^true].	"space"
	value = 13 ifTrue: [^true].	"cr"
	value = 9 ifTrue: [^true].	"tab"
	value = 10 ifTrue: [^true].	"line feed"
	value = 12 ifTrue: [^true].	"form feed"
	^false! !

!Character methodsFor: 'testing' stamp: 'di 4/3/1999 00:38'!
isSpecial
	"Answer whether the receiver is one of the special characters"

	^'+-/\*~<>=@,%|&?!!' includes: self! !

!Character methodsFor: 'testing'!
isUppercase
	"Answer whether the receiver is an uppercase letter.
	(The old implementation answered whether the receiver is not a lowercase letter.)"

	^8r101 <= value and: [value <= 8r132]! !

!Character methodsFor: 'testing'!
isVowel
	"Answer whether the receiver is one of the vowels, AEIOU, in upper or 
	lower case."

	^'AEIOU' includes: self asUppercase! !

!Character methodsFor: 'testing'!
tokenish
	"Answer whether the receiver is a valid token-character--letter, digit, or 
	colon."

	^self isLetter or: [self isDigit or: [self = $:]]! !


!Character methodsFor: 'copying'!
copy
	"Answer with the receiver because Characters are unique."! !

!Character methodsFor: 'copying'!
deepCopy
	"Answer with the receiver because Characters are unique."! !


!Character methodsFor: 'printing'!
hex
	^ String with: ('0123456789ABCDEF' at: value//16+1)
			with:  ('0123456789ABCDEF' at: value\\16+1)! !

!Character methodsFor: 'printing'!
isLiteral

	^true! !

!Character methodsFor: 'printing'!
printOn: aStream

	aStream nextPut: $$.
	aStream nextPut: self! !

!Character methodsFor: 'printing'!
storeOn: aStream
	"Character literals are preceded by '$'."

	aStream nextPut: $$; nextPut: self! !


!Character methodsFor: 'converting'!
asCharacter
	"Answer the receiver itself."

	^self! !

!Character methodsFor: 'converting'!
asInteger
	"Answer the value of the receiver."

	^value! !

!Character methodsFor: 'converting'!
asLowercase
	"If the receiver is uppercase, answer its matching lowercase Character."
	
	(8r101 <= value and: [value <= 8r132])  "self isUppercase"
		ifTrue: [^ Character value: value + 8r40]
		ifFalse: [^ self]! !

!Character methodsFor: 'converting' stamp: 'sma 3/11/2000 17:21'!
asString
	^ String with: self! !

!Character methodsFor: 'converting'!
asSymbol 
	"Answer a Symbol consisting of the receiver as the only element."

	^Symbol internCharacter: self! !

!Character methodsFor: 'converting'!
asUppercase
	"If the receiver is lowercase, answer its matching uppercase Character."
	
	(8r141 <= value and: [value <= 8r172])  "self isLowercase"
		ifTrue: [^ Character value: value - 8r40]
		ifFalse: [^ self]! !

!Character methodsFor: 'converting' stamp: 'sma 3/15/2000 22:57'!
isoToSqueak
	"Convert receiver from iso8895-1 (actually CP1252) to mac encoding.
	Does not do lf/cr conversion!! Characters not available in MacRoman
	encoding have been remapped to their base characters or to $?."

	value < 128 ifTrue: [^ self].
	^ Character value: (#(
		219 63 226 196 227 201 160 224 246 228 83 220 206 63 90 63		"80-8F"
		63 212 213 210 211 165 208 209 247 170 115 221 207 63 122 217		"90-9F"
		202 193 162 163 63 180 124 164 172 169 187 199 194 45 168 248	 	"A0-AF"
		161 177 50 51 171 181 166 225 252 49 188 200 63 63 63 192 			"B0-BF"
		203 231 229 204 128 129 174 130 233 131 230 232 237 234 235 236 	"C0-CF"
		63 132 241 238 239 205 133 42 175 244 242 243 134 89 63 167	 	"D0-DF"
		136 135 137 139 138 140 190 141 143 142 144 145 147 146 148 149		"E0-EF"
		63 150 152 151 153 155 154 214 191 157 156 158 159 121 63 216		"F0-FF"
	) at: value - 127)! !

!Character methodsFor: 'converting'!
to: other
	"Answer with a collection in ascii order -- $a to: $z"
	^ (self asciiValue to: other asciiValue) collect:
				[:ascii | Character value: ascii]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Character class
	instanceVariableNames: ''!

!Character class methodsFor: 'class initialization'!
initialize
	"Create the table of unique Characters. This code is not shown so that the
	user can not destroy the system by trying to recreate the table."! !


!Character class methodsFor: 'instance creation' stamp: 'ls 8/15/1998 06:56'!
allCharacters
	^ (0 to: 255)
		collect: [:v | Character value: v]

	
! !

!Character class methodsFor: 'instance creation'!
digitValue: x 
	"Answer the Character whose digit value is x. For example, answer $9 for 
	x=9, $0 for x=0, $A for x=10, $Z for x=35."

	| index |
	index _ x asInteger.
	^CharacterTable at: 
		(index < 10
			ifTrue: [48 + index]
			ifFalse: [55 + index])
		+ 1! !

!Character class methodsFor: 'instance creation'!
new
	"Creating new characters is not allowed."

	self error: 'cannot create new characters'! !

!Character class methodsFor: 'instance creation'!
separators
	^ #(32 "space"
		13 "cr"
		9 "tab"
		10 "line feed"
		12 "form feed")
		collect: [:v | Character value: v]

	
! !

!Character class methodsFor: 'instance creation'!
value: anInteger 
	"Answer the Character whose value is anInteger."

	^CharacterTable at: anInteger + 1! !


!Character class methodsFor: 'constants'!
backspace
	"Answer the Character representing a backspace."

	^self value: 8! !

!Character class methodsFor: 'constants'!
cr
	"Answer the Character representing a carriage return."

	^self value: 13! !

!Character class methodsFor: 'constants'!
enter
	"Answer the Character representing enter."

	^self value: 3! !

!Character class methodsFor: 'constants' stamp: 'ls 9/8/1998 22:15'!
lf
	"Answer the Character representing a linefeed."

	^self value: 10! !

!Character class methodsFor: 'constants'!
linefeed
	"Answer the Character representing a linefeed."

	^self value: 10! !

!Character class methodsFor: 'constants'!
newPage
	"Answer the Character representing a form feed."

	^self value: 12! !

!Character class methodsFor: 'constants'!
space
	"Answer the Character representing a space."

	^self value: 32! !

!Character class methodsFor: 'constants'!
tab
	"Answer the Character representing a tab."

	^self value: 9! !


Character initialize!
