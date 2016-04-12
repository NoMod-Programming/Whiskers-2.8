Object subclass: #ScratchStackFrame
	instanceVariableNames: 'parentFrame expression arguments pc startTime startValue shouldUnlight '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Execution Engine'!
!ScratchStackFrame commentStamp: 'jm 3/23/2005 09:11' prior: 0!
A ScratchStackFrame describes the state of a ScratchProcess.

Each ScratchProcess has a pointer to a ScratchStackFrame containing its state. Whenever the ScratchProcess yields control, its ScratchStackFrame tells it exactly where it left off.

Structure:
  parentFrame	the ScratchStackFrame to return to when this one has been evaluated.
  expression		ArgMorph, BlockMorph, a collection of blocks to evaluate,
					#shouldYield or #returnMarker
  arguments		the OrderedCollection of arg values computed so far (if expression is a BlockMorph)
  pc				the index of the next block to evaluate (if expression is a Collection)
  startTime		the time at which evaluation began (if expression is a timed CommandBlockMorph)
  startValue		the starting value for interpolation (if expression is a timed CommandBlockMorph)
  shouldUnlight	a Boolean that indicates if we should unlight the current expression (a block)
!


!ScratchStackFrame methodsFor: 'initialization' stamp: 'jm 3/23/2005 09:09'!
initialize

	parentFrame _ nil.
	expression _ nil.
	arguments _ OrderedCollection new. 
	pc _ 1.
	shouldUnlight _ false.
! !


!ScratchStackFrame methodsFor: 'accessing' stamp: 'DaveF 7/9/2003 19:46'!
addArgument: aValue
	"Adds this value to the list of evaluated arguments available in this stack frame."

	arguments add: aValue.
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'ee 2/27/2009 13:09'!
arguments
	"Answers the values of the arguments to be sent to the current command."

	^ arguments
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/5/2016 15:39'!
arguments: anOrderedCollection
	"Answers the values of the arguments to be sent to the current command."

	^ arguments _ anOrderedCollection
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'DaveF 7/4/2003 11:50'!
expression

	^ expression
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'DaveF 7/4/2003 11:33'!
expression: anExpression

	expression _ anExpression.
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'DaveF 7/8/2003 00:11'!
parentFrame

	^ parentFrame
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'DaveF 7/8/2003 00:10'!
parentFrame: aScratchStackFrame
	"Sets this frame's parent frame."

	parentFrame _ aScratchStackFrame.
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'DaveF 7/8/2003 00:06'!
pc
	"Answers the current program counter."

	^ pc
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'jm 3/23/2005 09:04'!
pc: anInteger
	"Set the program counter to the current index, indicating the next block to evaluate."

	pc _ anInteger.
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'jm 1/22/2007 13:01'!
printOn: aStream

	aStream nextPutAll: '[', expression printString, ' ', shouldUnlight printString, ']'.! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'DaveF 8/4/2003 17:23'!
shouldUnlight

	^ shouldUnlight
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'DaveF 8/4/2003 17:23'!
shouldUnlight: aBoolean

	shouldUnlight _ aBoolean.
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'DaveF 7/9/2003 18:35'!
shouldYield
	"Answers true iff this is a dummy frame simply indicating that the process should yield control."

	^ expression = #shouldYield
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'DaveF 7/9/2003 18:05'!
shouldYield: aBoolean
	"Makes this into a special stack frame that tells the evaluator to yield control to another process. When this flag is set, the rest of the stack frame is ignored."

	aBoolean
		ifTrue: [expression _ #shouldYield]
		ifFalse: [self error: 'Should not call shouldYield: with false.'].
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'jm 8/22/2003 18:56'!
startTime

	^ startTime
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'jm 8/22/2003 18:56'!
startTime: mSecs
	"Record the starting time for an interpolating command."
	
	startTime _ mSecs.
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'jm 8/22/2003 18:55'!
startValue

	^ startValue
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'jm 8/22/2003 18:55'!
startValue: aTime
	"Record the starting value for an interpolating command."
	
	startValue _ aTime.
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'jm 5/6/2007 13:47'!
stopMIDI

	(self startValue isKindOf: ScratchNotePlayer)
		ifTrue: [startValue noteOff].
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'jm 5/19/2009 13:10'!
stopMotors

	| motorName |
	(expression isKindOf: CommandBlockMorph) ifTrue: [
		#motorOnFor:elapsed:from: = expression selector ifTrue: [
			motorName _ startValue.
			expression receiver motorOff: motorName]].
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'jm 6/2/2009 11:31'!
stopTalkThinkAsk

	| s |
	(expression isKindOf: CommandBlockMorph) ifTrue: [
		((#say:duration:elapsed:from: = expression selector) |
		 (#think:duration:elapsed:from: = expression selector)) ifTrue: [
			expression receiver sayNothing].

		#doAsk = expression selector ifTrue: [
			(s _ expression receiver ownerThatIsA: ScratchStageMorph) ifNotNil: [s stopAsks]]].
! !
