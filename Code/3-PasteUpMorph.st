BorderedMorph subclass: #PasteUpMorph
	instanceVariableNames: 'turtleTrailsForm lastTurtlePositions isPartsBin worldState '
	classVariableNames: 'DisableDeferredUpdates MinCycleLapse '
	poolDictionaries: ''
	category: 'Morphic-Basic'!
!PasteUpMorph commentStamp: '<historical>' prior: 0!
A morph whose submorphs comprise a paste-up of rectangular subparts which "show through".

Facilities commonly needed on pages of graphical presentations and on simulation playfields, such as the painting of new objects, turtle trails, gradient fills, background paintings, parts-bin behavior, collision-detection, etc., are (or will be) provided.

A World, the entire Smalltalk screen, is a PasteUpMorph.  A World responds true to isWorld.  Morph subclasses that have specialized menus (BookMorph) build them in the message addBookMenuItemsTo:hand:.  A PasteUpMorph that is a world, builds its menu in HandMorph buildWorldMenu.

This class is young and still under construction, and a number of its (many) instance variables are not yet fully deployed.!


!PasteUpMorph methodsFor: 'initialization' stamp: 'EMP 12/10/2015 11:58'!
initialize

	super initialize.
	borderColor _ Color r: 0.861 g: 1.0 b: 0.722.
	color _ Color r: 0.8 g: 1.0 b: 0.6.
	bounds _ 0@0 corner: 50@40.
	self enableDragNDrop: true.
! !

!PasteUpMorph methodsFor: 'initialization' stamp: 'jm 7/17/2003 23:05'!
releaseCachedState

	super releaseCachedState.
	turtleTrailsForm ifNotNil: [turtleTrailsForm hibernate].
! !


!PasteUpMorph methodsFor: 'classification' stamp: 'di 7/27/1999 10:46'!
isWorldMorph

	^ worldState notNil! !

!PasteUpMorph methodsFor: 'classification' stamp: 'di 7/27/1999 10:46'!
world

	worldState == nil ifTrue: [^ super world].
	^ self! !


!PasteUpMorph methodsFor: 'display' stamp: 'jm 10/12/2005 10:38'!
drawOn: aCanvas
	"Update and draw the turtleTrails form. See the comment in updateTrailsForm."

	super drawOn: aCanvas.

	self updateTrailsForm.
	turtleTrailsForm ifNotNil: [
		(aCanvas copyClipRect: self bounds)
			paintImage: turtleTrailsForm at: self position].
! !

!PasteUpMorph methodsFor: 'display' stamp: 'jm 2/1/2005 12:16'!
drawSubmorphsOn: aCanvas

	super drawSubmorphsOn: (aCanvas copyClipRect: self innerBounds).
! !

!PasteUpMorph methodsFor: 'display' stamp: 'jm 11/24/2002 10:35'!
pseudoDraw: aRectangle on: aCanvas

	| c |
	c _ aCanvas copyClipRect: aRectangle.
	color isTranslucent ifTrue: [c fillColor: Color black].
	c fillRectangle: bounds color: color.
	turtleTrailsForm ifNotNil: [c paintImage: turtleTrailsForm at: 0@0].
	^ c
! !


!PasteUpMorph methodsFor: 'dropping/grabbing' stamp: 'jm 10/12/2005 10:51'!
acceptDroppingMorph: aMorph event: evt

	aMorph submorphsDo: [:m | (m isKindOf: HaloMorph) ifTrue: [m delete]].
	self addMorphFront: aMorph.

	self isPartsBin
		ifTrue: [
			aMorph isPartsDonor: true.
			aMorph allMorphsDo: [:m | m stopStepping]]
		ifFalse: [
			self world startSteppingSubmorphsOf: aMorph].
! !

!PasteUpMorph methodsFor: 'dropping/grabbing' stamp: 'sw 5/17/2000 12:05'!
repelsMorph: aMorph event: ev
	aMorph willingToBeEmbeddedUponLanding ifFalse: [^ false].
	self dragNDropEnabled ifFalse: [^ true].
	(self wantsDroppedMorph: aMorph event: ev) ifFalse: [^ true].
	^ super repelsMorph: aMorph event: ev "consults #repelling flag"! !

!PasteUpMorph methodsFor: 'dropping/grabbing' stamp: 'jm 12/8/2003 11:41'!
rootForGrabOf: aMorph
	"If open to drag-n-drop, allow the given submorph to be extracted. If I am a parts bin answer a new copy of it."

	| root |
	root _ aMorph.
	[root = self] whileFalse: [
		root owner == self ifTrue: [
			self isPartsBin ifTrue: [^ root fullCopy].
			self dragNDropEnabled ifTrue: [^ root]].
		root _ root owner].

	^ super rootForGrabOf: aMorph
! !

!PasteUpMorph methodsFor: 'dropping/grabbing' stamp: 'jm 10/13/2002 18:23'!
wantsDroppedMorph: aMorph event: evt

	aMorph willingToBeEmbeddedUponLanding ifFalse: [^ false].
	self isHidden ifTrue: [^ false].
	self dragNDropEnabled ifFalse: [^ false].
	(self bounds containsPoint: (self pointFromWorld: evt cursorPoint)) ifFalse: [^ false].
	^ true
! !


!PasteUpMorph methodsFor: 'menu & halo' stamp: 'jm 7/20/2003 20:39'!
addCustomMenuItems: menu hand: aHandMorph

	super addCustomMenuItems: menu hand: aHandMorph.
	menu add: 'clear pen trails' action: #clearTurtleTrails.
	menu add: 'playfield options...' target: self action: #presentPlayfieldMenu.
! !

!PasteUpMorph methodsFor: 'menu & halo' stamp: 'sw 1/10/2000 16:44'!
defersHaloOnClickTo: aSubMorph
	"If a cmd-click on aSubMorph would make it a preferred recipient of the halo, answer true"
	^ true
	! !

!PasteUpMorph methodsFor: 'menu & halo' stamp: 'jm 2/4/2003 13:36'!
isOpenForDragNDropString

	^ self dragNDropEnabled
		ifTrue: ['stop being open to drag & drop']
		ifFalse: ['start being open to drag & drop'].
! !

!PasteUpMorph methodsFor: 'menu & halo' stamp: 'sw 6/11/1999 16:55'!
isPartsBinString
	^ self isPartsBin
		ifTrue:
			['stop being a parts bin']
		ifFalse:
			['start being a parts bin']
! !

!PasteUpMorph methodsFor: 'menu & halo' stamp: 'jm 10/12/2005 10:42'!
playfieldOptionsMenu

	| isWorld aMenu |
	isWorld _ self isWorldMorph.
	aMenu _ MenuMorph new defaultTarget: self.
	aMenu addStayUpItem.
	#(
		(isPartsBinString toggleIsPartsBin
			'whether dragging an object from the interior should produce a COPY of the object')
		(isOpenForDragNDropString toggleDragNDrop
			'whether objects can be dropped into and dragged out of me')
	) do: [:triplet |
		isWorld ifFalse: [
			aMenu addUpdating: triplet first action: triplet second.
			aMenu balloonTextForLastItem: triplet third]]. 

	aMenu addTitle: 'playfield options...'.
	^ aMenu
! !

!PasteUpMorph methodsFor: 'menu & halo' stamp: 'jm 5/31/2003 16:31'!
presentPlayfieldMenu

	self playfieldOptionsMenu popUpForHand: self activeHand.
! !

!PasteUpMorph methodsFor: 'menu & halo' stamp: 'sw 12/30/1999 19:51'!
seeksOutHalo
	"Answer whether the receiver is an eager recipient of the halo"
	^ false! !

!PasteUpMorph methodsFor: 'menu & halo' stamp: 'sw 1/25/2000 17:44'!
wantsHaloFromClick
	^ (owner isKindOf: SystemWindow) not! !


!PasteUpMorph methodsFor: 'model' stamp: 'jm 3/13/2003 17:04'!
model
	"Return nil. Models are being eliminated from PasteUpMorph."

	^ nil
! !


!PasteUpMorph methodsFor: 'options' stamp: 'sw 4/13/1998 18:15'!
isPartsBin
	^ isPartsBin == true! !

!PasteUpMorph methodsFor: 'options' stamp: 'jm 2/4/2003 13:32'!
setPartsBinStatusTo: aBoolean

	isPartsBin _ aBoolean.
	isPartsBin
		ifTrue: [
			self enableDragNDrop: true.
			submorphs do: [:m | m stopStepping; isPartsDonor: true]]
		ifFalse: [
			submorphs do: [:m | m isPartsDonor: false].
			self world ifNotNil: [self world startSteppingSubmorphsOf: self]].
! !

!PasteUpMorph methodsFor: 'options' stamp: 'sw 9/30/1998 17:24'!
toggleIsPartsBin
	"Not entirely happy with the openToDragNDrop not being directly manipulable etc, but still living with it for now."
	self setPartsBinStatusTo: self isPartsBin not! !


!PasteUpMorph methodsFor: 'pen' stamp: 'jm 7/17/2003 23:03'!
clearTurtleTrails
	"Remove my turtle trails Form. It will be recreated if it is needed."

	turtleTrailsForm _ nil.
	self changed.
! !

!PasteUpMorph methodsFor: 'pen' stamp: 'jm 7/19/2003 14:52'!
createOrResizeTrailsForm
	"If necessary, create a new turtleTrailsForm or resize the existing one to fill my bounds. On return, turtleTrailsForm will be an 8-bit Form of the correct size."

	| newForm |
	turtleTrailsForm ifNil: [
		turtleTrailsForm _ Form extent: self extent depth: 8.
		^ self].

	turtleTrailsForm extent = self extent ifFalse: [  "resize trails Form to my current exent"
		newForm _ Form extent: self extent depth: 8.
		newForm
			copy: turtleTrailsForm boundingBox
			from: turtleTrailsForm
			to: 0@0
			rule: Form paint.
		turtleTrailsForm _ newForm].
! !

!PasteUpMorph methodsFor: 'pen' stamp: 'jm 3/5/2004 09:30'!
drawPenTrailFor: aMorph from: oldPoint to: newPoint
	"Draw a pen trail between the given points for the given morph using its pen size and color."
	"The turtleTrailsForm is created on demand when the first pen is put down and removed (to save space) when turtle trails are cleared."

	| pen penSize offset |
	oldPoint = newPoint ifTrue: [^ self].  "no movement"

	self createOrResizeTrailsForm.
	pen _ Pen newOnForm: turtleTrailsForm.
	penSize _ aMorph penSize.
	aMorph penSize ~= 1 ifTrue: [pen squareNib: penSize].
	offset _ (penSize / 2.0) + bounds topLeft.
	pen color: aMorph penColor.
	pen drawFrom: (oldPoint - offset) truncated to: (newPoint - offset) truncated.
	self invalidRect: ((oldPoint rect: newPoint) truncated expandBy: penSize + 1).
! !

!PasteUpMorph methodsFor: 'pen' stamp: 'jm 3/5/2004 09:21'!
penUpOrDownChangeFor: aMorph
	"The pen up/down state for the given morph may have changed; update lastTurtlePositions accordingly."

	aMorph penDown
		ifTrue: [
			lastTurtlePositions ifNil: [lastTurtlePositions _ IdentityDictionary new].
			(lastTurtlePositions includes: aMorph) ifFalse: [
				lastTurtlePositions at: aMorph put: aMorph penPosition]]
		ifFalse: [
			lastTurtlePositions ifNil: [^ self].
			lastTurtlePositions removeKey: aMorph ifAbsent: [].
			lastTurtlePositions size = 0 ifTrue: [lastTurtlePositions _ nil]].
! !

!PasteUpMorph methodsFor: 'pen' stamp: 'jm 3/5/2004 09:21'!
updateTrailsForm 
	"Update the turtle-trails form using the current positions of all morphs with their pens down."
	"Details: The positions of all morphs with their pens down are recorded by my draw method. If the list from the last display update isn't empty, then trails are drawn from the old to the current positions of all such morphs on the turtle-trails form. The turtle-trails form is created on demand when the first pen is put down and removed (to save space) when the turtle trails are cleared."

	| morphsToRemove m oldPoint newPoint |
	(lastTurtlePositions isNil or: [lastTurtlePositions size = 0]) ifTrue: [^ self].

	morphsToRemove _ OrderedCollection new.
	lastTurtlePositions associationsDo: [:assoc |
		m _ assoc key.
		(m penDown and: [m owner == self])
			ifTrue: [
				oldPoint _ assoc value.
				newPoint _ m penPosition.
				newPoint = oldPoint ifFalse: [
					self drawPenTrailFor: m from: oldPoint to: newPoint.
					assoc value: newPoint]]
			ifFalse: [morphsToRemove add: m]].

	"remove morphs that are not longer owned by me or whose pens are up"
	morphsToRemove do: [:key | lastTurtlePositions removeKey: key ifAbsent: []].
! !


!PasteUpMorph methodsFor: 'misc' stamp: 'jm 10/13/2002 18:22'!
drawInvalidAreasOn: aCanvas 
	"Redraw the damaged areas of the given canvas and clear the damage list.
	Return a collection of the areas that were redrawn."

	| rectList c i n mm morphs rects rectToFill remnants rect |
	rectList _ self damageRecorder invalidRectsFullBounds: self viewBox.
	self damageRecorder reset.
	self updateTrailsForm.

	n _ self submorphs size.
	morphs _ OrderedCollection new: n*2.
	rects _ OrderedCollection new: n*2.
	rectList do: [:r |
		true
		ifTrue:
			["Experimental top-down drawing --
			Traverses top to bottom, stopping if the entire area is filled.
			If only a single rectangle remains, then continue with the reduced rectangle."
			rectToFill _ r.
			i _ 1.
			[rectToFill == nil or: [i > n]] whileFalse:
				[mm _ submorphs at: i.
				((mm fullBounds intersects: r) and: [mm isHidden not]) ifTrue:
					[morphs addLast: mm.  rects addLast: rectToFill.
					remnants _ mm areasRemainingToFill: rectToFill.
					remnants size = 1 ifTrue: [rectToFill _ remnants first].
					remnants size = 0 ifTrue: [rectToFill _ nil]].
				i _ i+1].

			"Now paint from bottom to top, but using the reduced rectangles."
			rectToFill ifNotNil:
				[c _ self pseudoDraw: rectToFill on: aCanvas].
			[morphs isEmpty] whileFalse:
				[(rect _ rects removeLast) == rectToFill ifFalse:
					[c _ aCanvas copyClipRect: (rectToFill _ rect)].
				morphs removeLast fullDrawOn: c].
			morphs reset.  rects reset]
		ifFalse: [c _ self pseudoDraw: r on: aCanvas.
				submorphs reverseDo: [:m | m fullDrawOn: c]]
		].
	^ rectList! !

!PasteUpMorph methodsFor: 'misc' stamp: 'ar 3/14/2000 16:04'!
invalidRect: damageRect
	"Clip damage reports to my bounds, since drawing is clipped to my bounds."

	self isWorldMorph
		ifTrue: [self damageRecorder ifNotNil:
					[self damageRecorder recordInvalidRect: damageRect]]
		ifFalse: [super invalidRect: (damageRect intersect: bounds)]
! !

!PasteUpMorph methodsFor: 'misc' stamp: 'sw 6/3/2000 00:54'!
morphsAt: aPoint addTo: mList
	"Overridden to exclude spurious hits on extralimital submorphs."
	(self containsPoint: aPoint) ifTrue:
		[submorphs size > 0 ifTrue:
			[submorphs do: [:m | m morphsAt: aPoint addTo: mList]].
		mList addLast: self].
	^ mList! !

!PasteUpMorph methodsFor: 'misc' stamp: 'bf 9/22/1999 14:55'!
position: aPoint
	"Prevent moving a world (e.g. via HandMorph>>specialGesture:)"

	self isWorldMorph ifFalse: [super position: aPoint]
! !

!PasteUpMorph methodsFor: 'misc' stamp: 'sw 6/4/2000 21:42'!
unlockedMorphsAt: aPoint addTo: mList
	"Overridden to exclude spurious hits on extralimital submorphs."
	((self containsPoint: aPoint) and: [self isLocked not]) ifTrue:
		[submorphs size > 0 ifTrue:
			[submorphs do: [:m | m unlockedMorphsAt: aPoint addTo: mList]].
		mList addLast: self].
	^ mList! !

!PasteUpMorph methodsFor: 'misc' stamp: 'sw 5/6/1998 17:07'!
wantsKeyboardFocusFor: aSubmorph
	aSubmorph inPartsBin ifTrue: [^ false].
	aSubmorph wouldAcceptKeyboardFocus ifTrue: [ ^ true].
	^ super wantsKeyboardFocusFor: aSubmorph! !


!PasteUpMorph methodsFor: 'project state' stamp: 'jm 12/7/2005 09:31'!
activeHand

	^ worldState ifNotNil: [worldState activeHand] ifNil: [super activeHand]
! !

!PasteUpMorph methodsFor: 'project state' stamp: 'jm 12/7/2005 09:22'!
activeHand: aHandMorph

	worldState activeHand: aHandMorph.
! !

!PasteUpMorph methodsFor: 'project state' stamp: 'di 7/27/1999 10:46'!
canvas

	^ worldState canvas! !

!PasteUpMorph methodsFor: 'project state' stamp: 'di 7/27/1999 10:46'!
canvas: x

	worldState canvas: x.
! !

!PasteUpMorph methodsFor: 'project state' stamp: 'di 7/27/1999 10:46'!
damageRecorder

	^ worldState damageRecorder! !

!PasteUpMorph methodsFor: 'project state' stamp: 'di 7/27/1999 10:46'!
hands

	^ worldState hands! !

!PasteUpMorph methodsFor: 'project state' stamp: 'di 7/27/1999 10:46'!
hands: x

	worldState hands: x! !

!PasteUpMorph methodsFor: 'project state' stamp: 'di 7/27/1999 10:46'!
handsDo: aBlock

	^ worldState hands do: aBlock! !

!PasteUpMorph methodsFor: 'project state' stamp: 'sw 10/9/1999 22:51'!
isStepping: aMorph
	^ worldState isStepping: aMorph! !

!PasteUpMorph methodsFor: 'project state' stamp: 'di 7/27/1999 10:46'!
lastCycleTime

	^ worldState lastCycleTime! !

!PasteUpMorph methodsFor: 'project state' stamp: 'di 7/27/1999 10:46'!
lastCycleTime: x

	worldState lastCycleTime: x! !

!PasteUpMorph methodsFor: 'project state' stamp: 'di 7/27/1999 10:46'!
lastStepTime

	^ worldState lastStepTime! !

!PasteUpMorph methodsFor: 'project state' stamp: 'di 7/27/1999 10:46'!
lastStepTime: x

	worldState lastStepTime: x! !

!PasteUpMorph methodsFor: 'project state' stamp: 'jm 10/15/2002 15:32'!
modelWakeUp

	| aWindow |
	"I am the model of a SystemWindow, that has just been activated"
	owner == nil ifTrue: [^ self].  "Not in Morphic world"
	(aWindow _ self containingWindow) ifNotNil:
		[self viewBox = aWindow panelRect ifFalse:
			[self viewBox: aWindow panelRect]].
! !

!PasteUpMorph methodsFor: 'project state' stamp: 'di 7/27/1999 10:46'!
stepList

	^ worldState stepList! !

!PasteUpMorph methodsFor: 'project state' stamp: 'jm 12/9/2003 16:48'!
viewBox
	"This tortured workaround arises from a situation encountered in which a PasteUpMorph was directliy lodged as a submorph of another PasteUpMorph of identical size, with the former bearing flaps but the latter being the world."

	^ worldState
		ifNotNil: [worldState viewBox]
		ifNil: [(self ownerThatIsA: PasteUpMorph) viewBox]
! !

!PasteUpMorph methodsFor: 'project state' stamp: 'di 7/27/1999 10:46'!
viewBox: newViewBox

	| vb |
	((vb _ self viewBox) == nil or: [vb extent ~= newViewBox extent])
		ifTrue: [self canvas: nil].

	worldState viewBox: newViewBox.

	bounds _ 0@0 extent: newViewBox extent.
	"Paragraph problem workaround; clear selections to avoid screen droppings:"
	self handsDo: [:h | h newKeyboardFocus: nil].
	self fullRepaintNeeded.

! !


!PasteUpMorph methodsFor: 'stepping' stamp: 'tk 3/7/2000 22:48'!
cleanseStepList
	"Remove morphs from the step list that are not in this World.  Often were in a flap that has moved on to another world."

	| deletions morphToStep |
	deletions _ nil.
	self stepList do: [:entry |
		morphToStep _ entry at: 1.
		morphToStep world == self
			ifFalse:
				[deletions ifNil: [deletions _ OrderedCollection new].
				deletions addLast: morphToStep]].

	deletions ifNotNil:
		[deletions do: [:deletedM |
			self stopStepping: deletedM.
			deletedM stopStepping]].

! !

!PasteUpMorph methodsFor: 'stepping' stamp: 'EMP 12/10/2015 12:25'!
runStepMethods
	"Run morph 'step' methods whose time has come. Purge any morphs that are no longer in this world.
	ar 3/13/1999: Remove buggy morphs from the step list so that they don't raise repeated errors."

	| now deletions wakeupTime morphToStep |

	self stepList size = 0 ifTrue: [^ self].
	now _ Time millisecondClockValue.
	((now < self lastStepTime) or: [(now - self lastStepTime) > 5000])
		 ifTrue: [self adjustWakeupTimes].  "clock slipped"
	deletions _ nil.
	"Note: Put the following into an error handler to prevent errors happening on stepping"
	[self stepList do: [:entry |
		wakeupTime _ entry at: 2.
		morphToStep _ entry at: 1.
		morphToStep world == self
			ifTrue:
				[wakeupTime <= now
					ifTrue:
						[morphToStep stepAt: now.
						entry at: 2 put: now + morphToStep stepTime]]
			ifFalse:
				[deletions ifNil: [deletions _ IdentitySet new: 200].
				deletions add: morphToStep]]] 
	ifError: [:err :rcvr |
		self stopStepping: morphToStep. "Stop this guy right now"
		morphToStep setProperty: #errorOnStep toValue: true. "Remember stepping"
		Processor activeProcess errorHandler: nil. "So we don't handle this guy twice"
		rcvr error: err. "And re-raise the error from here so the stack is still valid"].

	deletions ifNotNil: [
		deletions do: [:m | m stopStepping].
		worldState stepList: (worldState stepList select: [:entry | (deletions includes: entry first) not])].

	self lastStepTime: now.
! !

!PasteUpMorph methodsFor: 'stepping' stamp: 'di 7/15/1999 09:51'!
startStepping: aMorph
	"Add the given morph to the step list. Do nothing if it is already being stepped."

	self stepList do: [:entry | entry first = aMorph ifTrue: [^ self]].  "already stepping"
	self adjustWakeupTimesIfNecessary.
	self stepList add:
		(Array with: aMorph with: Time millisecondClockValue).
! !

!PasteUpMorph methodsFor: 'stepping' stamp: 'di 7/15/1999 09:51'!
stopStepping: aMorph
	"Remove the given morph from the step list."

	self stepList copy do: [:entry |
		entry first == aMorph ifTrue: [self stepList remove: entry ifAbsent: []]].
! !


!PasteUpMorph methodsFor: 'world state' stamp: 'di 7/15/1999 09:51'!
abandonAllHalos
	self haloMorphs do: [:m | m delete]! !

!PasteUpMorph methodsFor: 'world state' stamp: 'di 7/15/1999 09:51'!
addAllMorphs: array

	super addAllMorphs: array.
	self isWorldMorph
		ifTrue: [array do: [:m | self startSteppingSubmorphsOf: m]].
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 12/7/2005 09:29'!
addHand: aHandMorph
	"Add the given hand to the list of hands for this world."

	self hands: (self hands copyWith: aHandMorph).
	aHandMorph privateOwner: self.
	self activeHand: aHandMorph.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'di 7/15/1999 09:51'!
addMorph: aMorph centeredNear: aPoint
	"Add the given morph to this world, attempting to keep its center as close to the given point possible while also keeping the it entirely within the bounds of this world."

	| trialRect delta |
	trialRect _ Rectangle center: aPoint extent: aMorph fullBounds extent.
	delta _ trialRect amountToTranslateWithin: bounds.
	aMorph position: trialRect origin + delta.
	self addMorph: aMorph.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'di 7/15/1999 09:51'!
allMorphsDo: aBlock
	"Enumerate all morphs in the world, including those held in hands."

	super allMorphsDo: aBlock.
	self isWorldMorph
		ifTrue: [self hands reverseDo: [:h | h allMorphsDo: aBlock]].
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 11/24/2002 10:49'!
assuredCanvas
	(self canvas == nil or:
	 [(self canvas extent ~= self viewBox extent)
		or: [self canvas form depth ~= Display depth]])
		ifTrue:
			["allocate a new offscreen canvas the size of the window"
			self canvas: (FormCanvas extent: self viewBox extent)].
	^ self canvas! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 10/4/2002 09:24'!
beWorldForProject: aProject

	self privateOwner: nil.
	worldState _ WorldState new.
	self addHand: HandMorph new.
	self startSteppingSubmorphsOf: self.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 11/24/2002 12:19'!
colorAt: aPoint belowMorph: aMorph
	"Return the color of the pixel immediately behind the given morph at the given point."
	"NOTE: due to some bounds wobble in flexing, take the middle of 3x3 patch."

	^ (self patchAt: (aPoint-1 extent: 3) without: aMorph andNothingAbove: true)
		colorAt: 1@1
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'EMP 12/10/2015 12:15'!
displayWorld
	"Update this world's display."

	| deferredUpdateMode updateNeeded worldDamageRects handsToDraw handDamageRects allDamage |

	submorphs do: [:m | m fullBounds].  "force re-layout if needed"
	updateNeeded _ self damageRecorder updateIsNeeded.
	updateNeeded ifFalse: [
		self handsDo: [:h |
			(h hasChanged and: [h needsToBeDrawn])
				ifTrue: [updateNeeded _ true]]].
	updateNeeded ifFalse: [^ self].  "display is already up-to-date"

	deferredUpdateMode _ self doDeferredUpdating.
	deferredUpdateMode ifFalse: [self assuredCanvas].

	worldDamageRects _ self drawInvalidAreasOn: self canvas.  "repair world's damage on canvas"
"Uncomment for Dakota:
		self remoteServer ifNotNil: [self remoteServer processDamageList: worldDamageRects]."
	handsToDraw _ self selectHandsToDrawForDamage: worldDamageRects.
	handDamageRects _ handsToDraw collect: [:h | h savePatchFrom: self canvas].
	allDamage _ worldDamageRects, handDamageRects.

	handsToDraw reverseDo: [:h | h fullDrawOn: self canvas].  "draw hands onto world canvas"
	false ifTrue: [  "*make this true to flash damaged areas for testing*"
		self flashRects: allDamage color: Color black].

	"quickly copy altered rects of canvas to Display:"
	deferredUpdateMode
		ifTrue: [allDamage do: [:r | Display forceToScreen: (r "translateBy: self viewBox origin")]]
		ifFalse: [self canvas showAt: self viewBox origin invalidRects: allDamage].
	handsToDraw do: [:h | h restoreSavedPatchOn: self canvas].  "restore world canvas under hands"
	Display deferUpdates: false; forceDisplayUpdate.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'ar 5/25/2000 18:00'!
displayWorldAsTwoTone
	"Display the world in living black-and-white. (This is typically done to save space.)"

	| f |
	f _ ColorForm extent: self viewBox extent depth: 1.
	f colors: (Array with: color dominantColor with: Color black).
	self canvas: (f getCanvas).

	"force the entire canvas to be redrawn"
	self fullRepaintNeeded.
	self drawInvalidAreasOn: self canvas.  "redraw on offscreen canvas"
	self canvas showAt: self viewBox origin.  "copy redrawn areas to Display"
	Display forceDisplayUpdate.
	self canvas: nil.  "forget my canvas to save space"
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 11/24/2002 10:49'!
displayWorldNonIncrementally
	"Display the morph world non-incrementally. Used for testing."

	(self canvas == nil or:
	 [(self canvas extent ~= self viewBox extent) or:
	 [self canvas form depth ~= Display depth]]) ifTrue: [
		"allocate a new offscreen canvas the size of the window"
		self canvas: (FormCanvas extent: self viewBox extent)].

	self canvas fillColor: color.
	submorphs reverseDo: [:m | m fullDrawOn: self canvas].
	self hands reverseDo: [:h | h fullDrawOn: self canvas].
	self canvas form displayOn: Display at: self viewBox origin.
	self fullRepaintNeeded.  "don't collect damage"
	Display forceDisplayUpdate.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'di 7/15/1999 09:51'!
displayWorldSafely
	"Update this world's display and keep track of errors during draw methods."
	| oldHandler errCtx errMorph |
	oldHandler _ Processor activeProcess errorHandler.
	[self displayWorld] ifError:[:err :rcvr|
		"Handle a drawing error"
		errCtx _ thisContext.
		[errCtx _ errCtx sender.
		"Search the sender chain to find the morph causing the problem"
		[errCtx notNil and:[(errCtx receiver isKindOf: Morph) not]] 
			whileTrue:[errCtx _ errCtx sender].
		"If we're at the root of the context chain then we have a fatal drawing problem"
		errCtx == nil ifTrue:[^self handleFatalDrawingError: err].
		errMorph _ errCtx receiver.
		"If the morph causing the problem has already the #drawError flag set,
		then search for the next morph above in the caller chain."
		errMorph hasProperty: #errorOnDraw] whileTrue.
		errMorph setProperty: #errorOnDraw toValue: true.
		"Install the old error handler, so we can re-raise the error"
		Processor activeProcess errorHandler: oldHandler.
		rcvr error: err.
	].! !

!PasteUpMorph methodsFor: 'world state' stamp: 'ar 5/25/2000 18:03'!
doDeferredUpdating
	"If this platform supports deferred updates, then make my canvas be the Display (or a rectangular portion of it), set the Display to deferred update mode, and answer true. Otherwise, do nothing and answer false. One can set the class variable DisableDeferredUpdates to true to completely disable the deferred updating feature."

	DisableDeferredUpdates ifNil: [DisableDeferredUpdates _ false].
	DisableDeferredUpdates ifTrue: [^ false].
	(Display deferUpdates: true) ifNil: [^ false].  "deferred updates not supported"

	self == World
		ifTrue: [  "this world fills the entire Display"
			((self canvas == nil) or: [self canvas form ~~ Display]) ifTrue: [
				self canvas: (Display getCanvas).
				self viewBox: Display boundingBox]]
		ifFalse: [  "this world is inside an MVC window"
			((self canvas == nil) or:
			 [(self canvas form ~~ Display) or:
			 [(self canvas origin ~= self viewBox origin)]]) ifTrue: [
				self canvas:
					((Display getCanvas)
						copyOffset: self viewBox origin clipRect: self viewBox)]].
	^ true
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 11/14/2007 23:03'!
doOneCycle

	self interCyclePause: MinCycleLapse.
	self doOneCycleNow.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'di 11/27/1999 10:11'!
exit

	Project current exit.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 5/29/2003 18:02'!
flashRects: rectangleList color: aColor
	"For testing. Flashes the given list of rectangles on the Display so you can watch incremental redisplay at work."
	"Details: Uses two reverses so that the display is restored to its original state. This is necessary when in deferred update mode."

	| blt screenRect |
	blt _ (BitBlt toForm: Display)
		sourceForm: nil;
		sourceOrigin: 0@0;
		clipRect: self viewBox;
		combinationRule: Form reverse.
	rectangleList do: [:r |
		screenRect _ r "translateBy: self viewBox origin".
		blt destRect: screenRect; copyBits.
		Display forceToScreen: screenRect; forceDisplayUpdate.
		(Delay forMilliseconds: 15) wait.
		blt destRect: screenRect; copyBits.
		Display forceToScreen: screenRect; forceDisplayUpdate].
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 10/12/2005 12:31'!
fullRepaintNeeded

	self damageRecorder doFullRepaint.
	self submorphsDo: [:m |
		(m isKindOf: SystemWindow) ifTrue: [m makeMeVisible]].

! !

!PasteUpMorph methodsFor: 'world state' stamp: 'di 11/27/1999 10:11'!
goBack

	Project returnToPreviousProject.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'di 7/15/1999 09:51'!
haloMorphOrNil
	| m |
	^ (m _ self haloMorphs) size > 0 ifTrue: [m first] ifFalse: [nil]! !

!PasteUpMorph methodsFor: 'world state' stamp: 'di 7/15/1999 09:51'!
haloMorphs
	^ submorphs select: [:m | m isKindOf: HaloMorph]! !

!PasteUpMorph methodsFor: 'world state' stamp: 'di 7/27/1999 10:46'!
handleFatalDrawingError: errMsg
	"Handle a fatal drawing error."
	Smalltalk isMorphic ifFalse:[^self error: errMsg]. "Can still handle it from MVC"
	Display deferUpdates: false. "Just in case"
	self primitiveError: errMsg.

	"Hm... we should jump into a 'safe' worldState here, but how do we find it?!!"! !

!PasteUpMorph methodsFor: 'world state' stamp: 'di 7/15/1999 09:51'!
handlesMouseDown: evt

	self isWorldMorph
		ifTrue: [^ true]
		ifFalse: [^ super handlesMouseDown: evt]
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 10/12/2005 11:26'!
initializeForProject

	worldState _ WorldState new.
	color _ (Color r:0.937 g: 0.937 b: 0.937).
	self addHand: HandMorph new.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 10/5/2002 06:38'!
install

	submorphs do: [:ss | ss owner == nil ifTrue: [ss privateOwner: self]].
		"Transcript that was in outPointers and then got deleted."

	self viewBox: Display boundingBox.
	self handsDo: [:h | h initForEvents].

	SystemWindow noteTopWindowIn: self.
	self displayWorldSafely.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 11/14/2007 23:16'!
interCyclePause: milliSecs
	"Delay enough that the next interaction cycle won't happen too soon after the original; thus, if all the system is doing is polling for interaction, the overall CPU usage of Squeak will be low"

	| currentTime wait |
	currentTime _ Time millisecondClockValue.
	self lastCycleTime ifNotNil: [ 
		wait _ self lastCycleTime + milliSecs - currentTime.
		wait > 0 ifTrue: [ 
			wait <= milliSecs ifTrue: [  "big waits happen after a snapshot"
				DisplayScreen checkForNewScreenSize.
				Delay waitMSecs: wait]]].

	self lastCycleTime: Time millisecondClockValue.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'di 11/27/1999 10:20'!
jumpToProject

	Project jumpToProject.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 8/11/2003 21:59'!
mouseDown: evt
	"Handle a mouse down event."

	self isWorldMorph ifFalse: [^ super mouseDown: evt].
	evt hand newKeyboardFocus: nil.
	evt hand invokeMetaMenu: evt.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'di 7/15/1999 09:51'!
open
	"Open a view on this WorldMorph."

	MorphWorldView openOn: self.! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 9/27/2003 21:44'!
patchAt: patchRect without: stopMorph andNothingAbove: stopThere
	"Return a complete rendering of this patch of the display screen without drawing stopMorph and, if stopThere is true, without drawing any morph above it."

	| c morphsToDraw i |
	c _ FormCanvas extent: patchRect extent depth: Display depth.
	c _ c copyOrigin: patchRect topLeft negated clipRect: (0@0 extent: patchRect extent).

	(self bounds containsRect: patchRect) ifFalse: [
		"fill areas of patchRect outside my bounds with black"
		c form fillColor: Color black].
	(self bounds intersects: patchRect) ifFalse: [^ c form].  "entirely out of bounds"

	"draw all morphs intersecting the given patch, stopping at the given morph"
	c fillRectangle: self bounds color: color.  "draw world color"
	morphsToDraw _ submorphs reversed asOrderedCollection.
	(i _ morphsToDraw indexOf: stopMorph) > 0 ifTrue: [
		stopThere
			ifTrue: [morphsToDraw _ morphsToDraw copyFrom: 1 to: i - 1]  "stop at stopMorph"
			ifFalse: [morphsToDraw removeIndex: i]].  "skip stopMorph"
	morphsToDraw do: [:m | m fullDrawOn: c].
	^ c form
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 12/7/2005 09:26'!
removeHand: aHandMorph
	"Remove the given hand from the list of hands for this world."

	(self hands includes: aHandMorph) ifTrue: [
		aHandMorph dropMorphsEvent: MorphicEvent new.
		self hands: (self hands copyWithout: aHandMorph).
		self invalidRect: aHandMorph fullBounds.
		self activeHand == aHandMorph ifTrue: [self activeHand: self hands first]].
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 10/14/2002 07:48'!
restoreDisplay

	self == World ifTrue: [  "otherwise, we're a morphic window in MVC and the restoreDisplay was, unusually, issued from that world's menu rather than from the MVC screen menu"
		DisplayScreen startUp.
		self extent: Display extent.
		self viewBox: Display boundingBox].

	self fullRepaintNeeded.
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'di 7/15/1999 09:51'!
selectHandsToDrawForDamage: damageList
	"Select the set of hands that must be redrawn because either (a) the hand itself has changed or (b) the hand intersects some damage rectangle."

	| result hBnds |
	result _ OrderedCollection new.
	self handsDo: [:h |
		h needsToBeDrawn ifTrue: [
			h hasChanged
				ifTrue: [result add: h]
				ifFalse: [
					hBnds _ h fullBounds.
					(damageList detect: [:r | r intersects: hBnds] ifNone: [nil])
						ifNotNil: [result add: h]]]].
	^ result
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 7/17/2003 23:02'!
sleep
	"Minimize space. Typically called when exiting a project."

	self canvas ifNil: [^ self].  "already cleaned up"

	Cursor normal show.  "restore the normal cursor"
	(turtleTrailsForm notNil and:
	 [self confirm: 'May I clear the pen trails?'])
		ifTrue: [self clearTurtleTrails].
	self canvas: nil.  "free my canvas to save space"
	self allMorphsDo: [:m | m releaseCachedState].
! !

!PasteUpMorph methodsFor: 'world state' stamp: 'jm 10/22/2005 14:32'!
startSteppingSubmorphsOf: aMorph
	"Ensure that all submorphs of the given morph that want to be stepped are added to the step list. Typically used after adding a morph to the world."

	| w |
	(w _ aMorph world) ifNil: [^ self].
	aMorph allMorphsDo: [:m |
		m wantsSteps ifTrue: [w startStepping: m]].

! !


!PasteUpMorph methodsFor: 'project' stamp: 'di 7/15/1999 09:51'!
adjustWakeupTimes
	"Fix the wakeup times in my step list. This is necessary when this world has been restarted after a pause, say because some other view had control, after a snapshot, or because the millisecond clock has wrapped around. (The latter is a rare occurence with a 32-bit clock!!)"

	| earliestTime t now m oldWakeupTime |
	"find earliest wakeup time"
	earliestTime _ SmallInteger maxVal.
	self stepList do: [:entry |
		t _ entry at: 2.
		t < earliestTime ifTrue: [earliestTime _ t]].

	"recompute all wakeup times, using earliestTime as the origin"
	now _ Time millisecondClockValue.
	self stepList do: [:entry |
		m _ entry at: 1.
		oldWakeupTime _ entry at: 2.
		entry at: 2 put: now + ((oldWakeupTime - earliestTime) min: m stepTime)].
	self lastStepTime: now.
! !

!PasteUpMorph methodsFor: 'project' stamp: 'di 7/15/1999 09:51'!
adjustWakeupTimesIfNecessary
	"Fix the wakeup times in my step list if necessary. This is needed after a snapshot, after a long pause (say because some other view had control or because the user was selecting from an MVC-style menu) or when the millisecond clock wraps around (a very rare occurence with a 32-bit clock!!)."

	| now |
	now _ Time millisecondClockValue.
	((now < self lastStepTime) or: [(now - self lastStepTime) > 5000])
		 ifTrue: [self adjustWakeupTimes].  "clock slipped"
! !

!PasteUpMorph methodsFor: 'project' stamp: 'tk 9/3/1999 12:07'!
project
	"Find the project that owns me.  Not efficient to call this."

	^ Project ofWorld: self! !


!PasteUpMorph methodsFor: 'interaction loop' stamp: 'jm 12/7/2005 09:23'!
cycleWhileWaitingMSecs: waitMSecs doInput: doInputFlag doSteps: doStepFlag
	"Perform the interactive loop repeatedly for the given number of milliseconds."

	| startT now |
	startT _ Time millisecondClockValue.
	[((now _ Time millisecondClockValue) < startT) or:
	 [(now - startT) < waitMSecs]] whileTrue: [
		doInputFlag ifTrue: [
			"process user input events"
			self handsDo: [:h |
				self activeHand: h.
				h processEvents]].

		doStepFlag ifTrue: [self runStepMethods].
		self displayWorldSafely].
! !

!PasteUpMorph methodsFor: 'interaction loop' stamp: 'TIS 6/18/2003 17:20'!
doOneCycleNoInput
	"Do one cycle of the display and step loop without user input."

	self runStepMethods.
	self displayWorldSafely.
! !

!PasteUpMorph methodsFor: 'interaction loop' stamp: 'jm 12/7/2005 09:23'!
doOneCycleNow
	"Do one cycle of the interactive loop. This method is called repeatedly when the world is running."

	"process user input events"
	self handsDo: [:h |
		self activeHand: h.
		h processEvents].

	self runStepMethods.
	self displayWorldSafely.
! !


!PasteUpMorph methodsFor: 'private' stamp: 'ar 3/14/2000 23:20'!
privateFullMoveBy: delta
	"Private. Overridden to prevent drawing turtle trails when a playfield is moved"
	self setProperty: #turtleTrailsDelta toValue: delta.
	super privateFullMoveBy: delta.
	self removeProperty: #turtleTrailsDelta.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

PasteUpMorph class
	instanceVariableNames: ''!

!PasteUpMorph class methodsFor: 'as yet unclassified' stamp: 'jm 5/31/2003 20:03'!
includeInNewMorphMenu

	^ true
! !

!PasteUpMorph class methodsFor: 'as yet unclassified' stamp: 'jm 10/12/2005 11:27'!
newWorldForProject: projectOrNil 
	"Answer a new pasteUpMorph configured as the root world for a project."

	^ self new initializeForProject
! !


!PasteUpMorph class methodsFor: 'project' stamp: 'di 7/15/1999 09:51'!
disableDeferredUpdates: aBoolean
	"If the argument is true, disable deferred screen updating."
	"Details: When deferred updating is used, Morphic performs double-buffered screen updates by telling the VM to de-couple the Display from the hardware display buffer, drawing directly into the Display, and then forcing the changed regions of the Display to be copied to the screen. This saves both time (an extra BitBlt is avoided) and space (an extra display buffer is avoided). However, on platforms on which the Display points directly to the hardware screen buffer, deferred updating can't be used (you'd see ugly flashing as the layers of the drawing were assembled). In this case, the drawing is composited into an offscreen FormCanvas  and then copied to the hardware display buffer."

	DisableDeferredUpdates _ aBoolean.
! !

!PasteUpMorph class methodsFor: 'project' stamp: 'jm 11/20/2007 09:09'!
initialize
	"self initialize"

	MinCycleLapse _ 25.
! !

!PasteUpMorph class methodsFor: 'project' stamp: 'jm 1/1/2004 11:18'!
startUp

	Smalltalk isMorphic ifTrue: [World restoreDisplay].
! !


PasteUpMorph initialize!
