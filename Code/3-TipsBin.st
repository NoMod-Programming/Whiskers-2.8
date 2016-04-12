BorderedMorph subclass: #TipsBin
	instanceVariableNames: 'master tabPane currentTab '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!TipsBin methodsFor: 'accessing' stamp: 'EMP 12/3/2015 16:02'!
currentCategory
	^ currentTab! !

!TipsBin methodsFor: 'accessing' stamp: 'EMP 4/12/2016 07:39'!
currentCategory: aString
	currentTab _ aString.
	self removeAllMorphs.
	self addMorph: tabPane.
	currentTab caseOf: {
		['Step by Step'] -> [].
		['How to'] -> [].
		['Blocks'] -> [].
		} otherwise: [].! !

!TipsBin methodsFor: 'accessing' stamp: 'EMP 4/11/2016 12:10'!
extent: aPoint
	self owner ifNotNil: [self owner owner ifNotNil: [
	super extent: (self owner owner width) @ aPoint y]].
	tabPane position: (self topLeft).
	tabPane width: self width + 17.! !

!TipsBin methodsFor: 'accessing' stamp: 'EMP 4/11/2016 12:15'!
initialize
	| tabOnForm tabOffForm tabID tabLabel |
	super initialize.
	self color: (Color gray: 0.9).
	borderColor _ (Color gray: 0.8).
	borderWidth _ 1.
	tabPane _ ScratchTabPaneMorph new extent: 20@30; color: Color transparent.
	tabPane
		borderWidth: 0;
		targetPane: self.

	tabOnForm _ (ScratchFrameMorph skinAt: #tabOn).
	tabOffForm _ (ScratchFrameMorph skinAt: #tabOff).

	"add the tabs"
	#('Step by Step' 'How to' 'Blocks') do: [:spec |
		tabID _ spec asString.
		tabLabel _ tabID localized.
		tabPane
			createSmallTab: tabID
			withLabel: tabLabel
			onForm: tabOnForm
			offForm: tabOffForm].

	"set current tab and add to frame"
	tabPane currentTab: 'Scripts'.
	self addMorph: tabPane.! !

!TipsBin methodsFor: 'accessing' stamp: 'EMP 12/3/2015 15:56'!
master: anObject
	master _ anObject! !

!TipsBin methodsFor: 'accessing' stamp: 'EMP 12/4/2015 11:04'!
target
	^ nil! !
