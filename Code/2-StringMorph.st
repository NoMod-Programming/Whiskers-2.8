Morph subclass: #StringMorph
	instanceVariableNames: 'font emphasis kern contents hasFocus passwordMode forceUnicodeRendering suppressAntiAliasing rightJustify '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Basic'!
!StringMorph commentStamp: 'jm 6/15/2003 10:46' prior: 0!
I am a simple, one-line string that displays all characters in a single font. See TextMorph if you need multiple fonts or styles in the same string or multiple lines.
!


!StringMorph methodsFor: 'initialization' stamp: 'EMP 2/9/2016 16:13'!
initWithContents: aString font: aFont

	self initialize.
	font _ aFont.
	kern _ 0.
	self contents: aString.
! !

!StringMorph methodsFor: 'initialization' stamp: 'jm 7/2/2008 20:21'!
initialize

	super initialize.
	color _ Color black.
	font _ nil.
	emphasis _ 0.  "no longer used; use appropriate font instead"
	kern _ 0.
	hasFocus _ false.
	passwordMode _ false.
	forceUnicodeRendering _ false.
	suppressAntiAliasing _ false. "suppress antialiasing"
	rightJustify _ false.

	"self contents: is slow, so initialize it this way:"
	contents _ 'StringMorph'.
	self extent: 72@12.  "determined empirically; depends on conents and font"
! !


!StringMorph methodsFor: 'accessing'!
contents

	^ contents! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 6/29/2008 10:32'!
contents: newContents

	| s |
	s _ newContents.
	((s isKindOf: String) | s isUnicode) ifFalse: [s _ newContents asString].
	contents = s ifTrue: [^ self].  "no change"

	self changed.
	contents _ s.
	self fitContents.
! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 6/2/2008 17:16'!
contents: aString font: aFont

	self initialize.
	font _ aFont.
	self contents: aString.
! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 6/2/2008 17:17'!
contentsClipped: aString
	"Change my text, but do not update my size as a result."

	contents = aString ifTrue: [^ self].  "no change"

	contents _ aString.
	self changed.
! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 6/2/2008 17:18'!
font

	font ifNil: [font _ TextStyle defaultFont].
	^ font
! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 6/2/2008 15:02'!
font: aFont

	font _ aFont.
	self fitContents.
! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 6/29/2008 11:02'!
forceUnicodeRendering

	forceUnicodeRendering ifNil: [forceUnicodeRendering _ false].
	^ forceUnicodeRendering
! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 7/2/2008 20:22'!
forceUnicodeRendering: aBoolean

	forceUnicodeRendering _ aBoolean.
! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 6/2/2008 17:17'!
hasFocus

	^ hasFocus
! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 3/30/2005 06:55'!
kern

	^ kern
! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 3/30/2005 07:01'!
kern: anInteger
	"Set the amount by which to adjust my inter-letter spacing (kerning). For example, setting this to 2 would add two additional pixels of space between characters."

	kern _ anInteger.
	self fitContents.
! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 3/26/2008 12:29'!
passwordMode: aBoolean

	passwordMode _ aBoolean.
! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 7/3/2008 10:34'!
rightJustify: aBoolean

	rightJustify = aBoolean ifFalse: [self changed].
	rightJustify _ aBoolean.
! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 6/2/2008 17:19'!
setWidth: width

	self extent: width @ self font height.
! !

!StringMorph methodsFor: 'accessing' stamp: 'jm 6/29/2008 11:27'!
suppressAntiAliasing: aBoolean

	suppressAntiAliasing _ aBoolean.
	self changed.

! !


!StringMorph methodsFor: 'drawing' stamp: 'EMP 2/9/2016 16:20'!
drawOn: aCanvas

	| f s clipC offset |
	clipC _ aCanvas copyClipRect: self bounds.

	s _ self stringToDisplay.
	(self forceUnicodeRendering and: [s isUnicode not])
		ifTrue: [s _ s asUTF8].

	offset _ self justificationOffsetFor: s.

	s isUnicode ifTrue: [
		suppressAntiAliasing ifNil: [suppressAntiAliasing _ false].
		f _ ScratchTranslator
			formFor: s
			font: self font
			fgColor: color
			bgColor: self backgroundColor
			suppressAntiAliasing: suppressAntiAliasing.
		f ifNotNil: [  "have rendering plugin"
			clipC paintImage: f at: bounds topLeft + (offset@0).
			^ self].
		"if no rendering system, do the best we can with Squeak"
		s _ s asMacRoman].

	clipC
		text: s
		bounds: (((bounds left + offset)@bounds top) corner: bounds corner)
		font: self font
		kern: (kern ifNil: [0] ifNotNil: [kern])
		color: color.
! !


!StringMorph methodsFor: 'editing' stamp: 'jm 11/1/2002 10:43'!
acceptContents
	"The message is sent when the user hits enter or cmd-S. Accept the current contents and end editing. This default implementation does nothing."
! !

!StringMorph methodsFor: 'editing' stamp: 'sw 9/17/1999 13:27'!
cancelEdits

	self doneWithEdits! !

!StringMorph methodsFor: 'editing' stamp: 'di 9/6/1999 22:44'!
doneWithEdits

	hasFocus _ false! !

!StringMorph methodsFor: 'editing' stamp: 'jm 10/20/2004 15:12'!
handlesMouseDown: evt

	^ (evt shiftPressed and: [owner wantsKeyboardFocusFor: self])
		ifTrue: [self uncoveredAt: evt cursorPoint]
		ifFalse: [super handlesMouseDown: evt].
! !

!StringMorph methodsFor: 'editing' stamp: 'jm 9/1/2008 10:51'!
launchMiniEditor: evt

	| textMorph |
	Preferences noviceMode ifTrue: [^ self].

	hasFocus _ true.  "Really only means edit in progress for this morph"
	textMorph _ StringMorphEditor new contentsAsIs: contents.
	textMorph color: self color.
	textMorph beAllFont: self font.
	textMorph bounds: (self bounds expandBy: 0@2).
	self addMorphFront: textMorph.
	evt hand newMouseFocus: textMorph.
	evt hand newKeyboardFocus: textMorph.
	textMorph editor selectFrom: 1 to: textMorph paragraph text string size.
	textMorph mouseDown: evt.
! !

!StringMorph methodsFor: 'editing' stamp: 'jm 3/15/2003 21:04'!
lostFocusWithoutAccepting
	"The message is sent when the user, having been in an editing episode on the receiver, changes the keyboard focus without having accepted the current edits. In This case, we just accept the edits."

	self acceptContents.
! !

!StringMorph methodsFor: 'editing' stamp: 'jm 10/20/2004 15:12'!
mouseDown: evt
	"If the shift key is pressed, make this string the keyboard input focus."

	(evt shiftPressed and: [owner wantsKeyboardFocusFor: self])
		ifTrue: [self launchMiniEditor: evt]
		ifFalse: [super mouseDown: evt].
! !

!StringMorph methodsFor: 'editing' stamp: 'sw 5/6/1998 15:45'!
wouldAcceptKeyboardFocus
	^ self isLocked not! !


!StringMorph methodsFor: 'menu' stamp: 'jm 6/2/2008 14:38'!
addCustomMenuItems: aCustomMenu hand: aHandMorph

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	aCustomMenu add: 'center title' action: #centerTitle.	
	aCustomMenu add: 'left align and space similar strings' action: #leftAlignAndSpaceEvenly.	
	aCustomMenu addLine.
	aCustomMenu add: 'set font' action: #fontMenu.
! !

!StringMorph methodsFor: 'menu' stamp: 'jm 1/24/2004 18:55'!
centerTitle

	self centerInOwner.
	self top: 25.
! !

!StringMorph methodsFor: 'menu' stamp: 'jm 12/15/2005 13:55'!
fontMenu

	| menu fName fSize |
	menu _ CustomMenu new.
	(StrikeFont fontNames copyWithout: 'DefaultTextStyle') do: [:fn |
		menu add: fn action: fn].
	(fName _ menu startUp) ifNil: [^ self].

	menu _ CustomMenu new.
	(StrikeFont sizesForFontName: fName) do: [:sz | menu add: sz printString action: sz].
	(fSize _ menu startUp) ifNil: [^ self].
	self font: (StrikeFont fontName: fName size: fSize).
! !

!StringMorph methodsFor: 'menu' stamp: 'jm 1/24/2004 18:38'!
leftAlignAndSpaceEvenly
	"Left-align all StringMorphs with the same font as me in my owner and space them evenly."

	| mList totalSpace avgSpace x y |
	owner ifNil: [^ self].
	mList _ owner submorphs select: [:m | (m isKindOf: StringMorph) and: [m font == self font]].
	mList _ mList sort: [:m1 :m2 | m1 top < m2 top].
	mList size < 2 ifTrue: [^ self].
	totalSpace _ (mList last bottom - mList first top) - (mList collect: [:m | m height]) sum.
	avgSpace _ totalSpace // (mList size - 1).
	x _ mList first left.
	y _ mList first top.
	mList do: [:m |
		m position: x@y.
		y _ y + m height + avgSpace].
! !


!StringMorph methodsFor: 'printing' stamp: 'jm 6/12/2008 04:35'!
printOn: aStream

	| s |
	super printOn: aStream.
	aStream nextPutAll: '['.
	s _ contents.
	(s isUnicode and: [s isMacRoman]) ifTrue: [s _ s asMacRoman].
	s isUnicode ifFalse: [
		s size > 20 ifTrue: [s _ (s copyFrom: 1 to: 20), '...']].
	aStream nextPutAll: s printString.
	aStream nextPutAll: ']'.
! !


!StringMorph methodsFor: 'object i/o' stamp: 'jm 10/10/2003 09:40'!
closeEditor
	"Be sure that any StringMorphEditors on me have been removed."

	self doneWithEdits.
	submorphs size = 0 ifTrue: [^ self].
	submorphs copy do: [:m |
		(m isKindOf: StringMorphEditor) ifTrue: [m delete]].
! !

!StringMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 19:38'!
fieldsVersion

	^ 1
! !

!StringMorph methodsFor: 'object i/o' stamp: 'jm 12/18/2005 09:25'!
initFieldsFrom: anObjStream version: classVersion

	| fontSpec |
	super initFieldsFrom: anObjStream version: classVersion.
	fontSpec _ anObjStream nextField.
	fontSpec ifNotNil: [
		font _ StrikeFont fontName: fontSpec first size: fontSpec second].

	self initFieldsNamed: #(
		emphasis
		contents
	) from: anObjStream.
! !

!StringMorph methodsFor: 'object i/o' stamp: 'jm 1/15/2006 12:53'!
storeFieldsOn: anObjStream

	self closeEditor.
	super storeFieldsOn: anObjStream.
	font
		ifNil: [anObjStream putField: nil]
		ifNotNil: [anObjStream putField: (Array with: font name with: font pointSize)].
	self storeFieldsNamed: #(
		emphasis
		contents
	) on: anObjStream.
! !


!StringMorph methodsFor: 'private' stamp: 'jm 6/2/2008 17:38'!
fitContents

	self extent: ((self stringExtent: contents) max: 5@5).
	self changed.
! !

!StringMorph methodsFor: 'private' stamp: 'jm 7/3/2008 11:25'!
justificationOffsetFor: aString

	rightJustify ifNil: [rightJustify _ false].
	rightJustify ifFalse: [^ 0].

	^ (self width - (self stringWidth: self stringToDisplay)) max: 0

! !

!StringMorph methodsFor: 'private' stamp: 'jm 7/3/2008 11:19'!
leftMargin
	"Answer the left edge of this StringMorph. For a left-justified string, this the left edge of its bounding box, but for a right-justified string it may be inset."

	^ self left + (self justificationOffsetFor: contents)
! !

!StringMorph methodsFor: 'private' stamp: 'jm 8/1/2008 21:45'!
stringExtent: aString
	"Answer the extent of the given string in my current font."

	| s usingOSFont scanner |
	s _ aString.
	usingOSFont _ font notNil and: [font isOSFont].
	s isUnicode | self forceUnicodeRendering | usingOSFont ifTrue: [
		ScratchTranslator canRenderUnicode
			ifTrue: [^ ScratchTranslator stringExtent: s asUTF8 font: self font]
			ifFalse: [s _ s asMacRoman]].

	scanner _ DisplayScanner quickPrintOn: Display box: Display boundingBox font: self font.
	kern ifNotNil: [scanner addKern: kern].
	^ scanner stringExtent: s
! !

!StringMorph methodsFor: 'private' stamp: 'jm 7/4/2008 06:43'!
stringHeight: aString
	"Answer the height of the given string in my current font."

	^ (self stringExtent: aString) y
! !

!StringMorph methodsFor: 'private' stamp: 'jm 7/3/2008 12:18'!
stringToDisplay
	"Answer the string that is displayed. In password mode, this will be all asterisks."

	| n s |
	passwordMode ifNil: [passwordMode _ false].
	passwordMode ifTrue: [
		n _ (contents isKindOf: UTF8) ifTrue: [contents asUTF32 size] ifFalse: [contents size].
		s _ String new: n withAll: $*.
		contents isUnicode ifTrue: [s _ s asUTF8].
		^ s].

	^ contents
! !

!StringMorph methodsFor: 'private' stamp: 'jm 6/2/2008 17:48'!
stringWidth: aString
	"Answer the width of the given string in my current font."

	^ (self stringExtent: aString) x
! !

!StringMorph methodsFor: 'private' stamp: 'jm 7/9/2008 20:46'!
stringWithEllipses: aString limitedToWidth: aNumber
	"Answer the given string limited in width. If the string is too wide to fit, truncate it and append ellipses."

	| ellipses maxW s w |
	ellipses _ ScratchTranslator ellipsesSuffix asUTF32.
	maxW _ (aNumber - (self stringWidth: ellipses)) max: 10.
	s _ aString asUTF32.
	(self stringWidth: s) < maxW ifTrue: [^ aString].

	1 to: s size do: [:i |
		w _ self stringWidth: (s copyFrom: 1 to: i), ellipses.
		w > maxW ifTrue: [
			^ ((s copyFrom: 1 to: i - 1), ellipses) asUTF8]].

	^ aString

! !

!StringMorph methodsFor: 'private' stamp: 'jm 6/7/2008 21:10'!
xOffsetFor: characterOffset in: aString
	"Answer the x-offset from the start of the given string to one pixel before the character with the given index. An offset of-1 is the position just before the first character."

	| subStr |
	characterOffset < 1 ifTrue: [^ -1].
	subStr _ aString copyFrom: 1 to: (characterOffset min: aString size).
	^ self stringWidth: subStr
! !

!StringMorph methodsFor: 'private' stamp: 'jm 6/29/2008 11:03'!
xRangesFor: s
	"Anwer an array of (leftX, rightX) pairs for the given string. For Unicode, there will be an entry in the resulting array for each UTF character in the input string, even when characters combine, so the x ranges for characters may overlap."
	"StringMorph new xRangesFor: 'Hello' asUTF8"

	s isUnicode | self forceUnicodeRendering ifTrue: [
		ScratchTranslator canRenderUnicode
			ifTrue: [^ ScratchTranslator xRangesFor: s asUTF8 font: self font]
			ifFalse: [^ self font xRangesFor: s asMacRoman]].

	^ self font xRangesFor: s
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

StringMorph class
	instanceVariableNames: ''!

!StringMorph class methodsFor: 'instance creation' stamp: 'jm 6/2/2008 14:47'!
contents: aString
	"Create an instance of me with the given contents."

	^ self basicNew initWithContents: aString font: nil
! !

!StringMorph class methodsFor: 'instance creation' stamp: 'jm 6/2/2008 14:47'!
contents: aString font: aFont
	"Create an instance of me with the given contents and font."

	^ self basicNew initWithContents: aString font: aFont
! !

!StringMorph class methodsFor: 'instance creation' stamp: 'jm 5/31/2003 20:03'!
includeInNewMorphMenu

	^ true
! !


!StringMorph class methodsFor: 'testing' stamp: 'di 5/6/1998 21:07'!
test
	"Return a morph with lots of strings for testing display speed."
	| c |
	c _ AlignmentMorph newColumn.
	SystemOrganization categories do:
		[:cat | c addMorph: (StringMorph new contents: cat)].
	^ c! !

!StringMorph class methodsFor: 'testing' stamp: 'jm 6/15/2003 10:35'!
test2
	"Return a morph with lots of strings for testing display speed."
	"StringMorph test2 openInWorld"

	| c r |
	c _ AlignmentMorph newColumn.
	SystemOrganization categories do:
		[:cat | c addMorphBack: (StringMorph new contents: cat)].
	r _ BorderedMorph new extent: c fullBounds extent.
	r color: Color white.
	c submorphsDo: [:m | r addMorph: m].
	^ r
! !
