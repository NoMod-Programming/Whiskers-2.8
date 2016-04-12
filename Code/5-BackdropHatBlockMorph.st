EventHatMorph subclass: #BackdropHatBlockMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!

!BackdropHatBlockMorph methodsFor: 'initialization' stamp: 'EMP 3/22/2016 10:39'!
initialize

	| s |
	super initialize.
	self removeAllMorphs.

	s _ StringMorph new
		contents: 'when backdrop switches to ' localized; font: (ScratchFrameMorph getFont: #Label);
		color: Color white.
	self addMorphBack: s.

	scriptNameMorph _ ChoiceArgMorph new
		getOptionsSelector: #stageCostumeNames;
		options: ScriptableScratchMorph new keyNames;
		choice: 'backdrop1'.
	self addMorphBack: scriptNameMorph.
! !


!BackdropHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/2/2015 20:34'!
asBlockTuple
	"Answer a tuple (Array) describing this block and its arguments."

	^ Array
		with: #whenSceneStarts
		with: scriptNameMorph choice
! !

!BackdropHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/2/2015 19:37'!
choice: aString

	scriptNameMorph choice: aString.
	self fixBlockLayout.
	self changed.
! !

!BackdropHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/2/2015 19:54'!
eventName

	^ 'Scratch-BackDropChanged'
! !

!BackdropHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/2/2015 19:54'!
printHatNameOn: aStream
	"Append a human-readable string for this hat block's name to the given stream."

	aStream nextPutAll: 'when backdrop switches to ', scriptNameMorph choice; cr.
! !

!BackdropHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/2/2015 19:43'!
respondsToBackdrop: aBackdropName

	^ (scriptNameMorph choice == aBackdropName)! !

!BackdropHatBlockMorph methodsFor: 'other' stamp: 'EMP 10/2/2015 19:59'!
respondsToBackdropName: aBackdropName

	^ (scriptNameMorph choice == aBackdropName)! !
