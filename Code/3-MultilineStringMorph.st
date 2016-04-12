BorderedMorph subclass: #MultilineStringMorph
	instanceVariableNames: 'font textColor selectionColor lines isEditable centerText hasFocus selectionStart selectionEnd startLoc blinkState growWithText renderer suppressAntiAliasing renderWithSqueak inset lineHeight '
	classVariableNames: 'CR '
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!MultilineStringMorph commentStamp: '<historical>' prior: 0!
An editable, multiple-line string in a single font with line wrapping.

Best for small amounts of text; for longer texts or texts with multiple type styles, see TextMorph.

My contents are stored in an array of strings ('lines') with all non-printing characters except cr's and spaces stripped out and tabs are replaced by a sequence of spaces.

Selection start and end points are represented as points where y holds the line number and x holds the index in the line of the character immediately after the selection point. The range of x for line L is thus 1 to (L size + 1), where the last selection point within the line is just before the line break.

Possible improvements:
  a. handle tabs correctly
  b. preserve non-printing characters (could be useful for editing files)
!


!MultilineStringMorph methodsFor: 'initialization' stamp: 'jm 8/11/2008 07:36'!
initialize

	super initialize.
	color _ Color transparent.
	textColor _ Color black.
	selectionColor _ Color r: 0.353 g: 0.607 b: 0.788.
	lines _ Array with: self emptyLine.
	isEditable _ true.
	centerText _ false.
	hasFocus _ false.
	selectionStart _ selectionEnd _ 1.
	blinkState _ true.
	growWithText _ false.
	inset _ 5@3.
	suppressAntiAliasing _ false.
	renderWithSqueak _ false.
	self font: TextStyle defaultFont.
	super extent: 90@25.
! !


!MultilineStringMorph methodsFor: 'copying' stamp: 'jm 7/25/2006 10:22'!
copy
	"Return a copy with a copy of my lines array."

	^ super copy setLines: lines copy
! !


!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 8/2/2008 14:24'!
centerText: aBoolean

	centerText _ aBoolean.
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 7/11/2008 15:07'!
contents
	"Answer my contents as a string."

	| sz result i |
	sz _ 0.
	lines do: [:s | sz _ sz + s size].
	result _ UTF32 new: sz.
	i _ 1.
	lines do: [:s |
		sz _ s size.
		result replaceFrom: i to: i + sz - 1 with: s startingAt: 1.
		i _ i + sz].
	^ result asUTF8
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 7/5/2008 08:43'!
contents: aStringOrText
	"Set my contents to the given String or Text. Break into lines, emove non-printing characters, and replace tabs with sequences of spaces."

	lines _ Array with: (self replaceTabs: aStringOrText asUTF32).
	self lineWrapFrom: 1.
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 6/12/2008 19:45'!
contents: aString font: aStrikeFont
	"Set my contents to the given String, UTF8, or Text and set my font. Remove non-printing characters, and replace tabs with sequences of spaces, and word-wrap."

	lines _ Array with: (self replaceTabs: aString).
	self font: aStrikeFont.
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 8/25/2008 19:27'!
ensureOSFont

	font isOSFont ifFalse: [
		self font: (StrikeFont osFontName: 'Helvetica Bold' size: font pointSize)].
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 9/16/2005 10:18'!
font

	^ font
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 7/10/2008 12:09'!
font: aFont

	font _ aFont.
	renderer _ StringMorph new font: aFont.
	lineHeight _ renderer stringHeight: ScratchTranslator renderHintString, 'Ag'.
	self wordWrapAll.
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 9/28/2007 15:46'!
growWithText: aBoolean

	growWithText _ aBoolean.
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 9/16/2005 11:27'!
hasFocus

	^ hasFocus
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 7/10/2008 14:19'!
isEditable

	isEditable ifNil: [isEditable _ true].
	^ isEditable
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 7/10/2008 14:19'!
isEditable: aBoolean

	isEditable _ aBoolean.
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 9/26/2005 19:41'!
isEmpty
	"Answer true if my contents is empty."

	^ lines size = 0 or: [lines size = 1 and: [lines first size = 0]]
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 12/8/2006 11:16'!
lines

	^ lines
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 8/11/2008 07:44'!
renderWithSqueak: aBoolean
	"If true, then if my font is a StrikeFont render my contents using that font and the Squeak rendering system. Note that it will only be able to render MacRoman text. This flag allows the text layer from old costumes to be edited in it's original Squeak font."

	renderWithSqueak _ aBoolean.
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 9/23/2005 10:38'!
selectionColor: aColor

	selectionColor _ aColor.
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 7/9/2008 19:30'!
suppressAntiAliasing: aBoolean

	suppressAntiAliasing _ aBoolean.
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 12/9/2005 16:51'!
textColor

	^ textColor
! !

!MultilineStringMorph methodsFor: 'accessing' stamp: 'jm 9/23/2005 10:37'!
textColor: aColor

	textColor _ aColor.
! !


!MultilineStringMorph methodsFor: 'drawing' stamp: 'jm 7/11/2008 18:15'!
drawCursor: charIndex line: lineIndex on: aCanvas
	"Draw a cursor at the given character index on the given line."

	| line pair x p |
	line _ lines at: lineIndex.
	line size = 0
		ifTrue: [pair _ #(0 0)]
		ifFalse: [pair _ (renderer xRangesFor: line) at: (charIndex within: 1 and: line size)].

	ScratchTranslator isRTL
		ifTrue: [x _ charIndex > line size ifTrue: [pair min] ifFalse: [pair max]]
		ifFalse: [x _ charIndex > line size ifTrue: [pair max] ifFalse: [pair min]].

	p _ self offsetForLine: lineIndex.
	aCanvas fillRectangle: (p + (x@0) extent: 2@lineHeight) color: selectionColor.
! !

!MultilineStringMorph methodsFor: 'drawing' stamp: 'jm 7/19/2008 10:18'!
drawOn: aCanvas

	| clipC |
	super drawOn: aCanvas.
	lineHeight ifNil: [self font: font].

	clipC _ aCanvas
		copyOffset: bounds origin
		clipRect: (bounds insetBy: borderWidth).

	(hasFocus | owner isNil) ifTrue: [self drawSelectionOn: clipC].
	self drawTextOn: clipC.
! !

!MultilineStringMorph methodsFor: 'drawing' stamp: 'jm 7/11/2008 19:06'!
drawSelectionFrom: startIndex to: endIndex line: lineIndex on: aCanvas
	"Draw the selection for the given character range of the given line on the given canvas."

	| line xRanges p pair w |
	line _ lines at: lineIndex.
	xRanges _ renderer xRangesFor: line.
	p _ self offsetForLine: lineIndex.
	startIndex to: endIndex - 1 do: [:i |
		pair _ xRanges at: (i within: 1 and: line size).
		w _ (pair last - pair first) abs.
		aCanvas fillRectangle: ((p + (pair first@0)) extent: w@lineHeight) color: selectionColor].
! !

!MultilineStringMorph methodsFor: 'drawing' stamp: 'jm 7/11/2008 18:11'!
drawSelectionLine: lineIndex on: aCanvas
	"Draw the selection for the entire line with the given index on the given canvas."

	| p w |
	p _ self offsetForLine: lineIndex.
	w _ renderer stringWidth: (lines at: lineIndex).
	aCanvas fillRectangle: (p extent: w@lineHeight) color: selectionColor.
! !

!MultilineStringMorph methodsFor: 'drawing' stamp: 'jm 8/8/2008 21:22'!
drawSelectionOn: aCanvas
	"Draw my selection onto the given canvas. The canvas has been offset to my origin."

	| start end startLine endLine startIndex endIndex |
	lines size = 0 ifTrue: [^ self].

	self ensureSelectionStartPrecedesEnd.
	start _ self lineAndIndexFor: selectionStart.
	end _ self lineAndIndexFor: selectionEnd.
	startLine _ start first.
	endLine _ end first.
	startIndex _ start last.
	endIndex _ end last.

	startLine = endLine ifTrue: [
		startIndex = endIndex
			ifTrue: [
				blinkState ifTrue: [
					self drawCursor: startIndex line: startLine on: aCanvas]]
			ifFalse: [
				self drawSelectionFrom: startIndex to: endIndex line: startLine on: aCanvas].
		^ self].

	self drawSelectionFrom: startIndex to: (lines at: startLine) size + 1 line: startLine on: aCanvas.
	startLine + 1 to: endLine - 1 do: [:i | self drawSelectionLine: i on: aCanvas].
	self drawSelectionFrom: 1 to: endIndex line: endLine on: aCanvas.
! !

!MultilineStringMorph methodsFor: 'drawing' stamp: 'jm 8/11/2008 07:41'!
drawString: aString at: aPoint on: aCanvas

	| s bgColor f |
	s _ aString.
	suppressAntiAliasing ifNil: [suppressAntiAliasing _ false].
	renderWithSqueak ifNil: [renderWithSqueak _ false].

	"allows costume textboxes using old fonts to be rendered:"
	(renderWithSqueak and: [font isOSFont not]) ifTrue: [s _ s asMacRoman].

	s isUnicode ifTrue: [
		bgColor _ color.
		bgColor isTransparent ifTrue: [
			bgColor _ self backgroundColor.
			(suppressAntiAliasing and: [bgColor = textColor])
				ifTrue: [bgColor _ textColor negated]].
		f _ ScratchTranslator
			formFor: s
			font: self font
			fgColor: textColor
			bgColor: bgColor
			suppressAntiAliasing: suppressAntiAliasing.
		f ifNotNil: [  "have rendering plugin"
			aCanvas paintImage: f at: aPoint.
			^ self].
		"no rendering plugin; convert to MacRoman and render with Squeak"
		s _ s asMacRoman].

	aCanvas
		text: s
		bounds: (aPoint extent: 10000@10000)
		font: font
		kern:0
		color: textColor.
! !

!MultilineStringMorph methodsFor: 'drawing' stamp: 'jm 8/2/2008 14:23'!
drawTextOn: aCanvas

	| hInset x y |
	hInset _ self insetX.
	y _ self insetY.
	centerText ifNil: [centerText _ false].
	lines do: [:s |
		ScratchTranslator isRTL
			ifTrue: [x _ self width - hInset - (renderer stringWidth: s)]
			ifFalse: [x _ hInset].
		centerText ifTrue: [
			x _ (self width - hInset - (renderer stringWidth: s)) // 2].
		self drawString: s at: x@y on: aCanvas.
		y _ y + lineHeight].
! !


!MultilineStringMorph methodsFor: 'stepping' stamp: 'jm 7/6/2008 17:47'!
step

	blinkState _ blinkState not.
	selectionStart = selectionEnd ifTrue: [self changed].
! !

!MultilineStringMorph methodsFor: 'stepping' stamp: 'jm 12/20/2006 16:14'!
stepTime

	^ 600
! !

!MultilineStringMorph methodsFor: 'stepping' stamp: 'jm 5/15/2008 14:02'!
wantsSteps

	^ hasFocus
! !


!MultilineStringMorph methodsFor: 'event handling' stamp: 'jm 7/6/2008 17:46'!
cursorKey: evt
	"Handle the given cursor control key."

	| ch pair lineNum line |
	ch _ evt keyValue.

	selectionStart = selectionEnd ifTrue: [startLoc _ selectionStart].

	ch = 28 ifTrue: [ "left"
		evt shiftPressed
			ifTrue: [
				selectionEnd > startLoc
					ifTrue: [selectionEnd _ selectionEnd - 1]
					ifFalse: [selectionStart _ selectionStart - 1]]
			ifFalse: [
				selectionStart _ selectionEnd _ selectionStart - 1]].

	ch = 29 ifTrue: [ "right"
		evt shiftPressed
			ifTrue: [
				selectionStart < startLoc
					ifTrue: [selectionStart _ selectionStart + 1]
					ifFalse: [selectionEnd _ selectionEnd + 1]]
			ifFalse: [
				selectionStart _ selectionEnd _ selectionStart + 1]].

	ch = 30 ifTrue: [  "up"
		pair _ self lineAndIndexFor: selectionStart.	
		lineNum _ (pair first - 1) max: 1.
		line _ lines at: lineNum.
		selectionStart _ (self startOfLine: lineNum) + (pair second min: line size).
		evt shiftPressed ifFalse: [selectionEnd _ selectionStart]].

	ch = 31 ifTrue: [  "down"
		pair _ self lineAndIndexFor: selectionEnd.	
		lineNum _ (pair first + 1) min: lines size.
		line _ lines at: lineNum.
		selectionEnd _ (self startOfLine: lineNum) + (pair second min: line size).
		evt shiftPressed ifFalse: [selectionStart _ selectionEnd]].

	blinkState _ true.
	self ensureSelectionStartPrecedesEnd.
	self changed.
! !

!MultilineStringMorph methodsFor: 'event handling' stamp: 'jm 12/18/2006 12:59'!
doubleClick: evt
	"Select a word."

	| lineAndIndex lineNum s index wordStart wordEnd lineStart |
	lines size = 0 ifTrue: [^ self].

	lineAndIndex _ self lineAndIndexFor: (self indexForPoint: evt cursorPoint).
	lineNum _ lineAndIndex first.
	s _ lines at: lineNum.
	s size = 0 ifTrue: [^ self].  "empty line"

	index _ lineAndIndex second.
	index > s size ifTrue: [index _ s size].  "at end of line; try one char back"
	(s at: index) isSeparator ifTrue: [^ self].  "on separator; do nothing"

	wordStart _ index.
	[(wordStart >= 1) and: [(s at: wordStart) isSeparator not]]
		whileTrue: [wordStart _ wordStart - 1].
	wordEnd _ index.
	[(wordEnd < s size) and: [(s at: wordEnd) isSeparator not]]
		whileTrue: [wordEnd _ wordEnd + 1].
	(s at: wordEnd) isSeparator ifTrue: [wordEnd _ wordEnd - 1].

	lineStart _ self startOfLine: lineNum.
	selectionStart _ lineStart + (wordStart + 1).
	selectionEnd _ lineStart + (wordEnd + 1).
	startLoc _ selectionStart.
	self changed.

! !

!MultilineStringMorph methodsFor: 'event handling' stamp: 'jm 8/9/2008 18:07'!
handlesMouseDown: evt

	^ self isEditable
! !

!MultilineStringMorph methodsFor: 'event handling'!
keyStroke: t1 
	| t2 t3 |
	t2 _ t1 unicodeChar.
	t2 = 0 ifTrue: [t2 _ t1 keyValue].
	t1 commandKeyPressed ifTrue: [t2 _ t2 \\ 32].
	t2 = 3 & (t1 buttons = 0) ifTrue: [t2 _ 13].
	t2 = 9
		ifTrue: 
			[(t3 _ self ownerThatIsA: DialogBoxMorph) ifNotNil: [t3 tabToNextField: t1].
			^ self].
	t2 = 27
		ifTrue: 
			[(t3 _ self ownerThatIsA: DialogBoxMorph) ifNotNil: [t3 escapeKeyPressed: t1].
			^ self].
	t1 controlKeyPressed | t1 commandKeyPressed
		ifTrue: 
			[t2 _ t2 \\ 32.
			t2 = 1 ifTrue: [^ self selectAll].
			t2 = 3 ifTrue: [^ self copySelection].
			t2 = 22 ifTrue: [^ self paste].
			t2 = 24 ifTrue: [^ self cutSelection]].
	t1 shiftPressed
		ifTrue: 
			[t2 = 1 ifTrue: [^ self moveCursorHomeAndSelect: true].
			t2 = 4 ifTrue: [^ self moveCursorEndAndSelect: true].
			t2 = 11 ifTrue: [^ self moveCursorPageUpAndSelect: true].
			t2 = 12 ifTrue: [^ self moveCursorPageDownAndSelect: true]].
	t1 buttons = 0
		ifTrue: 
			[t2 = 8 ifTrue: [^ self backspaceChar].
			t2 = 127 ifTrue: [^ self deleteNextChar].
			t2 = 1 ifTrue: [^ self moveCursorHomeAndSelect: false].
			t2 = 4 ifTrue: [^ self moveCursorEndAndSelect: false].
			t2 = 11 ifTrue: [^ self moveCursorPageUpAndSelect: false].
			t2 = 12 ifTrue: [^ self moveCursorPageDownAndSelect: false]].
	(t2 between: 28 and: 31)
		ifTrue: [^ self cursorKey: t1].
	self insertString: (UTF32 with: t2)! !

!MultilineStringMorph methodsFor: 'event handling' stamp: 'jm 5/15/2008 14:05'!
keyboardFocusChange: aBoolean

	hasFocus = aBoolean ifTrue: [^ self].

	self changed.
	aBoolean
		ifTrue: [
			self selectAll.
			self startStepping]
		ifFalse: [
			self stopStepping].

	hasFocus _ aBoolean.
! !

!MultilineStringMorph methodsFor: 'event handling' stamp: 'jm 7/10/2008 14:20'!
mouseDown: evt

	self isEditable ifFalse: [^ self].
	evt hand newKeyboardFocus: self.
	startLoc _ self indexForPoint: evt cursorPoint.
	selectionStart _ selectionEnd _ startLoc.
	evt hand waitForClicksOrDrag: self event: evt.
	self changed.
! !

!MultilineStringMorph methodsFor: 'event handling' stamp: 'jm 8/9/2008 18:17'!
mouseMove: evt

	| newLoc |
	self isEditable ifFalse: [^ self].
	newLoc _ self indexForPoint: evt cursorPoint.
	startLoc ifNil: [startLoc _ newLoc].
	newLoc < startLoc
		ifTrue: [selectionStart _ newLoc. selectionEnd _ startLoc]
		ifFalse: [selectionStart _ startLoc. selectionEnd _ newLoc].
	self changed.
! !

!MultilineStringMorph methodsFor: 'event handling' stamp: 'jm 1/5/2006 10:23'!
startDrag: evt
	"Do nothing."
! !

!MultilineStringMorph methodsFor: 'event handling' stamp: 'jm 7/10/2008 14:20'!
wouldAcceptKeyboardFocus

	^ self isEditable
! !


!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 12/9/2006 20:52'!
backspaceChar
	"If there is a selection, delete it. Otherwise delete the character just before the insertion point (i.e. backspace)."

	selectionStart = selectionEnd ifFalse: [^ self deleteSelection].

	selectionStart > 1 ifTrue: [
		selectionEnd _ selectionStart.
		selectionStart _ selectionStart - 1.
		self deleteSelection].
! !

!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 8/10/2008 20:18'!
copySelection
	"Record the current selection in the clipboard."

	ScratchTranslator unicodeClipboardPut: self currentSelection.
! !

!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 7/11/2008 06:29'!
currentSelection
	"Answer the current selection as a string."

	| line result start end startLineNum endLineNum |
	self ensureSelectionStartPrecedesEnd.
	start _ self lineAndIndexFor: selectionStart.
	end _ self lineAndIndexFor: selectionEnd.
	startLineNum _ start first.
	endLineNum _ end first.

	startLineNum = endLineNum ifTrue: [
		line _ lines at: startLineNum.
		^ line copyFrom: start second to: end second - 1].

	result _ WriteStream on: (UTF32 new: 1000).

	line _ lines at: startLineNum.
	result nextPutAll: (line copyFrom: start second to: line size).

	startLineNum + 1 to: endLineNum - 1 do: [:i |
		result nextPutAll: (lines at: i)].

	line _ lines at: endLineNum.
	result nextPutAll: (line copyFrom: 1 to: end second - 1).

	^ result contents
! !

!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 9/17/2005 13:41'!
cutSelection
	"Record the current selection in the clipboard, then delete it."

	selectionStart = selectionEnd ifTrue: [^ self].  "no selection"
	self copySelection.
	self deleteSelection.
! !

!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 12/9/2006 20:53'!
deleteNextChar
	"If there is a selection, delete it. Otherwise delete the character just after the insertion point (i.e. delete)."

	selectionStart = selectionEnd ifFalse: [^ self deleteSelection].

	selectionEnd _ selectionStart + 1.
	self deleteSelection.
! !

!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 12/12/2006 19:39'!
deleteSelection
	"Delete the current selection."

	| start end startLineNum endLineNum s1 s2 mergedLine remainingLines |
	self ensureSelectionStartPrecedesEnd.
	selectionStart = selectionEnd ifTrue: [^ self].  "no selection"

	start _ self lineAndIndexFor: selectionStart.
	end _ self lineAndIndexFor: selectionEnd.

	startLineNum _ start first.
	endLineNum _ end first.

	"merge the partial lines before and after the selection"
	s1 _ lines at: startLineNum.
	s2 _ lines at: endLineNum.
	mergedLine _ (s1 copyFrom: 1 to: start second - 1), (s2 copyFrom: end second to: s2 size).

	"combine with following line, if any"
	endLineNum < lines size ifTrue: [
		mergedLine _ mergedLine, (lines at: endLineNum + 1).
		remainingLines _ lines copyFrom: endLineNum + 2 to: lines size].

	"update lines"
	lines _ (lines copyFrom: 1 to: startLineNum - 1) copyWith: mergedLine.
	remainingLines ifNotNil: [lines _ lines, remainingLines].

	selectionEnd _ selectionStart.
	self lineWrapFrom: startLineNum.
! !

!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 7/6/2008 17:46'!
insertString: aString
	"Insert the given string at selectionStart."

	| start lineNum line prefix postfix |
	selectionStart = selectionEnd ifFalse: [self cutSelection].

	start _ self lineAndIndexFor: selectionStart.
	lineNum _ start first.
	line _ lines at: lineNum.
	prefix _ line copyFrom: 1 to: start second - 1.
	postfix _ line copyFrom: start second to: line size.

	lines at: lineNum put: (prefix, (self replaceTabs: aString), postfix).

	selectionEnd _ selectionStart _ selectionStart + aString size.
	self lineWrapFrom: lineNum.

! !

!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 12/12/2006 19:22'!
moveCursorContentsEnd
	"Position the cursor at the end of my contents (i.e. at very end, not the end of the current line)."

	selectionStart _ selectionEnd _ self charCount + 1.
	self changed.
! !

!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 7/6/2008 17:46'!
moveCursorEndAndSelect: selectFlag

	| lineNum line |
	lineNum _ (self lineAndIndexFor: selectionStart) first.
	line _ lines at: lineNum.
	selectionEnd _ (self startOfLine: lineNum) + line size.
	lineNum = lines size ifTrue: [selectionEnd _ selectionEnd + 1].
	selectFlag ifFalse: [selectionStart _ selectionEnd].
	startLoc _ selectionStart.
	self changed.
! !

!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 12/18/2006 12:57'!
moveCursorHomeAndSelect: selectFlag

	selectionStart _ (self startOfLine: (self lineAndIndexFor: selectionStart) first) + 1.
	selectFlag ifFalse: [selectionEnd _ selectionStart].
	startLoc _ selectionEnd.
	self changed.
! !

!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 7/6/2008 17:46'!
moveCursorPageDownAndSelect: selectFlag

	| i lastLine |
	i _ (self lineAndIndexFor: selectionStart) second.
	lastLine _ lines at: lines size.
	selectionEnd _ (self startOfLine: lines size) + (i min: lastLine size + 1).
	selectFlag ifFalse: [selectionStart _ selectionEnd].
	startLoc _ selectionStart.
	self changed.
! !

!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 12/18/2006 13:04'!
moveCursorPageUpAndSelect: selectFlag

	| i |
	i _ (self lineAndIndexFor: selectionStart) second.
	selectionStart _ i within: 1 and: (lines at: 1) size.
	selectFlag ifFalse: [selectionEnd _ selectionStart].
	startLoc _ selectionEnd.
	self changed.
! !

!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 7/11/2008 06:34'!
paste
	"Paste the last cut or copied text over the current selection."

	| s |
	s _ ScratchTranslator unicodeClipboard..
	s size = 0 ifTrue: [^ self].

	self deleteSelection.
	self insertString: s.
! !

!MultilineStringMorph methodsFor: 'editing' stamp: 'jm 12/9/2006 20:18'!
selectAll
	"Select all of my text."

	selectionStart _ 1.
	selectionEnd _ self charCount + 1.
	self changed.
! !


!MultilineStringMorph methodsFor: 'geometry' stamp: 'jm 7/30/2008 16:33'!
extent: aPoint

	| oldWidth |
	oldWidth _ self width.
	super extent: (aPoint max: ((2 * borderWidth) + inset + 10)).
	self width ~= oldWidth ifTrue: [self wordWrapAll].

! !


!MultilineStringMorph methodsFor: 'menu' stamp: 'jm 9/16/2005 11:29'!
addCustomMenuItems: aCustomMenu hand: aHandMorph

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	aCustomMenu add: 'set font' action: #fontMenu.
! !

!MultilineStringMorph methodsFor: 'menu' stamp: 'jm 12/15/2005 13:53'!
fontMenu

	| menu fName fSize |
	menu _ CustomMenu new.
	StrikeFont fontNames do: [:fn | menu add: fn action: fn].
	(fName _ menu startUp) ifNil: [^ self].

	menu _ CustomMenu new.
	(StrikeFont sizesForFontName: fName) do: [:sz | menu add: sz printString action: sz].
	(fSize _ menu startUp) ifNil: [^ self].
	self font: (StrikeFont fontName: fName size: fSize).
! !


!MultilineStringMorph methodsFor: 'object i/o' stamp: 'jm 9/16/2005 10:18'!
fieldsVersion

	^ 1
! !

!MultilineStringMorph methodsFor: 'object i/o' stamp: 'jm 8/11/2008 08:01'!
initFieldsFrom: anObjStream version: classVersion

	| fontSpec isOSFont |
	super initFieldsFrom: anObjStream version: classVersion.

	fontSpec _ anObjStream nextField.
	isOSFont _ ((fontSpec size > 2) and: [fontSpec at: 3]).
	isOSFont
		ifTrue: [self font: (StrikeFont osFontName: fontSpec first size: fontSpec second)]
		ifFalse: [self font: (StrikeFont fontName: fontSpec first size: fontSpec second)].

	self initFieldsNamed: #(
		textColor
		selectionColor
		lines
	) from: anObjStream.
	lines _ lines collect: [:s | s asUTF32].
! !

!MultilineStringMorph methodsFor: 'object i/o' stamp: 'jm 8/11/2008 07:24'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.

	lines _ lines collect: [:s | s asUTF8].
	anObjStream putField: {font name. font pointSize. font isOSFont}.  "font spec"
	self storeFieldsNamed: #(
		textColor
		selectionColor
		lines
	) on: anObjStream.
	lines _ lines collect: [:s | s asUTF32].

! !


!MultilineStringMorph methodsFor: 'private' stamp: 'jm 7/5/2008 10:27'!
breakLine: lineIndex
	"Break the given line by moving some of it down to the following line. Answer true if the line was broken, false otherwise. (This may cause the next line to become too long, thus propaging the need to word-wrap.)
	Try the following strategies, in order:
		a. break at an embedded if that leaves the line short enough
		b. break at the last space character before a word that hits the edge
		c. break a word that hits the edge if there is no space before that word"

	| line breakIndex i lineUpToBreak lineAfterBreak |
	line _ lines at: lineIndex.
	breakIndex _ nil.

	(self fits: line) ifTrue: [^ false].  "line already fits"

	(i _ line indexOf: CR) ~= 0 ifTrue: [
		(self fits: (line copyFrom: 1 to: i - 1))
			ifTrue: [breakIndex _ i]].

	breakIndex ifNil: [
		i _ line indexOfSeparatorStartingAt: 1.
		[i <= line size] whileTrue: [
			(self fits: (line copyFrom: 1 to: i - 1))
				ifTrue: [
					breakIndex _ i.
					i _ line indexOfSeparatorStartingAt: i + 1]
				ifFalse: [i _ line size + 1]]].

	breakIndex ifNil: [
		i _ line size.
		[i > 1 and:
		 [(self fits: (line copyFrom: 1 to: i)) not]]
			whileTrue: [i _ i - 1].
		breakIndex _ i].

	lineUpToBreak _ line copyFrom: 1 to: breakIndex.
	lineAfterBreak _ line copyFrom: breakIndex + 1 to: line size.

	lineIndex = lines size ifTrue: [lines _ lines copyWith: self emptyLine].  "make sure there is a next line"
	lines at: lineIndex put: lineUpToBreak.
	lines at: lineIndex + 1 put: lineAfterBreak, (lines at: lineIndex + 1).

	^ true
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 12/8/2006 19:35'!
charCount

	| result |
	result _ 0.
	lines do: [:s | result _ result + s size].
	^ result
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 7/5/2008 08:31'!
emptyLine

	^ UTF32 new
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 12/17/2006 20:17'!
ensureSelectionStartPrecedesEnd
	"If selectionEnd is before selectionStart, swap them."

	| lastIndex tmp |
	lastIndex _ self charCount + 1.
	selectionStart _ selectionStart within: 1 and: lastIndex.
	selectionEnd _ selectionEnd within: 1 and: lastIndex.
	selectionEnd < selectionStart ifTrue: [
		tmp _ selectionEnd.
		selectionEnd _ selectionStart.
		selectionStart _ tmp].
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 8/11/2008 18:01'!
fitContents
	"Set my extent to just fit around my contents."

	| w |
	w _ 10.
	lines do: [:s | w _ w max: (self widthWithContents: s)].
	super extent: (w@(lines size * lineHeight)) + (9@7).
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 8/6/2008 15:56'!
fits: aString
	"Answer true if the given string fits within my width."

	| i |
	i _ aString indexOf: CR.
	((i > 0) and: [i < aString size]) ifTrue: [^ false].  "line includes an embedded CR; needs to be broken"
	aString size > 500 ifTrue: [^ false].
	^ (renderer stringWidth: aString) < (self width - (self insetX + borderWidth + 2))
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 7/11/2008 19:19'!
indexForPoint: aPoint
	"Answer the character index for the given point in screen coordinates."
	"Note: This could be speeded up by doing a binary search for the character index, but it seems fast enough."

	| y lineNum x lineStart line xRanges pair |
	lines size = 0 ifTrue: [^ 1].

	y _ aPoint y - (self top + self insetY).
	lineNum _ ((y // lineHeight) + 1) max: 1.
	lineNum > lines size ifTrue: [^ (self startOfLine: lineNum) + 1].

	x _ (aPoint x - self left - (self offsetForLine: lineNum) x) min: self width.
	x < 0 ifTrue: [  "start of a line"
		lineNum = 1 ifTrue: [^ 1] ifFalse: [^ self startOfLine: lineNum]].

	"search for character index"
	lineStart _ self startOfLine: lineNum.
	line _ lines at: lineNum.
	xRanges _ renderer xRangesFor: line.
	1 to: line size do: [:i |
		pair _ xRanges at: i.
		(x between: pair first and: pair second) ifTrue: [^ lineStart + i]].

	"end of line"
	lineNum = lines size
		ifTrue: [^ lineStart + line size + 1]
		ifFalse: [^ lineStart + line size].
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 7/6/2008 16:10'!
insetX

	^ borderWidth + inset x
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 7/6/2008 16:10'!
insetY

	^ borderWidth + inset y
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 12/8/2006 11:33'!
lineAndIndexFor: charPos
	"Answer an Array containing the line number and the character index within that line for the given character position in my text."

	| count line |
	charPos < 1 ifTrue: [^ Array with: 1 with: 1].

	count _ 0.
	1 to: lines size do: [:lineNum |
		line _ lines at: lineNum.
		(charPos between: count + 1 and: count + line size)
			ifTrue: [^ Array with: lineNum with: charPos - count].
		count _ count + line size].
	
	^ Array with: lines size with: ((lines at: lines size) size + 1)
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 8/11/2008 18:18'!
lineWrapFrom: startLine
	"Fix line wrapping starting at the given line."

	| lineIndex newH |
	lineIndex _ startLine.
	[lineIndex <= lines size and: [self breakLine: lineIndex]]
		whileTrue: [lineIndex _ lineIndex + 1].

	"if the last line ends with a CR, add a blank line after it"
	(lines last size > 0 and: [lines last last = CR])
		ifTrue: [lines _ lines copyWith: self emptyLine].

	growWithText ifTrue: [
		newH _ ((lines size max: 1) * lineHeight) + (2 * self insetY).
		bounds height ~= newH ifTrue: [self height: newH]].

	self changed.
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 8/8/2008 21:04'!
offsetForLine: lineIndex
	"Answer the offset from my origin to the start of the line with the given index, taking RTL into account."

	| top |
	top _ self insetY + (lineHeight * (lineIndex - 1)).
	ScratchTranslator isRTL
		ifTrue: [^ (self width - (self insetX + (renderer stringWidth: (lines at: lineIndex)))) @ top]
		ifFalse: [^ self insetX @ top].
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'EMP 2/25/2016 17:01'!
replaceTabs: firstString
	"Answer a copy of the given UTF32 with each tab replaced by four spaces and all non-printing characters except spaces and line ends removed. Covert LF's to CR's."

	| s tab lf cr space result aString |
	aString _ firstString.
	(firstString isKindOf: Number) ifTrue: [aString _ firstString asString].
	s _ aString asUTF32.
	tab _ 9.
	lf _ 10.
	cr _ 13.
	space _ 32.
	result _ WriteStream on: (UTF32 new: s size * 4).
	s do: [:ch |
		ch < space
			ifTrue: [ "non-printing"
				ch = tab ifTrue: [result nextPutAll: '    ' asUTF32].
				(ch = cr) | (ch = lf) ifTrue: [result nextPut: cr]]
			ifFalse: [
				result nextPut: ch]].

	^ result contents
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 7/25/2006 10:07'!
setLines: anArray
	"Private!! Used when copying."

	lines _ anArray.
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 12/15/2006 13:43'!
startOfLine: lineIndex
	"Answer the character index for the start of the line with the given index. If the line is out of range treat it as if it were the first or last line."

	| result |
	lineIndex < 1 ifTrue: [^ 1].

	result _ 0.
	1 to: ((lineIndex - 1) min: lines size) do: [:i | result _ result + (lines at: i) size].
	^ result
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 7/9/2008 08:08'!
stringWidth: aString
	"Answer the width of the givne string."

	^ renderer stringWidth: aString
! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 7/9/2008 08:20'!
widthWithContents: aString
	"Answer how wide I would need to be to fit the given string on a single line."

	^ (renderer stringWidth: aString) + self insetX + borderWidth + 3

! !

!MultilineStringMorph methodsFor: 'private' stamp: 'jm 5/14/2008 13:53'!
wordWrapAll
	"Redo my wordwrap."

	((lines size > 1) or: [lines first size > 0]) ifTrue: [
		self contents: self contents].
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

MultilineStringMorph class
	instanceVariableNames: ''!

!MultilineStringMorph class methodsFor: 'class initialization' stamp: 'jm 7/5/2008 10:31'!
initialize
	"self initialize"

	CR _ 13.
! !


!MultilineStringMorph class methodsFor: 'instance creation' stamp: 'jm 9/16/2005 10:18'!
includeInNewMorphMenu

	^ true
! !


MultilineStringMorph initialize!
