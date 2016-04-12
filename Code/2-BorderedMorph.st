Morph subclass: #BorderedMorph
	instanceVariableNames: 'borderWidth borderColor '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Basic'!
!BorderedMorph commentStamp: 'jm 6/15/2003 10:14' prior: 0!
I can have a border of zero or more pixels and a fill color. I have many subclasses.
!


!BorderedMorph methodsFor: 'initialization' stamp: 'sw 11/29/1999 17:35'!
initialize
	super initialize.
	borderColor _ Color black.
	borderWidth _ 2! !


!BorderedMorph methodsFor: 'accessing' stamp: 'sw 8/6/97 14:34'!
borderColor
	^ borderColor! !

!BorderedMorph methodsFor: 'accessing' stamp: 'jm 5/14/1998 11:07'!
borderColor: colorOrSymbolOrNil

	borderColor = colorOrSymbolOrNil ifFalse: [
		borderColor _ colorOrSymbolOrNil.
		self changed].
! !

!BorderedMorph methodsFor: 'accessing' stamp: 'di 6/20/97 11:24'!
borderInset
	self borderColor: #inset! !

!BorderedMorph methodsFor: 'accessing' stamp: 'di 6/20/97 11:25'!
borderRaised
	self borderColor: #raised! !

!BorderedMorph methodsFor: 'accessing' stamp: 'di 6/20/97 11:09'!
borderWidth
	^ borderWidth! !

!BorderedMorph methodsFor: 'accessing' stamp: 'di 6/4/1999 09:42'!
borderWidth: anInteger
	borderColor ifNil: [borderColor _ Color black].
	borderWidth _ anInteger max: 0.
	self changed! !

!BorderedMorph methodsFor: 'accessing' stamp: 'jm 10/12/2005 11:20'!
cornerStyle

	^ self valueOfProperty: #cornerStyle ifAbsent: [#square]
! !

!BorderedMorph methodsFor: 'accessing' stamp: 'sw 11/29/1999 17:32'!
cornerStyle: aSymbol
	aSymbol == #square
		ifTrue:
			[self removeProperty: #cornerStyle]
		ifFalse:
			[self setProperty: #cornerStyle toValue: aSymbol].
	self changed! !

!BorderedMorph methodsFor: 'accessing' stamp: 'jm 10/14/2002 07:54'!
doesBevels
	"Return true if this object can show bevelled borders (i.e., can have #raised or #inset as valid borderColors). This method should be overridden to return false by subclasses that do not support bevelled borders, such as EllipseMorph."

	^ true
! !

!BorderedMorph methodsFor: 'accessing' stamp: 'di 1/3/1999 12:24'!
hasTranslucentColor
	"Answer true if this any of this morph is translucent but not transparent."

	(color isColor and: [color isTranslucentColor]) ifTrue: [^ true].
	(borderColor isColor and: [borderColor isTranslucentColor]) ifTrue: [^ true].
	^ false
! !

!BorderedMorph methodsFor: 'accessing' stamp: 'jm 10/14/2002 07:53'!
isRectangular
	"Return true if this morph is rectangular. Rectangular morphs may or may not have rounded corners. This method should be overridden to return false by non-rectangular subclasses such as EllipseMorph."

	^ true
! !

!BorderedMorph methodsFor: 'accessing' stamp: 'sw 11/29/1999 17:36'!
toggleCornerRounding
	self cornerStyle == #rounded
		ifTrue: [self useSquareCorners]
		ifFalse: [self useRoundedCorners].
	self changed! !

!BorderedMorph methodsFor: 'accessing' stamp: 'sw 11/29/1999 17:36'!
useRoundedCorners
	self cornerStyle: #rounded! !

!BorderedMorph methodsFor: 'accessing' stamp: 'sw 11/29/1999 17:37'!
useSquareCorners
	self cornerStyle: #square! !


!BorderedMorph methodsFor: 'drawing' stamp: 'jm 10/9/2002 07:34'!
areasRemainingToFill: aRectangle

	(color isColor and: [color isTranslucent]) ifTrue: [^ Array with: aRectangle].
	self isRectangular ifFalse: [^ Array with: aRectangle].

	self wantsRoundedCorners
	ifTrue: [(borderWidth > 0 and: [borderColor isColor and: [borderColor isTranslucent]])
				ifTrue: [^ aRectangle areasOutside: (self innerBounds intersect: self boundsWithinCorners)]
				ifFalse: [^ aRectangle areasOutside: self boundsWithinCorners]]
	ifFalse: [(borderWidth > 0 and: [borderColor isColor and: [borderColor isTranslucent]])
				ifTrue: [^ aRectangle areasOutside: self innerBounds]
				ifFalse: [^ aRectangle areasOutside: self bounds]]! !

!BorderedMorph methodsFor: 'drawing' stamp: 'di 3/25/2000 11:13'!
boundsWithinCorners

	^ CornerRounder rectWithinCornersOf: self bounds! !

!BorderedMorph methodsFor: 'drawing' stamp: 'jm 11/24/2002 10:34'!
drawOn: aCanvas 
	"Draw a rectangle with a solid, inset, or raised border.
	Note: the raised border color is generated from the receiver's own color,
	while the inset border color is generated from the color of its owner.
	This behavior is visually more consistent. Thanks to Hans-Martin Mosner."

	| insetColor |
	borderWidth = 0 ifTrue: [  "no border"
		"Note: This is the hook for border styles.
			When converting to the new borders we'll just put 0 into the borderWidth"
		super drawOn: aCanvas.
		^ self].

	borderColor == #raised ifTrue: [
		"Use a hack for now"
		aCanvas fillRectangle: self bounds color: color.
		^ aCanvas frameAndFillRectangle: bounds
			fillColor: Color transparent
			borderWidth: borderWidth
			topLeftColor: (borderWidth = 1 ifTrue: [color twiceLighter]
										ifFalse: [color lighter])
			bottomRightColor: (borderWidth = 1 ifTrue: [color twiceDarker]
										ifFalse: [color darker])].

	borderColor == #inset ifTrue: [
		insetColor _ owner colorForInsets.
		aCanvas fillRectangle: self bounds color: color.
		^ aCanvas frameAndFillRectangle: bounds
			fillColor: Color transparent
			borderWidth: borderWidth
			topLeftColor: (borderWidth = 1 ifTrue: [insetColor twiceDarker]
										ifFalse: [insetColor darker])
			bottomRightColor: (borderWidth = 1 ifTrue: [insetColor twiceLighter]
										ifFalse: [insetColor lighter])].

	"solid color border"
	aCanvas fillRectangle: (self bounds insetBy: borderWidth) color: color.
	aCanvas frameAndFillRectangle: bounds
		fillColor: Color transparent
		borderWidth: borderWidth
		borderColor: borderColor.! !

!BorderedMorph methodsFor: 'drawing' stamp: 'EMP 1/4/2016 14:27'!
fullDrawOn: aCanvas

	(self wantsRoundedCorners & (self height > 10))
		ifTrue: [self fullDrawWithRoundedCornersOn: aCanvas]
		ifFalse: [super fullDrawOn: aCanvas].
! !

!BorderedMorph methodsFor: 'drawing' stamp: 'EMP 1/8/2016 16:37'!
fullDrawWithRoundedCornersOn: aCanvas
	(self ownerThatIsA: InlinePaintFrame) ifNotNil: [(self ownerThatIsA: PaintColorSquarePicker) ifNotNil: [^ super fullDrawOn: aCanvas]].
	CornerRounder roundCornersOf: self on: aCanvas
		displayBlock: [super fullDrawOn: aCanvas]
		borderWidth: borderWidth! !

!BorderedMorph methodsFor: 'drawing' stamp: 'EMP 12/22/2015 15:55'!
wantsRoundedCorners
	^ self cornerStyle == #rounded! !


!BorderedMorph methodsFor: 'geometry' stamp: 'di 6/20/97 11:15'!
innerBounds
	^ bounds insetBy: borderWidth! !


!BorderedMorph methodsFor: 'menu' stamp: 'jm 10/9/2002 07:30'!
addCustomMenuItems: aCustomMenu hand: aHandMorph

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addList: #(
		('border color...' changeBorderColor:)
		('border width...' changeBorderWidth:)).

	self doesBevels ifTrue: [
		borderColor == #raised ifFalse: [aCustomMenu add: 'raised bevel' action: #borderRaised].
		borderColor == #inset ifFalse: [aCustomMenu add: 'inset bevel' action: #borderInset].
		((borderColor == #raised) or: [borderColor == #inset]) ifTrue: [
			aCustomMenu add: 'no bevel...' action: #changeBorderColor:]].

	self isRectangular ifTrue: [
		aCustomMenu addUpdating: #roundedCornersString target: self action: #toggleCornerRounding].
! !

!BorderedMorph methodsFor: 'menu' stamp: 'jm 12/7/2005 09:34'!
changeBorderColor: evt

	| aHand |
	aHand _ evt ifNotNil: [evt hand] ifNil: [self activeHand].
	aHand changeColorTarget: self selector: #borderColor: originalColor: self borderColor.
! !

!BorderedMorph methodsFor: 'menu' stamp: 'jm 12/7/2005 09:35'!
changeBorderWidth: evt

	| handle origin aHand |
	aHand _ evt ifNil: [self activeHand] ifNotNil: [evt hand].
	origin _ aHand gridPointRaw.
	handle _ HandleMorph new forEachPointDo:
		[:newPoint | handle removeAllMorphs.
		handle addMorph:
			(PolygonMorph vertices: (Array with: origin with: newPoint)
				color: Color black borderWidth: 1 borderColor: Color black).
		self borderWidth: (newPoint - origin) r asInteger // 5].
	aHand attachMorph: handle.
	handle startStepping! !

!BorderedMorph methodsFor: 'menu' stamp: 'sw 11/29/1999 17:34'!
roundedCornersString
	"Answer the string to put in a menu that will invite the user to switch to the opposite  corner-rounding mode"
	^ self cornerStyle  == #rounded
		ifTrue:
			['stop rounding corners']
		ifFalse:
			['start rounding corners']
			! !


!BorderedMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 17:26'!
fieldsVersion

	^ 1
! !

!BorderedMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 17:26'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		borderWidth
		borderColor
	) from: anObjStream.
! !

!BorderedMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 17:27'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		borderWidth
		borderColor
	) on: anObjStream.
! !


!BorderedMorph methodsFor: 'private' stamp: 'di 6/20/97 11:21'!
setBorderWidth: w borderColor: bc
	self borderWidth: w.
	self borderColor: bc.! !

!BorderedMorph methodsFor: 'private' stamp: 'di 6/20/97 11:22'!
setColor: c borderWidth: w borderColor: bc
	self color: c.
	self borderWidth: w.
	self borderColor: bc.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

BorderedMorph class
	instanceVariableNames: ''!

!BorderedMorph class methodsFor: 'as yet unclassified' stamp: 'jm 5/31/2003 20:03'!
includeInNewMorphMenu

	^ true
! !
