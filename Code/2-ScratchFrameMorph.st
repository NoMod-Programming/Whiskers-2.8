Morph subclass: #ScratchFrameMorph
	instanceVariableNames: 'topPane viewerPane scriptsPane stageFrame workPane titlePane libraryPane menuPanel stageButtonsPanel readoutPane logoMorph projectTitleMorph flagButton fillScreenFlag paintingInProgress projectDirectory projectName projectInfo author loginName loginPassword watcherPositions shuffledCostumeNames justSaved viewModeButtons viewMode lastViewMode viewModeButtonsPanel toolbarPanel lastWeDoPoll tabPaneMorph currentCategory showingCatSelector showHideButton tabHolderMorph smallerStageFrame tipsPane stopButton backpackPane '
	classVariableNames: 'AllowSharing BlockSize Clipboard DefaultNotes DefaultSprite Fonts FontsXO HelpSkin IsXO ScratchServers ScratchSettings ScratchSkin ScratchSkinXO ShareServer ShareServerPath SupportServer SupportServerPath TakeOverScreen UseErrorCatcher Version VersionDate VisibleDrives WorkpaneExtent '
	poolDictionaries: ''
	category: 'Scratch-UI-Panes'!
!ScratchFrameMorph commentStamp: '<historical>' prior: 0!
I am the top level user interface for Scratch. I tile the screen with a toolbar, a work pane (for content), a viewer pane, and a script editor pane. I can resize myself to fill the entire Squeak window.

I keep a list of Scratch processes (threads) and have the stage run each one to the its next stopping point when I am stepped each screen update cycle.
!


!ScratchFrameMorph methodsFor: 'intialization' stamp: 'EMP 3/22/2016 11:15'!
addShortcutButtonsTo: rowMorph

	| buttonSpecs b |
	buttonSpecs _ #(
		"name		tool tip				selector"
		(language	'Set language'		languageMenu:)
	).

	buttonSpecs do: [:spec |
		b _ ToggleButton
			onForm: (ScratchFrameMorph skinAt: (spec at: 1), 'ButtonOver')
			offForm: (ScratchFrameMorph skinAt: (spec at: 1), 'Button')
			overForm: (ScratchFrameMorph skinAt: (spec at: 1), 'ButtonOver').
		b
			target: self;
			actionSelector: (spec at: 3);
			setBalloonText: (spec at: 2) localized;
			actWhen: #buttonUp;
			isMomentary: true.
		
		('language' = (spec at: 1)) ifTrue: [  "language special case"
			b arguments: (Array with: b)].

		('save' = (spec at: 1)) ifTrue: [  "spacer"
			rowMorph addMorphBack: (Morph new extent: (10@5); color: Color transparent)].

		rowMorph addMorphBack: b].

	rowMorph addMorphBack: (Morph new extent: (12@5); color: Color transparent).
! !

!ScratchFrameMorph methodsFor: 'intialization' stamp: 'EMP 12/15/2015 12:17'!
createBasicPanes
	"Create and add my palette (viewer), script editor, stage, and library panes."

	topPane _ Morph new color: (Color r: 158/255 g: 158/255 b: 158/255).
	viewerPane _ ScratchViewerMorph new rebuildCategorySelectors.	
	scriptsPane _ ScratchScriptEditorMorph new.
	stageFrame _ Morph new color: (Color white).
	smallerStageFrame _ Morph new color: (Color gray: 0.8).
	tabHolderMorph _ Morph new color: Color white.
	titlePane _ ImageFrameMorph new initFromForm: "(ScratchFrameMorph skinAt: 'titlePane')"(ScratchFrameMorph skinAt: #libraryTop).
	workPane _ ScratchStageMorph new extent: WorkpaneExtent.
	libraryPane _ ScratchLibraryMorph new.
	tipsPane _ ScratchTipsSidebarMorph new frame: self; mode: #hidden.

	"make panes sticky so clicking on them doesn't pick up entire frame"
	self
		addMorph: (topPane isSticky: true);
		addMorph: (viewerPane isSticky: true);
		addMorph: (scriptsPane isSticky: true);
		addMorph: (stageFrame isSticky: true);
		addMorph: (smallerStageFrame isSticky: true);
		addMorph: (workPane isSticky: true);
		addMorph: (titlePane isSticky: true);
		addMorph: (tabHolderMorph isSticky: true);
		addMorph: (libraryPane isSticky: true);
		addMorph: (tipsPane isSticky: true).

	self createReadoutPane.
	workPane comeToFront.
! !

!ScratchFrameMorph methodsFor: 'intialization' stamp: 'EMP 11/8/2015 15:20'!
createLogo
	"Create and the Scratch logo."

	logoMorph _ ((SketchMorph withForm: (ScratchFrameMorph skinAt: #scratchLogo)) extent: (87@27)).
	logoMorph position: topPane position + (12@5).
	topPane addMorph: logoMorph.
! !

!ScratchFrameMorph methodsFor: 'intialization' stamp: 'EMP 11/6/2015 14:20'!
createMenuPanel
	"Create and add a panel containing the menus and close button."

	| menuSpecs m arrow |
	"create panel"
	menuPanel _ AlignmentMorph new
		color: Color transparent;
		centering: #center;
		inset: 0;
		height: 0.	"will grow as needed"

	self addShortcutButtonsTo: menuPanel.

	"menuSpecs defines the menus"
	menuSpecs _ #(
		"name			selector"
		('File'		fileMenu:)
		('Edit'			editMenu:)
		('Tips'			tipsScreens:)
		('About'			aboutScratch:)
	).
	"arrow _ UTF8 withAll: '▼"
	Smalltalk isUnix ifTrue: [arrow _ '' asUTF8] ifFalse: [arrow _ UTF8 withAll: '▼'].
	menuSpecs do: [:spec |
		m _ ScratchMenuTitleMorph new
			contents: ((spec at: 1) = 'File' ifTrue: [('File' localized) asUTF8, arrow] ifFalse: [(spec at: 1) = 'Edit' ifTrue: [('Edit ' localized) asUTF8, arrow] ifFalse: [(spec at: 1) localized]]);
			target: self selector: (spec at: 2).
		menuPanel addMorphBack: m.
			menuPanel addMorphBack: (Morph new color: Color transparent; extent: 12@5)].

	topPane addMorph: menuPanel.
! !

!ScratchFrameMorph methodsFor: 'intialization'!
createReadoutPane
	"Create and add my mouse readout pane."

	| xyReadout |

	readoutPane _ Morph new color: (Color white)"ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #mouseReadoutPane)".
	xyReadout _ self makeXYReadout.
	readoutPane	 addMorph: xyReadout.

	"make pane sticky so clicking on it doesn't pick up entire frame"
	self addMorph: (readoutPane isSticky: true).
! !

!ScratchFrameMorph methodsFor: 'intialization' stamp: 'EMP 2/25/2016 16:30'!
createStageButtonsPanel
	"Create and add a panel containing the project title, green flag, and stop buttons."

	| buttonSpecs bName button |
	"create panel"
	stageButtonsPanel _ AlignmentMorph new
		color: Color transparent;
		centering: #center;
		height: 20.

	projectTitleMorph _ StringMorph new
		forceUnicodeRendering: true;
		contents: '';
		font: (ScratchFrameMorph getFont: #FrameMorphProjectTitle).
	stageButtonsPanel
		addMorphBack: projectTitleMorph;
		addMorphBack: (AlignmentMorph newSpacer: Color transparent).

	"buttonSpecs defines the toolbar buttons; first is icon name, second is selector"
	buttonSpecs _ #(
		"name	selector		tool tip"
		(go		shoutGo		'Start green flag scripts')
		(stop	stopAll		'Stop everything')).

	buttonSpecs do: [:spec |
		bName _ spec first.
		button _ ToggleButton
			onForm: ((ScratchFrameMorph skinAt: (bName, 'ButtonPressed') asSymbol))
			offForm: ((ScratchFrameMorph skinAt: (bName, 'Button') asSymbol))
			overForm: ((spec first = #stop) ifTrue: [((ScratchFrameMorph skinAt: (bName, 'Button') asSymbol))] ifFalse: [((ScratchFrameMorph skinAt: (bName, 'ButtonPressed') asSymbol))]).
		button
			target: self;
			actionSelector: (spec at: 2);
			isMomentary: true;
			setProperty: #balloonText toValue: (spec at: 3) localized.

		stageButtonsPanel addMorphBack: button.
		bName = #go ifTrue: [
			flagButton _ button.
			stageButtonsPanel addMorphBack: (Morph new color: Color transparent; extent: 10@5)].
		bName = #stop ifTrue: [stopButton _ button]].

	titlePane addMorph: stageButtonsPanel.
! !

!ScratchFrameMorph methodsFor: 'intialization' stamp: 'EMP 9/30/2015 16:41'!
createTabPane

	| tabOnForm tabOffForm tabID tabLabel |

	"create tab pane"
	tabPaneMorph _ ScratchTabPaneMorph new extent: 20@30.
	tabPaneMorph
		borderWidth: 0;
		color: Color transparent;
		targetPane: self.

	tabOnForm _ (ScratchFrameMorph skinAt: #tabOn).
	tabOffForm _ (ScratchFrameMorph skinAt: #tabOff).

	"add the tabs"
	#(Scripts Costumes Sounds) do: [:spec |
		tabID _ spec asString.
		tabLabel _ tabID localized.
		tabPaneMorph
			createTab: tabID
			withLabel: tabLabel
			onForm: tabOnForm
			offForm: tabOffForm].

	"set current tab and add to frame"
	tabPaneMorph currentTab: 'Scripts'.
	self addMorph: tabPaneMorph.
! !

!ScratchFrameMorph methodsFor: 'intialization' stamp: 'EMP 2/7/2016 11:12'!
createToolbar
	"Create and add the toolbar."

	| buttonSpecs bName button |
	toolbarPanel _ AlignmentMorph new
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		color: Color transparent.
		
	buttonSpecs _ #(
		"name			selector"			"tooltip"
		(copy			copyTool		'Duplicate')
		(delete			cutTool			'Delete')
		(zoomIn 		zoomInTool		'Grow sprite')
		(zoomOut 		zoomOutTool		'Shrink sprite')
		(help			helpTool			'Block help')
	).

	buttonSpecs do: [:spec |
		bName _ spec at: 1.
		button _ ToggleButton
			onForm: (ScratchFrameMorph skinAt: (bName, 'ButtonPressed') asSymbol)
			offForm: (ScratchFrameMorph skinAt: (bName, 'Button') asSymbol)
			overForm: (ScratchFrameMorph skinAt: (bName, 'ButtonOver') asSymbol).
		button
			target: self;
			actionSelector: (spec at: 2);
			isMomentary: true;
			setProperty: #balloonText toValue: (spec at: 3) localized.
		toolbarPanel addMorphBack: button.
		toolbarPanel addMorphBack: (Morph new color: Color transparent;
					 extent: 3 @ 2)].

	self addMorph: toolbarPanel.
! !

!ScratchFrameMorph methodsFor: 'intialization' stamp: 'EMP 2/11/2016 14:21'!
createViewModeButtonsPanel

	| specs bName button |
	viewModeButtonsPanel _ AlignmentMorph newColumn
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		color: Color transparent.
	viewModeButtons _ OrderedCollection new.
	specs _ OrderedCollection new.
	"
	used before 2.0SqueakVersion
	specs add: #(quarter			enterQuarterMode		'Switch to small stage').
	specs add: #(normal			enterNormalMode		'Switch to full stage')."
	specs add: #(presentation	enterPresentationMode	'Switch to presentation mode').

	specs do: [:spec |
		bName _ spec first.
		button _ ToggleButton new
			onForm: (ScratchFrameMorph skinAt: bName, 'ViewModeOn')
			offForm: (ScratchFrameMorph skinAt: bName, 'ViewMode')
			overForm: (ScratchFrameMorph skinAt: bName, 'ViewModeOver').
		button
			target: self;
			actionSelector: (spec at: 2);
			alphaOn: true;
			setProperty: #balloonText toValue: (spec at: 3) localized.
		viewModeButtonsPanel
			addMorphBack: button.
		viewModeButtons add: button].
	viewModeButtonsPanel addMorphBack: (StringMorph new contents: (Version)).
	self addMorph: viewModeButtonsPanel.
! !

!ScratchFrameMorph methodsFor: 'intialization' stamp: 'EMP 11/5/2015 14:42'!
initialize

	super initialize.
	fillScreenFlag _ false.
	paintingInProgress _ false.
	color _ Color white.
	projectInfo _ Dictionary new.
	watcherPositions _ Dictionary new.
	justSaved _ false.
	author _ ''.
	loginName _ ''.
	loginPassword _ ''.
	viewMode _ #normal.
	showingCatSelector _ true.

	self createBasicPanes.
	self createLogo.
	self createMenuPanel.
	self createViewModeButtonsPanel.
	self createStageButtonsPanel.
	self createToolbar.
	self createTabPane.

	self extent: 500@500.
! !

!ScratchFrameMorph methodsFor: 'intialization'!
makeXYReadout
	"Make and answer an x-y readout."

	| normalFont boldFont panel spaceWidth labelX readoutX labelY readoutY |
	normalFont _ (ScratchFrameMorph getFont: #XYReadout).
	boldFont _ (ScratchFrameMorph getFont: #XYReadoutBold).

	(ScratchTranslator renderScale ~= 1) ifTrue: [
		"force fonts to be fixed size:"
		normalFont _ StrikeFont
			osFontName: normalFont name
			size: normalFont pointSize / ScratchTranslator renderScale asFloat.
		boldFont _ StrikeFont
			osFontName: boldFont name
			size: boldFont pointSize / ScratchTranslator renderScale asFloat].

	panel _ Morph new color: (Color white).

	ScratchTranslator isRTL
		ifTrue: [labelX _ StringMorph new font: normalFont; contents: ':x' asUTF8]
		ifFalse: [labelX _ StringMorph new font: normalFont; contents: 'x:' asUTF8].
	readoutX _ UpdatingStringMorph new
		target: self; getSelector: #mouseX;
		forceUnicodeRendering: true;
		font: boldFont;
		stepTime: 0;
		growable: false.
	readoutX width: (readoutX stringWidth: '-1000').
	ScratchTranslator isRTL
		ifTrue: [labelY _ labelX fullCopy contents: ':y' asUTF8]
		ifFalse: [labelY _ labelX fullCopy contents: 'y:' asUTF8].
	readoutY _ readoutX fullCopy getSelector: #mouseY.

	spaceWidth _ ((readoutX stringWidth: ' ') * 0.8) asInteger.

	ScratchTranslator isRTL
		ifTrue: [readoutY rightJustify: true.
			panel addMorph: (readoutY position: 0@0).
			panel addMorph: (labelY position: ((readoutY topRight) + (spaceWidth@0))).]
		ifFalse: [panel addMorph: (labelX position: 0@0).
			panel addMorph: (readoutX position: ((labelX topRight) + (spaceWidth@0)))].

	ScratchTranslator isRTL
		ifTrue: [readoutX rightJustify: true.
			panel addMorph: (readoutX position: (labelY right@labelY top) + (spaceWidth@0)).
			panel addMorph: (labelX position: ((readoutX topRight) + (spaceWidth@0)))]
		ifFalse: [panel addMorph: (labelY position: (labelX right + readoutX width + 8)@(labelX top)).
			panel addMorph: (readoutY position: ((labelY topRight) + (spaceWidth@0)))].
	
	ScratchTranslator isRTL
		ifTrue: [panel extent: ((labelX right) max: (labelY right))@(labelY bottom)]
		ifFalse: [panel extent: ((readoutX right) max: (readoutY right))@(labelY bottom)].

	^ panel
! !


!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 3/24/2007 09:34'!
author

	^ author
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 3/24/2007 09:35'!
author: aString
	"This is the author used in notes and save as, which is different from the user name used when uploading to the website."

	author _ aString.

! !

!ScratchFrameMorph methodsFor: 'accessing'!
currentCategory
	^ scriptsPane currentCategory! !

!ScratchFrameMorph methodsFor: 'accessing'!
currentCategory: cat
	^ scriptsPane currentCategory: cat! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'EMP 2/25/2016 16:29'!
flagButton
	^ flagButton! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 6/3/2009 16:44'!
importSpriteOrProject: fileNameOrData
	"Read the sprite or project file and merge into the current project."

	| data f importedStage defaultForm defaultSound oldName oldPosition |
	data _ fileNameOrData.
	(data isKindOf: String) ifTrue: [  "read the contents of a local file"
		(FileDirectory default fileExists: fileNameOrData) ifFalse: [^ self].
		f _ (FileStream readOnlyFileNamed: fileNameOrData) binary.
		f ifNil: [^ self].
		data _ f contentsOfEntireFile].

	[importedStage _ self extractProjectFrom: data] ifError: [^ self].

	"fix references to old stage"
	importedStage allMorphsDo: [:m |
		(m isKindOf: WatcherMorph) ifTrue: [m mapReceiver: importedStage to: workPane].
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m blocksBin submorphs do: [:stack |
				(stack isKindOf: BlockMorph) ifTrue: [
					stack blockSequence do: [:b | b mapReceiver: importedStage to: workPane]]]]].

	"add global variables from importated stage to my stage"
	importedStage varNames do: [:v |
		workPane addVariable: v value: (importedStage getVar: v)].

	"add imported stage scripts"
	importedStage blocksBin submorphs do: [:stack |
		(stack isKindOf: BlockMorph) ifTrue: [workPane addStack: stack fullCopy]].

	"add imported background costumes and scripts to my stage, filtering out default items"
	defaultForm _ workPane defaultImageMedia form hibernate.
	defaultSound _ SoundMedia new sound.
	importedStage media do: [:media |
		(media isImage and: [media form hibernate bits ~= defaultForm bits])
			ifTrue: [workPane addMediaItem: media].
		(media isSound and: [media sound samples ~= defaultSound samples])
			ifTrue: [workPane addMediaItem: media]].

	importedStage submorphs do: [:m |
		(m isKindOf: ScratchSpriteMorph) ifTrue: [
			oldName _ m objName.
			oldPosition _ m position - m owner position + (47@55).  "jm: I am not sure why this offset is needed. It's the rotation center of the default costume..."
			self addAndView: m.  "assigns a new name"
			m objName: oldName.
			m position: workPane topLeft + oldPosition]].

	workPane layoutChanged.
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'tis 11/8/2006 13:34'!
libraryPane

	^ libraryPane
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 3/24/2007 09:27'!
loginName

	^ loginName
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 3/24/2007 09:30'!
loginName: aString

	loginName _ aString.
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 3/24/2007 09:27'!
loginPassword

	^ loginPassword
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 3/24/2007 09:30'!
loginPassword: aString

	loginPassword _ aString.
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'EMP 11/23/2015 19:18'!
openScratchProjectNamed: fName
	"Open a Scratch project with the given name."

	| f projData newProj dir fn|
	self closeMediaEditorsAndDialogs ifFalse: [^ self].

	fn _ fName.
	f _ FileStream readOnlyFileNamedOrNil: fn.
 	f ifNil: ["try a different encoding, fixes a Firefox bug, -Jens"
		fn _ fName isoLatinToMac asUTF8.
		f _ FileStream readOnlyFileNamedOrNil: fn.
		f ifNil: [^ self inform: 'Could not read' withDetails: fName]].

	(ZipArchive isZipArchive: f) ifTrue: [^ self openScratchTwoProjectNamed: fName].

	[	projData _ f binary contentsOfEntireFile.
		newProj _ self extractProjectFrom: projData.
		projectInfo _ self extractInfoFrom: projData.
	] ifError: [:err :rcvr | ^ self inform: 'Could not read project; file may be damaged' withDetails: '(', err, ')'].

	dir _ FileDirectory dirPathFor: fn.
	projectDirectory _ FileDirectory on: dir.
	ScratchFileChooserDialog setLastFolderTo: projectDirectory forType: #project.
	projectName _ FileDirectory localNameFor: fn.

	self installNewProject: newProj.
	self initializeWatcherPositions.
	viewerPane updateContents.
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 5/2/2005 17:22'!
paintingInProgress
	"Answer true if the paint editor is in use."

	^ paintingInProgress
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 5/2/2005 17:06'!
paintingInProgress: aBoolean

	paintingInProgress _ aBoolean.
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 2/28/2009 14:29'!
projectComment

	^ projectInfo at: 'comment' ifAbsent: ['']
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 3/2/2009 12:56'!
projectCommentOrTemplate

	| s |
	s _ projectInfo at: 'comment' ifAbsent: [''].
	s size = 0 ifTrue: [s _ DefaultNotes].
	^ s
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 10/29/2005 10:26'!
projectInfo
	"Answer the project info dictionary."

	^ projectInfo
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'ee 6/2/2009 18:55'!
projectName

	^ self nameFromFileName: projectName
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 10/26/2008 17:44'!
projectName: aString

	projectName _ aString.
	projectTitleMorph contents: aString.
	self fixLayout.
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 6/23/2004 09:54'!
scratchObjects
	"Answer a collection of all the scratch objects in the work pane."

	^ self workPane submorphs select: [:m | m isKindOf: ScriptableScratchMorph]
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 7/20/2003 12:13'!
scriptsPane

	^ scriptsPane
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'EMP 10/3/2015 22:16'!
showHideButton
	^ showHideButton! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'EMP 2/25/2016 16:30'!
stopButton
	^ stopButton! !

!ScratchFrameMorph methodsFor: 'accessing'!
tabPaneMorph
	^ tabPaneMorph! !

!ScratchFrameMorph methodsFor: 'accessing'!
target
	^ scriptsPane target! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'EMP 12/15/2015 12:13'!
toggleShowing
	showingCatSelector _ (showingCatSelector = false).
	self hidePalette: (showingCatSelector not).! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'EMP 12/15/2015 12:16'!
toggleShowingtwo
	showingCatSelector _ (showingCatSelector = false).
	self hidePalette: showingCatSelector not.
	self fixLayout.! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'ee 12/30/2008 13:47'!
viewMode

	^ viewMode
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 7/20/2003 12:08'!
viewerPane

	^ viewerPane
! !

!ScratchFrameMorph methodsFor: 'accessing' stamp: 'jm 7/20/2003 12:08'!
workPane

	^ workPane
! !


!ScratchFrameMorph methodsFor: 'menu/button actions'!
aboutScratch

	| dialogBox |
	dialogBox _ DialogBoxMorph new
		title: 'About Scratch';
		withButtonsForYes: false no: false okay: true cancel: false.
	dialogBox
		message: '
Based on Scratch 1.4 by the MIT media lab

This version of Scratch is specially designed to help ease
the bridge between Scratch 1.4 and 2.0. It can also be used
for advanced programmers looking to modify a Squeak
Version of 2.0

NOTE: this is an unofficial modification of Scratch 1.4.
'
		font: (ScratchFrameMorph getFont: #AboutScratch).

	dialogBox getUserResponse.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 9/29/2015 15:36'!
aboutScratch: blank

	| dialogBox |
	dialogBox _ DialogBoxMorph new
		title: 'About Scratch';
		withButtonsForYes: false no: false okay: true cancel: false.
	dialogBox
		message: '
Based on Scratch 1.4 by the MIT media lab

This version of Scratch is specially designed to help ease
the bridge between Scratch 1.4 and 2.0. It can also be used
for advanced programmers looking to modify a Squeak
Version of 2.0

NOTE: this is an unofficial modification of Scratch 1.4.
'
		font: (ScratchFrameMorph getFont: #AboutScratch).

	dialogBox getUserResponse.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 12/3/2015 15:29'!
addServerCommandsIconizedTo: menu
	"Add Scratch server commands to the given menu."

	| disable endCmd |
	disable _ false.  "make this true to disable this feature"
	disable ifTrue: [^ self].

	menu addLine.
	(workPane scratchServer notNil and:
	 [workPane scratchServer sessionInProgress])
		ifTrue: [
			menu add: 'Show IP Address' action: #showNetworkAddress.
			endCmd _ workPane scratchServer isHosting
				ifTrue: ['Stop Hosting Mesh']
				ifFalse: ['Leave Mesh'].
			menu add: endCmd action: #exitScratchSession]
		ifFalse: [
			menu add: 'Host Mesh' action: #startHostingScratchSession.
			menu add: 'Join Mesh' action: #joinScratchSession].

! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 12/3/2015 15:31'!
addServerCommandsIconizedTo: menu width: maxWidth
	"Add Scratch server commands to the given menu."

	| disable endCmd |
	disable _ false.  "make this true to disable this feature"
	disable ifTrue: [^ self].

	menu addLine.
	(workPane scratchServer notNil and:
	 [workPane scratchServer sessionInProgress])
		ifTrue: [
			menu addIcon: (self checkBoxLabelled: 'Show IP Address' marked: false width: maxWidth) action: #showNetworkAddress.
			endCmd _ workPane scratchServer isHosting
				ifTrue: ['Stop Hosting Mesh']
				ifFalse: ['Leave Mesh'].
			menu addIcon: (self checkBoxLabelled: endCmd marked: false width: maxWidth) action: #exitScratchSession]
		ifFalse: [
			menu addIcon: (self checkBoxLabelled: 'Host Mesh' marked: false width: maxWidth) action: #startHostingScratchSession.
			menu addIcon: (self checkBoxLabelled: 'Join Mesh' marked: false width: maxWidth) action: #joinScratchSession].

! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 9/29/2015 14:24'!
addServerCommandsTo: menu
	"Add Scratch server commands to the given menu."

	| disable endCmd |
	disable _ false.  "make this true to disable this feature"
	disable ifTrue: [^ self].

	menu addLine.
	(workPane scratchServer notNil and:
	 [workPane scratchServer sessionInProgress])
		ifTrue: [
			menu add: 'Show IP Address' action: #showNetworkAddress.
			endCmd _ workPane scratchServer isHosting
				ifTrue: ['Stop Hosting Mesh']
				ifFalse: ['Leave Mesh'].
			menu add: endCmd action: #exitScratchSession]
		ifFalse: [
			menu add: 'Host Mesh' action: #startHostingScratchSession.
			menu add: 'Join Mesh' action: #joinScratchSession].

! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 12/8/2008 12:03'!
addSpriteMorph

	| result f m el |
	self world activeHand toolType: nil.
	self paintingInProgress ifTrue: [^ self beep].

	result _ ScratchFileChooserDialog chooseSpriteCostumeFor: self.
	result = #cancelled ifTrue: [^ self].
	(result asLowercase endsWith: '.sprite')
		ifTrue: [^ self importSpriteOrProject: result].

	[f _ Form fromFileNamed: result] ifError: [^ self].
	el _ ImageMedia new form: (ScratchFrameMorph scaledFormForPaintEditor: f).
	m _ ScratchSpriteMorph new soleCostume: el.
	el mediaName: (m unusedMediaNameFromBaseName: (FileDirectory localNameFor: result)).
	self addAndView: m.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 3/16/2007 19:12'!
allProjectMedia
	"Answer a collection of all media items in the current project."

	| result |
	result _ OrderedCollection new.
	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			result addAll: m media]].
	^ result
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 3/22/2016 10:34'!
askUpdates
	| latestVersion convertedVersion convertedLatestVersion updateDict imgName oldFName newFName ct |
	"ALMOST DONE!!!!!! ONE MORE UPDATE!!!!!!"
	true ifTrue: [^ #cancelled].
	latestVersion _ (HTTPSocket httpGetNoError: 'http://whiskers.gwiddle.co.uk/api/latestupdate/g1') contents.
	convertedVersion := Version asString findVersionNumber.
	convertedVersion last isDigit
		ifTrue: [convertedVersion := (convertedVersion asNumberNoError * 10000)]
		ifFalse: [convertedVersion := ((convertedVersion leadingDigits asNumberNoError * 10000) +  (Utilities lettersToNumbers: convertedVersion charsAfterLastDigits))].
	convertedLatestVersion _ latestVersion asString findVersionNumber.
	convertedLatestVersion last isDigit
		ifTrue: [convertedLatestVersion := (convertedLatestVersion asNumberNoError * 10000)]
		ifFalse: [convertedLatestVersion := ((convertedLatestVersion leadingDigits asNumberNoError * 10000) +  (Utilities lettersToNumbers: convertedLatestVersion charsAfterLastDigits))].
	(convertedLatestVersion > convertedVersion) ifFalse: [^ 'No update available'].
	(DialogBoxMorph ask: ('A newer version of Whiskers is available: 
', (Version), '
update?') title: 'A newer version of Whiskers is available') ifFalse: [^ #cancelled].
	self newScratchProject.
	[updateDict _ (Json readFrom: (HTTPSocket httpGetNoError: 'http://whiskers.gwiddle.co.uk/api/updateinfo/g1/help'))] ifError: [^ 'There was an error checking for updates'].
	updateDict at: 'DotImageDownload' ifPresent: [:imageDownload | 
	imgName _ Smalltalk imageName.
	oldFName _ FileDirectory forFileName: imgName.
	oldFName deleteFileNamed: imgName.
	newFName _ FileStream newFileNamed: imgName.
	ct _ ((HTTPSocket httpGetNoError: 'http://whiskers.gwiddle.co.uk/Whiskers.image') contents).
	(ct beginsWith: '<html') ifTrue: [^ 'There was an error checking for updates'].
	newFName nextPutAll: ct.
	Smalltalk quitPrimitive "Make sure the changes are saved."].! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 10/17/2007 12:29'!
canonicalizeImagesQuality: qualityOrNil saveOriginal: saveFlag

	| count unique match |
	count _ 0.
	unique _ OrderedCollection new: 1000.
	self allProjectMedia do: [:m |
		m isImage ifTrue: [
			match _ unique detect: [:u | u form equals: m form] ifNone: [nil].
			match
				ifNil: [
					qualityOrNil ifNotNil: [
						(m jpegCompressIfPossibleQuality: qualityOrNil saveOriginal: saveFlag)
							ifTrue: [count _ count + 1]].
					unique add: m]
				ifNotNil: [
					m shareFormWith: match]]].
	^ count
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 10/17/2007 13:47'!
canonicalizeSoundsBits: bitsPerSample saveOriginal: saveFlag

	| count unique match |
	count _ 0.
	unique _ OrderedCollection new: 1000.
	self allProjectMedia do: [:m |
		m isSound ifTrue: [
			match _ unique detect: [:u | u sound equals: m sound] ifNone: [nil].
			match
				ifNil: [
					bitsPerSample ifNotNil: [
						(m compressBitsPerSample: bitsPerSample saveOriginal: saveFlag)
							ifTrue: [count _ count + 1]].
					unique add: m]
				ifNotNil: [
					m shareSoundWith: match]]].

	bitsPerSample notNil & saveFlag not ifTrue: [
		"uncompress compressed sounds so the result can be heard"
		self allProjectMedia do: [:m | m isSound ifTrue: [ m decompress]]].

	^ count
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 2/9/2016 16:18'!
checkBoxLabelled: label marked: checkedFlag width: buttonWidth
	| image t5 t6 t7 t8 |
	checkedFlag
		ifTrue: [t6 _ ScratchFrameMorph skinAt: #menuTick]
		ifFalse: [t6 _ ScratchFrameMorph skinAt: #menuBlank].
	image _ ImageMorph new form: t6.
	t8 _ ' ' , label localized, '  '.
	t5 _ StringMorph contents: t8 font: (ScratchFrameMorph getFont: #MenuItem).
	t7 _ Morph new color: Color transparent.
	t7 height: (image height max: t5 height).
	t7 width: (image width + t5 width max: buttonWidth).
	image left: t7 left.
	image top: t7 top + (t7 height - image height // 2).
	t5 left: image right.
	t5 top: t7 top + (t7 height - t5 height // 2).
	t7 addMorph: image.
	t7 addMorph: t5.
	^ t7 imageForm! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 2/11/2016 16:21'!
checkForUpdate

	| t1 |
	t1 _ (self askUpdates).
	t1 = #cancelled ifFalse: [DialogBoxMorph inform: t1]..! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 7/9/2008 18:19'!
compressImages

	| s q count |
	s _ StringDialog askWithCancel: 'JPEG Quality (10-100)?' initialAnswer: '70'.
	s size = 0 ifTrue: [^ self].
	q _ [s asNumber] ifError: [nil].
	q ifNil: [^ self].
	q _ (q within: 10 and: 101) truncated.

	q > 100 ifTrue: [q _ nil].  "just canonicalize, don't compress"
	count _ self canonicalizeImagesQuality: q saveOriginal: false.

	scriptsPane categoryChanged: 'Costumes'.
	DialogBoxMorph inform: 'Images compressed' withDetails: count printString.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'ee 8/8/2008 13:16'!
compressSounds

	| menu bitsPerSample count |
	menu _ CustomMenu new title: 'Sound quality:'.
	menu add: 'High (biggest)' action: 5.
	menu add: 'Normal' action: 4.
	menu add: 'Low' action: 3.
	menu add: 'Lowest (smallest)' action: 2.
	menu addLine.
	menu add: 'cancel' action: nil.
	menu localize.
	(bitsPerSample _ menu startUp) ifNil: [^ self].

	count _ self canonicalizeSoundsBits: bitsPerSample saveOriginal: false.
	scriptsPane categoryChanged: 'Sounds'.
	DialogBoxMorph inform: 'Sounds compressed' withDetails: count printString.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 7/13/2008 10:27'!
developersMenu
	"Present the Scratch developer's menu."

	| menu |
	self world activeHand toolType: nil.
	Cursor normal show.
	menu _ CustomMenu new.

	fillScreenFlag
		ifTrue: [menu add: 'turn fill screen off' action: #fillScreenOff]
		ifFalse: [menu add: 'turn fill screen on' action: #fillScreenOn].
	UseErrorCatcher
		ifTrue: [menu add: 'turn error catching off' action: #toggleErrorCatcher]
		ifFalse: [menu add: 'turn error catching on' action: #toggleErrorCatcher].

	menu addLine.
	menu add: 'save image for end-user' action: #saveImageForEndUser.
 
	menu invokeOn: self.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 2/11/2016 14:24'!
editMenu: aMenuTitleMorph

	| menu maxWidth |
	menu _ CustomMenu new.
	menu color: (Color r: 158/255 g: 158/255 b: 158/255).
	maxWidth _ (self checkBoxLabelled: 'Small stage layout' marked: false width: 0) width.
	menu addIcon: (self checkBoxLabelled: 'Undelete' marked: false width: maxWidth) action: #undoTool.
	menu addLine.
	viewMode = #normal ifTrue: [menu addIcon: (self checkBoxLabelled: 'Small stage layout' marked: false width: maxWidth) action: #enterQuarterMode] ifFalse: [menu addIcon: (self checkBoxLabelled: 'Small stage layout' marked: true width: maxWidth) action: #enterNormalMode].
	ScratchProcess blockHighlightMSecs < 1
		ifTrue: [menu addIcon: (self checkBoxLabelled: 'Turbo mode' marked: true width: maxWidth) action: #toggleTurboMode]
		ifFalse: [menu addIcon: (self checkBoxLabelled: 'Turbo mode' marked: false width: maxWidth) action: #toggleTurboMode].

	menu addLine.
	workPane showMotorBlocks
		ifTrue: [menu addIcon: (self checkBoxLabelled: 'Hide motor blocks' marked: false width: maxWidth) action: #hideMotorBlocks]
		ifFalse: [menu addIcon: (self checkBoxLabelled: 'Show motor blocks' marked: false width: maxWidth) action: #showMotorBlocks].


	Sensor shiftPressed ifTrue: [
	fillScreenFlag
		ifTrue: [menu addIcon: (self checkBoxLabelled: 'fill screen' marked: true width: maxWidth) action: #fillScreenOff]
		ifFalse: [menu addIcon: (self checkBoxLabelled: 'fill screen' marked: false width: maxWidth) action: #fillScreenOn].
	UseErrorCatcher
		ifTrue: [menu addIcon: (self checkBoxLabelled: 'error catching' marked: true width: maxWidth) action: #toggleErrorCatcher]
		ifFalse: [menu addIcon: (self checkBoxLabelled: 'error catching' marked: false width: maxWidth) action: #toggleErrorCatcher].
	menu addLine.
	menu addIcon: (self checkBoxLabelled: 'bump major' marked: false width: maxWidth) action: #bumpMajor.
menu addIcon: (self checkBoxLabelled: 'bump minor' marked: false width: maxWidth) action: #bumpMinor.
menu addIcon: (self checkBoxLabelled: 'bump revision' marked: false width: maxWidth) action: #bumpRevision.

	menu addLine.
	menu addIcon: (self checkBoxLabelled: 'save for end-user' marked: false width: maxWidth) action: #saveImageForEndUser.].

	menu invokeOn: self at: aMenuTitleMorph bottomLeft + (0@10).
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 10/11/2006 17:56'!
editNotes

	(ScratchNotesDialog editNotesFor: self) getUserResponse.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 8/26/2008 11:50'!
enableRemoteSensors
	"Start running the Scratch server, allowing Scratch and other applications to interact with this Scratch remotely."

	| server |
	workPane scratchServer ifNil: [
		server _ ScratchServer new userName: 'Scratch'.
		server stage: workPane.
		workPane scratchServer: server].

	workPane scratchServer startHosting.
	DialogBoxMorph inform: 'Remote sensor connections enabled' localized.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 2/27/2009 09:04'!
exitScratchSession
	"Close all connections to remote collaborators."

	workPane scratchServer ifNil: [^ self].
	workPane scratchServer endScratchSession.
	workPane scratchServer: nil.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 10/28/2008 14:53'!
exportSprite

	scriptsPane target exportObject.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 4/29/2016 14:54'!
fibbonaci
	^  {{10@286. {{#callReporter. '  %n th fibbonaci number'. 12}}}. {10@13. {{#procDef. 'fibbonaci  %n   %n   %n '. {'number1'. 'number2'. 'iteration'}. {'10'. '10'. '10'}. false}. {#doIf. {#=. {#getParam. 'iteration'. #r}. '0'}. {{#report. {#getParam. 'number1'. #r}}}}. {#report. {#callReporter. 'fibbonaci  %n   %n   %n '. {#getParam. 'number2'. #r}. {#+. {#getParam. 'number1'. #r}. {#getParam. 'number2'. #r}}. {#-. {#getParam. 'iteration'. #r}. 1}}}}}. {10@186. {{#procDef. '  %n th fibbonaci number'. {'number1'}. {'10'}. true}. {#report. {#callReporter. 'fibbonaci  %n   %n   %n '. 0. 1. {#getParam. 'number1'. #r}}}}}}! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 12/3/2015 15:35'!
fileMenu: aMenuTitleMorph

	| menu maxWidth |
	menu _ CustomMenu new.
	menu color: (Color r: 158/255 g: 158/255 b: 158/255).
	maxWidth _ (self checkBoxLabelled: (Sensor shiftPressed ifTrue: ['Force Help Files Update'] ifFalse: ['Check for updates']) marked: false width: 0) width.
	menu addIcon: (self checkBoxLabelled: 'New' marked: false width: maxWidth) action: #newScratchProject.
	menu addIcon: (self checkBoxLabelled: 'Open...' marked: false width: maxWidth) action: #openScratchProject.
	menu addIcon: (self checkBoxLabelled: 'Save' marked: false width: maxWidth) action: #saveScratchProjectNoDialog.
	menu addIcon: (self checkBoxLabelled: 'Save As...' marked: false width: maxWidth) action: #saveScratchProject.
	"menu addLine.
	menu addIcon: (self checkBoxLabelled: 'Share to website' marked: false width: maxWidth) action: #share."
	menu addIcon: (self checkBoxLabelled: 'Check for updates' marked: false width: maxWidth) action: #checkForUpdate.
		Sensor shiftPressed ifTrue: [
		self addServerCommandsIconizedTo: menu width: maxWidth].
	menu addLine.
	menu addIcon: (self checkBoxLabelled: 'Import Project' marked: false width: maxWidth) action: #importScratchProject.
	menu addIcon: (self checkBoxLabelled: 'Export Sprite' marked: false width: maxWidth) action: #exportSprite.

	menu addLine.
	menu addIcon: (self checkBoxLabelled: 'Quit' marked: false width: maxWidth) action: #quitScratch.
		Sensor shiftPressed ifTrue: [
		menu addIcon: (self checkBoxLabelled: 'Force Help Files Update' marked: false width: maxWidth) action: #updateHelpFiles.
		menu addIcon: (self checkBoxLabelled: 'Import Extension File' marked: false width: maxWidth) action: #importExperimentalExtension].
		Sensor shiftPressed ifTrue: [
		menu addIcon: (self checkBoxLabelled: 'Other blocks' marked: (self class getSetting: #enableOthers) width: maxWidth)  action: #toggleOthers].
	menu localize.


	menu invokeOn: self at: aMenuTitleMorph bottomLeft + (0@10).
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 4/14/2009 09:56'!
fillScreenOff
	"Stop filling the entire screen. Useful during development."


	Smalltalk fullScreenMode: false.
	World restoreDisplay.

	fillScreenFlag _ false.
	self isSticky: false.
	self extent: Display extent - 50.
	UseErrorCatcher _ false.
	Preferences disable: #noviceMode.
	Preferences enable: #warnIfNoSourcesFile.
	Preferences enable: #warnIfNoChangesFile.
	Preferences insertionPointColor: (Color r: 0.4 g: 1.0 b: 0.0).
	Preferences textHighlightColor: (Color r: 0.4 g: 1.0 b: 0.0).
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 4/14/2009 09:55'!
fillScreenOn
	"Start filling the entire screen and being sticky. Also configure a few other things for the end user such as turning off halos and the control menu (noviceMode) and making sure that error catching is enabled."

	TakeOverScreen ifTrue: [
		Smalltalk fullScreenMode: true.
		World restoreDisplay].

	fillScreenFlag _ true.
	self position: 0@0.
	self isSticky: true.
	self comeToFront.
	UseErrorCatcher _ true.
	Sensor useOSEvents: true.
	Preferences enable: #noviceMode.
	Preferences disable: #warnIfNoSourcesFile.
	Preferences disable: #warnIfNoChangesFile.
	Preferences insertionPointColor: (Color r: 0.353 g: 0.607 b: 0.788).
	Preferences textHighlightColor: (Color r: 0.353 g: 0.607 b: 0.788).
	self updateProjectName.
	self step.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 5/13/2009 14:37'!
getLoginName
	"Ask the user for their name name and record their answer in 'loginName'."

	| s |
	s _ StringDialog
		askWithCancel: 'User name:'
		initialAnswer: loginName.
	s size = 0 ifTrue: [^ ''].
	loginName _ s.
	^ s
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'ee 4/28/2009 19:34'!
helpMenu: aMenuTitleMorph

	| menu |
	menu _ CustomMenu new.
	menu add: 'Help Page' action: #launchHelpPage.
	menu add: 'Help Screens' action: #launchAllHelpScreens.
	menu addLine.
	menu add: 'About Scratch' action: #aboutScratch.

	menu localize.

	#(1 2 3) do: [:n |
		menu labels at: n put:
			((menu labels at: n) copyFrom: 1 to: (menu labels at: n) size - 1), ScratchTranslator ellipsesSuffix].

	menu invokeOn: self at: aMenuTitleMorph bottomLeft + (0@10).
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 2/17/2009 11:33'!
hideMotorBlocks

	workPane showMotorBlocks: false.
	viewerPane refresh.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 5/14/2009 08:11'!
joinScratchSession
	"Join another Scratch user or a Scratch-compatible remote application."

	| server addrString ok |
	server _ ScratchServer new.
	server stage: workPane.
	workPane scratchServer: server.

	addrString _ StringDialog askWithCancel: 'IP address:'.
	addrString size = 0 ifTrue: [^ self].

	ok _ workPane scratchServer joinSessionAt: addrString.
	ok ifFalse: [DialogBoxMorph warn: 'Could not connect to ', addrString].
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'ee 4/29/2009 13:18'!
languageMenu: aToggleButtonMorph
	"Present a menu of possible languages for blocks."

	| bullet menu choice |
	ScratchTranslator canRenderUnicode ifFalse: [
		"try to find a Unicode plugin in case this is the first use after startup"
		ScratchTranslator detectRenderPlugin].

	bullet _ UTF8 withAll: '• '.
	menu _ CustomMenu new.
	ScratchTranslator languageNames do: [:lang |
		((ScratchTranslator isoCodeForName: lang) = (ScratchTranslator currentLanguage))
			ifTrue: [menu add: (bullet, lang) action: lang]
			ifFalse: [menu add: lang action: lang]].
	choice _ menu startUp: nil withCaption: nil at: aToggleButtonMorph bottomLeft + (0@10).

	choice ifNil: [^ self].
	self stopAll.
	self setLanguage: choice.
	self recordLanguage: (ScratchTranslator currentLanguage).
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 2/23/2009 07:07'!
launchAllHelpScreens

	self launchHelpFile: 'allscreens.html'
! !

!ScratchFrameMorph methodsFor: 'menu/button actions'!
launchHelpFile: t1 
	| t2 |
	self stopAll.
	t2 _ self helpDirectory.
	t2
		ifNil: 
			[self beep.
			^ self].
	(t2 fileExists: t1)
		ifTrue: [Smalltalk isMacOSX
				ifTrue: [ScratchPlugin primOpenURL: 'file://' , (t2 pathName , FileDirectory slash , t1) encodeForHTTP]
				ifFalse: [ScratchPlugin primOpenURL: t2 pathName , FileDirectory slash , t1]]
		ifFalse: [DialogBoxMorph inform: 'Scratch help file not found.' localized]! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'ee 4/15/2009 11:55'!
launchHelpPage

	self launchHelpFile: 'index.html'.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'ee 2/12/2009 16:45'!
launchScratchWebsite

	self world displayWorldSafely.
	Cursor wait showWhile: [ScratchPlugin primOpenURL: 'http://', ScratchFrameMorph shareServer].
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 2/9/2016 16:21'!
newScratchProject
	"Make a new, blank Scratch project."

	| response newProject sprite |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	(justSaved or: [self projectIsEmpty]) ifFalse: [
		"ask the user if they want to save the current project"
		response _ DialogBoxMorph askWithCancel: 'Save the current project?'.
		response = #cancelled ifTrue: [^ self].
		response ifTrue: [self saveScratchProjectNoDialog.
			justSaved ifFalse: [^ self]]].

	projectDirectory _ ScratchFileChooserDialog getDefaultFolderForType: #project.
	projectName _ ''.
	projectInfo _ Dictionary new.

	newProject _ ScratchStageMorph new.
	sprite _ ScratchFrameMorph defaultSprite fullCopy.
	sprite position: (241@180) - sprite extent.
	newProject addMorph: sprite.
	self installNewProject: newProject.

	self initializeWatcherPositions.
	justSaved _ true.
	"self enterNormalMode."
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 12/8/2008 12:05'!
paintSpriteMorph

	| m |
	m _ ScratchSpriteMorph new soleCostume: ImageMedia new.
	self addAndView: m.
	m editDrawingOldCostumeName: m costume mediaName deleteOnCancel: true.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 10/27/2008 13:49'!
pressGreenFlagButton
	"Simulate pressing the green flag button when enter key is pressed."

	flagButton on.
	World displayWorld.
	Delay waitMSecs: 100.
	flagButton off.
	World displayWorld.
	self shoutGo.

! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 3/26/2009 20:48'!
quitScratch
	"Quit from Scratch. Ask the user if they want to save, first."

	| response |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	(justSaved or: [self projectIsEmpty]) ifFalse: [
		response _ ScratchCloseDialog new getUserResponse.
		response = #cancelled ifTrue: [^ self].
		response ifTrue: [
			self saveScratchProjectNoDialog.
			justSaved ifFalse: [^ self]]].

	Smalltalk snapshot: false andQuit: true.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 10/10/2015 17:06'!
rebuildFullUI
| tempJustSaved |
tempJustSaved _ justSaved.
	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m convertStacksToTuples]].

	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m convertTuplesToStacks]].
	self
		view: scriptsPane target
		tab: scriptsPane tabPane currentTab
		category: viewerPane currentCategory.
	justSaved _ tempJustSaved.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 12/12/2015 13:21'!
recordProject
	^ self "Implementing soon..."! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 6/28/2008 08:48'!
renderingMenu

	ScratchTranslator renderingMenu.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 11/23/2015 19:15'!
resaveAllProjects
	"Resave all the projects in the given directory (to recompress them)."

	| dir |
	dir _ ScratchFileChooserDialog chooseFolder: FileDirectory default.
	dir = #cancelled ifTrue: [^ self].

	dir allFileNamesDo: [:fn |
		((fn asLowercase endsWith: '.sb' | (fn asLowercase endsWith: '.sb2')) and:
		 [((fn endsWith: '-2.sb') not) | ((fn endsWith: '-2.sb2') not)]) ifTrue: [
			self openScratchProjectNamed: fn.
			World doOneCycleNoInput.
"			projectName _ (fn copyFrom: 1 to: fn size - 3), '-3.sb'."
			self writeScratchProject]].
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'ee 11/10/2007 19:05'!
setSingleStepping
	"Ask whether script should be single-stepped."

	| menu mSecs |
	menu _ CustomMenu new title: 'Single-step speed?'.
	menu add: 'Turbo speed' action: 0.
	menu add: 'Normal' action: 1.
	menu add: 'Flash blocks (fast)' action: 30.
	menu add: 'Flash blocks (slow)' action: 200.
	mSecs _ menu localize startUp.
	mSecs ifNil: [^ self].
	ScratchProcess blockHighlightMSecs: mSecs.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 10/21/2008 19:26'!
share

	| dialog uploader success link |
	dialog _ ScratchUploadDialog uploadScratchFor: self.
	dialog getUserResponse = #cancelled ifTrue: [^ #cancelled].

	self updateLastHistoryEntryIfNeeded.

	loginName _ dialog userName.
	loginPassword _ dialog password.

	projectInfo at: 'author' put: loginName.
	projectInfo at: 'comment' put: dialog comment.
	projectInfo at: 'thumbnail' put: workPane thumbnailForm.
	self updateHistoryProjectName: dialog projectName op: 'share'.

	uploader _ ScratchUploadProgressDialog new
		userName: dialog userName password: dialog password;
		tags: dialog tags compression: dialog doCompression;
		projectName: (self nameFromFileName: dialog projectName)
			notes: dialog comment for: self.

	uploader
		position: World center - (uploader extent // 2);  "center on screen"
		openInWorld.

	success _ uploader postToHost: ShareServer path: ShareServerPath.
	success = #cancelled ifTrue: [uploader delete. ^ self removeLastHistoryEntry].
	success ifFalse: [ "failed; wait for user to close the dialog box"
		uploader getUserResponse.
		^ self removeLastHistoryEntry].

	uploader delete. World doOneCycle.

	link _ LinkMorph new
		font: (ScratchFrameMorph getFont: #ShareLink);
		contents: 'scratch.mit.edu';
		url: 'http://', ScratchFrameMorph shareServer, '/users/', dialog userName.

	DialogBoxMorph new
		title: 'Upload succeeded!!';
		withButtonsForYes: false no: false okay: true cancel: false;
		message: 'Your project is now online at';
		addMessageLine: link;
		getUserResponse.

	projectName _ self nameFromFileName: dialog projectName.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 9/29/2015 14:25'!
shareMenu: aMenuTitleMorph

	| menu |
	menu _ CustomMenu new.
	menu add: 'Share This Project Online' action: #share.
	menu add: 'Go To Scratch Website' action: #launchScratchWebsite.

	Sensor shiftPressed ifTrue: [
		self addServerCommandsTo: menu].

	menu localize.

	#(1 2) do: [:n |
		menu labels at: n put:
			((menu labels at: n) copyFrom: 1 to: (menu labels at: n) size - 1), ScratchTranslator ellipsesSuffix].

	menu invokeOn: self at: aMenuTitleMorph bottomLeft + (0@10).

! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 3/26/2009 22:21'!
showMotorBlocks

	workPane showMotorBlocks: true.
	viewerPane currentCategory: 'motion'.
	viewerPane pageViewer vScrollRelative: 1.0.! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 5/14/2009 10:33'!
showNetworkAddress
	"Display my IP address. This is a temporary feature to allow connected multiple Scratch computers in a peer-to-peer configuration without the help of a presence server."

	| localAddr wanAddr msg |
	Socket initializeNetwork.
	localAddr _ NetNameResolver localHostAddress.
	wanAddr _ nil.
"	wanAddr _ ScratchServer getIPAddressFromServer."

	msg _ NetNameResolver stringFromAddress: localAddr.
	(wanAddr notNil and: [wanAddr ~= localAddr]) ifTrue: [
		msg _ msg, String cr, 'Internet:   ', (NetNameResolver stringFromAddress: wanAddr)].

	DialogBoxMorph inform: msg title: 'IP Address'.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 10/31/2006 20:59'!
showSensorBoard

	| sb |
	sb _ workPane sensorBoard.
	sb position: self workPane position + 20.
	self workPane addMorph: sb.
	sb tryToOpenPort.
	World startSteppingSubmorphsOf: sb.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 5/14/2009 10:33'!
startHostingScratchSession
	"Start running the Scratch server, allowing Scratch and other applications to interact with this Scratch remotely."

	| server |
	workPane scratchServer ifNil: [
		server _ ScratchServer new.
		server stage: workPane.
		workPane scratchServer: server].

	workPane scratchServer startHosting.
	self showNetworkAddress.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 11/14/2006 17:58'!
stopAll
	"Tell my workPane to stop everything."

	| oldJustSaved |
	oldJustSaved _ justSaved.
	workPane stopAll.
	justSaved _ oldJustSaved.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 12/8/2008 12:05'!
surpriseSpriteMorph

	| fileName f el m e |
	self world activeHand toolType: nil.
	self paintingInProgress ifTrue: [^ self beep].

	fileName _ self nextSurpriseCostumeName.
	fileName ifNil: [
		^ self addAndView: ScratchFrameMorph defaultSprite fullCopy].

	[f _ Form fromFileNamed: fileName] ifError: [^ self].
	el _ ImageMedia new form: (ScratchFrameMorph scaledFormForPaintEditor: f).
	m _ ScratchSpriteMorph new soleCostume: el.
	el mediaName: (m unusedMediaNameFromBaseName: (FileDirectory localNameFor: fileName)).
	self addAndView: m.

	e _ (workPane extent - m extent) abs // 2.
	m referencePosition: ((e x negated) to: e x) atRandom @ ((e y negated) to: e y) atRandom.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 4/29/2016 14:41'!
tipsScreens: blank 
	| menu sprite blocks x y t |
	Sensor shiftPressed
		ifTrue: 
			[menu _ CustomMenu new.
			menu title: 'WHISKERS BETA MENU
This is for testing features, and beta features'.
			fillScreenFlag ifFalse: [
			menu add: 'Backwards compliant special features' action: #backwardsSpecial.
			menu add: 'Create a project with ALL blocks' action: #allBlocks.
			menu add: 'Get picture of stage' action: #stagePic.
			menu add: 'Get picture of scratch' action: #scratchPic.
			menu addLine].
			menu add: 'Fibbonaci test' action: #fibTest.
			menu startUp caseOf: {
				[#backwardsSpecial] -> [ScratchSettings at: #backwardsSpecial put: (ScratchSettings at: #backwardsSpecial) not].
				[#allBlocks] -> 
					
					[self newScratchProject.
					sprite _ ScratchFrameMorph allInstances first workPane firstSubmorph.
					blocks _ #().
					#('events' 'control' 'motion' 'motor' 'looks' 'pen' 'operators' 'sound' 'sensing' 'variables' 'list' 'more blocks' 'obsolete' ) do: [:m | blocks _ blocks , (sprite blocksFor: m)].
					x _ 12.
					y _ 10.
					sprite blocksBin: ((blocks select: [:m | m isKindOf: BlockMorph])
							collect: [:m | t _ {x @ y. {m asBlockTuple}}. (y _ y + m height + 10). t]).
					sprite convertTuplesToStacks.
					sprite blocksBin cleanUp].
				[#stagePic] -> [(ImageMorph new form: (Display copy: workPane bounds)) openInWorld].
				[#scratchPic] -> [(ImageMorph new form: (Display copy: self bounds)) openInWorld].
				[#fibTest] -> [self newScratchProject.
				sprite _ ScratchFrameMorph allInstances first workPane firstSubmorph.
				sprite blocksBin: self fibbonaci.
				sprite convertTuplesToStacks]

				}
				otherwise: []]
		ifFalse: [TipsDialog ask: 'select a category' localized]! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 9/29/2003 23:19'!
toggleErrorCatcher

	UseErrorCatcher _ UseErrorCatcher not.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 11/18/2015 14:43'!
toggleOthers
	| f sz settings all |
	ScratchSettings at: #enableOthers put: (self class getSetting: #enableOthers) not.
		f _ FileStream concreteStream new open: self class settingsFileName forWrite: true.
	f ifNil: [^ self].
	sz _ f size.
	settings _ (f next: sz) lines.
	settings _ settings reject: [:s | s asLowercase beginsWith: 'otherblocks='].
	settings _ settings
				reject: 
					[:s | 
					all _ s asByteArray asSet.
					all size = 1 and: [all asArray first = 0]].
	settings _ settings copyWith: 'OtherBlocks=' , (ScratchSettings at: #enableOthers ifAbsent: false) asString.
	f position: 0.
	settings do: [:s | f nextPutAll: s , String crlf].
	[f position < sz]
		whileTrue: [f nextPut: 0 asCharacter].
	f close! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 3/14/2005 15:13'!
toggleSingleStepping
	"Toggle single stepping."

	ScratchProcess blockHighlightMSecs <= 1
		ifTrue: [ScratchProcess blockHighlightMSecs: 60]
		ifFalse: [ScratchProcess blockHighlightMSecs: 1].
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 12/3/2015 14:27'!
toggleTurboMode
	"Ask whether script should be single-stepped."

	| |
	ScratchProcess blockHighlightMSecs = 0 ifTrue: [ScratchProcess blockHighlightMSecs: 1] ifFalse: [ScratchProcess blockHighlightMSecs: 0].
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 6/14/2007 18:44'!
uniqueSummaryFileName

	| baseName fileName n |
	baseName _ self projectName.
	baseName size <= 1 ifTrue: [baseName _ 'newProject'].
	fileName _ baseName, '-summary.txt'.
	n _ 1.

	[FileDirectory default fileExists: fileName] whileTrue: [
		fileName _ baseName, n printString, '-summary.txt'.
		n _ n + 1].

	^ fileName

! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'EMP 11/23/2015 19:16'!
writeMultipleSummaries
	"Write the summary for all Scratch projects in a given folder."

	| dir |
	dir _ ScratchFileChooserDialog chooseFolder: FileDirectory default.
	dir = #cancelled ifTrue: [^ self].

	dir allFileNamesDo: [:fn |
		(fn asLowercase endsWith: '.scratch') | (fn asLowercase endsWith: '.sb') | (fn asLowercase endsWith: '.sb2') ifTrue: [
			self openScratchProjectNamed: fn.
			World doOneCycleNoInput.
			self writeSummaryFile: fn]].
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 6/14/2007 17:06'!
writeSummaryFile
	"Write a summary of this project to a file."

	self writeSummaryFile: ''.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 5/21/2009 10:28'!
writeSummaryFile: fullFileName
	"Write a summary of this project to a file."

	| s sprites f fName |
	s _ WriteStream on: (String new: 10000).

	s nextPutAll: 'Project: ', self projectName; crlf.
	fullFileName size > 0 ifTrue: [s nextPutAll: 'Location: ', fullFileName; crlf].
	(projectInfo includesKey: 'author') ifTrue: [
		s nextPutAll: 'Author: ', (projectInfo at: 'author'); crlf].
	(projectInfo includesKey: 'scratch-version') ifTrue: [
		s nextPutAll: 'Scratch: ', (projectInfo at: 'scratch-version'); crlf].
	(projectInfo includesKey: 'comment') ifTrue: [
		s nextPutAll: 'Notes:'; crlf.
		(projectInfo at: 'comment') lines do: [:l | s nextPutAll: '    ', l; crlf].
		s crlf].
	(projectInfo includesKey: 'history') ifTrue: [
		s nextPutAll: 'History:'; crlf.
		(projectInfo at: 'history') lines do: [:l | s nextPutAll: '    ', l; crlf].
		s crlf].

	self writeSummaryTotalsOn: s.
	s nextPutAll: '--------'; crlf.
	workPane printSummaryOn: s.
	sprites _ workPane submorphs select: [:m | m isKindOf: ScratchSpriteMorph].
	sprites do: [:m |
		s skip: -2.  "remove last crlf"
		s nextPutAll: '--------'; crlf.
		m printSummaryOn: s].
	s nextPutAll: '--------'; crlf.

	ParagraphEditor clipboardTextPut: s contents asText.

	fName _ fullFileName.
	fullFileName size = 0
		ifTrue: [
			fName _ ScratchFileChooserDialog
				chooseNewFileDefault: self uniqueSummaryFileName
				title: 'File Name?'
				type: #projectSummary.
			fName = #cancelled ifTrue: [^ self]]
		ifFalse: [
			fName _ self uniqueSummaryFileName].

	f _ StandardFileStream newScratchFileNamed: fName.
	f ifNil: [^ self].
	f nextPutAll: s contents.
	f close.
! !

!ScratchFrameMorph methodsFor: 'menu/button actions' stamp: 'jm 3/20/2007 09:50'!
writeSummaryTotalsOn: aStream
	"Write the totals for this project on the given stream."

	| sprites uniqueCostumes uniqueSounds stackCount |
	sprites _ workPane submorphs select: [:m | m isKindOf: ScriptableScratchMorph].
	sprites _ sprites asArray copyWith: workPane.
	uniqueCostumes _ IdentitySet new: 100.
	uniqueSounds _ IdentitySet new: 100.
	stackCount _ 0.
	sprites do: [:m |
		m media do: [:item |
			item isImage ifTrue: [uniqueCostumes add: item form].
			item isSound ifTrue: [uniqueSounds add: item sound]].
		stackCount _ stackCount + m blocksBin submorphCount].

	aStream nextPutAll: 'Totals: '; crlf.
	aStream nextPutAll: '    Sprites: ', (sprites size - 1) printString; crlf.
	aStream nextPutAll: '    Stacks: ', stackCount printString; crlf.
	aStream nextPutAll: '    Unique costumes: ', uniqueCostumes size printString; crlf.
	aStream nextPutAll: '    Unique sounds: ', uniqueSounds size printString; crlf.
! !


!ScratchFrameMorph methodsFor: 'geometry' stamp: 'jm 10/26/2008 17:44'!
extent: aPoint
	"Position all my submorphs whenever I get resized."

	super extent: aPoint.
	self fixLayout.
! !

!ScratchFrameMorph methodsFor: 'geometry' stamp: 'EMP 2/7/2016 11:13'!
fixLayout

	| stageExtent xyReadout w |
	stageExtent _
		workPane isQuarterSize
			ifTrue: [workPane extent // 2]
			ifFalse: [workPane extent].

	topPane
		position: self topLeft;
		width: self width;
		height: (menuPanel height max: (logoMorph height + 2)).
	logoMorph center: topPane center; left: topPane left + 2.

	stageFrame
		extent: stageExtent + (2@50);
		top: topPane bottom;
		left: self left + 1.

	workPane position: stageFrame topLeft + (2@45).
	smallerStageFrame position: workPane topLeft - (1@1); extent: stageExtent + (2@2); comeToFront.
	workPane comeToFront.

	titlePane
		position: stageFrame topLeft + (1@4);
		width: stageFrame width;
		height: 45.

	self fixProjectTitleMorphLayout.

	tabHolderMorph width: (self width - (stageFrame width + 10));
	height: 30;
	position: stageFrame topRight + (10@0).

	tipsPane ifNotNil: [
	tipsPane top: tabHolderMorph bottom; right: self right; height: self bottom - tabHolderMorph bottom
].

	scriptsPane fixLayout.
	w _ (viewerPane catButtonsExtent x + 17)
		within: 40
		and: (self width - (scriptsPane bareMinimumWidth + stageFrame width)).
	viewerPane position: tabHolderMorph bottomLeft;
		width: w;
		height: self bottom - tabHolderMorph bottom.

	scriptsPane
		position: (showingCatSelector ifTrue: [viewerPane topRight] ifFalse: [tabHolderMorph bottomLeft]);
		width: (self width - (stageFrame width + (tipsPane width) + (showingCatSelector ifTrue: [viewerPane width] ifFalse: [0]))) - 10;
		height: self bottom - tabHolderMorph bottom;
		fixLayout.

	libraryPane position: ((self left + 2) @ (stageFrame bottom + 10));
		width: (showingCatSelector ifTrue: [(viewerPane left - 10) - (self left + 2)] ifFalse: [(tabHolderMorph left - 10) - (self left + 2)]);
		height: (self bottom - libraryPane top) - 2.

	menuPanel
		left: logoMorph right + 10;
		top: topPane top + ((topPane height - menuPanel height) // 2) + 2.

	viewModeButtonsPanel
		right: stageFrame left + ((viewModeButtonsPanel width) + 8);
		top: stageFrame top + 9.

	stageButtonsPanel
		position: (stageFrame left + (10 + viewModeButtonsPanel width))@(topPane bottom + 5);
		width: (stageFrame width - 28) - (viewModeButtonsPanel width);
		height: (workPane top - stageFrame top) - 8.

	xyReadout _ readoutPane submorphs at: 1.
	readoutPane
		width: xyReadout width;
		height: xyReadout height;
		position: (stageFrame bottomRight - ((xyReadout width) @ 3)).
	xyReadout right: readoutPane right;
				top: readoutPane top.

	tabPaneMorph
		left: (showingCatSelector ifTrue: [viewerPane left + 2] ifFalse: [scriptsPane left + 2]);
		extent: 400 @ ((scriptsPane top - topPane bottom));
		bottom: scriptsPane top.

	toolbarPanel left: (showingCatSelector
			ifTrue: [viewerPane left]
			ifFalse: [tabHolderMorph left])
			- 1;
		 top: self top + (topPane height / 2 - (toolbarPanel height / 2)) - 1! !

!ScratchFrameMorph methodsFor: 'geometry'!
hidePalette: hidePalette
	"Hide or show the blocks palette."

	hidePalette = viewerPane owner isNil ifTrue: [^ self].  "no change"

	hidePalette
		ifTrue: [
			viewerPane delete.
			scriptsPane
				initFrontFromForm: (ScratchFrameMorph skinAt: #blocksPaletteFrameTransparent2) topSectionHeight: 0;
				middleBarLeftMargin: 5 rightMargin: 0]
		ifFalse: [
			self addMorph: viewerPane.
			scriptsPane
				initFrontFromForm: (ScratchFrameMorph skinAt: #scriptPaneFrameTransparent2) topSectionHeight: 0;
				middleBarLeftMargin: 0 rightMargin: 0].

	scriptsPane color: (Color r: 149/255 g: 154/255 b: 159/255).
! !


!ScratchFrameMorph methodsFor: 'drawing' stamp: 'jm 12/9/2008 18:27'!
areasRemainingToFill: aRectangle
	"Drawing optimization. Since I completely fill my bounds with opaque pixels, this method tells Morphic that it isn't necessary to draw any morphs covered by me."
	
	^ aRectangle areasOutside: self bounds
! !

!ScratchFrameMorph methodsFor: 'drawing' stamp: 'EMP 12/2/2015 14:26'!
drawOn: aCanvas
	"Needed to fix some visual glitches"
	aCanvas fillRectangle: self bounds color: Color white "Comment this out to test color filling..."
! !

!ScratchFrameMorph methodsFor: 'drawing' stamp: 'EMP 12/10/2015 12:39'!
fullDrawOn: aCanvas
	"Draw my full Morphic structure on the given Canvas."
	"Optimization: if damage is entirely contained in a given pane, draw only that pane."

	| damageR stageR |

	damageR _ aCanvas clipRect.

	stageR _ workPane bounds.
	workPane isQuarterSize ifTrue: [
		stageR _ workPane position extent: (workPane width // 2) @ (workPane height // 2)].
	(stageR containsRect: damageR) ifTrue: [
		workPane fullDrawOn: aCanvas.
		^ self].

	(tipsPane fullBounds containsRect: damageR) ifTrue: [
		tipsPane fullDrawOn: aCanvas.
		^ self]. "Because the tips pane is meant to overlap the scripts pane, draw the tips pane on top."

	(scriptsPane bounds containsRect: damageR) ifTrue: [
		scriptsPane fullDrawOn: aCanvas.
		^ self].

	(viewerPane bounds containsRect: damageR) ifTrue: [
		viewerPane fullDrawOn: aCanvas.
		^ self].

	(readoutPane bounds containsRect: damageR) ifTrue: [
		readoutPane fullDrawOn: aCanvas.
		^ self].

	(libraryPane bounds containsRect: damageR) ifTrue: [
		libraryPane fullDrawOn: aCanvas.
		^ self].

	super fullDrawOn: aCanvas.
! !


!ScratchFrameMorph methodsFor: 'event handling' stamp: 'jm 3/16/2007 16:53'!
handlesMouseDown: evt

	^ true
! !

!ScratchFrameMorph methodsFor: 'event handling' stamp: 'EMP 12/2/2015 14:28'!
mouseDown: evt
	"Revert to normal cursor Use the code below to find a point."
	"Sensor waitClickButton. Sensor cursorPoint"
	| p |
	evt hand toolType: nil.

	p _ self position + (ScratchFrameMorph isXO ifTrue: [0@0] ifFalse: [0@0]).
	(((p extent: 10@10) containsPoint: evt cursorPoint) and:
	 [evt shiftPressed])
		ifTrue: [^ self developersMenu].
	
	"move; makes developing the top frame hard :)
	(evt cursorPoint y - self top) < topPane height ifTrue: [
		fillScreenFlag ifFalse: [evt hand grabMorph: self]]."
! !

!ScratchFrameMorph methodsFor: 'event handling' stamp: 'EMP 12/2/2015 14:34'!
wantsKeyboardFocusFor: aSubmorph
	"Don't allow shift-click edit and select in random label strings."

	^ false! !


!ScratchFrameMorph methodsFor: 'stepping' stamp: 'jm 6/25/2009 17:13'!
checkForWeDo
	"Check for WeDo, and show motor blocks if it is found."
	"Note: Polling on Vista can take several hundred milliseconds, so reduce polling to just a few times per minute."

	| now |
	now _ Time millisecondClockValue.
	(lastWeDoPoll isNil or: [lastWeDoPoll > now]) ifTrue: [lastWeDoPoll _ 0].
	((now - lastWeDoPoll) < 15000) ifTrue: [^ self]. "don't poll too often"
	lastWeDoPoll _ now.
	WeDoPlugin readInputs.
	WeDoPlugin isOpen ifTrue: [
		workPane showMotorBlocks ifTrue: [^ self].
		self showMotorBlocks.
		WeDoPlugin readInputs].
! !

!ScratchFrameMorph methodsFor: 'stepping' stamp: 'EMP 11/23/2015 16:08'!
processDroppedFiles
	"Process any files that have been dropped onto me."

	| droppedFiles m dropPoint fName |
	droppedFiles _ FileStream droppedFiles.
	droppedFiles size = 0 ifTrue: [^ self].
	(m _ self viewerPane target) ifNil: [^ self].
	dropPoint _ droppedFiles first.

	(droppedFiles copyFrom: 2 to: droppedFiles size) do: [:file |
		file close.
		fName _ file fullName.
		((fName asLowercase endsWith: '.scratch') | (fName asLowercase endsWith: '.sb') | (fName asLowercase endsWith: '.sb2'))
			ifTrue: [self openScratchDroppedProjectNamed: fName]
			ifFalse: [
				(fName asLowercase endsWith: '.sprite')
					ifTrue: [self importSpriteOrProject: fName]
					ifFalse: [m importMedia: fName]]].
! !

!ScratchFrameMorph methodsFor: 'stepping' stamp: 'EMP 4/26/2016 16:27'!
processKeyboardEvents

	| evt ch |
	World hands do: [:h |
		[(evt _ h nextUnclaimedKeystrokeOrNil) notNil] whileTrue: [
			ch _ evt keyValue.
			evt commandKeyPressed ifTrue: [ch _ ch \\ 32].	"map cmd/alt keys to control keys"
			(ch = 3) | (ch = 13) ifTrue: [^ self pressGreenFlagButton].
			ch = 15 ifTrue: [^ self openScratchProject].
			ch = 17 ifTrue: [^ self quitScratch].
			ch = 19 ifTrue: [^ self saveScratchProjectNoDialog].
			ch = 27 ifTrue: [
				TakeOverScreen ifTrue: [
					Smalltalk fullScreenMode: false.
					Smalltalk fullScreenMode: true.
					World restoreDisplay].
				^ self].
			workPane broadcastEvent: (ScratchKeypressEvent for: evt)]].
! !

!ScratchFrameMorph methodsFor: 'stepping' stamp: 'jm 5/20/2009 16:59'!
step
	"Run each process until it gives up control, then filter out any processes that have terminated."

	| screenExtent oldJustSaved |
	fillScreenFlag ifTrue: [
		screenExtent _ Display extent.
		((self position = (0@0)) and: [self extent = screenExtent]) ifFalse: [
			oldJustSaved _ justSaved.
			self position: 0@0.
			self extent: screenExtent.
			self enterQuarterModeIfSmallScreen.
			scriptsPane currentCategory: scriptsPane currentCategory.
			justSaved _ oldJustSaved.
			^ self]].

	workPane ifNotNil: [
		ScriptableScratchMorph scratchOrigin: workPane center.
		viewerPane target isNil 
			ifTrue: [workPane viewBlocksAndScripts]
			ifFalse: [viewerPane target isInWorld ifFalse: [workPane viewBlocksAndScripts]]].

	Sensor processOSMenuEvents.
	paintingInProgress ifTrue: [^ self].

	workPane scratchServer ifNotNil: [workPane scratchServer stepServer].
	self checkForWeDo.
	self updateToolButtons.
	self processWhenConditions.
	self processKeyboardEvents.
	workPane stepProcesses.
	workPane scratchServer ifNotNil: [workPane scratchServer stepServer].
	self processDroppedFiles.
	workPane processesToRun size > 0
		ifTrue: [flagButton on]
		ifFalse: [flagButton off].
! !

!ScratchFrameMorph methodsFor: 'stepping' stamp: 'jm 7/9/2003 12:02'!
stepTime
	"Every screen update cycle."

	^ 0
! !

!ScratchFrameMorph methodsFor: 'stepping' stamp: 'jm 4/22/2009 08:36'!
updateToolButtons
	"Update the highlighting of my tool buttons."

	| toolButtons currentTool |
	Sensor anyButtonPressed ifTrue: [^ self].  "don't update if mouse button pressed"

	toolButtons _ toolbarPanel submorphs select: [:m |
		(m isKindOf: ToggleButton) and: [m actionSelector endsWith: 'Tool']].

	currentTool _ (World activeHand toolType ifNil: ['none']) asLowercase.
	toolButtons do: [:b |
		(b actionSelector asLowercase = currentTool)
			ifTrue: [b on]
			ifFalse: [b off]].

! !


!ScratchFrameMorph methodsFor: 'dropping/grabbing' stamp: 'ee 5/14/2008 12:55'!
wantsDroppedMorph: aMorph event: evt

	^ (aMorph isKindOf: BlockMorph) or: [
	  	(aMorph isKindOf: ScriptableScratchMorph) or: [
			(aMorph isKindOf: ScratchCommentMorph)]].
! !


!ScratchFrameMorph methodsFor: 'view mode' stamp: 'jm 7/25/2006 11:46'!
closeDialogBoxes
	"Close all dialog boxes, including PaintEditors and SoundRecorders."

	World submorphs do: [:m |
		(m isKindOf: DialogBoxMorph) ifTrue: [m cancelled; delete]].
! !

!ScratchFrameMorph methodsFor: 'view mode' stamp: 'jm 4/13/2009 21:05'!
enterNormalMode
	"Go into normal (full-stage) mode."

	(viewMode = #normal) ifTrue: [
		self updateViewModeButtons.
		^ self].

	viewMode _ #normal.

	workPane isQuarterSize: false.
	workPane isInWorld
		ifTrue: [self fixLayout]
		ifFalse: [self exitPresentationMode].

	self updatePanes.
	self updateViewModeButtons.
! !

!ScratchFrameMorph methodsFor: 'view mode' stamp: 'EMP 11/18/2015 11:54'!
enterPresentationMode
	"Go into presentation mode."

	| presenter |
	ScratchPlugin pluginAvailable ifFalse: [
		self updateViewModeButtons.
		^ self beep].

	(viewMode = #presentation) ifTrue: [^ self].

	lastViewMode _ viewMode.
	viewMode _ #presentation.

	self closeDialogBoxes.
	workPane isQuarterSize: false.
	presenter _ ScratchPresenterMorph new frame: self.

	self delete.

	Sensor shiftPressed ifFalse: [
	Smalltalk fullScreenMode: true].
	World restoreDisplay.
	World assuredCanvas.  "re-allocate canvas after entering full-screen mode"

	((Display width >= 965) & (Display height >= 753))
		ifTrue: [presenter beDoubleSize].
	presenter extent: Display extent.

	World addMorphBack: presenter.
	World startSteppingSubmorphsOf: presenter.
	World activeHand newKeyboardFocus: nil.
	self updatePenPositions.
	self updateViewModeButtons.

	World assuredCanvas.  "re-allocate canvas after entering full-screen mode"
	World fullRepaintNeeded.
	World displayWorldSafely.
! !

!ScratchFrameMorph methodsFor: 'view mode' stamp: 'jm 4/13/2009 21:01'!
enterQuarterMode
	"Go into quarter stage mode."

	(viewMode = #quarter) ifTrue: [
		self updateViewModeButtons.
		^ self].

	viewMode _ #quarter.

	workPane isQuarterSize: true.
	workPane isInWorld
		ifTrue: [self fixLayout]
		ifFalse: [self exitPresentationMode].

	self updatePanes.
	self updateViewModeButtons.
! !

!ScratchFrameMorph methodsFor: 'view mode' stamp: 'EMP 12/9/2015 12:32'!
exitPresentationMode
	"Exit presentation mode."

	TakeOverScreen ifFalse: [
		Smalltalk fullScreenMode: false.
		World restoreDisplay].

	ScriptableScratchMorph doubleSize: false.
	self addMorphFront: workPane.
	self fixLayout.
	World addMorphBack: self.
	World startSteppingSubmorphsOf: self.

	lastViewMode = #normal ifTrue: [^ self enterNormalMode].
	lastViewMode = #quarter ifTrue: [^ self enterQuarterMode].

	World fullRepaintNeeded.
	self updatePenPositions. "We want to paint AFTER we change the modes"
! !

!ScratchFrameMorph methodsFor: 'view mode' stamp: 'jm 3/2/2009 12:56'!
projectComment: aString

	aString = DefaultNotes ifTrue: [
		projectInfo removeKey: 'comment' ifAbsent: [].
		^ self].

	projectInfo at: 'comment' put: aString asString.
! !

!ScratchFrameMorph methodsFor: 'view mode' stamp: 'jm 11/15/2006 17:10'!
updatePenPositions
	"Update the pen positions of my sprites when going between normal and presentation mode."

	| stage |
	stage _ self workPane.
	ScriptableScratchMorph scratchOrigin: stage center.
	stage submorphsDo: [:m | stage updatePenPositionFor: m].
! !

!ScratchFrameMorph methodsFor: 'view mode' stamp: 'ee 12/5/2008 17:27'!
updateViewModeButtons

	viewModeButtons do: [:b | b off].
	viewModeButtons do: [:b |
		(b actionSelector = #enterQuarterMode and: [viewMode = #quarter])
			ifTrue: [b on].
		(b actionSelector = #enterNormalMode and: [viewMode = #normal])
			ifTrue: [b on].
		(b actionSelector = #enterPresentationMode and: [viewMode = #presentation])
			ifTrue: [b on]].
! !


!ScratchFrameMorph methodsFor: 'other' stamp: 'ee 4/23/2008 22:01'!
addAndView: aSpriteMorph
	"Add given morph to the work pane and view it."

	| pos i p |
	aSpriteMorph center: workPane center.
	pos _ self scratchObjects collect: [:o | o referencePosition].
	i _ 0.
	[pos includes: (p _ (10 * i) asPoint)] whileTrue: [i _ i + 1].
	workPane addMorphFront: aSpriteMorph.
	aSpriteMorph objName: aSpriteMorph nextInstanceName.
	aSpriteMorph referencePosition: p.
	aSpriteMorph startStepping.
	workPane sprites addLast: aSpriteMorph.
	self view: aSpriteMorph tab: 'Scripts' category: 'motion'.
! !

!ScratchFrameMorph methodsFor: 'other' stamp: 'ee 7/1/2008 11:09'!
closeMediaEditorsAndDialogs
	"Close any open paint or sound editors, asking the user first to avoid losing edits. Answer true if all are closed."

	| mList mHasCancel |
	mList _ PaintFrame allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close paint editor?') ifFalse: [^ false].
		mList do: [:m | m cancelled; delete].
		paintingInProgress _ false].

	mList _ ScratchSoundRecorderDialogMorph allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close sound recorder?') ifFalse: [^ false].
		mList do: [:m | m cancelled; delete]].

	mList _ DialogBoxMorph allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close dialog?') ifFalse: [^ false].
		mList do: [:m |
			mHasCancel _ false.
			m buttons do: [:b |
				b action = #cancelled ifTrue: [mHasCancel _ true]].
			mHasCancel
				ifTrue: [m cancelled; delete]
				ifFalse: [m no; delete]]].

	DialogBoxMorph subclassesDo: [:c |
		mList _ c allInstances select: [:m | m isInWorld].
		mList size > 0 ifTrue: [
			(DialogBoxMorph ask: 'Close dialog?') ifFalse: [^ false].
			mList do: [:m |
				mHasCancel _ false.
				m buttons do: [:b |
					b action = #cancelled ifTrue: [mHasCancel _ true]].
				mHasCancel
					ifTrue: [m cancelled; delete]
					ifFalse: [m no; delete]]]].

	"subclass of a subclass of DialogBoxMorph"
	mList _ NewVariableDialog allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close dialog?') ifFalse: [^ false].
		mList do: [:m | m cancelled; delete]].

	^ true
! !

!ScratchFrameMorph methodsFor: 'other' stamp: 'jm 2/24/2004 18:57'!
delete

	World activeHand toolType: nil.
	super delete.
! !

!ScratchFrameMorph methodsFor: 'other'!
helpDirectory
	| t1 t2 |
	(FileDirectory default directoryNames includes: 'Help')
		ifTrue: [t1 _ FileDirectory default directoryNamed: 'Help'].
	Smalltalk isUnix
		ifTrue: [(FileDirectory default directoryExists: '/usr/share/scratch/Help')
				ifTrue: [t1 _ FileDirectory on: '/usr/share/scratch/Help']].
	t1 ifNil: [^ nil].
	(t1 directoryNames includes: 'en')
		ifTrue: [t2 _ t1 directoryNamed: 'en'].
	(t1 directoryNames includes: ScratchTranslator currentLanguage)
		ifTrue: [t2 _ t1 directoryNamed: ScratchTranslator currentLanguage].
	^ t2! !

!ScratchFrameMorph methodsFor: 'other'!
mouseX

	^ (workPane mouseX) within: -240 and: 240! !

!ScratchFrameMorph methodsFor: 'other'!
mouseY

	^ (workPane mouseY) within: -180 and: 180! !

!ScratchFrameMorph methodsFor: 'other'!
newSound
	"Open the dialog to record a new sound."

	tabPaneMorph currentTab: 'Sounds'.
	viewerPane target recordSound.! !

!ScratchFrameMorph methodsFor: 'other' stamp: 'jm 8/2/2005 19:17'!
openMIDI
	"Prompt the user to select a MIDI port number, then open it."

	workPane openMIDI.
! !

!ScratchFrameMorph methodsFor: 'other'!
presentHelpScreen: aStringOrNil
	"Look for a help screen with the given name in the 'Help' folder. If found, present it to the user."

	| helpDir subDir fileNames helpFileName helpForm |
	aStringOrNil ifNil: [^ self beep].

	"(FileDirectory default directoryNames includes: 'Help') ifFalse: [^ self beep].  no help folder
	helpDir _ FileDirectory default directoryNamed: 'Help'.

	use the English subfolder by default if it exists
	(helpDir directoryNames includes: 'en') ifTrue: [subDir _ helpDir directoryNamed: 'en'].
	use subfolder for the current language if it exists
	(helpDir directoryNames includes: ScratchTranslator currentLanguage) ifTrue: [
		subDir _ helpDir directoryNamed: ScratchTranslator currentLanguage].
	subDir ifNotNil: [helpDir _ subDir].

	fileNames _ helpDir fileNames collect: [:s | s asLowercase].

	helpFileName _ nil.
	#(hlp gif png jpg bmp) do: [:ext |
		helpFileName ifNil: [
			helpFileName _ aStringOrNil, '.', ext.
			(fileNames includes: helpFileName asLowercase)
				ifFalse: [helpFileName _ nil]]].
	helpFileName ifNil: [^ self beep].

	World doOneCycle.  update cursor before fetching helpForm
	[helpForm _ Form fromFileNamed: (helpDir fullNameFor: helpFileName)]
		ifError: [^ self beep].

	HelpDialog showForm: helpForm."
	HelpDialog showForm: (ScratchFrameMorph helpSkinAt: aStringOrNil).
! !

!ScratchFrameMorph methodsFor: 'other' stamp: 'EMP 4/12/2016 13:47'!
processWhenConditions
	"Trigger any 'when <condition>' hats."

	| objList |
	"true ifTrue: [^ self].  enabled"
	objList _ workPane submorphs select: [:m | m isKindOf: ScriptableScratchMorph].
	objList _ objList copyWith: workPane.
	objList do: [:obj |
		obj scripts do: [:hat |
			(hat isMemberOf: WhenTrueHatBlockMorph) ifTrue: [
				(hat hasRunningProcess not and: [hat evaluateCondition]) ifTrue: [
					hat start; layoutChanged]].
			(hat isMemberOf: WhenHatBlockMorph) ifTrue: [
				(hat hasRunningProcess not and: [hat evaluateCondition]) ifTrue: [
					hat start; layoutChanged]]]].
! !

!ScratchFrameMorph methodsFor: 'other' stamp: 'jm 11/13/2003 20:42'!
projectDirectory

	projectDirectory ifNil: [^ FileDirectory default].
	^ projectDirectory
! !

!ScratchFrameMorph methodsFor: 'other' stamp: 'jm 11/14/2006 17:41'!
projectModified
	"Record that the current project has changed since it was last saved."

	justSaved _ false.
! !

!ScratchFrameMorph methodsFor: 'other' stamp: 'EMP 4/29/2016 12:33'!
saveImageForEndUser

	| screenExtent |
	(self confirm: '
Close non-Scratch windows and save this
image in end-user (fillScreen) mode?') ifFalse: [^ self].

	ScratchFrameMorph isXO ifTrue: [Preferences useLargeFonts].

	self setLanguage: 'en'.
	self clearStage.

	Display newDepth: 32.
	self fillScreenOn.
	World doOneCycleNow.
	Smalltalk snapshot: true andQuit: true.
	screenExtent _ Display extent.
		((self position = (0@0)) and: [self extent = screenExtent]) ifFalse: [
			self position: 0@0.
			self extent: screenExtent].
	World doOneCycleNow.
	self startup.
	ScriptableScratchMorph initialize.
	Sensor useOSEvents: true.
! !

!ScratchFrameMorph methodsFor: 'other' stamp: 'ee 4/14/2008 15:01'!
updateMediaCategoryFor: anObject
	"Update the media viewer for the given object's media category. Do nothing if the media category of the given object is not being viewed."

	scriptsPane target = anObject ifTrue: [
		scriptsPane categoryChanged: 'Sounds'.
		scriptsPane categoryChanged: 'Costumes'].
	viewerPane target = anObject ifTrue: [
		viewerPane categoryChanged: 'Sound'].
! !

!ScratchFrameMorph methodsFor: 'other'!
view: aMorph tab: t category: c
	"Add given morph to the work pane and view it."

	scriptsPane target: aMorph.
	scriptsPane tabPane currentTab: t.
	tabPaneMorph currentTab: t.
	viewerPane
		target: aMorph;
		currentCategory: c.
! !


!ScratchFrameMorph methodsFor: 'startup' stamp: 'EMP 11/19/2015 14:54'!
clearFile: fName
	| dir dirNew |
	dir _ FileDirectory forFileName: fName.
	dir deleteFileNamed: fName.
	dirNew _ FileStream newFileNamed: fName.
	dirNew close! !

!ScratchFrameMorph methodsFor: 'startup' stamp: 'EMP 11/18/2015 14:25'!
processSettingsFile
	"Process settings from the Scratch.ini file."

	| lang k settings |
	self class setVisibleDrives: nil.
	lang _ nil.
	AllowSharing _ true.
	ScratchFileChooserDialog clearFolderCache. "clear homeDir and last folder cache"
	ScratchUploadProgressDialog initialize. "clear proxy settings"
	settings _ self readSettingsFile.
	ScratchSettings _ Dictionary new.
	settings associationsDo: [:assoc |
		k _ assoc key.
		k = 'language' ifTrue: [lang _ assoc value].
		k = 'home' ifTrue: [ScratchFileChooserDialog setHomeDir: assoc value].
		k = 'visibledrives' ifTrue: [self class setVisibleDrives: assoc value].
		k = 'share' ifTrue: [(assoc value) = '0' ifTrue: [AllowSharing _ false]].
		k = 'proxyserver' ifTrue: [ScratchUploadProgressDialog proxyServer: assoc value].
		k = 'proxyport' ifTrue: [ScratchUploadProgressDialog proxyPort: assoc value asNumberNoError].
		k = 'otherblocks' ifTrue: [ScratchSettings at: #enableOthers put: (assoc value asLowercase = 'true')].
		k = 'updatesEnabled' ifTrue: [ScratchSettings at: #enableUpdates put: (assoc value asLowercase = 'true')].
		].

	lang ifNil: [lang _ ScratchTranslator guessLanguage].
	self setLanguage: lang.
! !

!ScratchFrameMorph methodsFor: 'startup' stamp: 'jm 3/2/2009 12:56'!
readDefaultNotes
	"If there is a file named 'defaultNotes.txt' in the Scratch folder, read it in."

	| dir |
	DefaultNotes _ ''.
	dir _ FileDirectory default.
	(dir fileExists: 'defaultNotes.txt') ifTrue: [
		DefaultNotes _ (FileStream oldFileNamed: 'defaultNotes.txt') contentsOfEntireFile].
! !

!ScratchFrameMorph methodsFor: 'startup'!
readSettingsFile
	| t1 t2 t3 t4 t5 |
	t1 _ FileStream readOnlyFileNamedOrNil: self class settingsFileName.
	t1 ifNil: [^ Dictionary new].
	t2 _ Dictionary new.
	t1 contentsOfEntireFile lines do: 
		[:t6 | 
		t3 _ t6
					collect: [:t7 | t7 asciiValue < 32
							ifTrue: [Character space]
							ifFalse: [t7]].
		t4 _ t3 findTokens: '='.
		t5 _ t4 first withBlanksTrimmed asLowercase.
		t4 size = 2
			ifTrue: [t2 at: t5 put: t4 second withBlanksTrimmed]
			ifFalse: [t2 at: t5 put: '1']].
	^ t2! !

!ScratchFrameMorph methodsFor: 'startup' stamp: 'ee 8/11/2008 22:09'!
setDefaultSprite
	"Look for default sprite in Media directory. If none found, use the DefaultCatSprite"

	| d f data importedProject fName |

	DefaultSprite _ nil.

	"if dfault.sprite exists, use that"
	d _ ScratchFileChooserDialog getDefaultFolderForType: #costume.
	(d fileExists: 'default.sprite') ifTrue: [
		f _ (FileStream readOnlyFileNamed: (d fullNameFor: 'default.sprite')) binary.
		f ifNotNil: [
			data _ f contentsOfEntireFile.
			importedProject _ [self extractProjectFrom: data] ifError: [nil].
			importedProject ifNil: [^ self].
			importedProject submorphs do: [:m |
				(m isKindOf: ScratchSpriteMorph) ifTrue: [DefaultSprite _ m].
				^ self]]].

	"if default image exists, use the image and add 'pop' sound"
	#(gif png jpg bmp) do: [:e |
		fName _ 'default.', e.
		(d fileExists: fName) ifTrue: [
			DefaultSprite _ ScratchSpriteMorph new
				importMedia: (d fullNameFor: fName);
				addMediaItem: (SoundMedia new
					mediaName: 'pop' localized;
					sound: ScratchSpriteMorph popSound).
			^ self]].
! !

!ScratchFrameMorph methodsFor: 'startup' stamp: 'EMP 4/27/2016 15:52'!
startup

	| startupFileNames fileName arg presentationMode |
	Initializing _ true.
	HostSystemMenus startUp.
	HostSystemMenus menuBarControler reviseHostMenus.
	ScriptableScratchMorph randomInit.
	ScratchTranslator detectRenderPlugin.
	ScratchTranslator importLanguagesList.

	ScratchFrameMorph readShareServerEntry.

	self processSettingsFile.
	self readDefaultNotes.

	self updateProjectName.
	shuffledCostumeNames _ nil.
	author _ ''.
	loginName _ ''.
	loginPassword _ ''.
	justSaved _ true.
	presentationMode _ false.

	startupFileNames _ InputSensor startupFileNames asOrderedCollection.
	2 to: 10 do: [:i |
		arg _ Smalltalk getSystemAttribute: i.
		(arg notNil and: [arg size > 0]) ifTrue: [
			startupFileNames addLast: (ScratchPlugin primShortToLongPath: arg)]].
	startupFileNames do: [:n |
		(n asLowercase = 'presentation') ifTrue: [presentationMode _ true].
		(n asLowercase = 'fullscreen') ifTrue: [TakeOverScreen _ true]].

	TakeOverScreen ifTrue: [
		Smalltalk fullScreenMode: true.
		World restoreDisplay].
	self enterQuarterModeIfSmallScreen.
	fileName _ startupFileNames
		detect: [:fn |
			(fn asLowercase endsWith: '.sb') or: [(fn asLowercase endsWith: '.scratch') or: [(fn asLowercase endsWith: '.sb2') or: [fn asLowercase endsWith: '.zip']]]]
		ifNone: [nil].
	fileName ifNotNil: [
		presentationMode ifTrue: [Display fillColor: Color black].
		self openScratchProjectNamed: fileName.
		presentationMode ifTrue: [self enterPresentationMode; shoutGo].
		^ self].

	viewerPane currentCategory: 'motion'.
	self setDefaultSprite.
	self newScratchProject.
	fileName _ startupFileNames
		detect: [:fn | fn asLowercase endsWith: '.sprite']
		ifNone: [self askUpdates. ^ self].

	"open a .sprite file"
	workPane submorphs do: [:m | (m isKindOf: ScratchSpriteMorph) ifTrue: [m deleteSprite]].
	self importSpriteOrProject: fileName.
! !


!ScratchFrameMorph methodsFor: 'file read/write'!
clearStage

	self stopAll.
	projectDirectory _ ScratchFileChooserDialog getDefaultFolderForType: #project.
	projectName _ ''.
	projectInfo _ Dictionary new.

	self installNewProject: ScratchStageMorph new.
	self initializeWatcherPositions.
	justSaved _ true.
! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'jm 7/30/2008 17:12'!
extractInfoFrom: aByteArray
	"Answer a Scratch info dictionary from the given ByteArray. Answer an empty dictionary if it is an old project."

	| s version |
	s _ ReadStream on: aByteArray.
	version _ ObjStream scratchFileVersionFrom: (s next: 10) asString.
	(version = 1) | (version = 2)
		ifTrue: [
			s skip: 4.  "skip info header byte count"
			^ ObjStream new readObjFrom: s showProgress: false]
		ifFalse: [^ Dictionary new].

! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'jm 7/31/2008 20:03'!
extractProjectFrom: aByteArray
	"Answer a Scratch project (i.e. a ScratchStageMorph possibly containing sprites) from the given ByteArray. Answer nil if the project cannot be unpacked."

	| s version proj |
	s _ ReadStream on: aByteArray.
	version _ ObjStream scratchFileVersionFrom: (s next: 10) asString.
	version = 0 ifTrue: [
		s position: 0.
		proj _ ObjStream new readObjFrom: s showProgress: true].
	(version = 1) | (version = 2) ifTrue: [
		s skip: s uint32.  "skip header"
		proj _ ObjStream new readObjFrom: s showProgress: true].

	proj class = ScratchStageMorph ifFalse: [
		version > 2
			ifTrue: [self error: 'Project created by a later version of Scratch']
			ifFalse: [self error: 'Problem reading project.'].
		^ nil].

	ScriptableScratchMorph buildBlockSpecDictionary.
	proj allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [  "covert to new blocks"
			m convertStacksToTuples.
			m convertTuplesToStacks]].

	^ proj
! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'jm 5/8/2007 11:04'!
fixByteReversedSounds
	"See if the current project contains any byte-reversed copies of one of the standard sounds. If it does, byte-reverse all sounds. This is a workaround for a bug in Scratch 1.0 that did not upload sounds in big-endian order."

	| allSoundBuffers badMeowPrefix badPopPrefix foundBadSound |
	allSoundBuffers _ IdentitySet new.
	self allProjectMedia do: [:media |
		media isSound ifTrue: [
			allSoundBuffers add: media sound samples]].
	allSoundBuffers remove: ScriptableScratchMorph meowSound samples ifAbsent: [].
	allSoundBuffers remove: ScriptableScratchMorph popSound samples ifAbsent: [].

	badMeowPrefix _ ScriptableScratchMorph oldMeowPrefixReversed.
	badPopPrefix _ (ScriptableScratchMorph popSound samples copyFrom: 1 to: 100) reverseEndiannessStereo: false.
	foundBadSound _ false.
	allSoundBuffers do: [:buf |
		foundBadSound ifFalse: [
			((buf beginsWith: badMeowPrefix) or:
			 [buf beginsWith: badPopPrefix])
				ifTrue: [foundBadSound _ true]]].

	foundBadSound ifTrue: [
		allSoundBuffers do: [:buf | buf reverseEndiannessStereo: false]].
! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'ee 6/12/2008 12:01'!
importScratchProject
	"Allow the user to select a project to open, then merge that project's sprites with the
current project."

	| response |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	response _ ScratchFileChooserDialog
		chooseExistingFileType: #project
		extensions: #(scratch sb)
		title: 'Import Project'.
	response ifNil: [^ self].

	self importSpriteOrProject: response.
! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'EMP 10/3/2015 20:33'!
installNewProject: newWorkpane
	"Called after creating or reading a new project to clear the process scheduler, pick an object to view, clear the library thumbnails, and perform other housekeeping."

	| viewTarget sb |
	Initializing _ true.
	self stopAll.

	newWorkpane class = ScratchStageMorph
		ifFalse: [^ self inform: 'Incompatible Scratch file format'].

	"self exitScratchSession."
	workPane scratchServer ifNotNil: [
		workPane scratchServer clearCaches.
		workPane scratchServer stage: newWorkpane.
		newWorkpane scratchServer: workPane scratchServer].

	newWorkpane isQuarterSize: workPane isQuarterSize.
	newWorkpane bounds: workPane bounds.
	newWorkpane midiPortNum: workPane midiPortNum.
	workPane closeMIDI.

	"use the same sensorboard for the new project"
	sb _ workPane sensorBoard.
	newWorkpane submorphs do: [:m |
		(m isKindOf: SensorBoardMorph) ifTrue: [
			sb position: m position.
			newWorkpane replaceSubmorph: m by: sb.
			sb tryToOpenPort]].
	newWorkpane sensorBoard: sb.

	workPane owner replaceSubmorph: workPane by: newWorkpane.
	workPane _ newWorkpane.

	self fixByteReversedSounds.

	"fix sprite positions (backward compatability)"
	workPane submorphs do: [:m |
		(m isKindOf: WatcherMorph) ifTrue: [m convertFromOldWatcher].
		(m respondsTo: #costume) ifTrue: [
			m position: m position + m costume rotationCenter]. "fix up positions"
		m layoutChanged].
	workPane layoutChanged.

	"reset timer"
	ScriptableScratchMorph resetTimer.

	"pick an object view, or view the background if there is no other"
	viewTarget _ workPane.
	workPane submorphs do: [:m |
		(m respondsTo: #scripts) ifTrue: [
			m scripts size >= viewTarget scripts size ifTrue: [viewTarget _ m]]].
	viewTarget viewBlocksAndScripts.

	"populate the sprites list if it is empty (backward compatability)"
	workPane sprites isEmpty ifTrue: [
		workPane submorphs do: [:m |
			(m isKindOf: ScriptableScratchMorph) ifTrue: [workPane sprites addLast: m]]].

	tabPaneMorph currentTab: 'Scripts'.
	libraryPane clearLibrary.
	workPane clearPenTrails.
	self updateProjectName.
	ScratchProcess blockHighlightMSecs: 1.
	ScratchPrompterMorph clearLastAnswer.

	(projectInfo at: 'isHosting' ifAbsent: [false]) ifTrue: [
		self enableRemoteSensors].
	(projectInfo at: 'hasMotorBlocks' ifAbsent: [false]) ifTrue: [
		self showMotorBlocks].
	(projectInfo includesKey: 'penTrails') ifTrue: [
		workPane penTrailsForm: (projectInfo at: 'penTrails')].

	Clipboard _ nil.
	World cleanseStepList.  "make sure garbage collect can clean up the old sprites"
	Smalltalk garbageCollect.  "get rid of old sprite instances"

	self world ifNotNil: [self world startSteppingSubmorphsOf: self].
	ScriptableScratchMorph scratchOrigin: workPane center.
	justSaved _ true.
	Initializing _ false.! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'EMP 11/23/2015 16:07'!
nameFromFileName: fileName
	"Return the given Scratch file name without the trailing .sb or .scratch extension, if it has one. Ensure the the result is UTF8."

	| s |
	s _ fileName.
	(s asLowercase endsWith: '.scratch') ifTrue: [s _ s copyFrom: 1 to: s size - 8].
	(s asLowercase endsWith: '.sb') ifTrue: [s _ s copyFrom: 1 to: s size - 3].
	(s asLowercase endsWith: '.sb2') ifTrue: [s _ s copyFrom: 1 to: s size - 4].
	s isUnicode ifFalse: [s _ UTF8 withAll: s].

	^ s

! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'ee 6/12/2008 12:02'!
openScratchDroppedProjectNamed: fName
	"Open a Scratch project with the given name that was dropped on the Scratch window."

	| response |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	(justSaved or: [self projectIsEmpty]) ifFalse: [
		"ask the user if they want to save the current project"
		response _ DialogBoxMorph askWithCancel: 'Save the current project?'.
		response = #cancelled ifTrue: [^ self].
		response ifTrue: [self saveScratchProjectNoDialog]].

	self openScratchProjectNamed: fName.
! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'EMP 11/23/2015 19:20'!
openScratchProject
	"Allow the user to select a project to open, then open that project."

	| response newProj |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	(justSaved or: [self projectIsEmpty]) ifFalse: [
		"ask the user if they want to save the current project"
		response _ DialogBoxMorph askWithCancel: 'Save the current project?'.
		response = #cancelled ifTrue: [^ self].
		response ifTrue: [self saveScratchProjectNoDialog]].

	response _ ScratchFileChooserDialog openScratchFileFor: self.
	response = #cancelled ifTrue: [^ self].

	(response isKindOf: String) ifTrue: [  "read the contents of a local file"
		^ self openScratchProjectNamed: response].

	(response isKindOf: ByteArray) ifTrue: [
		(ZipArchive isZipArchive: response) ifTrue: [^ self openScratchTwoProjectNamed: response].
		[projectInfo _ self extractInfoFrom: response] ifError: [projectInfo _ Dictionary new].
		[newProj _ self extractProjectFrom: response] ifError: [^ self].
		self installNewProject: newProj.
		projectDirectory _ ScratchFileChooserDialog getDefaultFolderForType: #project].
! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'EMP 11/23/2015 19:15'!
saveScratchProject

	| fName result |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	fName _ ScratchFileChooserDialog saveScratchFileFor: self.
	(fName size = 0 or: [fName = #cancelled]) ifTrue: [^ self].

	[(result _ ScratchFileChooserDialog confirmFileOverwriteIfExisting: fName) = false] whileTrue: [
		fName _ ScratchFileChooserDialog saveScratchFileFor: self.
		(fName size = 0 or: [fName = #cancelled]) ifTrue: [^ self]].
	(result = #cancelled) ifTrue: [^ self].

	self updateLastHistoryEntryIfNeeded.

	fName _ (self nameFromFileName: fName), '.sb2'.
	projectDirectory _ FileDirectory on: (FileDirectory dirPathFor: fName).
	projectName _ FileDirectory localNameFor: fName.

	projectInfo at: 'author' put: author.
	self updateHistoryProjectName: projectName op: 'save'.
	self writeScratchProject.
! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'EMP 11/23/2015 19:15'!
saveScratchProjectNoDialog

	| fName dir |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].

	projectName ifNil: [projectName _ ''].
	fName _ self nameFromFileName: projectName.

	dir _ ScratchFileChooserDialog getLastFolderForType: #project.
	(fName size = 0 | (dir fileExists: fName , '.sb2') not) ifTrue: [^ self saveScratchProject].
	ScratchFileChooserDialog lastFolderIsSampleProjectsFolder ifTrue:  [^ self saveScratchProject].

	self updateLastHistoryEntryIfNeeded.

	projectName _ FileDirectory localNameFor: (fName, '.sb2').  "ignore path, if any; save in the original project directory"
	projectDirectory _ dir.

	self updateHistoryProjectName: projectName op: 'save'.
	self writeScratchProject.
! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'jm 5/11/2005 11:56'!
storeProjectInfoOn: aBinaryStream

	| s |
	projectInfo at: 'thumbnail' put: workPane thumbnailForm.

	s _ WriteStream on: (ByteArray new: 100000).
	ObjStream new storeObj: projectInfo on: s.

	aBinaryStream uint32: s size.
	aBinaryStream nextPutAll: s contents.
! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'jm 6/2/2009 18:59'!
updateHistoryProjectName: projName op: operation
	"The given user is about to save or upload a project with the given name. Update the project history. operation is a string specifying the operation."

	| timestamp tab history platform osVersion |
	projectInfo removeKey: 'organization' ifAbsent: [].	"obsolete"
	projectInfo at: 'scratch-version' put: Version.

	timestamp _ (Date today printFormat: #(3 2 1 $- 1 1)), ' ', Time now print24.
	tab _ String tab.

	history _ projectInfo at: 'history' ifAbsent: [''].
	history _ history, timestamp, tab.
	history _ history, operation, tab, (self nameFromFileName: projName), tab, loginName, tab, author.
	history _ history, String cr.
	projectInfo at: 'history' put: history.

	"record other data"
	projectInfo at: 'scratch-version' put: Version.
	projectInfo at: 'language' put: ScratchTranslator currentLanguage.

	platform _ Smalltalk platformName.
	platform ifNil: [platform _ 'unknown'].
	'linux' = platform ifTrue: [
		Display extent = (1200@900) ifTrue: [platform _ 'XO']].
	projectInfo at: 'platform' put: platform.

	osVersion _ Smalltalk osVersion.
	osVersion ifNil: [osVersion _ 'unknown'].
	projectInfo at: 'os-version' put: osVersion.

	(workPane scratchServer notNil and:
	 [workPane scratchServer isHosting])
		ifTrue: [projectInfo at: 'isHosting' put: true]
		ifFalse: [projectInfo removeKey: 'isHosting' ifAbsent: []].

	(self allBlocksString includesSubString: 'motor')
		ifTrue: [projectInfo at: 'hasMotorBlocks' put: true]
		ifFalse: [projectInfo removeKey: 'hasMotorBlocks' ifAbsent: []].

	workPane penTrailsForm
		ifNil: [projectInfo removeKey: 'penTrails' ifAbsent: []]
		ifNotNil: [projectInfo at: 'penTrails' put: workPane penTrailsForm].

! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'jm 3/28/2007 12:43'!
updateLastHistoryEntryIfNeeded
	"If the the last entry in this project's history is an old-sytle entry (i.e. one that does not include the project name and author) update it."

	| lines lastLine oldAuthor tab s |
	lines _ (projectInfo at: 'history' ifAbsent: ['']) lines.
	lines size = 0 ifTrue: [^ self].
	lastLine _ lines at: lines size.
	(lastLine includes: Character tab) ifTrue: [^ self].  "last line is already a new-style entry"

	oldAuthor _ projectInfo at: 'author' ifAbsent: [''].
	tab _ String tab.
	lastLine _ lastLine, tab, 'old', tab, projectName, tab, "blank scratchr name" tab, oldAuthor.
	lines at: lines size put: lastLine.

	s _ WriteStream on: (String new: 1000).
	lines do: [:entry | s nextPutAll: entry; cr].
	projectInfo at: 'history' put: s contents.
! !

!ScratchFrameMorph methodsFor: 'file read/write' stamp: 'EMP 10/3/2015 16:17'!
writeScratchProject
	"Write this Scratch project to the file named projectFile in the project directory. Called by saveScratchProject."

	| oldScriptsTarget oldTab oldViewerCategory oldPosition saveError out |
	self stopAll.
	self world ifNotNil: [self world activeHand newKeyboardFocus: nil].  "terminates active editor"

	"share duplicate sounds and images"
	self canonicalizeSoundsBits: nil saveOriginal: false.
	self canonicalizeImagesQuality: nil saveOriginal: false.

	oldScriptsTarget _ scriptsPane target.
	oldTab _ scriptsPane tabPane currentTab.
	oldViewerCategory _ viewerPane currentCategory.
	scriptsPane target: nil.

	workPane updateSpritesList.
	oldPosition _ workPane position.
	workPane delete; position: 0@0.
	self updatePenPositions.

	workPane sprites do: [:m | (m isClone) ifTrue: [m delete]].

	ScriptableScratchMorph buildBlockSpecDictionary.
	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m blocksBin allMorphsDo: [:b |
				(b isKindOf: BlockMorph) ifTrue: [b stop]].
			m convertStacksToTuples]].

	saveError _ nil.
	[	out _ FileStream newFileNamed: (projectDirectory unusedNameStartingWith: 'tmp').
		out
			ifNil: [saveError _ 'Folder may be locked or read-only']
			ifNotNil: [
				out binary.
				out nextPutAll: 'ScratchV02' asByteArray.
				self storeProjectInfoOn: out.
				ObjStream new storeObj: workPane on: out.
				out close].
	] ifError: [:err :rcvr |
		out ifNotNil: [
			[	out close.
				projectDirectory deleteFileNamed: out localName.
			] ifError: []].  "clean up, ignoring any errors"
		saveError _ err].

	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m convertTuplesToStacks]].

	self addMorph: (workPane position: oldPosition).
	oldScriptsTarget ifNil: [oldScriptsTarget _ workPane].
	oldScriptsTarget viewBlocksAndScripts.
	scriptsPane tabPane currentTab: oldTab.
	tabPaneMorph currentTab: oldTab.
	viewerPane currentCategory: oldViewerCategory.
	self updatePenPositions.

	saveError
		ifNil: [
			justSaved _ true.
			self updateProjectName.
			projectDirectory deleteFileNamed: projectName.
			[projectDirectory rename: out localName toBe: projectName]
				ifError: [^ self inform: 'Save failed' withDetails: 'Is the folder read-only?' localized].
			projectDirectory setMacFileNamed: projectName type: 'STsb' creator: 'MITS']
		ifNotNil: [
			projectName _ ''.
			self inform: 'Save failed' withDetails: saveError].
! !

!ScratchFrameMorph methodsFor: 'file read/write'!
writeScratchProjectOld
	"Obsolete!! Uses old format!! Write this Scratch project to the file named projectFile in the project directory. Called by saveScratchProject."

	| oldScriptsTarget oldTab oldViewerCategory oldPosition saveError out |
	self world ifNotNil: [self world activeHand newKeyboardFocus: nil].  "terminates active editor"
	self stopAll.

	(projectDirectory isKindOf: String) ifTrue: [
		projectDirectory _ FileDirectory on: projectDirectory].
	((FileDirectory default directoryExists: projectDirectory pathName) or: 
		[FileDirectory root directoryNames includes: projectDirectory pathName]) ifFalse: [
			projectDirectory _ FileDirectory default].

	oldScriptsTarget _ scriptsPane target.
	oldTab _ scriptsPane tabPane currentTab.
	oldViewerCategory _ viewerPane currentCategory.
	scriptsPane target: nil.

	oldPosition _ workPane position.
	workPane delete; position: 0@0.

	ScriptableScratchMorph buildBlockSpecDictionary.
	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m blocksBin allMorphsDo: [:b |
				(b isKindOf: BlockMorph) ifTrue: [b stop]].
			"xxx m convertStacksToTuples xxx"]].

	saveError _ nil.
	[	out _ (FileStream newFileNamed: (projectDirectory unusedNameStartingWith: 'tmp')) binary.
		ObjStream new storeObj: workPane on: out showProgress: true.
		out close.
	] ifError: [:err :rcvr | saveError _ err].

	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m convertTuplesToStacks]].

	workPane position: oldPosition.
	self addMorph: workPane.
	oldScriptsTarget ifNil: [oldScriptsTarget _ workPane].
	oldScriptsTarget viewBlocksAndScripts.
	scriptsPane tabPane currentTab: oldTab.
	tabPaneMorph currentTab: oldTab.
	viewerPane currentCategory: oldViewerCategory.
	self updateProjectName.

	saveError
		ifNil: [
			projectDirectory deleteFileNamed: projectName.
			projectDirectory rename: out localName toBe: projectName.
			projectDirectory setMacFileNamed: projectName type: 'STsb' creator: 'MITS']
		ifNotNil: [
			out close.
			projectDirectory deleteFileNamed: out localName.
			self inform: 'Save failed' withDetails: saveError].
! !


!ScratchFrameMorph methodsFor: 'uploading' stamp: 'jm 2/27/2009 11:31'!
allBlocksString

	| s stacks |
	s _ WriteStream on: (String new: 10000).
	((Array with: workPane), self scratchObjects) do: [:obj |
		stacks _ obj blocksBin submorphs select: [:m | m isKindOf: BlockMorph].
		stacks size > 0 ifTrue: [
			s nextPutAll: 'All stacks for ', obj objName, ':'; cr; cr.
			stacks do: [:blocks | self printTupleList: blocks tupleSequence on: s. s cr; cr].
			s cr]].

	^ s contents
! !

!ScratchFrameMorph methodsFor: 'uploading' stamp: 'jm 10/25/2007 14:35'!
compressMediaForUpload
	"Compress my media prior to uploading this project."

	self canonicalizeSoundsBits: 4 saveOriginal: true.
	self canonicalizeImagesQuality: 90 saveOriginal: true.

! !

!ScratchFrameMorph methodsFor: 'uploading' stamp: 'jm 10/23/2007 23:29'!
printTupleElement: el on: s

	(el isKindOf: Array) ifTrue: [self printTupleList: el on: s. ^ self].
	(el isKindOf: Symbol) ifTrue: [s nextPutAll: el. ^ self].
	(el isKindOf: String) ifTrue: [s nextPut: $". s nextPutAll: el. s nextPut: $". ^ self].
	(el isKindOf: ScriptableScratchMorph) ifTrue: [s nextPutAll: el objName. ^ self].
	s nextPutAll: el printString.
! !

!ScratchFrameMorph methodsFor: 'uploading' stamp: 'jm 10/23/2007 23:30'!
printTupleList: anArray on: s

	s nextPut: $(.
	1 to: anArray size do: [:i |
		self printTupleElement: (anArray at: i) on: s.
		i = anArray size ifFalse: [s space]].
	s nextPut: $).
! !

!ScratchFrameMorph methodsFor: 'uploading' stamp: 'jm 3/28/2007 11:29'!
removeLastHistoryEntry
	"Remove the last entry in the project history. This is done if an upload attempt fails or is cancelled."

	| lines s |
	lines _ (projectInfo at: 'history' ifAbsent: ['']) lines.
	lines size = 0 ifTrue: [^ self].

	lines _ lines copyFrom: 1 to: lines size - 1.

	s _ WriteStream on: (String new: 1000).
	lines do: [:entry | s nextPutAll: entry; cr].
	projectInfo at: 'history' put: s contents.
! !

!ScratchFrameMorph methodsFor: 'uploading' stamp: 'jm 10/18/2007 16:26'!
revertToUncompressedMedia
	"Revert to uncomprssed media after uploading this project."

	self allProjectMedia do: [:m | m revertToUncompressed].
! !

!ScratchFrameMorph methodsFor: 'uploading' stamp: 'jm 10/23/2007 23:34'!
scriptsStringForUpload

	| s scripts |
	s _ WriteStream on: (String new: 10000).
	((Array with: workPane), self scratchObjects) do: [:obj |
		scripts _ obj blocksBin submorphs select: [:m | m isKindOf: HatBlockMorph].
		scripts size > 0 ifTrue: [
			s nextPutAll: 'Scripts for ', obj objName, ':'; cr; cr.
			scripts do: [:hat | self printTupleList: hat tupleSequence on: s. s cr].
			s cr]].
	^ s contents
! !

!ScratchFrameMorph methodsFor: 'uploading'!
writeScratchProjectOn: aStream
	"Write this Scratch project in a serialized form on the given stream."

	| oldScriptsTarget oldTab oldViewerCategory oldPosition storeError |
	self stopAll.
	self world ifNotNil: [self world activeHand newKeyboardFocus: nil].  "terminates active editor"

	oldScriptsTarget _ scriptsPane target.
	oldTab _ scriptsPane tabPane currentTab.
	oldViewerCategory _ viewerPane currentCategory.
	scriptsPane target: nil.

	workPane updateSpritesList.
	oldPosition _ workPane position.
	workPane delete; position: 0@0.
	self updatePenPositions.

	ScriptableScratchMorph buildBlockSpecDictionary.
	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m blocksBin allMorphsDo: [:b |
				(b isKindOf: BlockMorph) ifTrue: [b stop]].
			m convertStacksToTuples]].

	storeError _ nil.
	[	aStream nextPutAll: 'ScratchV02' asByteArray.
		self storeProjectInfoOn: aStream.
		ObjStream new storeObj: workPane on: aStream.
	] ifError: [:err :rcvr | storeError _ err].

	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m convertTuplesToStacks]].

	self addMorph: (workPane position: oldPosition).
	oldScriptsTarget ifNil: [oldScriptsTarget _ workPane].
	oldScriptsTarget viewBlocksAndScripts.
	scriptsPane tabPane currentTab: oldTab.
	tabPaneMorph currentTab: oldTab.
	viewerPane currentCategory: oldViewerCategory.
	self updatePenPositions.

	storeError ifNotNil: [self error: storeError].
! !


!ScratchFrameMorph methodsFor: 'watchers' stamp: 'jm 5/6/2008 18:13'!
deleteWatchersForSprite: aSprite
	"The given sprite is being deleted. Delete all watchers associated with it."

	aSprite lists do: [:m | m delete].

	workPane submorphsDo: [:m |
		(m isKindOf: WatcherMorph) ifTrue: [
			(m target = aSprite) ifTrue: [m delete]]].

	watcherPositions keys do: [:k | 
		(k at: 1) = aSprite ifTrue: [watcherPositions removeKey: k]].
! !

!ScratchFrameMorph methodsFor: 'watchers' stamp: 'jm 12/1/2007 23:22'!
deleteWatchersForVar: varName ofSprite: aSprite
	"The given variable is being deleted. Delete all watchers associated with it."

	workPane submorphsDo: [:m |
		(m isKindOf: WatcherMorph) ifTrue: [
			((m target = aSprite) and:
			 [(m getSelector = #getVar:) and:
			 [m parameter = varName]])
				ifTrue: [m delete]]].
! !

!ScratchFrameMorph methodsFor: 'watchers' stamp: 'jm 8/25/2008 10:00'!
deletingWatcher
	"The given watcher is being removed from the stage; remember it's last position."

	| palette w |
	watcherPositions do: [:rec |
		rec first ifNotNil: [
			w _ rec first.
			w owner ifNil: [
				rec at: 1 put: nil.
				rec at: 2 put: w position - workPane position. "record old position and layout style"
				rec at: 3 put: w layoutStyle.
				rec at: 4 put: w sliderRange]]].

	palette _ viewerPane pageViewer contents.
	palette ifNotNil: [palette updateWatcherButtonsForFrame: self].
! !

!ScratchFrameMorph methodsFor: 'watchers' stamp: 'jm 8/25/2008 09:56'!
initializeWatcherPositions
	"If any watchers are on the stage, store their position. The dictionary, which is created lazily, is formatted in the following way:
	(<sprite or nil, depending on whether the block isSpriteSpecific>, <name of block>) ->
		(<watcher or nil, depending on whether the watcher is showing on stage>,
		 <position of watcher with top-left corner of stage = 0@0>
		 <layout style>
		 <slider range>)
	Or, more concisely: (sprite/nil,selectorAndArg)->(watcher/nil,position,style,range)."
 
	| p |
	watcherPositions _ Dictionary new.
	self scratchWatchers do: [:w |
		p _ w position - workPane position.
		watcherPositions
			at: {w getAssociatedSprite. w selectorAndArg}
			put: {w. p. w layoutStyle. w sliderRange}].
! !

!ScratchFrameMorph methodsFor: 'watchers' stamp: 'ee 7/11/2008 22:26'!
listWatchers
	"Answer a collection of all the list watchers in the work pane."

	^ self workPane submorphs select: [:m | m isKindOf: ScratchListMorph]
! !

!ScratchFrameMorph methodsFor: 'watchers' stamp: 'tis 7/31/2006 09:08'!
scratchWatchers
	"Answer a collection of all the scratch watchers in the work pane."

	^ self workPane submorphs select: [:m | m isKindOf: WatcherMorph]
! !

!ScratchFrameMorph methodsFor: 'watchers' stamp: 'EMP 12/12/2015 12:23'!
showWatcher: watcher pos: wPos
	"Show the given watcher. Reuse it's old position if it was showing before. Otherwise, find a new position for it."

	| rec style range |
	rec _ watcherPositions
		at: {watcher getAssociatedSprite. watcher selectorAndArg}
		ifAbsent: [nil].
	rec
		ifNil: [
			watcher position: wPos.
			style _ #small.
			range _ watcher sliderRange]
		ifNotNil: [
			watcher position: wPos.
			style _ rec third.
			range _ rec fourth].

	watcherPositions
		at: {watcher getAssociatedSprite. watcher selectorAndArg}
		put: {watcher. (watcher position - workPane position). style. range}.

	watcher sliderRange: range.
	watcher layoutStyle: style.
	watcher updateTargetName.
	workPane addMorph: watcher.
	watcher world ifNotNil: [watcher world startSteppingSubmorphsOf: watcher].

! !

!ScratchFrameMorph methodsFor: 'watchers' stamp: 'ee 6/28/2008 15:27'!
unusedPositionForWatcher
	"Return an unused watcher position on the stage."

	| watchers positions rowH x y newX |
	watchers _ (watcherPositions collect: [:r | r first]) select: [:w | w notNil].
	positions _ watchers collect: [:w | w position].

	(watchers size > 0)
		ifTrue: [rowH _ (watchers at: 1) height]
		ifFalse: [rowH _ 25].
	x _ workPane left + 10.
	y _ workPane top + 10.
	[positions includes: (x@y)] whileTrue: [
		y _ y + rowH.
		(y > (workPane bottom - rowH)) ifTrue: [  "start a new column"
			newX _ 0.
			watchers do: [:w |
				w left < (x + 20) ifTrue: [newX _ newX max: w right + 4]].
			newX > (workPane right - 20) ifTrue: [
				^ ((10 to: 400) atRandom) @ ((10 to: 330) atRandom)].  "no free location"
			x _ newX.
			y _ workPane top + 10]].

	^ x@y
! !

!ScratchFrameMorph methodsFor: 'watchers' stamp: 'jm 11/30/2007 19:35'!
watcherForBlock: aBlockMorph
	"Answer a watcher for the given block if there is one currently showing on the stage."

	| pair |
	pair _ watcherPositions
		at: {aBlockMorph getAssociatedSprite. aBlockMorph selectorAndArg}
		ifAbsent: [^ nil].

	^ pair first

! !

!ScratchFrameMorph methodsFor: 'watchers' stamp: 'jm 5/6/2008 17:17'!
watcherShowingFor: sprite selectorAndArg: selectorAndArg
	"Answer true if a watcher for the given sprite, selector, and argument is currently showing on the stage."

	| sel arg listM pair |
	sel _ selectorAndArg first.
	arg _ selectorAndArg second.
	#contentsOfList: = sel ifTrue: [
		listM _ sprite lists at: arg ifAbsent: [^ false].
		^ listM owner notNil].

	pair _ watcherPositions at: {sprite. selectorAndArg} ifAbsent: [^ false].
	pair first ifNotNil: [
		pair first owner ifNil: [pair at: 1 put: nil]].
	^ pair first notNil
! !


!ScratchFrameMorph methodsFor: 'tools (no longer used)' stamp: 'jm 2/13/2009 15:26'!
copyTool

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ self beep].
	hand _ self world activeHand.
	hand toolType: 'CopyTool'.

	cursorForm _ ScratchFrameMorph skinAt: #copyCursor.
	offset _ 8@13.

	ScratchFrameMorph isXO ifTrue: [
		cursorForm _ cursorForm magnifyBy: 1.5.
		offset _ (offset * 1.5) rounded].

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.
! !

!ScratchFrameMorph methodsFor: 'tools (no longer used)' stamp: 'jm 2/13/2009 15:26'!
cutTool

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ self beep].
	hand _ self world activeHand.
	hand toolType: 'CutTool'.

	cursorForm _ ScratchFrameMorph skinAt: #cutCursor.
	offset _ 8@8.

	ScratchFrameMorph isXO ifTrue: [
		cursorForm _ cursorForm magnifyBy: 1.5.
		offset _ (offset * 1.5) rounded].

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.
! !

!ScratchFrameMorph methodsFor: 'tools (no longer used)' stamp: 'EMP 11/16/2015 15:36'!
helpTool

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ self beep].
	hand _ self world activeHand.
	hand toolType: 'HelpTool'.

	cursorForm _ ScratchFrameMorph skinAt: #helpCursor.
	offset _ 9@9.

	ScratchFrameMorph isXO ifTrue: [
		cursorForm _ cursorForm magnifyBy: 1.5.
		offset _ (offset * 1.5) rounded].

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.
! !

!ScratchFrameMorph methodsFor: 'tools (no longer used)' stamp: 'jm 2/24/2004 18:58'!
normalTool

	self paintingInProgress ifTrue: [^ self beep].
	self world activeHand toolType: nil.
! !

!ScratchFrameMorph methodsFor: 'tools (no longer used)' stamp: 'EMP 4/27/2016 12:45'!
shoutGo
	self stopAll.
	workPane broadcastEvent: ScratchStartClickEvent new.
	flagButton on.
	World displayWorldSafely.
	World cycleWhileWaitingMSecs: 20 doInput: true doSteps: true! !

!ScratchFrameMorph methodsFor: 'tools (no longer used)' stamp: 'jm 1/23/2007 12:51'!
undoTool

	| m newOwner oldName |
	self paintingInProgress ifTrue: [^ self beep].
	Clipboard ifNil: [^ self beep].
	self activeHand toolType: nil.
	m _ Clipboard fullCopy.
	"Reset clipboard to empty since an undo just happened"
	
	(m isKindOf: BlockMorph) ifTrue: [
		newOwner _ viewerPane target.
		newOwner ifNotNil: [m newScriptOwner: newOwner].
		(viewerPane currentCategory = 'variables') ifTrue: [
			"update 'variables' category if it is showing"
			viewerPane currentCategory: 'variables']].

	(m isKindOf: ScratchSpriteMorph) ifTrue: [  "sprite; add to stage"
		m filterReset; show.
		m objName: Clipboard objName.
		Clipboard _ nil.
		oldName _ m objName.
		self addAndView: m.
		m objName: oldName.
		^ self].

	"blocks or anything else: attach to hand"
	self activeHand attachMorph: m.
	Clipboard _ nil.
! !

!ScratchFrameMorph methodsFor: 'tools (no longer used)' stamp: 'jm 2/13/2009 15:26'!
zoomInTool

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ self beep].
	hand _ self world activeHand.
	hand toolType: 'ZoomInTool'.

	cursorForm _ ScratchFrameMorph skinAt: #zoomInCursor.
	offset _ 8@8.

	ScratchFrameMorph isXO ifTrue: [
		cursorForm _ cursorForm magnifyBy: 1.5.
		offset _ (offset * 1.5) rounded].

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.
! !

!ScratchFrameMorph methodsFor: 'tools (no longer used)' stamp: 'jm 2/13/2009 15:26'!
zoomOutTool

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ self beep].
	hand _ self world activeHand.
	hand toolType: 'ZoomOutTool'.

	cursorForm _ ScratchFrameMorph skinAt: #zoomOutCursor.
	offset _ 8@8.

	ScratchFrameMorph isXO ifTrue: [
		cursorForm _ cursorForm magnifyBy: 1.5.
		offset _ (offset * 1.5) rounded].

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.

! !


!ScratchFrameMorph methodsFor: 'private' stamp: 'EMP 2/11/2016 14:25'!
bumpMajor
	| t1 |
	t1 := Version asString findVersionNumber.
	t1 last isDigit
		ifTrue: [Version := 'v' , (t1 asNumberNoError floor + 1) asString]
		ifFalse: [Version := 'v' , (t1 leadingDigits asNumberNoError floor + 1) asString].
	DialogBoxMorph inform: Version! !

!ScratchFrameMorph methodsFor: 'private' stamp: 'EMP 2/11/2016 14:25'!
bumpMinor
	| t1 |
	t1 := Version asString findVersionNumber.
	t1 last isDigit
		ifTrue: [Version := 'v' , ((t1 asNumberNoError truncated + ((t1 asNumberNoError fractionPart * 10 + 1) rounded / 10) asFloat asString) asString)]
		ifFalse: [Version := 'v' , ((t1 leadingDigits asNumberNoError truncated + ((t1 asNumberNoError fractionPart * 10 + 1) rounded / 10) asFloat asString) asString)].
	DialogBoxMorph inform: Version! !

!ScratchFrameMorph methodsFor: 'private' stamp: 'EMP 2/11/2016 14:28'!
bumpRevision
	| t1 |
	t1 := Version asString findVersionNumber.
	t1 last isDigit
		ifTrue: [Version := ' v' , t1 , 'a']
		ifFalse: [Version := 'v' , (t1 leadingDigits
							, (Utilities numbersToLetters: (Utilities lettersToNumbers: (t1 charsAfterLastDigits))
										+ 1))].
	DialogBoxMorph inform: Version! !

!ScratchFrameMorph methodsFor: 'private' stamp: 'jm 4/22/2009 09:37'!
enterQuarterModeIfSmallScreen

	(Display width >= 980) & (Display height >= 555) ifTrue: [^ self].
	viewMode = #normal ifTrue: [self enterQuarterMode].
! !

!ScratchFrameMorph methodsFor: 'private' stamp: 'ee 2/3/2009 13:26'!
fixProjectTitleMorphLayout
 
	| s truncated eWidth w |

	projectName ifNotNil: [
		s _  (self nameFromFileName: projectName).
		"trim project name to fit, if necessary"
		truncated _ false.
		eWidth _ (ScratchTranslator stringExtent: '...' font: projectTitleMorph font) x.
		w _ titlePane width - 100 - eWidth.
		[((ScratchTranslator stringExtent: s font: projectTitleMorph font) x) > w] whileTrue: [
			truncated _ true.
			s _ s copyFrom: 1 to: s size - 1].
		truncated ifTrue: [s _ s, '...'].
		projectTitleMorph contents: s].
! !

!ScratchFrameMorph methodsFor: 'private'!
nextSurpriseCostumeName
	| t1 t2 |
	(shuffledCostumeNames isNil or: [shuffledCostumeNames size = 0])
		ifTrue: 
			[shuffledCostumeNames _ OrderedCollection new: 1000.
			t1 _ ScratchFileChooserDialog getDefaultFolderForType: #costume.
			t1
				allFileNamesDo: [:t3 | (t3 includesSubString: 'Letters')
						ifFalse: 
							[t2 _ (FileDirectory extensionFor: t3) asLowercase.
							(t2 size > 0 and: [#(#gif #png #jpg ) includes: t2])
								ifTrue: [shuffledCostumeNames add: t3]]]].
	shuffledCostumeNames _ shuffledCostumeNames shuffledBy: Random new.
	shuffledCostumeNames size = 0 ifTrue: [^ nil].
	^ shuffledCostumeNames removeFirst! !

!ScratchFrameMorph methodsFor: 'private' stamp: 'jm 8/7/2008 13:32'!
projectIsEmpty
	"Answer true if the current project has no scripts, no variables, no special costumes or sounds, and at most a single sprite."

	| allScriptables defaultCostumes defaultSnds |
	"at most one sprite in workpane?"
	workPane submorphs size > 1 ifTrue: [^ false].
	workPane submorphs size = 1 ifTrue: [
		(workPane submorphs first isKindOf: ScratchSpriteMorph) ifFalse: [^ false]].

	allScriptables _ workPane submorphs copyWith: workPane.
	defaultCostumes _ Set
		with: ScriptableScratchMorph defaultBackgroundForm.
	defaultSnds _ Set
		with: ScriptableScratchMorph popSound
		with: ScriptableScratchMorph meowSound.

	ScratchFrameMorph defaultSprite ifNotNil: [
		ScratchFrameMorph defaultSprite media do: [:media |
			media isImage ifTrue: [defaultCostumes add: media form].
			media isSound ifTrue: [defaultSnds add: media sound]]].

	allScriptables do: [:m |
		m blocksBin submorphs size > 0 ifTrue: [^ false].  "any stacks?"
		m varNames size > 1 ifTrue: [^ false].  "any variables?"
		m media do: [:media |
			(media isImage and: [(defaultCostumes includes: media form) not]) ifTrue: [^ false].
			(media isSound and: [(defaultSnds includes: media sound) not]) ifTrue: [^ false]]].

	^ true
! !

!ScratchFrameMorph methodsFor: 'private' stamp: 'ee 11/4/2008 11:46'!
rebuildUIForNewLanguage
	"Rebuild my UI after the language or font has been changed."

	World fullRepaintNeeded.
	viewerPane rebuildCategorySelectors.
	self updatePanes.
	self
		view: scriptsPane target
		tab: scriptsPane tabPane currentTab
		category: viewerPane currentCategory.

! !

!ScratchFrameMorph methodsFor: 'private'!
recordLanguage: t1 
	| t2 t3 t4 t5 |
	t2 _ FileStream concreteStream new open: self class settingsFileName forWrite: true.
	t2 ifNil: [^ self].
	t3 _ t2 size.
	t4 _ (t2 next: t3) lines.
	t4 _ t4 reject: [:t6 | t6 asLowercase beginsWith: 'language='].
	t4 _ t4
				reject: 
					[:t6 | 
					t5 _ t6 asByteArray asSet.
					t5 size = 1 and: [t5 asArray first = 0]].
	t4 _ t4 copyWith: 'Language=' , t1.
	t2 position: 0.
	t4 do: [:t6 | t2 nextPutAll: t6 , String crlf].
	[t2 position < t3]
		whileTrue: [t2 nextPut: 0 asCharacter].
	t2 close! !

!ScratchFrameMorph methodsFor: 'private'!
setLanguage: aString
	"Set my language and update my blocks."

	| tempJustSaved |
	tempJustSaved _ justSaved.
	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m convertStacksToTuples]].

	ScratchTranslator setLanguage: (ScratchTranslator isoCodeForName: aString).
	viewerPane rebuildCategorySelectors.

	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m convertTuplesToStacks]].
	self updatePanes.
	self
		view: scriptsPane target
		tab: scriptsPane tabPane currentTab
		category: viewerPane currentCategory.
	justSaved _ tempJustSaved.
! !

!ScratchFrameMorph methodsFor: 'private'!
updatePanes

	| p |
	menuPanel delete.
	self createMenuPanel.

	toolbarPanel delete.
	self createToolbar.

	viewModeButtonsPanel delete.
	self createViewModeButtonsPanel.

	stageButtonsPanel delete.
	self createStageButtonsPanel.
	titlePane addMorph: stageButtonsPanel.

	scriptsPane tabPane delete.
	scriptsPane createTabPane.

	readoutPane delete.
	self createReadoutPane.

	workPane sensorBoard owner
		ifNil: [p _ nil]
		ifNotNil: [p _ workPane sensorBoard position].

	workPane sensorBoard addReadouts.
	p ifNotNil:[
		self showSensorBoard.
		workPane sensorBoard position: p].

	libraryPane clearLibrary.

	self scratchWatchers do: [:w | w languageChanged].
	self listWatchers do: [:w | w fixLayoutForNewLanguage].

	World startSteppingSubmorphsOf: self.
	self fixLayout.
	scriptsPane fixLayout.
	self updateViewModeButtons.
! !

!ScratchFrameMorph methodsFor: 'private' stamp: 'EMP 2/11/2016 14:21'!
updateProjectName
	"Update the project name display in the Scratch title bar."

	| s |
	projectName ifNil: [projectName _ ''].
	projectTitleMorph contents: (self nameFromFileName: projectName).

	projectTitleMorph contents size > 0
		ifTrue: [s _ projectTitleMorph contents, '- Whiskers ', Version]
		ifFalse: [s _ 'Whiskers ', Version].
	ScratchPlugin primSetWindowTitle: s.

	self fixLayout.
! !


!ScratchFrameMorph methodsFor: 'Scratch 2.0 file format-Testing' stamp: 'EMP 2/25/2016 14:50'!
addSprite: array toStage: stageToAddTo directory: aFolderName
	| currentSprite theDictionary currentSound |

	"Need to implement the following from the dicitonary: indexInLibrary, scratchX, scratchY, visible.
	base at: 'scratchX'. base at: 'scratchY'. ((base at: 'scale') * 100). base at: 'rotationStyle'. (base at: 'scripts' ifAbsent: [nil]
	"

	theDictionary _ array second.

	currentSprite _ array first.
	currentSprite setVarDict: (self convertTwoVarsFrom: (theDictionary at: 'variables' ifAbsent: [nil])).
	currentSprite setSizeTo: ((theDictionary at: 'scale') * 100).
	(theDictionary at: 'sounds' ifAbsent: [#()]) do: [:dict | 
	currentSound _ SampledSound fromFileNamed: (aFolderName, FileDirectory slash, ((FileDirectory on: aFolderName) findSoundFileThatContains: ((dict at: 'soundID') asString))).
	currentSprite addMediaItem: (SoundMedia new sound: currentSound; mediaName: (dict at: 'soundName'))].
	(theDictionary at: 'scripts' ifAbsent: [nil]) ifNotNil: [
	currentSprite blocksBin: (theDictionary at: 'scripts')].
	stageToAddTo addMorph: currentSprite.
	currentSprite convertTuplesToStacksTwo.
	currentSprite referencePosition: (theDictionary at: 'scratchX') @ (theDictionary at: 'scratchY')
! !

!ScratchFrameMorph methodsFor: 'Scratch 2.0 file format-Testing' stamp: 'EMP 2/24/2016 19:47'!
convertTwoListsFrom: lArray for: aScriptableScratchMorph
	| newDict currentList positionsDict |
	newDict _ Dictionary new.
	positionsDict _ Dictionary new.
	lArray ifNil: [^ {positionsDict. newDict}].
	lArray do: [:m | currentList _ ScratchListMorph new listName: (m at: 'listName') target: aScriptableScratchMorph.
	currentList newContents: (m at: 'contents').
	currentList extent: (m at: 'width') @ (m at: 'height').
	newDict at: (m at: 'listName') put: currentList.
	positionsDict at: currentList put: {(m at: 'x'). (m at: 'y'). (m at: 'visible')}. "There should be never of the same list"
	].
	^ {positionsDict. newDict}! !

!ScratchFrameMorph methodsFor: 'Scratch 2.0 file format-Testing' stamp: 'EMP 2/24/2016 19:13'!
convertTwoVarsFrom: vArray
	 | newDict |
	newDict _ Dictionary new.
	vArray ifNil: [^ newDict].
	vArray do: [:dict | newDict at: (dict at: 'name') put: (dict at: 'value')].
	^ newDict! !

!ScratchFrameMorph methodsFor: 'Scratch 2.0 file format-Testing' stamp: 'EMP 2/25/2016 14:52'!
extractProjectTwoDataFrom: aFolderName progressBar: progressDialog
	| file jsonParser newStage currentSound sprites watchers newSprite temp max theInterval oldForm newPenTrails listsDict |
	file _ FileStream readOnlyFileNamedOrNil: (aFolderName, FileDirectory slash, 'project.json').
	jsonParser _ Json readFrom: file.
	progressDialog percentDone: 51. "Continuing after the zip was extracted"
	"jsonParser inspect."
	"OK: The output of the JSON parser is in my class comment 'What does the 2.0 JSON structure look like'"
	(jsonParser isKindOf: Dictionary) ifFalse: [^ file close].
	
	"First, initialize the stage"
	newStage _ ScratchStageMorph new removeAllSounds.

	"Now add the variables, and their values (That way scripts can point to them without error). The watchers will be created after the sprites are added to the stage."
	newStage setVarDict: (self convertTwoVarsFrom: (jsonParser at: 'variables' ifAbsent: [nil])).
	
	"Same for the lists"
	listsDict _ (self convertTwoListsFrom: (jsonParser at: 'lists' ifAbsent: [nil]) for: newStage).
	newStage setListDict: (listsDict second).

	"The next few lines add all the backgrounds and their names to the stage. This is sort of a hack for now until I get SVGs working"
	newStage soleCostume: (ImageMedia new mediaName: ((jsonParser at: 'costumes') first at: 'costumeName'); form: (WarpBlt scale: (Form fromFileNamed: (aFolderName, FileDirectory slash, ((FileDirectory on: aFolderName) findImageFileThatContains: ((jsonParser at: 'costumes') first at: 'baseLayerID') asString))) by: ((1/2) @ (1/2)) smoothing: 2)).
	progressDialog percentDone: 52.
	max _ (jsonParser at: 'costumes') size.
	theInterval _ 2. "On the second costume"
	(jsonParser at: 'costumes') allButFirst do: [:m | 
	newStage addMediaItem: (ImageMedia new mediaName: (m at: 'costumeName'); form: (WarpBlt scale: (Form fromFileNamed: (aFolderName, FileDirectory slash, ((FileDirectory on: aFolderName) findImageFileThatContains: ((m at: 'baseLayerID') asString)))) by: ((1/2) @ (1/2)) smoothing: 2)).
	progressDialog percentDone: 52 + ((theInterval * 8) / max) rounded "Now, it's at 90%".
	theInterval _ theInterval + 1].
	"^^ What I'm doing is this: I'm finding the costume file, opening it, scaling it to half size, and loading it. It takes a bit of time, so I should optomize it somehow... Maybe a primitive???"
	newStage lookLikeIndex: (jsonParser at: 'currentCostumeIndex') + 1.
	oldForm _ (Form fromFileNamed: aFolderName , FileDirectory slash
					, ((FileDirectory on: aFolderName)
							findFileThatContains: (jsonParser at: 'penLayerID') asString)).
							
	newPenTrails _ ((Form extent: WorkpaneExtent depth: 32) fillWhite).
	oldForm displayInterpolatedIn: newPenTrails boundingBox on: newPenTrails.
    newStage penTrailsForm: newPenTrails. "fix incase of large/small pen forms -EMP 2/24/2016 13:41"
	progressDialog percentDone: 60.

	"Now I add the sounds, one by one, from the files that they come from"
	(jsonParser at: 'sounds' ifAbsent: [#()]) do: [:dict | 
	currentSound _ SampledSound fromFileNamed: (aFolderName, FileDirectory slash, ((FileDirectory on: aFolderName) findSoundFileThatContains: ((dict at: 'soundID') asString))).
	newStage addMediaItem: (SoundMedia new sound: currentSound; mediaName: (dict at: 'soundName'))].

	"now add the scripts to the stage"
	(jsonParser at: 'scripts' ifAbsent: [nil]) ifNotNil: [newStage blocksBin: (jsonParser at: 'scripts'). newStage convertTuplesToStacksTwo].


	"now create the sprites and watchers... I have to sort from watchers and sprites, add them to an array with their positions and the morph that is created, and send them to installNewProjectFromArray: with an array full of the following: [[sprite, x, y], [watcher, x, y], etc...]"

	temp _ (jsonParser at: 'children' ifAbsent: [nil]).
	temp ifNotNil: [sprites _ temp select: [:m | m includesKey: 'isDraggable' "I don't think watchers can be draggable"]].
	temp _ (jsonParser at: 'children' ifAbsent: [nil]).
	temp ifNotNil: [watchers _ temp select: [:m | m includesKey: 'sliderMax']]. 

	"sprites inspect." "It works!!!!!!"
	"watchers inspect."
	"sprites first inspect."
	max _ sprites size.
	theInterval _ 1.
	sprites _ (sprites collect: [:base |
		"base inspect."
		newSprite _ ScratchSpriteMorph new.
		newSprite objName: (base at: 'objName').

		newSprite isHidden: (base at: 'visible') asBoolean not. "Visibility"
		newSprite heading: (base at: 'direction') asNumberNoError. "Direction"
		newSprite setRotStyle: (base at: 'rotationStyle') asSymbol. "Rotation style"
		newSprite draggable: (base at: 'isDraggable') asBoolean. "Draggable on website?"

		newSprite removeAllSounds.
		newSprite soleCostume: (ImageMedia new mediaName: ((base at: 'costumes') first at: 'costumeName'); form: (WarpBlt scale: (Form fromFileNamed: (aFolderName, FileDirectory slash, ((FileDirectory on: aFolderName) findImageFileThatContains: ((base at: 'costumes') first at: 'baseLayerID') asString))) by: ((1/((base at: 'costumes') first at: 'bitmapResolution')) @ (1/((base at: 'costumes') first at: 'bitmapResolution'))) smoothing: 2)).
	(base at: 'costumes') allButFirst do: [:m | 
	newSprite addMediaItem: (ImageMedia new mediaName: (m at: 'costumeName'); form: (WarpBlt scale: (Form fromFileNamed: (aFolderName, FileDirectory slash, ((FileDirectory on: aFolderName) findImageFileThatContains: ((m at: 'baseLayerID') asString)))) by: ((1/2) @ (1/2)) smoothing: 2))].
	newSprite lookLikeIndex: (base at: 'currentCostumeIndex') + 1.
	progressDialog percentDone: 65 + ((theInterval * 5) / max) rounded. "Stop at 70%"
	theInterval _ theInterval + 1.
	{newSprite. base}]).

	self installNewProject: newStage withSprites: sprites stageListsAndPositions: listsDict andWatchers: watchers progressDialog: progressDialog folderName: aFolderName.
	file close! !

!ScratchFrameMorph methodsFor: 'Scratch 2.0 file format-Testing' stamp: 'EMP 2/25/2016 14:48'!
installNewProject: newWorkpane withSprites: spriteArray stageListsAndPositions: stageListsAndPositions andWatchers: watchersArray progressDialog: progressDialog folderName: aFolderName
	"Called after reading a 2.0 project to clear the process scheduler, pick an object to view, clear the library thumbnails, and perform other housekeeping. Also has to fix ALL sprite positions."

	| viewTarget sb theInterval max spriteListsAndPositions easyAccessSpriteDictionary newWatcher |
	Initializing _ true.
	self stopAll.

	newWorkpane class = ScratchStageMorph
		ifFalse: [^ self inform: 'Incompatible Scratch file format'].

	"self exitScratchSession."
	workPane scratchServer ifNotNil: [
		workPane scratchServer clearCaches.
		workPane scratchServer stage: newWorkpane.
		newWorkpane scratchServer: workPane scratchServer].

	newWorkpane isQuarterSize: workPane isQuarterSize.
	newWorkpane bounds: workPane bounds.
	newWorkpane midiPortNum: workPane midiPortNum.
	workPane closeMIDI.

	"use the same sensorboard for the new project"
	sb _ workPane sensorBoard.
	newWorkpane submorphs do: [:m |
		(m isKindOf: SensorBoardMorph) ifTrue: [
			sb position: m position.
			newWorkpane replaceSubmorph: m by: sb.
			sb tryToOpenPort]].
	newWorkpane sensorBoard: sb.
	workPane owner replaceSubmorph: workPane by: newWorkpane.
	workPane _ newWorkpane.
	self fixLayout.
	World doOneCycleNoInput.
	"place the sprites in the workpane. the spriteArray variable consists of the following:
	[sprite, x position, y position, size, rotation style, scripts]
	First add the sprite, fix it's size, fix it's x and y position, and then initialize all the scripts."

	ScriptableScratchMorph scratchOrigin: workPane center.
	theInterval _ 1.
	max _ spriteArray size.
	easyAccessSpriteDictionary _ Dictionary new.
	spriteArray do: [:array | 
	self addSprite: array toStage: workPane directory: aFolderName.
	World doOneCycle.
	array first referencePosition: (array second at: 'scratchX') @ (array second at: 'scratchY').
	spriteListsAndPositions _ (self convertTwoListsFrom: (array second at: 'lists' ifAbsent: [nil]) for: (array first)).
	array first setListDict: spriteListsAndPositions second.
	spriteListsAndPositions first keysAndValuesDo: [:list :posAndShowing | list position: (workPane topLeft + (posAndShowing first @ posAndShowing second)).
posAndShowing third ifTrue: [workPane addMorph: list]].
	easyAccessSpriteDictionary at: (array first objName asString) put: (array first).
	progressDialog percentDone: ((theInterval * 30) / max) rounded + 70.
	].
	easyAccessSpriteDictionary at: 'Stage' put: workPane.

	stageListsAndPositions first keysAndValuesDo: [:list :posAndShowing | list position: (workPane topLeft + (posAndShowing first @ posAndShowing second)).
posAndShowing third ifTrue: [workPane addMorph: list]].	

	self fixByteReversedSounds.

	"fix sprite positions (backward compatability)"
	workPane submorphs do: [:m |
		(m isKindOf: WatcherMorph) ifTrue: [m convertFromOldWatcher].
"		(m respondsTo: #costume) ifTrue: [
			m position: m position + m costume rotationCenter]. fix up positions"
		m layoutChanged].
	workPane layoutChanged.

	"reset timer"
	ScriptableScratchMorph resetTimer.

	"pick an object view, or view the background if there is no other"
	viewTarget _ workPane.
	workPane submorphs do: [:m |
		(m respondsTo: #scripts) ifTrue: [
			m scripts size >= viewTarget scripts size ifTrue: [viewTarget _ m]]].
	viewTarget viewBlocksAndScripts.

	"populate the sprites list if it is empty (backward compatability)"
	workPane sprites isEmpty ifTrue: [
		workPane submorphs do: [:m |
			(m isKindOf: ScriptableScratchMorph) ifTrue: [workPane sprites addLast: m]]].

	tabPaneMorph currentTab: 'Scripts'.
	libraryPane clearLibrary.
	workPane clearPenTrails.
	self updateProjectName.
	ScratchProcess blockHighlightMSecs: 1.
	ScratchPrompterMorph clearLastAnswer.

	(projectInfo at: 'isHosting' ifAbsent: [false]) ifTrue: [
		self enableRemoteSensors].
	(projectInfo at: 'hasMotorBlocks' ifAbsent: [false]) ifTrue: [
		self showMotorBlocks].
	(projectInfo includesKey: 'penTrails') ifTrue: [
		workPane penTrailsForm: (projectInfo at: 'penTrails')].

	Clipboard _ nil.
	World cleanseStepList.  "make sure garbage collect can clean up the old sprites"
	Smalltalk garbageCollect.  "get rid of old sprite instances"

	self world ifNotNil: [self world startSteppingSubmorphsOf: self].
	ScriptableScratchMorph scratchOrigin: workPane center.

		watchersArray do: [:watcherDict | newWatcher _ WatcherMorph new setCategoryColor: (ScriptableScratchMorph tryExtractColorFrom: (watcherDict at: 'color')).
	newWatcher target: (easyAccessSpriteDictionary at: (watcherDict at: 'target')) selector: (watcherDict at: 'cmd') parameter: (watcherDict at: 'param').
	newWatcher min: (watcherDict at: 'min' ifAbsent: [0]) max: (watcherDict at: 'max' ifAbsent: [100]).

	((watcherDict at: 'mode') = 1) ifTrue: [nil] ifFalse: [((watcherDict at: 'mode') = 2) ifTrue: [newWatcher showLargeReadout] ifFalse: [newWatcher showSlider]].
	newWatcher delete. "is that the issue?"
	(watcherDict at: 'visible' ifAbsent: [false]) ifTrue: [self showWatcher: newWatcher pos: (((watcherDict at: 'x') @ (watcherDict at: 'y')) + workPane position)].
].

	justSaved _ true.
	Initializing _ false.! !

!ScratchFrameMorph methodsFor: 'Scratch 2.0 file format-Testing' stamp: 'EMP 2/25/2016 16:38'!
openScratchTwoProjectNamed: fName
	"ScratchFrameMorph allInstances first openScratchTwoProjectNamed: 'test.sb2'"
	| f fn zip tempDirName file progressDialog dir |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	
	progressDialog _ DialogBoxMorph new percentDone: 1; openInWorld; centerOnScreen.
	(fName isKindOf: ByteArray) ifFalse: [
	fn _ fName.
	f _ FileStream readOnlyFileNamedOrNil: fn.
 	f ifNil: ["try a different encoding, fixes a Firefox bug, -Jens"
		fn _ fName isoLatinToMac asUTF8.
		f _ FileStream readOnlyFileNamedOrNil: fn.
		f ifNil: [^ self inform: 'Could not read' withDetails: fName]]] ifTrue: [f _ fName].
	progressDialog percentDone: 3.

	(fillScreenFlag = true) ifTrue: [[
	(ZipArchive isZipArchive: f) ifFalse: [^ self inform: 'Could not read project; file may be damaged' withDetails: '(NotZipFile:', fName asString, ')'].
	zip _ (ZipArchive new) readFrom: f.
	self ifNotNil: [zip extractZipTo: (file _ FileDirectory on: (tempDirName _ ((FileStream readOnlyFileNamedOrNil: fn) directory unusedNameStartingWith: 'tmp'))) withDialog: progressDialog].
	self extractProjectTwoDataFrom: tempDirName progressBar: progressDialog.
	] ifError: [:err :rcvr | progressDialog delete. ^ self inform: 'Could not read project; file may be damaged' withDetails: '(', err, ')']] ifFalse: [(ZipArchive isZipArchive: f) ifFalse: [^ self inform: 'Could not read project; file may be damaged' withDetails: '(NotZipFile:', fName asString, ')'].
	zip _ (ZipArchive new) readFrom: f.
	self ifNotNil: [zip extractZipTo: (file _ FileDirectory on: (tempDirName _ ((FileStream readOnlyFileNamedOrNil: fn) directory unusedNameStartingWith: 'tmp'))) withDialog: progressDialog].
	self extractProjectTwoDataFrom: tempDirName progressBar: progressDialog.
	].
	progressDialog percentDone: 100. World doOneCycleNoInput. Delay waitMSecs: 100. "Force 100% flash"
	progressDialog delete.

	"Now we have to delete the directory. We must remove all the files (to fix a wierd bug) and then delete the directory itself"

	file deleteAllFiles.
	file containingDirectory deleteDirectory: (file localName).

	dir _ FileDirectory dirPathFor: fn.
	projectDirectory _ FileDirectory on: dir.
	ScratchFileChooserDialog setLastFolderTo: projectDirectory forType: #project.
	projectName _ FileDirectory localNameFor: fn.
	World restoreDisplay.
	viewerPane updateContents.
! !

!ScratchFrameMorph methodsFor: 'Scratch 2.0 file format-Testing' stamp: 'EMP 2/25/2016 14:18'!
showWatcher: watcher
	"Show the given watcher. Reuse it's old position if it was showing before. Otherwise, find a new position for it."

	| rec style range |
	rec _ watcherPositions
		at: {watcher getAssociatedSprite. watcher selectorAndArg}
		ifAbsent: [nil].
	rec
		ifNil: [
			watcher position: self unusedPositionForWatcher.
			style _ #small.
			range _ watcher sliderRange]
		ifNotNil: [
			watcher position: workPane position + rec second.
			style _ rec third.
			range _ rec fourth].

	watcherPositions
		at: {watcher getAssociatedSprite. watcher selectorAndArg}
		put: {watcher. (watcher position - workPane position). style. range}.

	watcher sliderRange: range.
	watcher layoutStyle: style.
	watcher updateTargetName.
	workPane addMorph: watcher.
	watcher world ifNotNil: [watcher world startSteppingSubmorphsOf: watcher].

! !


!ScratchFrameMorph methodsFor: 'version control' stamp: 'EMP 4/6/2016 12:20'!
versionControlExport
	"Outputs all classes that have changed since the project start date to a directory that should be managed by an external revision control system."

	| dir date |

	dir _ self class versionControlDirectory.
	date _ self class versionControlStartDate.
	
	dir fileOutClassesChangedSince: date.! !

!ScratchFrameMorph methodsFor: 'version control' stamp: 'EMP 4/6/2016 12:19'!
versionControlImport
	"Updates the classes in the Squeak VM by importing them from a 'Classes' directory that should be managed by your revision control system."

	self class versionControlDirectory fileInContents! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchFrameMorph class
	instanceVariableNames: ''!

!ScratchFrameMorph class methodsFor: 'class initialization' stamp: 'jm 4/13/2009 21:05'!
initialize
	"self initialize"

	Clipboard _ nil.
	WorkpaneExtent _ 480@360.
	UseErrorCatcher _ true.
	AllowSharing _ true.
	DefaultNotes _ ''.

	self initFonts.
! !


!ScratchFrameMorph class methodsFor: 'license'!
license
	^ '
Scratch 1.4 
Copyright (C) 2011 Massachusetts Institute of Technology

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

Contact Linux@scratch.mit.edu for more information.
'! !


!ScratchFrameMorph class methodsFor: 'scratch skin' stamp: 'EMP 3/22/2016 11:24'!
exportSkin
	"ScratchFrameMorph exportSkin"
	"Thanks, dreammod"
    | t2 t4 |
    t4 _ 0.
    t2 _ ScratchFileChooserDialog chooseFolder: FileDirectory default pathName.
    'Exporting Skin...' displayProgressAt: Display center from: 0 to: ScratchSkin size during: [:t3 |
    ScratchSkin keys do: [:t1 | t4 _ t4 + 1.
    t3 value: t4.
    GIFReadWriter putForm: (ScratchSkin at: t1)
            onFileNamed: t2 pathName , FileDirectory slash , t1 asString , '.gif']]! !

!ScratchFrameMorph class methodsFor: 'scratch skin' stamp: 'EMP 10/10/2015 17:00'!
getFont: aSymbol
	"Get a font for a given purpose (specified by aSymbol) based on the current font setting."
	aSymbol = #Label ifTrue: [^ (StrikeFont fontName: #VerdanaBold size: (self getBlockSize))].
	aSymbol = #Arg ifTrue: [^ (StrikeFont fontName: #Verdana size: (self getArgSize))].
	^ (self isXO
		ifTrue: [FontsXO at: aSymbol]
		ifFalse: [Fonts at: aSymbol])
! !

!ScratchFrameMorph class methodsFor: 'scratch skin' stamp: 'EMP 11/5/2015 14:08'!
helpSkinAt: aSymbolOrString

	^ self helpSkinAt: aSymbolOrString ifAbsent: [^ nil]
! !

!ScratchFrameMorph class methodsFor: 'scratch skin'!
helpSkinAt: aSymbolOrString ifAbsent: aBlock
	"Answer the skin image with the given name. In XO mode, first check to see if an entry appears in ScratchSkinXO. If so, use it. Otherwise, use the image from the normal skin dictionary."

	| k |
	k _ aSymbolOrString asSymbol.
	^ HelpSkin at: k ifAbsent: aBlock
! !

!ScratchFrameMorph class methodsFor: 'scratch skin' stamp: 'EMP 2/9/2016 16:18'!
initFonts
	"self initFonts"

	| fontSpecs fonts fontsXO |
	fontSpecs _ #(
		(Arg						Verdana		10	HelveticaMedium 14)
		(Label			VerdanaBoldNarrowSpace	10	Helvetica		18)
		(MenuTitle					VerdanaBold		11	ArialBold		12)
		(MenuItem 					Verdana		13 	Arial			14 )
		(Button						VerdanaBold		10	ArialBold		16)
		(Category					VerdanaBold		10	ArialBold		16)
		(Tab						VerdanaBold		11	ArialBold		16)
		(CommentBlock				Verdana		10	Verdana		14)
		(TalkBubble					VerdanaBold		12	VerdanaBold		18)
		(ToolTip						Verdana		13	ArialBold		16)
		(ReporterToolTip				Verdana		14	ArialBold		16)
		(XYReadout					Verdana		8	Arial			11)
		(XYReadoutBold				VerdanaBold		8	ArialBold		11)
		(CostumesPage				VerdanaBold		11	ArialBold		14)
		(SoundsPage					VerdanaBold		11	ArialBold		14)
		(ViewerPage				VerdanaBold		11	ArialBold		14)
		(UpdatingStringField			VerdanaBold		11	VerdanaBold		14)
		(Watcher					VerdanaBold		10	ArialBold		14)
		(WatcherLarge				VerdanaBold		14	VerdanaBold		14)

		(PaintUtilityButton			VerdanaBold		10	ArialBold		16)
		(PaintSetRotationCenter		VerdanaBold		11	ArialBold		14)

		"Library"
		(LibraryItemName			VerdanaBold		9	ArialBold		14)
		(LibraryItemInfo			Verdana		6	Verdana		10)
		(MediaItemInfo				Verdana		9	Arial			14)

		"Dialog Boxes"
		(DialogBoxTitle				VerdanaBold		14	VerdanaBold		16)
		(DialogBoxMessage			VerdanaBold		13	VerdanaBold		16)
		(DialogBoxButton			VerdanaBold		11	VerdanaBold		16)
		(ProjectNotes				Verdana		10	Verdana		12)
		(LinkMorphDefault			VerdanaBold		10	VerdanaBold		12)
		(ShareLink					VerdanaBold		13	VerdanaBold		12)
		(SoundRecorderButton		VerdanaBold		13	VerdanaBold		12)
		(SoundRecorderTimer		NewYorkBold	10	NewYorkBold	12)
		(StringDialogTypeIn			Verdana		12	Verdana		16)
		(NewVariableDialogBox		Verdana		11	Verdana		14)
		(AboutScratch				VerdanaBold		11	VerdanaBold		14)
		(UploadTagLabel				VerdanaBold		10	VerdanaBold		12)
		(UploadTag					Verdana		10	Verdana		12)
		(UploadDialogLabel			VerdanaBold		10	VerdanaBold		12)
		(UploadDialogContents		Verdana		10	Verdana		12)
		(UploadDialogComment		Verdana		10	Verdana		12)

		"File Choosers"
		"This is the for the folder shortcuts in the file dialog"
		(FolderShortcut				Verdana		11	Verdana		14)
		(FileChooserNewFileTitle		VerdanaBold		10	VerdanaBold		14)
		(FileChooserNewFilename		Verdana		10	Verdana		12)
		(FileChooserLabel			VerdanaBold		10	VerdanaBold		14)
		(FileChooserContents			Verdana		12	Verdana		12)
		(FileChooserComment			Verdana		10	Verdana		12)
		(FilePickerDirectoryName	VerdanaBold		9	VerdanaBold		12)
		(FilePickerEntry				Verdana		11	Verdana		13)
		(FilePickerEntryHighlighted	VerdanaBold		11	VerdanaBold		13)

		(FrameMorphProjectTitle		VerdanaBold		13	ArialBold		16)
	).

	fonts _ Dictionary new.
	fontsXO _ Dictionary new.
	fontSpecs do: [:r |
		fonts at: (r at: 1) put: (StrikeFont fontName: (r at: 2) size: (r at: 3)).
		fontsXO at: (r at: 1) put: (StrikeFont fontName: (r at: 4) size: (r at: 5))].
	Fonts _ fonts.
	FontsXO _ fontsXO.
! !

!ScratchFrameMorph class methodsFor: 'scratch skin' stamp: 'jm 4/10/2008 12:00'!
isXO
	"Return true if the current skin is XO."

	^ IsXO
! !

!ScratchFrameMorph class methodsFor: 'scratch skin' stamp: 'jm 4/10/2008 12:00'!
isXO: aBoolean
	"Set the current skin style to #XO if the argument is true, normal otherwise."
	"self isXO: true"
	"self isXO: false"

	IsXO _ aBoolean.

	"aBoolean ifTrue: [(Preferences setMenuFontTo: (StrikeFont fontName: #VerdanaBold size: 18))]
			ifFalse: [(Preferences restoreDefaultFonts)]." "annoying for development"
! !

!ScratchFrameMorph class methodsFor: 'scratch skin'!
readHelpSkinFrom: aDirectory
	"Read the Forms for my skin from the given directory and store them in myskin dictionary."
	"When in XO mode, entries in ScratchSkinXO override the corresponding entries in ScratchSkin."
	"self readHelpSkinFrom: (FileDirectory default directoryNamed: '/Help/en/')"

	| dict img i |
	dict _ Dictionary new.
	aDirectory fileNames do: [:fn |
		Cursor read showWhile: [
			img _ [Form fromFileNamed: (aDirectory fullNameFor: fn)] ifError: [nil]].
		img ifNotNil: [
			i _ fn findLast: [:c | c = $.].
			i = 0 ifFalse: [fn _ fn copyFrom: 1 to: i - 1].
			dict at: fn asSymbol put: img]].
	HelpSkin _ dict.

	img _ HelpSkin at: #scriptsPaneTexture ifAbsent: [nil].
	(img notNil and: [img depth ~= 32]) ifTrue: [
		HelpSkin at: #scriptsPaneTexture put: (img asFormOfDepth: 32)].
	^ HelpSkin! !

!ScratchFrameMorph class methodsFor: 'scratch skin' stamp: 'EMP 9/29/2015 14:35'!
readSkinFrom: aDirectory
	"Read the Forms for my skin from the given directory and store them in myskin dictionary."
	"When in XO mode, entries in ScratchSkinXO override the corresponding entries in ScratchSkin."
	"self readSkinFrom: (FileDirectory default directoryNamed: 'ScratchSkin')"

	| dict img i xoDict |
	dict _ Dictionary new.
	xoDict _ Dictionary new.
	aDirectory fileNames do: [:fn |
		Cursor read showWhile: [
			img _ [Form fromFileNamed: (aDirectory fullNameFor: fn)] ifError: [nil]].
		img ifNotNil: [
			i _ fn findLast: [:c | c = $.].
			i = 0 ifFalse: [fn _ fn copyFrom: 1 to: i - 1].
			(fn asLowercase endsWith: '_xo')
				ifTrue: [xoDict at: (fn copyFrom: 1 to: fn size - 3) asSymbol put: img]
				ifFalse: [dict at: fn asSymbol put: img]]].
	ScratchSkin _ dict.
	ScratchSkinXO _ xoDict.

	img _ ScratchSkin at: #scriptsPaneTexture ifAbsent: [nil].
	(img notNil and: [img depth ~= 32]) ifTrue: [
		ScratchSkin at: #scriptsPaneTexture put: (img asFormOfDepth: 32)].
! !

!ScratchFrameMorph class methodsFor: 'scratch skin' stamp: 'jm 4/10/2008 12:11'!
skinAt: aSymbolOrString

	^ self skinAt: aSymbolOrString ifAbsent: [ScratchSkin errorKeyNotFound]
! !

!ScratchFrameMorph class methodsFor: 'scratch skin' stamp: 'ee 12/4/2008 11:43'!
skinAt: aSymbolOrString ifAbsent: aBlock
	"Answer the skin image with the given name. In XO mode, first check to see if an entry appears in ScratchSkinXO. If so, use it. Otherwise, use the image from the normal skin dictionary."

	| k |
	k _ aSymbolOrString asSymbol.
	self isXO ifTrue: [
		k = #scriptsPaneTexture ifTrue: [^ aBlock value].
		(ScratchSkinXO includesKey: k) ifTrue: [^ ScratchSkinXO at: k]].

	^ ScratchSkin at: k ifAbsent: aBlock
! !

!ScratchFrameMorph class methodsFor: 'scratch skin' stamp: 'jm 12/8/2008 16:09'!
takeOverScreen: aBoolean
	"self takeOverScreen: true"
	"self takeOverScreen: false"

	TakeOverScreen _ aBoolean
! !


!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'EMP 11/16/2015 12:09'!
buttonLabel: aString selector: aSymbolOrNil
	"Answer a big button with the given label."

	| button |
	button _ ResizableToggleButton2 new
		offForm: (ScratchFrameMorph skinAt: #btn) onForm: (ScratchFrameMorph skinAt: #btnPressed) overForm: (ScratchFrameMorph skinAt: #btnPressed);
		label: aString font: (ScratchFrameMorph getFont: #Button);
		actionSelector: aSymbolOrNil.

	^ button
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 11/17/2008 17:21'!
cameraMode

	^ #normal
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'EMP 2/9/2016 16:19'!
checkBoxLabelled: label marked: checkedFlag width: buttonWidth
	| image t5 t6 t7 t8 |
	checkedFlag
		ifTrue: [t6 _ ScratchFrameMorph skinAt: #menuTick]
		ifFalse: [t6 _ ScratchFrameMorph skinAt: #menuBlank].
	image _ ImageMorph new form: t6.
	t8 _ ' ' , label localized, '  '.
	t5 _ StringMorph contents: t8 font: (ScratchFrameMorph getFont: #MenuItem).
	t7 _ Morph new color: Color transparent.
	t7 height: (image height max: t5 height).
	t7 width: (image width + t5 width max: buttonWidth).
	image left: t7 left.
	image top: t7 top + (t7 height - image height // 2).
	t5 left: image right.
	t5 top: t7 top + (t7 height - t5 height // 2).
	t7 addMorph: image.
	t7 addMorph: t5.
	^ t7 imageForm! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'EMP 2/9/2016 16:19'!
checkBoxLabelled: label marked: checkedFlag width: buttonWidth dark: darkFlag
	| image t5 t6 t7 t8 |
	checkedFlag
		ifTrue: [darkFlag ifTrue: [t6 _ ScratchFrameMorph skinAt: #menuTickDark] ifFalse: [t6 _ ScratchFrameMorph skinAt: #menuTick]]
		ifFalse: [t6 _ ScratchFrameMorph skinAt: #menuBlank].
	image _ ImageMorph new form: t6.
	t8 _ ' ' , label localized, '  '.
	t5 _ StringMorph contents: t8 font: (ScratchFrameMorph getFont: #MenuItem).
	t7 _ Morph new color: Color transparent.
	t7 height: (image height max: t5 height).
	t7 width: (image width + t5 width max: buttonWidth).
	image left: t7 left.
	image top: t7 top + (t7 height - image height // 2).
	t5 left: image right.
	t5 top: t7 top + (t7 height - t5 height // 2).
	t7 addMorph: image.
	t7 addMorph: t5.
	^ t7 imageForm! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 11/17/2008 17:23'!
colorToTrack

	^ Color red

! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'EMP 9/29/2015 14:34'!
defaultSprite
"Return the default sprite if one was set, or the cat otherwise"

	DefaultSprite
		ifNotNil: [^ DefaultSprite]
		ifNil: [^ ScratchSpriteMorph new
			addMediaItem: (ImageMedia new
				mediaName: ('costume' localized, '1');
				form: (ScratchFrameMorph skinAt: #defaultSpriteCostume));
	"		addMediaItem: (ImageMedia new
				mediaName: ('costume' localized, '2');
				form: (ScratchFrameMorph skinAt: #defaultSpriteCostume2));"
			addMediaItem: (SoundMedia new
				mediaName: 'meow' localized;
				sound: ScratchSpriteMorph meowSound);
			lookLike: ('costume' localized, '1')].
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 4/14/2008 17:57'!
palettePaneColor

	| c |
	c _ Color r: 124 g: 128 b: 131 range: 255.
	self isXO ifTrue: [c _ c mixed: 0.75 with: Color white].
	^ c
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 3/17/2007 11:43'!
parseDownloadDatabase: fileName
	"Parse the HTML file for the Scratch download database."
	"self parseDownloadDatabase: 'mlist.html'"
	"To list downloads by date:
		(db collect: [:r | r first upTo: Character space]) asBag sortedElements"

	| raw lines inTable s records r |
	raw _ (FileStream oldFileNamed: fileName) contentsOfEntireFile.
	lines _ OrderedCollection new.
	inTable _ false.
	raw lines do: [:ln |
		s _ ln withBlanksTrimmed.
		s = '</table>' ifTrue: [inTable _ false].
		inTable ifTrue: [lines addLast: s].
		s = '<table>' ifTrue: [inTable _ true]].

	records _ OrderedCollection new.
	lines _ ReadStream on: lines.
	[lines atEnd] whileFalse: [
		ln _ lines next.
		ln = '<tr>' ifTrue: [
			r _ self parseRecordFrom: lines.
			r size > 0 ifTrue: [records addLast: r asArray]]].

	^ records asArray

! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 1/21/2007 16:20'!
parseRecordFrom: lineStream
	"An HTML table record from the given stream of lines."

	| rec ln buf |
	rec _ OrderedCollection new.
	[true] whileTrue: [
		ln _ lineStream next.
		ln = '</tr>' ifTrue: [^ rec].
		(ln beginsWith: '<td>') ifTrue: [
			buf _ ln copyFrom: 5 to: ln size.
			[lineStream atEnd | (buf endsWith: '</td>')] whileFalse: [buf _ buf, ' ', lineStream next].
			buf _ buf copyFrom: 1 to: buf size - 5.
			rec addLast: buf]].
	^ rec
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'EMP 12/22/2015 11:10'!
patchWindowsVM: vmFileName quitMessage: aString
	"Modify the Squeak application (the .exe file) for Windows to display the given string when you quit. You must start with a copy of the original VM, not one that has already been modified. This file will be modified in place, so make sure you keep a copy of the original!! The string is truncated to 27 characters since it must fit into the space of the original quit message."
	"self patchWindowsVM: 'Scratch.exe' quitMessage: 'Want to quit Whiskers now?' size"

	| orig firstOrigByte replacement f found startPos |
	orig _ 'Quit Squeak without saving?' asByteArray.
	firstOrigByte _ orig first.

	replacement _ aString asByteArray copyFrom: 1 to: (aString size min: orig size).
	replacement size < orig size ifTrue: [  "pad with zeros to the same size as the original"
		replacement _ replacement, (ByteArray new: orig size - replacement size withAll: 0)].

	f _ (FileStream oldFileNamed: vmFileName) binary.

	found _ false.
	[f atEnd | found] whileFalse: [
		[f atEnd not and: [f next ~= firstOrigByte]] whileTrue.  "scan for first byte"
		startPos _ f position - 1.
		f position: startPos.
		found _ true.
		1 to: orig size do: [:i | f next = (orig at: i) ifFalse: [found _ false]]].

	found ifTrue: [  "over-write the original message with the replacement"
		f position: startPos.
		replacement do: [:byte | f nextPut: byte]].

	f position: f size.  "position to end of file to avoid possible file truncation"
	f close.

	found
		ifTrue: [self inform: 'New quit message installed']
		ifFalse: [self inform: 'Original quit message not found; no change made'].

! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'MD 2/12/2004 18:27'!
putInClipboard: anObject
	
	Clipboard _ anObject.! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 12/31/2006 18:38'!
quitFromMenu
	"The user is using the application menu to quit from Scratch. If there is an open Scratch window, ask the user about saving the project. Otherwise, confirm that the user really wants to quit."

	| scratchWindow |
	scratchWindow _ World submorphs detect: [:m | (m isKindOf: self)] ifNone: [nil].
	scratchWindow
		ifNil: [World hands first quitSession]
		ifNotNil: [scratchWindow quitScratch].
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'EMP 11/5/2015 14:38'!
readShareServerEntry
	"Check for a file containing a list of Scratch servers.
	If this file is found and it includes an entry labled '*share*' then make that entry the server and path for 'Share' uploads. 
	If this file includes an entry labeled *support* then make that entry the server and path for the 'Support' site link.
	This is meant to be done once when Scratch is first started. Other entries in this file used to appear as Scratch servers in the Scratch project open dialog."
	"self readShareServerEntry"

	| s entryList servers key shareExists |
	"set defaults in case there is no 'servers.txt' file"
	ShareServer _ 'scratch.mit.edu'.
	ShareServerPath _ '/services/upload'.
	SupportServer _ ShareServer.
	SupportServerPath _ '/support'.
	ScratchServers _ #(
		('LTC Scratch Server'		'ltc.smm.org'			'/scratch/')
		('MIT Scratch Server'		'web.media.mit.edu'		'/~jmaloney/mit_scratch/')
	).

	(FileDirectory default fileExists: 'servers.txt') ifFalse: [^ self].
	[s _ (FileStream readOnlyFileNamed: 'servers.txt') contentsOfEntireFile] ifError: [^ self].
	entryList _ HtmlChunker parseTabbedString: s.

	"collect Scratch servers for open dialog"
	servers _ entryList select: [:entry | (entry first beginsWith: '*share*') not].
	servers do: [:entry |
		entry size >= 3 ifTrue: [
			key _ entry first asLowercase.
			ScratchServers _ ScratchServers reject: [:e | e first asLowercase = key].
			ScratchServers _ ScratchServers copyWith: entry]].
	ScratchServers sort: [:e1 :e2 | (e1 first compare: e2 first) <= 2].

	shareExists _ true.
	"if there is a file *share* entry, it overrides the default Share server"
	entry _ entryList detect: [:e | (e first beginsWith: '*share*')] ifNone: [shareExists _ false].
	shareExists ifTrue: [
		entry size >= 3 ifTrue: [
			ShareServer _ entry at: 2.
			ShareServerPath _ entry at: 3]].

	"if there is a file *support* entry, it overrides the default Support server"
	entry _ entryList detect: [:e | (e first beginsWith: '*support*')] ifNone: [^ self].
	entry size >= 3 ifTrue: [
		SupportServer _ entry at: 2.
		SupportServerPath _ entry at: 3].
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 11/8/2006 18:09'!
scaledFormForPaintEditor: aForm
	"Answer either the given form or a copy of it scaled down to fit into the paint editor."
	"This method supports a quick fix to the following problem: When a big image is loaded onto a sprite and then edited in the image editor, (a) you cannot edit offscreen pixels and (b) if you click 'OK' to accept the edits, the image will be cropped. This fix resizes the loaded image to fit into paint editor canvas to avoid these problems. In the longer term, we should fix the paint editor to allow editing images larger than the canvas size."

	| maxExtent scale |
	maxExtent _ WorkpaneExtent.
	((aForm width <= maxExtent x) and:
	 [aForm height <= maxExtent y])
		ifTrue: [^ aForm].

	scale _ (maxExtent x / aForm width) min: (maxExtent y / aForm height).
	^ ScratchPlugin scale: aForm by: scale
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 12/31/2006 13:18'!
scratchServers

	^ ScratchServers
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 4/14/2008 17:39'!
scriptsPaneColor

	| c |
	c _ Color r: 124 g: 128 b: 131 range: 255.
	self isXO ifTrue: [c _ c mixed: 0.8 with: Color white].
	^ c
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 3/17/2009 22:02'!
setVisibleDrives: driveListString
	"Set my set of visible drives. If the argument is nil, then all drives are made visible."

	| in drive |
	VisibleDrives _ nil.
	driveListString ifNil: [^ self].

	VisibleDrives _ OrderedCollection new.
	in _ ReadStream on: driveListString.
	[in atEnd] whileFalse: [
		in skipSeparators.
		drive _ (in upTo: $,) withBlanksTrimmed.
		drive size > 0 ifTrue: [VisibleDrives addLast: drive asUppercase]].

	VisibleDrives size > 0
		ifTrue: [VisibleDrives _ VisibleDrives asArray]
		ifFalse: [VisibleDrives _ nil].
! !

!ScratchFrameMorph class methodsFor: 'utilities'!
settingsFileName
	| t1 |
	Smalltalk isUnix
		ifTrue: 
			[t1 _ ScratchPlugin primGetFolderPath: 1.
			^ t1 , '/.scratch.ini'].
	^ FileDirectory default fullPathFor: 'Scratch.ini'! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 10/11/2006 15:02'!
shareServer
	"Answer the name of the Scratch project sharing server."

	^ ShareServer
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'e 2/24/2009 15:57'!
supportServer
	"Answer the name of the Scratch support site server."

	^ SupportServer
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'e 2/24/2009 15:57'!
supportServerPath
	"Answer the path of the Scratch support site server."

	^ SupportServerPath
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 7/19/2004 20:20'!
useErrorCatcher

	^ UseErrorCatcher
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 8/12/2008 19:32'!
version

	^ Version
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'EMP 11/18/2015 12:33'!
version: aString
	"self version: '2.0SV (internal ', (Date today printFormat: #(1 2 3 $- 2 2)), ')'"
	"self version: '2.0SV (', (Date today printFormat: #(1 2 3 $- 2 2)), ')'"

	Version _ aString.
	VersionDate _ (Date today printFormat: #(2 1 3 $/ 1 1 1))! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 8/13/2008 15:13'!
versionDate

	^ VersionDate
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 9/27/2007 15:52'!
visibleDrives
	"For Win32. Answer a list of visible drive names or nil. If nil, then all drives are visble."

	^ VisibleDrives
! !

!ScratchFrameMorph class methodsFor: 'utilities' stamp: 'jm 4/4/2005 08:09'!
workpaneExtent
	"Answer the extent of the work pane."

	^ WorkpaneExtent
! !


!ScratchFrameMorph class methodsFor: 'block resizing' stamp: 'EMP 10/10/2015 16:31'!
blockSize
	^ BlockSize! !

!ScratchFrameMorph class methodsFor: 'block resizing' stamp: 'EMP 10/10/2015 17:16'!
changeSize: sizeSelector



BlockSize ifNil: [BlockSize _ 2].

	sizeSelector = #Left ifTrue: [BlockSize _ (BlockSize asNumberNoError - 1)].
	sizeSelector = #Right ifTrue: [BlockSize _ (BlockSize asNumberNoError + 1)].
	sizeSelector = #Middle ifTrue: [BlockSize _ 2].
BlockSize _ (BlockSize within: 1 and: 7).
self allInstancesDo: [:m | m rebuildFullUI].! !

!ScratchFrameMorph class methodsFor: 'block resizing' stamp: 'EMP 10/10/2015 16:57'!
getArgSize
	^ (#(9 10 11 13 16 18 24) at: BlockSize)! !

!ScratchFrameMorph class methodsFor: 'block resizing' stamp: 'EMP 10/10/2015 16:56'!
getBlockSize
	^ (#(9 10 11 13 16 18 24) at: BlockSize)! !

!ScratchFrameMorph class methodsFor: 'block resizing' stamp: 'EMP 10/10/2015 17:11'!
getScale
	^ (#(0.9 1 1.1 1.3 1.6 1.8 2.4) at: BlockSize)! !


!ScratchFrameMorph class methodsFor: 'settings' stamp: 'EMP 11/18/2015 14:33'!
getSetting: aSymbol
	^ ScratchSettings at: aSymbol ifAbsent: [true].! !


!ScratchFrameMorph class methodsFor: 'comments' stamp: 'EMP 11/20/2015 15:23'!
whatDoesJSONLookLike
	^ '
	Dictionary
		Children
			List the sprites (sprite1, sprite2, etc...)
				costumes
				currentCostumeIndex
				indexInLibrary
				direction
				isDraggable
				objName
				rotationStyle
				scale
				scratchX
				scratchY
				sounds
				spriteInfo
				visible
		costumes (for the stage)
		currentCostumeIndex (for the stage)
		info
			flashVersion
			scriptCount
			spriteCount
			swfVersion
			videoOn
		objName
		penLayerID
		penLayerMD5
		sounds
			One dictionary per sound
				format
				md5
				rate
				sampleCount	
				soundName
				soundID
				
		tempoBPM
		videoAlpha
	'! !


!ScratchFrameMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 4/6/2016 12:22'!
versionControlDirectory
	"Returns the directory used by the revision control directory to store filed-out classes."
	| baseDirectory subdirName |
	baseDirectory _ FileDirectory default.	"Use the folder the image is in"
	subdirName _ 'Code'.
	"Create the source code revision directory is it doesn't exist"
	(baseDirectory directoryExists: subdirName) 
		ifFalse: [ baseDirectory createDirectory: subdirName ].
	"Return the code directory"
	^ baseDirectory directoryNamed: subdirName! !

!ScratchFrameMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 4/6/2016 12:24'!
versionControlExport
	"Outputs all classes that have changed since the project start date to a directory that should be managed by an external revision control system."

	| dir date |

	dir _ self versionControlDirectory.
	date _ self versionControlStartDate.
	
	dir fileOutClassesChangedSince: date.! !

!ScratchFrameMorph class methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 15:32'!
versionControlStartDate
	"Only classes that have changed since this date will be exported to the revision control system"
	^ '07/01/2015' asDate! !


ScratchFrameMorph initialize!
