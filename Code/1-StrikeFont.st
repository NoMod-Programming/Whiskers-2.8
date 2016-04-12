Object subclass: #StrikeFont
	instanceVariableNames: 'name pointSize ascent descent emphasis characterToGlyphMap xTable glyphs minAscii maxAscii maxWidth derivativeFonts isOSFont '
	classVariableNames: 'AllFonts '
	poolDictionaries: 'TextConstants '
	category: 'Graphics-Text'!
!StrikeFont commentStamp: 'jm 9/20/2007 09:49' prior: 0!
I represent a compact encoding of a set of Forms corresponding to characters in the ASCII character set. All the forms are placed side by side in a large form whose height is the font height, and whose width is the sum of all the character widths. The xTable variable gives the left x-coordinates of the subforms corresponding to the glyphs. Characters are mapped to glyphs by using the characterToGlyphMap.

Subclasses could have non-trivial mapping rules as well as different representations for glyphs sizes (e.g., not using an xTable). If so, these classes should return nil when queried for xTable and/or the characterToGlyphMap. This will cause the CharacterScanner primitive to fail and query the font for the width of a character (so that a more programatical approach can be implemented).

For display, fonts must implement these two messages:
	#installOn: aDisplayContext foregroundColor: foregroundColor backgroundColor: backgroundColor
This method installs the receiver (a font) on the given DisplayContext (which may be an instance of BitBlt or Canvas (or any of it's subclasses). The font should take the appropriate action to initialize the display context so that further display operations can be optimized.

	#displayString: aString on: aDisplayContext from: startIndex to: stopIndex at: aPoint kern: kernDelta
This method is called for each subsequent run of characters in aString which is to be displayed using the previously installed settings.

StrikeFonts use the MacRoman character set encoding, but some of the more playful fonts are not complete.

As of 2007, the following fonts are complete (although some are missing a few glyphs, such as the Euro currency mark): ComicSans Helvetica HelveticaBold HelveticaNeueBold HelveticaNeueMedium Times TimesBold Verdana VerdanaBold VerdanaBoldNarrowSpace.

The following older Apple Smalltalk fonts offer only partial coverage: NewYork NewYorkBold.

These fonts offer only partial coverage of MacRoman: Aardvark Cheri ComicBook Emulator Hebrew Letteromatic Parchment Radaern Scratch Textile Typewriter.

The Textile font has an off-by-one error toward the end due to a problem in the importing process.

PenMark is an ISO Latin font (ISO 8859-1).
!


!StrikeFont methodsFor: 'initialization' stamp: 'jm 12/27/2005 10:47'!
initForms: charForms firstAscii: firstAscii ascent: charAscent
	"Initialize myself with the given ascent from the given array of character Forms, the first of which is firstAscii. Assume that all character Forms are the same height. Note that charForms includes the symbol #missing for characters."

	| glyphsH missingGlyph spaceBetweenGlyphs nextX glyph firstX |
	glyphsH _ charForms first height.
	characterToGlyphMap _ nil.   "computed on demand"
	name _ 'none'.
	minAscii _ 0.
	maxAscii _ firstAscii + charForms size - 1.
	maxWidth _ 0.  "updated below"
	ascent _ charAscent.
	descent _ glyphsH - charAscent.
	emphasis _ 1.
	derivativeFonts _ nil.

	"make a glyph to be used for missing characters"
	missingGlyph _ Form extent: ((glyphsH // 2) max: 3)@glyphsH depth: 1.
	missingGlyph border: (0@0 extent: missingGlyph width@ascent) width: 1.

	"compute spacing"
	spaceBetweenGlyphs _ (ascent // 16) max: 1.

	"build xTable, find maxWidth, and compute total width of glyphs Form"
	xTable _ OrderedCollection new.
	nextX _ 0.
	firstAscii timesRepeat: [xTable add: nextX. nextX _ nextX + 1].  "chars < firstAscii display as a one-pixel wide space"
	firstX _ nextX.

	(charForms copyWith: missingGlyph) do: [:f |
		glyph _ #missing = f ifTrue: [missingGlyph] ifFalse: [f].
		xTable addLast: nextX.
		maxWidth _ maxWidth max: glyph width.
		nextX _ nextX + glyph width + spaceBetweenGlyphs].
	xTable size to: 257 do: [:i | xTable addLast: nextX].
	xTable _ xTable asArray.

	"build the glyphs Form, inserting one pixel of space between each character"
	glyphs _ Form extent: nextX@glyphsH depth: 1.
	nextX _ firstX.
	(charForms copyWith: missingGlyph) do: [:f |
		glyph _ #missing = f ifTrue: [missingGlyph] ifFalse: [f].
		glyph displayOn: glyphs at: nextX@0.
		nextX _ nextX + glyph width + spaceBetweenGlyphs].

! !

!StrikeFont methodsFor: 'initialization' stamp: 'jm 2/19/2005 21:46'!
initFrom: originalFont magnifiedBy: aNumber
	"Initialize myself to be a copy of the given font magnified by the give factor. If the magnification is not an integer it is rounded up to the next integer."
	"(StrikeFont new initFrom: TextStyle defaultFont magnifiedBy: 7) displayLine: 'Hello!!' at: 0@0"

	| mag |
	mag _ aNumber.
	mag isInteger ifFalse: [mag _ mag truncated + 1].
	mag <= 1 ifTrue: [self error: 'Font magnification must be > 1'].
	mag > 30 ifTrue: [self error: 'Maximum font magnification is 30'].

	characterToGlyphMap _ originalFont characterToGlyphMap.
	xTable _ originalFont xTable collect: [:n | mag * n].
	glyphs _ originalFont glyphs magnifyBy: mag.
	name _ originalFont name, '-x', mag printString.
	minAscii _ originalFont minAscii.
	maxAscii _ originalFont maxAscii.
	maxWidth _ mag * originalFont maxWidth.
	ascent _ mag * originalFont ascent.
	descent _ mag * originalFont descent.
	emphasis _ 1.
	derivativeFonts _ nil.
! !


!StrikeFont methodsFor: 'accessing' stamp: 'jm 2/19/2005 21:42'!
ascent
	"Answer the receiver's maximum extent of characters above the baseline."

	^ ascent
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 2/19/2005 21:42'!
characterToGlyphMap
	"Answer the character to glyph mapping table. If the table is not provided the character scanner will query the font directly for the width of each individual character."

	^ characterToGlyphMap ifNil: [
		characterToGlyphMap _ self createCharacterToGlyphMap]
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 2/19/2005 21:42'!
descent
	"Answer the receiver's maximum extent of characters below the baseline."

	^ descent
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 2/19/2005 21:42'!
glyphs
	"Answer a Form containing the bits representing the characters of the receiver."

	^ glyphs
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 2/19/2005 21:36'!
height
	"Answer my height, the sum of my ascent and descent."

	^ ascent + descent
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 7/10/2008 12:25'!
isOSFont
	"System fonts, to be rendered using the Unicode plugin, are represented by a StrikeFont with name beginning with an asterisk."

	isOSFont ifNil: [isOSFont _ false].
	^ isOSFont
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 7/10/2008 12:09'!
isOSFont: aBoolean

	isOSFont _ aBoolean.
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 2/19/2005 21:43'!
maxAscii
	"Answer the integer that is the last Ascii character value of the receiver."

	^ maxAscii
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 2/19/2005 21:43'!
maxWidth
	"Answer the integer that is the width of the receiver's widest character."

	^ maxWidth
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 2/19/2005 21:43'!
minAscii
	"Answer the integer that is the first Ascii character value of the receiver."

	^ minAscii
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 12/16/2005 11:20'!
name
	"Answer this font's family name."

	^ name
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 12/16/2005 11:20'!
name: aString
	"Set this font's family name."

	name _ aString asSymbol.
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 12/16/2005 12:03'!
pointSize
	"Answer the point size for the font. This is often the same as the font's ascent, but sometimes it's different."

	^ pointSize ifNil: [ascent] ifNotNil: [pointSize]
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 12/16/2005 11:58'!
pointSize: anInteger

	pointSize _ anInteger.
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 6/29/2008 10:41'!
widthOf: aCharacter 
	"Answer the width of the argument as a character in the receiver."

	| ascii |
	aCharacter isNumber
		ifTrue: [ascii _ aCharacter] "Unicode character"
		ifFalse: [ascii _ aCharacter asciiValue].
	(ascii between: minAscii and: maxAscii) ifFalse: [ascii _ maxAscii + 1].
	^ (xTable at: ascii + 2) - (xTable at: ascii + 1)
! !

!StrikeFont methodsFor: 'accessing' stamp: 'jm 12/16/2005 11:55'!
xTable
	"Answer an Array of the left x-coordinate of characters in glyphs."

	^ xTable
! !


!StrikeFont methodsFor: 'displaying' stamp: 'jm 12/16/2005 11:56'!
displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta
	"Draw the given string from startIndex to stopIndex at aPoint on the (already prepared) BitBlt."

	aBitBlt displayString: aString 
		from: startIndex 
		to: stopIndex 
		at: aPoint 
		strikeFont: self
		kern: kernDelta.
! !

!StrikeFont methodsFor: 'displaying' stamp: 'jm 5/12/2003 16:34'!
installOn: aDisplayContext foregroundColor: foregroundColor backgroundColor: backgroundColor
	"Install the receiver on the given display context for further drawing operations."

	^ aDisplayContext 
		installStrikeFont: self
		foregroundColor: foregroundColor 
		backgroundColor: backgroundColor
! !


!StrikeFont methodsFor: 'emphasis' stamp: 'jm 5/29/2003 18:04'!
bonk: glyphForm with: bonkForm
	"Bonking means to run through the glyphs clearing out black pixels
	between characters to prevent them from straying into an adjacent
	character as a result of, eg, bolding or italicizing"
	"Uses the bonkForm to erase at every character boundary in glyphs."

	| bb offset |
	offset _ bonkForm offset x.
	bb _ BitBlt toForm: glyphForm.
	bb sourceForm: bonkForm; sourceRect: bonkForm boundingBox;
		combinationRule: Form erase; destY: 0.
	1 to: xTable size-1 do: [:i | bb destX: (xTable at: i) + offset; copyBits].
! !

!StrikeFont methodsFor: 'emphasis'!
emphasis
	"Answer the integer code for synthetic bold, italic, underline, and 
	strike-out."

	^emphasis! !

!StrikeFont methodsFor: 'emphasis'!
emphasis: code 
	"Set the integer code for synthetic bold, itallic, underline, and strike-out, 
	where bold=1, italic=2, underlined=4, and struck out=8."

	emphasis _ code! !

!StrikeFont methodsFor: 'emphasis'!
emphasized: code 
	"Answer a copy of the receiver with emphasis set to include code."
	| derivative addedEmphasis base g r safeCode |
	code = 0 ifTrue: [^ self].
	(derivativeFonts == nil or: [derivativeFonts size = 0]) ifTrue: [^ self].
	derivative _ derivativeFonts at: (safeCode _ code min: derivativeFonts size).
	derivative == nil ifFalse: [^ derivative].  "Already have this style"

	"Dont have it -- derive from another with one with less emphasis"
	addedEmphasis _ 1 bitShift: safeCode highBit - 1.
	base _ self emphasized: safeCode - addedEmphasis.  "Order is Bold, Ital, Under, Narrow"
	addedEmphasis = 1 ifTrue:   "Compute synthetic bold version of the font"
		[derivative _ (base copy name: base name , 'B') makeBoldGlyphs].
	addedEmphasis = 2 ifTrue:   "Compute synthetic italic version of the font"
		[ derivative _ (base copy name: base name , 'I') makeItalicGlyphs].
	addedEmphasis = 4 ifTrue:   "Compute underlined version of the font"
		[derivative _ (base copy name: base name , 'U') makeUnderlinedGlyphs].
	addedEmphasis = 8 ifTrue:   "Compute narrow version of the font"
		[derivative _ (base copy name: base name , 'N') makeCondensedGlyphs].
	addedEmphasis = 16 ifTrue:   "Compute struck-out version of the font"
		[derivative _ (base copy name: base name , 'X') makeStruckOutGlyphs].
	derivative emphasis: safeCode.
	derivativeFonts at: safeCode put: derivative.
	^ derivative! !

!StrikeFont methodsFor: 'emphasis'!
makeBoldGlyphs
	"Make a bold set of glyphs with same widths by ORing 1 bit to the right
		(requires at least 1 pixel of intercharacter space)"
	| g bonkForm |
	g _ glyphs deepCopy.
	bonkForm _ (Form extent: 1@16) fillBlack offset: -1@0.
	self bonk: g with: bonkForm.
	g copyBits: g boundingBox from: g at: (1@0)
		clippingBox: g boundingBox rule: Form under fillColor: nil.
	glyphs _ g! !

!StrikeFont methodsFor: 'emphasis' stamp: 'di 10/31/97 13:18'!
makeCondensedGlyphs
	"Make a condensed set of glyphs with same widths.
	NOTE: this has been superceded by kerning -- should not get called"
	| g newXTable x x1 w |
	g _ glyphs deepCopy.
	newXTable _ Array new: xTable size.
	newXTable at: 1 put: (x _ xTable at: 1).
	1 to: xTable size-1 do:
		[:i | x1 _ xTable at: i.  w _ (xTable at: i+1) - x1.
		w > 1 ifTrue: [w _ w-1].  "Shrink every character wider than 1"
		g copy: (x@0 extent: w@g height) from: x1@0 in: glyphs rule: Form over.
		newXTable at: i+1 put: (x _ x + w)].
	xTable _ newXTable.
	glyphs _ g
"
(TextStyle default fontAt: 1) copy makeCondensedGlyphs
	displayLine: 'The quick brown fox jumps over the lazy dog'
	at: Sensor cursorPoint
"! !

!StrikeFont methodsFor: 'emphasis'!
makeItalicGlyphs
	"Make an italic set of glyphs with same widths by skewing left and right
		(may require more intercharacter space)"
	| g r bonkForm bc |
	g _ glyphs deepCopy.
	"BonkForm will have bits where slanted characters overlap their neighbors."
	bonkForm _ Form extent: (self height//4+2) @ self height.
	bc _ self descent//4 + 1.  "Bonker x-coord corresponding to char boundary."
	bonkForm fill: (0 @ 0 corner: (bc+1) @ self ascent) fillColor: Color black.
	4 to: self ascent-1 by: 4 do:
		[:y | 		"Slide ascenders right..."
		g copy: (1@0 extent: g width @ (self ascent - y))
			from: 0@0 in: g rule: Form over.
		bonkForm copy: (1@0 extent: bonkForm width @ (self ascent - y))
			from: 0@0 in: bonkForm rule: Form over].
	bonkForm fill: (0 @ 0 corner: (bc+1) @ self ascent) fillColor: Color white.
	bonkForm fill: (bc @ self ascent corner: bonkForm extent) fillColor: Color black.
	self ascent to: self height-1 by: 4 do:
		[:y | 		"Slide descenders left..."
		g copy: (0@y extent: g width @ g height)
			from: 1@y in: g rule: Form over.
		bonkForm copy: (0@0 extent: bonkForm width @ bonkForm height)
			from: 1@0 in: bonkForm rule: Form over].
	bonkForm fill: (bc @ self ascent corner: bonkForm extent) fillColor: Color white.
	"Now use bonkForm to erase at every character boundary in glyphs."
	bonkForm offset: (0-bc) @ 0.
	self bonk: g with: bonkForm.
	glyphs _ g
! !

!StrikeFont methodsFor: 'emphasis'!
makeStruckOutGlyphs
	"Make a struck-out set of glyphs with same widths"
	| g |
	g _ glyphs deepCopy.
	g fillBlack: (0 @ (self ascent - (self ascent//3)) extent: g width @ 1).
	glyphs _ g
! !

!StrikeFont methodsFor: 'emphasis'!
makeUnderlinedGlyphs
	"Make an underlined set of glyphs with same widths"
	| g |
	g _ glyphs deepCopy.
	g fillBlack: (0 @ (self ascent+1) extent: g width @ 1).
	glyphs _ g
! !

!StrikeFont methodsFor: 'emphasis' stamp: 'jm 12/16/2005 11:19'!
reset
	"Reset the cache of derivative emphasized fonts"

	| style font |
	derivativeFonts _ Array new: 32.
	#('B' 'I' 'BI') doWithIndex:
		[:tag :index | 
		(style _ TextStyle named: self name) ifNotNil:
			[(font _ style fontArray
				detect: [:each | each name = (self name , tag)]
				ifNone: [nil]) ifNotNil: [derivativeFonts at: index put: font]]]! !


!StrikeFont methodsFor: 'utilities' stamp: 'di 3/27/2000 14:25'!
characterFormAt: character 
	"Answer a Form copied out of the glyphs for the argument, character."
	| ascii leftX rightX |
	ascii _ character asciiValue.
	(ascii between: minAscii and: maxAscii) ifFalse: [ascii _ maxAscii + 1].
	leftX _ xTable at: ascii + 1.
	rightX _ xTable at: ascii + 2.
	^ glyphs copy: (leftX @ 0 corner: rightX @ self height)! !

!StrikeFont methodsFor: 'utilities' stamp: 'di 3/27/2000 16:15'!
characterFormAt: character put: characterForm
	"Copy characterForm over the glyph for the argument, character."
	| ascii leftX rightX widthDif newGlyphs |
	ascii _ character asciiValue.
	ascii < minAscii ifTrue: [^ self error: 'Cant store characters below min ascii'].
	ascii > maxAscii ifTrue:
		[(self confirm:
'This font does not accomodate ascii values higher than ' , maxAscii printString , '.
Do you wish to extend it permanently to handle values up to ' , ascii printString)
			ifTrue: [self extendMaxAsciiTo: ascii]
			ifFalse: [^ self error: 'No change made']].
	leftX _ xTable at: ascii + 1.
	rightX _ xTable at: ascii + 2.
	widthDif _ characterForm width - (rightX - leftX).
	widthDif ~= 0 ifTrue:
		["Make new glyphs with more or less space for this char"
		newGlyphs _ Form extent: (glyphs width + widthDif) @ glyphs height.
		newGlyphs copy: (0@0 corner: leftX@glyphs height)
			from: 0@0 in: glyphs rule: Form over.
		newGlyphs copy: ((rightX+widthDif)@0 corner: newGlyphs width@glyphs height)
			from: rightX@0 in: glyphs rule: Form over.
		glyphs _ newGlyphs.
		"adjust further entries on xTable"
		ascii+2 to: xTable size
			do: [:i | xTable at: i put: (xTable at: i) + widthDif]].
	glyphs copy: (leftX @ 0 extent: characterForm extent)
		from: 0@0 in: characterForm rule: Form over
"
| f |  f _ TextStyle defaultFont.
f characterFormAt: $  put: (Form extent: (f widthOf: $ )+10@f height)
"! !

!StrikeFont methodsFor: 'utilities'!
displayChar: ascii form: charForm
	"Convenience utility used during conversion of BitFont files"
	| m bigForm |
	Display fillBlack: (0@0 extent: 20@14).
	ascii printString displayAt: 0@2.
	charForm width > 0 ifTrue:
		[m _ 5.
		bigForm _ charForm magnify: charForm boundingBox by: m@m.
		Display border: ((bigForm boundingBox expandBy: m) translateBy: 50@2) width: m.
		bigForm displayAt: 50@2.
		Display fillBlack: ((50@2)+((m*charForm width)@0) extent: 1@(m*self height))].! !

!StrikeFont methodsFor: 'utilities'!
displayLine: aString at: aPoint 
	"Display the characters in aString, starting at position aPoint."

	self characters: (1 to: aString size)
		in: aString
		displayAt: aPoint
		clippedBy: Display boundingBox
		rule: Form over
		fillColor: nil! !

!StrikeFont methodsFor: 'utilities' stamp: 'sma 3/11/2000 11:28'!
edit: character		"(TextStyle default fontAt: 1) edit: $_"
	"Open a Bit Editor on the given character.  Note that you must do an accept
	(in the option menu of the bit editor) if you want this work.
	Accepted edits will not take effect in the font until you leave or close the bit editor.
	Also note that unaccepted edits will be lost when you leave or close."
	| charForm editRect scaleFactor bitEditor savedForm r |
	charForm _ self characterFormAt: character.
	editRect _ BitEditor locateMagnifiedView: charForm
	                                        scale: (scaleFactor _ 8@8).
	bitEditor _ BitEditor bitEdit: charForm at: editRect topLeft
			scale: scaleFactor remoteView: nil.
	savedForm _ Form fromDisplay: (r _ bitEditor displayBox expandBy: (0@23 corner: 0@0)).
	bitEditor controller startUp.
	bitEditor release.
	savedForm displayOn: Display at: r topLeft.
	self characterFormAt: character put: charForm! !

!StrikeFont methodsFor: 'utilities' stamp: 'di 4/28/2000 16:10'!
fixOneWideChars 
	"This fixes all 1-wide characters to be 2 wide with blank on the right
	so as not to cause artifacts in neighboring characters in bold or italic."
	| twoWide |
	minAscii to: maxAscii do:
		[:i | (self widthOf: (Character value: i)) = 1 ifTrue:
			[twoWide _ Form extent: 2@glyphs height.
			(self characterFormAt: (Character value: i)) displayOn: twoWide at: 0@0.
			self characterFormAt: (Character value: i) put: twoWide]].
"
StrikeFont allInstancesDo: [:f | f fixOneWideChars].
StrikeFont shutDown.  'Flush synthetic fonts'.
"
! !

!StrikeFont methodsFor: 'utilities' stamp: 'jm 12/15/2005 12:04'!
show
	"TextStyle default defaultFont show"

	Display restoreAfter: [
		Display fillWhite: (20@20 extent: 620@600).
		0 to: 15 do: [:i |
			i hex displayAt: 50 @ ((32 * i) + 50).
			0 to: 15 do: [:j |
				((16*i+j) between: 1 and: (self xTable size - 2)) ifTrue: [
					(self characterFormAt: (16 * i + j) asCharacter)
						displayAt: (32 * j + 100) @ ((32 * i) + 50)]]].
			'Click to continue...' asDisplayText
				displayOn: Display
				at: 50@580
				rule: Form paint].
! !

!StrikeFont methodsFor: 'utilities' stamp: 'jm 5/12/2003 17:48'!
widthOfString: aString
	"Answer the width of the given string in this font."
	"TextStyle default defaultFont widthOfString: 'hello!!'"

	^ self composeWord: (1 to: aString size) in: aString beginningAt: 0
! !

!StrikeFont methodsFor: 'utilities' stamp: 'jm 6/7/2008 21:24'!
xRangesFor: aString
	"Anwer an array of (leftX, rightX) pairs for the given string."
	"(StrikeFont fontName: 'New York' size: 12) xRangesFor: 'Hello'"
	"| f | f _ StrikeFont fontName: 'New York' size: 12. (1 to: 5) collect: [:i | f widthOfString: ('Hello' copyFrom: 1 to: i)]"

	| result lastX w right |
	result _ Array new: aString size.
	lastX _ 0.
	1 to: aString size do: [:i |
		w _ self widthOf: (aString at: i).
		right _ lastX + w.
		result at: i put: (Array with: lastX with: right).
		lastX _ right].

	^ result
! !


!StrikeFont methodsFor: 'file in/out' stamp: 'jm 12/16/2005 12:28'!
readFromOldStrikeFile: fileName
	"Build an instance from the old ST-80 strike font file name. The '.strike' extension is optional."
	"Note: this is an old format; use strike2 format instead."

	| f rasterWidth defaultSpaceWidth |
	f _ (FileStream readOnlyFileNamed: fileName) binary.

	name _ fileName copyUpTo: $..
	minAscii		_		f uint16.
	maxAscii		_		f uint16.
	maxWidth		_		f uint16.
	"strikeLength	_"		f uint16.
	ascent			_		f uint16.
	descent			_		f uint16.
	"xOffset			_"		f uint16. 	
	rasterWidth		_		f uint16 * 16.	
	emphasis		_		0.
	glyphs			_		Form extent: rasterWidth @ self height.
	f next: glyphs bits size into: glyphs bits startingAt: 1.
	characterToGlyphMap _ nil.

	xTable _ (Array new: maxAscii + 3) atAllPut: 0.
	minAscii + 1 to: maxAscii + 3 do: [:i | xTable at: i put: f uint16].

	"set up space character"
	defaultSpaceWidth _ 4.
	((xTable at: (Space asciiValue + 2)) = 0 or:
	 [(xTable at: (Space asciiValue + 2)) = (xTable at: (Space asciiValue + 1))]) ifTrue:	[
		(Space asciiValue + 2) to: xTable size do: [:i |
			xTable at: i put: ((xTable at: i) + defaultSpaceWidth)]].
	f close.
! !

!StrikeFont methodsFor: 'file in/out' stamp: 'jm 12/16/2005 12:27'!
readFromStrike2Stream: file 
	"Build an instance from the supplied binary stream on data in strike2 format"

	| fType defaultSpaceWidth |
	fType _ file int32.
	fType = 2 ifFalse: [file close. self error: 'not strike2 format'].
	minAscii _ file int32.
	maxAscii _ file int32.
	maxWidth _ file int32.
	ascent _ file int32.
	descent _ file int32.
	pointSize _ file int32.
	emphasis _ file int32.
	xTable _ (Array new: maxAscii + 3) atAllPut: 0.
	(minAscii + 1 to: maxAscii + 3) do: [:i | xTable at: i put: file int32].
	glyphs _ Form new readFrom: file.

	"set up space character"
	defaultSpaceWidth _ 4.
	((xTable at: (Space asciiValue + 2)) = 0 or:
	 [(xTable at: (Space asciiValue + 2)) = (xTable at: (Space asciiValue + 1))]) ifTrue:	[
		(Space asciiValue + 2) to: xTable size do: [:i |
			xTable at: i put: ((xTable at: i) + defaultSpaceWidth)]].
	characterToGlyphMap _ nil.
! !

!StrikeFont methodsFor: 'file in/out' stamp: 'jm 12/16/2005 12:21'!
readStrike2FileNamed: fileName
	"Build an instance from the strike font stored in strike2 format."
	"StrikeFont new readStrike2FileNamed: 'Palatino14.sf2'"

	| file |
	('*.sf2' match: fileName) ifFalse: [self halt.  "likely incompatible"].
	name _ fileName copyUpTo: $. .  "get family name"
	file _ (FileStream readOnlyFileNamed: fileName) binary.
	self readFromStrike2Stream: file.
	file close.
! !

!StrikeFont methodsFor: 'file in/out' stamp: 'jm 12/16/2005 12:44'!
writeAsStrike2On: aStream
	"Write me onto the given binary stream in strike2 format."

	aStream int32: 2.
	aStream int32: minAscii.
	aStream int32: maxAscii.
	aStream int32: maxWidth.
	aStream int32: ascent.
	aStream int32: descent.
	aStream int32: self pointSize.
	aStream int32: emphasis.
	(minAscii + 1 to: maxAscii + 3) do: [:i | aStream int32: (xTable at: i)].
	glyphs writeOn: aStream.
! !

!StrikeFont methodsFor: 'file in/out' stamp: 'jm 12/16/2005 12:20'!
writeStrike2FileNamed: fileName
	"Write me onto a file in strike2 format. By convention, the file name should be of the form: <family name><pointSize>.sf2"

	| file |
	file _ (FileStream newFileNamed: fileName) binary.
	self writeAsStrike2On: file.
	file close.
! !


!StrikeFont methodsFor: 'printing' stamp: 'jm 12/16/2005 12:00'!
printOn: aStream

	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self name;
		space;
		print: self pointSize;
		nextPut: $).
! !


!StrikeFont methodsFor: 'private' stamp: 'jm 5/29/2003 18:04'!
characters: anInterval in: sourceString displayAt: aPoint 
	clippedBy: clippingRectangle rule: ruleInteger fillColor: aForm 	"Simple, slow, primitive method for displaying a line of characters.
	No wrap-around is provided."

	| ascii destPoint bb leftX rightX sourceRect |
	destPoint _ aPoint.
	bb _ BitBlt toForm: Display.
	anInterval do: 
		[:i | 
		ascii _ (sourceString at: i) asciiValue.
		(ascii < minAscii or: [ascii > maxAscii])
			ifTrue: [ascii _ maxAscii].
		leftX _ xTable at: ascii + 1.
		rightX _ xTable at: ascii + 2.
		sourceRect _ leftX@0 extent: (rightX-leftX) @ self height.
		bb copyFrom: sourceRect in: glyphs to: destPoint.
		destPoint _ destPoint + ((rightX-leftX)@0)].
	^ destPoint! !

!StrikeFont methodsFor: 'private' stamp: 'jm 5/12/2003 16:40'!
composeWord: aTextLineInterval in: aString beginningAt: startX 
	"Non-primitive composition of a word--add the widths of all the characters in the given interval to startX and answer the total. Similar to the scanning primitive, but does not process any stop conditions."

	| result |
	result _ startX.
	aTextLineInterval do: [:i | 
		result _ result + (self widthOf: (aString at: i))].
	^ result
! !

!StrikeFont methodsFor: 'private' stamp: 'EMP 11/4/2015 15:54'!
createCharacterToGlyphMap
	"Private. Create the character to glyph mapping for a font that didn't have any before. This is basically equivalent to what the former setStopCondition did, only based on indexes."

	| map |
	map _ Array new: 256.
	0 to: minAscii - 1 do: [:i | map at: i + 1 put: maxAscii + 1].
	minAscii to: maxAscii do: [:i | map at: i + 1 put: i].
	maxAscii + 1 to: 255 do: [:i | map at: i + 1 put: maxAscii + 1].
	^ map
! !

!StrikeFont methodsFor: 'private' stamp: 'ar 5/23/2000 12:48'!
extendMaxAsciiTo: newMax
	"Extend the range of this font so that it can display glyphs up to newMax."

	(newMax+3) <= xTable size ifTrue: [^ self].  "No need to extend."
	xTable size = (maxAscii+3) ifFalse:
		[^ self error: 'This font is not well-formed.'].

	"Insert a bunch of zero-width characters..."
	xTable _ (xTable copyFrom: 1 to: maxAscii+2) ,
			((maxAscii+1 to: newMax) collect: [:i | xTable at: maxAscii+2]) ,
			{ xTable at: maxAscii+3 }.
	maxAscii _ newMax.
	self fillZeroWidthSlots.
	characterToGlyphMap _ nil.! !

!StrikeFont methodsFor: 'private' stamp: 'jm 5/24/2003 16:29'!
fillZeroWidthSlots
	"Note: this is slow because it copies the font once for every replacement."

	| nullGlyph |
	nullGlyph _ (Form extent: 1@glyphs height) fillColor: Color gray.

	"Fill the empty slots with narrow box characters."
	minAscii to: maxAscii do:
		[:i | (self widthOf: (Character value: i)) = 0 ifTrue:
			[self characterFormAt: (Character value: i) put: nullGlyph]].

! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

StrikeFont class
	instanceVariableNames: ''!

!StrikeFont class methodsFor: 'instance creation' stamp: 'jm 12/15/2005 13:55'!
passwordFontSize: aSize

	| aFont newXTable newGlyphs |
	aFont _ (StrikeFont fontName: #NewYork size: aSize) copy.
	newXTable _ aFont xTable copy.
	newGlyphs _ aFont glyphs copy.
	aFont instVarNamed: 'xTable' put: newXTable.
	aFont instVarNamed: 'glyphs' put: newGlyphs.
	aFont minAscii to: aFont maxAscii do: [:ascii |
		aFont characterFormAt: ascii asCharacter put: (aFont characterFormAt: $*)].
	^ aFont
! !


!StrikeFont class methodsFor: 'examples' stamp: 'jm 12/15/2005 14:04'!
example
	"Displays a line of text on the display screen at the location of the cursor."
	"StrikeFont example"

	| y font s |
	y _ 10.
	Display restoreAfter: [
		Display fillWhite.
		self fontNames do: [:fn |
			(self sizesForFontName: fn) do: [:sz |
				font _ self fontName: fn size: sz.
				s _ 'Hello in ', fn, ' ', sz printString.
				font displayLine: s at: 10@y.
				y _ y + font height + 3]]].

! !

!StrikeFont class methodsFor: 'examples' stamp: 'jm 12/16/2005 13:00'!
showSizes: fontName
	"Displays a line of text on the display screen at the location of the cursor."
	"StrikeFont showSizes: 'Verdana'"

	| y font s |
	y _ 10.
	Display restoreAfter: [
		Display fillWhite.
		(self sizesForFontName: fontName) do: [:sz |
			font _ self fontName: fontName size: sz.
			s _ 'Hello in ', fontName, ' ', sz printString.
			font displayLine: s at: 10@y.
			y _ y + font height + 3]].

! !


!StrikeFont class methodsFor: 'font lookup' stamp: 'jm 6/7/2007 10:55'!
addFont: aStrikeFont

	(AllFonts includes: aStrikeFont) ifTrue: [^ self].
	AllFonts _ AllFonts copyWith: aStrikeFont.
! !

!StrikeFont class methodsFor: 'font lookup' stamp: 'jm 1/13/2006 19:01'!
allFonts

	^ AllFonts
! !

!StrikeFont class methodsFor: 'font lookup' stamp: 'EMP 10/10/2015 16:43'!
blockOsFontName: fontName size: desiredSize
	"Answer a font to represent an OS font. Find a Squeak font of similar size to act as a placeholder for the OS font, then return a copy of that font with the OS font name and size."
	"Note: This approach allows the placeholder font to be used by the Squeak rendering system if the Unicode plugin is not available."
	"StrikeFont osFontName: 'VerdanaBold' size: 12"

	| font |
	"copy a Squeak font of similar size:"
	font _ (StrikeFont fontName: 'VerdanaBold' size: desiredSize) copy.
	font
		name: fontName;
		pointSize: desiredSize;
		isOSFont: true.
	^ font

! !

!StrikeFont class methodsFor: 'font lookup' stamp: 'jm 1/15/2006 15:38'!
closestNameTo: aString
	"Answer the font name whose most similar to the given name."

	| lcName closestMatch closestPrefixLength thisName n prefixLength |
	lcName _ aString asLowercase.
	(self fontNames includes: #Verdana)
		ifTrue: [closestMatch _ #Verdana]
		ifFalse: [closestMatch _ AllFonts first name].
	closestPrefixLength _ 0.
	self fontNames do: [:fn |
		thisName _ fn asLowercase.
		thisName = lcName ifTrue: [^ fn].
		n _ lcName size min: thisName size.
		prefixLength _ ((1 to: n) detect: [:i | (lcName at: i) ~= (thisName at: i)] ifNone: [n + 1]) - 1.
		prefixLength > closestPrefixLength ifTrue: [
			closestMatch _ fn.
			closestPrefixLength _ prefixLength]].

	^ closestMatch
! !

!StrikeFont class methodsFor: 'font lookup' stamp: 'EMP 11/4/2015 16:02'!
fontName: fontName size: desiredSize
	"Answer a font (or a default font if the given name is unknown) of the specified size. Answer the font whose pointSize (not its total height) is closest to the given size."
	"StrikeFont fontName: 'ComicSans' size: 12"

	| fontList similarName bestFont bestDist dist |
	fontList _ AllFonts select: [:f | f name = fontName].
	fontList isEmpty ifTrue: [
		similarName _ self closestNameTo: fontName.
		fontList _ AllFonts select: [:f | f name = similarName]].
	fontList isEmpty ifTrue: [fontList _ AllFonts].  "last resort--search all fonts"

	"find the closest size"
	bestFont _ fontList first.
	bestDist _ 9999.
	fontList do: [:f |
		dist _ (f pointSize - desiredSize) abs.
		dist < bestDist ifTrue: [
			bestFont _ f.
			bestDist _ dist]].

	^ bestFont
! !

!StrikeFont class methodsFor: 'font lookup' stamp: 'jm 12/15/2005 13:39'!
fontNames
	"StrikeFont fontNames"

	^ (AllFonts collect: [:f | f name]) asSet asArray sort
! !

!StrikeFont class methodsFor: 'font lookup' stamp: 'jm 12/27/2005 10:49'!
initFonts
	"self initFonts"
	"AllFonts _ AllFonts copyWithout: (self fontName: 'Charcoal72' size: 10)"

	self shutDown.
	Smalltalk garbageCollect.
	AllFonts _ StrikeFont allInstances asArray.
	AllFonts sort: [:f1 :f2 | f1 pointSize <= f2 pointSize].
	AllFonts sort: [:f1 :f2 | f1 name <= f2 name].
! !

!StrikeFont class methodsFor: 'font lookup' stamp: 'EMP 10/10/2015 16:39'!
osFontName: fontName size: desiredSize
	"Answer a font to represent an OS font. Find a Squeak font of similar size to act as a placeholder for the OS font, then return a copy of that font with the OS font name and size."
	"Note: This approach allows the placeholder font to be used by the Squeak rendering system if the Unicode plugin is not available."
	"StrikeFont osFontName: 'VerdanaBold' size: 12"

	| font |
	"copy a Squeak font of similar size:"
	font _ (StrikeFont fontName: 'Verdana' size: desiredSize) copy.
	font
		name: fontName;
		pointSize: desiredSize;
		isOSFont: true.
	^ font

! !

!StrikeFont class methodsFor: 'font lookup' stamp: 'jm 6/7/2007 10:56'!
removeFont: aStrikeFont

	AllFonts _ AllFonts copyWithout: aStrikeFont.
! !

!StrikeFont class methodsFor: 'font lookup' stamp: 'EMP 10/10/2015 16:36'!
sizesForFontName: fontName
	"Answer a collection of sizes for the font with the given name. If there are no fonts with the given family name, answer an empty collection."
	"StrikeFont sizesForFontName: 'NewYork'"

	^ ((AllFonts select: [:f | f name = fontName])
		collect: [:f | f pointSize]) asArray sort
! !


!StrikeFont class methodsFor: 'shut down' stamp: 'jm 1/1/2004 11:14'!
shutDown
	"Release all synthetically derived versions of base fonts to save space in snapshots. They can be derived again when they are needed."
	"StrikeFont shutDown"

	self allSubInstancesDo: [:sf | sf reset].
! !
