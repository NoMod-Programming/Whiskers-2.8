PasteUpMorph subclass: #ScratchScriptsMorph
	instanceVariableNames: 'feedbackMorph screenshooting resizeButtons isBackpack '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Panes'!
!ScratchScriptsMorph commentStamp: '<historical>' prior: 0!
I hold the scripts and partially assembled scripts for a ScriptableScratchMorph.
!


!ScratchScriptsMorph methodsFor: 'initialization' stamp: 'EMP 10/10/2015 16:18'!
initialize

	super initialize.
	color _ Color white.
	borderWidth _ 0.
	self enableDragNDrop: true.
	resizeButtons _ OrderedCollection new.! !


!ScratchScriptsMorph methodsFor: 'stepping' stamp: 'jens 3/3/2009 21:46'!
showCommentDropFeedback

	| hand comment target r |

	hand _ World activeHand.
	comment _ hand firstSubmorph.
	target _ comment attachTargetIn: self.
	target ifNil: [^ self].

	r _ target bounds.

	((target isKindOf: CBlockMorph) and: [target firstBlockList size > 0])
		ifTrue: [r _ r merge: target firstBlockList first fullBounds].
	(target isKindOf: IfElseBlockMorph)
		ifTrue: [
			(target trueBlockList size > 0)
				ifTrue: [r _ r merge: target trueBlockList first fullBounds].
			(target falseBlockList size > 0)
				ifTrue: [r _ r merge: target falseBlockList first fullBounds]].
	feedbackMorph
		bounds: (r expandBy: 3);
		color: Color transparent;
		borderColor: (comment topBarColor).
	self addMorphFront: feedbackMorph.
! !

!ScratchScriptsMorph methodsFor: 'stepping' stamp: 'EMP 10/3/2015 19:55'!
step
	"Give feedback about possible drop targets."

	| feedbackColor h b targetArg targetAssoc targetP targetBlock |

	feedbackMorph
		ifNil: [feedbackMorph _ BorderedMorph new borderWidth: 3]  "create feedback morph if necessary"
		ifNotNil: [feedbackMorph delete].  "remove old feedback"
	feedbackColor _ Color white.
	feedbackMorph useSquareCorners.

	h _ World activeHand.
	h toolType = 'CutTool' ifTrue: [^ self showDeleteFeedback].

	(self bounds containsPoint: h position) ifFalse: [^ self].
	h submorphCount = 1 ifFalse: [^ self].
	b _ h firstSubmorph.
	(b isKindOf: ScratchCommentMorph) ifTrue: [^ self showCommentDropFeedback].
	(b isKindOf: BlockMorph) ifFalse: [^ self].

"attempt at auto-scrolling (has some issues, commented out for now):

	((self owner bounds containsPoint: h position) and:
		[(h position x - self owner left) < 50 or: [
			(self owner right - h position x) < 50 or: [
				(self owner bottom - h position y) < 50 or: [
					(h position y - self owner top) < 50]]]])
		ifTrue:[self owner scrollMorphIntoView: h firstSubmorph].
xxxxxxxx"

	b isReporter ifTrue: [ "reporter block"
		(targetArg _ self topArgMorphAt: b bounds exclude: nil) ifNil: [^ self].
		(targetArg acceptsTypeOf: b) ifFalse: [^ self].
		feedbackMorph
			bounds: (targetArg bounds expandBy: 5);
			color: (feedbackColor alpha: 0.4);
			borderColor: feedbackColor;
			useRoundedCorners.
		^ self addMorphFront: feedbackMorph].

	"non-reporter (i.e. command block or hat block)"
	targetAssoc _ b closestAttachTargetIn: self.
	targetAssoc ifNil: [
		(b bottomBlock isKindOf: CBlockMorph) ifFalse: [
			targetAssoc _ b bottomBlock closestAttachTargetIn: self.
			targetAssoc ifNotNil:[
				(targetAssoc value owner isKindOf: BlockMorph) ifTrue:[
					targetAssoc _ nil]]]].
	targetAssoc ifNil: [^ self].

	targetP _ targetAssoc key.
	targetBlock _ targetAssoc value.
	feedbackMorph borderColor: feedbackColor; color: feedbackColor.

	"subtract the attachment point x from the width so that the feedback in CBlock won't stick out"
	ScratchTranslator isRTL
		ifTrue: [feedbackMorph extent: (targetP x - targetBlock left)@5.
			self addMorphFront: (feedbackMorph position: targetP - (feedbackMorph width@0))]
		ifFalse: [feedbackMorph extent: (targetBlock right - targetP x)@5.
			self addMorphFront: (feedbackMorph position: targetP)].
! !

!ScratchScriptsMorph methodsFor: 'stepping' stamp: 'md 2/20/2004 17:31'!
stepTime

	^ 50
! !

!ScratchScriptsMorph methodsFor: 'stepping' stamp: 'EMP 11/8/2015 14:12'!
topArgMorphAt: aRectangle exclude: aMorph
	"Give feedback about possible drop targets."

	| stack argM |
	"find the top block or stack under the given point, excluding the given morph"
	stack _ submorphs
		detect: [:m | (m ~~ aMorph) and: [(m isKindOf: BlockMorph) and: [m fullBounds intersects: aRectangle]]]
		ifNone: [^ nil].

	stack allMorphsDo: [:b |
		((b isKindOf: CommandBlockMorph) and:
		 [(b isKindOf: HatBlockMorph) not]) ifTrue: [
			(b isMobile) ifTrue: [
			1 to: b argumentCount do: [:i |
				argM _ b argumentAt: i.
				((argM bounds intersects: aRectangle) and:
				 [argM acceptsDroppedReporters])
					ifTrue: [^ argM]]]].
		(b isKindOf: WhenHatBlockMorph) ifTrue: [
			(b isKindOf: ProcedureHatBlockMorph) ifFalse: [
			argM _ b argMorph.
			((argM bounds intersects: aRectangle) and:
			 [argM acceptsDroppedReporters])
				ifTrue: [^ argM]]].
		(b isKindOf: WhenTrueHatBlockMorph) ifTrue: [
			argM _ b argMorph.
			((argM bounds intersects: aRectangle) and:
			 [argM acceptsDroppedReporters])
				ifTrue: [^ argM]]].
	^ nil
! !

!ScratchScriptsMorph methodsFor: 'stepping' stamp: 'md 3/1/2004 16:45'!
topBlockMorphAt: aPoint exclude: aMorph
	"Give feedback about possible drop targets."

	| stack answer blocksUnderHand |
	stack _ submorphs
		detect: [:m | (m isKindOf: BlockMorph) and: [m fullBounds containsPoint: aPoint]]
		ifNone: [^ nil].

	blocksUnderHand _ OrderedCollection new.
	stack allMorphsDo: [:s | ((s isKindOf: BlockMorph) and: [s bounds containsPoint: aPoint]) 
		ifTrue: 	[blocksUnderHand addLast: s]
	].
	
	(blocksUnderHand isEmpty) ifTrue: [^ nil]
	ifFalse: [answer _ blocksUnderHand first. ^ answer]	

! !


!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'ee 7/1/2008 20:40'!
cleanUp
	"Align all scripts vertically in alphabetical order"

	| sortedBlocks y collectedBlocks |
	collectedBlocks _ OrderedCollection new.
	submorphs do: [:m | (m isKindOf: BlockMorph) ifTrue:[collectedBlocks add: m]].
	sortedBlocks _ collectedBlocks copy sortBy: [:s1 :s2 | s1 top < s2 top].

	y _ 20.
	(owner isKindOf: ScrollFrameMorph2) ifTrue: [
		owner hScrollPixels: 0.
		owner vScrollPixels: 0].
	sortedBlocks do: [:s |
		ScratchTranslator isRTL
			ifTrue: [(owner isKindOf: ScrollFrameMorph2)
				ifTrue: [s position: (owner left + owner visibleExtent x - s width - 29)@(self top + y)]
				ifFalse: [s position: (self right - s width - 20)@(self top + y)]]
			ifFalse: [s position: self position + (20@y)].
		y _ y + s fullBounds height + 15].

	self layoutChanged.
! !

!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'md 2/18/2004 14:58'!
handlesMouseDown: evt
	
	^ true! !

!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'EMP 10/1/2015 15:38'!
mouseDown: evt

	| m |
	evt hand newKeyboardFocus: nil.

	evt hand toolType ifNotNil: [
		"revert to normal cursor"
		evt hand toolType: nil.
		^ self].

	evt rightButtonPressed ifTrue: [
		Sensor waitNoButton.
		(m _ self ownerThatIsA: ScratchScriptEditorMorph) ifNil: [(m _ self ownerThatIsA: WorkSpaceDialogMorph) ifNil: [^ self]].
		(m target notNil and: [m currentCategory = 'Scripts'])
			ifTrue: [m scriptsMenu: evt hand position].
		^ self].

	evt hand waitForClicksOrDrag: self event: evt.
! !

!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'ee 2/3/2009 13:29'!
mouseEnterDragging: evt
	"Switch the tabs to script if a block is current being dragged"

	| scriptEditorMorph |
	scriptEditorMorph _ self ownerThatIsA: ScratchScriptEditorMorph.
	(scriptEditorMorph currentCategory = 'Scripts') ifFalse:[
		scriptEditorMorph currentCategory: 'Scripts'].
! !

!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'EMP 10/1/2015 15:39'!
mouseHold: evt

	| m |
	(m _ self ownerThatIsA: ScratchScriptEditorMorph) ifNil: [(m _ self ownerThatIsA: WorkSpaceDialogMorph) ifNil: [^ self]].
	(m target notNil and: [m currentCategory = 'Scripts'])
		ifTrue: [m scriptsMenu: evt hand position].
! !

!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'EMP 11/2/2015 20:44'!
saveScriptsToImage
	"Take a snapshot of all scripts for a sprite and save as a GIF file"

	| fName saveForm |

	saveForm _ self screenshot.

	fName _ ScratchFileChooserDialog
		chooseNewFileDefault: ''
		title: 'Save Scripts Snapshot'
		type: #scriptsSnapshot.
	fName = #cancelled ifTrue: [^ self].
	fName size = 0 ifTrue: [^ self].

	(fName asLowercase endsWith: '.gif') ifFalse: [fName _ fName, '.gif'].
	saveForm writeGIFFileNamed: fName.
! !


!ScratchScriptsMorph methodsFor: 'drawing'!
drawOn: aCanvas
	"Fill with my texture patch. Fill with a solid color if there is no texture in the current skin dictionary."

	| patchF clipC y x |

	self isScreenshooting ifTrue: [
		aCanvas fillRectangle: self bounds color: Color transparent.
		^ self].

		aCanvas fillRectangle: self bounds color: (Color r: 222/255 g: 222/255 b: 222/255).
		^ self


	"patchF _ ScratchFrameMorph skinAt: #scriptsPaneTexture ifAbsent: [
		aCanvas fillRectangle: self bounds color: color.
		^ self].

	clipC _ aCanvas copyClipRect: self bounds.
	y _ self top.
	[y <= self bottom] whileTrue: [
		x _ self left.
		[x <= self right] whileTrue: [
			clipC paintImage: patchF at: x@y.
			x _ x + patchF width].
		y _ y + patchF height]."
! !

!ScratchScriptsMorph methodsFor: 'drawing' stamp: 'ee 1/1/2006 15:42'!
showDeleteFeedback
	"Display feedback for the scissors tool."

	| h cutBlock r |
	h _ World activeHand.
	(cutBlock _ self topBlockMorphAt: h cursorPoint exclude: nil) ifNil: [^ self].
	r _ cutBlock bounds.
	((cutBlock isKindOf: CBlockMorph) and: [cutBlock firstBlockList size > 0])
		ifTrue: [r _ r merge: cutBlock firstBlockList first fullBounds].
	(cutBlock isKindOf: HatBlockMorph)
		ifTrue: [r _ cutBlock fullBounds].
	feedbackMorph
		bounds: (r expandBy: 3);
		color: Color transparent;
		borderColor: (Color r: 212/255 g: 40/255 b: 40/255).
	self addMorphFront: feedbackMorph.
! !


!ScratchScriptsMorph methodsFor: 'object i/o' stamp: 'jm 9/30/2003 21:29'!
fieldsVersion
	"I depend on my superclass for object i/o. Currently, thos methods are inherited from Morph."

	^ 1
! !


!ScratchScriptsMorph methodsFor: 'screenshot' stamp: 'EMP 10/10/2015 16:12'!
createResizeButtons
	"Add buttons to set the rotation style."

	| specs x y style button |
	self deleteResizeButtons.

	specs _ #(
		(Left		'make blocks smaller')
		(Middle		'set blocks to the default size')
		(Right		'make blocks bigger')).

	x _ self left + 13.
	y _ self top + 12.
	specs do: [:pair |
		style _ pair first.
		button _ ToggleButton
			onForm: (ScratchFrameMorph skinAt: ('sizeButton', style))
			offForm: (ScratchFrameMorph skinAt: ('sizeButton', style))
			overForm: (ScratchFrameMorph skinAt: ('sizeButton', style)).
		button
			target: ScratchFrameMorph;
			arguments: (Array with: style);
			actionSelector: #changeSize:;
			setBalloonText: pair second localized;
			actWhen: #buttonDown;
			position: x@y.
		self addMorph: button.
		resizeButtons _ resizeButtons copyWith: button.
		x _ x + button width + 10].

	self updateResizeButtonHighlight.
! !

!ScratchScriptsMorph methodsFor: 'screenshot' stamp: 'EMP 10/10/2015 16:08'!
deleteResizeButtons
	resizeButtons ifNotNil: [
	resizeButtons do: [:m | m delete].
	resizeButtons _ #()].
! !

!ScratchScriptsMorph methodsFor: 'screenshot' stamp: 'jens 3/9/2009 13:02'!
isScreenshooting

	^ screenshooting ifNil: [screenshooting _ false]
! !

!ScratchScriptsMorph methodsFor: 'screenshot' stamp: 'jens 3/9/2009 13:44'!
screenshot
	"answer a Form of myself apt for exporting"

	| saveForm leftX topY rightX bottomY |

	screenshooting _ true.
	self changed.
	saveForm _ self imageForm.

	"clip"

	leftX _ submorphs anyOne left.
	topY _ submorphs anyOne top.
	rightX _ submorphs anyOne right.
	bottomY _ submorphs anyOne bottom.
	(self allMorphs select: [:m | m ~= self]) do: [:m |
		leftX _ leftX min: m left.
		topY _ topY min: m top.
		rightX _ rightX max: m right.
		bottomY _ bottomY max: m bottom].
	saveForm _ saveForm copy: (((leftX @ topY) - self position) rect: ((rightX @ bottomY) - self position)).

	screenshooting _ false.
	self changed.
	^ saveForm
! !

!ScratchScriptsMorph methodsFor: 'screenshot' stamp: 'EMP 10/10/2015 16:16'!
updateResizeButtonHighlight
	^ self! !
