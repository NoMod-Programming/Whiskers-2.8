ImageMorph subclass: #ScratchRotationSetterMorph
	instanceVariableNames: 'lastUpdateMSecs target draggingDirection lastRotationDegrees '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!ScratchRotationSetterMorph commentStamp: '<historical>' prior: 0!
I am a rotation setting morph that is like the one in scratch 2.0. To see me in action, simply open a ScratchInfoMorph on a sprite.!


!ScratchRotationSetterMorph methodsFor: 'initialization' stamp: 'EMP 11/10/2015 14:46'!
initialize

	super initialize.
	self form: (ScratchFrameMorph skinAt: #rotationSetterMorph).
	form fillColor: Color transparent.
	form border: form boundingBox width: 1.
	lastUpdateMSecs _ -1.
! !


!ScratchRotationSetterMorph methodsFor: 'accessing' stamp: 'EMP 9/30/2015 16:30'!
extent: aPoint
"Only use squares"
	self form: (ScratchFrameMorph skinAt: #rotationSetterMorph).
	form fillColor: Color transparent.
	form border: form boundingBox width: 1.
	lastUpdateMSecs _ -1.! !

!ScratchRotationSetterMorph methodsFor: 'accessing' stamp: 'EMP 9/30/2015 15:58'!
target

	^ target
! !

!ScratchRotationSetterMorph methodsFor: 'accessing' stamp: 'EMP 9/30/2015 16:02'!
target: aMorph

	target _ aMorph.
	self changed.! !


!ScratchRotationSetterMorph methodsFor: 'drawing' stamp: 'EMP 11/17/2015 18:52'!
drawOn: aCanvas

	| offset |
"	super drawOn: aCanvas. No longer needed, as I found a way to fix this"
	aCanvas frameOval: (self bounds) width: 1 color: (Color black).
	(target respondsTo: #rotationDegrees:) ifFalse: [^ self].  "nil or background"
	offset _ Point r: (self width / 2) - 2 degrees: target rotationDegrees.
	aCanvas line: self center to: self center + offset width: 3 color: (Color gray: 0.2).

! !


!ScratchRotationSetterMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 16:23'!
click: evt
| p |
	p _ evt cursorPoint - self center.
	p r > 0 ifTrue: [target rotationDegrees: p theta radiansToDegrees rounded].
	self changed.! !

!ScratchRotationSetterMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 16:02'!
doubleClick: evt
	"Set my target to it's normal orientation."

	(target respondsTo: #rotationDegrees:) ifFalse: [^ self].
	target rotationDegrees: 0.
	self changed.! !

!ScratchRotationSetterMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 15:59'!
handlesMouseDown: evt

	^ true
! !

!ScratchRotationSetterMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 16:22'!
mouseDown: evt

	draggingDirection _ false.

	evt hand waitForClicksOrDrag: self event: evt.
! !

!ScratchRotationSetterMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 16:02'!
mouseMove: evt

	| p |
	draggingDirection ifFalse: [^ self].
	(target respondsTo: #rotationDegrees:) ifFalse: [^ self].
	p _ evt cursorPoint - self center.
	p r > 0 ifTrue: [target rotationDegrees: p theta radiansToDegrees rounded].
	self changed.! !

!ScratchRotationSetterMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 16:00'!
startDrag: evt

	draggingDirection _ true.
! !


!ScratchRotationSetterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/17/2015 18:43'!
step

	((target respondsTo: #rotationDegrees) and:
	 [lastRotationDegrees ~= target rotationDegrees]) ifTrue: [
		self changed.  "update the direction marker"
		lastRotationDegrees _ target rotationDegrees].! !

!ScratchRotationSetterMorph methodsFor: 'as yet unclassified' stamp: 'EMP 9/30/2015 16:01'!
stepTime

	^ 100
! !
