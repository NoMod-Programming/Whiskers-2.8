Canvas subclass: #FormCanvas
	instanceVariableNames: 'origin clipRect form port shadowColor '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Support'!
!FormCanvas commentStamp: 'jm 6/15/2003 11:07' prior: 0!
I'm a subclass of Canvas for drawing on Forms.

Note that when shadowDrawing is true, shadowStipple may be either a color, for a solid shadow of the given color, or it may be a stipple used to simulate gray shading when the display cannot support alpha blending.
!


!FormCanvas methodsFor: 'initialize-release' stamp: 'ar 2/17/2000 00:21'!
reset

	origin _ 0@0.							"origin of the top-left corner of this cavas"
	clipRect _ (0@0 corner: 10000@10000).		"default clipping rectangle"
	self shadowColor: nil.! !


!FormCanvas methodsFor: 'accessing' stamp: 'ar 5/28/2000 17:11'!
allocateForm: extentPoint
	"Allocate a new form which is similar to the receiver"
	^form allocateForm: extentPoint! !

!FormCanvas methodsFor: 'accessing' stamp: 'ar 6/22/1999 14:06'!
clipRect
	"Return the currently active clipping rectangle"
	^ clipRect translateBy: origin negated! !

!FormCanvas methodsFor: 'accessing' stamp: 'jm 6/15/2003 19:08'!
contentsOfArea: aRectangle into: aForm

	port destForm 
		displayOn: aForm 
		at: (aRectangle origin + origin) negated
		clippingBox: (0@0 extent: aRectangle extent).
	^ aForm
! !

!FormCanvas methodsFor: 'accessing'!
depth

	^ form depth
! !

!FormCanvas methodsFor: 'accessing'!
extent

	^ form extent! !

!FormCanvas methodsFor: 'accessing'!
form

	^ form! !

!FormCanvas methodsFor: 'accessing' stamp: 'ee 1/25/2005 15:43'!
grafPort

	^ port
! !

!FormCanvas methodsFor: 'accessing' stamp: 'ar 6/22/1999 14:10'!
origin
	"Return the current origin for drawing operations"
	^ origin! !

!FormCanvas methodsFor: 'accessing' stamp: 'jm 11/24/2002 11:16'!
shadowColor

	^ shadowColor
! !

!FormCanvas methodsFor: 'accessing' stamp: 'ar 2/17/2000 00:26'!
shadowColor: aColor
	shadowColor _ aColor! !


!FormCanvas methodsFor: 'testing' stamp: 'ar 2/17/2000 00:24'!
isShadowDrawing
	^ self shadowColor notNil! !

!FormCanvas methodsFor: 'testing' stamp: 'ar 6/22/1999 14:08'!
isVisible: aRectangle
	"Optimization"
	(aRectangle right + origin x) < clipRect left	ifTrue: [^ false].
	(aRectangle left + origin x) > clipRect right	ifTrue: [^ false].
	(aRectangle bottom + origin y) < clipRect top	ifTrue: [^ false].
	(aRectangle top + origin y) > clipRect bottom	ifTrue: [^ false].
	^ true
! !


!FormCanvas methodsFor: 'converting' stamp: 'jm 1/6/2003 12:25'!
asShadowDrawingCanvas: aColor
	"Answer a copy of me for drawing drop-shadows."

	^ self copy shadowColor: aColor
! !


!FormCanvas methodsFor: 'transforms' stamp: 'ar 5/25/2000 18:04'!
transformBy: aDisplayTransform clippingTo: aClipRect during: aBlock	 smoothing: cellSize

	"Note: This method has been originally copied from TransformationMorph."
	| innerRect patchRect sourceQuad warp start subCanvas |
	(aDisplayTransform isPureTranslation) ifTrue:[
		^aBlock value: (self copyOffset: aDisplayTransform offset negated truncated
							clipRect: aClipRect)
	].
	"Prepare an appropriate warp from patch to innerRect"
	innerRect _ aClipRect.
	patchRect _ aDisplayTransform globalBoundsToLocal: innerRect.
	sourceQuad _ (aDisplayTransform sourceQuadFor: innerRect)
					collect: [:p | p - patchRect topLeft].
	warp _ self warpFrom: sourceQuad toRect: innerRect.
	warp cellSize: cellSize.

	"Render the submorphs visible in the clipping rectangle, as patchForm"
	start _ (self depth = 1 and: [self isShadowDrawing not])
		"If this is true B&W, then we need a first pass for erasure."
		ifTrue: [1] ifFalse: [2].
	start to: 2 do:
		[:i | "If i=1 we first make a shadow and erase it for opaque whites in B&W"
		subCanvas _ self class extent: patchRect extent depth: self depth.
		i=1	ifTrue: [subCanvas shadowColor: Color black.
					warp combinationRule: Form erase]
			ifFalse: [self isShadowDrawing ifTrue:
					[subCanvas shadowColor: self shadowColor].
					warp combinationRule: Form paint].
		subCanvas translateBy: patchRect topLeft negated
			during:[:offsetCanvas| aBlock value: offsetCanvas].
		warp sourceForm: subCanvas form; warpBits.
		warp sourceForm: nil.  subCanvas _ nil "release space for next loop"]
! !

!FormCanvas methodsFor: 'transforms' stamp: 'ar 6/17/1999 03:03'!
translateBy: delta clippingTo: aRectangle during: aBlock
	"Set a translation and clipping rectangle only during the execution of aBlock."
	^aBlock value: (self copyOffset: delta clipRect: aRectangle)! !

!FormCanvas methodsFor: 'transforms' stamp: 'ar 6/17/1999 03:02'!
translateBy: delta during: aBlock
	"Set a translation only during the execution of aBlock."
	^aBlock value: (self copyOffset: delta)! !

!FormCanvas methodsFor: 'transforms' stamp: 'ar 6/17/1999 02:55'!
translateTo: newOrigin clippingTo: aRectangle during: aBlock
	"Set a new origin and clipping rectangle only during the execution of aBlock."
	aBlock value: (self copyOrigin: newOrigin clipRect: aRectangle)! !


!FormCanvas methodsFor: 'copying' stamp: 'jm 8/2/97 14:00'!
copy
	"Make a copy the receiver on the same underlying Form but with its own grafPort."

	^ self clone resetGrafPort
! !

!FormCanvas methodsFor: 'copying' stamp: 'ar 6/17/1999 02:51'!
copyClipRect: aRectangle
	^ self copyOrigin: origin clipRect: (aRectangle translateBy: origin)
! !

!FormCanvas methodsFor: 'copying' stamp: 'ar 6/17/1999 02:52'!
copyOffset: aPoint
	^ self copyOrigin: origin + aPoint clipRect: clipRect! !

!FormCanvas methodsFor: 'copying' stamp: 'ar 6/17/1999 02:52'!
copyOffset: aPoint clipRect: sourceClip
	"Make a copy of me offset by aPoint, and further clipped
	by sourceClip, a rectangle in the un-offset coordinates"
	^ self copyOrigin: aPoint + origin
		clipRect: ((sourceClip translateBy: origin) intersect: clipRect)! !

!FormCanvas methodsFor: 'copying' stamp: 'ar 6/17/1999 02:52'!
copyOrigin: aPoint clipRect: aRectangle
	"Return a copy of this canvas with the given origin. The clipping rectangle of this canvas is the intersection of the given rectangle and the receiver's current clipping rectangle. This allows the clipping rectangles of nested clipping morphs to be composed."
	^ self copy
		setOrigin: aPoint
		clipRect: (clipRect intersect: aRectangle)! !


!FormCanvas methodsFor: 'drawing' stamp: 'ar 5/14/2000 15:50'!
fillColor: c
	"Note: This always fills, even if the color is transparent."
	self setClearColor: c.
	port fillRect: form boundingBox offset: origin.! !

!FormCanvas methodsFor: 'drawing' stamp: 'ar 2/17/2000 00:12'!
line: pt1 to: pt2 brushForm: brush
	| offset |
	offset _ origin.
	self setPaintColor: Color black.
	port sourceForm: brush; fillColor: nil;
		sourceRect: brush boundingBox;
		colorMap: (brush colormapIfNeededForDepth: self depth);
		drawFrom: (pt1 + offset) to: (pt2 + offset)! !

!FormCanvas methodsFor: 'drawing' stamp: 'ar 2/16/2000 22:07'!
line: pt1 to: pt2 width: w color: c
	| offset |
	offset _ origin - (w // 2) asPoint.
	self setFillColor: c.
	port width: w; height: w;
		drawFrom: (pt1 + offset) to: (pt2 + offset)! !

!FormCanvas methodsFor: 'drawing' stamp: 'jm 11/25/2002 12:39'!
paragraph: para bounds: bounds color: c

	| clipR scanner |
	self setPaintColor: c.
	clipR _ bounds translateBy: origin.
	scanner _ (port clippedBy: clipR) displayScannerFor: para
		foreground: (self shadowColor ifNil:[c]) background: Color transparent
		ignoreColorChanges: self shadowColor notNil.
	para displayOn: (self copyClipRect: bounds) using: scanner at: clipR topLeft.
! !

!FormCanvas methodsFor: 'drawing' stamp: 'jm 9/16/2005 11:00'!
strings: stringList lineHeight: lineHeight bounds: boundsRect font: fontOrNil color: c

	| scanner x y |
	scanner _ DisplayScanner
		quickPrintOn: form
		box: ((boundsRect translateBy: origin) intersect: clipRect) truncated
		font: fontOrNil
		color: (self shadowColor ifNil: [c]).

	x _ origin x + boundsRect left.
	y _ origin y + boundsRect top.
	stringList do: [:s |
		scanner drawString: s at: x@y.
		y _ y + lineHeight].
! !

!FormCanvas methodsFor: 'drawing' stamp: 'jm 3/30/2005 06:53'!
text: s bounds: boundsRect font: fontOrNil kern: kern color: c

	| scanner |
	scanner _
		DisplayScanner quickPrintOn: form
			box: ((boundsRect translateBy: origin) intersect: clipRect) truncated
			font: fontOrNil
			color: (self shadowColor ifNil: [c]).
	scanner addKern: kern.
	scanner drawString: s at: boundsRect topLeft + origin.
! !


!FormCanvas methodsFor: 'drawing-rectangles' stamp: 'ar 5/14/2000 15:50'!
frameAndFillRectangle: r fillColor: fillColor borderWidth: borderWidth borderColor: borderColor
	| rect |
	rect _ r translateBy: origin.
	"draw the border of the rectangle"
	borderColor isTransparent ifFalse:[
		self setFillColor: borderColor.
		(r area > 10000 or: [fillColor isTranslucent]) ifTrue: [
			port frameRect: rect borderWidth: borderWidth.
		] ifFalse: ["for small rectangles, it's faster to fill the entire outer rectangle
					than to compute and fill the border rects"
					port fillRect: rect offset: origin]].

	"fill the inside"
	fillColor isTransparent ifFalse:
		[self setFillColor: fillColor.
		port fillRect: (rect insetBy: borderWidth) offset: origin].! !

!FormCanvas methodsFor: 'drawing-rectangles' stamp: 'ar 2/16/2000 22:07'!
frameAndFillRectangle: r fillColor: fillColor borderWidth: borderWidth topLeftColor: topLeftColor bottomRightColor: bottomRightColor

	| w h rect |
	"First use quick code for top and left borders and fill"
	self frameAndFillRectangle: r
		fillColor: fillColor
		borderWidth: borderWidth
		borderColor: topLeftColor.

	"Now use slow code for bevelled bottom and right borders"
	bottomRightColor isTransparent ifFalse: [
		borderWidth isNumber
			ifTrue: [w _ h _ borderWidth]
			ifFalse: [w _ borderWidth x.   h _ borderWidth y].
		rect _ r translateBy: origin.
		self setFillColor: bottomRightColor.
		port 
			 frameRectRight: rect width: w;
			 frameRectBottom: rect height: h].
! !


!FormCanvas methodsFor: 'drawing-ovals' stamp: 'EMP 1/7/2016 19:44'!
fillAntialiasedOval: r color: fillColor borderWidth: borderWidth borderColor: borderColor

	| rect |
	"draw the border of the oval"
	rect _ r translateBy: origin.
	borderColor isTransparent ifFalse:[
		self setFillColor: borderColor.
		(r area > 10000 or: [fillColor isTranslucent]) 
			ifTrue: [port frameOval: rect borderWidth: borderWidth]
			ifFalse: [port fillAntialiasedOval: rect]]. "faster this way"

	"fill the inside"
	fillColor isTransparent ifFalse: [
		self setFillColor: fillColor.
		port fillAntialiasedOval: (rect insetBy: borderWidth)].
! !

!FormCanvas methodsFor: 'drawing-ovals' stamp: 'jm 11/29/2002 09:29'!
fillOval: r color: fillColor borderWidth: borderWidth borderColor: borderColor

	| rect |
	"draw the border of the oval"
	rect _ r translateBy: origin.
	borderColor isTransparent ifFalse:[
		self setFillColor: borderColor.
		(r area > 10000 or: [fillColor isTranslucent]) 
			ifTrue: [port frameOval: rect borderWidth: borderWidth]
			ifFalse: [port fillOval: rect]]. "faster this way"

	"fill the inside"
	fillColor isTransparent ifFalse: [
		self setFillColor: fillColor.
		port fillOval: (rect insetBy: borderWidth)].
! !


!FormCanvas methodsFor: 'drawing-images' stamp: 'jm 10/7/2002 05:27'!
image: aForm at: aPoint sourceRect: sourceRect rule: rule 
	"Draw the portion of the given Form defined by sourceRect at the given point using the given BitBlt combination rule."

	port colorMap: (aForm colormapIfNeededForDepth: form depth); fillColor: nil.
	port image: aForm at: aPoint + origin sourceRect: sourceRect rule: rule.
! !

!FormCanvas methodsFor: 'drawing-images' stamp: 'jm 3/18/2003 11:22'!
image: aForm at: aPoint sourceRect: sourceRect rule: rule alpha: alpha
	"Draw the portion of the given Form defined by sourceRect at the given point using the given BitBlt combination rule."

	port colorMap: (aForm colormapIfNeededForDepth: form depth); fillColor: nil.
	port image: aForm at: aPoint + origin sourceRect: sourceRect rule: rule alpha: alpha.
! !

!FormCanvas methodsFor: 'drawing-images' stamp: 'jm 10/7/2002 05:20'!
stencil: stencilForm at: aPoint sourceRect: sourceRect color: aColor
	"Flood this canvas with aColor wherever stencilForm has non-zero pixels"

	self setPaintColor: aColor.
	port colorMap: (Color maskingMap: stencilForm depth).
	port stencil: stencilForm
		at: aPoint + origin
		sourceRect: sourceRect.
! !


!FormCanvas methodsFor: 'other' stamp: 'ar 5/28/2000 17:07'!
printOn: aStream
	super printOn: aStream.
	aStream nextPutAll:' on: '; print: form.! !

!FormCanvas methodsFor: 'other'!
showAt: pt

	^ form displayAt: pt! !

!FormCanvas methodsFor: 'other' stamp: 'jm 5/29/2003 18:01'!
showAt: pt invalidRects: updateRects

	| blt |
	blt _ (BitBlt toForm: Display)
		sourceForm: form;
		combinationRule: Form over.
	updateRects do: [:rect |
		blt sourceRect: rect;
			destOrigin: rect topLeft + pt;
			copyBits]! !

!FormCanvas methodsFor: 'other' stamp: 'jm 5/29/2003 18:01'!
warpFrom: sourceQuad toRect: destRect

	^ (WarpBlt toForm: port destForm)
		combinationRule: Form paint;
		sourceQuad: sourceQuad destRect: (destRect translateBy: origin);
		clipRect: clipRect
! !


!FormCanvas methodsFor: 'private' stamp: 'jm 11/12/2002 13:08'!
resetGrafPort
	"Private!! Create a new grafPort for a new copy."

	port _ GrafPort toForm: form.
	port clipRect: clipRect.
! !

!FormCanvas methodsFor: 'private' stamp: 'jm 10/7/2002 05:27'!
setClearColor: aColor
	"Install a new clear color - e.g., a color is used for clearing the background"

	| clearColor |
	clearColor _ aColor ifNil: [Color transparent].
	clearColor isColor ifFalse: [
		(clearColor isKindOf: InfiniteForm) ifFalse: [^ self error:'Cannot install color'].
		port fillPattern: clearColor; combinationRule: Form over.
		^ self].

	"clearColor really *is* a color"
	port sourceForm: nil.
	port combinationRule: Form over.
	port fillPattern: clearColor.
	self depth = 8 ifTrue: [
		"use a stipple pattern"
		port fillColor: (clearColor balancedPatternForDepth: 8)].
! !

!FormCanvas methodsFor: 'private' stamp: 'jm 11/24/2002 11:36'!
setFillColor: aColor
	"Install a new color used for filling."

	| screen patternWord fillColor |
	fillColor _ self shadowColor ifNil: [aColor].
	fillColor ifNil: [fillColor _ Color transparent].
	fillColor isColor ifFalse: [
		(fillColor isKindOf: InfiniteForm) ifFalse: [^ self error:'Cannot use an InfiniteForm here'].
		port fillPattern: fillColor; combinationRule: Form over.  "use a stipple pattern"
		^ self].

	"fillColor really *is* a color"
	port sourceForm: nil.
	fillColor isTranslucent ifFalse: [
		port combinationRule: Form over.
		port fillPattern: fillColor.
		self depth = 8 ifTrue: [
			"In 8 bit depth it's usually a good idea to use a stipple pattern"
			port fillColor: (fillColor balancedPatternForDepth: 8)].
		^ self].

	"fillColor is a translucent color"
	self depth > 8 ifTrue: [
		"BitBlt setup for alpha masked transfer"
		port fillPattern: fillColor.
		self depth = 16
			ifTrue: [port alphaBits: fillColor privateAlpha; combinationRule: 30]
			ifFalse: [port combinationRule: Form blend].
		^ self].

	"Can't represent actual transparency -- use stipple pattern"
	screen _ Color translucentMaskFor: fillColor alpha depth: self depth.
	patternWord _ fillColor pixelWordForDepth: self depth.
	port fillPattern: (screen collect: [:maskWord | maskWord bitAnd: patternWord]).
	port combinationRule: Form paint.
! !

!FormCanvas methodsFor: 'private' stamp: 'jm 11/12/2002 13:08'!
setForm: aForm

	self reset.
	form _ aForm.
	port _ GrafPort toForm: form.
! !

!FormCanvas methodsFor: 'private' stamp: 'ar 6/22/1999 14:06'!
setOrigin: aPoint clipRect: aRectangle

	origin _ aPoint.
	clipRect _ aRectangle.
	port clipRect: aRectangle.
! !

!FormCanvas methodsFor: 'private' stamp: 'jm 10/7/2002 05:23'!
setPaintColor: aColor
	"Install a new color used for filling."

	| paintColor screen patternWord |
	paintColor _ self shadowColor ifNil: [aColor].
	paintColor ifNil: [paintColor _ Color transparent].
	paintColor isColor ifFalse:[
		(paintColor isKindOf: InfiniteForm) ifFalse:[^ self error:'Cannot install color'].
		port fillPattern: paintColor; combinationRule: Form paint.
		^ self].

	"Okay, so paintColor really *is* a color"
	port sourceForm: nil.
	(paintColor isTranslucent) ifFalse: [
		port fillPattern: paintColor.
		port combinationRule: Form paint.
		self depth = 8 ifTrue: [
			port fillColor: (paintColor balancedPatternForDepth: 8)].
		^ self].

	"paintColor is a translucent color"
	self depth > 8 ifTrue: [
		"BitBlt setup for alpha mapped transfer"
		port fillPattern: paintColor.
		self depth = 16
			ifTrue: [port alphaBits: paintColor privateAlpha; combinationRule: 31]
			ifFalse: [port combinationRule: Form blend].
		^ self].

	"Can't represent actual transparency -- use stipple pattern"
	screen _ Color translucentMaskFor: paintColor alpha depth: self depth.
	patternWord _ paintColor pixelWordForDepth: self depth.
	port fillPattern: (screen collect: [:maskWord | maskWord bitAnd: patternWord]).
	port combinationRule: Form paint
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

FormCanvas class
	instanceVariableNames: ''!

!FormCanvas class methodsFor: 'instance creation'!
extent: aPoint

	^ self extent: aPoint depth: Display depth
! !

!FormCanvas class methodsFor: 'instance creation'!
extent: extent depth: depth

	^ self new setForm: (Form extent: extent depth: depth)! !

!FormCanvas class methodsFor: 'instance creation' stamp: 'jm 8/2/97 13:54'!
on: aForm

	^ self new setForm: aForm
! !


!FormCanvas class methodsFor: 'testing' stamp: 'jm 11/12/2002 12:23'!
test1
	"FormCanvas test1"

	| canvas |
	canvas _ FormCanvas extent: 200@200.
	canvas fillColor: (Color black).
	canvas line: 10@10 to: 50@30 width: 1 color: (Color red).
	canvas frameRectangle: ((20@20) corner: (120@120)) width: 4 color: (Color green).
	canvas text: 'Hello, World!!' at: 40@40 font: nil color: (Color cyan).
	canvas fillRectangle: ((10@80) corner: (31@121)) color: (Color magenta).
	canvas fillOval: ((10@80) corner: (31@121)) color: (Color cyan).
	canvas frameOval: ((40@80) corner: (61@121)) color: (Color blue).
	canvas frameOval: ((70@80) corner: (91@121)) width: 3 color: (Color red alpha: 0.2).
	canvas fillRectangle: ((130@30) corner: (170@80)) color: (Color lightYellow).
	canvas showAt: 0@0.
! !

!FormCanvas class methodsFor: 'testing' stamp: 'jm 11/12/2002 12:23'!
test2
	"FormCanvas test2"

	| baseCanvas p |
	baseCanvas _ FormCanvas extent: 200@200.
	p _ Sensor cursorPoint.
	[Sensor anyButtonPressed] whileFalse: [
		baseCanvas translateBy: (Sensor cursorPoint - p) during:[:canvas|
			canvas fillColor: Color white.
			canvas line: 10@10 to: 50@30 width: 1 color: Color red.
			canvas frameRectangle: ((20@20) corner: (120@120)) width: 4 color: Color green.
			canvas text: 'Hello, World!!' at: 40@40 font: nil color: Color cyan.
			canvas fillRectangle: ((10@80) corner: (31@121)) color: Color magenta.
			canvas fillOval: ((10@80) corner: (31@121)) color: Color cyan.
			canvas frameOval: ((40@80) corner: (61@121)) color: Color blue.
			canvas frameOval: ((70@80) corner: (91@121)) width: 3 color: Color red.
			canvas fillRectangle: ((130@30) corner: (170@80)) color: Color lightYellow.
			canvas showAt: 0@0]].
! !

!FormCanvas class methodsFor: 'testing' stamp: 'jm 11/12/2002 12:23'!
test3
	"FormCanvas test3"

	| baseCanvas |
	baseCanvas _ FormCanvas extent: 200@200.
	baseCanvas fillColor: Color white.
	baseCanvas translateBy: 10@10 during:[:canvas|
		canvas shadowColor: (Color black alpha: 0.5).
		canvas line: 10@10 to: 50@30 width: 1 color: Color red.
		canvas frameRectangle: ((20@20) corner: (120@120)) width: 4 color: Color green.
		canvas text: 'Hello, World!!' at: 40@40 font: nil color: Color cyan.
		canvas fillRectangle: ((10@80) corner: (31@121)) color: Color magenta.
		canvas fillOval: ((10@80) corner: (31@121)) color: Color cyan.
		canvas frameOval: ((40@80) corner: (61@121)) color: Color blue.
		canvas frameOval: ((70@80) corner: (91@121)) width: 3 color: Color red.
		canvas fillRectangle: ((130@30) corner: (170@80)) color: Color lightYellow.
		canvas showAt: 0@0.
	].! !
