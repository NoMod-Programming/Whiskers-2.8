CommandBlockMorph subclass: #ProcCallBlockMorph
	instanceVariableNames: 'script '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!ProcCallBlockMorph commentStamp: 'EMP 11/10/2015 15:12' prior: 0!
A block that calls custom blocks. It has been redefined because of a new tuple format that is used in 2.0!


!ProcCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/6/2015 18:11'!
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

!ProcCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/15/2016 17:28'!
allVarNames
	^ self procedure findArgs! !

!ProcCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/9/2015 12:38'!
asBlockTuple
	| blockTuple argList arg |
	blockTuple _ Array new: argMorphs size + 2.
	blockTuple at: 1 put: #call.
	blockTuple at: 2 put: (self commandSpec).
	argList _ argMorphs.
	argList _ self organizeArgs: argList.
	1 to: argList size do: [:i |
		arg _ argList at: i.
		(arg isKindOf: ArgMorph) | (arg isKindOf: EventTitleMorph)
			ifTrue: [blockTuple at: i + 2 put: arg evaluate]
			ifFalse: [blockTuple at: i + 2 put: arg asBlockTuple]].
	^ blockTuple! !

!ProcCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 14:52'!
editCustomBlock
	| block |
	block _ self receiver procedure: (self commandSpec).
	block ifNotNil: [
	block editCustomBlock].! !

!ProcCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/3/2015 13:47'!
initialize
	| |
	super initialize.
	self color: (Color r: 89/255 g: 71/255 b:177/255)! !

!ProcCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/15/2016 17:25'!
isAtomic
	^ self procedure isAtomic! !

!ProcCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/15/2016 17:24'!
procedure
	^ self receiver procedure: (self commandSpec).! !

!ProcCallBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 14:53'!
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
