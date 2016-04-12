Morph subclass: #InlinePaintOptionsChooser
	instanceVariableNames: 'sliderMorph sampleMorph lastPenSize palette mode showRotationCenter eraserSize borderWidth fillStyle fillStylePane '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Paint'!

!InlinePaintOptionsChooser methodsFor: 'defined' stamp: 'EMP 12/22/2015 15:40'!
brushSize: penSize
	"This one only updates the morph's view"
	sampleMorph height: penSize.
	sampleMorph width: (self width - 6).
	self extent: self extent! !

!InlinePaintOptionsChooser methodsFor: 'defined' stamp: 'EMP 3/23/2016 14:49'!
extent: aPoint
	super extent: aPoint.

	sliderMorph extent: ((aPoint x - 4) @ 10).
	sliderMorph position: ((self left + 2) @ (self bottom - sliderMorph slider height)).
	sampleMorph ifNotNil: [
	sampleMorph center: (self center x) @ (self bottom - (23 + sliderMorph slider height))].! !

!InlinePaintOptionsChooser methodsFor: 'defined' stamp: 'EMP 3/23/2016 14:13'!
initialize
	super initialize.
	self mode: #paint.

	sampleMorph _ BorderedMorph new borderColor: (Color black); color: (Color black); cornerStyle: #rounded; extent: 100@16.
	self addMorph: sampleMorph.
	lastPenSize _ 1.
	self extent: 100@50.


	self borderWidth: 0.
	self color: Color red.
	self brushSize: 3.
	eraserSize _ 13.
	self shapeFilling: true.
	self fillStyle: #color.
	showRotationCenter _ false.
	self updateOptionsPane.! !

!InlinePaintOptionsChooser methodsFor: 'defined' stamp: 'EMP 1/11/2016 14:28'!
mode 
	^ mode ifNil: [mode _ #paint].! !

!InlinePaintOptionsChooser methodsFor: 'defined' stamp: 'EMP 1/11/2016 14:36'!
mode: aMode
	mode _ aMode.
	self updateOptionsPane.! !

!InlinePaintOptionsChooser methodsFor: 'defined' stamp: 'EMP 12/22/2015 15:28'!
palette
	^ palette! !

!InlinePaintOptionsChooser methodsFor: 'defined' stamp: 'EMP 12/22/2015 15:28'!
palette: aMorph
	^ palette _ aMorph! !

!InlinePaintOptionsChooser methodsFor: 'defined' stamp: 'EMP 3/23/2016 14:34'!
penSize: penSize

	sampleMorph height: penSize.
	sampleMorph width: (self width - 6).
	sampleMorph color: (palette color1).
	sampleMorph borderColor: (palette color1).
	self extent: self extent.
	palette ifNotNil: [palette brushSize: penSize].! !


!InlinePaintOptionsChooser methodsFor: 'undefined' stamp: 'EMP 1/11/2016 14:51'!
borderWidth: aNumber! !

!InlinePaintOptionsChooser methodsFor: 'undefined' stamp: 'EMP 3/24/2016 11:08'!
fillStyle: aSymbol
	fillStyle _ aSymbol! !

!InlinePaintOptionsChooser methodsFor: 'undefined' stamp: 'EMP 3/24/2016 12:16'!
otherFillStyle: aSymbol
	fillStyle _ aSymbol.
	palette fillStyle: aSymbol.
	self updateOptionsPane! !

!InlinePaintOptionsChooser methodsFor: 'undefined' stamp: 'EMP 3/24/2016 12:25'!
otherShapeFilling: ashapeFilling
	palette shapeFilling: ashapeFilling.
	self updateOptionsPane! !

!InlinePaintOptionsChooser methodsFor: 'undefined' stamp: 'EMP 1/11/2016 14:22'!
shapeFilling: ashapeFilling! !

!InlinePaintOptionsChooser methodsFor: 'undefined' stamp: 'EMP 4/5/2016 11:50'!
updateOptionsPane
	
	| b form formMorph spacer r q font fName textFontMenu textFontMorph textSizeMenu textSizeMorph aColor2 |
	(#(paint erase line) includes: self mode) ifTrue: [
	fillStylePane ifNotNil: [fillStylePane delete].	
	sliderMorph ifNotNil: [sliderMorph delete].
	sliderMorph _ ScratchSliderNotifyingMorph new maxVal: 32; minVal: 1; actionSelector: #penSize:; value: (((palette brushSize) + 1) / 33); target: self; notif: self; notifAction: #penSize:.
	self addMorph: sliderMorph.
	self addMorph: sampleMorph.
	^ self extent: (self extent) "redo layout"].

	(#(oval rect) includes: self mode) ifTrue:[
	sliderMorph ifNotNil: [sliderMorph delete].
	sampleMorph ifNotNil: [sampleMorph delete].
	fillStylePane ifNotNil: [fillStylePane delete].
	fillStylePane _ AlignmentMorph newRow
		inset: 0;
		borderWidth: 0;
		color: Color transparent;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap.
	sliderMorph _ ScratchSliderNotifyingMorph new maxVal: 32; minVal: 1; actionSelector: #borderWidth:; value: 16; target: self; notif: self; notifAction: #penSize:.
	self addMorph: sliderMorph.
	self addMorph: sampleMorph.


b _ ToggleButton onForm: (ScratchFrameMorph skinAt: #paintOptionsButtonPressed)
					 offForm: (ScratchFrameMorph skinAt: #paintOptionsButton).
		b
			target: self;
			actionSelector: #otherShapeFilling:;
			arguments: (Array with: true);
			toggleMode: false.
		palette shapeFilling ifTrue: [b on].
		(self mode = #oval)
			ifTrue: [form _ Form extent: 16@17 depth: 16.
					(FormCanvas on: form) fillOval: form boundingBox color: palette color1.
					formMorph _ ImageMorph new form: form; position: 7@5]
			ifFalse: [form _ Form extent: 16@17 depth: 8. form fillColor: self color1.
					formMorph _ ImageMorph new form: form; position: 7@5].
		b addMorph: formMorph.
		fillStylePane addMorphBack: b.
		fillStylePane addMorphBack: (Morph new extent: 5@2; color: Color transparent).
		b _ ToggleButton onForm: (ScratchFrameMorph skinAt: #paintOptionsButtonPressed)
					 offForm: (ScratchFrameMorph skinAt: #paintOptionsButton).
		b
			target: self;
			actionSelector: #otherShapeFilling:;
			arguments: (Array with: false);
			toggleMode: false.
		palette shapeFilling ifFalse: [b on].
		(self mode = #oval)
			ifTrue: [form _ Form extent: 16@17 depth: 16.
					(FormCanvas on: form) frameOval: form boundingBox width: 2 color: palette color1.
					formMorph _ ImageMorph new form: form; position: 7@5]
			ifFalse: [form _ Form extent: 16@17 depth: 8. form border: (0@0 extent: 16@17) width: 2 fillColor: self color1.
					formMorph _ ImageMorph new form: form; position: 7@5].
		b addMorph: formMorph.
		fillStylePane addMorphBack: b.
	self addMorphBack: fillStylePane.
	fillStylePane center: (self center - (0@30)).

	^ self extent: (self extent) "redo layout"].
	
	(#fill = self mode) ifTrue: [
	sliderMorph ifNotNil: [sliderMorph delete].
	sampleMorph ifNotNil: [sampleMorph delete].
	fillStylePane ifNotNil: [fillStylePane delete].
	fillStylePane _ AlignmentMorph newRow
		inset: 0;
		borderWidth: 0;
		color: Color transparent;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap.
	r _ AlignmentMorph newColumn
		inset: 0;
		borderWidth: 0;
		color: Color transparent;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap.
		spacer _ Morph new extent: 5@5; color: Color transparent.
			#(color hGradient) do: [:style |
			b _ ResizableToggleButton2 onForm: (ScratchFrameMorph skinAt: #paintOptionsButtonPressed)
					 offForm: (ScratchFrameMorph skinAt: #paintOptionsButton).
			b extent: 34@34.
			b
				target: self;
				actionSelector: #otherFillStyle:;
				arguments: (Array with: style);
				toggleMode: false.
			form _ Form extent: 20@20 depth: 32.
			(style == #color) ifTrue: [form fillColor: palette color1].
			(style == #hGradient) ifTrue: [form fillFromXColorBlock: [:m | palette color2 mixed: m with: palette color1]].
			(style == #vGradient) ifTrue: [form fillFromYColorBlock: [:m | palette color2 mixed: m with: palette color1]].
			(style == #rGradient) ifTrue: [form fillRadialFromXColorBlock: [:m | palette color2 mixed: m with: palette color1] center: 10@10].
			formMorph _ ImageMorph new form: form; position: 7@5.
			formMorph lock.
			b addMorph: formMorph.
			b off.
			(style == palette fillStyle) ifTrue: [b on].
			r addMorphBack: spacer fullCopy.
			r addMorphBack: b.
			b position: b left@ b top + 2].

	fillStylePane addMorphBack: r.
			fillStylePane addMorphBack: spacer fullCopy.
	q _ AlignmentMorph newColumn
		inset: 0;
		borderWidth: 0;
		color: Color transparent;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap.

	#(vGradient rGradient) do: [:vstyle |
			b _ ResizableToggleButton2 onForm: (ScratchFrameMorph skinAt: #paintOptionsButtonPressed)
					 offForm: (ScratchFrameMorph skinAt: #paintOptionsButton).
			b extent: 34@34.
			b
				target: self;
				actionSelector: #otherFillStyle:;
				arguments: (Array with: vstyle);
				toggleMode: false.
			form _ Form extent: 20@20 depth: 32.
			(vstyle == #color) ifTrue: [form fillColor: palette color1].
			(vstyle == #hGradient) ifTrue: [form fillFromXColorBlock: [:m | palette color2 mixed: m with: palette color1]].
			(vstyle == #vGradient) ifTrue: [form fillFromYColorBlock: [:m | palette color2 mixed: m with: palette color1]].
			(vstyle == #rGradient) ifTrue: [form fillRadialFromXColorBlock: [:m | palette color2 mixed: m with: palette color1] center: 10@10].

			formMorph _ ImageMorph new form: form; position: 7@5.
			formMorph lock.
			b addMorph: formMorph.
			b off.
			(vstyle == palette fillStyle) ifTrue: [b on].
			q addMorphBack: spacer fullCopy.
			q addMorphBack: b.
			b position: b left@ b top + 2].
		fillStylePane addMorphBack: q.
		fillStylePane addMorphBack: spacer fullCopy.
		self addMorphBack: fillStylePane.
	fillStylePane center: (self center).
	].

	(#text = self mode) ifTrue: [
	sliderMorph ifNotNil: [sliderMorph delete].
	sampleMorph ifNotNil: [sampleMorph delete].
	fillStylePane ifNotNil: [fillStylePane delete].
	fillStylePane _ AlignmentMorph newRow
		inset: 0;
		borderWidth: 0;
		color: Color transparent;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap.
	font _ (StrikeFont fontName: 'VerdanaBold' size: 11).
		fName _ palette canvasMorph canvasTextBox font name.
		textFontMenu _ ImageMorph new form: (ScratchFrameMorph skinAt: #textFontMenu).
		textFontMorph _ StringMorph new font: font.
		textFontMorph contents: (textFontMorph stringWithEllipses: fName limitedToWidth: 109).
		textFontMenu addMorph: textFontMorph.
		textFontMorph position: 8@3.
		textSizeMenu _ ImageMorph new form: (ScratchFrameMorph skinAt: #textSizeMenu).
		textSizeMorph _ StringMorph contents: palette canvasMorph canvasTextBox font pointSize asString font: font.
		textSizeMenu addMorph: textSizeMorph.
		textSizeMorph position: 9@3.
		aColor2 _ palette color1.
		(aColor2 == Color transparent) ifTrue: [aColor2 _ Color white].
			palette canvasMorph textColor: aColor2.
			palette canvasMorph changed.
		fillStylePane
			addMorphBack: textFontMenu;
			addMorphBack: (Morph new width: 8; height: 5; color: Color transparent);
			addMorphBack: textSizeMenu.
		self addMorphBack: fillStylePane.
	^ self extent: (self extent). "redo layout"
	].

	sampleMorph ifNotNil: [sampleMorph color: (palette color1).
	sampleMorph borderColor: (palette color1)].! !
