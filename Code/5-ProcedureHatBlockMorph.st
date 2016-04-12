WhenHatBlockMorph subclass: #ProcedureHatBlockMorph
	instanceVariableNames: 'spec parameterNames isAtomic block vars runningMouse '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!ProcedureHatBlockMorph commentStamp: 'EMP 11/10/2015 15:14' prior: 0!
This is a hatblockmorph subclass that contains another blockmorph (that is immobille), which I can drag parameters out of to use in a script. I honestly don't know why it is a subclass of WhenHatBlockMorph, but it breaks if I change it (at least for me).!


!ProcedureHatBlockMorph methodsFor: 'initialization' stamp: 'EMP 12/12/2015 13:11'!
initialize
	super initialize.
	self removeAllMorphs.
	runningMouse _ false.
	parameterNames _ OrderedCollection new.
	self addMorphBack: ((StringMorph contents: ('define ' localized) font: ((ScratchFrameMorph getFont: #Label))) color: Color white).
	self addMorphBack: (block _ ((AlignmentMorph new color: Color transparent) addMorphBack: (CustomProcedureHolder new commandSpec: ''; color: (Color r: 99/255 g: 45/255 b: 153/255) lighter; isMobile: false))).
	self color: (Color r: 99/255 g: 45/255 b: 153/255)! !

!ProcedureHatBlockMorph methodsFor: 'initialization' stamp: 'EMP 11/8/2015 11:23'!
isAtomic: aBoolean
	isAtomic _ aBoolean! !

!ProcedureHatBlockMorph methodsFor: 'initialization' stamp: 'EMP 11/8/2015 14:27'!
params: aCollection
	parameterNames _ aCollection.
	block ifNotNil: [
	(block submorphs) size > 0 ifTrue: [block submorphs first parameterNames: aCollection]]! !

!ProcedureHatBlockMorph methodsFor: 'initialization' stamp: 'EMP 1/12/2016 16:05'!
spec: specString
	| temp |
	spec _ specString.
	(temp _ self nextBlock).
	self removeAllMorphs.
	self addMorphBack: ((StringMorph contents: ('define ' localized) font: ((ScratchFrameMorph getFont: #Label))) color: Color white).
		self addMorphBack: (block _ ((AlignmentMorph new color: Color transparent) addMorphBack: (CustomProcedureHolder new parameterNames: parameterNames; commandSpec: specString; color: (Color r: 89/255 g: 71/255 b:177/255) lighter; isMobile: false))).
	temp ifNotNil: [self addMorphBack: temp].! !


!ProcedureHatBlockMorph methodsFor: 'accessing' stamp: 'EMP 11/8/2015 14:24'!
asBlockTuple
	^ {#procDef. spec. (self findArgs). (self defaultNames). isAtomic}! !

!ProcedureHatBlockMorph methodsFor: 'accessing' stamp: 'EMP 11/8/2015 15:06'!
defaultNames
	| result |
	result _ OrderedCollection new.
	((CommandBlockMorph parseCommandSpec: spec) select: [:s | BlockCreatorMorph isArgSpec: s]) do: [:arg | (arg = '%b') ifTrue: [result add: false] ifFalse: [(arg = '%s') ifTrue: [result add: ''] ifFalse: [result add: '10']]].
	^ result asArray! !

!ProcedureHatBlockMorph methodsFor: 'accessing' stamp: 'EMP 11/23/2015 14:13'!
editCustomBlock
	| resultArray |
	resultArray _ ((BlockCreationDialog forCustomBlock: {spec. self findArgs. isAtomic}) getUserResponse).
	resultArray = false ifTrue: [^ self beep].
	self spec: resultArray first first.
	self params: resultArray first second.
	self isAtomic: resultArray second.! !

!ProcedureHatBlockMorph methodsFor: 'accessing' stamp: 'EMP 11/8/2015 11:29'!
findArgs
	^ parameterNames asArray! !

!ProcedureHatBlockMorph methodsFor: 'accessing' stamp: 'EMP 2/25/2016 16:26'!
isAtomic
	^ (isAtomic = true) & (runningMouse = false)! !

!ProcedureHatBlockMorph methodsFor: 'accessing' stamp: 'EMP 11/8/2015 14:01'!
procedure
	^ (block submorphs first commandSpec)! !

!ProcedureHatBlockMorph methodsFor: 'accessing' stamp: 'EMP 11/16/2015 16:12'!
rightButtonMenu

	| menu choice |
	menu _ CustomMenu new.
	menu add: 'delete' action: #delete.
	menu addLine.
	menu add: 'add comment' action: #addComment.
	menu add: 'help' action: #presentHelpScreen.
	menu add: 'edit' action: #editCustomBlock.

	DebugMenu ifTrue: [
		menu addLine.
		menu add: 'show tuples' action: #showTuples].
	
	(choice _ menu localize; startUp) ifNil: [^ self] ifNotNil: [^ self perform: choice]
! !


!ProcedureHatBlockMorph methodsFor: 'private-evaluation' stamp: 'EMP 1/8/2016 07:53'!
drawArchOn: aCanvas 
	| diameter rawForm newForm |
	"The formula for getting the radius of a circle given the explained values is this:
	r = ((c*c) + 4(x*x)) / (8x)
	where r is the radius, x is the length from the midpoint to the circumference, and c is the chord length"


	"NOTE: Since the height is fixed, I premade some of the calculations to make it quicker"
	diameter _ (((self width * self width) + 1764) / 84). "remember that the diameter is the radius * 2"
	
	rawForm _ (EllipseMorph new extent: (diameter@diameter); color: (color); borderColor: (Color r: 142/255 g: 46/255 b: 194/255); borderWidth: 3) imageForm.

	newForm _ rawForm copy: ((((diameter - bounds width) / 2) @ 0) extent: ((bounds width) @ 25)).

	aCanvas paintImage: newForm at: self topLeft.! !

!ProcedureHatBlockMorph methodsFor: 'private-evaluation' stamp: 'EMP 1/7/2016 18:55'!
drawBodyOn: aCanvas 

	| archBottom |
	archBottom _ self top + self hatTopForm.

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

!ProcedureHatBlockMorph methodsFor: 'private-evaluation' stamp: 'EMP 1/12/2016 16:06'!
fixBlockLayout
	"Update the positions of my submorphs."

	| x centerY nextB |
	argMorph ifNil: [^ self].  "happens during initialization"

	blockLayoutNeeded ifFalse: [^ self].
	cachedForm _ nil.
	cachedFeedbackForm _ nil.


	self height: 20 + block height.

	x _ self left + 8.
	centerY _ bounds center y + 5.
	self nonControlFlowSubmorphs do: [:m |
		m position: x@(centerY - (m height // 2)).
		x _ x + m width + 5].

	self width: (((x + 4) - self left)).

	(nextB _ self nextBlock) ifNotNil: [
		nextB top: self bottom - 4.
		ScratchTranslator isRTL
			ifTrue: [nextB right: self right]
			ifFalse: [nextB left: self left].
		nextB fixBlockLayout].
! !

!ProcedureHatBlockMorph methodsFor: 'private-evaluation' stamp: 'EMP 1/12/2016 15:50'!
getArgumentOrNil: selector
	^ vars at: selector ifAbsent: [nil]! !

!ProcedureHatBlockMorph methodsFor: 'private-evaluation' stamp: 'EMP 1/7/2016 20:27'!
hatTopForm
	^ 21! !

!ProcedureHatBlockMorph methodsFor: 'private-evaluation' stamp: 'EMP 12/12/2015 13:11'!
start

	| stage |
	self stop.
	scratchProc ifNil: [
		runningMouse _ true.
		scriptOwner ifNil: [^ self].
		(stage _ self receiver ownerThatIsA: ScratchStageMorph) ifNil: [^ self].
		scratchProc _ stage startProcessFor: self.
		self changed].
! !

!ProcedureHatBlockMorph methodsFor: 'private-evaluation' stamp: 'EMP 4/5/2016 12:07'!
startForEvent: t1 args: t2 
	| stageMorph |
	t1 name = 'Scratch-KeyPressedEvent' ifFalse: [scratchProc ifNotNil: [self stop]].
	vars _ Dictionary new.
	(self findArgs) do: [:arg | vars at: arg put: (t2 at: (self findArgs indexOf: arg))].
	scriptOwner ifNil: [^ nil].
	(stageMorph _ scriptOwner ownerThatIsA: ScratchStageMorph) ifNil: [^ nil].
	scratchProc _ stageMorph startProcessFor: self fullCopy.
	self changed.
	^ scratchProc! !

!ProcedureHatBlockMorph methodsFor: 'private-evaluation' stamp: 'EMP 12/12/2015 13:12'!
stop

	scratchProc ifNotNil: [
		runningMouse _ false.
		self changed.
		scratchProc stop.
		scratchProc _ nil].
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ProcedureHatBlockMorph class
	instanceVariableNames: ''!

!ProcedureHatBlockMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 11/8/2015 14:26'!
fromSpec: specString params: paramCollection isAtomic: aBoolean
	| result |
	result _ self new.
	result params: paramCollection; spec: specString; isAtomic: aBoolean.
	^ result! !

!ProcedureHatBlockMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 10/7/2015 12:17'!
test
	"ProcedureHatBlockMorph test"
	^ self new openInWorld! !
