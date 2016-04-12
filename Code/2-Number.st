Magnitude subclass: #Number
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Kernel-Numbers'!
!Number commentStamp: '<historical>' prior: 0!
I am an abstract representation of a number. My subclasses Float, Fraction, and Integer, and their subclasses, provide concrete representations of a numeric quantity.

All my subclasses participate in a simple type coercion mechanism that supports mixed-mode arithmetic and comparisons.  It works as follows:  If
	self<typeA> op: arg<typeB>
fails because of incompatible types, then it is retried in the following guise:
	(arg adaptTypeA: self) op: arg adaptToTypeA.
This gives the arg of typeB an opportunity to resolve the incompatibility, knowing exactly what two types are involved.  If self is more general, then arg will be converted, and viceVersa.  This mechanism is extensible to any new number classes that one might wish to add to Squeak.  The only requirement is that every subclass of Number must support a pair of conversion methods specific to each of the other subclasses of Number.!


!Number methodsFor: 'arithmetic'!
* aNumber 
	"Answer the result of multiplying the receiver by aNumber."

	self subclassResponsibility! !

!Number methodsFor: 'arithmetic'!
+ aNumber 
	"Answer the sum of the receiver and aNumber."

	self subclassResponsibility! !

!Number methodsFor: 'arithmetic'!
- aNumber 
	"Answer the difference between the receiver and aNumber."

	self subclassResponsibility! !

!Number methodsFor: 'arithmetic'!
/ aNumber 
	"Answer the result of dividing the receiver by aNumber."

	self subclassResponsibility! !

!Number methodsFor: 'arithmetic'!
// aNumber 
	"Integer quotient defined by division with truncation toward negative 
	infinity. 9//4 = 2, -9//4 = -3. -0.9//0.4 = -3. \\ answers the remainder 
	from this division."

	^(self / aNumber) floor! !

!Number methodsFor: 'arithmetic'!
\\ aNumber 
	"modulo. Remainder defined in terms of //. Answer a Number with the 
	same sign as aNumber. e.g. 9\\4 = 1, -9\\4 = 3, 9\\-4 = -3, 0.9\\0.4 = 0.1."

	^self - (self // aNumber * aNumber)! !

!Number methodsFor: 'arithmetic'!
abs
	"Answer a Number that is the absolute value (positive magnitude) of the 
	receiver."

	self < 0
		ifTrue: [^self negated]
		ifFalse: [^self]! !

!Number methodsFor: 'arithmetic'!
negated
	"Answer a Number that is the negation of the receiver."

	^0 - self! !

!Number methodsFor: 'arithmetic'!
quo: aNumber 
	"Integer quotient defined by division with truncation toward zero. -9 quo: 
	4 = -2, -0.9 quo: 0.4 = -2. rem: answers the remainder from this division."

	^(self / aNumber) truncated! !

!Number methodsFor: 'arithmetic'!
reciprocal
	"Answer 1 divided by the receiver. Create an error notification if the 
	receiver is 0."

	self = 0
		ifTrue: [^self error: 'zero has no reciprocal']
		ifFalse: [^1 / self]! !

!Number methodsFor: 'arithmetic'!
rem: aNumber 
	"Remainder defined in terms of quo:. Answer a Number with the same 
	sign as self. e.g. 9 rem: 4 = 1, -9 rem: 4 = -1. 0.9 rem: 0.4 = 0.1."

	^self - ((self quo: aNumber) * aNumber)! !


!Number methodsFor: 'mathematical functions'!
arcCos 
	"The receiver is the cosine of an angle. Answer the angle measured in 
	radians."

	^self asFloat arcCos! !

!Number methodsFor: 'mathematical functions'!
arcSin
	"The receiver is the sine of an angle. Answer the angle measured in 
	radians."

	^self asFloat arcSin! !

!Number methodsFor: 'mathematical functions'!
arcTan
	"The receiver is the tangent of an angle. Answer the angle measured in 
	radians."

	^self asFloat arcTan! !

!Number methodsFor: 'mathematical functions' stamp: 'jsp 2/24/1999 15:20'!
arcTan: denominator
	"The receiver is the tangent of an angle. Answer the angle measured in 
	radians."

	^(self asFloat) arcTan: denominator.! !

!Number methodsFor: 'mathematical functions'!
cos
	"The receiver represents an angle measured in radians. Answer its cosine."

	^self asFloat cos! !

!Number methodsFor: 'mathematical functions'!
exp
	"Answer the exponential of the receiver as a floating point number."

	^self asFloat exp! !

!Number methodsFor: 'mathematical functions' stamp: 'jm 3/27/98 06:16'!
floorLog: radix
	"Answer the floor of the log base radix of the receiver."

	^ self asFloat floorLog: radix
! !

!Number methodsFor: 'mathematical functions' stamp: 'EMP 2/11/2016 14:27'!
fractionPart
	^ self - self integerPart! !

!Number methodsFor: 'mathematical functions' stamp: 'EMP 2/11/2016 14:27'!
integerPart
	^ self truncated! !

!Number methodsFor: 'mathematical functions'!
ln
	"Answer the natural log of the receiver."

	^self asFloat ln! !

!Number methodsFor: 'mathematical functions' stamp: 'di 9/8/1998 17:10'!
log
	"Answer the base-10 log of the receiver."

	^self asFloat log! !

!Number methodsFor: 'mathematical functions'!
log: aNumber 
	"Answer the log base aNumber of the receiver."

	^self ln / aNumber ln! !

!Number methodsFor: 'mathematical functions' stamp: 'RJ 3/15/1999 19:35'!
raisedTo: aNumber 
	"Answer the receiver raised to aNumber."

	aNumber isInteger ifTrue:
		["Do the special case of integer power"
		^ self raisedToInteger: aNumber].
	self < 0 ifTrue:
		[ self error: self printString, ' raised to a non-integer power' ].
	aNumber = 0 ifTrue: [^ 1].		"Special case of exponent=0"
	(self = 0) | (aNumber = 1) ifTrue:
		[^ self].						"Special case of exponent=1"
	^ (aNumber * self ln) exp		"Otherwise use logarithms"! !

!Number methodsFor: 'mathematical functions' stamp: 'RJ 3/15/1999 19:32'!
raisedToInteger: anInteger 
	"Answer the receiver raised to the power anInteger where the argument 
	must be a kind of Integer. This is a special case of raisedTo:."

	anInteger isInteger ifFalse:
		[^self error: 'raisedToInteger: only works for integral arguments'].
	anInteger = 0 ifTrue: [^ 1].
	(self = 0) | (anInteger = 1) ifTrue: [^ self].
	anInteger > 1 ifTrue:
		[^ (self * self raisedToInteger: anInteger // 2)
					* (self raisedToInteger: anInteger \\ 2)].
	^ (self raisedToInteger: anInteger negated) reciprocal! !

!Number methodsFor: 'mathematical functions'!
sin
	"The receiver represents an angle measured in radians. Answer its sine."

	^self asFloat sin! !

!Number methodsFor: 'mathematical functions'!
sqrt
	"Answer the square root of the receiver."

	^self asFloat sqrt! !

!Number methodsFor: 'mathematical functions'!
squared
	"Answer the receiver multipled by itself."

	^self * self! !

!Number methodsFor: 'mathematical functions'!
tan
	"The receiver represents an angle measured in radians. Answer its 
	tangent."

	^self asFloat tan! !


!Number methodsFor: 'truncation and round off'!
ceiling
	"Answer the integer nearest the receiver toward positive infinity."

	self <= 0.0
		ifTrue: [^self truncated]
		ifFalse: [^self negated floor negated]! !

!Number methodsFor: 'truncation and round off' stamp: 'di 2/19/98 21:58'!
detentBy: detent atMultiplesOf: grid snap: snap
	"Map all values that are within detent/2 of any multiple of grid to that multiple.  Otherwise, if snap is true, return self, meaning that the values in the dead zone will never be returned.  If snap is false, then expand the range between dead zones so that it covers the range between multiples of the grid, and scale the value by that factor."
	| r1 r2 |
	r1 _ self roundTo: grid.  "Nearest multiple of grid"
	(self roundTo: detent) = r1 ifTrue: [^ r1].  "Snap to that multiple..."
	snap ifTrue: [^ self].  "...or return self"

	r2 _ self < r1  "Nearest end of dead zone"
		ifTrue: [r1 - (detent asFloat/2)]
		ifFalse: [r1 + (detent asFloat/2)].
	"Scale values between dead zones to fill range between multiples"
	^ r1 + ((self - r2) * grid asFloat / (grid - detent))
"
	(170 to: 190 by: 2) collect: [:a | a detentBy: 10 atMultiplesOf: 90 snap: true] 	(170 to: 190 by: 2) collect: [:a | a detentBy: 10 atMultiplesOf: 90 snap: false]
	(3.9 to: 4.1 by: 0.02) collect: [:a | a detentBy: 0.1 atMultiplesOf: 1.0 snap: true] 	(-3.9 to: -4.1 by: -0.02) collect: [:a | a detentBy: 0.1 atMultiplesOf: 1.0 snap: false]
"! !

!Number methodsFor: 'truncation and round off'!
floor
	"Answer the integer nearest the receiver toward negative infinity."

	| truncation |
	truncation _ self truncated.
	self >= 0 ifTrue: [^truncation].
	self = truncation
		ifTrue: [^truncation]
		ifFalse: [^truncation - 1]! !

!Number methodsFor: 'truncation and round off' stamp: 'di 10/4/1999 08:08'!
roundTo: quantum 
	"Answer the nearest number that is a multiple of quantum."

	^(self / quantum) rounded * quantum! !

!Number methodsFor: 'truncation and round off'!
roundUpTo: aNumber 
	"Answer the next multiple of aNumber toward infinity that is nearest the 
	receiver."

	^(self/aNumber) ceiling * aNumber! !

!Number methodsFor: 'truncation and round off'!
rounded
	"Answer the integer nearest the receiver."

	^(self + (self sign / 2)) truncated! !

!Number methodsFor: 'truncation and round off'!
truncateTo: aNumber 
	"Answer the next multiple of aNumber toward zero that is nearest the 
	receiver."

	^(self quo: aNumber)
		* aNumber! !

!Number methodsFor: 'truncation and round off'!
truncated
	"Answer an integer nearest the receiver toward zero."

	^self quo: 1! !


!Number methodsFor: 'testing'!
even
	"Answer whether the receiver is an even number."

	^self \\ 2 = 0! !

!Number methodsFor: 'testing' stamp: 'sw 12/30/1998 13:21'!
isDivisibleBy: aNumber
	aNumber = 0 ifTrue: [^ false].
	aNumber isInteger ifFalse: [^ false].
	^ (self \\ aNumber) = 0! !

!Number methodsFor: 'testing' stamp: 'tao 10/10/97 16:36'!
isInf
	^ false! !

!Number methodsFor: 'testing' stamp: 'tao 4/19/98 23:33'!
isInfinite

	^ false! !

!Number methodsFor: 'testing' stamp: 'tao 10/10/97 16:36'!
isNaN
	^ false! !

!Number methodsFor: 'testing'!
isNumber
	^ true! !

!Number methodsFor: 'testing'!
isZero
	^self = 0! !

!Number methodsFor: 'testing' stamp: 'di 4/23/1998 11:18'!
negative
	"Answer whether the receiver is mathematically negative."

	^ self < 0! !

!Number methodsFor: 'testing'!
odd
	"Answer whether the receiver is an odd number."

	^self even == false! !

!Number methodsFor: 'testing'!
sign
	"Answer 1 if the receiver is greater than 0, -1 if less than 0, else 0."

	self > 0 ifTrue: [^1].
	self < 0 ifTrue: [^-1].
	^0! !


!Number methodsFor: 'converting'!
@ y 
	"Primitive. Answer a Point whose x value is the receiver and whose y 
	value is the argument. Optional. No Lookup. See Object documentation 
	whatIsAPrimitive."

	<primitive: 18>
	^Point x: self y: y! !

!Number methodsFor: 'converting' stamp: 'di 11/6/1998 13:21'!
adaptToFloat: rcvr andSend: selector 
	"If I am involved in arithmetic with a Float, convert me to a Float."
	^ rcvr perform: selector with: self asFloat! !

!Number methodsFor: 'converting' stamp: 'di 11/6/1998 13:44'!
adaptToFraction: rcvr andSend: selector
	"If I am involved in arithmetic with a Fraction, convert us and evaluate exprBlock."
	^ self subclassResponsibility! !

!Number methodsFor: 'converting' stamp: 'di 11/6/1998 13:44'!
adaptToInteger: rcvr andSend: selector
	"If I am involved in arithmetic with a Integer, convert us and evaluate exprBlock."
	^ self subclassResponsibility! !

!Number methodsFor: 'converting' stamp: 'di 11/6/1998 13:44'!
adaptToPoint: rcvr andSend: selector
	"If I am involved in arithmetic with a Point, convert me to a Point."
	^ rcvr perform: selector with: self@self! !

!Number methodsFor: 'converting' stamp: 'EMP 11/30/2015 14:46'!
asBoolean
	^ self = 1! !

!Number methodsFor: 'converting'!
asInteger
	"Answer an Integer nearest the receiver toward zero."

	^self truncated! !

!Number methodsFor: 'converting' stamp: 'sw 2/16/1999 18:15'!
asNumber
	^ self! !

!Number methodsFor: 'converting' stamp: 'jm 5/8/2008 11:01'!
asNumberNoError

	^ self
! !

!Number methodsFor: 'converting'!
asPoint
	"Answer a Point with the receiver as both coordinates; often used to 
	supply the same value in two dimensions, as with symmetrical gridding 
	or scaling."

	^self @ self! !

!Number methodsFor: 'converting' stamp: 'sw 9/8/97 16:30'!
asSmallAngleDegrees
	"Return the receiver normalized to lie within the range (-180, 180)"

	| pos |
	pos _ self \\ 360.
	pos > 180 ifTrue: [pos _ pos - 360].
	^ pos

"#(-500 -300 -150 -5 0 5 150 300 500 1200) collect: [:n | n asSmallAngleDegrees]"! !

!Number methodsFor: 'converting' stamp: 'sw 10/7/1999 12:24'!
asSmallPositiveDegrees
	"Return the receiver normalized to lie within the range (0, 360)"

	| result |
	result _ self.
	[result < 0] whileTrue: [result _ result + 360].
	^ result \\ 360

"#(-500 -300 -150 -5 0 5 150 300 500 1200) collect: [:n | n asSmallPositiveDegrees]"! !

!Number methodsFor: 'converting' stamp: 'EMP 2/25/2016 17:04'!
asUTF32
	^ self asString asUTF32! !

!Number methodsFor: 'converting'!
degreesToRadians
	"The receiver is assumed to represent degrees. Answer the conversion to 
	radians."

	^self asFloat degreesToRadians! !

!Number methodsFor: 'converting' stamp: 'jm 8/4/2008 09:12'!
localized

	^ self
! !

!Number methodsFor: 'converting'!
radiansToDegrees
	"The receiver is assumed to represent radians. Answer the conversion to 
	degrees."

	^self asFloat radiansToDegrees! !


!Number methodsFor: 'intervals'!
to: stop
	"Answer an Interval from the receiver up to the argument, stop, 
	incrementing by 1."

	^Interval from: self to: stop by: 1! !

!Number methodsFor: 'intervals'!
to: stop by: step
	"Answer an Interval from the receiver up to the argument, stop, 
	incrementing by step."

	^Interval from: self to: stop by: step! !

!Number methodsFor: 'intervals' stamp: 'tao 1/30/1999 08:58'!
to: stop by: step do: aBlock 
	"Normally compiled in-line, and therefore not overridable.
	Evaluate aBlock for each element of the interval (self to: stop by: 
step)."
	| nextValue |
	nextValue _ self.
	step = 0 ifTrue: [self error: 'step must be non-zero'].
	step < 0
		ifTrue: [[stop <= nextValue]
				whileTrue: 
					[aBlock value: nextValue.
					nextValue _ nextValue + step]]
		ifFalse: [[stop >= nextValue]
				whileTrue: 
					[aBlock value: nextValue.
					nextValue _ nextValue + step]]! !

!Number methodsFor: 'intervals'!
to: stop do: aBlock 
	"Normally compiled in-line, and therefore not overridable.
	Evaluate aBlock for each element of the interval (self to: stop by: 1)."
	| nextValue |
	nextValue _ self.
	[nextValue <= stop]
		whileTrue: 
			[aBlock value: nextValue.
			nextValue _ nextValue + 1]! !


!Number methodsFor: 'printing'!
defaultLabelForInspector
	"Answer the default label to be used for an Inspector window on the receiver."

	^ super defaultLabelForInspector, ': ', self printString! !

!Number methodsFor: 'printing' stamp: 'jm 6/3/2004 18:52'!
hhmmss

	^ self rounded hhmmss
! !

!Number methodsFor: 'printing' stamp: 'sw 6/29/1999 21:10'!
isOrAreStringWith: aNoun
	| result |
	result _ self = 1
		ifTrue:
			[' is one ']
		ifFalse:
			[self = 0
				ifTrue:
					[' are no ']
				ifFalse:
					[' are ', self printString, ' ']].
	result _ result, aNoun.
	self = 1 ifFalse: [result _ result, 's'].
	^ result

"#(0 1 2 98.6) do:
	[:num | Transcript cr; show: 'There', (num isOrAreStringWith: 'way'), ' to skin a cat']"! !

!Number methodsFor: 'printing'!
printOn: aStream
	"Default print radix is 10"
	self printOn: aStream base: 10! !

!Number methodsFor: 'printing'!
printStringBase: base
	^ String streamContents:
		[:strm | self printOn: strm base: base]! !

!Number methodsFor: 'printing' stamp: 'jm 9/1/2008 23:33'!
printStringNoExponent

	^ self printString
! !

!Number methodsFor: 'printing'!
storeOn: aStream 
	"Normal printing is OK for storing"
	self printOn: aStream! !

!Number methodsFor: 'printing'!
storeOn: aStream base: base
	"Append my printed representation to aStream, incuding the base."

	self printOn: aStream base: base! !

!Number methodsFor: 'printing'!
storeStringBase: base
	^ String streamContents: [:strm | self storeOn: strm base: base]! !

!Number methodsFor: 'printing' stamp: 'sw 7/1/1998 12:33'!
stringForReadout
	^ self rounded printString! !


!Number methodsFor: '*JSON-writing' stamp: 'tonyg 8/17/2005 00:41'!
jsonWriteOn: aWriteStream 
	aWriteStream nextPutAll: self asString.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Number class
	instanceVariableNames: ''!

!Number class methodsFor: 'instance creation' stamp: 'bf 12/9/1998 19:21'!
readFrom: stringOrStream 
	"Answer a number as described on aStream.  The number may
	include a leading radix specification, as in 16rFADE"
	| value base aStream sign |
	aStream _ (stringOrStream isMemberOf: String)
		ifTrue: [ReadStream on: stringOrStream]
		ifFalse: [stringOrStream].
	(aStream nextMatchAll: 'NaN') ifTrue: [^ Float nan].
	sign _ (aStream peekFor: $-) ifTrue: [-1] ifFalse: [1].
	(aStream nextMatchAll: 'Infinity') ifTrue: [^ Float infinity * sign].
	base _ 10.
	value _ Integer readFrom: aStream base: base.
	(aStream peekFor: $r)
		ifTrue: 
			["<base>r<integer>"
			(base _ value) < 2 ifTrue: [^self error: 'Invalid radix'].
			(aStream peekFor: $-) ifTrue: [sign _ sign negated].
			value _ Integer readFrom: aStream base: base].
	^ self readRemainderOf: value from: aStream base: base withSign: sign.! !

!Number class methodsFor: 'instance creation' stamp: 'tao 4/23/98 12:24'!
readFrom: stringOrStream base: base
	"Answer a number as described on aStream in the given number base."

	| aStream sign |
	aStream _ (stringOrStream isMemberOf: String)
		ifTrue: [ReadStream on: stringOrStream]
		ifFalse: [stringOrStream].
	(aStream nextMatchAll: 'NaN') ifTrue: [^ Float nan].
	sign _ (aStream peekFor: $-) ifTrue: [-1] ifFalse: [1].
	(aStream nextMatchAll: 'Infinity') ifTrue: [^ Float infinity * sign].
	^ self readRemainderOf: (Integer readFrom: aStream base: base)
			from: aStream base: base withSign: sign! !

!Number class methodsFor: 'instance creation' stamp: 'tao 4/23/98 12:12'!
readRemainderOf: integerPart from: aStream base: base withSign: sign
	"Read optional fractional part and exponent, and return the final result"

	| value fraction fracpos |

	value _ integerPart.
	(aStream peekFor: $.)
		ifTrue: 
			["<integer>.<fraction>"
			(aStream atEnd not and: [aStream peek digitValue between: 0 and: base - 1])
				ifTrue: 
					[fracpos _ aStream position.
					fraction _ Integer readFrom: aStream base: base.
					fraction _ 
						fraction asFloat / (base raisedTo: aStream position - fracpos).
					value _ value asFloat + fraction]
				ifFalse: 
					["oops - just <integer>."
					aStream skip: -1.		"un-gobble the period"
					^ value * sign
					"Number readFrom: '3r-22.2'"]].
	(aStream peekFor: $e)
		ifTrue: 
			["<integer>e<exponent>"
			value _ value * (base raisedTo: (Integer readFrom: aStream))].
	(value isFloat and: [value = 0.0 and: [sign = -1]])
		ifTrue: [^ Float negativeZero]
		ifFalse: [^ value * sign]! !
