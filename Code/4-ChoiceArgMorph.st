ArgMorph subclass: #ChoiceArgMorph
	instanceVariableNames: 'menuIconMorph isBoolean options choice getOptionsSelector '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!ChoiceArgMorph commentStamp: 'jm 7/7/2004 00:28' prior: 0!
I am used to represent an ArgMorph that allows the user to choose from a popup menu of choices. For example, I might allow selection of a sensor port from the list ('a', 'b', 'c', 'd').

In an earlier version of Scratch, I was used to represent boolean values. That usage has been replaced with BooleanArgMorph.
!


!ChoiceArgMorph methodsFor: 'initialization' stamp: 'EMP 10/11/2015 20:16'!
initialize

	super initialize.
	self borderInset.
	self borderWidth: 1.
	self color: Color brown.
	labelMorph _ StringMorph new
		font: (ScratchFrameMorph getFont: #Arg);
		forceUnicodeRendering: true;
		color: Color white.
	self addMorph: labelMorph.
	menuIconMorph _ ImageMorph new form: DropDownMenuForm.
	self addMorphFront: menuIconMorph.
	isBoolean _ false.
	options _ #(a b c d).
	self choice: #a.
! !


!ChoiceArgMorph methodsFor: 'accessing' stamp: 'EMP 4/9/2016 16:07'!
acceptsDroppedReporters

	^ true
! !

!ChoiceArgMorph methodsFor: 'accessing' stamp: 'EMP 4/9/2016 16:07'!
acceptsTypeOf: aBlockMorph
	"Answer true if I can accept a dropped reporter of the given type."

	^ aBlockMorph isReporter! !

!ChoiceArgMorph methodsFor: 'accessing' stamp: 'jm 8/24/2003 18:26'!
choice

	^ choice
! !

!ChoiceArgMorph methodsFor: 'accessing' stamp: 'jm 8/27/2008 09:55'!
choice: aSymbol
	"Update the toggle button when an argument is changed within a block."

	| frame palette block doLocalization label |
	frame _ self ownerThatIsA: ScratchFrameMorph.
	((#soundNames = getOptionsSelector) and:
	 [aSymbol = ('record' localized, ScratchTranslator ellipsesSuffix)]) ifTrue: [
		frame ifNotNil: [^ frame newSound]].

	((#sceneNames = getOptionsSelector) and:
	 [aSymbol = ('record' localized, ScratchTranslator ellipsesSuffix)]) ifTrue: [
		frame ifNotNil: [^ frame workPane newScene]].

	((#sceneNames = getOptionsSelector) and:
	 [aSymbol = ('re-record' localized, ScratchTranslator ellipsesSuffix)]) ifTrue: [
		frame ifNotNil: [^ frame workPane rerecordScene]].

	choice _ label _ aSymbol.
	label isUnicode ifFalse: [label _ label asString].
	doLocalization _ (#(costumeNames soundNames varNamesMenu listVarMenu) includes: getOptionsSelector) not.
	doLocalization & label isUnicode not
		ifTrue:[labelMorph contents: label localized]
		ifFalse:[labelMorph contents: label].
	labelMorph position: self position + borderWidth + (3 @ -1).
	self extent: (labelMorph extent + (16@2) + borderWidth).

	menuIconMorph position: (self right - borderWidth - 10)@(self top + borderWidth + 4).

	(block _ self ownerThatIsA: HatBlockMorph) ifNotNil: [
		block fixBlockLayout].

	(palette _ self ownerThatIsA: ScratchBlockPaletteMorph) ifNil: [^ self].
	(block _ self ownerThatIsA: BlockMorph) ifNil: [^ self].

	block isReporter ifTrue: [palette updateWatcherButtonsForFrame: frame].
! !

!ChoiceArgMorph methodsFor: 'accessing' stamp: 'jm 3/28/2005 15:13'!
defaultValue: aString
	"Set my default value."

	self choice: aString.
! !

!ChoiceArgMorph methodsFor: 'accessing' stamp: 'jm 8/6/2008 20:54'!
getOptionsSelector

	^ getOptionsSelector
! !

!ChoiceArgMorph methodsFor: 'accessing' stamp: 'jm 5/14/2004 11:50'!
getOptionsSelector: aSymbolOrString
	"Set a selector that is used to get a set of options from my command block's receiver. This is used when the options can change over time, such as selecting from a list of available sounds or costumes in the objects media library."

	getOptionsSelector _ aSymbolOrString asSymbol.
! !

!ChoiceArgMorph methodsFor: 'accessing' stamp: 'jm 6/10/2004 10:49'!
options
	"Answer my set of options. If getOptionsSelector is not nil and I'm in a CommandBlock with a non-nil receiver, fetch my set of options by sending getOptionsSelector to that receiver."

	(getOptionsSelector notNil and:
	 [(owner respondsTo: #receiver) and:
	 [owner receiver notNil]]) ifTrue: [
		^ owner receiver perform: getOptionsSelector].

	^ options
! !

!ChoiceArgMorph methodsFor: 'accessing' stamp: 'jm 8/24/2003 18:32'!
options: stringList

	options _ stringList asArray.
	(options includes: choice) ifFalse: [self choice: options first].
! !

!ChoiceArgMorph methodsFor: 'accessing' stamp: 'EMP 1/7/2016 12:19'!
presentMenu
	"Pop up a menu of choices."

	| optionList doLocalization menu selection option tempColor |
	optionList _ self options.
	optionList size = 0 ifTrue: [^ self].
	doLocalization _ (#(costumeNames soundNames varNamesMenu listVarMenu) includes: getOptionsSelector) not.
	menu _ CustomMenu new.
	optionList do: [:sym |
		'-' = sym
			ifTrue: [menu addLine]
			ifFalse: [
				doLocalization & sym isUnicode not
					ifTrue: [option _ sym localized asUTF8]
					ifFalse: [option _ sym].
				((#(hookupSensorNames hookupBooleanSensorNames) includes: getOptionsSelector) and:
				 [(#(connected resistance) includes: sym)])
					ifTrue: [#(A B C D) do: [:c |
						self owner isBooleanReporter
							ifFalse: [menu add: (option, '-', c) action: (sym, '-', c)]
							ifTrue: [menu add: (c asUTF8, ' ', option) action: (c, ' ' ,sym)]]]
					ifFalse: [menu add: option action: sym]]].
	tempColor _ (self color).
	(owner isKindOf: KeyEventHatMorph) ifTrue: [tempColor _ (Color h: 41 s: 0.85 v: 0.9)].
	menu color: (tempColor lighter); target: self.
	Sensor waitNoButton.
	(selection _ menu startUpAt: (self bottomLeft + (0 @ 10))) ifNotNil: [self choice: selection].
! !


!ChoiceArgMorph methodsFor: 'event handling' stamp: 'jm 1/23/2007 12:32'!
handlesMouseDown: evt

	^ evt hand toolType isNil and:
		[(self topRight - (14@0) corner: self bottomRight) containsPoint: evt cursorPoint]
! !

!ChoiceArgMorph methodsFor: 'event handling' stamp: 'jm 12/13/2006 21:35'!
mouseDown: evt

	self presentMenu.
! !

!ChoiceArgMorph methodsFor: 'event handling' stamp: 'jm 12/14/2004 11:51'!
wantsKeyboardFocusFor: aSubmorph
	"Don't allow shift-click editing of block labels."

	^ false
! !


!ChoiceArgMorph methodsFor: 'other' stamp: 'jm 8/24/2003 18:33'!
evaluate
	"Answer my value."

	isBoolean ifTrue: [^ 'true' = choice].
	^ choice
! !

!ChoiceArgMorph methodsFor: 'other' stamp: 'jm 4/1/2005 20:33'!
fixArgLayout
	"Set my color to my owner's color."

	self color: (owner color mixed: 0.75 with: (Color gray: 0.45)).
! !

!ChoiceArgMorph methodsFor: 'other' stamp: 'jm 10/30/2005 08:32'!
printArgOn: aStream
	"Print this argument morph on the given stream."

	aStream nextPutAll: '"', self labelMorph contents, '"'.
! !


!ChoiceArgMorph methodsFor: 'object i/o' stamp: 'jm 5/14/2004 11:39'!
fieldsVersion

	^ 2
! !

!ChoiceArgMorph methodsFor: 'object i/o' stamp: 'jm 5/14/2004 11:54'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		isBoolean
		options
		choice
	) from: anObjStream.
	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	self initFieldsNamed: #(
		getOptionsSelector
	) from: anObjStream.
! !

!ChoiceArgMorph methodsFor: 'object i/o' stamp: 'jm 5/14/2004 11:54'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		isBoolean
		options
		choice
		getOptionsSelector
	) on: anObjStream.
! !
