BorderedMorph subclass: #StringFieldMorph
	instanceVariableNames: 'stringMorph frame client insetX insetY heightPadding doResizing isNumeric isEditable acceptWhenFocusLost isKeyboardFocus selectionColor selectionStart selectionEnd dragStartIndex undoState blinkState lastContents '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Dialogs'!
!StringFieldMorph commentStamp: 'jm 6/23/2005 16:08' prior: 0!
I am a simple, editable one-line string for use in dialog boxes.

If cr, lf, or enter is pressed and my client responds to it, I send the "accept" message to the client.

I support selection by dragging the mouse. Double-clicking on a word selects that word. Double-clicking at either end selects everything.

I respond to a number of editing keys including:

  backspace/delete				delete the current selection; backspace if nothing is selected
  ctrl-a							select all
  ctrl-z, ctrl-x, ctrl-c, ctrl-v		undo, cut, copy, paste
  left/right arrow				move the cursor left or right

Either the control or command key can be used to type the editing keys. That is, cmd-a does the same thing as ctrl-a. This should make both PC and Mac users happy.
!


!StringFieldMorph methodsFor: 'initialization' stamp: 'jm 7/4/2008 13:34'!
forExpressionArg

	frame _ nil.
	borderColor _ Color transparent.
	borderWidth _ 0.
	insetX _ 0.
	heightPadding _ 2.
	self font: (ScratchFrameMorph getFont: #Arg).
! !

!StringFieldMorph methodsFor: 'initialization' stamp: 'EMP 11/3/2015 12:29'!
initialize

	super initialize.
	stringMorph _ StringMorph new
		contents: UTF32 new font: (StrikeFont fontName: 'Verdana' size: 12);
		forceUnicodeRendering: true.
	self addMorph: stringMorph.

	color _ (Color gray: 0.9).
	doResizing _ false.
	isNumeric _ false.
	isEditable _ true.
	isKeyboardFocus _ false.
	acceptWhenFocusLost _ false.
	self keyboardFocusChange: false.
	selectionColor _ (Color r: 0.353 g: 0.607 b: 0.788).
	selectionStart _ selectionEnd _ 0.
	self recordUndoState.
	self rightJustify: ScratchTranslator isRTL.

	self borderInset; useNoFrame.
	self width: 100.! !

!StringFieldMorph methodsFor: 'initialization' stamp: 'EMP 9/30/2015 15:06'!
useInfoFrame

	frame _ ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #infoFrame).
	insetX _ 2.
	heightPadding _ 5.
	borderWidth _ 2.
	self font: stringMorph font.
! !

!StringFieldMorph methodsFor: 'initialization' stamp: 'jm 7/4/2008 11:39'!
useNoFrame

	frame _ nil.
	borderWidth _ 2.
	insetX _ 2.
	heightPadding _ 3.
	self font: stringMorph font.
! !

!StringFieldMorph methodsFor: 'initialization' stamp: 'jm 7/4/2008 11:52'!
useStringFieldFrame

	frame _ ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #stringFieldFrame).
	insetX _ 3.
	heightPadding _ 9.
	borderWidth _ 5.
	self font: stringMorph font.
! !

!StringFieldMorph methodsFor: 'initialization' stamp: 'jm 7/4/2008 17:57'!
useTypeinFrame

	frame _ ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #typein).
	insetX _ 2.
	heightPadding _ 5.
	borderWidth _ 2.
	self font: stringMorph font.
! !


!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 4/4/2005 08:13'!
acceptWhenFocusLost: aBoolean
	"If true, then accept my contents (as if the user hit the enter key) I lose the keyboard focus lost."

	acceptWhenFocusLost _ aBoolean.
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 7/4/2008 08:35'!
borderWidth: aNumber
	"Adjust the position of my stringMorph to the new border size."

	super borderWidth: (aNumber asInteger max: 0).
	stringMorph position: self position + borderWidth + (insetX@insetY).
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 9/10/2004 18:59'!
client: aMorphOrNil

	client _ aMorphOrNil.
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 7/4/2008 11:08'!
color

	frame ifNotNil: [^ frame color].
	^ color = Color transparent
		ifTrue: [owner color]
		ifFalse: [color]

! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 6/29/2008 17:43'!
contents

	^ stringMorph contents asUTF8
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 7/3/2008 12:35'!
contents: aString

	doResizing
		ifTrue: [stringMorph contents: aString asUTF32]
		ifFalse: [stringMorph contentsClipped: aString asUTF32].

	self stringChanged.
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 12/31/2005 09:23'!
doResizing: aBoolean
	"If true, resize myself to the size of the string."

	doResizing _ aBoolean.
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 7/2/2008 11:58'!
font

	^ stringMorph font
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 7/4/2008 13:35'!
font: aFont

	stringMorph font: aFont.
	stringMorph height: (stringMorph stringHeight: ScratchTranslator renderHintString asUTF8).
	self height: stringMorph height + (2 * borderWidth) + heightPadding.
	insetY _ (self height // 2) - borderWidth - (ScratchTranslator centerOffsetForButtonWithFont: aFont).
	insetY _ insetY max: 1.
	self borderWidth: borderWidth.  "re-position string"
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 7/11/2008 06:53'!
isEditable
	"Answer true if I am editable."

	isEditable ifNil: [isEditable _ true].
	^ isEditable
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 7/11/2008 06:53'!
isEditable: aBoolean

	isEditable _ aBoolean.
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 12/31/2005 10:15'!
isNumeric: aBoolean
	"If true, then only allow typing digits and decimal point."

	isNumeric _ aBoolean.
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 3/26/2008 12:29'!
passwordMode: aBoolean

	stringMorph passwordMode: aBoolean.
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 7/3/2008 10:41'!
rightJustify: aBoolean

	stringMorph rightJustify: aBoolean.
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 7/9/2008 23:23'!
savedContents
	"If the user is editing, return the last contents before editing. Otherwise, return my contents."

	(isKeyboardFocus and: [lastContents notNil]) ifTrue: [^ lastContents asUTF8].
	^ stringMorph contents asUTF8
! !

!StringFieldMorph methodsFor: 'accessing' stamp: 'jm 3/17/2005 12:16'!
textColor: aColor
	"Set the color of my text."

	stringMorph color: aColor.
! !


!StringFieldMorph methodsFor: 'geometry' stamp: 'jm 7/4/2008 09:13'!
extent: aPoint

	super extent: aPoint.
	stringMorph width: ((self width - (2 * borderWidth) - insetX) max: 0).
! !

!StringFieldMorph methodsFor: 'geometry' stamp: 'jm 6/29/2008 14:44'!
fullBounds
	"Overridden to clip submorph hit detection to my bounds."

	fullBounds ifNil: [fullBounds _ bounds].
	^ bounds
! !


!StringFieldMorph methodsFor: 'drawing' stamp: 'jm 7/4/2008 11:08'!
drawOn: aCanvas
	"Draw the background then the selection."

	frame
		ifNil: [
			super drawOn: aCanvas]
		ifNotNil: [
			frame position: self topLeft; extent: self extent.
			frame drawOn: aCanvas].

	isKeyboardFocus ifTrue: [self drawSelectionOn: aCanvas].
! !

!StringFieldMorph methodsFor: 'drawing' stamp: 'jm 8/8/2008 14:48'!
drawSelectionOn: aCanvas

 	| xRanges clipC vInset offset selectionH rect pair start end |
	xRanges _ stringMorph xRangesFor: stringMorph stringToDisplay.
	clipC _ aCanvas copyClipRect: self innerBounds.
	vInset _ borderWidth + 2.
	offset _ stringMorph leftMargin@(self top + vInset).
	selectionH _ self height - (2 * vInset).

	selectionStart = selectionEnd ifTrue: [
		blinkState ifNil: [blinkState _ true].
		blinkState ifTrue: [
			rect _ ((self currsorOffsetFor: selectionStart) - 1)@0 extent: 2@selectionH.
			clipC fillRectangle: (rect translateBy: offset) color: selectionColor].
		^ self].

	selectionStart < selectionEnd
		ifTrue: [
			start _ selectionStart + 1.
			end _ selectionEnd]
		ifFalse: [
			start _ selectionEnd + 1.
			end _ selectionStart].

	start to: end do: [:i |
		(i between: 1 and: xRanges size) ifTrue: [
			pair _ xRanges at: i.
			rect _ (pair first @ 0) corner: (pair second @ selectionH).
			clipC fillRectangle: (rect translateBy: offset) color: selectionColor]].
! !

!StringFieldMorph methodsFor: 'drawing' stamp: 'jm 7/1/2008 10:16'!
drawSubmorphsOn: aCanvas
	"Clip submorph drawing to my bounds."

	"stringMorph suppressAntiAliasing: isKeyboardFocus."
	super drawSubmorphsOn: (aCanvas copyClipRect: self innerBounds).
! !


!StringFieldMorph methodsFor: 'event handling' stamp: 'jm 7/3/2008 10:58'!
click: evt

	| hadFocus |
	hadFocus _ isKeyboardFocus.
	evt hand newKeyboardFocus: self.
	hadFocus
		ifTrue: [
			selectionStart _ self characterOffsetForXOffset: evt cursorPoint x.
			selectionEnd _ selectionStart]
		ifFalse: [
			self selectAll].
	self changed.
! !

!StringFieldMorph methodsFor: 'event handling' stamp: 'jm 7/3/2008 10:58'!
doubleClick: evt
	"Select word or entire contents."

	| xOffset i |
	evt hand newKeyboardFocus: self.
	xOffset _ evt cursorPoint x - stringMorph left.
	xOffset < 3 ifTrue: [^ self selectAll].
	i _ self characterOffsetForXOffset: evt cursorPoint x.
	self selectWordOrAll: i + 1.
! !

!StringFieldMorph methodsFor: 'event handling' stamp: 'jm 12/31/2005 10:02'!
handlesMouseDown: evt

	^ self isEditable & evt hand toolType isNil
! !

!StringFieldMorph methodsFor: 'event handling'!
keyStroke: t1 
	| t2 t3 |
	t2 _ t1 unicodeChar.
	t2 = 0 ifTrue: [t2 _ t1 keyValue].
	t1 commandKeyPressed | t1 controlKeyPressed ifTrue: [t2 _ t2 \\ 32].
	t2 = 3 & (t1 buttons = 0) ifTrue: [t2 _ 13].
	t2 = 9
		ifTrue: 
			[(t3 _ self ownerThatIsA: DialogBoxMorph) ifNotNil: [t3 tabToNextField: t1].
			(t3 _ self ownerThatIsA: CommandBlockMorph) ifNotNil: [t3 tabToNextField: t1].
			^ self].
	t2 = 10 | (t2 = 13)
		ifTrue: 
			[(t3 _ self ownerThatIsA: DialogBoxMorph) ifNotNil: [^ t3 enterKeyPressed: t1].
			(t3 _ self ownerThatIsA: ScratchPrompterMorph) ifNotNil: [^ t3 enterKeyPressed].
			t1 hand newKeyboardFocus: nil.
			^ self].
	t2 = 27
		ifTrue: 
			[(t3 _ self ownerThatIsA: DialogBoxMorph) ifNotNil: [t3 escapeKeyPressed: t1].
			^ self].
	t2 = 8 ifTrue: [^ self backspace].
	t2 = 127 ifTrue: [^ self deleteSelection].
	t1 buttons = 64 | (t1 buttons = 16)
		ifTrue: 
			[t2 _ t2 \\ 32.
			t2 = 1 ifTrue: [self selectAll].
			t2 = 3 ifTrue: [self copySelection].
			t2 = 22 ifTrue: [self paste].
			t2 = 24 ifTrue: [self cutSelection].
			t2 = 26 ifTrue: [self undo]].
	t1 buttons = 8
		ifTrue: 
			[t2 = 28 ifTrue: [self moveCursorLeftAndSelect].
			t2 = 29 ifTrue: [self moveCursorRightAndSelect].
			t2 = 1 ifTrue: [self moveCursorHomeAndSelect].
			t2 = 4 ifTrue: [self moveCursorEndAndSelect]].
	t1 buttons = 0
		ifTrue: 
			[t2 = 1 ifTrue: [self moveCursorHome].
			t2 = 4 ifTrue: [self moveCursorEnd].
			t2 = 28 ifTrue: [self moveCursorLeft].
			t2 = 29 ifTrue: [self moveCursorRight].
			blinkState _ true].
	t2 >= 32 ifTrue: [self insertCharacter: t2]! !

!StringFieldMorph methodsFor: 'event handling' stamp: 'EMP 4/10/2016 15:28'!
keyboardFocusChange: amGettingFocus
	| label |
	"Set my color to show whether I have focus."

	(amGettingFocus and: [isKeyboardFocus not]) ifTrue: [
		lastContents _ stringMorph contents].

	(isKeyboardFocus and: [amGettingFocus not]) ifTrue: [
		lastContents _ nil.
		isNumeric ifTrue: [
			self contents: stringMorph contents asNumberNoError printStringNoExponent].
		acceptWhenFocusLost ifTrue: [self acceptEdits]].

	isKeyboardFocus _ amGettingFocus.
	isKeyboardFocus ifTrue: [selectionStart _ 0. selectionEnd _ stringMorph contents size.].
	(self ownerThatIsA: CustomBlockLabelMorph)
		ifNotNil: [isKeyboardFocus
				ifTrue: [(self ownerThatIsA: CustomBlockLabelMorph) lightColor]
				ifFalse: [(self ownerThatIsA: CustomBlockLabelMorph) darkColor]].
	((label _ self ownerThatIsA: CustomBlockLabelMorph) ifNil: [label _ self ownerThatIsA: ColoredExpressionArgMorph]) ifNotNil: [label showDeleteButton: isKeyboardFocus].
	self changed.
! !

!StringFieldMorph methodsFor: 'event handling' stamp: 'jm 7/3/2008 10:58'!
mouseDown: evt

	dragStartIndex _ self characterOffsetForXOffset: evt cursorPoint x.
	evt hand waitForClicksOrDrag: self event: evt.
! !

!StringFieldMorph methodsFor: 'event handling' stamp: 'jm 7/3/2008 10:58'!
mouseMove: evt

	| currIndex |
	dragStartIndex ifNil: [dragStartIndex _ 0].
	currIndex _ self characterOffsetForXOffset: evt cursorPoint x.
	selectionStart _ currIndex min: dragStartIndex.
	selectionEnd _ currIndex max: dragStartIndex.
	self changed.
! !

!StringFieldMorph methodsFor: 'event handling' stamp: 'jm 9/10/2004 18:52'!
preemptsMouseDown: evt

	^ true
! !

!StringFieldMorph methodsFor: 'event handling' stamp: 'jm 12/12/2006 20:05'!
startDrag: evt
	"Do nothing if have keyboard focus. Otherwise, allow myself to be grabbed."

	| myBlock |
	isKeyboardFocus ifFalse: [
		myBlock _ self ownerThatIsA: BlockMorph.
		myBlock
			ifNil: [super startDrag: evt]
			ifNotNil: [myBlock startDrag: evt]].
! !


!StringFieldMorph methodsFor: 'stepping' stamp: 'EMP 11/3/2015 12:28'!
step

	isKeyboardFocus ifFalse: [^ self].
	blinkState ifNil: [blinkState _ false].
	blinkState _ blinkState not.
	selectionStart = selectionEnd ifTrue: [self changed].! !

!StringFieldMorph methodsFor: 'stepping' stamp: 'EMP 11/17/2015 09:39'!
stepTime

	^ 600! !


!StringFieldMorph methodsFor: 'text editing' stamp: 'jm 7/3/2008 11:06'!
backspace
	"Delete the current selection. If there is no selection, delete the character before the cursor."

	| str newStr |
	(self rightSelection - self leftSelection) > 0 ifTrue: [^ self removeSelection].
	self leftSelection < 1 ifTrue: [^ self].
	self recordUndoState.
	str _ stringMorph contents.
	newStr _
		(str copyFrom: 1 to: self leftSelection - 1),
		(str copyFrom: self leftSelection + 1 to: str size).
	stringMorph contentsClipped: newStr.
	selectionEnd _ selectionStart _ (self leftSelection - 1) max: 0.
	self stringChanged.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'jm 6/30/2008 16:18'!
copySelection
	"Save the current selection in the clipboard."

	| s |
	s _ stringMorph contents 
		copyFrom: self leftSelection + 1 
		to: self rightSelection.
	s size = 0 ifTrue: [^ self].
	ScratchTranslator unicodeClipboardPut: s.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'tis 3/2/2007 20:04'!
cutSelection
	"Cut the current selection."

	selectionStart = selectionEnd ifTrue: [^ self].  "no selection; do nothing"
	self copySelection.  "save the selection we're about to cut"
	self removeSelection.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'jm 7/3/2008 11:06'!
deleteSelection
	"Delete the current selection. If there is no selection, delete the character after the cursor."

	| str newStr |
	str _ stringMorph contents.
	(self rightSelection - self leftSelection) > 0 ifTrue: [^ self removeSelection].
	(self rightSelection >= str size) ifTrue: [^ self].
	self recordUndoState.
	newStr _
		(str copyFrom: 1 to: self leftSelection),
		(str copyFrom: self leftSelection + 2 to: str size).
	stringMorph contentsClipped: newStr.
	selectionEnd _ selectionStart _ self leftSelection max: 0.
	self stringChanged.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'jm 7/3/2008 11:06'!
insertCharacter: unicodeChar
	"Insert the given character at the cursor position."

	| str newStr insertion |
	isNumeric ifTrue: [
		('-0123456789.,' asByteArray includes: unicodeChar)
			ifFalse: [^ self beep]].

	self recordUndoState.
	str _ stringMorph contents.
	insertion _ UTF32 with: unicodeChar.
	(str class = UTF8) ifTrue: [insertion _ insertion asUTF8].
	(str class = String) ifTrue: [insertion _ insertion asMacRoman].
	newStr _
		(str copyFrom: 1 to: self leftSelection),
		insertion,
		(str copyFrom: (self rightSelection + 1) to: str size).
	selectionEnd _ selectionStart _ self leftSelection + 1.
	stringMorph contentsClipped: newStr.
	self stringChanged.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'tis 8/2/2006 15:14'!
moveCursorEnd
	"Move the cursor (selectionStart) to the end of the current line."

	self moveCursorEndAndSelect.
	selectionEnd _ selectionStart.
	self changed.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'tis 8/2/2006 15:15'!
moveCursorEndAndSelect
	"Move the cursor (selectionStart), and select contents, to the end of the current line."

	self recordUndoState.
	selectionStart _ stringMorph contents size.
	self changed.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'tis 8/2/2006 15:15'!
moveCursorHome
	"Move the cursor (selectionStart) to the beginning of the current line."

	self moveCursorHomeAndSelect.
	selectionEnd _ selectionStart.
	self changed.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'tis 8/2/2006 15:16'!
moveCursorHomeAndSelect
	"Move the cursor (selectionStart), and select contents, to the beginning of the current line."

	self recordUndoState.
	selectionStart _ 0.
	self changed.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'tis 8/1/2006 15:14'!
moveCursorLeft
	"Move the cursor (selectionStart) left by one character."

	self moveCursorLeftAndSelect.
	selectionEnd _ selectionStart.
	self changed.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'tis 8/2/2006 15:16'!
moveCursorLeftAndSelect
	"Move the cursor (selectionStart), and select, left by one character."

	self recordUndoState.
	selectionStart _ (selectionStart - 1) max: 0.
	self changed.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'tis 8/1/2006 15:13'!
moveCursorRight
	"Move the cursor (selectionStart) right by one character."

	self moveCursorRightAndSelect.
	selectionEnd _ selectionStart.
	self changed.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'tis 8/2/2006 15:16'!
moveCursorRightAndSelect
	"Move the cursor (selectionStart), and select, right by one character."

	self recordUndoState.
	selectionStart _ (selectionStart + 1) min: stringMorph contents size.
	self changed.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'jm 7/3/2008 11:06'!
paste
	"Paste the last cut or copy over the current selection."

	| strToInsert str newStr |
	strToInsert _ ScratchTranslator unicodeClipboard.
	strToInsert size = 0 ifTrue: [^ self].

	self recordUndoState.
	str _ stringMorph contents.
	newStr _
		(str copyFrom: 1 to: self leftSelection),
		strToInsert,
		(str copyFrom: (self rightSelection + 1) to: str size).
	selectionEnd _ selectionStart _ self leftSelection + strToInsert size.
	stringMorph contentsClipped: newStr.
	self stringChanged.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'jm 9/14/2004 15:09'!
recordUndoState
	"Remember the current contents and selection to allow undo."

	undoState _ Array
		with: stringMorph contents
		with: selectionStart
		with: selectionEnd.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'jm 7/3/2008 11:07'!
removeSelection
	"Cut the current selection."

	| str newStr |
	self recordUndoState.
	str _ stringMorph contents.
	newStr _ 
		(str copyFrom: 1 to: self leftSelection), 
		(str copyFrom: self rightSelection + 1 to: str size).
	stringMorph contentsClipped: newStr.
	selectionEnd _ selectionStart _ self leftSelection.
	self stringChanged.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'jm 9/14/2004 15:21'!
selectAll
	"Select my entire contents."

	self recordUndoState.
	selectionStart _ 0.
	selectionEnd _ stringMorph contents size.
	self changed.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'jm 9/14/2004 16:10'!
selectWordOrAll: index

	| str wordStart wordEnd |
	str _ stringMorph contents.
	(index < 1) | (index > str size) ifTrue: [^ self selectAll].  "off end, select all"
	(str at: index) isSeparator ifTrue: [^ self].  "on separator; do nothing"

	self recordUndoState.
	wordStart _ index.
	[(wordStart >= 1) and: [(str at: wordStart) isSeparator not]]
		whileTrue: [wordStart _ wordStart - 1].
	wordEnd _ index.
	[(wordEnd < str size) and: [(str at: wordEnd) isSeparator not]]
		whileTrue: [wordEnd _ wordEnd + 1].
	(str at: wordEnd) isSeparator ifTrue: [wordEnd _ wordEnd - 1].

	selectionStart _ wordStart.
	selectionEnd _ wordEnd.
	self changed.
! !

!StringFieldMorph methodsFor: 'text editing' stamp: 'jm 7/3/2008 11:07'!
undo
	"Swap the undo buffer witht the current state. Doing this a second time will undo the undo operation."

	| oldUndoState |
	oldUndoState _ undoState.
	self recordUndoState.
	stringMorph contentsClipped: (oldUndoState at: 1).
	selectionStart _ (oldUndoState at: 2).
	selectionEnd _ (oldUndoState at: 3).
	self stringChanged.
! !


!StringFieldMorph methodsFor: 'private' stamp: 'tis 12/18/2006 15:43'!
acceptEdits
	"Tell the client to accept edits."

	client ifNil: [^ self].
	(client respondsTo: #accept) ifTrue: [client accept].
	(client respondsTo: #acceptContents) ifTrue: [client acceptContents].
	(client respondsTo: #yes) ifTrue: [client yes].
! !

!StringFieldMorph methodsFor: 'private' stamp: 'jm 8/8/2008 14:54'!
characterOffsetForXOffset: screenX
	"Answer the character offset at the given width into the string."

	| x xRanges p best isLTR |
	stringMorph contents size = 0 ifTrue: [^ 0].

	x _ screenX - stringMorph leftMargin.  "x offset within the string"
	xRanges _ stringMorph xRangesFor: stringMorph stringToDisplay.

	1 to: xRanges size do: [:i |
		p _ xRanges at: i.
		(x between: p first and: p last) ifTrue: [
			isLTR _ self isLTRAt: i in: xRanges.
			(x - p first) <= (p last - x)   "left half of character?"
				ifTrue: [^ isLTR ifTrue: [i - 1] ifFalse: [i]]
				ifFalse: [^ isLTR ifTrue: [i] ifFalse: [i - 1]]]].

	"x is not within any x-range"
	x < 0
		ifTrue: [  "x is left of the entire string; find left-most char index"
			best _ 1.
			1 to: xRanges size do: [:i |
				p _ xRanges at: i.
				p first < (xRanges at: best) first ifTrue: [best _ i]].
			best = 1 ifTrue: [best _ 0].
			^ best]
		ifFalse: [  "x is right of entire string; find right-most char index"
			best _ 1.
			1 to: xRanges size do: [:i |
				p _ xRanges at: i.
				p last > (xRanges at: best) last ifTrue: [best _ i]].
			best = 1 ifTrue: [best _ 0].
			^ best].

! !

!StringFieldMorph methodsFor: 'private' stamp: 'jm 8/8/2008 12:43'!
currsorOffsetFor: characterOffset
	"Answer the insertion cursor x offset for the given character offset."

	| s xRanges xPairChar0 xPairCharLast startsOnLeft r xPairCharOffset |
	stringMorph contents size = 0 ifTrue: [^ 0].

	s _ stringMorph stringToDisplay.
	xRanges _ stringMorph xRangesFor: s.
	xPairChar0 _ xRanges at: 1.
	xPairCharLast _ xRanges last.
	startsOnLeft _ xPairChar0 first < xPairCharLast last.

	"special case for a single character; double it to see if it is RTL"
	xRanges size = 1 ifTrue: [
		r _ stringMorph xRangesFor: (s asUTF8, s asUTF8).
		startsOnLeft _ r first first < r last last].

	"if string starts left-to-right, then put cursor on the left side left of first char, otherwise put it on the right side"
	characterOffset < 1 ifTrue: [
		startsOnLeft
			ifTrue: [^ xPairChar0 first]
			ifFalse: [^ xPairChar0 last - 1]].

	xPairCharOffset _ xRanges at: (characterOffset min: xRanges size).

	"if string starts left-to-right, then put cursor on right size of character"
	startsOnLeft
		ifTrue: [^ xPairCharOffset last]
		ifFalse: [^ xPairCharOffset first].
! !

!StringFieldMorph methodsFor: 'private' stamp: 'jm 8/8/2008 14:44'!
isLTRAt: index in: xRange
	"True if the character at the given index in the given xRange is LTR."
	"Note: we decide direction based on the following character if possible."

	xRange size < 2 ifTrue: [^ true].  "can't tell direction from a single character; assume LTR"	

	index >= xRange size ifTrue: [
		^ (xRange at: xRange size - 1) first < xRange last first]. "at end; compare to previous character"

	^ (xRange at: index) first < (xRange at: index + 1) first
! !

!StringFieldMorph methodsFor: 'private' stamp: 'tis 3/2/2007 19:46'!
leftSelection

	^ selectionStart min: selectionEnd! !

!StringFieldMorph methodsFor: 'private' stamp: 'tis 3/2/2007 19:46'!
rightSelection

	^ selectionStart max: selectionEnd! !

!StringFieldMorph methodsFor: 'private' stamp: 'jm 7/4/2008 13:43'!
stringChanged
	"My string has changed. Resize myself if necessary and report the change."

	doResizing ifTrue: [
		stringMorph fitContents.
		self width: (stringMorph right - self left) + borderWidth + 3].
	(owner respondsTo: #fixArgLayout) ifTrue: [owner fixArgLayout].
	self changed.
! !
