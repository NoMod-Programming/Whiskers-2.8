PasteUpMorph subclass: #ScratchTabPaneMorph
	instanceVariableNames: 'targetPane currentTab lastTabAdded barForm '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ScratchTabPaneMorph methodsFor: 'initialization' stamp: 'ee 2/3/2009 13:22'!
initialize

	| barFormSource |
	super initialize.
	self color: Color red.
	self extent: 100@1.
	
	barFormSource _ ScratchFrameMorph skinAt: #dividedImageFrameBar.
	barForm _ barFormSource copy: (((barFormSource width // 2) @ 0) extent: (1 @ barFormSource height))
! !


!ScratchTabPaneMorph methodsFor: 'accessing' stamp: 'EMP 4/11/2016 12:17'!
createSmallTab: tabID withLabel: aString onForm: aForm1 offForm: aForm2

	| button |
	button _ ResizableToggleButton2 new
		target: self;
		actionSelector: #currentTab:;
		toggleMode: false;
		toggleButtonMode: true;
		arguments: (Array with: tabID).

	button offForm: aForm2 onForm: aForm1 overForm: aForm1.
	self tab: button label: aString.

	button position: (lastTabAdded ifNil: [-0@0] ifNotNil: [(lastTabAdded right)@(self bottom - button height)]).
	(('Costumes' = aString) | ('Backdrops' = aString)) ifTrue: [button width: (button width * 0.25)].
	button extent: (button width - 2)@30.
	lastTabAdded _ button.
	self addMorph: button.
	button comeToFront.

	(button height > self height) ifTrue: [
		self height: button height.
		"if we just changed the height, then we must make sure all the previous tabs are aligned to the bottom"
		self submorphs do: [:m |
			(m isKindOf: ResizableToggleButton2) ifTrue: [
				m height: self height; bottom: self bottom.
				m label top: m label top]]].
! !

!ScratchTabPaneMorph methodsFor: 'accessing' stamp: 'EMP 3/22/2016 12:13'!
createTab: tabID withLabel: aString onForm: aForm1 offForm: aForm2

	| button |
	button _ ResizableToggleButton2 new
		target: self;
		actionSelector: #currentTab:;
		toggleMode: false;
		toggleButtonMode: true;
		arguments: (Array with: tabID).

	button offForm: aForm2 onForm: aForm1 overForm: aForm1.
	self tab: button label: aString.

	button position: (lastTabAdded ifNil: [-0@0] ifNotNil: [(lastTabAdded right)@(self bottom - button height)]).
	(('Costumes' = aString) | ('Backdrops' = aString)) ifTrue: [button width: (button width * 0.25)].
	button extent: (button width)@30.
	lastTabAdded _ button.
	self addMorph: button.
	button comeToFront.

	(button height > self height) ifTrue: [
		self height: button height.
		"if we just changed the height, then we must make sure all the previous tabs are aligned to the bottom"
		self submorphs do: [:m |
			(m isKindOf: ResizableToggleButton2) ifTrue: [
				m height: self height; bottom: self bottom.
				m label top: m label top]]].
! !

!ScratchTabPaneMorph methodsFor: 'accessing' stamp: 'ee 2/21/2005 23:30'!
currentTab

	^ currentTab.! !

!ScratchTabPaneMorph methodsFor: 'accessing' stamp: 'EMP 3/22/2016 10:47'!
currentTab: aString
	currentTab _ aString.
	self targetPane ifNil: [^ self].

	(targetPane target isKindOf: ScratchStageMorph)
		ifTrue: [self setLabelForTab: 'Costumes' to: 'Backdrops' localized]
		ifFalse: [self setLabelForTab: 'Costumes' to: 'Costumes' localized].

	self lightUpCurrentTab.
	targetPane currentCategory: aString.
! !

!ScratchTabPaneMorph methodsFor: 'accessing' stamp: 'EMP 10/9/2015 21:36'!
extent: aPoint
	super extent: aPoint.
	self submorphs do: [:m |
			(m isKindOf: ResizableToggleButton2) ifTrue: [
				m height: (self height - 3); bottom: self bottom.
				m label top: m label top]].! !

!ScratchTabPaneMorph methodsFor: 'accessing' stamp: 'ee 2/20/2005 23:51'!
targetPane

	^ targetPane.! !

!ScratchTabPaneMorph methodsFor: 'accessing' stamp: 'ee 2/21/2005 23:13'!
targetPane: aMorph

	targetPane _ aMorph.! !


!ScratchTabPaneMorph methodsFor: 'drawing'!
drawSubmorphsOn: aCanvas
	"Display submorphs back to front, draw a bar where appropriate in between tabs"

	| f barWidth myBox clipC |
	(self owner isKindOf: ScratchScriptEditorMorph) ifFalse: [
	myBox _ Rectangle origin: (self bounds origin) extent: (self bounds extent x - 20)@(self bounds extent y).
	clipC _ aCanvas copyClipRect: myBox.

	barWidth _ self width - 7.
	submorphs reverseDo:[:m | ((m isKindOf: ResizableToggleButton2) and: [m isOn])
		ifTrue: [f _ Form extent: (barWidth @ barForm height) depth: 32.
				10 to: barWidth by: barForm width do: [:x | barForm displayOn: f at: x@0 rule: Form blend]].
		f ifNotNil: ["clipC translucentImage: f at: ((self left - 13) @ (m bottom - 5))"].
		clipC fullDrawMorph: m]].
! !


!ScratchTabPaneMorph methodsFor: 'private' stamp: 'ee 1/29/2009 12:05'!
lightUpCurrentTab

	(self submorphs) do: [:m |
		(m isKindOf: ResizableToggleButton2) ifTrue: [
			m arguments first = currentTab
				ifTrue: [m setLabelColor: (Color r:(33/255) g:(33/255) b:(31/255)); on; comeToFront]
				ifFalse: [m setLabelColor: (Color r:(88/255) g:(89/255) b:(93/255)); off]]].
! !

!ScratchTabPaneMorph methodsFor: 'private' stamp: 'EMP 3/22/2016 12:13'!
setLabelForTab: tabID to: aString

	| theTab wInitial wDelta |
	self submorphs do: [:m |
		((m isKindOf: ResizableToggleButton2) and:
		 [m arguments first = tabID]) ifTrue: [
			theTab _ m.
			wInitial _ m width.
			self tab: m label: aString.
			wDelta _ m width - wInitial]].

	theTab ifNotNil: [
		self submorphs do: [:m |
			((m isKindOf: ResizableToggleButton2) and: [m left > (theTab left)])
				ifTrue: [
					"scoot the others down if the tab's width changed"
					m position: (m position) + (wDelta@0)]].
		theTab height: self height - 3; bottom: self bottom].
! !

!ScratchTabPaneMorph methodsFor: 'private' stamp: 'EMP 10/1/2015 12:07'!
tab: aResizableToggleButton2 label: aString

	| label |
	aResizableToggleButton2
		label: aString font: (ScratchFrameMorph getFont: #Tab).

	ScratchTranslator renderWithSqueak ifFalse: [
		aResizableToggleButton2 forceUnicodeRendering: true].

	"account for the size of the tab skin."
	aResizableToggleButton2 extent: (aResizableToggleButton2 extent - (0@1)).

	(label _ aResizableToggleButton2 findA: StringMorph) ifNotNil: [
		"slide label up a little"
		label top: label top].
! !
