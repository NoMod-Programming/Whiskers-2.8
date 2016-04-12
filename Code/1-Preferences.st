Object subclass: #Preferences
	instanceVariableNames: ''
	classVariableNames: 'CategoryInfo DesktopColor FlagDictionary HelpDictionary Parameters SyntaxColorsAndStyles '
	poolDictionaries: ''
	category: 'System-Support'!
!Preferences commentStamp: '<historical>' prior: 0!
A general mechanism to store preference choices.  The default setup treats any symbol as a potential boolean flag; flags unknown to the preference dictionary are always returned as false.  It is also possible to store non-boolean data in the preference table.  sw 8/91!


"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Preferences class
	instanceVariableNames: ''!

!Preferences class methodsFor: 'initialization' stamp: 'sw 2/15/2000 18:40'!
absorbAdditions
	"Preferences absorbAdditions"
	self initializeAddedPreferences.
	self initializeHelpMessages.
	self resetCategoryInfo! !

!Preferences class methodsFor: 'initialization' stamp: 'sw 1/12/2000 22:34'!
allPreferenceInitializationSpecs
	"Preferences allPreferenceInitializationSpecs"
	| aList additions |
	aList _ OrderedCollection new.
	(self class organization listAtCategoryNamed: 'initial values' asSymbol) do:
		[:aSelector | aSelector numArgs = 0 ifTrue:
			[additions _ self perform: aSelector.
			(additions isKindOf: Collection) ifFalse: [self error: 'method in "initial values" categories must return collections'].
			aList addAll: additions]].
	^ aList
			! !

!Preferences class methodsFor: 'initialization' stamp: 'sw 1/13/2000 14:03'!
callHelpMessageInitializers
	| listOfPairs |
	"Preferences callHelpMessageInitializers"
	(self class organization listAtCategoryNamed: #help) do:
		[:aSelector | aSelector numArgs = 0 ifTrue:
			[((listOfPairs _ self perform: aSelector) isKindOf: Collection)
				ifTrue:
					[listOfPairs do:
						[:pair | HelpDictionary at: pair first put: 
					(pair first, ':
		', pair last)]]]]! !

!Preferences class methodsFor: 'initialization' stamp: 'sw 1/13/2000 14:17'!
chooseInitialSettings
	"Restore the default choices for Preferences."
	"Preferences chooseInitialSettings"

	self allPreferenceInitializationSpecs do:
		[:aSpec |
			aSpec second == #true
				ifTrue:
					[self enable: aSpec first]
				ifFalse:
					[self disable: aSpec first]].
	self resetCategoryInfo

! !

!Preferences class methodsFor: 'initialization' stamp: 'sw 7/1/1999 23:17'!
compileAccessMethodFor: prefSymbol
	self class compileProgrammatically: (prefSymbol, '
	^ self valueOfFlag: #', prefSymbol) classified: 'standard preferences'! !

!Preferences class methodsFor: 'initialization' stamp: 'sw 9/19/1998 22:47'!
initialize
	"Preferences initialize"
	"Sometimes placed in a change-set even though unchanged, to trigger reinitialization upon update."

	FlagDictionary _ Dictionary new.
	self chooseInitialSettings.
! !

!Preferences class methodsFor: 'initialization' stamp: 'sw 1/13/2000 14:16'!
initializeAddedPreferences
	"Initialize any preference not yet known to the prefs dictionary as per descriptions in the 'initial values' category, but don't change the setting of any existing preference.
	Also, compile accessor methods for retrieving any preference that lacks one"

	"Preferences initializeAddedPreferences"

	| sym |
	self allPreferenceInitializationSpecs do:
		[:triplet |
			(self class selectors includes: (sym _ triplet first))
				ifFalse:
					[self compileAccessMethodFor: sym].
			(FlagDictionary includesKey: sym) ifFalse:
				[triplet second == #true
					ifTrue:
						[self enable: sym]
					ifFalse:
						[self disable: sym]]].
	self resetCategoryInfo

! !

!Preferences class methodsFor: 'initialization' stamp: 'sw 1/13/2000 13:49'!
initializeHelpMessages
	"Preferences initializeHelpMessages"
  	HelpDictionary _ Dictionary new.
	self callHelpMessageInitializers! !


!Preferences class methodsFor: 'parameters' stamp: 'EMP 3/15/2016 15:31'!
aaFontsColormapDepth
	"Adjust balance between colored AA text quality (especially if subpixel AA is used) and space / performance.
	5 is optimal quality. Each colorMap takes 128kB of RAM, and takes several seconds to build.
	4 is a reasonable balance. Each colorMap takes 16kB of RAM and builds fast on a fast machine.
	3 is good for slow hardware or memory restrictions. Each colorMap takes 2 kb of RAM."
	

	^ self! !

!Preferences class methodsFor: 'parameters' stamp: 'sw 10/19/1999 22:39'!
annotationInfo 
	^ #(

		(timeStamp			'The time stamp of the last submission of the method.')
		(messageCategory	'Which method category the method lies in')
		(sendersCount		'A report of how many senders there of the message.')
		(implementorsCount	'A report of how many implementors there are of the message.')
		(recentChangeSet	'The most recent change set bearing the method.')
		(allChangeSets		'A list of all change sets bearing the method.')
		(priorVersionsCount	'A report of how many previous versions there are of the method' )
		(priorTimeStamp		'The time stamp of the penultimate submission of the method, if any'))! !

!Preferences class methodsFor: 'parameters' stamp: 'jm 6/15/2003 12:35'!
defaultAnnotationRequests

	(Parameters includesKey: #MethodAnnotations) ifFalse: [
		Parameters
			at: #MethodAnnotations
			put: #(timeStamp messageCategory implementorsCount allChangeSets)].
	^ Parameters at: #MethodAnnotations
! !

!Preferences class methodsFor: 'parameters' stamp: 'jm 6/15/2003 12:36'!
defaultAnnotationRequests: newList

	^ Parameters at: #MethodAnnotations put: newList
! !

!Preferences class methodsFor: 'parameters' stamp: 'jhm 10/15/97 17:31'!
desktopColor
	"Answer the desktop color. Initialize it if necessary."
	
	DesktopColor == nil ifTrue: [DesktopColor _ Color gray].
	^ DesktopColor
! !

!Preferences class methodsFor: 'parameters' stamp: 'jhm 10/15/97 17:31'!
desktopColor: aColor
	"Record a new desktop color preference."

	DesktopColor _ aColor.
! !

!Preferences class methodsFor: 'parameters' stamp: 'sw 9/7/1999 12:45'!
initializeParameters
	"Preferences initializeParameters"
	Parameters _ IdentityDictionary new.
	self restoreDefaultMenuParameters.
	Parameters at: #maxBalloonHelpLineLength put: 28.
	self initializeTextHighlightingParameters! !

!Preferences class methodsFor: 'parameters' stamp: 'sw 11/5/1998 16:49'!
maxBalloonHelpLineLength
	^ Parameters at: #maxBalloonHelpLineLength! !

!Preferences class methodsFor: 'parameters' stamp: 'sw 1/27/2000 23:02'!
parameterAt: aKey
	^ Parameters at: aKey ifAbsent: [nil]! !

!Preferences class methodsFor: 'parameters' stamp: 'EMP 3/15/2016 15:26'!
properDisplayAlphaForFonts
	^ false! !

!Preferences class methodsFor: 'parameters'!
scrollBarColor
	"Answer the preferred color for scroll bar elevators."

	^ Color gray! !

!Preferences class methodsFor: 'parameters'!
scrollBarWidth
	"Answer the preferred width for scroll bars."

	^ 8! !

!Preferences class methodsFor: 'parameters' stamp: 'stp 01/13/2000 13:29'!
setParameter: paramName to: paramValue
	"Set the given field in the parameters dictionary."

	Parameters at: paramName put: paramValue! !


!Preferences class methodsFor: 'preferences dictionary' stamp: 'sw 1/19/2000 13:52'!
disable: preferenceNameSymbol
	"Shorthand access"
	self setPreference: preferenceNameSymbol toValue: false.
	self resetCategoryInfo "in case this call introduced a new pref"! !

!Preferences class methodsFor: 'preferences dictionary' stamp: 'jm 5/23/2003 12:44'!
doesNotUnderstand: aMessage
	"If the given message is unary, look up it's selector as a flag."

	aMessage arguments size > 0 ifTrue: [^ super doesNotUnderstand: aMessage].
	^ self valueOfFlag: aMessage selector
! !

!Preferences class methodsFor: 'preferences dictionary' stamp: 'sw 1/19/2000 13:53'!
enable: preferenceNameSymbol
	"Shorthand access"
	self setPreference: preferenceNameSymbol toValue: true.
	self resetCategoryInfo  "in case this call introduced a new pref"! !

!Preferences class methodsFor: 'preferences dictionary' stamp: 'jm 10/5/2002 06:54'!
noteThatFlag: prefSymbol justChangedTo: aBoolean
	"Provides a hook so that a user's toggling of a preference might precipitate some immediate action."

	prefSymbol == #roundedWindowCorners ifTrue: [
		Smalltalk isMorphic ifTrue: [World fullRepaintNeeded]].

	(prefSymbol == #smartUpdating) ifTrue:
		[SystemWindow allSubInstancesDo:
			[:aWindow | aWindow amendSteppingStatus]].
! !

!Preferences class methodsFor: 'preferences dictionary' stamp: 'jm 10/16/2002 13:02'!
openPreferencesInspector
	"Open a window on the current set of preferences choices, allowing the user to view and change their settings. If there is no Morphic in this image, use a dictionary inspector."
	
	Smalltalk hasMorphic
		ifFalse:	[FlagDictionary inspectWithLabel: 'Preferences']
		ifTrue:	[self openPreferencesControlPanel].
! !

!Preferences class methodsFor: 'preferences dictionary' stamp: 'jm 5/29/2003 19:28'!
orphanedHelpEntries
	"Answer a list of all the keys in the help dictionary that are not represented by actual preferences"
	"Preferences orphanedHelpEntries"

	| allFlags |
	allFlags _ self allPreferenceFlagKeys.
	^ HelpDictionary keys asArray sort select: [:k | (allFlags includes: k) not]

! !

!Preferences class methodsFor: 'preferences dictionary' stamp: 'sw 1/13/2000 11:12'!
preferencesLackingHelp
	^ self allPreferenceFlagKeys select:
		[:aKey | (self helpMessageOrNilForPreference: aKey) == nil]

"Preferences preferencesLackingHelp"! !

!Preferences class methodsFor: 'preferences dictionary' stamp: 'jm 5/29/2003 19:31'!
preferencesLackingInitializers
	"Preferences preferencesLackingInitializers"

	| initializedPrefs |
	initializedPrefs _ self allPreferenceInitializationSpecs collect: [:info | info first].
	^ self allPreferenceFlagKeys select: [:k | (initializedPrefs includes: k) not]
! !

!Preferences class methodsFor: 'preferences dictionary' stamp: 'jm 10/5/2002 06:56'!
setPreference: prefSymbol toValue: aBoolean

	(FlagDictionary at: prefSymbol ifAbsent: [nil]) ~~ aBoolean
		ifTrue: [
			FlagDictionary at: prefSymbol put: aBoolean.
			self noteThatFlag: prefSymbol justChangedTo: aBoolean].
! !

!Preferences class methodsFor: 'preferences dictionary' stamp: 'jhm 10/15/97 17:12'!
valueOfFlag: aFlagName

	^ FlagDictionary at: aFlagName ifAbsent: [false]
! !


!Preferences class methodsFor: 'preferences panel' stamp: 'jm 6/5/2003 21:28'!
addHaloControlsTo: controlPage

	controlPage addTransparentSpacerOfSize: (0 @ 4).
	controlPage addMorphBack: self haloThemeRadioButtons.
	controlPage addTransparentSpacerOfSize: (0 @ 4).
! !

!Preferences class methodsFor: 'preferences panel' stamp: 'jm 5/29/2003 19:03'!
allPreferenceFlagKeys
	"Preferences allPreferenceFlagKeys"

	^ FlagDictionary keys asArray sort
! !

!Preferences class methodsFor: 'preferences panel' stamp: 'jm 6/15/2003 16:43'!
defaultBackgroundColor
	"The background for the preferences control panel."

	^ Color white
! !

!Preferences class methodsFor: 'preferences panel' stamp: 'jm 5/29/2003 19:02'!
factoredCategories
	"Preferences factoredCategories"
	"CategoryInfo _ nil"

	| prefsWithoutInits extraItem |
	CategoryInfo ifNil: [CategoryInfo _ self initialCategoryInfo].
	((prefsWithoutInits _ self preferencesLackingInitializers) size > 0)
		ifTrue: [extraItem _ (Array with: 'uncategorized' with: prefsWithoutInits copy asArray sort)].
	^ extraItem
		ifNil: [CategoryInfo]
		ifNotNil: [CategoryInfo, (Array with: extraItem)]
! !

!Preferences class methodsFor: 'preferences panel' stamp: 'sw 1/13/2000 11:07'!
helpMessageForPreference: aSymbol
	^ (self helpMessageOrNilForPreference: aSymbol) ifNil:
		['No help available for ', aSymbol]! !

!Preferences class methodsFor: 'preferences panel' stamp: 'sw 1/13/2000 11:07'!
helpMessageOrNilForPreference: aSymbol
	"If the HelpDictionary has a help message prepared for aSymbol, return it, else return nil"
	HelpDictionary ifNil: [self initializeHelpMessages].
	^ HelpDictionary at: aSymbol ifAbsent: [nil]! !

!Preferences class methodsFor: 'preferences panel' stamp: 'jm 5/29/2003 19:04'!
initialCategoryInfo

	| categories |
	categories _ IdentityDictionary new.
	self allPreferenceInitializationSpecs do: [:spec |
		spec size > 2 ifTrue: [
			spec third do: [:sym | 
				(categories includesKey: sym) ifFalse:
					[categories at: sym put: OrderedCollection new].
				(categories at: sym) add: spec first]]].

	^ categories keys copy asArray sort collect: [:k |
		Array with: k with: (categories at: k) copy asArray sort]
! !

!Preferences class methodsFor: 'preferences panel' stamp: 'jm 12/7/2005 09:48'!
openPreferencesControlPanel
	"Preferences openPreferencesControlPanel"

	| panels panelColor panel prefsPanel window |
	panels _ Dictionary new.
	panelColor _ Color r: 0.645 g: 1.0 b: 1.0.
	self factoredCategories do: [:entry |
			panel _ (AlignmentMorph newColumn isSticky: true) color: panelColor.
			panel borderColor: panelColor; inset: 4.
			entry second do: [:pref |
				panel addMorphBack: (Preferences buttonRepresenting: pref wording: pref color: nil)].
			entry first == #halos ifTrue: [self addHaloControlsTo: panel].
			panels at: entry first put: panel].
	prefsPanel _ CategorizedControlPanel new panels: panels.
	prefsPanel currentCategory: 'general'.
	prefsPanel extent: 194@212.

	Smalltalk isMorphic
		ifTrue: [
			window _ (SystemWindow labelled: 'Preferences') model: nil.
			window bounds: (0@0 extent: 220@270).
			window addMorph: prefsPanel frame: (0@0 extent: 1@1).
			window updatePaneColors.
			window setProperty: #minimumExtent toValue: 220@270.
			self currentWorld activeHand attachMorph: window.
			self currentWorld startSteppingSubmorphsOf: window]
		ifFalse: [
			(window _ MVCWiWPasteUpMorph newWorldForProject: nil) addMorph: prefsPanel.
			window startSteppingSubmorphsOf: prefsPanel.
			MorphWorldView openOn: window label: 'Preferences' extent: prefsPanel extent + 2].
! !

!Preferences class methodsFor: 'preferences panel' stamp: 'sw 1/19/2000 13:43'!
resetCategoryInfo
	"Preferences resetCategoryInfo"

	CategoryInfo _ nil! !

!Preferences class methodsFor: 'preferences panel' stamp: 'sw 11/11/1998 16:39'!
setHelpFor: prefName toString: aString
	HelpDictionary ifNil: [self initializeHelpMessages].
	HelpDictionary at: prefName put: aString! !


!Preferences class methodsFor: 'menu parameters' stamp: 'di 1/14/1999 20:16'!
menuBorderColor
	Display depth <= 2 ifTrue: [^ Color black].
	^ Parameters at: #menuBorderColor! !

!Preferences class methodsFor: 'menu parameters' stamp: 'sw 11/3/1998 11:16'!
menuBorderWidth
	^ Parameters at: #menuBorderWidth! !

!Preferences class methodsFor: 'menu parameters' stamp: 'di 1/14/1999 20:17'!
menuColor
	Display depth <= 2 ifTrue: [^ Color white].
	^ Parameters at: #menuColor! !

!Preferences class methodsFor: 'menu parameters' stamp: 'sw 11/3/1998 11:37'!
menuLineLowerColor
	^ Parameters at: #menuLineLowerColor! !

!Preferences class methodsFor: 'menu parameters' stamp: 'sw 11/3/1998 11:36'!
menuLineUpperColor
	^ Parameters at: #menuLineUpperColor! !

!Preferences class methodsFor: 'menu parameters' stamp: 'di 1/14/1999 20:19'!
menuTitleBorderColor
	Display depth <= 2 ifTrue: [^ Color black].
	^ Parameters at: #menuTitleBorderColor! !

!Preferences class methodsFor: 'menu parameters' stamp: 'sw 11/3/1998 11:16'!
menuTitleBorderWidth
	^ Parameters at: #menuTitleBorderWidth! !

!Preferences class methodsFor: 'menu parameters' stamp: 'di 1/14/1999 20:18'!
menuTitleColor
	Display depth = 1 ifTrue: [^ Color white].
	Display depth = 2 ifTrue: [^ Color gray].
	^ Parameters at: #menuTitleColor! !

!Preferences class methodsFor: 'menu parameters' stamp: 'sw 11/3/1998 11:33'!
restoreDefaultMenuParameters
	"Preferences restoreDefaultMenuParameters"
	"Restore the four color choices of the original implementors of MorphicMenus"

	Parameters at: #menuColor put: (Color r: 0.8 g: 0.8 b: 0.8).
	Parameters at: #menuBorderColor put: #raised.
	Parameters at: #menuBorderWidth put: 2.

	Parameters at: #menuTitleColor put: (Color r: 0.5 g: 1 b: 0.75).
	Parameters at: #menuTitleBorderColor put: #inset.
	Parameters at: #menuTitleBorderWidth put: 1.

	Parameters at: #menuLineUpperColor put: (Color r: 0.667 g: 0.667 b: 0.667).
	Parameters at: #menuLineLowerColor put: (Color r: 0.833 g: 0.833 b: 0.833).! !


!Preferences class methodsFor: 'hard-coded prefs' stamp: 'jm 10/4/2002 15:02'!
browseToolClass

	^ Browser
! !

!Preferences class methodsFor: 'hard-coded prefs' stamp: 'programmatic 7/15/1999 09:55'!
cmdKeysInText
	"compiled programatically -- return hard-coded preference value"
	^ true! !


!Preferences class methodsFor: 'pref buttons' stamp: 'jm 12/15/2005 13:53'!
buttonRepresenting: prefSymbol wording: aString color: aColor
	"self currentHand attachMorph: (Preferences buttonRepresenting: #balloonHelpEnabled wording: 'Balloon Help' color: nil)"
	"Return a button that controls the setting of prefSymbol.  It will keep up to date even if the preference value is changed in a different place"
	| outerButton aButton str aHelp miniWrapper |
	(FlagDictionary includesKey: prefSymbol) ifFalse: [self error: 'Unknown preference: ', prefSymbol printString].
	outerButton _ AlignmentMorph newRow height: 24.
	outerButton color:  (aColor ifNil: [Color r: 0.645 g: 1.0 b: 1.0]).
	outerButton hResizing: #spaceFill; vResizing: #shrinkWrap.
	outerButton addMorph: (aButton _ ThreePhaseButtonMorph checkBox).
	aButton
		target: self;
		actionSelector: #togglePreference:;
		arguments: (Array with: prefSymbol);
		target: Preferences;
		getSelector: prefSymbol.

	outerButton addTransparentSpacerOfSize: (2 @ 0).
	str _ StringMorph contents: aString font: (StrikeFont fontName: 'NewYork' size: 12).
	miniWrapper _ AlignmentMorph newRow hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	miniWrapper color: Color transparent.
	miniWrapper addMorphBack: str lock.
	outerButton addMorphBack: miniWrapper.
	aButton setBalloonText: (aHelp _ Preferences helpMessageForPreference: prefSymbol).
	miniWrapper setBalloonText: aHelp; setProperty: #balloonTarget toValue: aButton.

	^ outerButton! !

!Preferences class methodsFor: 'pref buttons' stamp: 'sw 7/13/1999 18:55'!
togglePreference: prefSymbol
	| curr |
	curr _ (FlagDictionary at: prefSymbol ifAbsent: [^ self error: 'unknown pref: ', prefSymbol printString]).
	self setPreference: prefSymbol toValue: (curr == true) not

! !


!Preferences class methodsFor: 'misc' stamp: 'sw 10/6/1999 15:20'!
addModelItemsToWindowMenu: aMenu
	aMenu addLine.
	aMenu add: 'restore default preference settings' target: self action: #chooseInitialSettings.
	aMenu add: 'restore default text highlighting' target: self action: #initializeTextHighlightingParameters! !

!Preferences class methodsFor: 'misc' stamp: 'sw 7/13/1999 16:52'!
menuColorString
	^ (self valueOfFlag: #menuColorFromWorld)
		ifFalse:
			['start menu-color-from-world']
		ifTrue:
			['stop menu-color-from-world']! !

!Preferences class methodsFor: 'misc' stamp: 'sw 11/30/1999 22:23'!
roundedCornersString
	^ ((self valueOfFlag: #roundedWindowCorners)
		ifFalse:
			['start']
		ifTrue:
			['stop']), ' rounding window corners'! !

!Preferences class methodsFor: 'misc' stamp: 'sw 6/11/1999 20:53'!
staggerPolicyString
	^ (self valueOfFlag: #reverseWindowStagger)
		ifTrue: ['switch to tiling']
		ifFalse: ['switch to staggering']! !

!Preferences class methodsFor: 'misc' stamp: 'sw 7/13/1999 16:51'!
toggleMenuColorPolicy
	self togglePreference: #menuColorFromWorld! !

!Preferences class methodsFor: 'misc' stamp: 'sw 7/13/1999 16:52'!
toggleRoundedCorners
	self togglePreference: #roundedWindowCorners! !

!Preferences class methodsFor: 'misc' stamp: 'sw 6/11/1999 20:49'!
toggleWindowPolicy
	self togglePreference: #reverseWindowStagger! !


!Preferences class methodsFor: 'personalization' stamp: 'sw 7/1/1999 23:07'!
compileHardCodedPref: prefName enable: aBoolean
	"Compile a method that returns a simple true or false (depending on the value of aBoolean) when Preferences is sent prefName as a message"

	self class compileProgrammatically: (prefName asString, '
	"compiled programatically -- return hard-coded preference value"
	^ ', aBoolean storeString) classified: 'hard-coded prefs'.
	
"Preferences compileHardCodedPref: #testing enable: false"! !

!Preferences class methodsFor: 'personalization' stamp: 'jm 7/3/2004 17:56'!
disableProgrammerFacilities
	"Warning: do not call this lightly!! It disables all access to menus, debuggers, halos. There is no guaranteed return from this, which is to say, you cannot necessarily re-enable these things once they are disabled--you can only use whatever the UI of the current project affords, and you cannot even snapshot--you can only quit. 

You can completely reverse the work of this method by calling enableProgrammerFacilities--provided, of course, that you have left yourself a way to call that method!!

To set up a system that will come up with all the programmer facilities disabled, you have to request the snapshot in the same breath as you disable the programmer facilities. To do this, put the following line into the 'do' menu and then evaluate it from that 'do' menu:

 	Preferences disableProgrammerFacilities.

You will be prompted for a new image name under which to save the resulting image."

	self beep.
	(self confirm: 'CAUTION!!!!
This is a drastic step!!
Do you really want to do this?')
		ifFalse: [^ self inform: 'No change. Whew!!'].

	self disable: #cmdDotEnabled.								"disable user-interrupt key"
	self compileHardCodedPref: #cmdKeysInText enable: false.		"disable cmd-keys in text editors"
	self enable: #noviceMode.
	self disable: #warnIfNoSourcesFile.
	self disable: #warnIfNoChangesFile.
	Smalltalk saveAs.
! !

!Preferences class methodsFor: 'personalization' stamp: 'jm 7/3/2004 17:49'!
enableProgrammerFacilities
	"Meant as a one-touch recovery from a #disableProgrammerFacilities call."
	"Preferences enableProgrammerFacilities"

	self enable: #cmdDotEnabled.
	self compileHardCodedPref: #cmdKeysInText enable: true.
	self disable: #noviceMode.
	self enable: #warnIfNoSourcesFile.
	self enable: #warnIfNoChangesFile.
! !


!Preferences class methodsFor: 'help' stamp: 'jm 10/12/2005 12:01'!
helpMsgsAThroughF
	"This, and the other methodds in this category, are automatically called whenever you call:
   		Preferences initializeHelpMessages
	or
		Preferences callHelpMessageInitializers"

	^ #( 
		(annotationPanes
			'If true, a thin horizontal annotation pane is used in browsers.')

		(balloonHelpEnabled
			'Whether balloon help should be offered when the cursor lingers over certain objects.')

		(browseWithPrettyPrint
			'If true, browsers will automatically format their contents')

		(caseSensitiveFinds
			'If true, then the "find" command in text will always make its searches in a case-sensitive fashion')

		(changeSetVersionNumbers
			'If true, version-number extensions will be used when constructing names for change-set fileouts.  If false, timestamp extensions are used.')

		(checkForSlips 
			'If true, then whenever you file out a change set, it is checked for ''slips'' and if any are found, you are so informed and given a chance to open a browser on them')

		(cmdDotEnabled
			'If true, cmd-dot brings up a debugger;
		if false, the cmd-dot interrupt is disabled')

		(colorWhenPrettyPrinting
			'If true, then when browseWithPrettyPrint is in effect, the pretty-printing will be presented in color')

		(confirmFirstUseOfStyle
			'If true, the first attempt to submit a method with non-standard style will bring up a confirmation dialog')

		(debugHaloHandle 
			'If true, a special debugging halo handle is displayed at the right of the halo; if false, no such handle is shown.')

		(diffsInChangeList
			'If true, changeList browsers and Versions browsers will open up by default showing diffs, i.e. revealing the differences between successive versions or between the in-memory code and the code on disk')

		(fastDragWindowForMorphic
			'If true, morphic window drag will be done by dragging an outline of the window.')

	)  "end of list"
! !

!Preferences class methodsFor: 'help' stamp: 'programmatic 5/10/2000 15:45'!
helpMsgsAdditionbrowsingalternativeBrowseIt
	^ #((alternativeBrowseIt 'if true, then the "browse it" (cmd-b) feature in the text editor will offer you a list of class names matching the selection, if appropriate' ) )! !

!Preferences class methodsFor: 'help'!
helpMsgsAdditionscrollinghiddenScrollBars
	^ #((hiddenScrollBars 'If true, then scrollbars will only be shown if a pane''s contents are too large to fit inside the pane.' ) )! !

!Preferences class methodsFor: 'help' stamp: 'jm 7/3/2004 18:32'!
helpMsgsGThroughP

		^ #(
(ignoreStyleIfOnlyBold
	'If true, then any method submission in which the only style change is for bolding will be treated as a method with no style specifications')

(inboardScrollbars
	'If true, then ScrollPane will place scrollbars inside on the right and will not hide them on exit')

(logDebuggerStackToFile
	'If true, whenever you fall into a debugger a summary of its stack will be written to a file named
''SqueakDebug.log''')

(menuColorFromWorld
	'Governs whether the colors used in morphic menus should be derived from the color of the world background')

(noviceMode 
	'If true, certain novice-mode accommodations are made')

(optionalButtons
	'If true, then optional buttons will be used in certain standard tools, including browsers, message lists, fileLists, changeLists, and debuggers')

(printAlternateSyntax
	'If true, then
prettyPrint using experimental syntax.
Otherwise use normal ST-80 syntax')

(projectZoom
	'If true, then show a zoom effect when entering or leaving projects. This can be costly of memory (at least an extra screen buffer) so dont use it in low space situations. But it is cool')

(promptForUpdateServer
	'If false, the prompt for server choice when updating code from the server is suppressed. Set this to false to leave the server choice unchanged from update to update')

	)
! !

!Preferences class methodsFor: 'help' stamp: 'jm 7/1/2004 22:28'!
helpMsgsQThroughZ

	^ #(
		(reverseWindowStagger
			'If true, a reverse-stagger strategy  is used for determining where newly launched windows will be placed; if false, a direct- stagger strategy is used.')

		(roundedMenuCorners
			'Whether morphic menus should have rounded corners')

		(roundedWindowCorners
			'Governs whether morphic system windows should have rounded corners')

		(scrollBarsNarrow
			'If true, morphic scrollbars will be narrow.')

		(scrollBarsOnRight
			'If true, morphic scrollbars in subsequently opened windows will appear on the right side of their pane.')

		(scrollBarsWithoutMenuButton
			'If true, morphic scrollbars in subsequently opened windows will not include a menu button.')

		(smartUpdating
			'If true, then morphic tools such as browsers and inspectors will keep their contents up to date automatically, so that if something changes anywhere, the change will be reflected everywhere.')

		(soundQuickStart
			'If true, attempt to start playing sounds using optional "quick start"')

		(soundsEnabled
			'If false, all sound playing is disabled')

		(timeStampsInMenuTitles
			'If true, then the author''s timestamp is displayed as the menu title of any message list; if false, no author''s timestamps are shown')

		(thoroughSenders
			'If true, then ''senders'' browsers will dive inside structured literals in their search')

		(twentyFourHourFileStamps
			'If #changeSetVersionNumbers is false, this preference determines whether the date/time suffix used with changeset fileouts is based on a 24-hr clock or a 12-hr clock.')

		(uniformWindowColors
			'If true, then all standard windows are given the same color rather than their customized window-type-specific colors')

		(warnIfNoChangesFile
			'If true, then you will be warned, whenever you start up, if no changes file
can be found')

		(warnIfNoSourcesFile 
			'If true, then you will be warned, whenever you start up, if no sources file can be found')
	)
! !


!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 5/10/2000 15:45'!
alternativeBrowseIt
	^ self valueOfFlag: #alternativeBrowseIt! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 1/13/2000 10:57'!
annotationPanes
	^ self valueOfFlag: #annotationPanes! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 10/16/2002 13:04'!
autoAccessors
	^ self valueOfFlag: #autoAccessors! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 16:26'!
balloonHelpEnabled
	^ self valueOfFlag: #balloonHelpEnabled! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 16:26'!
browseWithPrettyPrint
	^ self valueOfFlag: #browseWithPrettyPrint! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 10/16/2002 13:04'!
browserShowsPackagePane
	^ self valueOfFlag: #browserShowsPackagePane! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 10/1/1999 20:55'!
caseSensitiveFinds
	^ self valueOfFlag: #caseSensitiveFinds! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 11/13/1999 22:52'!
changeSetVersionNumbers
	^ self valueOfFlag: #changeSetVersionNumbers! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 1/13/2000 12:21'!
checkForSlips
	^ self valueOfFlag: #checkForSlips! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 16:26'!
cmdDotEnabled
	^ self valueOfFlag: #cmdDotEnabled! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 11/6/1999 22:54'!
colorWhenPrettyPrinting
	^ self valueOfFlag: #colorWhenPrettyPrinting! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 16:27'!
confirmFirstUseOfStyle
	^ self valueOfFlag: #confirmFirstUseOfStyle! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 10/16/2002 13:04'!
conversionMethodsAtFileOut
	^ self valueOfFlag: #conversionMethodsAtFileOut! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 1/13/2000 10:57'!
debugHaloHandle
	^ self valueOfFlag: #debugHaloHandle! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 1/13/2000 10:57'!
diffsInChangeList
	^ self valueOfFlag: #diffsInChangeList! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 16:27'!
fastDragWindowForMorphic
	^ self valueOfFlag: #fastDragWindowForMorphic! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 6/1/2000 16:56'!
hiddenScrollBars
	^ self valueOfFlag: #hiddenScrollBars! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 16:28'!
ignoreStyleIfOnlyBold
	^ self valueOfFlag: #ignoreStyleIfOnlyBold! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 16:28'!
inboardScrollbars
	^ self valueOfFlag: #inboardScrollbars! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 16:28'!
logDebuggerStackToFile
	^ self valueOfFlag: #logDebuggerStackToFile! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 7/1/1999 22:32'!
menuColorFromWorld
	^ self valueOfFlag: #menuColorFromWorld! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 7/1/1999 23:28'!
mouseOverHaloseEnabled
	^ self valueOfFlag: #mouseOverHaloseEnabled! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 16:28'!
noviceMode
	^ self valueOfFlag: #noviceMode! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 12/13/1999 10:51'!
optionalButtons
	^ self valueOfFlag: #optionalButtons! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 20:50'!
printAlternateSyntax
	^ self valueOfFlag: #printAlternateSyntax! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 1/13/2000 10:57'!
projectZoom
	^ self valueOfFlag: #projectZoom! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 1/13/2000 10:57'!
promptForUpdateServer
	^ self valueOfFlag: #promptForUpdateServer! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 16:28'!
reverseWindowStagger
	^ self valueOfFlag: #reverseWindowStagger! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 11/26/1999 11:42'!
roundedMenuCorners
	^ self valueOfFlag: #roundedMenuCorners! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 7/1/1999 22:32'!
roundedWindowCorners
	^ self valueOfFlag: #roundedWindowCorners! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 1/13/2000 10:57'!
scrollBarsNarrow
	^ self valueOfFlag: #scrollBarsNarrow! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 1/13/2000 10:57'!
scrollBarsOnRight
	^ self valueOfFlag: #scrollBarsOnRight! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 1/13/2000 10:57'!
scrollBarsWithoutMenuButton
	^ self valueOfFlag: #scrollBarsWithoutMenuButton! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 10/20/1999 12:22'!
smartUpdating
	^ self valueOfFlag: #smartUpdating! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 1/13/2000 10:57'!
soundQuickStart
	^ self valueOfFlag: #soundQuickStart! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 1/12/2000 22:40'!
soundsEnabled
	^ self valueOfFlag: #soundsEnabled! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 16:29'!
thoroughSenders
	^ self valueOfFlag: #thoroughSenders! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 1/13/2000 12:21'!
timeStampsInMenuTitles
	^ self valueOfFlag: #timeStampsInMenuTitles! !

!Preferences class methodsFor: 'standard preferences' stamp: 'programmatic 11/13/1999 22:52'!
twentyFourHourFileStamps
	^ self valueOfFlag: #twentyFourHourFileStamps! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 1/12/2000 22:56'!
useAnnotationPanes
	"Because of so any senders, this wording retained here though we defer to the renamed flag"

	^ self valueOfFlag: #annotationPanes! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 16:30'!
warnIfNoChangesFile
	^ self valueOfFlag: #warnIfNoChangesFile! !

!Preferences class methodsFor: 'standard preferences' stamp: 'sw 6/28/1999 16:30'!
warnIfNoSourcesFile
	^ self valueOfFlag: #warnIfNoSourcesFile! !


!Preferences class methodsFor: 'initial values' stamp: 'jm 10/12/2005 12:01'!
initialValuesAToM
	"CategoryInfo _ nil"
	"Preferences openFactoredPanel"
	^#(
		(annotationPanes					false	(browsing))
		(autoAccessors						false	(general))
		(balloonHelpEnabled					true	(morphic))
		(browserShowsPackagePane			false	(browsing))
		(browseWithPrettyPrint				false	(browsing))
		(caseSensitiveFinds					false	(general))
		(changeSetVersionNumbers			true	(fileout))
		(checkForSlips						true	(fileout))
		(cmdDotEnabled						true	(debug))
		(colorWhenPrettyPrinting			false	(browsing))
		(confirmFirstUseOfStyle				true	(browsing))
		(conversionMethodsAtFileOut			false	(fileout))
		(debugHaloHandle					true	(debug halos))
		(diffsInChangeList					true	(browsing))
		(fastDragWindowForMorphic			false	(windows))
		(ignoreStyleIfOnlyBold				true	(browsing))
		(inboardScrollbars					false	(scrolling))
		(logDebuggerStackToFile				true	(debug))
		(menuColorFromWorld				false	(menus))
)
! !

!Preferences class methodsFor: 'initial values' stamp: 'programmatic 5/10/2000 15:45'!
initialValuesAdditionbrowsingalternativeBrowseIt
	^ #((alternativeBrowseIt false (browsing ) ) )! !

!Preferences class methodsFor: 'initial values'!
initialValuesAdditionscrollinghiddenScrollBars
	^ #((hiddenScrollBars false (scrolling ) ) )! !

!Preferences class methodsFor: 'initial values' stamp: 'jm 7/1/2004 22:28'!
initialValuesNToZ
	"Another lot of initial values for prefs. Simply placing methods of this sort in the 'initial values' category will assure that the initial values provided are ascribed to the preference when prefs are initialized."
	"Preferences resetCategoryInfo"

	^ #(	
		(noviceMode							false	(general))
		(optionalButtons						false	(general))
		(printAlternateSyntax				false	(browsing))
		(projectZoom							false	(general))
		(promptForUpdateServer				true	(updates))
		(reverseWindowStagger				true	(windows))
		(roundedMenuCorners				true	(menus))
		(roundedWindowCorners				false	(windows))
		(scrollBarsNarrow					false	(scrolling))
		(scrollBarsOnRight					false	(scrolling))
		(scrollBarsWithoutMenuButton		false	(menus scrolling))
		(smartUpdating						true	(browsing))
		(soundsEnabled						false	(media))
		(soundQuickStart					false	(media))
		(thoroughSenders					true	(general))
		(timeStampsInMenuTitles				false	(menus))
		(twentyFourHourFileStamps			true	(fileout)) 
		(warnIfNoChangesFile				true	(general))
		(warnIfNoSourcesFile				true	(general))
	)

! !


!Preferences class methodsFor: 'window colors' stamp: 'sw 7/12/1999 17:41'!
installBrightWindowColors
	"Preferences installBrightWindowColors"
	| windowColorDict |
	(Parameters includesKey: #windowColors) ifFalse:
		[Parameters at: #windowColors put: IdentityDictionary new].
	windowColorDict _ Parameters at: #windowColors.

	#(	(Browser				lightGreen)
		(ChangeList				lightBlue)
		(ChangeSorter			lightBlue)
		(Debugger				lightRed)
		(DualChangeSorter		lightBlue)
		(FileContentsBrowser		tan)
		(FileList					lightMagenta)
		(MessageSet				lightBlue)
		(Object					white)
		(SelectorBrowser			lightCyan)
		(StringHolder			lightYellow)
		(TranscriptStream		lightOrange))

	do:
			[:pair |
				windowColorDict at: pair first put: (Color perform: pair last)]
! !

!Preferences class methodsFor: 'window colors' stamp: 'sw 7/12/1999 17:41'!
installPastelWindowColors
	"Preferences installPastelWindowColors"
	| windowColorDict |
	(Parameters includesKey: #windowColors) ifFalse:
		[Parameters at: #windowColors put: IdentityDictionary new].
	windowColorDict _ Parameters at: #windowColors.

	#(	(Browser				paleGreen)
		(ChangeList				paleBlue)
		(ChangeSorter			paleBlue)
		(Debugger				veryPaleRed)
		(DualChangeSorter		paleBlue)
		(FileContentsBrowser		paleTan)
		(FileList					paleMagenta)
		(MessageSet				paleBlue)
		(Object					white)
		(SelectorBrowser			palePeach)
		(StringHolder			paleYellow)
		(TranscriptStream		paleOrange))

	do:
			[:pair |
				windowColorDict at: pair first put: (Color perform: pair last)]
! !

!Preferences class methodsFor: 'window colors' stamp: 'sw 7/13/1999 15:12'!
installUniformWindowColors
	"Preferences installUniformWindowColors"
	| windowColorDict |
	(Parameters includesKey: #windowColors) ifFalse:
		[Parameters at: #windowColors put: IdentityDictionary new].
	windowColorDict _ Parameters at: #windowColors.

	#(	(Browser				white)
		(ChangeList				white)
		(ChangeSorter			white)
		(Debugger				white)
		(DualChangeSorter		white)
		(FileContentsBrowser		white)
		(FileList					white)
		(MessageSet				white)
		(Object					white)
		(SelectorBrowser			white)
		(StringHolder			white)
		(TranscriptStream		white))

	do:
			[:pair |
				windowColorDict at: pair first put: (Color perform: pair last)]
! !

!Preferences class methodsFor: 'window colors' stamp: 'sw 10/27/1999 11:34'!
setWindowColorFor: modelSymbol to: incomingColor
	| aColor |
	(Parameters includesKey: #windowColors) ifFalse:
		[Parameters at: #windowColors put: IdentityDictionary new.
		self installBrightWindowColors].
	aColor _ incomingColor asNontranslucentColor.
	(aColor = ColorPickerMorph perniciousBorderColor or: [aColor = Color black]) ifTrue: [^ self].
	^ (Parameters at: #windowColors) at: modelSymbol put: aColor
	! !

!Preferences class methodsFor: 'window colors' stamp: 'jm 5/31/2003 16:44'!
windowColorClasses

	^ #(Browser	 ChangeList ChangeSorter Debugger DualChangeSorter FileContentsBrowser FileList	MessageSet StringHolder TranscriptStream)
! !

!Preferences class methodsFor: 'window colors' stamp: 'sw 7/13/1999 16:03'!
windowColorFor: aModelClassName
	| classToCheck windowColors |
	(Parameters includesKey: #windowColors) ifFalse:
		[Parameters at: #windowColors put: IdentityDictionary new.
		self installBrightWindowColors].
	classToCheck _ Smalltalk at: aModelClassName.
	windowColors _ Parameters at: #windowColors.
	[windowColors includesKey: classToCheck name]
		whileFalse:
			[classToCheck _ classToCheck superclass].
	^ windowColors at: classToCheck name ifAbsent: [Color white]
	! !

!Preferences class methodsFor: 'window colors' stamp: 'sw 7/13/1999 20:10'!
windowColorHelp
	"The 'Window Colors' panel lets you select colors for the standard Squeak windows.

The three buttons entitled 'Bright', 'Pastel', and 'White' let you install three different standard color schemes.

The rows of color swatches and tool names indicate what the color for each tool is currently set to be.  You can change the color for any tool by clicking on its swatch, then choosing a new color in the ensuing color-picker.

'TranscriptStream' governs the color of Transcripts.
'MessageSet' governs the color of message-list browsers.
'ChangeList' governs the color of change-list browsers *and* versions browsers.
'StringHolder' governs the color of Workspaces.

Any time you request a new window (browser, file-list, etc.), the current window-color setting for that kind of window will determine what color is used.

But note that if in Morphic, the 'Tools' flap and the 'Standard Parts Bin' both contain pre-allocated window prototypes, and these will not automatically change when you edit the standard window colors.  To get the Tools flap to reflect your latest color choices, hit the 'Update Tools Flap' button.  To get the standard parts bin to reflect your latest color choices, evaluate 'ScriptingSystem resetStandardPartsBin'"

	(StringHolder new contents: (self class firstCommentAt: #windowColorHelp))
		openLabel: 'About Window Colors'

	"Preferences windowColorHelp"! !

!Preferences class methodsFor: 'window colors' stamp: 'jm 12/7/2005 09:48'!
windowSpecificationPanel
	"Preferences windowSpecificationPanel"

	| aPanel buttonRow aButton aRow aSwatch aColor aWindow aMiniWorld |
	aPanel _ AlignmentMorph newColumn hResizing: #shrinkWrap; vResizing: #shrinkWrap.

	aPanel addMorph: (buttonRow _ AlignmentMorph newRow color: (aColor _ Color tan lighter)).
	
	aButton _ SimpleButtonMorph new target: self.
	buttonRow addTransparentSpacerOfSize: 2@0.
	buttonRow addMorphBack: (SimpleButtonMorph new label: '?'; target: self; actionSelector: #windowColorHelp; setBalloonText: 'Click for an explanation of this panel'; color: Color veryVeryLightGray; yourself).
	buttonRow addTransparentSpacerOfSize: 8@0.

	#(	('Bright' 	installBrightWindowColors	yellow
			'Use standard bright colors for all windows.')
		('Pastel'		installPastelWindowColors	paleMagenta
			'Use standard pastel colors for all windows.')
		('White'	installUniformWindowColors		white
			'Use white backgrounds for all standard windows.')
	) do: [:quad |
			aButton _ aButton fullCopy
				label: quad first;
				actionSelector: quad second;
				color: (Color colorFrom: quad third);
				setBalloonText: quad fourth;
				yourself.
			buttonRow addMorphBack: aButton.
			buttonRow addTransparentSpacerOfSize: 10@0].

	self windowColorClasses do: [:clName | 
			aRow _ AlignmentMorph newRow color: aColor.
			aSwatch _ UpdatingRectangleMorph new
				target: self;
				getSelector: #windowColorFor:;
				putSelector: #setWindowColorFor:to:;
				argument: clName;
				extent: (40 @ 20);
				yourself.
			aRow addMorphFront: aSwatch.
			aRow addTransparentSpacerOfSize: (12 @ 1).
			aRow addMorphBack:
				(StringMorph contents: clName font: TextStyle defaultFont).
			aPanel addMorphBack: aRow].

	 Smalltalk isMorphic
			ifTrue: [
					aWindow _ aPanel wrappedInWindowWithTitle: 'Window Colors'.
					self currentWorld activeHand attachMorph: aWindow.
					aWindow world startSteppingSubmorphsOf: aPanel.]
			ifFalse: [
					(aMiniWorld _ MVCWiWPasteUpMorph newWorldForProject: nil)
						addMorph: aPanel.
					aMiniWorld startSteppingSubmorphsOf: aPanel.
					MorphWorldView openOn: aMiniWorld
						label: 'Window Colors'
						extent: aMiniWorld fullBounds extent].
! !


!Preferences class methodsFor: 'text highlighting' stamp: 'jm 12/7/2005 09:50'!
chooseInsertionPointColor

	ColorPickerMorph new
		sourceHand: self currentWorld activeHand;
		target: self;
		selector: #insertionPointColor:;
		originalColor: self insertionPointColor;
		addToWorld: self currentWorld
			near: self currentWorld activeHand cursorBounds.
! !

!Preferences class methodsFor: 'text highlighting' stamp: 'jm 12/7/2005 09:50'!
chooseTextHighlightColor

	ColorPickerMorph new
		sourceHand: self currentWorld activeHand;
		target: self;
		selector: #textHighlightColor:;
		originalColor: self textHighlightColor;
		addToWorld: self currentWorld
			near: self currentWorld activeHand cursorBounds.
! !

!Preferences class methodsFor: 'text highlighting' stamp: 'sw 9/7/1999 13:07'!
initializeTextHighlightingParameters
	"Preferences initializeTextHighlightingParameters"
	Parameters at: #insertionPointColor put: (Color r: 0.4 g: 1.0 b: 0).
	Parameters at: #textHighlightColor put: (Color r: 0.4 g: 1.0 b: 0).! !

!Preferences class methodsFor: 'text highlighting' stamp: 'sw 9/7/1999 12:53'!
insertionPointColor
	^ Parameters at: #insertionPointColor! !

!Preferences class methodsFor: 'text highlighting' stamp: 'sw 9/7/1999 12:54'!
insertionPointColor: aColor
	Parameters at: #insertionPointColor put: aColor! !

!Preferences class methodsFor: 'text highlighting' stamp: 'sw 9/7/1999 12:53'!
textHighlightColor
	^ Parameters at: #textHighlightColor! !

!Preferences class methodsFor: 'text highlighting' stamp: 'sw 9/7/1999 12:54'!
textHighlightColor: aColor
	Parameters at: #textHighlightColor put: aColor! !


!Preferences class methodsFor: 'pretty-printing' stamp: 'jm 10/16/2002 13:09'!
initializeSyntaxColorsAndStyles
	"To change the color choices, you can simply edit this method, and then evaluate the following line:
		Preferences initializeSyntaxColorsAndStyles
	Later, people may wish to produce interactive editors for modifying the choices"

	| specs |
	SyntaxColorsAndStyles _ IdentityDictionary new.
	# (	(temporaryVariable		(magenta		bold))
		(methodArgument		(magenta		italic))
		(blockArgument			(magenta		italic))
		(comment				(red				normal))
		(variable				(blue			bold))
		(literal					(brown			normal))
		(keyword				(black	 		normal)))
	do: [:nameAndSpecs |
		specs _ nameAndSpecs second.
		SyntaxColorsAndStyles at: nameAndSpecs first put:
			(SyntaxAttribute color: (Color perform: specs first) emphasis: specs last)].
! !

!Preferences class methodsFor: 'pretty-printing' stamp: 'jm 10/16/2002 13:10'!
syntaxAttributesFor: aPartSymbol

	SyntaxColorsAndStyles ifNil: [self initializeSyntaxColorsAndStyles].
	^ (SyntaxColorsAndStyles at: aPartSymbol ifAbsent: [^ #()]) attributeList
! !


!Preferences class methodsFor: 'fonts' stamp: 'jm 6/9/2003 22:11'!
chooseFontWithPrompt: aPrompt andSendTo: aReceiver withSelector: aSelector

	Smalltalk isMorphic
		ifFalse: [self mvcPromptForFont: aPrompt andSendTo: aReceiver withSelector: aSelector]
		ifTrue: [self promptForFont: aPrompt andSendTo: aReceiver withSelector: aSelector].
! !

!Preferences class methodsFor: 'fonts' stamp: 'sw 12/8/1999 17:30'!
chooseListFont
	self chooseFontWithPrompt: 'standard list font' andSendTo: self withSelector: #setListFontTo:! !

!Preferences class methodsFor: 'fonts' stamp: 'sw 12/8/1999 17:30'!
chooseMenuFont
	self chooseFontWithPrompt: 'standard menu font' andSendTo: self withSelector: #setMenuFontTo:! !

!Preferences class methodsFor: 'fonts' stamp: 'sw 12/8/1999 18:39'!
chooseWindowTitleFont
	self chooseFontWithPrompt: 'window title font' andSendTo: self withSelector: #setWindowTitleFontTo:! !

!Preferences class methodsFor: 'fonts' stamp: 'jm 6/2/2008 14:54'!
fontConfigurationMenu

	| aMenu |
	aMenu _ MenuMorph new defaultTarget: Preferences.
	aMenu addTitle: 'Standard System Fonts'.

	aMenu add: 'list font...' action: #chooseListFont.
	aMenu lastItem font: Preferences standardListFont.
	aMenu balloonTextForLastItem: 'Choose the font to be used in list panes'.

	aMenu add: 'menu font...' action: #chooseMenuFont.
	aMenu lastItem font: Preferences standardMenuFont.
	aMenu balloonTextForLastItem: 'Choose the font to be used in menus'.

	aMenu add: 'window-title font...' action: #chooseWindowTitleFont.
	aMenu lastItem font: Preferences windowTitleFont.
	aMenu balloonTextForLastItem: 'Choose the font to be used in window titles.'.

	aMenu add: 'balloon-help font...' target: BalloonMorph action: #chooseBalloonFont.
	aMenu lastItem font: BalloonMorph balloonFont.
	aMenu balloonTextForLastItem: 'choose the font to be used when presenting balloon help.'.

	aMenu addLine.
	aMenu add: 'use large fonts' action: #useLargeFonts.
	aMenu balloonTextForLastItem: 'Use large system fonts'.

	aMenu add: 'restore default font choices' action: #restoreDefaultFonts.
	aMenu balloonTextForLastItem: 'Use the standard system font'.
	^ aMenu
! !

!Preferences class methodsFor: 'fonts' stamp: 'jm 12/15/2005 13:57'!
fontMenuForStyle: familyName target: target selector: selector

 	| menu |
	menu _ MenuMorph entitled: familyName.
 	(StrikeFont sizesForFontName: familyName) do: [:sz |
		menu 
			add: (sz asString, ' Point') 
			target: target 
			selector: selector
			argument: (StrikeFont fontName: familyName size: sz).
		menu lastItem font: (StrikeFont fontName: familyName size: sz)].
	^ menu
! !

!Preferences class methodsFor: 'fonts' stamp: 'jm 12/15/2005 13:45'!
mvcPromptForFont: aPrompt andSendTo: aTarget withSelector: aSelector
	"self mvcPromptForFont: 'Choose system font style' andSendTo: nil withSelector: #setSystemFontTo:"

	| aMenu aChoice aStyle namesAndSizes aFont |
	aMenu _ CustomMenu new.
	(StrikeFont fontNames copyWithout: 'DefaultTextStyle')
		do: [:fName | aMenu add: fName action: fName].
	aChoice _ aMenu startUpWithCaption: aPrompt.
	aChoice ifNil: [^ self].
	aMenu _ CustomMenu new.
	aStyle _ TextStyle named: aChoice.
	(namesAndSizes _ aStyle fontNamesWithHeights) do:
		[:aString | aMenu add: aString action: aString].
	aChoice _ aMenu startUpWithCaption: nil.
	aChoice ifNil: [^ self].
	aFont _ aStyle fontAt: (namesAndSizes indexOf: aChoice).
	aTarget perform: aSelector with: aFont.
! !

!Preferences class methodsFor: 'fonts' stamp: 'jm 12/16/2005 11:51'!
presentMvcFontConfigurationMenu

	| aMenu result |
	aMenu _ CustomMenu new.
	aMenu title: 'Standard System Fonts'.
	aMenu add: 'list font...' action: #chooseListFont.
	aMenu add: 'menu font...' action: #chooseMenuFont.
	aMenu add: 'window-title font...' action: #chooseWindowTitleFont.
	"aMenu add: 'code font...' action: #chooseCodeFont."
	aMenu addLine.
	aMenu add: 'restore default font choices' action: #restoreDefaultFonts.

	(result _ aMenu startUp) ifNotNil:
		[self perform: result]
! !

!Preferences class methodsFor: 'fonts' stamp: 'jm 12/15/2005 13:53'!
promptForFont: aPrompt andSendTo: aTarget withSelector: aSelector
	"NOTE: Morphic ONLY!!!!. Derived from a method written by Robin Gibson"
	"self promptForFont: 'Choose system font:' andSendTo: nil withSelector: #setSystemFontTo:"

	| menu subMenu |
	menu _ MenuMorph entitled: aPrompt.
	StrikeFont fontNames do: [:fn |
		subMenu _ self fontMenuForStyle: fn target: aTarget selector: aSelector.
		menu add: fn subMenu: subMenu.
		menu lastItem font: (StrikeFont fontName: fn size: 18)].

	menu popUpForHand: self currentWorld activeHand.
! !

!Preferences class methodsFor: 'fonts' stamp: 'jm 4/21/2009 20:37'!
restoreDefaultFonts
	"Preferences restoreDefaultFonts"

	#(	(setButtonFontTo:		ComicSans		12)
		(setListFontTo:			NewYork		10)
		(setMenuFontTo:			Verdana		13)
		(setWindowTitleFontTo:	NewYork		12)
	) do: [:triplet |
			self perform: triplet first with: (StrikeFont fontName: triplet second size: triplet third)].

	Smalltalk at: #BalloonMorph ifPresent:
		[:thatClass | thatClass setBalloonFontTo: (StrikeFont fontName: #ComicSans size: 12)].

	"Note:  The standard button font is reset by this code but is not otherwise settable by a public UI (too many things can go afoul) "
! !

!Preferences class methodsFor: 'fonts' stamp: 'jm 4/30/2009 23:11'!
restoreMVCMenuFont
	"Preferences restoreMVCMenuFont"
	"Preferences restoreDefaultFonts"

	self setMenuFontTo: (StrikeFont fontName: #Verdana size: 11).
! !

!Preferences class methodsFor: 'fonts' stamp: 'sw 12/8/1999 22:06'!
setButtonFontTo: aFont
	Parameters at: #standardButtonFont put: aFont! !

!Preferences class methodsFor: 'fonts' stamp: 'jm 10/5/2002 06:58'!
setListFontTo: aFont

	Parameters at: #standardListFont put: aFont.
	ListParagraph initialize.
! !

!Preferences class methodsFor: 'fonts' stamp: 'sw 12/8/1999 18:04'!
setMenuFontTo: aFont

	Parameters at: #standardMenuFont put: aFont.
	PopUpMenu setMenuFontTo: aFont! !

!Preferences class methodsFor: 'fonts' stamp: 'jm 10/5/2002 06:58'!
setWindowTitleFontTo: aFont

	Parameters at: #windowTitleFont put: aFont.
	StandardSystemView setLabelStyle.
! !

!Preferences class methodsFor: 'fonts' stamp: 'jm 12/15/2005 13:53'!
standardButtonFont
	"Answer an attractive font to use for buttons"
	"Answer the font to be used for textual flap tab labels"
	^ Parameters at: #standardButtonFont ifAbsent:
		[Parameters at: #standardButtonFont put: (StrikeFont fontName: #ComicBold size: 16)]! !

!Preferences class methodsFor: 'fonts' stamp: 'sw 12/8/1999 16:09'!
standardListFont
	"Answer the font to be used in lists"

	 ^ Parameters at: #standardListFont ifAbsent:
		[Parameters at: #standardListFont put: TextStyle defaultFont]! !

!Preferences class methodsFor: 'fonts' stamp: 'sw 12/8/1999 16:58'!
standardMenuFont
	"Answer the font to be used in menus"

	 ^ Parameters at: #standardMenuFont ifAbsent:
		[Parameters at: #standardMenuFont put: TextStyle defaultFont]! !

!Preferences class methodsFor: 'fonts' stamp: 'jm 6/13/2007 22:13'!
useLargeFonts
	"Preferences useLargeFonts"

	#(	(setButtonFontTo:		ComicSans		14)
		(setListFontTo:			VerdanaBold		18)
		(setMenuFontTo:			VerdanaBold		18)
		(setWindowTitleFontTo:	VerdanaBold		16)
	) do: [:triplet |
			self perform: triplet first with: (StrikeFont fontName: triplet second size: triplet third)].

	Smalltalk at: #BalloonMorph ifPresent:
		[:thatClass | thatClass setBalloonFontTo: (StrikeFont fontName: #ComicPlain size: 18)].

	"Note:  The standard button font is reset by this code but is not otherwise settable by a public UI (too many things can go afoul) "
! !

!Preferences class methodsFor: 'fonts' stamp: 'jm 12/15/2005 13:53'!
windowTitleFont
	"Answer the standard font to use for window titles"
	^  Parameters at: #windowTitleFont ifAbsent:
		[Parameters at: #windowTitleFont put: (StrikeFont fontName: #NewYork size: 15)]! !


!Preferences class methodsFor: 'halos' stamp: 'jm 6/15/2003 12:13'!
classicHaloSpecs
	"Non-iconic halos with traditional placements"
	"Preferences resetHaloSpecifications"  "  <-  will result in the standard default halos being reinstalled"
	"NB: listed below in clockwise order"

		^ #(
	"  	selector				horiz		vert			color info						icon key
		---------				------		-----------		-------------------------------		---------------"
	(addMenuHandle:		left			top				(red)							none)
	(addDismissHandle:		leftCenter	top				(red		muchLighter)			'Halo-Dismiss')
	(addGrabHandle:			center		top				(black)							none)
	(addDragHandle:			rightCenter	top				(brown)							none)
	(addDupHandle:			right		top				(green)							none)	
	(addDebugHandle:		right		topCenter		(blue	veryMuchLighter)		none)
	(addRepaintHandle:		right		center			(lightGray)						none)
	(addGrowHandle:		right		bottom			(yellow)						none)
	(addFontEmphHandle:	rightCenter	bottom			(lightBrown darker)				none)
	(addFontStyleHandle:		center		bottom			(lightRed)						none)
	(addFontSizeHandle:		leftCenter	bottom			(lightGreen)						none)
	(addRotateHandle:		left			bottom			(blue)							none))
! !

!Preferences class methodsFor: 'halos' stamp: 'jm 6/15/2003 12:13'!
customHaloSpecs
	"Intended for you to modify to suit your personal preference. What is implemented in the default here is just a skeleton; in comment at the bottom of this method are some useful lines you may wish to paste in to the main body here, possibly modifying positions, colors, etc..
	Note that in this example, we include:
			Dismiss handle, at top-left
			Menu handle, at top-right
			Resize handle, at bottom-right
			Rotate handle, at bottom-left
			Drag handle, at top-center
			Recolor handle, at left-center. (this one is NOT part of the standard formulary --
											it is included here to illustrate how to
 											add non-standard halos)
			Note that the optional handles for specialized morphs, such as Sketch, Text, PasteUp, are also included"

	^ #(
	(addDismissHandle:		left			top				(red		muchLighter)			'Halo-Dismiss')
	(addMenuHandle:		right		top				(red)							'Halo-Menu')
	(addDragHandle:			center		top				(brown)							'Halo-Drag')
	(addGrowHandle:		right		bottom			(yellow)						'Halo-Scale')
	(addRecolorHandle:		left			center			(green muchLighter lighter)		'Halo-Recolor')
	(addRepaintHandle:		right		center			(lightGray)						'Halo-Paint')
	(addFontSizeHandle:		leftCenter	bottom			(lightGreen)						'Halo-FontSize')
	(addFontStyleHandle:		center		bottom			(lightRed)						'Halo-FontStyle')
	(addFontEmphHandle:	rightCenter	bottom			(lightBrown darker)				'Halo-FontEmph')
	(addRotateHandle:		left			bottom			(blue)							'Halo-Rot')
	(addDebugHandle:		right		topCenter		(blue	veryMuchLighter)		'Halo-Debug')
	).

	"  Other useful handles...
  		selector				horiz		vert			color info						icon key
		---------				------		-----------		-------------------------------		---------------
	(addGrabHandle:			center		top				(black)							'Halo-Grab')
	(addDragHandle:			rightCenter	top				(brown)							'Halo-Drag')
	(addDupHandle:			right		top				(green)							'Halo-Dup')	
	(addHelpHandle:			center		bottom			(lightBlue)						'Halo-Help')
	(addRepaintHandle:		right		center			(lightGray)						'Halo-Paint')
	"
! !

!Preferences class methodsFor: 'halos' stamp: 'jm 6/5/2003 21:31'!
customHalosInForce

	^ (self parameterAt: #HaloTheme) == #customHaloSpecs
! !

!Preferences class methodsFor: 'halos' stamp: 'jm 6/15/2003 12:19'!
haloSpecifications
	"Answer a list of HaloSpecs that describe which halos are to be used, what they should look like, and where they should be situated"

	^ Parameters at: #HaloSpecs ifAbsent:
			[self installHaloTheme: #iconicHaloSpecifications]
! !

!Preferences class methodsFor: 'halos' stamp: 'jm 6/15/2003 11:52'!
haloThemeRadioButtons

	| buttonColumn aRow aRadioButton aStringMorph |
	buttonColumn _ AlignmentMorph newColumn color: Color transparent.
	#((iconicHaloSpecifications		iconic	iconicHalosInForce	'circular halos with icons inside')
	  (customHaloSpecs				custom	customHalosInForce	'customizable halos')
	) do: [:quad |
		aRow _ AlignmentMorph newRow color: Color transparent.
		aRow vResizing: #shrinkWrap.
		aRow addMorph: (aRadioButton _ ThreePhaseButtonMorph radioButton).
		aRadioButton target: Preferences.
		aRadioButton setBalloonText: quad fourth.
		aRadioButton actionSelector: #installHaloTheme:.
		aRadioButton getSelector: quad third.
		aRadioButton arguments: (Array with: quad first).
		aRow addTransparentSpacerOfSize: (4 @ 0).
		aRow addMorphBack: (aStringMorph _ StringMorph contents: quad second asString).
		aStringMorph setBalloonText: quad fourth.
		buttonColumn addMorphBack: aRow].
	^ buttonColumn

	"self currentHand attachMorph: Preferences haloThemeRadioButtons"
! !

!Preferences class methodsFor: 'halos' stamp: 'jm 6/15/2003 12:20'!
iconicHaloSpecifications

	^ #(
	"  	selector				horiz		vert			color info						icon key
		---------				------		-----------		-------------------------------		---------------"
	(addCollapseHandle:		left			topCenter		(tan)							'Halo-Collapse')
	(addDebugHandle:		right		topCenter		(blue	veryMuchLighter)		'Halo-Debug')
	(addDismissHandle:		left			top				(red		muchLighter)			'Halo-Dismiss')
	(addRotateHandle:		left			bottom			(blue)							'Halo-Rot')
	(addMenuHandle:		leftCenter	top				(red)							'Halo-Menu')
	(addGrabHandle:			center		top				(black)							'Halo-Grab')
	(addDragHandle:			rightCenter	top				(brown)							'Halo-Drag')
	(addDupHandle:			right		top				(green)							'Halo-Dup')	
	(addHelpHandle:			center		bottom			(lightBlue)						'Halo-Help')
	(addGrowHandle:		right		bottom			(yellow)						'Halo-Scale')
	(addRepaintHandle:		right		center			(lightGray)						'Halo-Paint')
	(addFontSizeHandle:		leftCenter	bottom			(lightGreen)						'Halo-FontSize')
	(addFontStyleHandle:		center		bottom			(lightRed)						'Halo-FontStyle')
	(addFontEmphHandle:	rightCenter	bottom			(lightBrown darker)				'Halo-FontEmph')
	)
! !

!Preferences class methodsFor: 'halos' stamp: 'sw 1/27/2000 23:25'!
iconicHalosInForce
	^ (self parameterAt: #HaloTheme) == #iconicHaloSpecifications! !

!Preferences class methodsFor: 'halos' stamp: 'sw 1/28/2000 10:36'!
installCustomHaloSpecs
	"Install an alternative set of halos, as customized by the user"
	"Preferences installCustomHaloSpecs"
	self installHaloTheme: #customHaloSpecs! !

!Preferences class methodsFor: 'halos' stamp: 'sw 1/27/2000 16:45'!
installHaloSpecsFromArray: anArray

	| aColor |
	^ Parameters at: #HaloSpecs put: 
		(anArray collect:
			[:quin |
				aColor _ Color.
				quin fourth do: [:sel | aColor _ aColor perform: sel].
				HaloSpec new 
					horizontalPlacement: quin second
					verticalPlacement: quin third 
					color: aColor
					iconSymbol: quin fifth
					addHandleSelector: quin first])! !

!Preferences class methodsFor: 'halos' stamp: 'sw 1/27/2000 23:15'!
installHaloTheme: themeSymbol
	self installHaloSpecsFromArray: (self perform: themeSymbol).
	self setParameter: #HaloTheme to: themeSymbol
	! !

!Preferences class methodsFor: 'halos' stamp: 'sw 1/28/2000 10:36'!
installIconicHaloSpecs
	"Install an alternative set of halos,  rather more based on the old placements, and without icons, , and lacking the scripting-relating handles.."
	"Preferences installIconicHaloSpecs"
	self installHaloTheme: #iconicHaloSpecifications! !


Preferences initialize!
