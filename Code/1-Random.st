Object subclass: #Random
	instanceVariableNames: 'seed a m q r '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Kernel-Numbers'!
!Random commentStamp: 'jm 10/23/2007 12:46' prior: 0!
This Random Number Generator was contributed by David N. Smith. It is an adaptation of the Park-Miller RNG, using Floats to avoid the need for LargeInteger arithmetic.
!


!Random methodsFor: 'initialization' stamp: 'EMP 12/12/2015 13:37'!
initialize
	"Pick a non-zero starting seed based on the clock and this objects's hash bits."

	seed _ (Time millisecondClockValue bitXor: self hash) bitXor: Time totalSeconds.
	"if seed is zero, get some random bits a different way"
	seed = 0 ifTrue: [seed _ Smalltalk primBytesLeft + 42 "Because it's the answer to life, the universe, and everything :P"].
	seed _ seed abs bitAnd: 16r3FFFFFFF.

	a _ 16807 asFloat.
	m _ 2147483647 asFloat.
	q _ (m quo: a) asFloat.
	r  _ (m \\ a) asFloat.

	self next. "take one step"
! !

!Random methodsFor: 'initialization' stamp: 'jm 10/23/2007 12:43'!
seed: anInteger

	seed _ anInteger.
! !


!Random methodsFor: 'accessing' stamp: 'jm 10/23/2007 12:43'!
next
	"Answer a random Float in the interval [0 to 1)."

	^ (seed _ self nextValue) / m
! !

!Random methodsFor: 'accessing' stamp: 'jm 10/23/2007 12:39'!
next: anInteger

	^ (1 to: anInteger) collect: [:i | self next]
! !

!Random methodsFor: 'accessing' stamp: 'jm 10/23/2007 12:43'!
nextInt: anInteger
	"Answer a random integer in the interval [1, anInteger]."

	^ (self next * anInteger) truncated + 1
! !


!Random methodsFor: 'private' stamp: 'jm 10/23/2007 12:37'!
nextValue 
	"This method generates random instances of Integer in the interval 0 to 16r7FFFFFFF. This method does NOT update the seed; repeated sends answer the same value.
	The algorithm is described in detail in 'Random Number Generators: 
	Good Ones Are Hard to Find' by Stephen K. Park and Keith W. Miller 
	(Comm. Asso. Comp. Mach., 31(10):1192--1201, 1988)."

	| lo hi aLoRHi result |
	hi _ (seed quo: q) asFloat.
	lo _ seed - (hi * q).  "= seed rem: q"  
	aLoRHi _ (a * lo) - (r * hi).
	result _ (aLoRHi > 0.0)
		ifTrue:  [aLoRHi]
		ifFalse: [aLoRHi + m].
	^ result! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Random class
	instanceVariableNames: ''!

!Random class methodsFor: 'instance creation' stamp: 'jm 10/23/2007 12:43'!
seed: anInteger

	^ self new initialize seed: anInteger
! !


!Random class methodsFor: 'examples and tests' stamp: 'jm 10/23/2007 12:47'!
bucketTest: randy
	"Execute this:   Random bucketTest: Random new"
	" A quick-and-dirty bucket test. Prints nbuckets values on the
Transcript.
	  Each should be 'near' the value of ntries. Any run with any value
'far' from ntries
	  indicates something is very wrong. Each run generates different
values.
	  For a slightly better test, try values of nbuckets of 200-1000 or
more; go get coffee.
	  This is a poor test; see Knuth.   Some 'OK' runs:
		1000 1023 998 969 997 1018 1030 1019 1054 985 1003
		1011 987 982 980 982 974 968 1044 976
		1029 1011 1025 1016 997 1019 991 954 968 999 991
		978 1035 995 988 1038 1009 988 993 976
"
	| nbuckets buckets ntrys slot |
	nbuckets := 20.
	buckets := Array new: nbuckets.
	buckets atAllPut: 0.
	ntrys :=  1000.
	ntrys*nbuckets timesRepeat: [
		slot := (randy next * nbuckets) floor + 1.
		buckets at: slot put: (buckets at: slot) + 1 ].
	Transcript cr.
	1 to: nbuckets do: [ :nb |
		Transcript show: (buckets at: nb) printString, ' ' ]! !

!Random class methodsFor: 'examples and tests' stamp: 'sma 5/12/2000 12:39'!
example
	"If you just want a quick random integer, use:
		10 atRandom
	Every integer interval can give a random number:
		(6 to: 12) atRandom
	SequenceableCollections can give randomly selected elements:
		'pick one of these letters randomly' atRandom
	SequenceableCollections also respond to shuffled, as in:
		($A to: $Z) shuffled

	The correct way to use class Random is to store one in 
	an instance or class variable:
		myGenerator _ Random new.
	Then use it every time you need another number between 0.0 and 1.0 (excluding)
		myGenerator next
	You can also generate a positive integer
		myGenerator nextInt: 10
"! !

!Random class methodsFor: 'examples and tests'!
theItsCompletelyBrokenTest
	"Random theItsCompletelyBrokenTest"
	"The above should print as...
	(0.149243269650845 0.331633021743797 0.75619644800024 0.393701540023881 0.941783181364547 0.549929193942775 0.659962596213428 0.991354559078512 0.696074432551896 0.922987899707159 )
	If they are not these values (accounting for precision of printing) then something is horribly wrong: DO NOT USE THIS CODE FOR ANYTHING. "
	| rng |
	rng := Random new.
	rng seed: 2345678901.
	^ (1 to: 10) collect: [:i | rng next]! !
