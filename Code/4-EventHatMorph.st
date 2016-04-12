HatBlockMorph subclass: #EventHatMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!EventHatMorph commentStamp: 'jm 3/28/2005 12:25' prior: 0!
I am a hat block for stacks triggered by Scratch events.
!


!EventHatMorph methodsFor: 'initialization' stamp: 'ee 1/28/2009 13:59'!
forStartEvent

	| parts s m |
	super initialize.
	self removeAllMorphs.

	parts _ ScratchTranslator labelPartsFor: 'when %m clicked'.

	s _ StringMorph new contents: parts first; font: (ScratchFrameMorph getFont: #Label); color: Color white.
	self addMorphBack: s.

	m _ ImageMorph new form: (ScratchFrameMorph skinAt: #goButton).
	self addMorphBack: m.

	s _ s fullCopy contents: parts second.
	self addMorphBack: s.

	"create scriptNameMorph but don't add it"
	scriptNameMorph _ EventTitleMorph new eventName: 'Scratch-StartClicked'.

	self fixBlockLayout.
! !

!EventHatMorph methodsFor: 'initialization' stamp: 'ee 3/8/2008 17:04'!
forceLayout
	"My UpdatingStringMorph calls this when its contents change"

	self fixBlockLayout.
	(self ownerThatIsA: ScratchBlockPaletteMorph) ifNotNil:[
		(self ownerThatIsA: ScratchBlockPaletteMorph) fixLayout].
! !

!EventHatMorph methodsFor: 'initialization' stamp: 'EMP 4/6/2016 15:10'!
initialize

	| parts label |
	super initialize.
	self removeAllMorphs.

	parts _ ScratchTranslator labelPartsFor: 'when I receive %e'.

	parts first size > 0 ifTrue: [
		label _ StringMorph contents: parts first font: (ScratchFrameMorph getFont: #Label).
		label color: Color white.
		self addMorphBack: label].

	scriptNameMorph _ EventTitleMorph new.
	self addMorphBack: scriptNameMorph.

	parts second size > 0 ifTrue: [
		label _ (StringMorph contents: parts second font: (ScratchFrameMorph getFont: #Label)) color: Color white.
		self addMorphBack: label].
! !


!EventHatMorph methodsFor: 'other' stamp: 'jm 3/28/2005 12:42'!
asBlockTuple
	"Answer a tuple (Array) describing this block and its event name."

	^ Array with: self class name with: self eventName
! !

!EventHatMorph methodsFor: 'other' stamp: 'jm 3/28/2005 12:32'!
eventName
	"Answer the name of this script."

	^ scriptNameMorph eventName
! !

!EventHatMorph methodsFor: 'other' stamp: 'ee 3/8/2008 15:57'!
eventName: aString
	"Set my event name. Used for initialization."

	scriptNameMorph eventName: aString.
	self fixBlockLayout.
	(self ownerThatIsA: ScratchViewerMorph) ifNotNil:[
		(self ownerThatIsA: ScratchViewerMorph) updateContents].
! !

!EventHatMorph methodsFor: 'other' stamp: 'jm 3/31/2005 21:41'!
helpScreenName
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	(self isKindOf: MouseClickEventHatMorph) ifTrue: [^ 'mouseclickHat'].
	(self isKindOf: KeyEventHatMorph) ifTrue: [^ 'keyHat'].
	self eventName = 'Scratch-StartClicked'
		ifTrue: [^ 'startHat']
		ifFalse: [^ 'broadcastHat'].

	^ nil
! !

!EventHatMorph methodsFor: 'other' stamp: 'jm 12/8/2005 19:21'!
printHatNameOn: aStream
	"Append a human-readable string for this hat block's name to the given stream."

	| evtName |
	evtName _ self eventName.
	evtName = 'Scratch-StartClicked'
		ifTrue: [aStream nextPutAll: 'when green flag clicked']
		ifFalse: [aStream nextPutAll: 'when I receive "', evtName, '"'].
	aStream cr.

! !

!EventHatMorph methodsFor: 'other' stamp: 'jm 6/4/2009 12:33'!
startForEvent: aScratchEvent
	"Starts a process for this event hat triggered by the given event. Answer the process that was started or nil if no new process was started."
	"Details: The current policy is to stop and re-start the script for all events except key-pressed. Key-pressed events are just ignored if the script for that event is already running."

	| stage |
	(aScratchEvent name = 'Scratch-KeyPressedEvent') ifFalse: [
		scratchProc ifNotNil: [self stop]].  "non-key events stop currently running process, if any"

	self hasRunningProcess ifTrue: [^ nil].  "don't re-trigger if running"

	scriptOwner ifNil: [^ nil].
	(stage _ scriptOwner ownerThatIsA: ScratchStageMorph) ifNil: [^ nil].
	scratchProc _ stage startProcessFor: self.
	self changed.
	^ scratchProc
! !
