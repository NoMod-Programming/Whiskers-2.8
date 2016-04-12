HatBlockMorph subclass: #WhenTrueHatBlockMorph
	instanceVariableNames: 'argMorph secondArgMorph lastState lastArg '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!

!WhenTrueHatBlockMorph methodsFor: 'initialization' stamp: 'EMP 10/3/2015 18:56'!
choice: aChoice
	secondArgMorph choice: aChoice! !

!WhenTrueHatBlockMorph methodsFor: 'initialization' stamp: 'EMP 1/7/2016 12:23'!
initialize

	| s1 s2 |
	super initialize.
	lastState _ false.
	lastArg _ nil.
	argMorph _ (ExpressionArgMorph new).
	secondArgMorph _ (ChoiceArgMorph new choice: 'loudness'; options: #('timer' 'loudness')).
	lastState _ false.

	s1 _ 'when' localized.
	s2 _ '>' localized.
	self removeAllMorphs.
	self addMorphBack: ((StringMorph contents: s1 font: (ScratchFrameMorph getFont: #Label)) color: Color white).
	self addMorphBack: secondArgMorph.
	self addMorphBack: ((StringMorph contents: s2 font: (ScratchFrameMorph getFont: #Label)) color: Color white).
	self addMorphBack: argMorph "too lazy to change all references to argMorph"
! !


!WhenTrueHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/3/2015 18:50'!
argMorph

	submorphs do: [:m |
		(m isKindOf: ReporterBlockMorph) ifTrue: [^ m]].
	^ argMorph
! !

!WhenTrueHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/3/2015 18:51'!
argMorphToReplace: aMorph
	"Answer a new argument morph to be used to replace the given morph."

	aMorph ~= argMorph ifTrue: [^ nil].
	^ (ExpressionArgMorph new)! !

!WhenTrueHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/3/2015 21:08'!
asBlockTuple
	"Answer a tuple (Array) describing this block and its arguments."

	| argTuple secondArgTuple |
	argTuple _ (argMorph isKindOf: ArgMorph)
		ifTrue: [argMorph evaluate]
		ifFalse: [argMorph asBlockTuple].
	secondArgTuple _ (secondArgMorph isKindOf: ArgMorph)
		ifTrue: [secondArgMorph evaluate]
		ifFalse: [secondArgMorph asBlockTuple].

	^ Array with: #whenSensorGreaterThan with: secondArgTuple with: argTuple! !

!WhenTrueHatBlockMorph methodsFor: 'other' stamp: 'EMP 1/7/2016 12:38'!
evaluateCondition
	"Answer true if my condition is true."
	
	(lastArg asNumberNoError = (argMorph evaluate asNumberNoError)) ifTrue: [^ false].
	(argMorph evaluate) isNumber ifTrue: [lastArg _ (argMorph evaluate) asNumberNoError. ^ lastState _ (argMorph evaluate) < (scriptOwner whenTrueGet: (secondArgMorph evaluate) numberTesting: (argMorph evaluate))].
	lastArg _ (argMorph evaluate) asNumberNoError.
	^ false
! !

!WhenTrueHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/5/2015 08:05'!
fixBlockLayout
	"Update the positions of my submorphs."

	| x centerY nextB |
	argMorph ifNil: [^ self].  "happens during initialization"
	blockLayoutNeeded ifFalse: [^ self].
	cachedForm _ nil.
	cachedFeedbackForm _ nil.
	secondArgMorph color: (self color darker).

	((argMorph isKindOf: ArgMorph) and: [argMorph owner = self])
		ifTrue: [argMorph fixArgLayout].
	self height: 26 + argMorph height.

	x _ self left + 8.
	centerY _ bounds center y + 5.
	self nonControlFlowSubmorphs do: [:m |
		m position: x@(centerY - (m height // 2)).
		x _ x + m width + 5].

	self width: ((x + 4 - self left) max: self hatTopForm width).

	(nextB _ self nextBlock) ifNotNil: [
		nextB top: self bottom - 4.
		nextB fixBlockLayout].
! !

!WhenTrueHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/3/2015 18:05'!
helpScreenName
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	^ 'whenHat'
! !

!WhenTrueHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/3/2015 18:05'!
nextBlock
	"Answer the block following myself in the block sequence or nil if I am the last block in the sequence. Each block is a submorph of the previous block."

	^ self submorphs
		detect: [:m | (m isKindOf: BlockMorph) and: [m ~= argMorph]]
		ifNone: [nil]
! !

!WhenTrueHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/3/2015 18:05'!
printHatNameOn: aStream
	"Append a human-readable string for this hat block's name to the given stream."

	aStream nextPutAll: 'when '.
	self printCodeSubmorph: argMorph on: aStream.
	aStream nextPutAll: ' becomes true'; cr.
! !

!WhenTrueHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/3/2015 18:05'!
replaceArgMorph: oldMorph by: newMorph
	"Replace oldMorph with newMorph. This is done when dropping a reporter block onto my argument."

	argMorph _ newMorph.
	self replaceSubmorph: oldMorph by: newMorph.
	self layoutChanged.
! !

!WhenTrueHatBlockMorph methodsFor: 'other' stamp: 'EMP 1/7/2016 12:41'!
reset
	^ lastArg _ (argMorph evaluate asNumberNoError - 1)! !
