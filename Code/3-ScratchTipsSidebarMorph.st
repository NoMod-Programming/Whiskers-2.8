BorderedMorph subclass: #ScratchTipsSidebarMorph
	instanceVariableNames: 'titlePane bin frame mode closeAndOpenButton '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Panes'!

!ScratchTipsSidebarMorph methodsFor: 'initialization' stamp: 'EMP 4/11/2016 12:01'!
extent: aPoint
	
	super extent: (((mode = #hidden) ifTrue: [22] ifFalse: [215]) @ aPoint y).
	titlePane ifNotNil: [titlePane extent: (self width @ 36)].
	bin ifNotNil: [bin position: (self position + (0@36)).
		bin extent: (self extent - (0@36)). 
		bin contents width: self width. 
		bin updateScrollbars].
	closeAndOpenButton position: (self left + ((mode = #hidden) ifTrue: [3] ifFalse: [6])) @ (self top + ((titlePane bottom - self top) // 4)).

	mode = #hidden ifTrue: [bin delete] ifFalse: [self addMorph: bin].! !

!ScratchTipsSidebarMorph methodsFor: 'initialization' stamp: 'EMP 12/3/2015 15:56'!
frame
	^ frame! !

!ScratchTipsSidebarMorph methodsFor: 'initialization' stamp: 'EMP 12/3/2015 15:56'!
frame: aFrameMorph
	frame _ aFrameMorph! !

!ScratchTipsSidebarMorph methodsFor: 'initialization' stamp: 'EMP 4/11/2016 12:07'!
initialize

	super initialize.
	mode _ #visible.
	titlePane _ ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #libraryTop).
	bin _ ScrollFrameMorph2 new growthFraction: 0.1; noHorizontalScroll.
	self addMorphBack: titlePane; addMorphBack: bin.

	closeAndOpenButton _ (ToggleButton onForm: (ScratchFrameMorph skinAt: #closeButtonTipsPressed) offForm: (ScratchFrameMorph skinAt: #closeButtonTips) overForm: (ScratchFrameMorph skinAt: #closeButtonTipsPressed)) target: self; actionSelector: #toggleShowing; borderWidth: 0.
	self addMorph: closeAndOpenButton.

	bin contents: (TipsBin new master: self).
	frame _ nil.
	self color: (Color gray: 0.9).
	borderColor _ Color gray: 0.8.
	borderWidth _ 1.
	self extent: 214@500.! !

!ScratchTipsSidebarMorph methodsFor: 'initialization' stamp: 'EMP 12/4/2015 11:23'!
mode: aMode
	mode _ aMode! !


!ScratchTipsSidebarMorph methodsFor: 'event handling' stamp: 'EMP 12/9/2015 15:54'!
handlesMouseDown: evt
	^ true! !

!ScratchTipsSidebarMorph methodsFor: 'event handling' stamp: 'EMP 12/10/2015 12:41'!
handlesMouseOver: evt
	^ true! !

!ScratchTipsSidebarMorph methodsFor: 'event handling' stamp: 'EMP 12/10/2015 12:33'!
mouseDown: evt
	"(titlePane bounds containsPoint: evt cursorPoint)"
	mode = #hidden ifTrue: [
	self toggleShowing] ifFalse: [(titlePane bounds containsPoint: evt cursorPoint) ifTrue: [self toggleShowing]].! !

!ScratchTipsSidebarMorph methodsFor: 'event handling' stamp: 'EMP 12/10/2015 12:46'!
mouseLeave: evt
	closeAndOpenButton off "We're turning it off just in case"! !

!ScratchTipsSidebarMorph methodsFor: 'event handling' stamp: 'EMP 12/10/2015 12:39'!
toggleShowing
	(mode = #hidden) ifTrue: [
	mode _ #visible.
	self extent: self extent.
closeAndOpenButton onForm: (ScratchFrameMorph skinAt: #closeButtonTipsPressed); offForm: (ScratchFrameMorph skinAt: #closeButtonTips); overForm: (ScratchFrameMorph skinAt: #closeButtonTipsPressed).
	(self ownerThatIsA: ScratchFrameMorph) fixLayout] ifFalse: [
	mode _ #hidden.
	self extent: self extent.
closeAndOpenButton onForm: (ScratchFrameMorph skinAt: #infoButtonTipsPressed); offForm: (ScratchFrameMorph skinAt: #infoButtonTips); overForm: (ScratchFrameMorph skinAt: #infoButtonTipsPressed).
	(self ownerThatIsA: ScratchFrameMorph) fixLayout
	].
	closeAndOpenButton off.! !
