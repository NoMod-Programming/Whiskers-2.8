SimpleSliderMorph subclass: #ScratchSliderNotifyingMorph
	instanceVariableNames: 'notif notifAction '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ScratchSliderNotifyingMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/11/2016 14:32'!
click: evt

	dragOffset _ (slider extent // 2) negated.
	self mouseMove: evt! !

!ScratchSliderNotifyingMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/11/2016 14:32'!
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

!ScratchSliderNotifyingMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/11/2016 14:32'!
extent: aRectangle
	super extent: aRectangle.
	self computeSlider! !

!ScratchSliderNotifyingMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/11/2016 14:32'!
fullDrawOn: aCanvas

	CornerRounder roundCornersOf: self on: aCanvas
		displayBlock: [super fullDrawOn: aCanvas]
		borderWidth: 0.
	aCanvas fullDrawMorph: slider "Hack to draw the slider in front of me"! !

!ScratchSliderNotifyingMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/11/2016 14:32'!
handlesMouseDown: evt

	^ true
! !

!ScratchSliderNotifyingMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/11/2016 14:32'!
initializeSlider
	slider _ ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #watcherSliderButton).
	self addMorph: (slider extent: (self width @ 3)).
	
! !

!ScratchSliderNotifyingMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/11/2016 14:32'!
mouseDown: evt

	(slider containsPoint: evt cursorPoint) ifTrue: [
		dragOffset _ slider position - evt cursorPoint.
		^ self].

	dragOffset _ nil.
	evt hand waitForClicksOrDrag: self event: evt.
! !

!ScratchSliderNotifyingMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/11/2016 14:32'!
mouseMove: evt

	dragOffset ifNotNil: [self scrollAbsolute: evt].
! !

!ScratchSliderNotifyingMorph methodsFor: 'as yet unclassified' stamp: 'EMP 3/23/2016 14:22'!
mouseUp: evt
	
	notif ifNotNil: [notifAction ifNotNil: [notif perform: notifAction withArguments: {(self value max: 1/32) * maxVal}]].! !

!ScratchSliderNotifyingMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/11/2016 14:34'!
notif: aMorph
	notif _ aMorph! !

!ScratchSliderNotifyingMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/11/2016 14:34'!
notifAction: anAction
	notifAction _ anAction! !

!ScratchSliderNotifyingMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/11/2016 14:32'!
startDrag: evt

	dragOffset _ (slider extent // 2) negated.
! !

!ScratchSliderNotifyingMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/11/2016 14:32'!
value
	^ (super value * 20) floor / 20! !
