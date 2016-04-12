AlignmentMorph subclass: #ScratchSoundEditorMorph
	instanceVariableNames: 'client soundName graph viewer selection startSelection playCursor cursor origSamplingRate samplingRate rateSlider slider volume snd completeSnd soundMorphSound copy time scrollDelta deltaVal fwdButton backButton undoSound undoSel undoCursor undoScale endPlaying nameMorph controls sliderBin graphBin '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Sound'!
!ScratchSoundEditorMorph commentStamp: '<historical>' prior: 0!
A sound editor, based on the wave editor.  It can be brought up by the SoundMorph.  When the soundEditor is brought up, it is created with a copy of the sound in the sound morph. It contains the sound of the soundmorph and is capable of editing that sound.  That sound is set in the method "sound:"

"viewing"
graph 					GraphMorph			
viewer					GraphMorph
selection 				    Array				an array of 2 #s that are the start and end of the selection.  This and the next 2 												variables are in terms of indices of the graph data
startSelection 			   Number				a number indicating the constant pt in a selection (mouse down loc)
cursor					   Number				a number indicating the location of the cursor

"Scrolling in view"
scrollDelta			        Number				a number telling us how much to scroll by, used in stepping to allow scrolling by 												buttons
slider					   slider morph			a slider for the graph
time					   a number			where we are in the graph in terms os msecs
deltaVal 					number				how much the cursor scrolls by, scrolldelta is set to +- this value
fwdButton 					button				scolling
backButton     				button				scrolling

"Playing variables" 
origSamplingRate 		  big number			indicates the sampling rate of the song @ loading
												so u can reset to that sampling rate.
samplingRate 	         another big number		indicates current sampling rate.	
(2 above aren't currently used)

volume					   slider morph			indicates volume, (0 to 1.0)		
preview						boolean 			whether we're in play all mode or play 	from 												cursor mode, where the cursor moves along with 												the music
"Sound manipulation"
snd 						SampledSound		Current sound used for playing from cursor + selection
completeSnd 				SampledSound		The entire song after editing (doesn't change with playing)
soundMorphSound   			SampledSound		a ref to the sound of the SoundMorph that created this, 
												so that u can change the sound within that sound editor

"Editing tools"
copy						SoundBuffer		the portion of the graph data that has been copied
undoSound 					SampledSound		the sound before any cuts/pastes crops
undoSel 					Array				a copy of the selection bf any cut/paste/crop


rateSlider 					currently not implemented
keyboard!


!ScratchSoundEditorMorph methodsFor: 'initialization' stamp: 'EMP 12/14/2015 15:31'!
addControls

	| b r spacer |
	b _ SimpleButtonMorph new target: self; borderColor: Color black; useSquareCorners.
	b borderColor: #raised; borderWidth: 3.
	r _ AlignmentMorph newRow.
	r color: (Color r: 222/255 g: 222/255 b: 222/255); borderWidth: 0; inset: 0.
	r hResizing: #spaceFill; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center.

	spacer _ Morph new color: r color; extent: 40@5.  "spacer"
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: ((ScratchFrameMorph buttonLabel: 'undo' localized selector: #undo) target: self).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: ((ScratchFrameMorph buttonLabel: 'copy' localized selector: #copy) target: self).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: ((ScratchFrameMorph buttonLabel: 'paste' localized selector: #paste) target: self).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: ((ScratchFrameMorph buttonLabel: 'cut' localized selector: #cut) target: self).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: ((ScratchFrameMorph buttonLabel: 'copy' localized selector: #copy) target: self).	
	r addMorphBack: (spacer fullCopy width: 25).
	r addMorphBack: (b copy target: graph;
							label: 'zoom selection';	actionSelector: #viewSelection).

	r addMorphBack: (spacer fullCopy width: 25).
	r addMorphBack: (b fullCopy label: 'okay';			actionSelector: #save).

	self addMorphBack: r.

! !

!ScratchSoundEditorMorph methodsFor: 'initialization' stamp: 'EMP 12/15/2015 10:32'!
addGraph

	| r |
	r _ AlignmentMorph newRow color: Color transparent.
	r color: (Color transparent); borderWidth: 0; inset: 0.
	r hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center.

	r addMorphBack: (AlignmentMorph newSpacer: r color).
	r addMorphBack: graph.
	r addMorphBack: (AlignmentMorph newSpacer: r color).
	self addMorphBack: r.
	nameMorph width: r width
! !

!ScratchSoundEditorMorph methodsFor: 'initialization' stamp: 'EMP 3/23/2016 12:07'!
addGraph: button

	| r |
	r _ AlignmentMorph newRow.
	r color: (Color transparent); borderWidth: 0; inset: 0.
	r hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center.

	r addMorphBack: (AlignmentMorph newSpacer: r color).
	r addMorphBack: graph.
	r addMorphBack: (AlignmentMorph newSpacer: r color).
	graphBin _ r.
	self addMorphBack: r.
	nameMorph width: r width - (button width + 40).
	button position: nameMorph topRight.
! !

!ScratchSoundEditorMorph methodsFor: 'initialization' stamp: 'EMP 3/4/2016 12:58'!
addNameMorph
	
	| r |
	r _ AlignmentMorph newRow color: Color transparent.
	nameMorph _ UpdatingStringFieldMorph new
		acceptWhenFocusLost: true;
		font: (ScratchFrameMorph getFont: #UpdatingStringField);
		rightJustify: ScratchTranslator isRTL;
		getSelector: #mediaName;
		putSelector: #mediaName:;
		target: self;
		stepTime: 50.

	r addMorph: nameMorph.
	r addMorphBack: (((ScratchFrameMorph buttonLabel: 'save' selector: #save) target: self)).
	self addMorphBack: r.! !

!ScratchSoundEditorMorph methodsFor: 'initialization' stamp: 'EMP 3/23/2016 10:05'!
addPlayButtons

	| r m space |
	r _ AlignmentMorph newColumn.
	r color: (Color transparent); borderWidth: 0; inset: 0.
	r hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center.

	m _ AlignmentMorph newRow.
	m color: Color transparent; borderWidth: 0; inset: 0.
	m hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	m centering: #center.

	space _ Morph new color: r color; extent: 3@5.


	m addMorphBack: ((ToggleButton onForm: (ScratchFrameMorph skinAt: #playButtonEditorPressed) offForm: (ScratchFrameMorph skinAt: #playButtonEditor) overForm: (ScratchFrameMorph skinAt: #playButtonEditorPressed)) actionSelector: #playAfterCursor; isMomentary: true; target: self).
	m addMorphBack: space copy.
	m addMorphBack: ((ToggleButton onForm: (ScratchFrameMorph skinAt: #stopButtonEditorPressed) offForm: (ScratchFrameMorph skinAt: #stopButtonEditor) overForm: (ScratchFrameMorph skinAt: #stopButtonEditorPressed)) actionSelector: #stop; isMomentary: true; target: self).
	r addMorphBack: m.
	
	controls _ r.
	self addMorphBack: controls.

! !

!ScratchSoundEditorMorph methodsFor: 'initialization' stamp: 'EMP 3/23/2016 10:05'!
addSlider

	| r |
	r _ AlignmentMorph newRow.
	r color: (Color transparent); borderWidth: 0; inset: 0.
	r hResizing: #spaceFill; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center.	

	slider _ ScratchScrollBar newHorizontal
		extent: (graph width)@10;
		target: self;
		percentVisible: ((graph width)/(graph data size));
		selector: #scrollTime:.
	
	r addMorph: slider.
	sliderBin _ r.
	self addMorphBack: sliderBin.
! !

!ScratchSoundEditorMorph methodsFor: 'initialization' stamp: 'EMP 10/11/2015 21:43'!
addValueSelectors

	| r m b |
	b _ SimpleButtonMorph new target: self; borderColor: Color black; useSquareCorners.
	b borderColor: #raised; borderWidth: 3.
	r _ AlignmentMorph newRow.
	r color: (Color transparent); borderWidth: 0; inset: 0.
	r hResizing: #spaceFill; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center.

	r addMorphBack: (Morph new color: r color; extent: 5@5).

	"r addMorphBack: (b fullCopy label: '<<';					actionSelector: #slower)."
	r addMorphBack: (b fullCopy label: 'Reset Play Rate';	actionSelector: #resetSamplingRate).
	"r addMorphBack: (b fullCopy label: '>>';					actionSelector: #faster)."

	r addMorphBack: (Morph new color: r color; extent: 25@5).
	m _ StringMorph new contents: 'Sampling Rate'.
	r addMorphBack: m.
	m_ Morph new color: r color; extent: 5@5. "spacer"
	r addMorphBack: m.

	rateSlider _ SimpleSliderMorph new
	color: Color veryVeryLightGray;
	extent: 60@2;
	target: self;
	minVal: 0.2;
	maxVal: 2.5;
	actionSelector: #samplingRate:.
	r addMorphBack: rateSlider.
	r addMorphBack: (Morph new color: r color; extent: 30@5).

	m _ StringMorph new contents: 'Index: '.
	r addMorphBack: m.
	m _ UpdatingStringMorph new
		target: graph; getSelector: #cursor; putSelector: #cursor:;
		growable: false; width: 30; step.
	r addMorphBack: m.
	
	m_ Morph new color: r color; extent: 20@5. "spacer"
	r addMorphBack: m.

	m _ StringMorph new contents: 'Value: '.
	r addMorphBack: m.
	m _ UpdatingStringMorph new
		target: graph; getSelector: #valueAtCursor; putSelector: #valueAtCursor:;
		growable: false; width: 40; step.
	r addMorphBack: m.

	m_ Morph new color: r color; extent: 20@5. "spacer"
	r addMorphBack: m.

	"r addMorphBack: ( b fullCopy label: 'zoom to selection';		actionSelector: #zoomToSelection).
	m _ Morph new color: r color; extent: 5@5.
	r addMorphBack: m."

	self addMorphBack: r.

! !

!ScratchSoundEditorMorph methodsFor: 'initialization' stamp: 'EMP 10/11/2015 21:43'!
addViewer

	| r |

	r _ AlignmentMorph newRow.
	r color: (Color transparent); borderWidth: 0; inset: 0.
	r hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center.

	r addMorphBack: (AlignmentMorph newSpacer: r color).
	r addMorphBack: viewer.
	r addMorphBack: (AlignmentMorph newSpacer: r color).

	self addMorphBack: r.
	
! !

!ScratchSoundEditorMorph methodsFor: 'initialization' stamp: 'EMP 3/23/2016 10:04'!
initialize

	| b |
	super initialize.
	borderWidth _ 2.
	copy _ nil.
	selection _ {nil. nil}.
	scrollDelta _ 0.
	deltaVal _ 10.
	cursor _ 200.
	playCursor _ nil.
	samplingRate _ SoundPlayer samplingRate.
	soundName _ 'sound'.
	self extent: 5@5;
		orientation: #vertical;
		inset: 3;
		borderColor: (Color r: 208/255 g: 209/255 b: 210/255);
		color: (Color r: 242/255 g: 242/255 b: 242/255);
		hResizing: #shrinkWrap;
		centering: #centered;
		vResizing: #shrinkWrap;
		borderWidth: 1.
	graph _ ScratchGraphMorph new extent: 380@150.
	graph editor: self.
	graph selection: selection.
	graph viewer: false.

	viewer _ ScratchGraphMorph new extent: 380@30.
	viewer editor: self.
	viewer cursorColorAtZeroCrossings: Color red.
	viewer viewer: true.
	viewer selection: selection.

	b _ self addNameMorph.
	self addGraph: b.
	self addMorph: (Morph new extent: 5@5; color: Color transparent).
	self addSlider.

	self addMorphBack: (Morph new extent: 5@5; color: Color transparent). "Spacer"

	self addPlayButtons.
! !

!ScratchSoundEditorMorph methodsFor: 'initialization' stamp: 'EMP 10/11/2015 21:43'!
makeSliderButton: buttonExtent

	| button |
	button _ BorderedMorph
		newBounds: (self innerBounds bottomRight - buttonExtent extent: buttonExtent)
		color: (Color transparent).

	button setBorderWidth: 1 borderColor: #raised.
	^ button
! !

!ScratchSoundEditorMorph methodsFor: 'initialization' stamp: 'EMP 10/11/2015 21:11'!
playAfterCursor

	| sel currSel |
	graph data size < 2 ifTrue: [^ self].
	

	sel _ ((selection at: 1) notNil and: [(selection at: 2) - (selection at: 1) > 3]).
	sel ifTrue: [currSel _ graph data copyFrom: (selection at: 1) asInteger to: (selection at: 2) asInteger. playCursor _ selection at: 1.
			    endPlaying _ selection at: 2.]
	    ifFalse: [currSel _ graph data copyFrom: (cursor max: 1) asInteger to: graph data size.
				playCursor _ cursor.
				endPlaying _ graph data size].
	
		self changed.


	snd isNil
		ifTrue: [
				 snd _ (SampledSound samples: currSel samplingRate: origSamplingRate).
				 snd play.]
		ifFalse: [
			currSel = snd samples
				ifTrue: [snd samplesRemaining = 0 ifTrue: [snd reset].
						 snd resumePlaying.]
				ifFalse: [ snd setSamples: currSel samplingRate: origSamplingRate.
						 snd play]].

! !

!ScratchSoundEditorMorph methodsFor: 'initialization' stamp: 'EMP 2/9/2016 16:04'!
scrollTime: t1 
	graph startIndex: graph data size - graph endIndex * t1.
	viewer flushCachedForm; changed! !

!ScratchSoundEditorMorph methodsFor: 'initialization' stamp: 'EMP 12/15/2015 10:26'!
startTime
	
	| secs hrs mins ms |
	secs _ cursor / samplingRate.
	hrs _ secs // 3600.
	mins _ (secs \\ 3600) // 60.
	secs _ secs \\ 60 asFloat.
	ms _ ((secs \\ 1) * 100) asFloat truncated.
	secs _ secs // 1.

	^ hrs asString,':',mins asString, ':', secs asString, '.', ms asString.
	
	"origSamplingRate isNil
		ifTrue: [ss _ 20000]
		ifFalse: [ss _ origSamplingRate].
	^ ((cursor asFloat/ss) roundTo: 0.01) asString "! !


!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 10/11/2015 21:11'!
faster

	| rate |
	rate _ rateSlider getScaledValue*1.1.
	rateSlider setScaledValue: rate.
	self samplingRate: rate.

	! !

!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 10/11/2015 21:11'!
invokeMenu
	"Invoke a menu of additonal functions."

	| aMenu |
	aMenu _ CustomMenu new.
	aMenu addList:	#(
		('save to file'		saveToFile)
		('read from file'	readFromFile)).
	aMenu invokeOn: self defaultSelection: nil.

! !

!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 10/11/2015 21:11'!
origSamplingRate

	^origSamplingRate.
! !

!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 10/11/2015 21:11'!
pause

	(snd notNil and: [snd isPlaying])
		ifTrue: [snd pause.].
! !

!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 10/11/2015 21:11'!
playAll

	"Resumes playing the selection if there is one, otherwise resumes playing the entire soundtrack."

	graph data size < 2 ifTrue: [^ self].
	playCursor _ 1.
	endPlaying _ graph data size.

	snd isNil
		ifTrue: [
				 snd _ (SampledSound samples: graph data samplingRate: origSamplingRate).
				 snd play.]
		ifFalse: [
			snd reset.
			(graph data = snd samples)
				ifTrue: [snd samplesRemaining = 0 ifTrue: [snd reset].
						 snd resumePlaying.]
				ifFalse: [snd setSamples: graph data samplingRate: origSamplingRate.
						 snd play]]
! !

!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 10/11/2015 21:11'!
playFrom: start to: end

	| sz i1 i2 snd2 |
	sz _ graph data size.
	i1 _ ((start + 1) min: sz) max: 1.
	i2 _ ((end + 1) min: sz) max: i1.
	(i1 + 2) >= i2 ifTrue: [^ self].
	snd2 _ SampledSound
		samples: (graph data copyFrom: i1 to: i2)
		samplingRate: samplingRate.
	snd2 play.
! !

!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 10/11/2015 21:11'!
readFromFile
	"Read my samples from a file selected by the user."

	| result |
	result _ StandardFileMenu oldFileExtensions: #(aif aiff au wav).
	result ifNil: [^ self].
	self readFromFile: result directory pathName, FileDirectory slash, result name.
! !

!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 12/14/2015 20:12'!
readFromFile: fName
	"Read my samples from the file with the given name."

	(FileDirectory default fileExists: fName)
		ifFalse: [^ self inform: 'File not found' withDetails: fName].
	snd _ SampledSound fromFileNamed: fName.

	completeSnd _ snd copy.
	graph cursor: 200.
	samplingRate _ snd originalSamplingRate.
	origSamplingRate _ snd originalSamplingRate.
	graph data: snd samples.
	graph scale: 2.0.

	self setVolume: 0.5.
	
	graph data size > 5000
		ifTrue: [deltaVal _ 50]
		ifFalse: [deltaVal _ graph data size // 10].

! !

!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 10/11/2015 21:11'!
resetSamplingRate

	snd ifNil: [^self].

	snd setSamples: snd samples samplingRate: origSamplingRate.
	rateSlider setScaledValue: 1.0.! !

!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 10/11/2015 21:11'!
samplingRate: sampleRate

"Sets the samplingRate to somewhere btw 0.1 and 2.5 the original samplingRate, given a number btw 0.2 and 2.5 (sampleRate)"

	snd ifNil: [^self.].

	origSamplingRate = 0 
		ifFalse: [snd setSamples: snd samples samplingRate: (sampleRate*origSamplingRate)]
		ifTrue: [ snd setSamples: snd samples samplingRate: (sampleRate*10000)].

	
! !

!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 10/11/2015 21:11'!
saveToFile
	"Export my samples to a WAV file."

	| fileName samples f |
	fileName _ StringDialog ask: 'File name?'.
	fileName size = 0 ifTrue: [^ self].
	(fileName asLowercase endsWith: '.wav') ifFalse: [fileName _ fileName, '.wav'].
	(graph data isKindOf: SoundBuffer)
		ifTrue: [samples _ graph data]
		ifFalse: [samples _ SoundBuffer fromArray: graph data].
	f _ (FileStream newFileNamed: fileName) binary.
	(SampledSound samples: samples samplingRate: samplingRate) storeWAVSamplesOn: f.
	f close.
! !

!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 10/11/2015 21:11'!
setVolume: aFloat

	"aFloat is a value btw 0 and 1.0"
	
	snd ifNil: [^self].
	snd adjustVolumeTo: aFloat overMSecs: 50.! !

!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 10/11/2015 21:11'!
slower

	| rate |
	rate _ rateSlider getScaledValue/1.1.
	rateSlider setScaledValue: rate.
	self samplingRate: rate.

	! !

!ScratchSoundEditorMorph methodsFor: 'menu' stamp: 'EMP 10/11/2015 21:11'!
stop

	snd pause.
	playCursor _ nil.
	! !


!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
client: anObject

	client _ anObject.
! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
cursor

	^cursor.! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
cursor: aNumber

	graph data ifNil: [^self].

	cursor ~= aNumber ifTrue:  [
	cursor _ ((aNumber truncated max: 1) min: graph data size) truncated.
	"graph keepIndexInView: cursor."
	].! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
data: newData

	graph data: newData.
! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
endPlaying

	^endPlaying.! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
graph

	^ graph
! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
playCursor
	
	^playCursor.! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
playCursor: aNumber

	graph data ifNil: [^self].

	"allows the graph to set where the playing cursor is"

	cursor ~= aNumber ifTrue:  [
	cursor _ ((aNumber truncated max: 1) min: graph data size) truncated.
	].! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
samplingRate

	^ samplingRate

! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
selection

	^selection.! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
selection: anArrayorNil

	anArrayorNil ifNil: [selection _ {nil. nil}.]
			 ifNotNil: [selection _ anArrayorNil.].
	graph selection: selection.
	viewer selection: selection! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
selection: aNumber scd: anotherNumber

	selection _ { aNumber min: anotherNumber. aNumber max: anotherNumber}.
	graph selection: selection.
	viewer selection: selection.
	graph flushCachedForm; changed.
	viewer flushCachedForm; changed.! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
selectionNil
	
	(selection at: 1) ifNil: [^ true].
	
	^false.! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 12/14/2015 20:00'!
slider 
	^slider! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
sound

	^snd.! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
soundName: aString
	"Note the sound name to use when saving."

	soundName _ aString.
! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
startSelection
		
	^ startSelection.! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
startSelection: aNumber


	startSelection _ aNumber.! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 12/14/2015 19:50'!
updateSliderValue

	^ self


! !

!ScratchSoundEditorMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:11'!
viewer

	^viewer.! !


!ScratchSoundEditorMorph methodsFor: 'event handling' stamp: 'EMP 12/14/2015 15:51'!
handlesMouseDown: evt

	| |
	^ true! !

!ScratchSoundEditorMorph methodsFor: 'event handling' stamp: 'EMP 10/12/2015 15:03'!
handlesMouseOver: evt

	^ true! !

!ScratchSoundEditorMorph methodsFor: 'event handling' stamp: 'EMP 12/15/2015 10:23'!
keyStroke: evt

	| keyVal |
	keyVal _ evt keyCharacter asciiValue.

	keyVal = 28 ifTrue: [ cursor _ cursor + (( -10) / graph scale). graph changed].
	keyVal = 29 ifTrue: [ cursor _ cursor + (10/graph scale). graph changed].! !

!ScratchSoundEditorMorph methodsFor: 'event handling' stamp: 'EMP 12/15/2015 10:20'!
mouseDown: evt

	| p |
	"do stuff"
	p _ evt cursorPoint.
	
	(nameMorph containsPoint: evt cursorPoint) ifFalse: [evt hand newKeyboardFocus: self].
	(slider containsPoint: p) ifTrue: [ 
		slider descending ifTrue: [scrollDelta _ deltaVal negated.]
						  ifFalse: [scrollDelta _ deltaVal]].! !

!ScratchSoundEditorMorph methodsFor: 'event handling' stamp: 'EMP 12/15/2015 10:17'!
mouseEnter: evt


	evt hand keyboardFocus = nameMorph ifTrue: [^ self].
	evt hand newKeyboardFocus: self.! !

!ScratchSoundEditorMorph methodsFor: 'event handling' stamp: 'EMP 12/14/2015 15:51'!
mouseUp: evt

	"do stuff"
	scrollDelta _ 0.! !


!ScratchSoundEditorMorph methodsFor: 'graph ops' stamp: 'EMP 10/11/2015 21:11'!
back
	"Moves the cursor back in the music score."

	scrollDelta _ -5.  
	self cursor: cursor + scrollDelta.! !

!ScratchSoundEditorMorph methodsFor: 'graph ops' stamp: 'EMP 10/11/2015 21:11'!
cancel

	self delete.
! !

!ScratchSoundEditorMorph methodsFor: 'graph ops' stamp: 'EMP 10/11/2015 21:11'!
copy

	"copies the current selection if there is one."
	(selection at: 1) ifNotNil:
		[copy _ graph data copyFrom: (graph selection at: 1) to: (graph selection at: 2).]! !

!ScratchSoundEditorMorph methodsFor: 'graph ops' stamp: 'EMP 10/11/2015 21:11'!
crop
	
	| sel |

	"Crops the sound in the sound editor to be only the selected region"

	sel _ ((selection at: 1) notNil and: [(selection at: 2) - (selection at: 1) > 3]).
	sel ifFalse: [^self].

	undoSel _ graph selection copy.
	undoSound _ SampledSound samples: graph data samplingRate: samplingRate.
	undoCursor _ cursor.
	undoScale _ graph scale/ScratchGraphMorph MinScale.

	sel _ graph data copyFrom: (selection at: 1) to: (selection at: 2).
	graph data: sel.
	viewer data: graph data.
	cursor _ ((cursor - (selection at: 1)) truncated max: 1) min: graph data size truncated.

	"scales the botton viewer so that the data fits on the entire screen." 
	(selection second - selection first)/graph data size >= 0.05
		ifTrue: [ScratchGraphMorph MinScale: (viewer extent x/ graph data size min: 1). "the mult factor in all scales, the minimum scale allowed...to get this just do self scale: 1, since this multiplied by input"
				viewer scale: 1.
				graph scale: 1.
				viewer startIndex: 1.
				graph computeSlider.
				self fixSliderRange.].

	graph calculateDataArray.
	viewer calculateDataArray.

	snd setSamples: sel samplingRate: samplingRate.
	completeSnd setSamples: sel samplingRate: samplingRate.

	selection at: 1 put: 1.
	selection at: 2 put: graph data size.
! !

!ScratchSoundEditorMorph methodsFor: 'graph ops' stamp: 'EMP 10/11/2015 21:11'!
cut 

	| data1 data2 |
	(selection at: 1) ifNil: [^ self.].

	undoSound _ SampledSound samples: graph data samplingRate: samplingRate.
	undoSel _ graph selection copy.
	undoCursor _ cursor.
	undoScale _ graph scale/ScratchGraphMorph MinScale.

	self copy.
	data1 _ graph data copyFrom: 1 to: (selection at: 1).
	data2 _ graph data copyFrom: (selection at: 2) to: graph data size.
	
	graph data: (data1, data2).
	viewer data: graph data.
		
	"scales the botton viewer so that the data fits on the entire screen." 
	((selection second - selection first)/graph data size asFloat) >= 0.05
		ifTrue: [ScratchGraphMorph MinScale: (viewer extent x/ graph data size min: 1).
				viewer scale: 1.
				graph scale: undoScale.
				viewer startIndex: 1.
				graph computeSlider.
				self fixSliderRange.].

	graph calculateDataArray.
	viewer calculateDataArray.

	snd setSamples: graph data samplingRate: samplingRate.
	completeSnd setSamples: graph data samplingRate: samplingRate.
	cursor _ (selection at: 1).
	
	selection at: 1 put: nil. 
	selection at: 2 put: nil.! !

!ScratchSoundEditorMorph methodsFor: 'graph ops' stamp: 'EMP 12/14/2015 19:50'!
fixSliderRange

	^slider! !

!ScratchSoundEditorMorph methodsFor: 'graph ops' stamp: 'EMP 10/11/2015 21:11'!
fwd
	
	"moves the cursor forward in the music."
	scrollDelta _ 5.
	self cursor: cursor + 5.! !

!ScratchSoundEditorMorph methodsFor: 'graph ops' stamp: 'EMP 10/11/2015 21:11'!
paste
	| data1 data2 |
	"inserts the copied data into the dataset where the cursor is."
	
	copy ifNil: [^self ].
	
	"self selectionNil ifTrue: [undoSel _ nil.] ifFalse: [undoSel _ selection copy.]."
	undoSel _ selection copy.
	undoSound _ SampledSound samples: graph data samplingRate: samplingRate.
	undoCursor _ cursor.
	undoScale _ graph scale/ScratchGraphMorph MinScale.


	((self selectionNil not) and: [(selection at: 2) - (selection at: 1) > 3])
		ifTrue: [data1 _ graph data copyFrom: 1 to: (graph selection at: 1).
			     data2 _ graph data copyFrom: (graph selection at: 2) to: graph data size.]
		ifFalse: [data1 _ graph data copyFrom: 1 to: graph cursor truncated.
				 data2 _ graph data copyFrom: graph cursor truncated + 1 to: graph data size.].
	
	graph data: (data1, copy, data2).
	viewer data: graph data.

	"scales the botton viewer so that the data fits on the entire screen." 
	(copy size)/graph data size >= 0.05
		ifTrue: [ScratchGraphMorph MinScale: (viewer extent x/ graph data size min: 1).
				viewer scale: 1.
				graph scale: undoScale.
				self fixSliderRange.
				viewer startIndex: 1.
				graph computeSlider.].

	

	graph calculateDataArray.
	viewer calculateDataArray.

	snd setSamples: graph data samplingRate: samplingRate.
	completeSnd setSamples: graph data samplingRate: samplingRate.

	self selection: {data1 size. (data1 size) + (copy size).}.
	cursor _ selection at: 2.
	graph startIndex: (slider getScaledValue)*(graph data size).

	viewer flushCachedForm.
		! !

!ScratchSoundEditorMorph methodsFor: 'graph ops' stamp: 'EMP 12/15/2015 10:34'!
save

	snd _ SampledSound samples: completeSnd samples samplingRate: samplingRate.
	client ifNotNil: [client saveSound: snd name: soundName].
! !

!ScratchSoundEditorMorph methodsFor: 'graph ops' stamp: 'EMP 12/15/2015 10:13'!
sound: aSampledSound

	"completeSnd is a version of the sound that is unaffected by the play mechanism.  This method is called when a SoundMorph brings up a SoundEditor. soundMorphSound is a copy of the initial sampledSound, used for saving and cancelling edits purposes.  It serves as a reference to the original sound so that we can actually change the sound in the soundMorph"

	soundMorphSound _ aSampledSound.
	snd _ aSampledSound copy.
	completeSnd _ snd copy.
	graph cursor: 200.
	samplingRate _ snd originalSamplingRate.
	origSamplingRate _ snd originalSamplingRate.

	ScratchGraphMorph MinScale: (graph extent x/completeSnd samples size).

	graph data: completeSnd samples.  "SHOULD IT BE COPY?/"
	graph scale: 2.
	graph calculateDataArray.
	"self fixSliderRange.
	graph computeSlider."
	
	viewer data: completeSnd samples.
	viewer scale: 1.
	viewer calculateDataArray.
	self setVolume: snd loudness.
	
	(graph data size > 5000)
		ifTrue: [deltaVal _ 200]
		ifFalse: [deltaVal _ (graph data size) // 10].

	self updateSlider! !

!ScratchSoundEditorMorph methodsFor: 'graph ops' stamp: 'EMP 10/11/2015 21:11'!
startTime: hrMinSecs
	
	| secs hrs mins hms |
	hms _ hrMinSecs findTokens: ' :.'.
	hrs _ hms at: 1.
	mins _ hms at: 2.
	secs _ hms at: 3.
	self startIndex: ((hrs asNumber * 3600) + (mins asNumber * 60) + secs asNumber) * samplingRate.
! !

!ScratchSoundEditorMorph methodsFor: 'graph ops' stamp: 'EMP 10/11/2015 21:11'!
undo


	| tmpSound tmpSel tmpCursor tmpScale |

	undoSound ifNil: [^self].

	tmpSound _ SampledSound samples: graph data samplingRate: samplingRate.
	tmpSel _ graph selection copy.
	tmpCursor _ cursor.
	tmpScale _ graph scale/ScratchGraphMorph MinScale.

	graph data: undoSound samples copy.
	viewer data: graph data.
	
	"scales the botton viewer so that the data fits on the entire screen." 
	(tmpSound samples size - graph data size) abs > 3
		ifTrue: [ScratchGraphMorph MinScale: ((viewer extent x/ graph data size) min: 1).
				viewer scale: 1.
				graph scale: undoScale.
				viewer startIndex: 1.
				graph computeSlider.
				self fixSliderRange.].

	graph calculateDataArray.
	viewer calculateDataArray.

	snd setSamples: graph data samplingRate: samplingRate.
	completeSnd setSamples: graph data samplingRate: samplingRate.
	self selection: undoSel copy.
	cursor _ undoCursor.

	undoSound _ tmpSound.
	undoSel _ tmpSel.
	undoCursor _ tmpCursor.
	undoScale _ tmpScale.
! !


!ScratchSoundEditorMorph methodsFor: 'stepping' stamp: 'EMP 3/23/2016 12:07'!
fixLayout
	super fixLayout.
	nameMorph isNil | graphBin isNil | controls isNil | sliderBin isNil ifTrue: [^ self].
	graphBin position: (nameMorph bottomLeft + (0@3)).
	sliderBin position: (graphBin bottomLeft + (0@3)).
	controls position: (sliderBin bottomLeft + (0@3)).! !

!ScratchSoundEditorMorph methodsFor: 'stepping' stamp: 'EMP 4/7/2016 12:23'!
resizeIfNeeded
	owner ifNotNil: [
		owner owner ifNotNil: [
	self extent = (((owner owner owner right - (owner owner owner left + 100)) max: (graphBin width + 9)) @ (owner owner owner height - 65)) ifFalse: [self emergencyExtent: (((owner owner owner right - (owner owner owner left + 100)) max: (graphBin width + 9)) @ (owner owner owner height - 65)). self otherPosition: (owner owner owner topLeft + (80@30))]]].! !

!ScratchSoundEditorMorph methodsFor: 'stepping' stamp: 'EMP 4/7/2016 15:39'!
step

	| played prev |
	owner ifNotNil: [
		owner owner ifNotNil: [
	self extent = (((owner owner owner right - (owner owner owner left + 100)) max: (graphBin width + 9)) @ (owner owner owner height - 65)) ifFalse: [self resizeIfNeeded]]].
		(SoundPlayer isPlaying: snd) ifTrue: [
		played _ ((snd millisecondsSinceStart) * snd samples size) / (1000.0 * snd duration).
		prev _ (completeSnd samples size - snd samples size).
		playCursor _ (played + prev truncated min: graph data size).
		self changed].
	scrollDelta = 0 ifFalse: [
		graph startIndex: graph startIndex + (scrollDelta/graph scale).
		self updateSliderValue.].
	graph step.
	graph computeSlider.
	self fixSliderRange.! !

!ScratchSoundEditorMorph methodsFor: 'stepping' stamp: 'EMP 12/15/2015 10:08'!
stepTime


	^ 0! !


!ScratchSoundEditorMorph methodsFor: 'other' stamp: 'EMP 3/4/2016 12:57'!
mediaName
	^ soundName! !

!ScratchSoundEditorMorph methodsFor: 'other' stamp: 'EMP 10/11/2015 21:11'!
normalize: sampleArray
	"Return a copy of the given sample array scaled to use the maximum 16-bit sample range. Remove any D.C. offset."

	| max abs scale out |
	max _ 0.
	sampleArray do: [:s |
		s > 0 ifTrue: [abs _ s] ifFalse: [abs _ 0 - s].
		abs > max ifTrue: [max _ abs]].
	scale _ ((1 << 15) - 1) asFloat / max.

	out _ sampleArray species new: sampleArray size.
	1 to: sampleArray size do: [:i |
		out at: i put: (scale * (sampleArray at: i)) truncated].
	^ out
! !

!ScratchSoundEditorMorph methodsFor: 'other' stamp: 'EMP 10/11/2015 21:11'!
stretch: sampleArray by: stretchFactor
	"Return an array consisting of the given samples \stretched in time by the given factor."

	| out end incr i frac index |
	out _ OrderedCollection new: (stretchFactor * sampleArray size) asInteger + 1.
	end _ (sampleArray size - 1) asFloat.
	incr _ 1.0 / stretchFactor.
	i _ 1.0.
	[i < end] whileTrue: [
		frac _ i fractionPart.
		index _ i truncated.
		i _ i + incr.
		out addLast:
			(((1.0 - frac) * (sampleArray at: index)) + (frac * (sampleArray at: index + 1))) rounded].
	^ out asArray
! !

!ScratchSoundEditorMorph methodsFor: 'other' stamp: 'EMP 10/11/2015 21:11'!
updateSlider

	"this is the order that these methods have to be called in order to update slider!!!!!!"
	graph computeSlider.  
	self fixSliderRange.
	self updateSliderValue.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchSoundEditorMorph class
	instanceVariableNames: ''!

!ScratchSoundEditorMorph class methodsFor: 'instance creation' stamp: 'EMP 10/11/2015 21:11'!
openOn: dataCollection
	"Open a new WaveEditor on the given sequencable collection of data."

	^ (self new data: dataCollection) openInWorld
! !

!ScratchSoundEditorMorph class methodsFor: 'instance creation' stamp: 'EMP 10/11/2015 21:14'!
test
	"ScratchSoundEditorMorph test"
	^ self new openInWorld! !


!ScratchSoundEditorMorph class methodsFor: 'icons' stamp: 'EMP 10/11/2015 22:03'!
downArrow

	^ (ScratchFrameMorph skinAt: #arrowOpenComment)"Form
		extent: 10@12
		depth: 4
		fromArray: #(3722304989 3707764736 3722304989 3707764736 3704479196 3170893824 3692739489 3170893824 3550548241 1023410176 3720417563 3707764736 3711570339 3707764736 3722121645 3707764736 3722252605 3707764736 3722296285 3707764736 3722261469 3707764736 3722304989 3707764736)
		offset: 0@0"
! !

!ScratchSoundEditorMorph class methodsFor: 'icons' stamp: 'EMP 10/11/2015 22:04'!
upArrow
	"Uparrow form used in slider." 

	^ ((ScratchFrameMorph skinAt: #arrowOpenComment) rotateBy: 180)"Form
		extent: 6@3
		fromArray: #(2r11e28 2r1111e27 2r111111e26)
		offset: 0@0"
! !
