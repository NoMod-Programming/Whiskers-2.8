Object subclass: #ScratchStackFrameToPerform
	instanceVariableNames: 'parentFrame selector '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Execution Engine'!

!ScratchStackFrameToPerform methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:38'!
evaluateIn: t1 
	t1 perform: selector.
	^ false! !

!ScratchStackFrameToPerform methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 15:18'!
expression
	^ selector! !

!ScratchStackFrameToPerform methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:35'!
hasDeletedReceiver
	^ false! !

!ScratchStackFrameToPerform methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:35'!
hasReceiver: t1 
	^ false! !

!ScratchStackFrameToPerform methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:35'!
lightUp
	self halt! !

!ScratchStackFrameToPerform methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:35'!
needsUnlighting
	^ false! !

!ScratchStackFrameToPerform methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:35'!
parentFrame
	^ parentFrame! !

!ScratchStackFrameToPerform methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:35'!
parentFrame: t1 
	parentFrame := t1! !

!ScratchStackFrameToPerform methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:38'!
selector
	^ selector! !

!ScratchStackFrameToPerform methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:38'!
selector: aSymbol
	selector _ aSymbol! !

!ScratchStackFrameToPerform methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:35'!
shouldUnlight
	^ false! !

!ScratchStackFrameToPerform methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:38'!
shouldYield
	^ false! !

!ScratchStackFrameToPerform methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:35'!
unlightExpression
	^ self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchStackFrameToPerform class
	instanceVariableNames: ''!

!ScratchStackFrameToPerform class methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:40'!
selector: aSymbol
	^ self new selector: aSymbol! !
