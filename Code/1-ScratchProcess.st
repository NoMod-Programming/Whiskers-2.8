Object subclass: #ScratchProcess
	instanceVariableNames: 'stackFrame topBlock readyToYield errorFlag readyToTerminate isFirst ci answer scriptVars '
	classVariableNames: 'BlockHighlightMSecs '
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


!ScratchProcess methodsFor: 'initialization' stamp: 'EMP 1/12/2016 15:50'!
initialize

	stackFrame _ nil.
	readyToYield _ false.
	errorFlag _ false.
	readyToTerminate _ false.
	ci _ 1.
	scriptVars _ Dictionary new.! !


!ScratchProcess methodsFor: 'accessing' stamp: 'EMP 1/12/2016 14:44'!
answer
	^ answer! !

!ScratchProcess methodsFor: 'accessing' stamp: 'jm 11/20/2003 11:12'!
errorFlag
	"Answer true if this process has stopped due to an error."

	^ errorFlag
! !

!ScratchProcess methodsFor: 'accessing' stamp: 'EMP 10/21/2015 15:16'!
errorFlag: aBoolean
	"Set the error flag for this process."

	errorFlag _ aBoolean.
	stackFrame expression showError.
	stackFrame expression topBlock showErrorFeedback.
! !

!ScratchProcess methodsFor: 'accessing' stamp: 'EMP 10/21/2015 15:40'!
errorFlagImmediate: aBoolean
	"Set the error flag for this process."

	errorFlag _ aBoolean.
! !

!ScratchProcess methodsFor: 'accessing' stamp: 'jm 11/20/2003 11:12'!
expression: expression
	"Sets the expression to evaluate. This can be a single block or a collection of blocks. It should only be called before running the process."

	stackFrame ifNotNil: [self error: 'Cannot modify expression'].
	stackFrame _ ScratchStackFrame new expression: expression.
! !

!ScratchProcess methodsFor: 'accessing' stamp: 'jm 12/9/2008 17:09'!
includesDeletedReceiver
	"Answer true if I contain a block whose receiver has been deleted."

	self stackAsArray do: [:b |
		((b isKindOf: CommandBlockMorph) and:
		 [b receiver owner isNil])
			ifTrue: [^ true]].

	^ false
! !

!ScratchProcess methodsFor: 'accessing' stamp: 'jm 5/28/2004 20:38'!
includesReceiver: anObject
	"Answer true if I have the given object as a block receiver."

	self stackAsArray do: [:frm |
		((frm respondsTo: #receiver) and: [frm receiver == anObject])
			ifTrue: [^ true]].
	^ false

! !

!ScratchProcess methodsFor: 'accessing' stamp: 'jm 6/4/2009 13:00'!
isRunning
	"Answer true if I am still running, have not encountered an error, and don't refer to any deleted objects."

	^ (stackFrame notNil and:
	   [errorFlag not and:
	   [self includesDeletedReceiver not]])
! !

!ScratchProcess methodsFor: 'accessing' stamp: 'EMP 10/21/2015 15:36'!
stackFrame
	^ stackFrame! !

!ScratchProcess methodsFor: 'accessing' stamp: 'jm 12/30/2008 18:33'!
topBlock: aBlock

	topBlock _ aBlock.
! !


!ScratchProcess methodsFor: 'entry points' stamp: 'jm 10/24/2005 18:45'!
runStepFor: aStageMorph
	"Evaluates the current expression, then the next, etc., until the next yield."

	| expr |
	"evaluate blocks until we're ready to yield"
	readyToYield _ false.
	[readyToYield or: [stackFrame isNil]] whileFalse: [
		self evaluateFor: aStageMorph].

	readyToTerminate ifTrue: [
		"pop all stack frames, unlighting enclosing blocks:"
		[stackFrame isNil] whileFalse: [
			expr _ stackFrame expression.
			(expr isKindOf: BlockMorph) ifTrue: [expr litUp: false].
			self popStackFrame]].
! !

!ScratchProcess methodsFor: 'entry points' stamp: 'EMP 1/12/2016 15:18'!
stepUntilDoneFor: aStageMorph

	[self isRunning] whileTrue: [
		Sensor keyboardPressed.
		self runStepFor: aStageMorph.
		self isAtomic].
! !

!ScratchProcess methodsFor: 'entry points' stamp: 'jm 6/4/2009 13:12'!
stop
	"Permanently terminates this process."

	stackFrame ifNotNil: [stackFrame stopMIDI; stopMotors; stopTalkThinkAsk].
	readyToYield _ true.
	readyToTerminate _ true.
	topBlock ifNotNil: [topBlock scratchProc: nil].
! !


!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 4/5/2016 14:53'!
applyPrimitive
	"Apply the current expression (which must be a CommandBlock) to the current arguments (which must all have been evaluated)."

	| value |
	stackFrame expression isParamGetter 
	ifTrue: [
	value _ self getArgumentOrNil: (stackFrame expression selector)]
	ifFalse: [
	value _ stackFrame expression evaluateWithArgs: stackFrame arguments].

	"save the return value in the parent frame before popStackFrame because popFrame adds a frame while single-stepping"
	self returnValueToParentFrame: value.
	self popStackFrame.! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 2/25/2016 16:28'!
applyTimedCommand
	"Applies the current command to the already evaluated list of arguments over a particular time interval."

	| block arguments currentTime startTime args totalMSecs elapsedMSecs |
	block _ stackFrame expression.
	arguments _ stackFrame arguments.

	"Do we still need to evaluate more arguments?"
	arguments size < block argumentCount ifTrue: [^ self evaluateNextArgument].
	arguments _ block coerceArgs: arguments.

	"Record or get the time when command was first invoked."
	currentTime _ Time millisecondClockValue.
	startTime _ stackFrame startTime.
	startTime ifNil: [  "first call; just set starting time and value"
		args _ arguments asArray, (Array with: 0 with: nil).
		stackFrame startValue: (block receiver perform: block selector withArguments: args).
		stackFrame startTime: currentTime.
		readyToYield _ true.
		^ self].

	"Call primitive time command with its arguments and the elapsed time in seconds"
	totalMSecs _ arguments last * 1000.
	block selector = #glideSecs:toX:y:elapsed:from: ifTrue: [totalMSecs _ arguments first * 1000].
	block selector = #mwait:elapsed:from: ifTrue: [totalMSecs _ arguments last].
	((block selector = #drum:duration:elapsed:from:) or:
	 [block selector = #noteOn:duration:elapsed:from:])
		ifTrue: [totalMSecs _ (60000 * arguments second) / block receiver tempo].
	block selector = #rest:elapsed:from:
		ifTrue: [totalMSecs _ (60000 * arguments first) / block receiver tempo].

	elapsedMSecs _ currentTime - startTime.
	currentTime < startTime ifTrue: [elapsedMSecs _ totalMSecs].  "clock wrap"
	args _ arguments asArray, (Array with: elapsedMSecs with: stackFrame startValue).
	block receiver perform: block selector withArguments: args.

	"If not done, then we leave stack as is and yield."
	elapsedMSecs < totalMSecs ifTrue: [
		self isAtomic ifFalse: [
		readyToYield _ true].
		^ self].

	"Pop this command off the stack and return."
	self popStackFrame.

! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 4/5/2016 12:15'!
evaluateCommandFor: aStageMorph
	"Evaluates the current block. If the argument is non-nil, redraw the stage."

	| expression |
	expression _ stackFrame expression.
	((BlockHighlightMSecs > 1) and: [self isAtomic not]) ifTrue: [expression litUp: true].

	expression isSpecialForm ifTrue: [^ self evaluateSpecialForm].

	"evaluate arguments, if necessary"
	stackFrame arguments size < expression argumentCount
		ifTrue: [^ self evaluateNextArgument].

	expression isTimed ifTrue: [^ self applyTimedCommand].

	self applyPrimitive.
	
		self isAtomic ifTrue: [^ self].
	aStageMorph ifNotNil: [
		aStageMorph updateTrailsForm.
		(BlockHighlightMSecs = 1) ifTrue: [  "normal (non-turbo) mode; redraw after each cmd"
			World displayWorldSafely]].
! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 2/25/2016 16:27'!
evaluateFor: aStageMorph
	"Evaluates the current expression in the current environment for the given StageMorph."

	| expression |
	stackFrame shouldYield ifTrue: [(self isAtomic) ifFalse: [^ self yield] ifTrue: [^ self popStackFrame]].
	expression _ stackFrame expression.
	stackFrame shouldUnlight ifTrue: [
		expression litUp: false.
		^ self popStackFrame].

	expression isCollection ifTrue: [^ self evaluateSequence].
	expression isArgMorph ifTrue: [^ self evaluateSelfEvaluating].
	expression isBlockMorph ifTrue: [^ self evaluateCommandFor: aStageMorph].

	self error: 'Unknown expression type:  ', expression printString.
! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'DaveF 7/9/2003 18:58'!
evaluateNextArgument
	"Evaluates the next argument of the command in expression.  Requires that expression be a block that takes more args than are already evaluated in the current stack frame."

	| argumentExpression |

	argumentExpression _ stackFrame expression argumentAt: stackFrame arguments size + 1.

	self pushStackFrame: (ScratchStackFrame new expression: argumentExpression).! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'jm 3/23/2005 09:53'!
evaluateSelfEvaluating
	"The easiest case. Evaluate a number, color, or any self-evaluating expression."

	| value |
	value _ stackFrame expression evaluate.
	self returnValueToParentFrame: value.
	self popStackFrame.
! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 10/26/2015 15:46'!
evaluateSequence
	"Requires that the current expression be a collection of blocks.  Evaluates the block in the current expression (which is a list of blocks) at the given pc."

	| blocks pc |
	blocks _ stackFrame expression.
	pc _ stackFrame pc.
	pc > blocks size
		ifTrue:	[self popStackFrame]
		ifFalse:	[stackFrame pc: pc + 1.
				self pushStackFrame: (ScratchStackFrame new expression: (blocks at: pc))].

! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'DaveF 7/9/2003 11:20'!
evaluateSpecialForm
	"Evaluates the current special form expression.  Requires that no arguments have been evaluated, and that the current expression be a special form."

	self perform: stackFrame expression selector.! !

!ScratchProcess methodsFor: 'private-evaluation' stamp: 'EMP 4/5/2016 12:15'!
yield
	"Sets a flag indicating that we're ready to yield to another process."

	readyToYield _ true.
	self popStackFrame.! !


!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 2/25/2016 16:33'!
doAsk
	"Ask the user a question and wait until the user types some text and hits the accept button."

	| block args question prompter |
	block _ stackFrame expression.
	args _ stackFrame arguments.

	"first time (args size = 0): open prompter"
	args size = 0
		ifTrue: [
			block receiver promptInProgress ifTrue: [
				self pushStackFrame: (ScratchStackFrame new shouldYield: true).
				^ self].
			question _ block args first asString.
			prompter _ block receiver promptForInput: question]
		ifFalse: [
			prompter _ args first].

	"if all processes have stopped, pop this frame and we're done."
	prompter isDone ifTrue: [^ self popStackFrame].

	"Set up the wait loop. We need to:
		1.  yield to another process
		2.  evaluate the termination expression again
	Push these onto stack in reverse order."

	"2.  evaluate this block again"
	"(Remove the current frame and replace it with one that will force the termination expression to be re-evaluated.)"
	self popStackFrameNoUnhightlight.
	self pushStackFrame: (ScratchStackFrame new expression: block; addArgument: prompter).

	"1.  yield to another process"
	self isAtomic ifFalse: [
	self pushStackFrame: (ScratchStackFrame new shouldYield: true)].
! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 2/25/2016 16:34'!
doBroadcastAndWait
	"Broadcast an event and wait until all processes started by that broadcast have terminated."

	| block args eventName stage procs |
	block _ stackFrame expression.
	args _ stackFrame arguments.

	"first time: send the event and collect a list of processes"
	args size = 0
		ifTrue: [
			eventName _ block args first asString.
			stage _ block receiver ownerThatIsA: ScratchStageMorph.
			procs _ stage broadcastEventNamed: eventName with: 0]
		ifFalse: [
			procs _ args first].

	"if all processes have stopped, pop this frame and we're done."
	(procs select: [:p | p isRunning]) size = 0 ifTrue: [^ self popStackFrame].

	"Set up the wait loop. We need to:
		1.  yield to another process
		2.  evaluate the termination expression again
	Push these onto stack in reverse order."

	"2.  evaluate this block again"
	"(Remove the current frame and replace it with one that will force the termination expression to be re-evaluated.)"
	self popStackFrameNoUnhightlight.
	self pushStackFrame: (ScratchStackFrame new expression: block; addArgument: procs).

	"1.  yield to another process"
	self isAtomic ifFalse: [
	self pushStackFrame: (ScratchStackFrame new shouldYield: true)].
! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 2/25/2016 16:34'!
doForLoop
	"Handles one iteration of a forEach block"

	| arguments block counter frame changerBlock |

	block _ stackFrame expression.
	arguments _ stackFrame arguments.
	"If we haven't done so yet, evaluate the argument to repeat."
	arguments size < block argumentCount ifTrue: [isFirst _ true. ^ self evaluateNextArgument].
	arguments _ block coerceArgs: arguments.

	"If the number of times to repeat is 0, then we're done."
	counter _ arguments second asNumberNoError.
	counter <= 0 ifTrue:	[^ self popStackFrame].

	"Pop this instruction from the stack."
	self popStackFrameNoUnhightlight.

	"At top of stack should now be:
		(0. set the value to zero; only for the first iteration)
		1. increment the variable
		2.  evaluate body of repeat block.
		3.  yield.
		4.  evaluate repeat block with decremented counter value.
	Need to add these to the stack in reverse order."

	"4.  evaluate repeat block with decremented counter value."
	frame _ ScratchStackFrame new
				expression:		block;
				addArgument: (arguments first);
				addArgument:	counter - 1.
	self pushStackFrame: frame.

	"3.  yield."
	self isAtomic ifFalse: [self pushStackFrame: (ScratchStackFrame new shouldYield: true)].

	"2.  evaluate body of repeat block."
	self pushStackFrame: (ScratchStackFrame new expression: block firstBlockList).

	"1. increment the variable"
	changerBlock _ (SetterBlockMorph new
	initChangerForVar: (arguments first asString); 
	receiver: (block receiver)).
	changerBlock expressionArg numExpression: '1'.
	self pushStackFrame: (ScratchStackFrame new expression: (Array with: changerBlock)).

	isFirst = true ifTrue: [
	changerBlock _ (SetterBlockMorph new
	initSetterForVar: (arguments first asString); 
	receiver: (block receiver)).
	changerBlock expressionArg numExpression: '0'.
	self pushStackFrame: (ScratchStackFrame new expression: (Array with: changerBlock))].
	isFirst _ false.
! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 2/25/2016 16:34'!
doForever
	"Executes one iteration of a forever loop."

	"Right now, the forever special form is at the top of the stack.  We're going to add two more things on top of this:  (1) a frame for evaluating the blocks in the forever block, and (2) a frame that just results in yielding control.  That way we'll evaluate the contents of the block, give up control, and do it all again."

	| blocks |

	"Remember blocks to evaluate before we clobber the stack."
	blocks _ stackFrame expression firstBlockList.	

	"When we're all done with these blocks, we want to yield."
	self isAtomic ifFalse: [
	self pushStackFrame: (ScratchStackFrame new shouldYield: true)].

	"First, we want to evaluate the blocks inside the loop."
	self pushStackFrame: (ScratchStackFrame new expression: blocks).
! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 2/25/2016 16:35'!
doForeverIf
	"Executes one iteration of a forever if loop."

	| block args |
	block _ stackFrame expression.
	args _ stackFrame arguments.

	"evaluate the condition if we haven't yet"
	args size < 1 ifTrue: [^ self evaluateNextArgument].

	"remove the current frame and replace it with one that will force the test expression to be re-evaluated."
	self popStackFrameNoUnhightlight.
	self pushStackFrame: (ScratchStackFrame new expression: block).
	self isAtomic ifTrue: [
	self pushStackFrame: (ScratchStackFrame new shouldYield: true)]. "yield after possibly running body"

	"if the condition was true, run the body"
	args first ifTrue: [
		self pushStackFrame: (ScratchStackFrame new expression: block firstBlockList)].

! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/6/2016 11:57'!
doIf
	"Evaluate the current expression (which must be an if)."

	| block arguments argExp |

	block _ stackFrame expression.
	arguments _ stackFrame arguments.

	"Evaluate the arg if we haven't already."
	arguments size = 0
		ifTrue:	[argExp _ block argumentAt: 1.
				^self pushStackFrame: (ScratchStackFrame new expression: argExp)].

	"We can pop this expression off the stack either way."
	self popStackFrame.

	"If the predicate was false, just return."
	arguments first asBoolean
		ifFalse: [^self].

	"Since the predicate was true, evaluate the body of the if."
	self pushStackFrame: (ScratchStackFrame new expression: block firstBlockList).! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 4/5/2016 16:16'!
doIfElse
	"Evaluate the current expression (which must be an if-then-else)."

	| block arguments argExp |
	block _ stackFrame expression.
	arguments _ stackFrame arguments.

	"evaluate the arg if we haven't already."
	arguments size = 0 ifTrue: [
		argExp _ block argumentAt: 1.
		^ self pushStackFrame: (ScratchStackFrame new expression: argExp)].

	"we can pop this expression off the stack either way"
	self popStackFrame.

	(arguments first asBoolean)
		ifTrue: [self pushStackFrame: (ScratchStackFrame new expression: block trueBlockList)]
		ifFalse: [self pushStackFrame: (ScratchStackFrame new expression: block falseBlockList)].
! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'jm 5/5/2007 17:04'!
doPlaySoundAndWait
	"Play a sound and block until it has finished playing."

	| block args soundName snd |
	block _ stackFrame expression.
	args _ stackFrame arguments.

	"first time: send the event and collect a list of processes"
	args size = 0
		ifTrue: [
			soundName _ block args first.
			snd _ block receiver soundNamed: soundName ifAbsent: [^ self popStackFrame].
			snd playFromStart]
		ifFalse: [
			snd _ args first].

	"if sound has stopped, pop this frame and we're done"
	snd isPlaying ifFalse: [^ self popStackFrame].

	"Set up the wait loop. We need to:
		1.  yield to another process
		2.  evaluate our termination condition again
	Push these onto stack in reverse order."

	"2.  evaluate this block again"
	"(Remove the current frame and replace it with one that will force the termination condition to be re-evaluated.)"
	self popStackFrameNoUnhightlight.
	self pushStackFrame: (ScratchStackFrame new
		expression: block;
		addArgument: snd).

	"1.  yield to another process"
	self pushStackFrame: (ScratchStackFrame new shouldYield: true).
! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 12/12/2015 12:57'!
doRepeat
	"Handles one iteration of a repeat block."

	| arguments argExp block counter frame |

	block _ stackFrame expression.
	arguments _ stackFrame arguments.

	"If we haven't done so yet, evaluate the argument to repeat."
	arguments size < 1
		ifTrue:	[argExp _ block argumentAt: 1.
				^self pushStackFrame: (ScratchStackFrame new expression: argExp)].

	"If the number of times to repeat is 0, then we're done."
	counter _ arguments first asNumberNoError.
	counter <= 0 ifTrue:	[^ self popStackFrame].

	"Pop this instruction from the stack."
	self popStackFrameNoUnhightlight.

	"At top of stack should now be:
		1.  evaluate body of repeat block.
		2.  yield.
		3.  evaluate repeat block with decremented counter value.
	Need to add these to the stack in reverse order."

	"3.  evaluate repeat block with decremented counter value."
	frame _ ScratchStackFrame new
				expression:		block;
				addArgument:	counter - 1.
	self pushStackFrame: frame.

	"2.  yield."
	self isAtomic ifFalse: [self pushStackFrame: (ScratchStackFrame new shouldYield: true)].

	"1.  evaluate body of repeat block."
	self pushStackFrame: (ScratchStackFrame new expression: block firstBlockList).
! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'jm 3/22/2005 11:17'!
doReturn
	"Evaluates its argument, and returns the value to the frame from which the current method was called."

	| value args |

	args _ stackFrame arguments.

	"Evaluate the argument, if necessary."
	args size < stackFrame expression argumentCount
		ifTrue: [^self evaluateNextArgument].

	"Remember the return value."
	args size > 0
		ifTrue:	[value _ args first]
		ifFalse:	[value _ nil].

	"Pop until we're out of frames to pop, or we hit a return marker."

	[stackFrame isNil] whileFalse:
		[self popStackFrame].

	stackFrame ifNotNil:	[
		self returnValueToParentFrame: value.
		self popStackFrame].
! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'DaveF 7/25/2003 11:15'!
doUntil
	"Evaluates the current until-loop expression."

	^self doUntil: true.! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 12/12/2015 12:58'!
doUntil: terminatingBoolean
	"Evaluates the current while or until loop expression until the loop condition evaluates to the boolean terminating value."

	| args block |

	block _ stackFrame expression.
	args _ stackFrame arguments.

	"Evaluate the condition if we haven't yet."
	args size < 1
		ifTrue: [^self evaluateNextArgument].

	"If the condition matches the terminatingBoolean, pop this frame and we're done."
	args first = terminatingBoolean ifTrue: [^self popStackFrame].

	"Set up for an iteration of the while loop.  We need to:
		1.  evaluate the body
		2.  yield to another process
		3.  evaluate the while/until block again
	Push these onto stack in reverse order."

	"3.  evaluate the while/until block again"
	"(We remove the current frame and replace it with one that will force the argument to be re-evaluated.)"
	self popStackFrameNoUnhightlight.
	self pushStackFrame: (ScratchStackFrame new expression: block).

	"2.  yield to another process"
	self isAtomic ifFalse: [self pushStackFrame: (ScratchStackFrame new shouldYield: true)].
	
	"1.  evaluate the body"
	self pushStackFrame: (ScratchStackFrame new expression: block firstBlockList).
! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'jm 1/22/2007 13:09'!
doWaitUntil
	"Evaluates the the wait condition until it evaluates to true."

	| block args |
	block _ stackFrame expression.
	args _ stackFrame arguments.

	"evaluate the termination expression if we haven't yet."
	args size < 1 ifTrue: [^ self evaluateNextArgument].

	"if the termination condition is met, pop this frame and we're done."
	args first ifTrue: [^ self popStackFrame].

	"Set up for waitUntil loop. We need to:
		1.  yield to another process
		2.  evaluate the termination expression again
	Push these onto stack in reverse order."

	"2.  evaluate this block again"
	"(Remove the current frame and replace it with one that will force the termination expression to be re-evaluated.)"
	self popStackFrameNoUnhightlight.
	self pushStackFrame: (ScratchStackFrame new expression: block).

	"1.  yield to another process"
	self pushStackFrame: (ScratchStackFrame new shouldYield: true).
! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'DaveF 7/25/2003 11:14'!
doWhile
	"Evaluates the current while-loop expression."

	^self doUntil: false.! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 12/12/2015 11:25'!
startSceneAndWait
	"Broadcast an event and wait until all processes started by that broadcast have terminated."

	| block args eventName stage procs |
	block _ stackFrame expression.
	args _ stackFrame arguments.

	"first time: send the event and collect a list of processes"
	args size = 0
		ifTrue: [
			eventName _ block args first asString.
			stage _ block receiver ownerThatIsA: ScratchStageMorph.
			procs _ stage broadcastEventNamed: 'Scratch-BackDropChanged' with: eventName]
		ifFalse: [
			procs _ args first].

	"if all processes have stopped, pop this frame and we're done."
	(procs select: [:p | p isRunning]) size = 0 ifTrue: [^ self popStackFrame].

	"Set up the wait loop. We need to:
		1.  yield to another process
		2.  evaluate the termination expression again
	Push these onto stack in reverse order."

	"2.  evaluate this block again"
	"(Remove the current frame and replace it with one that will force the termination expression to be re-evaluated.)"
	self popStackFrameNoUnhightlight.
	self pushStackFrame: (ScratchStackFrame new expression: block; addArgument: procs).

	"1.  yield to another process"
	self pushStackFrame: (ScratchStackFrame new shouldYield: true).
! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 12/8/2015 19:52'!
stopScripts
	"Evaluates its argument, and returns the value to the frame from which 
	the current method was called."
	| value args stage |
	args _ stackFrame arguments.
	"Evaluate the argument, if necessary."
	args size < stackFrame expression argumentCount ifTrue: [^ self evaluateNextArgument].
	"Remember the return value."
	args size > 0
		ifTrue: [value _ args first]
		ifFalse: [value _ nil].
	value = 'this script'
		ifTrue: 
			["Pop until we're out of frames to pop, or we hit a return 
			marker. "
			[stackFrame isNil]
				whileFalse: [self popStackFrame].
			stackFrame
				ifNotNil: 
					[self returnValueToParentFrame: value.
					self popStackFrame].
			^ self].
	value = 'all'
		ifTrue: 
			[stage _ stackFrame expression receiver ownerThatIsA: ScratchStageMorph.
			stage ifNotNil: [stage stopAll].
			self stop.
			^ self].
	value = 'other scripts in sprite' ifTrue: [(stackFrame expression receiver blocksBin submorphs) do: [:m | ((m isKindOf: BlockMorph) and: [m ~= topBlock]) ifTrue: [m stop]]. self popStackFrame.
	^ self].

	^ self error: 'Again... stopScripts.'! !

!ScratchProcess methodsFor: 'private-special forms' stamp: 'EMP 12/12/2015 12:58'!
warpSpeed
	"Handles one iteration of a repeat block."

	| block |

	block _ stackFrame expression.


	"Pop this instruction from the stack."
	self popStackFrameNoUnhightlight.

	"At top of stack should now be:
		1.  evaluate the body of the all at once block.
	Need to add these to the stack in reverse order."


	"1.  evaluate body of repeat block."
	self pushStackFrame: (ScratchStackFrame new expression: block firstBlockList).
! !


!ScratchProcess methodsFor: 'private-stack' stamp: 'EMP 12/12/2015 13:01'!
popStackFrame
	"Pops the current stack frame off the top of the stack, so that the next one becomes the current frame."

	| command frame unlightFrame |

	frame _ stackFrame.
	stackFrame _ stackFrame parentFrame.

	command _ frame expression.

	self isAtomic ifTrue: [^ self].

	BlockHighlightMSecs > 0 ifTrue: [
		(frame shouldUnlight not and: [command isKindOf: BlockMorph]) ifTrue: [
			"We push a new frame for unlighting this command."
			unlightFrame _ ScratchStackFrame new
				expression: command;
				shouldUnlight: true.
			self pushStackFrame: unlightFrame]].
! !

!ScratchProcess methodsFor: 'private-stack' stamp: 'jm 1/22/2007 13:12'!
popStackFrameNoUnhightlight
	"Pops the current stack frame off the top of the stack, so that the next one becomes the current frame. Do not add a stack frame to unhighlight this block. Use this method when a block will re-evaluated, such 'wait until'."

	stackFrame _ stackFrame parentFrame.

! !

!ScratchProcess methodsFor: 'private-stack' stamp: 'jm 3/23/2005 09:06'!
pushStackFrame: aScratchStackFrame
	"Pushes the given new stack frame onto the top of the stack, so that it becomes the current stack frame."

	aScratchStackFrame parentFrame: stackFrame.
	stackFrame _ aScratchStackFrame.
! !

!ScratchProcess methodsFor: 'private-stack' stamp: 'jm 8/13/2003 17:40'!
returnValueToParentFrame: anObject
	"Append the given object to the argument list of my parent frame."

	| f |
	stackFrame ifNil: [^ self].
	f _ stackFrame parentFrame.
	[f notNil and: [f shouldUnlight]] whileTrue: [
		f _ f parentFrame].
	f ifNotNil: [f addArgument: anObject].
! !

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


!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/5/2016 15:54'!
call
	| block args proc blockArgs scriptReceiver |
	block _ stackFrame expression.
	args _ stackFrame arguments.

	stackFrame expression isReporter ifTrue: [^ self callReporter].

	args size = 0 ifTrue: [
	blockArgs _ block args.
	scriptReceiver _ block receiver.
	proc _ ((scriptReceiver procedure: block commandSpec withArgs: blockArgs)) scriptArgs: (blockArgs).
	] ifFalse: [
	proc _ args first.
	].

	(proc isKindOf: Array) ifTrue: [answer _ ''. self returnValueToParentFrame: nil. ^ self popStackFrame].
	proc isRunning ifFalse: [answer _ proc answer. self returnValueToParentFrame: answer. ^ self popStackFrame].

	self popStackFrameNoUnhightlight.
	self pushStackFrame: (ScratchStackFrame new expression: block; addArgument: proc).
	self pushStackFrame: (ScratchStackFrame new shouldYield: true).
! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/6/2016 12:00'!
callReporter
	| block args proc blockArgs scriptReceiver |
	block _ stackFrame expression.
	args _ stackFrame arguments.
	args size < stackFrame expression argumentCount
		ifTrue: [^self evaluateNextArgument].

	(args size = (stackFrame expression argumentCount + 1)) ifFalse: [
	blockArgs _ args.
	scriptReceiver _ block receiver.
	proc _ ((scriptReceiver procedure: block commandSpec withArgs: blockArgs)) scriptArgs: (blockArgs).
	args add: proc.
	] ifTrue: [
	proc _ args last.
	].

	(proc isKindOf: Array) ifTrue: [answer _ ''. self returnValueToParentFrame: nil. ^ self popStackFrame].
	proc isRunning ifFalse: [answer _ proc answer. self returnValueToParentFrame: answer. ^ self popStackFrame].

	self popStackFrameNoUnhightlight.
	self pushStackFrame: (ScratchStackFrame new expression: block; arguments: args; yourself).
	self isAtomic ifFalse: [
	self pushStackFrame: (ScratchStackFrame new shouldYield: true)].
! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/5/2016 16:14'!
getArgumentOrNil: selector
	^ scriptVars at: selector asByteArray asString ifAbsent: [nil].! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 2/25/2016 16:31'!
isAtomic
	| t1 t2 |
	t2 _ World findA: ScratchPresenterMorph.
	t2 notNil
		ifTrue: [t1 _ t2 buttons third bounds]
		ifFalse: [t1 _ ScratchFrameMorph allInstances first stopButton bounds].
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
	^ (topBlock isKindOf: ProcedureHatBlockMorph) and: [topBlock isAtomic]! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/5/2016 16:04'!
report
	| t1 t3 |
	"If we haven't done so already, evaluate the argument to be reported back to the end-user"
	stackFrame arguments size < stackFrame expression argumentCount
		ifTrue:	[^ self evaluateNextArgument].

	t1 _ stackFrame arguments first asString.
	answer _ t1.
	t3 _ 
			[[stackFrame isNil or: [stackFrame expression = #closeCustomBlock]]
				whileFalse: [self popStackFrame].
			stackFrame ifNotNil: [self popStackFrame]].
	t3 value.
	[stackFrame notNil
		and: [stackFrame parentFrame notNil and: [stackFrame parentFrame expression = #shouldYield]]]
		whileTrue: 
			[t3 value.
			t3 value].
	self returnValueToParentFrame: t1.
	stackFrame ifNotNil: [self popStackFrame].
	readyToTerminate _ true.! !

!ScratchProcess methodsFor: 'private-custom blocks' stamp: 'EMP 4/5/2016 16:08'!
scriptArgs: aDictionary

	| argNames |
	scriptVars _ Dictionary new.
	argNames _ (topBlock findArgs).
	argNames do: [:arg | scriptVars at: arg asByteArray asString put: (aDictionary at: (argNames indexOf: arg))].! !

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


ScratchProcess initialize!
