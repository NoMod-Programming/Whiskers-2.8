DialogBoxMorph subclass: #WorkSpaceDialogMorph
	instanceVariableNames: 'initialClass initialMethod resizeMorph resizeOffset pageViewerMorph '
	classVariableNames: 'Backpack UserPos UserSize '
	poolDictionaries: ''
	category: 'Scratch-UI-Panes'!

!WorkSpaceDialogMorph methodsFor: 'initialization' stamp: 'EMP 10/30/2015 12:20'!
initialize
	super initialize.
	WorkSpaceDialogMorph loadBackpack.
	Backpack ifNil: [self class initialize].
	self title: 'Backpack'.
	pageViewerMorph _ ScrollFrameMorph2 new growthFraction: 0.1;
			 color: ScratchFrameMorph scriptsPaneColor;
			 contents: Backpack.
	pageViewerMorph position: 36@55.
	mainColumn hResizing: #rigid; vResizing: #rigid.
	mainColumn addMorph: pageViewerMorph.
	resizeMorph _ ScratchResizeMorph ofType: #corner.
	self addMorph: resizeMorph.
	self
		withButtonsForYes: false
		no: false
		okay: true
		cancel: false! !


!WorkSpaceDialogMorph methodsFor: 'accessing' stamp: 'EMP 10/1/2015 15:40'!
currentCategory
	^ 'Scripts'! !

!WorkSpaceDialogMorph methodsFor: 'accessing' stamp: 'EMP 10/1/2015 15:41'!
extent: aPoint 
	| w newExtent min |
	min _ self class minExtent.
	newExtent _ aPoint max: min.
	bounds extent = newExtent
		ifFalse: 
			[self changed.
			bounds _ bounds topLeft extent: newExtent.
			self layoutChanged.
			self changed].
	self fixLayoutForExtent: newExtent.
	UserPos isNil & resizeOffset isNil
		ifTrue: 
			[w _ self world.
			w ifNotNil: [self position: w center - (self extent // 2)]].
	"center on screen"
	self keepOnScreen! !

!WorkSpaceDialogMorph methodsFor: 'accessing' stamp: 'EMP 10/1/2015 15:41'!
fixLayoutForExtent: aPoint 
	super fixLayoutForExtent: aPoint.
	titleBin ifNotNil: [titleBin width: aPoint x - 40].
	pageViewerMorph ifNil: [^ self].
	mainColumn extent: aPoint - (65 @30).
	pageViewerMorph extent: aPoint - (65 @ 30).
	self updateResizeMorph! !

!WorkSpaceDialogMorph methodsFor: 'accessing' stamp: 'EMP 10/1/2015 15:39'!
target
	^ 'nothing yet, just dummy text for the right button menu'! !

!WorkSpaceDialogMorph methodsFor: 'accessing' stamp: 'EMP 10/30/2015 12:21'!
yes
	"Yes button was pressed."
	self class saveBackpack.
	super yes.! !


!WorkSpaceDialogMorph methodsFor: 'right button menu' stamp: 'EMP 11/2/2015 20:43'!
scriptsMenu: aPosition
	"Present a menu of Scratch script operations."

	| menu choice |
	self target ifNil: [^ self].
	menu _ CustomMenu new.
	menu add: 'clean up' action: #cleanUp.
	menu add: 'save picture of scripts' action: #saveScriptsToImage.

	choice _ menu localize startUp.
	choice ifNil: [^ self].
	choice = #addComment:
		ifTrue: [Backpack perform: choice with: aPosition]
		ifFalse: [Backpack perform: choice].
! !


!WorkSpaceDialogMorph methodsFor: 'private' stamp: 'EMP 10/1/2015 15:41'!
centerOnScreen
	super centerOnScreen.
	self updateResizeMorph! !

!WorkSpaceDialogMorph methodsFor: 'private' stamp: 'EMP 10/1/2015 15:54'!
getUserResponse
	"Wait for the user to respond, then report their response. The symbol  
	#cancel is returned if the user wishes to cancel the operation.  
	True/false is returned if they respond yes/no, and a string is returned  
	if this this a string input dialog and they don't cancel."
	"Details: This is invoked synchronously from the caller. In order to keep  
	processing inputs and updating the screen while waiting for the user to 
	respond, this method has its own version of the World's event loop."
	| w |
	self openInWorld.
	UserPos isNil
		ifTrue: [self centerOnScreen]
		ifFalse: [self snapToUserDimensions].
	w _ self world.
	self buttons size > 0 ifTrue: [w activeHand newKeyboardFocus: self buttons last].
	tabFields size > 0 ifTrue: [w activeHand newKeyboardFocus: (tabFields at: 1)].
	done _ false.
	[done]
		whileFalse: [w doOneCycle].
	"wait for user to press a button"
	^ editor! !

!WorkSpaceDialogMorph methodsFor: 'private' stamp: 'EMP 10/1/2015 15:42'!
keepOnScreen
	| min |
	min _ self class minExtent.
	self left < 0 ifTrue: [self left: 0].
	self top < 0 ifTrue: [self top: 0].
	self right > Display extent x ifTrue: [resizeOffset
			ifNil: 
				[self left: (Display extent x - self width max: 0).
				(self right > Display extent x and: [self width > min x])
					ifTrue: [self width: Display extent x - self left]]
			ifNotNil: [self width: Display extent x - self left]].
	self bottom > Display extent y ifTrue: [resizeOffset
			ifNil: 
				[self top: (Display extent y - self height max: 0).
				(self bottom > Display extent y and: [self height > min y])
					ifTrue: [self height: Display extent y - self top]]
			ifNotNil: [self height: Display extent y - self top]]! !

!WorkSpaceDialogMorph methodsFor: 'private' stamp: 'EMP 10/1/2015 15:42'!
rememberUserDimensions
	self class setUserPos: self position size: self extent! !

!WorkSpaceDialogMorph methodsFor: 'private' stamp: 'EMP 10/1/2015 15:42'!
snapToUserDimensions

	self extent: UserSize.
	UserPos ifNotNil: [
		self position: UserPos ].
! !


!WorkSpaceDialogMorph methodsFor: 'event handling' stamp: 'EMP 10/1/2015 15:41'!
handlesMouseDown: evt 
	^ true! !

!WorkSpaceDialogMorph methodsFor: 'event handling' stamp: 'EMP 10/1/2015 15:42'!
justDroppedInto: aMorph event: evt
	"Never embed myself in a morph (e.g. the Stage)."

	super justDroppedInto: aMorph event: evt.
	self keepOnScreen
! !

!WorkSpaceDialogMorph methodsFor: 'event handling' stamp: 'EMP 10/1/2015 15:42'!
mouseDown: evt 
	"Handle a mouse click. Left button either drags or performs click action. 
	Right button brings up a menu."
	| p |
	p _ evt cursorPoint.
	((resizeMorph bounds expandBy: 4)
		containsPoint: p)
		ifTrue: [resizeOffset _ self bottomRight - p]
		ifFalse: [evt hand grabMorph: self]! !

!WorkSpaceDialogMorph methodsFor: 'event handling' stamp: 'EMP 10/1/2015 15:42'!
mouseMove: evt 
	resizeOffset ifNotNil: [self extent: evt cursorPoint - self topLeft + resizeOffset]! !

!WorkSpaceDialogMorph methodsFor: 'event handling' stamp: 'EMP 10/1/2015 15:42'!
mouseUp: evt

	resizeOffset _ nil.
! !

!WorkSpaceDialogMorph methodsFor: 'event handling' stamp: 'EMP 10/1/2015 15:42'!
updateResizeMorph
	resizeMorph ifNotNil: [resizeMorph position: self bottomRight - bottomRightForm width
		"resizeMorph extent -"]! !


!WorkSpaceDialogMorph methodsFor: 'stepping' stamp: 'EMP 10/1/2015 15:42'!
step
	resizeOffset notNil | (owner isKindOf: HandMorph) ifTrue: [^ self].
	self keepOnScreen.
	"pageViewerMorph position: self topLeft + (20 @ 50).
	buttonRow position: pageViewerMorph bottomRight + (-50 @ 10)"! !

!WorkSpaceDialogMorph methodsFor: 'stepping' stamp: 'EMP 10/1/2015 15:43'!
stepTime
	^ 0! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WorkSpaceDialogMorph class
	instanceVariableNames: ''!

!WorkSpaceDialogMorph class methodsFor: 'initialization' stamp: 'EMP 10/30/2015 12:16'!
initialize
	"BlockEditorFrameMorph initialize"
	self resetDimensions.
	Backpack _ WorkspaceMorph new.
	Backpack extent: 350 @ 370.
	Backpack position: 10 @ 10.
	Backpack color: (Color
			r: 0.486
			g: 0.501
			b: 0.513)! !

!WorkSpaceDialogMorph class methodsFor: 'initialization' stamp: 'EMP 10/1/2015 15:26'!
minExtent
	^ 600 @ 430.! !

!WorkSpaceDialogMorph class methodsFor: 'initialization' stamp: 'EMP 10/1/2015 15:53'!
new
	| t1 |
	t1 _ super new.
	t1 extent: 150 @ 100.
	^ t1 getUserResponse.! !

!WorkSpaceDialogMorph class methodsFor: 'initialization' stamp: 'EMP 10/21/2014 14:23'!
resetDimensions
	UserPos _ nil.
	UserSize _ self minExtent.! !

!WorkSpaceDialogMorph class methodsFor: 'initialization' stamp: 'EMP 10/21/2014 14:23'!
setUserPos: aPoint size: anExtent
	UserPos _ aPoint.
	UserSize _ anExtent.! !


!WorkSpaceDialogMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:15'!
backpack
	^ Backpack! !

!WorkSpaceDialogMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:16'!
blockFromSpec: t1 color: t2 
	^ ScriptableScratchMorph new blockFromSpec: t1 color: t2! !

!WorkSpaceDialogMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:16'!
convertStacksToTuples
	Backpack blocks: #().
	Backpack submorphs do: [:t1 | (t1 isKindOf: BlockMorph)
			ifTrue: 
				[Backpack blocks: Backpack blocks , {{t1 position - Backpack position. t1 tupleSequence}}.
				t1 delete]]! !

!WorkSpaceDialogMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:16'!
convertTuplesToStacks
	| t1 t2 |
	(Backpack blocks isKindOf: Array)
		ifFalse: [^ self].
	t1 _ Backpack blocks.
	t1 do: 
		[:t3 | 
		t2 _ self stackFromTupleList: t3 second receiver: self.
		t2 position: t3 first.
		Backpack addMorph: t2]! !

!WorkSpaceDialogMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:16'!
extractBackpackFrom: t1 
	| t2 t3 t4 |
	t2 _ ReadStream on: t1.
	t3 _ ObjStream scratchFileVersionFrom: (t2 next: 10) asString.
	t3 = 0
		ifTrue: 
			[t2 position: 0.
			t4 _ ObjStream new readObjFrom: t2 showProgress: true].
	t3 = 1 | (t3 = 2)
		ifTrue: 
			[t2 skip: t2 uint32.
			t4 _ ObjStream new readObjFrom: t2 showProgress: true].
	t4 class = WorkspaceMorph
		ifFalse: 
			[t3 > 2
				ifTrue: [self error: 'Backpack created by a later version of Scratch']
				ifFalse: [self error: 'Problem reading backpack.'].
			^ nil].
	^ t4! !

!WorkSpaceDialogMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 12/12/2015 13:42'!
loadBackpack
	
	| temp |
	Backpack delete.	
	temp _ (FileStream readOnlyFileNamedOrNil: 'backpack.bpk').
	temp ifNil: [^ self].
	Backpack _ self extractBackpackFrom: temp binary contentsOfEntireFile.
	temp close.
	Backpack extent: 350 @ 370.
	Backpack position: 10 @ 10.
	Backpack color: (Color
			r: 0.486
			g: 0.501
			b: 0.513).
	self convertTuplesToStacks! !

!WorkSpaceDialogMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:22'!
open
	| t1 |
	t1 _ super new
				withButtonsForYes: false
				no: false
				okay: true
				cancel: false.
	^ t1 getUserResponse! !

!WorkSpaceDialogMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 11/2/2015 20:38'!
saveBackpack
	| t1 |
	self convertStacksToTuples.
	(FileDirectory default) deleteFileNamed: 'backpack.bpk'.
	t1 _ FileStream newFileNamed: 'backpack.bpk'.
	t1 binary.
	ObjStream new storeObj: Backpack on: t1.! !

!WorkSpaceDialogMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:17'!
stackFromTupleList: t1 receiver: t2 
	| t3 t4 t5 t6 |
	t3 _ t4 _ nil.
	t6 _ ScriptableScratchMorph new.
	t1 do: 
		[:t7 | 
		t5 _ t6 blockFromTuple: t7 receiver: t2.
		t4 ifNil: [t3 _ t5]
			ifNotNil: [t4 nextBlock: t5].
		t4 _ t5].
	^ t3! !


WorkSpaceDialogMorph initialize!
