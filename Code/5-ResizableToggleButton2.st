SimpleButtonMorph subclass: #ResizableToggleButton2
	instanceVariableNames: 'label iconMorph current normal pressed over labelColorOff labelColorOn labelColorOver isOn wasOn toggleMode toggleButtonMode justification padding hOffset vOffset '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ResizableToggleButton2 methodsFor: 'initialization' stamp: 'jm 7/10/2008 13:45'!
forceUnicodeRendering: aBoolean

	label forceUnicodeRendering: aBoolean.
	self updateSize.

! !

!ResizableToggleButton2 methodsFor: 'initialization' stamp: 'jm 7/1/2008 10:20'!
initialize

	super initialize.
	self cornerStyle: #square.
	color _ Color transparent.
	borderWidth _ 0.
	isOn _ false.
	toggleButtonMode _ false.
	toggleMode _ true.
	justification _ #center.
	hOffset _ 0.
	vOffset _ 5.
	padding _ 8@8.

	label _ StringMorph new.
	labelColorOff _ Color r: (78/255) g: (82/255) b: (82/255).
	labelColorOn _ Color black.
	labelColorOver _ labelColorOff.
! !

!ResizableToggleButton2 methodsFor: 'initialization' stamp: 'ee 4/23/2008 21:54'!
label: aString font: font

	label delete.
	label
		contents: aString font: font;
		color: (isOn ifTrue: [labelColorOn] ifFalse: [labelColorOff]).
	self addMorphFront: label.
	self updateSize.
! !

!ResizableToggleButton2 methodsFor: 'initialization' stamp: 'jm 7/1/2008 10:26'!
offForm: offForm onForm: onForm

	normal _ ImageFrameMorph new initFromForm: offForm.
	pressed _ ImageFrameMorph new initFromForm: onForm.
	over _ nil.
	current _ normal.
	padding _ normal minExtent - (0@5).

	toggleMode _ false.
	self off.

! !

!ResizableToggleButton2 methodsFor: 'initialization' stamp: 'jm 2/11/2008 11:37'!
offForm: offForm onForm: onForm overForm: overForm

	self offForm: offForm onForm: onForm.
	overForm ifNotNil: [over _ ImageFrameMorph new initFromForm: overForm].

! !

!ResizableToggleButton2 methodsFor: 'initialization' stamp: 'nb 1/8/2008 14:16'!
setDefaultLabel
	"Overridden to do nothing. I have no label by default, although a label can be added."
! !

!ResizableToggleButton2 methodsFor: 'initialization' stamp: 'jm 2/7/2008 08:43'!
setLabelColor: aColor
	"Sets all label colors to the given color."

	self labelColorOn: aColor labelColorOff: aColor labelColorOver: aColor.
! !


!ResizableToggleButton2 methodsFor: 'accessing' stamp: 'ee 7/1/2008 15:06'!
action

	^ actionSelector
! !

!ResizableToggleButton2 methodsFor: 'accessing' stamp: 'jm 1/17/2008 13:16'!
color

	current ifNil: [^ Color white].
	^ current color
! !

!ResizableToggleButton2 methodsFor: 'accessing' stamp: 'jm 2/19/2008 00:02'!
icon: aForm
	"Add an icon to this button."

	iconMorph ifNotNil: [iconMorph delete].  "delete old icon"
	iconMorph _ ImageMorph new form: aForm.
	self addMorph: iconMorph.
	self extent: (iconMorph extent + 10).

! !

!ResizableToggleButton2 methodsFor: 'accessing' stamp: 'nb 1/8/2008 14:16'!
isOn

	^ isOn
! !

!ResizableToggleButton2 methodsFor: 'accessing' stamp: 'nb 3/30/2008 16:51'!
label

	^ label
! !

!ResizableToggleButton2 methodsFor: 'accessing' stamp: 'jm 2/8/2008 08:23'!
off
	"Turn myself off."

	isOn _ false.
	self setCurrent: normal.
	label color: labelColorOff.

! !

!ResizableToggleButton2 methodsFor: 'accessing' stamp: 'jm 2/8/2008 08:23'!
on
	"Turn myself on."

	isOn _ true.
	self setCurrent: pressed.
	label color: labelColorOn.

! !

!ResizableToggleButton2 methodsFor: 'accessing' stamp: 'ee 8/8/2008 20:56'!
over
	"Show my over skin."

	"toggleButtonMode ifFalse: [^ self]."
	isOn ifTrue: [^ self].
	over ifNil: [^ self].

	self setCurrent: over.
	label color: labelColorOver.
! !

!ResizableToggleButton2 methodsFor: 'accessing' stamp: 'jm 7/1/2008 10:21'!
padding: aPoint

	padding _ aPoint.
! !

!ResizableToggleButton2 methodsFor: 'accessing' stamp: 'nb 1/14/2008 14:17'!
toggleButtonMode: mode
	"If set to true, the button switches from on to off with a click, and the button remains in on mode until it is clicked again. If it is set to false, the button goes into on mode only when the mouse button is held down. toggleMode also disables changing the font color when in on mode."

	toggleButtonMode _ mode.
! !

!ResizableToggleButton2 methodsFor: 'accessing' stamp: 'nb 1/14/2008 14:19'!
toggleMode: mode
	"The same as ToggleButton's toggleMode. If set to true, clicking the button when turns it from on to off. If false, clicking the button when on does nothing."

	toggleMode _ mode.
! !


!ResizableToggleButton2 methodsFor: 'event handling' stamp: 'jm 2/28/2008 14:54'!
copyRecordingIn: dict
	"Copy frame morphs for all states."

	| result |
	result _ super copyRecordingIn: dict.
	normal ifNotNil: [result normal: (normal copyRecordingIn: dict)].
	pressed ifNotNil: [result pressed: (pressed copyRecordingIn: dict)].
	over ifNotNil: [result over: (over copyRecordingIn: dict)].
	^ result! !

!ResizableToggleButton2 methodsFor: 'event handling' stamp: 'nb 1/14/2008 18:35'!
handlesMouseOver: evt
	
	^ true
! !

!ResizableToggleButton2 methodsFor: 'event handling' stamp: 'jm 5/28/2009 21:18'!
keyStroke: evt

	| ch m |
	ch _ evt unicodeChar.
	ch = 0 ifTrue: [ch _ evt keyValue].

	ch = 9 ifTrue: [  "tab"
		(m _ self ownerThatIsA: DialogBoxMorph) ifNotNil: [m tabToNextField: evt].
		^ self].

	ch = 27 ifTrue: [  "escape key"
		(m _ self ownerThatIsA: DialogBoxMorph) ifNotNil: [m escapeKeyPressed: evt].
		^ self].

	(ch = 10) | (ch = 13) ifTrue: [  "cr, lf, or enter key"
		(m _ self ownerThatIsA: DialogBoxMorph) ifNotNil: [^ m enterKeyPressed: evt].
		evt hand newKeyboardFocus: nil.
		^ self].

! !

!ResizableToggleButton2 methodsFor: 'event handling' stamp: 'ee 4/16/2009 13:45'!
keyboardFocusChange: aBoolean

	aBoolean
		ifTrue: [self on]
		ifFalse: [self off].

! !

!ResizableToggleButton2 methodsFor: 'event handling'!
mouseDown: evt


	(self owner owner class) asString = 'ScratchScriptEditorMorph' ifFalse: [
	evt hand toolType: nil.
	wasOn _ isOn.

	evt hand newKeyboardFocus: nil.

	evt rightButtonPressed ifTrue: [
		Sensor waitNoButton.
		^ self rightButtonMenu].

	toggleButtonMode
		ifTrue: [
			toggleMode
				ifTrue: [
					isOn
						ifTrue: [isOn _ false. self over]
						ifFalse: [self on]]

				ifFalse: [
					isOn
						ifTrue: [^ self]
						ifFalse: [self on]]]
		ifFalse: [self on].

	actWhen = #buttonDown ifTrue: [
		self doButtonAction.
		self off]].
! !

!ResizableToggleButton2 methodsFor: 'event handling' stamp: 'nb 1/14/2008 19:48'!
mouseEnter: evt

	self over.
! !

!ResizableToggleButton2 methodsFor: 'event handling' stamp: 'nb 1/10/2008 15:47'!
mouseLeave: evt

	isOn ifFalse: [ over ifNotNil: [self off] ].
	ScratchToolTipMorph clearToolTips.
! !

!ResizableToggleButton2 methodsFor: 'event handling'!
mouseMove: evt
 
	| containsPoint |
	actWhen = #buttonDown ifTrue: [^ self].

	containsPoint _ self containsPoint: evt cursorPoint.
	toggleButtonMode
		ifFalse: [
			containsPoint
				ifTrue: [isOn ifFalse: [self on]]
				ifFalse: [isOn ifTrue: [self off]]]
		ifTrue: [
			toggleMode
				ifTrue: [
					containsPoint
						ifTrue: [
							wasOn
								ifTrue: [isOn ifTrue: [isOn _ false. self over]]
								ifFalse: [isOn ifTrue: [^ self] ifFalse: [self on]]]
						ifFalse: [
							wasOn
								ifTrue: [isOn ifFalse: [self on]]
								ifFalse: [isOn ifTrue: [self off]]]]
				ifFalse: [
					containsPoint
						ifTrue: [
							(wasOn = true)
								ifTrue: [^ self]
								ifFalse: [isOn ifFalse: [self on]]]
						ifFalse: [
							(wasOn = true)
								ifTrue: [^ self]
								ifFalse: [isOn ifTrue: [isOn _ false. self over]]]]].
! !

!ResizableToggleButton2 methodsFor: 'event handling'!
mouseUp: evt
	
	(self owner owner class) asString = 'ScratchScriptEditorMorph' ifFalse: [
		(actWhen = #buttonUp and:
	 [self containsPoint: evt cursorPoint])
		ifTrue: [self doButtonAction].

	toggleButtonMode ifFalse: [ self off ]].
! !

!ResizableToggleButton2 methodsFor: 'event handling' stamp: 'nb 1/8/2008 14:16'!
rightButtonMenu

	| menu |
	(self owner isKindOf: ScratchBlockPaletteMorph) ifTrue: [
		menu _ CustomMenu new.
		menu add: 'help' action: #presentHelpScreen.
		menu localize; invokeOn: self].
! !


!ResizableToggleButton2 methodsFor: 'geometry' stamp: 'ee 6/13/2008 18:26'!
extent: aPoint

	super extent: aPoint.
	current ifNotNil: [current extent: aPoint].
	self updateLayout.
	iconMorph ifNotNil: [
		iconMorph position: self position + ((self extent - iconMorph extent) // 2)].
! !


!ResizableToggleButton2 methodsFor: 'layout' stamp: 'ee 6/13/2008 18:26'!
centerLabelOffset: anInteger
	"Center the label horizontally with the given offset."

	justification _ #center.
	hOffset _ anInteger.
	self updateLayout.
! !

!ResizableToggleButton2 methodsFor: 'layout' stamp: 'ee 6/13/2008 18:27'!
leftJustifyInset: anInteger
	"Left-justify the label with the given inset from the left edge."

	justification _ #left.
	hOffset _ anInteger.
	self updateLayout.
! !

!ResizableToggleButton2 methodsFor: 'layout' stamp: 'ee 6/13/2008 18:27'!
rightJustifyInset: anInteger
	"Right-justify the label with the given inset from the right edge."

	justification _ #right.
	hOffset _ anInteger.
	self updateLayout.
! !


!ResizableToggleButton2 methodsFor: 'private' stamp: 'ee 8/20/2008 02:53'!
helpScreenName
	"Answer the name of the help screen for this block, or nil if no help is available."

	#addGlobalVariable = actionSelector ifTrue: [^ 'addVariable'].
	#addGlobalList = actionSelector ifTrue: [^ 'addList'].
	(#(addVariable addGlobalVariable deleteVariable addList addGlobalList deleteList) includes: actionSelector)
		ifTrue: [^ actionSelector asString].

	^ nil
! !

!ResizableToggleButton2 methodsFor: 'private' stamp: 'nb 1/14/2008 14:11'!
labelColorOn: onColor labelColorOff: offColor labelColorOver: overColor
	
	labelColorOn _ onColor.
	labelColorOff _ offColor.
	labelColorOver _ overColor.
	isOn ifTrue: [ label color: onColor ] ifFalse: [ label color: offColor ].
! !

!ResizableToggleButton2 methodsFor: 'private' stamp: 'jm 2/28/2008 14:53'!
normal: aMorph

	normal _ aMorph.
! !

!ResizableToggleButton2 methodsFor: 'private' stamp: 'jm 2/28/2008 14:53'!
over: aMorph

	over _ aMorph.
! !

!ResizableToggleButton2 methodsFor: 'private' stamp: 'nb 1/8/2008 14:16'!
presentHelpScreen
	"Answer the name of the help screen for this block, or nil if no help is available."

	| fr |
	fr _ self ownerThatIsA: ScratchFrameMorph.
	fr
		ifNil: [^ nil]
		ifNotNil: [fr presentHelpScreen: self helpScreenName].
! !

!ResizableToggleButton2 methodsFor: 'private' stamp: 'jm 2/28/2008 14:53'!
pressed: aMorph

	pressed _ aMorph.
! !

!ResizableToggleButton2 methodsFor: 'private' stamp: 'jm 2/8/2008 08:23'!
setCurrent: aMorph
	"Make the given morph be the one currently displayed."

	aMorph ifNil: [^ self].  "should not happen"
	aMorph
		position: self position;
		extent: self extent.

	current delete.
	current _ aMorph.
	self addMorphBack: current.

! !

!ResizableToggleButton2 methodsFor: 'private' stamp: 'ee 6/13/2008 18:41'!
updateLayout
	"Update the label position within the button."

	| x y top |
	x _ ((self width - label width) // 2) + hOffset.  "center by default"
	justification = #left ifTrue: [x _ hOffset].
	justification = #right ifTrue: [x _ self width - hOffset - label width].

	y _ ((self height / 2) - vOffset) rounded.

	top _ self top + 10.
	(self submorphs size = 2)
		ifTrue: [label position: self position + (x@y)]
		ifFalse: [self submorphs reversed do: [:m |
			(m isKindOf: ImageFrameMorph) ifFalse: [
				m left: self left + ((self width - m width) // 2).
				m top: top.
				top _ m bottom + 6]]].
! !

!ResizableToggleButton2 methodsFor: 'private' stamp: 'jm 7/1/2008 10:26'!
updateSize
	"Set this button size based on the label size. Assume the label has already been set."

	| trim contentsExtent |
	trim _ ScratchTranslator verticalTrimForFont: label font.
	contentsExtent _ 0@0.
	self submorphsDo: [: m |
		(m isKindOf: ImageFrameMorph) ifFalse: [
			contentsExtent _ (contentsExtent x max: m width)@(contentsExtent y + m height)]].
	self extent: contentsExtent + padding - (0@trim).
	vOffset _ ScratchTranslator centerOffsetForButtonWithFont: label font.
	self updateLayout.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ResizableToggleButton2 class
	instanceVariableNames: ''!

!ResizableToggleButton2 class methodsFor: 'as yet unclassified' stamp: 'EMP 3/24/2016 11:26'!
onForm: onForm offForm: offForm
	^ self new offForm: offForm onForm: onForm! !
