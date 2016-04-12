Object subclass: #FontExtractor
	instanceVariableNames: 'strikeForm markerGlyph fontAscent fontHeight spaceWidth charOffset basePix lineForms '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!FontExtractor commentStamp: '<historical>' prior: 0!
This class allows you to extract any font from a screen shot of it.

Here's the process:

For best results, turn off font anti-aliasing or set your screen depth to one-bit. Then create the text file 'strike.txt' by doing:

	FontExtractor writeStrikeFile

Open that file in text editor and set the font to the desired font, style, and size. Make a screen shot of the text editor and store it in a graphics format readable by Squeak, such as BMP, PNG, or GIF (but NOT JPEG). Use your favorite image editor to crop the screen shot to a rectangle containing all the letters of the font, leaving a few pixels of white space around the edges. Don't include the window borders or anything outside of the window containing the font. You should end up with just the letters of the font in black on a plain white background.

Now process that font by doing:

	font _ FontExtractor extractFontFromFileNamed: 'yourFileName'

To do:
  [ ] handle two or more missing characters in a row (glyphsForLine:)
!


!FontExtractor methodsFor: 'all' stamp: 'jm 1/13/2006 13:47'!
baselineYForLineCounts: pixCountArray
	"Answer the baseline y from the given array of (<y>, <pixCount>) pairs for a given line."
	"Details: The first character in the line should be the marker character (a period). The baseline is the bottom of the marker character. So first we scan horizontally to isolate the maker, then we scan up to find its bottom."

	| lineForm tallies bgPix h x markStart markEnd mForm w y |
	lineForm _ strikeForm copy: (0@pixCountArray first first corner: strikeForm width@(pixCountArray last first + 1)).

	self assert: [lineForm depth = 1].
	tallies _ Bitmap new: (1 bitShift: lineForm depth).
	bgPix _ 1.  "white pixel value"
	h _ lineForm height.

	"find the start of the mark"
	x _ 0.
	markStart _ markEnd _ nil.
	[markEnd isNil] whileTrue: [
		tallies atAllPut: 0.
		lineForm tallyPixelValuesInRect: (x@0 extent: 1@h) into: tallies.
		markStart
			ifNil: [(tallies at: bgPix) < h ifTrue: [markStart _ x]]
			ifNotNil: [(tallies at: bgPix) = h ifTrue: [markEnd _ x]].
		x _ x + 1].

	mForm _ lineForm copy: (markStart@0 corner: markEnd@h).  "marker form"
	"find the bottom of the mark"
	w _ mForm width.
	y _ h - 1.
	[y > 0] whileTrue: [
		tallies atAllPut: 0.
		mForm tallyPixelValuesInRect: (0@y extent: w@1) into: tallies.
		(tallies at: bgPix) < w ifTrue: [^ pixCountArray first first + y].
		y _ y - 1].

	^ pixCountArray first first
! !

!FontExtractor methodsFor: 'all' stamp: 'jm 1/13/2006 11:10'!
baselineYForLineCountsOLD: pixCountArray
	"Answer the baseline y from the given array of (<y>, <pixCount>) pairs for a given line."
	"Details: The baseline is detected by scanning up from the bottom to find the first horizontal line with at least half the number of black pixels as the maximum number of black pixels. While this heuristic usually works for alphanumeric fonts, it wouldn't necessarily work for fonts of symbols or icons."

	| maxBlackCount |
	maxBlackCount _ pixCountArray inject: 0 into: [:m :pair | m max: pair last].
	pixCountArray reverseDo: [:pair |
		pair last > (maxBlackCount // 2) ifTrue: [^ pair first]].
! !

!FontExtractor methodsFor: 'all' stamp: 'jm 2/15/2004 16:29'!
computeMetricsFrom: aForm
	"Compute the width of a space character. Also compute the pixel offset from the right edge of a period to the edge of the next character from the given line form (typically the first line of the strike file). These metrics are used to extract the characters from subsequent lines. Finally, record the marker (period) form for use during line scanning."
	"Details: The first line contains four printing characters intermixed with space characters:
		.<space>.<space><space>.<space>x
	The difference in spacing between the first/second and second/third periods gives the width of a space character. The space between the last period and the start of the 'x' is the character start offset."

	| glyphPairs markerPair d1 |
	spaceWidth _ 0.
	glyphPairs _ self glyphStartsAndStopsFrom: aForm.
	glyphPairs size = 4 ifFalse: [self error: 'implementation problem'].
	markerPair _ glyphPairs first.
	markerGlyph _ aForm copy: (markerPair first@0 extent: (markerPair last + 1 - markerPair first)@aForm height).
	d1 _ (glyphPairs at: 2) first - ((glyphPairs at: 1) last + 1).
	basePix _ (glyphPairs at: 3) first - ((glyphPairs at: 2) last + 1).
	spaceWidth _ basePix - d1.
	charOffset _ (glyphPairs at: 4) first - ((glyphPairs at: 3) last + 1).
! !

!FontExtractor methodsFor: 'all' stamp: 'jm 1/13/2006 12:53'!
extractFontFrom: aForm name: aString
	"Answer a StrikeFont for the font extracted from the given Form."
	"FontExtractor new extractFontFrom: (Form fromFileNamed: 'Palatino24.gif')"

	| r glyphs spaceGlyph |
	"reduce depth and trim the strike form"
	strikeForm _ Form extent: aForm extent depth: 1.
	strikeForm copy: strikeForm boundingBox from: 0@0 in: aForm rule: Form over.
	r _ strikeForm rectangleEnclosingPixelsNotOfColor: (strikeForm colorAt: 0@0).
	strikeForm _ strikeForm copy: (r origin extent: r width@(r height + 1)).

	self extractLines.
	self computeMetricsFrom: lineForms first.

	spaceGlyph _ (Form extent: (spaceWidth - 2)@fontHeight depth: 1) fillWhite.
	glyphs _ OrderedCollection new.
	glyphs add: spaceGlyph.
	2 to: lineForms size do: [:i | glyphs addAll: (self glyphsForLine: i)].
	"self inform: ((1 to: lineForms size) collect: [:i | (self glyphsForLine: i) size]) printString."
	glyphs _ self removeDuplicatedMissingGlyphs: glyphs.
	^ StrikeFont new
		initForms: glyphs firstAscii: 32 ascent: fontAscent;
		name: aString
! !

!FontExtractor methodsFor: 'all' stamp: 'jm 2/19/2005 23:58'!
extractLines
	"Set my lineForms to an array of Forms, one for each line of characters in my strikeForm."

	| linePixCounts lineCount ascents descents pixCountsForLine baselineY topY |
	linePixCounts _ self extractPixCountsForLines.
	lineCount _ linePixCounts size.
	ascents _ Array new: lineCount.
	descents _ Array new: lineCount.
	1 to: lineCount do: [:i |
		pixCountsForLine _ linePixCounts at: i.
		baselineY _ self baselineYForLineCounts: pixCountsForLine.
		ascents at: i put: (baselineY - pixCountsForLine first first) + 1.
		descents at: i put: (pixCountsForLine last first - baselineY)].

	fontAscent _ ascents max.
	fontHeight _ ascents max + descents max.
	lineForms _ (1 to: linePixCounts size) collect: [:i |
		baselineY _ (linePixCounts at: i) first first + (ascents at: i).
		topY _ baselineY - fontAscent.
		strikeForm copy: (0@topY extent: strikeForm width@fontHeight)].
! !

!FontExtractor methodsFor: 'all' stamp: 'jm 1/13/2006 22:25'!
extractPixCountsForLines
	"Answer an array line arrays. Each line array is a sequence of (y, pixCount) pairs for one pixel row within the line of characters."
	"Details: Try extracting lines with different inter-line gaps until we get the expected 15 lines."

	| lines |
	2 to: 25 do: [:gap |
		lines _ self extractPixCountsForLinesMinLineSpace: gap.
		lines size = 15 ifTrue: [^ lines]].
	self error: 'Could not extract lines'
! !

!FontExtractor methodsFor: 'all' stamp: 'jm 2/19/2005 22:48'!
extractPixCountsForLinesMinLineSpace: lineGap
	"Answer an array line arrays. Each line array is a sequence of (y, pixCount) pairs for one pixel row within the line of characters. There must be at least lineGap blank pixels rows between lines; we need to tolerate a certain amount of vertical gap because in larger fonts there is often a gap between the tops of accented capital letters and their accent marks."

	| w h tallies lines inRun pixCount thisLine endOfLastLine |
	w _ strikeForm width.
	h _ strikeForm height.
	tallies _ Bitmap new: 2.
	lines _ OrderedCollection new.
	endOfLastLine _ -100.
	inRun _ false.
	0 to: h - 1 do: [:y |
		tallies at: 2 put: 0.
		strikeForm tallyPixelValuesInRect: (0@y extent: w@1) into: tallies.
		pixCount _ tallies at: 2.
		inRun ifFalse: [
			pixCount > 0 ifTrue: [
				(y - endOfLastLine) < lineGap
					ifTrue: [thisLine _ lines removeLast asOrderedCollection]
					ifFalse: [thisLine _ OrderedCollection new].
				inRun _ true]].
		inRun ifTrue: [
				pixCount = 0
					ifTrue: [
						endOfLastLine _ y.
						lines addLast: thisLine asArray.
						inRun _ false]
					ifFalse: [
						thisLine addLast: (Array with: y with: pixCount)]]].

	inRun ifTrue: [self error: 'final line must be all white space'].

	^ lines asArray
! !

!FontExtractor methodsFor: 'all' stamp: 'jm 2/22/2005 09:32'!
glyphAfter: startX in: lineForm
	"Answer a pair containing the starting and ending x positions of the next glyph after the given x offset in the given Form. Answer #missing if the glyph is missing or nil if there are no more marks in the line. Assume startX is the first position after the previous marker."

	| h pair nextMark glyphStart glyphEnd |
	h _ lineForm height.
	pair _ self markAfter: startX in: lineForm.
	pair ifNil: [^ nil].

	nextMark _ lineForm copy: (pair first@0 corner: pair last@h).
	(self isMarker: nextMark) ifTrue: [  "is there enough space for this to be the next marker?"
		(pair first - startX) >= (3 * spaceWidth) ifTrue: [^ #missing]].

	glyphStart _ pair first.
	glyphEnd _ pair last.
	[true] whileTrue: [
		"examine the next mark"
		pair _ self markAfter: glyphEnd + 1 in: lineForm.
		pair ifNil: [^ Array with: glyphStart with: glyphEnd].  "end of line"
		nextMark _ lineForm copy: (pair first@0 corner: pair last@h).
		((self isMarker: nextMark) and:
		 [(pair first - glyphEnd) > spaceWidth])
			ifTrue: [^ Array with: glyphStart with: glyphEnd].  "found next marker"
		glyphEnd _ pair last].  "extend the glyph to include this mark"
! !

!FontExtractor methodsFor: 'all' stamp: 'jm 2/21/2005 21:17'!
glyphStartsAndStopsFrom: lineForm
	"Answer an array of (startX, endX) runs for the glyphs in the given Form."

	| w h tallies runs endOfLastGlyph inRun pixCount thisRun |
	w _ lineForm width.
	h _ lineForm height.
	tallies _ Bitmap new: 2.
	runs _ OrderedCollection new.
	endOfLastGlyph _ -100.
	inRun _ false.
	0 to: w - 1 do: [:x |
		tallies at: 2 put: 0.
		lineForm tallyPixelValuesInRect: (x@0 extent: 1@h) into: tallies.
		pixCount _ tallies at: 2.
		(inRun not and: [pixCount > 0]) ifTrue: [ "start a new run or extend the last run"
			(x - endOfLastGlyph) <= spaceWidth  "some chars, such as double-quote, include a gap of a few pixels"
				ifTrue: [thisRun _ runs removeLast]  "extend the last run"
				ifFalse: [thisRun _ Array with: x with: 0].
			inRun _ true].
		(inRun and: [pixCount = 0]) ifTrue: [  "end the current run"
			thisRun at: 2 put: x - 1.
			endOfLastGlyph _ x - 1.
			runs addLast: thisRun.
			inRun _ false]].

	inRun ifTrue: [self error: 'line must end with white space'].

	^ runs asArray
! !

!FontExtractor methodsFor: 'all' stamp: 'EMP 11/4/2015 15:25'!
glyphsForLine: lineIndex
	"Answer an Array whose elements are the character glyphs for the line with the given index. If a glyph is missing from the font, the entry for that character is the symbol #missing."

	| result lineForm h markerPair glyphPair |
	result _ OrderedCollection new.
	lineForm _ lineForms at: lineIndex.
	h _ lineForm height.

	"read the first marker"
	markerPair _ self markAfter: 0 in: lineForm.

	"at the start of each loop iteration, markerPair contains the start and end of the last marker"
	"the loop terminates when the next markerPair or glyphPair is nil (indicating the end of the line)"
	[true] whileTrue: [
		markerPair ifNil: [^ result asArray].
		"self assert: [self isMarker: (lineForm copy: (markerPair first@0 corner: markerPair last@h))]."
		glyphPair _ self glyphAfter: (markerPair last + 1) in: lineForm.
		glyphPair ifNil: [^ result asArray].
		#missing = glyphPair
			ifTrue: [
				result addLast: #missing.
				markerPair _ self markAfter: (markerPair last + 1) in: lineForm]
			ifFalse: [
				result addLast: (lineForm copy: (glyphPair first@0 corner: glyphPair last@h)).
				markerPair _ self markAfter: glyphPair last + 1 in: lineForm]].

! !

!FontExtractor methodsFor: 'all' stamp: 'jm 2/18/2005 21:50'!
isMarker: aForm

	aForm width = markerGlyph width ifFalse: [^ false].
	^ aForm bits = markerGlyph bits
! !

!FontExtractor methodsFor: 'all' stamp: 'jm 2/21/2005 23:54'!
markAfter: startX in: lineForm
	"Answer a pair containing the starting and ending x positions of the next mark after the given x offset in the given Form. Answer nil if there are no more marks. A mark is a contiguous horizontal region of the given Form containing non-background-color pixels."
	"Note: The top-left pixel of the given form is assumed to be of the background color."

	| w h tallies bgPix markStart x |
	w _ lineForm width.
	h _ lineForm height.
	startX > w ifTrue: [^ nil].  "past end"

	self assert: [lineForm depth <= 16].
	tallies _ Bitmap new: (1 bitShift: lineForm depth).
	bgPix _ (lineForm pixelValueAt: 0@0) + 1.  "pixel value of the background color"

	"find the start of the mark"
	markStart _ nil.
	x _ startX.
	[markStart isNil and: [x < w]] whileTrue: [
		tallies atAllPut: 0.
		lineForm tallyPixelValuesInRect: (x@0 extent: 1@h) into: tallies.
		(tallies at: bgPix) < h ifTrue: [markStart _ x].
		x _ x + 1].

	markStart ifNil: [^ nil].  "no more marks"

	"find the end of the mark"
	[x < w] whileTrue: [
		tallies atAllPut: 0.
		lineForm tallyPixelValuesInRect: (x@0 extent: 1@h) into: tallies.
		(tallies at: bgPix) = h ifTrue: [^ Array with: markStart with: x].
		x _ x + 1].

	^ Array with: markStart with: w  "mark went to end of line"
! !

!FontExtractor methodsFor: 'all' stamp: 'jm 1/13/2006 14:18'!
removeDuplicatedMissingGlyphs: originalGlyphs
	"Answer an array of glyphs that avoids duplicating the 'missing character' glyph, often a question mark."
	"Note: Assume that if the last glyph is not #missing and appears many times in the font then it's the 'missing character' glyph and should be replaced everywhere after it's first occurence with #missing."

	| missingGlyph firstI thisGlyph newGlyphs count |
	missingGlyph _ originalGlyphs last.
	(missingGlyph isKindOf: Form) ifFalse: [^ originalGlyphs].
	firstI _ (1 to: originalGlyphs size) detect: [:i |
		thisGlyph _ originalGlyphs at: i.
		(thisGlyph isKindOf: Form) and:
		 [(missingGlyph extent = thisGlyph extent) and:
		 [missingGlyph bits = thisGlyph bits]]].
	firstI = originalGlyphs size ifTrue: [^ originalGlyphs].

	newGlyphs _ originalGlyphs asArray copy.
	count _ 0.
	firstI + 1 to: originalGlyphs size do: [:i |
		thisGlyph _ originalGlyphs at: i.
		((thisGlyph isKindOf: Form) and:
		 [(missingGlyph extent = thisGlyph extent) and:
		 [missingGlyph bits = thisGlyph bits]]) ifTrue: [
			newGlyphs at: i put: #missing.
			count _ count + 1]].
	Transcript show: 'Replaced ', count printString, ' missing glyphs'; cr.
	^ newGlyphs
! !

!FontExtractor methodsFor: 'all' stamp: 'jm 2/22/2005 08:48'!
show: aForm
	"Display the given form magnified. Used for debugging."

	| mag |
	(aForm isKindOf: Form) ifFalse: [Display fill: (0@0 extent: 20) fillColor: Color blue. ^ self].
	mag _ 2.
	Display fillWhite: (0@0 extent: (aForm extent * mag) + 15).
	(aForm magnifyBy: mag) displayAt: 5@5.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

FontExtractor class
	instanceVariableNames: ''!

!FontExtractor class methodsFor: 'utilities' stamp: 'jm 1/13/2006 12:52'!
extractFontFromFileNamed: fileName
	"Extract a font from an image file showing all its letters. (In the old days, printers called this a 'strike' of the font."

	| f |
	f _ Form fromFileNamed: fileName.
	^ self new
		extractFontFrom: f
		name: (FileDirectory baseNameFor: (FileDirectory localNameFor: fileName)).
! !

!FontExtractor class methodsFor: 'utilities' stamp: 'jm 1/13/2006 19:25'!
writeStrikeFile
	"Use this method to write a text file that will be used to make a font image for processing. See my class comment for what to do with this file."
	"FontExtractor writeStrikeFile"

	| f |
	f _ (FileStream newFileNamed: 'strike.txt') binary.
	f nextPutAll: '  . .  . x', String crlf, String crlf.
	33 to: 255 do: [:ch |
		(ch \\ 16) = 0 ifTrue: [f nextPutAll: '  .', String crlf, String crlf].
		f nextPutAll: '   . '.
		f nextPut: ch].
	f nextPutAll: '  . ', String crlf, String crlf.
	f close.
! !
