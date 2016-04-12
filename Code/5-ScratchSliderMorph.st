SimpleSliderMorph subclass: #ScratchSliderMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!ScratchSliderMorph commentStamp: 'EMP 12/22/2015 14:48' prior: 0!
A Slider subclass that is made to look like the Scratch 2.0 sliders!


!ScratchSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 14:47'!
click: evt

	dragOffset _ (slider extent // 2) negated.
	self mouseMove: evt! !

!ScratchSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 14:47'!
computeSlider
	| r |
	r _ self roomToMove.
	self descending
		ifFalse:
			[slider position: (bounds isWide
				ifTrue: [r topLeft + ((r width * value) asInteger @ 0)]
				ifFalse: [r topLeft + (0 @ (r height * value)  asInteger)])]
		ifTrue:
			[slider position: (bounds isWide
				ifTrue:	[r bottomRight - ((r width * value) asInteger @ 0)]
				ifFalse:	[r bottomRight - ((0 @ (r height * value) asInteger))])].
	slider position: (slider position - ((bounds isWide) ifTrue: [(0@4)] ifFalse: [(4@0)])).
	(bounds isWide) ifTrue: [slider extent: (self sliderExtent + (0@10))] ifFalse: [slider extent: (self sliderExtent + (10@0))]! !

!ScratchSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 14:47'!
extent: aRectangle
	super extent: aRectangle.
	self computeSlider! !

!ScratchSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 14:47'!
fullDrawOn: aCanvas

	CornerRounder roundCornersOf: self on: aCanvas
		displayBlock: [super fullDrawOn: aCanvas]
		borderWidth: 0.
	aCanvas fullDrawMorph: slider "Hack to draw the slider in front of me"! !

!ScratchSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 14:47'!
handlesMouseDown: evt

	^ true
! !

!ScratchSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 14:47'!
initializeSlider
	slider _ ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #watcherSliderButton).
	self addMorph: (slider extent: (self width @ 3)).
	
! !

!ScratchSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 14:47'!
mouseDown: evt

	(slider containsPoint: evt cursorPoint) ifTrue: [
		dragOffset _ slider position - evt cursorPoint.
		^ self].

	dragOffset _ nil.
	evt hand waitForClicksOrDrag: self event: evt.
! !

!ScratchSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 14:47'!
mouseMove: evt

	dragOffset ifNotNil: [self scrollAbsolute: evt].
! !

!ScratchSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 14:47'!
mouseUp: evt
	"Overidden to do nothing."
! !

!ScratchSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 14:47'!
startDrag: evt

	dragOffset _ (slider extent // 2) negated.
! !

!ScratchSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 14:47'!
value
	^ (super value * 20) floor / 20! !
