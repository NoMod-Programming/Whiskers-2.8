Object subclass: #SharedPool
	instanceVariableNames: ''
	classVariableNames: 'SharedPoolDictionary '
	poolDictionaries: ''
	category: 'System-Pools'!
!SharedPool commentStamp: '<historical>' prior: 0!
A shared pool represents a set of bindings which are accessible to all classes which import the pool in its 'pool dictionaries'. SharedPool is NOT a dictionary but rather a name space. Bindings are represented by 'class variables' - as long as we have no better way to represent them at least.!


"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SharedPool class
	instanceVariableNames: ''!

!SharedPool class methodsFor: 'enumerating' stamp: 'EMP 11/20/2015 12:29'!
keysDo: aBlock
"A hopefully temporary fix for an issue arising from miss-spelled variable names in code being compiled. The correction code (see Class>possibleVariablesFor:continuedFrom: assumes that sharedPools are Dictionaries. The proper fix would involve making sure all pools are actually subclasses of SharedPool, which they are not currently."
	SharedPoolDictionary bindingsDo:[:b|
		aBlock value: b key]! !


!SharedPool class methodsFor: 'name lookup' stamp: 'ar 5/18/2003 17:46'!
bindingOf: varName
	"Answer the binding of some variable resolved in the scope of the receiver"
	| aSymbol binding |
	aSymbol := varName asSymbol.

	"First look in classVar dictionary."
	binding := self classPool bindingOf: aSymbol.
	binding ifNotNil:[^binding].

	"Next look in shared pools."
	self sharedPools do:[:pool | 
		binding := pool bindingOf: aSymbol.
		binding ifNotNil:[^binding].
	].

	"subclassing and environment are not preserved"
	^nil! !

!SharedPool class methodsFor: 'name lookup' stamp: 'ar 5/18/2003 20:33'!
bindingsDo: aBlock
	^self classPool bindingsDo: aBlock! !

!SharedPool class methodsFor: 'name lookup' stamp: 'ar 5/18/2003 18:14'!
classBindingOf: varName
	"For initialization messages grant the regular scope"
	^super bindingOf: varName! !

!SharedPool class methodsFor: 'name lookup' stamp: 'tween 9/13/2004 10:10'!
hasBindingThatBeginsWith: aString
	"Answer true if the receiver has a binding that begins with aString, false otherwise"

	"First look in classVar dictionary."
	(self classPool hasBindingThatBeginsWith: aString) ifTrue:[^true].
	"Next look in shared pools."
	self sharedPools do:[:pool | 
		(pool hasBindingThatBeginsWith: aString) ifTrue: [^true]].
	^false! !

!SharedPool class methodsFor: 'name lookup' stamp: 'tpr 5/29/2003 18:12'!
includesKey: aName
	"does this pool include aName"
	^(self bindingOf: aName) notNil! !
