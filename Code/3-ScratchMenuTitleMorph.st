StringMorph subclass: #ScratchMenuTitleMorph
	instanceVariableNames: 'target selector '
	classVariableNames: 'MenuBarIsActive '
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ScratchMenuTitleMorph methodsFor: 'initialization' stamp: 'EMP 10/9/2015 13:45'!
initialize

	super initialize.
	self
		font: (ScratchFrameMorph getFont: #MenuTitle);
		forceUnicodeRendering: true;
		color: self normalColor.
! !


!ScratchMenuTitleMorph methodsFor: 'accessing'!
highlightColor

	^ Color orange lighter! !

!ScratchMenuTitleMorph methodsFor: 'accessing'!
normalColor

	^ Color white
! !

!ScratchMenuTitleMorph methodsFor: 'accessing' stamp: 'jm 11/10/2008 12:48'!
selector

	^ selector
! !

!ScratchMenuTitleMorph methodsFor: 'accessing' stamp: 'jm 10/28/2008 12:50'!
target: anObject selector: aSymbol

	target _ anObject.
	selector _ aSymbol.
! !


!ScratchMenuTitleMorph methodsFor: 'event handling' stamp: 'jm 10/28/2008 11:34'!
handlesMouseDown: evt

	^ true
! !

!ScratchMenuTitleMorph methodsFor: 'event handling' stamp: 'jm 10/28/2008 11:39'!
handlesMouseOver: evt

	^ true
! !

!ScratchMenuTitleMorph methodsFor: 'event handling' stamp: 'jens 3/7/2009 22:24'!
mouseDown: evt

	target isNil | selector isNil ifTrue: [^ self].
	Cursor normal show.
	MenuBarIsActive _ true.
	target perform: selector with: self.  "invoke my menu"
! !

!ScratchMenuTitleMorph methodsFor: 'event handling'!
mouseEnter: evt

	self color: self highlightColor.
	self class menuBarIsActive ifTrue: [
		self class closeAllMenus.
		MenuBarIsActive _ true.
		((((self selector = #tipsScreens:) = true) or: [((self selector = #aboutScratch:) = true)])) ifFalse: [
		target perform: selector with: self ]
ifTrue: [MenuBarIsActive _ false]]  "invoke my menu if not the tip/about screen selector"
! !

!ScratchMenuTitleMorph methodsFor: 'event handling' stamp: 'jm 10/28/2008 12:25'!
mouseLeave: evt

	self color: self normalColor.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchMenuTitleMorph class
	instanceVariableNames: ''!

!ScratchMenuTitleMorph class methodsFor: 'as yet unclassified' stamp: 'jens 3/11/2009 21:25'!
closeAllMenus

	self menuBarIsActive ifFalse: [^self ].
	World submorphs do: [:m |
		(m isKindOf: MenuMorph) ifTrue: [m deleteIfPopUp]].
	MenuBarIsActive _ false.
! !

!ScratchMenuTitleMorph class methodsFor: 'as yet unclassified' stamp: 'jens 3/18/2009 17:20'!
deactivateMenuBar

	MenuBarIsActive _ false.
! !

!ScratchMenuTitleMorph class methodsFor: 'as yet unclassified' stamp: 'jens 3/7/2009 22:22'!
menuBarIsActive

	^ MenuBarIsActive ifNil: [MenuBarIsActive _ false].
! !
