ReporterBlockMorph subclass: #ProcReporterCallBlockMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!ProcReporterCallBlockMorph commentStamp: 'EMP 1/12/2016 14:21' prior: 0!
If I weren't too tired right now, I would implement custom reporters. Alas, I am too tired!


!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/12/2016 14:18'!
addLabel
	"Add a label for my command and arguments. This is the method that really creates the whole block."
	"Details: We remove all the pieces of this block, and then reassemble them, being careful not to destroy any argument morphs that we might still want to use. This is helpful if someone adds/removes parameters from a hat block. Percent signs with a slash after them (%/) are commented and treated as part of the label"

	| tokens args nextArgIndex m next |
	commandSpec ifNil: [^ self].

	"we make sure not to remove the next block."
	next _ self nextBlock.
	self removeAllMorphsIn: (self submorphs reject: [:t | t = next]).

	tokens _ CommandBlockMorph parseCommandSpec: commandSpec.
	args _ tokens select: [:s | BlockCreatorMorph isArgSpec: s].

	"remove any excess arg morphs from the list."
	[argMorphs size > args size] whileTrue: [
		m _ argMorphs last.
		argMorphs remove: m.

		"if the argument we're throwing out is anything complicated, we'd like to keep it around in the world."
		(m isKindOf: BlockMorph) ifTrue: [m openInWorld]].

	"create new arg morphs."
	[argMorphs size < args size] whileTrue: [
		argMorphs addLast: (self argMorphFor: (args at: argMorphs size + 1))].

	nextArgIndex _ 1.

	tokens do: [:spec |
		s _ spec.
		(BlockCreatorMorph isArgSpec: s)
			ifTrue:	[
				m _ argMorphs at: nextArgIndex.
				nextArgIndex _ nextArgIndex + 1]
			ifFalse:	[
				m _ self labelMorphFor: s].
		self addMorphBack: m].

	self isReporter ifTrue: [
		m _ submorphs first.
		((m isKindOf: ChoiceArgMorph) | (m isKindOf: SpriteArgMorph)) ifTrue: [  "add spacer"
			self addMorphFront: (Morph new color: Color transparent; extent: 2@5)].

		m _ submorphs last.
		((m isKindOf: ChoiceArgMorph) | (m isKindOf: SpriteArgMorph)) ifTrue: [  "add spacer"
			self addMorphBack: (Morph new color: Color transparent; extent: 2@5)]].
! !

!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/15/2016 19:25'!
allVarNames
	^ self procedure findArgs! !

!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/12/2016 15:28'!
argumentAt: index
	^ argMorphs at: index "override the superclass method"! !

!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/28/2016 12:25'!
asBlockTuple
	| blockTuple argList arg |
	blockTuple _ Array new: argMorphs size + 2.
	blockTuple at: 1 put: #callReporter.
	blockTuple at: 2 put: (self commandSpec).
	argList _ argMorphs.
	argList _ self organizeArgs: argList.
	1 to: argList size do: [:i |
		arg _ argList at: i.
		(arg isKindOf: ArgMorph) | (arg isKindOf: EventTitleMorph)
			ifTrue: [blockTuple at: i + 2 put: arg evaluate]
			ifFalse: [blockTuple at: i + 2 put: arg asBlockTuple]].
	^ blockTuple! !

!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 14:52'!
editCustomBlock
	| block |
	block _ self receiver procedure: (self commandSpec).
	block ifNotNil: [
	block editCustomBlock].! !

!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/16/2016 11:52'!
evaluate
	self start.
	scratchProc stepUntilDoneFor: (receiver ownerThatIsA: ScratchStageMorph).
	^ scratchProc answer! !

!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 15:15'!
evaluateIn: aStackFrame
	super evaluateIn: aStackFrame.
	^ false! !

!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/16/2016 11:52'!
evaluateWithArgs: t1 
	self start.
	scratchProc stepUntilDoneFor: (receiver ownerThatIsA: ScratchStageMorph).
	^ scratchProc answer! !

!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/12/2016 14:19'!
initialize
	| |
	super initialize.
	self color: (Color r: 89/255 g: 71/255 b:177/255)! !

!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/15/2016 19:25'!
isAtomic
	^ self procedure isAtomic! !

!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/5/2016 12:21'!
isSpecialForm
	^ true! !

!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/15/2016 19:25'!
procedure
	^ self receiver procedure: (self commandSpec).! !

!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/12/2016 15:29'!
rightButtonMenu

	| menu choice |
	menu _ CustomMenu new.

	menu add: 'duplicate' action: #duplicate.
	menu add: 'delete' action: #delete.
	menu addLine.
	menu add: 'add comment' action: #addComment.
	menu add: 'help' action: #presentHelpScreen.
	menu add: 'edit' action: #editCustomBlock.

	DebugMenu ifTrue: [
		menu addLine.
		menu add: 'show tuples' action: #showTuples].
	
	(choice _ menu localize; startUp) ifNil: [^ self] ifNotNil: [^ self perform: choice]
! !

!ProcReporterCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/16/2016 16:28'!
showValue
	| t1 t2 t3 t4 t5 |
	t1 _ false.
	
	[self start.
	scratchProc stepUntilDoneFor: (receiver ownerThatIsA: ScratchStageMorph).
	t2 _ scratchProc answer] ifError: 
			[t1 _ true.
			t2 _ 'Error!!'].
	(t2 isKindOf: Morph)
		ifTrue: [(t2 respondsTo: #displayForm)
				ifTrue: [t2 _ t2 displayForm]
				ifFalse: [t2 _ t2 imageForm]]
		ifFalse: [t2 _ t2 asString].
	((self isBooleanReporter or: [t2 = 'Error!!'])
		and: [t2 isKindOf: String])
		ifTrue: [t2 _ t2 localized].
	t3 _ (ScratchReporterToolTipMorph string: t2 for: self) left: self right;
			 bottom: self top.
	ScratchTranslator isRTL ifTrue: [t3 right: self left].
	t1 ifTrue: [t3 messageColor: Color red darker].
	t4 _ self world.
	t4 ifNil: [^ self].
	t4 addMorphFront: t3.
	((t5 _ t4 bounds) containsRect: t3 bounds)
		ifFalse: [t3 bounds: (t3 bounds translatedToBeWithin: t5)].
	self setProperty: #toolTip toValue: t3.
	t3 initialCursorPoint: Sensor cursorPoint.
	t3 startStepping! !
