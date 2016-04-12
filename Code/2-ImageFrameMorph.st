Morph subclass: #ImageFrameMorph
	instanceVariableNames: 'frameInFront topLeftForm topRightForm bottomLeftForm bottomRightForm topEdgeForm leftEdgeForm rightEdgeForm bottomEdgeForm myBox edgeCache '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!ImageFrameMorph commentStamp: '<historical>' prior: 0!
I am draw a rectangular frame using Forms. I have Forms for my four corners and form Forms that are used to tile my edges so that I can be resized.
!


!ImageFrameMorph methodsFor: 'intialization' stamp: 'jm 5/14/2005 16:04'!
initFromForm: aForm
	"Initialize myself by cutting up the given Form. The corners are taken to extend to one pixel short of the center in each dimension. A one-pixel strip from the center of each edge will be replicated to stretch the edge. The color of the center pixel of the rectangle will be used as the fill color. (You can suppress color filling by setting my color to transparent after calling this method)."

	| cornerExtent center |
	cornerExtent _ (aForm extent - 1) // 2.
	center _ aForm extent // 2.

	topLeftForm _ (aForm copy: (0@0 extent: cornerExtent)).
	topRightForm _ (aForm copy: ((aForm width - cornerExtent x) @ 0 extent: cornerExtent)).
	bottomLeftForm _ (aForm copy: (0 @ (aForm height - cornerExtent y) extent: cornerExtent)).
	bottomRightForm _ (aForm copy: ((aForm extent - cornerExtent) extent: cornerExtent)).

	topEdgeForm _ (aForm copy: ((center x@0) extent: (1 @ cornerExtent y))).
	leftEdgeForm _ (aForm copy: ((0 @ center y) extent: (cornerExtent x @ 1))).
	rightEdgeForm _ (aForm copy: (((aForm width - cornerExtent x) @ center y) extent: (cornerExtent x @ 1))).
	bottomEdgeForm _ (aForm copy: ((center x@(aForm height - cornerExtent y)) extent: (1 @ cornerExtent y))).

	color _ aForm colorAt: center.
! !

!ImageFrameMorph methodsFor: 'intialization' stamp: 'jm 10/25/2008 16:20'!
initFrontFromForm: aForm
	"Initialize myself so that my frame is drawn in front of my submorphs, like a picture frame."

	| c f |
	frameInFront _ true.

	c _ (aForm colorAt: aForm extent // 2).
	f _ aForm deepCopy.
	f shapeFill: Color transparent interiorPoint: aForm extent // 2.
	self initFromForm: f.
	color _ c.

! !

!ImageFrameMorph methodsFor: 'intialization' stamp: 'jm 12/9/2008 12:26'!
initialize

	super initialize.
	color _ Color transparent.
	frameInFront _ false.
	edgeCache _ Array new: 5.
	self extent: 100@100.
! !


!ImageFrameMorph methodsFor: 'accessing' stamp: 'jm 2/7/2008 08:54'!
minExtent
	"Answer my minimum extent."

	^ (topLeftForm width + topEdgeForm width + topRightForm width) @
	  (topLeftForm height + leftEdgeForm height + bottomLeftForm height)! !


!ImageFrameMorph methodsFor: 'drawing' stamp: 'jm 10/26/2008 17:38'!
areasRemainingToFill: aRectangle
	"Drawing optimization. Since I completely fill my bounds with opaque pixels, this method tells Morphic that it isn't necessary to draw any morphs covered by me."
	
	^ aRectangle areasOutside: self bounds
! !

!ImageFrameMorph methodsFor: 'drawing' stamp: 'jm 10/26/2008 10:54'!
drawBackgroundOn: aCanvas
	"Draw my background."

	color isTransparent ifTrue: [^ self].

	aCanvas
		fillRectangle: ((myBox origin + topLeftForm extent) corner: (myBox corner - bottomRightForm extent))
		color: color.
! !

!ImageFrameMorph methodsFor: 'drawing' stamp: 'jm 10/25/2008 23:58'!
drawBottomEdgeOn: aCanvas
	"Draw my bottom edge."

	| r f |
	r _ ((myBox left + topLeftForm width) @ (myBox bottom - bottomEdgeForm height)) corner: ((myBox right - bottomRightForm width) @ myBox bottom).
	(r intersects: aCanvas clipRect) ifFalse: [^ self].

	f _ edgeCache at: 3.
	(f isNil or: [f extent ~= r extent]) ifTrue: [
		f _ Form extent: r extent depth: 32.
		0 to: r width by: bottomEdgeForm width do: [:x | bottomEdgeForm displayOn: f at: x@0 rule: Form over].
		edgeCache at: 3 put: f].

	aCanvas translucentImage: f at: r topLeft.
! !

!ImageFrameMorph methodsFor: 'drawing' stamp: 'EMP 12/4/2015 11:53'!
drawCornersOn: aCanvas
	"Draw my corners if they intersect the canvas clipping box."

	| clipR p |
	clipR _ aCanvas clipRect.

	p _ (myBox right - topRightForm width)@myBox top.
	((p extent: topRightForm extent) intersects: clipR) ifTrue: [
		aCanvas translucentImage: topRightForm at: p].

	p _ myBox topLeft.
	((p extent: topLeftForm extent) intersects: clipR) ifTrue: [
		aCanvas translucentImage: topLeftForm at: p].


	p _ (myBox right - bottomRightForm width)@(myBox bottom - bottomRightForm height).
	((p extent: bottomRightForm extent) intersects: clipR) ifTrue: [
		aCanvas translucentImage: bottomRightForm at: p].

		p _ myBox left@(myBox bottom - bottomLeftForm height).
	((p extent: bottomLeftForm extent) intersects: clipR) ifTrue: [
		aCanvas translucentImage: bottomLeftForm at: p].
! !

!ImageFrameMorph methodsFor: 'drawing' stamp: 'EMP 12/4/2015 11:53'!
drawFrameOn: aCanvas
	"Draw my edges and corners. Draw a simple border if any of my forms is nil."

	(topLeftForm isNil | topRightForm isNil | bottomLeftForm isNil | bottomRightForm isNil |
	 topEdgeForm isNil | leftEdgeForm isNil | rightEdgeForm isNil | bottomEdgeForm isNil)
		ifTrue: [^ aCanvas frameRectangle: self bounds width: 3 color: Color red].

	"draw edges"
	self drawTopEdgeOn: aCanvas.
	self drawRightEdgeOn: aCanvas.
	self drawLeftEdgeOn: aCanvas.
	self drawBottomEdgeOn: aCanvas.

	self drawCornersOn: aCanvas.

! !

!ImageFrameMorph methodsFor: 'drawing' stamp: 'jm 10/25/2008 23:55'!
drawLeftEdgeOn: aCanvas
	"Draw my left edge."

	| r f |
	r _ (myBox left @ (myBox top + topLeftForm height)) corner: ((myBox left + leftEdgeForm width) @ (myBox bottom - bottomLeftForm height)).
	(r intersects: aCanvas clipRect) ifFalse: [^ self].

	f _ edgeCache at: 1.
	(f isNil or: [f extent ~= r extent]) ifTrue: [
		f _ Form extent: r extent depth: 32.
		0 to: r height by: leftEdgeForm height do: [:y | leftEdgeForm displayOn: f at: 0@y rule: Form over].
		edgeCache at: 1 put: f].

	aCanvas translucentImage: f at: r topLeft.
! !

!ImageFrameMorph methodsFor: 'drawing' stamp: 'EMP 12/9/2015 12:06'!
drawOn: aCanvas
	"Draw my background."

	"myBox has integer position and extent and has a potentially inset bottom"
	myBox _ bounds origin truncated corner: (bounds right@self insetBottom) truncated.

	self drawBackgroundOn: aCanvas.

	frameInFront ifFalse: [self drawFrameOn: aCanvas].
! !

!ImageFrameMorph methodsFor: 'drawing' stamp: 'jm 10/25/2008 23:54'!
drawRightEdgeOn: aCanvas
	"Draw my right edge."

	| r f |
	r _ ((myBox right - rightEdgeForm width) @ (myBox top + topRightForm height)) corner: (myBox right @ (myBox bottom - bottomRightForm height)).
	(r intersects: aCanvas clipRect) ifFalse: [^ self].

	f _ edgeCache at: 4.
	(f isNil or: [f extent ~= r extent]) ifTrue: [
		f _ Form extent: r extent depth: 32.
		0 to: r height by: rightEdgeForm height do: [:y | rightEdgeForm displayOn: f at: 0@y rule: Form over].
		edgeCache at: 4 put: f].

	aCanvas translucentImage: f at: r topLeft.

! !

!ImageFrameMorph methodsFor: 'drawing' stamp: 'jm 10/25/2008 23:57'!
drawTopEdgeOn: aCanvas
	"Draw my top edge."

	| r f |
	r _ ((myBox left + topLeftForm width) @ myBox top) corner: ((myBox right - topRightForm width) @ (myBox top + topEdgeForm height)).
	(r intersects: aCanvas clipRect) ifFalse: [^ self].

	f _ edgeCache at: 2.
	(f isNil or: [f extent ~= r extent]) ifTrue: [
		f _ Form extent: r extent depth: 32.
		0 to: r width by: topEdgeForm width do: [:x | topEdgeForm displayOn: f at: x@0 rule: Form over].
		edgeCache at: 2 put: f].

	aCanvas translucentImage: f at: r topLeft.
! !

!ImageFrameMorph methodsFor: 'drawing' stamp: 'jm 12/8/2008 13:52'!
fullDrawOn: aCanvas
	"Draw my frame in front of my submorphs."

	| clipC |
	self isHidden ifTrue: [^ self].
	(self hasProperty: #errorOnDraw) ifTrue:[^ self drawErrorOn: aCanvas].
	(aCanvas isVisible: self fullBounds) ifFalse: [^ self].

	"myBox has integer position and extent and has a potentially inset bottom"
	myBox _ bounds truncated.
	clipC _ aCanvas copyClipRect: myBox.

	frameInFront
		ifTrue: [
			self drawOn: clipC.
			self drawSubmorphsOn: clipC.
			self drawFrameOn: clipC]
		ifFalse: [
			self drawOn: clipC.
			self drawSubmorphsOn: clipC].
! !

!ImageFrameMorph methodsFor: 'drawing' stamp: 'jm 5/14/2005 19:32'!
hasTranslucentColor

	^ true
! !

!ImageFrameMorph methodsFor: 'drawing' stamp: 'jm 11/29/2006 16:30'!
insetBottom

	^ self bottom
! !
