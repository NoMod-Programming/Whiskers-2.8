DialogBoxMorph subclass: #PaintFrame
	instanceVariableNames: 'canvasMorph paletteMorph hScrollbar vScrollbar transformButtons canvasButtons fileButtons colorSquarePicker colorPicker zoomBar canvasFrame scratchFrame originalObject oldCostumeName deleteSpriteOnCancel setRotationCenterMorph setRotationCenterButton colorPickerButton '
	classVariableNames: 'ColorPicker SquareColorPicker '
	poolDictionaries: ''
	category: 'Scratch-Paint'!
!PaintFrame commentStamp: 'jm 12/21/2005 18:14' prior: 0!
I am the top-level of the paint editor. I have the following morphic compontents:

	canvasMorph			the area in which drawing is done
	paletteMorph			a palette of painting controls
	hScrollbar				horizontal scrollbar
	vScrollbar				vertical scrollbar
	transformButtons		an Array of button morphs for image transforms (flip, etc.)
	canvasButtons			an Array of button morphs for image transforms (flip, etc.)
	fileButtons				an Array of button morphs for import/export
	colorSquarePicker		an array of color squares
	colorPicker				a continuous color palette
	scaleMorph				string showing the current scale
	scaleMenuBar			menu bar frame round the scaleMorph

My other instance variables are:

	canvasFrame			the frame around canvasMorph
	scratchFrame			the ScratchFrame that created me (optional)
	originalObject			the source of the form being edited; informed if ok button pressed
	oldCostumeName			name of the Scratch costume being edited (optional)
	deleteSpriteOnCancel		true if operation is "paint a new sprite" (optional)

The optional values are not needed when editing a non-Scratch object such as an ImageMorph.
!


!PaintFrame methodsFor: 'initialization' stamp: 'ee 2/20/2009 11:21'!
addButtons

	| b |
	fileButtons _ AlignmentMorph newRow
		color: Color transparent;
		vResizing: #rigid;
		width: 233;
		inset: 0.

	b _ self makeButtonLabel: 'Import' selector:  #import.
	b setProperty: #balloonText toValue: 'Import an image on top of your current canvas' localized.
	fileButtons addMorphBack: b.

	b _ ResizableToggleButton2 new
		offForm: (ScratchFrameMorph skinAt: #paintUtilityButton)
			onForm: (ScratchFrameMorph skinAt: #paintUtilityButtonPressed);
		label: 'Clear' localized font: (ScratchFrameMorph getFont: #PaintUtilityButton);
		target: canvasMorph;
		actionSelector: #eraseAll;
		setProperty: #balloonText toValue: 'Clear canvas' localized.
	fileButtons addMorphBack: (AlignmentMorph newSpacer: Color transparent).
	fileButtons addMorphBack: b.

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

	self addMorph: fileButtons.
	self addMorph: canvasButtons.
	self addMorph: self makeZoomBar.
! !

!PaintFrame methodsFor: 'initialization' stamp: 'EMP 12/22/2015 14:50'!
addColorChoosers
	"ColorPicker _ SquareColorPicker _ nil"

	"color picker is somewhat slow to create, so cache one and copy it"
	(ColorPicker isNil or:
	 [ColorPicker extent ~= (112@108)]) ifTrue: [
		ColorPicker _ PaintColorPicker new
			selector: #color1:;
			selector2: #color2:;
			extent: 120@108].
	colorPicker _ ColorPicker fullCopy target: canvasMorph palette.

	SquareColorPicker ifNil: [
		SquareColorPicker _ PaintColorSquarePicker new initFromForm: (ScratchFrameMorph skinAt: #paintCanvasFrame);
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

!PaintFrame methodsFor: 'initialization' stamp: 'jm 3/21/2008 14:00'!
addScrollbarsAndBevel

	self addMorph: (
		hScrollbar _ ScratchScrollBar newHorizontal
			target: canvasMorph;
			selector: #scrollFractionX:).
	self addMorph: (
		vScrollbar _ ScratchScrollBar newVertical
			target: canvasMorph;
			selector: #scrollFractionY:).
	self addMorphBack: (
		canvasFrame _ ImageFrameMorph new
			initFromForm: (ScratchFrameMorph skinAt: #paintCanvasFrame);
			extent: canvasMorph extent + (8@8)).
! !

!PaintFrame methodsFor: 'initialization' stamp: 'jm 2/25/2009 16:20'!
addSetRotationCenterButton

	| setRotationLabel spacer font |

	setRotationCenterMorph _ AlignmentMorph newRow
		color: Color transparent;
		centering: #center.

	"make components"
	setRotationCenterButton _ ToggleButton
		onForm: (ScratchFrameMorph skinAt: #paintSetRotCenterButtonPressed)
		offForm: (ScratchFrameMorph skinAt: #paintSetRotCenterButton).
	setRotationCenterButton
		target: paletteMorph;
		actionSelector: #toggleRotationPoint;
		setProperty: #balloonText toValue: 'Position the cross-hair to set the rotation center' localized.
	spacer _ Morph new extent: 6@3; color: Color transparent.
	setRotationLabel _ StringMorph contents: 'Set costume center' localized.
	font _ (ScratchFrameMorph getFont: #PaintSetRotationCenter).
	setRotationLabel font: font; color: Color gray darker.

	"add components"
	setRotationCenterMorph
		addMorphBack: setRotationCenterButton;
		addMorphBack: spacer;
		addMorphBack: setRotationLabel.

	"add bar to frame"
	self addMorph: setRotationCenterMorph.
! !

!PaintFrame methodsFor: 'initialization' stamp: 'ee 2/20/2009 11:09'!
addTransformButtons

	| specs b |
	specs _ #(
		(paintGrow				enlarge		'Grow')
		(paintShrink			shrink		'Shrink')
		-
		(paintRotateLeft			rotateCCW	'Rotate counter-clock-wise')
		(paintRotateRight		rotateCW	'Rotate clock-wise')
		-
		(paintFlipVertical		flipH		'Flip horizontally')
		(paintFlipHorizontal		flipV		'Flip vertically')
	).

	transformButtons _ AlignmentMorph newRow
		color: Color transparent;
		inset: 0;
		vResizing: #shrinkWrap;
		centering: #center.

	specs do: [:n |
		n = #-
			ifTrue: [
				transformButtons addMorphBack: (Morph new extent: 3@10; color: Color transparent)]
			ifFalse: [
				b _ ToggleButton new
					onForm: (ScratchFrameMorph skinAt: ((n at: 1), 'ButtonPressed'))
						offForm: (ScratchFrameMorph skinAt: ((n at: 1), 'Button'))
						overForm: (ScratchFrameMorph skinAt: ((n at: 1), 'Button'));
					target: canvasMorph;
					isMomentary: true;
					toggleMode: false;
					actionSelector: (n at: 2);
					setProperty: #balloonText toValue: (n at: 3) localized.
				transformButtons addMorphBack: b]].

	self addMorph: transformButtons.
! !

!PaintFrame methodsFor: 'initialization' stamp: 'ee 2/20/2009 11:06'!
initialize

	super initialize.
	self addMorph: (
		canvasMorph _ PaintCanvas new
			extent: ScratchFrameMorph workpaneExtent;
			editForm: ((Form extent: PaintCanvas canvasExtent depth: 32) fillColor: Color transparent)).
	buttonRow ifNotNil: [
		buttonRow delete.
		self addMorph: buttonRow].
	self addMorph: (paletteMorph _ canvasMorph palette).
	self addScrollbarsAndBevel.
	self addButtons.
	self addSetRotationCenterButton.
	self addTransformButtons.
	self addColorChoosers.
! !

!PaintFrame methodsFor: 'initialization' stamp: 'jm 4/23/2008 10:23'!
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

!PaintFrame methodsFor: 'initialization' stamp: 'jm 3/21/2008 14:08'!
makeZoomBar

	| b t |
	zoomBar _ AlignmentMorph newRow
		color: Color transparent;
		centering: #bottomRight;
		vResizing: #shrinkWrap.

	#(out in) do: [:n |
		b _ ToggleButton
			onForm: (ScratchFrameMorph skinAt: ('paintZoom', n asString capitalized, 'Button'))
			offForm: (ScratchFrameMorph skinAt: ('paintZoom', n asString capitalized, 'Button')).
		b
			target: self;
			actionSelector: #scaleCanvas:;
			arguments: (Array with: n);
			borderWidth: 0;
			setProperty: #balloonText toValue: ('Zoom ', n asString) localized.
		zoomBar addMorphBack: b.

		#out = n ifTrue: [
			#(1 2 4 8 16) do: [:scale |
				t _ ToggleButton
					onForm: (ScratchFrameMorph skinAt: ('zoom', scale asString, 'ButtonPressed'))
					offForm: (ScratchFrameMorph skinAt: ('zoom', scale asString, 'Button')).
				t
					target: self;
					actionSelector: #scaleCanvas:;
					arguments: (Array with: scale);
					setProperty: #balloonText toValue: scale asString, 'x'.
				zoomBar addMorphBack: t.
				zoomBar addMorphBack: (Morph new extent: 2@2; color: Color transparent)]]].

	^ zoomBar
! !


!PaintFrame methodsFor: 'accessing' stamp: 'tis 8/3/2006 12:23'!
originalObject

	^ originalObject! !

!PaintFrame methodsFor: 'accessing' stamp: 'ee 1/5/2006 19:28'!
setRotationCenterButton

	^ setRotationCenterButton! !


!PaintFrame methodsFor: 'entry points' stamp: 'jm 8/22/2006 12:27'!
clearRotationCenter
	"Clear the rotation center. Used when making a new drawing."

	canvasMorph clearRegistrationPoint.
! !

!PaintFrame methodsFor: 'entry points' stamp: 'jm 12/16/2005 13:55'!
oldCostumeName: aString deleteOnCancel: aBoolean
	"Set state used when editing a Scratch costumes or painting a new sprite."

	oldCostumeName _ aString.
	deleteSpriteOnCancel _ aBoolean.
	aBoolean ifTrue: [canvasMorph editForm: (Form extent: 4@4 depth: 8)].  "clears cat"
! !

!PaintFrame methodsFor: 'entry points' stamp: 'ee 11/1/2005 22:08'!
scratchFrame: aScratchFrameMorph

	scratchFrame _ aScratchFrameMorph.
! !

!PaintFrame methodsFor: 'entry points' stamp: 'jm 3/3/2008 11:38'!
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


!PaintFrame methodsFor: 'geometry' stamp: 'jm 9/26/2005 11:21'!
extent: aPoint

	super extent: aPoint.
	self fixLayout.
! !

!PaintFrame methodsFor: 'geometry' stamp: 'ee 6/23/2009 14:05'!
fixLayout

	canvasMorph ifNil: [^ self].
	canvasMorph position: (self right - canvasMorph width - 55)@(self top + 42).
	canvasButtons position: (self left + 20)@(canvasMorph top + 80).
	paletteMorph position:
		(self left + 20)@(canvasButtons bottom + 5).
	hScrollbar
		position: canvasMorph bottomLeft + (0@9);
		width: canvasMorph width.
	vScrollbar
		position: canvasMorph topRight + (9@0);
		height: canvasMorph height.

	titleBin left: self left + ((self width - titleBin width) // 2) - 5.
	fileButtons position: (self left + 20)@(canvasButtons top - 35).
	transformButtons position: (self left + 18)@(canvasMorph top).
	colorSquarePicker position: (self left + 25)@(paletteMorph bottom - 55).
	colorPickerButton position: (colorSquarePicker right + 5)@(colorSquarePicker top + 30).
	setRotationCenterMorph position: (self left + (((canvasMorph left - self left) - setRotationCenterMorph width) // 2)) @ (colorSquarePicker bottom - 3).
	buttonRow position: (self right - buttonRow width - 30)@(self bottom - buttonRow height - 22).
	canvasFrame position: canvasMorph position - (4@4).
	zoomBar position: (canvasMorph left - zoomBar width - 15)@(setRotationCenterMorph top - 21).
! !

!PaintFrame methodsFor: 'geometry' stamp: 'jm 11/19/2005 10:31'!
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


!PaintFrame methodsFor: 'interaction' stamp: 'tis 11/7/2006 18:09'!
cancelled
	"Cancel button was pressed. Cancel painting without saving."

	oldCostumeName ifNotNil: [
		originalObject ifNotNil: [
			originalObject revertToCostume: oldCostumeName.
			deleteSpriteOnCancel ifTrue: [originalObject deleteSprite]]].

	self exitPaintEditor.
	super cancelled.
! !

!PaintFrame methodsFor: 'interaction' stamp: 'jm 1/4/2006 10:28'!
yes
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


!PaintFrame methodsFor: 'drawing' stamp: 'jm 11/15/2005 19:54'!
areasRemainingToFill: aRectangle
	"Drawing optimization. If damage is within my bounds, don't drawn anything below me."

	((bounds insetBy: 15) containsRect: aRectangle)
		ifTrue: [^ #()]
		ifFalse: [^ Array with: aRectangle].

! !

!PaintFrame methodsFor: 'drawing' stamp: 'jm 11/15/2005 20:00'!
drawSubmorphsOn: aCanvas
	"Optimization: If change is only within PaintCanvas, only redraw that."

	(canvasMorph bounds containsRect: aCanvas clipRect) ifTrue: [
		 aCanvas fullDrawMorph: canvasMorph.
		^ self].

	super drawSubmorphsOn: aCanvas.
! !

!PaintFrame methodsFor: 'drawing' stamp: 'jm 11/15/2005 20:08'!
fullDrawOn: aCanvas
	"Optimization. Don't draw myself if damage is only within the paint canvas."

	self isHidden ifTrue: [^ self].
	(self hasProperty: #errorOnDraw) ifTrue:[^ self drawErrorOn: aCanvas].
	(canvasMorph bounds containsRect: aCanvas clipRect)
		ifFalse: [aCanvas drawMorph: self].
	self drawSubmorphsOn:aCanvas.
! !


!PaintFrame methodsFor: 'other' stamp: 'jm 9/11/2006 13:26'!
exitPaintEditor

	scratchFrame ifNotNil: [scratchFrame paintingInProgress: false].
	World ifNotNil: [World activeHand turnOffGridding; showTemporaryCursor: nil].
! !

!PaintFrame methodsFor: 'other' stamp: 'tis 12/7/2006 16:04'!
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

!PaintFrame methodsFor: 'other' stamp: 'jm 10/11/2007 17:19'!
justDroppedInto: aMorph event: evt

	| r |
	super justDroppedInto: aMorph event: evt.
	owner = World ifFalse: [^ self].

	r _ self bounds intersect: World bounds.
	(r width > 50) & (r height > 50) ifFalse: [  "almost off the screen; re-center"
		self position: World bounds center - (self extent // 2).
		self bottom > World bottom ifTrue: [self top: World bottom - (self height - 20)]].
! !

!PaintFrame methodsFor: 'other' stamp: 'jm 9/12/2006 18:08'!
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

!PaintFrame methodsFor: 'other' stamp: 'ee 6/25/2009 10:58'!
presentColorPicker

	colorPicker owner
		ifNil: [self addMorph: colorPicker.
			colorPicker position: paletteMorph bottomLeft - (0@55) + (5@0)]
		ifNotNil: [colorPicker delete].
! !

!PaintFrame methodsFor: 'other' stamp: 'ee 12/21/2005 20:31'!
scaleCanvas: aNumberOrSymbol

	| numToScale |

	numToScale _ aNumberOrSymbol.
	(aNumberOrSymbol == #in) ifTrue: [numToScale _ (canvasMorph scale*2 min: 16)].
	(aNumberOrSymbol == #out) ifTrue: [numToScale _ (canvasMorph scale//2 max: 1)].
	
	zoomBar allMorphsDo: [:b |
		(b isKindOf: ToggleButton) ifTrue: [
			b arguments first = numToScale ifTrue: [b on] ifFalse: [b off]]].

	canvasMorph scale: numToScale.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

PaintFrame class
	instanceVariableNames: ''!

!PaintFrame class methodsFor: 'instance creation' stamp: 'jm 1/12/2006 19:03'!
clearColorPickers
	"self clearColorPickers"

	ColorPicker _ SquareColorPicker _ nil.
! !

!PaintFrame class methodsFor: 'instance creation' stamp: 'ee 2/20/2009 11:07'!
new

	^ super new
		withButtonsForYes: false no: false okay: true cancel: true;
		title: 'Paint Editor';
		extent: 800@490
! !
