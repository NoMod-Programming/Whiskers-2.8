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


!ScratchStackFrame methodsFor: 'initialization' stamp: 'EMP 4/26/2016 16:01'!
initialize
	parentFrame := nil.
	expression := nil.
	arguments := OrderedCollection new.
	pc := 1.
	shouldUnlight := false! !


!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:01'!
addArgument: t1 
	self arguments add: t1! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
arguments
	^ arguments
		ifNil: [arguments := OrderedCollection new: 4]! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/5/2016 15:39'!
arguments: anOrderedCollection
	"Answers the values of the arguments to be sent to the current command."

	^ arguments _ anOrderedCollection
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
coerceArguments
	arguments
		ifNil: [^ #()].
	^ expression coerceArgs: self arguments! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
expression
	^ expression! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
expression: t1 
	expression := t1! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
firstArg
	^ arguments
		ifNotNil: [arguments first]! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
needsMoreArgumentsEvaluated
	^ self numberOfArgumentsReady < expression argumentCount! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
needsUnlighting
	^ expression isBlockMorph! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
parentFrame
	^ parentFrame! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
parentFrame: t1 
	parentFrame := t1! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
pc
	^ pc
		ifNil: [pc := 1]! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'jm 3/23/2005 09:04'!
pc: anInteger
	"Set the program counter to the current index, indicating the next block to evaluate."

	pc _ anInteger.
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
printOn: t1 
	t1 nextPutAll: 'ScratchStackFrame [' , expression printString , ']'! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/28/2016 15:31'!
secondArg
	^ arguments
		ifNotNil: [arguments second]! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
shouldUnlight
	^ false! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'DaveF 8/4/2003 17:23'!
shouldUnlight: aBoolean

	shouldUnlight _ aBoolean.
! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
shouldYield
	^ false! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:02'!
shouldYield: t1 
	self error: 'Should not call shouldYield: any longer'! !

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

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:03'!
stopMIDI
	(self startValue isKindOf: ScratchNotePlayer)
		ifTrue: [startValue noteOff]! !

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:03'!
stopMotors
	| t1 |
	expression isCommandBlockMorph
		ifTrue: [#motorOnFor:elapsed:from: = expression selector
				ifTrue: [t1 := startValue.
					expression receiver motorOff: t1]]! !

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

!ScratchStackFrame methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:03'!
unlightExpression
	expression litUp: false! !


!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:51'!
buildPrompter
	^ expression buildPrompter! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:03'!
evaluateExpression
	^ expression evaluateInStackFrame: self! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 12:42'!
evaluateIn: t1 
	^ expression evaluateIn: t1! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:04'!
hasDeletedReceiver
	^ expression hasDeletedReceiver! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:04'!
hasReceiver: t1 
	^ expression receiver == t1! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:04'!
numberOfArgumentsReady
	^ arguments
		ifNil: [0]
		ifNotNil: [arguments size]! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:51'!
promptInProgress
	^ expression promptInProgress! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:04'!
startSoundCommand
	^ expression startSoundCommand! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:04'!
startTimedCommandWith: t1 at: t2 
	startTime := t2.
	startValue := expression startTimedCommandWith: t1! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:04'!
stepTimedCommandWith: t1 at: t2 
	| t3 |
	t3 := t2 - startTime.
	^ expression stepTimedCommandWith: t1 asArray
			, (Array with: t3 with: startValue) after: t3! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:04'!
toEvaluateExpression
	^ ScratchStackFrame forExpression: expression! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:04'!
toEvaluateFalseBlockList
	^ ScratchStackFrame forExpression: expression falseBlockList! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:04'!
toEvaluateFirstBlockList
	^ ScratchStackFrame forExpression: expression firstBlockList! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:04'!
toEvaluateNextArgument
	^ ScratchStackFrame
		forExpression: (expression argumentAt: self numberOfArgumentsReady + 1)! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:04'!
toEvaluateTrueBlockList
	^ ScratchStackFrame forExpression: expression trueBlockList! !

!ScratchStackFrame methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:04'!
toUnlightExpression
	^ ScratchStackFrameToUnlight forExpression: expression! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchStackFrame class
	instanceVariableNames: ''!

!ScratchStackFrame class methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:04'!
forExpression: t1 
	^ super new expression: t1! !
