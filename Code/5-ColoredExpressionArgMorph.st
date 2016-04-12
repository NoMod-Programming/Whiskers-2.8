ExpressionArgMorph subclass: #ColoredExpressionArgMorph
	instanceVariableNames: 'type '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!ColoredExpressionArgMorph commentStamp: 'EMP 11/10/2015 15:09' prior: 0!
An expressionargmorph that is colored like a parameter!


!ColoredExpressionArgMorph methodsFor: 'initialize' stamp: 'EMP 11/6/2015 14:56'!
initialize
	super initialize.
	type _ #string.
	self color: (Color r: 89/255 g: 71/255 b:177/255) lighter.
	self stringExpression: 'undefined'.
	labelMorph textColor: (Color white)! !


!ColoredExpressionArgMorph methodsFor: 'accessing' stamp: 'EMP 11/6/2015 14:34'!
acceptsDroppedReporters

	^ false! !

!ColoredExpressionArgMorph methodsFor: 'accessing' stamp: 'EMP 11/6/2015 14:36'!
acceptsTypeOf: aBlockMorph
	^ false "you cannot use a variable in a custom block's name"! !

!ColoredExpressionArgMorph methodsFor: 'accessing' stamp: 'EMP 11/6/2015 22:09'!
evaluate
	^ {#arg. type. (labelMorph contents asString)}! !

!ColoredExpressionArgMorph methodsFor: 'accessing' stamp: 'EMP 11/6/2015 14:46'!
forType: aSymbol

	type _ aSymbol.
	aSymbol = #number ifTrue: [isNumber _ true] ifFalse: [isNumber _ false]! !

!ColoredExpressionArgMorph methodsFor: 'accessing' stamp: 'EMP 11/6/2015 14:46'!
isNumberExpression
	^ type = #number! !

!ColoredExpressionArgMorph methodsFor: 'accessing' stamp: 'EMP 11/6/2015 22:19'!
type
	^ type! !


!ColoredExpressionArgMorph methodsFor: 'drawing' stamp: 'EMP 11/6/2015 15:17'!
booleanDrawOn: aCanvas 

	| h s v darkerC lighterC right topY bottomY xInset c |
	h _ (Color r: 89/255 g: 71/255 b:177/255)  hue.
	s _ (Color r: 89/255 g: 71/255 b:177/255) saturation.
	v _ (Color r: 89/255 g: 71/255 b:177/255) brightness.
	darkerC _ Color h: h s: (s - 0.3) v: (v - 0.3).
	lighterC _ Color h: h s: (s - 0.2) v: (v + 0.2).

	right _ self width.
	topY _ bottomY _ self height // 2.
	self height even ifTrue: [topY _ bottomY - 1].
	xInset _ 0.
	[topY >= 0] whileTrue: [
		self drawHLineFrom: xInset to: (xInset + 2) y: topY color: darkerC on: aCanvas.
		c _ (topY <= 1) ifTrue: [darkerC] ifFalse: [color].
		self drawHLineFrom: xInset + 2 to: right - (xInset + 1) y: topY color: c on: aCanvas.
		self drawHLineFrom: (right - (xInset + 1)) to: (right - xInset) y: topY color: darkerC on: aCanvas.

		self drawHLineFrom: xInset to: (xInset + 1) y: bottomY color: lighterC on: aCanvas.
		c _ (bottomY >= (self height - 2)) ifTrue: [lighterC] ifFalse: [color].
		self drawHLineFrom: xInset + 1 to: right - (xInset + 1) y: bottomY color: c on: aCanvas.
		self drawHLineFrom: (right - (xInset + 2)) to: (right - xInset) y: bottomY color: lighterC on: aCanvas.

		xInset _ xInset + 1.	
		bottomY _ bottomY + 1.
		topY _ topY - 1].

! !

!ColoredExpressionArgMorph methodsFor: 'drawing' stamp: 'EMP 11/6/2015 14:38'!
drawOn: aCanvas 

	type = #string ifTrue: [^ self stringDrawOn: aCanvas].
	type = #number ifTrue: [^ self numberDrawOn: aCanvas].
	type = #boolean ifTrue: [^ self booleanDrawOn: aCanvas].
	^ super drawOn: aCanvas
! !

!ColoredExpressionArgMorph methodsFor: 'drawing' stamp: 'EMP 11/6/2015 14:48'!
numberDrawOn: aCanvas 
	| darkerC right topY bottomY radius xInset c |

	darkerC _ (Color r: 89/255 g: 71/255 b:177/255) darker.
	right _ self width.
	topY _ bottomY _ radius _ self height // 2.
	self height even ifTrue: [topY _ bottomY - 1].
	[topY >= 0] whileTrue: [
		xInset _ radius - (radius squared - (radius - topY - 1) squared) sqrt rounded.

		self drawHLineFrom: xInset to: (xInset + 1) y: topY color: darkerC on: aCanvas.
		c _ (topY < 1) ifTrue: [darkerC] ifFalse: [(Color r: 89/255 g: 71/255 b:177/255) lighter].
		self drawHLineFrom: xInset + 1 to: right - (xInset + 1) y: topY color: c on: aCanvas.
		self drawHLineFrom: (right - (xInset + 1)) to: (right - xInset) y: topY color: darkerC on: aCanvas.

		self drawHLineFrom: xInset to: right - xInset y: bottomY color: (Color r: 89/255 g: 71/255 b:177/255) lighter on: aCanvas.

		xInset = 0 ifTrue: [
			self drawHLineFrom: xInset + 1 to: xInset + 2 y: topY color: (Color r: 89/255 g: 71/255 b:177/255) lighter on: aCanvas.
			self drawHLineFrom: xInset to: xInset + 1 y: bottomY color: darkerC on: aCanvas.
			self drawHLineFrom: (right - (xInset + 1)) to: (right - xInset) y: bottomY color: darkerC on: aCanvas].

		bottomY _ bottomY + 1.
		topY _ topY - 1].

! !

!ColoredExpressionArgMorph methodsFor: 'drawing' stamp: 'EMP 11/6/2015 14:50'!
stringDrawOn: aCanvas 
	^ super drawOn: aCanvas
! !


!ColoredExpressionArgMorph methodsFor: 'private' stamp: 'EMP 11/6/2015 15:14'!
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
			(type = #boolean) ifTrue: [self extent: labelMorph extent + (10 @ 0).
			xInset _ 5] ifFalse: [
			self extent: labelMorph extent + (2 @ 0).
			xInset _ 3]].

	ScratchTranslator isRTL
		ifTrue: [labelMorph position: (self right - (xInset + labelMorph width)) @ top]
		ifFalse: [labelMorph position: (self left + xInset) @ top].
! !
