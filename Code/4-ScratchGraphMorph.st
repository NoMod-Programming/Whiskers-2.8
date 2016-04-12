RectangleMorph subclass: #ScratchGraphMorph
	instanceVariableNames: 'data dataColor playCursorColor playing cursorColor cursorColorAtZeroCrossings startIndex minVal maxVal selection scale cachedForm hasChanged viewer trueCalls falseCalls negVals posVals editor '
	classVariableNames: 'MinScale '
	poolDictionaries: ''
	category: 'Scratch-Sound'!
!ScratchGraphMorph commentStamp: '<historical>' prior: 0!
I display a graph of numbers, normalized so the full range of values just fits my height. I support a movable cursor that can be dragged with the mouse.

Implementation notes: Some operations on me may be done at sound sampling rates (e.g. 11-44 thousand times/second). To allow such high bandwidth application, certain operations that change my appearance do not immediately report a damage rectangle. Instead, a flag is set indicating that my display needs to refreshed and a step method reports the damage rectangle if that flag is set. Also, I cache a bitmap of my graph to allow the cursor to be moved without redrawing the graph.

All indices, like startIndex, cursor, etc are in terms of the graph data.

IMPORTANT!!  The current implementation cannot stand alone, it needs to be a submorph of SoundEditor.
!


!ScratchGraphMorph methodsFor: 'initialization' stamp: 'LY 7/31/2003 11:55'!
addRuler

	ruler _ ScratchRulerMorph graphMorph: self.
	self addMorphBack: ruler.
	ruler position: self bottomLeft.
! !

!ScratchGraphMorph methodsFor: 'initialization' stamp: 'EMP 12/15/2015 09:59'!
initialize

	super initialize.
	self color: (Color r: 0.8 g: 0.8 b: 0.6).
	self extent: 365@80.
	self borderWidth: 2.
	dataColor _ Color r: 48/255 g: 48/255 b: 48/255.
	cursorColor _ (Color r: 167/255 g: 167/255 b: 211/255 alpha: 0.9).
	playCursorColor _ Color blue.
	cursorColorAtZeroCrossings _ Color red.
	startIndex _ 1.
	viewer _ false.
	selection _ {nil. nil}.
	scale _ 1.0.
	hasChanged _ false.
	posVals _ negVals _ nil.

	self data:
		((0 to: 360 - 1) collect:
			[:x | (100.0 * (x degreesToRadians sin)) asInteger]).

	
	
! !


!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
color: aColor

	super color: aColor.
	self flushCachedForm.
! !

!ScratchGraphMorph methodsFor: 'accessing'!
cursor

	^ editor cursor
! !

!ScratchGraphMorph methodsFor: 'accessing'!
cursor: aNumber


	editor cursor: aNumber.
! !

!ScratchGraphMorph methodsFor: 'accessing'!
cursorAtEnd

	^editor cursor truncated >= data size
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
cursorColor

	^ cursorColor
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
cursorColor: aColor

	cursorColor _ aColor.
	self flushCachedForm.
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
cursorColorAtZeroCrossing

	^ cursorColorAtZeroCrossings
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
cursorColorAtZeroCrossings: aColor

	cursorColorAtZeroCrossings _ aColor.
	self flushCachedForm.
! !

!ScratchGraphMorph methodsFor: 'accessing'!
cursorWrapped: aNumber

	| sz |
	editor cursor ~= aNumber ifTrue: [
		editor cursor: aNumber.
		sz _ data size.
		sz = 0
			ifTrue: [editor cursor: 1]
			ifFalse: [
				((editor cursor >= (sz + 1)) or: [editor cursor < 0]) ifTrue: [
					 editor cursor: editor cursor - ((editor cursor // sz) * sz)].
				editor cursor < 1 ifTrue: [editor cursor: sz + editor cursor]].
		"assert: 1 <= cursor < data size + 1"
		hasChanged _ true].
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'EMP 12/14/2015 20:29'!
customScale
	"Called when the user wants to input a scale value."

	| answer |
	answer _ FillInTheBlank request: 'Please type desired scale:' initialAnswer: '2x'.
	answer size = 0 ifTrue: [^ self].
	answer _ answer copyWithout: $x.
	self zoom: answer asNumberNoError
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
data

	^ data
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
data: aCollection

	data _ aCollection.
	maxVal _ minVal _ 0.
	data do: [:x |
		x < minVal ifTrue: [minVal _ x].
		x > maxVal ifTrue: [maxVal _ x]].

	self flushCachedForm.
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
dataColor

	^ dataColor
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
dataColor: aColor

	dataColor _ aColor.
	self flushCachedForm.
! !

!ScratchGraphMorph methodsFor: 'accessing'!
editor

	^editor! !

!ScratchGraphMorph methodsFor: 'accessing'!
editor: aSoundEditor

	editor _ aSoundEditor.! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/28/2003 10:11'!
interpolatedValueAtCursor

	| sz prev frac next |
	data isEmpty ifTrue: [^ 0].
	sz _ data size.
	owner cursor < 0 ifTrue: [^ data at: 1].  "just to be safe, though cursor shouldn't be negative"
	prev _ owner cursor truncated.
	frac _ owner cursor - prev.
	prev < 1 ifTrue: [prev _ sz].
	prev > sz ifTrue: [prev _ 1].
	"assert: 1 <= prev <= sz"
	frac = 0 ifTrue: [^ data at: prev].  "no interpolation needed"

	"interpolate"
	next _ prev = sz ifTrue: [1] ifFalse: [prev + 1].
	^ ((1.0 - frac) * (data at: prev)) + (frac * (data at: next))
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
lastValue

	data size = 0 ifTrue: [^ 0].
	^ data last
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
lastValue: aNumber

	self appendValue: aNumber.
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'LY 7/31/2003 12:09'!
ruler

	^ruler.! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'LY 7/30/2003 10:54'!
scale
	
	^scale.! !

!ScratchGraphMorph methodsFor: 'accessing'!
scale: aNumber

	"setting the absolute scale of how the graph is display.  It is relative to MinScale, the minimum scale possible, which is the scale value of the viewer."

	aNumber < 1 ifTrue: [^self].
	scale _ (aNumber*MinScale) asFloat min: 1.
	
	self calculateDataArray.
	self flushCachedForm; changed.
	editor viewer flushCachedForm; changed.

	editor updateSlider.
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
selection

	^ selection
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'LY 7/26/2003 16:48'!
selection: anArrayOrNil
	"Set the selection to the given (startIndex, stopIndex) pair to to nil."

	anArrayOrNil
		ifNil: [	selection at: 1 put: nil. selection at: 2 put: nil]
		ifNotNil: [ selection _ anArrayOrNil.].

! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
startIndex

	^ startIndex
! !

!ScratchGraphMorph methodsFor: 'accessing' stamp: 'jm 7/12/2003 17:23'!
startIndex: aNumber

	startIndex ~= aNumber ifTrue:  [
		startIndex _ aNumber asInteger.
		self flushCachedForm].
! !

!ScratchGraphMorph methodsFor: 'accessing'!
valueAtCursor

	data isEmpty ifTrue: [^ 0].
	^ data at: ((editor cursor truncated max: 1) min: data size).
! !

!ScratchGraphMorph methodsFor: 'accessing'!
valueAtCursor: aPointOrNumber

	data isEmpty ifTrue: [^ 0].
	data
		at: ((editor cursor truncated max: 1) min: data size)
		put: (self asNumber: aPointOrNumber).
	self flushCachedForm.
! !

!ScratchGraphMorph methodsFor: 'accessing'!
viewer: aBoolean

	viewer _ aBoolean. "whether or not this graphMorph is the viewer graph Morph"
	
	viewer ifFalse: [self color: Color white.].! !


!ScratchGraphMorph methodsFor: 'drawing'!
drawOn: aCanvas

	| c |

	cachedForm = nil ifTrue:  [
		c _ FormCanvas extent: bounds extent.
		c translateBy: bounds origin negated
			during:[:tempCanvas| self drawDataOn: tempCanvas].
		cachedForm _ c form].
	aCanvas paintImage: cachedForm at: bounds origin.
	self drawCursorOn: aCanvas.
	self drawPlayCursorOn: aCanvas.
	! !

!ScratchGraphMorph methodsFor: 'drawing' stamp: 'EMP 2/9/2016 16:05'!
endIndex
	^ startIndex + bounds width min: data size! !

!ScratchGraphMorph methodsFor: 'drawing' stamp: 'LY 7/25/2003 17:31'!
hasChanged: aBoolean
	
	hasChanged _ aBoolean.! !


!ScratchGraphMorph methodsFor: 'change reporting' stamp: 'jm 7/12/2003 17:23'!
layoutChanged

	super layoutChanged.
	cachedForm _ nil.
! !


!ScratchGraphMorph methodsFor: 'events' stamp: 'jm 7/12/2003 17:23'!
handlesMouseDown: evt

	^ true
! !

!ScratchGraphMorph methodsFor: 'events'!
mouseDown: evt

	"Handles mouse down and drag events.  Updates the cursor's position and sets the selection to an array containing two copies of the current cursor value."
	| x s |

	 x _ evt cursorPoint x - (bounds left + borderWidth).

	s _ editor startSelection.
	editor startSelection: editor cursor.  
	editor cursor: startIndex + (x/scale).
		
	evt shiftPressed
		ifTrue: [  editor selectionNil 
					ifFalse: [
						editor startSelection: s.
				  		self adjustSelection.].]
		ifFalse: [
				 ((editor selectionNil not) and: [(selection at: 2) - (selection at: 1) > 3])
						ifTrue: [ editor selection: nil.
			  				      self flushCachedForm.
				 				 self changed.].
			  	 editor startSelection: editor cursor.
				 editor selection: {editor cursor. editor cursor}.].


	 
	
	! !

!ScratchGraphMorph methodsFor: 'events' stamp: 'EMP 12/14/2015 20:05'!
mouseMove: evt

	"Updates the cursor position as the mouse moves.  Adjusts the selection only if the mouse is currently being pressed"
	| x w |

	x _ evt cursorPoint x - (bounds left + borderWidth).
	w _ self width - (2 * borderWidth).

	(viewer not and: [x < 0]) ifTrue: [
		editor cursor: startIndex + (x /scale).
		self adjustSelection.
		editor slider scrollFraction: (startIndex/data size).
		^ self startIndex: self editor cursor].
	(viewer not and: [x > w]) ifTrue: [
		editor cursor: startIndex + (x /scale).
		self adjustSelection.
		editor slider scrollFraction: (startIndex/data size).
		^ self startIndex: editor cursor - (w/scale) truncated.
		"^ editor cursor = data size
			ifTrue: [ self startIndex: editor cursor - (w/(scale*2)) truncated.]
			ifFalse: [ self startIndex: editor cursor - (w/scale) truncated.]."].


	evt anyButtonPressed 
		ifTrue: [editor cursor: (startIndex + (x/scale) truncated).
				self adjustSelection.]
! !

!ScratchGraphMorph methodsFor: 'events'!
mouseUp: evt

	((editor selectionNil not) and: [(selection at: 2) - (selection at: 1) <=3])
		ifTrue: [editor selection: nil.
				editor startSelection: nil.].
! !


!ScratchGraphMorph methodsFor: 'stepping' stamp: 'EMP 12/15/2015 12:33'!
step
	"Make a deferred damage rectangle if I've changed. This allows applications to call methods that invalidate my display at high-bandwidth without paying the cost of doing the damage reporting on ever call; they can merely set hasChanged to true."

	super step.
	
	hasChanged == nil ifTrue: [hasChanged _ false].
	hasChanged ifTrue: [
		self changed.
		hasChanged _ false].
! !

!ScratchGraphMorph methodsFor: 'stepping' stamp: 'EMP 12/15/2015 12:33'!
stepTime

	^ 150! !


!ScratchGraphMorph methodsFor: 'menu' stamp: 'jm 7/12/2003 17:23'!
addCustomMenuItems: aCustomMenu hand: aHandMorph

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'open wave editor' action: #openWaveEditor.
	aCustomMenu add: 'read file' action: #readDataFromFile.
! !

!ScratchGraphMorph methodsFor: 'menu'!
adjustSelection
	"Adjust the selection, if any, to the current cursor position. Do nothing if there is no selection."

	editor selectionNil ifTrue: [^ self].
	editor selection: editor cursor scd: editor startSelection.

! !

!ScratchGraphMorph methodsFor: 'menu' stamp: 'jm 1/29/2009 14:57'!
openWaveEditor

	| factor scaledData |
	self data: data.  "make sure maxVal and minVal are current"
	factor _ 32767 // ((minVal abs max: maxVal abs) max: 1).
	scaledData _ SoundBuffer newMonoSampleCount: data size.
	1 to: data size do: [:i | scaledData at: i put: (factor * (data at: i)) truncated].
	(SimpleWaveEditor new
		data: scaledData;
		samplingRate: 11025) openInWorld.
! !

!ScratchGraphMorph methodsFor: 'menu' stamp: 'jm 12/4/2003 20:21'!
readDataFromFile

	| result fName |
	result _ StandardFileMenu oldFileExtensions: #(aif aiff au wav).
	result ifNil: [^ self].
	fName _  result directory pathName, FileDirectory slash, result name.
	self data: (SampledSound fromFileNamed: fName) samples.

! !


!ScratchGraphMorph methodsFor: 'viewing' stamp: 'EMP 3/7/2016 14:11'!
computeSlider
	
	editor slider percentVisible: ((self width) / (self data size // 25)) - 100.
	editor slider changed.! !

!ScratchGraphMorph methodsFor: 'viewing'!
setScale

	| menu choice |

	menu _ CustomMenu new.
	menu add: '1x' action: '1';
		   add: '2x' action: '2';
		   add: '3x' action: '3';
		   add: '4x' action: '4';
		   add: '5x' action: '5';
		   add: 'other' action: #customScale.
	choice _ menu startUp.
	choice ifNil: [^self].

	choice = #customScale 
		ifFalse: [self scale: choice asNumber.]	
		ifTrue: [ self customScale].! !

!ScratchGraphMorph methodsFor: 'viewing' stamp: 'EMP 12/14/2015 20:08'!
viewSelection

	| diff |
	selection ifNil: [^self].
	(selection isKindOf: Array) ifTrue: [((selection first) = nil) ifTrue: [^ self] ifFalse: [(selection second = nil) ifTrue: [^ self]]].
	scale _ (MinScale*(data size/(selection second - selection first)) asFloat min: 1).
	self calculateDataArray.

	diff _ (selection second - selection first) - bounds width.
	diff < 0
		ifTrue: [ self startIndex: selection first asInteger + (diff//2)]
		ifFalse: [self startIndex: selection first asInteger.].
	
	
	editor updateSlider.


	! !

!ScratchGraphMorph methodsFor: 'viewing'!
zoom: aNumber

	scale _ ((scale*aNumber asFloat) max: MinScale asFloat) min: 1.
	
	self calculateDataArray.
	self flushCachedForm; changed.
	editor viewer flushCachedForm; changed.

	editor updateSlider.! !

!ScratchGraphMorph methodsFor: 'viewing' stamp: 'LY 7/30/2003 15:19'!
zoomIn

	self zoom: 2.! !

!ScratchGraphMorph methodsFor: 'viewing' stamp: 'LY 7/30/2003 15:21'!
zoomOut

	self zoom: 0.5.! !


!ScratchGraphMorph methodsFor: 'commands' stamp: 'jm 7/12/2003 17:23'!
appendValue: aPointOrNumber

	| newVal |
	(data isKindOf: OrderedCollection) ifFalse: [data _ data asOrderedCollection].
	newVal _ self asNumber: aPointOrNumber.
	data addLast: newVal.
	newVal < minVal ifTrue: [minVal _ newVal].
	newVal > maxVal ifTrue: [maxVal _ newVal].
	self cursor: data size.
	self flushCachedForm.
! !

!ScratchGraphMorph methodsFor: 'commands'!
centerCursor
	"Scroll so that the cursor is as close as possible to the center of my window."

	| w |

	w _ self width - (2 * borderWidth).
	self startIndex: ((editor cursor - (w // (scale*2))) max: 1).
! !

!ScratchGraphMorph methodsFor: 'commands' stamp: 'jm 7/12/2003 17:23'!
clear

	self startIndex: 1.
	self cursor: 1.
	self data: OrderedCollection new.
! !

!ScratchGraphMorph methodsFor: 'commands' stamp: 'jm 7/12/2003 17:23'!
loadSineWave

	self loadSoundData: FMSound sineTable.
! !

!ScratchGraphMorph methodsFor: 'commands' stamp: 'jm 7/12/2003 17:23'!
loadSound: aSound

	self loadSoundData: aSound samples.
! !

!ScratchGraphMorph methodsFor: 'commands' stamp: 'EMP 12/15/2015 12:34'!
loadSoundData: aCollection

	| factor absV newData |
	factor _ 1.
	aCollection do: [:v | (absV _ v abs) > factor ifTrue: [scale _ absV]].
	scale _ 100.0 / factor.
	newData _ OrderedCollection new: aCollection size.
	1 to: aCollection size do: [:i | newData addLast: (factor * (aCollection at: i))].

	self data: newData.
	self startIndex: 1.
	self cursor: 1.
! !

!ScratchGraphMorph methodsFor: 'commands' stamp: 'jm 2/3/2009 14:19'!
playOnce

	| factor absV scaledData |
	data isEmpty ifTrue: [^ self].  "nothing to play"
	factor _ 1.
	data do: [:v | (absV _ v abs) > factor ifTrue: [factor _ absV]].
	factor _ 32767.0 / factor.
	scaledData _ SoundBuffer newMonoSampleCount: data size.
	1 to: data size do: [:i |
		scaledData at: i put: (factor * (data at: i)) truncated].
	(SampledSound samples: scaledData samplingRate: 11025) play.
! !

!ScratchGraphMorph methodsFor: 'commands' stamp: 'jm 7/12/2003 17:23'!
reverse

	data _ data reversed.
	self flushCachedForm.
! !


!ScratchGraphMorph methodsFor: 'private'!
calculateDataArray

	| currIndex neg pos |

	negVals _ OrderedCollection new.
	posVals _ OrderedCollection new.

	data isEmpty ifTrue: [^ self].
	currIndex_ neg_pos _ 0.

	(1 to: data size) do: [ :i |
		((i * scale) truncated > currIndex)
			ifTrue: [
			
					currIndex _ (i*scale) truncated.		
					neg _ neg min: (data at: i).
					pos _ pos max: (data at: i).
			
					posVals add: pos.
					negVals	add: neg.
		
					pos _ neg _ 0.]
			ifFalse: [
						neg _ neg min: (data at: i).
						pos _ pos max: (data at: i).].].! !

!ScratchGraphMorph methodsFor: 'private'!
drawCursorOn: aCanvas

	| ptr x r c |
	ptr _ (editor cursor asInteger max: 1) min: data size.
	c _ cursorColor.
	((ptr > 1) and: [ptr < data size]) ifTrue: [
		(data at: ptr) sign ~= (data at: ptr + 1) sign
			ifTrue: [c _ cursorColorAtZeroCrossings]].
	r _ self innerBounds.
	x _ r left + ((ptr - startIndex)*scale).
	((x >= r left) and: [x <= r right]) ifTrue: [
		aCanvas fillRectangle: (x@r top corner: x + 1@r bottom) color: c].
! !

!ScratchGraphMorph methodsFor: 'private'!
drawDataOn: aCanvas

	| x start end left right yScale baseLine top bottom |
	super drawOn: aCanvas.

	viewer ifTrue: [self drawViewOn: aCanvas.].
	self drawSelectionOn: aCanvas.

	(posVals isNil) ifTrue: [^ self].

	maxVal = minVal ifTrue: [yScale _ 1.] 
					ifFalse: [yScale _ (bounds height - (2 * borderWidth)) asFloat / (maxVal - minVal)].
	baseLine _ bounds bottom - borderWidth + (minVal * yScale) truncated.

	left _ 0. right _ 10.
	x _ bounds left + borderWidth.

	start _ (startIndex*scale) truncated min: data size max: 1.
	end _ start + bounds width min: data size.

	start to: end do: [:i |
		i > posVals size ifTrue: [^self].
					
		left _ x truncated. right _ x + 1.
		right > (bounds right - borderWidth) ifTrue: [^ self].

		top _ baseLine min: (baseLine - (yScale*(posVals at: i))) truncated.
		bottom _ (baseLine max: baseLine - (yScale*(negVals at: i))) truncated.
											
		aCanvas fillRectangle: (left@top corner: right@bottom) color: dataColor.
		x _ x + 1].! !

!ScratchGraphMorph methodsFor: 'private'!
drawPlayCursorOn: aCanvas

	| ptr x r c |

	editor playCursor ifNil: [^self].
	(editor endPlaying ~= data size) & (editor playCursor >= (editor endPlaying)) ifTrue: [^self].

	ptr _ (editor playCursor asInteger max: 1) min: data size.
	c _ cursorColor.
	r _ self innerBounds.
	x _ r left + ((ptr - startIndex)*scale).
	((x >= r left) and: [x <= r right]) ifTrue: [
		aCanvas fillRectangle: (x@r top corner: x + 1@r bottom) color: c].
! !

!ScratchGraphMorph methodsFor: 'private' stamp: 'EMP 12/15/2015 10:04'!
drawSelectionOn: aCanvas

	| x y lightColor darkColor v1 v2 offsetX s1 s2 bottom |

	editor selectionNil ifTrue: [^ self].

	lightColor _ Color lightBlue.
	darkColor _ lightColor.

	v1 _ (editor graph startIndex asInteger max: 1) min: data size.
	v2 _ v1 + (bounds width/(editor graph scale)) min: data size.
	

	offsetX _ bounds left + borderWidth.
	x _ (offsetX + ((selection first - startIndex)*scale)).
	y _ bounds top + borderWidth.

	viewer 
		ifFalse: [
			selection first > v2 ifTrue: [^ self].  "selection is not visible"
			selection last < v1 ifTrue: [^ self].  "selection is not visible"

			aCanvas
				fillRectangle: (x@y extent: ((selection last - selection first)*scale)@(self height - (2 * borderWidth)))
				color: lightColor. "lightYellow"]
		ifTrue: [
			s1 _ selection first.
			s2 _ selection second.

			bottom _ self height - (2 * borderWidth).


			((s1 max: s2) <= v1) | ((s1 min: s2) >= v2)
				ifTrue: [^aCanvas 				
							fillRectangle: ((offsetX + (s1*scale))@y extent: ((s2-s1)*scale)@bottom)
							color: darkColor.].
			
			(s1 <= v1) & (s2 >= v2)
				ifTrue: [^aCanvas fillRectangle: ((offsetX + (s1*scale))@y extent: ((v1-s1)*scale)@bottom)
								color: darkColor;
								fillRectangle: ((offsetX + (v1*scale))@y extent: ((v2-v1)*scale)@bottom)
								color: lightColor;
								fillRectangle: (( offsetX + (v2*scale))@y extent: ((s2-v2)*scale)@bottom)
								color: darkColor.].
			
			(s1 >= v1) & (s2 <= v2)
				ifTrue: [^aCanvas
							fillRectangle: ((offsetX + (s1*scale))@y extent: ((s2-s1)*scale)@bottom)
							color: lightColor.].
	
			(s1 < v1) & (s2 > v1) & (s2 < v2)
				ifTrue: [^aCanvas
							fillRectangle: ((offsetX + (s1*scale))@y extent: ((v1-s1)*scale)@bottom)
							color: darkColor;
							fillRectangle: ((offsetX + (v1*scale))@y extent: ((s2- v1)*scale)@bottom)
							color: lightColor.].
		
			(s1 >= v1) & (s2 >= v2) 
				ifTrue: [^aCanvas
							fillRectangle: ((offsetX + (s1*scale))@y extent: ((v2-s1)*scale)@bottom)
							color: lightColor;
							fillRectangle: ((offsetX + (v2*scale))@y extent: ((s2 - v2)*scale)@bottom)
							color: darkColor.].

			"Transcript show: 'no category :(';cr."

			].



! !

!ScratchGraphMorph methodsFor: 'private' stamp: 'EMP 12/14/2015 19:51'!
drawViewOn: aCanvas

	"highlights the part of the graph morph we're viewing."
	| y ex start x |

	viewer ifFalse: [^self].
	
	
	start _ ((editor graph startIndex*bounds width)/data size) truncated min: data size.
	ex_ 1.

	x _ (bounds left + borderWidth + start).
	y _ bounds top + borderWidth.

	aCanvas
		fillRectangle: (x@y extent: ex@(self height - (2 * borderWidth)))
		color: Color white. "lightYellow".
! !

!ScratchGraphMorph methodsFor: 'private' stamp: 'LY 7/25/2003 17:31'!
flushCachedForm

	cachedForm _ nil.
	hasChanged _ true.
 ! !

!ScratchGraphMorph methodsFor: 'private' stamp: 'LY 8/1/2003 13:18'!
keepIndexInView: index

	| w newStart |

	w _ bounds width - (2 * borderWidth).
	index < startIndex ifTrue: [
		newStart _ index - w//scale + 1.
		^ self startIndex: (newStart max: 1)].
	index > (startIndex + w//scale) ifTrue: [
		^ self startIndex: (index min: data size)].
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchGraphMorph class
	instanceVariableNames: ''!

!ScratchGraphMorph class methodsFor: 'instance creation' stamp: 'LY 7/30/2003 11:52'!
MinScale

	^MinScale! !

!ScratchGraphMorph class methodsFor: 'instance creation' stamp: 'jm 9/5/2006 18:27'!
MinScale: aNumber

	"aNumber should be equal to: viewer extent x/ graph data size"
	MinScale _ aNumber asFloat.
! !

!ScratchGraphMorph class methodsFor: 'instance creation' stamp: 'jm 7/12/2003 17:23'!
openOn: dataCollection
	"Open a new GraphMorph on the given sequencable collection of data."

	^ (self new data: dataCollection) openInWorld
! !
