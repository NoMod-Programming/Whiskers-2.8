StringDialog subclass: #TipsDialog
	instanceVariableNames: 'allSpritesRadioButton thisSpriteRadioButton spriteSpecificFlag radioButtons category scopeRadioButtons userSpec commandBlockRadioButton reporterBlockRadioButton booleanBlockRadioButton booleanBlockFlag reporterBlockFlag categoryChooser type '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Dialogs'!

!TipsDialog methodsFor: 'initialization'!
initialize
	| |
	super initialize.
	reporterBlockFlag _ false.
	booleanBlockFlag _ false.
	type _ #none.
	category _ #other.
	spriteSpecificFlag _ false.
	self buildTypeChooser.
	self buildCategoryChooser.
	self buildScopeRadioButtons.
	mainColumn
		submorphsDo: [:t1 | (t1 = messageLineMorphs) not ifTrue: [t1 delete]].
	mainColumn addMorphBack: (Morph new extent: 5 @ 6;
		 color: Color transparent);
	 addMorphBack: categoryChooser;
	 addMorphBack: (Morph new extent: 5 @ 7;
		 color: Color transparent);
	 addMorphBack: buttonRow;
	 addMorphBack: bottomSpacer.! !


!TipsDialog methodsFor: 'interaction'!
buildCategoryChooser
	| t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 |
	t1 _ #(#motion #control #looks #sensing #sound #operators #pen #variables #list #'other help').
	categoryChooser _ ImageFrameMorph new.
	categoryChooser initFromForm: (ScratchFrameMorph skinAt: #paintOptionsBackground).
	t2 _ 75 @ 0.
	t3 _ t1
				collect: 
					[:t15 | 
					t4 _ (ScratchTranslator translationFor: t15 asString) capitalized.
					(#(#list #'other help') includes: t15)
						ifTrue: 
							[t5 _ ScratchFrameMorph skinAt: #variablesOld.
							t6 _ ScratchFrameMorph skinAt: #variablesOldPressed.
							t7 _ ScratchFrameMorph skinAt: #variablesOldOver]
						ifFalse: 
							[t5 _ ScratchFrameMorph skinAt: t15, 'Old'.
							t6 _ ScratchFrameMorph skinAt: t15 , 'OldPressed'.
							t7 _ ScratchFrameMorph skinAt: t15 , 'OldOver'].
					ScratchTranslator isRTL
						ifTrue: [t8 _ ResizableToggleButton2 new
										offForm: (t5 flipBy: #horizontal centerAt: t5 center)
										onForm: (t6 flipBy: #horizontal centerAt: t6 center)
										overForm: (t7 flipBy: #horizontal centerAt: t7 center)]
						ifFalse: [t8 _ ResizableToggleButton2 new
										offForm: t5
										onForm: t6
										overForm: t7].
					t8 label: t4 font: (ScratchFrameMorph getFont: #Category);
					 setLabelColor: Color white;
					 target: self;
					 actionSelector: #category:;
					 arguments: (Array with: t15);
					 toggleButtonMode: true;
					 toggleMode: false.
					ScratchTranslator isRTL
						ifTrue: [t8 rightJustifyInset: 10]
						ifFalse: [t8 leftJustifyInset: 10].
					t2 _ t2 max: t8 extent + (3 @ -6).
					t8].
	t9 _ 15.
	t14 _ 2 * t2 x + (3 * t9) @ (t1 size // 2 * (t2 y + 6) + 25).
	t10 _ self left + 12 + t9.
	t11 _ t10 + t2 x + t9.
	t12 _ t10.
	t13 _ categoryChooser top + 17.
	1 to: t3 size do: 
		[:t16 | 
		t8 _ t3 at: t16.
		t8 extent: t2.
		categoryChooser addMorph: (t8 position: t12 @ t13).
		t16 even
			ifTrue: 
				[t12 _ t10.
				t13 _ t13 + t8 height + 6]
			ifFalse: [t12 _ t11]].
	categoryChooser width: t14 x + 25.
	categoryChooser height: t14 y! !

!TipsDialog methodsFor: 'interaction'!
formTypeCommandOff
	^ (CommandBlockMorph new color: ((ScriptableScratchMorph blockColorFor: category asString)
			mixed: 0.2 with: Color veryLightGray);
	 commandSpec: 'stack' localized) imageForm! !

!TipsDialog methodsFor: 'interaction'!
formTypeCommandOn
	^ (CommandBlockMorph new color: (ScriptableScratchMorph blockColorFor: category asString);
	 commandSpec: 'stack' localized) imageForm! !

!TipsDialog methodsFor: 'interaction'!
formTypeCommandOver
	^ (CommandBlockMorph new color: ((ScriptableScratchMorph blockColorFor: category asString)
			mixed: 0.4 with: Color veryLightGray);
	 commandSpec: 'stack' localized) imageForm! !

!TipsDialog methodsFor: 'interaction' stamp: 'EMPedemonte20 9/23/2015 12:34'!
formTypePredicateOff
	^ (ReporterBlockMorph new isBoolean: true;
	 color: ((ScriptableScratchMorph blockColorFor: category asString)
			mixed: 0.2 with: Color veryLightGray);
	 commandSpec: 'predicate' localized) imageForm! !

!TipsDialog methodsFor: 'interaction' stamp: 'EMPedemonte20 9/23/2015 12:34'!
formTypePredicateOn
	^ (ReporterBlockMorph new isBoolean: true;
	 color: (ScriptableScratchMorph blockColorFor: category asString);
	 commandSpec: 'predicate' localized) imageForm! !

!TipsDialog methodsFor: 'interaction' stamp: 'EMPedemonte20 9/23/2015 12:34'!
formTypePredicateOver
	^ (ReporterBlockMorph new isBoolean: true;
	 color: ((ScriptableScratchMorph blockColorFor: category asString)
			mixed: 0.4 with: Color veryLightGray);
	 commandSpec: 'predicate' localized) imageForm! !

!TipsDialog methodsFor: 'interaction' stamp: 'EMPedemonte20 9/23/2015 12:34'!
formTypeReporterOff
	^ (ReporterBlockMorph new color: ((ScriptableScratchMorph blockColorFor: category asString)
			mixed: 0.2 with: Color veryLightGray);
	 commandSpec: 'reporter' localized) imageForm! !

!TipsDialog methodsFor: 'interaction' stamp: 'EMPedemonte20 9/23/2015 12:34'!
formTypeReporterOn
	^ (ReporterBlockMorph new color: (ScriptableScratchMorph blockColorFor: category asString);
	 commandSpec: 'reporter' localized) imageForm! !

!TipsDialog methodsFor: 'interaction' stamp: 'EMPedemonte20 9/23/2015 12:34'!
formTypeReporterOver
	^ (ReporterBlockMorph new color: ((ScriptableScratchMorph blockColorFor: category asString)
			mixed: 0.4 with: Color veryLightGray);
	 commandSpec: 'reporter' localized) imageForm! !

!TipsDialog methodsFor: 'interaction' stamp: 'EMPedemonte20 9/23/2015 12:42'!
reformTypeCommandOver
	^ (CommandBlockMorph new color: ((ScriptableScratchMorph blockColorFor: category asString)
			mixed: 0.4 with: Color veryLightGray);
	 commandSpec: 'stack' localized) imageForm! !

!TipsDialog methodsFor: 'interaction' stamp: 'EMPedemonte20 9/23/2015 12:35'!
selectBooleanBlock
	reporterBlockFlag _ true.
	booleanBlockFlag _ true.
	type _ #boolean.
	booleanBlockRadioButton onForm: self formTypePredicateOn;
	 overForm: self formTypePredicateOn;
	 on.
	commandBlockRadioButton offForm: self formTypeCommandOff;
	 overForm: self formTypeCommandOver;
	 off.
	reporterBlockRadioButton offForm: self formTypeReporterOff;
	 overForm: self formTypeReporterOver;
	 off.
	World activeHand newKeyboardFocus: tabFields first! !

!TipsDialog methodsFor: 'interaction' stamp: 'EMPedemonte20 9/23/2015 12:35'!
selectCommandBlock
	reporterBlockFlag _ false.
	booleanBlockFlag _ false.
	type _ #none.
	booleanBlockRadioButton offForm: self formTypePredicateOff;
	 overForm: self formTypePredicateOver;
	 off.
	commandBlockRadioButton onForm: self formTypeCommandOn;
	 overForm: self formTypeCommandOn;
	 on.
	reporterBlockRadioButton offForm: self formTypeReporterOff;
	 overForm: self formTypeReporterOver;
	 off.
	World activeHand newKeyboardFocus: tabFields first! !

!TipsDialog methodsFor: 'interaction' stamp: 'EMPedemonte20 9/23/2015 12:35'!
selectReporterBlock
	reporterBlockFlag _ true.
	booleanBlockFlag _ false.
	type _ #reporter.
	booleanBlockRadioButton offForm: self formTypePredicateOff;
	 overForm: self formTypePredicateOver;
	 off.
	commandBlockRadioButton offForm: self formTypeCommandOff;
	 overForm: self formTypeCommandOver;
	 off.
	reporterBlockRadioButton onForm: self formTypeReporterOn;
	 overForm: self formTypeReporterOn;
	 on.
	World activeHand newKeyboardFocus: tabFields first! !

!TipsDialog methodsFor: 'interaction'!
toggleSpriteSpecific
	spriteSpecificFlag _ spriteSpecificFlag not.
	spriteSpecificFlag
		ifTrue: 
			[allSpritesRadioButton off.
			thisSpriteRadioButton on]
		ifFalse: 
			[allSpritesRadioButton on.
			thisSpriteRadioButton off].
	World activeHand newKeyboardFocus: tabFields first! !

!TipsDialog methodsFor: 'interaction' stamp: 'EMPedemonte20 9/23/2015 12:35'!
updateTypeSelection
	#none = type ifTrue: [^ self selectCommandBlock].
	#boolean = type ifTrue: [^ self selectBooleanBlock].
	self selectReporterBlock! !


!TipsDialog methodsFor: 'private' stamp: 'EMPedemonte20 9/23/2015 12:33'!
buildScopeRadioButtons
	| t1 t2 |
	scopeRadioButtons _ AlignmentMorph newRow color: Color transparent;
			 hResizing: #shrinkWrap;
			 vResizing: #shrinkWrap.
	allSpritesRadioButton _ ToggleButton onForm: (ScratchFrameMorph skinAt: #radioButtonOn)
				offForm: (ScratchFrameMorph skinAt: #radioButton).
	allSpritesRadioButton on; target: self; actionSelector: #toggleSpriteSpecific.
	t1 _ StringMorph new contents: 'For all sprites' localized;
			 font: (ScratchFrameMorph getFont: #NewVariableDialogBox).
	scopeRadioButtons addMorphBack: allSpritesRadioButton.
	scopeRadioButtons addMorphBack: (Morph new extent: 5 @ 5;
		 color: Color transparent).
	scopeRadioButtons addMorphBack: t1.
	scopeRadioButtons addMorphBack: (Morph new extent: 15 @ 5;
		 color: Color transparent).
	thisSpriteRadioButton _ allSpritesRadioButton fullCopy off.
	t2 _ StringMorph new contents: 'For this sprite only' localized;
			 font: (ScratchFrameMorph getFont: #NewVariableDialogBox).
	scopeRadioButtons addMorphBack: thisSpriteRadioButton.
	scopeRadioButtons addMorphBack: (Morph new extent: 5 @ 5;
		 color: Color transparent).
	scopeRadioButtons addMorphBack: t2.
	ScratchTranslator isRTL ifTrue: [scopeRadioButtons submorphs reversed do: 
			[:t3 | 
			t3 delete.
			scopeRadioButtons addMorphBack: t3]]! !

!TipsDialog methodsFor: 'private' stamp: 'EMPedemonte20 9/23/2015 12:33'!
buildTypeChooser
	| t1 |
	t1 _ Morph new extent: 5 @ 5;
			 color: Color transparent.
	radioButtons _ AlignmentMorph newRow color: Color transparent;
			 hResizing: #shrinkWrap;
			 vResizing: #shrinkWrap.
	commandBlockRadioButton _ ToggleButton
				onForm: self formTypeCommandOn
				offForm: self formTypeCommandOff
				overForm: self formTypeCommandOver.
	commandBlockRadioButton on; target: self; actionSelector: #selectCommandBlock.
	radioButtons addMorphBack: commandBlockRadioButton.
	radioButtons addMorphBack: t1 fullCopy.
	reporterBlockRadioButton _ ToggleButton
				onForm: self formTypeReporterOn
				offForm: self formTypeReporterOff
				overForm: self formTypeReporterOver.
	reporterBlockRadioButton off; target: self; actionSelector: #selectReporterBlock.
	radioButtons addMorphBack: reporterBlockRadioButton.
	radioButtons addMorphBack: t1 fullCopy.
	booleanBlockRadioButton _ ToggleButton
				onForm: self formTypePredicateOn
				offForm: self formTypePredicateOff
				overForm: self formTypePredicateOver.
	booleanBlockRadioButton off; target: self; actionSelector: #selectBooleanBlock.
	radioButtons addMorphBack: booleanBlockRadioButton! !

!TipsDialog methodsFor: 'private'!
category: t1 
	done _ true.
	category _ t1.
	self updateTypeSelection.
	categoryChooser submorphs do: [:t2 | (t2 isKindOf: ResizableToggleButton2)
			ifTrue: [t2 arguments first = category
					ifTrue: [t2 off "on"]
					ifFalse: [t2 off]]].
	World activeHand newKeyboardFocus: tabFields first! !

!TipsDialog methodsFor: 'private' stamp: 'EMPedemonte20 9/23/2015 12:33'!
disableAllButCategory
	mainColumn
		submorphsDo: [:t1 | (t1 = messageLineMorphs) not ifTrue: [t1 delete]].
	mainColumn addMorphBack: (Morph new extent: 5 @ 7;
		 color: Color transparent);
	 addMorphBack: categoryChooser;
	 addMorphBack: (Morph new extent: 5 @ 7;
		 color: Color transparent);
	 addMorphBack: buttonRow;
	 addMorphBack: bottomSpacer! !

!TipsDialog methodsFor: 'private' stamp: 'EMPedemonte20 9/23/2015 12:34'!
disableAllButCategoryAndShape
	| t1 |
	t1 _ Array with: messageLineMorphs with: radioButtons.
	mainColumn
		submorphsDo: [:t2 | (t1 includes: t2)
				ifFalse: [t2 delete]].
	mainColumn addMorphBack: (Morph new extent: 5 @ 7;
		 color: Color transparent);
	 addMorphBack: categoryChooser;
	 addMorphBack: (Morph new extent: 5 @ 7;
		 color: Color transparent);
	 addMorphBack: radioButtons;
	 addMorphBack: (Morph new extent: 5 @ 7;
		 color: Color transparent);
	 addMorphBack: buttonRow;
	 addMorphBack: bottomSpacer! !

!TipsDialog methodsFor: 'private' stamp: 'EMPedemonte20 9/23/2015 12:33'!
disableTypeDeclaration
	radioButtons isHidden: true! !

!TipsDialog methodsFor: 'private'!
getUserResponse
	| t1 |
	super getUserResponse.
	category = #other ifTrue: [^ #cancelled].
	category = #motion ifTrue: [t1 _ TipsDialog2 createDialogForMotion].
	category = #control ifTrue: [t1 _ TipsDialog2 createDialogForControl].
	category = #sensing ifTrue: [t1 _ TipsDialog2 createDialogForSensing].
	category = #looks ifTrue: [t1 _ TipsDialog2 createDialogForLooks].
	category = #sound ifTrue: [t1 _ TipsDialog2 createDialogForSound].
	category = #operators ifTrue: [t1 _ TipsDialog2 createDialogForOperators].
	category = #pen ifTrue: [t1 _ TipsDialog2 createDialogForPen].
	category = #variables ifTrue: [t1 _ TipsDialog2 createDialogForVariables].
	category = #list ifTrue: [t1 _ TipsDialog2 createDialogForList].
	category = #'other help' ifTrue: [t1 _ TipsDialog2 createDialogForOther].
	^ Array with: t1 asString! !

!TipsDialog methodsFor: 'private' stamp: 'EMPedemonte20 9/23/2015 12:33'!
setCategory: t1 
	#none = t1 ifTrue: [^ category _ #other].
	category _ t1! !

!TipsDialog methodsFor: 'private' stamp: 'EMPedemonte20 9/23/2015 12:33'!
setType: t1 
	type _ t1! !

!TipsDialog methodsFor: 'private' stamp: 'EMPedemonte20 9/23/2015 12:33'!
setUserSpec: t1 
	userSpec _ t1! !

!TipsDialog methodsFor: 'private' stamp: 'EMPedemonte20 9/23/2015 12:32'!
updateInitialSettings
	self initialAnswer: userSpec;
	 category: category;
	 updateTypeSelection! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

TipsDialog class
	instanceVariableNames: ''!

!TipsDialog class methodsFor: 'instance creation'!
ask: questionString
	"Put up an instance of me to ask the user for the name for a new variable."

	| dialogBox |
	dialogBox _ self new
		withButtonsForYes: false no: false okay: false cancel: true;
		message: questionString;
		extent: 330@200.
	^ dialogBox getUserResponse
! !

!TipsDialog class methodsFor: 'instance creation' stamp: 'EMPedemonte20 9/22/2015 16:56'!
askWithCancel: questionString initialAnswer: aString
	"Put up an instance of me to ask the user for string input (such as file name). The initial response text is set to the given string, which the user can replace or edit. This version includes a cancel button. Answer the empty string if cancelled."

	| dialogBox |
	dialogBox _ self new
		withButtonsForYes: false no: false okay: true cancel: true;
		message: questionString;
		initialAnswer: aString.
	^ dialogBox getUserResponse
! !
