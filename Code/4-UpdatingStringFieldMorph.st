StringFieldMorph subclass: #UpdatingStringFieldMorph
	instanceVariableNames: 'target getSelector putSelector stepTime '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Dialogs'!
!UpdatingStringFieldMorph commentStamp: 'jm 7/4/2008 12:29' prior: 0!
A subclass of UpdatingStringFieldMorph that updates when stepped.
!


!UpdatingStringFieldMorph methodsFor: 'initialization' stamp: 'EMP 3/4/2016 13:00'!
initialize

	super initialize.
	stringMorph color: Color white.
	stepTime _ 200.
	self useTypeinFrame.
	self font: (StrikeFont fontName: 'Verdana' size: 12).
! !


!UpdatingStringFieldMorph methodsFor: 'accessing' stamp: 'jm 7/2/2008 13:58'!
getSelector: aSelector

	getSelector _ aSelector.
! !

!UpdatingStringFieldMorph methodsFor: 'accessing' stamp: 'jm 7/2/2008 13:58'!
putSelector: aSelector

	putSelector _ aSelector.
! !

!UpdatingStringFieldMorph methodsFor: 'accessing' stamp: 'jm 7/2/2008 13:59'!
target

	^ target
! !

!UpdatingStringFieldMorph methodsFor: 'accessing' stamp: 'jm 7/2/2008 13:59'!
target: aScratchObjectOrMediaObjectOrNil

	target _ aScratchObjectOrMediaObjectOrNil.
	self step.
! !


!UpdatingStringFieldMorph methodsFor: 'stepping' stamp: 'jm 7/2/2008 15:24'!
step

	| s |
	super step.
	isKeyboardFocus ifTrue: [^ self]. "do not update if user is editing"
	(target notNil & getSelector notNil) ifFalse: [^ self].

	s _ target perform: getSelector.
	s asUTF8 = self contents ifFalse: [self contents: s].
! !

!UpdatingStringFieldMorph methodsFor: 'stepping' stamp: 'EMP 3/7/2016 12:19'!
stepTime
	^ stepTime ifNil: [50]
! !

!UpdatingStringFieldMorph methodsFor: 'stepping' stamp: 'EMP 3/4/2016 13:00'!
stepTime: aNumber
	stepTime _ aNumber! !


!UpdatingStringFieldMorph methodsFor: 'private' stamp: 'jm 7/2/2008 14:22'!
acceptEdits
	"Tell the client to accept edits."

	(target notNil & putSelector notNil) ifFalse: [^ self].
	[target perform: putSelector with: self contents] ifError: [].

! !

!UpdatingStringFieldMorph methodsFor: 'private' stamp: 'jm 7/2/2008 13:58'!
isEditable
	"Answer true if I am editable."

	^ putSelector notNil
! !
