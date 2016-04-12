ColoredExpressionArgMorph subclass: #ColoredExpressionArgWithName
	instanceVariableNames: 'name '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!

!ColoredExpressionArgWithName methodsFor: 'as yet unclassified' stamp: 'EMP 4/10/2016 10:11'!
evaluate
	^ {#arg. type. (labelMorph contents asString). name asString}! !

!ColoredExpressionArgWithName methodsFor: 'as yet unclassified' stamp: 'EMP 4/10/2016 10:11'!
name
	^ name! !

!ColoredExpressionArgWithName methodsFor: 'as yet unclassified' stamp: 'EMP 4/10/2016 10:11'!
name: aStringOrSymbol
	name _ aStringOrSymbol! !
