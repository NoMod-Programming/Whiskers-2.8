BitBlt subclass: #GrafPort
	instanceVariableNames: 'alpha fillPattern '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Support'!
!GrafPort commentStamp: 'jm 6/15/2003 11:18' prior: 0!
I am a subclass of BitBlt used by FormCanvas.
!


!GrafPort methodsFor: 'accessing' stamp: 'ar 2/17/2000 01:07'!
alphaBits: a
	alpha _ a! !

!GrafPort methodsFor: 'accessing' stamp: 'ar 5/18/2000 18:34'!
displayScannerFor: para foreground: foreColor background: backColor ignoreColorChanges: shadowMode

	^ (DisplayScanner new text: para text textStyle: para textStyle
			foreground: foreColor background: backColor fillBlt: self
			ignoreColorChanges: shadowMode)
		setPort: self clone
! !

!GrafPort methodsFor: 'accessing' stamp: 'ar 2/17/2000 01:09'!
fillPattern: anObject
	fillPattern _ anObject.
	self fillColor: anObject.! !


!GrafPort methodsFor: 'drawing support' stamp: 'EMP 3/15/2016 15:33'!
basicDisplayString: aString from: startIndex to: stopIndex at: aPoint strikeFont: font
	"Answer last affected pixel position"

	destY _ aPoint y.
	destX _ aPoint x.

	"the following are not really needed, but theBitBlt primitive will fail if not set"
	sourceX ifNil: [sourceX _ 100].
	width ifNil: [width _ 100].

	self primDisplayString: aString from: startIndex to: stopIndex
			map: font characterToGlyphMap xTable: font xTable
			kern: font baseKern.
	^ destX@(destY+font height)! !

!GrafPort methodsFor: 'drawing support' stamp: 'EMP 3/15/2016 15:33'!
colorConvertingMap: targetColor from: sourceDepth to: destDepth keepSubPixelAA: keepSubPix
	"Note: The color converting map for sourceDepth=16 and for sourceDepth=32 are the same"
	
	| srcIndex map mapsForSource mapsForSourceAndDest |
	ColorConvertingMaps 
		ifNil: [ColorConvertingMaps _ (1 to: 10) collect: [:i | Array new: 32]].
		
	srcIndex _ sourceDepth.
	sourceDepth > 8 ifTrue: [ srcIndex _ keepSubPix ifTrue: [9] ifFalse: [10] ].
	mapsForSource _ ColorConvertingMaps at: srcIndex.
	(mapsForSourceAndDest _ mapsForSource at: destDepth) ifNil: [
		mapsForSourceAndDest _ mapsForSource at: destDepth put: Dictionary new ].
	
	map _ mapsForSourceAndDest at: targetColor ifAbsentPut: [
		Color 
			computeColorConvertingMap: targetColor 
			from: sourceDepth 
			to: destDepth 
			keepSubPixelAA: keepSubPix ].

	^ map! !

!GrafPort methodsFor: 'drawing support' stamp: 'EMP 3/15/2016 15:35'!
displayString: aString from: startIndex to: stopIndex at: aPoint strikeFont: font color: foregroundColor 
	"If required, do a second pass with new rule and colorMap.
	Answer last 
	affected pixel position
	Answer nil if nothing was done
	"
	"Slight optimization when there's nothing to do."
	| answer prevRule secondPassMap sourceDepth destDepth |
	clipHeight = 0 ifTrue: [^ nil].
	clipWidth = 0 ifTrue: [^ nil].
	self installStrikeFont: font foregroundColor: (foregroundColor alpha: 1).
	"If combinationRule is rgbMul, we might need the special two-pass 
	technique for component alpha blending.
	If not, do it simply"
	combinationRule = 37 ifFalse: ["rgbMul"
		^ self
			basicDisplayString: aString
			from: startIndex
			to: stopIndex
			at: aPoint
			strikeFont: font].
	"We need to do a second pass. The colormap set is for use in the second 
	pass. "
	secondPassMap _ colorMap.
	sourceDepth _ sourceForm depth.
	destDepth _ destForm depth.
	colorMap _ sourceDepth ~= destDepth ifTrue: [Color cachedColormapFrom: sourceDepth to: destDepth].
	answer _ self
				basicDisplayString: aString
				from: startIndex
				to: stopIndex
				at: aPoint
				strikeFont: font.
	colorMap _ secondPassMap.
	secondPassMap
		ifNotNil: 
			[prevRule _ combinationRule.
			combinationRule _ 20.
			"rgbAdd"
			self
				basicDisplayString: aString
				from: startIndex
				to: stopIndex
				at: aPoint
				strikeFont: font.
			combinationRule _ prevRule].
	^ answer! !

!GrafPort methodsFor: 'drawing support' stamp: 'EMP 1/7/2016 19:44'!
fillAntialiasedOval: rect
	| centerX centerY nextY yBias xBias outer nextOuterX |
	rect area <= 0 ifTrue: [^ self].
	height _ 1.
	yBias _ rect height odd ifTrue: [0] ifFalse: [-1].
	xBias _ rect width odd ifTrue: [1] ifFalse: [0].
	centerX _ rect center x.
	centerY _ rect center y.
	outer _ EllipseMidpointTracer new on: rect.
	nextY _ rect height // 2.
	[nextY > 0] whileTrue:[
		nextOuterX _ outer stepInY.
		width _ (nextOuterX bitShift: 1) + xBias.
		destX _ centerX - nextOuterX.
		destY _ centerY - nextY.
		self copyBits.
		destY _ centerY + nextY + yBias.
		self copyBits.
		nextY _ nextY - 1.
	].
	destY _ centerY.
	height _ 1 + yBias.
	width _ rect width.
	destX _ rect left.
	self copyBits.
! !

!GrafPort methodsFor: 'drawing support' stamp: 'ar 2/16/2000 22:32'!
fillOval: rect
	| centerX centerY nextY yBias xBias outer nextOuterX |
	rect area <= 0 ifTrue: [^ self].
	height _ 1.
	yBias _ rect height odd ifTrue: [0] ifFalse: [-1].
	xBias _ rect width odd ifTrue: [1] ifFalse: [0].
	centerX _ rect center x.
	centerY _ rect center y.
	outer _ EllipseMidpointTracer new on: rect.
	nextY _ rect height // 2.
	[nextY > 0] whileTrue:[
		nextOuterX _ outer stepInY.
		width _ (nextOuterX bitShift: 1) + xBias.
		destX _ centerX - nextOuterX.
		destY _ centerY - nextY.
		self copyBits.
		destY _ centerY + nextY + yBias.
		self copyBits.
		nextY _ nextY - 1.
	].
	destY _ centerY.
	height _ 1 + yBias.
	width _ rect width.
	destX _ rect left.
	self copyBits.
! !

!GrafPort methodsFor: 'drawing support' stamp: 'jm 5/12/2003 19:59'!
fillRect: rect offset: aPoint
	"The offset is really just for stupid InfiniteForms."

	| fc |
	fillPattern class == InfiniteForm ifTrue:[
		fc _ halftoneForm.
		self fillColor: nil.
		fillPattern displayUsingBitBlt: ((self clippedBy: rect) colorMap: nil) at: aPoint.
		halftoneForm _ fc.
		^ self].

	destX _ rect left.
	destY _ rect top.
	sourceX _ 0.
	sourceY _ 0.
	width _ rect width.
	height _ rect height.
	self copyBits.! !

!GrafPort methodsFor: 'drawing support' stamp: 'ar 2/16/2000 22:26'!
frameOval: rect borderWidth: borderWidth
	| centerX centerY nextY yBias xBias wp outer inner nextOuterX nextInnerX fillAlpha |
	rect area <= 0 ifTrue: [^ self].
	height _ 1.
	wp _ borderWidth asPoint.
	yBias _ rect height odd ifTrue: [0] ifFalse: [-1].
	xBias _ rect width odd ifTrue: [1] ifFalse: [0].
	centerX _ rect center x.
	centerY _ rect center y.
	outer _ EllipseMidpointTracer new on: rect.
	inner _ EllipseMidpointTracer new on: (rect insetBy: wp).
	nextY _ rect height // 2.
	1 to: (wp y min: nextY) do:[:i|
		nextOuterX _ outer stepInY.
		width _ (nextOuterX bitShift: 1) + xBias.
		destX _ centerX - nextOuterX.
		destY _ centerY - nextY.
		self copyBits.
		destY _ centerY + nextY + yBias.
		self copyBits.
		nextY _ nextY - 1.
	].
	[nextY > 0] whileTrue:[
		nextOuterX _ outer stepInY.
		nextInnerX _ inner stepInY.
		destX _ centerX - nextOuterX.
		destY _ centerY - nextY.
		width _ nextOuterX - nextInnerX.
		self copyBits.
		destX _ centerX + nextInnerX + xBias.
		self copyBits.
		destX _ centerX - nextOuterX.
		destY _ centerY + nextY + yBias.
		self copyBits.
		destX _ centerX + nextInnerX + xBias.
		self copyBits.
		nextY _ nextY - 1.
	].
	destY _ centerY.
	height _ 1 + yBias.
	width _ wp x.
	destX _ rect left.
	self copyBits.
	destX _ rect right - wp x.
	self copyBits.
! !

!GrafPort methodsFor: 'drawing support' stamp: 'ar 2/17/2000 14:44'!
frameRect: rect borderWidth: borderWidth
	sourceX _ 0.
	sourceY _ 0.
	(rect areasOutside: (rect insetBy: borderWidth)) do:
		[:edgeStrip | self destRect: edgeStrip; copyBits].
! !

!GrafPort methodsFor: 'drawing support' stamp: 'ar 2/17/2000 01:08'!
frameRectBottom: rect height: h

	destX _ rect left + 1.
	destY _ rect bottom - 1.
	width _ rect width - 2.
	height _ 1.
	1 to: h do: [:i |
		self copyBits.
		destX _ destX + 1.
		destY _ destY - 1.
		width _ width - 2].
! !

!GrafPort methodsFor: 'drawing support' stamp: 'ar 2/17/2000 01:08'!
frameRectRight: rect width: w

	width _ 1.
	height _ rect height - 1.
	destX _ rect right - 1.
	destY _ rect top + 1.
	1 to: w do: [:i |
		self copyBits.
		destX _ destX - 1.
		destY _ destY + 1.
		height _ height - 2].
! !

!GrafPort methodsFor: 'drawing support' stamp: 'ar 2/17/2000 01:08'!
image: aForm at: aPoint sourceRect: sourceRect rule: rule
	"Draw the portion of the given Form defined by sourceRect at the given point using the given BitBlt combination rule."

	sourceForm _ aForm.
	combinationRule _ rule.
	self sourceRect: sourceRect.
	self destOrigin: aPoint.
	self copyBits! !

!GrafPort methodsFor: 'drawing support' stamp: 'jm 3/18/2003 11:17'!
image: aForm at: aPoint sourceRect: sourceRect rule: rule alpha: a
	"Draw the portion of the given Form defined by sourceRect at the given point using the given BitBlt combination rule."

	sourceForm _ aForm.
	combinationRule _ rule.
	self sourceRect: sourceRect.
	self destOrigin: aPoint.
	self copyBitsTranslucent: a.
! !

!GrafPort methodsFor: 'drawing support' stamp: 'EMP 3/15/2016 12:33'!
installStrikeFont: aStrikeFont foregroundColor: foregroundColor

	sourceForm _ aStrikeFont glyphs.
	sourceY _ 0.
	height _ aStrikeFont height.
	self setRuleAndMapFor: sourceForm depth foregroundColor: foregroundColor! !

!GrafPort methodsFor: 'drawing support' stamp: 'EMP 3/15/2016 15:34'!
primDisplayString: aString from: startIndex to: stopIndex map: glyphMap xTable: xTable kern: kernDelta
	| ascii glyph |
	<primitive:'primitiveDisplayString' module:'BitBltPlugin'>
	startIndex to: stopIndex do:[:charIndex|
		ascii _ (aString at: charIndex) asciiValue.
		glyph _ glyphMap at: ascii + 1.
		sourceX _ xTable at: glyph + 1.
		width _ (xTable at: glyph + 2) - sourceX.
		self copyBits.
		destX _ destX + width + kernDelta.
	].! !

!GrafPort methodsFor: 'drawing support' stamp: 'EMP 3/15/2016 15:33'!
setRuleAndMapFor: sourceDepth foregroundColor: foregroundColor

	| targetColor destDepth |
	destDepth _ destForm depth.
	halftoneForm _ nil.	"Don't use fillColor. Use a more powerful ColorMap"

	sourceDepth = 1 ifTrue: [
		self combinationRule: Form paint.
		"Set up color map for a different source depth (color font)"
		"Uses caching for reasonable efficiency"
		colorMap _ self cachedFontColormapFrom1BitTo: destDepth.
		colorMap at: 1 put: (destForm pixelValueFor: Color transparent).
		colorMap at: 2 put: (destForm pixelValueFor: foregroundColor) ]
	
	ifFalse: [
		"Enable subpixel rendering if requested, but never for translucent text:
		This technique always draws opaque text. This could be added, by using an extra colormap for the rgbMul phase...
		So far, no need arised for doing so."
		(sourceDepth > 8 and: [
			Preferences subPixelRenderFonts and: [ foregroundColor = Color black or: [ 
				Preferences subPixelRenderColorFonts and: [ foregroundColor isOpaque ]]]]) ifTrue: [
			destDepth > 8 ifTrue: [
				"rgbMul is equivalent to component alpha blend if text is black (only faster, hehe)"
				self combinationRule: 37.		"rgbMul"
				colorMap _ (foregroundColor ~= Color black or: [
						destDepth = 32 and: [ destForm ~~ Display or: [Preferences properDisplayAlphaForFonts] ]]) ifTrue: [
					"rgbMul / rgbAdd IS component alpha blend for any color of text (neat trick, eh!!)"
					"This colorMap is to be used on the second pass with rule 20 (rgbAdd)
					See #displayString:from:to:at:strikeFont:color:"
					"Note: In 32bpp, if we want the correct alpha in the result, we need the second pass, as the destination could have transparent pixels, 
					and we need to add to the alpha channel"
					self colorConvertingMap: foregroundColor from: sourceDepth to: destDepth keepSubPixelAA: true]]
			ifFalse: [
				self combinationRule: 25.		"Paint"
				targetColor _ foregroundColor = Color black ifFalse: [ foregroundColor ].
				colorMap _ self colorConvertingMap: targetColor from: sourceDepth to: destDepth keepSubPixelAA: true]]
		ifFalse: [
			"Do not use rule 34 for 16bpp display. TTCFont uses it, but it builds a glyphs cache for each color used!!"
			self combinationRule: (destDepth = 32 ifTrue: [34 "alphaBlendScaled"] ifFalse: [25 "Paint"]).
			colorMap _ self colorConvertingMap: foregroundColor from: sourceDepth to: destDepth keepSubPixelAA: false]]! !

!GrafPort methodsFor: 'drawing support' stamp: 'ar 2/17/2000 00:31'!
stencil: stencilForm at: aPoint sourceRect: aRect
	"Paint using aColor wherever stencilForm has non-zero pixels"
	self sourceForm: stencilForm;
		destOrigin: aPoint;
		sourceRect: aRect.
	self copyBits! !


!GrafPort methodsFor: 'copying' stamp: 'ar 2/17/2000 01:07'!
clippedBy: aRectangle
	^ self copy clipRect: (self clipRect intersect: aRectangle)! !

!GrafPort methodsFor: 'copying' stamp: 'ar 2/17/2000 01:07'!
copyBits
	"Override copybits to do translucency if desired"

	(combinationRule >= 30 and: [combinationRule <= 31])
		ifTrue: [alpha == nil
					ifTrue: [self copyBitsTranslucent: 255]
					ifFalse: [self copyBitsTranslucent: alpha]]
		ifFalse: [super copyBits]! !
