ScriptableScratchMorph subclass: #ScratchSpriteMorph
	instanceVariableNames: 'scalePoint rotationDegrees rotationStyle rotatedForm offsetWhenRotated draggable penDown penSize penColor penHue penShade '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Objects'!
!ScratchSpriteMorph commentStamp: '<historical>' prior: 0!
I represent a programmable Scratch object.

I have a costume, a bitmapped image that can be rotated, scaled, and image-filtered.

The raw Form before any rotation or scaling is stored in originalForm. rotatedForm is a cache of the rotated and scaled version of originalForm.

rotationStyle has three possible values:
	normal		continuous rotation with direction
	leftRight	for directions with x component < 0, flip the bitmap around the y-axis, otherwise no rotation
	none		don't rotate with direction

The leftRight style is useful for side-views of things such as cars, horses, etc.
!


!ScratchSpriteMorph methodsFor: 'initialization' stamp: 'EMP 10/6/2015 14:56'!
backdropName
	^ ((self ownerThatIsA: ScratchStageMorph) costumeNameFromNumber: ((self ownerThatIsA: ScratchStageMorph) backgroundIndex))! !

!ScratchSpriteMorph methodsFor: 'initialization' stamp: 'EMP 10/6/2015 14:54'!
changeBackdropTo: aCostumeName
	(self ownerThatIsA: ScratchStageMorph) showBackground: aCostumeName! !

!ScratchSpriteMorph methodsFor: 'initialization' stamp: 'EMP 11/18/2015 14:33'!
costumeName
	^ (self costumeNameFromNumber: (self costumeIndex))! !

!ScratchSpriteMorph methodsFor: 'initialization' stamp: 'EMP 10/3/2015 17:03'!
getCounter
	^ ((self ownerThatIsA: ScratchStageMorph) getCounter)! !

!ScratchSpriteMorph methodsFor: 'initialization' stamp: 'EMP 10/3/2015 16:00'!
incCounter
	(self ownerThatIsA: ScratchStageMorph) incCounter! !

!ScratchSpriteMorph methodsFor: 'initialization' stamp: 'ee 8/5/2008 10:17'!
initialize

	super initialize.
	scalePoint _ 1.0@1.0.
	rotationDegrees _ 0.0.				"clockwise angle of rotation"
	rotationStyle _ #normal.				"#normal, #leftRight, or #none"
	rotatedForm _ self costumeForm.		"cached rotated/scaled copy of costume form"
	offsetWhenRotated _ 0@0.			"offset for rotated form needed to keep rotation center invariant"
	draggable _ false.
	penDown _ false.
	penSize _ 1.
	penHue _ 133.3.
	penShade _ 50.
	self penColor: Color blue.
	self extent: rotatedForm extent.
! !

!ScratchSpriteMorph methodsFor: 'initialization' stamp: 'EMP 10/3/2015 16:01'!
resetCounter
	(self ownerThatIsA: ScratchStageMorph) resetCounter! !


!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'EMP 10/6/2015 14:25'!
backdropNames
	^ (self ownerThatIsA: ScratchStageMorph) costumeNames! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 8/7/2008 13:16'!
defaultImageMedia

	^ ImageMedia new
		form: (Form extent: 8@8 depth: 8) fillWhite;
		mediaName: ('costume' localized, '1')
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 10/19/2007 11:35'!
draggable

	draggable ifNil: [draggable _ true].
	^ draggable
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 10/19/2007 11:35'!
draggable: aBoolean

	draggable _ aBoolean.
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'EMP 10/2/2015 16:01'!
getVar: varName
	"Answer the value of the given user variable of this object, or 0 if the variable has been deleted."

	^ vars at: varName asString ifAbsent: [^ ((self ownerThatIsA: ScratchStageMorph) getVar: (varName asString))]
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 12/5/2004 10:40'!
heading
	"Answer my heading in degrees, a number between -180 and 180."

	| result |
	result _ rotationDegrees + 90.
	result > 180 ifTrue: [result _ result - 360].
	^ result

! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 12/5/2004 10:40'!
heading: headingDegrees
	"Set my heading in degrees, where 0 degrees is facing up and the heading increases clockwise."
	"Note: Our convention is that artwork is drawing facing to the right. Thus, a heading of 90 corresponds to a rotationDegrees of zero."

	self rotationDegrees: headingDegrees - 90
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 5/10/2004 19:37'!
isClone: aBoolean

	isClone _ aBoolean.
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 4/30/2004 19:05'!
isPaintable
	"Answer true if my image can be repainted."

	^ true
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 5/6/2004 19:49'!
isRotatable
	"Answer true if my image can be rotated."

	^ true
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 7/3/2008 15:14'!
isSprite

	^ true
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'EMP 11/30/2015 14:15'!
offsetWhenRotated
	^ offsetWhenRotated! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'EMP 11/9/2015 14:20'!
position: aPoint

"	self halt.	"
	super position: aPoint.! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 5/8/2009 12:11'!
referencePosition

	| p s |
	p _ (bounds origin + offsetWhenRotated) - ScratchOrigin.

	"adjust when in Hand in quartersize mode:"
	((owner isKindOf: HandMorph) and:
	 [((s _ owner formerOwner) isKindOf: ScratchStageMorph) and:
	 [s isQuarterSize]]) ifTrue: [
		"Note: this is not quite right when rotation center is offset"
		p _ (p * 2) + (240@180)].

	^ p x @ p y negated
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 9/25/2007 13:12'!
referencePosition: aPoint
	"Set my reference position. Avoid infinite or NaN coordinates. Keep on screen."

	| newX newY p |
	newX _ aPoint x.
	newX isNaN ifTrue: [newX _ 0].
	newX isInf ifTrue: [newX _ newX sign * 10000].
	newY _ aPoint y.
	newY isNaN ifTrue: [newY _ 0].
	newY isInf ifTrue: [newY _ newY sign * 10000].

	p _ newX @ newY negated.
	self position: ScratchOrigin + (p - offsetWhenRotated).
	self keepOnScreen.
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 6/2/2004 19:17'!
rotatedForm
	"Answer my rotated and scaled form."

	rotatedForm ifNil: [self costumeChanged].
	^ rotatedForm
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 5/3/2004 20:21'!
rotationCenter

	^ costume rotationCenter
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 4/30/2004 19:05'!
rotationDegrees

	^ rotationDegrees
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 12/1/2006 11:27'!
rotationDegrees: newRotationDegrees

	rotationDegrees ~= newRotationDegrees ifTrue: [
		rotationDegrees _ newRotationDegrees asFloat \\ 360.0.
		(rotationStyle = #none) ifFalse: [
			self positionTalkBubble.
			self costumeChanged]].
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 4/30/2004 19:05'!
rotationStyle

	^ rotationStyle
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 12/1/2006 11:30'!
rotationStyle: aSymbol
	"Set my rotation style to #normal, #leftRight, or #none. Styles mean:
		#normal	-- smooth 360 degree rotation
		#leftRight	-- flip about the vertical axis
		#none		-- do not rotate"

	rotationStyle _ aSymbol.
	self costumeChanged.
	self positionTalkBubble.
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 7/2/2004 00:45'!
scale

	^ (100 * scalePoint x) rounded
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 1/4/2006 14:36'!
scalePoint

	^ scalePoint
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 12/1/2006 11:28'!
scalePoint: aPoint

	scalePoint _ aPoint.
	self costumeChanged.
	self positionTalkBubble.
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'EMP 11/30/2015 14:43'!
setRotStyle: aSymbol
	aSymbol = #'all around' ifTrue: [^ self rotationStyle: #normal].
	aSymbol = #'left-right' ifTrue: [^ self rotationStyle: #leftRight].
	aSymbol = #'don''t rotate' ifTrue: [^ self rotationStyle: #none].
	aSymbol = #none ifTrue: [^ self rotationStyle: #none].
	aSymbol = #normal ifTrue: [^ self rotationStyle: #normal].
	aSymbol = #leftRight ifTrue: [^ self rotationStyle: #leftRight].
	^ self rotationStyle: #leftRight! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'EMP 4/6/2016 13:31'!
tryExtractColorFrom: aColorAsNumber
	| base result alpha red green blue |
	"Try answering a color from a Scratch 2.0 color value, or nil if none can be deciphered
	-EMP 11/9/15"
	base _ (aColorAsNumber) asString withoutLeadingBlanks withoutTrailingBlanks.
	"First, try to see if the input got converted to a string"
	(base beginsWith: '(Color') ifTrue: [[result _ (Compiler evaluate: base for: self logged: false)] ifError: [result _ nil "reset the result in case of an error AFTER storing the value"]].

	"Next, try to see if it a scratch 2.0 format color: ARGB"
	(base asNumberNoError = 0) ifFalse: [
	alpha _ ((base asNumberNoError / 16777216) floor) asInteger.
	red _ ((base asNumberNoError - ((alpha * 16777216)) / 65536) floor) asInteger.
	green _ ((base asNumberNoError - ((alpha * 16777216) + (red * 65536)) / 256) floor) asInteger.
	blue _ ((base asNumberNoError - ((alpha * 16777216) + (red * 65536) + (green * 256))) floor) asInteger.
	result _ (Color r: red/255 g: green/255 b: blue/255 alpha: (1 - (alpha / 255))) "I am trying to implement color alpha. About halfway through"].

	(base asNumberNoError = 0) ifTrue: [^ (Color r:0 g:0 b:0) "in case a user wants zero"].
	
	result ifNil: [^ nil] ifNotNil: [^ result]! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 5/15/2004 20:20'!
xpos

	^ self referencePosition x
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 6/19/2004 07:49'!
xpos: aNumber

	| newX |
	newX _ aNumber isInteger ifTrue: [aNumber] ifFalse: [aNumber asFloat].
	self referencePosition: (newX @ self ypos).
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 5/15/2004 20:20'!
ypos

	^ self referencePosition y
! !

!ScratchSpriteMorph methodsFor: 'accessing' stamp: 'jm 6/19/2004 07:51'!
ypos: aNumber

	| newY |
	newY _ aNumber isInteger ifTrue: [aNumber] ifFalse: [aNumber asFloat].
	self referencePosition: (self xpos @ newY).
! !


!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 4/1/2005 13:31'!
changePenHueBy: aNumber
	"Change the pen hue by given number."

	self setPenHueTo: penHue + aNumber.

! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 4/1/2005 13:33'!
changePenShadeBy: aNumber
	"Change the pen shade (lightness) by given number"

	self setPenShadeTo: penShade + aNumber.
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 3/16/2005 11:31'!
changePenSizeBy: aNumber
	"Change my pen width."

	self penSize: penSize + aNumber.
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 8/2/2005 18:52'!
clearPenTrails
	"Clear the pen trails layer."

	| m |
	(m _ self ownerThatIsA: ScratchStageMorph)
		ifNotNil: [m clearPenTrails].
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'EMP 3/22/2016 11:01'!
gotoSpriteOrMouse: anObject
	"Go to the given sprite or mouse position."

	| aSpriteOrSymbol p |
	aSpriteOrSymbol _ self coerceSpriteArg: anObject.

	aSpriteOrSymbol = #mouse ifTrue: [^ self gotoX: self mouseX y: self mouseY].
	aSpriteOrSymbol = #'_random_' ifTrue: [^ self gotoX: (self randomFrom: -240 to: 240) y: (self randomFrom: -180 to: 180)].
	(aSpriteOrSymbol isKindOf: self class) ifFalse: [^ self].
	p _ aSpriteOrSymbol referencePosition.
	self gotoX: p x y: p y.

! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 2/5/2005 10:52'!
penColor

	^ penColor
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'EMP 11/9/2015 14:17'!
penColor: aColor
	"Set my pen color."

	| b |
	aColor isColor ifTrue: [penColor _ aColor] ifFalse: [(penColor _ self tryExtractColorFrom: aColor) ifNil: [^ self "uses custom block idea"]].
	penHue _ (penColor hue * 200.0) / 360.0.
	b _ penColor brightness.
	b = 1.0
		ifTrue: [penShade _ 50.0 + (50.0 * (1.0 - penColor saturation))]
		ifFalse: [penShade _ 50.0 * b].! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 2/5/2005 10:52'!
penDown

	^ penDown
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 8/2/2005 18:52'!
penDown: aBoolean

	| m |
	penDown _ aBoolean.
	penColor ifNil: [penColor _ Color black].  "initialize if necessary"
	penSize ifNil: [penSize _ 1].  "initialize if necessary"

	(m _ self ownerThatIsA: ScratchStageMorph)
		ifNotNil: [m penUpOrDownChangeFor: self].
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 2/5/2005 10:39'!
penPosition

	^ self referencePosition
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 2/5/2005 10:52'!
penSize

	^ penSize
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jens 11/18/2008 09:47'!
penSize: aNumber
	"Set my pen width."

	penSize _ aNumber rounded min: (ScratchFrameMorph workpaneExtent x * 2) max: 1.
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 2/5/2005 11:41'!
putPenDown
	"Put down my drawing pen (i.e. start drawing a pen trail)."

	self penDown: true.
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 2/5/2005 11:40'!
putPenUp
	"Put up my drawing pen (i.e. stop drawing a pen trail)."

	self penDown: false.
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 2/10/2008 22:20'!
setPenColorFromCostumedNamed: costumeNameOrIndex x: x y: y
	"Set my pen color from my costume of the given name at the given point. If the point is off the edge, set my color to black."

	| cName m f pixel |
	cName _ costumeNameOrIndex.
	cName isNumber ifTrue: [cName _ self costumeNameFromNumber: costumeNameOrIndex].
	m _ media
		detect: [:el | el isSound not and: [el mediaName caseInsensitiveEqual: cName]]
		ifNone: [^ self].

	f _ m form.
	f unhibernate.
	pixel _ ScratchPlugin
		primInterpolate: f bits
		width: f width
		x: (x * 1024) rounded
		y: ((f height - y) * 1024) rounded.

	pixel = 0
		ifTrue: [self penColor: Color black]
		ifFalse: [self penColor: (Color colorFromPixelValue: pixel depth: 24)].
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 4/1/2005 13:30'!
setPenHueTo: aNumber
	"Set the pen hue to given number between 0 and 200. (That makes 100 the 'maximum' distance away from the original color on the color wheel.)"

	penHue _ aNumber \\ 200.
	self setPenShadeTo:  penShade.  "compute and set penColor"
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 4/1/2005 14:22'!
setPenShadeTo: aNumber
	"Set the pen shade (lightness) to given number between 0 and 100. A shade of 0 is black, 100 is white, and 50 is fully saturated color."
	"Details: We don't want to get all the way to pure black or white, so we divide the range 0..50 by a number > 50 when computing the fraction of the original color to mix with black or white."

	| normalizeShade scale k |
	penShade _ aNumber asFloat \\ 200.0.
	penColor _ Color h: (360.0 * penHue) / 200.0 s: 1.0 v: 1.0.
	normalizeShade _ penShade > 100.0 ifTrue: [200.0 - penShade] ifFalse: [penShade].

	normalizeShade = 50.0 ifTrue: [^ self].  "pure color"

	scale _ 1.0 / 60.0.
	k _ 1.0 - (50.0 * scale).
	normalizeShade < 50.0 ifTrue: [
		penColor _ penColor mixed: (scale * normalizeShade) + k with: Color black].
	normalizeShade > 50.0 ifTrue: [
		penColor _ penColor mixed: 1.0 - (scale * (normalizeShade - 50.0)) with: Color white].
! !

!ScratchSpriteMorph methodsFor: 'pen ops' stamp: 'jm 8/2/2005 18:52'!
stampCostume
	"Stamp a copy of my current costume on the pen trails layer."

	| m |
	self step.  "update costume if necessary"
	(m _ self ownerThatIsA: ScratchStageMorph)
		ifNotNil: [m stampCostume: self].
! !


!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 12/4/2006 11:54'!
bounceOffEdge
	"Set my direction to bounce off the edge."

	| myBox edgeBox dirX dirY |
	owner ifNil: [^ self].
	myBox _ self fullBounds.
	edgeBox _ owner bounds.
	(edgeBox containsRect: myBox) ifTrue: [^ self].

	dirX _ self rotationDegrees degreesToRadians cos.
	dirY _ self rotationDegrees degreesToRadians sin negated.
	myBox left < edgeBox left ifTrue: [dirX _ dirX abs].
	myBox right > edgeBox right ifTrue: [dirX _ dirX abs negated].
	myBox top < edgeBox top ifTrue: [dirY _ dirY abs negated].
	myBox bottom > edgeBox bottom ifTrue: [dirY _ dirY abs].
	self rotationDegrees: (dirY negated asFloat arcTan: dirX) radiansToDegrees.
	self position: self position + (myBox amountToTranslateWithin: edgeBox).
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 7/2/2004 00:47'!
changeXposBy: aNumber
	"Move right by the given amount."

	self referencePosition: self referencePosition + (aNumber@0).
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 7/2/2004 00:47'!
changeYposBy: aNumber
	"Move up by the given amount."

	self referencePosition: self referencePosition + (0@aNumber).
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 11/30/2006 21:08'!
color: sensitiveColor sees: soughtColor
	"Return true if any of my pixels of sensitiveColor intersect with pixels of soughtColor in the world."

	| r myImage sensitivePixelsMask map index imageBelowMe |
	r _ self bounds intersect: owner bounds.
	r area = 0 ifTrue: [^ false].

	"make a mask with 1 where pixel = sensitiveColor, 0 elsewhere"
	myImage _ self imageForm asFormOfDepth: 16.
	sensitivePixelsMask _ Form extent: myImage extent depth: 1.
	map _ Bitmap new: (1 bitShift: (myImage depth min: 15)).
	map at: (index _ sensitiveColor indexInMap: map) put: 1.
	sensitivePixelsMask
		copyBits: ((r origin - self position) extent: r extent)
		from: myImage form
		at: 0@0
		colorMap: map.

	"grab an image of the world below me"
	imageBelowMe _ owner patchAt: r without: self andNothingAbove: false.

	"intersect world pixels of the color we're looking for with sensitive pixels mask"
	map at: index put: 0.  "clear map and reuse it"
	map at: (soughtColor indexInMap: map) put: 1.

	sensitivePixelsMask
		copyBits: imageBelowMe boundingBox
		from: imageBelowMe at: 0@0 clippingBox: imageBelowMe boundingBox
		rule: Form and
		fillColor: nil
		map: map.
	^ (sensitivePixelsMask tallyPixelValues at: 2) > 0
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 6/8/2009 10:09'!
directionMenu
	"Provides a drop-down menu for setting the sprite direction."

	| menu |
	menu _ CustomMenu new.
	#(	('right' 90)
		('left' -90)
		('up' 0)
		('down' 180)
	) do: [:pair |
		menu
			add: '(' asUTF8, pair second printString, ') ', pair first localized
			action: pair second].
	^ menu
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 3/28/2009 20:15'!
distanceTo: anObject
	"Answer the distance to the given sprite."

	| aSpriteOrSymbol |
	aSpriteOrSymbol _ self coerceSpriteArg: anObject.

	aSpriteOrSymbol = #mouse ifTrue: [
		^ ((self mouseX @ self mouseY)  - self referencePosition) r].

	(aSpriteOrSymbol isKindOf: self class) ifFalse: [^ 10000].
	^ (aSpriteOrSymbol referencePosition - self referencePosition) r
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jens 11/21/2008 09:49'!
forward: distance
	"Move the object forward (i.e., the direction of its heading) by the given distance.
	Avoid infinite or NaN coordinates"

	| radians deltaP newPos newX newY |
	radians _ rotationDegrees degreesToRadians.
	deltaP _ ((radians cos)@(radians sin)) * distance.
	newPos _ self position + deltaP.
	newX _ newPos x.
	newY _ newPos y.
	newX isNaN ifTrue: [newX _ 0].
	newX isInf ifTrue: [newX _ newX sign * 10000].
	newY isNaN ifTrue: [newY _ 0].
	newY isInf ifTrue: [newY _ newY sign * 10000].
	self position: newX @ newY.
	self keepOnScreen.
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 12/14/2005 19:46'!
glideSecs: duration toX: endX y: endY elapsed: elapsed from: startPoint
	"Interpolate my position from my current postion to the given x and y over the given duration. If startPoint is nil, just answer my current position; this sets the starting point for the interpolation."

	| fraction endPoint |
	startPoint ifNil: [^ self referencePosition].
	endPoint _ endX@endY.
	duration < 0.001
		ifTrue: [fraction _ 1]
		ifFalse: [fraction _ elapsed asFloat / (1000.0 * duration)].
	fraction > 1.0 ifTrue: [fraction _ 1].
	fraction < 0.0 ifTrue: [fraction _ 0].
	self referencePosition: startPoint + (fraction * (endPoint - startPoint)) truncated.
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 5/10/2004 16:31'!
gotoX: x y: y

	self referencePosition: x@y.
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 10/12/2005 22:08'!
gotoX: endX y: endY duration: duration elapsed: elapsed from: startPoint
	"Interpolate my position from startPoint to endPoint over the given duration. If startPoint is nil, just answer my current position; this sets the starting point for the interpolation."

	| fraction endPoint |
	startPoint ifNil: [^ self referencePosition].
	endPoint _ endX@endY.
	duration < 0.001
		ifTrue: [fraction _ 1]
		ifFalse: [fraction _ elapsed asFloat / (1000.0 * duration)].
	fraction > 1.0 ifTrue: [fraction _ 1].
	fraction < 0.0 ifTrue: [fraction _ 0].
	self referencePosition: startPoint + (fraction * (endPoint - startPoint)) truncated.
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'EMP 10/3/2015 16:18'!
isClone

	^ (isClone == true)
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 5/26/2005 16:26'!
isOnEdge
	"Answer true if I'm touching the edge of my owner."

	owner ifNil: [^ false].
	^ (owner bounds containsRect: self bounds) not

! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 6/9/2004 09:23'!
pointToX: x y: y
	"Set my heading to point at the given point."

	| delta angle |
	delta _ (x@y) - self referencePosition.
	angle _ (delta x abs < 0.001)
		ifTrue: [
			delta y < 0 ifTrue: [90] ifFalse: [270]]
		ifFalse: [
			((delta x >= 0 ifTrue: [0] ifFalse: [180])
				- ((delta y / delta x) arcTan * 57.2957795131)) rounded].
	self rotationDegrees: angle.

! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 3/28/2009 20:16'!
pointTowards: anObject
	"Point toward the given sprite."

	| aSpriteOrSymbol p |
	aSpriteOrSymbol _ self coerceSpriteArg: anObject.

	aSpriteOrSymbol = #mouse ifTrue: [^ self pointToX: self mouseX y: self mouseY].
	(aSpriteOrSymbol isKindOf: self class) ifFalse: [^ self].
	p _ aSpriteOrSymbol referencePosition.
	self pointToX: p x y: p y.

! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'EMP 9/30/2015 15:43'!
toggleShowing
	"Make myself visible."

	self isHidden: (self isHidden not).
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 3/28/2009 20:17'!
touching: anObject
	"Answer true if any visible part of me touches a visible part of the given sprite."
	"Details: Currently uses the bounding box; should follow this up with comparison of visible pixels."

	| aSpriteOrSymbol stage intersection f1 f2 map oldVis |
	aSpriteOrSymbol _ self coerceSpriteArg: anObject.

	aSpriteOrSymbol = #mouse ifTrue: [
		(stage _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ false].
		^ self containsPoint: stage adjustedCursorPoint].

	aSpriteOrSymbol = #edge ifTrue: [^ self isOnEdge].

	(aSpriteOrSymbol isKindOf: self class) ifFalse: [^ false].
	(self isHidden not and: [aSpriteOrSymbol isHidden not]) ifFalse: [^ false].
	intersection _ self bounds intersect: aSpriteOrSymbol bounds.
	(intersection width > 0 and: [intersection height > 0]) ifFalse: [^ false].

	f1 _ Form extent: intersection extent depth: 2.
	f2 _ f1 deepCopy.
	oldVis _ self visibility. self visibility: 100.
	self drawOn: ((FormCanvas on: f1) copyOffset: intersection topLeft negated).
	self visibility: oldVis.

	oldVis _ aSpriteOrSymbol visibility. aSpriteOrSymbol visibility: 100.	
	aSpriteOrSymbol drawOn: ((FormCanvas on: f2) copyOffset: intersection topLeft negated).
	aSpriteOrSymbol visibility: oldVis.

	map _ Bitmap new: 4 withAll: 1.
	map at: 1 put: 0.  "transparent"
	f1 copyBits: f1 boundingBox from: f1 at: 0@0 colorMap: map.	"make mask with 0 where transparent, 1 elsewhere"
	f2 copyBits: f2 boundingBox from: f2 at: 0@0 colorMap: map.	"ditto for other sprite image"
	f2 displayOn: f1 at: 0@0 rule: Form and.						"and the masks together"

	^ (f1 tallyPixelValues at: 1) < (f1 width * f1 height)			"are any pixels of the result non-zero?"
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'ee 7/2/2008 14:10'!
touchingColor: soughtColor
	"Answer true if any of my non-transparent pixels touch pixels of the given color in the world."

	| r myImage sensitivePixelsMask map imageBelowMe |
	r _ self bounds intersect: owner bounds.
	r area = 0 ifTrue: [^ false].

	"make a mask with 0 where transparent, 1 elsewhere"
	myImage _ self imageForm asFormOfDepth: 16.
	sensitivePixelsMask _ Form extent: myImage extent depth: 1.
	map _ Bitmap new: (1 bitShift: (myImage depth min: 15)).
	map atAllPut: 1.
	map at: (Color transparent indexInMap: map) put: 0.
	sensitivePixelsMask
		copyBits: ((r origin - self position) extent: r extent)
		from: myImage form
		at: 0@0
		colorMap: map.

	"grab an image of the world below me"
	imageBelowMe _ owner patchAt: r withoutWatchersAnd: self andNothingAbove: false.

	"intersect world pixels of the color we're looking for with sensitive pixels mask"
	map atAllPut: 0.  "clear map and reuse it"
	map at: (soughtColor indexInMap: map) put: 1.
	sensitivePixelsMask
		copyBits: imageBelowMe boundingBox
		from: imageBelowMe at: 0@0 clippingBox: imageBelowMe boundingBox
		rule: Form and
		fillColor: nil
		map: map.

	^ (sensitivePixelsMask tallyPixelValues at: 2) > 0  "true if any pixels are 1"
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 4/30/2004 19:05'!
turn: degrees
	"Turn clockwise the given number of degrees."

	self rotationDegrees: rotationDegrees + degrees.
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 12/2/2005 14:03'!
turnAwayFromEdge
	"Turn away from the nearest edge."

	| dirX dirY refP delta |
	dirX _ self rotationDegrees degreesToRadians cos.
	dirY _ self rotationDegrees degreesToRadians sin negated.
	refP _ self referencePosition.
	delta _ (ScratchFrameMorph workpaneExtent // 2) - refP abs.

	(delta x < delta y) | (delta x < 0) ifTrue: [  "point dirX towards center"
		dirX = 0.0 ifTrue: [dirX _ 0.1].
		refP x > 0
			ifTrue: [dirX _ dirX abs negated]
			ifFalse: [dirX _ dirX abs]].
	(delta y < delta x) | (delta y < 0) ifTrue: [  "point dirY towards center"
		dirY = 0.0 ifTrue: [dirY _ 0.1].
		refP y > 0
			ifTrue: [dirY _ dirY abs negated]
			ifFalse: [dirY _ dirY abs]].

	self rotationDegrees: (dirY negated asFloat arcTan: dirX) radiansToDegrees.
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 6/9/2004 09:09'!
turnLeft: degrees
	"Turn counter-clockwise the given number of degrees."

	self rotationDegrees: rotationDegrees - degrees.
! !

!ScratchSpriteMorph methodsFor: 'motion ops' stamp: 'jm 6/9/2004 09:11'!
turnRight: degrees
	"Turn clockwise the given number of degrees."

	self rotationDegrees: rotationDegrees + degrees.
! !


!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'jm 6/22/2009 20:16'!
bubble: obj thinkFlag: thinkFlag promptFlag: promptFlag
	"Make a talk bubble with the given string."

	| s talkBubble |
	self sayNothing.

	obj isNumber
		ifTrue: [
			obj isInteger
				ifTrue: [s _ obj printString]
				ifFalse: [s _ (obj asFloat roundTo: 0.01) printString]]
		ifFalse: [(obj isKindOf: Boolean)
			ifTrue: [s _ obj asString localized]
			ifFalse: [s _ obj asString]].
	(s skipDelimiters: ' 	' startingAt: 1) > s size ifTrue: [^ self].
	s size < 5 ifTrue: [s _ s, ' '].

	talkBubble _ ScratchTalkBubbleMorph new message: s.
	thinkFlag ifTrue: [talkBubble beThoughtBubble: true].
	promptFlag ifTrue: [talkBubble bePrompt: true].
	talkBubble lock; position: self position.
	self setProperty: #talkBubble toValue: talkBubble.
	self addMorphFront: talkBubble.
	self positionTalkBubble.
	World displayWorldSafely.
	^ talkBubble
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'jm 12/1/2006 11:23'!
changeSizeBy: delta
	"Change my size by the given delta."

	| currentScale |
	currentScale _ 100.0 * (scalePoint x max: scalePoint y).
	self setSizeTo: (currentScale + delta).
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'jm 12/1/2006 11:23'!
changeStretchBy: delta
	"Change my aspect ratio by the given amount."

	| currentStretch |
	currentStretch _ (100.0 * scalePoint x) / scalePoint y.
	self setStretchTo: (currentStretch + delta).
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'jm 5/10/2004 16:51'!
goBackByLayers: aNumber
	"Decrease my layer by (i.e., move me towards the back by) the given number of layers."

	owner ifNil: [^ self].
	self layer: (owner submorphs indexOf: self) + aNumber truncated.
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'jm 5/26/2005 16:00'!
hide
	"Make myself invisible."

	self isHidden: true.
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'jm 5/10/2004 16:54'!
layer: aNumber

	| n submorphsMinusMe newSubmorphs |
	owner ifNil: [^ 1].
	n _ (aNumber rounded max: 1) min: owner submorphCount.
	submorphsMinusMe _ owner submorphs copyWithout: self.
	newSubmorphs _
		(submorphsMinusMe copyFrom: 1 to: (n - 1 min: submorphsMinusMe size)),
		(Array with: self),
		(submorphsMinusMe copyFrom: n to: submorphsMinusMe size).
	owner privateSubmorphs: newSubmorphs.
	self changed.
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'jm 12/1/2006 11:22'!
lookLike: costumeName

	super lookLike: costumeName.
	self positionTalkBubble.
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'jm 12/1/2006 11:22'!
multiplySizeBy: factor
	"Used by the magnifying glass tool. Multiply my scale by the given factor."

	self setSizeTo: 100.0 * (self scalePoint x max: self scalePoint y) * factor.
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'nb 1/7/2008 13:00'!
recordScene: sceneName

	| state |
	self isHidden ifTrue: [
		sceneStates removeKey: sceneName ifAbsent: [].
		^ self ].

	state _ Dictionary new.
	state at: #referencePosition put: self referencePosition.
	state at: #size put: self scale.
	state at: #heading put: self heading.
	sceneStates at: sceneName put: state.
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'ee 3/1/2009 12:30'!
say: aValue
	"Present a talk bubble with the given string."

	self bubble: aValue thinkFlag: false promptFlag: false.
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'jm 12/1/2006 19:21'!
say: stringOrNum duration: durationSecs elapsed: elapsedMSecs from: startPoint

	startPoint ifNil: [^ self say: stringOrNum].  "first call, show talk bubble"
	elapsedMSecs >= (1000 * durationSecs) ifTrue: [self sayNothing].  "clear bubble"
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'jm 4/30/2004 19:05'!
sayNothing
	"Delete my talk bubble if I have one."

	| talkBubble |
	(talkBubble _ self valueOfProperty: #talkBubble) ifNil: [^ self].
	talkBubble delete.
	self setProperty: #talkBubble toValue: nil.
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'nb 1/7/2008 12:20'!
scenes

	^ sceneStates keys
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'nb 1/7/2008 14:07'!
setScene: sceneName

	| sceneState |
	sceneState _ sceneStates at: sceneName ifAbsent: [^ self hide].
	self show.
	self referencePosition: (sceneState at: #referencePosition).
	self setSizeTo: (sceneState at: #size).
	self heading: (sceneState at: #heading).
! !

!ScratchSpriteMorph methodsFor: 'looks ops'!
setSizeTo: t1 
	| t2 t3 t4 t5 t6 |
	t2 _ self costumeForm extent asFloatPoint max: 1.0e-5 @ 1.0e-5.
	t3 _ (t2 min: 5 @ 5) asFloatPoint.
	t4 _ ScratchFrameMorph workpaneExtent asFloatPoint * 1.5.
	t5 _ (t3 x / t2 x max: t3 y / t2 y)
				min: 1.0.
	t6 _ t4 x / t2 x min: t4 y / t2 y.
	self scalePoint: (t1 / 100.0 within: t5 and: t6) asPoint! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'jm 12/1/2006 11:29'!
setStretchTo: percent
	"Set x stretch percent relative to y. For example, a stretch of 200 stretches x by a factor of two relative to y while a stretch of 50 compresses x by a factor of two. As my stretch is changed, my x scale changes but my y scale remains the same."

	| baseScale origExtent minStretch maxStretch newStretchFactor |
	baseScale _ scalePoint y.
	origExtent _ self costumeForm extent.
	minStretch _ 8.0 / (baseScale * origExtent x).  "min width 8 pixels"
	maxStretch _ 500.0 / (baseScale * origExtent x). "max width 500 pixels"
	newStretchFactor _ ((percent max: 0) / 100.0) within: minStretch and: maxStretch.
	self scalePoint: baseScale * (newStretchFactor @ 1.0).
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'jm 5/26/2005 16:00'!
show
	"Make myself visible."

	self isHidden: false.
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'ee 3/1/2009 12:30'!
think: aValue
	"Present a thought bubble with the given string."

	self bubble: aValue thinkFlag: true promptFlag: false.
! !

!ScratchSpriteMorph methodsFor: 'looks ops' stamp: 'jm 12/1/2006 19:21'!
think: stringOrNum duration: durationSecs elapsed: elapsedMSecs from: startPoint

	startPoint ifNil: [^ self think: stringOrNum].  "first call, show think bubble"
	elapsedMSecs >= (1000 * durationSecs) ifTrue: [self sayNothing].  "clear bubble"
! !


!ScratchSpriteMorph methodsFor: 'movie ops' stamp: 'tis 3/2/2007 23:23'!
stopPlaying
	"Reset my transient state, such as pen down."

	super stopPlaying.
	self sayNothing.

! !


!ScratchSpriteMorph methodsFor: 'sensing ops' stamp: 'ee 11/9/2007 14:48'!
attributeNames

	^ #('x position' 'y position' 'direction' 'costume #' 'size' 'volume') collect: [:s | s]
! !

!ScratchSpriteMorph methodsFor: 'sensing ops' stamp: 'EMP 3/22/2016 10:43'!
getAttribute: attr
	"Answer the value of my variable or built-in attribute with the given name. Answer zero if I have no attribute or variable with the given name."

	| a |
	(vars includesKey: attr) ifTrue: [^ vars at: attr].

	a _ attr localized.
	'x position' localized = a ifTrue: [^ self xpos].
	'y position' localized = a ifTrue: [^ self ypos].
	'direction' localized = a ifTrue: [^ self heading].
	'costume #' localized = a ifTrue: [^ self costumeIndex].
	'costume name' localized = a ifTrue: [^ self costumeName].
	'size' localized = a ifTrue: [^ self scale].
	'volume' localized = a ifTrue: [^ self volume].
	^ 0
! !

!ScratchSpriteMorph methodsFor: 'sensing ops' stamp: 'jm 2/11/2009 09:57'!
hideQuestion
	"Hide my question prompt."
! !

!ScratchSpriteMorph methodsFor: 'sensing ops' stamp: 'ee 3/1/2009 12:29'!
showQuestion: aString
	"Show the given question prompt."

	self bubble: aString thinkFlag: false promptFlag: true.
! !


!ScratchSpriteMorph methodsFor: 'clone ops' stamp: 'EMP 10/5/2015 11:52'!
cloneAndSend: msgName
	"Clone this sprite and send the clone (and only the clone) the given message."

	| frame clone |
	(frame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [(frame _ ((self ownerThatIsA: OffscreenWorldMorph) frame)) ifNil: [^ self]].

	clone _ self fullCopy.
	clone objName: objName, ' clone'.
	clone isClone: true.
	clone blocksBin allMorphsDo: [:m |
		(m isKindOf: BlockMorph) ifTrue: [m stop]].

	frame workPane addMorph: clone.
	clone eventReceived: (ScratchEvent new name: msgName asString argument: 0).
! !

!ScratchSpriteMorph methodsFor: 'clone ops' stamp: 'EMP 3/22/2016 11:01'!
createCloneOf: anObject
	"Clone this sprite and send the clone (and only the clone) the given message."

	| frame clone |
	(frame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [(frame _ ((self ownerThatIsA: OffscreenWorldMorph) frame)) ifNil: [^ self]].
	anObject ifNil: [^ self].
	anObject = #'_myself_' ifTrue: [clone _ self fullCopy] ifFalse: [
	clone _ anObject fullCopy].
	clone objName: objName, ' clone'.
	clone isClone: true.
	clone blocksBin allMorphsDo: [:m |
		(m isKindOf: BlockMorph) ifTrue: [m stop]].

	frame workPane addMorph: clone.
	clone eventReceived: (ScratchEvent new name: 'Scratch-StartedAsClone' argument: 1).
! !

!ScratchSpriteMorph methodsFor: 'clone ops' stamp: 'EMP 10/2/2015 21:41'!
deleteClone
	isClone ifTrue: [self delete].! !


!ScratchSpriteMorph methodsFor: 'drawing' stamp: 'jm 1/8/2006 18:42'!
drawOn: aCanvas
	"Draw myself if my visibility is > 0. If my visibility is 1, draw using the normal 'paint' mode. Otherwise, draw using 'alpha' resulting in a partially transparent rendering."

	| f alpha |
	f _ self filteredForm.
	visibility < 100 ifTrue: [
		visibility > 0 ifTrue: [
			alpha _ ((255.0 * visibility) / 100.0) truncated.
			aCanvas paintImage: f at: bounds origin sourceRect: f boundingBox alpha: alpha].
		^ self].

	aCanvas paintImage: f at: bounds origin.
! !

!ScratchSpriteMorph methodsFor: 'drawing' stamp: 'jm 7/9/2008 10:12'!
drawSubmorphsOn: aCanvas
	"Display submorphs back to front, but do not draw and talk/think bubble submorphs."

	submorphs reverseDo: [:m |
		(m isKindOf: ScratchTalkBubbleMorph) ifFalse: [
			aCanvas fullDrawMorph: m]].
! !

!ScratchSpriteMorph methodsFor: 'drawing' stamp: 'jm 7/9/2008 10:12'!
drawTalkBubbleOn: aCanvas
	"Draw and talk/think bubble submorphs."

	submorphs size = 0 ifTrue: [^ self].
	submorphs reverseDo: [:m |
		(m isKindOf: ScratchTalkBubbleMorph) ifTrue: [
			aCanvas fullDrawMorph: m]].
! !


!ScratchSpriteMorph methodsFor: 'geometry' stamp: 'jm 4/30/2004 19:05'!
containsPoint: aPoint

	^ (self bounds containsPoint: aPoint) and:
	  [(self rotatedForm isTransparentAt: aPoint - bounds origin) not]
! !


!ScratchSpriteMorph methodsFor: 'event handling' stamp: 'EMP 2/9/2016 16:22'!
justDroppedInto: newOwner event: evt
	
	| sf vp |
	super justDroppedInto: newOwner event: evt.
	(newOwner isKindOf: ScratchStageMorph) ifTrue: [self positionTalkBubble].
	(sf _ self ownerThatIsA: ScratchFrameMorph) ifNotNil: [(vp _ sf viewerPane) ifNotNil: [vp refresh]].
! !


!ScratchSpriteMorph methodsFor: 'right button menu' stamp: 'jm 8/3/2008 13:14'!
grabFromScreen
	"Set my form to be a rectangular portion of the screen."

	| f el |
	(f _ self grabFormFromScreen) ifNil: [^ self].
	el _ ImageMedia new form: f.
	el mediaName: (self unusedMediaNameFromBaseName: 'costume1').
	media addLast: el.
	self lookLike: el mediaName.
	self updateMediaCategory.
! !

!ScratchSpriteMorph methodsFor: 'right button menu' stamp: 'EMP 12/12/2015 12:27'!
rightButtonMenu
	"Present the right button menu."

	| menu |
	menu _ CustomMenu new.
	menu add: 'info' action: #showSpriteInto.
	menu addLine.
	menu add: 'grab screen region for new costume' action: #grabFromScreen.
	menu add: 'export this sprite' action: #exportObject.
	menu addLine.
	menu add: 'duplicate' action: #duplicate.
	menu add: 'delete' action: #undoableDeleteSprite.
	menu addLine.
	menu add: 'resize this sprite' action: #resizeHandle.
	menu add: 'rotate this sprite' action: #rotateHandle.
	menu localize; invokeOn: self.
! !

!ScratchSpriteMorph methodsFor: 'right button menu' stamp: 'EMP 12/12/2015 12:29'!
showSpriteInto
	| sFrame lPane |
	(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNotNil: [(lPane _ sFrame libraryPane) ifNotNil: [lPane showInfo: self]]! !


!ScratchSpriteMorph methodsFor: 'object i/o' stamp: 'nb 1/7/2008 14:00'!
fieldsVersion

	^ 3
! !

!ScratchSpriteMorph methodsFor: 'object i/o' stamp: 'jm 7/8/2008 06:12'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		visibility
		scalePoint
		rotationDegrees
		rotationStyle
	) from: anObjStream.

	scalePoint ifNil: [scalePoint _ 1.0@1.0].
	offsetWhenRotated _ 0@0.
	draggable _ false.  "default for old sprites"
	self layoutChanged.

	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	self initFieldsNamed: #(
		volume
		tempoBPM
		draggable
	) from: anObjStream.
	classVersion = 2 ifTrue: [^ self].

	"fields added in version 3"
	self initFieldsNamed: #(
		sceneStates
		lists
	) from: anObjStream.
	lists ifNil: [lists _ Dictionary new].  "work around"
! !

!ScratchSpriteMorph methodsFor: 'object i/o' stamp: 'jm 5/12/2008 12:00'!
storeFieldsOn: anObjStream

	| oldP |
	self sayNothing.  "delete talk bubble before saving"

	"for backward compatability, remove offsetWhenRotated and subtract costume rotationCenter when saving"
	oldP _ self position.
	self position: self position + offsetWhenRotated - costume rotationCenter.

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		visibility
		scalePoint
		rotationDegrees
		rotationStyle
		volume
		tempoBPM
		draggable
		sceneStates
		lists
	) on: anObjStream.

	self position: oldP.  "restore position"
! !


!ScratchSpriteMorph methodsFor: 'private' stamp: 'jm 12/15/2006 11:48'!
copyForExport
	"Answer a copy of me for exporting."
	"Note: Sprites are always exported in the context of an empty background."

	| objToExport |
	objToExport _ ScratchStageMorph new clearMediaAndCostume.
	objToExport position: owner position.
	objToExport addMorph: super copyForExport.
	^ objToExport
! !

!ScratchSpriteMorph methodsFor: 'private' stamp: 'jm 10/16/2007 18:21'!
generateRotatedForm
	"Compute my rotatedForm and offsetWhenRotated."

	| adjustedAngle srcForm smoothPix pair |
	rotationStyle = #normal
		ifTrue: [adjustedAngle _ rotationDegrees]  "smooth rotation"
		ifFalse: [adjustedAngle _ 0.0].  "leftRight or none"

	srcForm _ self costumeForm.
	((srcForm width = 1) & (srcForm height = 1))
		ifTrue: [adjustedAngle _ 0.0].  "don't rotate a 1x1 costume"

	((adjustedAngle = 0.0) and: [1.0@1.0 = scalePoint])
		ifTrue: [  "no rotation or scaling; use original"
			rotatedForm _ srcForm.
			offsetWhenRotated _ costume rotationCenter]
		ifFalse: [  "generated rotated and/or scaled form"
			(((adjustedAngle rounded \\ 90) = 0) and:
			 [1.0@1.0 = scalePoint]) ifTrue: [
				^ self rotateByFlipping].
			((scalePoint x < 1.0) or: [scalePoint y < 1.0])
				ifTrue: [smoothPix _ 2]
				ifFalse: [smoothPix _ 1].
			pair _ WarpBlt
				rotate: srcForm
				degrees: adjustedAngle negated
				center: costume rotationCenter
				scaleBy: scalePoint
				smoothing: smoothPix.
			rotatedForm _ pair first.
			offsetWhenRotated _ (costume rotationCenter + pair last) rounded].

	((rotationStyle = #leftRight) and:
	 [(rotationDegrees > 90.0) and: [rotationDegrees < 270.0]]) ifTrue: [
		"headed left; use flipped"
		rotatedForm _ rotatedForm flipBy: #horizontal centerAt: 0@0.
		offsetWhenRotated _ (rotatedForm width - offsetWhenRotated x - 1) @ offsetWhenRotated y].
! !

!ScratchSpriteMorph methodsFor: 'private' stamp: 'jm 8/3/2008 13:13'!
grabFormFromScreen
	"Grab a rectangular portion of the screen selected by the user and trim white pixels from around edges (this assumes the stage is white). If the resulting form is empty, return nil."

	| f f2 |
	f _ Form fromUser.
	f2 _ (Form extent: (f extent + 2) depth: f depth) fillWhite.
	f displayOn: f2 at: 1@1 rule: Form over.
	f2 shapeFill: Color transparent interiorPoint: 0@0.
	f _ f2 trimBordersOfColor: Color transparent.
	(f width = 0) | (f height = 0) ifTrue: [^ nil].

	^ f
! !

!ScratchSpriteMorph methodsFor: 'private' stamp: 'jm 5/27/2005 22:48'!
keepOnScreen
	"Make me stick to edge of my owner."

	| edgeBox |
	owner ifNil: [^ self].
	(owner bounds containsRect: bounds) ifTrue: [^ self].  "entirely on screen"
	edgeBox _ owner bounds insetBy: (18 min: (bounds width min: bounds height) // 2).
	(bounds intersects: edgeBox) ifTrue: [^ self].
	self right < edgeBox left ifTrue: [self right: edgeBox left].
	self left > edgeBox right ifTrue: [self left: edgeBox right].
	self bottom < edgeBox top ifTrue: [self bottom: edgeBox top].
	self top > edgeBox bottom ifTrue: [self top: edgeBox bottom].
! !

!ScratchSpriteMorph methodsFor: 'private' stamp: 'jm 1/8/2006 18:33'!
layoutChanged
	"Update rotatedForm and offsetWhenRotated and compute new bounds."

	| refPoint |
	self changed.
	refPoint _ bounds origin + offsetWhenRotated.
	(rotationStyle == #none and: [scalePoint = (1.0@1.0)])
		ifTrue: [  "zero rotation and scale; use original Form"
			rotatedForm _ self costumeForm.
			offsetWhenRotated _ costume rotationCenter]
		ifFalse: [self generateRotatedForm].	"compute the new rotatedForm and offsetWhenRotated"

	bounds _ (refPoint - offsetWhenRotated) extent: rotatedForm extent.
	super layoutChanged.
	self changed.
! !

!ScratchSpriteMorph methodsFor: 'private' stamp: 'jm 11/29/2007 17:17'!
positionTalkBubble

	| bubble stage stageBounds y f r yInset strip x |
	(bubble _ self valueOfProperty: #talkBubble) ifNil: [^ self].
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ self].
	stageBounds _ stage bounds.

	f _ self imageForm.
	r _ f rectangleEnclosingPixelsNotOfColor: Color transparent.
	yInset _ 0.
	((r area = 0) or: [r height < 10])
		ifTrue: [r _ f boundingBox]
		ifFalse: [
			yInset _ (r top max: 0) min: (r height - 10).
			strip _ f copy: ((0@r top) extent: (f width@(10 min: f height))).
			r _ strip rectangleEnclosingPixelsNotOfColor: Color transparent].

	x _ self right - ((f width - r right) min: f width // 2).
	bubble pointLeft: true.
	((x + bubble width) <= stageBounds right) ifFalse: [
		x _ (self left - bubble width) + (r left min: (f width // 2)).
		bubble pointLeft: false].

	y _ (self top + yInset + 10 - bubble height) within: stageBounds top and: (stageBounds bottom - bubble height).
	bubble position: x@y.
	self layoutChanged.
! !

!ScratchSpriteMorph methodsFor: 'private' stamp: 'jm 10/16/2007 19:06'!
rotateByFlipping
	"Compute my rotatedForm and offsetWhenRotated for unscaled rotation by a multiple of 90 degrees."

	| a center srcForm |
	a _ rotationDegrees rounded \\ 360.
	a < 0 ifTrue: [a _ a + 360].
	srcForm _ self costumeForm.
	center _ costume rotationCenter.
	0 = a ifTrue: [
		rotatedForm _ srcForm.
		offsetWhenRotated _ center].
	90 = a ifTrue: [
		rotatedForm _ srcForm rotateBy: #right centerAt: 0@0.
		offsetWhenRotated _ (srcForm height - 1 - center y) @ center x].
	180 = a ifTrue: [
		rotatedForm _ srcForm rotateBy: #pi centerAt: 0@0.
		offsetWhenRotated _ srcForm extent - 1 - center].
	270 = a ifTrue: [
		rotatedForm _ srcForm rotateBy: #left centerAt: 0@0.
		offsetWhenRotated _ center y @ (srcForm width - 1 - center x)].

! !

!ScratchSpriteMorph methodsFor: 'private' stamp: 'jm 6/2/2004 19:17'!
rotationDegrees: newRotationDegrees scalePoint: newScalePoint

	((newRotationDegrees ~= rotationDegrees) or:
	 [scalePoint ~= newScalePoint]) ifTrue: [
		rotationDegrees _ newRotationDegrees asFloat \\ 360.0.
		scalePoint _ newScalePoint.
		self costumeChanged].
! !


!ScratchSpriteMorph methodsFor: 'handle ops' stamp: 'jens 10/27/2008 10:58'!
resizeHandle

	SpriteHandleMorph resize: self! !

!ScratchSpriteMorph methodsFor: 'handle ops' stamp: 'jens 10/27/2008 12:53'!
rotateHandle

	SpriteHandleMorph rotate: self! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchSpriteMorph class
	instanceVariableNames: ''!

!ScratchSpriteMorph class methodsFor: 'block specs' stamp: 'EMP 4/11/2016 15:29'!
blockSpecs

	| blocks |
	blocks _ #(
			'control'
			('wait %n secs'					t	wait:elapsed:from: 1)).
	(ScratchFrameMorph getSetting: #enableOthers) ifTrue: [blocks _ blocks, #(
			('counter'						r	#COUNT)
			('increment counter'			-	#'INCR_COUNT')
			('reset counter'					-	#'CLR_COUNT'))].
	blocks _ blocks, #(
			-
			('forever'						c	doForever)
			('repeat %n'						c	doRepeat 10)
			-
			('if %b'							c	doIf)
			('if %b'							c	doIfElse)).
	(ScratchFrameMorph getSetting: #enableOthers) ifTrue: [blocks _ blocks, #(
			('for each %m.var from 1 to %n'			c	doForLoop))].
	blocks _ blocks, #(
			('wait until %b'					s	doWaitUntil)
			('repeat until %b'				c	doUntil)).
	(ScratchFrameMorph getSetting: #enableOthers) ifTrue: [blocks _ blocks, #(
			('while %b'						c	doWhile)
			('all at once'					c	warpSpeed))].
	blocks _ blocks, #(
			-
			"('stop script'					s	doReturn)
			('stop all'						-	stopAll)"
			('stop %m.stop'	s	stopScripts 'all')
			-
			('when I start as a clone'		C	-)
			('create clone of %m.spriteOnly'			-	createCloneOf)
			('delete clone'					-	deleteClone)
			"-
			('report %s'						s	report)
			xxx This was for a beta of custom reporters; getting more stable now that the argument is accepted as a reporter too"
		'motion'
			('move %n steps'				-	forward:)
			('turn @turnRight %n degrees'				-	turnRight: 15)	"icon shows turn direction"
			('turn @turnLeft %n degrees'				-	turnLeft: 15)	"icon shows turn direction"
			-
			('point in direction %d.direction'			-	heading: 90)
			('point towards %m.spriteOrMouse'				-	pointTowards:)
			-
			('go to x:%n y:%n'				-	gotoX:y: 0 0)
			('go to %m.location'						-	gotoSpriteOrMouse:)
			('glide %n secs to x:%n y:%n'	t	glideSecs:toX:y:elapsed:from: 1 50 50)
			-
			('change x by %n'				-	changeXposBy: 10)
			('set x to %n'					-	xpos: 0)
			('change y by %n'				-	changeYposBy: 10)
			('set y to %n'					-	ypos: 0)
			-
			('if on edge, bounce'			-	bounceOffEdge)
			-
			('set rotation style %m.rotationStyle'			-	setRotStyle:)
			-
			('x position'						r	xpos)
			('y position'						r	ypos)
			('direction'						r	heading)
		'pen'
			('clear'							-	clearPenTrails)
			-
			('stamp'							-	stampCostume)
			-
			('pen down'						-	putPenDown)
			('pen up'						-	putPenUp)
			-
			('set pen color to %c'			-	penColor:)
			('change pen color by %n'		-	changePenHueBy:)
			('set pen color to %n'			-	setPenHueTo: 0)
			-
			('change pen shade by %n'		-	changePenShadeBy:)
			('set pen shade to %n'			-	setPenShadeTo: 50)
			-
			('change pen size by %n'		-	changePenSizeBy: 1)
			('set pen size to %n'				-	penSize: 1)
	).

	blocks _ blocks, #(
		'looks'
			('say %s for %n secs'			t	say:duration:elapsed:from: 'Hello!!' 2)
			('say %s'						-	say: 'Hello!!')
			('think %s for %n secs'			t	think:duration:elapsed:from: 'Hmm...' 2)
			('think %s'						-	think: 'Hmm...')
			-
			('show'							-	show)
			('hide'							-	hide)
			-
			('switch to costume %m.costume'			-	lookLike:)
			('next costume'					-	nextCostume)
			('switch to backdrop %m.backdrop'		-	startScene)
			('switch backdrop to %m.backdrop and wait' s startSceneAndWait 'backdrop1')
			-
			('change %m.effect effect by %n'		-	changeGraphicEffect:by: 'color' 25)
			('set %m.effect effect to %n'			-	setGraphicEffect:to: 'color' 0)
			('clear graphic effects'			-	filterReset)
			-
			('change size by %n'			-	changeSizeBy:)
			('set size to %n %'				-	setSizeTo: 100)
			-
			('go to front'					-	comeToFront)
			('go back %n layers'			-	goBackByLayers: 1)
			-
			('costume #'						r	costumeIndex)).
	(ScratchFrameMorph getSetting: #enableOthers) ifTrue: [blocks _ blocks, #(
			('backdrop name'				r	backdropName)
			('costume name'					r	costumeName))].
	blocks _ blocks, #(
			('size'							r	scale)
		'sensing'
			('touching %m.touching ?' 				b	touching:)
			('touching color %c ?' 			b	touchingColor:)
			('color %c is touching %c ?'		b	color:sees:)
			('distance to %m.spriteOrMouse'				r	distanceTo:)
			-
			('ask %s and wait'				s	doAsk 'What''s your name?')
			('answer'						r	answer)
			-
			('key %m.key pressed?'				b	keyPressed: 'space')
			('mouse down?'					b	mousePressed)
			('mouse x'						r	mouseX)
			('mouse y'						r	mouseY)
			-
			('loudness'						r	soundLevel)
			('loud?'							b	isLoud)
			-
			('timer'							r	timer)
			('reset timer'					-	timerReset)
			-
			('%m.attribute of %m.spriteOrStage'	r	getAttribute:of:)
			-
			('current %m.timeAndDate'					r	timeAndDate)
			('days since 2000'				r	timestamp)
			('username'						r	getUserName)
		).

	^ blocks, super blockSpecs
! !
