SimpleButtonMorph subclass: #ResizableToggleButton
	instanceVariableNames: 'sideMargin isOn offLabelColor normalFormLeft normalFormEdge normalFormRight pressedFormLeft pressedFormEdge pressedFormRight '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ResizableToggleButton methodsFor: 'initialization' stamp: 'ee 3/9/2005 19:55'!
initialize

	super initialize.
	self cornerStyle: #square.
	isOn _ false.! !

!ResizableToggleButton methodsFor: 'initialization' stamp: 'jm 3/9/2005 16:42'!
normalFormLeft: f1 normalFormEdge: f2 normalFormRight: f3 label: aLabel sideMargin: aNumber

	normalFormLeft _ f1.
	normalFormEdge _ f2.
	normalFormRight _ f3.
	sideMargin _ aNumber.
	self label: aLabel font: TextStyle defaultFont.
! !

!ResizableToggleButton methodsFor: 'initialization' stamp: 'ee 3/9/2005 17:49'!
pressedFormLeft: f1 pressedFormEdge: f2 pressedFormRight: f3 

	pressedFormLeft _ f1.
	pressedFormEdge _ f2.
	pressedFormRight _ f3.
! !

!ResizableToggleButton methodsFor: 'initialization' stamp: 'ee 2/10/2005 19:09'!
setDefaultLabel
	"Overridden to do nothing. I have no label by default, although a label can be added."
! !


!ResizableToggleButton methodsFor: 'drawing' stamp: 'jm 8/22/2006 09:04'!
areasRemainingToFill: aRectangle
	"Don't optimize redraw; I may have transparent areas!!"

	^ Array with: aRectangle
! !

!ResizableToggleButton methodsFor: 'drawing' stamp: 'ee 3/21/2005 22:40'!
drawOn: aCanvas
	"Draw my normalLeft/normalEdge/normalRight forms and extend the normalEdgeForm to the width of my bounds."

	| startPoint p clipC lastX formLeft formEdge formRight |

	isOn & pressedFormLeft notNil
		ifTrue: [formLeft _ pressedFormLeft.
				formEdge _ pressedFormEdge.
				formRight _ pressedFormRight] 
		ifFalse: [formLeft _ normalFormLeft.
				formEdge _ normalFormEdge.
				formRight _ normalFormRight].
	
	startPoint _ self bounds origin + (formLeft width@0).
	p _ startPoint.
	clipC _ aCanvas copyClipRect: self bounds.
	lastX _ self bounds right - (formRight width) - 1.

	clipC paintImage: formLeft at: self bounds origin.
	[p x <= lastX] whileTrue: [
		clipC paintImage: formEdge at: p.
		p _ (p x + formEdge width) @ p y].
	clipC paintImage: formRight at: p.
	
	
! !


!ResizableToggleButton methodsFor: 'accessing' stamp: 'ee 3/9/2005 20:03'!
actWhen

	^ actWhen! !

!ResizableToggleButton methodsFor: 'accessing' stamp: 'ee 1/15/2008 12:59'!
color

	isOn
		ifNotNil:[isOn
			ifTrue:[^ pressedFormEdge colorAt: ((pressedFormEdge width // 2)@(pressedFormEdge height // 2))]
			ifFalse:[^ normalFormEdge colorAt: ((normalFormEdge width // 2)@(normalFormEdge height // 2))]]
		ifNil:[^ super color].! !

!ResizableToggleButton methodsFor: 'accessing' stamp: 'jm 1/21/2007 11:47'!
helpScreenName
	"Answer the name of the help screen for this block, or nil if no help is available."

	#addGlobalVariable = actionSelector ifTrue: [^ 'addVariable'].
	(#(addVariable addGlobalVariable deleteVariable) includes: actionSelector)
		ifTrue: [^ actionSelector asString].

	^ nil
! !

!ResizableToggleButton methodsFor: 'accessing' stamp: 'ee 3/9/2005 19:55'!
isOn

	^ isOn! !

!ResizableToggleButton methodsFor: 'accessing' stamp: 'jm 2/28/2005 15:30'!
label: aString font: aFont

	| oldLabel m |
	(oldLabel _ self findA: StringMorph) ifNotNil: [oldLabel delete].
	m _ StringMorph contents: aString font: (aFont ifNil: [Preferences standardButtonFont]).
	m color: (Color r: (78/255) g: (82/255) b: (82/255)).
	self extent: m extent + borderWidth.
	self width: self width + sideMargin.
	self height: (self height max: normalFormLeft height).
	m position: (self center - (m extent // 2)) - (0@1).
	self addMorph: m.
	m lock.
! !

!ResizableToggleButton methodsFor: 'accessing' stamp: 'jm 3/14/2005 13:20'!
off
	"Turn myself off."

	| myLabel |
	isOn ifFalse: [^ self].
	isOn _ false.
	self changed.

	(myLabel _ self findA: StringMorph) ifNotNil: [
		offLabelColor ifNotNil: [
			myLabel color: offLabelColor]].
! !

!ResizableToggleButton methodsFor: 'accessing' stamp: 'jm 3/14/2005 13:21'!
on
	"Turn myself on."

	| myLabel |
	isOn ifTrue: [^ self].
	isOn _ true.
	self changed.

	(myLabel _ self findA: StringMorph) ifNotNil: [
		offLabelColor _ myLabel color.
		myLabel color: Color black].
! !

!ResizableToggleButton methodsFor: 'accessing' stamp: 'tis 10/8/2006 21:03'!
presentHelpScreen
	"Answer the name of the help screen for this block, or nil if no help is available."

	| fr |
	fr _ self ownerThatIsA: ScratchFrameMorph.
	fr
		ifNil: [^ nil]
		ifNotNil: [fr presentHelpScreen: self helpScreenName]
! !


!ResizableToggleButton methodsFor: 'event handling' stamp: 'jm 11/27/2007 16:04'!
mouseDown: evt

	evt rightButtonPressed ifTrue: [^ self rightButtonMenu].

	evt hand toolType: nil.

	self on.
	actWhen = #buttonDown ifTrue: [
		self doButtonAction.
		self off].

! !

!ResizableToggleButton methodsFor: 'event handling' stamp: 'jm 8/22/2006 08:21'!
mouseLeave: evt

	ScratchToolTipMorph clearToolTips.
! !

!ResizableToggleButton methodsFor: 'event handling' stamp: 'jm 3/10/2005 09:50'!
mouseMove: evt

	actWhen = #buttonDown ifTrue: [^ self].
	(self containsPoint: evt cursorPoint)
		ifTrue: [self on]
		ifFalse: [self off].

! !

!ResizableToggleButton methodsFor: 'event handling' stamp: 'jm 3/10/2005 09:52'!
mouseUp: evt
	
	(actWhen = #buttonUp and:
	 [self containsPoint: evt cursorPoint])
		ifTrue: [self doButtonAction].

	self off.
! !

!ResizableToggleButton methodsFor: 'event handling' stamp: 'jm 10/25/2007 19:13'!
rightButtonMenu

	| menu |

	(self owner isKindOf: ScratchBlockPaletteMorph) ifTrue: [
		menu _ CustomMenu new.
		menu add: 'help' action: #presentHelpScreen.
		menu localize; invokeOn: self].
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ResizableToggleButton class
	instanceVariableNames: ''!

!ResizableToggleButton class methodsFor: 'instance creation' stamp: 'ee 2/10/2005 19:10'!
normalFormLeft: f1 normalFormEdge: f2 normalFormRight: f3 label: aLabel sideMargin: aNumber
	"Set the forms used for my normal state."

	^ self new
		normalFormLeft: f1
		normalFormEdge: f2
		normalFormRight: f3
		label: aLabel
		sideMargin: aNumber.! !

!ResizableToggleButton class methodsFor: 'instance creation' stamp: 'EMP 3/24/2016 11:40'!
onForm: onForm offForm: offForm
	^ self new offForm: offForm onForm: onForm! !
