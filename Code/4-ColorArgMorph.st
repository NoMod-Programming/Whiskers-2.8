ArgMorph subclass: #ColorArgMorph
	instanceVariableNames: 'showPalette '
	classVariableNames: 'ColorPalette '
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!ColorArgMorph commentStamp: 'jm 3/12/2003 18:44' prior: 0!
I represent a color argument for a command block. Clicking on me allows the user to change my color value.
!


!ColorArgMorph methodsFor: 'initialization' stamp: 'jm 3/28/2005 18:15'!
initialize

	super initialize.
	self borderColor: (Color gray: 0.4).
	self borderWidth: 1.
	self extent: 13@13.
	showPalette _ true.
! !


!ColorArgMorph methodsFor: 'event handling' stamp: 'EMP 11/9/2015 14:13'!
acceptsDroppedReporters

	^ true
! !

!ColorArgMorph methodsFor: 'event handling' stamp: 'jm 4/26/2005 10:59'!
handlesMouseDown: evt

	^ evt hand toolType isNil
! !

!ColorArgMorph methodsFor: 'event handling' stamp: 'jm 12/13/2004 11:26'!
mouseUp: evt

	| w palette |
	showPalette ifNil: [showPalette _ true].

	(w _ self world) ifNil: [^ self].
	showPalette ifTrue: [
		palette _ ImageMorph new form: ColorPalette.
		palette position: self bounds bottomLeft + (0@5).
		w addMorph: palette.
		w displayWorldSafely].

	Cursor eyeDropper showWhile: [
		Sensor waitButton.
		[Sensor anyButtonPressed] whileTrue: [
			self color: (Display colorAt: Sensor cursorPoint).
			w displayWorldSafely]].

	palette ifNotNil: [palette delete].
! !


!ColorArgMorph methodsFor: 'other' stamp: 'EMP 11/9/2015 14:13'!
acceptsTypeOf: aBlockMorph
	"Answer true if I can accept a dropped reporter of the given type."

	aBlockMorph isReporter ifFalse: [^ false].
	^ aBlockMorph isBooleanReporter not  "must be a number"
! !

!ColorArgMorph methodsFor: 'other' stamp: 'jm 3/23/2005 18:12'!
defaultValue: aColor

	self setColor: aColor.
! !

!ColorArgMorph methodsFor: 'other' stamp: 'DaveF 7/11/2003 18:37'!
evaluate
	"Answer my color."

	^ color
! !

!ColorArgMorph methodsFor: 'other' stamp: 'jm 10/30/2005 09:01'!
hexFor: aNumber
	"Answer a string representing the given number, rounded, in hexadecimal."

	| s |
	s _ (255.0 * aNumber) rounded hex.
	s _ s copyFrom: 4 to: s size.
	s _ (String new: 2 - s size withAll: $0), s.  "pad to two digits"
	^ s
! !

!ColorArgMorph methodsFor: 'other' stamp: 'jm 10/30/2005 09:07'!
printArgOn: aStream
	"Print this argument morph on the given stream."

	aStream nextPutAll: 'c[',
		(self hexFor: color red),
		(self hexFor: color green),
		(self hexFor: color blue),
		']'.
! !

!ColorArgMorph methodsFor: 'other' stamp: 'EMP 11/24/2015 16:56'!
setColor: aColor
	| newColor |
	"Make sure the color is not translucent."
	newColor _ aColor.
	aColor isColor ifFalse: [newColor _ (ScratchSpriteMorph new tryExtractColorFrom: aColor)].
	self color: (newColor alpha: 1.0).
! !

!ColorArgMorph methodsFor: 'other' stamp: 'jm 3/11/2004 11:55'!
showPalette: aBoolean

	showPalette _ aBoolean.
! !


!ColorArgMorph methodsFor: 'object i/o' stamp: 'jm 3/14/2004 13:08'!
fieldsVersion

	^ 1
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ColorArgMorph class
	instanceVariableNames: ''!

!ColorArgMorph class methodsFor: 'class initialization' stamp: 'jm 6/25/2004 13:54'!
colorPaletteExtent: extent
	"Answer a form containing a palette of colors sorted horizontally by hue and vertically by lightness."
	"(self colorPaletteExtent: 180@100) display"

	| palette grayWidth startHue vSteps hSteps x basicHue y c |
	palette _ Form extent: extent depth: 32.
	grayWidth _ 10.
	startHue _ 338.0.
	vSteps _ palette height // 2.
	hSteps _ palette width - grayWidth.
	x _ 0.
	startHue to: startHue + 360.0 by: 360.0 / hSteps do: [:h |
		basicHue _ Color h: h asFloat s: 1.0 v: 1.0.
		y _ 1.
		0 to: vSteps do: [:n |
 			c _ basicHue mixed: (n asFloat / vSteps asFloat) with: Color white.
			palette fill: (x@y extent: 1@1) fillColor: c.
			y _ y + 1].
		1 to: vSteps do: [:n |
 			c _ Color black mixed: (n asFloat / vSteps asFloat) with: basicHue.
			palette fill: (x@y extent: 1@1) fillColor: c.
			y _ y + 1].
		x _ x + 1].

	y _ 1.
	1 to: vSteps * 2 do: [:n |
 		c _ Color black mixed: (n asFloat / (2 * vSteps) asFloat) with: Color white.
		palette fill: (x@y extent: 10@1) fillColor: c.
		y _ y + 1].

	^ palette
! !

!ColorArgMorph class methodsFor: 'class initialization' stamp: 'jm 6/28/2004 10:41'!
initialize
	"self initialize. ColorPalette display"

	ColorPalette _ self colorPaletteExtent: 150@100.
! !


ColorArgMorph initialize!
