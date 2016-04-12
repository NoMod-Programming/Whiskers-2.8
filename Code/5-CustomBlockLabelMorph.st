ExpressionArgMorph subclass: #CustomBlockLabelMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!CustomBlockLabelMorph commentStamp: 'EMP 11/10/2015 15:09' prior: 0!
Same comment as ColoredExpressionArgMorph!


!CustomBlockLabelMorph methodsFor: 'initialization' stamp: 'EMP 11/6/2015 15:50'!
initialize
	super initialize.
	self color: (Color r: 89/255 g: 71/255 b:177/255).
	labelMorph textColor: (Color white)! !


!CustomBlockLabelMorph methodsFor: 'accessing' stamp: 'EMP 11/6/2015 22:07'!
acceptsDroppedReporters
	^ false! !

!CustomBlockLabelMorph methodsFor: 'accessing' stamp: 'EMP 11/6/2015 22:07'!
acceptsTypeOf: aMorph
	^ false! !

!CustomBlockLabelMorph methodsFor: 'accessing' stamp: 'EMP 11/6/2015 21:55'!
evaluate
	^ {#label. (super evaluate)}! !

!CustomBlockLabelMorph methodsFor: 'accessing' stamp: 'EMP 11/6/2015 15:48'!
fixArgLayout

	| top xInset extraW |
	top _ self top + 1.
	isNumber
		ifTrue: [
			self extent: labelMorph extent + (5 @ 2).
			"tiny vertical adjustment to account for differences in string rendering"
			Smalltalk isWindows ifFalse: [top _ top + 1].
			"for tall fonts, add extra width"
			extraW _ (self height - (1.3 * self width) rounded) max: 0.
			extraW > 0 ifTrue: [self width: self width + extraW].
			xInset _ 4 + (extraW // 2)]
		ifFalse: [
			self extent: labelMorph extent + (2 @ 2).
			xInset _ 3].

	ScratchTranslator isRTL
		ifTrue: [labelMorph position: (self right - (xInset + labelMorph width)) @ top]
		ifFalse: [labelMorph position: (self left + xInset) @ top].
! !


!CustomBlockLabelMorph methodsFor: 'as yet unclassified' stamp: 'EMP 2/26/2016 09:59'!
darkColor
	self
		color: (Color
				r: 135 / 255
				g: 56 / 255
				b: 191 / 255).
	labelMorph textColor: Color white! !

!CustomBlockLabelMorph methodsFor: 'as yet unclassified' stamp: 'EMP 2/26/2016 09:59'!
lightColor
	self
		color: (Color
				r: 239 / 255
				g: 166 / 255
				b: 255 / 255).
	labelMorph textColor: Color black! !
