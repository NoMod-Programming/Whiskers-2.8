Morph subclass: #ScratchScrollBar
	instanceVariableNames: 'target selector sliderStart sliderLength frameStartForm frameMiddleForm frameEndForm sliderStartForm sliderMiddleForm sliderEndForm sliderInsets dragOffset '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ScratchScrollBar methodsFor: 'initialization' stamp: 'EMP 11/25/2015 14:20'!
hFrameForm: frameForm sliderForm: sliderForm
	"Initialize myself as a horizontal slider, setting my forms by cutting up the given forms."

	| midX h |
	"set my forms"
	midX _ frameForm height // 2.
	h _ frameForm height.
	frameStartForm _ frameForm copy: (0@0 extent: midX@h).
	frameMiddleForm _ frameForm copy: (midX@0 extent: 1@h).
	frameEndForm _ frameForm copy: ((midX + 1)@0 corner: frameForm extent).

	h _ sliderForm height.
	sliderStartForm _ sliderForm copy: (0@0 extent: 7@h).
	sliderMiddleForm _ sliderForm copy: (7@0 extent: 1@h).
	sliderEndForm _ sliderForm copy: (8@0 corner: sliderForm extent).

	sliderInsets _ 0@0 corner: 1@1.
	self extent: 200 @ frameStartForm height.
! !

!ScratchScrollBar methodsFor: 'initialization' stamp: 'ee 2/11/2009 13:39'!
initVertical: aBoolean

	aBoolean
		ifTrue: [
		 	self vFrameForm: (ScratchFrameMorph skinAt: #vScrollFrame)
				sliderForm: (ScratchFrameMorph skinAt: #vScrollSlider)]
		ifFalse: [
		 	self hFrameForm: (ScratchFrameMorph skinAt: #hScrollFrame)
				sliderForm: (ScratchFrameMorph skinAt: #hScrollSlider)].
! !

!ScratchScrollBar methodsFor: 'initialization' stamp: 'EMP 11/25/2015 16:54'!
initialize

	super initialize.
	target _ nil.
	selector _ nil.
	sliderStart _ 0.
	sliderLength _ 50.
	sliderInsets _ 0@0 corner: 1@1.
	dragOffset _ 0.
! !

!ScratchScrollBar methodsFor: 'initialization' stamp: 'EMP 11/25/2015 14:19'!
vFrameForm: frameForm sliderForm: sliderForm
	"Initialize myself as a vertical slider, setting my forms by cutting up the given forms."

	| midY w |
	"set my forms"
	midY _ frameForm height // 2.
	w _ frameForm width.
	frameStartForm _ frameForm copy: (0@0 extent: w@midY).
	frameMiddleForm _ frameForm copy: (0@midY extent: w@1).
	frameEndForm _ frameForm copy: (0@(midY + 1) corner: frameForm extent).

	w _ sliderForm width.
	sliderStartForm _ sliderForm copy: (0@0 extent: w@7).
	sliderMiddleForm _ sliderForm copy: (0@(7) extent: w@1).
	sliderEndForm _ sliderForm copy: (0@(11) corner: sliderForm extent).

	sliderInsets _ 0@0 corner: 1@1.
	self extent: frameStartForm width @ 200.
! !


!ScratchScrollBar methodsFor: 'accessing' stamp: 'jm 3/14/2005 14:58'!
scrollFraction
	"Answer the scroll fraction, a number between 0.0 and 1.0."

	| maxStart |
	(maxStart _ self maxSliderStart) = 0 ifTrue: [^ 0.0].
	^ sliderStart asFloat / maxStart
! !

!ScratchScrollBar methodsFor: 'accessing' stamp: 'jm 2/23/2005 15:02'!
scrollFraction: aNumber
	"Set my scroll fraction, a number between 0.0 and 1.0."

	sliderStart _ (((aNumber asFloat min: 1.0) max: 0.0) * self maxSliderStart) rounded.
	self changed.
! !

!ScratchScrollBar methodsFor: 'accessing' stamp: 'jm 2/1/2005 14:41'!
selector: aSymbol

	selector _ aSymbol.
! !

!ScratchScrollBar methodsFor: 'accessing' stamp: 'jm 2/1/2005 14:41'!
target: anObject

	target _ anObject.
! !


!ScratchScrollBar methodsFor: 'scroll bar protocol' stamp: 'jm 11/12/2005 13:54'!
percentVisible: percentVisible
	"Supply an optional floating fraction so slider can expand to indicate the percent of the content that is visible."

	sliderLength _ ((percentVisible min: 1.0) * self maxSliderLength) rounded.
	sliderLength _ sliderLength max: self minSliderLength.
	sliderLength = self maxSliderLength ifTrue: [self scrollFraction: 0].
	self changed.
! !

!ScratchScrollBar methodsFor: 'scroll bar protocol' stamp: 'jm 2/1/2005 14:43'!
scrollDelta: ignore1 pageDelta: ignore2
	"For compatability with old scrollbars. I don't support paging or scrolling arrows."
! !

!ScratchScrollBar methodsFor: 'scroll bar protocol' stamp: 'jm 2/23/2005 14:49'!
updateTarget
	"Update my target object with my current value, a number between 0.0 and 1.0. Do nothing if either my target or my selector is nil."

	target notNil & selector notNil
		ifTrue: [target perform: selector with: self scrollFraction].
! !

!ScratchScrollBar methodsFor: 'scroll bar protocol' stamp: 'jm 2/23/2005 15:01'!
value: scrollFraction
	"Set my scroll fraction (range is 0.0 to 1.0). This method is for compatability with ScrollBar."

	self scrollFraction: scrollFraction.
! !


!ScratchScrollBar methodsFor: 'drawing' stamp: 'jm 4/5/2005 21:27'!
drawHEdge: aForm from: startX to: endX yOffset: yOffset on: aCanvas
	"Use the given form starting at the given point to draw a horizontal edge between the given starting and ending x positions. Do nothing if the given form is nil."

	| x y |
	aForm ifNil: [^ self].
	x _ startX.
	y _ bounds top + yOffset.
	[x <= endX] whileTrue: [
		aCanvas translucentImage: aForm at: x@y.
		x _ x + aForm width].
! !

!ScratchScrollBar methodsFor: 'drawing' stamp: 'ee 2/12/2009 16:26'!
drawHSliderOn: aCanvas
	"Draw a horizontal slider on the given canvas."

	| y leftX rightX |
	sliderLength = self maxSliderLength ifTrue: [^ self].
	y _ self top + sliderInsets top.
	leftX _ self left + sliderInsets left + sliderStart.
	rightX _ leftX + sliderLength.
	self drawHEdge: sliderMiddleForm
		from: leftX + sliderStartForm width
		to: (rightX - sliderEndForm width)
		yOffset: sliderInsets top
		on: aCanvas.
	aCanvas translucentImage: sliderStartForm at: (leftX @ y).
	aCanvas translucentImage: sliderEndForm at: ((rightX - sliderEndForm width + 1) @ y).
! !

!ScratchScrollBar methodsFor: 'drawing' stamp: 'jm 5/26/2005 18:48'!
drawOn: aCanvas
	"Draw myself, clipping to my bounds."

	| clipC |
	clipC _ aCanvas copyClipRect: self bounds.

	self bounds isWide
		ifTrue: [
			"draw horizontal frame"
			self drawHEdge: frameMiddleForm
				from: (self left + frameStartForm width)
				to: (self right - frameEndForm width)
				yOffset: 0
				on: clipC.
			clipC translucentImage: frameStartForm at: self topLeft.
			clipC translucentImage: frameEndForm at: ((self right + 1 - frameEndForm width) @ self top).

			self drawHSliderOn: clipC]	
		ifFalse: [
			"draw vertical frame"
			self drawVEdge: frameMiddleForm
				from: (self top + frameStartForm height)
				to: (self bottom - frameEndForm height)
				xOffset: 0
				on: clipC.
			clipC translucentImage: frameStartForm at: self topLeft.
			clipC translucentImage: frameEndForm at: (self left @ (self bottom + 1 - frameEndForm height)).

			self drawVSliderOn: clipC].

! !

!ScratchScrollBar methodsFor: 'drawing' stamp: 'jm 4/5/2005 21:27'!
drawVEdge: aForm from: startY to: endY xOffset: xOffset on: aCanvas
	"Use the given form starting at the given point to draw a vertical edge between the given starting and ending y positions. Do nothing if the given form is nil."

	| x y |
	aForm ifNil: [^ self].
	x _ bounds left + xOffset.
	y _ startY.
	[y <= endY] whileTrue: [
		aCanvas translucentImage: aForm at: x@y.
		y _ y + aForm height].
! !

!ScratchScrollBar methodsFor: 'drawing' stamp: 'ee 2/11/2009 13:38'!
drawVSliderOn: aCanvas
	"Draw a vertical slider on the given canvas."

	| x topY bottomY |
	sliderLength = self maxSliderLength ifTrue: [^ self].
	x _ self left + sliderInsets left.
	topY _ self top + sliderInsets top + sliderStart.
	bottomY _ topY + sliderLength.
	self drawVEdge: sliderMiddleForm
		from: topY + sliderStartForm height
		to: (bottomY - sliderEndForm height)
		xOffset: sliderInsets left
		on: aCanvas.
	aCanvas translucentImage: sliderStartForm at: (x @ topY).
	aCanvas translucentImage: sliderEndForm at: (x @ (bottomY - sliderEndForm height + 1)).
! !


!ScratchScrollBar methodsFor: 'event handling' stamp: 'jm 3/27/2005 10:53'!
handlesMouseDown: evt

	^ true
! !

!ScratchScrollBar methodsFor: 'event handling' stamp: 'jm 2/1/2005 11:20'!
linearOffset: evt
	"Answer the linear position of the given event's cursor point along my slider's range. For example, this will be zero at the leftmost/topmost edge of the slider's range."

	bounds isWide
		ifTrue: [^ evt cursorPoint x - (self left + sliderInsets left)]  "horizontal"
		ifFalse: [^ evt cursorPoint y - (self top + sliderInsets top)].  "vertical"

! !

!ScratchScrollBar methodsFor: 'event handling' stamp: 'jm 3/14/2005 14:54'!
maxSliderLength
	"Answer the maximum slider length."

	bounds isWide
		ifTrue: [^ bounds width - (sliderInsets left + sliderInsets right)]
		ifFalse: [^ bounds height - (sliderInsets top + sliderInsets bottom)].

! !

!ScratchScrollBar methodsFor: 'event handling' stamp: 'jm 3/14/2005 14:56'!
maxSliderStart
	"Answer the maximum sliderStart value given the slider's length."

	bounds isWide
		ifTrue: [^ bounds width - (sliderLength + sliderInsets left + sliderInsets right)]
		ifFalse: [^ bounds height - (sliderLength + sliderInsets top + sliderInsets bottom)].
! !

!ScratchScrollBar methodsFor: 'event handling' stamp: 'ee 2/12/2009 16:26'!
minSliderLength
	"Answer the minimum slider length."

	bounds isWide
		ifTrue: [^ sliderEndForm width + sliderEndForm width]
		ifFalse: [^ sliderEndForm height + sliderEndForm height].
! !

!ScratchScrollBar methodsFor: 'event handling' stamp: 'jm 3/27/2005 11:05'!
mouseDown: evt
	"Record the offset between the slider's start offset and the relative event's location."

	| offset pageDelta |
	dragOffset _ nil.
	self maxSliderLength = sliderLength ifTrue: [^ self].  "do nothing"

	offset _ self linearOffset: evt.
	((offset >= sliderStart) & (offset <= (sliderStart + sliderLength)))
		ifTrue: [  "mouse went down on the slider: start dragging it"
			dragOffset _ sliderStart - offset].

	"handle page up or down"
	pageDelta _ sliderLength / self maxSliderLength.
	offset < sliderStart
		ifTrue: [self scrollFraction: self scrollFraction - pageDelta; updateTarget]
		ifFalse: [self scrollFraction: self scrollFraction + pageDelta; updateTarget]

! !

!ScratchScrollBar methodsFor: 'event handling' stamp: 'jm 3/27/2005 10:32'!
mouseMove: evt
	"Update the slider position if in drag mode."

	dragOffset ifNil: [^ self].  "not in slider drag mode"

	sliderStart _ (self linearOffset: evt) + dragOffset.
	sliderStart _ (sliderStart max: 0) min: (self maxSliderStart).
	self updateTarget.
	self changed.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchScrollBar class
	instanceVariableNames: ''!

!ScratchScrollBar class methodsFor: 'instance creation' stamp: 'jm 5/26/2005 18:17'!
newHorizontal
	"Answer a new horizontal scrollbar."

	^ self new initVertical: false
! !

!ScratchScrollBar class methodsFor: 'instance creation' stamp: 'jm 5/26/2005 18:17'!
newVertical
	"Answer a new vertical scrollbar."

	^ self new initVertical: true
! !
