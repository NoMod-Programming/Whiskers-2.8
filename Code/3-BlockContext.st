ContextPart variableSubclass: #BlockContext
	instanceVariableNames: 'nargs startpc home '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Kernel-Methods'!
!BlockContext commentStamp: '<historical>' prior: 0!
My instances function similarly to instances of MethodContext, but they hold the dynamic state for execution of a block in Smalltalk. They access all temporary variables and the method sender via their home pointer, so that those values are effectively shared. Their indexable part is used to store their independent value stack during execution.
	
My instance must hold onto its home in order to work. This can cause circularities if the home is also pointing (via a temp, perhaps) to the instance. In the rare event that this happens (as in SortedCollection sortBlock:) the message fixTemps will replace home with a copy of home, thus defeating the sharing of temps but, nonetheless, eliminating the circularity.

BlockContexts must only be created using the method newForMethod:.  Note that it is impossible to determine the real object size of a BlockContext except by asking for the frameSize of its method.  Any fields above the stack pointer (stackp) are truly invisible -- even (and especially!!) to the garbage collector.  Any store into stackp other than by the primitive method stackp: is potentially fatal.!


!BlockContext methodsFor: 'initialize-release'!
home: aContextPart startpc: position nargs: anInteger 
	"This is the initialization message. The receiver has been initialized with 
	the correct size only."

	home _ aContextPart.
	startpc _ position.
	nargs _ anInteger! !


!BlockContext methodsFor: 'accessing'!
fixTemps
	"Fix the values of the temporary variables used in the block that are 
	ordinarily shared with the method in which the block is defined."

	home _ home copy.
	home swapSender: nil! !

!BlockContext methodsFor: 'accessing'!
hasMethodReturn
	"Answer whether the receiver has a return ('^') in its code."

	| method scanner end |
	method _ self method.
	"Determine end of block from long jump preceding it"
	end _ (method at: startpc-2)\\16-4*256 + (method at: startpc-1) + startpc - 1.
	scanner _ InstructionStream new method: method pc: startpc.
	scanner scanFor: [:byte | (byte between: 120 and: 124) or: [scanner pc > end]].
	^scanner pc <= end! !

!BlockContext methodsFor: 'accessing'!
home
	"Answer the context in which the receiver was defined."

	^home! !

!BlockContext methodsFor: 'accessing'!
method
	"Answer the compiled method in which the receiver was defined."

	^home method! !

!BlockContext methodsFor: 'accessing'!
numArgs

	^nargs! !

!BlockContext methodsFor: 'accessing'!
receiver 
	"Refer to the comment in ContextPart|receiver."

	^home receiver! !

!BlockContext methodsFor: 'accessing'!
tempAt: index 
	"Refer to the comment in ContextPart|tempAt:."

	^home at: index! !

!BlockContext methodsFor: 'accessing'!
tempAt: index put: value 
	"Refer to the comment in ContextPart|tempAt:put:."

	^home at: index put: value! !


!BlockContext methodsFor: 'evaluating' stamp: 'jm 5/22/2003 20:25'!
ifError: errorHandlerBlock
	"Evaluate the block represented by the receiver. If an error occurs the given handler block is evaluated. The handler block can be either a zero- or two-argument block; if the latter, then the error message and receiver are supplied to it as parameters. Answer the value returned by the handler block if the receiver gets an error."
	"Warning: The receiver should not contain an explicit return since that would leave an obsolete error handler hanging around."
	"Examples:
		[1 whatsUpDoc] ifError: [:err :rcvr | ^ 'huh?'].
		[1 whatsUpDoc] ifError: ['huh'].
		[1 / 0] ifError: [:err :rcvr |
			'division by 0' = err
				ifTrue: [^ Float infinity]
				ifFalse: [self error: err]]
"

	| activeProcess lastHandler val |
	activeProcess _ Processor activeProcess.
	lastHandler _ activeProcess errorHandler.
	activeProcess errorHandler: [:aString :aReceiver |
		activeProcess errorHandler: lastHandler.
		errorHandlerBlock numArgs = 0 ifTrue: [^ errorHandlerBlock value].
		^ errorHandlerBlock value: aString value: aReceiver].
	val _ self value.
	activeProcess errorHandler: lastHandler.
	^ val
! !

!BlockContext methodsFor: 'evaluating' stamp: 'jm 6/10/2003 12:26'!
msecs
	"Answer the number of milliseconds taken to execute this block. For typing convenience (shorter than 'timeToRun')."

	^ Time millisecondsToRun: self
! !

!BlockContext methodsFor: 'evaluating' stamp: 'jm 6/3/1998 14:25'!
timeToRun
	"Answer the number of milliseconds taken to execute this block."

	^ Time millisecondsToRun: self
! !

!BlockContext methodsFor: 'evaluating'!
value
	"Primitive. Evaluate the block represented by the receiver. Fail if the 
	block expects any arguments or if the block is already being executed. 
	Optional. No Lookup. See Object documentation whatIsAPrimitive."

	<primitive: 81>
	^self valueWithArguments: #()! !

!BlockContext methodsFor: 'evaluating'!
value: arg 
	"Primitive. Evaluate the block represented by the receiver. Fail if the 
	block expects other than one argument or if the block is already being 
	executed. Optional. No Lookup. See Object documentation 
	whatIsAPrimitive."

	<primitive: 81>
	^self valueWithArguments: (Array with: arg)! !

!BlockContext methodsFor: 'evaluating'!
value: arg1 value: arg2 
	"Primitive. Evaluate the block represented by the receiver. Fail if the 
	block expects other than two arguments or if the block is already being 
	executed. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 81>
	^self valueWithArguments: (Array with: arg1 with: arg2)! !

!BlockContext methodsFor: 'evaluating'!
value: arg1 value: arg2 value: arg3 
	"Primitive. Evaluate the block represented by the receiver. Fail if the 
	block expects other than three arguments or if the block is already being 
	executed. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 81>
	^self valueWithArguments: 
		(Array
			with: arg1
			with: arg2
			with: arg3)! !

!BlockContext methodsFor: 'evaluating' stamp: 'di 11/30/97 09:19'!
value: arg1 value: arg2 value: arg3 value: arg4 
	"Primitive. Evaluate the block represented by the receiver. Fail if the 
	block expects other than three arguments or if the block is already being 
	executed. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 81>
	^self valueWithArguments: 
		(Array
			with: arg1
			with: arg2
			with: arg3
			with: arg4)! !

!BlockContext methodsFor: 'evaluating'!
valueWithArguments: anArray 
	"Primitive. Evaluate the block represented by the receiver. The argument 
	is an Array whose elements are the arguments for the block. Fail if the 
	length of the Array is not the same as the the number of arguments that 
	the block was expecting. Fail if the block is already being executed. 
	Essential. See Object documentation whatIsAPrimitive."

	<primitive: 82>
	self numArgs = anArray size
		ifTrue: [self error: 'Attempt to evaluate a block that is already being evaluated.']
		ifFalse: [self error: 'This block requires ' , self numArgs printString , ' arguments.']! !


!BlockContext methodsFor: 'controlling' stamp: 'EMP 11/20/2015 12:19'!
repeat
	"Evaluate the receiver repeatedly, ending only if the block explicitly returns."

	[self value. true] whileTrue! !

!BlockContext methodsFor: 'controlling'!
whileFalse
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the receiver, as long as its value is false."
 
	^ [self value] whileFalse: []! !

!BlockContext methodsFor: 'controlling'!
whileFalse: aBlock 
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the argument, aBlock, as long as the value of the receiver is false."

	^ [self value] whileFalse: [aBlock value]! !

!BlockContext methodsFor: 'controlling'!
whileTrue
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the receiver, as long as its value is true."
 
	^ [self value] whileTrue: []! !

!BlockContext methodsFor: 'controlling'!
whileTrue: aBlock 
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the argument, aBlock, as long as the value of the receiver is true."

	^ [self value] whileTrue: [aBlock value]! !


!BlockContext methodsFor: 'scheduling' stamp: 'jm 5/23/2003 12:30'!
bg
	"Create and schedule a Process running the code in the receiver at background priority. For conviently running a computation in the background from an expression."
	"Example: [(Delay forSeconds: 2) wait. self beep] bg"

	^ self forkAt: Processor userBackgroundPriority
! !

!BlockContext methodsFor: 'scheduling' stamp: 'di 9/12/1998 11:53'!
fork
	"Create and schedule a Process running the code in the receiver."

	^ self newProcess resume! !

!BlockContext methodsFor: 'scheduling' stamp: 'jm 11/9/1998 10:16'!
forkAt: priority 
	"Create and schedule a Process running the code in the receiver at the given priority. Answer the newly created process."

	| forkedProcess |
	forkedProcess _ self newProcess.
	forkedProcess priority: priority.
	^ forkedProcess resume
! !

!BlockContext methodsFor: 'scheduling' stamp: 'ar 6/5/1998 21:44'!
newProcess
	"Answer a Process running the code in the receiver. The process is not 
	scheduled."
	<primitive: 19> "Simulation guard"
	^Process
		forContext: 
			[self value.
			Processor terminateActive]
		priority: Processor activePriority! !

!BlockContext methodsFor: 'scheduling' stamp: 'EMP 11/20/2015 12:46'!
on: exception do: handlerAction
	"Evaluate the receiver in the scope of an exception handler."
	| handlerActive |
	<primitive: 199>
	handlerActive _ true.
	^self value! !


!BlockContext methodsFor: 'instruction decoding'!
blockReturnTop
	"Simulate the interpreter's action when a ReturnTopOfStack bytecode is 
	encountered in the receiver."

	| save dest |
	save _ home.	"Needed because return code will nil it"
	dest _ self return: self pop to: self sender.
	home _ save.
	sender _ nil.
	^dest! !


!BlockContext methodsFor: 'printing'!
printOn: aStream

	home == nil ifTrue: [^aStream nextPutAll: 'a BlockContext with home=nil'].
	aStream nextPutAll: '[] in '.
	super printOn: aStream! !


!BlockContext methodsFor: 'private' stamp: 'jm 5/15/2003 20:52'!
cannotReturn: result
	"The receiver tried to return result to a method context that no longer exists."

	Debugger
		openContext: thisContext
		label: 'Block cannot return'
		contents: thisContext shortStack.
! !

!BlockContext methodsFor: 'private' stamp: 'di 1/14/1999 22:28'!
instVarAt: index put: value
	index = 3 ifTrue: [self stackp: value. ^ value].
	^ super instVarAt: index put: value! !


!BlockContext methodsFor: 'system simulation' stamp: 'di 1/11/1999 10:24'!
pushArgs: args from: sendr 
	"Simulates action of the value primitive."

	args size ~= nargs ifTrue: [^self error: 'incorrect number of args'].
	self stackp: 0.
	args do: [:arg | self push: arg].
	sender _ sendr.
	pc _ startpc! !
