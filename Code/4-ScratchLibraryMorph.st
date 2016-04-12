DividedImageFrameMorph subclass: #ScratchLibraryMorph
	instanceVariableNames: 'scrollPane stagePane thumbWidth itemExtent spritePane buttonPane spriteLabel showingInfoFor infoMorph showingInfo '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Panes'!
!ScratchLibraryMorph commentStamp: '<historical>' prior: 0!
I am a Scratch library viewer. I display thumbnails of all the Scratch objects that exist in the world including the stage. Clicking on one of these thumbnails views the associated scratch object.
!


!ScratchLibraryMorph methodsFor: 'initialization' stamp: 'EMP 11/13/2015 16:30'!
buildPanes
	"Build my scroll pane."

	| bin |
	stagePane _ Morph new
		color: Color transparent;
		position: self position + (7@0).

	bin _ ScratchSpriteLibraryMorph new
		color: Color transparent;
		borderWidth: 0.

	scrollPane _ ScrollFrameMorph2 new
		color: Color transparent;
		contents: bin;
		showHorizontalScrollbar: false.

	spritePane _ ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #libraryTop);
		position: (self position).
	spriteLabel _ self buildSpriteLabel.
	buttonPane _ self makeNewSpriteButtons: (self ownerThatIsA: ScratchFrameMorph).

	self addMorph: spritePane.
	"self addMorph: spriteLabel."
	self addMorph: buttonPane.
	self addMorph: scrollPane.
	self addMorph: stagePane.
! !

!ScratchLibraryMorph methodsFor: 'initialization'!
buildSpriteLabel

	^ StringMorph new
		font: (ScratchFrameMorph getFont: #Tab);
		color: Color black;
		contents: 'New sprite:' localized
! !

!ScratchLibraryMorph methodsFor: 'initialization' stamp: 'EMP 11/16/2015 14:59'!
clearLibrary
	"Remove all library items. My step method will re-add items for existing objects."

	| sFrame |
	stagePane removeAllMorphs.
	scrollPane contents removeAllMorphs.
	scrollPane vScrollRelative: 0.

	spriteLabel delete.
	spriteLabel _ self buildSpriteLabel.

	sFrame _ self ownerThatIsA: ScratchFrameMorph.
	(sFrame isNil or:
	 [sFrame viewMode = #normal]) ifTrue: [
		self addMorph: spriteLabel].

	buttonPane delete.
	buttonPane _ self makeNewSpriteButtons: sFrame.
	self addMorph: buttonPane.

	topSectionHeight _ 30.
	self fixLayout.
! !

!ScratchLibraryMorph methodsFor: 'initialization' stamp: 'EMP 11/16/2015 14:56'!
initialize

	super initialize.
	self buildPanes.
	self
		initFrontFromForm: (ScratchFrameMorph skinAt: 'blankFrame')
		topSectionHeight: 23 "I don't know why I had to change this manually".
	self middleBarLeftMargin: 0 rightMargin: 0.
	frameInFront _ false.
	self extent: 200@100.
	showingInfoFor _ nil.! !

!ScratchLibraryMorph methodsFor: 'initialization' stamp: 'EMP 11/16/2015 14:54'!
makeNewSpriteButtons: aScratchFrameMorph
	"Return a morph containing a set of new sprite buttons."

	| panel buttonSpecs buttons button butonExtent x |
	panel _ Morph new color: Color transparent.

	buttonSpecs _ #(
		"	icon name				selector					tooltip"
		(newSpriteSurprise 		surpriseSpriteMorph		'Get surprise sprite')
		(newSpritePaint			paintSpriteMorph		'Paint new sprite')
		(newSpriteLibrary		addSpriteMorph			'Choose new sprite from file')
	).

	buttons _ buttonSpecs collect: [:spec |
		button _ ToggleButton new
			onForm: (ScratchFrameMorph skinAt: (spec at: 1))
			offForm: (ScratchFrameMorph skinAt: (spec at: 1)).

		button
			target: aScratchFrameMorph;
			actionSelector: (spec at: 2);
			setProperty: #balloonText toValue: (spec at: 3) localized.
		button].

	butonExtent _ ScratchFrameMorph isXO ifTrue: [27@23] ifFalse: [27@23].
	x _ 12.
	panel addMorph: (spriteLabel position: x@10).
	x _ x + 5 + spriteLabel width.
	buttons do: [:b |
		b extent: butonExtent.
		panel addMorph: (b position: x@6).
		x _ x + b width - 5].

	panel extent: (x)@(butonExtent y + 1).

	^ panel
! !


!ScratchLibraryMorph methodsFor: 'accessing' stamp: 'EMP 12/12/2015 12:31'!
showInfo: aSpriteOrAStageMorph
	showingInfoFor = aSpriteOrAStageMorph ifFalse: [infoMorph ifNotNil: [infoMorph delete].
	showingInfoFor _ nil.
	infoMorph _ nil.
	self updateInfoButtonMorphs.
	showingInfo _ false].
	showingInfo ifFalse: [
	showingInfo _ true.
	showingInfoFor _ aSpriteOrAStageMorph.
	infoMorph _ ScratchInfoMorph new.
	infoMorph target: aSpriteOrAStageMorph.
	self addMorph: (infoMorph position: ((stagePane right + 3) @ (self top + topSectionHeight)); extent: ((self width - (stagePane right + 1)) @ (self height - topSectionHeight)))].
	! !

!ScratchLibraryMorph methodsFor: 'accessing' stamp: 'EMP 9/30/2015 14:24'!
showingInfo
	^ (showingInfo = true)! !

!ScratchLibraryMorph methodsFor: 'accessing' stamp: 'ee 11/10/2008 14:10'!
spriteButtonsTarget: anObject

	buttonPane submorphs do: [:m |
		(m isKindOf: ToggleButton) ifTrue: [
			m target: anObject]].! !

!ScratchLibraryMorph methodsFor: 'accessing' stamp: 'tis 9/11/2006 10:46'!
spriteThumbnails

	^ scrollPane contents submorphs
! !

!ScratchLibraryMorph methodsFor: 'accessing' stamp: 'EMP 12/12/2015 12:30'!
toggleInfo: aSpriteOrAStageMorph
	aSpriteOrAStageMorph = showingInfoFor ifTrue: [infoMorph ifNotNil: [infoMorph delete].
	showingInfoFor _ nil.
	infoMorph _ nil.
	self updateInfoButtonMorphs.
	showingInfo _ false]
	ifFalse: [
	showingInfo _ true.
	showingInfoFor _ aSpriteOrAStageMorph.
	infoMorph _ ScratchInfoMorph new.
	infoMorph target: aSpriteOrAStageMorph.
	self addMorph: (infoMorph position: ((stagePane right + 3) @ (self top + topSectionHeight)); extent: ((self width - (stagePane right + 1)) @ (self height - topSectionHeight)))]
	! !

!ScratchLibraryMorph methodsFor: 'accessing' stamp: 'EMP 9/29/2015 14:55'!
updateInfoButtonMorphs

	scrollPane contents submorphs do: [:m | m infoButtonOff].
	stagePane submorphs do: [:m | m infoButtonOff].
! !


!ScratchLibraryMorph methodsFor: 'geometry' stamp: 'EMP 2/7/2016 11:09'!
extent: aRectangle

	| nameHeight |
	super extent: aRectangle.
	scrollPane isNil | stagePane isNil ifTrue: [^ self].
	
	thumbWidth _ 50.
	nameHeight _ (ScratchTranslator stringExtent: ('Sprite1' localized) font: (ScratchFrameMorph getFont: #LibraryItemName)) y.
	itemExtent _ (60 + nameHeight)@(60 + nameHeight).
	stagePane left: self left.
	stagePane width: itemExtent x.
	scrollPane left: stagePane right.

	self fixLayout.
! !

!ScratchLibraryMorph methodsFor: 'geometry' stamp: 'EMP 2/7/2016 11:06'!
fixLayout
	| t1 t2 t3 t4 t6 |
	scrollPane isNil | stagePane isNil | spritePane isNil
		ifTrue: [^ self].
	spritePane width: self width.
	spritePane height: topSectionHeight + 2.
	spritePane right: self right.
	buttonPane position: self left @ (self top + (topSectionHeight // 2) - (buttonPane height // 2) - 4).
	buttonPane right: self right - 15.
	stagePane height = self height
		ifFalse: [stagePane height: self height].
	scrollPane height = self height
		ifFalse: [scrollPane height: self height - topSectionHeight].
	scrollPane width = (self right - stagePane right - 1)
		ifFalse: [scrollPane width: self right - stagePane right - 1].
	scrollPane position: scrollPane left @ (self top + topSectionHeight).
	stagePane position: stagePane left @ (self top + topSectionHeight).
	t1 := scrollPane contents.
	ScratchTranslator isRTL
		ifTrue: [t4 := t1 left + 30]
		ifFalse: [t4 := t1 left + 5].
	t6 := t1 top + 3.
	t2 := t4 + scrollPane width - 5.
	t1 submorphs
		do: [:t7 | 
			t4 + t7 width > t2
				ifTrue: [ScratchTranslator isRTL
						ifTrue: [t4 := t1 left + 30]
						ifFalse: [t4 := t1 left + 5].
					t6 := t6 + t7 height + 2].
			t7 position: t4 @ t6.
			t4 := t4 + t7 width + 3].
	scrollPane layoutChanged.
	stagePane submorphCount > 0
		ifTrue: [t3 := stagePane firstSubmorph.
			t3 position: stagePane center x - (t3 width // 2) + 2 @ (stagePane top + 5)]! !


!ScratchLibraryMorph methodsFor: 'drawing' stamp: 'EMP 11/16/2015 12:16'!
drawBackgroundOn: aCanvas
	"Draw my background."

	| |
	"color isTransparent ifTrue: [^ self]."
	color _ (Color r:230/255 g:232/255 b:232/255).

	aCanvas fillRectangle: (myBox) color: color.
! !

!ScratchLibraryMorph methodsFor: 'drawing' stamp: 'EMP 11/16/2015 12:14'!
drawOn: aCanvas
	| r |
	super drawOn: aCanvas.
	r _ ((stagePane right + 3) @ (myBox top)) extent: (1 @ self height).
	aCanvas fillRectangle: r color: (Color r: 208/255 g: 209/255 b: 210/255).
	^ aCanvas! !

!ScratchLibraryMorph methodsFor: 'drawing' stamp: 'EMP 11/17/2015 09:34'!
fullDrawOn: aCanvas
	| r |
	super fullDrawOn: aCanvas.
	r _ ((stagePane right + 3) @ (myBox top)) extent: (1 @ ((showingInfo = true) ifTrue: [topSectionHeight] ifFalse: [self height])).
	aCanvas fillRectangle: r color: (Color r: 208/255 g: 209/255 b: 210/255).! !


!ScratchLibraryMorph methodsFor: 'stepping' stamp: 'EMP 10/3/2015 19:50'!
step
	"Update my thumbnail list if morphs have been added or deleted."

	| sFrame workPane morphsWithThumbnails doLayout workPaneObjects |
	(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self].
	sFrame paintingInProgress
		ifTrue: [^ self]
		ifFalse: [scrollPane owner ifNil: [self addMorph: scrollPane]].

	workPane _ sFrame workPane.
	infoMorph ifNotNil: [infoMorph step]. "I can't seem to get stepping to work :P"
	"remove thumbnails for any objects that have been deleted"
	morphsWithThumbnails _ IdentitySet new.
	doLayout _ false.
	scrollPane contents submorphs do: [:m |
		(m target isNil or: [m target owner isNil])
			ifTrue: [m delete. doLayout _ true]
			ifFalse: [morphsWithThumbnails add: m target]].
	stagePane submorphs do: [:m |
		(m target isNil or: [m target owner isNil])
			ifTrue: [m delete. doLayout _ true]
			ifFalse: [morphsWithThumbnails add: m target]].

	"add thumbnail for the background, if necessary"
	(morphsWithThumbnails includes: workPane) ifFalse: [
		self addThumbnailFor: workPane.
		doLayout _ true].

	"add thumbnails for any new objects"
	workPaneObjects _ workPane sprites select: [:s |
		(s isKindOf: ScriptableScratchMorph) and: [s isScriptable & s isClone not]].
	workPaneObjects do: [:m |
		(morphsWithThumbnails includes: m) ifFalse: [
			self addThumbnailFor: m.
			doLayout _ true]].

	doLayout ifTrue: [
		self changed.
		self fixLayout.
		self isInWorld ifTrue: [self world startSteppingSubmorphsOf: self]].

	self updateHighlight.
! !

!ScratchLibraryMorph methodsFor: 'stepping' stamp: 'EMP 10/3/2015 19:42'!
stepTime

	^ 100
! !


!ScratchLibraryMorph methodsFor: 'private' stamp: 'EMP 9/28/2015 16:04'!
addThumbnailFor: aMorph
	"Add a thumbnail for the given morph."

	| newThumbnail |
	newThumbnail _ LibraryItemMorph new.
	newThumbnail extent: itemExtent thumbWidth: thumbWidth.
	newThumbnail  target: aMorph.
	(newThumbnail target isKindOf: ScratchStageMorph)
		ifTrue: [stagePane addMorph: newThumbnail]
		ifFalse: [scrollPane contents addMorphBack: newThumbnail].
	newThumbnail addInfoButton.
	newThumbnail step.
! !

!ScratchLibraryMorph methodsFor: 'private' stamp: 'EMP 9/30/2015 14:20'!
click: evt
	^ nil! !

!ScratchLibraryMorph methodsFor: 'private' stamp: 'EMP 9/30/2015 14:20'!
doubleClick: evt
	^ nil! !

!ScratchLibraryMorph methodsFor: 'private' stamp: 'EMP 9/30/2015 14:20'!
handlesMouseDown: evt
	^ true! !

!ScratchLibraryMorph methodsFor: 'private' stamp: 'EMP 9/30/2015 14:17'!
mouseDown: evt
	^ nil! !

!ScratchLibraryMorph methodsFor: 'private' stamp: 'EMP 9/30/2015 14:21'!
mouseMove: evt
	^ nil! !

!ScratchLibraryMorph methodsFor: 'private' stamp: 'jm 11/21/2006 16:02'!
unhighlightAll

	scrollPane contents submorphs do: [:m | m highlight: false].
	stagePane submorphs do: [:m | m highlight: false].
! !

!ScratchLibraryMorph methodsFor: 'private' stamp: 'jm 11/21/2006 16:02'!
updateHighlight

	| sFrame viewedObj |
	(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self].
	viewedObj _ sFrame viewerPane target.

	scrollPane contents submorphs do: [:m | 
		m highlight: (m target = viewedObj)].
	stagePane submorphs do: [:m | 
		m highlight: (m target = viewedObj)].
! !
