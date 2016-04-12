Morph subclass: #PaintColorPicker
	instanceVariableNames: 'selectedColor target selector selector2 shadePickerContainer colorPickerImage colorPickerContainer shadePickerImage '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Paint'!

!PaintColorPicker methodsFor: 'initialization' stamp: 'ee 2/21/2009 10:47'!
createColorPickers

	colorPickerContainer _ BorderedMorph new.
	colorPickerImage _ ImageMorph new.
	colorPickerContainer
		borderWidth: 1;
		borderColor: (Color r: 0.505 g: 0.505 b: 0.505);
		extent: 500@500;
		addMorph: colorPickerImage.
	self addMorph: colorPickerContainer.
	colorPickerImage position: colorPickerImage position + (1@1).

	shadePickerContainer _ BorderedMorph new.
	shadePickerImage _ ImageMorph new.
	shadePickerContainer
		borderWidth: 1;
		borderColor: (Color r: 0.505 g: 0.505 b: 0.505);
		addMorph: shadePickerImage.
	self addMorph: shadePickerContainer.
	shadePickerImage position: shadePickerImage position + (1@1).
! !

!PaintColorPicker methodsFor: 'initialization' stamp: 'ee 11/2/2005 18:35'!
createColorWheels

	| f h c f2 fx fy fx2 fy2 |
	fx _ colorPickerContainer width - 2.
	fy _ colorPickerContainer height - 2.
	f _ Form extent: fx@fy depth: 32.
	fx2 _ shadePickerContainer width - 2.
	fy2 _ shadePickerContainer height - 2.
	f2 _ Form extent: fx2@fy2 depth: 32.

	0 to: fx do: [:x |
		h _ x * 360 // fx.
		0 to: (fy // 2) do: [:y |
			c _ Color h: h s: (y / (fy // 2)) v: 1.0.
			f fill: (x@y extent: 1) fillColor: c].
		((fy // 2) + 1) to: fy do: [:y |
			c _ Color h: h s: 1.0 v: (fy - y) / (fy // 2).
			f fill: (x@y extent: 1) fillColor: c]].
	0 to: fx2 do: [:x |
		c _ Color gray: (x / fx2).
		f2 fill: ((x@0) extent: (1@fy2)) fillColor: c].

	colorPickerImage form: f.
	shadePickerImage form: f2.
! !

!PaintColorPicker methodsFor: 'initialization' stamp: 'EMP 12/18/2015 11:18'!
initialize

	super initialize.
	selectedColor _ Color black.
	target _ selector _ nil.
	self createColorPickers.
	self color: (Color r: 246/255 g: 246/255 b: 246/255).
	self extent: 20@20.! !


!PaintColorPicker methodsFor: 'accessing' stamp: 'ee 11/2/2005 17:05'!
selectedColor

	^ selectedColor
! !

!PaintColorPicker methodsFor: 'accessing' stamp: 'ee 11/2/2005 17:05'!
selector

	^ selector
! !

!PaintColorPicker methodsFor: 'accessing' stamp: 'ee 11/16/2005 21:57'!
selector2

	^ selector2
! !

!PaintColorPicker methodsFor: 'accessing' stamp: 'ee 11/16/2005 22:01'!
selector2: sel

	(sel isNil or: [sel = 'nil' or: [sel isEmpty]])
		ifTrue: [selector2 _ nil]
		ifFalse: [selector2 _ sel asSymbol].! !

!PaintColorPicker methodsFor: 'accessing' stamp: 'ee 11/2/2005 17:05'!
selector: sel

	(sel isNil or: [sel = 'nil' or: [sel isEmpty]])
		ifTrue: [selector _ nil]
		ifFalse: [selector _ sel asSymbol].
! !

!PaintColorPicker methodsFor: 'accessing' stamp: 'ee 11/2/2005 17:05'!
target

	^ target
! !

!PaintColorPicker methodsFor: 'accessing' stamp: 'ee 11/2/2005 17:05'!
target: anObject

	target _ anObject.
! !


!PaintColorPicker methodsFor: 'geometry' stamp: 'jm 11/15/2005 16:57'!
extent: newExtent

	newExtent = self extent ifFalse: [
		super extent: newExtent.
		(colorPickerContainer notNil and:
		 [shadePickerContainer notNil]) ifTrue: [
			colorPickerContainer
				extent: (newExtent x - 8)@(newExtent y - 22);
				position: (self left + 4)@(self top + 4).
			shadePickerContainer
				extent: (newExtent x - 8)@(9);
				position: (self left + 4)@(self bottom - 15).
			self createColorWheels]].
! !


!PaintColorPicker methodsFor: 'event handling' stamp: 'ee 11/2/2005 17:05'!
handlesMouseDown: evt

	^ true
! !

!PaintColorPicker methodsFor: 'event handling' stamp: 'ee 11/16/2005 19:15'!
handlesMouseOver: evt

	^ true
! !

!PaintColorPicker methodsFor: 'event handling' stamp: 'ee 11/2/2005 17:05'!
mouseDown: evt

	self mouseMove: evt.
! !

!PaintColorPicker methodsFor: 'event handling' stamp: 'jm 3/26/2008 11:50'!
mouseEnter: evt

	evt hand showTemporaryCursor: Cursor eyeDropper asXOCursorForm.
! !

!PaintColorPicker methodsFor: 'event handling' stamp: 'jm 9/12/2006 22:50'!
mouseLeave: evt

	evt hand showTemporaryCursor: nil.
! !

!PaintColorPicker methodsFor: 'event handling' stamp: 'jm 11/27/2007 16:07'!
mouseMove: evt

	target ifNil: [^ self].

	((colorPickerImage bounds containsPoint: evt cursorPoint) or: [
	 (shadePickerImage bounds containsPoint: evt cursorPoint)]) ifTrue: [
		selectedColor _ Display colorAt: evt cursorPoint].

	evt shiftPressed | evt rightButtonPressed
		ifTrue: [selector2 ifNotNil: [target perform: selector2 with: selectedColor]]
		ifFalse: [selector ifNotNil: [target perform: selector with: selectedColor]].
! !

!PaintColorPicker methodsFor: 'event handling' stamp: 'ee 6/25/2009 10:59'!
mouseUp: evt
	'do nothing'
! !
