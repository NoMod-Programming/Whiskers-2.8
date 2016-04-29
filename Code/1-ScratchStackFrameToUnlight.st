Object subclass: #ScratchStackFrameToUnlight
	instanceVariableNames: 'parentFrame expressionToUnlight '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Execution Engine'!

!ScratchStackFrameToUnlight methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:00'!
evaluateIn: t1 
	expressionToUnlight litUp: false.
	t1 popStackFrameNoUnhightlight.
	^ false! !

!ScratchStackFrameToUnlight methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:00'!
expression
	^ expressionToUnlight! !

!ScratchStackFrameToUnlight methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:00'!
expression: t1 
	expressionToUnlight := t1! !

!ScratchStackFrameToUnlight methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:00'!
hasDeletedReceiver
	^ expressionToUnlight hasDeletedReceiver! !

!ScratchStackFrameToUnlight methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:00'!
hasReceiver: t1 
	^ expressionToUnlight receiver == t1! !

!ScratchStackFrameToUnlight methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:00'!
needsUnlighting
	^ false! !

!ScratchStackFrameToUnlight methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:00'!
parentFrame
	^ parentFrame! !

!ScratchStackFrameToUnlight methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:00'!
parentFrame: t1 
	parentFrame := t1! !

!ScratchStackFrameToUnlight methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:00'!
shouldUnlight
	^ true! !

!ScratchStackFrameToUnlight methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:00'!
unlightExpression
	expressionToUnlight litUp: false! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchStackFrameToUnlight class
	instanceVariableNames: ''!

!ScratchStackFrameToUnlight class methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:05'!
forExpression: t1 
	^ super new expression: t1! !
