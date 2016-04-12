Morph subclass: #InlinePaintColorPicker
	instanceVariableNames: 'selectedColor target selector selector2 colorPickerImage colorPickerContainer sliderMorph lastValue '
	classVariableNames: 'StoredForms '
	poolDictionaries: ''
	category: 'Scratch-Paint'!

!InlinePaintColorPicker methodsFor: 'initialization' stamp: 'EMP 12/22/2015 14:42'!
createColorPickers

	"colorPickerContainer _ BorderedMorph new."
	colorPickerImage _ ImageMorph new.
	"colorPickerContainer
		borderWidth: 1;
		borderColor: (Color r: 0.505 g: 0.505 b: 0.505);
		extent: 500@500;
		addMorph: colorPickerImage.
	self addMorph: colorPickerContainer."
	self addMorph: colorPickerImage.

	sliderMorph _ GrayscaleSliderMorph new.
	sliderMorph target: self; actionSelector: #grayscaleValue:;minVal: 0; maxVal: 100; adjustToValue: 0.0.
	self addMorph: sliderMorph.
	sliderMorph position: (colorPickerImage topRight + (3@0)).
! !

!InlinePaintColorPicker methodsFor: 'initialization' stamp: 'EMP 12/22/2015 14:42'!
createColorWheels

	| f h c fx fy |
	fx _ colorPickerImage width.
	fy _ colorPickerImage height.
	f _ Form extent: fx@fy depth: 32.
	(StoredForms isKindOf: Dictionary) ifFalse: [StoredForms _ Dictionary new].
	(StoredForms includesKey: (sliderMorph value)) ifTrue: [^ colorPickerImage form: (StoredForms at: (sliderMorph value))].
	0 to: fx do: [:x |
		h _ x * 360 // fx.
		0 to: (fy) do: [:y |
			c _ Color h: h s: 1 l: 1 - (y / (fy + 85)).
			c _ c mixed: (1 - sliderMorph value) with: Color black.
			f fill: (x@y extent: 1) fillColor: c]].
	StoredForms at: (sliderMorph value) put: f.
	colorPickerImage form: f.! !

!InlinePaintColorPicker methodsFor: 'initialization' stamp: 'EMP 12/22/2015 13:06'!
grayscaleValue: aValue
	(aValue < (lastValue - 0.05)) | (aValue > (lastValue + 0.05)) ifTrue: [self createColorWheels "Recreate the color values". lastValue _ aValue].! !

!InlinePaintColorPicker methodsFor: 'initialization' stamp: 'EMP 12/22/2015 12:48'!
initialize

	super initialize.
	selectedColor _ Color black.
	target _ selector _ nil.
	self createColorPickers.
	self color: (Color r: 246/255 g: 246/255 b: 246/255).
	lastValue _ -1.
	self extent: 20@20.! !

!InlinePaintColorPicker methodsFor: 'initialization' stamp: 'EMP 12/21/2015 19:57'!
stuff
	^ ((sliderMorph value * 1000) asInteger / 1000)! !


!InlinePaintColorPicker methodsFor: 'accessing' stamp: 'EMP 12/21/2015 19:40'!
selectedColor

	^ selectedColor
! !

!InlinePaintColorPicker methodsFor: 'accessing' stamp: 'EMP 12/21/2015 19:40'!
selector

	^ selector
! !

!InlinePaintColorPicker methodsFor: 'accessing' stamp: 'EMP 12/21/2015 19:40'!
selector2

	^ selector2
! !

!InlinePaintColorPicker methodsFor: 'accessing' stamp: 'EMP 12/21/2015 19:40'!
selector2: sel

	(sel isNil or: [sel = 'nil' or: [sel isEmpty]])
		ifTrue: [selector2 _ nil]
		ifFalse: [selector2 _ sel asSymbol].! !

!InlinePaintColorPicker methodsFor: 'accessing' stamp: 'EMP 12/21/2015 19:40'!
selector: sel

	(sel isNil or: [sel = 'nil' or: [sel isEmpty]])
		ifTrue: [selector _ nil]
		ifFalse: [selector _ sel asSymbol].
! !

!InlinePaintColorPicker methodsFor: 'accessing' stamp: 'EMP 12/21/2015 19:40'!
target

	^ target
! !

!InlinePaintColorPicker methodsFor: 'accessing' stamp: 'EMP 12/21/2015 19:40'!
target: anObject

	target _ anObject.
! !


!InlinePaintColorPicker methodsFor: 'geometry' stamp: 'EMP 12/22/2015 14:41'!
extent: newExtent

	newExtent = self extent ifFalse: [
		super extent: newExtent.
		(colorPickerImage notNil and:
		 [sliderMorph notNil]) ifTrue: [
			sliderMorph 
				extent: (10@(newExtent y - 8)).
			colorPickerImage
				extent: (newExtent x - (sliderMorph slider width + 8))@(newExtent y - 8);
				position: (self left + 5)@(self top + 5).
			sliderMorph position: (colorPickerImage right + 4)@(self top + 4)]].

	self createColorWheels! !


!InlinePaintColorPicker methodsFor: 'event handling' stamp: 'EMP 12/21/2015 19:40'!
handlesMouseDown: evt

	^ true
! !

!InlinePaintColorPicker methodsFor: 'event handling' stamp: 'EMP 12/21/2015 19:40'!
handlesMouseOver: evt

	^ true
! !

!InlinePaintColorPicker methodsFor: 'event handling' stamp: 'EMP 12/21/2015 19:40'!
mouseDown: evt

	self mouseMove: evt.
! !

!InlinePaintColorPicker methodsFor: 'event handling' stamp: 'EMP 12/21/2015 19:40'!
mouseEnter: evt

	evt hand showTemporaryCursor: Cursor eyeDropper asXOCursorForm.
! !

!InlinePaintColorPicker methodsFor: 'event handling' stamp: 'EMP 12/21/2015 19:40'!
mouseLeave: evt

	evt hand showTemporaryCursor: nil.
! !

!InlinePaintColorPicker methodsFor: 'event handling' stamp: 'EMP 12/21/2015 20:07'!
mouseMove: evt

	target ifNil: [^ self].

	(colorPickerImage bounds containsPoint: evt cursorPoint) ifTrue: [
		selectedColor _ Display colorAt: evt cursorPoint].

	evt shiftPressed | evt rightButtonPressed
		ifTrue: [selector2 ifNotNil: [target perform: selector2 with: selectedColor]]
		ifFalse: [selector ifNotNil: [target perform: selector with: selectedColor]].
! !

!InlinePaintColorPicker methodsFor: 'event handling' stamp: 'EMP 12/21/2015 19:40'!
mouseUp: evt
	'do nothing'
! !
