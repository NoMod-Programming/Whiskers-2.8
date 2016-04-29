ReporterBlockMorph subclass: #CustomReporterMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!CustomReporterMorph commentStamp: 'EMP 11/10/2015 15:12' prior: 0!
A custom reporter meant to report the values from custom blocks.!


!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/8/2015 14:56'!
asBlockTuple
	^ {#getParam. self commandSpec. (isBoolean ifTrue: [#b] ifFalse: [#r])}! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/8/2015 14:54'!
commandSpec
	^ (super commandSpec asByteArray) asString! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/13/2015 13:53'!
commandSpec: aString
	super commandSpec: aString asUTF8! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/12/2016 15:54'!
evaluate
	| procedureHat arg |
	(procedureHat _ self ownerThatIsA: ProcedureHatBlockMorph) ifNil: [^ ''].
	(arg _ ((procedureHat scratchProc) ifNotNil: [procedureHat scratchProc getArgumentOrNil: (self selector asUTF8)])) ifNil: [^ '0'].
	^ arg! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 14:57'!
evaluateIn: t1 
	t1 returnValueToParentFrame: (t1 getArgumentOrNil: self selector).
	t1 popStackFrameNoUnhightlight.
	^ false! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/12/2016 15:54'!
evaluateWithArgs: args
	| procedureHat arg |
	(procedureHat _ self ownerThatIsA: ProcedureHatBlockMorph) ifNil: [^ ''].
	(arg _ ((procedureHat scratchProc) ifNotNil: [procedureHat scratchProc getArgumentOrNil: (self selector asUTF8)])) ifNil: [^ '0'].
	^ arg! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/3/2015 13:48'!
initialize
	super initialize.
	self color: (Color r: 89/255 g: 71/255 b:177/255)! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/8/2015 14:18'!
isBoolean: aBoolean
	isBoolean _ aBoolean.
	self changed! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/5/2016 14:51'!
isParamGetter
	^ true! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/13/2016 15:39'!
rightButtonMenu
	| menu choice |

	menu _ CustomMenu new.
	menu add: 'duplicate' action: #duplicate.
	menu add: 'delete' action: #delete.
	menu addLine.
	menu add: 'add comment' action: #addComment.
	choice _ menu startUp.
	choice ifNotNil: [self perform: choice].! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/13/2015 13:53'!
selector: aString
	super selector: aString asUTF8! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/8/2015 14:51'!
showBlockType
	DialogBoxMorph inform: isBoolean asString! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/8/2015 14:51'!
showCommandSpec
	DialogBoxMorph inform: commandSpec asString! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/8/2015 14:51'!
showSelector
	DialogBoxMorph inform: selector asString! !

!CustomReporterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/8/2015 14:47'!
startDrag: evt 
	| startEvt rootForGrab |
	(self owner isKindOf: CustomProcedureHolder) ifFalse: [^ super startDrag: evt].
	startEvt _ evt hand firstClickEvent.
	startEvt ifNil: [startEvt _ evt].
	rootForGrab _ self fullCopy.
	rootForGrab ifNil: [^ self]. "should never happen, well, because I EXIST :P"
	evt hand grabMorph: rootForGrab.
	rootForGrab position: evt hand position + (rootForGrab topLeft - startEvt cursorPoint)! !
