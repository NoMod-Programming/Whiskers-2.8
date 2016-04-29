PaintColorPicker subclass: #InlinePaintColorSquarePicker
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Paint'!

!InlinePaintColorSquarePicker methodsFor: 'initialization' stamp: 'EMP 12/21/2015 19:40'!
createColorPickers
	"Overridden to do nothing"! !

!InlinePaintColorSquarePicker methodsFor: 'initialization' stamp: 'EMP 12/22/2015 16:00'!
createColorSwatches

	| baseColors emptyRow swatchCol row thisColor b swatch spacer spacerRow c transparentSwatch |

	baseColors _ OrderedCollection new.
	#(0.0 0.4 0.5 0.7 0.8 0.9 1.0 1.0) do: [:x |
		c _ Color r: x g: x b: x.
		baseColors add: c].
	#(0.2 0.4 1.0) do: [:y |
		#(0 35 60 140 180 225 270 315) do: [:x |
			c _ Color h: x s: y v: 1.0.
			baseColors add: c]].
	#(0.8 0.6 0.4) do: [:y |
		#(0 35 60 140 180 225 270 315) do: [:x |
			c _ Color h: x s: 1.0 v: y.
			baseColors add: c]].

	emptyRow _ AlignmentMorph newRow
		color: Color transparent;
		inset: 0;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.

	spacer _ Morph new
		width: 2;
		height: 12;
		color: Color transparent.

	spacerRow _ Morph new
		width: self width;
		height: 2;
		color: Color transparent.

	swatch _ SimpleButtonMorph new
		borderWidth: 0;
		label: ' ';
		actWhen: #buttonDown;
		target: self;
		actionSelector: #setColor:.

	swatch firstSubmorph delete. "remove label, which can cause layout issue with scaled up fonts"
	swatch extent: 12@12.
	swatch useSquareCorners.

	transparentSwatch _ IconicButton new
		labelGraphic: (ScratchFrameMorph skinAt: #transparentSwatch);
		borderWidth: 0;
		target: self;
		actionSelector: #setColor:;
		extent: 12@12;
		arguments: (Array with: Color transparent).

	swatchCol _ AlignmentMorph newColumn color: Color transparent; inset: 0; hResizing: #rigid; vResizing: #rigid.
	row _ emptyRow fullCopy.
	1 to: (baseColors size) do: [:i |
		thisColor _ baseColors at: i.
		b _ swatch fullCopy color: thisColor; arguments: (Array with: thisColor); useSquareCorners.
		row ifNil: [row _ emptyRow fullCopy].
		(i = 8) ifTrue: [row addMorphBack: transparentSwatch] ifFalse: [
		row addMorphBack: b].
		row addMorphBack: spacer fullCopy.
		(i \\ 8) = 0 ifTrue: [  "start a new row"
			swatchCol addMorphBack: row.
			swatchCol addMorphBack: spacerRow fullCopy.
			row _ emptyRow fullCopy]].

	self addMorph: swatchCol.
	swatchCol position: (self topLeft) + (5@5).
! !

!InlinePaintColorSquarePicker methodsFor: 'initialization' stamp: 'EMP 12/21/2015 19:40'!
initialize

	super initialize.
	self createColorSwatches.! !


!InlinePaintColorSquarePicker methodsFor: 'event handling' stamp: 'EMP 12/21/2015 19:40'!
handlesMouseDown: evt

	^ false
! !

!InlinePaintColorSquarePicker methodsFor: 'event handling' stamp: 'EMP 12/21/2015 19:40'!
setColor: aColor

	target ifNil: [^ self].

	Sensor shiftPressed | Sensor rightButtonPressed
		ifTrue: [selector2 ifNotNil: [target perform: selector2 with: aColor]]
		ifFalse: [selector ifNotNil: [target perform: selector with: aColor]].
! !


!InlinePaintColorSquarePicker methodsFor: 'geometry' stamp: 'EMP 12/21/2015 19:40'!
extent: aPoint

	bounds extent = aPoint ifFalse: [
		bounds _ bounds topLeft extent: aPoint.
		self layoutChanged.
		self changed].
! !
