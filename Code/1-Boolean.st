Object subclass: #Boolean
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Kernel-Objects'!
!Boolean commentStamp: '<historical>' prior: 0!
Boolean is an abstract class defining the protocol for logic testing operations and conditional control structures for the logical values represented by the instances of its subclasses True and False.

Boolean redefines #new so no instances of Boolean can be created. It also redefines several messages in the 'copying' protocol to ensure that only one instance of each of its subclasses True (the global true, logical assertion) and False (the global false, logical negation) ever exist in the system.!


!Boolean methodsFor: 'logical operations'!
& aBoolean 
	"Evaluating conjunction. Evaluate the argument. Then answer true if 
	both the receiver and the argument are true."

	self subclassResponsibility! !

!Boolean methodsFor: 'logical operations'!
not
	"Negation. Answer true if the receiver is false, answer false if the 
	receiver is true."

	self subclassResponsibility! !

!Boolean methodsFor: 'logical operations'!
| aBoolean 
	"Evaluating disjunction (OR). Evaluate the argument. Then answer true 
	if either the receiver or the argument is true."

	self subclassResponsibility! !


!Boolean methodsFor: 'controlling'!
and: alternativeBlock 
	"Nonevaluating conjunction. If the receiver is true, answer the value of 
	the argument, alternativeBlock; otherwise answer false without 
	evaluating the argument."

	self subclassResponsibility! !

!Boolean methodsFor: 'controlling'!
ifFalse: alternativeBlock 
	"If the receiver is true (i.e., the condition is true), then the value is the 
	true alternative, which is nil. Otherwise answer the result of evaluating 
	the argument, alternativeBlock. Create an error notification if the 
	receiver is nonBoolean. Execution does not actually reach here because 
	the expression is compiled in-line."

	self subclassResponsibility! !

!Boolean methodsFor: 'controlling'!
ifFalse: falseAlternativeBlock ifTrue: trueAlternativeBlock 
	"Same as ifTrue:ifFalse:."

	self subclassResponsibility! !

!Boolean methodsFor: 'controlling'!
ifTrue: alternativeBlock 
	"If the receiver is false (i.e., the condition is false), then the value is the 
	false alternative, which is nil. Otherwise answer the result of evaluating 
	the argument, alternativeBlock. Create an error notification if the 
	receiver is nonBoolean. Execution does not actually reach here because 
	the expression is compiled in-line."

	self subclassResponsibility! !

!Boolean methodsFor: 'controlling'!
ifTrue: trueAlternativeBlock ifFalse: falseAlternativeBlock
	"If the receiver is true (i.e., the condition is true), then answer the value 
	of the argument trueAlternativeBlock. If the receiver is false, answer the 
	result of evaluating the argument falseAlternativeBlock. If the receiver 
	is a nonBoolean then create an error notification. Execution does not 
	actually reach here because the expression is compiled in-line."

	self subclassResponsibility! !

!Boolean methodsFor: 'controlling'!
or: alternativeBlock 
	"Nonevaluating disjunction. If the receiver is false, answer the value of 
	the argument, alternativeBlock; otherwise answer true without 
	evaluating the argument."

	self subclassResponsibility! !


!Boolean methodsFor: 'copying' stamp: 'EMP 11/30/2015 14:38'!
asBoolean
	"I am a boolean. Therefore, don't do anything else other than answer self"! !

!Boolean methodsFor: 'copying' stamp: 'tk 6/26/1998 11:32'!
clone 
	"Receiver has two concrete subclasses, True and False.
	Only one instance of each should be made, so return self."! !

!Boolean methodsFor: 'copying'!
deepCopy 
	"Receiver has two concrete subclasses, True and False.
	Only one instance of each should be made, so return self."! !

!Boolean methodsFor: 'copying'!
shallowCopy 
	"Receiver has two concrete subclasses, True and False.
	Only one instance of each should be made, so return self."! !


!Boolean methodsFor: 'printing'!
storeOn: aStream 
	"Refer to the comment in Object|storeOn:."

	self printOn: aStream! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Boolean class
	instanceVariableNames: ''!

!Boolean class methodsFor: 'instance creation'!
new
	self error: 'You may not create any more Booleans - this is two-valued logic'! !
