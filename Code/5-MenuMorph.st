AlignmentMorph subclass: #MenuMorph
	instanceVariableNames: 'defaultTarget lastSelection stayUp originalEvent popUpOwner '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Menus'!

!MenuMorph methodsFor: 'initialization' stamp: 'EMP 4/9/2016 15:40'!
initialize
	super initialize.
	self setDefaultParameters.
	orientation _ #vertical.
	hResizing _ #shrinkWrap.
	vResizing _ #shrinkWrap.
	defaultTarget _ nil.
	lastSelection _ nil.
	stayUp _ false.
	originalEvent _ nil.
	popUpOwner _ nil.
	borderColor _ Color r:(96/255) g:(99/255) b:(101/255).
	Preferences roundedMenuCorners ifTrue: [self useRoundedCorners].! !

!MenuMorph methodsFor: 'initialization' stamp: 'EMP 12/3/2015 14:53'!
setDefaultParameters

	| worldColor |
	((Preferences menuColorFromWorld and: [Display depth > 4]) and: [(worldColor _ self currentWorld color) isKindOf: Color])
		ifTrue: [self setColor: (worldColor luminance > 0.7
							ifTrue: [worldColor mixed: 0.8 with: Color black]
							ifFalse: [worldColor mixed: 0.4 with: Color white])
					borderWidth: Preferences menuBorderWidth
					borderColor: #raised]
		ifFalse: [self setColor: Preferences menuColor
					borderWidth: Preferences menuBorderWidth
					borderColor: Preferences menuBorderColor].
	inset _ 1! !

!MenuMorph methodsFor: 'initialization' stamp: 'sw 11/3/1998 11:23'!
setTitleParametersFor: aMenuTitle
	aMenuTitle setColor: Preferences menuTitleColor borderWidth: Preferences menuTitleBorderWidth borderColor: Preferences menuTitleBorderColor! !


!MenuMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
hasSubMenu: aMenuMorph

	| sub |
	self items do: [:each |
		sub _ each subMenu.
		sub ifNotNil: [
			sub == aMenuMorph ifTrue: [^ true].
			(sub hasSubMenu: aMenuMorph) ifTrue: [^ true]]].
	^ false
! !

!MenuMorph methodsFor: 'accessing' stamp: 'sw 11/22/1999 10:25'!
itemWithWording: wording
	| aString aSubmenu subItem |
	"If any of the receiver's items or submenu items have the given wording (case-blind comparison done), then return it, else return nil."

	aString _ wording asString asLowercase.
	self items do:
		[:anItem |
			(anItem contents asString asLowercase = aString) ifTrue: [^ anItem].
			(aSubmenu _ anItem subMenu) ifNotNil:
				[(subItem _ aSubmenu itemWithWording: wording) ifNotNil: [^ subItem]]].
	^ nil! !

!MenuMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
items

	^ submorphs select: [:m | m isKindOf: MenuItemMorph]
! !

!MenuMorph methodsFor: 'accessing' stamp: 'sw 4/19/1999 12:22'!
lastItem
	^ submorphs last! !

!MenuMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
lastSelection
	"Return the label of the last selected item or nil."

	lastSelection == nil
		ifTrue: [^ lastSelection selector]
		ifFalse: [^ nil].
! !

!MenuMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
lastSelection: aString
	"Set the last selection so that it is selected by default when this menu first pops up."

	lastSelection _ self items
		detect: [:each | each selector == aString] ifNone: [nil].
! !

!MenuMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
popUpOwner

	^ popUpOwner
! !

!MenuMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
popUpOwner: aMenuItemMorph

	popUpOwner _ aMenuItemMorph.
! !

!MenuMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
stayUp

	^ stayUp
! !

!MenuMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
stayUp: aBoolean

	stayUp _ aBoolean.
! !


!MenuMorph methodsFor: 'construction' stamp: 'jm 10/13/2002 17:38'!
add: aString action: aSymbol
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the default target object."
	"Details: Note that the menu item added captures the default target object at the time the item is added; the default target can later be changed before added additional items without affecting the targets of previously added entries. The model is that each entry is like a button that knows everything it needs to perform its action."

	self add: aString
		target: defaultTarget
		selector: aSymbol
		argumentList: Array empty.
! !

!MenuMorph methodsFor: 'construction' stamp: 'sw 5/1/1998 00:48'!
add: aString selector: aSymbol argument: arg

	self add: aString
		target: defaultTarget
		selector: aSymbol
		argumentList: (Array with: arg)
! !

!MenuMorph methodsFor: 'construction' stamp: 'jm 11/4/97 07:46'!
add: aString subMenu: aMenuMorph
	"Append the given submenu with the given label."

	| item |
	item _ MenuItemMorph new.
	item contents: aString;
		subMenu: aMenuMorph.
	self addMorphBack: item.
! !

!MenuMorph methodsFor: 'construction' stamp: 'jm 10/13/2002 17:38'!
add: aString target: aTarget action: aSymbol

	self add: aString
		target: aTarget
		selector: aSymbol
		argumentList: Array empty.
! !

!MenuMorph methodsFor: 'construction' stamp: 'jm 10/13/2002 17:38'!
add: aString target: anObject selector: aSymbol
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object."

	self add: aString
		target: anObject
		selector: aSymbol
		argumentList: Array empty.
! !

!MenuMorph methodsFor: 'construction' stamp: 'jm 11/4/97 07:46'!
add: aString target: target selector: aSymbol argument: arg
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given argument."

	self add: aString
		target: target
		selector: aSymbol
		argumentList: (Array with: arg)
! !

!MenuMorph methodsFor: 'construction' stamp: 'jm 11/4/97 07:46'!
add: aString target: target selector: aSymbol argumentList: argList
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given arguments. If the selector takes one more argument than the number of arguments in the given list, then the triggering event is supplied as as the last argument."

	| item |
	item _ MenuItemMorph new
		contents: aString;
		target: target;
		selector: aSymbol;
		arguments: argList asArray.
	self addMorphBack: item.
! !

!MenuMorph methodsFor: 'construction' stamp: 'jens 3/27/2009 09:42'!
addIcon: aForm tooltip: aString action: aSymbol
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given arguments. If the selector takes one more argument than the number of arguments in the given list, then the triggering event is supplied as as the last argument."

	self addIcon: aForm 
		tooltip: aString 
		target: defaultTarget 
		selector: aSymbol 
		argumentList: Array empty
! !

!MenuMorph methodsFor: 'construction' stamp: 'jens 3/25/2009 11:01'!
addIcon: aForm tooltip: aString target: target selector: aSymbol argumentList: argList
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given arguments. If the selector takes one more argument than the number of arguments in the given list, then the triggering event is supplied as as the last argument."

	| item |
	item _ MenuItemMorph new
		icon: aForm;
		contents: '';
		setBalloonText: aString;
		target: target;
		selector: aSymbol;
		arguments: argList asArray.
	self addMorphBack: item.
! !

!MenuMorph methodsFor: 'construction' stamp: 'jm 5/20/1998 10:50'!
addLine
	"Append a divider line to this menu. Suppress duplicate lines."

	submorphs isEmpty ifTrue: [^ self].
	(self lastSubmorph isKindOf: MenuLineMorph)
		ifFalse: [self addMorphBack: MenuLineMorph new].
! !

!MenuMorph methodsFor: 'construction' stamp: 'md 12/15/1999 12:44'!
addList: listOfPairs
	"Add the given items to this menu, where each item is a pair (<string> <actionSelector>)..  ILf an element of the list is simply the symobl $-, add a line to the receiver."

	listOfPairs do: [:pair |
		#- = pair
			ifTrue: [self addLine]
			ifFalse: [self add: pair first action: pair last]]! !

!MenuMorph methodsFor: 'construction' stamp: 'jm 10/13/2002 17:38'!
addStayUpItem
	"Append a menu item that can be used to toggle this menu's persistent."

	self add: 'keep this menu up'
		target: self
		selector: #toggleStayUp:
		argumentList: Array empty.
	self addLine.
! !

!MenuMorph methodsFor: 'construction' stamp: 'sw 6/19/1999 23:09'!
addTitle: aString
	"Add a title line at the top of this menu."

	self addTitle: aString updatingSelector: nil updateTarget: nil! !

!MenuMorph methodsFor: 'construction' stamp: 'sw 12/8/1999 17:53'!
addTitle: aString updatingSelector: aSelector updateTarget: aTarget
	"Add a title line at the top of this menu  Make aString its initial contents.  If aSelector is not nil, then periodically obtain fresh values for its contents by sending aSelector to aTarget.."

	| title |
	title _ AlignmentMorph new.
	self setTitleParametersFor: title.
	title vResizing: #shrinkWrap.
	title orientation: #vertical.
	title centering: #center.
	aSelector
		ifNotNil:
			[title addMorphBack: (UpdatingStringMorph new lock; useStringFormat; target: aTarget; getSelector: aSelector)]
		ifNil:
			[(aString asString findTokens: String cr) do:
				[:line | title addMorphBack: (StringMorph contents: line font: Preferences standardMenuFont)]].
	
	self addMorphFront: title.
! !

!MenuMorph methodsFor: 'construction' stamp: 'jm 10/13/2002 17:38'!
addUpdating: aWordingSelector action: aSymbol

	self addUpdating: aWordingSelector
		target: defaultTarget
		selector: aSymbol
		argumentList: Array empty.
! !

!MenuMorph methodsFor: 'construction' stamp: 'sw 6/21/1999 11:32'!
addUpdating: wordingSelector enablementSelector: enablementSelector target: target selector: aSymbol argumentList: argList
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given arguments. If the selector takes one more argument than the number of arguments in the given list, then the triggering event is supplied as as the last argument.  In this variant, the wording of the menu item is obtained by sending the wordingSelector to the target, and the optional enablementSelector determines whether or not the item should be enabled."

	| item |
	item _ UpdatingMenuItemMorph new
		target: target;
		selector: aSymbol;
		wordingProvider: target wordingSelector: wordingSelector;
		enablementSelector: enablementSelector;
		arguments: argList asArray.
	self addMorphBack: item.
! !

!MenuMorph methodsFor: 'construction' stamp: 'jm 10/13/2002 17:38'!
addUpdating: aWordingSelector target: aTarget action: aSymbol

	self addUpdating: aWordingSelector
		target: aTarget
		selector: aSymbol
		argumentList: Array empty.
! !

!MenuMorph methodsFor: 'construction' stamp: 'sw 6/11/1999 16:46'!
addUpdating: wordingSelector target: target selector: aSymbol argumentList: argList
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given arguments. If the selector takes one more argument than the number of arguments in the given list, then the triggering event is supplied as as the last argument.  In this variant, the wording of the menu item is obtained by sending the wordingSelector to the target"

	| item |
	item _ UpdatingMenuItemMorph new
		target: target;
		selector: aSymbol;
		wordingProvider: target wordingSelector: wordingSelector;
		arguments: argList asArray.
	self addMorphBack: item.
! !

!MenuMorph methodsFor: 'construction' stamp: 'sw 11/5/1998 21:13'!
balloonTextForLastItem: balloonText
	submorphs last setBalloonText: balloonText! !

!MenuMorph methodsFor: 'construction' stamp: 'jm 6/12/2008 10:02'!
convertItemsToUTF8

	| utf8 |
	submorphs do: [:m |
		(m isKindOf: MenuItemMorph) ifTrue: [
			utf8 _ UTF8 withAll: m contents.
			m contents: ''.
			m contents: utf8]].
! !

!MenuMorph methodsFor: 'construction' stamp: 'jm 11/4/97 07:46'!
defaultTarget: anObject
	"Set the default target for adding menu items."

	defaultTarget _ anObject.
! !

!MenuMorph methodsFor: 'construction' stamp: 'di 8/20/1998 09:30'!
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

!MenuMorph methodsFor: 'construction' stamp: 'sw 7/1/1999 22:21'!
title: aString
	"Add a title line at the top of this menu."

	self addTitle: aString! !


!MenuMorph methodsFor: 'control' stamp: 'jm 10/15/2002 17:18'!
deleteIfPopUp
	"Remove this menu from the screen if stayUp is not true. If it is a submenu, also remove its owning menu."

	stayUp ifFalse: [self delete].
	(popUpOwner notNil and: [popUpOwner isKindOf: MenuItemMorph]) ifTrue: [
		popUpOwner isSelected: false.
		(popUpOwner owner isKindOf: MenuMorph)
			ifTrue: [popUpOwner owner deleteIfPopUp]].
! !

!MenuMorph methodsFor: 'control' stamp: 'bf 11/23/1999 11:11'!
deleteIfPopUpFrom: item event: evt
	"Remove this menu from the screen if stayUp is not true, but only if the user did move the mouse since invoking me. This allows for click-move-click selection style."

	stayUp ifFalse: 
		[((self hasProperty: #stayUpOnce) or: 
			[(evt cursorPoint dist: originalEvent cursorPoint) < 2]) ifTrue:
				[self removeProperty: #stayUpOnce.
				^evt hand newMouseFocus: item "Do tracking and delete on next click"]].
	self deleteIfPopUp.
! !

!MenuMorph methodsFor: 'control' stamp: 'di 3/14/1999 13:04'!
invokeItem: aMenuItem
	"Perform the action associated with the given menu item."

	^ self invokeItem: aMenuItem event: originalEvent! !

!MenuMorph methodsFor: 'control' stamp: 'di 3/14/1999 13:03'!
invokeItem: aMenuItem event: evt
	"Perform the action associated with the given menu item."

	| sel target args selArgCount |
	aMenuItem isEnabled ifFalse: [^ self].
	lastSelection _ aMenuItem.
	"to do: report lastSelection"
	sel _ aMenuItem selector.
	target _ aMenuItem target.
	args _ aMenuItem arguments.
	selArgCount _ sel numArgs.
	Cursor normal showWhile: [  "show cursor in case item opens a new MVC window"
		selArgCount = 0
			ifTrue: [target perform: sel]
			ifFalse: [
				selArgCount = args size
					ifTrue: [target perform: sel withArguments: args]
					ifFalse: [target perform: sel withArguments: (args copyWith: evt)]]].
! !

!MenuMorph methodsFor: 'control' stamp: 'bf 11/23/1999 11:17'!
justDroppedInto: aMorph event: anEvent
	"This menu was grabbed and moved. Save us from being deleted by the mouseUp event."
	stayUp ifFalse: [self setProperty: #stayUpOnce toValue: true].
	super justDroppedInto: aMorph event: anEvent! !

!MenuMorph methodsFor: 'control' stamp: 'EMP 12/12/2015 18:19'!
popUpAdjacentTo: rightOrLeftPoint forHand: hand from: sourceItem
	"Present this menu at the given point under control of the given hand."

	| selectedItem delta tryToPlace selectedOffset |
	hand world startSteppingSubmorphsOf: self.
	popUpOwner _ sourceItem.
	originalEvent _ hand lastEvent.
	selectedItem _ self selectedItem.
	self fullBounds.  "ensure layout is current"
	selectedOffset _ selectedItem position - self position.
	tryToPlace _
		[:where :mustFit |
		self position: where - selectedOffset.
		delta _ self fullBoundsInWorld amountToTranslateWithin: hand worldBounds.
		(delta x = 0 or: [mustFit]) ifTrue:
			[delta = (0@0) ifFalse: [self position: self position + delta].
			sourceItem owner owner addMorphFront: self.
			^ self]].
	tryToPlace 
		value: rightOrLeftPoint first value: false;
		value: rightOrLeftPoint last  - (self width @ 0) value: false;
		value: rightOrLeftPoint first value: true

	! !

!MenuMorph methodsFor: 'control' stamp: 'sma 6/5/2000 13:55'!
popUpAt: aPoint event: evt
	"Present this menu at the given point in response to the given event."

	self popUpAt: aPoint forHand: evt hand! !

!MenuMorph methodsFor: 'control' stamp: 'EMP 12/12/2015 18:22'!
popUpAt: aPoint forHand: hand 
	"Present this menu at the given point under control of the given hand."
	| selectedItem i yOffset sub delta |

	hand resetClickState.
	self changed.

	popUpOwner _ hand.
	originalEvent _ hand lastEvent.
	selectedItem _ self items detect: [:each | each == lastSelection]
				ifNone: [self items isEmpty
						ifTrue: [^ self]
						ifFalse: [self items first]].
	"Note: items may not be laid out yet (I found them all to be at 0@0), 
	so have to add up heights of items above the selected item."
	i _ 0.
	yOffset _ 0.
	[(sub _ self submorphs at: (i _ i + 1)) == selectedItem]
		whileFalse: [yOffset _ yOffset + sub height].
	self position: aPoint - (0 @ (yOffset + 8)).
	self bounds right > hand worldBounds right
		ifTrue: [self position: self position - (self bounds width @ 0)].
	delta _ self bounds amountToTranslateWithin: hand worldBounds.
	delta = (0 @ 0) ifFalse: [self position: self position + delta].
	hand world addMorphFront: self; startSteppingSubmorphsOf: self.
	hand newMouseFocus: selectedItem.
	self changed! !

!MenuMorph methodsFor: 'control' stamp: 'EMP 12/12/2015 18:18'!
popUpAt: aPoint forHand: hand from: sourceItem
	"Present this menu at the given point under control of the given hand."

	| selectedItem delta |
	popUpOwner _ sourceItem.
	originalEvent _ hand lastEvent.
	selectedItem _ self selectedItem.
	self fullBounds.  "ensure layout is current"
	self position: aPoint - (selectedItem position - self position).
	sourceItem owner owner addMorphFront: self.
	delta _ self fullBoundsInWorld amountToTranslateWithin: hand worldBounds.
	delta = (0@0) ifFalse: [self position: self position + delta]! !

!MenuMorph methodsFor: 'control' stamp: 'sma 6/5/2000 13:50'!
popUpForHand: hand 
	"Present this menu under control of the given hand."

	self popUpAt: hand position forHand: hand! !

!MenuMorph methodsFor: 'control' stamp: 'jm 12/7/2005 09:49'!
popUpNearHand

	| hand |
	hand _ self currentWorld activeHand.
	self popUpAt: hand position forHand: hand.
! !

!MenuMorph methodsFor: 'control' stamp: 'jm 7/1/2004 22:29'!
willingToBeEmbeddedUponLanding

	^ false
! !


!MenuMorph methodsFor: 'layout' stamp: 'jm 11/4/97 07:15'!
minHeightWhenEmpty

	^ 10
! !

!MenuMorph methodsFor: 'layout' stamp: 'jm 11/4/97 07:15'!
minWidthWhenEmpty

	^ 20
! !


!MenuMorph methodsFor: 'menu' stamp: 'jm 11/4/97 07:46'!
addCustomMenuItems: aCustomMenu hand: aHandMorph

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	aCustomMenu add: 'add title...' action: #addTitle.
	aCustomMenu add: 'set target...' action: #setTarget:.
	defaultTarget ifNotNil: [
		aCustomMenu add: 'add item...' action: #addItem].
	aCustomMenu add: 'remove item' action: #removeItem:.
	aCustomMenu add: 'add line' action: #addLine.
	(self canDetachSubMenu: aHandMorph)
		ifTrue: [aCustomMenu add: 'detach submenu' action: #detachSubMenu:].
! !

!MenuMorph methodsFor: 'menu' stamp: 'jm 11/4/97 07:46'!
addItem

	| string sel |
	string _ FillInTheBlank request: 'Label for new item?'.
	string isEmpty ifTrue: [^ self].
	sel _ FillInTheBlank request: 'Selector?'.
	sel isEmpty ifFalse: [sel _ sel asSymbol].
	self add: string action: sel.
! !

!MenuMorph methodsFor: 'menu' stamp: 'jm 11/4/97 07:46'!
addTitle

	| string |
	string _ FillInTheBlank request: 'Title for this menu?'.
	string isEmpty ifTrue: [^ self].
	self addTitle: string.
! !

!MenuMorph methodsFor: 'menu' stamp: 'di 2/23/98 22:23'!
canDetachSubMenu: hand
	| possibleTargets item arg |
	(arg _ hand argumentOrNil) ifNil: [^ false].
	possibleTargets _ arg morphsAt: hand targetOffset.
	item _ possibleTargets
		detect: [:each | each isKindOf: MenuItemMorph]
		ifNone: [^ false].
	^ item subMenu notNil
! !

!MenuMorph methodsFor: 'menu' stamp: 'jm 11/4/97 07:46'!
detachSubMenu: evt

	| possibleTargets item subMenu |
	possibleTargets _ evt hand argumentOrNil morphsAt: evt hand targetOffset.
	item _ possibleTargets detect: [:each | each isKindOf: MenuItemMorph] ifNone: [^ self].
	subMenu _ item subMenu.
	subMenu ifNotNil: [
		item subMenu: nil.
		item delete.
		subMenu stayUp: true.
		subMenu popUpOwner: nil.
		subMenu addTitle: item contents.
		evt hand attachMorph: subMenu].
! !

!MenuMorph methodsFor: 'menu' stamp: 'jm 11/4/97 07:46'!
removeItem: evt

	| possibleTargets item |
	possibleTargets _ evt hand argumentOrNil morphsAt: evt hand targetOffset.
	item _ possibleTargets
		detect: [:each |
					(each isKindOf: MenuItemMorph) or:
					 [each isKindOf: MenuLineMorph]]
		ifNone: [^ self].
	item delete.
! !

!MenuMorph methodsFor: 'menu' stamp: 'di 4/11/98 14:25'!
setInvokingView: invokingView
	"Re-work every menu item of the form
		<target> perform: <selector>
	to the form
		<target> perform: <selector> orSendTo: <invokingView>.
	This supports MVC's vectoring of non-model messages to the editPane."
	self items do:
		[:item |
		item arguments isEmpty ifTrue:  "only the simple messages"
			[item arguments: (Array with: item selector with: invokingView).
			item selector: #perform:orSendTo:]]! !

!MenuMorph methodsFor: 'menu' stamp: 'jm 11/4/97 07:46'!
setTarget: evt
	"Set the default target object to be used for add item commands, and re-target all existing items to the new target or the the invoking hand."

	| rootMorphs old |
	rootMorphs _ self world rootMorphsAt: evt hand targetOffset.
	rootMorphs size > 1
		ifTrue: [defaultTarget _ rootMorphs at: 2]
		ifFalse: [^ self].
	"re-target all existing items"
	self items do: [:item |
		old _ item target.
		old isHandMorph
			ifTrue: [item target: evt hand. evt hand setArgument: defaultTarget]
			ifFalse: [item target: defaultTarget]].
! !

!MenuMorph methodsFor: 'menu' stamp: 'jm 10/15/2002 17:18'!
toggleStayUp: evt
	"Toggle my 'stayUp' flag and adjust the menu item to reflect its new state."

	self items do: [:item |
		item selector = #toggleStayUp: ifTrue:
			[stayUp _ stayUp not.	
			 stayUp
				ifTrue: [item contents: 'dismiss this menu']
				ifFalse: [item contents: 'keep this menu up']]].
	stayUp ifFalse: [self delete].
! !


!MenuMorph methodsFor: 'event handling' stamp: 'jm 5/2/2009 18:03'!
handlesMouseDown: evt

	^ true
! !

!MenuMorph methodsFor: 'event handling' stamp: 'jm 5/2/2009 18:08'!
mouseDown: evt
	"Do nothing. This is to prevent picking up the menu."
! !


!MenuMorph methodsFor: 'private' stamp: 'EMP 12/3/2015 14:56'!
positionAt: aPoint
	"Note: items may not be laid out yet (I found them all to be at 0@0),  
	so we have to add up heights of items above the selected item."

	| i yOffset selectedItem sub delta |
	i _ 0.
	yOffset _ 0.
	selectedItem _ self selectedItem.
	[(sub _ self submorphs at: (i _ i + 1)) == selectedItem]
		whileFalse: [yOffset _ yOffset + sub height].

	self position: aPoint - (2 @ (yOffset + 8)).

	"If it doesn't fit, show it to the left, not to the right of the hand."
	self right > popUpOwner worldBounds right
		ifTrue: [self left: self left - self width + 4].

	"Make sure that the menu fits in the world."
	delta _ self bounds amountToTranslateWithin: popUpOwner worldBounds.
	delta = (0 @ 0) ifFalse: [self position: self position + delta]! !

!MenuMorph methodsFor: 'private' stamp: 'sma 6/5/2000 14:42'!
positionAt: aPoint relativeTo: selectedItem
	"Note: items may not be laid out yet (I found them all to be at 0@0),  
	so we have to add up heights of items above the selected item."

	| i yOffset sub delta |
	i _ 0.
	yOffset _ 0.
	[(sub _ self submorphs at: (i _ i + 1)) == selectedItem]
		whileFalse: [yOffset _ yOffset + sub height].

	self position: aPoint - (2 @ (yOffset + 8)).

	"If it doesn't fit, show it to the left, not to the right of the hand."
	self right > popUpOwner worldBounds right
		ifTrue: [self left: self left - self width + 4].

	"Make sure that the menu fits in the world."
	delta _ self bounds amountToTranslateWithin: popUpOwner worldBounds.
	delta = (0 @ 0) ifFalse: [self position: self position + delta]! !

!MenuMorph methodsFor: 'private' stamp: 'sma 6/5/2000 14:38'!
selectedItem
	| items |
	items _ self items.
	^ items detect: [:each | each == lastSelection] ifNone: [items first]! !


!MenuMorph methodsFor: 'drawing' stamp: 'EMP 12/4/2015 12:06'!
bounds
	^ super bounds extendBy: (3@3)! !

!MenuMorph methodsFor: 'drawing' stamp: 'EMP 12/12/2015 18:22'!
changed
	"Report that the area occupied by this morph should be redrawn."

	self invalidRect: (self fullBounds expandBy: 3@3).
! !

!MenuMorph methodsFor: 'drawing' stamp: 'EMP 12/4/2015 12:08'!
drawOn: aCanvas

	color isTransparent ifTrue: [^ self].
	aCanvas fillRectangle: (bounds) color: color.
! !

!MenuMorph methodsFor: 'drawing' stamp: 'EMP 12/4/2015 15:34'!
fullDrawOn: aCanvas

	| shadowOrigin topShadowExtent leftShadowExtent alphas |
	super fullDrawOn: aCanvas.

	(self hasProperty: #errorOnDraw) ifTrue:[^ self].

	"shadow constants"
	shadowOrigin _ self topLeft + aCanvas origin.
	topShadowExtent _ (self width - 2)@1.
	leftShadowExtent _ 1@(self height - 2).

	"shadow alpha values"
	alphas _ FloatArray
		with: 0.51
		with: 0.26
		with: 0.07.

	"outer shadow: bottom"
	
	shadowOrigin _ self bottomLeft + (2 @ 0) + aCanvas origin.
	
	1 to: 3 do: [:i |
		aCanvas grafPort
			fill: (shadowOrigin + (0@(i-1)) extent: topShadowExtent)
			fillColor: (Color black alpha: (alphas at: i))
			rule: Form blend].

	"outer shadow: side"
	shadowOrigin _ self topRight + (0 @ 2) + aCanvas origin.
	1 to: 3 do: [:i |
		aCanvas grafPort
			fill: (shadowOrigin + ((i-1)@0) extent: leftShadowExtent)
			fillColor: (Color black alpha: (alphas at: i))
			rule: Form blend].
	self shadowDrawOn: aCanvas alphas: alphas


! !

!MenuMorph methodsFor: 'drawing' stamp: 'EMP 12/4/2015 12:24'!
shadowDrawOn: aCanvas
	| shadowOrigin |
	shadowOrigin _ self bottomRight + aCanvas origin.
	"corner shadow fix"
	aCanvas grafPort
		fill: (shadowOrigin extent: (3@3))
		fillColor: (Color white)
		rule: Form blend.

	aCanvas grafPort
		fill: (shadowOrigin +(0@1) extent: (1@1))
		fillColor: (Color white)
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin + (1@0) extent: (1@1))
		fillColor: (Color white)
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin +(0@2) extent: (1@1))
		fillColor: (Color white)
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin + (2@0) extent: (1@1))
		fillColor: (Color white)
		rule: Form blend.

! !

!MenuMorph methodsFor: 'drawing' stamp: 'EMP 12/4/2015 15:32'!
shadowDrawOn: aCanvas alphas: alphaList
	| shadowOrigin |
	shadowOrigin _ self bottomRight + aCanvas origin.
	"corner shadow fix No need to fill white anymore...
	aCanvas grafPort
		fill: (shadowOrigin extent: (3@3))
		fillColor: (Color white)
		rule: Form blend."

	aCanvas grafPort
		fill: (shadowOrigin + (0@0) extent: (1@1))
		fillColor: (Color black alpha: (alphaList at: 1))
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin + (1@0) extent: (1@1))
		fillColor: (Color black alpha: (alphaList at: 2))
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin +(0@1) extent: (1@1))
		fillColor: (Color black alpha: (alphaList at: 2))
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin + (2@0) extent: (1@1))
		fillColor: (Color black alpha: (alphaList at: 3))
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin + (0@2) extent: (1@1))
		fillColor: (Color black alpha: (alphaList at: 3))
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin + (3@3) extent: (1@1))
		fillColor: (Color black alpha: (alphaList at: 3))
		rule: Form blend.

! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

MenuMorph class
	instanceVariableNames: ''!

!MenuMorph class methodsFor: 'example' stamp: 'jm 11/4/97 07:46'!
example
	"MenuMorph example"

	| menu |
	menu _ MenuMorph new.
	menu addStayUpItem.
	menu add: 'apples' action: #apples.
	menu add: 'oranges' action: #oranges.
	menu addLine.
	menu addLine.  "extra lines ignored"
	menu add: 'peaches' action: #peaches.
	menu addLine.
	menu add: 'pears' action: #pears.
	menu addLine.
	^ menu
! !


!MenuMorph class methodsFor: 'instance creation' stamp: 'jm 5/14/1998 17:21'!
entitled: aString
	"Answer a new instance of me with the given title."

	^ self new addTitle: aString
! !
