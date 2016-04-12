ArgMorph subclass: #ExpressionArgMorph
	instanceVariableNames: 'isNumber '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!ExpressionArgMorph commentStamp: 'jm 6/21/2004 13:29' prior: 0!
I represent a literal value such as a number or string. I can be edited.
!


!ExpressionArgMorph methodsFor: 'initialization' stamp: 'jm 7/4/2008 13:23'!
initialize

	super initialize.
	isNumber _ true.
	self borderWidth: 1.
	self borderInset.
	self color: (Color gray: 0.95).
	self extent: 25@12.

	"To allow for editing in place."
	labelMorph _ StringFieldMorph new
		forExpressionArg;
		doResizing: true;
		font: (ScratchFrameMorph getFont: #Arg);
		color: Color transparent.
	self addMorph: labelMorph.
	self numExpression: '10'.
! !


!ExpressionArgMorph methodsFor: 'accessing' stamp: 'jm 5/7/2009 13:29'!
defaultValue: anObject

	anObject isNumber ifTrue: [self numExpression: anObject].
	(anObject isKindOf: String) ifTrue: [self stringExpression: anObject].
! !

!ExpressionArgMorph methodsFor: 'accessing' stamp: 'jm 5/7/2009 13:13'!
defaultValueFromSpec: anObject
	"Like defaultValue:, but '-' in a block spec creates an empty number expression."

	self defaultValue: anObject.
	'-' asUTF8 = anObject ifTrue: [self numExpression: ' '].  "empty, evaluates to zero"
! !

!ExpressionArgMorph methodsFor: 'accessing' stamp: 'jm 7/1/2008 11:44'!
numExpression: aNumber

	isNumber _ true.
	labelMorph isNumeric: true.

	aNumber isFloat
		ifTrue: [labelMorph contents: aNumber printStringNoExponent]
		ifFalse: [labelMorph contents: aNumber asString].
	self fixArgLayout.
! !

!ExpressionArgMorph methodsFor: 'accessing' stamp: 'EMP 4/10/2016 15:29'!
showDeleteButton: aBoolean! !

!ExpressionArgMorph methodsFor: 'accessing' stamp: 'jm 7/1/2008 11:45'!
stringExpression: aString

	isNumber _ false.
	labelMorph isNumeric: false.
	labelMorph contents: aString.
	self fixArgLayout.
! !


!ExpressionArgMorph methodsFor: 'queries' stamp: 'jm 7/7/2004 00:24'!
acceptsDroppedReporters

	^ true
! !

!ExpressionArgMorph methodsFor: 'queries' stamp: 'EMP 3/22/2016 10:42'!
acceptsTypeOf: aBlockMorph
	"Answer true if I can accept a dropped reporter of the given type."

	^ aBlockMorph isReporter! !


!ExpressionArgMorph methodsFor: 'drawing' stamp: 'EMP 11/24/2015 14:56'!
drawOn: aCanvas 

	| darkerC right topY bottomY radius xInset c |
	isNumber ifFalse: [super drawOn: aCanvas. ^ self drawShadowsOn: aCanvas].

	darkerC _ Color gray.
	right _ self width.
	topY _ bottomY _ radius _ self height // 2.
	self height even ifTrue: [topY _ bottomY - 1].
	[topY >= 0] whileTrue: [
		xInset _ radius - (radius squared - (radius - topY - 1) squared) sqrt rounded.

		self drawHLineFrom: xInset to: (xInset + 1) y: topY color: darkerC on: aCanvas.
		c _ (topY < 1) ifTrue: [darkerC] ifFalse: [Color white].
		self drawHLineFrom: xInset + 1 to: right - (xInset + 1) y: topY color: c on: aCanvas.
		self drawHLineFrom: (right - (xInset + 1)) to: (right - xInset) y: topY color: darkerC on: aCanvas.

		self drawHLineFrom: xInset to: right - xInset y: bottomY color: Color white on: aCanvas.

		xInset = 0 ifTrue: [
			self drawHLineFrom: xInset + 1 to: xInset + 2 y: topY color: Color white on: aCanvas.
			self drawHLineFrom: xInset to: xInset + 1 y: bottomY color: darkerC on: aCanvas.
			self drawHLineFrom: (right - (xInset + 1)) to: (right - xInset) y: bottomY color: darkerC on: aCanvas].

		bottomY _ bottomY + 1.
		topY _ topY - 1].
	"Now draw the shadows:"
	self drawShadowsOn: aCanvas.
! !

!ExpressionArgMorph methodsFor: 'drawing' stamp: 'EMP 12/1/2015 16:47'!
drawShadowsOn: aCanvas
	| shadowOrigin topShadowExtent leftShadowExtent alphas darkerC right topY bottomY radius xInset c |

	"shadow constants"
	shadowOrigin _ self topLeft + aCanvas origin.
	topShadowExtent _ self width@1.
	leftShadowExtent _ 1@self height.

	"shadow alpha values"
	alphas _ FloatArray
		with: 0.2
		with: 0.14
		with: 0.07.

	"There are two different shadows: A simple one for strings, and a more complex one for numbers. PLEASE DO NOT CHANGE CODE UNLESS YOU KNOW WHAT YOU ARE DOING."

	(self isRectangular) ifTrue: [
	"top/horizontal shadow"
	1 to: 3 do: [:i |
		aCanvas grafPort
			fill: (shadowOrigin + (0@(i-1)) extent: topShadowExtent)
			fillColor: (Color black alpha: (alphas at: i))
			rule: Form blend].

	"left/vertical shadow"
	1 to: 3 do: [:i |
		aCanvas grafPort
			fill: (shadowOrigin + ((i-1)@0) extent: leftShadowExtent)
			fillColor: (Color black alpha: (alphas at: i))
			rule: Form blend].

	"corner shadow fix"
	aCanvas grafPort
		fill: (shadowOrigin extent: (1@1))
		fillColor: (Color white alpha: 0.32)
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin +(0@1) extent: (1@1))
		fillColor: (Color white alpha: 0.19)
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin + (1@0) extent: (1@1))
		fillColor: (Color white alpha: 0.19)
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin +(0@2) extent: (1@1))
		fillColor: (Color white alpha: 0.05)
		rule: Form blend.
	^ aCanvas grafPort
		fill: (shadowOrigin + (2@0) extent: (1@1))
		fillColor: (Color white alpha: 0.05)
		rule: Form blend].

	"DISABLE REPORTER SHADOW >>>" true ifTrue: [^ self].
	darkerC _ Color black.
	right _ self width.
	topY _ bottomY _ radius _ self height // 2.
	self height even ifTrue: [topY _ bottomY - 1].
	[topY >= 0] whileTrue: [
		xInset _ radius - (radius squared - (radius - topY - 1) squared) sqrt rounded.
		(1 to: 3) do: [:integer | 
		self drawHLineFrom: xInset to: (xInset + integer) y: topY color: (Color black alpha: (alphas at: integer)) on: aCanvas].
		c _ (topY < 1) ifTrue: [Color black alpha: (alphas at: 1)] ifFalse: [(topY < 3) ifTrue: [Color black alpha: (alphas at: 2)] ifFalse: [(topY < 5) ifTrue: [Color black alpha: (alphas at: 3)] ifFalse: [Color white]]].
		self drawHLineFrom: xInset + 1 to: right - (xInset + 1) y: topY color: c on: aCanvas.
		self drawHLineFrom: (right - (xInset + 1)) to: (right - xInset) y: topY color: darkerC on: aCanvas.

		self drawHLineFrom: xInset to: right - xInset y: bottomY color: Color white on: aCanvas.

		xInset <= 5 ifTrue: [
			self drawHLineFrom: xInset + 1 to: xInset + 2 y: topY color: ((xInset < 1) ifTrue: [Color black alpha: (alphas at: 1)] ifFalse: [(xInset < 3) ifTrue: [Color black alpha: (alphas at: 2)] ifFalse: [(xInset < 5) ifTrue: [Color black alpha: (alphas at: 3)] ifFalse: [Color white]]]) on: aCanvas.
			self drawHLineFrom: xInset to: xInset + 1 y: bottomY color: darkerC on: aCanvas.
			self drawHLineFrom: (right - (xInset + 1)) to: (right - xInset) y: bottomY color: darkerC on: aCanvas].

		bottomY _ bottomY + 1.
		topY _ topY - 1]
! !

!ExpressionArgMorph methodsFor: 'drawing' stamp: 'jm 5/8/2008 12:14'!
isNumberExpression

	^ isNumber
! !

!ExpressionArgMorph methodsFor: 'drawing' stamp: 'jm 3/28/2005 17:12'!
isRectangular

	^ isNumber not
! !


!ExpressionArgMorph methodsFor: 'evaluation' stamp: 'jm 7/9/2008 23:25'!
evaluate
	"Answer the result of evaluating my expression in the context of the given ScratchProcess."

	| expr |
	expr _ labelMorph savedContents.
	isNumber
		ifTrue: [^ expr asNumberNoError]
		ifFalse: [^ expr].  "string"
! !


!ExpressionArgMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 18:19'!
fieldsVersion

	^ 1
! !

!ExpressionArgMorph methodsFor: 'object i/o' stamp: 'jm 6/21/2004 17:57'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		isNumber
	) from: anObjStream.
! !

!ExpressionArgMorph methodsFor: 'object i/o' stamp: 'jm 6/21/2004 17:57'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		isNumber
	) on: anObjStream.
! !


!ExpressionArgMorph methodsFor: 'private' stamp: 'jm 7/4/2008 17:37'!
fixArgLayout

	| top xInset extraW |
	top _ self top.
	isNumber
		ifTrue: [
			self extent: labelMorph extent + (5 @ 0).
			"tiny vertical adjustment to account for differences in string rendering"
			Smalltalk isWindows ifFalse: [top _ top + 1].
			"for tall fonts, add extra width"
			extraW _ (self height - (1.3 * self width) rounded) max: 0.
			extraW > 0 ifTrue: [self width: self width + extraW].
			xInset _ 4 + (extraW // 2)]
		ifFalse: [
			self extent: labelMorph extent + (2 @ 0).
			xInset _ 3].

	ScratchTranslator isRTL
		ifTrue: [labelMorph position: (self right - (xInset + labelMorph width)) @ top]
		ifFalse: [labelMorph position: (self left + xInset) @ top].
! !
