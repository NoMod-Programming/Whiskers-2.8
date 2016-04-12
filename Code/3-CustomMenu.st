SelectionMenu subclass: #CustomMenu
	instanceVariableNames: 'title labels dividers lastDivider includesUTF8 icons isHorizontal '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tools-Menus'!
!CustomMenu commentStamp: '<historical>' prior: 0!
I am used to build menus on-the-fly. I maintain lists of menu items, actions (usually symbols to be sent as messages), and menu section dividing lines to which my clients may append new entries and lines by sending me the messages:

	add: aString action: anAction
	addLine

After the menu is constructed, it may be invoked with one of the following messages:

	startUp: initialSelection
	startUp

I am a subclass of ActionMenu, so I inherit a number of instance variables. The ones I am particularly concerned with are:

	items _ an OrderedCollection of strings to appear in the menu
	selectors _ an OrderedCollection of Symbols to be used as message selectors
	lineArray _ an OrderedCollection of line positions
	lastLine _ used to keep track of the last line to avoid making duplicate entries in lineArray!


!CustomMenu methodsFor: 'initialize-release' stamp: 'jens 3/26/2009 18:32'!
initialize

	labels _ OrderedCollection new.
	icons _ OrderedCollection new.
	selections _ OrderedCollection new.
	dividers _ OrderedCollection new.
	isHorizontal _ false.
	lastDivider _ 0.
	includesUTF8 _ false.! !

!CustomMenu methodsFor: 'initialize-release' stamp: 'EMP 10/11/2015 20:04'!
target: aMorph
	target _ aMorph.! !

!CustomMenu methodsFor: 'initialize-release' stamp: 'sw 8/18/1998 12:01'!
title: aTitle
	title _ aTitle! !


!CustomMenu methodsFor: 'accessing' stamp: 'jens 3/26/2009 18:33'!
beHorizontal
	isHorizontal _ true! !

!CustomMenu methodsFor: 'accessing' stamp: 'EMP 10/11/2015 19:26'!
color: aColor
	color _ aColor.! !

!CustomMenu methodsFor: 'accessing' stamp: 'jens 3/26/2009 15:09'!
icons
	^icons! !

!CustomMenu methodsFor: 'accessing' stamp: 'jens 3/26/2009 18:32'!
isHorizontal
	^isHorizontal! !

!CustomMenu methodsFor: 'accessing' stamp: 'ee 10/28/2007 01:58'!
labels

	^ labels! !


!CustomMenu methodsFor: 'construction' stamp: 'jens 3/26/2009 17:51'!
add: aString action: actionItem
	"Add the given string as the next menu item. If it is selected, the given action (usually but not necessarily a symbol) will be returned to the client."

	| s |
	s _ String new: aString size + 2.
	s at: 1 put: Character space.
	s replaceFrom: 2 to: s size - 1 with: aString.
	s at: s size put: Character space.
	aString isUnicode ifTrue: [includesUTF8 _ true].
	labels addLast: s.
	icons add: nil.
	selections addLast: actionItem.! !

!CustomMenu methodsFor: 'construction' stamp: 'jens 5/20/2010 23:52'!
add: aString toolTip: data action: actionItem

	| lbl tip |
	(icons size = labels size) ifFalse: [^self error: 'inconsistent menu construction' ].
	labels addLast: '  '.

	lbl _ (StringMorph contents: aString
						font: Preferences standardMenuFont) imageForm.

	tip _ data.
	(data isKindOf: Morph) ifTrue: [
		tip _ data imageForm ].

	icons addLast: (Array with: lbl with: tip).
	selections addLast: actionItem.! !

!CustomMenu methodsFor: 'construction' stamp: 'EMP 12/3/2015 11:51'!
addIcon: aForm action: actionItem

	self addIcon: aForm toolTip: nil action: actionItem! !

!CustomMenu methodsFor: 'construction' stamp: 'jens 6/9/2010 23:09'!
addIcon: aForm toolTip: string action: actionItem

	(icons size = labels size) ifFalse: [^self error: 'inconsistent menu construction' ].
	labels addLast: '  '.
	icons addLast: (Array with: aForm with: string).
	selections addLast: actionItem.! !

!CustomMenu methodsFor: 'construction'!
addLine
	"Append a line to the menu after the last entry. Suppress duplicate lines."

	(lastDivider ~= selections size) ifTrue: [
		lastDivider _ selections size.
		dividers addLast: lastDivider].! !

!CustomMenu methodsFor: 'construction' stamp: 'jm 3/29/98 07:09'!
addList: listOfPairs
	"Add a menu item to the receiver for each pair in the given list of the form (<what to show> <selector>). Add a line for each dash (-) in the list."
	"CustomMenu new addList: #(
		('apples' buyApples)
		('oranges' buyOranges)
		-
		('milk' buyMilk)); startUp"

	listOfPairs do: [:pair |
		#- = pair
			ifTrue: [self addLine]
			ifFalse: [self add: pair first action: pair last]].
! !

!CustomMenu methodsFor: 'construction' stamp: 'sw 7/20/1999 18:47'!
balloonTextForLastItem: aString
	"Vacuous backstop provided for compatibility with MorphicMenu"! !

!CustomMenu methodsFor: 'construction' stamp: 'jm
 8/20/1998 08:34'!
labels: aString font: aFont lines: anArrayOrNil
	"This method allows the receiver to accept old-style SelectionMenu creation messages. It should be used only for backward compatibility during the MVC-to-Morphic transition. New code should be written using the other menu construction protocol such as addList:."

	| labelList linesArray |
	labelList _ (aString findTokens: String cr) asArray.
	anArrayOrNil
		ifNil: [linesArray _ #()]
		ifNotNil: [linesArray _ anArrayOrNil].
	1 to: labelList size do: [:i |
		self add: (labelList at: i) action: (labelList at: i).
		(linesArray includes: i) ifTrue: [self addLine]].
	font ifNotNil: [font _ aFont].
! !

!CustomMenu methodsFor: 'construction' stamp: 'di 8/20/1998 09:24'!
labels: labelList lines: linesArray selections: selectionsArray
	"This method allows the receiver to accept old-style SelectionMenu creation messages. It should be used only for backward compatibility during the MVC-to-Morphic transition. New code should be written using the other menu construction protocol such as addList:."
	"Labels can be either a sting with embedded crs, or a collection of strings."

	| labelArray |
	(labelList isMemberOf: String)
		ifTrue: [labelArray _ labelList findTokens: String cr]
		ifFalse: [labelArray _ labelList].
	1 to: labelArray size do: [:i |
		self add: (labelArray at: i) action: (selectionsArray at: i).
		(linesArray includes: i) ifTrue: [self addLine]].
! !

!CustomMenu methodsFor: 'construction' stamp: 'jens 6/7/2010 22:47'!
localize
	"Localize my labels. Note: This should be called before build."

	| s2 |
	labels _ labels collect: [:s |
		s2 _ (s copyFrom: 2 to: s size - 1) localized.
		s2 isUnicode ifTrue: [includesUTF8 _ true].
		(UTF8 withAll: (' ', s2, ' ')) "asMacRoman"].

	title ifNotNil: [title _ title localized].

	icons do: [:eachPair |
		eachPair ifNotNil: [
			eachPair second ifNotNil: [
			eachPair at: 2 put: (eachPair at: 2) localized ]]]
! !


!CustomMenu methodsFor: 'invocation' stamp: 'jm 11/17/97 16:54'!
invokeOn: targetObject defaultSelection: defaultSelection
	"Invoke the menu with the given default selection (i.e. one of my 'action' symbols). Answer the 'action' selector associated with the menu item chosen by the user or nil if none is chosen."

	| sel |
	sel _ self startUp: defaultSelection.
	sel = nil ifFalse: [
		sel numArgs = 0
			ifTrue: [^ targetObject perform: sel]
			ifFalse: [^ targetObject perform: sel with: nil]].
	^ nil
! !

!CustomMenu methodsFor: 'invocation' stamp: 'jm 1/1/2004 11:16'!
startUp
	"Build and invoke this menu with no initial selection. Answer the selection associated with the menu item chosen by the user or nil if none is chosen."

	^ self startUp: nil
! !

!CustomMenu methodsFor: 'invocation' stamp: 'sw 8/18/1998 12:01'!
startUp: initialSelection
	"Build and invoke this menu with the given initial selection. Answer the selection associated with the menu item chosen by the user or nil if none is chosen."

	^ self startUp: initialSelection withCaption: title! !

!CustomMenu methodsFor: 'invocation' stamp: 'EMP 12/2/2015 14:58'!
startUp: initialSelection at: location
	"Build and invoke this menu with the given initial selection. Answer the selection associated with the menu item chosen by the user or nil if none is chosen."

	^ self startUp: initialSelection withCaption: title at: location! !

!CustomMenu methodsFor: 'invocation' stamp: 'jm 3/9/2005 16:21'!
startUp: initialSelection withCaption: caption
	"Build and invoke this menu with the given initial selection and caption. Answer the selection associated with the menu item chosen by the user or nil if none is chosen."

	^ self
		startUp: initialSelection
		withCaption: caption
		at: (Smalltalk isMorphic 
				ifTrue: [World cursorPoint]
				ifFalse: [Sensor cursorPoint])! !

!CustomMenu methodsFor: 'invocation' stamp: 'jm 9/30/2007 14:09'!
startUp: initialSelection withCaption: caption at: aPoint
	"Build and invoke this menu with the given initial selection and caption at the given point. Answer the selection associated with the menu item chosen by the user or nil if none is chosen."

	self build.
	(initialSelection notNil) ifTrue: [self preSelect: initialSelection].
	^ self startUpWithCaption: caption at: aPoint
! !

!CustomMenu methodsFor: 'invocation' stamp: 'EMP 12/2/2015 14:59'!
startUpAt: loc
	"Build and invoke this menu with no initial selection. Answer the selection associated with the menu item chosen by the user or nil if none is chosen."

	^ self startUp: nil at: loc
! !

!CustomMenu methodsFor: 'invocation' stamp: 'sw 7/31/97 19:31'!
startUpWithCaption: caption
	"Build and invoke this menu with no initial selection. Answer the selection associated with the menu item chosen by the user or nil if none is chosen; use the provided caption"

	^ self startUp: nil withCaption: caption! !


!CustomMenu methodsFor: 'private' stamp: 'jm 6/3/2009 17:32'!
build
	"Turn myself into an invokable ActionMenu."

	| stream |
	stream _ WriteStream on: String new.
	labels do: [:label | stream nextPutAll: label; cr].
	labels isEmpty ifFalse: [stream skip: -1].  "remove final cr"
	super
		labels: stream contents
		font: MenuStyle defaultFont
		lines: dividers.
! !

!CustomMenu methodsFor: 'private' stamp: 'di 4/14/1999 21:28'!
preSelect: action
	"Pre-select and highlight the menu item associated with the given action."

	| i |
	i _ selections indexOf: action ifAbsent: [^ self].
	marker ifNil: [self computeForm].
	marker _ marker
		align: marker topLeft
		with: (marker left)@(frame inside top + (marker height * (i - 1))).
	selection _ i.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

CustomMenu class
	instanceVariableNames: ''!

!CustomMenu class methodsFor: 'example' stamp: 'sw 11/8/1999 17:27'!
example
	"CustomMenu example"

	| menu |
	menu _ CustomMenu new.
	menu add: 'apples' action: #apples.
	menu add: 'oranges' action: #oranges.
	menu addLine.
	menu addLine.  "extra lines ignored"
	menu add: 'peaches' action: #peaches.
	menu addLine.
	menu add: 'pears' action: #pears.
	menu addLine.
	^ menu startUp: #apples


"NB:  The following is equivalent to the above, but uses the compact #fromArray: consruct:
	(CustomMenu fromArray:
		#(	('apples'		apples)
			('oranges'		oranges)
			-
			-
			('peaches'		peaches)
			-
			('pears'			pears)
			-))
				startUp: #apples"! !
