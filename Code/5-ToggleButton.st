SimpleButtonMorph subclass: #ToggleButton
	instanceVariableNames: 'onForm offForm overForm disabledForm isMomentary toggleMode isOn isDisabled isOver wasOn alphaOn '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!ToggleButton commentStamp: '<historical>' prior: 0!
I am a button with several forms. Clicking on me toggles which form is shown and sends my target a message. If my isMomentary flag is true, then I return to my off state after I am pressed (i.e. when the mouse goes up).

I can also show a different form on mouse-over.

Finally, if I am disabled I can show a disabled form.

!


!ToggleButton methodsFor: 'initialization' stamp: 'ee 11/10/2008 15:02'!
initialize

	super initialize.
	self cornerStyle: #square.
	isMomentary _ false.
	toggleMode _ true.
	isDisabled _ false.
	isOn _ isOver _ false.
	alphaOn _ false.
! !

!ToggleButton methodsFor: 'initialization'!
offForm: t1 
	offForm _ t1.
	self on; off! !

!ToggleButton methodsFor: 'initialization'!
onForm: t1 
	onForm _ t1.
	self on; off! !

!ToggleButton methodsFor: 'initialization' stamp: 'jm 12/18/2003 12:08'!
onForm: f1 offForm: f2

	onForm _ f1.
	offForm _ f2.
	self on; off.
! !

!ToggleButton methodsFor: 'initialization' stamp: 'jm 12/18/2003 12:08'!
onForm: f1 offForm: f2 overForm: f3

	onForm _ f1.
	offForm _ f2.
	overForm _ f3.
	self on; off.
! !

!ToggleButton methodsFor: 'initialization' stamp: 'ee 6/17/2005 16:38'!
onForm: f1 offForm: f2 overForm: f3 disabledForm: f4

	onForm _ f1.
	offForm _ f2.
	overForm _ f3.
	disabledForm _ f4.
	self on; off.
! !

!ToggleButton methodsFor: 'initialization'!
overForm: t1 
	overForm _ t1.
	self on; off! !

!ToggleButton methodsFor: 'initialization' stamp: 'jm 12/17/2003 13:07'!
setDefaultLabel
	"Overridden to do nothing. I have no label by default, although a label can be added."
! !


!ToggleButton methodsFor: 'accessing' stamp: 'ee 11/10/2008 15:03'!
alphaOn: aBoolean

	alphaOn _ aBoolean.! !

!ToggleButton methodsFor: 'accessing' stamp: 'jm 8/22/2006 07:57'!
clearIsOver

	| f |
	isOver ifFalse: [^ self].  "already cleared"
	isOver _ false.

	"update my extent"
	f _ isOn ifTrue: [onForm] ifFalse: [offForm].
	isDisabled ifTrue: [f _ disabledForm].
	f ifNotNil: [self extent: f extent].
! !

!ToggleButton methodsFor: 'accessing' stamp: 'ee 1/15/2008 13:03'!
color

	isOn
		ifNotNil:[isOn
			ifTrue:[^ onForm colorAt: ((onForm width // 2)@(onForm height // 2))]
			ifFalse:[isOver
				ifTrue:[^ overForm colorAt: ((overForm width // 2)@(overForm height // 2))]
				ifFalse:[^ offForm colorAt: ((offForm width // 2)@(offForm height // 2))]]]
		ifNil:[^ super color].! !

!ToggleButton methodsFor: 'accessing' stamp: 'jm 8/22/2006 07:56'!
isDisabled

	^ isDisabled
! !

!ToggleButton methodsFor: 'accessing' stamp: 'jm 8/22/2006 07:47'!
isDisabled: aBoolean

	isDisabled _ aBoolean.
! !

!ToggleButton methodsFor: 'accessing' stamp: 'jm 12/17/2003 13:07'!
isMomentary: aBoolean

	isMomentary _ aBoolean.
! !

!ToggleButton methodsFor: 'accessing' stamp: 'jm 12/17/2003 13:07'!
isOn

	^ isOn
! !

!ToggleButton methodsFor: 'accessing' stamp: 'ee 3/22/2005 00:46'!
label

	self allMorphsDo: [:m | (m isKindOf: StringMorph) ifTrue: [^ m]].
	! !

!ToggleButton methodsFor: 'accessing' stamp: 'jm 12/17/2003 13:08'!
label: aString font: aFont
	"Add the given label in the given font centered in my current extent."

	| oldLabel m |
	(oldLabel _ self findA: StringMorph) ifNotNil: [oldLabel delete].
	m _ StringMorph contents: aString font: (aFont ifNil: [Preferences standardButtonFont]).
	m position: self center - (m extent // 2).
	self addMorph: m.
	m lock.
! !

!ToggleButton methodsFor: 'accessing' stamp: 'jm 8/22/2006 08:40'!
off
	"Turn myself off."

	isOn ifFalse: [^ self].
	self changed.
	isOn _ false.
	offForm ifNotNil: [self extent: offForm extent].
	self changed.
! !

!ToggleButton methodsFor: 'accessing' stamp: 'jm 8/22/2006 08:41'!
on
	"Turn myself on."

	isOn ifTrue: [^ self].
	self changed.
	isOn _ true.
	onForm ifNotNil: [self extent: onForm extent].
	self changed.
! !

!ToggleButton methodsFor: 'accessing' stamp: 'jm 8/22/2006 08:47'!
setLabelColor: aColor

	| s |
	s _ self findA: StringMorph.
	s color: aColor.
! !

!ToggleButton methodsFor: 'accessing' stamp: 'tis 12/15/2006 18:35'!
shortcutLabel: aString font: aFont
	"Add the given label in the given font centered in my current extent."

	| oldLabel m |
	(oldLabel _ self findA: StringMorph) ifNotNil: [oldLabel delete].
	m _ StringMorph contents: aString font: (aFont ifNil: [Preferences standardButtonFont]).
	m position: self center - (m extent // 2) + (0@6).
	self addMorph: m.
	m lock.
! !

!ToggleButton methodsFor: 'accessing' stamp: 'jm 12/17/2003 13:02'!
toggleMode: aBoolean

	toggleMode _ aBoolean.
! !


!ToggleButton methodsFor: 'geometry' stamp: 'EMP 11/5/2015 12:45'!
containsPoint: aPoint

	| f |
	^ (self bounds containsPoint: aPoint) "ifFalse: [^ false].
	f _ isOn ifTrue: [onForm] ifFalse: [offForm].
	f ifNil: [^ true].
	^ (f isTransparentAt: aPoint - bounds origin) not"
! !

!ToggleButton methodsFor: 'geometry' stamp: 'ee 12/22/2005 00:15'!
extent: aRectangle
	"Overridden because SimpleButtonMorph tries to center the label, if there is one, and we want manual control."

	| label oldP oldPSub |
	(label _ self findA: StringMorph) ifNil: [
		(self submorphCount = 1) ifTrue: [oldPSub _ self firstSubmorph position].
		super extent: aRectangle.
		(self submorphCount = 1) ifTrue: [self firstSubmorph position: oldPSub].
		^self].
	oldP _ label position.
	super extent: aRectangle.
	label position: oldP.
! !


!ToggleButton methodsFor: 'drawing' stamp: 'jm 8/22/2006 09:04'!
areasRemainingToFill: aRectangle
	"Don't optimize redraw; I may have transparent areas!!"

	^ Array with: aRectangle
! !

!ToggleButton methodsFor: 'drawing' stamp: 'EMP 2/9/2016 15:23'!
drawOn: t1 
	| t2 |
	t2 := isOn
				ifTrue: [onForm]
				ifFalse: [offForm].
	isOver & isOn not
		ifTrue: [t2 := overForm].
	isDisabled
		ifTrue: [t2 := disabledForm].
	t2
		ifNil: [t1
				frameRectangle: self bounds
				width: 3
				color: (isOn
						ifTrue: [Color veryVeryLightGray]
						ifFalse: [Color gray]).
			^ self].
	alphaOn
		ifTrue: [t1 translucentImage: t2 at: bounds origin]
		ifFalse: [t1 paintImage: t2 at: bounds origin]! !


!ToggleButton methodsFor: 'event handling' stamp: 'ee 8/6/2003 16:33'!
handlesMouseOver: evt

	^ true
! !

!ToggleButton methodsFor: 'event handling' stamp: 'jm 10/11/2006 17:38'!
mouseDown: evt
	"If I am currently turned on, turn myself off and vice versa. If toggleMode is false, then do nothing if I am already on. If isMomentary, then turn myself off immediately. If I am to act when I'm pressed, then send my target my action selector."

	evt hand toolType: nil.
	isDisabled ifTrue: [^ self].

	wasOn _ isOn.
	actWhen == #buttonDown ifTrue: [
		self doButtonAction.
		self on.
		isMomentary ifTrue: [self off]].
! !

!ToggleButton methodsFor: 'event handling' stamp: 'jm 1/6/2006 10:46'!
mouseEnter: evt

	isDisabled ifTrue: [^ self].

	overForm ifNotNil: [
		self changed.
		isOver _ true.
		self extent: overForm extent.
		self changed].
! !

!ToggleButton methodsFor: 'event handling' stamp: 'jm 8/22/2006 08:22'!
mouseLeave: evt

	ScratchToolTipMorph clearToolTips.
	isDisabled ifTrue: [^ self].

	overForm ifNotNil: [
		self changed.
		isOver _ false.
		isOn ifTrue: [self on] ifFalse: [self off]].
! !

!ToggleButton methodsFor: 'event handling' stamp: 'ee 6/17/2005 17:45'!
mouseMove: evt
	"Give feedback depending on whether the mouse is over me. If I was originally on, show my off image if the mouse is over me and my on image if not. Do the opposite if I was originally off."

	isDisabled ifTrue: [^self].

	actWhen == #buttonDown ifTrue: [^ self].
	(toggleMode not & wasOn) ifTrue: [^ self].  "already on and not toggling"
	(self containsPoint: evt cursorPoint)
		ifTrue: [wasOn ifTrue: [self off] ifFalse: [self on]]
		ifFalse: [wasOn ifTrue: [self on] ifFalse: [self off]].
! !

!ToggleButton methodsFor: 'event handling' stamp: 'jm 8/22/2006 07:56'!
mouseUp: evt
	"If I am a momentary button, then turn off. If I am to act on button up, then send my target my action selector."

	isDisabled ifTrue:[^ self].

	isMomentary ifTrue: [self off].

	(actWhen == #buttonUp and:
	 [self containsPoint: evt cursorPoint])
		ifTrue: [self doButtonAction].
! !


!ToggleButton methodsFor: 'menu' stamp: 'ee 6/24/2003 11:37'!
addCustomMenuItems: aCustomMenu hand: aHandMorph

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'change action selector' action: #setActionSelector.
	aCustomMenu add: 'change arguments' action: #setArguments.
! !


!ToggleButton methodsFor: 'object i/o' stamp: 'jm 8/22/2006 07:43'!
fieldsVersion

	^ 1
! !

!ToggleButton methodsFor: 'object i/o' stamp: 'jm 8/22/2006 08:24'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		onForm
		offForm
		overForm
		disabledForm
		isMomentary
		toggleMode
		isOn
		isDisabled
	) from: anObjStream.
! !

!ToggleButton methodsFor: 'object i/o' stamp: 'jm 8/22/2006 08:25'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		onForm
		offForm
		overForm
		disabledForm
		isMomentary
		toggleMode
		isOn
		isDisabled
	) on: anObjStream.

! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ToggleButton class
	instanceVariableNames: ''!

!ToggleButton class methodsFor: 'instance creation' stamp: 'TIS 6/20/2006 13:41'!
buttonHue: hue
	"Answer a new ToggleButton that looks like an LED indicator light of the given hue."

	| d onF offF w bezelF |
	w _ 2.
	bezelF _ ImageMorph bezelDiameter: 14 width: 2 baseColor: Color gray inset: true.
	d _ bezelF width - (2 * w).
	onF _ bezelF deepCopy.
	(ImageMorph glowDiameter: d color: (Color h: hue s: 0.4 v: 1) on: true)
		displayOn: onF at: w@w rule: Form paint.
	offF _ bezelF deepCopy.
	(ImageMorph glowDiameter: d color: (Color h: hue s: 0.4 v: 1) on: false)
		displayOn: offF at: w@w rule: Form paint.
	^ ToggleButton onForm: onF offForm: offF
! !

!ToggleButton class methodsFor: 'instance creation' stamp: 'ee 7/1/2003 14:49'!
onForm: f1 offForm: f2
	"Set the forms used for my on and off states."

	^ self new onForm: f1 offForm: f2
! !

!ToggleButton class methodsFor: 'instance creation' stamp: 'ee 8/6/2003 16:28'!
onForm: f1 offForm: f2 overForm: f3
	"Set the forms used for my on and off states."

	^ self new onForm: f1 offForm: f2 overForm: f3
! !
