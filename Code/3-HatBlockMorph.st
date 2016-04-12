BlockMorph subclass: #HatBlockMorph
	instanceVariableNames: 'scriptNameMorph indicatorMorph scriptOwner parameters isClickable '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!HatBlockMorph commentStamp: 'jm 3/28/2005 12:25' prior: 0!
I represent a script consisting of a sequence of blocks.

!


!HatBlockMorph methodsFor: 'initialization' stamp: 'EMP 1/6/2016 15:12'!
initialize

	super initialize.
	self color: (Color r: 200/255 g: 131/255 b: 48/255).
	self extent: 92@38.
	scriptOwner _ nil.

	scriptNameMorph _ StringMorph new
		contents: 'script';
		font: (ScratchFrameMorph getFont: #Label);
		forceUnicodeRendering: true;
		color: Color white.
	self addMorph: scriptNameMorph.
! !


!HatBlockMorph methodsFor: 'accessing' stamp: 'jm 12/21/2008 12:22'!
isHatBlock

	^ true
! !

!HatBlockMorph methodsFor: 'accessing' stamp: 'jm 6/10/2004 10:47'!
receiver

	^ scriptOwner
! !

!HatBlockMorph methodsFor: 'accessing' stamp: 'jm 3/5/2003 16:52'!
scriptOwner

	^ scriptOwner
! !

!HatBlockMorph methodsFor: 'accessing' stamp: 'ee 3/6/2008 18:07'!
scriptOwner: anObject

	scriptOwner _ anObject.
	self fixBlockLayout.
! !


!HatBlockMorph methodsFor: 'drawing' stamp: 'EMP 1/6/2016 15:21'!
drawArchOn: aCanvas 

	| archForm stretchX leftForm midForm rightForm y x |
	archForm _ self hatTopForm.
	stretchX _ archForm width - 22.
	leftForm _ archForm copy: (0@0 corner: stretchX@archForm height).
	midForm _ archForm copy: (stretchX@0 extent: 1@archForm height).
	rightForm _ archForm copy: ((stretchX + 1)@0 corner: archForm extent).
	
	y _ self top.
	x _ self left.
	aCanvas paintImage: leftForm at: x@y.
	x _ x + leftForm width.
	(self width - (leftForm width + rightForm width)) asInteger timesRepeat: [
		aCanvas paintImage: midForm at: x@y.
		x _ x + 1].
	aCanvas paintImage: rightForm at: x@y.
! !

!HatBlockMorph methodsFor: 'drawing' stamp: 'EMP 1/7/2016 10:43'!
drawBodyOn: aCanvas 

	| archBottom |
	archBottom _ self top + self hatTopForm height.

	self drawArchOn: aCanvas.
	aCanvas
		fillRectangle: (self left@archBottom corner: (self right - 1)@(self bottom - 7))
		color: color.
	aCanvas
		fillRectangle: (self left@archBottom corner: (self left + 2)@(self bottom - 7))
		color: highlightColor2.

	aCanvas
		fillRectangle: ((self right - 1)@(archBottom -  1) corner: self right@(self bottom - 7))
		color: color slightlyDarker slightlyDarker.
! !

!HatBlockMorph methodsFor: 'drawing' stamp: 'ee 3/5/2008 16:11'!
drawOn: aCanvas 

	| c |
	self computeHighlightColors.
	c _ FormCanvas extent: self extent depth: 32.
	c _ c copyOffset: self topLeft negated.
	self drawBodyOn: c.
	self drawBottomEdgeOn: c.

	self drawFinalOn: aCanvas fromCanvas: c.
! !


!HatBlockMorph methodsFor: 'event handling' stamp: 'jm 12/30/2008 18:17'!
click: evt

	evt hand toolType = 'CutTool' ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		(owner isKindOf: ScratchBlockPaletteMorph) ifTrue: [^ self].  "ignore if in palette"
		ScratchFrameMorph putInClipboard: self.
		^ self stop; delete].

	super click: evt.
! !

!HatBlockMorph methodsFor: 'event handling' stamp: 'jm 3/28/2005 12:28'!
duplicate
	"Overridden to pick an unused script name for the duplicate."

	| m |
	m _ self fullCopy.
	scriptOwner ifNotNil: [m scriptOwner: scriptOwner].
	self world activeHand attachMorph: m.
! !


!HatBlockMorph methodsFor: 'processes' stamp: 'jm 12/21/2008 12:25'!
start

	| stage |
	self stop.
	scratchProc ifNil: [
		scriptOwner ifNil: [^ self].
		(stage _ self receiver ownerThatIsA: ScratchStageMorph) ifNil: [^ self].
		scratchProc _ stage startProcessFor: self.
		self changed].
! !


!HatBlockMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 19:07'!
fieldsVersion

	^ 1
! !

!HatBlockMorph methodsFor: 'object i/o' stamp: 'jm 3/28/2005 12:47'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		scriptNameMorph
		indicatorMorph
		scriptOwner
		parameters
		isClickable
	) from: anObjStream.
	parameters _ nil.  "procedures with parameters are no longer supported"

	"remove the indicator morph when reading in an older project"
	indicatorMorph ifNotNil: [
		submorphs _ submorphs copyWithout: indicatorMorph.
		indicatorMorph _ nil].
! !

!HatBlockMorph methodsFor: 'object i/o' stamp: 'jm 9/28/2003 18:16'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		scriptNameMorph
		indicatorMorph
		scriptOwner
		parameters
		isClickable
	) on: anObjStream.
! !


!HatBlockMorph methodsFor: 'private' stamp: 'ee 3/6/2008 14:55'!
blockAttachPoints: aSet
	"Answer a collection of possible attachment points for me. Each entry is an Association mapping a point to the morph to which a dropping block could be attached."

	| nextB |
	nextB _ self nextBlock.
	nextB
		ifNil: [ScratchTranslator isRTL
			ifTrue: [aSet add: (self bottomRight -> self)]
			ifFalse: [aSet add: (self bottomLeft -> self)]]
		ifNotNil: [nextB blockAttachPoints: aSet].
! !

!HatBlockMorph methodsFor: 'private' stamp: 'EMP 1/6/2016 15:51'!
fixBlockLayout
	"Update the positions of my submorphs."

	| x centerY nextB nonBlockSubmorphs oldExtent oldPos |
	blockLayoutNeeded ifFalse: [^ self].
	super fixBlockLayout.
	oldExtent _ self extent.
	oldPos _ self position.

	ScratchTranslator isRTL
		ifTrue: [x _ self right - 8]
		ifFalse: [x _ self left + 8].
	centerY _ self top + 25.
	self nonControlFlowSubmorphs do: [:m |
		(m isKindOf: ArgMorph) ifTrue: [m fixArgLayout].
		ScratchTranslator isRTL
			ifTrue: [m position: (x - m width)@(centerY - (m height // 2)). 
				x _ x - m width - 5]
			ifFalse: [m position: x@(centerY - (m height // 2)). 
				x _ x + m width + 5]].
	ScratchTranslator isRTL
		ifTrue: [x _ x - 4.
			self width: ((self right - x) max: self hatTopForm width)]
		ifFalse: [x + x + 4.
			self width: ((x - self left) max: self hatTopForm width)].
	ScratchTranslator isRTL ifTrue: [
		self left: oldPos x + (oldExtent x - self width)].

	nonBlockSubmorphs _ self submorphs select: [:m |
		(m isKindOf: BlockMorph) not or: [m isKindOf: ArgMorph]].
	self height: self hatTopForm height + (nonBlockSubmorphs inject: CBlockBracketThickness into: [:h :m | h max: (m height + 8)]).

	(nextB _ self nextBlock) ifNotNil: [
		ScratchTranslator isRTL
			ifTrue: [nextB right: self right]
			ifFalse: [nextB left: self left].
		nextB top: self bottom - 4.
		nextB fixBlockLayout].
! !

!HatBlockMorph methodsFor: 'private' stamp: 'EMP 1/6/2016 15:32'!
hatTopForm

	^ ((self color = (Color r: 212/255 g: 40/255 b: 40/255)) ifTrue: [ScratchFrameMorph skinAt: #hatBlockTopObsolete]
	ifFalse: [(self color = (Color r: 99/255 g: 45/255 b: 153/255)) ifTrue: [ScratchFrameMorph skinAt: #hatBlockTopCustom] ifFalse: [(self color = (Color r: 225/255 g: 169/255 b: 26/255)) ifTrue: [ScratchFrameMorph skinAt: #hatBlockTopControl] ifFalse: [ScratchFrameMorph skinAt: #hatBlockTop]]])! !

!HatBlockMorph methodsFor: 'private' stamp: 'jm 5/8/2007 11:16'!
mapReceiver: oldObj to: newObj
	"Used in cloning or importing to make blocks that refererred to the original object new refer to the new copy."

	scriptOwner == oldObj ifTrue: [scriptOwner _ newObj].
! !

!HatBlockMorph methodsFor: 'private' stamp: 'jm 12/10/2005 11:04'!
printCodeOn: aStream indent: indent
	"Append a human-readable string for this block on the given stream."

	indent timesRepeat: [aStream nextPutAll: '    '].
	self printHatNameOn: aStream.
	self nextBlock ifNotNil: [self nextBlock printCodeOn: aStream indent: indent + 1].
	indent timesRepeat: [aStream nextPutAll: '    '].
	aStream nextPutAll: 'end'; cr.
! !

!HatBlockMorph methodsFor: 'private' stamp: 'jm 12/8/2005 19:21'!
printHatNameOn: aStream
	"Append a human-readable string for this hat block's name to the given stream."

	aStream nextPutAll: 'to ', scriptNameMorph contents; cr.

! !
