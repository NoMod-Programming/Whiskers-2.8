AlignmentMorph subclass: #ScratchCommentMorph
	instanceVariableNames: 'labelMorph resizeMorph commentMorph showHideMorph isShowing isResizing resizeOffset connector anchor anchorOffset oldAnchorPos lastLayoutTime lastHeight '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ScratchCommentMorph methodsFor: 'initialization' stamp: 'EMP 1/7/2016 14:30'!
addTopBar

	| topBarMorph |
	topBarMorph _ AlignmentMorph newRow
		extent: (160@12);
		vResizing: #rigid;
		color: self topBarColor;
		borderWidth: 0;
		inset: 0;
		centering: #center.

	labelMorph _ StringMorph new
		color: (Color gray: 0.33);
		contents: '';
		font: (ScratchFrameMorph getFont: #Label).

	showHideMorph _ ImageMorph new form: (ScratchFrameMorph skinAt: #arrowOpenComment).
	showHideMorph form colors: (Array
		with: Color transparent
		with: (Color gray: 0.5)).

	topBarMorph
		addMorphBack: (Morph new extent: 5@5; color: Color transparent);
		addMorphBack: showHideMorph;
		addMorphBack: (Morph new extent: 3@5; color: Color transparent);
		addMorphBack: labelMorph;
		addMorphBack: (AlignmentMorph newSpacer: Color transparent).

	self addMorphBack: topBarMorph.
! !

!ScratchCommentMorph methodsFor: 'initialization' stamp: 'EMP 1/7/2016 14:36'!
initialize

	| bottomBar |
	super initialize.
	anchorOffset _ 5.

	self vResizing: #rigid;
		hResizing: #rigid;
		orientation: #vertical;
		centering: #bottomRight;
		inset: 0;
		borderWidth: 1;
		borderColor: (Color r: 208/255 g: 209/255 b: 210/255);
		color: self commentMorphColor;
		useRoundedCorners;
		width: self defaultWidth;
		height: 200.
	isShowing _ true.

	self addTopBar.

	bottomBar _ AlignmentMorph newRow
		color: Color transparent;
		centering: #center.
	resizeMorph _ ScratchResizeMorph ofType: #corner.
	resizeMorph vResizing: #spaceFill.
	commentMorph _ MultilineStringMorph new
		color: Color transparent;
		growWithText: false;
		borderWidth: 0;
		font: (ScratchFrameMorph getFont: #CommentBlock);
		contents: 'add comment here' localized, ScratchTranslator ellipsesSuffix;
		width: self defaultWidth - resizeMorph width.
	bottomBar addMorphBack: commentMorph.
	bottomBar addMorphBack: resizeMorph.

	self addMorphBack: bottomBar.
	isResizing _ false.
	resizeOffset _ 0@0.
! !


!ScratchCommentMorph methodsFor: 'accessing' stamp: 'jens 3/3/2009 22:48'!
anchor

	^ anchor
! !

!ScratchCommentMorph methodsFor: 'accessing' stamp: 'jens 3/30/2009 22:20'!
anchor: aBlock

	self detach.
	anchor _ aBlock.
	aBlock topBlock commentLayoutChanged.
! !

!ScratchCommentMorph methodsFor: 'accessing' stamp: 'ee 5/1/2008 12:37'!
commentMorph

	^ commentMorph
! !

!ScratchCommentMorph methodsFor: 'accessing' stamp: 'EMP 1/7/2016 14:15'!
commentMorphColor

	^ Color r: 1 g: 1 b: (210/255).
! !

!ScratchCommentMorph methodsFor: 'accessing' stamp: 'jens 1/27/2009 20:16'!
delete

	self detach.
	ScratchFrameMorph putInClipboard: self.
	super delete
! !

!ScratchCommentMorph methodsFor: 'accessing' stamp: 'EMP 1/7/2016 14:51'!
height: aNumber

	super height: (15 max: aNumber).
	commentMorph notNil & resizeMorph notNil ifTrue: [
		commentMorph height: self height].
! !

!ScratchCommentMorph methodsFor: 'accessing' stamp: 'jens 3/30/2009 13:11'!
isShowing


	^ isShowing

! !

!ScratchCommentMorph methodsFor: 'accessing' stamp: 'jm 6/30/2008 13:47'!
width: aNumber

	super width: (self defaultWidth max: aNumber).
	commentMorph notNil & resizeMorph notNil ifTrue: [
		commentMorph width: self width - resizeMorph width].
! !


!ScratchCommentMorph methodsFor: 'dropping/grabbing' stamp: 'jens 3/3/2009 22:30'!
aboutToBeGrabbedBy: aHand
	"The receiver is being grabbed by a hand. Perform necessary adjustments (if any) and return the morph that should be added to the hand. This default implementation just returns the reciver."

	self detach.
	^ self
! !

!ScratchCommentMorph methodsFor: 'dropping/grabbing' stamp: 'jm 3/20/2009 14:06'!
attachTargetIn: newOwner
	"Answer a CommandBlockMorph that is overlapped by the receiver, nil if none."

	| candidates target overlap ratio |

	(newOwner isKindOf: ScratchScriptsMorph) ifFalse: [^ nil].

	candidates _ newOwner allMorphs select: [:each |
		(each isKindOf: BlockMorph) and:
		[each isReporter not and:
		[each hasComment not and:
		[self bounds intersects: each bounds]]]].

	candidates isEmpty ifTrue: [^ nil].

	target _ candidates first.
	ratio _ (self bounds intersect: target bounds) area / target bounds area.
	candidates do: [:each |
		overlap _ ((self bounds intersect: each bounds) area / (each bounds area)).
		overlap > ratio ifTrue: [
			ratio _ overlap.
			target _ each]].

	^ target
! !

!ScratchCommentMorph methodsFor: 'dropping/grabbing' stamp: 'jens 3/3/2009 21:53'!
justDroppedInto: newOwner event: evt
	"Handle being dropped into a new situation."

	| frame target |
	(frame _ newOwner ownerThatIsA: ScratchFrameMorph)
		ifNotNil: [frame projectModified].

	((self ownerThatIsA: ScratchViewerMorph) notNil) ifTrue: [
		"delete myself when dropped in the blocks palette area"
		self delete.
		^ self].

	"comments cannot be dropped onto the stage"
	(owner isKindOf: ScratchStageMorph) ifTrue: [
		^ self rejectDropEvent: evt].

	"okay to drop comments into the world during development"
	((owner == World) and: [Preferences noviceMode not]) ifTrue: [^ self].

	(owner isKindOf: ScratchScriptsMorph) ifFalse: [
		^ self rejectDropEvent: evt].

	target _ self attachTargetIn: newOwner.
	target ifNotNil: [self anchor: target]
! !

!ScratchCommentMorph methodsFor: 'dropping/grabbing' stamp: 'ee 5/14/2008 11:53'!
rejectDropEvent: evt
	"Reject being dropped by the given event."

	evt hand rejectDropMorph: self event: evt.
! !

!ScratchCommentMorph methodsFor: 'dropping/grabbing' stamp: 'ee 4/30/2008 10:29'!
rootForGrabOf: aMorph
	"Allow myself to be extracted."

	(owner notNil and: [owner isPartsBin])
		ifTrue: [^ super rootForGrabOf: aMorph]
		ifFalse: [^ self].
! !

!ScratchCommentMorph methodsFor: 'dropping/grabbing' stamp: 'ee 5/14/2008 11:56'!
slideBackToFormerSituation: evt

	| wasEmbedded o pane oldP slideForm startPoint |
	wasEmbedded _ false.
	(o _ evt hand formerOwner) ifNil: [^ self].
	(o isKindOf: BlockMorph) ifTrue: [
		wasEmbedded _ true.
		(pane _ o ownerThatIsA: ScratchScriptsMorph) ifNotNil: [
			o _ pane]].
	oldP _ evt hand formerPosition.
	slideForm _ self imageForm offset: 0@0.
	startPoint _ evt hand fullBounds origin.
	owner privateRemoveMorph: self.
	self world displayWorld.
	slideForm slideFrom: startPoint to: oldP nSteps: 12 delay: 15.
	self position: oldP.
	o addMorph: self.
	wasEmbedded ifTrue: [self justDroppedInto: o event: evt].
! !


!ScratchCommentMorph methodsFor: 'event handling' stamp: 'jm 3/20/2009 16:47'!
duplicate

	| dup |
	dup _ self class new.
	dup width: self width.
	dup commentMorph contents: commentMorph contents.
	isShowing ifFalse: [dup toggleShowing].

	self world activeHand attachMorph: dup.
! !

!ScratchCommentMorph methodsFor: 'event handling' stamp: 'ee 4/30/2008 10:30'!
handlesMouseDown: evt

	^ true
! !

!ScratchCommentMorph methodsFor: 'event handling' stamp: 'EMP 1/7/2016 14:50'!
mouseDown: evt
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	| p |
	World activeHand showTemporaryCursor: nil.
	evt hand newKeyboardFocus: nil.
	isResizing _ false.
	p _ evt cursorPoint.

	((showHideMorph bounds expandBy: 4) containsPoint: p) ifTrue: [^ self toggleShowing].
	(isShowing and: [commentMorph containsPoint: p])
		ifTrue: [^ commentMorph mouseDown: evt].

	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[((resizeMorph bounds expandBy: 4) containsPoint: p)
			ifFalse: [evt hand grabMorph: self]
			ifTrue: [isResizing _ true.
				resizeOffset _ self bottomRight - p]].
! !

!ScratchCommentMorph methodsFor: 'event handling' stamp: 'EMP 1/7/2016 14:52'!
mouseMove: evt

	| p |
	evt hand newKeyboardFocus: nil.
	p _ evt cursorPoint.

	isResizing ifTrue: [
		self width: (self defaultWidth max: ((p - self topLeft) + resizeOffset) x).
		commentMorph width: self width - (resizeMorph width).
		self height: (40 max: ((p + resizeOffset) - self topLeft) y).
		commentMorph height: self height - (resizeMorph height)].
! !

!ScratchCommentMorph methodsFor: 'event handling' stamp: 'ee 8/11/2008 13:04'!
rightButtonMenu

	| menu |
	menu _ CustomMenu new.

	menu addLine.
	menu add: 'delete' action: #delete.
	menu add: 'duplicate' action: #duplicate.

	menu localize; invokeOn: self.
! !


!ScratchCommentMorph methodsFor: 'stepping' stamp: 'jm 3/29/2009 13:26'!
step
	"Follow the anchor block"

	| t |
	anchor ifNil: [^ self].

	anchor isInWorld ifFalse: [^ self detach].  "anchor block was deleted"

	"check for layout change and fix offset if needed"
	(t _ anchor topBlock lastLayoutTime) = lastLayoutTime ifFalse: [
		self updateAnchorOffset.
		oldAnchorPos _ nil.  "force position update"
		lastLayoutTime _ t].

	anchor position ~= oldAnchorPos ifTrue: [
		self updatePosition.
		oldAnchorPos _ anchor position].
! !

!ScratchCommentMorph methodsFor: 'stepping' stamp: 'jm 3/29/2009 10:28'!
stepTime

	^ 0
! !


!ScratchCommentMorph methodsFor: 'private' stamp: 'jens 3/30/2009 22:23'!
commentsAfterMe: blocksInStack
	"Return a collection of comment morphs in my owner that are attached to blocks after me in the given list of blocks. Assumes anchor is not nil."

	| result allComments |
	owner ifNil: [^ #()].
	allComments _ owner submorphs select: [:m |
		m isKindOf: self class].

	result _ OrderedCollection new.
	blocksInStack reversed do: [:b |
		b == anchor ifTrue: [^ result asArray].
		allComments do: [:c | c anchor = b ifTrue: [result add: c]]].

	^ result asArray

! !

!ScratchCommentMorph methodsFor: 'private' stamp: 'jm 3/29/2009 10:25'!
commentsBeforeMe: blocksInStack
	"Return a collection of comment morphs in my owner that are attached to blocks before me in the given list of blocks. Assumes anchor is not nil."

	| allComments result |
	owner ifNil: [^ #()].
	allComments _ owner submorphs select: [:m | m isKindOf: self class].

	result _ OrderedCollection new.
	blocksInStack do: [:b |
		b == anchor ifTrue: [^ result asArray].
		allComments do: [:c | c anchor = b ifTrue: [result add: c]]].

	^ result asArray
! !

!ScratchCommentMorph methodsFor: 'private' stamp: 'EMP 1/7/2016 14:20'!
defaultWidth

	^ 151
! !

!ScratchCommentMorph methodsFor: 'private' stamp: 'jens 3/30/2009 21:56'!
detach

	| oldAnchor |
	oldAnchor _ anchor.
	anchor _ nil.
	connector ifNotNil: [
		connector delete.
		connector _ nil].
	oldAnchor ifNotNil: [
		oldAnchor topBlock commentLayoutChanged].
! !

!ScratchCommentMorph methodsFor: 'private' stamp: 'jm 7/8/2008 19:11'!
labelWhenClosed
	"Answer the label string to used when the comment is closed."

	| maxW firstLine ellipses s w |
	maxW _ self width - 22.
	firstLine _ commentMorph lines at: 1.
	(labelMorph stringWidth: firstLine) < maxW ifTrue: [^ firstLine].
	ellipses _ ScratchTranslator ellipsesSuffix asUTF32.

	1 to: firstLine size do: [:i |
		s _ firstLine copyFrom: 1 to: i.
		w _ labelMorph stringWidth: s, ellipses.
		w > maxW ifTrue: [
			^ (firstLine copyFrom: 1 to: i - 1), ellipses]].

	^ firstLine

! !

!ScratchCommentMorph methodsFor: 'private' stamp: 'jens 3/30/2009 22:21'!
layoutChanged

	super layoutChanged.
	anchor ifNotNil: [anchor topBlock commentLayoutChanged].

! !

!ScratchCommentMorph methodsFor: 'private' stamp: 'jm 3/29/2009 11:14'!
refreshConnector

	| y |
	owner ifNil: [^ self].

	connector ifNil: [
		connector _ ScratchConnectorMorph new color: self topBarColor].

	connector owner isNil ifTrue: [
		owner addMorph: connector.
		connector goBehind].

	y _ self top + 7.
	ScratchTranslator isRTL
		ifTrue: [
			connector
				from: (anchor left + 1) @ y
				to: self right @ y]
		ifFalse: [
			connector
				from: (anchor right - 1) @ y
				to: self left @ y].

! !

!ScratchCommentMorph methodsFor: 'private' stamp: 'jens 3/30/2009 20:38'!
resetAnchorOffset
	
	anchorOffset _ 5.
	self updatePosition.
! !

!ScratchCommentMorph methodsFor: 'private' stamp: 'EMP 1/7/2016 14:55'!
toggleShowing

	| colors |
	isShowing _ isShowing not.
	colors _ showHideMorph form colors.
	isShowing
		ifTrue: [
			showHideMorph form: (ScratchFrameMorph skinAt: #arrowOpenComment).
			showHideMorph form colors: colors.
			(self submorphs at: 2) addMorphBack: commentMorph.
			(self submorphs at: 2) addMorphBack: resizeMorph.
			commentMorph startStepping.
			labelMorph contents: ''.
			lastHeight ifNil: [lastHeight _ 40].
			self height: lastHeight.
			self comeToFront.
			self color: self commentMorphColor]
		ifFalse: [
			showHideMorph form: (ScratchFrameMorph skinAt: #arrowClosedComment).
			showHideMorph form colors: colors.
			commentMorph delete.
			resizeMorph delete.
			labelMorph contents: self labelWhenClosed.
			self color: self topBarColor.
			lastHeight _ self height.
			self height: 15].

	anchor ifNotNil: [anchor topBlock commentLayoutChanged].

! !

!ScratchCommentMorph methodsFor: 'private' stamp: 'EMP 1/7/2016 14:14'!
topBarColor

	^ Color r: 1 g: 1 b: (128/255)
! !

!ScratchCommentMorph methodsFor: 'private' stamp: 'jens 3/4/2009 00:39'!
tupleSequence
	"Answer an array with a single tuple describing this comment."

	anchor isNil
		ifTrue: [
			^ Array with:
				(Array
					with: #scratchComment
					with: commentMorph contents
					with: isShowing
					with: self width)]
		ifFalse: [
			^ Array with:
				(Array
					with: #scratchComment
					with: commentMorph contents
					with: isShowing
					with: self width
					with: anchor blockID)]
! !

!ScratchCommentMorph methodsFor: 'private' stamp: 'jens 3/30/2009 21:51'!
updateAnchorOffset
	"Update the horizontal offset from my anchor block."

	| extraSpace blocksInStack rects allObstacles touching before after collapsed |

	anchor ifNil: [^ self].

	self resetAnchorOffset.
	isShowing ifFalse: [^ self].

	extraSpace _ 5.
	blocksInStack _ anchor topBlock allMorphs reversed select:
		[:m | (m isKindOf: BlockMorph) and: [m isReporter not]].
	before _ self commentsBeforeMe: blocksInStack.
	after _ self commentsAfterMe: blocksInStack.
	collapsed _ after select: [:c | c isShowing not].

	before, collapsed do: [: c | c resetAnchorOffset].
	before do: [:c | c updateAnchorOffset].

	allObstacles _ blocksInStack, before, collapsed.
	rects _ allObstacles collect: [:m | (m isKindOf: BlockMorph)
		ifTrue: [m bounds origin extent: (m bounds extent - (0@4))]
		ifFalse: [m bounds]].

	[touching _ rects detect: [:r | (r intersects: self bounds)] ifNone: [nil].
	 touching isNil] whileFalse: [
		ScratchTranslator isRTL
			ifTrue: [self right: (self right min: (touching left - extraSpace))]
			ifFalse: [self left: (self left max: (touching right + extraSpace))]].

	ScratchTranslator isRTL
		ifTrue: [anchorOffset _ anchor left - self right]
		ifFalse: [anchorOffset _ self left - anchor right].

	self updatePosition.
! !

!ScratchCommentMorph methodsFor: 'private' stamp: 'jm 3/30/2009 21:47'!
updatePosition

	| vOffset |
	anchor ifNil: [^ self].

	vOffset _ (anchor isKindOf: HatBlockMorph) ifTrue: [19] ifFalse: [3].
	ScratchTranslator isRTL
		ifTrue: [self position: (anchor left - self width - anchorOffset) @ (anchor top + vOffset)]
		ifFalse: [self position: (anchor right + anchorOffset) @ (anchor top + vOffset)].

	self refreshConnector.
	oldAnchorPos _ anchor position.
! !
