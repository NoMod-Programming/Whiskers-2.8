StringMorph subclass: #UpdatingStringMorph
	instanceVariableNames: 'format target lastValue getSelector putSelector parameter floatPrecision growable stepTime '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Widgets'!
!UpdatingStringMorph commentStamp: 'jm 3/15/2003 21:05' prior: 0!
I am a StringMorph that periodically polls my target object (by sending it getSelector) and displays the resulting value. If I have a putSelector, then I can be edited and my target object is informed by sending the new value as a parameter of the putSelector message.
!


!UpdatingStringMorph methodsFor: 'initialization' stamp: 'jm 3/15/2003 20:37'!
initialize

	super initialize.
	format _ #default.  "formats: #string, #default"
	target _ getSelector _ lastValue _ putSelector _ parameter _ nil.
	floatPrecision _ 1.
	growable _ true.
	stepTime _ 50.
! !


!UpdatingStringMorph methodsFor: 'accessing' stamp: 'jm 3/15/2003 19:43'!
floatPrecision

	^ floatPrecision
! !

!UpdatingStringMorph methodsFor: 'accessing' stamp: 'jm 5/26/1999 16:22'!
floatPrecision: aNumber

	floatPrecision _ aNumber.
! !

!UpdatingStringMorph methodsFor: 'accessing'!
getSelector

	^ getSelector
! !

!UpdatingStringMorph methodsFor: 'accessing'!
getSelector: aSymbol

	getSelector _ aSymbol.
! !

!UpdatingStringMorph methodsFor: 'accessing' stamp: 'jm 3/15/2003 20:34'!
growable

	^ growable
! !

!UpdatingStringMorph methodsFor: 'accessing' stamp: 'jm 5/26/1999 16:22'!
growable: aBoolean

	growable _ aBoolean.
! !

!UpdatingStringMorph methodsFor: 'accessing' stamp: 'jm 3/15/2003 20:49'!
parameter

	^ parameter
! !

!UpdatingStringMorph methodsFor: 'accessing' stamp: 'jm 3/15/2003 20:51'!
parameter: anObject
	"Set a parameter (e.g., an array index) to be sent with both my get selector and my put selector. The default is nil, which means no parameter is used."

	parameter _ anObject.
! !

!UpdatingStringMorph methodsFor: 'accessing'!
putSelector

	^ putSelector
! !

!UpdatingStringMorph methodsFor: 'accessing'!
putSelector: aSymbol

	putSelector _ aSymbol.
! !

!UpdatingStringMorph methodsFor: 'accessing'!
target

	^ target
! !

!UpdatingStringMorph methodsFor: 'accessing' stamp: 'jm 9/26/2003 08:13'!
target: anObject

	target _ anObject.
	lastValue _ nil.
! !


!UpdatingStringMorph methodsFor: 'format'!
useDefaultFormat
	"Use the object's own printString format."

	format _ #default.
! !

!UpdatingStringMorph methodsFor: 'format'!
useStringFormat

	format _ #string.! !


!UpdatingStringMorph methodsFor: 'stepping' stamp: 'sw 7/15/1999 07:28'!
step
	| s |
	super step.
	hasFocus ifFalse:
		["update contents, but only if user isn't editing this string"
		s _ self readFromTarget.
		s = contents ifFalse:
			[self updateContentsFrom: s]]
! !

!UpdatingStringMorph methodsFor: 'stepping'!
stepTime

	^ stepTime ifNil: [50]
! !

!UpdatingStringMorph methodsFor: 'stepping' stamp: 'jm 5/26/1999 16:23'!
stepTime: mSecsPerStep

	stepTime _ mSecsPerStep truncated.
! !


!UpdatingStringMorph methodsFor: 'menu' stamp: 'jm 3/15/2003 20:33'!
addCustomMenuItems: menu hand: aHandMorph

	| prefix |
	super addCustomMenuItems: menu hand: aHandMorph.
	prefix _ growable ifTrue: ['stop'] ifFalse: ['start'].
	menu add: prefix, ' being growable' action: #toggleGrowability.
	menu add: 'decimal places...' action: #setPrecision.
	menu add: 'font size...' action: #setFontSize.
	menu add: 'font style...' action: #setFontStyle.
! !

!UpdatingStringMorph methodsFor: 'menu' stamp: 'jm 12/16/2005 11:49'!
setFontSize

	| fontName labels choice |
	fontName _ font ifNil: ['NewYork'] ifNotNil: [font name].
	labels _ (StrikeFont sizesForFontName: fontName)
				collect: [:sz | fontName, ' ', sz printString].
	choice _ (SelectionMenu labelList: labels selections: labels) startUp.
	choice ifNil: [^ self].
	self font: (StrikeFont fontName: fontName size: (labels indexOf: choice)).
! !

!UpdatingStringMorph methodsFor: 'menu' stamp: 'sw 12/7/1999 11:45'!
setFontStyle
	| aList reply style |
	aList _ (TextConstants select: [:anItem | anItem isKindOf: TextStyle])
			keys asOrderedCollection.
	reply _ (SelectionMenu labelList: aList selections: aList) startUp.
	reply ~~ nil ifTrue:
		[(style _ TextStyle named: reply) ifNil: [self beep. ^ true].
		self font: (style defaultFont)]! !

!UpdatingStringMorph methodsFor: 'menu' stamp: 'sw 10/5/1998 15:31'!
setPrecision
	| aList aMenu reply |
	aList _ #('0' '1' '2' '3' '4' '5').
	aMenu _ SelectionMenu labels: aList selections: aList.
	reply _ aMenu startUpWithCaption: 'How many decimal places?'.
	reply ifNotNil:
		[self floatPrecision:
			(#(1 0.1 0.01 0.001 0.0001 0.00001 0.000001) at: (aList indexOf: reply))]! !

!UpdatingStringMorph methodsFor: 'menu' stamp: 'jm 3/15/2003 20:33'!
toggleGrowability

	growable _ growable not.
	self updateContentsFrom: self readFromTarget.
	growable ifTrue: [self fitContents].
! !


!UpdatingStringMorph methodsFor: 'editing' stamp: 'jm 7/1/2004 12:45'!
acceptContents

	| newValue |
	((target ~~ nil) and: [putSelector ~~ nil]) ifTrue: [
		"compute the new value"
		format = #string
			ifTrue: [newValue _ contents]
			ifFalse: [newValue _ contents asNumberNoError].

		newValue ifNotNil: [
			parameter
				ifNil: [target perform: putSelector with: newValue]
				ifNotNil: [target perform: putSelector with: parameter with: newValue].
			target isMorph ifTrue: [target changed]].

		self fitContents].
! !

!UpdatingStringMorph methodsFor: 'editing' stamp: 'jm 8/21/2006 11:40'!
handlesMouseDown: evt

	putSelector ifNil: [^ false].

	(owner wantsKeyboardFocusFor: self)
		ifTrue: [^ self uncoveredAt: evt cursorPoint].
	^ super handlesMouseDown: evt
! !

!UpdatingStringMorph methodsFor: 'editing' stamp: 'jm 3/15/2003 20:36'!
lostFocusWithoutAccepting
	"The message is sent when the user, having been in an editing episode on the receiver, changes the keyboard focus without having accepted the current edits. In This case, we just accept the edits."

	self acceptContents.
! !

!UpdatingStringMorph methodsFor: 'editing' stamp: 'sw 9/9/1999 10:58'!
mouseDown: evt
	(owner wantsKeyboardFocusFor: self) ifTrue:
		[putSelector ifNotNil: [self launchMiniEditor: evt]]! !


!UpdatingStringMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 22:18'!
fieldsVersion

	^ 1
! !

!UpdatingStringMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 22:21'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		format
		target
		getSelector
		putSelector
		parameter
		floatPrecision
		growable
		stepTime
	) from: anObjStream.
! !

!UpdatingStringMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 22:21'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		format
		target
		getSelector
		putSelector
		parameter
		floatPrecision
		growable
		stepTime
	) on: anObjStream.
! !


!UpdatingStringMorph methodsFor: 'private' stamp: 'jm 6/2/2008 20:01'!
fitContents

	|  newExtent |
	newExtent _ (self stringExtent: contents) max: 5@0.
	self extent = newExtent ifFalse: [
		self extent: newExtent.
		self changed.
		(self ownerThatIsA: EventHatMorph) ifNotNil:[
			(self ownerThatIsA: EventHatMorph) forceLayout]].
! !

!UpdatingStringMorph methodsFor: 'private' stamp: 'jm 6/3/2008 14:28'!
formatValue: v

	format = #string ifTrue: [
		v isUnicode ifTrue: [^ v].
		^ v asString].

	(format = #default and: [v isNumber]) ifTrue: [
		v isInteger
			ifTrue: [
				v digitLength > 25 ifTrue: [
					v digitLength < 128
						ifTrue: [^ self formatValue: v asFloat]  "use exponential notation"
						ifFalse: [^ v > 0 ifTrue: ['Infinity'] ifFalse: ['-Infinity']]].
				^ v printString]
			ifFalse: [
				v isInf ifTrue: [
					^ v > 0 ifTrue: ['Infinity'] ifFalse: ['-Infinity']].
				v isNaN ifTrue: [^ 'Error!!'].
				^ (v asFloat roundTo: floatPrecision) printString]].

	(v isKindOf: Boolean) ifTrue: [^ v printString localized].
	(v isKindOf: String) ifTrue: [^ v].

	^ v printString
! !

!UpdatingStringMorph methodsFor: 'private' stamp: 'jm 3/17/2003 17:01'!
readFromTarget
	"Answer the formatted string for the value read from my target. If the target or selector are nil, or if the value is the same as the last value read, answer my current contents."

	| v |
	(v _ self valueFromTargetOrNil) ifNil: [^ contents].
	lastValue = v ifTrue: [^ contents].
	lastValue _ v.
	^ self formatValue: v
! !

!UpdatingStringMorph methodsFor: 'private' stamp: 'jm 3/15/2003 20:34'!
updateContentsFrom: aValue

	growable
		ifTrue: [self contents: aValue]
		ifFalse: [self contentsClipped: aValue].
! !

!UpdatingStringMorph methodsFor: 'private' stamp: 'EMP 10/3/2015 17:11'!
valueFromTargetOrNil
	"Answer the value read from my target. Answer nil if my target or selector is nil.."

	| result |
	((target == nil) or: [getSelector == nil]) ifTrue: [^ nil].
	result _ nil.
	getSelector == #COUNT ifTrue: [^ result _ target perform: #getCounter].
	[result _ parameter
		ifNil: [target perform: getSelector]
		ifNotNil: [target perform: getSelector with: parameter]
	] ifError: [].
	^ result
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

UpdatingStringMorph class
	instanceVariableNames: ''!

!UpdatingStringMorph class methodsFor: 'instance creation' stamp: 'jm 3/15/2003 20:49'!
on: targetObject selector: aSymbol

	^ self new
		getSelector: aSymbol;
		target: targetObject
! !
