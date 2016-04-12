RectangleMorph subclass: #SimpleButtonMorph
	instanceVariableNames: 'target actionSelector arguments actWhen oldColor drawToolTipAbove '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Widgets'!
!SimpleButtonMorph commentStamp: 'jm 6/15/2003 11:36' prior: 0!
I am a simple button with a string label. I can have a target object, selector, and optional argument list so that when I'm activated I can send the target a specific message. I can act either on mouse-down or mouse-up.
!


!SimpleButtonMorph methodsFor: 'initialization' stamp: 'jm 12/7/2005 09:36'!
adaptToWorld: aWorld

	super adaptToWorld: aWorld.
	target isMorph ifTrue: [
		target isWorldMorph ifTrue: [self target: aWorld].
		target isHandMorph ifTrue: [self target: aWorld activeHand]].
! !

!SimpleButtonMorph methodsFor: 'initialization' stamp: 'jm 1/5/2006 09:00'!
initialize

	self initializeAllButLabel.
	self setDefaultLabel.
! !

!SimpleButtonMorph methodsFor: 'initialization' stamp: 'EMP 12/22/2015 15:59'!
initializeAllButLabel

	super initialize.
	self borderWidth: 1.
	self cornerStyle: #rounded.
	self color: (Color r: 0.4 g: 0.8 b: 0.6).
	self borderColor: self color darker.
	target _ nil.
	actionSelector _ #flash.
	arguments _ Array empty.
	actWhen _ #buttonUp.
	drawToolTipAbove _ false.
! !

!SimpleButtonMorph methodsFor: 'initialization' stamp: 'di 6/5/2000 09:09'!
initializeWithLabel: labelString

	self initializeAllButLabel; label: labelString
! !

!SimpleButtonMorph methodsFor: 'initialization' stamp: 'jm 1/5/2006 09:00'!
setDefaultLabel

	self label: 'Flash'.
! !


!SimpleButtonMorph methodsFor: 'menu' stamp: 'jm 12/8/2003 12:01'!
addCustomMenuItems: aCustomMenu hand: aHandMorph

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	self hasLabel ifTrue: [
		aCustomMenu add: 'change label' action: #setLabel].
	((self world rootMorphsAt: aHandMorph targetOffset) size > 1) ifTrue: [
		aCustomMenu add: 'set target' action: #setTarget:].

	aCustomMenu add: 'change action selector' action: #setActionSelector.
	aCustomMenu add: 'change arguments' action: #setArguments.
	aCustomMenu add: 'change when to act' action: #setActWhen.

! !

!SimpleButtonMorph methodsFor: 'menu'!
setActWhen
	actWhen _ (SelectionMenu selections: #(buttonDown buttonUp whilePressed))
		startUpWithCaption: 'Choose one of the following conditions'
! !

!SimpleButtonMorph methodsFor: 'menu'!
setActionSelector

	| newSel |
	newSel _ FillInTheBlank
		request:
'Please type the selector to be sent to
the target when this button is pressed'
		initialAnswer: actionSelector.
	newSel isEmpty ifFalse: [self actionSelector: newSel].
! !

!SimpleButtonMorph methodsFor: 'menu'!
setArguments

	| s newArgs newArgsArray |
	s _ WriteStream on: ''.
	arguments do: [:arg | arg printOn: s. s nextPutAll: '. '].
	newArgs _ FillInTheBlank
		request:
'Please type the arguments to be sent to the target
when this button is pressed separated by periods'
		initialAnswer: s contents.
	newArgs isEmpty ifFalse: [
		newArgsArray _ Compiler evaluate: '{', newArgs, '}' for: self logged: false.
		self arguments: newArgsArray].
! !

!SimpleButtonMorph methodsFor: 'menu'!
setLabel

	| newLabel |
	newLabel _ FillInTheBlank
		request:
'Please a new label for this button'
		initialAnswer: self label.
	newLabel isEmpty ifFalse: [self label: newLabel].
! !

!SimpleButtonMorph methodsFor: 'menu'!
setTarget: evt

	| rootMorphs |
	rootMorphs _ self world rootMorphsAt: evt hand targetOffset.
	rootMorphs size > 1
		ifTrue: [target _ rootMorphs at: 2]
		ifFalse: [target _ nil. ^ self].
! !


!SimpleButtonMorph methodsFor: 'accessing'!
actWhen: condition
	"Accepts symbols:  #buttonDown, #buttonUp, and #whilePressed"
	actWhen _ condition! !

!SimpleButtonMorph methodsFor: 'accessing'!
actionSelector

	^ actionSelector
! !

!SimpleButtonMorph methodsFor: 'accessing'!
actionSelector: aSymbolOrString

	(nil = aSymbolOrString or:
	 ['nil' = aSymbolOrString or:
	 [aSymbolOrString isEmpty]])
		ifTrue: [^ actionSelector _ nil].

	actionSelector _ aSymbolOrString asSymbol.
! !

!SimpleButtonMorph methodsFor: 'accessing'!
arguments

	^ arguments
! !

!SimpleButtonMorph methodsFor: 'accessing'!
arguments: aCollection

	arguments _ aCollection asArray copy.
! !

!SimpleButtonMorph methodsFor: 'accessing' stamp: 'jm 12/1/2006 10:50'!
drawToolTipAbove

	drawToolTipAbove ifNil: [drawToolTipAbove _ false].
	^ drawToolTipAbove
! !

!SimpleButtonMorph methodsFor: 'accessing' stamp: 'jm 1/5/2006 08:56'!
drawToolTipAbove: aBoolean

	drawToolTipAbove _ aBoolean.
! !

!SimpleButtonMorph methodsFor: 'accessing' stamp: '6/7/97 10:53 di'!
extent: newExtent
	| label |
	super extent: newExtent.
	submorphs size = 1 ifTrue:
		["keep the label centered"
		"NOTE: may want to test more that it IS a label..."
		label _ self firstSubmorph.
		label position: self center - (label extent // 2)]! !

!SimpleButtonMorph methodsFor: 'accessing' stamp: 'jm 11/6/2003 08:23'!
fitContents

	| oldCenter m |
	submorphs size = 0 ifTrue: [^ self].
	oldCenter _ self center.
	m _ submorphs first.
	self extent: m extent + (borderWidth + 6).
	self center: oldCenter.
	m position: oldCenter - (m extent // 2).
! !

!SimpleButtonMorph methodsFor: 'accessing' stamp: 'jm 12/8/2003 11:59'!
hasLabel
	"I have a text label."

	^ true
! !

!SimpleButtonMorph methodsFor: 'accessing' stamp: 'jm 11/14/2005 16:50'!
helpScreenName
	"Answer the name of the help screen for this button, or nil if no help is available."

	^ nil
! !

!SimpleButtonMorph methodsFor: 'accessing'!
label

	| s |
	s _ ''.
	self allMorphsDo: [:m | (m isKindOf: StringMorph) ifTrue: [s _ m contents]].
	^ s! !

!SimpleButtonMorph methodsFor: 'accessing' stamp: 'jm 11/6/2003 08:21'!
label: aString

	self label: aString font: TextStyle defaultFont.
! !

!SimpleButtonMorph methodsFor: 'accessing' stamp: 'jm 11/6/2003 08:26'!
label: aString font: aFont

	| oldLabel m |
	(oldLabel _ self findA: StringMorph) ifNotNil: [oldLabel delete].
	m _ StringMorph contents: aString font: (aFont ifNil: [Preferences standardButtonFont]).
	self extent: m extent + (borderWidth + 6).
	m position: self center - (m extent // 2).
	self addMorph: m.
	m lock.
! !

!SimpleButtonMorph methodsFor: 'accessing' stamp: 'sw 6/11/1999 18:40'!
labelString: aString

	| existingLabel |
	(existingLabel _ self findA: StringMorph)
		ifNil:
			[self label: aString]
		ifNotNil:
			[existingLabel contents: aString.
			self fitContents]
! !

!SimpleButtonMorph methodsFor: 'accessing'!
target

	^ target
! !

!SimpleButtonMorph methodsFor: 'accessing'!
target: anObject

	target _ anObject
! !


!SimpleButtonMorph methodsFor: 'events'!
doButtonAction
	"Perform the action of this button. Subclasses may override this method. The default behavior is to send the button's actionSelector to its target object with its arguments."

	(target ~~ nil and: [actionSelector ~~ nil]) ifTrue: [
		Cursor normal showWhile: [
			target perform: actionSelector withArguments: arguments]].
! !

!SimpleButtonMorph methodsFor: 'events' stamp: 'sw 8/16/97 22:10'!
handlesMouseDown: evt
	^  self isPartsDonor not
! !

!SimpleButtonMorph methodsFor: 'events' stamp: 'di 5/23/2000 16:17'!
mouseDown: evt

	| now dt |
	oldColor _ color.
	now _ Time millisecondClockValue.
	actWhen == #buttonDown
		ifTrue: [self doButtonAction].
	dt _ Time millisecondClockValue - now max: 0.  "Time it took to do"
	dt < 200 ifTrue: [(Delay forMilliseconds: 200-dt) wait]
! !

!SimpleButtonMorph methodsFor: 'events' stamp: 'jm 8/11/2003 20:57'!
mouseMove: evt

	actWhen == #buttonDown ifTrue: [^ self].
	(self containsPoint: evt cursorPoint)
		ifTrue: [
			oldColor ifNotNil: [
				self color: (oldColor mixed: 1/2 with: Color white)].
			(actWhen == #whilePressed and:
			 [evt anyButtonPressed])
				 ifTrue: [self doButtonAction]]
		ifFalse: [oldColor ifNotNil: [self color: oldColor]].
! !

!SimpleButtonMorph methodsFor: 'events' stamp: 'sma 4/22/2000 17:29'!
mouseUp: evt
	oldColor ifNotNil:
		["if oldColor nil, it signals that mouse had not gone DOWN
		inside me, e.g. because of a cmd-drag; in this case we want
		to avoid triggering the action!!"
		self color: oldColor.
		oldColor _ nil.
		(actWhen == #buttonUp and: [self containsPoint: evt cursorPoint])
			ifTrue: [self doButtonAction]]! !

!SimpleButtonMorph methodsFor: 'events' stamp: 'jm 4/17/2008 12:58'!
showBalloon: msg

	| w worldBounds tooltip |

	w _ self world.
	tooltip _ ScratchToolTipMorph string: msg for: self.
	w addMorphFront: tooltip "(w activeHand position + tooltip offset)".
	self drawToolTipAbove
		ifTrue: [tooltip position: self topLeft - (0@tooltip height)]
		ifFalse: [tooltip position: self bottomLeft + (0@8)].

	worldBounds _ w bounds.
	(worldBounds containsRect: tooltip bounds) ifFalse: [
		tooltip bounds: (tooltip bounds translatedToBeWithin: worldBounds).
		(tooltip bounds intersects: w activeHand bounds) ifTrue: [tooltip left: w activeHand bounds right].
		(worldBounds containsRect: tooltip bounds) ifFalse: [
			tooltip bounds: (tooltip bounds translatedToBeWithin: worldBounds).
			(tooltip bounds intersects: w activeHand bounds) ifTrue: [tooltip right: w activeHand bounds left - 8]]].
! !


!SimpleButtonMorph methodsFor: 'copying' stamp: 'jm 7/28/97 11:52'!
updateReferencesUsing: aDictionary
	"If the arguments array points at a morph we are copying, then point at the new copy.  And also copies the array, which is important!!"

	super updateReferencesUsing: aDictionary.
	arguments _ arguments collect:
		[:old | aDictionary at: old ifAbsent: [old]].
! !


!SimpleButtonMorph methodsFor: 'object i/o' stamp: 'jm 9/25/2003 09:59'!
fieldsVersion

	^ 1
! !

!SimpleButtonMorph methodsFor: 'object i/o' stamp: 'jm 9/25/2003 10:07'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		target
		actionSelector
		arguments
		actWhen
	) from: anObjStream.
! !

!SimpleButtonMorph methodsFor: 'object i/o' stamp: 'jm 9/25/2003 10:07'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		target
		actionSelector
		arguments
		actWhen
	) on: anObjStream.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SimpleButtonMorph class
	instanceVariableNames: ''!

!SimpleButtonMorph class methodsFor: 'instance creation' stamp: 'jm 5/31/2003 20:01'!
includeInNewMorphMenu

	^ true
! !

!SimpleButtonMorph class methodsFor: 'instance creation' stamp: 'di 6/5/2000 08:42'!
newWithLabel: labelString

	^ self basicNew initializeWithLabel: labelString
! !
