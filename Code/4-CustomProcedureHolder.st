CommandBlockMorph subclass: #CustomProcedureHolder
	instanceVariableNames: 'paramNames '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!CustomProcedureHolder commentStamp: 'EMP 11/10/2015 15:10' prior: 0!
This is a VERY simplistic subclass of CommandBlockMorph. This one simply replaces all arguments by labels, unless they are a color, number, string, or boolean.!


!CustomProcedureHolder methodsFor: 'as yet unclassified' stamp: 'EMP 11/8/2015 14:30'!
addLabel
	super addLabel.
	self fixParameters! !

!CustomProcedureHolder methodsFor: 'as yet unclassified' stamp: 'EMP 11/8/2015 14:48'!
fixParameters
	| i |
	i _ 0.
	(self submorphs select: [:submorph | submorph isKindOf: CustomReporterMorph])
		 do: [:param |
	i _ i + 1.
	param commandSpec: (paramNames at: i ifAbsent: ['undefined']); selector: (paramNames at: i ifAbsent: ['undefined'])]
	! !

!CustomProcedureHolder methodsFor: 'as yet unclassified' stamp: 'EMP 11/8/2015 14:34'!
parameterNames: aCollection
	paramNames _ aCollection.
	self addLabel.! !

!CustomProcedureHolder methodsFor: 'as yet unclassified' stamp: 'EMP 4/10/2016 15:06'!
uncoloredArgMorphFor: specString
	"Answer an argument morph for the given argument specification string."

	| code |
	code _ specString copyFrom: 2 to: (specString size).
	's' = code ifTrue: [^ CustomReporterMorph new isBoolean: false].
	'n' = code ifTrue: [^ CustomReporterMorph new isBoolean: false].
	'b' = code ifTrue: [^ CustomReporterMorph new isBoolean: true].
	'c' = code ifTrue: [^ CustomReporterMorph new isBoolean: false].
	(#('m.spriteOnly' 'm.spriteOrMouse' 'm.spriteOrStage' 'm.location' 'm.touching' 'm.timeAndDate' 'm.var' 'm.list' 'm.backdrop' 'm.broadcast') includes: (code)) ifTrue: [^ CustomReporterMorph new isBoolean: false].
	^ (StringMorph contents: code asString font: (ScratchFrameMorph getFont: #Label)) color: self labelColor
! !
