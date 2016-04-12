DividedImageFrameMorph subclass: #ScratchViewerMorph
	instanceVariableNames: 'target pageViewer currentCategory catButtonsExtent '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Panes'!
!ScratchViewerMorph commentStamp: '<historical>' prior: 0!
I am a Scratch blocks palette viewer. I have a set of ToggleButtons that allow selection of a blocks category to view and a scrollable area showing the blocks in the currently selected category.
!


!ScratchViewerMorph methodsFor: 'initialization' stamp: 'EMP 2/9/2016 16:26'!
initialize

	super initialize.
	self
		initFromForm: (ScratchFrameMorph skinAt: #blocksPaletteFrameTransparent2)
		topSectionHeight: 120.
	self middleBarLeftMargin: 5 rightMargin: 0.
	color _ (Color gray: 0.9)"(Color r: 0.584 g: 0.603 b: 0.623)".
	pageViewer _ ScrollFrameMorph2 new growthFraction: 0.1; noHorizontalScroll.
	self addMorphBack: (pageViewer position: self position + (0@120)).
	self target: nil.
	self extent: 214@500.
! !

!ScratchViewerMorph methodsFor: 'initialization' stamp: 'EMP 3/22/2016 11:58'!
rebuildCategorySelectors
	| t1 t2 t3 t4 t5 t6 t7 t10 t12 t13 t14 t15 t16 |
	t1 := #(#(#motion 'motion' ) #(#events 'events' ) #(#looks 'looks' ) #(#control 'control' ) #(#sound 'sound' ) #(#sensing 'sensing' ) #(#pen 'pen' ) #(#operators 'operators' ) #(#variables 'data' ) #(#other 'more blocks' ) ).
	submorphs
		do: [:t17 | (t17 isKindOf: ResizableToggleButton2)
				ifTrue: [t17 delete]].
	t12 := 75 @ 0.
	t2 := t1
				collect: [:t17 | 
					t13 := (ScratchTranslator translationFor: t17 second asString) capitalized.
					t14 := ScratchFrameMorph skinAt: t17 first.
					t15 := ScratchFrameMorph skinAt: t17 first , 'Pressed'.
					t16 := ScratchFrameMorph skinAt: t17 first.
					ScratchTranslator isRTL
						ifTrue: [t10 := ResizableToggleButton2 new
										offForm: (t14 flipBy: #horizontal centerAt: t14 center)
										onForm: (t15 flipBy: #horizontal centerAt: t15 center)
										overForm: (t16 flipBy: #horizontal centerAt: t16 center)]
						ifFalse: [t10 := ResizableToggleButton2 new
										offForm: t14
										onForm: t15
										overForm: t16].
					t10
						label: t13
						font: (ScratchFrameMorph getFont: #Category);
						
						labelColorOn: Color white
						labelColorOff: (Color gray: 0.4)
						labelColorOver: Color orange lighter;
						 target: self;
						 actionSelector: #currentCategory:;
						
						arguments: (Array with: t17 second);
						 toggleButtonMode: true;
						 toggleMode: false.
					ScratchTranslator isRTL
						ifTrue: [t10 rightJustifyInset: 10]
						ifFalse: [t10 leftJustifyInset: 10].
					t12 := t12 max: t10 extent + (5 @ -5).
					t10].
	t3 := 9.
	catButtonsExtent := 2 * t12 x + (t3 * 2) @ (t1 size // 2 * t12 y + 30).
	t4 := self left + t3.
	t5 := t4 + t12 x + t3 + 3.
	t6 := t4.
	t7 := self top + 10.
	1
		to: t2 size
		do: [:t8 | 
			t10 := t2 at: t8.
			t10 extent: t12.
			self
				addMorph: (t10 position: t6 @ t7).
			t8 even
				ifTrue: [t6 := t4.
					t7 := t7 + t10 height + 2]
				ifFalse: [t6 := t5]].
	self width: catButtonsExtent x.
	pageViewer position: self position + (3 @ catButtonsExtent y).
	topSectionHeight := catButtonsExtent y - 4! !


!ScratchViewerMorph methodsFor: 'accessing' stamp: 'nb 1/24/2008 17:35'!
catButtonsExtent

	^ catButtonsExtent
! !

!ScratchViewerMorph methodsFor: 'accessing' stamp: 'jm 6/29/2004 14:20'!
categoryChanged: aString
	"The given category has changed (e.g., due to a variable or script add/remove). If it's the current category, update my contents. Otherwise, do nothing."

	self target ifNil: [^ self].
	currentCategory = aString ifTrue: [self updateContents].
! !

!ScratchViewerMorph methodsFor: 'accessing' stamp: 'jm 2/27/2005 19:04'!
currentCategory

	^ currentCategory
! !

!ScratchViewerMorph methodsFor: 'accessing' stamp: 'TIS 7/10/2006 11:17'!
currentCategory: aString

	World activeHand newKeyboardFocus: nil.
	currentCategory _ aString.
	self lightUpSelectorForCurrentCategory.
	self updateContents.
! !

!ScratchViewerMorph methodsFor: 'accessing' stamp: 'TIS 7/7/2006 13:33'!
pageViewer

	^ pageViewer
! !

!ScratchViewerMorph methodsFor: 'accessing' stamp: 'EMP 2/9/2016 16:23'!
refresh
	"Refresh the palette for the current category."

	World activeHand newKeyboardFocus: nil.
	self updateContentsRefresh.
! !

!ScratchViewerMorph methodsFor: 'accessing' stamp: 'jm 5/11/2004 19:36'!
target

	^ target
! !

!ScratchViewerMorph methodsFor: 'accessing' stamp: 'jm 2/27/2005 19:28'!
target: aScratchObject
	"Start viewing the given object, if not object, return an empty viewer."

	| categories |
	target _ aScratchObject.
	aScratchObject ifNil: [
		^ self currentCategory: 'none'].

	"keep the same category selected if possible"
	categories _ target blockCategories.
	(categories includes: currentCategory)
		ifTrue: [self currentCategory: currentCategory]
		ifFalse: [self currentCategory: categories first].

	self isInWorld ifTrue: [self world startSteppingSubmorphsOf: self].
! !


!ScratchViewerMorph methodsFor: 'drawing' stamp: 'jm 10/28/2008 13:07'!
drawBackgroundOn: aCanvas
	"Draw my background."

	color isTransparent ifTrue: [^ self].

	aCanvas
		fillRectangle: (self topLeft extent: (self width @ catButtonsExtent y))
		color: color.
! !


!ScratchViewerMorph methodsFor: 'geometry' stamp: 'EMP 12/9/2015 12:08'!
extent: aPoint

	super extent: aPoint.
	pageViewer ifNotNil: [pageViewer extent: self extent - ((pageViewer position - self position) + (0@3))].
! !


!ScratchViewerMorph methodsFor: 'private' stamp: 'nb 1/14/2008 20:45'!
lightUpSelectorForCurrentCategory

	submorphs do: [:m |
		(m isKindOf: ResizableToggleButton2) ifTrue: [
			m arguments first = currentCategory
				ifTrue: [m on]
				ifFalse: [m off]]].
! !

!ScratchViewerMorph methodsFor: 'private'!
updateContents

	| p |
	self target ifNil: [
		pageViewer contents: (Morph new color: (Color gray: 0.9)"ScratchFrameMorph palettePaneColor").
		^ self].

	p _ self target viewerPageForCategory: currentCategory.
	p color: (Color gray: 0.9)"ScratchFrameMorph palettePaneColor".

	pageViewer contents: p.
	self isInWorld ifTrue: [self world startSteppingSubmorphsOf: p].
	p fixLayout.
	ScratchTranslator isRTL
		ifTrue: [pageViewer hScrollPixels: (p right)].
! !

!ScratchViewerMorph methodsFor: 'private' stamp: 'EMP 2/9/2016 16:32'!
updateContentsRefresh

	| p pv ph |
	self target ifNil: [
		pageViewer contents: (Morph new color: (Color gray: 0.9)"ScratchFrameMorph palettePaneColor").
		^ self].
	pv _ pageViewer vScrollPixels.
	ph _ pageViewer hScrollPixels.

	p _ self target viewerPageForCategory: currentCategory.
	p color: (Color gray: 0.9)"ScratchFrameMorph palettePaneColor".

	pageViewer contents: p.
	self isInWorld ifTrue: [self world startSteppingSubmorphsOf: p].
	p fixLayout.
	ScratchTranslator isRTL
		ifTrue: [pageViewer hScrollPixels: (p right)].
	pageViewer vScrollPixels: pv.
	pageViewer hScrollPixels: ph.
! !
