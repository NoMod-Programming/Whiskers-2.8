StringMorph subclass: #MenuItemMorph
	instanceVariableNames: 'isInTransition isEnabled subMenu isSelected target selector arguments icon '
	classVariableNames: 'SubMenuMarker '
	poolDictionaries: ''
	category: 'Morphic-Menus'!

!MenuItemMorph methodsFor: 'initialization' stamp: 'jm 7/2/2008 20:41'!
initialize

	super initialize.
	bounds _ 0@0 extent: 10@10.
	color _ Color black.
	contents _ ''.
	hasFocus _ false.
	isEnabled _ true.
	subMenu _ nil.
	isSelected _ false.
	target _ nil.
	selector _ nil.
	arguments _ nil.
	font _ Preferences standardMenuFont.
	rightJustify _ ScratchTranslator isRTL.
! !


!MenuItemMorph methodsFor: 'accessing' stamp: 'jm 12/7/2005 09:36'!
adaptToWorld: aWorld

	super adaptToWorld: aWorld.
	target isMorph ifTrue: [
		target isWorldMorph ifTrue: [self target: aWorld].
		target isHandMorph ifTrue: [self target: aWorld activeHand]].
! !

!MenuItemMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
arguments

	^ arguments
! !

!MenuItemMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
arguments: aCollection

	arguments _ aCollection.
! !

!MenuItemMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
isEnabled

	^ isEnabled
! !

!MenuItemMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
isEnabled: aBoolean

	isEnabled = aBoolean ifTrue: [^ self].
	isEnabled _ aBoolean.
	self color: (aBoolean ifTrue: [Color black] ifFalse: [Color gray]).
! !

!MenuItemMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
selector

	^ selector
! !

!MenuItemMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
selector: aSymbol

	selector _ aSymbol.
! !

!MenuItemMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
subMenu

	^ subMenu
! !

!MenuItemMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
subMenu: aMenuMorph

	subMenu _ aMenuMorph.
	self changed.
! !

!MenuItemMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
target

	^ target! !

!MenuItemMorph methodsFor: 'accessing' stamp: 'jm 11/4/97 07:46'!
target: anObject

	target _ anObject.
! !


!MenuItemMorph methodsFor: 'drawing' stamp: 'EMP 12/3/2015 14:08'!
drawOn: aCanvas
	| selectionColor px py newIcon |
	isSelected & isEnabled
		ifTrue:
			[selectionColor _ Display depth <= 2
				ifTrue: [Color gray]
				ifFalse: [(owner color luminance > (0.8) ifTrue: [Color white darker] ifFalse: [owner color lighter lighter lighter])].
			aCanvas fillRectangle: self bounds color: selectionColor].
	super drawOn: aCanvas.
	subMenu ifNotNil:
		[aCanvas
			paintImage: SubMenuMarker
			at: self right - 8 @ (self top + self bottom - SubMenuMarker height // 2)].
	icon ifNotNil: [
		newIcon _ icon.
		newIcon _ self findIconsFor: icon.
		px _ self width - newIcon width // 2.
		py _ self height - newIcon height // 2.
		aCanvas
			paintImage: newIcon
			at: self position + (px @ py )]
		! !

!MenuItemMorph methodsFor: 'drawing' stamp: 'EMP 12/4/2015 11:58'!
findIconsFor: aForm
	| labels max maxWidth |
	"Edit menu... See file menu advice :P"
	labels _ #('Small stage layout' 'Turbo mode' 'fill screen' 'error catching').
	max  _ ''.
	labels do: [:m | (m size > max size) ifTrue: [max _ m]].
	maxWidth _ (ScratchFrameMorph checkBoxLabelled: max marked: false width: 0) width.
	(#(true false) evalStrings) do: [:bool | labels do: [:label | ((ScratchFrameMorph checkBoxLabelled: label marked: bool width: maxWidth) equals: aForm) ifTrue: [^ (ScratchFrameMorph checkBoxLabelled: label marked: bool width: maxWidth dark: isSelected not)]]].

	"File menu... Remember to put the largest possible string here to make sure the widths will come out the same"
	labels _ #('Force Help Files Update' 'Other blocks').
	max  _ ''.
	labels do: [:m | (m size > max size) ifTrue: [max _ m]].
	maxWidth _ (ScratchFrameMorph checkBoxLabelled: max marked: false width: 0) width.
	(#(true false) evalStrings) do: [:bool | labels do: [:label | ((ScratchFrameMorph checkBoxLabelled: label marked: bool width: maxWidth) equals: aForm) ifTrue: [^ (ScratchFrameMorph checkBoxLabelled: label marked: bool width: maxWidth dark: isSelected not)]]].

	^ aForm! !


!MenuItemMorph methodsFor: 'events' stamp: 'jm 11/4/97 07:15'!
handlesMouseDown: evt

	^ true
! !

!MenuItemMorph methodsFor: 'events' stamp: 'sw 6/24/1999 11:34'!
invokeWithEvent: evt
	"Perform the action associated with the given menu item."

	| selArgCount |
	self isEnabled ifFalse: [^ self].
	(owner isKindOf: MenuMorph) ifTrue: [owner lastSelection: selector].

	Cursor normal showWhile: [  "show cursor in case item opens a new MVC window"
		(selArgCount _ selector numArgs) = 0
			ifTrue:
				[target perform: selector]
			ifFalse:
				[selArgCount = arguments size
					ifTrue: [target perform: selector withArguments: arguments]
					ifFalse: [target perform: selector withArguments: (arguments copyWith: evt)]]]
! !

!MenuItemMorph methodsFor: 'events' stamp: 'sw 3/2/1999 13:39'!
mouseDown: evt
	"Handle a mouse down event. Menu items get activated when the mouse is over them."

	self isInMenu ifFalse: [^ super mouseDown: evt].
	evt shiftPressed ifTrue: [^ super mouseDown: evt].  "enable label editing" 
	(owner hasProperty: #paletteMenu)
		ifFalse:
			[self bringMenuChainToFront].
	self selectFromHand: evt hand
! !

!MenuItemMorph methodsFor: 'events' stamp: 'di 2/23/98 16:22'!
mouseMove: evt
	| m |
	m _ evt hand recipientForMouseDown: evt hand lastEvent.
	m == self
		ifTrue: [isSelected ifFalse: [m selectFromHand: evt hand]]
		ifFalse: [self deselectForNewMorph: m.
				((m isKindOf: MenuItemMorph) and: [m isInMenu]) ifTrue:
					[m selectFromHand: evt hand]].! !

!MenuItemMorph methodsFor: 'events' stamp: 'bf 11/23/1999 09:37'!
mouseUp: evt
	"Handle a mouse up event. Menu items get activated when the mouse is over them."

	| mouseInMe |
	mouseInMe _ self containsPoint: evt cursorPoint.
	self deselectItem.
	self isInMenu
		ifTrue:
			[(mouseInMe and: [self selector = #toggleStayUp:])
				ifFalse: [owner deleteIfPopUpFrom: self event: evt].
			subMenu ifNil:
				[mouseInMe ifTrue:
					[evt hand world displayWorld.
					owner invokeItem: self event: evt]]]
		ifFalse:  
			[self invokeWithEvent: evt]
			
			
! !


!MenuItemMorph methodsFor: 'layout' stamp: 'jm 11/4/97 07:46'!
hResizing

	^ #spaceFill
! !

!MenuItemMorph methodsFor: 'layout' stamp: 'di 5/7/1998 01:21'!
isAlignmentMorph

	^ true
! !

!MenuItemMorph methodsFor: 'layout' stamp: 'jens 3/25/2009 03:48'!
layoutInWidth: w height: h

	icon ifNotNil: [^self extent: ((icon extent) max: w@h) ].
	self extent: ((self stringExtent: contents) max: w@h).

! !

!MenuItemMorph methodsFor: 'layout' stamp: 'jens 3/27/2009 09:38'!
minHeight

	icon ifNotNil: [^icon height + 2].
	^ self extent y
! !

!MenuItemMorph methodsFor: 'layout' stamp: 'jens 3/27/2009 09:38'!
minWidth

	icon ifNotNil: [^icon width + 2].
	^ (self stringWidth: contents) + (subMenu == nil ifTrue: [0] ifFalse: [10])
! !

!MenuItemMorph methodsFor: 'layout' stamp: 'jm 11/4/97 07:46'!
vResizing

	^ #shrinkWrap
! !


!MenuItemMorph methodsFor: 'private' stamp: 'sw 6/20/1999 23:39'!
bringMenuChainToFront

	| menusToPopUp menu owningItem |
	menusToPopUp _ OrderedCollection new.
	menu _ self owner.
	[menu isKindOf: MenuMorph] whileTrue: [
		menusToPopUp addFirst: menu.
		owningItem _ menu popUpOwner.
		(owningItem isKindOf: MenuItemMorph)
			ifTrue: [menu _ owningItem owner]
			ifFalse: [menu _ nil]].
	menusToPopUp do: [:m | (m owner isKindOf: AlignmentMorph)
		ifFalse:
			[m owner addMorphFront: m]].
! !

!MenuItemMorph methodsFor: 'private' stamp: 'jm 11/4/97 07:46'!
deletePopupBackToCommonMenuWith: menuOrMenuItem

	| m menuToKeepUp owningItem |
	(menuOrMenuItem isKindOf: MenuMorph)
		ifTrue: [m _ menuOrMenuItem]
		ifFalse: [
			(menuOrMenuItem isKindOf: MenuItemMorph)
				ifTrue: [m _ menuOrMenuItem owner]
				ifFalse: [^ self]].

	menuToKeepUp _ IdentitySet new.
	[m isKindOf: MenuMorph] whileTrue: [
		menuToKeepUp add: m.
		owningItem _ m popUpOwner.
		(owningItem isKindOf: MenuItemMorph)
			ifTrue: [m _ owningItem owner]
			ifFalse: [m _ nil]].

	m _ self owner.
	[m isKindOf: MenuMorph] whileTrue: [
		(menuToKeepUp includes: m) ifTrue: [^ self].
		m stayUp ifFalse: [m delete].
		(m popUpOwner isKindOf: MenuItemMorph) ifTrue: [m popUpOwner isSelected: false].
		owningItem _ m popUpOwner.
		(owningItem isKindOf: MenuItemMorph)
			ifTrue: [m _ owningItem owner]
			ifFalse: [m _ nil]].
! !

!MenuItemMorph methodsFor: 'private' stamp: 'di 2/23/98 19:58'!
deselectForNewMorph: aMorph
	aMorph == owner
		ifTrue: [^ self isSelected: false].   "in my menu but not over any item"
	(aMorph == subMenu or: [aMorph owner == subMenu])
		ifTrue: [^ self].  "selecting my submenu or an item in it, leave me selected"

	self isSelected: false.
	subMenu ifNotNil: [subMenu stayUp ifFalse: [subMenu delete]].

	self deletePopupBackToCommonMenuWith: aMorph.
	aMorph owner ~= self owner ifFalse: [
		self deletePopupBackToCommonMenuWith: aMorph].
! !

!MenuItemMorph methodsFor: 'private' stamp: 'di 2/23/98 16:24'!
deselectItem
	| item |
	self isSelected: false.
	subMenu ifNotNil: [subMenu deleteIfPopUp].
	(owner isKindOf: MenuMorph) ifTrue:
		[item _ owner popUpOwner.
		(item isKindOf: MenuItemMorph) ifTrue: [item deselectItem]].
! !

!MenuItemMorph methodsFor: 'private' stamp: 'jm 11/4/97 07:46'!
hideSubmenu

	subMenu ifNotNil: [subMenu deleteIfPopUp].
	(owner isKindOf: MenuMorph) ifTrue: [owner deleteIfPopUp].
! !

!MenuItemMorph methodsFor: 'private' stamp: 'jens 3/25/2009 03:40'!
icon: aForm
	icon _ aForm.! !

!MenuItemMorph methodsFor: 'private' stamp: 'jm 11/4/97 07:46'!
isInMenu

	^ owner isKindOf: MenuMorph
! !

!MenuItemMorph methodsFor: 'private' stamp: 'jm 11/4/97 07:46'!
isSelected: aBoolean

	isSelected _ aBoolean.
	self changed.
! !

!MenuItemMorph methodsFor: 'private' stamp: 'EMP 12/9/2015 12:35'!
selectFromHand: aHand

	self isSelected: true.
	aHand newMouseFocus: self.
	subMenu ifNotNil: [
		subMenu delete.
		subMenu
			popUpAdjacentTo: (Array with: self bounds topRight + (3@0)
									with: self bounds topLeft)
			forHand: aHand
			from: self].
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

MenuItemMorph class
	instanceVariableNames: ''!

!MenuItemMorph class methodsFor: 'class initialization' stamp: 'jm 11/16/97 09:17'!
initialize
	"MenuItemMorph initialize"

	| f |
	f _ Form
		extent: 5@9
		fromArray: #(2147483648 3221225472 3758096384 4026531840 4160749568 4026531840 3758096384 3221225472 2147483648)
		offset: 0@0.
	SubMenuMarker _ ColorForm mappingWhiteToTransparentFrom: f.
! !


MenuItemMorph initialize!
