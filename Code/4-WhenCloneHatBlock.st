HatBlockMorph subclass: #WhenCloneHatBlock
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!

!WhenCloneHatBlock methodsFor: 'initialization' stamp: 'EMP 10/2/2015 21:20'!
forStartEvent

	| s |
	super initialize.
	self removeAllMorphs.

	s _ StringMorph new contents: 'when I start as a clone' localized; font: (ScratchFrameMorph getFont: #Label); color: Color white.
	self addMorphBack: s.

	"create scriptNameMorph but don't add it"
	scriptNameMorph _ EventTitleMorph new eventName: 'Scratch-StartedAsClone'.

	self fixBlockLayout.
! !

!WhenCloneHatBlock methodsFor: 'initialization' stamp: 'EMP 10/2/2015 20:50'!
forceLayout
	"My UpdatingStringMorph calls this when its contents change"

	self fixBlockLayout.
	(self ownerThatIsA: ScratchBlockPaletteMorph) ifNotNil:[
		(self ownerThatIsA: ScratchBlockPaletteMorph) fixLayout].
! !

!WhenCloneHatBlock methodsFor: 'initialization' stamp: 'EMP 10/2/2015 21:18'!
initialize

	| parts label |
	super initialize.
	self removeAllMorphs.

	parts _ ScratchTranslator labelPartsFor: 'when I start as a clone'.

	parts first size > 0 ifTrue: [
		label _ StringMorph contents: parts first font: (ScratchFrameMorph getFont: #Label).
		label color: Color white.
		self addMorphBack: label].

	scriptNameMorph _ EventTitleMorph new.
! !


!WhenCloneHatBlock methodsFor: 'other' stamp: 'EMP 10/2/2015 22:08'!
asBlockTuple
	"Answer a tuple (Array) describing this block and its event name."

	^ Array with: #whenCloned
! !

!WhenCloneHatBlock methodsFor: 'other' stamp: 'EMP 10/2/2015 20:50'!
eventName
	"Answer the name of this script."

	^ scriptNameMorph eventName
! !

!WhenCloneHatBlock methodsFor: 'other' stamp: 'EMP 10/2/2015 20:50'!
eventName: aString
	"Set my event name. Used for initialization."

	scriptNameMorph eventName: aString.
	self fixBlockLayout.
	(self ownerThatIsA: ScratchViewerMorph) ifNotNil:[
		(self ownerThatIsA: ScratchViewerMorph) updateContents].
! !

!WhenCloneHatBlock methodsFor: 'other' stamp: 'EMP 10/2/2015 20:50'!
helpScreenName
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	(self isKindOf: MouseClickEventHatMorph) ifTrue: [^ 'mouseclickHat'].
	(self isKindOf: KeyEventHatMorph) ifTrue: [^ 'keyHat'].
	self eventName = 'Scratch-StartClicked'
		ifTrue: [^ 'startHat']
		ifFalse: [^ 'broadcastHat'].

	^ nil
! !

!WhenCloneHatBlock methodsFor: 'other' stamp: 'EMP 4/26/2016 16:46'!
isWhenCloneHat
	^ true! !

!WhenCloneHatBlock methodsFor: 'other' stamp: 'EMP 10/2/2015 20:50'!
printHatNameOn: aStream
	"Append a human-readable string for this hat block's name to the given stream."

	| evtName |
	evtName _ self eventName.
	evtName = 'Scratch-StartClicked'
		ifTrue: [aStream nextPutAll: 'when green flag clicked']
		ifFalse: [aStream nextPutAll: 'when I receive "', evtName, '"'].
	aStream cr.

! !

!WhenCloneHatBlock methodsFor: 'other' stamp: 'EMP 10/2/2015 21:29'!
startForEvent: aScratchEvent
	"Starts a process for this event hat triggered by the given event. Answer the process that was started or nil if no new process was started."
	"Details: The current policy is to stop and re-start the script for all events except key-pressed. Key-pressed events are just ignored if the script for that event is already running."

	| stage |
	(aScratchEvent name = 'Scratch-StartedAsClone') ifTrue: [
	self hasRunningProcess ifTrue: [^ nil].  "don't re-trigger if running"

	scriptOwner ifNil: [^ nil].
	(stage _ scriptOwner ownerThatIsA: ScratchStageMorph) ifNil: [^ nil].
	scratchProc _ stage startProcessFor: self.
	self changed.
	^ scratchProc]
! !
