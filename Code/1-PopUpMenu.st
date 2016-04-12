Object subclass: #PopUpMenu
	instanceVariableNames: 'labelString font lineArray frame form marker selection color target '
	classVariableNames: 'MenuStyle '
	poolDictionaries: ''
	category: 'Tools-Menus'!
!PopUpMenu commentStamp: '<historical>' prior: 0!
I represent a list of items. My instances are presented on the display screen in a rectangular area. The user points to an item, pressing a mouse button; the item is highlighted. When the button is released, the highlighted item indicates the selection.!


!PopUpMenu methodsFor: 'accessing' stamp: 'sma 5/28/2000 11:44'!
center
	"Answer the point at the center of the receiver's rectangular area."

	^ frame center! !

!PopUpMenu methodsFor: 'accessing' stamp: 'EMP 10/11/2015 20:22'!
color
	^ color ifNil: [color _ Color white].! !

!PopUpMenu methodsFor: 'accessing' stamp: 'EMP 10/11/2015 20:23'!
color: aColor
	color _ aColor.! !

!PopUpMenu methodsFor: 'accessing' stamp: 'ee 8/10/2008 21:52'!
frameHeight
	"Designed to avoid the entire frame computation (includes MVC form),
	since the menu may well end up being displayed in Morphic anyway."
	| nItems |
	frame ifNotNil: [^ frame height].
	nItems _ 1 + (labelString occurrencesOf: Character cr).
	^ (nItems * (ScratchTranslator stringExtent: 'Language' localized font: MenuStyle defaultFont) y) + 4 "border width"! !

!PopUpMenu methodsFor: 'accessing' stamp: 'jens 3/26/2009 18:02'!
icons
	^Array empty! !

!PopUpMenu methodsFor: 'accessing' stamp: 'EMP 10/11/2015 20:23'!
initialize
	super initialize.
	color _ Color white.
	target _ nil.! !

!PopUpMenu methodsFor: 'accessing' stamp: 'jens 3/26/2009 18:31'!
isHorizontal
	^false! !

!PopUpMenu methodsFor: 'accessing' stamp: 'sma 5/28/2000 14:55'!
labelString
	^ labelString! !

!PopUpMenu methodsFor: 'accessing' stamp: 'sma 5/28/2000 14:55'!
lineArray
	^ lineArray! !

!PopUpMenu methodsFor: 'accessing' stamp: 'sma 5/28/2000 12:32'!
nItems
	^ (labelString occurrencesOf: Character cr) + 1! !

!PopUpMenu methodsFor: 'accessing' stamp: 'EMP 12/2/2015 14:55'!
startUpWithCaption: captionOrNil at: location
	"Display the menu, with caption if supplied. Wait for the mouse button to go down,
	then track the selection as long as the button is pressed. When the button is released, 
	answer the index of the current selection, or zero if the mouse is not released over 
	any menu item. Location specifies the desired topLeft of the menu body rectangle."

	| maxHeight menuMorph loc |
	maxHeight _ Display height*3//4.
	self frameHeight > maxHeight ifTrue:
		[^ self
			startUpSegmented: maxHeight
			withCaption: captionOrNil
			at: location].

	Smalltalk isMorphic
		ifTrue:
			[selection _ Cursor normal showWhile:
				[menuMorph _ (MVCMenuMorph from: self title: captionOrNil) color: (self color); labelColor: (self color luminance > 0.6
		ifTrue: [Color black]
		ifFalse: [Color white]).
			((self target isKindOf: ArgMorph) | (self target isKindOf: BlockMorph)) ifTrue: [menuMorph useSquareCorners; borderWidth: 0].
		loc _ location.
		self isHorizontal & ScratchTranslator isRTL ifTrue: [
			loc _ location - (menuMorph width @ 0) ].
		menuMorph invokeAt: loc in: World].
			^ selection].

	frame ifNil: [self computeForm].
	Cursor normal showWhile:
		[self
			displayAt: location
			withCaption: captionOrNil
			during: [self controlActivity]].
	^ selection! !

!PopUpMenu methodsFor: 'accessing' stamp: 'EMP 10/11/2015 20:04'!
target
	^ target! !


!PopUpMenu methodsFor: 'basic control sequence' stamp: 'sma 6/1/2000 13:04'!
controlActivity
	"Do whatever a menu must do - now with keyboard support."

	| didNotMove downPos |
	didNotMove _ true.
	Sensor anyButtonPressed
		ifFalse:
			[didNotMove _ false.
			Sensor waitButtonOrKeyboard]. 
	
	Sensor keyboardPressed ifFalse: [self manageMarker].
	(didNotMove and: [selection = 0])
		ifTrue:
			[downPos _ Sensor cursorPoint.
			[didNotMove and: [Sensor anyButtonPressed]]
				whileTrue:
					[(downPos dist: Sensor cursorPoint) < 2 ifFalse: [didNotMove _ false]].
			didNotMove ifTrue: [Sensor waitButtonOrKeyboard]].

	[Sensor keyboardPressed] whileTrue:
		[self readKeyboard ifTrue: [^ self].
		Sensor waitButtonOrKeyboard].

	[Sensor anyButtonPressed] whileTrue: [self manageMarker]! !

!PopUpMenu methodsFor: 'basic control sequence' stamp: 'sma 6/1/2000 10:55'!
readKeyboard
	"Keyboard support for menus. ESC will abort the menu, Space or CR
	will select an item. Cursor up and cursor down will change the
	selection. Any other key will either select an item whose label starts
	with that character or select the next matching label.
	Answer true if the menu should be closed and false otherwise."

	| ch labels occurences |
	ch _ Sensor keyboard asciiValue.
	(ch = 13 or: [ch = 32]) ifTrue: [^ true].
	ch = 27 ifTrue: [self setSelection: 0. ^ true].
	ch = 30
		ifTrue:
			[self setSelection: (selection <= 1
				ifTrue: [self nItems]
				ifFalse: [selection - 1])].
	ch = 31 ifTrue: [self setSelection: selection \\ self nItems + 1].
	ch _ ch asCharacter asLowercase.
	labels _ labelString findTokens: Character cr asString.
	occurences _ 0.
	1 + selection to: selection + labels size do:
		[:index |
		| i | i _ index - 1 \\ labels size + 1.
		(labels at: i) withBlanksTrimmed first asLowercase = ch
			ifTrue: [(occurences _ occurences + 1) = 1 ifTrue: [self setSelection: i]]].
	^ occurences = 1! !

!PopUpMenu methodsFor: 'basic control sequence'!
startUp
	"Display and make a selection from the receiver as long as the button 
	is pressed. Answer the current selection."
	
	^ self startUpWithCaption: nil! !

!PopUpMenu methodsFor: 'basic control sequence' stamp: 'sma 4/30/2000 10:04'!
startUpCenteredWithCaption: captionOrNil
	"Differs from startUpWithCaption: by appearing with cursor in the menu,
	and thus ready to act on mouseUp, without requiring user tweak to confirm"

	| cursorPoint |
	cursorPoint _ Smalltalk isMorphic 
			ifTrue: [World cursorPoint]
			ifFalse: [Sensor cursorPoint].
	^ self startUpWithCaption: captionOrNil at: cursorPoint - (20@0)! !

!PopUpMenu methodsFor: 'basic control sequence' stamp: 'jm 4/25/2008 16:01'!
startUpSegmented: segmentHeight withCaption: captionOrNil at: location
	"This menu is too big to fit comfortably on the screen. Break it up into smaller chunks, and manage the relative indices. Inspired by a special-case solution by Reinier van Loon."
	"(PopUpMenu labels: (String streamContents: [:s | 1 to: 100 do: [:i | s print: i; cr]. s skip: -1])
		lines: (5 to: 100 by: 5)) startUpWithCaption: 'Give it a whirl...'"

	| nLines nLinesPer allLabels from to subset subLines index |
	frame ifNil: [self computeForm].
	allLabels _ labelString findTokens: String cr.
	nLines _ allLabels size.
	lineArray ifNil: [lineArray _ Array new].
	nLinesPer _ segmentHeight // marker height - 3.
	from _ 1.
	[true] whileTrue: [
		to _ (from + nLinesPer) min: nLines.
		subset _ allLabels copyFrom: from to: to.
		subset addLast: ('more' localized, ScratchTranslator ellipsesSuffix).
		subLines _ lineArray select: [:n | n >= from] thenCollect: [:n | n - (from-1)].
		subLines _ subLines, (Array with: subset size - 1).
		index _ (PopUpMenu labels: subset asStringWithCr lines: subLines)
					startUpWithCaption: captionOrNil at: location.
		index = subset size
			ifTrue: [
				from _ to + 1.
				from > nLines ifTrue: [from _ 1]]
			ifFalse: [
				index = 0 ifTrue: [^ 0].
				^ from + index - 1]].! !

!PopUpMenu methodsFor: 'basic control sequence' stamp: 'sma 4/30/2000 10:05'!
startUpWithCaption: captionOrNil
	"Display the menu, slightly offset from the cursor,
	so that a slight tweak is required to confirm any action."

	^ self startUpWithCaption: captionOrNil
		at: (Smalltalk isMorphic 
			ifTrue: [World cursorPoint]
			ifFalse: [Sensor cursorPoint])! !


!PopUpMenu methodsFor: 'displaying' stamp: 'sw 12/10/1999 09:55'!
displayAt: aPoint withCaption: captionOrNil during: aBlock
	"Display the receiver just to the right of aPoint while aBlock is evaluated.  If the receiver is forced off screen, display it just to the right."
	| delta savedArea captionForm captionSave outerFrame captionText tFrame frameSaveLoc captionBox |
	marker ifNil: [self computeForm].
	frame _ frame align: marker leftCenter with: aPoint + (2@0).
	outerFrame _ frame.
	captionOrNil notNil ifTrue:
		[captionText _ (DisplayText
				text: captionOrNil asText
				textStyle: MenuStyle copy centered)
					foregroundColor: Color black
					backgroundColor: Color white.
		tFrame _ captionText boundingBox insetBy: -2.
		outerFrame _ frame merge: (tFrame align: tFrame bottomCenter
					with: frame topCenter + (0@2))].
	delta _ outerFrame amountToTranslateWithin: Display boundingBox.
	frame right > Display boundingBox right
		ifTrue: [delta _ 0 - frame width @ delta y].
	frame _ frame translateBy: delta.
	captionOrNil notNil ifTrue:
		[captionForm _ captionText form.
		captionBox _ captionForm boundingBox expandBy: 4.
		captionBox _ captionBox align: captionBox bottomCenter
								with: frame topCenter + (0@2).
		captionSave _ Form fromDisplay: captionBox.
		Display border: captionBox width: 4 fillColor: Color white.
		Display border: captionBox width: 2 fillColor: Color black.
		captionForm displayAt: captionBox topLeft + 4].
	marker _ marker align: marker leftCenter with: aPoint + delta +  (2@0).
	savedArea _ Form fromDisplay: frame.
	self menuForm displayOn: Display at: (frameSaveLoc _ frame topLeft).
	selection ~= 0 ifTrue: [Display reverse: marker].
	Cursor normal showWhile: [aBlock value].
	savedArea displayOn: Display at: frameSaveLoc.
	captionOrNil notNil ifTrue:
		[captionSave displayOn: Display at: captionBox topLeft]! !


!PopUpMenu methodsFor: 'marker adjustment' stamp: 'di 4/13/1999 17:42'!
manageMarker
	"If the cursor is inside the receiver's frame, then highlight the marked 
	item. Otherwise no item is to be marked."
	| pt |
	"Don't let pt get far from display box, so scrolling will go all the way"
	pt _ Sensor cursorPoint adhereTo: (Display boundingBox expandBy: 1).
	(frame inside containsPoint: pt)
		ifTrue: ["Need to cache the form for reasonable scrolling performance"
				((Display boundingBox insetBy: 0@3) containsPoint: pt)
					ifFalse: [pt _ pt - (self scrollIntoView: pt)].
				self markerOn: pt]
		ifFalse: [self markerOff]! !

!PopUpMenu methodsFor: 'marker adjustment' stamp: 'sma 5/28/2000 15:27'!
markerOff
	"No item is selected. Reverse the highlight if any item has been marked 
	as selected."

	self setSelection: 0! !

!PopUpMenu methodsFor: 'marker adjustment' stamp: 'sma 6/1/2000 13:01'!
markerOn: aPoint 
	"The item whose bounding area contains aPoint should be marked as 
	selected. Highlight its area and set the selection to its index."

	selection = 0 | (marker containsPoint: aPoint) not 
		ifTrue: [selection = 0 & (marker containsPoint: aPoint)
					ifTrue: [Display reverse: marker]
					ifFalse: 
						[selection > 0 ifTrue: [Display reverse: marker].
						marker _ 
							marker 
								align: marker topLeft 
								with: marker left @ (self markerTop: aPoint).
						Display reverse: marker]].
	selection _ marker top - frame top // marker height + 1! !

!PopUpMenu methodsFor: 'marker adjustment'!
markerTop: aPoint 
	"Answer aPoint, gridded to lines in the receiver."

	^(aPoint y - frame inside top truncateTo: font height) + frame inside top! !

!PopUpMenu methodsFor: 'marker adjustment' stamp: 'di 3/9/98 19:46'!
scrollIntoView: cursorLoc
	| dy |
	dy _ 0.
	cursorLoc y < 2 ifTrue: [dy _ font height].
	cursorLoc y > (Display height-3) ifTrue: [dy _ font height negated].
	dy = 0 ifTrue: [^ 0@0].
	self markerOff.
	frame _ frame translateBy: 0@dy.
	marker _ marker translateBy: 0@dy.
	self menuForm displayOn: Display at: frame topLeft.
	^ 0@dy! !


!PopUpMenu methodsFor: 'private' stamp: 'ee 8/7/2008 20:38'!
computeForm
	"Compute and answer a Form to be displayed for this menu."

	| borderInset paraForm menuForm inside |
	borderInset _ 4@4.
	paraForm _ (DisplayText text: labelString asText textStyle: MenuStyle) form.
	menuForm _ Form extent: paraForm extent + (borderInset * 2).
	menuForm borderWidth: 2.
	paraForm displayOn: menuForm at: borderInset.
	lineArray == nil ifFalse:
		[lineArray do:
			[ :line |
			menuForm fillBlack: (4 @ ((line * font height) + borderInset y)
				extent: (menuForm width - 8 @ 1))]].

	frame _ Quadrangle new.
	frame region: menuForm boundingBox.
	frame borderWidth: 4.
	inside _ frame inside.
	marker _ inside topLeft extent: (inside width @ ((ScratchTranslator stringExtent: 'Language' localized font: MenuStyle defaultFont) y)).
	selection _ 1.

	^ form _ menuForm
! !

!PopUpMenu methodsFor: 'private' stamp: 'di 4/13/1999 16:21'!
labels: aString font: aFont lines: anArray

	labelString _ aString.
	font _ aFont.
	lineArray _ anArray.
! !

!PopUpMenu methodsFor: 'private' stamp: 'di 4/13/1999 17:51'!
menuForm
	"Answer a Form to be displayed for this menu."

	form == nil ifTrue: [self computeForm].
	^ form! !

!PopUpMenu methodsFor: 'private' stamp: 'sma 2/5/2000 11:56'!
rescan
	"Cause my form to be recomputed after a font change."

	labelString == nil ifTrue: [labelString _ 'NoText!!'].
	self labels: labelString font: (MenuStyle fontAt: 1) lines: lineArray.
	frame _ marker _ form _ nil.

	"PopUpMenu allSubInstancesDo: [:m | m rescan]"! !


!PopUpMenu methodsFor: 'selecting' stamp: 'sma 5/28/2000 12:27'!
selection
	"Answer the current selection."

	^ selection! !

!PopUpMenu methodsFor: 'selecting' stamp: 'sma 6/1/2000 11:01'!
setSelection: index
	| newSelection |
	selection = index ifTrue: [^ self].
	newSelection _ (0 max: index) min: frame height // marker height.
	selection > 0 ifTrue: [Display reverse: marker].
	marker _ marker translateBy: 0 @ (newSelection - selection * marker height).
	selection _ newSelection.
	selection > 0 ifTrue: [Display reverse: marker]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

PopUpMenu class
	instanceVariableNames: ''!

!PopUpMenu class methodsFor: 'class initialization' stamp: 'jm 4/25/2005 13:00'!
initialize
	"self initialize"

	| fnt |
	fnt _ TextStyle defaultFont.
	MenuStyle _ TextStyle fontArray: (Array with: fnt).
	MenuStyle
		gridForFont: 1 withLead: 0;
		centered.

	PopUpMenu allSubInstancesDo: [:m | m rescan].
! !

!PopUpMenu class methodsFor: 'class initialization' stamp: 'jm 12/16/2005 11:30'!
setMenuFontTo: aFont

	MenuStyle _ TextStyle withFont: aFont.
	MenuStyle 
		gridForFont: 1 withLead: 0;
		centered.
	self allSubInstancesDo: [:m | m rescan].
! !


!PopUpMenu class methodsFor: 'instance creation' stamp: 'sma 5/28/2000 15:44'!
labelArray: labelArray
	"Answer an instance of me whose items are in labelArray."

	^ self labelArray: labelArray lines: nil! !

!PopUpMenu class methodsFor: 'instance creation' stamp: 'sma 5/28/2000 15:43'!
labelArray: labelArray lines: lineArray
	"Answer an instance of me whose items are in labelArray, with lines 
	drawn after each item indexed by anArray. 2/1/96 sw"

	labelArray isEmpty ifTrue: [self error: 'Menu must not be zero size'].
	^ self
		labels: (String streamContents: 
			[:stream |
			labelArray do: [:each | stream nextPutAll: each; cr].
			stream skip: -1 "remove last CR"])
		lines: lineArray

"Example:
	(PopUpMenu labelArray: #('frog' 'and' 'toad') lines: #()) startUp"! !

!PopUpMenu class methodsFor: 'instance creation' stamp: 'sma 5/28/2000 15:36'!
labels: aString
	"Answer an instance of me whose items are in aString."

	^ self labels: aString lines: nil! !

!PopUpMenu class methodsFor: 'instance creation' stamp: 'sw 12/6/1999 17:55'!
labels: aString lines: anArray
	"Answer an instance of me whose items are in aString, with lines drawn 
	after each item indexed by anArray."

	^ self new
		labels: aString
		font: MenuStyle defaultFont
		lines: anArray! !


!PopUpMenu class methodsFor: 'dialogs' stamp: 'sma 5/28/2000 15:48'!
confirm: queryString
	"Put up a yes/no menu with caption queryString. Answer true if the 
	response is yes, false if no. This is a modal question--the user must 
	respond yes or no."

	"PopUpMenu confirm: 'Are you hungry?'"

	^ self confirm: queryString trueChoice: 'Yes' falseChoice: 'No'! !

!PopUpMenu class methodsFor: 'dialogs' stamp: 'sma 6/5/2000 09:11'!
confirm: queryString orCancel: cancelBlock
	"Put up a yes/no/cancel menu with caption aString. Answer true if  
	the response is yes, false if no. If cancel is chosen, evaluate  
	cancelBlock. This is a modal question--the user must respond yes or no."

	"PopUpMenu confirm: 'Reboot universe' orCancel: [^'Nevermind']"

	| menu choice |
	menu _ PopUpMenu labelArray: {'Yes'. 'No'. 'Cancel'}.
	choice _ menu startUpWithCaption: queryString.
	choice = 1 ifTrue: [^ true].
	choice = 2 ifTrue: [^ false].
	^ cancelBlock value! !

!PopUpMenu class methodsFor: 'dialogs' stamp: 'sma 6/5/2000 09:12'!
confirm: queryString trueChoice: trueChoice falseChoice: falseChoice
	"Put up a yes/no menu with caption queryString. The actual wording 
	for the two choices will be as provided in the trueChoice and 
	falseChoice parameters. Answer true if the response is the true-choice, 
	false if it's the false-choice.
	This is a modal question -- the user must respond one way or the other."

	"PopUpMenu 
		confirm: 'Are you hungry?'
		trueChoice: 'yes, I''m famished'
		falseChoice: 'no, I just ate'"

	| menu choice |
	menu _ PopUpMenu labelArray: {trueChoice. falseChoice}.
	[(choice _ menu startUpWithCaption: queryString) isNil] whileTrue.
	^ choice = 1! !

!PopUpMenu class methodsFor: 'dialogs' stamp: 'sma 5/28/2000 15:57'!
inform: aString
	"PopUpMenu inform: 'I like Squeak'"

	(PopUpMenu labels: ' OK ') startUpWithCaption: aString! !

!PopUpMenu class methodsFor: 'dialogs' stamp: 'sma 5/28/2000 15:57'!
notify: message
	"Deprecated. Use #inform: instead."

	self inform: message! !


PopUpMenu initialize!
