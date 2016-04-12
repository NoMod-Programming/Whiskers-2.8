CommandBlockMorph subclass: #SetterBlockMorph
	instanceVariableNames: 'variable '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!SetterBlockMorph commentStamp: 'jm 11/25/2003 13:04' prior: 0!
I am a block for setting a variable.
!


!SetterBlockMorph methodsFor: 'initialization' stamp: 'EMP 4/8/2016 07:09'!
initChangerForVar: varName

	self commandSpec: (ScratchTranslator translationFor: 'change %m.var by %n').
	argPermutation _ CommandBlockMorph argPermutationForSpec: 'set %m.var to %n' withTranslation: commandSpec.
	self selector: #changeVar:by:.
	self variable: varName.
! !

!SetterBlockMorph methodsFor: 'initialization' stamp: 'EMP 4/8/2016 07:10'!
initSetterForVar: varName

	self commandSpec: (ScratchTranslator translationFor: 'set %m.var to %n').
	argPermutation _ CommandBlockMorph argPermutationForSpec: 'set %m.var to %n' withTranslation: commandSpec.
	self selector: #setVar:to:.
	self variable: varName.
! !

!SetterBlockMorph methodsFor: 'initialization' stamp: 'jm 3/31/2005 19:38'!
initialize

	super initialize.
	isSpecialForm _ false.
	isTimed _ false.
! !


!SetterBlockMorph methodsFor: 'accessing' stamp: 'jm 7/3/2008 16:09'!
expressionArg

	submorphs do: [:m |
		(m isKindOf: ExpressionArgMorph) ifTrue: [^ m]].

	^ nil! !

!SetterBlockMorph methodsFor: 'accessing' stamp: 'jm 11/15/2006 11:46'!
helpScreenName
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	#setVar:to: = selector
		ifTrue: [^ 'variableSet']
		ifFalse: [^ 'variableChangeBy']
! !

!SetterBlockMorph methodsFor: 'accessing' stamp: 'jm 7/3/2008 15:56'!
receiver: anObject
	"Set my receiver object and, if possible, my block color."

	receiver _ anObject.
	(receiver respondsTo: #variableBlockColor)
		ifTrue: [self color: receiver variableBlockColor].
! !

!SetterBlockMorph methodsFor: 'accessing' stamp: 'jm 7/13/2008 23:04'!
variable

	submorphs do: [:m |
		(m isKindOf: ChoiceArgMorph) ifTrue: [^ m choice]].
	^ ''

! !

!SetterBlockMorph methodsFor: 'accessing' stamp: 'jm 7/13/2008 23:04'!
variable: aVar

	submorphs do: [:m |
		(m isKindOf: ChoiceArgMorph) ifTrue: [^ m choice: aVar]].
! !


!SetterBlockMorph methodsFor: 'object i/o' stamp: 'jm 12/1/2003 10:52'!
fieldsVersion

	^ 1
! !

!SetterBlockMorph methodsFor: 'object i/o' stamp: 'jm 7/13/2008 23:07'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		variable
	) from: anObjStream.
	self variable: variable.
! !

!SetterBlockMorph methodsFor: 'object i/o' stamp: 'jm 7/13/2008 23:07'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	variable _ self variable.
	self storeFieldsNamed: #(
		variable
	) on: anObjStream.
! !


!SetterBlockMorph methodsFor: 'private' stamp: 'jm 7/13/2008 23:04'!
asBlockTuple
	"Answer a tuple (Array) describing this block and its arguments."

	| result arg |
	result _ Array with: #changeVariable with: self variable with: selector with: nil.

	arg _ (argMorphs first isKindOf: ChoiceArgMorph)
		ifTrue: [argMorphs last]
		ifFalse: [argMorphs first].

	(arg isKindOf: ArgMorph)
		ifTrue: [result at: 4 put: arg evaluate]
		ifFalse: [result at: 4 put: arg asBlockTuple].

	^ result

! !

!SetterBlockMorph methodsFor: 'private' stamp: 'EMP 4/11/2016 16:22'!
labelMorphFor: aString

	| s |
	s _ ((((aString copyReplaceAll: '\\@' with: '@') copyReplaceAll: '\\%' with: '%') copyReplaceAll: '\/' with: '/') copyReplaceAll: '\\\\' with: '\')..
	commandSpec isUnicode ifTrue: [s _ UTF8 withAll: s].
	self variable isUnicode ifTrue: [s _ UTF8 withAll: s].
	^ (StringMorph contents: s font: (ScratchFrameMorph getFont: #Label))
		color: self labelColor
! !
