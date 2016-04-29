Object subclass: #VariableFrame
	instanceVariableNames: 'vars '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Execution Engine'!

!VariableFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/14/2016 16:03'!
add: t1 
	vars at: t1 put: 0! !

!VariableFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/14/2016 16:03'!
changeVar: t1 by: t2 
	| t3 |
	t3 _ vars at: t1 asString ifAbsent: [^ self].
	self setVar: t1 to: t3 asNumberNoError + t2 asNumberNoError! !

!VariableFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/14/2016 16:03'!
forNames: t1 
	t1 do: [:t2 | vars at: t2 put: 0]! !

!VariableFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/14/2016 16:03'!
getVar: t1 
	^ vars at: t1 asString ifAbsent: [0]! !

!VariableFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/14/2016 16:03'!
initialize
	super initialize.
	vars _ Dictionary new! !

!VariableFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/14/2016 16:03'!
interpretStringAsNumberIfPossible: t1 
	| t2 t3 t4 |
	(t1 isKindOf: String)
		ifFalse: [^ t1].
	t1 size = 0 ifTrue: [^ t1].
	(t1 first isKindOf: Character)
		ifTrue: [t2 _ ReadStream on: t1 asByteArray]
		ifFalse: [t2 _ ReadStream on: t1].
	t3 _ '0123456789' asByteArray.
	t4 _ false.
	(t2 atEnd not and: [t2 peek = $- asciiValue])
		ifTrue: [t2 next].
	[t2 atEnd not and: [t3 includes: t2 peek]]
		whileTrue: 
			[t4 _ true.
			t2 next].
	(t2 atEnd not and: [t2 peek = $. asciiValue])
		ifTrue: [t2 next].
	[t2 atEnd not and: [t3 includes: t2 peek]]
		whileTrue: 
			[t4 _ true.
			t2 next].
	(t2 atEnd and: [t4])
		ifTrue: [^ t1 asNumberNoError].
	^ t1! !

!VariableFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/14/2016 16:03'!
remove: t1 
	vars removeKey: t1! !

!VariableFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/14/2016 16:03'!
renameVar: t1 to: t2 
	| t3 |
	(vars includesKey: t1)
		ifTrue: 
			[t3 _ vars at: t1.
			self remove: t1]
		ifFalse: [t3 _ 0].
	vars at: t2 put: t3! !

!VariableFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/14/2016 16:04'!
scope
	^ self varNamesMenu! !

!VariableFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/14/2016 16:03'!
setVar: t1 to: t2 
	vars at: t1 put: t2! !

!VariableFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/14/2016 16:04'!
varNamesMenu
	^ vars keys asSortedCollection asArray! !

!VariableFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/14/2016 16:04'!
vars
	^ vars! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

VariableFrame class
	instanceVariableNames: ''!

!VariableFrame class methodsFor: 'as yet unclassified' stamp: 'EMP 4/15/2016 17:28'!
forNames: t1 
	^ self new forNames: t1! !
