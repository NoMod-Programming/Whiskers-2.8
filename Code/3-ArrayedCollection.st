SequenceableCollection subclass: #ArrayedCollection
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Abstract'!
!ArrayedCollection commentStamp: '<historical>' prior: 0!
I am an abstract collection of elements with a fixed range of integers (from 1 to n>=1) as external keys.!


!ArrayedCollection methodsFor: 'accessing' stamp: 'sma 5/12/2000 11:36'!
size
	"Answer how many elements the receiver contains."

	<primitive: 62>
	^ self basicSize! !


!ArrayedCollection methodsFor: 'adding' stamp: 'sma 5/12/2000 14:09'!
add: newObject
	self shouldNotImplement! !


!ArrayedCollection methodsFor: 'printing'!
storeOn: aStream

	aStream nextPutAll: '(('.
	aStream nextPutAll: self class name.
	aStream nextPutAll: ' new: '.
	aStream store: self size.
	aStream nextPut: $).
	(self storeElementsFrom: 1 to: self size on: aStream)
		ifFalse: [aStream nextPutAll: '; yourself'].
	aStream nextPut: $)! !


!ArrayedCollection methodsFor: 'private'!
defaultElement

	^nil! !

!ArrayedCollection methodsFor: 'private'!
storeElementsFrom: firstIndex to: lastIndex on: aStream

	| noneYet defaultElement arrayElement |
	noneYet _ true.
	defaultElement _ self defaultElement.
	firstIndex to: lastIndex do: 
		[:index | 
		arrayElement _ self at: index.
		arrayElement = defaultElement
			ifFalse: 
				[noneYet
					ifTrue: [noneYet _ false]
					ifFalse: [aStream nextPut: $;].
				aStream nextPutAll: ' at: '.
				aStream store: index.
				aStream nextPutAll: ' put: '.
				aStream store: arrayElement]].
	^noneYet! !


!ArrayedCollection methodsFor: 'sorting' stamp: 'sma 6/1/2000 11:57'!
isSorted
	"Return true if the receiver is sorted by the given criterion.
	Optimization for isSortedBy: [:a :b | a <= b]."

	| lastElm elm |
	self isEmpty ifTrue: [^ true].
	lastElm _ self first.
	2 to: self size do: 
		[:index | 
		elm _ self at: index.
		lastElm <= elm ifFalse: [^ false].
		lastElm _ elm].
	^ true! !

!ArrayedCollection methodsFor: 'sorting' stamp: 'sma 6/1/2000 11:58'!
isSortedBy: aBlock
	"Return true if the receiver is sorted by the given criterion."

	| lastElm elm |
	self isEmpty ifTrue: [^ true].
	lastElm _ self first.
	2 to: self size do: 
		[:index | 
		elm _ self at: index.
		(aBlock value: lastElm value: elm) ifFalse: [^ false].
		lastElm _ elm].
	^ true! !

!ArrayedCollection methodsFor: 'sorting' stamp: 'sma 5/12/2000 14:28'!
mergeFirst: first middle: middle last: last into: dst by: aBlock
	"Private. Merge the sorted ranges [first..middle] and [middle+1..last] 
	of the receiver into the range [first..last] of dst."

	| i1 i2 val1 val2 out |
	i1 _ first.
	i2 _ middle + 1.
	val1 _ self at: i1.
	val2 _ self at: i2.
	out _ first - 1.  "will be pre-incremented"

	"select 'lower' half of the elements based on comparator"
	[(i1 <= middle) and: [i2 <= last]] whileTrue:
		[(aBlock value: val1 value: val2)
			ifTrue: [dst at: (out _ out + 1) put: val1.
					val1 _ self at: (i1 _ i1 + 1)]
			ifFalse: [dst at: (out _ out + 1) put: val2.
					i2 _ i2 + 1.
					i2 <= last ifTrue: [val2 _ self at: i2]]].

	"copy the remaining elements"
	i1 <= middle
		ifTrue: [dst replaceFrom: out + 1 to: last with: self startingAt: i1]
		ifFalse: [dst replaceFrom: out + 1 to: last with: self startingAt: i2]! !

!ArrayedCollection methodsFor: 'sorting' stamp: 'sma 5/12/2000 14:25'!
mergeSortFrom: startIndex to: stopIndex by: aBlock
	"Sort the given range of indices using the mergesort algorithm.
	Mergesort is a worst-case O(N log N) sorting algorithm that usually
	does only half as many comparisons as heapsort or quicksort."

	"Details: recursively split the range to be sorted into two halves,
	mergesort each half, then merge the two halves together. An extra 
	copy of the data is used as temporary storage and successive merge 
	phases copy data back and forth between the receiver and this copy.
	The recursion is set up so that the final merge is performed into the
	receiver, resulting in the receiver being completely sorted."

	self size <= 1 ifTrue: [^ self].  "nothing to do"
	startIndex = stopIndex ifTrue: [^ self].
	self assert: [startIndex >= 1 and: [startIndex < stopIndex]]. "bad start index"
	self assert: [stopIndex <= self size]. "bad stop index"
	self
		mergeSortFrom: startIndex
		to: stopIndex 
		src: self clone 
		dst: self 
		by: aBlock! !

!ArrayedCollection methodsFor: 'sorting' stamp: 'sma 5/12/2000 14:26'!
mergeSortFrom: first to: last src: src dst: dst by: aBlock
	"Private. Split the range to be sorted in half, sort each half, and 
	merge the two half-ranges into dst."

	| middle |
	first = last ifTrue: [^ self].
	middle _ (first + last) // 2.
	self mergeSortFrom: first to: middle src: dst dst: src by: aBlock.
	self mergeSortFrom: middle + 1 to: last src: dst dst: src by: aBlock.
	src mergeFirst: first middle: middle last: last into: dst by: aBlock! !

!ArrayedCollection methodsFor: 'sorting' stamp: 'sma 5/12/2000 14:22'!
sort
	"Sort this array into ascending order using the '<=' operator."

	self sort: [:a :b | a <= b]! !

!ArrayedCollection methodsFor: 'sorting' stamp: 'sma 5/12/2000 14:21'!
sort: aSortBlock 
	"Sort this array using aSortBlock. The block should take two arguments
	and return true if the first element should preceed the second one."

	self
		mergeSortFrom: 1
		to: self size
		by: aSortBlock! !


!ArrayedCollection methodsFor: 'as yet unclassified' stamp: 'EMP 4/5/2016 15:56'!
copyWithArray: newCollection
	"Answer a copy of the receiver that is 1 bigger than the receiver and has 
	newElement at the last element."

	| newIC |
	newIC _ self species new: self size + newCollection size.
	self size = 0 ifTrue: [^ newCollection].
	newCollection size = 0 ifTrue: [^ self].
	newIC 
		replaceFrom: 1
		to: self size
		with: self
		startingAt: 1.
	newIC replaceFrom: (self size + 1) to: (newIC size) with: newCollection startingAt: 1.
	^newIC! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ArrayedCollection class
	instanceVariableNames: ''!

!ArrayedCollection class methodsFor: 'instance creation'!
new
	"Answer a new instance of me, with size = 0."

	^self new: 0! !

!ArrayedCollection class methodsFor: 'instance creation'!
new: size withAll: value 
	"Answer an instance of me, with number of elements equal to size, each 
	of which refers to the argument, value."

	^(self new: size) atAllPut: value! !

!ArrayedCollection class methodsFor: 'instance creation'!
newFrom: aCollection 
	"Answer an instance of me containing the same elements as aCollection."
	| newArray |
	newArray _ self new: aCollection size.
	1 to: aCollection size do: [:i | newArray at: i put: (aCollection at: i)].
	^ newArray

"	Array newFrom: {1. 2. 3}
	{1. 2. 3} as: Array
	{1. 2. 3} as: ByteArray
	{$c. $h. $r} as: String
	{$c. $h. $r} as: Text
"! !

!ArrayedCollection class methodsFor: 'instance creation'!
with: anObject 
	"Answer a new instance of me, containing only anObject."

	| newCollection |
	newCollection _ self new: 1.
	newCollection at: 1 put: anObject.
	^newCollection! !

!ArrayedCollection class methodsFor: 'instance creation'!
with: firstObject with: secondObject 
	"Answer a new instance of me, containing firstObject and secondObject."

	| newCollection |
	newCollection _ self new: 2.
	newCollection at: 1 put: firstObject.
	newCollection at: 2 put: secondObject.
	^newCollection! !

!ArrayedCollection class methodsFor: 'instance creation'!
with: firstObject with: secondObject with: thirdObject 
	"Answer a new instance of me, containing only the three arguments as
	elements."

	| newCollection |
	newCollection _ self new: 3.
	newCollection at: 1 put: firstObject.
	newCollection at: 2 put: secondObject.
	newCollection at: 3 put: thirdObject.
	^newCollection! !

!ArrayedCollection class methodsFor: 'instance creation'!
with: firstObject with: secondObject with: thirdObject with: fourthObject 
	"Answer a new instance of me, containing only the three arguments as
	elements."

	| newCollection |
	newCollection _ self new: 4.
	newCollection at: 1 put: firstObject.
	newCollection at: 2 put: secondObject.
	newCollection at: 3 put: thirdObject.
	newCollection at: 4 put: fourthObject.
	^newCollection! !

!ArrayedCollection class methodsFor: 'instance creation'!
with: firstObject with: secondObject with: thirdObject with: fourthObject with: fifthObject
	"Answer a new instance of me, containing only the five arguments as
	elements."

	| newCollection |
	newCollection _ self new: 5.
	newCollection at: 1 put: firstObject.
	newCollection at: 2 put: secondObject.
	newCollection at: 3 put: thirdObject.
	newCollection at: 4 put: fourthObject.
	newCollection at: 5 put: fifthObject.
	^newCollection! !

!ArrayedCollection class methodsFor: 'instance creation' stamp: 'sw 10/24/1998 22:22'!
with: firstObject with: secondObject with: thirdObject with: fourthObject with: fifthObject with: sixthObject
	"Answer a new instance of me, containing only the 6 arguments as elements."

	| newCollection |
	newCollection _ self new: 6.
	newCollection at: 1 put: firstObject.
	newCollection at: 2 put: secondObject.
	newCollection at: 3 put: thirdObject.
	newCollection at: 4 put: fourthObject.
	newCollection at: 5 put: fifthObject.
	newCollection at: 6 put: sixthObject.
	^ newCollection! !

!ArrayedCollection class methodsFor: 'instance creation' stamp: 'sma 5/12/2000 17:37'!
withAll: aCollection
	"Create a new collection containing all the elements from aCollection."

	^ (self new: aCollection size) replaceFrom: 1 to: aCollection size with: aCollection! !
