BorderedMorph subclass: #PaintPalette
	instanceVariableNames: 'canvasMorph brushSizeMorph brushSize eraserSize brushIcon colorSwitcher fillStylePane optionsPane storedColor toolbarButtons mode storedMode shapeFilling fillStyle showRotationCenter brushSizeMenu textSizeMenu textSizeMorph textFontMenu textFontMorph otherNotif '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Paint'!

!PaintPalette methodsFor: 'initialization' stamp: 'EMP 12/16/2015 15:16'!
addToolbarButtons

	| b firstRow secondRow buttonSpecs bName bTip |
	toolbarButtons _ AlignmentMorph newColumn
		inset: 0;
		vResizing: #shrinkWrap.
	firstRow _ AlignmentMorph newRow
		inset: 0;
		vResizing: #shrinkWrap.
	secondRow _ AlignmentMorph newRow
		inset: 0;
		vResizing: #shrinkWrap.
	true ifTrue: [^ self]. "No longer needed"
	buttonSpecs _ #(
		"name			tip"
		(paint			'Paintbrush')
		(erase			'Eraser')
		(fill				'Fill tool (fill areas with color or gradient)')
		(rect 			'Rectangle tool (draw outlined or filled rectangle or square)')
		(oval 			'Ellipse tool (draw outlined or filled ellipse or circle)')
	).

	buttonSpecs do: [:spec |
		bName _ spec at: 1.
		bTip _ spec at: 2.
		b _ ToggleButton new
			onForm: (ScratchFrameMorph skinAt: (bName, 'ToolButtonPressed'))
			offForm: (ScratchFrameMorph skinAt: (bName, 'ToolButton'))
			overForm: (ScratchFrameMorph skinAt: (bName, 'ToolButtonOver'));
			target: self;
			isMomentary: false;
			toggleMode: false;
			actionSelector: #mode:;
			arguments: (Array with: bName);
			setProperty: #balloonText toValue: bTip localized;
			actWhen: #buttonDown.
		firstRow addMorphBack: b].

	buttonSpecs _ #(
		"name			tip"
		(line			'Line tool (draw lines)')
		(text			'Text tool (edit text layer)')
		(move			'Select tool (move, modify, or delete selection)')
		(stamp 			'Stamp tool (select area, then stamp copies of it)')
		(eyedropper 	'Eyedropper tool (select a color)')
	).

	buttonSpecs do: [:spec |
		bName _ spec at: 1.
		bTip _ spec at: 2.
		b _ ToggleButton new
			onForm: (ScratchFrameMorph skinAt: (bName, 'ToolButtonPressed'))
			offForm: (ScratchFrameMorph skinAt: (bName, 'ToolButton'))
			overForm: (ScratchFrameMorph skinAt: (bName, 'ToolButtonOver'));
			target: self;
			isMomentary: false;
			toggleMode: false;
			actionSelector: #mode:;
			arguments: (Array with: bName);
			setProperty: #balloonText toValue: bTip localized;
			actWhen: #buttonDown.
		secondRow addMorphBack: b.
		].

	toolbarButtons addMorphBack: firstRow.
	toolbarButtons addMorphBack: secondRow.
	self addMorph: toolbarButtons.
! !

!PaintPalette methodsFor: 'initialization' stamp: 'ee 10/2/2007 16:52'!
createColorSwitcher

	colorSwitcher _ PaintColorSwitcher new.
	colorSwitcher setProperty: #balloonText toValue: 'Switch colors' localized.
	self addMorph: colorSwitcher.
! !

!PaintPalette methodsFor: 'initialization' stamp: 'EMP 12/17/2015 11:50'!
createOptionsPane

	^ self
! !

!PaintPalette methodsFor: 'initialization' stamp: 'EMP 12/22/2015 15:25'!
initialize

	super initialize.
	otherNotif _ nil.
	self borderWidth: 0.
	self color: Color transparent.
	self createOptionsPane.
	self createColorSwitcher.
	self addToolbarButtons.
	self brushSize: 3.
	eraserSize _ 13.
	self extent: (toolbarButtons width)@(100 + toolbarButtons height).
	self shapeFilling: true.
	self fillStyle: #color.
	showRotationCenter _ false.
	self mode: #paint.
	self storedColor: colorSwitcher foreground.
	self updateOptionsPane.
! !

!PaintPalette methodsFor: 'initialization' stamp: 'EMP 12/22/2015 15:26'!
mode: aSymbol

	otherNotif ifNotNil: [otherNotif mode: aSymbol].
	canvasMorph ifNotNil: [canvasMorph commitMove].
	self showRotationCenter ifTrue: [self showRotationCenter: false].
	mode _ aSymbol.
	brushSizeMenu ifNotNil: [brushSizeMenu delete].
	canvasMorph ifNotNil: [
		mode = #text 
			ifTrue: [
				self color1: canvasMorph textColor.
				World activeHand newKeyboardFocus: canvasMorph]
			ifFalse: [
			self color1: self storedColor]].
	self updateOptionsPane.
	self updateToolbarButtons.

	self owner changed.
! !

!PaintPalette methodsFor: 'initialization' stamp: 'EMP 1/11/2016 14:26'!
otherNotif: aMorph
	otherNotif _ aMorph.
	otherNotif palette: self.
	otherNotif mode: self mode.! !


!PaintPalette methodsFor: 'accessing' stamp: 'jm 9/27/2006 11:04'!
brushSize

	^ mode = #erase ifTrue: [eraserSize] ifFalse: [brushSize]
! !

!PaintPalette methodsFor: 'accessing' stamp: 'EMP 1/11/2016 14:41'!
brushSize: aNumber
	"Set the brush size for painting and erasing."

	otherNotif ifNotNil: [otherNotif brushSize: aNumber].
	mode = #erase
		ifTrue: [eraserSize _ aNumber]
		ifFalse: [brushSize _ aNumber].! !

!PaintPalette methodsFor: 'accessing' stamp: 'jm 11/15/2005 17:15'!
canvasMorph

	^ canvasMorph
! !

!PaintPalette methodsFor: 'accessing' stamp: 'jm 11/15/2005 17:15'!
canvasMorph: anObject
	"Set the PaintCanvas that I control."

	canvasMorph _ anObject.
! !

!PaintPalette methodsFor: 'accessing' stamp: 'ee 11/11/2005 21:11'!
color1

	^ colorSwitcher foreground
! !

!PaintPalette methodsFor: 'accessing' stamp: 'EMP 3/23/2016 14:36'!
color1: aColor
	"Set the color for painting, ovals, and rectangles. This is also used as the first color when doing gradiant fills."

	| aColor2 |

	aColor2 _ aColor.
	(mode == #text) 
		ifTrue: [(aColor == Color transparent) ifTrue: [aColor2 _ Color white].
				canvasMorph textColor: aColor2. 
				canvasMorph changed]
		ifFalse: [self storedColor: aColor2].
	colorSwitcher foreground: aColor2.
	self updateOptionsPane.
! !

!PaintPalette methodsFor: 'accessing' stamp: 'ee 11/11/2005 21:12'!
color2

	^ colorSwitcher background
! !

!PaintPalette methodsFor: 'accessing' stamp: 'EMP 3/23/2016 14:36'!
color2: aColor
	"Set the second color for gradiant fills."

	colorSwitcher background: aColor.
	self updateOptionsPane.
! !

!PaintPalette methodsFor: 'accessing' stamp: 'ee 11/13/2005 01:01'!
fillStyle

	^ fillStyle
! !

!PaintPalette methodsFor: 'accessing' stamp: 'ee 12/21/2005 23:16'!
fillStyle: aSymbol
	"Set the paint bucket fill style: color, erase, hGradient, vGradient, or rGradient."

	fillStyle _ aSymbol.
	fillStylePane ifNil: [^ self].
	self updateOptionsPane.
! !

!PaintPalette methodsFor: 'accessing' stamp: 'ee 11/11/2005 21:03'!
mode

	^ mode
! !

!PaintPalette methodsFor: 'accessing' stamp: 'ee 11/13/2005 00:47'!
shapeFilling

	^ shapeFilling
! !

!PaintPalette methodsFor: 'accessing' stamp: 'EMP 12/17/2015 11:49'!
shapeFilling: aBoolean
	"Set the shape filling mode for ovals and rectangles."

	shapeFilling _ aBoolean.! !

!PaintPalette methodsFor: 'accessing' stamp: 'jm 12/20/2005 12:02'!
showRotationCenter

	^ showRotationCenter
! !

!PaintPalette methodsFor: 'accessing' stamp: 'jm 9/20/2006 14:59'!
showRotationCenter: aBoolean

	showRotationCenter = aBoolean ifTrue: [^ self].

	canvasMorph commitMove.  "commit the last move operation if necessary"

	showRotationCenter _ aBoolean.
	showRotationCenter
		ifTrue: [
			storedMode _ mode.
			mode _ #setRotationCenter.
			owner ifNotNil: [owner setRotationCenterButton on]]
		ifFalse: [
			mode _ storedMode.
			owner ifNotNil: [owner setRotationCenterButton off]].

	self updateToolbarButtons.
	canvasMorph ifNotNil: [canvasMorph changed].
! !

!PaintPalette methodsFor: 'accessing' stamp: 'ee 12/20/2005 22:43'!
storedColor

	^ storedColor! !

!PaintPalette methodsFor: 'accessing' stamp: 'ee 12/20/2005 22:43'!
storedColor: aColor

	storedColor _ aColor! !

!PaintPalette methodsFor: 'accessing' stamp: 'EMP 1/11/2016 14:28'!
updateOptionsPane

	otherNotif ifNotNil: [otherNotif mode: self mode; mode; brushSize: self brushSize; shapeFilling: self shapeFilling; updateOptionsPane].! !


!PaintPalette methodsFor: 'geometry' stamp: 'ee 11/6/2005 21:22'!
extent: aPoint

	super extent: aPoint.
	self fixLayout.
! !

!PaintPalette methodsFor: 'geometry' stamp: 'EMP 12/17/2015 11:49'!
fixLayout

	colorSwitcher position: (self topLeft).
! !


!PaintPalette methodsFor: 'event handling' stamp: 'EMP 12/17/2015 11:48'!
brushSizeMenu

	| b icon row n2 colorToUse |

	brushSizeMenu ifNotNil: [brushSizeMenu isInWorld ifTrue: [^ self]].
	brushSizeMenu _ AlignmentMorph newColumn
		color: Color transparent;
		inset: 0;
		borderWidth: 1;
		useRoundedCorners;
		borderColor: (Color r: (173/255) g: (174/255) b: (181/255)).
	row _ AlignmentMorph newRow
		borderWidth: 0;
		inset: 0.
	#(1 2 3 4 5 7 9 13 19 29 47 75) do: [:n | 
		n2 _ n asNumber.
		(n2 <= 6) ifTrue: [n2 _ n2 + 1].
		(n2 == 29) ifTrue: [n2 _ 23].
		(n2 == 47) ifTrue: [n2 _ 25].
		(n2 == 75) ifTrue: [n2 _ 27].
		self mode = #erase
			ifTrue: [colorToUse _ Color transparent]
			ifFalse: [colorToUse _ self color1].
		icon _ (PaintCanvas brushCursorSize: n2 color: colorToUse scale: 1).
		b _ IconicButton new
			color: (Color r: (211/255) g: (212/255) b: (220/255));
			borderColor: (Color r: (173/255) g: (174/255) b: (181/255));
			labelGraphic: icon;
			width: 30; 
			height: 30;
			actionSelector: #brushSize:;
			target: self;
			arguments: (Array with: n).
		(self brushSize = n asNumber) ifTrue: [b color: Color white "(Color r: (188/255) g: (193/255) b: (200/255))"].
		row addMorphBack: b.
		(row submorphs size == 4) ifTrue: [
			brushSizeMenu addMorphBack: row.
			row _ AlignmentMorph newRow borderWidth: 0; inset: 0]].! !

!PaintPalette methodsFor: 'event handling' stamp: 'EMP 3/23/2016 14:16'!
handlesMouseDown: evt
	
	^ false! !

!PaintPalette methodsFor: 'event handling' stamp: 'e 1/1/2006 11:09'!
mouseUp: evt

	| p |
	p _ evt cursorPoint.
	brushSizeMorph ifNotNil: [
		(brushSizeMorph isInWorld and: [brushSizeMorph containsPoint: p])
			ifTrue: [^ self brushSizeMenu]].
	textSizeMenu ifNotNil: [
		(textSizeMenu isInWorld and: [textSizeMenu containsPoint: p])
			ifTrue: [^ self textSizeMenu]].
	textFontMenu ifNotNil: [
		(textFontMenu isInWorld and: [textFontMenu containsPoint: p])
			ifTrue: [^ self textFontMenu]].
! !

!PaintPalette methodsFor: 'event handling' stamp: 'jm 8/2/2008 17:49'!
textFontMenu

	| useOSFont fontList lcName menu choice fontSize font |
	useOSFont _ true.
	fontList _ UnicodePlugin getFontList.
	fontList size = 0 ifTrue: [
		useOSFont _ false.
		fontList _ StrikeFont fontNames reject: [:fn |
			lcName _ fn asLowercase.
			(lcName includesSubString: 'arial') |
			(lcName includesSubString: 'helvetica') |
			(lcName includesSubString: 'narrowspace') |
			(lcName includesSubString: 'newyork')]].

	menu _ CustomMenu new.
	fontList do: [:n | menu add: n asString action: n].
	choice _ menu startUp.
	choice ifNil: [^ self].

	fontSize _ textSizeMorph contents asNumber.
	useOSFont
		ifTrue: [font _ StrikeFont osFontName: choice size: fontSize]
		ifFalse: [font _ StrikeFont fontName: choice size: fontSize].

	canvasMorph canvasTextBox font: font.
	self updateOptionsPane.
	canvasMorph changed.

! !

!PaintPalette methodsFor: 'event handling' stamp: 'jm 7/10/2008 12:49'!
textSizeMenu

	| menu font sizeList choice oldFont newFont |
	menu _ CustomMenu new.
	font _ canvasMorph canvasTextBox font.
	font isOSFont
		ifTrue: [sizeList _ #(8 9 10 12 14 18 24 36 48 60 72 96 120 144 216 288)]
		ifFalse: [sizeList _ StrikeFont sizesForFontName: font name].

	sizeList size = 0 ifTrue: [^ self beep].  "should not happen"
	sizeList do: [:n | menu add: n printString action: n].
	choice _ menu startUp.
	choice ifNil: [^ self].

	textSizeMorph contents: choice asString.
	oldFont _ canvasMorph canvasTextBox font.
	oldFont isOSFont
		ifTrue: [newFont _ StrikeFont osFontName: font name size: choice]
		ifFalse: [newFont _ StrikeFont fontName: font name size: choice].

	canvasMorph canvasTextBox font: newFont.
	canvasMorph changed.! !

!PaintPalette methodsFor: 'event handling' stamp: 'jm 9/20/2006 14:51'!
toggleRotationPoint

	self showRotationCenter: showRotationCenter not.
! !

!PaintPalette methodsFor: 'event handling' stamp: 'EMP 12/22/2015 15:31'!
updateOptionsPaneOld

	| options font s spacer form b formMorph colorToUse brushThumbnail n2 aColor2 fName |

	optionsPane removeAllMorphs.
	options _ AlignmentMorph newRow
		width: (optionsPane width - 16);
		height: (optionsPane height - 30);
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		inset: 0.

	(#(paint erase line) includes: self mode) ifTrue: [
		brushSizeMorph _ AlignmentMorph newRow
			centering: #center;
			color: Color transparent.
		font _ (StrikeFont fontName: 'VerdanaBold' size: 11).
		s _ (StringMorph contents: 'Brush size: ' localized).
		self mode = #erase ifTrue: [s contents: ('Eraser size' localized ,': ')].
		s font: font; color: Color gray darker.
		brushSizeMorph addMorphBack: s.
		self mode = #erase
			ifTrue: [colorToUse _ Color transparent]
			ifFalse: [colorToUse _ self color1].
		brushSizeMorph addMorphBack: (Morph new extent: 2@5; color: Color transparent).
		brushSizeMorph addMorphBack: (ImageMorph new form: (ScratchFrameMorph skinAt: #downArrow)).
		brushSizeMorph addMorphBack: (Morph new extent: 4@5; color: Color transparent).
		brushThumbnail _ Morph new
			extent: 30@30;
			color: Color transparent.
		n2 _ self brushSize.
		(n2 <= 6) ifTrue: [n2 _ n2 + 1].
		(n2 == 29) ifTrue: [n2 _ 23].
		(n2 == 47) ifTrue: [n2 _ 25].
		(n2 == 75) ifTrue: [n2 _ 27].
		brushIcon _ ImageMorph new form: (PaintCanvas brushCursorSize: n2 color: colorToUse scale: 1).
		brushIcon position: (15@15 - ((n2//2)@(n2//2))).
		brushThumbnail addMorphBack: brushIcon.
		brushSizeMorph addMorphBack: brushThumbnail.
		options
			addMorphBack: brushSizeMorph].

	(#(oval rect) includes: self mode) ifTrue: [
		b _ ToggleButton onForm: (ScratchFrameMorph skinAt: #paintOptionsButtonPressed)
					 offForm: (ScratchFrameMorph skinAt: #paintOptionsButton).
		b
			target: self;
			actionSelector: #shapeFilling:;
			arguments: (Array with: true);
			toggleMode: false.
		self shapeFilling ifTrue: [b on].
		(self mode = #oval)
			ifTrue: [form _ Form extent: 16@17 depth: 16.
					(FormCanvas on: form) fillOval: form boundingBox color: self color1.
					formMorph _ ImageMorph new form: form; position: 7@5]
			ifFalse: [form _ Form extent: 16@17 depth: 8. form fillColor: self color1.
					formMorph _ ImageMorph new form: form; position: 7@5].
		b addMorph: formMorph.
		options addMorphBack: b.
		options addMorphBack: (Morph new extent: 5@2; color: Color transparent).
		b _ ToggleButton onForm: (ScratchFrameMorph skinAt: #paintOptionsButtonPressed)
					 offForm: (ScratchFrameMorph skinAt: #paintOptionsButton).
		b
			target: self;
			actionSelector: #shapeFilling:;
			arguments: (Array with: false);
			toggleMode: false.
		self shapeFilling ifFalse: [b on].
		(self mode = #oval)
			ifTrue: [form _ Form extent: 16@17 depth: 16.
					(FormCanvas on: form) frameOval: form boundingBox width: 2 color: self color1.
					formMorph _ ImageMorph new form: form; position: 7@5]
			ifFalse: [form _ Form extent: 16@17 depth: 8. form border: (0@0 extent: 16@17) width: 2 fillColor: self color1.
					formMorph _ ImageMorph new form: form; position: 7@5].
		b addMorph: formMorph.
		options addMorphBack: b].

	#fill = self mode ifTrue: [
		fillStylePane _ AlignmentMorph newRow
		inset: 0;
		borderWidth: 0;
		color: Color transparent;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap.
		spacer _ Morph new extent: 5@5; color: Color transparent.
		#(color hGradient vGradient rGradient) do: [:style |
			b _ ToggleButton onForm: (ScratchFrameMorph skinAt: #paintOptionsButtonPressed)
					 offForm: (ScratchFrameMorph skinAt: #paintOptionsButton).
			b
				target: self;
				actionSelector: #fillStyle:;
				arguments: (Array with: style);
				toggleMode: false.
			form _ Form extent: 16@17 depth: 32.
			(style == #color) ifTrue: [form fillColor: self color1].
			(style == #hGradient) ifTrue: [form fillFromXColorBlock: [:m | self color2 mixed: m with: self color1]].
			(style == #vGradient) ifTrue: [form fillFromYColorBlock: [:m | self color2 mixed: m with: self color1]].
			(style == #rGradient) ifTrue: [form fillRadialFromXColorBlock: [:m | self color2 mixed: m with: self color1] center: 8@8].
			formMorph _ ImageMorph new form: form; position: 7@5.
			formMorph lock.
			b addMorph: formMorph.
			b off.
			(style == self fillStyle) ifTrue: [b on].
			fillStylePane addMorphBack: spacer fullCopy.
			fillStylePane addMorphBack: b.
			b position: b left@ b top + 2].
		fillStylePane addMorphBack: spacer fullCopy.
		options
			addMorphBack: fillStylePane].

	#text = self mode ifTrue: [
		font _ (StrikeFont fontName: 'VerdanaBold' size: 11).
		fName _ canvasMorph canvasTextBox font name.
		textFontMenu _ ImageMorph new form: (ScratchFrameMorph skinAt: #textFontMenu).
		textFontMorph _ StringMorph new font: font.
		textFontMorph contents: (textFontMorph stringWithEllipses: fName limitedToWidth: 109).
		textFontMenu addMorph: textFontMorph.
		textFontMorph position: 8@3.
		textSizeMenu _ ImageMorph new form: (ScratchFrameMorph skinAt: #textSizeMenu).
		textSizeMorph _ StringMorph contents: canvasMorph canvasTextBox font pointSize asString font: font.
		textSizeMenu addMorph: textSizeMorph.
		textSizeMorph position: 9@3.
		aColor2 _ self color1.
		(aColor2 == Color transparent) ifTrue: [aColor2 _ Color white].
			canvasMorph textColor: aColor2.
			canvasMorph changed.
		options
			addMorphBack: textFontMenu;
			addMorphBack: (Morph new width: 8; height: 5; color: Color transparent);
			addMorphBack: textSizeMenu].

	optionsPane addMorph: options.
	options position: (optionsPane left + (optionsPane width // 2) - (options width // 2))@(optionsPane top + (optionsPane height //2) - (options height // 2)).
! !

!PaintPalette methodsFor: 'event handling' stamp: 'jm 9/8/2006 09:34'!
updateToolbarButtons

	toolbarButtons ifNil: [^ self].
	toolbarButtons allMorphsDo: [:b |
		(b isKindOf: ToggleButton) ifTrue: [
			b arguments first = self mode ifTrue: [b on] ifFalse: [b off]]].
! !
