ExpressionArgMorph subclass: #ExpressionArgMorphWithMenu
	instanceVariableNames: 'menuMorph getMenuSelector specialValue '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!ExpressionArgMorphWithMenu commentStamp: 'jm 3/28/2005 15:10' prior: 0!
I represent a literal value such as a number or string. I can be edited by typing or a value can be chosen from a pull-down menu.
!


!ExpressionArgMorphWithMenu methodsFor: 'accessing' stamp: 'jm 6/28/2008 12:02'!
defaultValue: anObject

	((#(listIndexMenu listIndexForDeleteMenu) includes: getMenuSelector) and:
	 [anObject isKindOf: String])
		ifTrue: [self specialValue: anObject]
		ifFalse: [super defaultValue: anObject].

! !

!ExpressionArgMorphWithMenu methodsFor: 'accessing' stamp: 'jm 5/8/2008 12:08'!
menuSelector

	^ getMenuSelector

! !

!ExpressionArgMorphWithMenu methodsFor: 'accessing' stamp: 'jm 12/17/2004 12:54'!
menuSelector: menuSelector
	"Add a drop-down menu button with the given selector. The selector should result in a menu whose action items are values that can be put into this type argument, typically numbers or strings."

	menuMorph _ ImageMorph new form: DropDownMenuForm.
	getMenuSelector _ menuSelector.
	self addMorphFront: menuMorph.
	self fixArgLayout.
! !

!ExpressionArgMorphWithMenu methodsFor: 'accessing' stamp: 'jm 8/4/2008 09:06'!
specialValue: aString
	"A special value is a menu selection such as 'last' for a list index that appears as a string in a number if field. If the user edits the field, then it only accepts numeric input. The argumet is retained in the specialValue instance variable."

	isNumber _ true.
	labelMorph contents: aString localized.
	labelMorph
		isNumeric: true;
		position: self position + (0@1).
	self fixArgLayout.
	specialValue _ aString.
! !


!ExpressionArgMorphWithMenu methodsFor: 'evaluation' stamp: 'jm 5/6/2008 18:57'!
evaluate
	"Answer the result of evaluating my expression in the context of the given ScratchProcess."

	specialValue ifNotNil: [^ specialValue].
	^ super evaluate
! !


!ExpressionArgMorphWithMenu methodsFor: 'event handling' stamp: 'jm 1/23/2007 12:37'!
handlesMouseDown: evt

	^ menuMorph notNil
! !

!ExpressionArgMorphWithMenu methodsFor: 'event handling' stamp: 'EMP 4/8/2016 16:01'!
mouseDown: evt

	| rcvr menu choice |
	menuMorph ifNil: [^ super mouseDown: evt].
	(evt cursorPoint x < (menuMorph left - 1)) ifTrue: [^ super mouseDown: evt].

	(getMenuSelector notNil and:
	 [(owner isKindOf: BlockMorph) and: 
	 [(rcvr _ owner receiver) notNil]]) ifFalse: [^ self beep].
	menu _ rcvr perform: getMenuSelector.
	(menu isKindOf: ScratchNoteSelector) ifTrue: [
		menu position: owner bottomLeft + (((owner width - menu width) // 2) @ -4)].
	menu color: ((self ownerThatIsA: BlockMorph) color lighter).
	(menu isKindOf: ScratchNoteSelector) ifFalse: [menu target: self].
	choice _ menu startUp.
	choice ifNil: [^ self].
	evt hand newKeyboardFocus: nil.  "close mini-editor, if any"

	(#(listIndexMenu listIndexForDeleteMenu) includes: getMenuSelector) ifTrue: [
		^ self specialValue: choice].

	isNumber
		ifTrue: [self numExpression: choice]
		ifFalse: [self stringExpression: choice].

! !


!ExpressionArgMorphWithMenu methodsFor: 'object i/o' stamp: 'jm 5/6/2008 19:21'!
fieldsVersion

	^ 2
! !

!ExpressionArgMorphWithMenu methodsFor: 'object i/o' stamp: 'jm 5/6/2008 19:23'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		menuMorph
		getMenuSelector
	) from: anObjStream.

	classVersion = 1 ifTrue: [^ self].

	"field added in version 2"
	self initFieldsNamed: #(
		specialValue
	) from: anObjStream.
! !

!ExpressionArgMorphWithMenu methodsFor: 'object i/o' stamp: 'jm 5/6/2008 19:22'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		menuMorph
		getMenuSelector
		specialValue
	) on: anObjStream.
! !


!ExpressionArgMorphWithMenu methodsFor: 'private' stamp: 'jm 7/4/2008 17:27'!
fixArgLayout

	| dx |
	dx _ 9.
	super fixArgLayout.
	menuMorph ifNil: [^ self].
	self width: self width + dx.
	menuMorph position: (self right - dx - 2)@(self top + (self height // 3)).
	(thisContext sender receiver isKindOf: StringFieldMorph) ifTrue: [
		"clear only when user edit my label, but not on other arg layout changes"
		specialValue _ nil].
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ExpressionArgMorphWithMenu class
	instanceVariableNames: ''!

!ExpressionArgMorphWithMenu class methodsFor: 'class initialization' stamp: 'jm 3/29/2005 20:43'!
initialize
	"self initialize"

	DropDownMenuForm _ Form
		extent: 7@4
		depth: 1
		fromArray: #(4261412864 2080374784 939524096 268435456)
		offset: 0@0.
	DropDownMenuForm _ DropDownMenuForm colorReduced.  "become a ColorForm"
	DropDownMenuForm colors:
		(Array with: Color transparent with: (Color gray: 0.25)).
! !


ExpressionArgMorphWithMenu initialize!
