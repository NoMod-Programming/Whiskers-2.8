BorderedMorph subclass: #ScratchBlockPaletteMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!ScratchBlockPaletteMorph commentStamp: '<historical>' prior: 0!
I am used as a scrollable blocks palette morph in a ScratchViewerMorph.
!


!ScratchBlockPaletteMorph methodsFor: 'initialization' stamp: 'jm 3/29/2008 11:07'!
initialize

	super initialize.
	borderWidth _ 0.
! !


!ScratchBlockPaletteMorph methodsFor: 'dropping/grabbing' stamp: 'jm 3/18/2005 12:28'!
acceptDroppingMorph: aMorph event: evt
	"This method allows re-ordering of media in the costumes and sounds tabs."

	| editor mediaItems insertAfter |
	((aMorph isKindOf: MediaItemMorph) and:
	 [(editor _ self ownerThatIsA: ScratchScriptEditorMorph) notNil])
		ifFalse: [^ super acceptDroppingMorph: aMorph event: evt].

	mediaItems _ self submorphs select: [:m |
		(m isKindOf: MediaItemMorph) and:
		 [(m ~~ aMorph) and:
		 [(m media mediaType = aMorph media mediaType) and:
		 [m bounds intersects: aMorph bounds]]]].
	mediaItems _ mediaItems sort: [:m1 :m2 | m1 top < m2 top].

	mediaItems isEmpty
		ifTrue: [insertAfter _ nil]  "end of list"
		ifFalse: [
			aMorph center y > mediaItems last center y
				ifTrue: [insertAfter _ nil]  "end of list"
				ifFalse: [insertAfter _ mediaItems last media]].

	editor target insertMedia: aMorph media before: insertAfter.
! !

!ScratchBlockPaletteMorph methodsFor: 'dropping/grabbing' stamp: 'jm 7/1/2004 23:15'!
isPartsBin

	^ true
! !

!ScratchBlockPaletteMorph methodsFor: 'dropping/grabbing' stamp: 'jm 7/1/2004 23:21'!
rootForGrabOf: aMorph
	"I act like a parts bin; answer a new copy of the morph being extracted."

	| root |
	root _ aMorph.
	(root isKindOf: BlockMorph) ifFalse: [^ nil].
	[root = self] whileFalse: [
		root owner == self ifTrue: [^ root fullCopy].
		root _ root owner].

	^ super rootForGrabOf: aMorph
! !

!ScratchBlockPaletteMorph methodsFor: 'dropping/grabbing' stamp: 'jm 12/21/2008 12:44'!
wantsDroppedMorph: aMorph event: evt

	| f |
	((aMorph isKindOf: BlockMorph) or:
	 [(aMorph isKindOf: MediaItemMorph) or:
	 [(aMorph isKindOf: LibraryItemMorph) or:
	 [aMorph isKindOf: ScratchCommentMorph]]])
		ifTrue: [^ true].

	(aMorph isKindOf: ScratchSpriteMorph) ifTrue: [
		f _ self ownerThatIsA: ScratchFrameMorph.
		f viewerPane pageViewer contents = self ifTrue: [^ true]].

	^ false
! !


!ScratchBlockPaletteMorph methodsFor: 'other' stamp: 'EMP 12/18/2015 22:08'!
fixLayout
	"Right align the blocks in the palette if RTL is set to true. The watcher toggle checkbox buttons are assumed to be about 18 pixels wide."

	| offset r |
	owner ifNil: [^ self].
	ScratchTranslator isRTL ifTrue:[
		self submorphs do: [:m |
			(m isKindOf: BlockMorph) ifTrue: [
				m canBecomeWatcher
					ifTrue: [m position: (self right - m width - 18 - 10)@(m position y)]
					ifFalse: [m position: (self right - m width - 10)@(m position y)].
				m changed].
			((m isKindOf: ToggleButton) or: [m isKindOf: ResizableToggleButton2]) ifTrue:[	"watcher checkbox case"
				m position: (self right - m width - 10)@(m position y)].
			(m isKindOf: ImageMorph) ifTrue: [
				m position: (self right - m width - 10)@(m position y)]]].
	offset _ self topLeft negated.
	r _ 0@0 extent: 1@1.
	self submorphsDo: [:m |
		r _ r quickMerge: (m fullBounds translateBy: offset) truncated].
	self width: (r width max: owner width).! !

!ScratchBlockPaletteMorph methodsFor: 'other' stamp: 'jm 12/1/2007 20:56'!
updateWatcherButtonsForFrame: frame
	"Update the watcher button on this palette."

	| reporter sprite selAndArg |
	frame ifNil: [^ self].

	submorphs do: [:b |
		((b isKindOf: ToggleButton) and:
		 [b target isKindOf: ReporterBlockMorph]) ifTrue: [
			reporter _ b target.
			sprite _ reporter getAssociatedSprite.
			selAndArg _ reporter selectorAndArg.
			(frame watcherShowingFor: sprite selectorAndArg: selAndArg)
				ifTrue: [b on; setProperty: #balloonText toValue: 'Remove viewer from stage' localized]
				ifFalse: [b off; setProperty: #balloonText toValue: 'View on stage' localized]]].
! !
