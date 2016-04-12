Object subclass: #Stream
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Streams'!
!Stream commentStamp: '<historical>' prior: 0!
I am an abstract class that represents an accessor for a sequence of objects. This sequence is referred to as my "contents".!


!Stream methodsFor: 'accessing'!
contents
	"Answer all of the contents of the receiver."

	self subclassResponsibility! !

!Stream methodsFor: 'accessing' stamp: 'sma 4/22/2000 17:07'!
flush
	"Do nothing by default"! !

!Stream methodsFor: 'accessing'!
next
	"Answer the next object accessible by the receiver."

	self subclassResponsibility! !

!Stream methodsFor: 'accessing'!
next: anInteger 
	"Answer the next anInteger number of objects accessible by the receiver."

	| aCollection |
	aCollection _ OrderedCollection new.
	anInteger timesRepeat: [aCollection addLast: self next].
	^aCollection! !

!Stream methodsFor: 'accessing'!
nextMatchAll: aColl
    "Answer true if next N objects are the ones in aColl,
     else false.  Advance stream of true, leave as was if false."
    | save |
    save _ self position.
    aColl do: [:each |
       (self next) = each ifFalse: [
            self position: save.
            ^ false]
        ].
    ^ true! !

!Stream methodsFor: 'accessing'!
nextPut: anObject 
	"Insert the argument, anObject, as the next object accessible by the 
	receiver. Answer anObject."

	self subclassResponsibility! !

!Stream methodsFor: 'accessing'!
nextPutAll: aCollection 
	"Append the elements of aCollection to the sequence of objects accessible 
	by the receiver. Answer aCollection."

	aCollection do: [:v | self nextPut: v].
	^aCollection! !

!Stream methodsFor: 'accessing' stamp: 'ls 9/12/1998 20:55'!
upToEnd
	"answer the remaining elements in the string"
	| elements |
	elements _ OrderedCollection new.
	[ self atEnd ] whileFalse: [ 
		elements add: self next ].
	^elements! !


!Stream methodsFor: 'testing'!
atEnd
	"Answer whether the receiver can access any more objects."

	self subclassResponsibility! !

!Stream methodsFor: 'testing' stamp: 'EMP 11/20/2015 11:50'!
isStream
	^ true! !


!Stream methodsFor: 'enumerating'!
do: aBlock 
	"Evaluate aBlock for each of the objects accessible by receiver."

	[self atEnd]
		whileFalse: [aBlock value: self next]! !


!Stream methodsFor: 'printing' stamp: 'sma 6/1/2000 09:56'!
print: anObject
	"Have anObject print itself on the receiver."

	anObject printOn: self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Stream class
	instanceVariableNames: ''!

!Stream class methodsFor: 'instance creation'!
new

	self error: 'Streams are created with on: and with:'! !
