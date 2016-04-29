ReporterBlockMorph subclass: #ListContentsBlockMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!ListContentsBlockMorph commentStamp: 'jm 5/5/2008 10:40' prior: 0!
Reporter for the contents of a list.
!


!ListContentsBlockMorph methodsFor: 'all' stamp: 'jens 11/18/2008 09:40'!
addLabel
	"Add a label for my command and arguments. 
	This is the method that really creates the whole block."
	"Details: This overrides the superclass method to allow 
	using percent character in variable/list names"

	commandSpec ifNil: [^ self].
	self removeAllMorphs.
	self addMorphBack: (self labelMorphFor: commandSpec).
! !

!ListContentsBlockMorph methodsFor: 'all' stamp: 'jm 5/12/2008 22:45'!
asBlockTuple
	"Answer a tuple (Array) describing this block and its arguments."

	^ Array with: #contentsOfList: with: commandSpec
! !

!ListContentsBlockMorph methodsFor: 'all' stamp: 'EMP 4/26/2016 16:17'!
evaluateInStackFrame: t1 
	^ self evaluateWithArgs: nil! !

!ListContentsBlockMorph methodsFor: 'all' stamp: 'jm 5/5/2008 10:45'!
evaluateWithArgs: ignored

	^ receiver contentsOfList: commandSpec
! !

!ListContentsBlockMorph methodsFor: 'all' stamp: 'jm 5/6/2008 17:10'!
selectorAndArg

	^ Array with: selector with: commandSpec
! !

!ListContentsBlockMorph methodsFor: 'all' stamp: 'jm 8/13/2008 18:56'!
toggleWatcher
	"Toggle between hiding and showing a list watcher for this block."

	| listMorph stage |
	listMorph _ receiver lists at: commandSpec ifAbsent: [^ self].
	listMorph owner
		ifNil: [
			(stage _ receiver ownerThatIsA: ScratchStageMorph) ifNil: [^ self].
			stage addMorph: listMorph.
			(stage bounds containsPoint: listMorph topLeft) ifFalse: [
				listMorph position: stage topLeft + 10].
			listMorph
				fixLayoutForNewLanguage;
				startStepping]
		ifNotNil: [
			listMorph delete].
! !
