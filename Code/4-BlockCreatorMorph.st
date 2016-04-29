CommandBlockMorph subclass: #BlockCreatorMorph
	instanceVariableNames: 'lastParameters '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!BlockCreatorMorph commentStamp: 'EMP 11/10/2015 15:09' prior: 0!
This is a subclass of commandblockmorph that is made to allow naming a block!


!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/11/2016 16:15'!
addLabel
	"Add a label for my command and arguments. This is the method that really creates the whole block."
	"Details: We remove all the pieces of this block, and then reassemble them, being careful not to destroy any argument morphs that we might still want to use. This is helpful if someone adds/removes parameters from a hat block."

	| tokens args nextArgIndex m |
	commandSpec ifNil: [^ self].

	"we make sure not to remove the next block."
	self removeAllMorphs.

	tokens _ BlockCreatorMorph parseCommandSpec: commandSpec.
	args _ tokens select: [:s | BlockCreatorMorph isArgSpec: s].

	"remove any excess arg morphs from the list."
	[argMorphs size > 0] whileTrue: [
		m _ argMorphs last.
		argMorphs remove: m.

		"if the argument we're throwing out is anything complicated, we'd like to keep it around in the world."
		(m isKindOf: BlockMorph) ifTrue: [m openInWorld]].

	"create new arg morphs."
	[argMorphs size < args size] whileTrue: [
		argMorphs addLast: (self argMorphFor: (args at: argMorphs size + 1))].

	nextArgIndex _ 1.
	tokens do: [:s |
		(BlockCreatorMorph isArgSpec: s)
			ifTrue:	[
				m _ argMorphs at: nextArgIndex.
				nextArgIndex _ nextArgIndex + 1]
			ifFalse:	[
				m _ self labelMorphFor: s].
		self addMorphBack: m].

	self isReporter ifTrue: [
		m _ submorphs first.
		((m isKindOf: ChoiceArgMorph) | (m isKindOf: SpriteArgMorph)) ifTrue: [  "add spacer"
			self addMorphFront: (Morph new color: Color transparent; extent: 2@5)].

		m _ submorphs last.
		((m isKindOf: ChoiceArgMorph) | (m isKindOf: SpriteArgMorph)) ifTrue: [  "add spacer"
			self addMorphBack: (Morph new color: Color transparent; extent: 2@5)]].
! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/9/2016 15:45'!
addParameter: type
	type = #reporter ifTrue: [self commandSpec: (self commandSpec asString, ' %n ')].
	type = #string ifTrue: [self commandSpec: (self commandSpec asString, ' %s ')].
	type = #boolean ifTrue: [self commandSpec: (self commandSpec asString, ' %b ')].
	type = #text ifTrue: [self commandSpec: (self commandSpec asString, '  ')].
	type = #color ifTrue: [self commandSpec: (self commandSpec asString, ' %c ')].
	type = #dropdown ifTrue: [self dropdownMenu].
	^ self fixParametersWith: lastParameters! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/5/2016 15:56'!
blockLabels
	^ (self submorphs select: [:m | m isKindOf: CustomBlockLabelMorph]), (self submorphs select: [:m | m isKindOf: ColoredExpressionArgMorph])! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/6/2015 22:13'!
commandSpec
	lastParameters _ self getBlockName second.
	^ self getBlockName first! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/6/2015 22:43'!
defaultNameForArgMorph: anArgMorph
	| type others otherLabels newLabel temp |
	type _ anArgMorph type.
	others _ (self submorphs select: [:morph | (morph isKindOf: ColoredExpressionArgMorph) and: [morph type = type]]).
	otherLabels  _ (others collect: [:item | item evaluate third]).
	newLabel _ 1.
	otherLabels do: [:label | ((label beginsWith: (type asString)) and: [label size > (type asString size)]) ifTrue: [((temp _ (label copyFrom: (type asString size + 1) to: (label size))) asNumberNoError = 0) ifFalse: [newLabel _ temp asNumberNoError + 1]]].
	^ (type asString), newLabel asString! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/10/2016 15:08'!
dropdownMenu
	| menu choice |
	menu _ CustomMenu new.
	#(
	('List of sprites and "myself"'								'm.spriteOnly')
	('List of sprites and "mouse-pointer"'							'm.spriteOrMouse')
	('List of sprites and "Stage"'									'm.spriteOrStage')
	('List of sprites and "random position" and "mouse-pointer"'	'm.location')
	('List of sprites and "edge"'									'm.touching')
	('List of time and date names'								'm.timeAndDate')
	('List of variable names'									'm.var')
	('List of list names'											'm.list')
	('List of backdrop names'									'm.backdrop')
	('List of broadcast names'									'm.broadcast')
	) do: [:m | menu add: (m first) action: (m second)].
	choice _ (menu startUp ifNil: [^ self]).
	self commandSpec: (commandSpec, '%', choice , ' ').! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/6/2015 15:19'!
evaluate
	^ ''! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/6/2015 21:26'!
extent: aPoint
	| d |
	super extent: aPoint.
	(d _ (self ownerThatIsA: BlockCreationDialog)) ifNotNil: [d updateWidth: self width]! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/6/2015 22:18'!
fixParametersWith: anOrderedCollectionOfValues
	| args i |
	args _ self submorphs select: [:m | m isKindOf: ColoredExpressionArgMorph].
	i _ 0.
	args do: [:arg | i _ i + 1. arg stringExpression: (anOrderedCollectionOfValues at: i ifAbsent: [self defaultNameForArgMorph: arg])].! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/16/2016 16:25'!
getBlockName
	| label varNames |
	label _ ''.
	varNames _ OrderedCollection new.
	((self submorphs select: [:m | m isArgMorph]) collect: [:morph | morph evaluate]) do: [:m | (m first = #arg) ifTrue: [label _ label, ' ', ((m second) caseOf: {
		[#string] -> [varNames add: m third. ' %s '].
		[#boolean] -> [varNames add: m third. ' %b '].
		[#color] -> [varNames add: m third. ' %c '].
		[#number] -> [varNames add: m third. ' %n ']
		}
		otherwise: [varNames add: m third. ' ',(m fourth), ' ']
)] ifFalse: [label _ label, ((((m second copyReplaceAll: '\' with: '\\\\') copyReplaceAll: '/' with: '\/') copyReplaceAll: '%' with: '\\%') copyReplaceAll: '@' with: '\\@') asString]
].
	^ {label. varNames asArray}! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 1/7/2016 20:31'!
initialize
	super initialize.
	lastParameters _ OrderedCollection new.
	self color: (Color r: 89/255 g: 71/255 b:177/255).
	self addParameter: #text! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/11/2016 16:23'!
labelMorphFor: aString

	| s |
	s _ ((((aString copyReplaceAll: '\\@' with: '@') copyReplaceAll: '\\%' with: '%') copyReplaceAll: '\/' with: '/') copyReplaceAll: '\\\\' with: '\').
	commandSpec isUnicode ifTrue: [s _ UTF8 withAll: s].
	^ (CustomBlockLabelMorph new stringExpression: s)
! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/6/2015 15:52'!
startDrag: evt
	^ self "don't allow me to be grabbed"! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/10/2016 15:08'!
uncoloredArgMorphFor: specString
	"Answer an argument morph for the given argument specification string."

	| code |
	code _ specString copyFrom: 2 to: specString size.
	's' = code ifTrue: [^ ColoredExpressionArgMorph new forType: #string].
	'n' = code ifTrue: [^ ColoredExpressionArgMorph new forType: #number].
	'b' = code ifTrue: [^ ColoredExpressionArgMorph new forType: #boolean].
	'c' = code ifTrue: [^ ColoredExpressionArgMorph new forType: #color].
	'm.spriteOnly' = code ifTrue: [^ ColoredExpressionArgWithName new forType: #spriteOnly; name: '%m.spriteOnly' ].
	'm.spriteOrMouse' = code ifTrue: [^ ColoredExpressionArgWithName new forType: #spriteOrMouse; name: '%m.spriteOrMouse' ].
	'm.spriteOrStage' = code ifTrue: [^ ColoredExpressionArgWithName new forType: #spriteOrStage; name: '%m.spriteOrStage' ].
	'm.location' = code ifTrue: [^ ColoredExpressionArgWithName new forType: #location; name: '%m.location' ].
	'm.touching' = code ifTrue: [^ ColoredExpressionArgWithName new forType: #touching; name: '%m.touching' ].
	'm.timeAndDate' = code ifTrue: [^ ColoredExpressionArgWithName new forType: #timeAndDate; name: '%m.timeAndDate' ].
	'm.var' = code ifTrue: [^ ColoredExpressionArgWithName new forType: #var; name: '%m.var' ].
	'm.list' = code ifTrue: [^ ColoredExpressionArgWithName new forType: #list; name: '%m.list' ].
	'm.backdrop' = code ifTrue: [^ ColoredExpressionArgWithName new forType: #backdrop; name: '%m.backdrop' ].
	'm.broadcast' = code ifTrue: [^ ColoredExpressionArgWithName new forType: #broadcast; name: '%m.broadcast' ].
	^ (StringMorph contents: code asString font: (ScratchFrameMorph getFont: #Label)) color: self labelColor
! !

!BlockCreatorMorph methodsFor: 'as yet unclassified' stamp: 'EMP 11/6/2015 21:26'!
width: aPoint
	| d |
	super width: aPoint.
	(d _ (self ownerThatIsA: BlockCreationDialog)) ifNotNil: [d updateWidth: self width]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

BlockCreatorMorph class
	instanceVariableNames: ''!

!BlockCreatorMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 11/6/2015 15:31'!
argPermutationForSpec: spec withTranslation: translatedSpec
	"CommandBlockMorph argPermutationForSpec: '%a of %m of %m of %t' withTranslation: '%a de %m de %m de %t'"
	"CommandBlockMorph argPermutationForSpec: '%a of %m of %m of %t' withTranslation: '%t de %m2 de %m1 de %a'"

	| parsedSpec parsedTranslatedSpec parsedSpecArgs parsedTranslatedSpecArgs permutation a copiesSize n originalPermutation |

	parsedSpec _ CommandBlockMorph parseCommandSpec: spec.
	parsedSpecArgs _ parsedSpec select: [:s | BlockCreatorMorph isArgSpec: s].
	parsedTranslatedSpec _ CommandBlockMorph parseCommandSpec: translatedSpec.
	parsedTranslatedSpecArgs _ parsedTranslatedSpec select: [:s | BlockCreatorMorph isArgSpec: s].

	permutation _ #().
	1 to: parsedSpecArgs size do: [:i | permutation _ permutation copyWith: i].
	originalPermutation _ permutation.

	"no change"
	(parsedSpecArgs = parsedTranslatedSpecArgs) ifTrue: [
			^ originalPermutation].

	"otherwise, calculate permutation"
	1 to: parsedSpecArgs size do: [:i |
		a _ parsedSpecArgs at: i.
		copiesSize _ (parsedSpecArgs select: [:s | (s = a)]) size.
		(copiesSize = 1)
			ifTrue:[permutation at: i put: (parsedTranslatedSpecArgs indexOf: a
				ifAbsent: [Transcript show: 'Permutation failed: ', spec.
						^ originalPermutation])]
			ifFalse:["count copies until now"
				n _ ((parsedSpecArgs copyFrom: 1 to: i) select: [:s | (s = a)]) size.
				permutation at: i put: (parsedTranslatedSpecArgs indexOf: (a,n asString)
					ifAbsent: [Transcript show: 'Permutation failed: ', spec.
						^ originalPermutation])]].
	^ permutation
! !

!BlockCreatorMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 4/9/2016 16:28'!
isArgSpec: aString
	"Answer true if the given string is an argument specification."
^ (((aString size > 1) and: [aString first = $%]) and: [#('%s' '%b' '%n' '%c' '%m.spriteOnly' '%m.spriteOrMouse' '%m.spriteOrStage' '%m.location' '%m.touching' '%m.timeAndDate' '%m.var' '%m.list' '%m.backdrop' '%m.broadcast') includes: aString])
! !

!BlockCreatorMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 4/11/2016 16:16'!
parseCommandSpec: aString
	^ (super parseCommandSpec: aString), #('')! !
