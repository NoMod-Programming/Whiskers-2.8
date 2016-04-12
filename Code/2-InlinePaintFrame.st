Morph subclass: #InlinePaintFrame
	instanceVariableNames: 'colorPicker canvasMorph canvasButtons colorSquarePicker colorPickerButton paletteMorph hScrollbar vScrollbar fileButtons setRotationCenterMorph setRotationCenterButton transformButtons zoomBar originalObject oldCostumeName deleteSpriteOnCancel scratchFrame nameMorph colorSwitcher optionsPanel '
	classVariableNames: 'ColorPicker SquareColorPicker '
	poolDictionaries: ''
	category: 'Scratch-Paint'!
!InlinePaintFrame commentStamp: 'EMP 12/22/2015 14:43' prior: 0!
See comment in PaintFrame. This version does not need a DialogBoxMorph to use.!


!InlinePaintFrame methodsFor: 'initialization' stamp: 'EMP 12/16/2015 15:05'!
addButtons

	| b |
	fileButtons _ AlignmentMorph newRow
		color: Color transparent;
		vResizing: #rigid;
		width: 233;
		inset: 0.
	canvasButtons _ AlignmentMorph newRow
		color: Color transparent;
		vResizing: #shrinkWrap;
		inset: 0.

	b _ self makeButtonLabel: 'Undo' selector:  #undo.
	b setProperty: #balloonText toValue: 'Undo' localized.
	canvasButtons addMorphBack: b.

	b _ self makeButtonLabel: 'Redo' selector:  #redo.
	b setProperty: #balloonText toValue: 'Redo' localized.
	canvasButtons addMorphBack: b.


	b _ ResizableToggleButton2 new
		offForm: (ScratchFrameMorph skinAt: #paintUtilityButton)
			onForm: (ScratchFrameMorph skinAt: #paintUtilityButtonPressed);
		label: 'Clear' localized font: (ScratchFrameMorph getFont: #PaintUtilityButton);
		target: canvasMorph;
		actionSelector: #eraseAll;
		setProperty: #balloonText toValue: 'Clear canvas' localized.
	fileButtons addMorphBack: (AlignmentMorph newSpacer: Color transparent).
	fileButtons addMorphBack: b.
	b _ self makeButtonLabel: 'Import' selector:  #import.
	b setProperty: #balloonText toValue: 'Import an image on top of your current canvas' localized.
	fileButtons addMorphBack: b.

	self addMorph: fileButtons.
	self addMorph: canvasButtons.
	self addMorph: self makeZoomBar.
! !

!InlinePaintFrame methodsFor: 'initialization' stamp: 'EMP 12/21/2015 19:41'!
addColorChoosers
	"ColorPicker _ SquareColorPicker _ nil.  122@110"

	"color picker is somewhat slow to create, so cache one and copy it"
	(ColorPicker isNil or:
	 [ColorPicker extent ~= (112@108)]) ifTrue: [
		ColorPicker _ InlinePaintColorPicker new
			selector: #color1:;
			selector2: #color2:;
			extent: 120@108].
	colorPicker _ ColorPicker fullCopy target: canvasMorph palette.

	SquareColorPicker ifNil: [
		SquareColorPicker _ InlinePaintColorSquarePicker new
			selector: #color1:;
			selector2: #color2:;
			extent: 120@108].
	colorSquarePicker _ SquareColorPicker fullCopy target: canvasMorph palette.

	colorPickerButton _ ToggleButton
		onForm: (ScratchFrameMorph skinAt: #squareColorSquare)
		offForm: (ScratchFrameMorph skinAt: #colorSquare).
	colorPickerButton
		color: Color transparent;
		target: self;
		borderWidth: 0;
		actionSelector: #presentColorPicker;
		actWhen: #buttonUp.

	self addMorph: colorPickerButton.
	self addMorph: colorSquarePicker.
! !

!InlinePaintFrame methodsFor: 'initialization' stamp: 'EMP 12/16/2015 11:02'!
addScrollbarsAndBevel

	self addMorph: (
		hScrollbar _ ScratchScrollBar newHorizontal
			target: canvasMorph;
			selector: #scrollFractionX:).
	self addMorph: (
		vScrollbar _ ScratchScrollBar newVertical
			target: canvasMorph;
			selector: #scrollFractionY:).! !

!InlinePaintFrame methodsFor: 'initialization' stamp: 'EMP 12/18/2015 11:39'!
addSetRotationCenterButton

	setRotationCenterMorph _ AlignmentMorph newRow
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		inset: 0;
		centering: #center.

	"make components"
	setRotationCenterButton _ ToggleButton
		onForm: (ScratchFrameMorph skinAt: #paintSetRotCenterButtonPressed)
		offForm: (ScratchFrameMorph skinAt: #paintSetRotCenterButton) overForm: (ScratchFrameMorph skinAt: #paintSetRotCenterButtonPressed).
	setRotationCenterButton
		target: paletteMorph;
		actionSelector: #toggleRotationPoint;
		setProperty: #balloonText toValue: 'Position the cross-hair to set the rotation center' localized.

	"add components"
	setRotationCenterMorph
		addMorphBack: setRotationCenterButton.

	"add bar to frame"
	self addMorph: setRotationCenterMorph.
! !

!InlinePaintFrame methodsFor: 'initialization' stamp: 'EMP 12/22/2015 14:15'!
addTransformButtons

	| specs b |
	specs _ #(
		(paintGrow				enlarge		'Grow')
		-
		(paintShrink			shrink		'Shrink')
		-
		(paintRotateLeft			rotateCCW	'Rotate counter-clock-wise')
		-
		(paintRotateRight		rotateCW	'Rotate clock-wise')
		-
		(paintFlipVertical		flipH		'Flip horizontally')
		-
		(paintFlipHorizontal		flipV		'Flip vertically')
	).

	transformButtons _ AlignmentMorph newColumn
		color: Color transparent;
		inset: 0;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		centering: #topLeft.

	specs do: [:n |
		n = #-
			ifTrue: [
				transformButtons addMorphBack: (Morph new extent: 3@10; color: Color transparent)]
			ifFalse: [
				b _ ToggleButton new
					onForm: (ScratchFrameMorph skinAt: ((n at: 1), 'ButtonPressed'))
						offForm: (ScratchFrameMorph skinAt: ((n at: 1), 'Button'))
						overForm: (ScratchFrameMorph skinAt: ((n at: 1), 'ButtonPressed'));
					target: canvasMorph;
					isMomentary: true;
					toggleMode: false;
					actionSelector: (n at: 2);
					setProperty: #balloonText toValue: (n at: 3) localized.
				transformButtons addMorphBack: b]].

	self addMorph: transformButtons.
! !

!InlinePaintFrame methodsFor: 'initialization' stamp: 'EMP 12/16/2015 15:10'!
createColorSwitcher

	colorSwitcher _ PaintColorSwitcher new.
	colorSwitcher setProperty: #balloonText toValue: 'Switch colors' localized.
	self addMorph: colorSwitcher.
! !

!InlinePaintFrame methodsFor: 'initialization' stamp: 'EMP 12/22/2015 13:53'!
export

	| triple form textBox fName f |
	triple _ self newFormTextBoxAndRegPoint.
	triple ifNil: [^ self beep].  "empty drawing"
	form _ triple first.
	textBox _ triple second.
	(textBox isNil or: [textBox contents isEmpty]) ifFalse: [
		form _ form deepCopy.
		textBox drawTextOn: (FormCanvas on: form)].

	fName _ ''.
	fName _ ScratchFileChooserDialog
		chooseNewFileDefault: fName
		title: 'File Name?'
		type: #costume.
	fName = #cancelled ifTrue: [^ self].
	fName size = 0 ifTrue: [^ self].

	"make sure that file can be created"
	f _ StandardFileStream newScratchFileNamed: fName.
	f ifNil: [^ self].
	f close.
	FileDirectory default deleteFileNamed: f fullName.

	form colorsUsed size < 255 ifTrue: [
		(fName asLowercase endsWith: '.gif')
			ifTrue: [fName _ fName]
			ifFalse: [fName _ fName, '.gif'].
		GIFReadWriter putForm: form colorReduced8Bit onFileNamed: fName.
		^ self].
	(fName asLowercase endsWith: '.bmp')
		ifTrue: [fName _ fName]
		ifFalse: [fName _ fName, '.bmp'].
	(form asFormOfDepth: 32) writeBMPFileNamed: fName.
! !

!InlinePaintFrame methodsFor: 'initialization' stamp: 'EMP 1/8/2016 16:36'!
initialize

	super initialize.
	self addMorph: (
		canvasMorph _ PaintCanvas new
			extent: ScratchFrameMorph workpaneExtent;
			editForm: ((Form extent: PaintCanvas canvasExtent depth: 32) fillColor: Color transparent)).
	self addMorph: (paletteMorph _ canvasMorph palette).
	paletteMorph extent:  56@45.
	self addMorph: (nameMorph _ (UpdatingStringFieldMorph new target: self; getSelector: #costumeName; putSelector: #costumeName:; acceptWhenFocusLost: true)).
	self addScrollbarsAndBevel.
	self addButtons.
	self addSetRotationCenterButton.
	self addTransformButtons.
	self addColorChoosers.
	self scaleCanvas: #Left.
	canvasMorph palette otherNotif: (optionsPanel _ InlinePaintOptionsChooser new).
	self addMorph: optionsPanel.
! !

!InlinePaintFrame methodsFor: 'initialization' stamp: 'EMP 12/15/2015 16:07'!
makeButtonLabel: aString selector: sel

	| font |
	font _ (ScratchFrameMorph getFont: #PaintUtilityButton).
	^ ResizableToggleButton2 new
		offForm: (ScratchFrameMorph skinAt: #paintUtilityButton)
			onForm: (ScratchFrameMorph skinAt: #paintUtilityButtonPressed);
		label: aString localized font: font;
		target: canvasMorph;
		actionSelector: sel
! !

!InlinePaintFrame methodsFor: 'initialization' stamp: 'EMP 12/18/2015 10:49'!
makeZoomBar

	| b |
	zoomBar _ AlignmentMorph newRow
		color: Color transparent;
		centering: #bottomRight;
		vResizing: #shrinkWrap.

	#(Left Middle Right) do: [:n |
		b _ ToggleButton
			onForm: (ScratchFrameMorph skinAt: ('sizeButton', n asString capitalized, 'Pressed'))
			offForm: (ScratchFrameMorph skinAt: ('sizeButton', n asString capitalized)) overForm: (ScratchFrameMorph skinAt: ('sizeButton', n asString capitalized, 'Pressed')).
		b
			target: self;
			actionSelector: #scaleCanvas:;
			arguments: (Array with: n);
			isMomentary: true;
			borderWidth: 0.
		zoomBar addMorphBack: b].

	^ zoomBar
! !

!InlinePaintFrame methodsFor: 'initialization' stamp: 'EMP 12/17/2015 12:00'!
presentColorPicker

	colorPicker owner
		ifNil: [self addMorph: colorPicker.
			colorPicker position: (colorSquarePicker topLeft)]
		ifNotNil: [colorPicker delete].
! !

!InlinePaintFrame methodsFor: 'initialization' stamp: 'EMP 12/22/2015 13:52'!
setRotationCenterButton

	^ setRotationCenterButton! !


!InlinePaintFrame methodsFor: 'geometry' stamp: 'EMP 12/22/2015 13:51'!
exitPaintEditor

	scratchFrame ifNotNil: [scratchFrame paintingInProgress: false].
	World ifNotNil: [World activeHand turnOffGridding; showTemporaryCursor: nil].
! !

!InlinePaintFrame methodsFor: 'geometry' stamp: 'EMP 12/22/2015 13:51'!
extent: aPoint

	super extent: aPoint.
	self fixLayout.
! !

!InlinePaintFrame methodsFor: 'geometry' stamp: 'EMP 1/11/2016 09:15'!
fixLayout

	canvasMorph ifNil: [^ self].
	canvasMorph center: ((self center x - vScrollbar width) @ (self center y - hScrollbar height)).
	nameMorph position: (self topLeft + (3@3)).
	canvasButtons position: (nameMorph topRight).
	fileButtons center: ((self center x) @ (self top + (fileButtons height // 2))).
	hScrollbar
		position: canvasMorph bottomLeft + (0@2);
		width: canvasMorph width.
	vScrollbar
		position: canvasMorph topRight + (2@0);
		height: canvasMorph height.
	colorSquarePicker position: ((self center x - (colorSquarePicker width //2)) @ (self bottom - colorSquarePicker width)).
	colorPicker position: (colorSquarePicker topLeft).
	colorPickerButton position: (colorSquarePicker left - (colorPickerButton width + 5))@(colorSquarePicker bottom - (colorPickerButton height)).
	paletteMorph position:
		(colorSquarePicker topLeft - (paletteMorph width @ 0)).
	setRotationCenterMorph position: ((self right - (setRotationCenterMorph width + 3)) @ (self top)).
	
	transformButtons position: (setRotationCenterMorph bottomLeft).

	zoomBar position: (self right - zoomBar width - 5)@(colorSquarePicker position y).
	optionsPanel height: ((self bottom - 8) - (colorSquarePicker top - 2)).
	optionsPanel left: self left + 8.
	optionsPanel bottom: (self bottom - 8).
	
	"InlinePaintFrame new extent: 570@650; openInWorld"
! !

!InlinePaintFrame methodsFor: 'geometry' stamp: 'EMP 12/22/2015 13:50'!
scaleCanvas: aNumberOrSymbol

	| numToScale |

	numToScale _ aNumberOrSymbol.
	(aNumberOrSymbol == #Right) ifTrue: [numToScale _ (canvasMorph scale*2 min: 16)].
	(aNumberOrSymbol == #Left) ifTrue: [numToScale _ (canvasMorph scale//2 max: 1)].
	(aNumberOrSymbol == #Middle) ifTrue: [numToScale _ 1].

	canvasMorph scale: numToScale.
! !

!InlinePaintFrame methodsFor: 'geometry' stamp: 'EMP 12/15/2015 19:05'!
updateScrollbars
	"Update my scrollbars based on my current scale."

	| visible scaledTotal |
	visible _ canvasMorph extent.
	scaledTotal _ canvasMorph canvasForm extent * canvasMorph scale asFloat.
	hScrollbar
		percentVisible: visible x / scaledTotal x;
		scrollFraction: canvasMorph scrollFractionX.
	vScrollbar
		percentVisible: visible y / scaledTotal y;
		scrollFraction: canvasMorph scrollFractionY.
! !


!InlinePaintFrame methodsFor: 'drawing' stamp: 'EMP 12/22/2015 13:50'!
areasRemainingToFill: aRectangle
	"Drawing optimization. If damage is within my bounds, don't drawn anything below me."

	((bounds insetBy: 15) containsRect: aRectangle)
		ifTrue: [^ #()]
		ifFalse: [^ Array with: aRectangle].

! !

!InlinePaintFrame methodsFor: 'drawing' stamp: 'EMP 12/22/2015 14:27'!
drawOn: aCanvas
	| |
	super drawOn: aCanvas.! !

!InlinePaintFrame methodsFor: 'drawing' stamp: 'EMP 12/22/2015 13:51'!
drawSubmorphsOn: aCanvas
	"Optimization: If change is only within PaintCanvas, only redraw that."

	(canvasMorph bounds containsRect: aCanvas clipRect) ifTrue: [
		 aCanvas fullDrawMorph: canvasMorph.
		^ self].

	super drawSubmorphsOn: aCanvas.
! !

!InlinePaintFrame methodsFor: 'drawing' stamp: 'EMP 12/22/2015 14:33'!
fullDrawOn: aCanvas
	| r |
	"Optimization. Don't draw myself if damage is only within the paint canvas."

	self isHidden ifTrue: [^ self].
	(self hasProperty: #errorOnDraw) ifTrue:[^ self drawErrorOn: aCanvas].
	(canvasMorph bounds containsRect: aCanvas clipRect)
		ifFalse: [aCanvas drawMorph: self].
	r _ Rectangle encompassing: {(self bottomRight - 5). ((self left + 5) @ (colorSquarePicker top - 5))}.
	aCanvas frameAndFillRectangle: r fillColor: (Color r: 246/255 g: 246/255 b: 246/255) borderWidth: 2 borderColor: (Color r: 208/255 g: 209/255 b: 210/255).
	self drawSubmorphsOn:aCanvas.
! !


!InlinePaintFrame methodsFor: 'entry points' stamp: 'EMP 12/15/2015 16:11'!
clearRotationCenter
	"Clear the rotation center. Used when making a new drawing."

	canvasMorph clearRegistrationPoint.
! !

!InlinePaintFrame methodsFor: 'entry points' stamp: 'EMP 12/22/2015 13:51'!
oldCostumeName: aString deleteOnCancel: aBoolean
	"Set state used when editing a Scratch costumes or painting a new sprite."

	oldCostumeName _ aString.
	deleteSpriteOnCancel _ aBoolean.
	aBoolean ifTrue: [canvasMorph editForm: (Form extent: 4@4 depth: 8)].  "clears cat"
! !

!InlinePaintFrame methodsFor: 'entry points' stamp: 'EMP 12/15/2015 16:10'!
originalObject

	^ originalObject! !

!InlinePaintFrame methodsFor: 'entry points' stamp: 'EMP 12/22/2015 13:51'!
scratchFrame: aScratchFrameMorph

	scratchFrame _ aScratchFrameMorph.
! !

!InlinePaintFrame methodsFor: 'entry points' stamp: 'EMP 12/22/2015 13:50'!
withStartingObject: anObject
	"Start editing the given object's form (i.e. it's current costume, if it is a ScratchSpriteMorph)."

	| costume |
	originalObject _ anObject.
	(anObject respondsTo: #costume)
		ifTrue: [  "editing a Scratch object"
			costume _ anObject costume.
			canvasMorph
				editForm: costume form
				regPoint: costume rotationCenter
				textBox: costume textBox
				isStage: (anObject isKindOf: ScratchStageMorph)]
		ifFalse: [  "editing a non-Scratch object"
			canvasMorph editForm: anObject form].

	(anObject isKindOf: ScratchStageMorph)
		ifTrue: [self scaleCanvas: 1]
		ifFalse: [self scaleCanvas: 2].
	World activeHand newKeyboardFocus: canvasMorph.

! !


!InlinePaintFrame methodsFor: 'exit points' stamp: 'EMP 12/22/2015 13:51'!
cancelled
	"Cancel button was pressed. Cancel painting without saving."

	oldCostumeName ifNotNil: [
		originalObject ifNotNil: [
			originalObject revertToCostume: oldCostumeName.
			deleteSpriteOnCancel ifTrue: [originalObject deleteSprite]]].

	self exitPaintEditor.
	super cancelled.
! !

!InlinePaintFrame methodsFor: 'exit points' stamp: 'EMP 12/22/2015 13:52'!
newFormTextBoxAndRegPoint
	"Answer an array containing my current canvasForm, text box, and registration point. The text box is sized to fit the text or is nil if it is empty."

	| textBox r newForm regPoint |
	canvasMorph commitMove.

	textBox _ canvasMorph canvasTextBox copy.
	textBox
		textColor: canvasMorph textColor;
		fitContents.
	textBox contents isEmpty ifTrue: [textBox _ nil].

	(originalObject isKindOf: ScratchStageMorph)
		ifTrue: [
			r _ 0@0 extent: ScratchFrameMorph workpaneExtent.
			newForm _ Form extent: r extent depth: 32.
			newForm fillWhite.
			canvasMorph canvasForm
				displayOn: newForm
				at: (newForm extent - canvasMorph canvasForm extent // 2)
				rule: Form paint]
		ifFalse: [
			r _ canvasMorph canvasForm rectangleEnclosingPixelsNotOfColor: Color transparent.
			((r area = 0) & textBox isNil) ifTrue: [^ nil].  "empty canvas and no text"
			r area = 0 ifTrue: [r _ textBox position extent: 1].  "text only"
			textBox ifNotNil: [
				r _ r merge: textBox bounds.
				textBox position: textBox position - r origin].
			newForm _ Form extent: r extent depth: 32.
			canvasMorph canvasForm displayOn: newForm at: r origin negated rule: Form paint].

	regPoint _ canvasMorph registrationPoint.
	regPoint
		ifNil: [regPoint _ r extent // 2]
		ifNotNil: [regPoint _ regPoint - r topLeft].

	^ Array with: newForm with: textBox with: regPoint
! !

!InlinePaintFrame methodsFor: 'exit points' stamp: 'EMP 12/22/2015 13:50'!
save
	"Save the edited form back to the original object."

	| triple |
	originalObject ifNil: [^ self exitPaintEditor].

	triple _ self newFormTextBoxAndRegPoint.
	triple ifNil: [^ self beep; cancelled].

	originalObject
		editedForm: triple first textBox: triple second;
		rotationCenter: triple third.
	self exitPaintEditor.
	super yes.
! !


!InlinePaintFrame methodsFor: 'accessing' stamp: 'EMP 12/17/2015 12:06'!
costumeName
	^ 'costumeName'! !

!InlinePaintFrame methodsFor: 'accessing' stamp: 'EMP 12/22/2015 13:39'!
costumeName: aString
	DialogBoxMorph inform: 'it works...'! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

InlinePaintFrame class
	instanceVariableNames: ''!

!InlinePaintFrame class methodsFor: 'as yet unclassified' stamp: 'EMP 12/15/2015 16:01'!
clearColorPickers
	"self clearColorPickers"

	ColorPicker _ SquareColorPicker _ nil.
! !
