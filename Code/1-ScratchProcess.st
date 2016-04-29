Object subclass: #ScratchProcess
	instanceVariableNames: 'stackFrame topBlock readyToYield errorFlag readyToTerminate blockVarList answer atomicityList ci scriptVars tempVars scriptList isPaused timeOffset blockToDebug nextBlockToDebug doneWithDebugging beingAtomic isFirst '
	classVariableNames: 'BlockHighlightMSecs Times '
	poolDictionaries: ''
	category: 'Scratch-Execution Engine'!
!ScratchProcess commentStamp: 'jm 6/29/2005 18:02' prior: 0!
A ScratchProcess is what brings a stack of blocks to life. The process keeps track of which block to run next, evaluates block arguments, handles control structures, and so forth.

The ScratchFrameMorph is the scheduler, telling each process when to run by calling its runStep method. The runStep method will execute some number of blocks, then voluntarily yield control so that the ScratchFrameMorph can run another process. The etiquette is that a process should yield control at the end of every loop iteration, and while it is running a timed command (e.g. "wait 5 secs") or a synchronous command (e.g. "broadcast xxx and wait").

Structure:
  stackFrame		the ScratchStackFrame describing the current state of this process
  readyToYield		boolean indicating whether to yield control to another process
  errorFlag			boolean indicating whether an error was encountered
  readyToTerminate	boolean indicating whether the stop method has been called
!


!ScratchProcess methodsFor: 'initialization' stamp: 'EMP 4/26/2016 16:05'!
forBlock: t1 
	| t2 |
	beingAtomic := false.
	topBlock := t1.
	t2 := topBlock blockSequence.
	t2 first isHatBlock
		ifTrue: [t2 := t2 allButFirst].
	topBlock stopProcess; scratchProc: self.
	stackFrame := ScratchStackFrame forExpression: t2! !

!ScratchProcess methodsFor: 'initialization' stamp: 'EMP 4/26/2016 15:41'!
initialize

	stackFrame _ nil.
	readyToYield _ false.
	errorFlag _ false.
	readyToTerminate _ false.
	ci _ 1.
	scriptVars _ Dictionary new.
	tempVars _ VariableFrame new.
	atomicityList _ OrderedCollection new.! !


!ScratchProcess methodsFor: 'accessing' stamp: 'EMP 4/14/2016 16:05'!
answer
	^ answer! !

!ScratchProcess methodsFor: 'accessing' stamp: 'jm 11/20/2003 11:12'!
errorFlag
	"Answer true if this process has stopped due to an error."

	^ errorFlag
! !

!ScratchProcess methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:06'!
errorFlag: t1 
	errorFlag := t1.
	stackFrame
		ifNotNil: [stackFrame expression showError.
			stackFrame expression topBlock showErrorFeedback]! !

!ScratchProcess methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:07'!
includesDeletedReceiver
	self
		stackFromFrame: stackFrame
		upwardsDo: [:t1 | 
			t1 hasDeletedReceiver
				ifTrue: [^ true].
			nil].
	^ false! !

!ScratchProcess methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:07'!
includesReceiver: t1 
	self
		stackFromFrame: stackFrame
		upwardsDo: [:t2 | 
			(t2 hasReceiver: t1)
				ifTrue: [^ true].
			nil].
	^ false! !

!ScratchProcess methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:07'!
isRunning
	^ stackFrame notNil
		and: [errorFlag not
				and: [self includesDeletedReceiver not]]! !


!ScratchProcess methodsFor: 'entry points' stamp: 'EMP 4/28/2016 15:13'!
runStepFor: t1 
	readyToYield := false.
	[readyToYield
		or: [stackFrame isNil]]
		whileFalse: [(stackFrame evaluateIn: self)
				ifTrue: [t1 updateTrailsForm.
					((BlockHighlightMSecs = 1) & (self isAtomic not))
						ifTrue: [World displayWorldSafely]]].
	readyToTerminate
		ifTrue: [[stackFrame isNil]
				whileFalse: [stackFrame unlightExpression.
					self popStackFrameNoUnhightlight]]! !

!ScratchProcess methodsFor: 'entry points' stamp: 'EMP 4/26/2016 16:07'!
stepUntilDoneFor: t1 
	[self isRunning]
		whileTrue: [Sensor keyboardPressed.
			self runStepFor: t1.
			self isAtomic]! !

!ScratchProcess methodsFor: 'entry points' stamp: 'jm 6/4/2009 13:12'!
stop
	"Permanently terminates this process."

	stackFrame ifNotNil: [stackFrame stopMIDI; stopMotors; stopTalkThinkAsk].
	readyToYield _ true.
	readyToTerminate _ true.
	topBlock ifNotNil: [topBlock scratchProc: nil].
! !


!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 4/26/2016 16:10'!
applyPrimitive
	"Apply the current expression (which must be a CommandBlock) to the current arguments (which must all have been evaluated)."

	| |
	stackFrame expression isParamGetter 
	ifTrue: [
	self returnValueToParentFrame: (self getArgumentOrNil: (stackFrame expression selector)). ^ self popStackFrame].

	"save the return value in the parent frame before popStackFrame because popFrame adds a frame while single-stepping"

	self returnValueToParentFrame: stackFrame evaluateExpression.
	self popStackFrame! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 4/26/2016 16:10'!
applyTimedCommand
	| t1 t2 t3 |
	stackFrame needsMoreArgumentsEvaluated
		ifTrue: [^ self evaluateNextArgument].
	t3 := stackFrame coerceArguments.
	t1 := Time millisecondClockValue.
	t2 := stackFrame startTime.
	t2
		ifNil: [stackFrame startTimedCommandWith: t3 at: t1.
			readyToYield := true.
			^ self].
	(stackFrame stepTimedCommandWith: t3 at: t1)
		ifTrue: [readyToYield := true.
			^ self].
	self popStackFrame! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 4/26/2016 16:44'!
closeAtomic
	atomicityList removeLast.
	self popStackFrame! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 4/26/2016 16:10'!
evaluateNextArgument
	self pushStackFrame: stackFrame toEvaluateNextArgument! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 4/26/2016 16:10'!
evaluateSequence
	| t1 t2 |
	t1 := stackFrame expression.
	t2 := stackFrame pc.
	t2 > t1 size
		ifTrue: [self popStackFrame]
		ifFalse: [stackFrame pc: t2 + 1.
			self
				pushStackFrame: (ScratchStackFrame
						forExpression: (t1 at: t2))]! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 4/16/2016 15:38'!
evaluateSpecialForm
	| |
	"Evaluates the current special form expression.  Requires that no arguments have been evaluated, and that the current expression be a special form."

	(#(setVar:to: changeVar:by:) includes: (stackFrame expression selector)) ifTrue: [
	#setVar:to: = (stackFrame expression selector) ifTrue: [^ self setVar].
	#changeVar:by: = (stackFrame expression selector) ifTrue: [^ self changeVar].
	].
	self perform: stackFrame expression selector! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 4/26/2016 16:11'!
evaluateSpecialForm: selector
	| |
	"Evaluates the current special form expression.  Requires that no arguments have been evaluated, and that the current expression be a special form."

	(#(setVar:to: changeVar:by:) includes: (selector)) ifTrue: [
	#setVar:to: = (selector) ifTrue: [^ self setVar].
	#changeVar:by: = (selector) ifTrue: [^ self changeVar].
	].
	self perform: selector! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 4/26/2016 16:11'!
numberOfArgumentsReady
	^ stackFrame numberOfArgumentsReady! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 4/28/2016 15:20'!
yield
	readyToYield := true.
	self popStackFrame! !


!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/26/2016 16:11'!
doAsk
	| t1 t2 |
	t2 := stackFrame.
	stackFrame numberOfArgumentsReady = 0
		ifTrue: [stackFrame promptInProgress
				ifTrue: [self pushStackFrame: ScratchStackFrameToYield new.
					^ self].
			t1 := stackFrame buildPrompter]
		ifFalse: [t1 := t2 firstArg].
	t1 isDone
		ifTrue: [^ self popStackFrame].
	self popStackFrameNoUnhightlight.
	self
		pushStackFrame: (t2 toEvaluateExpression addArgument: t1).
	self pushStackFrame: ScratchStackFrameToYield new! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/26/2016 16:43'!
doBroadcastAndWait
	| t1 t2 t3 t4 t5 |
	t1 := stackFrame expression.
	t2 := stackFrame arguments.
	t2 size = 0
		ifTrue: [t3 := t1 args first asString.
			t4 := t1 receiver ownerOrYourselfThatIsA: ScratchStageMorph.
			t5 := t4
						broadcastEvent: (ScratchNamedEvent new name: t3)]
		ifFalse: [t5 := t2 first].
	(t5
			select: [:t6 | t6 isRunning]) size = 0
		ifTrue: [^ self popStackFrame].
	self popStackFrameNoUnhightlight.
	self
		pushStackFrame: ((ScratchStackFrame forExpression: t1)
				addArgument: t5).
	self pushStackFrame: ScratchStackFrameToYield new! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/28/2016 16:01'!
doForLoop
	"Handles one iteration of a forEach block"

	| arguments block counter frame changerBlock toEvaluateExpression oldStackFrame |

	block _ stackFrame expression.
	arguments _ stackFrame arguments.
	oldStackFrame _ stackFrame.
	toEvaluateExpression _ stackFrame toEvaluateExpression.
	"If we haven't done so yet, evaluate the argument to repeat."
	stackFrame needsMoreArgumentsEvaluated ifTrue: [isFirst _ true. ^ self evaluateNextArgument].

	"If the number of times to repeat is 0, then we're done."
	counter _ stackFrame secondArg asNumberNoError.
	counter < 1 ifTrue:	[^ self popStackFrame].

	"Pop this instruction from the stack."
	self popStackFrameNoUnhightlight.

	"Find the changerBlock, or create one if needed"
	oldStackFrame numberOfArgumentsReady < 3 ifTrue: [
	changerBlock _ (SetterBlockMorph new
	initChangerForVar: (arguments first asString); 
	receiver: (block receiver)).
	changerBlock expressionArg numExpression: '1'] ifFalse: [changerBlock _ oldStackFrame arguments third].

	"At top of stack should now be:
		(0. set the value of the variable to zero; only for the first iteration)
		1. increment the variable by 1
		2.  evaluate body of repeat block.
		3.  yield.
		4.  evaluate for loop with decremented counter value.
	Need to add these to the stack in reverse order."


	"4.  evaluate repeat block with decremented counter value."
	frame _ toEvaluateExpression
				addArgument: (oldStackFrame firstArg);
				addArgument:	counter - 1;
				addArgument: changerBlock.
	self pushStackFrame: frame.

	"3.  yield."
	self isAtomic ifFalse: [self pushStackFrame: (ScratchStackFrameToYield new)].

	"2.  evaluate body of repeat block."
	self pushStackFrame: (ScratchStackFrame new expression: block firstBlockList).

	"1. increment the variable"
	self pushStackFrame: (ScratchStackFrame new expression: changerBlock).

	isFirst = true ifTrue: [
	changerBlock _ (SetterBlockMorph new
	initSetterForVar: (oldStackFrame firstArg asString); 
	receiver: (block receiver)).
	changerBlock expressionArg numExpression: '1'.
	self pushStackFrame: (ScratchStackFrame new expression: changerBlock)].
	isFirst _ false.
! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/27/2016 12:31'!
doForever
	| t1 |
	t1 := stackFrame.
	(self isAtomic) ifFalse: [
	self pushStackFrame: ScratchStackFrameToYield new].
	self pushStackFrame: t1 toEvaluateFirstBlockList! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/28/2016 15:42'!
doForeverIf
	| t1 |
	t1 := stackFrame.
	stackFrame numberOfArgumentsReady < 1
		ifTrue: [^ self evaluateNextArgument].
	self popStackFrameNoUnhightlight.
	self pushStackFrame: t1 toEvaluateExpression.
	(self isAtomic) ifFalse: [
	self pushStackFrame: ScratchStackFrameToYield new].
	t1 firstArg asBoolean
		ifTrue: [self pushStackFrame: t1 toEvaluateFirstBlockList]! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/28/2016 15:42'!
doIf
	| t1 |
	t1 := stackFrame.
	stackFrame numberOfArgumentsReady < 1
		ifTrue: [^ self evaluateNextArgument].
	self popStackFrame.
	t1 firstArg asBoolean
		ifFalse: [^ self].
	self pushStackFrame: t1 toEvaluateFirstBlockList! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/28/2016 15:42'!
doIfElse
	| t1 |
	t1 := stackFrame.
	stackFrame numberOfArgumentsReady < 1
		ifTrue: [^ self evaluateNextArgument].
	self popStackFrame.
	t1 firstArg asBoolean
		ifTrue: [self pushStackFrame: t1 toEvaluateTrueBlockList]
		ifFalse: [self pushStackFrame: t1 toEvaluateFalseBlockList]! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/27/2016 12:31'!
doPlaySoundAndWait
	| t1 t2 |
	t2 := stackFrame.
	stackFrame numberOfArgumentsReady = 0
		ifTrue: [(t1 := stackFrame startSoundCommand)
				ifNil: [^ self popStackFrame]]
		ifFalse: [t1 := stackFrame firstArg].
	t1 isPlaying
		ifFalse: [^ self popStackFrame].
	self popStackFrameNoUnhightlight.
	self
		pushStackFrame: (t2 toEvaluateExpression addArgument: t1).
	(self isAtomic) ifFalse: [
	self pushStackFrame: ScratchStackFrameToYield new].! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/28/2016 15:41'!
doRepeat
	| t1 t2 t3 |
	t1 := stackFrame.
	stackFrame numberOfArgumentsReady < 1
		ifTrue: [^ self evaluateNextArgument].
	t2 := stackFrame firstArg asNumberNoError.
	t2 < 1
		ifTrue: [^ self popStackFrame].
	self popStackFrameNoUnhightlight.
	t3 := t1 toEvaluateExpression addArgument: t2 - 1.
	self pushStackFrame: t3.
	(self isAtomic) ifFalse: [
	self pushStackFrame: ScratchStackFrameToYield new].
	self pushStackFrame: t1 toEvaluateFirstBlockList! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/26/2016 16:12'!
doReturn
	stackFrame needsMoreArgumentsEvaluated
		ifTrue: [^ self evaluateNextArgument].
	answer
		ifNil: [answer := ''].
	[stackFrame isNil]
		whileFalse: [self popStackFrame]! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/26/2016 16:13'!
doUntil
	^ self doUntil: true! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/26/2016 16:13'!
doUntil: t1 
	| t2 |
	stackFrame numberOfArgumentsReady < 1
		ifTrue: [^ self evaluateNextArgument].
	stackFrame firstArg = t1
		ifTrue: [^ self popStackFrame].
	t2 := stackFrame.
	self popStackFrameNoUnhightlight.
	self pushStackFrame: t2 toEvaluateExpression.
	self pushStackFrame: ScratchStackFrameToYield new.
	self pushStackFrame: t2 toEvaluateFirstBlockList! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/27/2016 12:31'!
doWaitUntil
	| t1 |
	stackFrame numberOfArgumentsReady < 1
		ifTrue: [^ self evaluateNextArgument].
	stackFrame firstArg
		ifTrue: [^ self popStackFrame].
	t1 := stackFrame.
	self popStackFrameNoUnhightlight.
	self pushStackFrame: t1 toEvaluateExpression.
	(self isAtomic) ifFalse: [
	self pushStackFrame: ScratchStackFrameToYield new].! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/26/2016 16:13'!
doWhile
	^ self doUntil: false! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/26/2016 16:13'!
startSceneAndWait
	| t1 t2 t3 t4 t5 |
	t1 := stackFrame expression.
	t2 := stackFrame arguments.
	t2 size = 0
		ifTrue: [t3 := t1 args first asString.
			t4 := t1 receiver ownerOrYourselfThatIsA: ScratchStageMorph.
			t5 := t4
						broadcastEvent: (ScratchBackdropChangedEvent bgName: t3)]
		ifFalse: [t5 := t2 first].
	(t5
			select: [:t6 | t6 isRunning]) size = 0
		ifTrue: [^ self popStackFrame].
	self popStackFrameNoUnhightlight.
	self
		pushStackFrame: ((ScratchStackFrame forExpression: t1)
				addArgument: t5).
	self pushStackFrame: ScratchStackFrameToYield new! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/26/2016 16:13'!
stopScripts
	| t1 t2 t3 |
	stackFrame needsMoreArgumentsEvaluated
		ifTrue: [^ self evaluateNextArgument].
	t2 := stackFrame arguments.
	t2 size > 0
		ifTrue: [t1 := t2 first]
		ifFalse: [t1 := nil].
	t1 = 'this script'
		ifTrue: [[stackFrame isNil]
				whileFalse: [self popStackFrame].
			stackFrame
				ifNotNil: [self returnValueToParentFrame: t1.
					self popStackFrame].
			answer
				ifNil: [answer := ''].
			^ self].
	t1 = 'all'
		ifTrue: [t3 := stackFrame expression receiver ownerThatIsA: ScratchStageMorph.
			t3
				ifNotNil: [t3 stopAll].
			self stop.
			answer
				ifNil: [answer := ''].
			^ self].
	t1 = 'other scripts in sprite'
		ifTrue: [stackFrame expression receiver blocksBin submorphs
				do: [:t4 | ((t4 isKindOf: BlockMorph)
							and: [t4 ~= topBlock])
						ifTrue: [t4 clearProcess]].
			self popStackFrame.
			^ self].
	t1 = 'other scripts in stage'
		ifTrue: [stackFrame expression receiver blocksBin submorphs
				do: [:t4 | ((t4 isKindOf: BlockMorph)
							and: [t4 ~= topBlock])
						ifTrue: [t4 clearProcess]].
			self popStackFrame.
			^ self].
	^ self error: 'Again... stopScripts.'! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/29/2016 14:31'!
warpSpeed
	| t1 |
	t1 := stackFrame.
	self popStackFrameNoUnhightlight.
	t1 expression firstBlockList isEmpty ifFalse: [
	atomicityList add: true.
	self pushStackFrame: ScratchStackFrameToYield new.
	self
		pushStackFrame: (ScratchStackFrameToPerform selector: #closeAtomic).
	self pushStackFrame: t1 toEvaluateFirstBlockList]! !


!ScratchProcess methodsFor: 'private-stack' stamp: 'EMP 4/28/2016 14:57'!
popStackFrame
	| t1 |
	t1 := stackFrame.
	stackFrame := stackFrame parentFrame.
	self isAtomic ifFalse: [
	BlockHighlightMSecs > 0
		ifTrue: [t1 needsUnlighting
				ifTrue: [self pushStackFrame: t1 toUnlightExpression]]]! !

!ScratchProcess methodsFor: 'private-stack' stamp: 'EMP 4/26/2016 16:13'!
popStackFrameNoUnhightlight
	stackFrame := stackFrame parentFrame! !

!ScratchProcess methodsFor: 'private-stack' stamp: 'EMP 4/26/2016 16:13'!
pushStackFrame: t1 
	t1 parentFrame: stackFrame.
	stackFrame := t1! !

!ScratchProcess methodsFor: 'private-stack' stamp: 'EMP 4/26/2016 16:13'!
returnValueToParentFrame: t1 
	| t2 |
	stackFrame
		ifNil: [^ self].
	t2 := stackFrame parentFrame.
	[t2 notNil
		and: [t2 shouldUnlight]]
		whileTrue: [t2 := t2 parentFrame].
	t2
		ifNotNil: [t2 addArgument: t1]! !

!ScratchProcess methodsFor: 'private-stack' stamp: 'DaveF 7/9/2003 18:26'!
stackAsArray
	"Returns an array describing the contents of the stack.  Useful for debugging."

	| frame collection |

	frame _ stackFrame.
	collection _ OrderedCollection new.
	
	[frame isNil] whileFalse:
		[collection add: frame expression.
		frame _ frame parentFrame].

	^collection asArray! !

!ScratchProcess methodsFor: 'private-stack' stamp: 'EMP 4/26/2016 16:13'!
stackFromFrame: t1 upwardsDo: t2 
	| t3 |
	t3 := t1.
	[t3 isNil]
		whileFalse: [t2 value: t3.
			t3 := t3 parentFrame]! !


!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/16/2016 12:46'!
bindStopBlocksIn: t1 to: t2 
	t1 do: [:t3 | t3
			allMorphsDo: [:t4 | ((t4 isKindOf: CommandBlockMorph)
					and: [t4 selector = #stopScripts or: [t4 selector = #report]])
					ifTrue: [t4 stopFrame: t2]]]! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/28/2016 15:18'!
call
	| block lambda argsList script varsFrame params iLimiT stopFrame |
	self isAtomic.
	block _ stackFrame expression.
	stackFrame arguments size < block argumentCount ifTrue: [^ self evaluateNextArgument].

	lambda _ block.
	argsList _ stackFrame arguments.
	script _ (lambda procedure ifNil: [^ self popStackFrame]) blockSequence allButFirst collect: [:m | m fullCopy].
	atomicityList ifNil: [atomicityList _ OrderedCollection new].
	atomicityList add: lambda isAtomic.
	blockVarList ifNil: [blockVarList _ OrderedCollection new].
	blockVarList add: (VariableFrame forNames: lambda allVarNames).
	varsFrame _ blockVarList last.
	params _ block allVarNames.
	params size > 0
		ifTrue: 
			[iLimiT _ argsList size.
			(1 to: iLimiT)
				do: [:i | argsList size >= i ifTrue: [varsFrame setVar: (params at: i)
							to: (argsList at: i)]]].
	scriptList ifNil: [scriptList _ OrderedCollection new].
	scriptList add: script.

	stopFrame _ ScratchStackFrameToPerform selector: #closeCustomBlock.
	self pushStackFrame: stopFrame.
	self bindStopBlocksIn: script to: stopFrame.
	self pushStackFrame: (ScratchStackFrame new expression: (script , {(CommandBlockMorph new commandSpec: '%s'; selector: #report; isSpecialForm: true; receiver: (block receiver); argPermutation: {1})}))! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/28/2016 15:18'!
callReporter
	| block lambda argsList script varsFrame params iLimiT stopFrame |
	self isAtomic.
	block _ stackFrame expression.
	stackFrame arguments size < block argumentCount ifTrue: [^ self evaluateNextArgument].

	lambda _ block.
	argsList _ stackFrame arguments.
	script _ (lambda procedure ifNil: [^ self popStackFrame]) blockSequence allButFirst collect: [:m | m fullCopy].
	atomicityList ifNil: [atomicityList _ OrderedCollection new].
	atomicityList add: lambda isAtomic.
	blockVarList ifNil: [blockVarList _ OrderedCollection new].
	blockVarList add: (VariableFrame forNames: lambda allVarNames).
	varsFrame _ blockVarList last.
	params _ block allVarNames.
	params size > 0
		ifTrue: 
			[iLimiT _ argsList size.
			(1 to: iLimiT)
				do: [:i | argsList size >= i ifTrue: [varsFrame setVar: (params at: i)
							to: (argsList at: i)]]].
	scriptList ifNil: [scriptList _ OrderedCollection new].
	scriptList add: script.

	stopFrame _ ScratchStackFrameToPerform selector: #closeCustomBlock.
	self pushStackFrame: stopFrame.
	self bindStopBlocksIn: script to: stopFrame.
	self pushStackFrame: (ScratchStackFrame new expression: (script , {(CommandBlockMorph new commandSpec: '%s'; selector: #report; isSpecialForm: true; receiver: (block receiver); argPermutation: {1})}))! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/16/2016 15:48'!
changeVar
	| t1 t2 |
	t1 _ stackFrame expression.
	t2 _ stackFrame arguments.
		t2 size < 2 ifTrue: 
			[^ self evaluateNextArgument].

	(t1 receiver) changeVar: (t2 first) by: (t2 second).
	self popStackFrame! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/28/2016 14:56'!
closeCustomBlock
	blockVarList
		ifNotNil: [blockVarList size > 0
				ifTrue: 
					[blockVarList removeLast.
					atomicityList removeLast.
					scriptList removeLast]].
	stackFrame ifNotNil: [self isAtomic ifTrue: [self popStackFrameNoUnhightlight] ifFalse: [self popStackFrame]].! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/27/2016 16:05'!
getArgumentOrNil: selector
	blockVarList ifNil: [^ 0].
	^ blockVarList last getVar: selector asByteArray asString! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/28/2016 15:21'!
isAtomic
	| t1 t2 |
	t2 _ World findA: ScratchPresenterMorph.
	t2 notNil
		ifTrue: [t1 _ t2 buttons third bounds]
		ifFalse: [t1 _(World findA: ScratchFrameMorph) stopButton bounds].
	(Sensor anyButtonPressed and: [t1 containsPoint: Sensor cursorPoint])
		ifTrue: 
			[self stop.
			ScratchFrameMorph allInstances do: [:t3 | t3 stopAll]].
	(Character value: 27)
		= Sensor keyboardPeek
		ifTrue: 
			[Sensor flushKeyboard.
			Preferences noviceMode ifFalse: [Display flash: t1].
			^ false].
	((Time primMillisecondClock) > ci) ifTrue: [ci _ Time primMillisecondClock + 500. World displayWorldSafely].
	atomicityList ifNil: [^ false].
	atomicityList size = 0 ifTrue: [^ false].
	Sensor flushKeyboard.
	^ atomicityList last or: [BlockHighlightMSecs = 0]! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/27/2016 15:19'!
report
	"Evaluates its argument, and returns the value to the frame from which the current method was called."

	| value args zap |

	args _ stackFrame arguments.

	"Evaluate the argument, if necessary."

	stackFrame needsMoreArgumentsEvaluated
		ifTrue: [^self evaluateNextArgument].


	"Remember the return value."
	args size > 0
		ifTrue:	[value _ args first]
		ifFalse:	[value _ nil].
	answer _ value. 

	zap _ [
		[ stackFrame isNil
		or: [stackFrame expression = #closeCustomBlock]] whileFalse: [ 
			self popStackFrame]. self closeCustomBlock].

	zap value.


	[stackFrame notNil 
	and: [stackFrame parentFrame notNil 
	and: [stackFrame parentFrame shouldYield]]] whileTrue: [
		zap value. zap value ].

	self returnValueToParentFrame: value.

	stackFrame ifNotNil: [ self popStackFrame ].
! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/5/2016 16:08'!
scriptArgs: aDictionary

	| argNames |
	scriptVars _ Dictionary new.
	argNames _ (topBlock findArgs).
	argNames do: [:arg | scriptVars at: arg asByteArray asString put: (aDictionary at: (argNames indexOf: arg))].! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/16/2016 15:41'!
setVar
	| t1 t2 |
	t1 _ stackFrame expression.
	t2 _ stackFrame arguments.
	t2 size < 2 ifTrue: 
			[^ self evaluateNextArgument].

	(t1 receiver) setVar: (t2 first) to: (t2 second).
	self popStackFrame! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchProcess class
	instanceVariableNames: ''!

!ScratchProcess class methodsFor: 'class initialization' stamp: 'jm 3/22/2005 11:00'!
initialize

	BlockHighlightMSecs _ 1.
! !


!ScratchProcess class methodsFor: 'class variables' stamp: 'jm 8/10/2004 12:45'!
blockHighlightMSecs

	^ BlockHighlightMSecs
! !

!ScratchProcess class methodsFor: 'class variables' stamp: 'jm 8/8/2003 14:02'!
blockHighlightMSecs: aNumber

	BlockHighlightMSecs _ aNumber.
! !


!ScratchProcess class methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:14'!
forBlock: t1 
	^ self new forBlock: t1! !


ScratchProcess initialize!
