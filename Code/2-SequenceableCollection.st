Collection subclass: #SequenceableCollection
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Abstract'!
!SequenceableCollection commentStamp: '<historical>' prior: 0!
I am an abstract superclass for collections that have a well-defined order associated with their elements. Thus each element is externally-named by integers referred to as indices.!


!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 6/1/2000 15:34'!
allButFirst
	"Answer a copy of the receiver containing all but the first
	element. Raise an error if there are not enough elements."

	^ self allButFirst: 1! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 6/1/2000 15:35'!
allButFirst: n
	"Answer a copy of the receiver containing all but the first n
	elements. Raise an error if there are not enough elements."

	^ self copyFrom: n + 1 to: self size! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 6/1/2000 15:35'!
allButLast
	"Answer a copy of the receiver containing all but the last
	element. Raise an error if there are not enough elements."

	^ self allButLast: 1! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 6/1/2000 15:35'!
allButLast: n
	"Answer a copy of the receiver containing all but the last n
	elements. Raise an error if there are not enough elements."

	^ self copyFrom: 1 to: self size - n! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 5/12/2000 12:11'!
at: index ifAbsent: exceptionBlock 
	"Answer the element at my position index. If I do not contain an element 
	at index, answer the result of evaluating the argument, exceptionBlock."

	(index between: 1 and: self size) ifTrue: [^ self at: index].
	^ exceptionBlock value! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 5/12/2000 12:14'!
atAll: indexArray
	"Answer a new collection like the receiver which contains all elements
	of the receiver at the indices of indexArray."

	| newCollection |
	newCollection _ self species new: indexArray size.
	1 to: indexArray size do:
		[:index |
		newCollection at: index put: (self at: (indexArray at: index))].
	^ newCollection! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 5/12/2000 12:17'!
atAll: aCollection put: anObject 
	"Put anObject at every index specified by the elements of aCollection."

	aCollection do: [:index | self at: index put: anObject].
	^ anObject! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 4/22/2000 17:45'!
atAllPut: anObject 
	"Put anObject at every one of the receiver's indices."

	| size |
	(size _ self size) > 26 "first method faster from 27 accesses and on"
		ifTrue: [self from: 1 to: size put: anObject]
		ifFalse: [1 to: size do: [:index | self at: index put: anObject]]! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'di 11/6/1998 14:32'!
atPin: index 
	"Return the index'th element of me if possible.
	Return the first or last element if index is out of bounds."

	index < 1 ifTrue: [^ self first].
	index > self size ifTrue: [^ self last].
	^ self at: index! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 5/12/2000 12:36'!
atRandom
	"Answer a random element of the receiver.  Uses a shared random 
	number generator owned by class Collection.  If you use this a lot, 
	define your own instance of Random and use #atRandom:.  Causes 
	an error if self has no elements."

	^ self atRandom: Collection randomForPicking

"Examples:
	#('one' 'or' 'the' 'other') atRandom
	(1 to: 10) atRandom
	'Just pick one of these letters at random' atRandom
"! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 5/12/2000 12:50'!
atRandom: aGenerator
	"Answer a random element of the receiver.  Uses aGenerator which
	should be kept by the user in a variable and used every time. Use
	this instead of #atRandom for better uniformity of random numbers 
	because only you use the generator.  Causes an error if self has no 
	elements."

	^ self at: (aGenerator nextInt: self size)! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 5/12/2000 13:51'!
atWrap: index 
	"Answer the index'th element of the receiver.  If index is out of bounds,
	let it wrap around from the end to the beginning until it is in bounds."

	^ self at: index - 1 \\ self size + 1! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 5/12/2000 13:52'!
atWrap: index put: value
	"Store value into the index'th element of the receiver.  If index is out
	of bounds, let it wrap around from the end to the beginning until it 
	is in bounds. Answer value."

	^ self at: index  - 1 \\ self size + 1 put: value! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'jm 6/20/2003 10:01'!
fifth
	"Answer the fifth element of the receiver."

	^ self at: 5
! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'jm 6/20/2003 10:01'!
first
	"Answer the first element of the receiver."

	^ self at: 1
! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 6/1/2000 15:31'!
first: n
	"Answer the first n elements of the receiver.
	Raise an error if there are not enough elements."

	^ self copyFrom: 1 to: n! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'jm 6/20/2003 10:01'!
fourth
	"Answer the fourth element of the receiver."

	^ self at: 4
! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 4/22/2000 17:52'!
from: startIndex to: endIndex put: anObject
	"Put anObject in all indexes between startIndex 
	and endIndex. Very fast. Faster than to:do: for
	more than 26 positions. No range checks are 
	performed. Answer anObject."

	| written toWrite thisWrite |
	self at: startIndex put: anObject.
	written _ 1.
	toWrite _ endIndex - startIndex + 1.
	[written < toWrite] whileTrue:
		[thisWrite _ written min: toWrite - written.
		self 
			replaceFrom: startIndex + written
			to: startIndex + written + thisWrite - 1
			with: self startingAt: startIndex.
		written _ written + thisWrite].
	^ anObject! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'ar 8/14/1998 21:21'!
identityIndexOf: anElement ifAbsent: exceptionBlock
	"Answer the index of anElement within the receiver. If the receiver does 
	not contain anElement, answer the result of evaluating the argument, 
	exceptionBlock."
	1 to: self size do:
		[:i | (self at: i) == anElement ifTrue: [^ i]].
	^ exceptionBlock value! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 6/1/2000 15:46'!
indexOf: anElement
	"Answer the index of the first occurence of anElement within the  
	receiver. If the receiver does not contain anElement, answer 0."

	^ self indexOf: anElement ifAbsent: [0]! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 6/1/2000 15:47'!
indexOf: anElement ifAbsent: exceptionBlock
	"Answer the index of the first occurence of anElement within the  
	receiver. If the receiver does not contain anElement, answer the 
	result of evaluating the argument, exceptionBlock."

	^ self indexOf: anElement startingAt: 1 ifAbsent: exceptionBlock! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'sma 6/1/2000 15:47'!
indexOf: anElement startingAt: start ifAbsent: exceptionBlock
	"Answer the index of the first occurence of anElement after start
	within the receiver. If the receiver does not contain anElement, 
	answer the 	result of evaluating the argument, exceptionBlock."

	start to: self size do:
		[:index |
		(self at: index) = anElement ifTrue: [^ index]].
	^ exceptionBlock value! !

!SequenceableCollection methodsFor: 'accessing'!
indexOfSubCollection: aSubCollection startingAt: anIndex 
	"Answer the index of the receiver's first element, such that that element 
	equals the first element of aSubCollection, and the next elements equal 
	the rest of the elements of aSubCollection. Begin the search at element 
	anIndex of the receiver. If no such match is found, answer 0."

	^self
		indexOfSubCollection: aSubCollection
		startingAt: anIndex
		ifAbsent: [0]! !

!SequenceableCollection methodsFor: 'accessing'!
indexOfSubCollection: sub startingAt: start ifAbsent: exceptionBlock
	"Answer the index of the receiver's first element, such that that element 
	equals the first element of sub, and the next elements equal 
	the rest of the elements of sub. Begin the search at element 
	start of the receiver. If no such match is found, answer the result of 
	evaluating argument, exceptionBlock."
	| first index |
	sub isEmpty ifTrue: [^ exceptionBlock value].
	first _ sub first.
	start to: self size - sub size + 1 do:
		[:startIndex |
		(self at: startIndex) = first ifTrue:
			[index _ 1.
			[(self at: startIndex+index-1) = (sub at: index)]
				whileTrue:
				[index = sub size ifTrue: [^startIndex].
				index _ index+1]]].
	^ exceptionBlock value! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'di 6/2/2000 09:15'!
last
	"Answer the last element of the receiver.
	Raise an error if the collection is empty."

	| size |
	(size _ self size) = 0 ifTrue: [self errorEmptyCollection].
	^ self at: size! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'ar 1/20/98 16:22'!
replaceAll: oldObject with: newObject 
	"Replace all occurences of oldObject with newObject"
	| index |
	index _ self
				indexOf: oldObject
				startingAt: 1
				ifAbsent: [0].
	[index = 0]
		whileFalse: 
			[self at: index put: newObject.
			index _ self
						indexOf: oldObject
						startingAt: index + 1
						ifAbsent: [0]]! !

!SequenceableCollection methodsFor: 'accessing'!
replaceFrom: start to: stop with: replacement 
	"This destructively replaces elements from start to stop in the receiver. 
	Answer the receiver itself. Use copyReplaceFrom:to:with: for 
	insertion/deletion which may alter the size of the result."

	replacement size = (stop - start + 1)
		ifFalse: [self error: 'Size of replacement doesnt match'].
	^self replaceFrom: start to: stop with: replacement startingAt: 1! !

!SequenceableCollection methodsFor: 'accessing'!
replaceFrom: start to: stop with: replacement startingAt: repStart 
	"This destructively replaces elements from start to stop in the receiver 
	starting at index, repStart, in the sequenceable collection, 
	replacementCollection. Answer the receiver. No range checks are 
	performed."

	| index repOff |
	repOff _ repStart - start.
	index _ start - 1.
	[(index _ index + 1) <= stop]
		whileTrue: [self at: index put: (replacement at: repOff + index)]! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'jm 6/20/2003 10:02'!
second
	"Answer the second element of the receiver."

	^ self at: 2
! !

!SequenceableCollection methodsFor: 'accessing'!
swap: oneIndex with: anotherIndex 
	"Move the element at oneIndex to anotherIndex, and vice-versa."

	| element |
	element _ self at: oneIndex.
	self at: oneIndex put: (self at: anotherIndex).
	self at: anotherIndex put: element! !

!SequenceableCollection methodsFor: 'accessing' stamp: 'jm 6/20/2003 10:02'!
third
	"Answer the third element of the receiver."

	^ self at: 3
! !


!SequenceableCollection methodsFor: 'testing' stamp: 'sma 5/12/2000 14:08'!
includes: anObject
	"Answer whether anObject is one of the receiver's elements."

	^ (self indexOf: anObject) ~= 0! !


!SequenceableCollection methodsFor: 'comparing' stamp: 'sma 5/12/2000 14:04'!
= otherCollection 
	"Answer true if the receiver is equivalent to the otherCollection.
	First test for identity, then rule out different species and sizes of
	collections. As a last resort, examine each element of the receiver
	and the otherCollection."

	self == otherCollection ifTrue: [^ true].
	self species == otherCollection species ifFalse: [^ false].
	^ self hasEqualElements: otherCollection! !

!SequenceableCollection methodsFor: 'comparing' stamp: 'sma 5/12/2000 14:04'!
hasEqualElements: otherCollection
	"Answer whether the receiver's size is the same as otherCollection's
	size, and each of the receiver's elements equal the corresponding 
	element of otherCollection.
	This should probably replace the current definition of #= ."

	| size |
	(size _ self size) = otherCollection size ifFalse: [^ false].
	1 to: size do:
		[:index |
		(self at: index) = (otherCollection at: index) ifFalse: [^ false]].
	^ true! !

!SequenceableCollection methodsFor: 'comparing' stamp: 'di 11/24/1999 20:30'!
hash
"Answer an integer hash value for the receiver such that,
  -- the hash value of an unchanged object is constant over time, and
  -- two equal objects have equal hash values."
    | size |
	(size _ self size) = 0 ifTrue: [^ 17171].
	^ size + (self at: 1) hash + (self at: size) hash! !


!SequenceableCollection methodsFor: 'converting' stamp: 'sma 5/12/2000 17:32'!
asArray
	"Answer an Array whose elements are the elements of the receiver."

	^ Array withAll: self! !

!SequenceableCollection methodsFor: 'converting' stamp: 'sma 5/12/2000 17:36'!
asByteArray
	"Answer a ByteArray whose elements are the elements of the receiver."

	^ ByteArray withAll: self! !

!SequenceableCollection methodsFor: 'converting' stamp: 'ar 9/14/1998 23:47'!
asFloatArray
	"Answer a FloatArray whose elements are the elements of the receiver, in 
	the same order."

	| floatArray |
	floatArray _ FloatArray new: self size.
	1 to: self size do:[:i| floatArray at: i put: (self at: i) asFloat ].
	^floatArray! !

!SequenceableCollection methodsFor: 'converting' stamp: 'ar 10/10/1998 16:19'!
asIntegerArray
	"Answer an IntegerArray whose elements are the elements of the receiver, in 
	the same order."

	| intArray |
	intArray _ IntegerArray new: self size.
	1 to: self size do:[:i| intArray at: i put: (self at: i)].
	^intArray! !

!SequenceableCollection methodsFor: 'converting' stamp: 'djm 11/20/1998 05:44'!
asStringWithCr
	"Convert to a string with returns between items.  Elements are
usually strings.
	 Useful for labels for PopUpMenus."
	| labelStream |
	labelStream _ WriteStream on: (String new: 200).
	self do: [:each |
		(each isKindOf: String)
			ifTrue: [labelStream nextPutAll: each; cr]
			ifFalse: [each printOn: labelStream. labelStream cr]].
	self size > 0 ifTrue: [labelStream skip: -1].
	^ labelStream contents! !

!SequenceableCollection methodsFor: 'converting' stamp: 'ar 10/10/1998 16:20'!
asWordArray
	"Answer a WordArray whose elements are the elements of the receiver, in 
	the same order."

	| wordArray |
	wordArray _ WordArray new: self size.
	1 to: self size do:[:i| wordArray at: i put: (self at: i)].
	^wordArray! !

!SequenceableCollection methodsFor: 'converting' stamp: 'jm 4/27/98 04:09'!
reversed
	"Answer a copy of the receiver with element order reversed."
	"Example: 'frog' reversed"

	| n result src |
	n _ self size.
	result _ self species new: n.
	src _ n + 1.
	1 to: n do: [:i | result at: i put: (self at: (src _ src - 1))].
	^ result
! !


!SequenceableCollection methodsFor: 'copying' stamp: 'di 1/16/98 16:40'!
, otherCollection 
	"Concatenate two Strings or Collections."
	
	^ self copyReplaceFrom: self size + 1
		  to: self size
		  with: otherCollection
"
#(2 4 6 8) , #(who do we appreciate)
((2989 printStringBase: 16) copyFrom: 4 to: 6) , ' boy!!'
"! !

!SequenceableCollection methodsFor: 'copying' stamp: 'sma 6/1/2000 16:07'!
copyEmpty
	^ self species new: 0! !

!SequenceableCollection methodsFor: 'copying'!
copyFrom: start to: stop 
	"Answer a copy of a subset of the receiver, starting from element at 
	index start until element at index stop."

	| newSize |
	newSize _ stop - start + 1.
	^(self species new: newSize)
		replaceFrom: 1
		to: newSize
		with: self
		startingAt: start! !

!SequenceableCollection methodsFor: 'copying'!
copyReplaceAll: oldSubstring with: newSubstring 
	"Default is not to do token matching.
	See also String copyReplaceTokens:with:"
	^ self copyReplaceAll: oldSubstring with: newSubstring asTokens: false
	"'How now brown cow?' copyReplaceAll: 'ow' with: 'ello'"
	"'File asFile Files File''s File' copyReplaceTokens: 'File' with: 'Pile'"! !

!SequenceableCollection methodsFor: 'copying'!
copyReplaceFrom: start to: stop with: replacementCollection 
	"Answer a copy of the receiver satisfying the following conditions: If 
	stop is less than start, then this is an insertion; stop should be exactly 
	start-1, start = 1 means insert before the first character, start = size+1 
	means append after last character. Otherwise, this is a replacement; start 
	and stop have to be within the receiver's bounds."

	| newSequenceableCollection newSize endReplacement |
	newSize _ self size - (stop - start + 1) + replacementCollection size.
	endReplacement _ start - 1 + replacementCollection size.
	newSequenceableCollection _ self species new: newSize.
	newSequenceableCollection
		replaceFrom: 1
		to: start - 1
		with: self
		startingAt: 1.
	newSequenceableCollection
		replaceFrom: start
		to: endReplacement
		with: replacementCollection
		startingAt: 1.
	newSequenceableCollection
		replaceFrom: endReplacement + 1
		to: newSize
		with: self
		startingAt: stop + 1.
	^newSequenceableCollection! !

!SequenceableCollection methodsFor: 'copying' stamp: 'sma 6/1/2000 16:00'!
copyUpTo: anElement 
	"Answer all elements up to but not including anObject. If there
	is no such object, answer a copy of the receiver."

	^ self first: (self indexOf: anElement ifAbsent: [^ self copy]) - 1! !

!SequenceableCollection methodsFor: 'copying'!
copyWith: newElement 
	"Answer a copy of the receiver that is 1 bigger than the receiver and has 
	newElement at the last element."

	| newIC |
	newIC _ self species new: self size + 1.
	newIC 
		replaceFrom: 1
		to: self size
		with: self
		startingAt: 1.
	newIC at: newIC size put: newElement.
	^newIC! !

!SequenceableCollection methodsFor: 'copying' stamp: 'EMP 12/12/2015 11:49'!
copyWithArray: newCollection
	"Answer a copy of the receiver that is 1 bigger than the receiver and has 
	newElement at the last element."

	| newIC |
	newIC _ self species new: self size + newCollection size.
	newIC 
		replaceFrom: 1
		to: self size
		with: self
		startingAt: 1.
	newIC replaceFrom: (self size + 1) to: (newIC size) with: newCollection startingAt: 1.
	^newIC! !

!SequenceableCollection methodsFor: 'copying' stamp: 'sma 4/22/2000 18:01'!
forceTo: length paddingWith: elem
	"Force the length of the collection to length, padding
	if necessary with elem.  Note that this makes a copy."

	| newCollection copyLen |
	newCollection _ self species new: length.
	copyLen _ self size min: length.
	newCollection replaceFrom: 1 to: copyLen with: self startingAt: 1.
	newCollection from: copyLen + 1 to: length put: elem.
	^ newCollection! !

!SequenceableCollection methodsFor: 'copying'!
shallowCopy

	^self copyFrom: 1 to: self size! !

!SequenceableCollection methodsFor: 'copying' stamp: 'sma 5/12/2000 12:36'!
shuffled
	^ self shuffledBy: Collection randomForPicking

"Examples:
	($A to: $Z) shuffled
"! !

!SequenceableCollection methodsFor: 'copying' stamp: 'djp 10/23/1999 22:12'!
shuffledBy: aRandom
	| copy | 
	copy _ self shallowCopy.
	copy size to: 1 by: -1 do: 
		[:i | copy swap: i with: ((1 to: i) atRandom: aRandom)].
	^ copy! !

!SequenceableCollection methodsFor: 'copying' stamp: 'sma 4/28/2000 18:34'!
sortBy: aBlock
	"Create a copy that is sorted.  Sort criteria is the block that accepts two arguments.
	When the block is true, the first arg goes first ([:a :b | a > b] sorts in descending
	order)."

	^ (self asSortedCollection: aBlock) asOrderedCollection! !


!SequenceableCollection methodsFor: 'enumerating' stamp: 'tk 7/30/97 12:41'!
asDigitsToPower: anInteger do: aBlock
	"Repeatedly value aBlock with a single Array.  Adjust the collection
	so that aBlock is presented all (self size raisedTo: anInteger) possible 
	combinations of the receiver's elements taken as digits of an anInteger long number."
	"(0 to: 1) asDigitsToPower: 4 do: [:each | Transcript cr; show: each printString]"

	| aCollection |
	aCollection _ Array new: anInteger.
	self asDigitsAt: 1 in: aCollection do: aBlock! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'sma 5/12/2000 11:46'!
collect: aBlock 
	"Evaluate aBlock with each of the receiver's elements as the argument.  
	Collect the resulting values into a collection like the receiver. Answer  
	the new collection."

	| newCollection |
	newCollection _ self species new: self size.
	1 to: self size do:
		[:index |
		newCollection at: index put: (aBlock value: (self at: index))].
	^ newCollection! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'sma 6/1/2000 11:47'!
collect: aBlock from: firstIndex to: lastIndex
	"Refer to the comment in Collection|collect:."

	| size result j |
	size _ lastIndex - firstIndex + 1.
	result _ self species new: size.
	j _ firstIndex.
	1 to: size do: [:i | result at: i put: (aBlock value: (self at: j)). j _ j + 1].
	^ result! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'tk 7/30/97 12:52'!
combinations: kk atATimeDo: aBlock
	"Take the items in the receiver, kk at a time, and evaluate the block for each combination.  Hand in an array of elements of self as the block argument.  Each combination only occurs once, and order of the elements does not matter.  There are (self size take: kk) combinations."
	" 'abcde' combinations: 3 atATimeDo: [:each | Transcript cr; show: each printString]"

	| aCollection |
	aCollection _ Array new: kk.
	self combinationsAt: 1 in: aCollection after: 0 do: aBlock! !

!SequenceableCollection methodsFor: 'enumerating'!
do: aBlock 
	"Refer to the comment in Collection|do:."
	1 to: self size do:
		[:index | aBlock value: (self at: index)]! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'di 7/13/97 09:43'!
doWithIndex: elementAndIndexBlock
	"Use the new version with consistent naming"
	^ self withIndexDo: elementAndIndexBlock! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'ar 6/3/2000 15:54'!
findBinaryIndex: aBlock
	"Search for an element in the receiver using binary search.
	The argument aBlock is a one-element block returning
		0 	- if the element is the one searched for
		<0	- if the search should continue in the first half
		>0	- if the search should continue in the second half
	If no matching element is found, raise an error.
	Examples:
		#(1 3 5 7 11 15 23) findBinaryIndex:[:arg| 11 - arg]
	"
	^self findBinaryIndex: aBlock ifNone: [self errorNotFound: aBlock]! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'ar 6/3/2000 15:54'!
findBinaryIndex: aBlock ifNone: exceptionBlock
	"Search for an element in the receiver using binary search.
	The argument aBlock is a one-element block returning
		0 	- if the element is the one searched for
		<0	- if the search should continue in the first half
		>0	- if the search should continue in the second half
	If no matching element is found, evaluate exceptionBlock."
	| index low high test |
	low _ 1.
	high _ self size.
	[index _ high + low // 2.
	low > high] whileFalse:[
		test _ aBlock value: (self at: index).
		test = 0 
			ifTrue:[^index]
			ifFalse:[test > 0
				ifTrue: [low _ index + 1]
				ifFalse: [high _ index - 1]]].
	^exceptionBlock value! !

!SequenceableCollection methodsFor: 'enumerating'!
findFirst: aBlock
	"Return the index of my first element for which aBlock evaluates as true."

	| index |
	index _ 0.
	[(index _ index + 1) <= self size] whileTrue:
		[(aBlock value: (self at: index)) ifTrue: [^index]].
	^ 0! !

!SequenceableCollection methodsFor: 'enumerating'!
findLast: aBlock
	"Return the index of my last element for which aBlock evaluates as true."

	| index |
	index _ self size + 1.
	[(index _ index - 1) >= 1] whileTrue:
		[(aBlock value: (self at: index)) ifTrue: [^index]].
	^ 0! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'sma 5/12/2000 18:13'!
keysAndValuesDo: aBlock 
	"Enumerate the receiver with all the keys (aka indices) and values."

	1 to: self size do: [:index | aBlock value: index value: (self at: index)]! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'di 11/12/1998 15:01'!
pairsDo: aBlock 
	"Evaluate aBlock with my elements taken two at a time.  If there's an odd number of items, ignore the last one.  Allows use of a flattened array for things that naturally group into pairs.  See also pairsCollect:"

	1 to: self size // 2 do:
		[:index | aBlock value: (self at: 2 * index - 1) value: (self at: 2 * index)]
"
#(1 'fred' 2 'charlie' 3 'elmer') pairsDo:
	[:a :b | Transcript cr; show: b, ' is number ', a printString]
"! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'ward 7/28/97 09:41'!
permutationsDo: aBlock
	"Repeatly value aBlock with a single copy of the receiver. Reorder the copy
	so that aBlock is presented all (self size factorial) possible permutations."
	"(1 to: 4) permutationsDo: [:each | Transcript cr; show: each printString]"

	self shallowCopy permutationsStartingAt: 1 do: aBlock! !

!SequenceableCollection methodsFor: 'enumerating'!
reverseDo: aBlock
	"Evaluate aBlock with each of the receiver's elements as the argument, 
	starting with the last element and taking each in sequence up to the 
	first. For SequenceableCollections, this is the reverse of the enumeration 
	for do:."

	self size to: 1 by: -1 do: [:index | aBlock value: (self at: index)]! !

!SequenceableCollection methodsFor: 'enumerating'!
reverseWith: aSequenceableCollection do: aBlock 
	"Evaluate aBlock with each of the receiver's elements, in reverse order, 
	along with the  
	corresponding element, also in reverse order, from 
	aSequencableCollection. "

	self size ~= aSequenceableCollection size ifTrue: [^ self errorNoMatch].
	self size
		to: 1
		by: -1
		do: [:index | aBlock value: (self at: index)
				value: (aSequenceableCollection at: index)]! !

!SequenceableCollection methodsFor: 'enumerating'!
select: aBlock 
	"Refer to the comment in Collection|select:."
	| aStream |
	aStream _ WriteStream on: (self species new: self size).
	1 to: self size do: 
		[:index |
		(aBlock value: (self at: index))
			ifTrue: [aStream nextPut: (self at: index)]].
	^ aStream contents! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'sma 6/1/2000 16:00'!
upTo: anObject
	"Deprecated. Use copyUpTo:"

	^ self copyUpTo: anObject! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'di 8/31/1999 13:13'!
with: otherCollection collect: twoArgBlock 
	"Collect and return the result of evaluating twoArgBlock with corresponding elements from this collection and otherCollection."
	| result |
	otherCollection size = self size ifFalse: [self error: 'otherCollection must be the same size'].
	result _ self species new: self size.
	1 to: self size do:
		[:index | result at: index put:
		(twoArgBlock
			value: (self at: index)
			value: (otherCollection at: index))].
	^ result! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'di 8/3/1999 15:26'!
with: otherCollection do: twoArgBlock 
	"Evaluate twoArgBlock with corresponding elements from this collection and otherCollection."
	otherCollection size = self size ifFalse: [self error: 'otherCollection must be the same size'].
	1 to: self size do:
		[:index |
		twoArgBlock value: (self at: index)
				value: (otherCollection at: index)]! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'di 5/17/1998 13:34'!
withIndexCollect: elementAndIndexBlock 
	"Just like with:collect: except that the iteration index supplies the second argument to the block."
	| result |
	result _ self species new: self size.
	1 to: self size do:
		[:index | result at: index put:
		(elementAndIndexBlock
			value: (self at: index)
			value: index)].
	^ result! !

!SequenceableCollection methodsFor: 'enumerating' stamp: 'di 7/13/97 09:35'!
withIndexDo: elementAndIndexBlock 
	"Just like with:do: except that the iteration index supplies the second argument to the block."
	1 to: self size do:
		[:index |
		elementAndIndexBlock
			value: (self at: index)
			value: index]! !


!SequenceableCollection methodsFor: 'removing'!
remove: oldObject ifAbsent: anExceptionBlock 
	"SequencableCollections cannot implement removing."

	self shouldNotImplement! !


!SequenceableCollection methodsFor: 'private' stamp: 'sma 5/12/2000 11:33'!
anyOne
	^ self first! !

!SequenceableCollection methodsFor: 'private' stamp: 'tk 7/30/97 12:42'!
asDigitsAt: anInteger in: aCollection do: aBlock
	"(0 to: 1) asDigitsToPower: 4 do: [:each | Transcript cr; show: each printString]"

	self do: 
		[:each | 
		aCollection at: anInteger put: each.
		anInteger = aCollection size 
			ifTrue: [aBlock value: aCollection]
			ifFalse: [self asDigitsAt: anInteger + 1 in: aCollection do: aBlock]].! !

!SequenceableCollection methodsFor: 'private' stamp: 'tk 7/30/97 12:42'!
combinationsAt: jj in: aCollection after: nn do: aBlock
	"Choose k of N items and put in aCollection.  jj-1 already chosen.  Indexes of items are in numerical order, to avoid the same combo being used twice.  In this slot, we are allowed to use items in self indexed by nn+1 to self size.  nn is the index used for position jj-1."
	"(1 to: 6) combinationsSize: 3 do: [:each | Transcript cr; show: each printString]"

nn+1 to: self size do: [:index | 
		aCollection at: jj put: (self at: index).
		jj = aCollection size 
			ifTrue: [aBlock value: aCollection]
			ifFalse: [self combinationsAt: jj + 1 in: aCollection after: index do: aBlock]].! !

!SequenceableCollection methodsFor: 'private' stamp: 'tk 1/7/98 10:57'!
copyReplaceAll: oldSubstring with: newSubstring asTokens: ifTokens
	"Answer a copy of the receiver in which all occurrences of
	oldSubstring have been replaced by newSubstring.
	ifTokens (valid for Strings only) specifies that the characters
	surrounding the recplacement must not be alphanumeric.
		Bruce Simth,  must be incremented by 1 and not 
	newSubstring if ifTokens is true.  See example below. "

	| aString startSearch currentIndex endIndex |
	(ifTokens and: [(self isKindOf: String) not])
		ifTrue: [(self isKindOf: Text) ifFalse: [
			self error: 'Token replacement only valid for Strings']].
	aString _ self.
	startSearch _ 1.
	[(currentIndex _ aString indexOfSubCollection: oldSubstring startingAt: startSearch)
			 > 0]
		whileTrue: 
		[endIndex _ currentIndex + oldSubstring size - 1.
		(ifTokens not
			or: [(currentIndex = 1
					or: [(aString at: currentIndex-1) isAlphaNumeric not])
				and: [endIndex = aString size
					or: [(aString at: endIndex+1) isAlphaNumeric not]]])
			ifTrue: [aString _ aString
					copyReplaceFrom: currentIndex
					to: endIndex
					with: newSubstring.
				startSearch _ currentIndex + newSubstring size]
			ifFalse: [
				ifTokens 
					ifTrue: [startSearch _ currentIndex + 1]
					ifFalse: [startSearch _ currentIndex + newSubstring size]]].
	^ aString

"Test case:
	'test te string' copyReplaceAll: 'te' with: 'longone' asTokens: true   "
! !

!SequenceableCollection methodsFor: 'private'!
errorOutOfBounds

	self error: 'indices are out of bounds'! !

!SequenceableCollection methodsFor: 'private' stamp: 'ward 7/28/97 09:38'!
permutationsStartingAt: anInteger do: aBlock
	"#(1 2 3 4) permutationsDo: [:each | Transcript cr; show: each printString]"

	anInteger > self size ifTrue: [^self].
	anInteger = self size ifTrue: [^aBlock value: self].
	anInteger to: self size do:
		[:i | self swap: anInteger with: i.
		self permutationsStartingAt: anInteger + 1 do: aBlock.
		self swap: anInteger with: i]! !


!SequenceableCollection methodsFor: '*JSON-writing' stamp: 'tonyg 8/17/2005 00:40'!
jsonWriteOn: aStream
	| needComma |
	needComma := false.
	aStream nextPut: $[.
	self do: [:v |
		needComma
			ifTrue: [ aStream nextPutAll: ', ' ]
			ifFalse: [ needComma := true ].
		v jsonWriteOn: aStream.
	].
	aStream nextPut: $].! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SequenceableCollection class
	instanceVariableNames: ''!

!SequenceableCollection class methodsFor: 'stream creation'!
streamContents: blockWithArg
	| stream |
	stream _ WriteStream on: (self new: 100).
	blockWithArg value: stream.
	^stream contents! !

!SequenceableCollection class methodsFor: 'stream creation' stamp: 'di 6/20/97 09:07'!
streamContents: blockWithArg limitedTo: sizeLimit
	| stream |
	stream _ LimitedWriteStream on: (self new: (100 min: sizeLimit)).
	stream setLimit: sizeLimit limitBlock: [^ stream contents].
	blockWithArg value: stream.
	^ stream contents
"
String streamContents: [:s | 1000 timesRepeat: [s nextPutAll: 'Junk']] limitedTo: 25
 'JunkJunkJunkJunkJunkJunkJ'
"! !
