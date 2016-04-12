DialogBoxMorph subclass: #ScratchSoundRecorderDialogMorph
	instanceVariableNames: 'recorder timerMorph currentMode recordMeter modeButtonsPane client duration savedMeterLevels curStep recorderBackgroundLeft recorderBackgroundCenter recorderBackgroundRight '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Sound'!

!ScratchSoundRecorderDialogMorph methodsFor: 'initialization' stamp: 'jm 3/21/2008 14:10'!
buttonType: type action: actionSelector
	"Answer a new button with the given type and selector. The button target will be me and it will use custom forms."

	| onForm offForm overForm disabledForm |
	onForm _ ScratchFrameMorph skinAt: ('record', type, 'ButtonPressed').
	offForm _ ScratchFrameMorph skinAt: ('record', type, 'Button').
	overForm _ ScratchFrameMorph skinAt: ('record', type, 'ButtonOver').
	disabledForm _ ScratchFrameMorph skinAt: ('record', type, 'ButtonDisabled').

	^ ToggleButton new
		isMomentary: false;
		onForm: onForm offForm: offForm overForm: overForm disabledForm: disabledForm;
		label: '' font: (ScratchFrameMorph getFont: #SoundRecorderButton);
		target: self;
		actionSelector: actionSelector.
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'initialization' stamp: 'ee 9/16/2005 10:13'!
convertToMmss: aNumber
	"Answer a string of the form MM:SS. For displaying a time in seconds as hours, minutes, and seconds."

	| mm ss |
	mm _ ((aNumber // 60) \\ 60) printString.
	"mm size < 2 ifTrue: [mm _ '0', mm]."
	ss _ (aNumber \\ 60) printString.
	ss size < 2 ifTrue: [ss _ '0', ss].
	^ mm, ':', ss
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'initialization' stamp: 'ee 6/28/2008 14:37'!
initialize

	super initialize.

	self makeModeButtonsPane.
	self makeRecordMeter.
	self makeRecordTimer.

	recorder _ ScriptableScratchMorph soundRecorder stopRecording.
	recorder recordLevel: 0.5.
	savedMeterLevels _ OrderedCollection new.
	curStep _ 1.
	
	duration _ 0.
	self setMode: #stop.
	self setMode: #play isDisabled: true.

	"fixes layout"
	mainColumn centering: #topLeft.
	self extent: 380@145.
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'initialization' stamp: 'ee 6/26/2008 17:52'!
makeModeButtonsPane

	| button tempBin |

	modeButtonsPane _ AlignmentMorph newRow vResizing: #shrinkWrap.
	modeButtonsPane color: Color transparent.
	#(play stop record) do: [:n |
		button _ (self buttonType: n asString capitalized action: n).
		button setProperty: #balloonText toValue: n asString localized.
		modeButtonsPane addMorphBack: button].

	tempBin _ AlignmentMorph newRow
		color: Color transparent;
		centering: #center.
	tempBin
		addMorphBack: modeButtonsPane;
		addMorphBack: buttonRow.
	mainColumn addMorphBack: tempBin.
	bottomSpacer delete.
	bottomSpacer _ nil.
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'initialization' stamp: 'ee 6/26/2008 17:55'!
makeRecordMeter

	recorderBackgroundLeft _ (ScratchFrameMorph skinAt: #recorderBackgroundLeft).
	recorderBackgroundCenter _ (ScratchFrameMorph skinAt: #recorderBackgroundCenter).
	recorderBackgroundRight _ (ScratchFrameMorph skinAt: #recorderBackgroundRight).

	recordMeter _ ScratchRecordMeter new.
	mainColumn
		addMorphFront: (Morph new extent: 5@5; color: Color transparent);
		addMorphFront: recordMeter.
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'initialization' stamp: 'ee 6/26/2008 17:55'!
makeRecordTimer

	"timer"
	timerMorph _ StringMorph  "morph to display the duration"
		contents: (self convertToMmss: 0)
		font: (ScratchFrameMorph getFont: #SoundRecorderTimer).
	timerMorph color: Color darkGray.
	fileInfoColumn
		addMorphBack: (Morph new extent: (5@5); color: Color transparent);
		addMorphBack: timerMorph.
! !


!ScratchSoundRecorderDialogMorph methodsFor: 'accessing' stamp: 'ee 6/16/2005 12:08'!
client: anObject

	client _ anObject.
! !


!ScratchSoundRecorderDialogMorph methodsFor: 'drawing' stamp: 'ee 6/28/2008 14:35'!
drawOn: aCanvas

	| p clipC lastX |

	super drawOn: aCanvas.

	"draw recorder meter background, scalable"
	recorderBackgroundCenter ifNil: [^ self].

	clipC _ aCanvas copyClipRect: self fullBounds.
	p _ (self bounds topLeft + (20@(recordMeter top - self top - 3))) + (recorderBackgroundLeft width@0).
	clipC paintImage: recorderBackgroundLeft at: (self bounds topLeft + (20@(recordMeter top - self top - 3))).
	lastX _ (self bounds right - 66) - (recorderBackgroundRight width).
	[p x <= lastX] whileTrue: [
		clipC paintImage: recorderBackgroundCenter at: p.
		p _ (p x + recorderBackgroundCenter width) @ p y].
	clipC paintImage: recorderBackgroundRight at: ((self bounds right - 66) - recorderBackgroundRight width)@(self bounds top + (recordMeter top - self top - 3)).
! !


!ScratchSoundRecorderDialogMorph methodsFor: 'button commands' stamp: 'jm 5/10/2006 11:37'!
cancelled
	"Cancel button was pressed."

	recorder pause.
	recorder clearRecordedSound.
	super cancelled.
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'button commands' stamp: 'ee 6/23/2005 14:33'!
play

	recorder pause.
	recorder playback.
	curStep _ 1.
	self
		setMode: #play;
		setMode: #record isDisabled: true.
	self changed.! !

!ScratchSoundRecorderDialogMorph methodsFor: 'button commands' stamp: 'EMP 12/15/2015 09:24'!
qyes

	| samples samplingRate snd |
	self stop.
	samples _ recorder condensedSamples.
	samplingRate _ recorder samplingRate.
	samplingRate = 44100 ifTrue: [
		samples _ samples downSampledLowPassFiltering: false.
		samplingRate _ 22050].
	snd _ SampledSound samples: samples samplingRate: samplingRate.
	(client notNil and: [samples size > 0]) ifTrue: [
		client saveNewSound: snd name: 'recording' localized,'1'].
	recorder clearRecordedSound.
	super yes.
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'button commands' stamp: 'ee 6/26/2005 01:11'!
record

	recorder isActive ifFalse:[
		recorder clearRecordedSound.
		recorder resumeRecording.
		savedMeterLevels _ OrderedCollection new.
		duration _ 0.
		self
			setMode: #record;
			setMode: #play isDisabled: false.
		self changed].
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'button commands' stamp: 'jm 8/22/2006 07:49'!
setMode: aSymbol
	"Update the highlighting of my tool buttons."

	| modeButtons |
	currentMode _ aSymbol.
	modeButtons _ modeButtonsPane submorphs select: [:m | m isKindOf: ToggleButton].

	modeButtons do: [:b |
		b actionSelector = currentMode
			ifTrue: [b isDisabled: false. b on]
			ifFalse: [b off]].
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'button commands' stamp: 'jm 8/22/2006 07:49'!
setMode: aSymbol isDisabled: aBoolean

	| modeButtons |
	modeButtons _ modeButtonsPane submorphs select: [:m | m isKindOf: ToggleButton].

	modeButtons do: [:b |
		b actionSelector = aSymbol ifTrue: [b isDisabled: aBoolean]].
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'button commands' stamp: 'jm 9/25/2006 11:59'!
stop

	recorder isActive ifTrue: [
		recorder pause.
		recorder trim: 1300 normalizedVolume: 80.0].
	self
		setMode: #stop;
		setMode: #play isDisabled: false;
		setMode: #record isDisabled: false.
	recorder recordedSound
		ifNil: [duration _ 0.0]
		ifNotNil: [duration _ recorder recordedSound duration].
	self updateTime.
	self changed.
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'button commands' stamp: 'EMP 12/15/2015 07:00'!
yes

	| samples samplingRate snd |
	self stop.
	samples _ recorder condensedSamples.
	samplingRate _ recorder samplingRate.
	samplingRate = 44100 ifTrue: [
		samples _ samples downSampledLowPassFiltering: false.
		samplingRate _ 22050].
	snd _ SampledSound samples: samples samplingRate: samplingRate.
	(client notNil and: [samples size > 0]) ifTrue: [
		client saveNewSound: snd name: 'recording' localized,'1'].
	recorder clearRecordedSound.
	super yes.
! !


!ScratchSoundRecorderDialogMorph methodsFor: 'stepping' stamp: 'ee 6/16/2005 12:24'!
startStepping
	"Make the level meter active when dropped into the world. Do nothing if already recording. Note that this will cause other recorders to stop recording..."

	super startStepping.
	recorder isPaused ifTrue: [
		SoundRecorder allSubInstancesDo: [:r | r stopRecording].  "stop all other sound recorders"
		recorder pause].  "meter is updated while paused"
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'stepping' stamp: 'jm 9/20/2005 16:08'!
step

	| m |
	recorder isPaused
		ifTrue: [(currentMode = #play)
			ifTrue: [
				(recorder recordedSound notNil and: [recorder recordedSound isPlaying])
					ifTrue: [
						duration _ recorder recordedSound millisecondsSinceStart // 1000.
						(curStep < savedMeterLevels size) 
							ifTrue: [recordMeter setLevel: (savedMeterLevels at: curStep)].
						curStep _ curStep + 1.
						self updateTime]
					ifFalse: [self stop]]
			ifFalse: [recordMeter setLevel: 0.0]]
		ifFalse: [
			duration _ duration + 0.2.
			self updateTime.
			m _ recorder meterLevel*3.
			recordMeter setLevel: m.
			savedMeterLevels add: m.].
		! !

!ScratchSoundRecorderDialogMorph methodsFor: 'stepping' stamp: 'ee 6/20/2005 15:58'!
stepTime

	"^ 50"
	^ 200.
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'stepping' stamp: 'ee 6/20/2005 13:10'!
stopStepping
	"Turn off recording."

	super stopStepping.
	recorder stopRecording.
! !

!ScratchSoundRecorderDialogMorph methodsFor: 'stepping' stamp: 'ee 9/16/2005 10:12'!
updateTime

	timerMorph contents: (self convertToMmss: duration rounded).! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchSoundRecorderDialogMorph class
	instanceVariableNames: ''!

!ScratchSoundRecorderDialogMorph class methodsFor: 'instance creation' stamp: 'ee 6/20/2005 12:47'!
forClient: aScriptableScratchMorph
	"SoundRecorderDialogMorph forClient: "

	| dialog |
	dialog _ super new
		withButtonsForYes: false no: false okay: true cancel: true;
		client: aScriptableScratchMorph;
		title: 'Sound Recorder'.
	^ dialog getUserResponse! !
