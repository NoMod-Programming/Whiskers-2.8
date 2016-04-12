DialogBoxMorph subclass: #BlockCreationDialog
	instanceVariableNames: 'isAtomic block blockColumn blockParts blockPartsBin showHideButton isAtomicButton bin showingBin '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!BlockCreationDialog commentStamp: 'EMP 11/10/2015 15:08' prior: 0!
This is a subclass of DialogBoxMorph made to create custom blocks. Right now, its capabilities include block making, and adding parameters, even rhough those are handles by the BlockCreatorMorph (the "Block")!


!BlockCreationDialog methodsFor: 'initialization' stamp: 'EMP 4/7/2016 15:49'!
initialize
	| toggleButton labelText maxStringLength buttons label offForm onForm b final |

	"Dear people wishing to look at my code... I know that this is repetitive. I should fix it, but right now I am feeling too lazy to do so. So... you can fix it if you like"

	super initialize.
	block _ BlockCreatorMorph new commandSpec: '	'.
	blockColumn _ AlignmentMorph new color: Color transparent; addMorph: block.
	self title: 'New Block'.
	isAtomic _ false.
	showingBin _ true.
	blockParts _ OrderedCollection new.
	showHideButton _ AlignmentMorph new color: Color transparent.
	isAtomicButton _ AlignmentMorph new color: Color transparent.
	toggleButton _ ((ToggleButton
		onForm: (ScratchFrameMorph skinAt: #watcherButtonPressed)
		offForm: (ScratchFrameMorph skinAt: #watcherButton)) alphaOn: false).
	toggleButton target: self;
		actionSelector: #toggleAtomic;
		borderWidth: 0;
		setProperty: #balloonText toValue: 'Allows a block to run without making changes to the screen until it is done' localized.
	labelText _ StringMorph new contents: '  Run without screen refresh'; font: (ScratchFrameMorph getFont: #DialogBoxMessage).
	isAtomicButton addMorphBack: toggleButton; addMorphBack: (labelText position: (toggleButton topRight + (10@0))).
	showHideButton addMorphBack: ((toggleButton copy) onForm: (ScratchFrameMorph skinAt: #arrowOpenComment) offForm: (ScratchFrameMorph skinAt: #arrowClosedComment); actionSelector: #toggleBin; setProperty: #balloonText toValue: 'Show or hide additional options for this block'); addMorphBack: (StringMorph new contents: ' options'; font: (ScratchFrameMorph getFont: #DialogBoxMessage)).


	"find the longest string"
	maxStringLength _ 0.
	#('Add number input' 'Add string input' 'Add boolean input' 'Add color input' 'Add label text' 'Add dropdown input') do: [:m | maxStringLength _ (((ScratchTranslator stringExtent: m font: (ScratchFrameMorph getFont: #DialogBoxMessage)) x) max: maxStringLength)].
	maxStringLength _ maxStringLength + 20.
	

	"assemble the block builder"
	blockPartsBin _ AlignmentMorph newColumn
		color: Color transparent;
		centering: #center;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.
	buttons _ (#(
	('add number input' reporter)
	('add string input' string)
	('add boolean input' boolean)
	('add color input' color)
	('add dropdown input' dropdown)
	('add label text' text)
	) collect: [:pair | 
	label _ StringMorph contents: ((ScratchTranslator translationFor: pair first asString) capitalized) font: (ScratchFrameMorph getFont: #DialogBoxMessage).
	offForm _ (ScratchFrameMorph skinAt: (pair second, 'Button')).
	onForm _ (ScratchFrameMorph skinAt: (pair second, 'ButtonPressed')).
	b _ ResizableToggleButton2 new offForm: offForm onForm: onForm overForm: onForm.
	b target: self; actionSelector: #addParameter:; arguments: (Array with: pair second).
	b extent: 51@26.
	final _ AlignmentMorph new color: Color transparent; hResizing: #rigid; vResizing: #shrinkWrap; extent: ((maxStringLength + b width) @ (b height - 15)).
	final addMorph: (label position: 0@0); addMorphBack: (Morph new color: Color transparent; extent: (maxStringLength - label width)@5); addMorphBack: (b position: (maxStringLength@0)).
	b over; off.
	final]).
	
	buttons do: [:m | blockPartsBin addMorphBack: m].

	bin _ AlignmentMorph newColumn color: Color transparent.
	bin 
		addMorphBack: blockPartsBin;
		addMorphBack: isAtomicButton.

	mainColumn submorphsDo: [:m | 
		((m = messageLineMorphs) not) ifTrue: [m delete]].
	mainColumn
		addMorphBack: (Morph new extent: (5@6); color: Color transparent);
		addMorphBack: blockColumn;
		addMorphBack: (Morph new extent: (5@6); color: Color transparent);
		addMorphBack: showHideButton;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: bin;
		addMorphBack: (Morph new extent: (216@7); color: Color transparent);
		addMorphBack: buttonRow.
	bottomSpacer ifNil: [
		bottomSpacer _ (Morph new extent: (5@22); color: Color transparent).
		(shortcutColumn height > mainColumn height)
			ifTrue: [shortcutColumn addMorphBack: bottomSpacer]
			ifFalse: [(mainColumn height > fileInfoColumn height)
				ifTrue: [mainColumn addMorphBack: bottomSpacer]
				ifFalse: [fileInfoColumn addMorphBack: bottomSpacer]]].
	self extent: (385@175).
	self toggleBin.
	self extent: (385@175).! !


!BlockCreationDialog methodsFor: 'as yet unclassified' stamp: 'EMP 11/6/2015 22:03'!
addParameter: type
	block addParameter: type! !

!BlockCreationDialog methodsFor: 'as yet unclassified' stamp: 'EMP 11/16/2015 16:13'!
block
	^ block! !

!BlockCreationDialog methodsFor: 'as yet unclassified' stamp: 'EMP 11/5/2015 12:34'!
extent: aPoint
	super extent: aPoint.
	self fixLayout.! !

!BlockCreationDialog methodsFor: 'as yet unclassified' stamp: 'EMP 11/6/2015 21:31'!
fixLayout
	| xPos yPos shortcutWidth fileColumnWidth |
	shortcutColumn ifNil: [^ self].
	xPos _ self left + 20.
	yPos _ self top + 40.

	"position and size the shortcut column"
	shortcutColumn position: xPos@yPos.
	shortcutWidth _ 0.
	shortcutColumn submorphsDo: [: m |
		shortcutWidth _ m width max: shortcutWidth].
	shortcutColumn submorphsDo: [: m |
		m width: shortcutWidth].

	"position main column"
	mainColumn center: ((self width // 2) + self left)@(yPos + (mainColumn height // 2)).

	"position and size the fileInfo column"
	fileInfoColumn position: (mainColumn right + 5)@yPos.
	fileColumnWidth _ 0.
	fileInfoColumn submorphsDo: [: m |
		fileColumnWidth _ m width max: fileColumnWidth].
	fileInfoColumn submorphsDo: [: m |
		(m isKindOf: StringMorph)
			ifFalse: [m width: fileColumnWidth]].

	"position and size title"
	titleBin center: self center.
	titleBin top: self top.

	"add a bottom spacer to the tallest column"
	bottomSpacer ifNil: [
		bottomSpacer _ (Morph new extent: (5@22); color: Color transparent).
		(shortcutColumn height > mainColumn height)
			ifTrue: [shortcutColumn addMorphBack: bottomSpacer]
			ifFalse: [(mainColumn height > fileInfoColumn height)
				ifTrue: [mainColumn addMorphBack: bottomSpacer]
				ifFalse: [fileInfoColumn addMorphBack: bottomSpacer]]].! !

!BlockCreationDialog methodsFor: 'as yet unclassified' stamp: 'EMP 2/26/2016 09:56'!
getUserResponse
	| result w |
	"Wait for the user to respond, then report their response. The symbol #cancel is returned if the user wishes to cancel the operation. True/false is returned if they respond yes/no, and a string is returned if this this a string input dialog and they don't cancel."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	self openInWorld.
	self centerOnScreen.
	w _ self world.
	self buttons size > 0 ifTrue: [
		w activeHand newKeyboardFocus: self buttons last].
	tabFields size > 0 ifTrue: [
		w activeHand newKeyboardFocus: (tabFields at: 1)].
	done _ false.
	World hands first newKeyboardFocus: (block blockLabels first labelMorph).
	[done] whileFalse: [w doOneCycle].  "wait for user to press a button"

	result _ response.

	(result = #cancelled) | (result = '') ifTrue: [^ false].
	^ {block getBlockName. isAtomic}! !

!BlockCreationDialog methodsFor: 'as yet unclassified' stamp: 'EMP 11/16/2015 16:27'!
isAtomic: aBoolean
	| isAtomicButtonTemp |
	isAtomic _ aBoolean.
	aBoolean ifTrue: [isAtomicButtonTemp _ (isAtomicButton submorphs detect: [:m | m isKindOf: ToggleButton] ifNone: [nil]). isAtomicButtonTemp ifNotNil: [isAtomicButtonTemp on]] ifFalse: [isAtomicButtonTemp _ (isAtomicButton submorphs detect: [:m | m isKindOf: ToggleButton] ifNone: [nil]). isAtomicButtonTemp ifNotNil: [isAtomicButtonTemp off]].! !

!BlockCreationDialog methodsFor: 'as yet unclassified' stamp: 'EMP 11/4/2015 14:43'!
toggleAtomic
	isAtomic _ isAtomic not! !

!BlockCreationDialog methodsFor: 'as yet unclassified' stamp: 'EMP 11/6/2015 21:28'!
toggleBin
	showingBin ifTrue: [
	mainColumn submorphsDo: [:m | 
		((m = messageLineMorphs) not) ifTrue: [m delete]].
	mainColumn
		addMorphBack: (Morph new extent: (5@6); color: Color transparent);
		addMorphBack: blockColumn;
		addMorphBack: (Morph new extent: (5@6); color: Color transparent);
		addMorphBack: showHideButton;
		addMorphBack: (Morph new extent: (216@7); color: Color transparent);
		addMorphBack: buttonRow;
		addMorphBack: bottomSpacer] ifFalse: [
	mainColumn submorphsDo: [:m | 
		((m = messageLineMorphs) not) ifTrue: [m delete]].
	mainColumn
		addMorphBack: (Morph new extent: (5@6); color: Color transparent);
		addMorphBack: blockColumn;
		addMorphBack: (Morph new extent: (5@6); color: Color transparent);
		addMorphBack: showHideButton;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: bin;
		addMorphBack: (Morph new extent: (216@7); color: Color transparent);
		addMorphBack: buttonRow].
	bottomSpacer ifNil: [
		bottomSpacer _ (Morph new extent: (5@22); color: Color transparent).
		(shortcutColumn height > mainColumn height)
			ifTrue: [shortcutColumn addMorphBack: bottomSpacer]
			ifFalse: [(mainColumn height > fileInfoColumn height)
				ifTrue: [mainColumn addMorphBack: bottomSpacer]
				ifFalse: [fileInfoColumn addMorphBack: bottomSpacer]]].
	initialized _ true.
	showingBin _ showingBin not.
	showingBin ifFalse: [
	World doOneCycleNoInput].
	self extent: ((block width + 60 max: 385) @ (showingBin ifTrue: [mainColumn height + bin height + buttonRow height] ifFalse: [mainColumn height + buttonRow height])).! !

!BlockCreationDialog methodsFor: 'as yet unclassified' stamp: 'EMP 11/6/2015 21:28'!
updateWidth: aNumber
	self extent: (aNumber + 60 max: 385) @ (self height).
	self fixLayout! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

BlockCreationDialog class
	instanceVariableNames: ''!

!BlockCreationDialog class methodsFor: 'as yet unclassified' stamp: 'EMP 11/16/2015 16:19'!
forCustomBlock: anArray
	| result |
	"anArray is an array with the following:
	[
	the block spec string
	the argument names
	isAtomic
	]"

	result _ self new.
	result isAtomic: ((anArray third) = true).
	result block commandSpec: (anArray first asString).
	result block fixParametersWith: (anArray second).
	^ result! !

!BlockCreationDialog class methodsFor: 'as yet unclassified' stamp: 'EMP 11/5/2015 12:19'!
new
	^ super new withButtonsForYes: false no: false okay: true cancel: true! !
