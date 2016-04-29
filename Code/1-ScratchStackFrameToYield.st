Object subclass: #ScratchStackFrameToYield
	instanceVariableNames: 'parentFrame '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Execution Engine'!

!ScratchStackFrameToYield methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:18'!
evaluateIn: t1 
	t1 yield.
	^ false! !

!ScratchStackFrameToYield methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:01'!
expression
	^ nil! !

!ScratchStackFrameToYield methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:18'!
hasDeletedReceiver
	^ false! !

!ScratchStackFrameToYield methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:18'!
hasReceiver: t1 
	^ false! !

!ScratchStackFrameToYield methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:18'!
lightUp
	self halt! !

!ScratchStackFrameToYield methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:01'!
needsUnlighting
	^ false! !

!ScratchStackFrameToYield methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:01'!
parentFrame
	^ parentFrame! !

!ScratchStackFrameToYield methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:01'!
parentFrame: t1 
	parentFrame := t1! !

!ScratchStackFrameToYield methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:01'!
shouldUnlight
	^ false! !

!ScratchStackFrameToYield methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:01'!
shouldYield
	^ true! !

!ScratchStackFrameToYield methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:01'!
unlightExpression
	^ self! !
