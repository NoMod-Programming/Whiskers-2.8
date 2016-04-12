PaintColorPicker subclass: #PaintColorSquarePicker
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Paint'!

!PaintColorSquarePicker methodsFor: 'initialization' stamp: 'ee 11/6/2005 15:19'!
createColorPickers
	"Overridden to do nothing"! !

!PaintColorSquarePicker methodsFor: 'initialization' stamp: 'EMP 12/22/2015 15:51'!
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
		useSquareCorners;
		actionSelector: #setColor:.

	swatch firstSubmorph delete. "remove label, which can cause layout issue with scaled up fonts"
	swatch extent: 12@12.

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
		b _ swatch fullCopy color: thisColor; arguments: (Array with: thisColor).
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

!PaintColorSquarePicker methodsFor: 'initialization' stamp: 'ee 11/6/2005 15:18'!
initialize

	super initialize.
	self createColorSwatches.! !


!PaintColorSquarePicker methodsFor: 'event handling' stamp: 'jm 11/20/2005 23:09'!
handlesMouseDown: evt

	^ false
! !

!PaintColorSquarePicker methodsFor: 'event handling' stamp: 'jm 11/27/2007 16:07'!
setColor: aColor

	target ifNil: [^ self].

	Sensor shiftPressed | Sensor rightButtonPressed
		ifTrue: [selector2 ifNotNil: [target perform: selector2 with: aColor]]
		ifFalse: [selector ifNotNil: [target perform: selector with: aColor]].
! !


!PaintColorSquarePicker methodsFor: 'geometry' stamp: 'ee 11/12/2005 12:48'!
extent: aPoint

	bounds extent = aPoint ifFalse: [
		bounds _ bounds topLeft extent: aPoint.
		self layoutChanged.
		self changed].
! !
