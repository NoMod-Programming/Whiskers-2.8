Object subclass: #Morph
	instanceVariableNames: 'bounds owner submorphs fullBounds color flags properties '
	classVariableNames: 'HiddenFlag LockedFlag PartsDonorFlag StickyFlag '
	poolDictionaries: ''
	category: 'Morphic-Kernel'!
!Morph commentStamp: 'jm 6/15/2003 10:58' prior: 0!
A morph (from the Greek "shape" or "form") is an interactive graphical object.

The 'bounds' of a morph is a rectangle that just encloses its visual representation on the screen. A morph's drawOn: method should not write pixels outside of the bounds rectangle. This rectangle is used both to keep track of screen areas that need to be repainted and as the first approximation for mouse-click hit detection.

Simple morphs can be combined to create a compound morph. In such a structure, one morph forms the root of the hierarchy, each morph has a list of zero or morph submorphs, and each morph knows which morph has it as a submorph (i.e., its 'owner').

All coordinates are in global screen coordinates. (Except in the case of morphs within a TransformMorph, but TransformMorph's are being phased out.)

Morphs have a set of flags (such as 'hidden') and an optional list of properties.
!


!Morph methodsFor: 'initialization' stamp: 'sw 10/2/97 23:08'!
initialExtent
	| ext |
	(ext _ self valueOfProperty: #initialExtent)
		ifNotNil:
			[^ ext].
	^ super initialExtent! !

!Morph methodsFor: 'initialization' stamp: 'jm 10/14/2002 08:40'!
initialize

	bounds _ 0@0 corner: 50@40.
	owner _ nil.
	submorphs _ Array empty.
	fullBounds _ nil.
	color _ Color blue.
	flags _ 0.
	properties _ nil.
! !

!Morph methodsFor: 'initialization' stamp: 'jm 7/5/1998 12:40'!
openInMVC

	MorphWorldView
		openWorldWith: self
		labelled: self defaultLabelForInspector.
! !

!Morph methodsFor: 'initialization' stamp: 'sma 4/30/2000 10:43'!
openInWorld
	"Add this morph to the world.  If in MVC, then provide a Morphic window for it."

	Smalltalk isMorphic
		ifTrue: [self openInWorld: self currentWorld]
		ifFalse: [self openInMVC]! !

!Morph methodsFor: 'initialization' stamp: 'bf 1/5/2000 19:57'!
openInWorld: aWorld
	"Add this morph to the requested World."
	(aWorld viewBox origin ~= (0@0) and: [self position = (0@0)]) ifTrue:
		[self position: aWorld viewBox origin].
	aWorld addMorph: self.
	aWorld startSteppingSubmorphsOf: self! !


!Morph methodsFor: 'classification' stamp: 'di 5/7/1998 01:21'!
isAlignmentMorph

	^ false! !

!Morph methodsFor: 'classification' stamp: 'jm 10/14/2002 09:14'!
isColorable
	"Answer true if my color can be changed using the color: message. Subclasses whose color cannot be changes this way (e.g., those based on a Form) should override this to return false."

	^ true
! !

!Morph methodsFor: 'classification'!
isHandMorph

	^ false! !

!Morph methodsFor: 'classification'!
isMorph

	^ true! !

!Morph methodsFor: 'classification' stamp: 'jm 12/9/2003 18:05'!
isPaintable
	"Answer true if my image can be repainted."

	^ false
! !

!Morph methodsFor: 'classification' stamp: 'jm 5/6/2004 19:48'!
isRotatable
	"Answer true if my image can be rotated."

	^ false
! !

!Morph methodsFor: 'classification'!
isWorldMorph

	^ false! !

!Morph methodsFor: 'classification'!
isWorldOrHandMorph

	^ self isWorldMorph or: [self isHandMorph]! !


!Morph methodsFor: 'accessing' stamp: 'jm 3/3/2008 23:19'!
backgroundColor
	"Answer the background color for this morph, taken to be color of the first owner that is not transparent. Note that this does not take sibling morphs into account."

	| m |
	m _ owner.
	[m notNil] whileTrue: [
		(m isKindOf: SystemWindow) ifTrue: [^ Color transparent].
		m color isTransparent ifFalse: [^ m color].
		m _ m owner].

	^ m ifNil: [Color white] ifNotNil: [m color].
! !

!Morph methodsFor: 'accessing' stamp: 'jm 8/11/2003 21:09'!
balloonHelpTextFor: aSelector

	#(	(chooseEmphasisOrAlignment				'Emphasis & alignment')
		(chooseFont								'Change font')
		(chooseStyle								'Change style')
		(dismiss									'Remove')
		(doDebug:with:							'Debug')
		(doDirection:with:						'Choose forward direction')
		(doDup:with:							'Duplicate')
		(doMenu:with:							'Menu')
		(doGrab:with:							'Pick up')
		(doRecolor:with:							'Change color')
		(editDrawing							'Repaint')
		(maybeDoDup:with:						'Duplicate')
		(mouseDownInDimissHandle:with:			'Delete')
		(mouseDownInCollapseHandle:with:		'Collapse morph')
		(mouseDownOnHelpHandle:				'Help')
		(prepareToTrackCenterOfRotation:with:	'Set center of rotation')
		(startDrag:with:							'Move')
		(startGrow:with:							'Change size') 
		(trackCenterOfRotation:with:				'Set center of rotation')
	)  do: [:pair |
		aSelector = pair first ifTrue: [^ pair last]].

	^ aSelector asString  "this is best we can do; gives some information at least"

! !

!Morph methodsFor: 'accessing' stamp: 'jm 10/13/2002 20:09'!
balloonText
	"Answer balloon help text or nil, if no help is available."

	^ self valueOfProperty: #balloonText
! !

!Morph methodsFor: 'accessing'!
color

	^ color! !

!Morph methodsFor: 'accessing' stamp: 'jm 8/24/97 21:26'!
color: aColor

	color = aColor ifFalse: [
		color _ aColor.
		self changed].
! !

!Morph methodsFor: 'accessing' stamp: 'ee 6/28/2008 13:40'!
colorForInsets
	"Return the color to be used for shading inset borders. The default is my own color, but it might want to be, eg, my owner's color. Whoever's color ends up prevailing, the color itself gets the last chance to determine, so that when, for example, an InfiniteForm serves as the color, callers won't choke on some non-Color object being returned"

	(color = Color transparent) ifTrue: [
		owner ifNotNil: [
			^ owner colorForInsets]].
	^ color colorForInsets
! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:38'!
eventNameMatches: aMessage
	^ false! !

!Morph methodsFor: 'accessing' stamp: 'di 1/3/1999 12:25'!
hasTranslucentColor
	"Answer true if this any of this morph is translucent but not transparent."

	^ color isColor and: [color isTranslucentColor]
! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:42'!
isBackdropEventHatMorph
	^ false! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:40'!
isMouseClickEventHatMorph
	^ false! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:46'!
isWhenCloneHat
	^ false! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:39'!
respondsToBackdropName: t1 
	^ false! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:38'!
respondsToKeyEvent: event
	^ false! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:39'!
stopAllProcessing
	^ self! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:06'!
stopProcess
	^ self! !


!Morph methodsFor: 'access properties' stamp: 'jm 10/13/2002 21:06'!
hasProperty: propName
	"Return true if my properties list includes a property with the given name."

	properties ifNil: [^ false].
	^ (properties propertyForName: propName asSymbol) notNil
! !

!Morph methodsFor: 'access properties' stamp: 'jm 10/13/2002 21:06'!
removeProperty: propName
	"Remove the property with the given name from my properties list."

	properties ifNil: [^ self].
	properties _ properties copyWithoutName: propName asSymbol.
! !

!Morph methodsFor: 'access properties' stamp: 'jm 10/13/2002 21:07'!
setProperty: propName toValue: anObject

	| entry newEntry |
	anObject ifNil: [^ self removeProperty: propName].
	properties ifNil: [
		properties _ MorphProperty new name: propName value: anObject.
		^ self].

	entry _ properties propertyForName: propName asSymbol.
	entry
		ifNil: [  "create and add a new entry at start of properties list"
			newEntry _ MorphProperty new name: propName value: anObject.
			newEntry nextLink: properties.
			properties _ newEntry]
		ifNotNil: [  "update the existing entry"
			entry value: anObject].
! !

!Morph methodsFor: 'access properties' stamp: 'jm 10/13/2002 20:49'!
valueOfProperty: propName
	"Return the value of the property with the given name in my properties list, or nil if I have no property with that name."

	^ self valueOfProperty: propName ifAbsent: [nil]
! !

!Morph methodsFor: 'access properties' stamp: 'jm 10/13/2002 21:07'!
valueOfProperty: propName ifAbsent: aBlock
	"Return the value of the property with the given name in my properties list, or the value of the given block if I have no property with that name."

	| prop |
	properties ifNil: [^ aBlock value].
	prop _ properties propertyForName: propName asSymbol.
	prop
		ifNil: [^ aBlock value]
		ifNotNil: [^ prop value].
! !

!Morph methodsFor: 'access properties' stamp: 'EMP 4/27/2016 12:04'!
valueOfProperty: propName ifPresent: aBlock
	"Return the value of the property with the given name in my properties list, or the value of the given block if I have no property with that name."

	| prop |
	properties ifNil: [^ aBlock value].
	prop _ properties propertyForName: propName asSymbol.
	prop
		ifNil: [^ self]
		ifNotNil: [^ aBlock value].
! !


!Morph methodsFor: 'copying'!
copy

	^ self copyWithoutSubmorphs! !

!Morph methodsFor: 'copying' stamp: 'jm 10/13/2002 21:23'!
copyRecordingIn: dict
	"Recursively copy this entire composite morph, recording the correspondence between old and new morphs in the given dictionary. This dictionary will be used to update intra-composite references in the copy. See updateReferencesUsing:.
	Note: This default implementation copies ONLY morphs in the submorph hierarchy. If a subclass stores morphs in instance variables that it wants to copy, then it should override this method to do so. The same goes for subclasses that contain other data that should be copied when the morph is duplicated."

	| new |
	new _ self copy.
	dict at: self put: new.
	submorphs size > 0 ifTrue: [
		new privateSubmorphs:
			(submorphs collect: [:m |
				(m copyRecordingIn: dict) privateOwner: new])].

	properties ifNotNil: [new privateProperties: properties copyAll].
	^ new
! !

!Morph methodsFor: 'copying' stamp: 'jm 10/13/2002 21:27'!
copyWithoutSubmorphs

	^ self clone
		privateOwner: nil;
		privateSubmorphs: Array empty;
		privateBounds: (bounds origin corner: bounds corner)  "deep-copy bounds"
! !

!Morph methodsFor: 'copying' stamp: 'jm 10/7/2002 06:43'!
deepCopy

	^ self fullCopy
! !

!Morph methodsFor: 'copying' stamp: 'jm 10/13/2002 21:25'!
fullCopy
	"Produce a copy of me with my entire tree of submorphs. Morphs mentioned more than once are all directed to a single new copy. Simple
inst vars are not copied, so you must override to copy Arrays, Forms, editable text, etc."

	| dict new |
	dict _ IdentityDictionary new: 1000.
	new _ self copyRecordingIn: dict.
	new allMorphsDo: [:m | m updateReferencesUsing: dict].
	^ new! !

!Morph methodsFor: 'copying' stamp: 'jm 10/13/2002 21:01'!
updateReferencesUsing: aDictionary
	"Update intra-morph references within a composite morph that has
been copied. For example, if a button refers to morph X in the orginal
composite then the copy of that button in the new composite should refer to
the copy of X in new composite, not the original X. This default
implementation updates the contents of any morph-bearing slot. It may be
overridden to avoid this behavior if so desired."

	| old prop |
	Morph instSize + 1 to: self class instSize do: [:i |
		old _ self instVarAt: i.
		old isMorph ifTrue:
			[self instVarAt: i put: (aDictionary at: old ifAbsent: [old])]].

	"map morph values in my properties list"
	prop _ properties.
	[prop == nil] whileFalse: [
		old _ prop value.
		old isMorph ifTrue: [
			prop value: (aDictionary at: old ifAbsent: [old])].
		prop _ prop nextLink].
! !


!Morph methodsFor: 'structure' stamp: 'jm 12/7/2005 09:29'!
activeHand

	^ (self world ifNil: [^ nil]) activeHand
! !

!Morph methodsFor: 'structure' stamp: 'jm 12/21/2004 12:15'!
allOwners
	"Answer a collection of all my owners from the root of the morph structure down to my immediate owner. The root will be the first element."

	| result m |
	result _ OrderedCollection new.

	m _ owner.
	[m == nil] whileFalse: [
		result addFirst: m.
		m _ m owner].
	^ result asArray
! !

!Morph methodsFor: 'structure' stamp: 'jm 7/8/97 10:08'!
isInWorld
	"Return true if this morph is in a world."

	^ self world ~~ nil! !

!Morph methodsFor: 'structure'!
owner
	"Returns the owner of this morph, which may be nil."

	^ owner! !

!Morph methodsFor: 'structure' stamp: 'EMP 4/26/2016 16:11'!
ownerOrYourselfThatIsA: t1 
	| t2 |
	t2 := self.
	[t2 == nil]
		whileFalse: [(t2 isKindOf: t1)
				ifTrue: [^ t2].
			t2 := t2 owner].
	^ t2! !

!Morph methodsFor: 'structure' stamp: 'jm 8/16/2005 17:16'!
ownerThatIsA: aClass
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current |
	current _ self.
	[current == nil] whileFalse: [
		(current isKindOf: aClass) ifTrue: [^ current].
		current _ current owner].
	^ current
! !

!Morph methodsFor: 'structure' stamp: 'EMP 2/9/2016 15:37'!
ownerThatIsANotSelf: aClass
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current |
	current _ self owner.
	[current == nil] whileFalse: [
		(current isKindOf: aClass) ifTrue: [^ current].
		current _ current owner].
	^ current
! !

!Morph methodsFor: 'structure'!
root
	"Return the root of the composite morph containing the receiver. The owner of the root is either nil, a WorldMorph, or a HandMorph. If the receiver's owner is nil, the root is the receiver itself. This method always returns a morph."

	(owner = nil or: [owner isWorldOrHandMorph]) ifTrue: [^ self].
	^ owner root! !

!Morph methodsFor: 'structure' stamp: 'jm 12/9/2008 16:10'!
world
	"Answer the PasteUpMorph 'world' that contains this morph or nil if it is not in the world."

	| m |
	m _ owner.
	[nil == m] whileFalse: [
		m isWorldMorph ifTrue: [^ m].
		m _ m owner].

	^ nil
! !


!Morph methodsFor: 'submorphs-accessing'!
allMorphs
	"Return a collection containing all morphs in this composite morph (including the receiver)."

	| all |
	all _ OrderedCollection new: 100.
	self allMorphsDo: [: m | all add: m].
	^ all! !

!Morph methodsFor: 'submorphs-accessing'!
allMorphsDo: aBlock
	"Evaluate the given block for all morphs in this composite morph (including the receiver)."

	submorphs size > 0 ifTrue: [
		submorphs do: [:m | m allMorphsDo: aBlock].
	].
	aBlock value: self.
! !

!Morph methodsFor: 'submorphs-accessing'!
findA: aClass
	"Return the first submorph of the receiver that is descended from the given class. Return nil if there is no such submorph. Clients of this code should always check for a nil return value so that the code will be robust if the user takes the morph apart."

	submorphs do: [:each | (each isKindOf: aClass) ifTrue: [^ each]].
	^ nil
! !

!Morph methodsFor: 'submorphs-accessing'!
firstSubmorph

	^ submorphs at: 1! !

!Morph methodsFor: 'submorphs-accessing'!
hasSubmorphs

	^ submorphs size > 0! !

!Morph methodsFor: 'submorphs-accessing'!
lastSubmorph

	^ submorphs at: submorphs size! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'di 2/21/98 21:20'!
morphsAt: aPoint
	"Return a collection of all morphs in this morph structure that contain the given point, possibly including the receiver itself.  The order is deepest embedding first."

	^ self morphsAt: aPoint addTo: OrderedCollection new! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'jm 8/3/2003 14:07'!
morphsAt: aPoint addTo: mList
	"Return a collection of all morphs in this morph structure that contain the given point, possibly including the receiver itself. Must do this recursively because of transforms.  "

	(self fullBounds containsPoint: aPoint) ifFalse: [^ mList].  "quick elimination"
	submorphs size > 0 ifTrue: [
		submorphs do: [:m | m morphsAt: aPoint addTo: mList]].
	(self containsPoint: aPoint) ifTrue: [mList addLast: self].
	^ mList
! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'ar 11/8/1999 00:08'!
rootMorphsAt: aPoint
	"Return the list of root morphs containing the given point, excluding the receiver.
	ar 11/8/1999: Moved into morph for an incredibly ugly hack in 3D worlds"

	^ self submorphs select:
		[:m | (m fullContainsPoint: aPoint) and: [m isLocked not]]! !

!Morph methodsFor: 'submorphs-accessing'!
submorphCount

	^ submorphs size! !

!Morph methodsFor: 'submorphs-accessing'!
submorphs

	^ submorphs copy! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'di 11/4/97 14:30'!
submorphsBehind: aMorph do: aBlock
	| behind |
	behind _ false.
	submorphs do:
		[:m | m == aMorph ifTrue: [behind _ true]
						ifFalse: [behind ifTrue: [aBlock value: m]]].
! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'di 5/13/1998 20:42'!
submorphsDo: aBlock

	submorphs size = 0 ifTrue: [^ self].
	submorphs do: aBlock.! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'di 11/4/97 14:29'!
submorphsInFrontOf: aMorph do: aBlock
	| behind |
	behind _ false.
	submorphs do:
		[:m | m == aMorph ifTrue: [behind _ true]
						ifFalse: [behind ifFalse: [aBlock value: m]]].
! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'jm 7/9/2008 20:27'!
uncoveredAt: aPoint
	"Return true if the receiver is not covered by any submorphs at the given point."

	| w morphsAbove |
	(w _ self world) ifNil: [^ true].

	morphsAbove _ w morphsAt: aPoint.
	^ (morphsAbove size = 0) or:
	 [morphsAbove first = self or:
	 [(morphsAbove first isKindOf: HaloMorph) and:
	 [(morphsAbove at: 2) = self]]]
! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'sw 8/22/97 23:45'!
unlockedMorphsAt: aPoint
	"Return a collection of all unlocked morphs in this morph structure that contain the given point, possibly including the receiver itself.  Simplified "

	^ self unlockedMorphsAt: aPoint addTo: OrderedCollection new! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'di 2/10/98 15:47'!
unlockedMorphsAt: aPoint addTo: mList
	"Return a collection of all morphs in this morph structure that contain the given point, possibly including the receiver itself.  Must do this recursively because of transforms.  "
	(self fullBounds containsPoint: aPoint) ifFalse: [^ mList].  "quick elimination"
	self isLocked ifTrue: [^ mList].
	submorphs size > 0 ifTrue:
		[submorphs do: [:m | m unlockedMorphsAt: aPoint addTo: mList]].
	(self containsPoint: aPoint) ifTrue: [mList addLast: self].
	^ mList! !


!Morph methodsFor: 'submorphs-add/remove'!
addAllMorphs: aCollection

	aCollection do: [:m |
		m owner ifNotNil: [m owner privateRemoveMorph: m].
		m layoutChanged.
		m privateOwner: self].
	submorphs _ submorphs, aCollection.
	self layoutChanged.
! !

!Morph methodsFor: 'submorphs-add/remove'!
addMorph: aMorph

	self addMorphFront: aMorph.! !

!Morph methodsFor: 'submorphs-add/remove'!
addMorphBack: aMorph

	aMorph owner ifNotNil: [aMorph owner privateRemoveMorph: aMorph].
	aMorph layoutChanged.
	aMorph privateOwner: self.
	submorphs _ submorphs copyWith: aMorph.
	aMorph changed.  "need to paint morphs now front, if any"
	self layoutChanged.
! !

!Morph methodsFor: 'submorphs-add/remove'!
addMorphCentered: aMorph

	self addMorphFront: aMorph.
	aMorph position: bounds center - (aMorph extent // 2)! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'jm 5/29/1998 15:39'!
addMorphFront: aMorph

	| newSubmorphs |
	aMorph owner ifNotNil: [aMorph owner privateRemoveMorph: aMorph].
	aMorph layoutChanged.
	aMorph privateOwner: self.
	newSubmorphs _ submorphs species new: submorphs size + 1.
	newSubmorphs at: 1 put: aMorph.
	newSubmorphs
		replaceFrom: 2
		to: newSubmorphs size
		with: submorphs
		startingAt: 1.
	submorphs _ newSubmorphs.
	aMorph changed.
	self layoutChanged.
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'ar 11/15/1998 23:42'!
addMorphFront: aMorph fromWorldPosition: wp

	self addMorphFront: aMorph.
	aMorph position: (self transformFromWorld globalPointToLocal: wp)! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'jm 10/15/2002 17:20'!
comeToFront

	| myOwner |
	myOwner _ self owner.
	(myOwner == nil or: [myOwner hasSubmorphs not]) ifTrue: [^ self].
	myOwner firstSubmorph == self ifFalse:
		[myOwner addMorphFront: self].
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'di 10/27/97 23:26'!
copyWithoutSubmorph: sub
	"Needed to get a morph to draw without one of its submorphs.
	NOTE:  This must be thrown away immediately after use."
	^ self clone privateSubmorphs: (submorphs copyWithout: sub)! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'jm 10/3/2002 19:23'!
delete
	"Remove the receiver as a submorph of its owner and make its new owner be nil."

	owner ifNotNil: [
		owner privateRemoveMorph: self.
		owner _ nil].
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'jm 3/30/2005 07:16'!
goBehind

	owner ifNotNil: [
		owner addMorphBack: self].
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'jens 3/18/2009 13:24'!
moveMorph: morphToMove inFrontOf: aMorph
	"change a submorph's layer by moving it in front of another submorph"

	| morphsBehind morphsBefore idx sm |
	sm _ (submorphs reject: [:m | m == morphToMove]) asOrderedCollection.
	idx _ sm indexOf: aMorph.
	morphsBefore _ sm copyFrom: 1 to: idx - 1.
	morphsBehind _ sm copyFrom: idx to: sm size.
	morphToMove privateOwner: self.
	morphsBefore add: morphToMove.
	submorphs _ (morphsBefore, morphsBehind) asArray.
	morphToMove changed.
	self layoutChanged.
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'EMP 4/29/2016 10:03'!
privateAddMorph: aMorph atIndex: index

	((index >= 1) and: [index <= (submorphs size + 1)])
		ifFalse: [^ self error: 'index out of range'].
	aMorph owner ifNotNil: [aMorph owner privateRemoveMorph: aMorph].
	aMorph layoutChanged.
	aMorph privateOwner: self.
	submorphs _ submorphs copyReplaceFrom: index to: index-1 with: (Array with: aMorph).
	self layoutChanged.
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'sw 2/15/98 23:34'!
privateDelete
	"Remove the receiver as a submorph of its owner and make its new owner be nil, without informing anyone other than my owner"

	owner ifNotNil:
		[owner privateRemoveMorph: self.
		owner _ nil].! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'jm 10/13/2002 17:37'!
removeAllMorphs

	self changed.
	submorphs do: [:m | m privateOwner: nil].
	submorphs _ Array empty.
	self layoutChanged.
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'RAA 10/6/1999 12:23'!
removeAllMorphsIn: aCollection
"greatly speeds up the removal of *lots* of submorphs"
	| set |
	self changed.
	aCollection do: [:m | m privateOwner: nil].
	set _ IdentitySet new: aCollection size * 4 // 3.
	aCollection do: [:each | set add: each].
	submorphs _ submorphs reject: [ :each | set includes: each].
	self layoutChanged.
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'sw 10/25/1999 23:34'!
replaceSubmorph: oldMorph by: newMorph
	| index itsPosition w |
	oldMorph stopStepping.
	itsPosition _ oldMorph referencePositionInWorld.
	index _ submorphs indexOf: oldMorph.
	oldMorph privateDelete.
	self privateAddMorph: newMorph atIndex: index.
	newMorph referencePositionInWorld: itsPosition.
	(w _ newMorph world) ifNotNil:
		[w startSteppingSubmorphsOf: newMorph]! !


!Morph methodsFor: 'drawing' stamp: 'di 6/24/1998 14:10'!
areasRemainingToFill: aRectangle
	"May be overridden by any subclasses with opaque regions"

	^ Array with: aRectangle! !

!Morph methodsFor: 'drawing' stamp: 'jm 10/13/2002 18:24'!
basicFullDrawOn: aCanvas
	"Draw the full Morphic structure on the given Canvas.  This duplicates the implementation of fullDrawOn: (which could invoke this if it cared) but this method is never overridden, so that it can be invoked by subclass implementations of #fullDrawOn: without getting snagged by the complexities of intervening implementations of #fullDrawOn:"

	self isHidden ifTrue: [^ self].
	(self hasProperty: #errorOnDraw) ifTrue: [^ self drawErrorOn: aCanvas].
	aCanvas drawMorph: self.
	self drawSubmorphsOn: aCanvas
! !

!Morph methodsFor: 'drawing' stamp: 'ar 4/2/1999 13:13'!
drawErrorOn: aCanvas
	"The morph (or one of its submorphs) had an error in its drawing method."
	aCanvas
		frameAndFillRectangle: bounds
		fillColor: Color red
		borderWidth: 1
		borderColor: Color yellow.
	aCanvas line: bounds topLeft to: bounds bottomRight width: 1 color: Color yellow.
	aCanvas line: bounds topRight to: bounds bottomLeft width: 1 color: Color yellow.! !

!Morph methodsFor: 'drawing' stamp: 'jm 10/25/2008 16:45'!
drawOn: aCanvas

	color isTransparent ifTrue: [^ self].
	aCanvas fillRectangle: self bounds color: color.
! !

!Morph methodsFor: 'drawing' stamp: 'ar 5/29/1999 05:23'!
drawSubmorphsOn: aCanvas
	"Display submorphs back to front"
	submorphs reverseDo:[:m | aCanvas fullDrawMorph: m].
! !

!Morph methodsFor: 'drawing' stamp: 'sw 10/10/1999 10:23'!
flash
	| c w |
	c _ self color.
	self color: Color black.
	(w _ self world) ifNotNil: [w displayWorldSafely].
	self color: c
! !

!Morph methodsFor: 'drawing' stamp: 'jm 10/13/2002 18:18'!
fullBounds

	fullBounds ifNil: [
		fullBounds _ self bounds.
		submorphs size > 0 ifTrue: [
			submorphs do: [:m |
				m isHidden ifFalse: [
					fullBounds _ fullBounds quickMerge: m fullBounds]]]].
	^ fullBounds
! !

!Morph methodsFor: 'drawing' stamp: 'jm 10/13/2002 19:07'!
fullDrawOn: aCanvas
	"Draw my full Morphic structure on the given Canvas"

	self isHidden ifTrue: [^ self].
	(self hasProperty: #errorOnDraw) ifTrue:[^ self drawErrorOn: aCanvas].
	aCanvas drawMorph: self.
	self drawSubmorphsOn:aCanvas.
! !

!Morph methodsFor: 'drawing' stamp: 'EMP 2/9/2016 16:41'!
handledOwnDraggingBy: t1 on: t2 
	^ false! !

!Morph methodsFor: 'drawing' stamp: 'jm 7/4/2003 10:34'!
imageForm

	^ self imageForm: Display depth forRectangle: self fullBounds
! !

!Morph methodsFor: 'drawing' stamp: 'jm 11/29/2002 10:12'!
imageForm: depth forRectangle: rect

	| canvas |
	canvas _ FormCanvas extent: rect extent depth: depth.
	canvas translateBy: rect topLeft negated during: [:c | self fullDrawOn: c].
	^ canvas form offset: 0@0
! !

!Morph methodsFor: 'drawing' stamp: 'jm 6/7/2004 11:18'!
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
	self drawOn: c.
	morphsToDraw _ submorphs reversed asOrderedCollection.
	(i _ morphsToDraw indexOf: stopMorph) > 0 ifTrue: [
		stopThere
			ifTrue: [morphsToDraw _ morphsToDraw copyFrom: 1 to: i - 1]  "stop at stopMorph"
			ifFalse: [morphsToDraw removeIndex: i]].  "skip stopMorph"
	morphsToDraw do: [:m | m fullDrawOn: c].
	^ c form
! !

!Morph methodsFor: 'drawing' stamp: 'sw 10/10/1999 23:25'!
refreshWorld
	| aWorld |
	(aWorld _ self world) ifNotNil: [aWorld displayWorldSafely]
! !

!Morph methodsFor: 'drawing' stamp: 'jm 11/24/2002 10:49'!
shadowForm
	"Return a form representing the 'shadow' of the receiver - e.g., all pixels that are occupied by the receiver are one, all others are zero."
	| canvas |
	canvas _ (FormCanvas extent: bounds extent depth: 1)
				asShadowDrawingCanvas: Color black. "Color black represents one for 1bpp"
	canvas translateBy: bounds topLeft negated
		during: [:tempCanvas| self fullDrawOn: tempCanvas].
	^ canvas form offset: bounds topLeft
! !


!Morph methodsFor: 'geometry' stamp: 'di 7/24/97 11:55'!
align: aPoint1 with: aPoint2
	"Translate by aPoint2 - aPoint1."

	^ self position: self position + (aPoint2 - aPoint1)! !

!Morph methodsFor: 'geometry'!
bottom

	^ bounds bottom! !

!Morph methodsFor: 'geometry' stamp: 'sw 5/5/1998 01:24'!
bottom: aNumber
	self position: (bounds left @ (aNumber - self height))! !

!Morph methodsFor: 'geometry' stamp: 'tk 9/8/97 10:44'!
bottomLeft

	^ bounds bottomLeft! !

!Morph methodsFor: 'geometry' stamp: 'di 6/12/97 11:17'!
bottomRight

	^ bounds bottomRight! !

!Morph methodsFor: 'geometry' stamp: 'jm 8/3/97 15:50'!
bounds
	"Return the bounds of this morph."
	"Note: It is best not to override this method because many methods in Morph and its subclasses use the instance variable directly rather than 'self bounds'. Instead, subclasses should be sure that the bounds instance variable is correct."

	^ bounds
! !

!Morph methodsFor: 'geometry'!
bounds: newBounds

	self position: newBounds topLeft; extent: newBounds extent! !

!Morph methodsFor: 'geometry' stamp: 'ar 11/15/1998 23:44'!
boundsInWorld

	owner ifNil: [^ bounds].
	^ (owner transformFrom: self world) localBoundsToGlobal: bounds.
! !

!Morph methodsFor: 'geometry'!
center

	^ bounds center! !

!Morph methodsFor: 'geometry' stamp: 'sw 6/11/1999 18:48'!
center: aPoint
	self position: (aPoint - (self extent // 2))! !

!Morph methodsFor: 'geometry' stamp: 'EMP 3/23/2016 11:58'!
emergencyExtent: aPoint
	"Can be called without use of SUPER"
	bounds extent = aPoint ifFalse: [
		self changed.
		bounds _ bounds topLeft extent: aPoint.
		self layoutChanged.
		self changed].
! !

!Morph methodsFor: 'geometry'!
extent

	^ bounds extent! !

!Morph methodsFor: 'geometry' stamp: 'jm 8/24/97 21:27'!
extent: aPoint

	bounds extent = aPoint ifFalse: [
		self changed.
		bounds _ bounds topLeft extent: aPoint.
		self layoutChanged.
		self changed].
! !

!Morph methodsFor: 'geometry' stamp: 'ar 11/15/1998 23:44'!
fullBoundsInWorld

	owner ifNil: [^ self fullBounds].
	^ (owner transformFrom: self world) localBoundsToGlobal: self fullBounds.
! !

!Morph methodsFor: 'geometry'!
height

	^ bounds height! !

!Morph methodsFor: 'geometry' stamp: 'jm 1/29/98 14:26'!
height: aNumber

	self extent: self width@aNumber asInteger.
! !

!Morph methodsFor: 'geometry'!
innerBounds
	"Return the inner rectangle enclosed by the bounds of this morph excluding the space taken by its borders. For an unbordered morph, this is just its bounds."

	^ bounds! !

!Morph methodsFor: 'geometry'!
left

	^ bounds left! !

!Morph methodsFor: 'geometry' stamp: 'sw 5/5/1998 01:22'!
left: aNumber
	self position: (aNumber @ bounds top)! !

!Morph methodsFor: 'geometry'!
minHeight
	"Return the minimum width for this morph. Ordinary morphs just answer their current height."

	^ self fullBounds height
! !

!Morph methodsFor: 'geometry'!
minWidth
	"Return the minimum width for this morph. Ordinary morphs just answer their current width."

	^ self fullBounds width
! !

!Morph methodsFor: 'geometry' stamp: 'sw 6/4/2000 21:59'!
minimumExtent
	| ext |
	"This returns the minimum extent that the morph may be shrunk to.  Not honored in too many places yet, but respected by the resizeToFit feature, at least.  copied up from SystemWindow 6/00"
	(ext _ self valueOfProperty: #minimumExtent)
		ifNotNil:
			[^ ext].
	^ 100 @ 80! !

!Morph methodsFor: 'geometry' stamp: 'EMP 3/23/2016 12:33'!
otherPosition: aPoint
	"Change the position of this morph and and all of its submorphs. Can be used in emer"

	| delta |
	delta _ aPoint - bounds topLeft.
	(delta x = 0 and: [delta y = 0]) ifTrue: [^ self].  "Null change"
	self privateFullMoveBy: delta.! !

!Morph methodsFor: 'geometry' stamp: 'ar 11/15/1998 23:42'!
pointFromWorld: aPoint

	owner ifNil: [^ aPoint].
	^ (owner transformFrom: self world) globalPointToLocal: aPoint.
! !

!Morph methodsFor: 'geometry' stamp: 'ar 11/15/1998 23:43'!
pointInWorld: aPoint

	owner ifNil: [^ aPoint].
	^ (owner transformFrom: self world) localPointToGlobal: aPoint.
! !

!Morph methodsFor: 'geometry'!
position

	^ bounds topLeft! !

!Morph methodsFor: 'geometry' stamp: 'di 4/8/98 20:35'!
position: aPoint
	"Change the position of this morph and and all of its submorphs."

	| delta |
	delta _ aPoint - bounds topLeft.
	(delta x = 0 and: [delta y = 0]) ifTrue: [^ self].  "Null change"
	self changed.
	self privateFullMoveBy: delta.
	self changed.
! !

!Morph methodsFor: 'geometry' stamp: 'di 9/30/1998 12:11'!
positionInWorld

	^ self pointInWorld: self position.
! !

!Morph methodsFor: 'geometry'!
right

	^ bounds right! !

!Morph methodsFor: 'geometry' stamp: 'sw 5/5/1998 01:23'!
right: aNumber
	self position: ((aNumber - bounds width) @ bounds top)! !

!Morph methodsFor: 'geometry' stamp: 'jm 10/15/2002 17:20'!
setConstrainedPositionFrom: aPoint
	"Change the position of this morph and and all of its submorphs to aPoint, but don't let me go outside my owner's bounds."

	| trialRect delta boundingMorph |
	trialRect _ aPoint extent: self bounds extent.
	boundingMorph _ self owner.
	delta _ boundingMorph
			ifNil:    [0@0]
			ifNotNil: [trialRect amountToTranslateWithin: boundingMorph bounds].
	self position: aPoint + delta.
	self layoutChanged  "So that, eg, surrounding text will readjust"
! !

!Morph methodsFor: 'geometry'!
top

	^ bounds top! !

!Morph methodsFor: 'geometry' stamp: 'sw 5/5/1998 01:23'!
top: aNumber
	self position: (bounds left @ aNumber)! !

!Morph methodsFor: 'geometry' stamp: 'di 6/12/97 11:07'!
topLeft

	^ bounds topLeft! !

!Morph methodsFor: 'geometry' stamp: 'sw 8/20/97 23:04'!
topRight

	^ bounds topRight! !

!Morph methodsFor: 'geometry'!
width

	^ bounds width! !

!Morph methodsFor: 'geometry' stamp: 'jm 1/29/98 14:26'!
width: aNumber

	self extent: aNumber asInteger@self height.
! !

!Morph methodsFor: 'geometry' stamp: 'di 2/23/98 11:36'!
worldBounds
	^ self world bounds! !

!Morph methodsFor: 'geometry' stamp: 'sw 4/27/2000 13:53'!
worldBoundsForHalo
	"To restore older behavior, change this to return  self fullBoundsInWorld"

	^ self boundsInWorld
! !


!Morph methodsFor: 'geometry-rotate scale and flex' stamp: 'jm 10/13/2002 19:15'!
addTransparentSpacerOfSize: aPoint

	self addMorphBack:
		((Morph new extent: aPoint) color: Color transparent)
! !

!Morph methodsFor: 'geometry-rotate scale and flex' stamp: 'jm 4/29/1998 11:28'!
referencePosition

	^ bounds center
! !

!Morph methodsFor: 'geometry-rotate scale and flex' stamp: 'jm 5/2/1998 07:16'!
referencePosition: aPosition

	self position: aPosition - (bounds extent // 2).
! !

!Morph methodsFor: 'geometry-rotate scale and flex' stamp: 'sw 10/25/1999 16:49'!
referencePositionInWorld

	^ self pointInWorld: self referencePosition
! !

!Morph methodsFor: 'geometry-rotate scale and flex' stamp: 'sw 10/25/1999 23:33'!
referencePositionInWorld: aPoint
	| localPosition |
	localPosition _ owner
		ifNil: [aPoint]
		ifNotNil: [(owner transformFrom: self world) globalPointToLocal: aPoint].

	self referencePosition: localPosition
! !

!Morph methodsFor: 'geometry-rotate scale and flex' stamp: 'jm 4/25/1998 05:19'!
rotationDegrees
	"Default implementation."

	^ 0.0
! !


!Morph methodsFor: 'geometry-testing'!
containsPoint: aPoint

	^ self bounds containsPoint: aPoint! !

!Morph methodsFor: 'geometry-testing' stamp: 'di 5/3/2000 19:05'!
fullContainsPoint: aPoint

	(self fullBounds containsPoint: aPoint) ifFalse: [^ false].  "quick elimination"
	(self containsPoint: aPoint) ifTrue: [^ true].  "quick acceptance"
	submorphs do: [:m | (m fullContainsPoint: aPoint) ifTrue: [^ true]].
	^ false
! !


!Morph methodsFor: 'dropping/grabbing' stamp: 'jm 3/16/2003 11:03'!
aboutToBeGrabbedBy: aHand
	"The receiver is being grabbed by a hand. Perform necessary adjustments (if any) and return the morph that should be added to the hand. This default implementation just returns the reciver."

	^ self
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'sw 10/18/97 18:03'!
acceptDroppingMorph: aMorph event: evt
	"This message is sent when a morph is dropped onto a morph that has agreed to accept the dropped morph by responding 'true' to the wantsDroppedMorph:Event: message. This default implementation just adds the given morph to the receiver."

	self addMorph: aMorph.
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'jm 6/14/2004 14:00'!
allowSubmorphExtraction
	"Return true if this morph allows its submorphs to be extracted just by grabbing them."

	self isPartsBin ifTrue: [^ false].
	^ self dragNDropEnabled or: [self dragEnabled]
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'EMP 4/27/2016 11:55'!
changed
	"Report that the area occupied by this morph should be redrawn."

	self invalidRect: self fullBounds.
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:50'!
dragEnabled
	"Get this morph's ability to add and remove morphs via drag-n-drop."
	^(self valueOfProperty: #dragEnabled) == true
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:48'!
dragNDropEnabled
	"Get this morph's ability to add and remove morphs via drag-n-drop."
	^(self valueOfProperty: #dragNDropEnabled) == true
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:51'!
dropEnabled
	"Get this morph's ability to add and remove morphs via drag-n-drop."
	^(self valueOfProperty: #dropEnabled) == true
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:50'!
enableDrag: aBoolean
	self setProperty: #dragEnabled toValue: aBoolean! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:54'!
enableDragNDrop: aBoolean
	self enableDrag: aBoolean.
	self enableDrop: aBoolean.
	self setProperty: #dragNDropEnabled toValue: aBoolean! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:51'!
enableDrop: aBoolean
	self setProperty: #dropEnabled toValue: aBoolean! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'sw 10/11/1999 13:20'!
justDroppedInto: aMorph event: anEvent
	"This message is sent to a dropped morph after it has been dropped on--and been accepted by--a drop-sensitive morph"

	| aWindow partsBinCase |
	(partsBinCase _ aMorph isPartsBin) ifFalse:
		[self isPartsDonor: false].
	(aWindow _ aMorph ownerThatIsA: SystemWindow) ifNotNil:
		[aWindow isActive ifFalse:
			[aWindow activate]].
	(self isInWorld and: [partsBinCase not]) ifTrue:
		[self world startSteppingSubmorphsOf: self]  
	"Note an unhappy inefficiency here:  the startStepping... call will often have already been called in the sequence leading up to entry to this method, but unfortunately the isPartsDonor: call often will not have already happened, with the result that the startStepping... call will not have resulted in the startage of the steppage."
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'sw 1/11/1999 20:07'!
repelsMorph: aMorph event: ev
	^ false! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'jm 6/14/2004 14:25'!
rootForGrabOf: aMorph
	"Answer the root of the morph structure to be picked up when the given morph is grabbed."

	(self isSticky and: [self isPartsDonor not])
		ifTrue: [^ nil]
		ifFalse: [
			(owner isNil or: [owner isWorldOrHandMorph])
				ifTrue: [^ self]
				ifFalse: [
					owner allowSubmorphExtraction
						ifTrue: [^ self]
						ifFalse: [^ owner rootForGrabOf: aMorph]]].
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'jm 8/3/2003 10:06'!
slideBackToFormerSituation: evt

	| slideForm formerOwner formerPosition aWorld startPoint endPoint trans |
	(formerOwner _ evt hand formerOwner) ifNil: [^ self].
	formerPosition _ evt hand formerPosition.
	aWorld _ self world.

	trans _ formerOwner transformFromWorld.
	slideForm _ self imageForm offset: 0@0.

	startPoint _ evt hand fullBounds origin.
	endPoint _ trans localPointToGlobal: formerPosition.
	owner privateRemoveMorph: self.
	aWorld displayWorld.
	slideForm slideFrom: startPoint to: endPoint nSteps: 12 delay: 15.
	formerOwner addMorph: self.
	self position: formerPosition.
	self justDroppedInto: formerOwner event: evt.
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:46'!
toggleDragNDrop
	"Toggle this morph's ability to add and remove morphs via drag-n-drop."

		self enableDragNDrop: self dragNDropEnabled not.
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'jm 7/3/2004 19:22'!
vanishAfterSlidingTo: aPosition event: evt

	| aForm aWorld startPoint endPoint |
	aForm _ self imageForm offset: 0@0.
	aWorld _ self world.
	startPoint _ evt hand fullBounds origin.
	self delete.
	aWorld ifNil: [^ self].
	aWorld displayWorld.
	endPoint _ aPosition.
	aForm slideFrom: startPoint  to: endPoint nSteps: 12 delay: 15.
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/28/2000 10:51'!
wantsDroppedMorph: aMorph event: evt
	"Return true if the receiver wishes to accept the given morph, which is being dropped by a hand in response to the given event. The default implementation returns false.
NOTE: the event is assumed to be in global (world) coordinates."

	^self dragNDropEnabled
		or: [self dropEnabled]! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'jm 7/1/2004 22:27'!
willingToBeEmbeddedUponLanding
	"Answer whether the receiver, when dropped over a container that is open to drag-and-drop, is eager to be embedded in the it.  SystemWindows and MenuMorphs are examples of morphs that are reluctant in this regard."
	
	^ true
! !


!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:21'!
click: evt
	"Handle a single-click event. This message is only sent to clients that request it by sending #waitForClicksOrDrag:event: to the initiating hand in their mouseDown: method. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 12/7/2005 09:49'!
cursorPoint

	^ self currentWorld activeHand lastEvent cursorPoint
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:22'!
doubleClick: evt
	"Handle a double-click event. This message is only sent to clients that request it by sending #waitForClicksOrDrag:event: to the initiating hand in their mouseDown: method. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:24'!
handlesMouseDown: evt
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ false
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:32'!
handlesMouseOver: evt
	"Return true if I want to receive mouseEnter: and mouseLeave: when the button is up and the hand is empty. The default response is false; subclasses that implement mouse mouseEnter messages should override this to return true." 

	^ false
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:31'!
handlesMouseOverDragging: evt
	"Return true if I want to receive mouseEnterDragging: and mouseLeaveDragging: when the hand drags something over me (button up or button down), or when the mouse button is down but there is no mouseDown recipient. The default response is false; subclasses that implement mouse mouseEnterDragging messages should override this to return true."

	"NOTE:  If the hand state matters in these cases, it may be tested by constructs such as
		event anyButtonPressed
		event hand hasSubmorphs"

	^ false
! !

!Morph methodsFor: 'event handling' stamp: 'sw 4/2/98 14:16'!
hasFocus
	^ false! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:25'!
keyStroke: anEvent
	"Handle a keystroke event. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 11/1/2002 10:45'!
keyboardFocusChange: aBoolean
	"The message is sent to a morph when its keyboard focus change. The argument is true if the receiver is gaining (versus losing) the keyboard focus. Morphs that accept keystrokes should change their appearance in some way when they are the current keyboard focus. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:25'!
mouseDown: evt
	"Handle a mouse down event. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:26'!
mouseEnter: evt
	"Handle a mouseEnter event. The mouse just entered my bounds with no button pressed. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:26'!
mouseEnterDragging: evt
	"Handle a mouseEnterDragging event. The mouse just entered my bounds with a button pressed or laden with submorphs. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 12/19/2008 17:18'!
mouseHold: evt
	"Handle a hold event, triggered by pressing and holding down the mouse without moving the mouse for the duration of a double click. This message is only sent to clients that request it by sending #waitForClicksOrDrag:event: to the initiating hand in their mouseDown: method. This default implementation treats a hold as a drag."

	self startDrag: evt.
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:27'!
mouseLeave: evt
	"Handle a mouseLeave event. The mouse just left my bounds with no button pressed. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:27'!
mouseLeaveDragging: evt
	"Handle a mouseLeaveLaden event. The mouse just left my bounds with a button pressed or laden with submorphs. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:28'!
mouseMove: evt
	"Handle a mouse move event as part of the sequence mouseDown, mouseMove(s), mouseUp. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:29'!
mouseUp: evt
	"Handle a mouse up event. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'sw 8/11/97 18:36'!
preemptsMouseDown: evt
	"Return true if this morph wants to handle mouse down events even when the mouse is pressed over a submorph that also wishes to handle mouse down events. Responding true to this message allows a morph to reverse the normal policy that control is given to the inner-most submorph that wants it. This can be used, for example, to allow buttons in a parts bin to be copied when clicked, instead of being activated."

	^ self isPartsDonor
! !

!Morph methodsFor: 'event handling' stamp: 'jm 7/1/2004 23:02'!
startDrag: evt
	"Handle a drag event. This message is only sent to clients that request it by sending #waitForClicksOrDrag:event: to the initiating hand in their mouseDown: method. This default implementation grabs me."

	| frontM rootForGrab |
	frontM _ (self unlockedMorphsAt: evt cursorPoint) first.
	rootForGrab _ frontM rootForGrabOf: frontM.
	rootForGrab ifNil: [^ self].
	rootForGrab position: rootForGrab position + (evt hand position - evt cursorPoint).
	evt hand grabMorph: rootForGrab.
! !

!Morph methodsFor: 'event handling'!
transformFrom: uberMorph
	"Return a transform to be used to map coordinates in a morph above me into my local coordinates, or vice-versa. This is used to support scrolling, scaling, and/or rotation. This default implementation just returns my owner's transform or the identity transform if my owner is nil."

	owner == uberMorph ifTrue: [^ MorphicTransform identity].
	owner ifNil: [^ MorphicTransform identity].
	^ owner transformFrom: uberMorph
! !

!Morph methodsFor: 'event handling'!
transformFromWorld
	"Return a transform to map world coordinates into my local coordinates"

	^ self transformFrom: nil! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/2/2006 15:45'!
wantsKeyboardFocusFor: aSubmorph
	"Answer whether a mouse click on aSubmorph, a text-edit-capable thing, should result in a text selection there."

	owner ifNotNil: [^ owner wantsKeyboardFocusFor: aSubmorph].
	^ aSubmorph wouldAcceptKeyboardFocus
! !

!Morph methodsFor: 'event handling' stamp: 'sw 5/6/1998 12:54'!
wouldAcceptKeyboardFocus
	"Answer whether a plain mouse click on the receiver should result in a text selection there"
	^ false! !


!Morph methodsFor: 'naming' stamp: 'jm 10/13/2002 20:07'!
externalName

	^ self valueOfProperty: #externalName ifAbsent: [self innocuousName]
! !

!Morph methodsFor: 'naming' stamp: 'jm 10/7/2002 07:22'!
innocuousName
	"Choose an innocuous name for the receiver -- one that does not end in the word Morph"

	| myName |
	myName _ self class name asString copy.
	(myName size > 5 and: [myName endsWith: 'Morph'])
		ifTrue: [^ myName copyFrom: 1 to: myName size - 5]
		ifFalse: [^ myName].
! !

!Morph methodsFor: 'naming' stamp: 'sw 11/3/97 01:57'!
name: aName
	(aName isKindOf: String) ifTrue:
		[self setNameTo: aName]! !

!Morph methodsFor: 'naming' stamp: 'jm 10/13/2002 20:54'!
setNameTo: aName

	self setProperty: #externalName toValue: aName asString.
! !


!Morph methodsFor: 'stepping and presenter'!
startStepping
	"Start getting sent the 'step' message."

	| w |
	self step.  "one to get started!!"
	w _ self world.
	w ifNotNil: [
		w startStepping: self.
		self changed].! !

!Morph methodsFor: 'stepping and presenter' stamp: 'jm 10/7/2002 07:39'!
step
	"Do some periodic activity. Use startStepping/stopStepping to start and stop getting sent this message. The time between steps is specified by this morph's answer to the stepTime message. This default implementation does nothing."
! !

!Morph methodsFor: 'stepping and presenter' stamp: 'EMP 1/6/2016 14:41'!
stepAt: millisecondClockValue
	"Do some periodic activity. Use startStepping/stopStepping to start and stop getting sent this message. The time between steps is specified by this morph's answer to the stepTime message.
	The millisecondClockValue parameter gives the value of the millisecond clock at the moment of dispatch.
	Default is to dispatch to the parameterless step method for the morph, but this protocol makes it possible for some morphs to do differing things depending on the clock value"
	
	self step


"0.035 for speed test when timer > than"
! !

!Morph methodsFor: 'stepping and presenter' stamp: 'jm 10/7/2002 07:40'!
stepTime
	"Answer the desired time between steps in milliseconds. This default implementation requests that the 'step' method be called once every second."

	^1000
! !

!Morph methodsFor: 'stepping and presenter'!
stopStepping
	"Stop getting sent the 'step' message."

	| w |
	w _ self world.
	w ifNotNil: [
		w stopStepping: self.
		self changed].
! !

!Morph methodsFor: 'stepping and presenter' stamp: 'jm 10/7/2002 07:40'!
wantsSteps
	"Return true if the receiver overrides the default Morph step method."
	"Details: Find the first class in superclass chain that implements #step and return true if it isn't class Morph."

	| c |
	self isPartsDonor ifTrue: [^ false].
	c _ self class.
	[c includesSelector: #step] whileFalse: [c _ c superclass].
	^ c ~= Morph
! !


!Morph methodsFor: 'menus' stamp: 'jm 1/24/2004 19:14'!
addAddHandMenuItemsForHalo: aMenu hand: aHandMorph
	"Add halo menu items to be handled by the invoking hand. The halo menu is invoked by clicking on the menu-handle of the receiver's halo."

	aMenu addLine.
	self owner isWorldMorph ifTrue:
		[aMenu add: #collapse target: self action: #collapse].

	aMenu add: 'copy to paste buffer' action: #copyToPasteBuffer.
	aMenu add: 'change color...' target: self action: #changeColor.
	aMenu add: 'center in owner' target: self action: #centerInOwner.
	aMenu addLine.

	aHandMorph potentialEmbeddingTargets size > 1 ifTrue:
		[aMenu add: 'embed...' action: #placeArgumentIn].

	aMenu defaultTarget: self.
	(owner == nil) ifFalse: [
		aMenu add: 'send to back' action: #goBehind.
		aMenu add: 'bring to front' action: #comeToFront].
	aMenu addLine.

	aMenu defaultTarget: aHandMorph.
! !

!Morph methodsFor: 'menus' stamp: 'jm 3/20/2003 21:35'!
addCustomMenuItems: aCustomMenu hand: aHandMorph
	"Add morph-specific items to the given menu which was invoked by the given hand."

	Preferences noviceMode ifFalse:
		[self addDebuggingItemsTo: aCustomMenu hand: aHandMorph].
! !

!Morph methodsFor: 'menus' stamp: 'jm 1/24/2004 19:09'!
centerInOwner

	owner ifNil: [^ self].
	self left: owner left + ((owner width - self width) // 2).
! !

!Morph methodsFor: 'menus' stamp: 'di 9/3/1999 10:17'!
changeColor

	ColorPickerMorph new
		sourceHand: self activeHand;
		target: self;
		selector: #color:;
		originalColor: self color;
		addToWorld: self world
			near: self fullBounds! !

!Morph methodsFor: 'menus' stamp: 'sw 2/21/2000 15:21'!
collapse
	CollapsedMorph new beReplacementFor: self! !

!Morph methodsFor: 'menus' stamp: 'jm 12/7/2005 09:49'!
inspectInMorphic

	self currentWorld activeHand
		attachMorph: ((Inspector openAsMorphOn: self) extent: 300@200).
! !


!Morph methodsFor: 'halos and balloon help' stamp: 'jm 5/19/2009 13:13'!
addHalo: evt

	| halo |
	self world ifNil: [^ self].
	halo _ HaloMorph new bounds: self worldBoundsForHalo.
	self world addMorphFront: halo.
	halo target: self.
	halo startStepping.
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'jm 10/11/2002 15:54'!
addHandlesTo: aHaloMorph box: box

	aHaloMorph haloBox: box.
	Preferences haloSpecifications do: [:aSpec |
		aHaloMorph perform: aSpec addHandleSelector with: aSpec].
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'sma 12/23/1999 14:11'!
balloonColor
	^ Display depth <= 2
		ifTrue: [Color white]
		ifFalse: [Color r: 1.0 g: 1.0 b: 0.6]! !

!Morph methodsFor: 'halos and balloon help' stamp: 'jm 9/30/2003 00:18'!
comeToFrontAndAddHalo

	self comeToFront.
	self addHalo: nil.
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'sw 1/11/2000 18:24'!
defersHaloOnClickTo: aSubMorph
	"If a cmd-click on aSubMorph would make it a preferred recipient of the halo, answer true"
	"May want to add a way (via a property) for morphs to assert true here -- this would let certain kinds of morphs that are unusually reluctant to take the halo on initial click"

	^ false
	! !

!Morph methodsFor: 'halos and balloon help' stamp: 'jm 4/24/2008 20:14'!
deleteBalloon
	"If I am showing a balloon, delete it."

	| balloon |
	ScratchToolTipMorph clearToolTips.

	(balloon _ self valueOfProperty: #balloon) ifNil: [^ self].
	balloon delete.
	self setProperty: #balloon toValue: nil.
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'jm 10/8/2002 08:53'!
mouseDownOnHelpHandle: anEvent
	"The mouse went down in the show-balloon handle"
	
	| str |
	str _ self balloonText.
	str ifNil: [str _ self noHelpString].
	self showBalloon: str
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'sw 9/19/97 13:46'!
noHelpString
	^ 'Help not yet supplied'! !

!Morph methodsFor: 'halos and balloon help' stamp: 'sw 12/30/1999 19:51'!
seeksOutHalo
	"Answer whether the receiver is an eager recipient of the halo"
	^ true! !

!Morph methodsFor: 'halos and balloon help' stamp: 'jm 4/17/2008 10:49'!
setBalloonText: aString
	"Set receiver's balloon help string. Pass nil to remove the help."

	aString
		ifNil: [self removeProperty: #balloonText]
		ifNotNil: [self setProperty: #balloonText toValue: aString].
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'jm 4/24/2008 16:11'!
showBalloon: msg

	| w worldBounds tooltip |
	w _ self world.
	tooltip _ (ScratchToolTipMorph string: msg for: self).
	w addMorphFront: (tooltip position: self bottomLeft + (0@8)).
	((worldBounds _ w bounds) containsRect: tooltip bounds) ifFalse:
		[tooltip bounds: (tooltip bounds translatedToBeWithin: worldBounds)].! !

!Morph methodsFor: 'halos and balloon help' stamp: 'sma 12/23/1999 13:24'!
wantsBalloon
	"Answer true if receiver wants to show a balloon help text is a few moments." 

	^ self balloonText notNil! !

!Morph methodsFor: 'halos and balloon help' stamp: 'sw 1/25/2000 17:43'!
wantsHaloFromClick
	^ true! !


!Morph methodsFor: 'change reporting' stamp: 'jm 10/13/2002 20:51'!
invalidRect: damageRect

	owner ifNotNil: [owner invalidRect: damageRect].
! !

!Morph methodsFor: 'change reporting' stamp: 'jm 5/14/2008 13:50'!
layoutChanged
	"Note that something has changed about the size, shape, or location of the receiver or one of its submorphs, so that fullBounds must be recomputed."

	fullBounds _ nil.
	owner ifNotNil: [owner layoutChanged].
"xxx
	submorphs size > 0 ifTrue:
		['Let submorphs know about a change above'
		submorphs do: [:m | m ownerChanged]].
xxx"
! !

!Morph methodsFor: 'change reporting' stamp: 'jm 7/24/2003 18:06'!
mayNeedLayout
	"Answer true if something has occured that might require my layout to change That is, if layoutChanged has been sent to me or any of my submorphs."

	^ fullBounds isNil
! !

!Morph methodsFor: 'change reporting' stamp: 'jm 10/12/2005 11:13'!
ownerChanged
	"This default implementation does nothing."
! !


!Morph methodsFor: 'e-toy support' stamp: 'jm 10/13/2002 11:22'!
adaptToWorld: aWorld
	"The receiver finds itself operating in a possibly-different new world.  If any of the receiver's parts are world-dependent (such as a target of a SimpleButtonMorph, etc.), then have them adapt accordingly"

	submorphs do: [:m | m adaptToWorld: aWorld].
! !

!Morph methodsFor: 'e-toy support'!
asNumber: aPointOrNumber
	"Support for e-toy demo."

	aPointOrNumber class = Point
		ifTrue: [^ aPointOrNumber r]
		ifFalse: [^ aPointOrNumber].
! !

!Morph methodsFor: 'e-toy support' stamp: 'sw 5/23/2000 03:42'!
containingWindow
	^ self ownerThatIsA: SystemWindow! !

!Morph methodsFor: 'e-toy support' stamp: 'sw 10/26/1999 23:32'!
embeddedInMorphicWindowLabeled: labelString
	| window |
	window _ (SystemWindow labelled: labelString) model: nil.
	window setStripeColorsFrom: nil defaultBackgroundColor.
	window addMorph: self frame: (0@0 extent: 1@1).
	^ window! !

!Morph methodsFor: 'e-toy support' stamp: 'tk 9/3/1999 11:46'!
wrappedInWindowWithTitle: aTitle
	| aWindow |
	aWindow _ (SystemWindow labelled: aTitle) model: Model new.
	aWindow addMorph: self frame: (0@0 extent: 1@1).
	aWindow extent: self extent + (2 @ 18).
	^ aWindow! !


!Morph methodsFor: 'parts bin' stamp: 'di 8/11/1998 12:48'!
inPartsBin
	| o |
	self isPartsDonor ifTrue: [^ true].

	o _ self owner.
	[o == nil] whileFalse:
		[o isPartsBin ifTrue: [^ true].
		o _ o owner].
	^ false
! !

!Morph methodsFor: 'parts bin' stamp: 'sw 8/12/97 14:16'!
isPartsBin
	^ false! !


!Morph methodsFor: 'printing' stamp: 'jm 7/25/2006 11:51'!
printOn: aStream

	| m |
	super printOn: aStream.

	(m _ self findA: StringMorph) ifNil: [
		aStream nextPutAll: '()'.
		^ self].

	aStream nextPutAll: '('.
	m ifNotNil: [aStream print: m contents; space]. 
	aStream print: self identityHash; nextPutAll: ')'.
! !

!Morph methodsFor: 'printing' stamp: 'jm 5/28/1998 18:00'!
printStructureOn: aStream indent: tabCount

	tabCount timesRepeat: [aStream tab].
	self printOn: aStream.
	aStream cr.
	self submorphsDo: [:m | m printStructureOn: aStream indent: tabCount + 1].
! !

!Morph methodsFor: 'printing' stamp: 'jm 5/28/1998 17:58'!
structureString
	"Return a string that showing this morph and all its submorphs in an indented list that reflects its structure."

	| s |
	s _ WriteStream on: (String new: 1000).
	self printStructureOn: s indent: 0.
	^ s contents
! !


!Morph methodsFor: 'caching' stamp: 'jm 10/13/2002 20:51'!
releaseCachedState
	"Release any state that can be recomputed on demand, such as the pixel values for a color gradient or the editor state for a TextMorph. This method may be called to save space when a morph becomes inaccessible. Implementations of this method should do 'super releaseCachedState'."
! !


!Morph methodsFor: 'debug and other' stamp: 'sw 10/21/1998 09:29'!
addDebuggingItemsTo: aMenu hand: aHandMorph
	aMenu add: 'debug...' subMenu:  (self debuggingMenuFor: aHandMorph)! !

!Morph methodsFor: 'debug and other' stamp: 'jm 12/9/2003 09:13'!
debuggingMenuFor: aHandMorph

	| aMenu |
	aMenu _ MenuMorph new defaultTarget: self.
	aMenu addStayUpItem.
	(self hasProperty: #errorOnDraw) ifTrue: [
		aMenu add: 'start drawing again' action: #resumeAfterDrawError.
		aMenu addLine].
	(self hasProperty: #errorOnStep) ifTrue: [
		aMenu add: 'start stepping again' action: #resumeAfterStepError.
		aMenu addLine].

	aMenu add: 'inspect morph' action: #inspectInMorphic.
	Smalltalk isMorphic ifFalse:
		[aMenu add: 'inspect morph (in MVC)' action: #inspect].
 	aMenu addLine.

	aMenu add: 'browse morph class' target: self selector: #browseHierarchy.
	aMenu add: 'make own subclass' target: aHandMorph action: #subclassMorph.
	aMenu addLine.

	aMenu add: 'control-menu...' target: aHandMorph selector: #invokeMetaMenuFor: argument: self.

	^ aMenu
! !

!Morph methodsFor: 'debug and other' stamp: 'ar 4/2/1999 15:11'!
resumeAfterDrawError
	self changed.
	self removeProperty:#errorOnDraw.
	self changed.! !

!Morph methodsFor: 'debug and other' stamp: 'ar 4/2/1999 15:22'!
resumeAfterStepError
	"Resume stepping after an error has occured."
	self startStepping. "Will #step"
	self removeProperty:#errorOnStep. "Will remove prop only if #step was okay"
! !


!Morph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 15:37'!
fieldsVersion

	^ 1
! !

!Morph methodsFor: 'object i/o' stamp: 'jm 9/28/2003 18:23'!
initFieldsFrom: anObjStream version: classVersion
	"Set my instance variables from the given object stream."

	self initFieldsNamed: #(
		bounds
		owner
		submorphs
		color
		flags
	) from: anObjStream.
	anObjStream nextField.  "placeholder for properties"
	fullBounds _ nil.
! !

!Morph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 15:32'!
storeFieldsOn: anObjStream

	self storeFieldsNamed: #(
		bounds
		owner
		submorphs
		color
		flags
	) on: anObjStream.
	anObjStream putField: nil.  "placeholder for properties"
! !


!Morph methodsFor: 'private'!
privateBounds: boundsRect
	"Private!! Use position: and/or extent: instead."

	fullBounds _ nil.
	bounds _ boundsRect.! !

!Morph methodsFor: 'private' stamp: 'jm 5/29/1998 21:28'!
privateColor: aColor

	color _ aColor.
! !

!Morph methodsFor: 'private' stamp: 'jm 7/8/97 08:32'!
privateFullMoveBy: delta
	"Private!! Relocate me and all of my subMorphs by recursion. Subclasses that implement different coordinate systems may override this method."

	self privateMoveBy: delta.
	1 to: submorphs size do: [:i |
		(submorphs at: i) privateFullMoveBy: delta].
! !

!Morph methodsFor: 'private' stamp: 'jm 10/9/2002 05:37'!
privateMoveBy: delta
	"Private!! Use 'position:' instead."

	fullBounds == bounds
		ifTrue: ["optimization: avoids recomputing fullBounds"
			fullBounds _ bounds _ bounds translateBy: delta]
		ifFalse: [
			bounds _ bounds translateBy: delta.
			fullBounds _ nil].
! !

!Morph methodsFor: 'private'!
privateOwner: aMorph
	"Private!! Should only be used by methods that maintain the ower/submorph invariant."

	owner _ aMorph.! !

!Morph methodsFor: 'private' stamp: 'jm 10/13/2002 21:22'!
privateProperties: aMorphPropertyOrNil
	"Private!! Used when copying."

	properties _ aMorphPropertyOrNil.
! !

!Morph methodsFor: 'private'!
privateRemoveMorph: aMorph
	"Private!! Should only be used by methods that maintain the ower/submorph invariant."

	aMorph changed.
	submorphs _ submorphs copyWithout: aMorph.
	self layoutChanged.
! !

!Morph methodsFor: 'private'!
privateSubmorphs: aCollection
	"Private!! Should only be used by methods that maintain the ower/submorph invariant."

	submorphs _ aCollection.! !


!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 17:50'!
getFlag: maskInteger
	"Return the boolean flag for the given mask. The maskInteger is assumed to be an integer with only a single bit set, the bit corresponding to the flag to be read."

	^ (flags bitAnd: maskInteger) ~= 0
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:25'!
isHidden

	^ self getFlag: HiddenFlag
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/31/2002 10:18'!
isHidden: aBoolean

	self setFlag: HiddenFlag to: aBoolean.
	self changed.
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:29'!
isLocked

	^ self getFlag: LockedFlag
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:27'!
isLocked: aBoolean

	self setFlag: LockedFlag to: aBoolean.
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:29'!
isPartsDonor

	^ self getFlag: PartsDonorFlag
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/14/2002 08:54'!
isPartsDonor: aBoolean

	self setFlag: PartsDonorFlag to: aBoolean.
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:29'!
isSticky

	^ self getFlag: StickyFlag
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/14/2002 08:54'!
isSticky: aBoolean

	self setFlag: StickyFlag to: aBoolean.
! !

!Morph methodsFor: 'flags' stamp: 'jm 6/2/2009 11:42'!
isVisible

	^ self isHidden not
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:27'!
lock

	self isLocked: true.
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 17:49'!
setFlag: maskInteger to: aBoolean
	"Set the given flag bit to the given boolean value (false = 0, true = 1). The maskInteger is assumed to be an integer with only as single bit set, the bit corresponding to the flag to be modified."
	"Details: Morphs have a number of boolean properties that are most efficiently stored as a bit-vector packed into a single 31-bit Squeak SmallInteger."

	aBoolean
		ifTrue: [flags _ flags bitOr: maskInteger]
		ifFalse: [flags _ flags bitAnd: maskInteger bitInvert].
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:07'!
toggleStickiness

	self isSticky: self isSticky not.
! !


!Morph methodsFor: 'dropping/grabbing' stamp: 'jm 3/16/2003 11:03'!
aboutToBeGrabbedBy: aHand
	"The receiver is being grabbed by a hand. Perform necessary adjustments (if any) and return the morph that should be added to the hand. This default implementation just returns the reciver."

	^ self
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'sw 10/18/97 18:03'!
acceptDroppingMorph: aMorph event: evt
	"This message is sent when a morph is dropped onto a morph that has agreed to accept the dropped morph by responding 'true' to the wantsDroppedMorph:Event: message. This default implementation just adds the given morph to the receiver."

	self addMorph: aMorph.
! !

!Morph methodsFor: 'structure' stamp: 'jm 12/7/2005 09:29'!
activeHand

	^ (self world ifNil: [^ nil]) activeHand
! !

!Morph methodsFor: 'e-toy support' stamp: 'jm 10/13/2002 11:22'!
adaptToWorld: aWorld
	"The receiver finds itself operating in a possibly-different new world.  If any of the receiver's parts are world-dependent (such as a target of a SimpleButtonMorph, etc.), then have them adapt accordingly"

	submorphs do: [:m | m adaptToWorld: aWorld].
! !

!Morph methodsFor: 'menus' stamp: 'jm 1/24/2004 19:14'!
addAddHandMenuItemsForHalo: aMenu hand: aHandMorph
	"Add halo menu items to be handled by the invoking hand. The halo menu is invoked by clicking on the menu-handle of the receiver's halo."

	aMenu addLine.
	self owner isWorldMorph ifTrue:
		[aMenu add: #collapse target: self action: #collapse].

	aMenu add: 'copy to paste buffer' action: #copyToPasteBuffer.
	aMenu add: 'change color...' target: self action: #changeColor.
	aMenu add: 'center in owner' target: self action: #centerInOwner.
	aMenu addLine.

	aHandMorph potentialEmbeddingTargets size > 1 ifTrue:
		[aMenu add: 'embed...' action: #placeArgumentIn].

	aMenu defaultTarget: self.
	(owner == nil) ifFalse: [
		aMenu add: 'send to back' action: #goBehind.
		aMenu add: 'bring to front' action: #comeToFront].
	aMenu addLine.

	aMenu defaultTarget: aHandMorph.
! !

!Morph methodsFor: 'submorphs-add/remove'!
addAllMorphs: aCollection

	aCollection do: [:m |
		m owner ifNotNil: [m owner privateRemoveMorph: m].
		m layoutChanged.
		m privateOwner: self].
	submorphs _ submorphs, aCollection.
	self layoutChanged.
! !

!Morph methodsFor: 'menus' stamp: 'jm 3/20/2003 21:35'!
addCustomMenuItems: aCustomMenu hand: aHandMorph
	"Add morph-specific items to the given menu which was invoked by the given hand."

	Preferences noviceMode ifFalse:
		[self addDebuggingItemsTo: aCustomMenu hand: aHandMorph].
! !

!Morph methodsFor: 'debug and other' stamp: 'sw 10/21/1998 09:29'!
addDebuggingItemsTo: aMenu hand: aHandMorph
	aMenu add: 'debug...' subMenu:  (self debuggingMenuFor: aHandMorph)! !

!Morph methodsFor: 'halos and balloon help' stamp: 'jm 5/19/2009 13:13'!
addHalo: evt

	| halo |
	self world ifNil: [^ self].
	halo _ HaloMorph new bounds: self worldBoundsForHalo.
	self world addMorphFront: halo.
	halo target: self.
	halo startStepping.
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'jm 10/11/2002 15:54'!
addHandlesTo: aHaloMorph box: box

	aHaloMorph haloBox: box.
	Preferences haloSpecifications do: [:aSpec |
		aHaloMorph perform: aSpec addHandleSelector with: aSpec].
! !

!Morph methodsFor: 'submorphs-add/remove'!
addMorph: aMorph

	self addMorphFront: aMorph.! !

!Morph methodsFor: 'submorphs-add/remove'!
addMorphBack: aMorph

	aMorph owner ifNotNil: [aMorph owner privateRemoveMorph: aMorph].
	aMorph layoutChanged.
	aMorph privateOwner: self.
	submorphs _ submorphs copyWith: aMorph.
	aMorph changed.  "need to paint morphs now front, if any"
	self layoutChanged.
! !

!Morph methodsFor: 'submorphs-add/remove'!
addMorphCentered: aMorph

	self addMorphFront: aMorph.
	aMorph position: bounds center - (aMorph extent // 2)! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'jm 5/29/1998 15:39'!
addMorphFront: aMorph

	| newSubmorphs |
	aMorph owner ifNotNil: [aMorph owner privateRemoveMorph: aMorph].
	aMorph layoutChanged.
	aMorph privateOwner: self.
	newSubmorphs _ submorphs species new: submorphs size + 1.
	newSubmorphs at: 1 put: aMorph.
	newSubmorphs
		replaceFrom: 2
		to: newSubmorphs size
		with: submorphs
		startingAt: 1.
	submorphs _ newSubmorphs.
	aMorph changed.
	self layoutChanged.
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'ar 11/15/1998 23:42'!
addMorphFront: aMorph fromWorldPosition: wp

	self addMorphFront: aMorph.
	aMorph position: (self transformFromWorld globalPointToLocal: wp)! !

!Morph methodsFor: 'geometry-rotate scale and flex' stamp: 'jm 10/13/2002 19:15'!
addTransparentSpacerOfSize: aPoint

	self addMorphBack:
		((Morph new extent: aPoint) color: Color transparent)
! !

!Morph methodsFor: 'geometry' stamp: 'di 7/24/97 11:55'!
align: aPoint1 with: aPoint2
	"Translate by aPoint2 - aPoint1."

	^ self position: self position + (aPoint2 - aPoint1)! !

!Morph methodsFor: 'submorphs-accessing'!
allMorphs
	"Return a collection containing all morphs in this composite morph (including the receiver)."

	| all |
	all _ OrderedCollection new: 100.
	self allMorphsDo: [: m | all add: m].
	^ all! !

!Morph methodsFor: 'submorphs-accessing'!
allMorphsDo: aBlock
	"Evaluate the given block for all morphs in this composite morph (including the receiver)."

	submorphs size > 0 ifTrue: [
		submorphs do: [:m | m allMorphsDo: aBlock].
	].
	aBlock value: self.
! !

!Morph methodsFor: 'structure' stamp: 'jm 12/21/2004 12:15'!
allOwners
	"Answer a collection of all my owners from the root of the morph structure down to my immediate owner. The root will be the first element."

	| result m |
	result _ OrderedCollection new.

	m _ owner.
	[m == nil] whileFalse: [
		result addFirst: m.
		m _ m owner].
	^ result asArray
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'jm 6/14/2004 14:00'!
allowSubmorphExtraction
	"Return true if this morph allows its submorphs to be extracted just by grabbing them."

	self isPartsBin ifTrue: [^ false].
	^ self dragNDropEnabled or: [self dragEnabled]
! !

!Morph methodsFor: 'drawing' stamp: 'di 6/24/1998 14:10'!
areasRemainingToFill: aRectangle
	"May be overridden by any subclasses with opaque regions"

	^ Array with: aRectangle! !

!Morph methodsFor: 'e-toy support'!
asNumber: aPointOrNumber
	"Support for e-toy demo."

	aPointOrNumber class = Point
		ifTrue: [^ aPointOrNumber r]
		ifFalse: [^ aPointOrNumber].
! !

!Morph methodsFor: 'accessing' stamp: 'jm 3/3/2008 23:19'!
backgroundColor
	"Answer the background color for this morph, taken to be color of the first owner that is not transparent. Note that this does not take sibling morphs into account."

	| m |
	m _ owner.
	[m notNil] whileTrue: [
		(m isKindOf: SystemWindow) ifTrue: [^ Color transparent].
		m color isTransparent ifFalse: [^ m color].
		m _ m owner].

	^ m ifNil: [Color white] ifNotNil: [m color].
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'sma 12/23/1999 14:11'!
balloonColor
	^ Display depth <= 2
		ifTrue: [Color white]
		ifFalse: [Color r: 1.0 g: 1.0 b: 0.6]! !

!Morph methodsFor: 'accessing' stamp: 'jm 8/11/2003 21:09'!
balloonHelpTextFor: aSelector

	#(	(chooseEmphasisOrAlignment				'Emphasis & alignment')
		(chooseFont								'Change font')
		(chooseStyle								'Change style')
		(dismiss									'Remove')
		(doDebug:with:							'Debug')
		(doDirection:with:						'Choose forward direction')
		(doDup:with:							'Duplicate')
		(doMenu:with:							'Menu')
		(doGrab:with:							'Pick up')
		(doRecolor:with:							'Change color')
		(editDrawing							'Repaint')
		(maybeDoDup:with:						'Duplicate')
		(mouseDownInDimissHandle:with:			'Delete')
		(mouseDownInCollapseHandle:with:		'Collapse morph')
		(mouseDownOnHelpHandle:				'Help')
		(prepareToTrackCenterOfRotation:with:	'Set center of rotation')
		(startDrag:with:							'Move')
		(startGrow:with:							'Change size') 
		(trackCenterOfRotation:with:				'Set center of rotation')
	)  do: [:pair |
		aSelector = pair first ifTrue: [^ pair last]].

	^ aSelector asString  "this is best we can do; gives some information at least"

! !

!Morph methodsFor: 'accessing' stamp: 'jm 10/13/2002 20:09'!
balloonText
	"Answer balloon help text or nil, if no help is available."

	^ self valueOfProperty: #balloonText
! !

!Morph methodsFor: 'drawing' stamp: 'jm 10/13/2002 18:24'!
basicFullDrawOn: aCanvas
	"Draw the full Morphic structure on the given Canvas.  This duplicates the implementation of fullDrawOn: (which could invoke this if it cared) but this method is never overridden, so that it can be invoked by subclass implementations of #fullDrawOn: without getting snagged by the complexities of intervening implementations of #fullDrawOn:"

	self isHidden ifTrue: [^ self].
	(self hasProperty: #errorOnDraw) ifTrue: [^ self drawErrorOn: aCanvas].
	aCanvas drawMorph: self.
	self drawSubmorphsOn: aCanvas
! !

!Morph methodsFor: 'geometry'!
bottom

	^ bounds bottom! !

!Morph methodsFor: 'geometry' stamp: 'sw 5/5/1998 01:24'!
bottom: aNumber
	self position: (bounds left @ (aNumber - self height))! !

!Morph methodsFor: 'geometry' stamp: 'tk 9/8/97 10:44'!
bottomLeft

	^ bounds bottomLeft! !

!Morph methodsFor: 'geometry' stamp: 'di 6/12/97 11:17'!
bottomRight

	^ bounds bottomRight! !

!Morph methodsFor: 'geometry' stamp: 'jm 8/3/97 15:50'!
bounds
	"Return the bounds of this morph."
	"Note: It is best not to override this method because many methods in Morph and its subclasses use the instance variable directly rather than 'self bounds'. Instead, subclasses should be sure that the bounds instance variable is correct."

	^ bounds
! !

!Morph methodsFor: 'geometry'!
bounds: newBounds

	self position: newBounds topLeft; extent: newBounds extent! !

!Morph methodsFor: 'geometry' stamp: 'ar 11/15/1998 23:44'!
boundsInWorld

	owner ifNil: [^ bounds].
	^ (owner transformFrom: self world) localBoundsToGlobal: bounds.
! !

!Morph methodsFor: 'geometry'!
center

	^ bounds center! !

!Morph methodsFor: 'geometry' stamp: 'sw 6/11/1999 18:48'!
center: aPoint
	self position: (aPoint - (self extent // 2))! !

!Morph methodsFor: 'menus' stamp: 'jm 1/24/2004 19:09'!
centerInOwner

	owner ifNil: [^ self].
	self left: owner left + ((owner width - self width) // 2).
! !

!Morph methodsFor: 'menus' stamp: 'di 9/3/1999 10:17'!
changeColor

	ColorPickerMorph new
		sourceHand: self activeHand;
		target: self;
		selector: #color:;
		originalColor: self color;
		addToWorld: self world
			near: self fullBounds! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'EMP 4/27/2016 11:55'!
changed
	"Report that the area occupied by this morph should be redrawn."

	self invalidRect: self fullBounds.
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:21'!
click: evt
	"Handle a single-click event. This message is only sent to clients that request it by sending #waitForClicksOrDrag:event: to the initiating hand in their mouseDown: method. This default implementation does nothing."
! !

!Morph methodsFor: 'menus' stamp: 'sw 2/21/2000 15:21'!
collapse
	CollapsedMorph new beReplacementFor: self! !

!Morph methodsFor: 'accessing'!
color

	^ color! !

!Morph methodsFor: 'accessing' stamp: 'jm 8/24/97 21:26'!
color: aColor

	color = aColor ifFalse: [
		color _ aColor.
		self changed].
! !

!Morph methodsFor: 'accessing' stamp: 'ee 6/28/2008 13:40'!
colorForInsets
	"Return the color to be used for shading inset borders. The default is my own color, but it might want to be, eg, my owner's color. Whoever's color ends up prevailing, the color itself gets the last chance to determine, so that when, for example, an InfiniteForm serves as the color, callers won't choke on some non-Color object being returned"

	(color = Color transparent) ifTrue: [
		owner ifNotNil: [
			^ owner colorForInsets]].
	^ color colorForInsets
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'jm 10/15/2002 17:20'!
comeToFront

	| myOwner |
	myOwner _ self owner.
	(myOwner == nil or: [myOwner hasSubmorphs not]) ifTrue: [^ self].
	myOwner firstSubmorph == self ifFalse:
		[myOwner addMorphFront: self].
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'jm 9/30/2003 00:18'!
comeToFrontAndAddHalo

	self comeToFront.
	self addHalo: nil.
! !

!Morph methodsFor: 'e-toy support' stamp: 'sw 5/23/2000 03:42'!
containingWindow
	^ self ownerThatIsA: SystemWindow! !

!Morph methodsFor: 'geometry-testing'!
containsPoint: aPoint

	^ self bounds containsPoint: aPoint! !

!Morph methodsFor: 'copying'!
copy

	^ self copyWithoutSubmorphs! !

!Morph methodsFor: 'copying' stamp: 'jm 10/13/2002 21:23'!
copyRecordingIn: dict
	"Recursively copy this entire composite morph, recording the correspondence between old and new morphs in the given dictionary. This dictionary will be used to update intra-composite references in the copy. See updateReferencesUsing:.
	Note: This default implementation copies ONLY morphs in the submorph hierarchy. If a subclass stores morphs in instance variables that it wants to copy, then it should override this method to do so. The same goes for subclasses that contain other data that should be copied when the morph is duplicated."

	| new |
	new _ self copy.
	dict at: self put: new.
	submorphs size > 0 ifTrue: [
		new privateSubmorphs:
			(submorphs collect: [:m |
				(m copyRecordingIn: dict) privateOwner: new])].

	properties ifNotNil: [new privateProperties: properties copyAll].
	^ new
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'di 10/27/97 23:26'!
copyWithoutSubmorph: sub
	"Needed to get a morph to draw without one of its submorphs.
	NOTE:  This must be thrown away immediately after use."
	^ self clone privateSubmorphs: (submorphs copyWithout: sub)! !

!Morph methodsFor: 'copying' stamp: 'jm 10/13/2002 21:27'!
copyWithoutSubmorphs

	^ self clone
		privateOwner: nil;
		privateSubmorphs: Array empty;
		privateBounds: (bounds origin corner: bounds corner)  "deep-copy bounds"
! !

!Morph methodsFor: 'event handling' stamp: 'jm 12/7/2005 09:49'!
cursorPoint

	^ self currentWorld activeHand lastEvent cursorPoint
! !

!Morph methodsFor: 'debug and other' stamp: 'jm 12/9/2003 09:13'!
debuggingMenuFor: aHandMorph

	| aMenu |
	aMenu _ MenuMorph new defaultTarget: self.
	aMenu addStayUpItem.
	(self hasProperty: #errorOnDraw) ifTrue: [
		aMenu add: 'start drawing again' action: #resumeAfterDrawError.
		aMenu addLine].
	(self hasProperty: #errorOnStep) ifTrue: [
		aMenu add: 'start stepping again' action: #resumeAfterStepError.
		aMenu addLine].

	aMenu add: 'inspect morph' action: #inspectInMorphic.
	Smalltalk isMorphic ifFalse:
		[aMenu add: 'inspect morph (in MVC)' action: #inspect].
 	aMenu addLine.

	aMenu add: 'browse morph class' target: self selector: #browseHierarchy.
	aMenu add: 'make own subclass' target: aHandMorph action: #subclassMorph.
	aMenu addLine.

	aMenu add: 'control-menu...' target: aHandMorph selector: #invokeMetaMenuFor: argument: self.

	^ aMenu
! !

!Morph methodsFor: 'copying' stamp: 'jm 10/7/2002 06:43'!
deepCopy

	^ self fullCopy
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'sw 1/11/2000 18:24'!
defersHaloOnClickTo: aSubMorph
	"If a cmd-click on aSubMorph would make it a preferred recipient of the halo, answer true"
	"May want to add a way (via a property) for morphs to assert true here -- this would let certain kinds of morphs that are unusually reluctant to take the halo on initial click"

	^ false
	! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'jm 10/3/2002 19:23'!
delete
	"Remove the receiver as a submorph of its owner and make its new owner be nil."

	owner ifNotNil: [
		owner privateRemoveMorph: self.
		owner _ nil].
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'jm 4/24/2008 20:14'!
deleteBalloon
	"If I am showing a balloon, delete it."

	| balloon |
	ScratchToolTipMorph clearToolTips.

	(balloon _ self valueOfProperty: #balloon) ifNil: [^ self].
	balloon delete.
	self setProperty: #balloon toValue: nil.
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:22'!
doubleClick: evt
	"Handle a double-click event. This message is only sent to clients that request it by sending #waitForClicksOrDrag:event: to the initiating hand in their mouseDown: method. This default implementation does nothing."
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:50'!
dragEnabled
	"Get this morph's ability to add and remove morphs via drag-n-drop."
	^(self valueOfProperty: #dragEnabled) == true
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:48'!
dragNDropEnabled
	"Get this morph's ability to add and remove morphs via drag-n-drop."
	^(self valueOfProperty: #dragNDropEnabled) == true
! !

!Morph methodsFor: 'drawing' stamp: 'ar 4/2/1999 13:13'!
drawErrorOn: aCanvas
	"The morph (or one of its submorphs) had an error in its drawing method."
	aCanvas
		frameAndFillRectangle: bounds
		fillColor: Color red
		borderWidth: 1
		borderColor: Color yellow.
	aCanvas line: bounds topLeft to: bounds bottomRight width: 1 color: Color yellow.
	aCanvas line: bounds topRight to: bounds bottomLeft width: 1 color: Color yellow.! !

!Morph methodsFor: 'drawing' stamp: 'jm 10/25/2008 16:45'!
drawOn: aCanvas

	color isTransparent ifTrue: [^ self].
	aCanvas fillRectangle: self bounds color: color.
! !

!Morph methodsFor: 'drawing' stamp: 'ar 5/29/1999 05:23'!
drawSubmorphsOn: aCanvas
	"Display submorphs back to front"
	submorphs reverseDo:[:m | aCanvas fullDrawMorph: m].
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:51'!
dropEnabled
	"Get this morph's ability to add and remove morphs via drag-n-drop."
	^(self valueOfProperty: #dropEnabled) == true
! !

!Morph methodsFor: 'e-toy support' stamp: 'sw 10/26/1999 23:32'!
embeddedInMorphicWindowLabeled: labelString
	| window |
	window _ (SystemWindow labelled: labelString) model: nil.
	window setStripeColorsFrom: nil defaultBackgroundColor.
	window addMorph: self frame: (0@0 extent: 1@1).
	^ window! !

!Morph methodsFor: 'geometry' stamp: 'EMP 3/23/2016 11:58'!
emergencyExtent: aPoint
	"Can be called without use of SUPER"
	bounds extent = aPoint ifFalse: [
		self changed.
		bounds _ bounds topLeft extent: aPoint.
		self layoutChanged.
		self changed].
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:50'!
enableDrag: aBoolean
	self setProperty: #dragEnabled toValue: aBoolean! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:54'!
enableDragNDrop: aBoolean
	self enableDrag: aBoolean.
	self enableDrop: aBoolean.
	self setProperty: #dragNDropEnabled toValue: aBoolean! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:51'!
enableDrop: aBoolean
	self setProperty: #dropEnabled toValue: aBoolean! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:38'!
eventNameMatches: aMessage
	^ false! !

!Morph methodsFor: 'geometry'!
extent

	^ bounds extent! !

!Morph methodsFor: 'geometry' stamp: 'jm 8/24/97 21:27'!
extent: aPoint

	bounds extent = aPoint ifFalse: [
		self changed.
		bounds _ bounds topLeft extent: aPoint.
		self layoutChanged.
		self changed].
! !

!Morph methodsFor: 'naming' stamp: 'jm 10/13/2002 20:07'!
externalName

	^ self valueOfProperty: #externalName ifAbsent: [self innocuousName]
! !

!Morph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 15:37'!
fieldsVersion

	^ 1
! !

!Morph methodsFor: 'submorphs-accessing'!
findA: aClass
	"Return the first submorph of the receiver that is descended from the given class. Return nil if there is no such submorph. Clients of this code should always check for a nil return value so that the code will be robust if the user takes the morph apart."

	submorphs do: [:each | (each isKindOf: aClass) ifTrue: [^ each]].
	^ nil
! !

!Morph methodsFor: 'submorphs-accessing'!
firstSubmorph

	^ submorphs at: 1! !

!Morph methodsFor: 'drawing' stamp: 'sw 10/10/1999 10:23'!
flash
	| c w |
	c _ self color.
	self color: Color black.
	(w _ self world) ifNotNil: [w displayWorldSafely].
	self color: c
! !

!Morph methodsFor: 'drawing' stamp: 'jm 10/13/2002 18:18'!
fullBounds

	fullBounds ifNil: [
		fullBounds _ self bounds.
		submorphs size > 0 ifTrue: [
			submorphs do: [:m |
				m isHidden ifFalse: [
					fullBounds _ fullBounds quickMerge: m fullBounds]]]].
	^ fullBounds
! !

!Morph methodsFor: 'geometry' stamp: 'ar 11/15/1998 23:44'!
fullBoundsInWorld

	owner ifNil: [^ self fullBounds].
	^ (owner transformFrom: self world) localBoundsToGlobal: self fullBounds.
! !

!Morph methodsFor: 'geometry-testing' stamp: 'di 5/3/2000 19:05'!
fullContainsPoint: aPoint

	(self fullBounds containsPoint: aPoint) ifFalse: [^ false].  "quick elimination"
	(self containsPoint: aPoint) ifTrue: [^ true].  "quick acceptance"
	submorphs do: [:m | (m fullContainsPoint: aPoint) ifTrue: [^ true]].
	^ false
! !

!Morph methodsFor: 'copying' stamp: 'jm 10/13/2002 21:25'!
fullCopy
	"Produce a copy of me with my entire tree of submorphs. Morphs mentioned more than once are all directed to a single new copy. Simple
inst vars are not copied, so you must override to copy Arrays, Forms, editable text, etc."

	| dict new |
	dict _ IdentityDictionary new: 1000.
	new _ self copyRecordingIn: dict.
	new allMorphsDo: [:m | m updateReferencesUsing: dict].
	^ new! !

!Morph methodsFor: 'drawing' stamp: 'jm 10/13/2002 19:07'!
fullDrawOn: aCanvas
	"Draw my full Morphic structure on the given Canvas"

	self isHidden ifTrue: [^ self].
	(self hasProperty: #errorOnDraw) ifTrue:[^ self drawErrorOn: aCanvas].
	aCanvas drawMorph: self.
	self drawSubmorphsOn:aCanvas.
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 17:50'!
getFlag: maskInteger
	"Return the boolean flag for the given mask. The maskInteger is assumed to be an integer with only a single bit set, the bit corresponding to the flag to be read."

	^ (flags bitAnd: maskInteger) ~= 0
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'jm 3/30/2005 07:16'!
goBehind

	owner ifNotNil: [
		owner addMorphBack: self].
! !

!Morph methodsFor: 'drawing' stamp: 'EMP 2/9/2016 16:41'!
handledOwnDraggingBy: t1 on: t2 
	^ false! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:24'!
handlesMouseDown: evt
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ false
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:32'!
handlesMouseOver: evt
	"Return true if I want to receive mouseEnter: and mouseLeave: when the button is up and the hand is empty. The default response is false; subclasses that implement mouse mouseEnter messages should override this to return true." 

	^ false
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:31'!
handlesMouseOverDragging: evt
	"Return true if I want to receive mouseEnterDragging: and mouseLeaveDragging: when the hand drags something over me (button up or button down), or when the mouse button is down but there is no mouseDown recipient. The default response is false; subclasses that implement mouse mouseEnterDragging messages should override this to return true."

	"NOTE:  If the hand state matters in these cases, it may be tested by constructs such as
		event anyButtonPressed
		event hand hasSubmorphs"

	^ false
! !

!Morph methodsFor: 'event handling' stamp: 'sw 4/2/98 14:16'!
hasFocus
	^ false! !

!Morph methodsFor: 'access properties' stamp: 'jm 10/13/2002 21:06'!
hasProperty: propName
	"Return true if my properties list includes a property with the given name."

	properties ifNil: [^ false].
	^ (properties propertyForName: propName asSymbol) notNil
! !

!Morph methodsFor: 'submorphs-accessing'!
hasSubmorphs

	^ submorphs size > 0! !

!Morph methodsFor: 'accessing' stamp: 'di 1/3/1999 12:25'!
hasTranslucentColor
	"Answer true if this any of this morph is translucent but not transparent."

	^ color isColor and: [color isTranslucentColor]
! !

!Morph methodsFor: 'geometry'!
height

	^ bounds height! !

!Morph methodsFor: 'geometry' stamp: 'jm 1/29/98 14:26'!
height: aNumber

	self extent: self width@aNumber asInteger.
! !

!Morph methodsFor: 'drawing' stamp: 'jm 7/4/2003 10:34'!
imageForm

	^ self imageForm: Display depth forRectangle: self fullBounds
! !

!Morph methodsFor: 'drawing' stamp: 'jm 11/29/2002 10:12'!
imageForm: depth forRectangle: rect

	| canvas |
	canvas _ FormCanvas extent: rect extent depth: depth.
	canvas translateBy: rect topLeft negated during: [:c | self fullDrawOn: c].
	^ canvas form offset: 0@0
! !

!Morph methodsFor: 'parts bin' stamp: 'di 8/11/1998 12:48'!
inPartsBin
	| o |
	self isPartsDonor ifTrue: [^ true].

	o _ self owner.
	[o == nil] whileFalse:
		[o isPartsBin ifTrue: [^ true].
		o _ o owner].
	^ false
! !

!Morph methodsFor: 'object i/o' stamp: 'jm 9/28/2003 18:23'!
initFieldsFrom: anObjStream version: classVersion
	"Set my instance variables from the given object stream."

	self initFieldsNamed: #(
		bounds
		owner
		submorphs
		color
		flags
	) from: anObjStream.
	anObjStream nextField.  "placeholder for properties"
	fullBounds _ nil.
! !

!Morph methodsFor: 'initialization' stamp: 'sw 10/2/97 23:08'!
initialExtent
	| ext |
	(ext _ self valueOfProperty: #initialExtent)
		ifNotNil:
			[^ ext].
	^ super initialExtent! !

!Morph methodsFor: 'initialization' stamp: 'jm 10/14/2002 08:40'!
initialize

	bounds _ 0@0 corner: 50@40.
	owner _ nil.
	submorphs _ Array empty.
	fullBounds _ nil.
	color _ Color blue.
	flags _ 0.
	properties _ nil.
! !

!Morph methodsFor: 'geometry'!
innerBounds
	"Return the inner rectangle enclosed by the bounds of this morph excluding the space taken by its borders. For an unbordered morph, this is just its bounds."

	^ bounds! !

!Morph methodsFor: 'naming' stamp: 'jm 10/7/2002 07:22'!
innocuousName
	"Choose an innocuous name for the receiver -- one that does not end in the word Morph"

	| myName |
	myName _ self class name asString copy.
	(myName size > 5 and: [myName endsWith: 'Morph'])
		ifTrue: [^ myName copyFrom: 1 to: myName size - 5]
		ifFalse: [^ myName].
! !

!Morph methodsFor: 'menus' stamp: 'jm 12/7/2005 09:49'!
inspectInMorphic

	self currentWorld activeHand
		attachMorph: ((Inspector openAsMorphOn: self) extent: 300@200).
! !

!Morph methodsFor: 'change reporting' stamp: 'jm 10/13/2002 20:51'!
invalidRect: damageRect

	owner ifNotNil: [owner invalidRect: damageRect].
! !

!Morph methodsFor: 'classification' stamp: 'di 5/7/1998 01:21'!
isAlignmentMorph

	^ false! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:42'!
isBackdropEventHatMorph
	^ false! !

!Morph methodsFor: 'classification' stamp: 'jm 10/14/2002 09:14'!
isColorable
	"Answer true if my color can be changed using the color: message. Subclasses whose color cannot be changes this way (e.g., those based on a Form) should override this to return false."

	^ true
! !

!Morph methodsFor: 'classification'!
isHandMorph

	^ false! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:25'!
isHidden

	^ self getFlag: HiddenFlag
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/31/2002 10:18'!
isHidden: aBoolean

	self setFlag: HiddenFlag to: aBoolean.
	self changed.
! !

!Morph methodsFor: 'structure' stamp: 'jm 7/8/97 10:08'!
isInWorld
	"Return true if this morph is in a world."

	^ self world ~~ nil! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:29'!
isLocked

	^ self getFlag: LockedFlag
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:27'!
isLocked: aBoolean

	self setFlag: LockedFlag to: aBoolean.
! !

!Morph methodsFor: 'classification'!
isMorph

	^ true! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:40'!
isMouseClickEventHatMorph
	^ false! !

!Morph methodsFor: 'classification' stamp: 'jm 12/9/2003 18:05'!
isPaintable
	"Answer true if my image can be repainted."

	^ false
! !

!Morph methodsFor: 'parts bin' stamp: 'sw 8/12/97 14:16'!
isPartsBin
	^ false! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:29'!
isPartsDonor

	^ self getFlag: PartsDonorFlag
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/14/2002 08:54'!
isPartsDonor: aBoolean

	self setFlag: PartsDonorFlag to: aBoolean.
! !

!Morph methodsFor: 'classification' stamp: 'jm 5/6/2004 19:48'!
isRotatable
	"Answer true if my image can be rotated."

	^ false
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:29'!
isSticky

	^ self getFlag: StickyFlag
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/14/2002 08:54'!
isSticky: aBoolean

	self setFlag: StickyFlag to: aBoolean.
! !

!Morph methodsFor: 'flags' stamp: 'jm 6/2/2009 11:42'!
isVisible

	^ self isHidden not
! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:46'!
isWhenCloneHat
	^ false! !

!Morph methodsFor: 'classification'!
isWorldMorph

	^ false! !

!Morph methodsFor: 'classification'!
isWorldOrHandMorph

	^ self isWorldMorph or: [self isHandMorph]! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'sw 10/11/1999 13:20'!
justDroppedInto: aMorph event: anEvent
	"This message is sent to a dropped morph after it has been dropped on--and been accepted by--a drop-sensitive morph"

	| aWindow partsBinCase |
	(partsBinCase _ aMorph isPartsBin) ifFalse:
		[self isPartsDonor: false].
	(aWindow _ aMorph ownerThatIsA: SystemWindow) ifNotNil:
		[aWindow isActive ifFalse:
			[aWindow activate]].
	(self isInWorld and: [partsBinCase not]) ifTrue:
		[self world startSteppingSubmorphsOf: self]  
	"Note an unhappy inefficiency here:  the startStepping... call will often have already been called in the sequence leading up to entry to this method, but unfortunately the isPartsDonor: call often will not have already happened, with the result that the startStepping... call will not have resulted in the startage of the steppage."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:25'!
keyStroke: anEvent
	"Handle a keystroke event. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 11/1/2002 10:45'!
keyboardFocusChange: aBoolean
	"The message is sent to a morph when its keyboard focus change. The argument is true if the receiver is gaining (versus losing) the keyboard focus. Morphs that accept keystrokes should change their appearance in some way when they are the current keyboard focus. This default implementation does nothing."
! !

!Morph methodsFor: 'submorphs-accessing'!
lastSubmorph

	^ submorphs at: submorphs size! !

!Morph methodsFor: 'change reporting' stamp: 'jm 5/14/2008 13:50'!
layoutChanged
	"Note that something has changed about the size, shape, or location of the receiver or one of its submorphs, so that fullBounds must be recomputed."

	fullBounds _ nil.
	owner ifNotNil: [owner layoutChanged].
"xxx
	submorphs size > 0 ifTrue:
		['Let submorphs know about a change above'
		submorphs do: [:m | m ownerChanged]].
xxx"
! !

!Morph methodsFor: 'geometry'!
left

	^ bounds left! !

!Morph methodsFor: 'geometry' stamp: 'sw 5/5/1998 01:22'!
left: aNumber
	self position: (aNumber @ bounds top)! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:27'!
lock

	self isLocked: true.
! !

!Morph methodsFor: 'change reporting' stamp: 'jm 7/24/2003 18:06'!
mayNeedLayout
	"Answer true if something has occured that might require my layout to change That is, if layoutChanged has been sent to me or any of my submorphs."

	^ fullBounds isNil
! !

!Morph methodsFor: 'geometry'!
minHeight
	"Return the minimum width for this morph. Ordinary morphs just answer their current height."

	^ self fullBounds height
! !

!Morph methodsFor: 'geometry'!
minWidth
	"Return the minimum width for this morph. Ordinary morphs just answer their current width."

	^ self fullBounds width
! !

!Morph methodsFor: 'geometry' stamp: 'sw 6/4/2000 21:59'!
minimumExtent
	| ext |
	"This returns the minimum extent that the morph may be shrunk to.  Not honored in too many places yet, but respected by the resizeToFit feature, at least.  copied up from SystemWindow 6/00"
	(ext _ self valueOfProperty: #minimumExtent)
		ifNotNil:
			[^ ext].
	^ 100 @ 80! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'di 2/21/98 21:20'!
morphsAt: aPoint
	"Return a collection of all morphs in this morph structure that contain the given point, possibly including the receiver itself.  The order is deepest embedding first."

	^ self morphsAt: aPoint addTo: OrderedCollection new! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'jm 8/3/2003 14:07'!
morphsAt: aPoint addTo: mList
	"Return a collection of all morphs in this morph structure that contain the given point, possibly including the receiver itself. Must do this recursively because of transforms.  "

	(self fullBounds containsPoint: aPoint) ifFalse: [^ mList].  "quick elimination"
	submorphs size > 0 ifTrue: [
		submorphs do: [:m | m morphsAt: aPoint addTo: mList]].
	(self containsPoint: aPoint) ifTrue: [mList addLast: self].
	^ mList
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:25'!
mouseDown: evt
	"Handle a mouse down event. This default implementation does nothing."
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'jm 10/8/2002 08:53'!
mouseDownOnHelpHandle: anEvent
	"The mouse went down in the show-balloon handle"
	
	| str |
	str _ self balloonText.
	str ifNil: [str _ self noHelpString].
	self showBalloon: str
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:26'!
mouseEnter: evt
	"Handle a mouseEnter event. The mouse just entered my bounds with no button pressed. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:26'!
mouseEnterDragging: evt
	"Handle a mouseEnterDragging event. The mouse just entered my bounds with a button pressed or laden with submorphs. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 12/19/2008 17:18'!
mouseHold: evt
	"Handle a hold event, triggered by pressing and holding down the mouse without moving the mouse for the duration of a double click. This message is only sent to clients that request it by sending #waitForClicksOrDrag:event: to the initiating hand in their mouseDown: method. This default implementation treats a hold as a drag."

	self startDrag: evt.
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:27'!
mouseLeave: evt
	"Handle a mouseLeave event. The mouse just left my bounds with no button pressed. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:27'!
mouseLeaveDragging: evt
	"Handle a mouseLeaveLaden event. The mouse just left my bounds with a button pressed or laden with submorphs. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:28'!
mouseMove: evt
	"Handle a mouse move event as part of the sequence mouseDown, mouseMove(s), mouseUp. This default implementation does nothing."
! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/13/2002 11:29'!
mouseUp: evt
	"Handle a mouse up event. This default implementation does nothing."
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'jens 3/18/2009 13:24'!
moveMorph: morphToMove inFrontOf: aMorph
	"change a submorph's layer by moving it in front of another submorph"

	| morphsBehind morphsBefore idx sm |
	sm _ (submorphs reject: [:m | m == morphToMove]) asOrderedCollection.
	idx _ sm indexOf: aMorph.
	morphsBefore _ sm copyFrom: 1 to: idx - 1.
	morphsBehind _ sm copyFrom: idx to: sm size.
	morphToMove privateOwner: self.
	morphsBefore add: morphToMove.
	submorphs _ (morphsBefore, morphsBehind) asArray.
	morphToMove changed.
	self layoutChanged.
! !

!Morph methodsFor: 'naming' stamp: 'sw 11/3/97 01:57'!
name: aName
	(aName isKindOf: String) ifTrue:
		[self setNameTo: aName]! !

!Morph methodsFor: 'halos and balloon help' stamp: 'sw 9/19/97 13:46'!
noHelpString
	^ 'Help not yet supplied'! !

!Morph methodsFor: 'initialization' stamp: 'jm 7/5/1998 12:40'!
openInMVC

	MorphWorldView
		openWorldWith: self
		labelled: self defaultLabelForInspector.
! !

!Morph methodsFor: 'initialization' stamp: 'sma 4/30/2000 10:43'!
openInWorld
	"Add this morph to the world.  If in MVC, then provide a Morphic window for it."

	Smalltalk isMorphic
		ifTrue: [self openInWorld: self currentWorld]
		ifFalse: [self openInMVC]! !

!Morph methodsFor: 'initialization' stamp: 'bf 1/5/2000 19:57'!
openInWorld: aWorld
	"Add this morph to the requested World."
	(aWorld viewBox origin ~= (0@0) and: [self position = (0@0)]) ifTrue:
		[self position: aWorld viewBox origin].
	aWorld addMorph: self.
	aWorld startSteppingSubmorphsOf: self! !

!Morph methodsFor: 'geometry' stamp: 'EMP 3/23/2016 12:33'!
otherPosition: aPoint
	"Change the position of this morph and and all of its submorphs. Can be used in emer"

	| delta |
	delta _ aPoint - bounds topLeft.
	(delta x = 0 and: [delta y = 0]) ifTrue: [^ self].  "Null change"
	self privateFullMoveBy: delta.! !

!Morph methodsFor: 'structure'!
owner
	"Returns the owner of this morph, which may be nil."

	^ owner! !

!Morph methodsFor: 'change reporting' stamp: 'jm 10/12/2005 11:13'!
ownerChanged
	"This default implementation does nothing."
! !

!Morph methodsFor: 'structure' stamp: 'EMP 4/26/2016 16:11'!
ownerOrYourselfThatIsA: t1 
	| t2 |
	t2 := self.
	[t2 == nil]
		whileFalse: [(t2 isKindOf: t1)
				ifTrue: [^ t2].
			t2 := t2 owner].
	^ t2! !

!Morph methodsFor: 'structure' stamp: 'jm 8/16/2005 17:16'!
ownerThatIsA: aClass
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current |
	current _ self.
	[current == nil] whileFalse: [
		(current isKindOf: aClass) ifTrue: [^ current].
		current _ current owner].
	^ current
! !

!Morph methodsFor: 'structure' stamp: 'EMP 2/9/2016 15:37'!
ownerThatIsANotSelf: aClass
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current |
	current _ self owner.
	[current == nil] whileFalse: [
		(current isKindOf: aClass) ifTrue: [^ current].
		current _ current owner].
	^ current
! !

!Morph methodsFor: 'drawing' stamp: 'jm 6/7/2004 11:18'!
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
	self drawOn: c.
	morphsToDraw _ submorphs reversed asOrderedCollection.
	(i _ morphsToDraw indexOf: stopMorph) > 0 ifTrue: [
		stopThere
			ifTrue: [morphsToDraw _ morphsToDraw copyFrom: 1 to: i - 1]  "stop at stopMorph"
			ifFalse: [morphsToDraw removeIndex: i]].  "skip stopMorph"
	morphsToDraw do: [:m | m fullDrawOn: c].
	^ c form
! !

!Morph methodsFor: 'geometry' stamp: 'ar 11/15/1998 23:42'!
pointFromWorld: aPoint

	owner ifNil: [^ aPoint].
	^ (owner transformFrom: self world) globalPointToLocal: aPoint.
! !

!Morph methodsFor: 'geometry' stamp: 'ar 11/15/1998 23:43'!
pointInWorld: aPoint

	owner ifNil: [^ aPoint].
	^ (owner transformFrom: self world) localPointToGlobal: aPoint.
! !

!Morph methodsFor: 'geometry'!
position

	^ bounds topLeft! !

!Morph methodsFor: 'geometry' stamp: 'di 4/8/98 20:35'!
position: aPoint
	"Change the position of this morph and and all of its submorphs."

	| delta |
	delta _ aPoint - bounds topLeft.
	(delta x = 0 and: [delta y = 0]) ifTrue: [^ self].  "Null change"
	self changed.
	self privateFullMoveBy: delta.
	self changed.
! !

!Morph methodsFor: 'geometry' stamp: 'di 9/30/1998 12:11'!
positionInWorld

	^ self pointInWorld: self position.
! !

!Morph methodsFor: 'event handling' stamp: 'sw 8/11/97 18:36'!
preemptsMouseDown: evt
	"Return true if this morph wants to handle mouse down events even when the mouse is pressed over a submorph that also wishes to handle mouse down events. Responding true to this message allows a morph to reverse the normal policy that control is given to the inner-most submorph that wants it. This can be used, for example, to allow buttons in a parts bin to be copied when clicked, instead of being activated."

	^ self isPartsDonor
! !

!Morph methodsFor: 'printing' stamp: 'jm 7/25/2006 11:51'!
printOn: aStream

	| m |
	super printOn: aStream.

	(m _ self findA: StringMorph) ifNil: [
		aStream nextPutAll: '()'.
		^ self].

	aStream nextPutAll: '('.
	m ifNotNil: [aStream print: m contents; space]. 
	aStream print: self identityHash; nextPutAll: ')'.
! !

!Morph methodsFor: 'printing' stamp: 'jm 5/28/1998 18:00'!
printStructureOn: aStream indent: tabCount

	tabCount timesRepeat: [aStream tab].
	self printOn: aStream.
	aStream cr.
	self submorphsDo: [:m | m printStructureOn: aStream indent: tabCount + 1].
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'EMP 4/29/2016 10:03'!
privateAddMorph: aMorph atIndex: index

	((index >= 1) and: [index <= (submorphs size + 1)])
		ifFalse: [^ self error: 'index out of range'].
	aMorph owner ifNotNil: [aMorph owner privateRemoveMorph: aMorph].
	aMorph layoutChanged.
	aMorph privateOwner: self.
	submorphs _ submorphs copyReplaceFrom: index to: index-1 with: (Array with: aMorph).
	self layoutChanged.
! !

!Morph methodsFor: 'private'!
privateBounds: boundsRect
	"Private!! Use position: and/or extent: instead."

	fullBounds _ nil.
	bounds _ boundsRect.! !

!Morph methodsFor: 'private' stamp: 'jm 5/29/1998 21:28'!
privateColor: aColor

	color _ aColor.
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'sw 2/15/98 23:34'!
privateDelete
	"Remove the receiver as a submorph of its owner and make its new owner be nil, without informing anyone other than my owner"

	owner ifNotNil:
		[owner privateRemoveMorph: self.
		owner _ nil].! !

!Morph methodsFor: 'private' stamp: 'jm 7/8/97 08:32'!
privateFullMoveBy: delta
	"Private!! Relocate me and all of my subMorphs by recursion. Subclasses that implement different coordinate systems may override this method."

	self privateMoveBy: delta.
	1 to: submorphs size do: [:i |
		(submorphs at: i) privateFullMoveBy: delta].
! !

!Morph methodsFor: 'private' stamp: 'jm 10/9/2002 05:37'!
privateMoveBy: delta
	"Private!! Use 'position:' instead."

	fullBounds == bounds
		ifTrue: ["optimization: avoids recomputing fullBounds"
			fullBounds _ bounds _ bounds translateBy: delta]
		ifFalse: [
			bounds _ bounds translateBy: delta.
			fullBounds _ nil].
! !

!Morph methodsFor: 'private'!
privateOwner: aMorph
	"Private!! Should only be used by methods that maintain the ower/submorph invariant."

	owner _ aMorph.! !

!Morph methodsFor: 'private' stamp: 'jm 10/13/2002 21:22'!
privateProperties: aMorphPropertyOrNil
	"Private!! Used when copying."

	properties _ aMorphPropertyOrNil.
! !

!Morph methodsFor: 'private'!
privateRemoveMorph: aMorph
	"Private!! Should only be used by methods that maintain the ower/submorph invariant."

	aMorph changed.
	submorphs _ submorphs copyWithout: aMorph.
	self layoutChanged.
! !

!Morph methodsFor: 'private'!
privateSubmorphs: aCollection
	"Private!! Should only be used by methods that maintain the ower/submorph invariant."

	submorphs _ aCollection.! !

!Morph methodsFor: 'geometry-rotate scale and flex' stamp: 'jm 4/29/1998 11:28'!
referencePosition

	^ bounds center
! !

!Morph methodsFor: 'geometry-rotate scale and flex' stamp: 'jm 5/2/1998 07:16'!
referencePosition: aPosition

	self position: aPosition - (bounds extent // 2).
! !

!Morph methodsFor: 'geometry-rotate scale and flex' stamp: 'sw 10/25/1999 16:49'!
referencePositionInWorld

	^ self pointInWorld: self referencePosition
! !

!Morph methodsFor: 'geometry-rotate scale and flex' stamp: 'sw 10/25/1999 23:33'!
referencePositionInWorld: aPoint
	| localPosition |
	localPosition _ owner
		ifNil: [aPoint]
		ifNotNil: [(owner transformFrom: self world) globalPointToLocal: aPoint].

	self referencePosition: localPosition
! !

!Morph methodsFor: 'drawing' stamp: 'sw 10/10/1999 23:25'!
refreshWorld
	| aWorld |
	(aWorld _ self world) ifNotNil: [aWorld displayWorldSafely]
! !

!Morph methodsFor: 'caching' stamp: 'jm 10/13/2002 20:51'!
releaseCachedState
	"Release any state that can be recomputed on demand, such as the pixel values for a color gradient or the editor state for a TextMorph. This method may be called to save space when a morph becomes inaccessible. Implementations of this method should do 'super releaseCachedState'."
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'jm 10/13/2002 17:37'!
removeAllMorphs

	self changed.
	submorphs do: [:m | m privateOwner: nil].
	submorphs _ Array empty.
	self layoutChanged.
! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'RAA 10/6/1999 12:23'!
removeAllMorphsIn: aCollection
"greatly speeds up the removal of *lots* of submorphs"
	| set |
	self changed.
	aCollection do: [:m | m privateOwner: nil].
	set _ IdentitySet new: aCollection size * 4 // 3.
	aCollection do: [:each | set add: each].
	submorphs _ submorphs reject: [ :each | set includes: each].
	self layoutChanged.
! !

!Morph methodsFor: 'access properties' stamp: 'jm 10/13/2002 21:06'!
removeProperty: propName
	"Remove the property with the given name from my properties list."

	properties ifNil: [^ self].
	properties _ properties copyWithoutName: propName asSymbol.
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'sw 1/11/1999 20:07'!
repelsMorph: aMorph event: ev
	^ false! !

!Morph methodsFor: 'submorphs-add/remove' stamp: 'sw 10/25/1999 23:34'!
replaceSubmorph: oldMorph by: newMorph
	| index itsPosition w |
	oldMorph stopStepping.
	itsPosition _ oldMorph referencePositionInWorld.
	index _ submorphs indexOf: oldMorph.
	oldMorph privateDelete.
	self privateAddMorph: newMorph atIndex: index.
	newMorph referencePositionInWorld: itsPosition.
	(w _ newMorph world) ifNotNil:
		[w startSteppingSubmorphsOf: newMorph]! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:39'!
respondsToBackdropName: t1 
	^ false! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:38'!
respondsToKeyEvent: event
	^ false! !

!Morph methodsFor: 'debug and other' stamp: 'ar 4/2/1999 15:11'!
resumeAfterDrawError
	self changed.
	self removeProperty:#errorOnDraw.
	self changed.! !

!Morph methodsFor: 'debug and other' stamp: 'ar 4/2/1999 15:22'!
resumeAfterStepError
	"Resume stepping after an error has occured."
	self startStepping. "Will #step"
	self removeProperty:#errorOnStep. "Will remove prop only if #step was okay"
! !

!Morph methodsFor: 'geometry'!
right

	^ bounds right! !

!Morph methodsFor: 'geometry' stamp: 'sw 5/5/1998 01:23'!
right: aNumber
	self position: ((aNumber - bounds width) @ bounds top)! !

!Morph methodsFor: 'structure'!
root
	"Return the root of the composite morph containing the receiver. The owner of the root is either nil, a WorldMorph, or a HandMorph. If the receiver's owner is nil, the root is the receiver itself. This method always returns a morph."

	(owner = nil or: [owner isWorldOrHandMorph]) ifTrue: [^ self].
	^ owner root! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'jm 6/14/2004 14:25'!
rootForGrabOf: aMorph
	"Answer the root of the morph structure to be picked up when the given morph is grabbed."

	(self isSticky and: [self isPartsDonor not])
		ifTrue: [^ nil]
		ifFalse: [
			(owner isNil or: [owner isWorldOrHandMorph])
				ifTrue: [^ self]
				ifFalse: [
					owner allowSubmorphExtraction
						ifTrue: [^ self]
						ifFalse: [^ owner rootForGrabOf: aMorph]]].
! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'ar 11/8/1999 00:08'!
rootMorphsAt: aPoint
	"Return the list of root morphs containing the given point, excluding the receiver.
	ar 11/8/1999: Moved into morph for an incredibly ugly hack in 3D worlds"

	^ self submorphs select:
		[:m | (m fullContainsPoint: aPoint) and: [m isLocked not]]! !

!Morph methodsFor: 'geometry-rotate scale and flex' stamp: 'jm 4/25/1998 05:19'!
rotationDegrees
	"Default implementation."

	^ 0.0
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'sw 12/30/1999 19:51'!
seeksOutHalo
	"Answer whether the receiver is an eager recipient of the halo"
	^ true! !

!Morph methodsFor: 'halos and balloon help' stamp: 'jm 4/17/2008 10:49'!
setBalloonText: aString
	"Set receiver's balloon help string. Pass nil to remove the help."

	aString
		ifNil: [self removeProperty: #balloonText]
		ifNotNil: [self setProperty: #balloonText toValue: aString].
! !

!Morph methodsFor: 'geometry' stamp: 'jm 10/15/2002 17:20'!
setConstrainedPositionFrom: aPoint
	"Change the position of this morph and and all of its submorphs to aPoint, but don't let me go outside my owner's bounds."

	| trialRect delta boundingMorph |
	trialRect _ aPoint extent: self bounds extent.
	boundingMorph _ self owner.
	delta _ boundingMorph
			ifNil:    [0@0]
			ifNotNil: [trialRect amountToTranslateWithin: boundingMorph bounds].
	self position: aPoint + delta.
	self layoutChanged  "So that, eg, surrounding text will readjust"
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 17:49'!
setFlag: maskInteger to: aBoolean
	"Set the given flag bit to the given boolean value (false = 0, true = 1). The maskInteger is assumed to be an integer with only as single bit set, the bit corresponding to the flag to be modified."
	"Details: Morphs have a number of boolean properties that are most efficiently stored as a bit-vector packed into a single 31-bit Squeak SmallInteger."

	aBoolean
		ifTrue: [flags _ flags bitOr: maskInteger]
		ifFalse: [flags _ flags bitAnd: maskInteger bitInvert].
! !

!Morph methodsFor: 'naming' stamp: 'jm 10/13/2002 20:54'!
setNameTo: aName

	self setProperty: #externalName toValue: aName asString.
! !

!Morph methodsFor: 'access properties' stamp: 'jm 10/13/2002 21:07'!
setProperty: propName toValue: anObject

	| entry newEntry |
	anObject ifNil: [^ self removeProperty: propName].
	properties ifNil: [
		properties _ MorphProperty new name: propName value: anObject.
		^ self].

	entry _ properties propertyForName: propName asSymbol.
	entry
		ifNil: [  "create and add a new entry at start of properties list"
			newEntry _ MorphProperty new name: propName value: anObject.
			newEntry nextLink: properties.
			properties _ newEntry]
		ifNotNil: [  "update the existing entry"
			entry value: anObject].
! !

!Morph methodsFor: 'drawing' stamp: 'jm 11/24/2002 10:49'!
shadowForm
	"Return a form representing the 'shadow' of the receiver - e.g., all pixels that are occupied by the receiver are one, all others are zero."
	| canvas |
	canvas _ (FormCanvas extent: bounds extent depth: 1)
				asShadowDrawingCanvas: Color black. "Color black represents one for 1bpp"
	canvas translateBy: bounds topLeft negated
		during: [:tempCanvas| self fullDrawOn: tempCanvas].
	^ canvas form offset: bounds topLeft
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'jm 4/24/2008 16:11'!
showBalloon: msg

	| w worldBounds tooltip |
	w _ self world.
	tooltip _ (ScratchToolTipMorph string: msg for: self).
	w addMorphFront: (tooltip position: self bottomLeft + (0@8)).
	((worldBounds _ w bounds) containsRect: tooltip bounds) ifFalse:
		[tooltip bounds: (tooltip bounds translatedToBeWithin: worldBounds)].! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'jm 8/3/2003 10:06'!
slideBackToFormerSituation: evt

	| slideForm formerOwner formerPosition aWorld startPoint endPoint trans |
	(formerOwner _ evt hand formerOwner) ifNil: [^ self].
	formerPosition _ evt hand formerPosition.
	aWorld _ self world.

	trans _ formerOwner transformFromWorld.
	slideForm _ self imageForm offset: 0@0.

	startPoint _ evt hand fullBounds origin.
	endPoint _ trans localPointToGlobal: formerPosition.
	owner privateRemoveMorph: self.
	aWorld displayWorld.
	slideForm slideFrom: startPoint to: endPoint nSteps: 12 delay: 15.
	formerOwner addMorph: self.
	self position: formerPosition.
	self justDroppedInto: formerOwner event: evt.
! !

!Morph methodsFor: 'event handling' stamp: 'jm 7/1/2004 23:02'!
startDrag: evt
	"Handle a drag event. This message is only sent to clients that request it by sending #waitForClicksOrDrag:event: to the initiating hand in their mouseDown: method. This default implementation grabs me."

	| frontM rootForGrab |
	frontM _ (self unlockedMorphsAt: evt cursorPoint) first.
	rootForGrab _ frontM rootForGrabOf: frontM.
	rootForGrab ifNil: [^ self].
	rootForGrab position: rootForGrab position + (evt hand position - evt cursorPoint).
	evt hand grabMorph: rootForGrab.
! !

!Morph methodsFor: 'stepping and presenter'!
startStepping
	"Start getting sent the 'step' message."

	| w |
	self step.  "one to get started!!"
	w _ self world.
	w ifNotNil: [
		w startStepping: self.
		self changed].! !

!Morph methodsFor: 'stepping and presenter' stamp: 'jm 10/7/2002 07:39'!
step
	"Do some periodic activity. Use startStepping/stopStepping to start and stop getting sent this message. The time between steps is specified by this morph's answer to the stepTime message. This default implementation does nothing."
! !

!Morph methodsFor: 'stepping and presenter' stamp: 'EMP 1/6/2016 14:41'!
stepAt: millisecondClockValue
	"Do some periodic activity. Use startStepping/stopStepping to start and stop getting sent this message. The time between steps is specified by this morph's answer to the stepTime message.
	The millisecondClockValue parameter gives the value of the millisecond clock at the moment of dispatch.
	Default is to dispatch to the parameterless step method for the morph, but this protocol makes it possible for some morphs to do differing things depending on the clock value"
	
	self step


"0.035 for speed test when timer > than"
! !

!Morph methodsFor: 'stepping and presenter' stamp: 'jm 10/7/2002 07:40'!
stepTime
	"Answer the desired time between steps in milliseconds. This default implementation requests that the 'step' method be called once every second."

	^1000
! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:39'!
stopAllProcessing
	^ self! !

!Morph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:06'!
stopProcess
	^ self! !

!Morph methodsFor: 'stepping and presenter'!
stopStepping
	"Stop getting sent the 'step' message."

	| w |
	w _ self world.
	w ifNotNil: [
		w stopStepping: self.
		self changed].
! !

!Morph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 15:32'!
storeFieldsOn: anObjStream

	self storeFieldsNamed: #(
		bounds
		owner
		submorphs
		color
		flags
	) on: anObjStream.
	anObjStream putField: nil.  "placeholder for properties"
! !

!Morph methodsFor: 'printing' stamp: 'jm 5/28/1998 17:58'!
structureString
	"Return a string that showing this morph and all its submorphs in an indented list that reflects its structure."

	| s |
	s _ WriteStream on: (String new: 1000).
	self printStructureOn: s indent: 0.
	^ s contents
! !

!Morph methodsFor: 'submorphs-accessing'!
submorphCount

	^ submorphs size! !

!Morph methodsFor: 'submorphs-accessing'!
submorphs

	^ submorphs copy! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'di 11/4/97 14:30'!
submorphsBehind: aMorph do: aBlock
	| behind |
	behind _ false.
	submorphs do:
		[:m | m == aMorph ifTrue: [behind _ true]
						ifFalse: [behind ifTrue: [aBlock value: m]]].
! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'di 5/13/1998 20:42'!
submorphsDo: aBlock

	submorphs size = 0 ifTrue: [^ self].
	submorphs do: aBlock.! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'di 11/4/97 14:29'!
submorphsInFrontOf: aMorph do: aBlock
	| behind |
	behind _ false.
	submorphs do:
		[:m | m == aMorph ifTrue: [behind _ true]
						ifFalse: [behind ifFalse: [aBlock value: m]]].
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/25/2000 15:46'!
toggleDragNDrop
	"Toggle this morph's ability to add and remove morphs via drag-n-drop."

		self enableDragNDrop: self dragNDropEnabled not.
! !

!Morph methodsFor: 'flags' stamp: 'jm 10/13/2002 18:07'!
toggleStickiness

	self isSticky: self isSticky not.
! !

!Morph methodsFor: 'geometry'!
top

	^ bounds top! !

!Morph methodsFor: 'geometry' stamp: 'sw 5/5/1998 01:23'!
top: aNumber
	self position: (bounds left @ aNumber)! !

!Morph methodsFor: 'geometry' stamp: 'di 6/12/97 11:07'!
topLeft

	^ bounds topLeft! !

!Morph methodsFor: 'geometry' stamp: 'sw 8/20/97 23:04'!
topRight

	^ bounds topRight! !

!Morph methodsFor: 'event handling'!
transformFrom: uberMorph
	"Return a transform to be used to map coordinates in a morph above me into my local coordinates, or vice-versa. This is used to support scrolling, scaling, and/or rotation. This default implementation just returns my owner's transform or the identity transform if my owner is nil."

	owner == uberMorph ifTrue: [^ MorphicTransform identity].
	owner ifNil: [^ MorphicTransform identity].
	^ owner transformFrom: uberMorph
! !

!Morph methodsFor: 'event handling'!
transformFromWorld
	"Return a transform to map world coordinates into my local coordinates"

	^ self transformFrom: nil! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'jm 7/9/2008 20:27'!
uncoveredAt: aPoint
	"Return true if the receiver is not covered by any submorphs at the given point."

	| w morphsAbove |
	(w _ self world) ifNil: [^ true].

	morphsAbove _ w morphsAt: aPoint.
	^ (morphsAbove size = 0) or:
	 [morphsAbove first = self or:
	 [(morphsAbove first isKindOf: HaloMorph) and:
	 [(morphsAbove at: 2) = self]]]
! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'sw 8/22/97 23:45'!
unlockedMorphsAt: aPoint
	"Return a collection of all unlocked morphs in this morph structure that contain the given point, possibly including the receiver itself.  Simplified "

	^ self unlockedMorphsAt: aPoint addTo: OrderedCollection new! !

!Morph methodsFor: 'submorphs-accessing' stamp: 'di 2/10/98 15:47'!
unlockedMorphsAt: aPoint addTo: mList
	"Return a collection of all morphs in this morph structure that contain the given point, possibly including the receiver itself.  Must do this recursively because of transforms.  "
	(self fullBounds containsPoint: aPoint) ifFalse: [^ mList].  "quick elimination"
	self isLocked ifTrue: [^ mList].
	submorphs size > 0 ifTrue:
		[submorphs do: [:m | m unlockedMorphsAt: aPoint addTo: mList]].
	(self containsPoint: aPoint) ifTrue: [mList addLast: self].
	^ mList! !

!Morph methodsFor: 'copying' stamp: 'jm 10/13/2002 21:01'!
updateReferencesUsing: aDictionary
	"Update intra-morph references within a composite morph that has
been copied. For example, if a button refers to morph X in the orginal
composite then the copy of that button in the new composite should refer to
the copy of X in new composite, not the original X. This default
implementation updates the contents of any morph-bearing slot. It may be
overridden to avoid this behavior if so desired."

	| old prop |
	Morph instSize + 1 to: self class instSize do: [:i |
		old _ self instVarAt: i.
		old isMorph ifTrue:
			[self instVarAt: i put: (aDictionary at: old ifAbsent: [old])]].

	"map morph values in my properties list"
	prop _ properties.
	[prop == nil] whileFalse: [
		old _ prop value.
		old isMorph ifTrue: [
			prop value: (aDictionary at: old ifAbsent: [old])].
		prop _ prop nextLink].
! !

!Morph methodsFor: 'access properties' stamp: 'jm 10/13/2002 20:49'!
valueOfProperty: propName
	"Return the value of the property with the given name in my properties list, or nil if I have no property with that name."

	^ self valueOfProperty: propName ifAbsent: [nil]
! !

!Morph methodsFor: 'access properties' stamp: 'jm 10/13/2002 21:07'!
valueOfProperty: propName ifAbsent: aBlock
	"Return the value of the property with the given name in my properties list, or the value of the given block if I have no property with that name."

	| prop |
	properties ifNil: [^ aBlock value].
	prop _ properties propertyForName: propName asSymbol.
	prop
		ifNil: [^ aBlock value]
		ifNotNil: [^ prop value].
! !

!Morph methodsFor: 'access properties' stamp: 'EMP 4/27/2016 12:04'!
valueOfProperty: propName ifPresent: aBlock
	"Return the value of the property with the given name in my properties list, or the value of the given block if I have no property with that name."

	| prop |
	properties ifNil: [^ aBlock value].
	prop _ properties propertyForName: propName asSymbol.
	prop
		ifNil: [^ self]
		ifNotNil: [^ aBlock value].
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'jm 7/3/2004 19:22'!
vanishAfterSlidingTo: aPosition event: evt

	| aForm aWorld startPoint endPoint |
	aForm _ self imageForm offset: 0@0.
	aWorld _ self world.
	startPoint _ evt hand fullBounds origin.
	self delete.
	aWorld ifNil: [^ self].
	aWorld displayWorld.
	endPoint _ aPosition.
	aForm slideFrom: startPoint  to: endPoint nSteps: 12 delay: 15.
! !

!Morph methodsFor: 'halos and balloon help' stamp: 'sma 12/23/1999 13:24'!
wantsBalloon
	"Answer true if receiver wants to show a balloon help text is a few moments." 

	^ self balloonText notNil! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'panda 4/28/2000 10:51'!
wantsDroppedMorph: aMorph event: evt
	"Return true if the receiver wishes to accept the given morph, which is being dropped by a hand in response to the given event. The default implementation returns false.
NOTE: the event is assumed to be in global (world) coordinates."

	^self dragNDropEnabled
		or: [self dropEnabled]! !

!Morph methodsFor: 'halos and balloon help' stamp: 'sw 1/25/2000 17:43'!
wantsHaloFromClick
	^ true! !

!Morph methodsFor: 'event handling' stamp: 'jm 10/2/2006 15:45'!
wantsKeyboardFocusFor: aSubmorph
	"Answer whether a mouse click on aSubmorph, a text-edit-capable thing, should result in a text selection there."

	owner ifNotNil: [^ owner wantsKeyboardFocusFor: aSubmorph].
	^ aSubmorph wouldAcceptKeyboardFocus
! !

!Morph methodsFor: 'stepping and presenter' stamp: 'jm 10/7/2002 07:40'!
wantsSteps
	"Return true if the receiver overrides the default Morph step method."
	"Details: Find the first class in superclass chain that implements #step and return true if it isn't class Morph."

	| c |
	self isPartsDonor ifTrue: [^ false].
	c _ self class.
	[c includesSelector: #step] whileFalse: [c _ c superclass].
	^ c ~= Morph
! !

!Morph methodsFor: 'geometry'!
width

	^ bounds width! !

!Morph methodsFor: 'geometry' stamp: 'jm 1/29/98 14:26'!
width: aNumber

	self extent: aNumber asInteger@self height.
! !

!Morph methodsFor: 'dropping/grabbing' stamp: 'jm 7/1/2004 22:27'!
willingToBeEmbeddedUponLanding
	"Answer whether the receiver, when dropped over a container that is open to drag-and-drop, is eager to be embedded in the it.  SystemWindows and MenuMorphs are examples of morphs that are reluctant in this regard."
	
	^ true
! !

!Morph methodsFor: 'structure' stamp: 'jm 12/9/2008 16:10'!
world
	"Answer the PasteUpMorph 'world' that contains this morph or nil if it is not in the world."

	| m |
	m _ owner.
	[nil == m] whileFalse: [
		m isWorldMorph ifTrue: [^ m].
		m _ m owner].

	^ nil
! !

!Morph methodsFor: 'geometry' stamp: 'di 2/23/98 11:36'!
worldBounds
	^ self world bounds! !

!Morph methodsFor: 'geometry' stamp: 'sw 4/27/2000 13:53'!
worldBoundsForHalo
	"To restore older behavior, change this to return  self fullBoundsInWorld"

	^ self boundsInWorld
! !

!Morph methodsFor: 'event handling' stamp: 'sw 5/6/1998 12:54'!
wouldAcceptKeyboardFocus
	"Answer whether a plain mouse click on the receiver should result in a text selection there"
	^ false! !

!Morph methodsFor: 'e-toy support' stamp: 'tk 9/3/1999 11:46'!
wrappedInWindowWithTitle: aTitle
	| aWindow |
	aWindow _ (SystemWindow labelled: aTitle) model: Model new.
	aWindow addMorph: self frame: (0@0 extent: 1@1).
	aWindow extent: self extent + (2 @ 18).
	^ aWindow! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Morph class
	instanceVariableNames: ''!

!Morph class methodsFor: 'class initialization' stamp: 'jm 10/13/2002 17:58'!
initialize
	"Morph initialize"

	"flag masks: integers with a single bit set used as masks for the flags field"
	HiddenFlag _ 1.
	StickyFlag _ 2.
	LockedFlag _ 4.
	PartsDonorFlag _ 8.
! !


!Morph class methodsFor: 'instance creation' stamp: 'jm 5/31/2003 19:52'!
includeInNewMorphMenu
	"Answer true for all classes that can be instantiated from the new morph menu."

	^ false
! !

!Morph class methodsFor: 'instance creation'!
newBounds: bounds

	^ self new privateBounds: bounds! !

!Morph class methodsFor: 'instance creation' stamp: 'jm 5/29/1998 21:28'!
newBounds: bounds color: color

	^ (self new privateBounds: bounds) privateColor: color
! !

!Morph class methodsFor: 'instance creation' stamp: 'jm 6/28/2003 09:37'!
open
	"Answer an instance of me and add it to the world."

	^ self new openInWorld
! !


Morph initialize!
