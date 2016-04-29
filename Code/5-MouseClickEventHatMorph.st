EventHatMorph subclass: #MouseClickEventHatMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!MouseClickEventHatMorph commentStamp: 'jm 3/28/2005 12:26' prior: 0!
I am a hat block for stacks triggered by clicking on an object with the mouse.
!


!MouseClickEventHatMorph methodsFor: 'initialization' stamp: 'EMP 4/6/2016 15:07'!
initialize

	| s |
	super initialize.
	self removeAllMorphs.

	s _ StringMorph new contents: 'when this sprite clicked' localized; font: (ScratchFrameMorph getFont: #Label); color: Color white.
	self addMorphBack: s.
! !


!MouseClickEventHatMorph methodsFor: 'other' stamp: 'jm 3/28/2005 12:38'!
eventName

	^ 'Scratch-MouseClickEvent'
! !

!MouseClickEventHatMorph methodsFor: 'other' stamp: 'EMP 4/26/2016 16:34'!
eventNameMatches: t1 
	^ false! !

!MouseClickEventHatMorph methodsFor: 'other' stamp: 'EMP 4/26/2016 16:34'!
isMouseClickEventHatMorph
	^ true! !

!MouseClickEventHatMorph methodsFor: 'other' stamp: 'jm 12/8/2005 19:22'!
printHatNameOn: aStream
	"Append a human-readable string for this hat block's name to the given stream."

	aStream nextPutAll: 'when ', self receiverName, ' clicked'; cr.
! !

!MouseClickEventHatMorph methodsFor: 'other' stamp: 'jm 12/17/2004 16:04'!
receiverName

	(scriptOwner respondsTo: #objName)
		ifTrue: [^ scriptOwner objName]
		ifFalse: [^ 'I''m'].
! !
