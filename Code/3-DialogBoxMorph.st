ImageFrameMorph subclass: #DialogBoxMorph
	instanceVariableNames: 'titleMorph buttonRow messageLineMorphs percentMorph done response topLeftForms topRightForms bottomLeftForms bottomRightForms topEdgeForms leftEdgeForms rightEdgeForms bottomEdgeForms mainColumn shortcutColumn fileInfoColumn titleBin bottomSpacer tabFields initialized '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Dialogs'!
!DialogBoxMorph commentStamp: 'jm 5/14/2005 16:21' prior: 0!
I am a DialogBox for presenting messages to the user and asking them simple yes/no/okay/cancel questions. I have instance variables for all the forms that comprise my frame which I draw myself.

Examples:
	DialogBoxMorph ask: 'Time for lunch?'
	DialogBoxMorph askWithCancel: 'Save project before quitting?'
	DialogBoxMorph inform: 'Operation complete.'
	DialogBoxMorph informWithCancel: 'This operation may take a while...'
	DialogBoxMorph warn: 'File not found'

For string input, see StringDialogBoxMorph.
!


!DialogBoxMorph methodsFor: 'initialization' stamp: 'ee 9/9/2005 16:19'!
addNoShadowFrameFromForm: aForm

	| cornerExtent center |
	cornerExtent _ (aForm extent - 1) // 2.
	center _ aForm extent // 2.

	topLeftForms _ Array new: 2.
	bottomLeftForms _ Array new: 2.
	topRightForms _ Array new: 2.
	bottomRightForms _ Array new: 2.
	topEdgeForms _ Array new: 2.
	leftEdgeForms _ Array new: 2.
	rightEdgeForms _ Array new: 2.
	bottomEdgeForms _ Array new: 2.

	topLeftForms
		at: 1 put: topLeftForm deepCopy;
		at: 2 put: (aForm copy: (0@0 extent: cornerExtent)).
	topRightForms
		at: 1 put: topRightForm copy;
		at: 2 put: (aForm copy: ((aForm width - cornerExtent x) @ 0 extent: cornerExtent)).
	bottomLeftForms
		at: 1 put: bottomLeftForm copy;
		at: 2 put: (aForm copy: (0 @ (aForm height - cornerExtent y) extent: cornerExtent)).
	bottomRightForms
		at: 1 put: bottomRightForm copy;
		at: 2 put: (aForm copy: ((aForm extent - cornerExtent) extent: cornerExtent)).

	topEdgeForms
		at: 1 put: topEdgeForm copy;
		at: 2 put: (aForm copy: ((center x@0) extent: (1 @ cornerExtent y))).
	leftEdgeForms
		at: 1 put: leftEdgeForm copy;
		at: 2 put: (aForm copy: ((0 @ center y) extent: (cornerExtent x @ 1))).
	rightEdgeForms
		at: 1 put: rightEdgeForm copy;
		at: 2 put: (aForm copy: (((aForm width - cornerExtent x) @ center y) extent: (cornerExtent x @ 1))).
	bottomEdgeForms
		at: 1 put: bottomEdgeForm copy;
		at: 2 put: (aForm copy: ((center x@(aForm height - cornerExtent y)) extent: (1 @ cornerExtent y))).

! !

!DialogBoxMorph methodsFor: 'initialization' stamp: 'EMP 11/5/2015 12:25'!
initialize
	"Set the forms for all my UI elements, create a row to hold my buttons, and a column to hold my shortcut buttons."
	initialized _ false.
	super initialize.
	self initFromForm: (ScratchFrameMorph skinAt: #dialogFrame).
	self addNoShadowFrameFromForm: (ScratchFrameMorph skinAt: #dialogFrameNoShadow).
	done _ false.
	tabFields _ OrderedCollection new.

	"create columns"
	mainColumn _ AlignmentMorph newColumn
		color: Color transparent;
		centering: #center;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.
	shortcutColumn _ AlignmentMorph newColumn
		color: Color transparent;
		centering: #center;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.
	fileInfoColumn _ AlignmentMorph newColumn
		color: Color transparent;
		centering: #topLeft;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.
	titleBin _ AlignmentMorph newRow
		color: Color transparent;
		centering: #center;
		hResizing: #spaceFill;
		vResizing: #rigid;
		height: 32.
	buttonRow _ AlignmentMorph newRow
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		height: 32.

	ScratchTranslator isRTL
		ifTrue: [fileInfoColumn centering: #bottomRight]
		ifFalse: [fileInfoColumn centering: #topLeft].

	self
		addMorph: mainColumn;
		addMorph: shortcutColumn;
		addMorph: fileInfoColumn;
		addMorph: titleBin.

	mainColumn addMorph: buttonRow.

	self extent: 50@50.
	initialized _ true.
! !

!DialogBoxMorph methodsFor: 'initialization' stamp: 'ee 4/16/2009 13:42'!
withButtonsForYes: yesFlag no: noFlag okay: okayFlag cancel: cancelFlag
	"Replace my current buttons with the ones specified."
	"Note: The button row morph was created by initialize; I just replace its contents with a new collection of buttons."

	| spacer |
	spacer _ Morph new extent: 10@5; color: Color transparent.
	buttonRow removeAllMorphs.

	buttonRow addMorphBack: (AlignmentMorph newSpacer: Color transparent).
	buttonRow addMorphBack: spacer.
	yesFlag ifTrue: [
		buttonRow addMorphBack: (self buttonLabel: 'Yes' localized action: #yes).
		buttonRow addMorphBack: spacer fullCopy].

	noFlag ifTrue: [
		buttonRow addMorphBack: (self buttonLabel: 'No' localized action: #no).
		buttonRow addMorphBack: spacer fullCopy].

	okayFlag ifTrue: [
		buttonRow addMorphBack: (self buttonLabel: 'OK' localized action: #yes).
		buttonRow addMorphBack: spacer fullCopy].

	cancelFlag ifTrue: [
		buttonRow addMorphBack: (self buttonLabel: 'Cancel' localized action: #cancelled).
		buttonRow addMorphBack: spacer fullCopy].

	buttonRow submorphs do: [:b |
		(b isKindOf: ResizableToggleButton2) ifTrue: [tabFields add: b]].
! !


!DialogBoxMorph methodsFor: 'accessing' stamp: 'ee 6/28/2008 12:12'!
addMessageLine: aMorph
	"Add the given morph (some kind of StringMorph, probably) centered below the other message lines."

	| ypos |
	messageLineMorphs ifNil: [messageLineMorphs _ OrderedCollection new].
	ypos _ self top + 50.
	messageLineMorphs submorphsDo: [:m | ypos _ ypos max: (m bottom + 5)].
	aMorph position: (self left + ((self width - aMorph width) // 2))@ypos.
	messageLineMorphs addMorphBack: aMorph.
	self height: (aMorph bottom - self top) + 75.
! !

!DialogBoxMorph methodsFor: 'accessing' stamp: 'ee 7/1/2008 14:58'!
buttons

	^ buttonRow submorphs select: [:m |
		m isKindOf: ResizableToggleButton2].
! !

!DialogBoxMorph methodsFor: 'accessing' stamp: 'EMP 11/4/2015 14:39'!
centerOnScreen
	"Center myself on the screen, if possible. Otherwise, adjust position so buttons are visible."

	| w |
	w _ self world.
	self extent: self extent.  
	self position: w center - (self extent // 2) + (0@5).  
	self bottom > w bottom ifTrue: [
		self bottom: w bottom + 37.  
		self top > -2 ifTrue: [self top: -2]]. 
	(self top < -2 and: [self top > -34]) ifTrue: [
		self top: -34].
! !

!DialogBoxMorph methodsFor: 'accessing' stamp: 'jm 5/21/2005 10:11'!
isDone

	^ done
! !

!DialogBoxMorph methodsFor: 'accessing' stamp: 'EMP 9/29/2015 16:02'!
shortcutButtonLabel: labelString action: actionSelector icon: aSymbol
	"Answer a new shortcut button with the given label and selector. A shortcut button has a folder icon on it. The button target will be me and it will use my button forms. Icon can be: #folderIcon, #folderCatIcon, #folderHouseIcon #folderPicIcon, #folderSoundIcon"
	"(DialogBoxMorph new shortcutButtonLabel: 'Yes' action: #beep isCat: true) openInWorld"

	| onForm offForm overForm button |
	onForm _ ScratchFrameMorph skinAt: #dialogButtonFrameOver.
	offForm _ ScratchFrameMorph skinAt: #dialogButtonFrame.
	overForm _ ScratchFrameMorph skinAt: #dialogButtonFrameOver.

	button _ ResizableToggleButton2 new
		offForm: offForm
		onForm: onForm
		overForm: overForm.

	button addMorph: (ImageMorph new form: (ScratchFrameMorph skinAt: aSymbol)).

	^ (button
		label: labelString localized font: (ScratchFrameMorph getFont: #FolderShortcut);
		target: self;
		actionSelector: actionSelector;
		setLabelColor: (Color gray: 0.15)).
! !

!DialogBoxMorph methodsFor: 'accessing' stamp: 'EMP 11/4/2015 14:37'!
title: aString
	"Note: Title is actually two StringMorphs with the same contents and font: a gray shadow of the text with a white submorph of the same text, offset by a small amount."
	titleBin ifNotNil: [titleBin delete].
	titleBin removeAllMorphs.
	titleMorph ifNotNil: [titleMorph delete].
	titleMorph _ StringMorph new
		contents: aString localized;
		color: Color black;
		font: (ScratchFrameMorph getFont: #DialogBoxTitle);
		kern: 1.

	titleBin
		addMorph: (AlignmentMorph newSpacer: Color transparent);
		addMorph: (Morph new extent: (5@5); color: Color transparent);
		addMorph: titleMorph;
		addMorph: (AlignmentMorph newSpacer: Color transparent).


	self addMorphBack: titleBin.
	self changed.
! !


!DialogBoxMorph methodsFor: 'drawing' stamp: 'jm 12/19/2006 23:54'!
areasRemainingToFill: aRectangle
	"Drawing optimization. This method tells Morphic that it isn't necessary to draw any morphs covered by me. (My bounds must be inset due to my rounded corners)."
	
	^ aRectangle areasOutside: (self bounds insetBy: 16)
! !

!DialogBoxMorph methodsFor: 'drawing' stamp: 'EMP 9/29/2015 15:38'!
drawOn: aCanvas

	| i |
	i _ (owner isKindOf: HandMorph) ifTrue: [1] ifFalse: [1].

	topLeftForm _ topLeftForms at: i.
	bottomLeftForm _ bottomLeftForms at: i.
	topRightForm _ topRightForms at: i.
	bottomRightForm _ bottomRightForms at: i.
	topEdgeForm _ topEdgeForms at: i.
	leftEdgeForm _ leftEdgeForms at: i.
	rightEdgeForm _ rightEdgeForms at: i.
	bottomEdgeForm _ bottomEdgeForms at: i.
	edgeCache _ Array new: edgeCache size.

	super drawOn: aCanvas.
! !


!DialogBoxMorph methodsFor: 'geometry' stamp: 'EMP 11/5/2015 12:31'!
extent: aPoint
	
	| w bool |
	bool _ ((self isKindOf: PaintFrame) or: [self isKindOf: BlockCreationDialog]).
	bool ifTrue: [^ super extent: aPoint].
	self fixLayoutForExtent: aPoint.
	super extent: self fullBounds extent.
	w _ self world.
	initialized ifFalse: [
	w ifNotNil: [self position: w center - (self extent // 2)]].  "center on screen"
! !

!DialogBoxMorph methodsFor: 'geometry' stamp: 'EMP 2/11/2016 14:56'!
fixLayoutForExtent: aPoint

	| xPos yPos shortcutWidth fileColumnWidth |
	shortcutColumn ifNil: [^ self].
	xPos _ self left + 20.
	yPos _ self top + 40.

	"position and size the shortcut column"
	shortcutColumn position: xPos@yPos.
	shortcutWidth _ 0.
	shortcutColumn submorphsDo: [: m |
		shortcutWidth _ m width max: shortcutWidth].
	shortcutColumn submorphsDo: [: m |
		m width: shortcutWidth].

	"position main column"
	mainColumn position: (shortcutColumn right + 5)@yPos.

	"position and size the fileInfo column"
	fileInfoColumn position: (mainColumn right + 5)@yPos.
	fileColumnWidth _ 0.
	fileInfoColumn submorphsDo: [: m |
		fileColumnWidth _ m width max: fileColumnWidth].
	fileInfoColumn submorphsDo: [: m |
		(m isKindOf: StringMorph)
			ifFalse: [m width: fileColumnWidth]].

	"position and size title"
	titleBin left: self left.
	titleBin width: shortcutColumn width + mainColumn width + fileInfoColumn width + 55.

	"add a bottom spacer to the tallest column"
	bottomSpacer ifNil: [
		bottomSpacer _ (Morph new extent: (5@22); color: Color transparent).
		(shortcutColumn height > mainColumn height)
			ifTrue: [shortcutColumn addMorphBack: bottomSpacer]
			ifFalse: [(mainColumn height > fileInfoColumn height)
				ifTrue: [mainColumn addMorphBack: bottomSpacer]
				ifFalse: [fileInfoColumn addMorphBack: bottomSpacer]]].
! !


!DialogBoxMorph methodsFor: 'interaction' stamp: 'jm 10/11/2006 17:03'!
cancelled
	"Cancel button was pressed."

	response _ #cancelled.
	done _ true.
	self delete.
	World doOneCycle.  "erase myself from the screen"
! !

!DialogBoxMorph methodsFor: 'interaction' stamp: 'jm 5/28/2009 21:31'!
getUserResponse
	"Wait for the user to respond, then report their response. The symbol #cancel is returned if the user wishes to cancel the operation. True/false is returned if they respond yes/no, and a string is returned if this this a string input dialog and they don't cancel."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	| w |
	self openInWorld.
	self centerOnScreen.
	w _ self world.
	self buttons size > 0 ifTrue: [
		w activeHand newKeyboardFocus: self buttons last].
	tabFields size > 0 ifTrue: [
		w activeHand newKeyboardFocus: (tabFields at: 1)].
	done _ false.
	[done] whileFalse: [w doOneCycle].  "wait for user to press a button"

	^ response
! !

!DialogBoxMorph methodsFor: 'interaction' stamp: 'nb 1/25/2008 13:31'!
message: aMessage
	"Set my message/question text."

	self
		message: aMessage localized
		font: (ScratchFrameMorph getFont: #DialogBoxMessage).
! !

!DialogBoxMorph methodsFor: 'interaction' stamp: 'ee 6/28/2008 12:07'!
message: aMessage details: aDetailsString font: aStrikeFont
	"Set and position my message/question text."

	| lines m |
	messageLineMorphs ifNotNil: [
		messageLineMorphs submorphsDo: [:lineM | lineM delete]].

	messageLineMorphs _ AlignmentMorph newColumn
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		centering: #center.
	lines _ aMessage lines.
	1 to: lines size do: [:n |
		m _ StringMorph
			contents: (lines at: n)
			font: aStrikeFont.
		messageLineMorphs addMorphBack: m].
	lines _ aDetailsString lines.
	1 to: lines size do: [:n |
		m _ StringMorph
			contents: (lines at: n)
			font: aStrikeFont.
		messageLineMorphs addMorphBack: m].

	mainColumn addMorph: messageLineMorphs.

	self changed.
! !

!DialogBoxMorph methodsFor: 'interaction' stamp: 'ee 6/28/2008 12:15'!
message: aMessage font: aStrikeFont
	"Set and position my message/question text."

	| lines m |
	messageLineMorphs ifNotNil: [
		messageLineMorphs submorphsDo: [:lineM | lineM delete]].

	messageLineMorphs _ AlignmentMorph newColumn
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		centering: #center.
	lines _ aMessage lines.
	1 to: lines size do: [:n |
		m _ StringMorph
			contents: (lines at: n)
			font: aStrikeFont.
		messageLineMorphs addMorphBack: m].

	mainColumn addMorph: messageLineMorphs.

	self changed.
! !

!DialogBoxMorph methodsFor: 'interaction' stamp: 'jm 10/11/2006 17:04'!
no
	"No button was pressed."

	response _ false.
	done _ true.
	self delete.
	World doOneCycle.  "erase myself from the screen"
! !

!DialogBoxMorph methodsFor: 'interaction' stamp: 'ee 6/28/2008 12:22'!
percentDone: aNumber
	"Show a percent complete indicator. The argument should be in the range 0-100."

	| percent fullWidth indicator |
	percentMorph ifNil: [
		percentMorph _ RectangleMorph new
			extent: 104@16;
			borderWidth: 1;
			color: Color transparent;
			borderColor: (Color gray: 0.5).
		indicator _ Morph new
			extent: 0@12;
			color: (Color r: 0.35 g: 0.50 b: 0.67);
			position: percentMorph position + 2.
		percentMorph addMorph: indicator.
		percentMorph position: (self center x - (percentMorph width // 2) - 5)@(buttonRow top - 27).
		mainColumn addMorph: percentMorph].

	fullWidth _ percentMorph width - 4.
	indicator _ percentMorph firstSubmorph.
	percent _ (aNumber * fullWidth / 100.0) rounded within: 0 and: fullWidth.
	indicator width: percent.

	World displayWorld.
! !

!DialogBoxMorph methodsFor: 'interaction' stamp: 'jm 10/11/2006 17:03'!
yes
	"Yes button was pressed."

	response _ true.
	done _ true.
	self delete.
	World doOneCycle.  "erase myself from the screen"
! !


!DialogBoxMorph methodsFor: 'dropping/grabbing' stamp: 'EMP 1/8/2016 07:55'!
handlesMouseDown: evt
	^ true! !

!DialogBoxMorph methodsFor: 'dropping/grabbing' stamp: 'jm 10/20/2007 18:53'!
justDroppedInto: aMorph event: evt
	"Never embed myself in a morph (e.g. the Stage)."

	self world addMorphFront: self.
! !

!DialogBoxMorph methodsFor: 'dropping/grabbing' stamp: 'EMP 1/8/2016 07:57'!
mouseDown: evt
	evt hand newKeyboardFocus: self.
	evt hand waitForClicksOrDrag: self event: evt! !


!DialogBoxMorph methodsFor: 'event handling' stamp: 'EMP 1/12/2016 16:19'!
enterKeyPressed: evt
	"Respond to the enter key being pressed in one of my input fields or on one of my buttons."

	"if a button has focus, do that button"
	(evt hand keyboardFocus isKindOf: ResizableToggleButton2) ifTrue: [
		evt hand keyboardFocus doButtonAction.
		^ self].

	"if any other submorph has focus, return OK"
	evt hand newKeyboardFocus: self.
	self yes.
! !

!DialogBoxMorph methodsFor: 'event handling' stamp: 'jm 5/28/2009 21:10'!
escapeKeyPressed: evt
	"Respond to the escape key being pressed in one of my input fields or on one of my buttons by cancelling this dialog."

	self cancelled.
! !

!DialogBoxMorph methodsFor: 'event handling' stamp: 'ee 4/16/2009 14:19'!
tabToNextField: evt
	"Move the keyboard focus to the next submorph that responds to keyboard events."

	| current |

	tabFields size = 0 ifTrue: [^ self].

	current _ (1 to: tabFields size) detect: [:i |
		(tabFields at: i) == evt hand keyboardFocus] ifNone: [tabFields size].
	evt hand newKeyboardFocus: (tabFields at: (current \\ tabFields size) + 1).
! !


!DialogBoxMorph methodsFor: 'private' stamp: 'EMP 9/29/2015 16:03'!
buttonLabel: labelString action: actionSelector
	"Answer a new button with the given label and selector. The button target will be me and it will use my button forms."
	"(DialogBoxMorph new buttonLabel: 'Yes' action: #beep) openInWorld"

	| onForm offForm button overForm |
	onForm _ ScratchFrameMorph skinAt: #dialogButtonFrameOver.
	offForm _ ScratchFrameMorph skinAt: #dialogButtonFrame.
	overForm _ ScratchFrameMorph skinAt: #dialogButtonFrameOver.

	button _ ResizableToggleButton2 new
		offForm: offForm
		onForm: onForm
		overForm: overForm.

	^ button
		padding: 39@22;
		label: labelString font: (ScratchFrameMorph getFont: #DialogBoxButton);
		target: self;
		actionSelector: actionSelector;
		setLabelColor: (Color gray: 0.15)
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

DialogBoxMorph class
	instanceVariableNames: ''!

!DialogBoxMorph class methodsFor: 'instance creation' stamp: 'jm 5/14/2005 19:02'!
ask: questionString
	"Put up an instance of me to ask a yes/no question. Answer true or false depending on which button the user presses."
	"DialogBoxMorph ask: 'Time for lunch?'"

	| dialogBox |
	dialogBox _ self new
		title: '?';
		withButtonsForYes: true no: true okay: false cancel: false;
		message: questionString.
	^ dialogBox getUserResponse
! !

!DialogBoxMorph class methodsFor: 'instance creation' stamp: 'EMP 11/18/2015 14:49'!
ask: questionString title: titleString
	"Put up an instance of me to ask a yes/no question. Answer true or false depending on which button the user presses."
	"DialogBoxMorph ask: 'Time for lunch?'"

	| dialogBox |
	dialogBox _ self new
		title: titleString;
		withButtonsForYes: true no: true okay: false cancel: false;
		message: questionString.
	^ dialogBox getUserResponse
! !

!DialogBoxMorph class methodsFor: 'instance creation' stamp: 'jm 5/14/2005 19:02'!
askWithCancel: questionString
	"Put up an instance of me to ask a yes/no question but include a cancel button as well. Answer either a boolean or the symbol #cancelled."
	"DialogBoxMorph askWithCancel: 'Save project before quitting?'"

	| dialogBox |
	dialogBox _ self new
		title: '?';
		withButtonsForYes: true no: true okay: false cancel: true;
		message: questionString.
	^ dialogBox getUserResponse
! !

!DialogBoxMorph class methodsFor: 'instance creation' stamp: 'nb 1/25/2008 13:31'!
inform: informationString
	"Put up an instance of me to give the user an informational message and wait until they click the 'ok' button before proceeding."
	"DialogBoxMorph inform: 'Operation complete.'"

	| dialogBox |
	dialogBox _ self new
		withButtonsForYes: false no: false okay: true cancel: false.
	dialogBox
		message: informationString
		font: (ScratchFrameMorph getFont: #DialogBoxMessage).

	^ dialogBox getUserResponse
! !

!DialogBoxMorph class methodsFor: 'instance creation' stamp: 'jm 2/16/2008 11:39'!
inform: informationString title: titleString
	"Put up an instance of me to give the user an informational message and wait until they click the 'ok' button before proceeding."
	"DialogBoxMorph inform: 'Operation complete.' title: 'Status'"

	| dialogBox |
	dialogBox _ self new
		withButtonsForYes: false no: false okay: true cancel: false;
		title: titleString.
	dialogBox
		message: informationString
		font: (StrikeFont fontName: 'VerdanaBold' size: 13).

	^ dialogBox getUserResponse
! !

!DialogBoxMorph class methodsFor: 'instance creation' stamp: 'jm 4/25/2008 15:23'!
inform: informationString withDetails: detailsString
	"Put up an instance of me to give the user an informational message and wait until they click the 'ok' button before proceeding."
	"DialogBoxMorph inform: 'Operation complete.'"

	| dialogBox |
	dialogBox _ self new
		withButtonsForYes: false no: false okay: true cancel: false.
	dialogBox
		message: (informationString localized, ScratchTranslator colonSuffix)
		details: detailsString
		font: (ScratchFrameMorph getFont: #DialogBoxMessage).

	^ dialogBox getUserResponse
! !

!DialogBoxMorph class methodsFor: 'instance creation' stamp: 'jm 5/21/2005 10:00'!
informWithCancel: informationString
	"Put up an instance of me to give the user an informational message and wait until they click the 'ok' button before proceeding."
	"DialogBoxMorph informWithCancel: 'This operation may take a while...'"

	| dialogBox |
	dialogBox _ self new
		withButtonsForYes: false no: false okay: false cancel: true;
		message: informationString.
	^ dialogBox getUserResponse
! !

!DialogBoxMorph class methodsFor: 'instance creation' stamp: 'jm 5/14/2005 19:02'!
warn: informationString
	"Put up an instance of me to give the user a warning message and wait until they click the 'ok' button before proceeding."
	"DialogBoxMorph warn: 'File not found'"

	| dialogBox |
	dialogBox _ self new
		title: '!!';
		withButtonsForYes: false no: false okay: true cancel: false;
		message: informationString.
	^ dialogBox getUserResponse
! !
