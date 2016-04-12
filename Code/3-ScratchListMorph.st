BorderedMorph subclass: #ScratchListMorph
	instanceVariableNames: 'titleMorph addItemMorph countMorph resizeMorph scrollPane emptyMorph numberMorphs cellMorphs listName target resizeOffset focusIndex lastActivityIndex highlightActive lastActivityError listLayoutNeeded '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Watchers'!
!ScratchListMorph commentStamp: 'jm 5/14/2008 10:59' prior: 0!
A scrollable, ordered list of editable strings.

The following are top-level submorphs:
	titleMorph
	addItemMorph
	resizeMorph
	countMorph
	scrollPane

These morphs appear inside the scroll pane:
	emptyMorph -- added/removed to indicate when list is empty
	numberMorphs -- cell numbers (indices)
	cellMorphs -- list of cells

Each cell consists of a frame containing a line-wrapping string morph.

!


!ScratchListMorph methodsFor: 'initialization' stamp: 'jm 6/28/2008 12:37'!
addScrollPane

	scrollPane _ ScrollFrameMorph2 new
		vBarInset: 16;
		hBarInset: 18;
		color: Color transparent;
		growthFraction: 0.0;
		scrollbarStartInset: 2 endInset: -2;
		contents: (Morph new color: Color transparent).

	self addMorph: scrollPane.
! !

!ScratchListMorph methodsFor: 'initialization' stamp: 'jm 7/11/2008 14:58'!
addTitleAndControls

	titleMorph _ StringMorph new contents: 'myList'; font: (ScratchFrameMorph getFont: #Label).
	addItemMorph _ (ImageMorph new form: (ScratchFrameMorph skinAt: #addItem)).
	resizeMorph _ ScratchResizeMorph ofType: #corner.
	countMorph _ StringMorph new
		contents: '0';
		font: (ScratchFrameMorph getFont: #XYReadout);
		color: (Color gray: 0.15).

	"emptyMorph is added to contents pane when list is empty"
	emptyMorph _ StringMorph new
		contents: '(empty)' localized;
		font: (ScratchFrameMorph getFont: #CommentBlock).

	self addMorph: titleMorph.
	self addMorph: addItemMorph.
	self addMorph: resizeMorph.
	self addMorph: countMorph.
! !

!ScratchListMorph methodsFor: 'initialization' stamp: 'jm 5/31/2008 11:56'!
initialize

	super initialize.
	self
		color: (Color r: (193/255) g: (196/255) b: (199/255));
		borderWidth: 2;
		borderColor: self normalBorderColor;
		useRoundedCorners.

	cellMorphs _ OrderedCollection new: 1000.
	numberMorphs _ #().
	listLayoutNeeded _ true.
	focusIndex _ 0.
	lastActivityError _ false.
	highlightActive _ false.

	self addTitleAndControls.
	self addScrollPane.

	self extent: 65@115.
! !

!ScratchListMorph methodsFor: 'initialization' stamp: 'jm 7/11/2008 15:01'!
listName: asString target: aScriptableSpriteMorph

	listName _ asString asUTF8.
	target _ aScriptableSpriteMorph.
	self updateTitle.
! !


!ScratchListMorph methodsFor: 'accessing' stamp: 'jm 5/14/2008 18:13'!
focusCell: cellMorph

	focusIndex _ cellMorphs indexOf: cellMorph ifAbsent: [1].
	World activeHand newKeyboardFocus: cellMorph firstSubmorph.
! !

!ScratchListMorph methodsFor: 'accessing' stamp: 'ee 5/6/2008 16:04'!
focusIndex

	^ focusIndex
! !

!ScratchListMorph methodsFor: 'accessing' stamp: 'jm 5/15/2008 14:21'!
focusIndex: anInteger

	| cell |
	focusIndex _ anInteger.
	focusIndex > cellMorphs size ifTrue: [focusIndex _ 1].
	focusIndex < 1 ifTrue: [focusIndex _ cellMorphs size].

	cellMorphs size > 0 ifTrue: [
		cell _ cellMorphs at: focusIndex.
		World activeHand newKeyboardFocus: cell firstSubmorph.
		scrollPane scrollSubmorphIntoView: cell].
! !

!ScratchListMorph methodsFor: 'accessing' stamp: 'jm 5/14/2008 18:22'!
indexOfCell: cellMorph

	^ cellMorphs indexOf: cellMorph ifAbsent: [-1]
! !

!ScratchListMorph methodsFor: 'accessing' stamp: 'jm 6/4/2008 19:44'!
listContents

	^ cellMorphs collect: [:m | m firstSubmorph contents].
! !

!ScratchListMorph methodsFor: 'accessing' stamp: 'jm 6/4/2008 19:07'!
listName

	^ listName
! !

!ScratchListMorph methodsFor: 'accessing' stamp: 'jens 9/22/2008 11:23'!
target

	^ target
! !


!ScratchListMorph methodsFor: 'dropping/grabbing' stamp: 'jm 5/15/2008 14:32'!
delete

	super delete.
	ScratchFrameMorph allInstancesDo: [:frame | frame deletingWatcher].
! !

!ScratchListMorph methodsFor: 'dropping/grabbing' stamp: 'jm 6/4/2008 18:53'!
justDroppedInto: aMorph event: evt

	(aMorph isKindOf: ScratchStageMorph) ifTrue: [
		super justDroppedInto: aMorph event: evt.
		self world ifNotNil: [self world startSteppingSubmorphsOf: self].
		^ self].

	"delete me if dropped anywhere but the stage"
	self position:  evt hand formerPosition.
	^ self delete
! !


!ScratchListMorph methodsFor: 'event handling' stamp: 'jm 6/4/2008 19:20'!
handlesMouseDown: evt

	^ self world notNil! !

!ScratchListMorph methodsFor: 'event handling' stamp: 'jm 8/13/2008 20:01'!
mouseDown: evt
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	| p |
	resizeOffset _ nil.
	evt hand toolType = 'CutTool' ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		^ self delete].

	World activeHand showTemporaryCursor: nil.
	evt hand newKeyboardFocus: nil.
	p _ evt cursorPoint.

	((addItemMorph bounds expandBy: 4) containsPoint: p) ifTrue: [
		^ self insertLine: '' at: (self lineCount + 1)].

	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[
			((resizeMorph bounds expandBy: 4) containsPoint: p)
				ifFalse: [evt hand grabMorph: self]
				ifTrue: [resizeOffset _ self bottomRight - p]].
! !

!ScratchListMorph methodsFor: 'event handling' stamp: 'jm 5/15/2008 14:27'!
mouseMove: evt

	resizeOffset ifNotNil: [
		self extent: (evt cursorPoint - self topLeft) + resizeOffset].
! !

!ScratchListMorph methodsFor: 'event handling' stamp: 'ee 7/31/2008 12:56'!
rightButtonMenu

	| menu |
	menu _ CustomMenu new.
	menu add: 'export' action: #exportList.
	menu add: 'import' action: #importList.
	menu addLine.
	menu add: 'hide' action: #delete.

	menu localize.
	menu labels at: 2 put: 
		((menu labels at: 2) copyFrom: 1 to: (menu labels at: 2) size - 1), ScratchTranslator ellipsesSuffix.
	menu invokeOn: self.
! !


!ScratchListMorph methodsFor: 'geometry' stamp: 'jm 5/16/2008 09:12'!
extent: aPoint

	super extent: (aPoint max: 95@115).
	self fixLayout.
! !

!ScratchListMorph methodsFor: 'geometry' stamp: 'jm 8/13/2008 18:50'!
fixLayout

	titleMorph fitContents.
	(titleMorph width > (self width - 12)) ifTrue: [
		self width: titleMorph width + 12].

	titleMorph position: (self center x - (titleMorph width // 2)) @ (self top + 5).

	countMorph fitContents.

	scrollPane
		position: (self left + 2) @ (titleMorph bottom + 3);
		extent: (self width - 4) @ (self bottom - titleMorph bottom - countMorph height - 12).

	addItemMorph position: (self left + 3) @ (self bottom - addItemMorph height - 3).
	resizeMorph position: (self bottomRight - resizeMorph extent).

	self updateCountMorph.
	countMorph bottom: self bottom - 3.

	self updateContents.
! !

!ScratchListMorph methodsFor: 'geometry' stamp: 'ee 5/14/2009 17:33'!
fixLayoutForNewLanguage
	"This method updates the height and word-wrapping of cells after a language or font change."

	| cellContents oldH |
	cellMorphs size = 0 ifTrue: [self fixLayout. ^ self showEmpty].
	cellContents _ cellMorphs first firstSubmorph.
	oldH _ cellContents height.
	cellContents font: cellContents font.
	cellContents height = oldH ifTrue: [self fixLayout. ^ self].  "no size change"

	scrollPane vScrollRelative: 0.
	cellMorphs do: [:c | c firstSubmorph font: c firstSubmorph font].
	self fixLayout.
! !


!ScratchListMorph methodsFor: 'stepping' stamp: 'jm 6/4/2008 19:09'!
step

	self updateTitle.
	self updateBorder.
	self updateCountMorph.
	self updateIndexHighlight.
	listLayoutNeeded ifTrue: [self updateContents].
! !

!ScratchListMorph methodsFor: 'stepping' stamp: 'jm 5/31/2008 11:46'!
stepTime

	^ 200
! !

!ScratchListMorph methodsFor: 'stepping' stamp: 'jm 5/31/2008 13:56'!
updateBorder

	lastActivityError
		ifTrue: [self borderColor: Color red]
		ifFalse: [self borderColor: self normalBorderColor].
	lastActivityError _ false.
! !

!ScratchListMorph methodsFor: 'stepping' stamp: 'ee 7/6/2008 20:39'!
updateCountMorph

	countMorph contents: 'length' localized, ScratchTranslator colonSuffix, ' ', self lineCount printString.
	countMorph left: self left + ((self width - countMorph width) // 2) + 3.
! !

!ScratchListMorph methodsFor: 'stepping' stamp: 'jm 5/31/2008 14:43'!
updateIndexHighlight
	"Update the highlighted index."

	highlightActive ifTrue: [
		numberMorphs do: [:m | m color: self indexColor].
		highlightActive _ false].
! !

!ScratchListMorph methodsFor: 'stepping' stamp: 'EMP 2/24/2016 19:55'!
updateTitle
	"Update my title if I am owned by a sprite and the sprite name changes."

	| s |
	listName ifNil: [^ self].

	(target isKindOf: ScratchSpriteMorph)
		ifTrue: [s _ target objName, ': ', listName]
		ifFalse: [s _ listName].

	titleMorph contents = s ifFalse: [
		titleMorph contents: s.
		self fixLayout].
! !


!ScratchListMorph methodsFor: 'list ops' stamp: 'EMP 2/25/2016 16:48'!
addLettersOf: anObject
	anObject asUTF32 do: [:ch |
		cellMorphs addLast: (self createCell: (UTF32 with: ch) asUTF8)].

	self noteChangeAtIndex: cellMorphs size.
! !

!ScratchListMorph methodsFor: 'list ops' stamp: 'jm 5/14/2008 14:19'!
clear

	cellMorphs _ cellMorphs species new: 1000.
	self updateContents.
! !

!ScratchListMorph methodsFor: 'list ops' stamp: 'jm 4/1/2009 10:24'!
concatenatedLines

	| isSingleLetters s |
	isSingleLetters _ true.
	cellMorphs do: [:m |
		isSingleLetters ifTrue: [
			m firstSubmorph contents asUTF32 size <= 1 ifFalse: [isSingleLetters _ false]]].

	s _ WriteStream on: (UTF8 new: 1000).
	isSingleLetters
		ifTrue: [
			cellMorphs do: [:m | s nextPutAll: m firstSubmorph contents]]
		ifFalse: [
			cellMorphs do: [:m | s nextPutAll: m firstSubmorph contents; space].
			s position > 0 ifTrue: [s skip: -1]].

	^ s contents
! !

!ScratchListMorph methodsFor: 'list ops' stamp: 'jm 2/3/2009 14:20'!
contains: aStringOrNumber

	| s |
	s _ aStringOrNumber asString asUTF8.
	cellMorphs do: [:m |
		s = m firstSubmorph contents ifTrue: [^ true]].

	^ false
! !

!ScratchListMorph methodsFor: 'list ops' stamp: 'ee 5/14/2009 13:59'!
createCell: aString

	| readout cell font numberRight |
	font _ ScratchFrameMorph getFont: #Watcher.
	readout _ ListMultilineStringMorph new
		borderWidth: 0;
		color: Color transparent;
		textColor: Color white;
		growWithText: true;
		contents: aString font: font.
	readout height: ((ScratchTranslator stringExtent: 'A' font: font) y) + 6.
	ScratchTranslator isRTL
		ifTrue: [numberRight _ self right - 5]
		ifFalse: [numberRight _ self left + self largestIndexWidth + 6].
	ScratchTranslator isRTL
		ifTrue: [readout width: self right - self left - self largestIndexWidth - 33]
		ifFalse: [readout width: self right - numberRight - 25].

	cell _ WatcherReadoutFrameMorph new
		color: ScriptableScratchMorph listBlockColor;
		extent: readout extent + 3;
		addMorphBack: readout.

	cell position: scrollPane contents bottomLeft.
	scrollPane contents addMorph: cell.
	^ cell
! !

!ScratchListMorph methodsFor: 'list ops' stamp: 'jm 5/31/2008 15:31'!
deleteLineAt: aNumber

	| index |
	index _ aNumber asInteger.
	(index > 0 and: [index <= cellMorphs size]) ifFalse: [
		lastActivityError _ true.
		^ self].

	index = numberMorphs size ifTrue: [
		numberMorphs last delete.
		numberMorphs _ numberMorphs copyFrom: 1 to: numberMorphs size - 1].

	(cellMorphs removeAt: index) delete.
	self noteChangeAtIndex: index.
! !

!ScratchListMorph methodsFor: 'list ops' stamp: 'jm 5/31/2008 14:07'!
insertLine: aString at: aNumber

	| index newCell |
	index _ aNumber asInteger.
	(index > 0 and: [index <= (cellMorphs size + 1)]) ifFalse: [
		lastActivityError _ true.
		^ self].

	newCell _ self createCell: aString.
	index = 1
		ifTrue: [cellMorphs addFirst: newCell]
		ifFalse: [
			index > cellMorphs size
				ifTrue: [cellMorphs addLast: newCell]
				ifFalse: [cellMorphs add: newCell afterIndex: index - 1]].

	self noteChangeAtIndex: index.
	^ newCell
! !

!ScratchListMorph methodsFor: 'list ops' stamp: 'jm 7/9/2008 17:10'!
lineAt: aNumber

	| index |
	index _ aNumber asInteger.
	(index > 0 and: [index <= cellMorphs size])
		ifTrue: [
			self noteChangeAtIndex: index.
			^ (cellMorphs at: index) firstSubmorph contents asUTF8]
		ifFalse: [
			lastActivityError _ true.
			^ ''].
! !

!ScratchListMorph methodsFor: 'list ops' stamp: 'jm 5/13/2008 16:48'!
lineCount

	^ cellMorphs size
! !

!ScratchListMorph methodsFor: 'list ops' stamp: 'jm 5/31/2008 14:11'!
setLineAt: aNumber to: newContents

	| index |
	index _ aNumber asInteger.
	(index > 0 and: [index <= cellMorphs size]) ifFalse: [
		lastActivityError _ true.
		^ self].

	(cellMorphs at: index) firstSubmorph contents: newContents asString.
	self noteChangeAtIndex: index.

! !


!ScratchListMorph methodsFor: 'import/export' stamp: 'jm 5/21/2009 10:25'!
exportList

	| fName f |
	fName _ titleMorph contents.
	fName size <= 1 ifTrue: [fName _ 'newList'].
	fName _ fName, '.txt'.

	fName _ ScratchFileChooserDialog
		chooseNewFileDefault: fName
		title: 'File Name?'
		type: #list.
	fName = #cancelled ifTrue: [^ self].

	f _ StandardFileStream newScratchFileNamed: fName.
	f ifNil: [^ self].
	cellMorphs do: [:m | f nextPutAll: m firstSubmorph contents; crlf].
	f close.
! !

!ScratchListMorph methodsFor: 'import/export' stamp: 'jm 5/21/2009 10:21'!
importList

	| result |
	result _ ScratchFileChooserDialog
		chooseExistingFileType: #list
		extensions: #(txt)
		title: 'Import List'.

	#cancelled = result ifTrue: [^ self].
	self importListFromFileNamed: result.
! !

!ScratchListMorph methodsFor: 'import/export' stamp: 'jm 6/25/2009 17:13'!
importListFromFileNamed: aFilename

	| f |
	f _ FileStream readOnlyFileNamedOrNil: (FileDirectory default fullNameFor: aFilename).
	f ifNil: [
		DialogBoxMorph inform: 'File not found' withDetails: aFilename.
		^ nil].

	"Assume the file was encoded as UTF8"
	[	self newContents:
			(f contentsOfEntireFile lines collect: [:s | UTF8 withAll: s]).
	] ifError: [self beep].
! !


!ScratchListMorph methodsFor: 'object i/o' stamp: 'jm 6/17/2008 21:39'!
fieldsVersion

	^ 2
! !

!ScratchListMorph methodsFor: 'object i/o' stamp: 'jm 6/17/2008 21:42'!
initFieldsFrom: anObjStream version: classVersion
	"Note: To simplify my representation in the project file, my submorphs are removed before saving and restored when I am read in from an object file."

	| strings |
	super initFieldsFrom: anObjStream version: classVersion.

	listName _ anObjStream nextField.
	strings _ anObjStream nextField.
	classVersion > 1 ifTrue: [target _ anObjStream nextField].

	self removeAllMorphs.
	self addTitleAndControls; addScrollPane.
	titleMorph contents: listName.
	self newContents: strings.
	self fixLayout.
	self updateContents.
! !

!ScratchListMorph methodsFor: 'object i/o' stamp: 'jm 6/17/2008 21:46'!
storeFieldsOn: anObjStream
	"Note: To simplify my representation in the project file, my submorphs are removed before saving and restored when I am read in from an object file."

	| strings |
	strings _ cellMorphs asArray collect: [:m | m firstSubmorph contents].
	self removeAllMorphs.
	numberMorphs _ #().

	super storeFieldsOn: anObjStream.
	anObjStream putField: listName.
	anObjStream putField: strings.
	anObjStream putField: target.

	self addTitleAndControls; addScrollPane.
	titleMorph contents: listName.
	self newContents: strings.
	self fixLayout.

! !


!ScratchListMorph methodsFor: 'private' stamp: 'jm 5/31/2008 13:57'!
indexColor

	^ Color gray: 0.32
! !

!ScratchListMorph methodsFor: 'private' stamp: 'jm 5/14/2008 11:05'!
largestIndexWidth
	"Estimate the width needed for the largest cell number."
	"Note: we estimate using the width of the the digit '0' times the number of digits needed."

	| digitWidth digitCount n |
	digitWidth _ (ScratchFrameMorph getFont: #Label) widthOf: $0.
	n _ cellMorphs size + 1 max: 100.
	digitCount _ n log ceiling.
	^ digitCount * digitWidth

! !

!ScratchListMorph methodsFor: 'private' stamp: 'jm 6/4/2008 17:36'!
newContents: listOfStrings
	"Set my contents to the given collection of strings."

	scrollPane contents
		removeAllMorphs;
		top: scrollPane top;
		extent: scrollPane extent.

	cellMorphs _ cellMorphs species new: ((2 * listOfStrings size) max: 1000).
	numberMorphs _ #().

	listOfStrings do: [:s | cellMorphs addLast: (self createCell: s)].
	self updateContents.
! !

!ScratchListMorph methodsFor: 'private' stamp: 'jm 5/31/2008 11:04'!
normalBorderColor

	^ Color r: (148/255) g: (145/255) b: (145/255)
! !

!ScratchListMorph methodsFor: 'private' stamp: 'ee 8/7/2008 20:11'!
noteChangeAtIndex: index

	lastActivityIndex _ index.	

	cellMorphs size < 20
		ifTrue: [
			self updateContents.
			(index between: 1 and: numberMorphs size) ifTrue: [
				(numberMorphs at: index) color: (Color white).
				highlightActive _ true].
			lastActivityIndex _ nil]
		ifFalse: [
			listLayoutNeeded _ true].
! !

!ScratchListMorph methodsFor: 'private' stamp: 'jm 5/31/2008 15:38'!
scrollActiveCellIntoView

	| cell page newTop |
	lastActivityIndex _ lastActivityIndex within: 1 and: cellMorphs size.
	cell _ cellMorphs at: lastActivityIndex.
	page _ scrollPane contents.
	(scrollPane bounds containsRect: cell bounds) ifFalse: [
		newTop _ (scrollPane bounds center y) - (cell top - page top).
		newTop _ newTop max: (scrollPane bottom - (cellMorphs last bottom - page top) - 3).
		newTop _ newTop min: scrollPane top.
		page top: newTop].
! !

!ScratchListMorph methodsFor: 'private' stamp: 'jm 8/13/2008 15:33'!
showEmpty
	"Show the empty label."

	| page |
	scrollPane hScrollRelative: 0; vScrollRelative: 0.
	page _ scrollPane contents
		removeAllMorphs;
		extent: scrollPane extent.

	numberMorphs size > 0 ifTrue: [numberMorphs _ #()].

	emptyMorph
		contents: '(empty)' localized;
		position: (page center - (emptyMorph extent // 2)).
	page addMorph: emptyMorph.

	scrollPane updateScrollbars.
	listLayoutNeeded _ false.

! !

!ScratchListMorph methodsFor: 'private' stamp: 'ee 8/7/2008 20:11'!
updateContents
	"Update and layout my contents."

	| page numberRight cellWidth inset x y |
	cellMorphs size = 0 ifTrue: [^ self showEmpty].
	emptyMorph delete.

	page _ scrollPane contents.
	page changed.

	ScratchTranslator isRTL
		ifTrue: [numberRight _ self right - 5]
		ifFalse: [numberRight _ self left + self largestIndexWidth + 6].

	"word-wrap cell contents and fix cell extents, if needed"
	ScratchTranslator isRTL
		ifTrue: [cellWidth _ self right - self left - self largestIndexWidth - 33]
		ifFalse: [cellWidth _ self right - numberRight - 25].
	inset _ 3.
	cellMorphs do: [:cell |
		((cell width ~= cellWidth) or: [cell extent ~= (cell firstSubmorph extent + inset)]) ifTrue: [
		cell firstSubmorph width: cellWidth - inset.
		cell extent: cell firstSubmorph extent + inset]].

	"position cells"
	ScratchTranslator isRTL
		ifTrue: [x _ self left + 26]
		ifFalse: [x _ numberRight + 4].
	y _ page top + 3.
	cellMorphs do: [:cell |
		cell position: x@y.
		y _ y + cell height - 1].

	self updateIndices: numberRight.

	page extent: (self width - (2 * borderWidth)) @ (y + 3).

	lastActivityIndex ifNotNil: [
 		(lastActivityIndex between: 1 and: cellMorphs size) ifTrue: [
			(numberMorphs at: lastActivityIndex) color: (Color white).
			highlightActive _ true].
		self scrollActiveCellIntoView.
		lastActivityIndex _ nil].
	scrollPane updateScrollbars.
	scrollPane updateScrollbars.

	listLayoutNeeded _ false.
! !

!ScratchListMorph methodsFor: 'private' stamp: 'jm 5/31/2008 13:57'!
updateIndices: rightX

	| s newNumbers page num cell |
	numberMorphs size > cellMorphs size ifTrue: [
		cellMorphs size + 1 to: numberMorphs size do: [:i | (numberMorphs at: i) delete].
		numberMorphs _ numberMorphs copyFrom: 1 to: cellMorphs size].

	newNumbers _ #().
	numberMorphs size < cellMorphs size ifTrue: [
		page _ scrollPane contents.
		s _ StringMorph new
			color: self indexColor;
			font: (ScratchFrameMorph getFont: #Label).
		newNumbers _ (numberMorphs size + 1 to: cellMorphs size)
			collect: [:i | s fullCopy contents: i printString].
		newNumbers do: [:m | page addMorph: m].
		numberMorphs _ numberMorphs, newNumbers].

	1 to: cellMorphs size do: [:i |
		num _ numberMorphs at: i.
		cell _ cellMorphs at: i.
		num position: (rightX - num width) @ (cell top + ((cell height - num height) // 2))].

! !
