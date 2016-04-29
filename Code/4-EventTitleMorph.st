ArgMorph subclass: #EventTitleMorph
	instanceVariableNames: 'menuIconMorph '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!EventTitleMorph commentStamp: 'jm 3/28/2005 15:16' prior: 0!
I am used as the title for a named event hat. I have a popup list of events that includes a way to type in a new event name.

Unlike other kind of ArgMorph, I can't be replaced with a reporter.

!


!EventTitleMorph methodsFor: 'initialization' stamp: 'EMP 4/6/2016 15:10'!
initialize

	super initialize.
	self borderInset.
	self borderWidth: 1.
	self color: Color brown.

	menuIconMorph _ ImageMorph new form: DropDownMenuForm.
	self addMorphFront: menuIconMorph.

	labelMorph _ StringMorph new
		font: (ScratchFrameMorph getFont: #Arg);
		forceUnicodeRendering: true;
		color: Color white.
	self addMorph: labelMorph.
	self eventName: 'message1'.
! !


!EventTitleMorph methodsFor: 'accessing' stamp: 'jm 3/28/2005 15:21'!
defaultValue: aString

	self eventName: aString.
! !

!EventTitleMorph methodsFor: 'accessing' stamp: 'jm 12/17/2004 17:01'!
evaluate

	^ self eventName
! !

!EventTitleMorph methodsFor: 'accessing' stamp: 'jm 8/11/2004 18:42'!
eventName

	^ labelMorph contents
! !

!EventTitleMorph methodsFor: 'accessing' stamp: 'ee 4/2/2008 15:29'!
eventName: aString

	| block |
	labelMorph contents: aString asString.
	labelMorph position: self position + borderWidth + (3 @ -1).
	self extent: (labelMorph extent + (16@2) + borderWidth).
	menuIconMorph position: (self right - borderWidth - 10)@(self top + borderWidth + 4).

	(block _ self ownerThatIsA: HatBlockMorph) ifNotNil: [
		block fixBlockLayout].
! !

!EventTitleMorph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:32'!
eventNameMatches: t1 
	^ labelMorph contents sameAs: t1! !

!EventTitleMorph methodsFor: 'accessing' stamp: 'jm 4/1/2005 20:34'!
fixArgLayout
	"Set my color to my owner's color."

	self color: (owner color mixed: 0.75 with: (Color gray: 0.4)).
! !

!EventTitleMorph methodsFor: 'accessing' stamp: 'jm 10/30/2005 08:40'!
printArgOn: aStream
	"Print this argument morph on the given stream."

	aStream nextPut: $".
	aStream nextPutAll: self labelMorph contents.
	aStream nextPut: $".
! !


!EventTitleMorph methodsFor: 'queries' stamp: 'jm 5/15/2008 13:44'!
acceptsDroppedReporters
	"Accept reporter blocks in broadcast blocks but not in 'when I receive' hat block."

	^ owner isKindOf: CommandBlockMorph
! !

!EventTitleMorph methodsFor: 'queries' stamp: 'jm 5/15/2008 13:40'!
acceptsTypeOf: aBlockMorph
	"Answer true if I can accept a dropped reporter of the given type."

	aBlockMorph isReporter ifFalse: [^ false].
	^ aBlockMorph isBooleanReporter not
! !


!EventTitleMorph methodsFor: 'event handling' stamp: 'jm 1/23/2007 12:31'!
handlesMouseDown: evt

	^ evt hand toolType isNil and:
		[(self topRight - (14@0) corner: self bottomRight) containsPoint: evt cursorPoint]
! !

!EventTitleMorph methodsFor: 'event handling' stamp: 'jm 12/13/2006 21:33'!
mouseDown: evt

	self presentMenu.
! !

!EventTitleMorph methodsFor: 'event handling' stamp: 'EMP 10/11/2015 20:06'!
presentMenu
	"Pop up a menu of choices."

	| eventNames sFrame menu choice s |
	eventNames _ #().
	(sFrame _ self ownerThatIsA: ScratchFrameMorph)
		ifNotNil: [eventNames _ sFrame workPane allEventNames].

	menu _ CustomMenu new color: (self color twiceLighter lighter).
	eventNames do: [:n | menu add: n action: n asString].
	menu addLine.
	menu add: ('new' localized, ScratchTranslator ellipsesSuffix) action: #newEvent.
	menu color: (self color lighter); target: self.
	(choice _ menu startUp) ifNil: [^ self].
	choice == #newEvent ifTrue: [
		s _ StringDialog ask: 'Message name:'.
		s size = 0 ifTrue: [^ self].
		^ self eventName: s].

	self eventName: choice.
! !

!EventTitleMorph methodsFor: 'event handling' stamp: 'jm 12/14/2004 11:53'!
wantsKeyboardFocusFor: aSubmorph
	"Don't allow shift-click editing of block labels."

	^ false
! !


!EventTitleMorph methodsFor: 'object i/o' stamp: 'jm 5/11/2005 10:49'!
fieldsVersion

	^ super fieldsVersion
! !
