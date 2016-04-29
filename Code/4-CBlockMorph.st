CommandBlockMorph subclass: #CBlockMorph
	instanceVariableNames: 'nestedBlock nextBlock topBarBottom blockBottom loopMorph stretchHeight '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!CBlockMorph commentStamp: 'jm 12/7/2002 16:07' prior: 0!
I am a command block that contains a nested sequence of command blocks, such as a loop.
!


!CBlockMorph methodsFor: 'initialization' stamp: 'ee 7/10/2008 13:19'!
initialize

	super initialize.
	self color: (Color r: 1.0 g: 0.581 b: 0.194).
	stretchHeight _ 0.
! !


!CBlockMorph methodsFor: 'accessing' stamp: 'ee 7/11/2008 22:23'!
bracketThickness

	^ CBlockBracketThickness
! !

!CBlockMorph methodsFor: 'accessing' stamp: 'ee 7/11/2008 22:23'!
nestedBlockAt: aPoint

	^ nestedBlock
! !

!CBlockMorph methodsFor: 'accessing' stamp: 'jm 11/29/2006 12:22'!
topBarHeight
	"Answer the height of the top bar."

	| nonBlockSubmorphs |
	nonBlockSubmorphs _ self submorphs select: [:m |
		(m isKindOf: BlockMorph) not or: [argMorphs includes: m]].
	^ nonBlockSubmorphs inject: CBlockBracketThickness into: [:h :m | h max: (m height + 4)].

! !


!CBlockMorph methodsFor: 'drawing' stamp: 'EMP 4/21/2016 09:15'!
drawBottomBarOn: aCanvas 

	| left barTop barBottom |
	self isForever
		ifTrue: [
			barBottom _ self bottom - 3.
			self drawSmoothBottomEdgeOn: aCanvas]
		ifFalse: [
			barBottom _ self bottom - 7.
			self drawBottomEdgeOn: aCanvas].


	barTop _ barBottom - (CBlockBracketThickness - 3).
	left _ self left + CBlockBracketThickness - 1.

	"fill in bottom-left corner"
	aCanvas fillRectangle: (left@(barTop - 2) extent: 1@1) color: color.
	aCanvas fillRectangle: (left@(barTop - 1) extent: 2@1) color: color.
	aCanvas fillRectangle: (left@barTop extent: 3@1) color: color.

	aCanvas
		fillRectangle: ((left + 3)@barTop corner: (self right - 2)@(barTop + 1))
		color: highlightColor1.
	aCanvas
		fillRectangle: (left@(barTop + 1) corner: (self right - 1)@barBottom)
		color: color.
	aCanvas
		fillRectangle: ((self right - 1)@(barTop + 2) corner: self right@barBottom)
		color: shadowColor.


! !

!CBlockMorph methodsFor: 'drawing' stamp: 'EMP 4/21/2016 09:16'!
drawInnerTopY: y on: aCanvas

	| left right gapStart gapEnd |
	left _ CBlockBracketThickness - 1.
	right _ self width - 1.
	gapStart _ left + PuzzleInset + 1.
	gapEnd _ gapStart + PuzzleWidth.

	self drawHLineFrom: left to: (right - 1) y: y color: color on: aCanvas.
	self drawHLineFrom: left to: (right - 2) y: y + 1 color: color on: aCanvas.

	"fill in upper-left inside corner"
	self drawHLineFrom: left to: (left + 2) y: y + 2 color: color on: aCanvas.
	self drawHLineFrom: left to: (left + 1) y: y + 3 color: color on: aCanvas.
	self drawPoint: (left + 1)@(y + 3) color: shadowColor on: aCanvas.

	self drawHLineFrom: gapStart to: gapEnd y: y + 2 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 1 to: gapEnd - 1 y: y + 3 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 1 to: gapEnd - 1 y: y + 4 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 2 to: gapEnd - 2 y: y + 5 color: color on: aCanvas.

	self drawHLineFrom: (left + 2) to: gapStart y: y + 2 color: shadowColor on: aCanvas.
	self drawHLineFrom: gapEnd to: right - 2 y: y + 2 color: shadowColor on: aCanvas.
	self drawHLineFrom: gapStart + 2 to: gapEnd - 2 y: y + 6 color: shadowColor on: aCanvas.

	self drawPoint: gapStart@(y + 3) color: shadowColor on: aCanvas.
	self drawPoint: gapStart@(y + 4) color: shadowColor on: aCanvas.
	self drawPoint: (gapStart + 1)@(y + 5) color: shadowColor on: aCanvas.

	self drawPoint: (gapEnd - 1)@(y + 3) color: shadowColor on: aCanvas.
	self drawPoint: (gapEnd - 1)@(y + 4) color: shadowColor on: aCanvas.
	self drawPoint: (gapEnd - 2)@(y + 5) color: shadowColor on: aCanvas.

	self drawPoint: (right - 1)@y color: shadowColor on: aCanvas.
	self drawPoint: (right - 2)@(y + 1) color: shadowColor on: aCanvas.

! !

!CBlockMorph methodsFor: 'drawing' stamp: 'ee 3/5/2008 16:15'!
drawOn: aCanvas 

	| c |
	topBarBottom _ self top + self topBarHeight.
	self isForever
		ifTrue: [blockBottom _ self bottom - 3]
		ifFalse: [blockBottom _ self bottom - 7].

	self computeHighlightColors.
	c _ FormCanvas extent: self extent depth: 32.
	c _ c copyOffset: self topLeft negated.
	self drawTopEdgeOn: c.
	self drawTopBarOn: c.
	self drawVerticalBarOn: c.
	self drawBottomBarOn: c.

	self drawFinalOn: aCanvas fromCanvas: c.
! !

!CBlockMorph methodsFor: 'drawing' stamp: 'EMP 4/26/2016 15:33'!
drawTopBarOn: aCanvas 

	| left right y gapStart gapEnd |

	aCanvas fillRectangle: (self left @ (self top + 5) corner: self right - 2 @ topBarBottom)
		color: color.
	aCanvas fillRectangle: (self right - 2@(self top + 5) corner: self right - 1 @ topBarBottom)
		color: (Color black mixed: 0.11 with: color).
	aCanvas fillRectangle: (self right - 1@(self top + 5) corner: self right @ topBarBottom)
		color: (Color black mixed: 0.06 with: color).


	left _ CBlockBracketThickness - 1.
	right _ self width - 1.
	y _ topBarBottom - self top.
	gapStart _ left + PuzzleInset + 1.
	gapEnd _ gapStart + PuzzleWidth.

	self drawHLineFrom: left to: (right - 1) y: y color: color on: aCanvas.
	self drawHLineFrom: left to: (right - 2) y: y + 1 color: (Color black mixed: 0.06 with: color) on: aCanvas.
	self drawHLineFrom: left to: (right - 3) y: y + 2 color: (Color black mixed: 0.11 with: color) on: aCanvas.

	"fill in upper-left inside corner"
	self drawHLineFrom: left to: (left + 2) y: y + 2 color: (Color black mixed: 0.11 with: color) on: aCanvas.
	self drawHLineFrom: left to: (left + 1) y: y + 3 color: color on: aCanvas.
	self drawPoint: (left + 1)@(y + 3) color: (Color black mixed: 0.11 with: color) on: aCanvas.

	self drawHLineFrom: gapStart - 2 to: gapEnd + 2 y: y + 1 color: color on: aCanvas.
	self drawHLineFrom: gapStart - 1 to: gapEnd + 1 y: y + 2 color: color on: aCanvas.
	self drawHLineFrom: gapStart to: gapEnd y: y + 3 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 1 to: gapEnd - 1 y: y + 4 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 2 to: gapEnd - 2 y: y + 5 color: (Color black mixed: 0.11 with: color) on: aCanvas.

	self drawPoint: (gapStart - 1@(y+3)) color: (Color black mixed: 0.11 with: color) on: aCanvas.
	self drawPoint: (gapStart@(y+4)) color: (Color black mixed: 0.11 with: color) on: aCanvas.
	self drawPoint: (gapStart + 1@(y+5)) color: (Color black mixed: 0.11 with: color) on: aCanvas.
	self drawPoint: (gapEnd@(y+3)) color: (Color black mixed: 0.11 with: color) on: aCanvas.
	self drawPoint: (gapEnd - 1@(y+4)) color: (Color black mixed: 0.11 with: color) on: aCanvas.
	self drawPoint: (gapEnd - 2@(y+5)) color: (Color black mixed: 0.11 with: color) on: aCanvas.
! !

!CBlockMorph methodsFor: 'drawing' stamp: 'EMP 4/22/2016 14:36'!
drawVerticalBarOn: aCanvas 

	| left top barRight |
	left _ self left.
	barRight _ (left + CBlockBracketThickness).
	top _ self top.
	
	aCanvas
		fillRectangle: ((left + 2)@(top + 5) corner: barRight@blockBottom)
		color: color.

	aCanvas
		fillRectangle: ((left)@(top + 5) corner: (left + 1)@blockBottom)
		color: (Color white mixed: 0.13 with: color).
	aCanvas
		fillRectangle: ((left + 1)@(top + 5) corner: (left + 2)@blockBottom)
		color: (Color white mixed: 0.06 with: color).


	aCanvas 
		fillRectangle: ((barRight - 2)@(topBarBottom + 4) corner: ((barRight - 1)@blockBottom))
		color: (Color black mixed: 0.06 with: color).
	aCanvas 
		fillRectangle: ((barRight - 1)@(topBarBottom + 4) corner: ((barRight)@blockBottom))
		color: (Color black mixed: 0.15 with: color).
! !

!CBlockMorph methodsFor: 'drawing' stamp: 'ee 7/10/2008 20:59'!
fixBlockLayout
	"Update the positions of my submorphs."

	| oldExtent newW newH f |
	blockLayoutNeeded ifFalse: [^ self].
	super fixBlockLayout.

	"fix nestedBlock and nextBlock in case they've been removed from me"
	(nestedBlock notNil and: [nestedBlock owner ~~ self]) ifTrue: [nestedBlock _ nil].
	(nextBlock notNil and: [nextBlock owner ~~ self]) ifTrue: [nextBlock _ nil].

	oldExtent _ self extent.
	newW _ oldExtent x max: 40.
	newH _ self topBarHeight + CBlockBracketThickness.
	self isForever ifFalse: [newH _ newH + 4].

	nestedBlock
		ifNil: [newH _ newH + 14]
		ifNotNil: [
			stretchHeight _ 0.
			nestedBlock fixBlockLayout.
			newH _ newH + nestedBlock fullBounds height - 1.
			ScratchTranslator isRTL
				ifTrue: [nestedBlock position: self topRight - ((CBlockBracketThickness + nestedBlock width)@0)
					+ (0@(self topBarHeight + 3))]
				ifFalse: [nestedBlock position: self position + (CBlockBracketThickness@(self topBarHeight + 3))].
			nestedBlock blockSequence last isStopOrForever ifTrue: [newH _ newH + 4]].
	self extent: newW@newH + (0@stretchHeight).
	ScratchTranslator isRTL ifTrue: [
		self left: self left + (oldExtent x - newW)].

	"position loop morph"
	loopMorph ifNotNil: [
		f _ ScratchFrameMorph skinAt: #loopIcon.
		ScratchTranslator isRTL
			ifTrue: [loopMorph form: (f flipBy: #horizontal centerAt: f center)]
			ifFalse: [loopMorph form: f].
		self isForever
			ifTrue: [ScratchTranslator isRTL
				ifTrue: [loopMorph position: self bottomLeft + (4@0) - (0@(loopMorph height + 2))]
				ifFalse: [loopMorph position: self bottomRight - loopMorph extent - (4@2)]]
			ifFalse: [ScratchTranslator isRTL
				ifTrue: [loopMorph position: self bottomLeft + (4@0) - (0@(loopMorph height + 6))]
				ifFalse: [loopMorph position: self bottomRight - loopMorph extent - (4@6)]]].

	nextBlock ifNotNil: [
		ScratchTranslator isRTL
			ifTrue: [nextBlock position: (self right - nextBlock width)@(self bottom - 4)]
			ifFalse: [nextBlock position: self left@(self bottom - 4)]].
! !


!CBlockMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 19:04'!
fieldsVersion

	^ 1
! !

!CBlockMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 19:05'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		nestedBlock
		nextBlock
	) from: anObjStream.
! !

!CBlockMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 19:05'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		nestedBlock
		nextBlock
	) on: anObjStream.
! !


!CBlockMorph methodsFor: 'private' stamp: 'ee 6/19/2008 11:18'!
addCommandIcons
	"Add additional icons to certain blocks. Do nothing if this isn't one of those blocks."

	| f |
	super addCommandIcons.

	(#(doForever doForeverIf doRepeat doUntil) includes: selector) ifTrue: [
		f _ ScratchFrameMorph skinAt: #loopIcon ifAbsent: [^ self].
		loopMorph _ ImageMorph new form: f.
		self addMorphBack: loopMorph].
! !

!CBlockMorph methodsFor: 'private' stamp: 'ee 2/28/2009 16:10'!
asBlockTuple
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple arg argList |
	blockTuple _ Array new: argMorphs size + 2.
	blockTuple at: 1 put: selector.

	argList _ argMorphs.
	argList _ self organizeArgs: argList.
	1 to: argList size do: [:i |
		arg _ argList at: i.
		(arg isKindOf: ArgMorph)
			ifTrue: [blockTuple at: i + 1 put: arg evaluate]
			ifFalse: [blockTuple at: i + 1 put: arg asBlockTuple]].

	nestedBlock
		ifNil: [blockTuple at: blockTuple size put: nil]
		ifNotNil: [blockTuple at: blockTuple size put: nestedBlock tupleSequence].

	^ blockTuple
! !

!CBlockMorph methodsFor: 'private' stamp: 'jm 4/3/2005 16:01'!
attachBlock: aBlockMorph
	"Attach the given block to me. Assume the block has been positioned correctly."

	self addMorph: aBlockMorph.
	aBlockMorph top >= (self bottom - CBlockBracketThickness)
		ifTrue: [nextBlock _ aBlockMorph]
		ifFalse: [nestedBlock _ aBlockMorph].
! !

!CBlockMorph methodsFor: 'private' stamp: 'jens 8/29/2008 12:21'!
attachBlockNested: aBlockMorph
	"Attach the given block to me. Assume the block has been positioned correctly."

	(stretchHeight = 0)
			ifTrue: [self position: (aBlockMorph left)@(aBlockMorph top - self height + 4)].
	self addMorph: aBlockMorph.
	(stretchHeight = 0)
		ifTrue: [self bottomBlock nextBlock: aBlockMorph]
		ifFalse: [nestedBlock _ aBlockMorph].
! !

!CBlockMorph methodsFor: 'private' stamp: 'ee 3/5/2008 16:37'!
blockAttachPoints: aSet
	"Answer a collection of possible attachment points for me. Each entry is an Association mapping a point to the morph to which a dropping command block could be attached."

	| result |

	result _ #().
	(self isKindOf: HatBlockMorph) ifFalse: [
		ScratchTranslator isRTL
			ifTrue: [result _ result copyWith: (self topRight -> self)]
			ifFalse: [result _ result copyWith: (self topLeft -> self)]].

	nestedBlock
		ifNil: [ScratchTranslator isRTL
			ifTrue: [result _ result copyWith: ((self topRight + (-12@(self topBarHeight + 7))) -> self)]
			ifFalse: [result _ result copyWith: ((self topLeft + (12@(self topBarHeight + 7))) -> self)]]
		ifNotNil: [nestedBlock blockAttachPoints: aSet].

	nextBlock
		ifNil: [self isStopOrForever ifFalse: [ScratchTranslator isRTL
			ifTrue: [result _ result copyWith: (self bottomRight -> self)]
			ifFalse: [result _ result copyWith: (self bottomLeft -> self)]]]
		ifNotNil: [nextBlock blockAttachPoints: aSet].

	aSet addAll: result.
! !

!CBlockMorph methodsFor: 'private' stamp: 'jm 8/24/2003 12:11'!
firstBlockList
	"Answer an array containing the block sequence for my first (and only) nested block. (An if-then-else block would have a second block list.)"

	nestedBlock
		ifNil: [^ #()]
		ifNotNil: [^ nestedBlock blockSequence].

! !

!CBlockMorph methodsFor: 'private' stamp: 'jm 3/23/2005 18:08'!
firstBlockList: aBlockMorph
	"Add the given block as my first nested block sequence. Delete the old nested blocks, if any."

	nestedBlock ifNotNil: [nestedBlock delete].
	nestedBlock _ aBlockMorph.
	aBlockMorph ifNotNil: [self addMorph: aBlockMorph].
! !

!CBlockMorph methodsFor: 'private' stamp: 'jm 10/20/2004 09:51'!
litUp: aBoolean
	"Overridden to suppress highlighting of control structures. Do nothing."! !

!CBlockMorph methodsFor: 'private' stamp: 'jm 3/20/2003 13:21'!
nextBlock
	"Answer the block myself in the block sequence or nil if I am the last block in the sequence. Each block is a submorph of the previous block."

	^ nextBlock
! !

!CBlockMorph methodsFor: 'private' stamp: 'jm 3/23/2005 18:08'!
nextBlock: aBlockMorph
	"Add the given block as the block following me. Delete old nextBlock, if any."

	self nextBlock ifNotNil: [self nextBlock delete].
	nextBlock _ aBlockMorph.
	aBlockMorph ifNotNil: [self addMorph: aBlockMorph].
! !

!CBlockMorph methodsFor: 'private' stamp: 'jm 11/29/2006 12:22'!
nonControlFlowSubmorphs
	"Answer a collection of submorphs minus any blocks that are part of the control flow. For example, command blocks omit their submorph that is the next block in the block sequence, C-blocks omit both their next block and the first block of their nested block list, etc."

	^ submorphs select: [:m | (m ~~ nestedBlock) & (m ~~ nextBlock)]
! !

!CBlockMorph methodsFor: 'private' stamp: 'jm 12/10/2005 11:04'!
printCodeOn: aStream indent: indent
	"Append a human-readable string for this block on the given stream."

	indent timesRepeat: [aStream nextPutAll: '    '].
	submorphs do: [:m |
		(m ~~ nestedBlock) & (m ~~ nextBlock) ifTrue: [
			self printCodeSubmorph: m on: aStream.
			aStream space]].
	aStream cr.
	nestedBlock ifNotNil: [nestedBlock printCodeOn: aStream indent: indent + 1].
	nextBlock ifNotNil: [nextBlock printCodeOn: aStream indent: indent].
! !


!CBlockMorph methodsFor: 'geometry' stamp: 'jm 3/29/2008 12:19'!
containsPoint: aPoint

	cachedForm ifNil: [self updateCachedForm].
	^ (self fullBounds containsPoint: aPoint) and:
	  [(cachedForm isTransparentAt: aPoint - self fullBounds origin) not]
! !

!CBlockMorph methodsFor: 'geometry' stamp: 'ee 7/11/2008 22:23'!
stretchHeight: aNumber

	(stretchHeight = aNumber) ifTrue: [^ self].
	stretchHeight _ aNumber.
	blockLayoutNeeded _ true.
	self fixBlockLayout.
! !
