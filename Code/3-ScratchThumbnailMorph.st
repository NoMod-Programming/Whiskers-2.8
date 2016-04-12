ImageMorph subclass: #ScratchThumbnailMorph
	instanceVariableNames: 'target showDirection lastUpdateMSecs lastRotationDegrees draggingDirection '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!ScratchThumbnailMorph commentStamp: '<historical>' prior: 0!
I show an updating thumbnail picture of my target morph. I allow the direction of my target to be set by dragging.
!


!ScratchThumbnailMorph methodsFor: 'initialization' stamp: 'EMP 9/30/2015 15:19'!
initialize

	super initialize.
	self form: (Form extent: 100@100 depth: 16).
	form fillColor: Color transparent.
	form border: form boundingBox width: 1.
	showDirection _ true.
	lastUpdateMSecs _ -1.
! !


!ScratchThumbnailMorph methodsFor: 'accessing' stamp: 'nb 3/8/2008 13:40'!
extent: aPoint
"Only use squares"
	self form: (Form extent: aPoint depth: 16).
	form fillColor: Color transparent.
	form border: form boundingBox width: 1.
	showDirection _ true.
	lastUpdateMSecs _ -1.! !

!ScratchThumbnailMorph methodsFor: 'accessing' stamp: 'jm 4/27/2007 15:47'!
showDirection: aBoolean

	showDirection _ aBoolean.
! !

!ScratchThumbnailMorph methodsFor: 'accessing' stamp: 'TIS 7/14/2003 14:08'!
target

	^ target
! !

!ScratchThumbnailMorph methodsFor: 'accessing' stamp: 'jm 6/22/2003 22:57'!
target: aMorph

	target _ aMorph.
	self updateThumbnail.
! !


!ScratchThumbnailMorph methodsFor: 'drawing' stamp: 'jm 4/27/2007 15:48'!
drawOn: aCanvas

	| offset |
	super drawOn: aCanvas.
	(target respondsTo: #rotationDegrees:) ifFalse: [^ self].  "nil or background"
	showDirection ifTrue: [
		offset _ Point r: (self width / 2) - 1 degrees: target rotationDegrees.
		aCanvas line: self center to: self center + offset width: 1 color: Color blue].

! !


!ScratchThumbnailMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 16:24'!
doubleClick: evt
	"Set my target to it's normal orientation."

	"(target respondsTo: #rotationDegrees:) ifFalse: [^ self].
	target rotationDegrees: 0.
	self updateThumbnail."
! !

!ScratchThumbnailMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 16:24'!
handlesMouseDown: evt

	^ false
! !

!ScratchThumbnailMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 16:24'!
mouseDown: evt

	"draggingDirection _ false.
	evt shiftPressed ifTrue: [
		target ifNotNil: [target makeVisible].
		^ self].

	evt hand waitForClicksOrDrag: self event: evt."
! !

!ScratchThumbnailMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 16:24'!
mouseMove: evt

	"| p |
	draggingDirection ifFalse: [^ self].
	(target respondsTo: #rotationDegrees:) ifFalse: [^ self].
	p _ evt cursorPoint - self center.
	p r > 0 ifTrue: [target rotationDegrees: p theta radiansToDegrees rounded].
	self updateThumbnail."
! !

!ScratchThumbnailMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 16:24'!
startDrag: evt

	"draggingDirection _ true."
! !


!ScratchThumbnailMorph methodsFor: 'stepping' stamp: 'jm 12/7/2004 19:07'!
step
	"Optimization: Don't update unless the costume has changed."

	| delta |
	((target respondsTo: #rotationDegrees) and:
	 [lastRotationDegrees ~= target rotationDegrees]) ifTrue: [
		self changed.  "update the direction marker"
		lastRotationDegrees _ target rotationDegrees].

	(target notNil and:
	 [lastUpdateMSecs = target costumeChangeMSecs])
		ifTrue: [^ self].

	delta _ Time millisecondClockValue - lastUpdateMSecs.
	(delta < 0) | (delta > 100) ifTrue: [self updateThumbnail].
! !

!ScratchThumbnailMorph methodsFor: 'stepping' stamp: 'jm 12/9/2008 16:49'!
stepTime

	^ 100
! !

!ScratchThumbnailMorph methodsFor: 'stepping' stamp: 'EMP 9/30/2015 15:28'!
updateThumbnail

	| f e r |
	form fillColor: Color transparent.
	target ifNil: [^ self].

	f _ target form.

	((f width <= form width) & (f height <= form height)) ifTrue: [
		"target's image fits without shrinking"
		f displayOn: form at: ((form extent - f extent) // 2).
		^ self changed].

	f width > f height 
		ifTrue: [e _ form width @ ((f height * form width) // f width)]
		ifFalse: [e _ ((f width * form height) // f height) @ form height].
	e _ e max: (8@8).
	r _ Rectangle center: (form extent // 2) extent: e.

	(WarpBlt toForm: form)
		sourceForm: f;
		cellSize: 2;  "do smoothing; this also installs a colormap"
		combinationRule: Form paint;
		copyQuad: f boundingBox innerCorners toRect: (r insetBy: 2).

	lastUpdateMSecs _ target costumeChangeMSecs.
	self changed.
! !
