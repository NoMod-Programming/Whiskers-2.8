Morph subclass: #LibraryItemMorph
	instanceVariableNames: 'target thumbnailMorph nameMorph scriptCountMorph isSelected rolloverOn lastUpdateMSecs highlightForm currentForm thumbWidth rolloverForm infoButtonMorph thumbnailMorphHolder beingDragged drewOnce '
	classVariableNames: 'InfoFont NameFont '
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!LibraryItemMorph commentStamp: '<historical>' prior: 0!
I represent a scriptable morph in the library pane. I display a thumbnail of the morph, its name, and some information about it.
!


!LibraryItemMorph methodsFor: 'initialization' stamp: 'EMP 11/17/2015 09:55'!
addInfoButton
		infoButtonMorph _ ToggleButton
		onForm: (ScratchFrameMorph skinAt: #infoButton) 
		offForm: (ScratchFrameMorph skinAt: #infoButtonPressed)
		overForm: (ScratchFrameMorph skinAt: #infoButtonPressed).
	infoButtonMorph
		position: self topLeft;
		target: (self ownerThatIsA: ScratchLibraryMorph);
		arguments: ((Array with: (self target)));
		actionSelector: #toggleInfo:;
		setBalloonText: 'show info for this sprite';
		actWhen: #buttonUp;
		comeToFront.
	(target isKindOf: ScratchStageMorph) ifFalse: [
	self addMorph: infoButtonMorph].! !

!LibraryItemMorph methodsFor: 'initialization' stamp: 'EMP 2/9/2016 16:45'!
buildSubmorphs
	"LibraryItemMorph open"

	thumbnailMorph _ ImageMorph new
		form: (Form extent: (self width - 5)@(self width - 5) depth: 16) fillWhite.
	thumbnailMorph position: (self center x - (thumbnailMorph width // 2)) @ 0.
	self addMorph: thumbnailMorph.
	nameMorph _ StringMorph new
		font: (ScratchFrameMorph getFont: #LibraryItemName);
		position: 0 @ (thumbnailMorph bottom - 10);
		color: Color black.
	self addMorph: nameMorph.

	self color: Color transparent.
! !

!LibraryItemMorph methodsFor: 'initialization' stamp: 'ee 3/25/2009 09:17'!
extent: aRectangle thumbWidth: w

	lastUpdateMSecs _ -1.
	self extent: aRectangle.
	thumbWidth _ w.

	self buildSubmorphs.
	self target: nil.
	isSelected _ nil.
	rolloverOn _ false.
	highlightForm _ ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #librarySelected).
	highlightForm extent: self extent.
	rolloverForm _ ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #libraryRollover).
	rolloverForm extent: self extent.
	currentForm _ nil.
	self highlight: false.
! !

!LibraryItemMorph methodsFor: 'initialization' stamp: 'EMP 9/29/2015 14:55'!
infoButtonOff
	infoButtonMorph off! !


!LibraryItemMorph methodsFor: 'accessing' stamp: 'jm 7/11/2008 06:45'!
color

	currentForm
		ifNil: [^ color]
		ifNotNil: [^ currentForm color].
! !

!LibraryItemMorph methodsFor: 'accessing' stamp: 'EMP 2/7/2016 10:54'!
highlight: t1 
	| t2 |
	isSelected = t1
		ifTrue: [^ self].
	isSelected := t1.
	isSelected
		ifTrue: [rolloverOn := false.
			highlightForm extent: self extent.
			currentForm
				ifNotNil: [currentForm delete].
			currentForm := highlightForm.
			self
				addMorphBack: (currentForm position: self position).
			(target isKindOf: ScratchStageMorph)
				ifFalse: [infoButtonMorph
						ifNotNil: [self addMorph: infoButtonMorph]].
			t2 := Color black]
		ifFalse: [currentForm
				ifNotNil: [currentForm delete.
					currentForm := (self target isKindOf: ScratchSpriteMorph)
								ifTrue: [rolloverForm].
					currentForm
						ifNotNil: [self
								addMorphBack: (currentForm position: self position)]].
			t2 := Color black.
			infoButtonMorph
				ifNotNil: [infoButtonMorph delete]].
	nameMorph color: t2.
	self changed! !

!LibraryItemMorph methodsFor: 'accessing' stamp: 'jm 6/18/2004 09:15'!
target

	^ target
! !

!LibraryItemMorph methodsFor: 'accessing' stamp: 'EMP 2/10/2016 14:26'!
target: t1 
	target := t1.
		(target isKindOf: ScratchStageMorph) ifTrue: [
	scriptCountMorph _ StringMorph new
		font: (ScratchFrameMorph getFont: #LibraryItemInfo);
		contents: '';
		color: (Color gray: 0.1).
	self height: (self height + 4 + scriptCountMorph height).
	self addMorph: (scriptCountMorph position: 0 @ nameMorph bottom)].
	currentForm
		ifNotNil: [currentForm delete].
	currentForm := (t1 isKindOf: ScratchSpriteMorph)
				ifTrue: [rolloverForm].
	currentForm
		ifNotNil: [self
				addMorphBack: (currentForm position: self position)]! !


!LibraryItemMorph methodsFor: 'drawing' stamp: 'jm 7/10/2004 15:33'!
areasRemainingToFill: aRectangle
	"Drawing optimization. Since I clip drawing of my submorphs, this method tells Morphic that it isn't necessary to draw any morphs covered by me. This is a little lie because I have rounded corners."
	
	^ aRectangle areasOutside: self bounds
! !

!LibraryItemMorph methodsFor: 'drawing' stamp: 'EMP 2/7/2016 11:02'!
drawOn: t1 
	beingDragged = false
		ifTrue: [^ self].
	currentForm
		ifNil: [currentForm := rolloverForm
						ifNotNil: [(self target isKindOf: ScratchSpriteMorph)
								ifTrue: [rolloverForm drawOn: t1]]]
		ifNotNil: [currentForm drawOn: t1]! !

!LibraryItemMorph methodsFor: 'drawing' stamp: 'EMP 2/7/2016 10:52'!
drawSubmorphsOn: aCanvas
	"Clip submorph drawing to my bounds."

	| r |
	r _ self bounds.
	super drawSubmorphsOn: (aCanvas copyClipRect: r).

! !

!LibraryItemMorph methodsFor: 'drawing' stamp: 'EMP 2/9/2016 16:44'!
handledOwnDraggingBy: t1 on: t2 
	thumbnailMorph fullDrawOn: t2.
	^ true! !

!LibraryItemMorph methodsFor: 'drawing' stamp: 'EMP 2/10/2016 15:13'!
updateNameAndInfo

	| w y |

	self
		setProperty: #balloonText
		toValue: ((target objName asUTF8, ' (' asUTF8, 'Scripts' localized, ScratchTranslator colonSuffix, ' ' asUTF8, target scripts size printString asUTF8,')' asUTF8) asUTF8).

	nameMorph ifNotNil:[
		(target isKindOf: ScriptableScratchMorph) ifFalse: [
			nameMorph contents: '<no object>'.
			scriptCountMorph contents: ''.
			^ self].

		nameMorph contents = target objName ifFalse: [
			nameMorph contents: self truncatedLabel.
			nameMorph left: self left + ((self width - nameMorph width) // 2) + 1]].

	scriptCountMorph ifNotNil: [
		w _ 0.
		target costumesSize > 1
			ifTrue: [
				w > 0 ifTrue: [w _ w + 2].
				scriptCountMorph contents: (target costumesSize asString), (' backdrops' localized).
				w _ w + scriptCountMorph width + 2]
			ifFalse: [
				w > 0 ifTrue: [w _ w + 2].
				scriptCountMorph contents: '1', (' backdrop' localized).
				w _ w + scriptCountMorph width + 2].

		"layout info morph row"
		y _ nameMorph bottom.
		w > 0 ifTrue: [
			scriptCountMorph position: (self left + ((self width - (scriptCountMorph width)) // 2))@y; color: (Color gray: 0.2)]].
		infoButtonMorph ifNotNil: [infoButtonMorph position: self topLeft.
infoButtonMorph comeToFront].! !


!LibraryItemMorph methodsFor: 'event handling' stamp: 'EMP 2/9/2016 16:37'!
beingDragged
	^ beingDragged := true! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'EMP 2/9/2016 16:37'!
copyForDragging
	^ self removeAllMorphs; addMorph: thumbnailMorph; beingDragged; yourself! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 14:25'!
handlesMouseDown: evt

	^ ((self ownerThatIsA: ScratchLibraryMorph) ifNotNil: [(self ownerThatIsA: ScratchLibraryMorph) showingInfo]) = false
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 14:26'!
handlesMouseOverDragging: evt

	| m |

	(((self ownerThatIsA: ScratchLibraryMorph) ifNotNil: [(self ownerThatIsA: ScratchLibraryMorph) showingInfo]) = false) ifTrue: [

	evt hand submorphs size = 1 ifFalse: [^ false].
	m _ evt hand firstSubmorph.
	^ ((m isKindOf: BlockMorph) or: [(m isKindOf: MediaItemMorph) or: [m isKindOf: ScratchCommentMorph]])]
	ifFalse: [^ false].
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'jm 7/4/2008 19:53'!
mouseDown: evt
	"Handle a mouse click. Left click either sets me as a target, deletes me, or copies me.  Shift left click makes me reappear in the middle of the screen.  Holding left button drags me. Right button brings up a menu."

	| duplicate frame |

	(evt hand toolType = 'CutTool') & (evt rightButtonPressed not) ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		(target notNil and:
		 [(target isKindOf: ScratchStageMorph) not]) ifTrue: [
			self target undoableDeleteSprite].
		^ self].
	
	(evt hand toolType = 'CopyTool') & (evt rightButtonPressed not) ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		(target notNil and:
		 [(target isKindOf: ScratchStageMorph) not]) ifTrue: [
			duplicate _ self target duplicate.
			self world activeHand
				attachMorph: duplicate;
				formerOwner: self target owner position: self target owner center].
		^ self].

	target ifNotNil: [
		evt shiftPressed ifTrue: [self select. ^ self target makeVisible].
		evt rightButtonPressed
			ifTrue: [
				Sensor waitNoButton. 
				(target isKindOf: ScratchStageMorph) 
					ifFalse: [^ self rightButtonMenu]]
			ifFalse:	[
				self select.
				frame _ self ownerThatIsA: ScratchFrameMorph.
				"Set the viewerPane target to my target so I stay highlighted while I am being dragged. This is sort of a hack because my target is not actually being viewed until the mouseUp: command is called."
				frame viewerPane target: self target.
				evt hand waitForClicksOrDrag: self event: evt]].
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'EMP 9/30/2015 14:28'!
mouseEnterDragging: evt

	"| m s |

	m _ BorderedMorph new
		color: Color gray lighter lighter;
		borderWidth: 1;
		borderColor: Color gray;
		useRoundedCorners.
	s _ StringMorph
		contents: ('Copy to ', target objName)
		font: (ScratchFrameMorph getFont: #Button).
	s color: Color white.
	m
		addMorph: (s position: (5@2));
		width: s width + 10;
		height: s height + 5.
	(evt hand submorphs at: 1) addCopyTooltip: (m).

	isSelected ifTrue: [^ self]."
		(((self ownerThatIsA: ScratchLibraryMorph) ifNotNil: [(self ownerThatIsA: ScratchLibraryMorph) showingInfo]) ifTrue: [^ nil]).
	rolloverOn _ true.
	currentForm _ rolloverForm.
	self addMorphBack: (currentForm position: (self position + (0@0))).
	self changed.
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'jm 6/3/2009 20:01'!
mouseHold: evt

	(target isKindOf: ScratchStageMorph) ifFalse: [self rightButtonMenu].
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'jm 5/19/2009 12:47'!
mouseLeaveDragging: evt

	"(evt hand submorphs at: 1) removeCopyTooltip."

	isSelected ifTrue: [^ self].

	rolloverOn _ false.
	currentForm ifNotNil: [
		currentForm delete.
		currentForm _ nil].
	self changed.
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'EMP 10/3/2015 20:34'!
mouseUp: evt
	"View my target if it is not already beeing viewed."

	| frame |
	frame _ self ownerThatIsA: ScratchFrameMorph.
	frame ifNil: [^ self].
	self target ifNil: [^ self]. "deleted"

	self select.
	"frame scriptsPane target = self target ifFalse: ["
		self target viewBlocksAndScripts
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'jm 7/4/2008 19:53'!
select

	(self ownerThatIsA: ScratchLibraryMorph) unhighlightAll. "unhighlight others"
	self highlight: true.
	World displayWorldSafely. "force immediate feedback"
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'EMP 2/9/2016 16:37'!
startDrag: evt

	(self target isKindOf: ScratchStageMorph) ifTrue: [^ self]. "cannot drag stage thumbnail"

	(self ownerThatIsA: ScratchLibraryMorph)
		ifNil: [evt hand grabMorph: self]
		ifNotNil: [evt hand attachMorph: self fullCopy copyForDragging].
! !


!LibraryItemMorph methodsFor: 'dropping/grabbing' stamp: 'ee 5/14/2008 13:00'!
acceptDroppingMorph: aMorph event: evt
	"Copy the dropped scripts of another object into its target."

	(aMorph isKindOf: MediaItemMorph) ifTrue: [
		target addMediaItem: aMorph media copy.
		evt hand rejectDropMorph: aMorph event: evt].

	(aMorph isKindOf: BlockMorph) ifTrue: [
		evt hand rejectDropMorph: aMorph event: evt.
		target addStack: aMorph fullCopy].

	(aMorph isKindOf: ScratchCommentMorph) ifTrue: [
		evt hand rejectDropMorph: aMorph event: evt.
		target addComment: aMorph fullCopy].
! !

!LibraryItemMorph methodsFor: 'dropping/grabbing' stamp: 'jm 10/20/2007 18:42'!
justDroppedInto: aMorph event: evt
	"When I am dropped into the viewer pane or the script editor, then delete the sprite associated with me."

	self delete.
true ifTrue: [^ self].

	"delete me when dropped on the blocks palette or the script editor"
	(((aMorph ownerThatIsA: ScratchViewerMorph) notNil) 
		or: [(aMorph ownerThatIsA: ScratchScriptEditorMorph) notNil]) ifTrue: [
		^ self target undoableDeleteSprite].

	"blocks cannot be dropped onto the stage"
	(owner isKindOf: ScratchStageMorph) ifTrue: [
		^ self rejectDropEvent: evt].
! !

!LibraryItemMorph methodsFor: 'dropping/grabbing' stamp: 'tis 11/10/2006 18:20'!
rejectDropEvent: evt
	"Reject being dropped by the given event."

	evt hand rejectDropMorph: self event: evt.
! !

!LibraryItemMorph methodsFor: 'dropping/grabbing' stamp: 'ee 2/19/2009 11:52'!
wantsDroppedMorph: aMorph event: evt
	"Answer true if the given morph is a script, costume, sound or comment."

	^ (aMorph isKindOf: BlockMorph) or: [
		(aMorph isKindOf: MediaItemMorph) or: [
			aMorph isKindOf: ScratchCommentMorph]]
! !


!LibraryItemMorph methodsFor: 'stepping' stamp: 'ee 12/4/2008 11:49'!
step
	"Optimization: Don't update unless the costume has changed."

	| changeTime stage frame |
	target ifNil: [
		(frame _ (self ownerThatIsA: ScratchFrameMorph)) ifNotNil: [
			(stage _ frame workPane) ifNotNil: [
				stage updateSpritesList]].
		^ self].
	target world isNil ifTrue: [target _ nil. ^ self].
	changeTime _ target costumeChangeMSecs.
	changeTime = lastUpdateMSecs ifFalse: [
		self updateThumbnail.
		lastUpdateMSecs _ changeTime].
	Sensor anyButtonPressed ifFalse: [self updateNameAndInfo].
! !

!LibraryItemMorph methodsFor: 'stepping' stamp: 'EMP 2/10/2016 15:22'!
updateThumbnail

	| f e r form |
	true ifTrue: [^ self updateThumbnailNew].
	form _ thumbnailMorph form.
	form fillColor: Color transparent.
	target ifNil: [
		thumbnailMorph changed.
		^ self].
	f _ target imageForm asFormOfDepth: 16.
	(target isKindOf: ScratchStageMorph) ifTrue: [f _ f borderWidth: 7].
	((f width <= form width) & (f height <= form height)) ifTrue: [
		"target's image fits without shrinking"
		f displayOn: form at: ((form extent - f extent) // 2).
		thumbnailMorph changed.
		^ self].


	f width > f height 
		ifTrue: [e _ form width @ ((f height * form width) // f width)]
		ifFalse: [e _ ((f width * form height) // f height) @ form height].
	e _ e max: (8@8).
	r _ Rectangle center: (form extent // 2) extent: e.

	(WarpBlt toForm: form)
		sourceForm: f;
		cellSize: 2;  "do smoothing; this also installs a colormap"
		combinationRule: Form paint;
		copyQuad: f boundingBox innerCorners toRect: (r insetBy: 2).

	thumbnailMorph changed.
! !

!LibraryItemMorph methodsFor: 'stepping' stamp: 'EMP 2/24/2016 12:47'!
updateThumbnailNew

	| t3 f form e r |
	"----BEGIN TEST FOR SIZE----"
	form _ thumbnailMorph form.
	f _ target imageForm asFormOfDepth: 16.
	((f width <= form width) & (f height <= form height)) ifTrue: [
		f displayOn: form at: ((form extent - f extent) // 2).
		thumbnailMorph changed.
		^ self].
	"----END TEST FOR SIZE----"
	f width > f height 
		ifTrue: [e _ (form width @ ((f height * form width) // f width))]
		ifFalse: [e _ (((f width * form height) // f height) @ form height)].
	e _ e max: (8@8).
	r _ Rectangle center: (form extent // 2) extent: e.
	t3 := Form extent: (thumbnailMorph extent) depth: (thumbnailMorph form depth).
	(target isKindOf: ScratchStageMorph) ifTrue: [f _ f borderWidth: 4].
	(f) displayInterpolatedIn: r on: t3.
	thumbnailMorph form: t3.! !


!LibraryItemMorph methodsFor: 'right button menu' stamp: 'jm 10/25/2007 19:09'!
rightButtonMenu
	"Present the right button menu."

	| menu |
	menu _ CustomMenu new.
	menu add: 'show' action: #makeVisible.
	menu add: 'export this sprite' action: #exportObject.
	menu addLine.
	menu add: 'duplicate' action: #duplicateNoAttach.
	menu add: 'delete' action: #undoableDeleteSprite.
	menu localize; invokeOn: self target.
! !


!LibraryItemMorph methodsFor: 'private' stamp: 'ee 3/28/2009 19:12'!
truncatedLabel
	"Answer the label string to used as the name morph."

	| ellipses s w n |

	nameMorph contents = target objName ifFalse: [
		n _ target objName.
		ellipses _ ScratchTranslator ellipsesSuffix asUTF32.
		1 to: n size do: [:i |
			s _ n copyFrom: 1 to: i.
			w _ nameMorph stringWidth: (s asUTF32, ellipses).
			w > (self width - 3) ifTrue: [
				^ (n copyFrom: 1 to: i - 1) asUTF32, ellipses]]].

	^ target objName
! !
