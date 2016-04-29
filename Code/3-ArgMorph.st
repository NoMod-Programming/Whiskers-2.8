BorderedMorph subclass: #ArgMorph
	instanceVariableNames: 'labelMorph '
	classVariableNames: 'DropDownMenuForm '
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!ArgMorph commentStamp: 'jm 3/15/2003 12:22' prior: 0!
I am an abstract superclass for all kinds of argument morphs--morphs that are used to hold the argument for various kinds of BlockMorph.
!


!ArgMorph methodsFor: 'drawing' stamp: 'jm 3/28/2005 16:00'!
drawHLineFrom: startX to: endX y: yOffset color: c on: aCanvas

	| y |
	y _ self top + yOffset.
	aCanvas
		fillRectangle: ((self left + startX)@y corner: (self left + endX)@(y + 1))
		color: c.
! !


!ArgMorph methodsFor: 'other' stamp: 'jm 7/7/2004 00:23'!
acceptsDroppedReporters
	"Answer true if I accept dropped reporter blocks. Answer false by default."

	^ false
! !

!ArgMorph methodsFor: 'other' stamp: 'jm 3/28/2005 19:18'!
acceptsTypeOf: aBlockMorph
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	^ false
! !

!ArgMorph methodsFor: 'other' stamp: 'jm 3/28/2005 15:12'!
defaultValue: anObject
	"Set my default value. This default implementation does nothing."
! !

!ArgMorph methodsFor: 'other' stamp: 'jm 8/24/2003 16:57'!
fixArgLayout
	"Fix my layout. This default implementation does nothing."! !

!ArgMorph methodsFor: 'other' stamp: 'EMP 4/26/2016 16:19'!
hasDeletedReceiver
	^ false! !

!ArgMorph methodsFor: 'other' stamp: 'jm 12/9/2008 17:31'!
isArgMorph
	"True only for ArgMorphs."

	^ true
! !

!ArgMorph methodsFor: 'other' stamp: 'jm 12/9/2008 17:35'!
isBlockMorph
	"True only for BlockMorphs."

	^ false
! !

!ArgMorph methodsFor: 'other' stamp: 'jm 3/15/2003 12:21'!
isReporter
	"Answer true since every ArgMorph reports a value."

	^ true
! !

!ArgMorph methodsFor: 'other' stamp: 'jm 10/21/2003 12:32'!
labelMorph

	^ labelMorph
! !

!ArgMorph methodsFor: 'other' stamp: 'jm 3/14/2009 14:08'!
printArgOn: aStream
	"Print this argument morph on the given stream."

	| v |
	self labelMorph ifNotNil: [
		v _ self evaluate.
		(v isKindOf: String)
			ifTrue: [aStream nextPutAll: '"', v, '"']
			ifFalse: [aStream nextPutAll: v asString]].

! !


!ArgMorph methodsFor: 'object i/o' stamp: 'EMP 4/26/2016 16:15'!
evaluateIn: t1 
	t1 returnValueToParentFrame: self evaluate.
	t1 popStackFrameNoUnhightlight.
	^ false! !

!ArgMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 18:25'!
fieldsVersion

	^ 1
! !

!ArgMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 18:25'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		labelMorph
	) from: anObjStream.
! !

!ArgMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 18:33'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		labelMorph
	) on: anObjStream.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ArgMorph class
	instanceVariableNames: ''!

!ArgMorph class methodsFor: 'class initialization' stamp: 'jm 6/22/2007 12:49'!
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


ArgMorph initialize!
