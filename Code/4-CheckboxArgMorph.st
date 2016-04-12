ArgMorph subclass: #CheckboxArgMorph
	instanceVariableNames: 'checkbox '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!

!CheckboxArgMorph methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 15:06'!
acceptsDroppedReporters
	^ false! !

!CheckboxArgMorph methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 15:06'!
defaultValue: t1 
	t1 = #true ifTrue: [^ checkbox on].
	t1 = #false ifTrue: [^ checkbox off].
	t1
		ifTrue: [checkbox on]
		ifFalse: [checkbox off]! !

!CheckboxArgMorph methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 15:06'!
evaluate
	^ checkbox isOn! !

!CheckboxArgMorph methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 15:06'!
initialize
	super initialize.
	self addMorphBack: (checkbox _ ToggleButton new onForm: (ScratchFrameMorph skinAt: #watcherButtonPressed)
					offForm: (ScratchFrameMorph skinAt: #watcherButton)).
	self extent: checkbox extent! !
