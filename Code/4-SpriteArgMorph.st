ArgMorph subclass: #SpriteArgMorph
	instanceVariableNames: 'menuIconMorph morph type '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!SpriteArgMorph commentStamp: '<historical>' prior: 0!
I represent a scriptable scratch morph argument for a command block.  Clicking on me and then another point on the screen allows the user to set my value to the scriptable scratch morph that has been clicked on.!


!SpriteArgMorph methodsFor: 'initialize' stamp: 'EMP 4/8/2016 17:13'!
initialize

	super initialize.
	self borderInset.
	self borderWidth: 1.
	self color: Color white.
	type _ #spriteOrStage.

	labelMorph _ StringMorph new
		font: (ScratchFrameMorph getFont: #Arg);
		forceUnicodeRendering: true;
		color: Color white.
	self addMorph: labelMorph.
	((labelMorph extent y) > 15)
		ifTrue: [ self extent: 20@((labelMorph extent y) + 3) ]
		ifFalse: [ self extent: 20@15 ].
	menuIconMorph _ ImageMorph new form: DropDownMenuForm.
	self addMorphFront: menuIconMorph.

	morph _ nil.
	self updateLabel.
! !

!SpriteArgMorph methodsFor: 'initialize' stamp: 'EMP 4/9/2016 15:12'!
type
	^ type! !

!SpriteArgMorph methodsFor: 'initialize' stamp: 'EMP 4/9/2016 15:12'!
type: aSymbol
	type _ aSymbol! !


!SpriteArgMorph methodsFor: 'event handling' stamp: 'jm 4/18/2008 14:10'!
fixGetAttribueBlock
	"If my owner is a get attribute block, make sure that the attribute is consistent the the type of the target sprite or stage."

	| attributeArg possibleAttributes |
	morph ifNil: [^ self].
	((owner isKindOf: ReporterBlockMorph) and: [owner selector = #getAttribute:of:]) ifFalse: [^ self].

	attributeArg _ owner submorphs detect: [:m | m isKindOf: AttributeArgMorph] ifNone: [^ self].

	possibleAttributes _ morph attributeNames, morph varNames.
	(possibleAttributes includes: attributeArg choice) ifFalse: [
		 attributeArg choice: possibleAttributes first].
! !

!SpriteArgMorph methodsFor: 'event handling' stamp: 'jm 1/23/2007 12:33'!
handlesMouseDown: evt

	^ evt hand toolType isNil and:
		[(self topRight - (14@0) corner: self bottomRight) containsPoint: evt cursorPoint]
! !

!SpriteArgMorph methodsFor: 'event handling' stamp: 'jm 12/13/2006 21:28'!
mouseDown: evt

	self presentMenu.
! !

!SpriteArgMorph methodsFor: 'event handling' stamp: 'EMP 4/9/2016 15:42'!
presentMenu
	"Let the user select a Scratch object or the special value #mouse."

	| frame objList menu choice |
	(frame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self].


	objList _ frame scratchObjects.
	objList sort: [:obj1 :obj2 | obj1 objName asLowercase < obj2 objName asLowercase].

	menu _ CustomMenu new.
	(type = #spriteOrStage) ifTrue: [
			menu add: ('Stage' localized asUTF8) action: frame workPane.
			objList _ objList copyWithout: owner receiver].
	(type = #spriteOrMouse) ifTrue: [
		menu add: 'mouse-pointer' localized asUTF8 action: #mouse.
		objList _ objList copyWithout: owner receiver].
	(type = #touching) ifTrue: [
		menu add: 'edge' localized asUTF8 action: #edge.
		menu add: 'mouse-pointer' localized asUTF8 action: #mouse.
		objList _ objList copyWithout: owner receiver].
	(type = #spriteOnly) ifTrue: [
		(owner receiver isKindOf: ScratchStageMorph) ifFalse: [
			menu add: ('myself' localized asUTF8) action: #'_myself_'].
		objList _ objList copyWithout: owner receiver].
	(type = #location) ifTrue: [
		menu add: 'mouse-pointer' localized asUTF8 action: #mouse.
		menu add: 'random position' localized action: #'_random_'.
		objList _ objList copyWithout: owner receiver].

	objList size > 0 ifTrue: [menu addLine].
	objList do: [:obj | menu add: obj objName action: obj].
	menu color: (self color lighter); target: self.
	(choice _ menu startUpAt: (self bottomLeft + (0@10))) ifNil: [^ self].
	morph _ choice.
	self fixGetAttribueBlock.
	self updateLabel.
! !

!SpriteArgMorph methodsFor: 'event handling' stamp: 'jm 12/14/2004 11:55'!
wantsKeyboardFocusFor: aSubmorph
	"Don't allow shift-click editing of block labels."

	^ false
! !


!SpriteArgMorph methodsFor: 'stepping' stamp: 'jm 9/5/2006 11:20'!
step

	self updateLabel.
! !

!SpriteArgMorph methodsFor: 'stepping' stamp: 'jm 12/9/2008 16:29'!
stepTime

	^ 500
! !

!SpriteArgMorph methodsFor: 'stepping' stamp: 'EMP 3/22/2016 10:56'!
updateLabel
	"Update my label string."

	| s sel |
	(owner isKindOf: CommandBlockMorph) ifTrue: [sel _ owner selector].
	self checkForDeletedMorph.
	s _ ' '.
	(morph isKindOf: ScriptableScratchMorph) ifTrue: [s _ morph objName. ((morph = (owner receiver)) and: [(sel = #createCloneOf)]) ifTrue: [s _ 'myself' localized]].
	(morph isKindOf: String) ifTrue: [
		s _ morph localized.
		morph = #mouse ifTrue: [s _ 'mouse-pointer' localized].
		(morph = '_myself_') ifTrue: [s _ 'myself' localized].
		(morph = '_random_') ifTrue: [s _ 'random position' localized]].

	labelMorph contents = s ifFalse: [
		labelMorph contents: s.
		labelMorph position: self position + borderWidth + (3 @ -1).
		self extent: (labelMorph extent + (16@2) + borderWidth).
		menuIconMorph position: (self right - borderWidth - 10)@(self top + borderWidth + 4).
		(self ownerThatIsA: ScratchBlockPaletteMorph) ifNotNil: [
			(self ownerThatIsA: ScratchBlockPaletteMorph) fixLayout]].
! !


!SpriteArgMorph methodsFor: 'other' stamp: 'jm 3/27/2009 07:47'!
acceptsDroppedReporters

	^ true
! !

!SpriteArgMorph methodsFor: 'other' stamp: 'jm 3/27/2009 07:48'!
acceptsTypeOf: aBlockMorph
	"Answer true if I can accept a dropped reporter of the given type."

	aBlockMorph isReporter ifFalse: [^ false].
	^ aBlockMorph isBooleanReporter not
! !

!SpriteArgMorph methodsFor: 'other' stamp: 'jm 12/5/2007 14:37'!
checkForDeletedMorph
	"If I refer to a Sprite that has been deleted, nil out my morph field. Do nothing if my morph is a ScratchStageMorph"

	(morph isKindOf: Morph) ifFalse: [^ self].
	morph owner ifNotNil: [^ self].

	(morph isKindOf: ScratchStageMorph) ifTrue: [^ self].

	morph _ nil.  "nil out reference to deleted sprite"

! !

!SpriteArgMorph methodsFor: 'other' stamp: 'jm 12/10/2004 14:11'!
clearMorphReference
	"Clear my morph reference."

	(morph isKindOf: Morph) ifFalse: [^ self].
	morph _ nil.
	self updateLabel.
! !

!SpriteArgMorph methodsFor: 'other' stamp: 'jm 3/28/2005 15:14'!
defaultValue: aSpriteMorph

	morph _ aSpriteMorph.
! !

!SpriteArgMorph methodsFor: 'other' stamp: 'jm 9/5/2006 11:19'!
evaluate
	"Answer either nil, the symbol #mouse, or a Scratch sprite object."

	self checkForDeletedMorph.
	^ morph
! !

!SpriteArgMorph methodsFor: 'other' stamp: 'jm 3/28/2005 17:03'!
fixArgLayout
	"Set my color to my owner's color."

	self color: (owner color mixed: 0.7 with: (Color gray: 0.3)).
! !

!SpriteArgMorph methodsFor: 'other' stamp: 'jm 3/14/2009 13:53'!
printArgOn: aStream
	"Print this argument morph on the given stream."

	aStream nextPutAll: 's['.
	aStream nextPutAll: self labelMorph contents.
	aStream nextPut: $].
! !


!SpriteArgMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 18:34'!
fieldsVersion

	^ 1
! !

!SpriteArgMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 18:35'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		morph
	) from: anObjStream.
! !

!SpriteArgMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 18:39'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		morph
	) on: anObjStream.
! !
