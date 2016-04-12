ScrollFrameMorph subclass: #ScrollFrameMorph2
	instanceVariableNames: 'scrollBarStartInset scrollBarEndInset useHorizontalScroll '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!ScrollFrameMorph2 commentStamp: '<historical>' prior: 0!
This subclass of ScrollFrameMorph uses ScratchScrollBars.
!


!ScrollFrameMorph2 methodsFor: 'initialization' stamp: 'EMP 2/9/2016 16:27'!
initialize
	
	useHorizontalScroll _ true.
	super initialize.
	self borderWidth: 0.
	self removeAllMorphs.

	self color: Color blue.
	hbarInset _ 12.
	vbarInset _ 10.
	scrollBarStartInset _ 10.
	scrollBarEndInset _ 14.
	contentsChanged _ false.

	contents _ PasteUpMorph new
		color: (Color gray: 0.9);
		borderWidth: 0;
		enableDragNDrop: true.

	hScrollbar _ ScratchScrollBar newHorizontal
		target: self;
		selector: #hScrollRelative:.
	vScrollbar _ ScratchScrollBar newVertical
		target: self;
		selector: #vScrollRelative:.

	contents position: self position + borderWidth.
	self addMorph: contents.
	self addMorph: hScrollbar.
	self addMorph: vScrollbar.
	self extent: 160@120.
! !

!ScrollFrameMorph2 methodsFor: 'initialization' stamp: 'EMP 2/9/2016 16:28'!
noHorizontalScroll
	useHorizontalScroll _ false! !


!ScrollFrameMorph2 methodsFor: 'geometry' stamp: 'ee 3/6/2008 21:44'!
extent: aPoint
	"After setting my size, position and size my scrollbars and grow box. Also update my contents and scrollbar ranges."

	| inner w h |
	super extent: (aPoint truncated max: self minWidth@self minHeight).

	scrollBarStartInset ifNil: [
		scrollBarStartInset _ scrollBarEndInset _ 0].  "needed during initialization"

	inner _ self innerBounds.

	w _ inner width - scrollBarStartInset.
	vScrollbar owner = self
		ifTrue: [w _ w - vbarInset]
		ifFalse: [w _ w - scrollBarEndInset].
	hScrollbar position: (inner left + scrollBarStartInset)@(inner bottom - hbarInset).
	hScrollbar width: w.

	h _ inner height - scrollBarStartInset.
	hScrollbar owner = self
		ifTrue: [h _ h - hbarInset]
		ifFalse: [h _ h - scrollBarEndInset].
	ScratchTranslator isRTL
		ifTrue: [vScrollbar position: (inner left + 9)@(inner top + scrollBarStartInset)]
		ifFalse: [vScrollbar position: (inner right - vbarInset)@(inner top + scrollBarStartInset)].
	vScrollbar height: h.

	self updateContentsExtent.
	self updateScrollbars.
! !

!ScrollFrameMorph2 methodsFor: 'geometry' stamp: 'jm 6/28/2008 12:35'!
scrollbarStartInset: startInset endInset: endInset

	scrollBarStartInset _ startInset.
	scrollBarEndInset _ endInset.
! !


!ScrollFrameMorph2 methodsFor: 'drawing' stamp: 'jm 4/5/2005 21:43'!
drawSubmorphsOn: aCanvas
	"If my contents has changed, fix it's extent and update my scrollbar ranges. Clip submorph drawing to my bounds."

	| clipR |
	contentsChanged ifTrue: [
		self updateContentsExtent.
		self updateScrollbars.
		contentsChanged _ false].

	"draw my contents morph clipped to my visible extent"
	clipR _ self innerBounds topLeft extent: self visibleExtent.
	(aCanvas copyClipRect: clipR) fullDrawMorph: contents.

	"draw all my submorphs other than my contents"
	submorphs reverseDo:[:m |
		(m ~~ contents) ifTrue: [aCanvas fullDrawMorph: m]].


! !


!ScrollFrameMorph2 methodsFor: 'scrollbar visibility' stamp: 'EMP 2/9/2016 16:25'!
hScrollbar
	^ hScrollbar! !

!ScrollFrameMorph2 methodsFor: 'scrollbar visibility' stamp: 'EMP 2/9/2016 16:27'!
showHorizontalScrollbar: aBoolean
	"Show or hide my horizontal scrollbar."

	useHorizontalScroll ifFalse: [^ self].
	aBoolean = (hScrollbar owner = self) ifTrue: [^ self].

	aBoolean
		ifTrue: [self addMorph: hScrollbar]
		ifFalse: [hScrollbar delete].

	self extent: self extent.
! !

!ScrollFrameMorph2 methodsFor: 'scrollbar visibility' stamp: 'jm 4/6/2005 17:07'!
showVerticalScrollbar: aBoolean
	"Show or hide my vertical scrollbar."

	aBoolean = (vScrollbar owner = self) ifTrue: [^ self].

	aBoolean
		ifTrue: [self addMorph: vScrollbar]
		ifFalse: [vScrollbar delete].

	self extent: self extent.
! !

!ScrollFrameMorph2 methodsFor: 'scrollbar visibility' stamp: 'EMP 2/9/2016 16:24'!
vScrollbar
	^ vScrollbar! !


!ScrollFrameMorph2 methodsFor: 'scrolling' stamp: 'ee 10/24/2007 19:45'!
scrollMorphIntoView: aMorph

	| offset |
	(self bounds containsRect: aMorph fullBounds) ifTrue: [^ self].

	((aMorph fullBounds top < self top) and: [(aMorph fullBounds top < contents top) not]) ifTrue: [
		offset _ aMorph fullBounds top - contents top.
		contents top: (self top + 3) - offset].

	((aMorph fullBounds left < self left) and: [(aMorph fullBounds left < contents left) not]) ifTrue: [
		offset _ aMorph fullBounds left - contents left.
		contents left: (self left + 3) - offset].

	(aMorph fullBounds right > self right) ifTrue: [
		offset _ aMorph fullBounds right - contents left.
		contents left: (self right - 3) - offset].

	(aMorph fullBounds bottom > self bottom) ifTrue: [
		offset _ aMorph fullBounds bottom - contents top.
		contents top: (self bottom - 3) - offset].

	self updateContentsExtent.
	self updateScrollbars.
! !
