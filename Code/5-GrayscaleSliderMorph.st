SimpleSliderMorph subclass: #GrayscaleSliderMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!GrayscaleSliderMorph commentStamp: 'EMP 12/22/2015 13:14' prior: 0!
This class is a quick hack to draw a grayscale slider in morphic!


!GrayscaleSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/18/2015 22:03'!
click: evt

	dragOffset _ (slider extent // 2) negated.
	self mouseMove: evt! !

!GrayscaleSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 14:45'!
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

!GrayscaleSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/21/2015 19:36'!
drawOn: aCanvas

	| maxHeight range |
	range _ 100. "Range. 0-200. Chooses the differences of the grayscale sliders"

	maxHeight _ self height + 200.
	(1 to: self height) do: [:x | aCanvas line: (self left @ (self bottom - x)) to: ((self right - 1) @ (self bottom - x)) color: (Color gray: (((x + range) / maxHeight)))].
! !

!GrayscaleSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/18/2015 22:36'!
extent: aRectangle
	super extent: aRectangle.
	self computeSlider! !

!GrayscaleSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 13:13'!
fullDrawOn: aCanvas

	CornerRounder roundCornersOf: self on: aCanvas
		displayBlock: [super fullDrawOn: aCanvas]
		borderWidth: 0.
	aCanvas fullDrawMorph: slider "Hack to draw the slider in front of me"! !

!GrayscaleSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/18/2015 21:57'!
handlesMouseDown: evt

	^ true
! !

!GrayscaleSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/18/2015 22:00'!
initializeSlider
	slider _ ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #watcherSliderButton).
	self addMorph: (slider extent: (self width @ 3)).
	
! !

!GrayscaleSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/18/2015 21:58'!
mouseDown: evt

	(slider containsPoint: evt cursorPoint) ifTrue: [
		dragOffset _ slider position - evt cursorPoint.
		^ self].

	dragOffset _ nil.
	evt hand waitForClicksOrDrag: self event: evt.
! !

!GrayscaleSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/18/2015 21:58'!
mouseMove: evt

	dragOffset ifNotNil: [self scrollAbsolute: evt].
! !

!GrayscaleSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/18/2015 21:58'!
mouseUp: evt
	"Overidden to do nothing."
! !

!GrayscaleSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/18/2015 21:58'!
startDrag: evt

	dragOffset _ (slider extent // 2) negated.
! !

!GrayscaleSliderMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/22/2015 13:10'!
value
	^ (super value * 20) floor / 20! !
