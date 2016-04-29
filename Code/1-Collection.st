Object subclass: #Collection
	instanceVariableNames: ''
	classVariableNames: 'RandomForPicking '
	poolDictionaries: ''
	category: 'Collections-Abstract'!
!Collection commentStamp: '<historical>' prior: 0!
I am the abstract superclass of all classes that represent a group of elements.!


!Collection methodsFor: 'accessing' stamp: 'jm 11/9/2002 23:00'!
average
	"Answer the average of my elements. Assume I contain only numbers."

	^ self sum asFloat / self size
! !

!Collection methodsFor: 'accessing' stamp: 'jm 5/29/2003 19:32'!
contents
	"Compatibility with streams."

	^ self
! !

!Collection methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:16'!
evaluateIn: t1 
	t1 evaluateSequence.
	^ false! !

!Collection methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:20'!
hasDeletedReceiver
	^ false! !

!Collection methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:24'!
hasReceiver: t1 
	^ false! !

!Collection methodsFor: 'accessing' stamp: 'jm 5/29/2003 19:38'!
max
	"Answer the maximum element of this collection. Raise an error if the collection is empty."

	^ self inject: self anyOne into: [:max :each | max max: each]
! !

!Collection methodsFor: 'accessing' stamp: 'jm 5/29/2003 19:38'!
min
	"Answer the minimum element of this collection. Raise an error if the collection is empty."

	^ self inject: self anyOne into: [:min :each | min min: each]
! !

!Collection methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:24'!
receiver
	^ nil! !

!Collection methodsFor: 'accessing' stamp: 'sma 5/12/2000 11:34'!
size
	"Answer how many elements the receiver contains."

	| tally |
	tally _ 0.
	self do: [:each | tally _ tally + 1].
	^ tally! !

!Collection methodsFor: 'accessing' stamp: 'jm 5/29/2003 19:44'!
sum
	"Answer the sum of the elements of this collection. Answer zero if the collection is empty."
	"Details: To allow collections of any kind of object that understands + and - to be summed, the inital sum is an arbitrary sample element (as opposed to 0). This initial value is then subtracted from the final sum."

	| sum sample |
	self size = 0 ifTrue: [^ 0].
	sample _ self anyOne.
	sum _ self inject: sample into: [:accum :each | accum + each].
	^ sum - sample
! !


!Collection methodsFor: 'adding'!
add: newObject 
	"Include newObject as one of the receiver's elements. Answer newObject. 
	ArrayedCollections cannot respond to this message."

	self subclassResponsibility! !

!Collection methodsFor: 'adding' stamp: 'sma 5/12/2000 17:26'!
addAll: aCollection 
	"Include all the elements of aCollection as the receiver's elements. Answer 
	aCollection. Actually, any object responding to #do: can be used as argument."

	aCollection do: [:each | self add: each].
	^ aCollection! !


!Collection methodsFor: 'comparing' stamp: 'sma 5/12/2000 12:08'!
hash
	"A default hash function for any collection.  Note that this method is 
	insensitive to contents when the size is greater than 10, so critical 
	applications that compare many large collections of the same length 
	will want to refine this behavior."

	| hash |
	hash _ self species hash.
	self size <= 10 ifTrue: [self do: [:elem | hash _ hash bitXor: elem hash]].
	^ hash bitXor: self size hash! !


!Collection methodsFor: 'converting' stamp: 'sma 5/6/2000 20:22'!
asArray
	"Answer an Array whose elements are the elements of the receiver.
	Implementation note: Cannot use ''Array withAll: self'' as that only
	works for SequenceableCollections which support the replacement 
	primitive."

	| array index |
	array _ Array new: self size.
	index _ 0.
	self do: [:each | array at: (index _ index + 1) put: each].
	^ array! !

!Collection methodsFor: 'converting' stamp: 'sma 5/6/2000 20:10'!
asBag
	"Answer a Bag whose elements are the elements of the receiver."

	^ Bag withAll: self! !

!Collection methodsFor: 'converting' stamp: 'sma 5/6/2000 20:22'!
asByteArray
	"Answer a ByteArray whose elements are the elements of the receiver.
	Implementation note: Cannot use ''ByteArray withAll: self'' as that only
	works for SequenceableCollections which support the replacement 
	primitive."

	| array index |
	array _ ByteArray new: self size.
	index _ 0.
	self do: [:each | array at: (index _ index + 1) put: each].
	^ array! !

!Collection methodsFor: 'converting' stamp: 'sma 5/12/2000 17:43'!
asOrderedCollection
	"Answer an OrderedCollection whose elements are the elements of the
	receiver. The order in which elements are added depends on the order
	in which the receiver enumerates its elements. In the case of unordered
	collections, the ordering is not necessarily the same for multiple 
	requests for the conversion."

	^ self as: OrderedCollection! !

!Collection methodsFor: 'converting' stamp: 'sma 5/6/2000 20:29'!
asSet
	"Answer a Set whose elements are the unique elements of the receiver."

	^ Set withAll: self! !

!Collection methodsFor: 'converting' stamp: 'sma 5/12/2000 17:44'!
asSortedCollection
	"Answer a SortedCollection whose elements are the elements of the 
	receiver. The sort order is the default less than or equal."

	^ self as: SortedCollection! !

!Collection methodsFor: 'converting' stamp: 'sma 5/12/2000 17:46'!
asSortedCollection: aSortBlock 
	"Answer a SortedCollection whose elements are the elements of the 
	receiver. The sort order is defined by the argument, aSortBlock."

	| aSortedCollection |
	aSortedCollection _ SortedCollection new: self size.
	aSortedCollection sortBlock: aSortBlock.
	aSortedCollection addAll: self.
	^ aSortedCollection! !


!Collection methodsFor: 'copying' stamp: 'sma 5/12/2000 14:41'!
copyWith: newElement
	"Answer a new collection with newElement added (as last
	element if sequenceable)."

	^ self copy
		add: newElement;
		yourself! !

!Collection methodsFor: 'copying' stamp: 'sma 5/12/2000 14:43'!
copyWithout: oldElement 
	"Answer a copy of the receiver that does not contain any
	elements equal to oldElement."

	^ self reject: [:each | each = oldElement]

"Examples:
	'fred the bear' copyWithout: $e
	#(2 3 4 5 5 6) copyWithout: 5
"! !


!Collection methodsFor: 'enumerating' stamp: 'sma 4/30/2000 11:17'!
anySatisfy: aBlock
	"Evaluate aBlock with the elements of the receiver.
	If aBlock returns true for any element return true.
	Otherwise return false."

	self do: [:each | (aBlock value: each) ifTrue: [^ true]].
	^ false! !

!Collection methodsFor: 'enumerating'!
associationsDo: aBlock
	"Evaluate aBlock for each of the receiver's elements (key/value 
	associations).  If any non-association is within, the error is not caught now,
	but later, when a key or value message is sent to it."

	self do: aBlock! !

!Collection methodsFor: 'enumerating' stamp: 'sma 5/12/2000 11:45'!
collect: aBlock 
	"Evaluate aBlock with each of the receiver's elements as the argument.  
	Collect the resulting values into a collection like the receiver. Answer  
	the new collection."

	| newCollection |
	newCollection _ self species new.
	self do: [:each | newCollection add: (aBlock value: each)].
	^ newCollection! !

!Collection methodsFor: 'enumerating' stamp: 'sma 5/12/2000 11:20'!
detect: aBlock 
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Answer the first element for which aBlock evaluates to true."

	^ self detect: aBlock ifNone: [self errorNotFound: aBlock]! !

!Collection methodsFor: 'enumerating' stamp: 'sma 5/12/2000 11:52'!
detect: aBlock ifNone: exceptionBlock 
	"Evaluate aBlock with each of the receiver's elements as the argument.  
	Answer the first element for which aBlock evaluates to true. If none  
	evaluate to true, then evaluate the argument, exceptionBlock."

	self do: [:each | (aBlock value: each) ifTrue: [^ each]].
	^ exceptionBlock value! !

!Collection methodsFor: 'enumerating'!
do: aBlock 
	"Evaluate aBlock with each of the receiver's elements as the argument."

	self subclassResponsibility! !

!Collection methodsFor: 'enumerating'!
inject: thisValue into: binaryBlock 
	"Accumulate a running value associated with evaluating the argument, 
	binaryBlock, with the current value of the argument, thisValue, and the 
	receiver as block arguments. For instance, to sum the numeric elements 
	of a collection, aCollection inject: 0 into: [:subTotal :next | subTotal + 
	next]."

	| nextValue |
	nextValue _ thisValue.
	self do: [:each | nextValue _ binaryBlock value: nextValue value: each].
	^nextValue! !

!Collection methodsFor: 'enumerating'!
occurrencesOf: anObject 
	"Answer how many of the receiver's elements are equal to anObject."

	| tally |
	tally _ 0.
	self do: [:each | anObject = each ifTrue: [tally _ tally + 1]].
	^tally! !

!Collection methodsFor: 'enumerating'!
reject: aBlock 
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Collect into a new collection like the receiver only those elements for 
	which aBlock evaluates to false. Answer the new collection."

	^self select: [:element | (aBlock value: element) == false]! !

!Collection methodsFor: 'enumerating'!
select: aBlock 
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Collect into a new collection like the receiver, only those elements for 
	which aBlock evaluates to true. Answer the new collection."

	| newCollection |
	newCollection _ self species new.
	self do: [:each | (aBlock value: each) ifTrue: [newCollection add: each]].
	^newCollection! !

!Collection methodsFor: 'enumerating' stamp: 'sma 5/12/2000 11:59'!
select: selectBlock thenCollect: collectBlock
	"Utility method to improve readability."

	^ (self select: selectBlock) collect: collectBlock! !


!Collection methodsFor: 'removing' stamp: 'sma 5/12/2000 11:22'!
remove: oldObject 
	"Remove oldObject from the receiver's elements. Answer oldObject 
	unless no element is equal to oldObject, in which case, raise an error.
	ArrayedCollections cannot respond to this message."

	^ self remove: oldObject ifAbsent: [self errorNotFound: oldObject]! !

!Collection methodsFor: 'removing' stamp: 'sma 5/12/2000 11:14'!
remove: oldObject ifAbsent: anExceptionBlock 
	"Remove oldObject from the receiver's elements. If several of the 
	elements are equal to oldObject, only one is removed. If no element is 
	equal to oldObject, answer the result of evaluating anExceptionBlock. 
	Otherwise, answer the argument, oldObject. ArrayedCollections cannot 
	respond to this message."

	self subclassResponsibility! !

!Collection methodsFor: 'removing' stamp: 'jm 5/29/2003 19:48'!
removeAll: aCollection 
	"Remove each element of aCollection which is present in the receiver from the receiver. Answer aCollection. No error is raised if an element isn't found. ArrayedCollections cannot respond to this message."

	aCollection do: [:each | self remove: each ifAbsent: []].
	^ aCollection
! !

!Collection methodsFor: 'removing' stamp: 'sma 5/12/2000 11:19'!
removeAllSuchThat: aBlock 
	"Evaluate aBlock for each element and remove all that elements from
	the receiver for that aBlock evaluates to true.  Use a copy to enumerate 
	collections whose order changes when an element is removed (i.e. Sets)."

	self copy do: [:each | (aBlock value: each) ifTrue: [self remove: each]]! !


!Collection methodsFor: 'testing' stamp: 'sma 5/12/2000 14:07'!
includes: anObject 
	"Answer whether anObject is one of the receiver's elements."

	^ self anySatisfy: [:each | each = anObject]! !

!Collection methodsFor: 'testing'!
includesAnyOf: aCollection 
	"Answer whether any element of aCollection is one of the receiver's elements."
	aCollection do: [:elem | (self includes: elem) ifTrue: [^ true]].
	^ false! !

!Collection methodsFor: 'testing' stamp: 'jm 1/1/2009 16:59'!
isCollection
	"Answer true if I represent a Collection."

	^ true
! !

!Collection methodsFor: 'testing'!
isEmpty
	"Answer whether the receiver contains any elements."

	^self size = 0! !

!Collection methodsFor: 'testing' stamp: 'sw 4/7/1999 17:28'!
isEmptyOrNil
	"Answer whether the receiver contains any elements, or is nil.  Useful in numerous situations where one wishes the same reaction to an empty collection or to nil"

	^ self size = 0! !


!Collection methodsFor: 'printing' stamp: 'sma 6/1/2000 09:39'!
printElementsOn: aStream
	aStream nextPut: $(.
	self do: [:element | aStream print: element; space].
	self isEmpty ifFalse: [aStream skip: -1].
	aStream nextPut: $)! !

!Collection methodsFor: 'printing' stamp: 'sma 6/1/2000 09:41'!
printNameOn: aStream
	super printOn: aStream! !

!Collection methodsFor: 'printing' stamp: 'sma 6/1/2000 09:41'!
printOn: aStream 
	"Append a sequence of characters that identify the receiver to aStream."

	self printNameOn: aStream.
	self printElementsOn: aStream! !

!Collection methodsFor: 'printing'!
storeOn: aStream 
	"Refer to the comment in Object|storeOn:."

	| noneYet |
	aStream nextPutAll: '(('.
	aStream nextPutAll: self class name.
	aStream nextPutAll: ' new)'.
	noneYet _ true.
	self do: 
		[:each | 
		noneYet
			ifTrue: [noneYet _ false]
			ifFalse: [aStream nextPut: $;].
		aStream nextPutAll: ' add: '.
		aStream store: each].
	noneYet ifFalse: [aStream nextPutAll: '; yourself'].
	aStream nextPut: $)! !


!Collection methodsFor: 'private' stamp: 'sma 5/12/2000 11:33'!
anyOne
	"Answer a representative sample of the receiver. This method can
	be helpful when needing to preinfer the nature of the contents of 
	semi-homogeneous collections."

	self emptyCheck.
	self do: [:each | ^ each]! !

!Collection methodsFor: 'private'!
emptyCheck

	self isEmpty ifTrue: [self errorEmptyCollection]! !

!Collection methodsFor: 'private'!
errorEmptyCollection

	self error: 'this collection is empty'! !

!Collection methodsFor: 'private'!
errorNoMatch

	self error: 'collection sizes do not match'! !

!Collection methodsFor: 'private' stamp: 'sma 5/12/2000 11:22'!
errorNotFound: anObject
	"Actually, this should raise a special Exception not just an error."

	self error: 'Object is not in the collection.'! !

!Collection methodsFor: 'private'!
errorNotKeyed

	self error: self class name, 's do not respond to keyed accessing messages.'! !

!Collection methodsFor: 'private'!
toBraceStack: itsSize 
	"Push receiver's elements onto the stack of thisContext sender.  Error if receiver does
	 not have itsSize elements or if receiver is unordered.
	 Do not call directly: this is called by {a. b} _ ... constructs."

	self size ~= itsSize ifTrue:
		[self error: 'Trying to store ', self size printString,
					' values into ', itsSize printString, ' variables.'].
	thisContext sender push: itsSize fromIndexable: self! !


!Collection methodsFor: '*jsbridge-core' stamp: 'bf 11/25/2014 18:12'!
asJSArgument
	"converted to JS array by plugin"
	| array i |
	array := Array new: self size.
	i := 0.
	self do: [:each | array at: (i := i + 1) put: each asJSArgument].
	^ array
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Collection class
	instanceVariableNames: ''!

!Collection class methodsFor: 'instance creation' stamp: 'sma 5/6/2000 19:58'!
with: anObject 
	"Answer an instance of me containing anObject."

	^ self new
		add: anObject;
		yourself! !

!Collection class methodsFor: 'instance creation' stamp: 'sma 5/6/2000 20:01'!
with: firstObject with: secondObject 
	"Answer an instance of me containing the two arguments as elements."

	^ self new
		add: firstObject;
		add: secondObject;
		yourself! !

!Collection class methodsFor: 'instance creation' stamp: 'sma 5/6/2000 20:03'!
with: firstObject with: secondObject with: thirdObject 
	"Answer an instance of me containing the three arguments as elements."

	^ self new
		add: firstObject;
		add: secondObject;
		add: thirdObject;
		yourself! !

!Collection class methodsFor: 'instance creation' stamp: 'sma 5/6/2000 20:06'!
with: firstObject with: secondObject with: thirdObject with: fourthObject 
	"Answer an instance of me, containing the four arguments as the elements."

	^ self new
		add: firstObject;
		add: secondObject;
		add: thirdObject;
		add: fourthObject;
		yourself! !

!Collection class methodsFor: 'instance creation' stamp: 'sma 5/6/2000 20:06'!
with: firstObject with: secondObject with: thirdObject with: fourthObject with: fifthObject
	"Answer an instance of me, containing the five arguments as the elements."

	^ self new
		add: firstObject;
		add: secondObject;
		add: thirdObject;
		add: fourthObject;
		add: fifthObject;
		yourself! !

!Collection class methodsFor: 'instance creation' stamp: 'sma 5/6/2000 20:06'!
with: firstObject with: secondObject with: thirdObject with: fourthObject with: fifthObject with: sixthObject
	"Answer an instance of me, containing the six arguments as the elements."

	^ self new
		add: firstObject;
		add: secondObject;
		add: thirdObject;
		add: fourthObject;
		add: fifthObject;
		add: sixthObject;
		yourself! !

!Collection class methodsFor: 'instance creation' stamp: 'sma 5/6/2000 20:07'!
withAll: aCollection
	"Create a new collection containing all the elements from aCollection."

	^ (self new: aCollection size)
		addAll: aCollection;
		yourself! !


!Collection class methodsFor: 'private' stamp: 'sma 3/3/2000 10:45'!
initialize
	"Set up a Random number generator to be used by atRandom when the 
	user does not feel like creating his own Random generator."

	RandomForPicking _ Random new! !

!Collection class methodsFor: 'private' stamp: 'sma 5/12/2000 12:31'!
randomForPicking
	^ RandomForPicking! !


Collection initialize!
