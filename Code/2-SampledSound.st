AbstractSound subclass: #SampledSound
	instanceVariableNames: 'initialCount count samples originalSamplingRate samplesSize scaledIndex indexHighBits scaledIncrement scaledInitialIndex '
	classVariableNames: 'CoffeeCupClink IncrementFractionBits IncrementScaleFactor NominalSamplePitch ScaledIndexOverflow '
	poolDictionaries: ''
	category: 'Sound-Synthesis'!

!SampledSound methodsFor: 'initialization' stamp: 'jm 1/18/1999 06:42'!
pitch: pitchNameOrNumber

	| p |
	p _ self nameOrNumberToPitch: pitchNameOrNumber.
	originalSamplingRate _
		((self samplingRate asFloat * p asFloat) / NominalSamplePitch asFloat) asInteger.
	self reset.
! !

!SampledSound methodsFor: 'initialization' stamp: 'jm 9/27/2003 12:23'!
setPitch: pitchNameOrNumber dur: d loudness: vol
	"Used to play scores using the default sample table."
	"(SampledSound pitch: 880.0 dur: 1.5 loudness: 0.6) play"

	| p |
	super setPitch: pitchNameOrNumber dur: d loudness: vol.
	p _ self nameOrNumberToPitch: pitchNameOrNumber.
	"samples _ DefaultSampleTable."
	samplesSize _ samples size.
	initialCount _ (d * self samplingRate asFloat) rounded.
	originalSamplingRate _
		((self samplingRate asFloat * p asFloat) / NominalSamplePitch asFloat) asInteger.
	self loudness: vol.
	self reset.
! !

!SampledSound methodsFor: 'initialization' stamp: 'jm 7/20/2003 22:26'!
setSamples: anArray from: startIndex to: endIndex samplingRate: rate loudness: loudness
	"Initialize me to play the given range of the given array at the given sampling rate."

	| buf |
	anArray class isWords ifFalse: [
		"convert the subarray into a SoundBuffer"
		buf _ SoundBuffer fromArray: (anArray copyFrom: startIndex to: endIndex).
		^ self setSamples: buf samplingRate: rate].

	anArray class isWords
		ifTrue: [samples _ anArray]
		ifFalse: [samples _ SoundBuffer fromArray: anArray].

	samplesSize _ samples size.
	originalSamplingRate _ rate.
	self loudness: loudness.
	initialCount _ ((endIndex - (startIndex - 1)) * SoundPlayer samplingRate) // rate.
	scaledInitialIndex _ startIndex * IncrementScaleFactor.  "scaled index of the first sample to play"
	self reset.
! !

!SampledSound methodsFor: 'initialization' stamp: 'jm 7/9/1999 19:23'!
setSamples: anArray samplingRate: rate
	"Set my samples array to the given array with the given nominal sampling rate. Altering the rate parameter allows the sampled sound to be played back at different pitches."
	"Note: There are two ways to use sampled sound: (a) you can play them through once (supported by this method) or (b) you can make them the default waveform with which to play a musical score (supported by the class method defaultSampleTable:)."
	"Assume: anArray is either a SoundBuffer or a collection of signed 16-bit sample values."
	"(SampledSound
		samples: SampledSound coffeeCupClink
		samplingRate: 5000) play"

	"copy the array into a SoundBuffer if necessary"
	anArray class isWords
		ifTrue: [samples _ anArray]
		ifFalse: [samples _ SoundBuffer fromArray: anArray].

	samplesSize _ samples size.
	samplesSize >= SmallInteger maxVal ifTrue: [  "this is unlikely..."
		self error: 'sample count must be under ',  SmallInteger maxVal printString].
	originalSamplingRate _ rate.
	initialCount _ (samplesSize * self samplingRate) // originalSamplingRate.
	self loudness: 1.0.
	self reset.
! !


!SampledSound methodsFor: 'accessing' stamp: 'jm 8/23/2003 18:51'!
currentPosition
	"Answer the current position of the playback head in seconds since the start of this sound (at the original sampling)."

	| sampleIndex |
	sampleIndex _ indexHighBits + (scaledIndex >> IncrementFractionBits).
	^ sampleIndex asFloat / originalSamplingRate
! !

!SampledSound methodsFor: 'accessing' stamp: 'jm 3/28/98 05:46'!
duration

	^ initialCount asFloat / self samplingRate asFloat
! !

!SampledSound methodsFor: 'accessing' stamp: 'jm 9/11/1998 15:39'!
duration: seconds

	super duration: seconds.
	count _ initialCount _ (seconds * self samplingRate) rounded.
! !

!SampledSound methodsFor: 'accessing' stamp: 'jm 10/12/2007 21:39'!
equals: aSampledSound
	"Answer true if the receiver is exactly the same as the given SampledSound."

	self == aSampledSound ifTrue: [^ true].

	self class = aSampledSound class ifFalse: [^ false].
	(originalSamplingRate = aSampledSound originalSamplingRate) ifFalse: [^ false].

	^ samples = aSampledSound samples
! !

!SampledSound methodsFor: 'accessing' stamp: 'jm 12/15/97 22:51'!
originalSamplingRate

	^ originalSamplingRate
! !

!SampledSound methodsFor: 'accessing' stamp: 'jm 8/23/2003 18:12'!
playbackRate
	"Answer the playback rate."

	^ (scaledIncrement * self samplingRate) asFloat /
		(originalSamplingRate * IncrementScaleFactor)
! !

!SampledSound methodsFor: 'accessing' stamp: 'jm 8/23/2003 18:15'!
playbackRate: aNumber
	"Set the playback rate."

	| rate |
	rate _ aNumber asFloat max: 0.01.
	scaledIncrement _
		((rate * originalSamplingRate * IncrementScaleFactor) / self samplingRate) rounded.
! !

!SampledSound methodsFor: 'accessing' stamp: 'jm 9/12/97 16:46'!
samples

	^ samples
! !


!SampledSound methodsFor: 'playing' stamp: 'bf 5/11/2012 17:04'!
mixSampleCount: n into: aSoundBuffer startingAt: startIndex leftVol: leftVol rightVol: rightVol
	"Mix the given number of samples with the samples already in the given buffer starting at the given index. Assume that the buffer size is at least (index + count) - 1."

	| lastIndex outIndex sampleIndex sample i s overflow |
	<primitive:'primitiveMixSampledSound' module:'SoundGenerationPlugin'>
	self var: #aSoundBuffer declareC: 'short int *aSoundBuffer'.
	self var: #samples declareC: 'short int *samples'.

	lastIndex _ (startIndex + n) - 1.
	outIndex _ startIndex.    "index of next stereo output sample pair"
	sampleIndex _ indexHighBits + (scaledIndex >> IncrementFractionBits).
	[(sampleIndex <= samplesSize) and: [outIndex <= lastIndex]] whileTrue: [
		sample _ ((samples at: sampleIndex) * scaledVol) // ScaleFactor.
		leftVol > 0 ifTrue: [
			i _ (2 * outIndex) - 1.
			s _ (aSoundBuffer at: i) + ((sample * leftVol) // ScaleFactor).
			s >  32767 ifTrue: [s _  32767].  "clipping!!"
			s < -32767 ifTrue: [s _ -32767].  "clipping!!"
			aSoundBuffer at: i put: s].
		rightVol > 0 ifTrue: [
			i _ 2 * outIndex.
			s _ (aSoundBuffer at: i) + ((sample * rightVol) // ScaleFactor).
			s >  32767 ifTrue: [s _  32767].  "clipping!!"
			s < -32767 ifTrue: [s _ -32767].  "clipping!!"
			aSoundBuffer at: i put: s].

		scaledVolIncr ~= 0 ifTrue: [
			scaledVol _ scaledVol + scaledVolIncr.
			((scaledVolIncr > 0 and: [scaledVol >= scaledVolLimit]) or:
			 [scaledVolIncr < 0 and: [scaledVol <= scaledVolLimit]])
				ifTrue: [  "reached the limit; stop incrementing"
					scaledVol _ scaledVolLimit.
					scaledVolIncr _ 0]].

		scaledIndex _ scaledIndex + scaledIncrement.
		scaledIndex >= ScaledIndexOverflow ifTrue: [
			overflow _ scaledIndex >> IncrementFractionBits.
			indexHighBits _ indexHighBits + overflow.
			scaledIndex _ scaledIndex - (overflow << IncrementFractionBits)].

		sampleIndex _ indexHighBits + (scaledIndex >> IncrementFractionBits).
		outIndex _ outIndex + 1].
	count _ count - n.
! !

!SampledSound methodsFor: 'playing' stamp: 'jm 7/15/2003 12:29'!
reset
	"Details: The sample index and increment are scaled to allow fractional increments without having to do floating point arithmetic in the inner loop."

	super reset.
	scaledIncrement _
		((originalSamplingRate asFloat / self samplingRate) * IncrementScaleFactor) rounded.
	count _ initialCount.
	scaledIndex _ IncrementScaleFactor.  "index of the first sample, scaled"
	scaledInitialIndex ifNotNil: [scaledIndex _ scaledInitialIndex].
	indexHighBits _ 0.
! !

!SampledSound methodsFor: 'playing' stamp: 'jm 9/13/97 19:07'!
samplesRemaining

	^ count
! !

!SampledSound methodsFor: 'playing' stamp: 'jm 9/9/1998 21:58'!
stopAfterMSecs: mSecs
	"Terminate this sound this note after the given number of milliseconds."

	count _ (mSecs * self samplingRate) // 1000.
! !


!SampledSound methodsFor: 'file i/o' stamp: 'jm 12/3/2003 17:28'!
storeSampleCount: samplesToStore bigEndian: bigEndianFlag on: aBinaryStream
	"Store my samples on the given stream at the current SoundPlayer sampling rate. If bigFlag is true, then each 16-bit sample is stored most-significant byte first (AIFF files), otherwise it is stored least-significant byte first (WAV files)."

	self samplingRate ~= originalSamplingRate ifTrue: [
		^ super storeSampleCount: samplesToStore bigEndian: bigEndianFlag on: aBinaryStream].

	"optimization: if sampling rates match, just store my buffer"
	samples storeOn: aBinaryStream bigEndian: bigEndianFlag stereo: false.
! !


!SampledSound methodsFor: 'object i/o' stamp: 'jm 9/25/2003 10:32'!
fieldsVersion

	^ 1
! !

!SampledSound methodsFor: 'object i/o' stamp: 'jm 9/28/2003 18:44'!
initFieldsFrom: anObjStream version: classVersion

	self initFieldsNamed: #(
		envelopes
		scaledVol
		initialCount
		samples
		originalSamplingRate
		samplesSize
		scaledIncrement
		scaledInitialIndex 
	) from: anObjStream.
! !

!SampledSound methodsFor: 'object i/o' stamp: 'jm 9/28/2003 18:44'!
storeFieldsOn: anObjStream

	self storeFieldsNamed: #(
		envelopes
		scaledVol
		initialCount
		samples
		originalSamplingRate
		samplesSize
		scaledIncrement
		scaledInitialIndex 
	) on: anObjStream.
! !


!SampledSound methodsFor: 'as yet unclassified' stamp: 'EMP 3/8/2016 16:09'!
copyWithArray: newCollection
	"Answer a copy of the receiver that is 1 bigger than the receiver and has 
	newElement at the last element."

	| newIC |
	newIC _ self species newMonoSampleCount: self size + newCollection size.
	newIC 
		replaceFrom: 1
		to: self size
		with: self
		startingAt: 1.
	newIC replaceFrom: (self size + 1) to: (newIC size) with: newCollection startingAt: 1.
	^newIC! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SampledSound class
	instanceVariableNames: ''!

!SampledSound class methodsFor: 'class initialization' stamp: 'jm 12/16/2006 18:57'!
initialize
	"SampledSound initialize"

	IncrementFractionBits _ 16.
	IncrementScaleFactor _ 2 raisedTo: IncrementFractionBits.
	ScaledIndexOverflow _ 2 raisedTo: 29.  "handle overflow before needing LargePositiveIntegers"
	NominalSamplePitch _ 400.
! !


!SampledSound class methodsFor: 'instance creation' stamp: 'jm 8/29/2006 11:40'!
fromFileNamed: fileName
	"Read a sound from the file of the given name. The resulting sound may be a SampledSound (mono) or a MixedSound (stereo)."
	"(SampledSound fromFileNamed: 'test.aif') play"

	| f id snd |
	f _ (FileStream readOnlyFileNamed: fileName) binary.
	id _ (f next: 4) asString.
	f position: 0.
	id = 'RIFF' ifTrue: [snd _ self readWAVFrom: f].
	id = 'FORM' ifTrue: [snd _ self readAIFFrom: f].
	id = '.snd' ifTrue: [snd _ self readSNDFrom: f].
	f close.
	snd ifNotNil: [^ snd].

	([MPEGFile isFileValidMPEG: fileName] ifError: [false]) ifTrue: [
		snd _ self readMP3FromFileNamed: (FileDirectory default fullNameFor: fileName)].

	snd ifNil: [self error: 'Unrecognized audio file format'].
	^ snd
! !

!SampledSound class methodsFor: 'instance creation' stamp: 'jm 9/12/97 19:20'!
samples: anArrayOf16BitSamples samplingRate: samplesPerSecond
	"Return a SampledSound with the given samples array and sampling rate."

	^ self new setSamples: anArrayOf16BitSamples samplingRate: samplesPerSecond
! !


!SampledSound class methodsFor: 'coffee cup clink' stamp: 'jm 12/4/2003 19:58'!
coffeeCupClink
	"Return the samples array for the sound of a spoon being tapped against a coffee cup."

	CoffeeCupClink ifNil: [CoffeeCupClink _ SoundBuffer fromArray: self coffeeCupSamples].
	^ CoffeeCupClink
! !

!SampledSound class methodsFor: 'coffee cup clink' stamp: 'jm 12/4/2003 20:03'!
coffeeCupSamples
	"Answer an array of 16-bit samples for the sound of a spoon being tapped against a coffee cup."

	^ #(768 1024 -256 2304 -13312 26624 32512 19200 6400 -256 5888 32512 28928 32512 -32768 32512 -32768 18688 26368 -26112 32512 32512 2304 32512 5632 2816 10240 -4608 -1792 32512 32512 -5376 10752 32512 32512 32512 8192 15872 32512 -3584 -32768 -23296 -24832 -32768 -32768 -32768 -2304 32512 32512 -32768 32512 -15360 6400 8448 -18176 -32768 -256 -32768 -29440 9472 20992 17920 32512 32512 -256 32512 -32768 -32768 -23040 -32768 -25088 -32768 -27648 -1536 24320 -32768 32512 20480 27904 22016 16384 -32768 32512 -27648 -32768 -7168 28160 -6400 5376 32512 -256 32512 -7168 -11776 -19456 -27392 -24576 -32768 -24064 -19456 12800 32512 27136 2048 25344 15616 8192 -4608 -28672 -32768 -30464 -2560 17664 256 -8192 8448 32512 27648 -6144 -512 -7424 -18688 7936 -256 -22272 -14080 2048 27648 15616 -12288 -768 5376 3328 5632 3072 -6656 -20480 10240 27136 -10752 -11008 -768 -2048 6144 -7168 -3584 -1024 -7680 19712 26112 1024 -11008 3072 16384 -8960 -14848 -4864 -23808 -11264 12288 8192 7168 4864 23040 32512 512 -11776 -5632 -16896 -21504 -12800 -6144 -16896 -4352 32512 32512 23296 21760 5632 2816 -9472 -20992 -11264 -29440 -32768 -3584 7680 8448 15360 32512 32512 15616 15104 -2048 -27904 -27904 -25600 -12288 -12032 -13568 17152 22272 15360 30208 28160 7680 -5632 -8192 -16384 -31744 -25856 -10752 -3840 6656 13056 24320 26368 12800 20736 12288 -19200 -20992 -16640 -21504 -17920 -6912 8448 11264 14080 23040 18176 8192 -1024 0 256 -20992 -19712 -4608 -11264 -2048 14080 12032 8192 6912 13056 9216 -5632 -5376 -3840 -6656 -9984 -5632 4864 -3584 -1280 17408 7680 -1280 4096 2816 -1024 -4864 3328 8448 -768 -5888 -2048 5120 0 3072 11008 -7680 -15360 2560 6656 -3840 0 11776 7680 2816 1536 -1280 -3840 -8704 -1536 3584 -9728 -9728 11776 18688 7680 6656 6400 -4864 -3840 -256 -6912 -13312 -11264 2304 9728 1792 3328 18944 18432 6912 6144 -1536 -17664 -14336 -2304 -10496 -15616 -4096 9728 17152 14848 13312 11520 2304 -1024 2560 -8704 -26624 -18688 -256 -256 2816 14080 13824 12544 14080 9728 -512 -12032 -8960 -3328 -9984 -15872 -5120 8192 3584 10496 20224 7936 4608 6144 1280 -8704 -12800 -7424 -8448 -8960 -3840 7424 13056 8704 13312 13056 -2304 -4864 -768 -7168 -10496 -4608 -1536 -3072 -1280 6144 13312 11008 4864 4864 1536 -8960 -7680 1792 -4864 -7680 2816 5632 3328 2560 5376 7936 3584 -512 512 -4608 -9728 0 9216 768 -4096 7680 7168 256 4608 -768 -8704 -6400 2048 6144 -3072 -3328 6400 9472 3840 -768 1792 -3840 -5120 6144 768 -9984 -4352 5120 9472 6912 2816 1792 1280 768 512 -2816 -9728 -6912 6912 6912 -3328 -768 8448 11776 10752 3328 -6912 -10752 -8704 -1536 0 -6912 -3328 9984 13568 7424 6144 6656 256 0 256 -12032 -17920 -8192 3584 8960 4096 5632 12032 8704 6912 5632 -3584 -10496 -7936 -2048 -9216 -11776 2304 9472 15104 14848 5888 512 -2816 1024 2560 -9984 -13312 -5120 768 1792 768 8448 12032 11264 12800 -256 -11264 -9728 -2304 3072 -4352 -6912 256 2304 5376 9984 8192 2816 1280 3584 -2048 -11008 -8448 -2048 3072 4864 2304 3072 3072 3072 7168 3328 -5376 -4864 512 512 -1792 -1792 1792 5376 5888 5888 512 -5888 -3584 4096 3584 -6400 -4864 4608 3072 3840 5376 1024 768 2816 5888 -768 -12288 -7936 2304 5888 3328 2048 6144 3072 3072 6400 -3328 -7168 256 4096 -512 -9472 -6656 3328 6912 9216 8704 3840 -2560 -256 6656 -2560 -11264 -4608 -768 -1280 1536 3072 4096 5120 9984 11264 1024 -8192 -6144 -1024 -3840 -5632 -512 1024 2304 9728 9728 1280 512 4096 2816 -3584 -9984 -6912 -2304 512 5632 7680 3584 1024 5632 5888 -1280 -3584 -2304 -2560 -1536 -1024 -1792 -512 1536 7680 9984 2048 -2048 2048 3328 -1280 -4096 -3328 -4608 -1280 4352 3328 1280 1792 5120 6912 1024 -2560 0 -768 -1024 1280 -256 -4608 -1280 6400 5120 768 1792 2560 2048 0 -1536 -1280 -2304 1024 5376 2560 -2560 -512 4096 2048 512 768 -1280 -256 2560 2560 -256 -1024 768 3584 1280 -3328 -1536 1792 2816 3328 2304 -256 256 2816 2304 -1280 -3328 -1536 2304 2304 -256 -256 1024 1536 3840 5120 1024 -2048 0 1536 -768 -2560 -1792 256 2304 2048 1536 256 768 5888 6656 256 -3840 -2304 -1280 -1536 256 0 -512 2304 4352 3840 768 0 2304 3072 256 -3072 -2560 -2560 256 4608 2560 256 1536 3072 3072 1792 256 256 512 -256 -768 -1280 -1536 768 4352 2816 -512 768 2560 2560 2304 -256 -1792 -768 768 1792 256 -2304 -256 3328 3840 2304 2304 1536 256 2048 1024 -1536 -1792 -1024 512 256 -512 0 2304 4864 5120 4352 1024 -1280 0 -768 -2816 -2304 -512 1024 2048 2304 2048 3072 3840 2816 2048 -512 -3072 -1792 -1536 -1280 768 1280 1536 2304 2816 2048 1536 2048 1536 1536 -768 -3840 -2048 0 1280 2816 1792 1536 2560 3584 2816 1024 256 -768 -768 -1280 -2816 -768 1792 3328 5120 3072 1280 1536 1792 768 -1024 -1280 -1536 -768 512 256 1536 2560 2560 3328 1280 0 768 1536 768 -256 -512 -1536 -1280 768 1280 2304 2560 2560 2560 1024 -256 -512 0 1280 1536 768 -1280 -512 2048 1536 2048 1280 -256 256 512 768 768 1280 2304 1792 512 -1280 -1024 768 1536 1536 256 -768 1536 3584 3072 1792 -256 -1536 -512 256 -512 -512 768 2048 2048 1792 1280 1280 3072 2816 768 -1024 -2304 -1024 256 256 1280 1792 2304 2816 2304 1280 512 1024 768 -768 -1280 -1280 -512 1536 2560 2816 2048 512 1024 1792 1280 768 0 -768 -768 0 256 256 1280 2560 2304 2304 1536 512 512 1024 1280 0 -1792 -1536 -512 1280 3072 2816 1792 512 1024 1536 256 -256 768 768 256 256 -256 512 1280 1280 1536 768 1024 1792 1536 1024 0 256 -512 -256 1024 512 256 768 1792 2304 1280 256 768 1024 1280 1792 768 -768 -768 768 512 256 1024 1792 1536 1280 1536 1792 1280 768 512 -512 -1792 -512 512 768 2304 2816 1792 768 1536 2304 1536 0 -256 -256 -768 -768 256 1536 1536 2304 2048 256 768 2048 2304 1280 0 -256 -1024 -1024 0 1024 1792 2304 2304 1280 512 1280 2048 1280 256 -512 -1792 -1536 256 1536 1792 2048 2048 2048 1536 512 512 768 256 -256 0 -512 -1024 768 2048 2304 2304 1280 1280 1024 1024 1024 0 -512 256 768 0 -256 1536 2304 1792 2304 1280 -512 -256 768 1536 1024 256 512 512 1024 1792 1792 1536 1024 1280 0 -1280 256 2048 2560 2048 1024 -256 -256 1024 1280 1536 1024 0 0 256 768 1792 2304 2048 1280 1024 0 -512 -256 256 1024 1024 512 768 768 1280 2048 1792 1024 768 768 -256 -1024 0 256 1024 1536 1024 1280 1536 1792 1792 1024 512 512 0 -512 -256 512 768 1280 1280 1024 1280 1792 1792 1280 512 -256 -256 256 512 1280 1024 1280 1280 1024 1024 768 1024 1024 1024 1280 256 256 768 768 1024 512 256 768 1280 2560 2560 1280 512 -256 -512 -256 1024 1536 768 1024 1280 768 1024 1536 1536 1024 256 0 0 0 768 768 512 1280 1536 1280 1280 1280 1280 768 768 256 -256 768 768 256 768 1280 1792 1536 1536 1536 256 512 1024 0 -768 -256 768 512 1024 2048 1536 1024 1536 1536 768 0 0 -256)
! !


!SampledSound class methodsFor: 'conversions' stamp: 'bf 5/11/2012 17:04'!
convert8bitSignedFrom: aByteArray to16Bit: aSoundBuffer
	"Copy the contents of the given array of signed 8-bit samples into the given array of 16-bit signed samples."

	| n s |
	<primitive: 'primitiveConvert8BitSigned' module: 'MiscPrimitivePlugin'>
	self var: #aByteArray declareC: 'unsigned char *aByteArray'.
	self var: #aSoundBuffer declareC: 'unsigned short *aSoundBuffer'.
	n _ aByteArray size.
	1 to: n do: [:i |
		s _ aByteArray at: i.
		s > 127
			ifTrue: [aSoundBuffer at: i put: ((s - 256) bitShift: 8)]
			ifFalse: [aSoundBuffer at: i put: (s bitShift: 8)]].
! !

!SampledSound class methodsFor: 'conversions' stamp: 'jm 2/15/98 18:13'!
convert8bitSignedTo16Bit: aByteArray
	"Convert the given array of samples--assumed to be 8-bit signed, linear data--into 16-bit signed samples. Return an array containing the resulting samples. Typically used to read uncompressed AIFF sound data."

	| result |
	result _ SoundBuffer newMonoSampleCount: aByteArray size.
	self convert8bitSignedFrom: aByteArray to16Bit: result.
	^ result
! !

!SampledSound class methodsFor: 'conversions' stamp: 'jm 12/4/2003 19:30'!
convert8bitUnsignedTo16Bit: anArray
	"Convert the given array of samples--assumed to be 8-bit unsigned, linear data--into 16-bit signed samples. Return an array containing the resulting samples."

	| n samples s |
	n _ anArray size.
	samples _ SoundBuffer newMonoSampleCount: n.
	1 to: n do: [:i |
		s _ anArray at: i.
		samples at: i put: (s - 128) * 256].
	^ samples
! !


!SampledSound class methodsFor: 'mulaw encode/decode' stamp: 'jm 9/17/97 13:11'!
uLawDecode: aByteArray
	"Convert the given array of uLaw-encoded 8-bit samples into a SoundBuffer of 16-bit signed samples."

	| n out decodingTable |
	n _ aByteArray size.
	out _ SoundBuffer newMonoSampleCount: n.
	decodingTable _ self uLawDecodeTable.
	1 to: n do: [:i | out at: i put: (decodingTable at: (aByteArray at: i) + 1)].
	^ out
! !

!SampledSound class methodsFor: 'mulaw encode/decode' stamp: 'jm 9/13/97 16:41'!
uLawDecodeTable
	"Return a 256 entry table to be used to decode 8-bit uLaw-encoded samples."
	"Details: This table was computed as follows:
		| d encoded lastEncodedPos lastEncodedNeg |
		d _ Array new: 256.
		lastEncodedPos _ nil.
		lastEncodedNeg _ nil.
		4095 to: 0 by: -1 do: [:s |
			encoded _ SampledSound uLawEncodeSample: s.
			lastEncodedPos = encoded
				ifFalse: [
					d at: (encoded + 1) put: (s bitShift: 3).
					lastEncodedPos _ encoded].
			encoded _ encoded bitOr: 16r80.
			lastEncodedNeg = encoded
				ifFalse: [
					d at: (encoded + 1) put: (s bitShift: 3) negated.
					lastEncodedNeg _ encoded]].
		d "

	^ #(32760 31608 30584 29560 28536 27512 26488 25464 24440 23416 22392 21368 20344 19320 18296 17272 16248 15736 15224 14712 14200 13688 13176 12664 12152 11640 11128 10616 10104 9592 9080 8568 8056 7800 7544 7288 7032 6776 6520 6264 6008 5752 5496 5240 4984 4728 4472 4216 3960 3832 3704 3576 3448 3320 3192 3064 2936 2808 2680 2552 2424 2296 2168 2040 1912 1848 1784 1720 1656 1592 1528 1464 1400 1336 1272 1208 1144 1080 1016 952 888 856 824 792 760 728 696 664 632 600 568 536 504 472 440 408 376 360 344 328 312 296 280 264 248 232 216 200 184 168 152 136 120 112 104 96 88 80 72 64 56 48 40 32 24 16 8 0 -32760 -31608 -30584 -29560 -28536 -27512 -26488 -25464 -24440 -23416 -22392 -21368 -20344 -19320 -18296 -17272 -16248 -15736 -15224 -14712 -14200 -13688 -13176 -12664 -12152 -11640 -11128 -10616 -10104 -9592 -9080 -8568 -8056 -7800 -7544 -7288 -7032 -6776 -6520 -6264 -6008 -5752 -5496 -5240 -4984 -4728 -4472 -4216 -3960 -3832 -3704 -3576 -3448 -3320 -3192 -3064 -2936 -2808 -2680 -2552 -2424 -2296 -2168 -2040 -1912 -1848 -1784 -1720 -1656 -1592 -1528 -1464 -1400 -1336 -1272 -1208 -1144 -1080 -1016 -952 -888 -856 -824 -792 -760 -728 -696 -664 -632 -600 -568 -536 -504 -472 -440 -408 -376 -360 -344 -328 -312 -296 -280 -264 -248 -232 -216 -200 -184 -168 -152 -136 -120 -112 -104 -96 -88 -80 -72 -64 -56 -48 -40 -32 -24 -16 -8 0)
! !

!SampledSound class methodsFor: 'mulaw encode/decode' stamp: 'jm 12/4/2003 19:25'!
uLawEncode: anArray
	"Convert the given array of 16-bit signed samples into a ByteArray of uLaw-encoded 8-bit samples."

	| n out s |
	n _ anArray size.
	out _ ByteArray new: n.
	1 to: n do: [:i |
		s _ anArray at: i.
		s _ s bitShift: -3.  "drop 3 least significant bits"
		s < 0
			ifTrue: [s _ (self uLawEncodeSample: s negated) bitOr: 16r80]
			ifFalse: [s _ (self uLawEncodeSample: s)].
		out at: i put: s].
	^ out
! !

!SampledSound class methodsFor: 'mulaw encode/decode' stamp: 'jm 9/13/97 15:40'!
uLawEncodeSample: s
	"Encode the given 16-bit signed sample using the uLaw 8-bit encoding."

	s < 496 ifTrue: [
		s < 112 ifTrue: [
			s < 48 ifTrue: [
				s < 16
					ifTrue: [^ 16r70 bitOr: (15 - s)]
					ifFalse: [^ 16r60 bitOr: (15 - ((s - 16) bitShift: -1))]].
			^ 16r50 bitOr: (15 - ((s - 48) bitShift: -2))].
		s < 240
			ifTrue: [^ 16r40 bitOr: (15 - ((s - 112) bitShift: -3))]
			ifFalse: [^ 16r30 bitOr: (15 - ((s - 240) bitShift: -4))]].

	s < 2032 ifTrue: [
		s < 1008
			ifTrue: [^ 16r20 bitOr: (15 - ((s - 496) bitShift: -5))]
			ifFalse: [^ 16r10 bitOr: (15 - ((s - 1008) bitShift: -6))]].

	s < 4080
		ifTrue: [^ 15 - ((s - 2032) bitShift: -7)]
		ifFalse: [^ 0].
! !


!SampledSound class methodsFor: 'file reading support' stamp: 'jm 12/4/2003 09:54'!
findWAVEChunk: chunkID in: aBinaryStream ifAbsent: notFoundBlock
	"Search the given stream from its beginning for a chunk with the given four-letter id and answer the size of the chunk. The stream is left positioned at the start of the chunk data. If  no chunk of the given type is found, answer the result of evaluating notFoundBlock."

	| id count |
	aBinaryStream position: 0.
	id _ (aBinaryStream next: 4) asString.
	id = 'RIFF' ifFalse: [^ self error: 'Not a RIFF file'].
	aBinaryStream skip: 4.  "skip total length"

	id _ (aBinaryStream next: 4) asString.
	id = 'WAVE' ifFalse: [^ self error: 'Not a WAVE file'].

	[aBinaryStream atEnd] whileFalse: [
		id _ (aBinaryStream next: 4) asString.
		count _ aBinaryStream littleEndianUint32.
		id = chunkID ifTrue: [^ count].
		aBinaryStream skip: (count roundUpTo: 2)].  "skip this chunk. round size up to next even number"

	^ notFoundBlock value
! !

!SampledSound class methodsFor: 'file reading support' stamp: 'jm 12/4/2003 18:05'!
infoForWAVFileNamed: fileName asString: stringFlag
	"Answer the encoding information for the WAV file of the given name."

	| f count header s type channels samplingRate bitsPerSample |
	f _ (FileStream readOnlyFileNamed: fileName) binary.
	count _ self findWAVEChunk: 'fmt ' in: f ifAbsent: [^ self error: 'Bad WAV file'].
	header _ f next: count.

	"process format chunk"
	s _ ReadStream on: header.
	type _ s littleEndianUint16.
	channels _ s littleEndianUint16.
	samplingRate _ s littleEndianUint32.
	s littleEndianUint32.  "average bytes per second"
	s littleEndianUint16.  "block alignment"
	bitsPerSample _ s littleEndianUint16.

	f close.

	stringFlag
		ifTrue: [
			^ fileName, ': ', samplingRate printString, ', ',
				(channels > 2
					ifTrue: [channels printString, ' channels, ']
					ifFalse: [channels = 1 ifTrue: ['mono, '] ifFalse: ['stereo, ']]),
				bitsPerSample printString, '-bit',
				(type = 1 ifTrue: [''] ifFalse: [' format=', type printString])]
		ifFalse: [
			^ Array with: samplingRate with: channels with: bitsPerSample with: type].
! !

!SampledSound class methodsFor: 'file reading support' stamp: 'jm 12/4/2003 18:33'!
readAIFFrom: aBinaryStream
	"Read a sound in AIFF format from the given stream."

	| aiff channels samplingRate |
	aiff _ AIFFFileReader new.
	aiff readFromStream: aBinaryStream mergeIfStereo: true skipDataChunk: false.
	channels _ aiff channelData size.
	samplingRate _ aiff samplingRate.

	"build sound object"
	channels = 1 ifTrue: [^ self samples: (aiff channelData at: 1) samplingRate: samplingRate].
	channels = 2 ifTrue: [
		^ MixedSound new
			add: (self samples: (aiff channelData at: 1) samplingRate: samplingRate) pan: 0.0;
			add: (self samples: (aiff channelData at: 2) samplingRate: samplingRate) pan: 1.0;
			yourself].

	 self error: 'Unsupported number of channels: ', channels printString.

! !

!SampledSound class methodsFor: 'file reading support' stamp: 'jm 3/20/2007 23:15'!
readMP3FromFileNamed: fileName
	"Read a sound in MP3 format from the file with the given name. Answer true if successful."

	| mpegFile channels sampleCount samplingRate buf1 snd buf2 |
	(MPEGFile isFileValidMPEG: fileName) ifFalse: [^ self error: 'Bad MP3 file: ', fileName].
	mpegFile _ MPEGFile openFile: fileName.
	channels _ mpegFile audioChannels: 0. "assume sound track is in stream 0"
	channels > 2 ifTrue: [
		mpegFile close.
		^ self error: 'Unsupported number of channels: ', channels printString].

	sampleCount _ mpegFile audioSamples: 0.
	samplingRate _ mpegFile audioSampleRate: 0.
	buf1 _ SoundBuffer newMonoSampleCount: sampleCount.
	mpegFile audioReadBuffer: buf1 stream: 0 channel: 0.

	"build sound object"
	channels = 1 ifTrue: [snd _ self samples: buf1 samplingRate: samplingRate].
	channels = 2 ifTrue: [
		buf2 _ SoundBuffer newMonoSampleCount: sampleCount.
		mpegFile audioReReadBuffer: buf2 stream: 0 channel: 1.
		snd _ MixedSound new
			add: (self samples: buf1 samplingRate: samplingRate) pan: 0.0;
			add: (self samples: buf2 samplingRate: samplingRate) pan: 1.0;
			yourself].

	mpegFile closeFile.
	^ snd
! !

!SampledSound class methodsFor: 'file reading support' stamp: 'jm 12/5/2003 18:02'!
readSNDFrom: aBinaryStream
	"Read a sound in Sun Audio format from the given stream."
	"A few formats in use:
		1	muLaw
		2	8-bit linear
		3	16-bit linear"

	| id hdrSize count encoding samplingRate channels data leftAndRight |
	"read the header"
	id _ (aBinaryStream next: 4) asString.
	id = '.snd' ifFalse: [^ self error: 'Not a Sun Audio (.au) file'].
	hdrSize _ aBinaryStream uint32.
 	count _ aBinaryStream uint32.
	encoding _ aBinaryStream uint32.
	samplingRate _ aBinaryStream uint32.
	channels _ aBinaryStream uint32.
	aBinaryStream skip: (hdrSize - 24).

	"check the format"
	((encoding >= 1) & (encoding <= 3)) ifFalse: [
		^ self error: 'Unsupported Sun Audio (.au) format: ', encoding printString].

	encoding = 1 ifTrue: [data _ self uLawDecode: (aBinaryStream next: count)].
	encoding = 2 ifTrue: [data _ self convert8bitSignedTo16Bit: (aBinaryStream next: count)].
	encoding = 3 ifTrue: [
		data _ SoundBuffer newMonoSampleCount: count // 2.
		aBinaryStream next: (count // 4) into: data startingAt: 1.  "size is in 32-bit words"
		Smalltalk isBigEndian ifFalse: [data reverseEndiannessStereo: (channels = 2)]].

	"build sound object"
	channels = 1 ifTrue: [^ self samples: data samplingRate: samplingRate].
	channels = 2 ifTrue: [
		leftAndRight _ data splitStereo.
		^ MixedSound new
			add: (self samples: leftAndRight first samplingRate: samplingRate) pan: 0.0;
			add: (self samples: leftAndRight last samplingRate: samplingRate) pan: 1.0;
			yourself].

	 self error: 'Unsupported number of channels: ', channels printString.

! !

!SampledSound class methodsFor: 'file reading support' stamp: 'EMP 3/14/2016 14:23'!
readWAVFrom: aBinaryStream
	"Answer a new instance of me from the windows WAV file with the given name. Currently, only formats 1 (uncompressed 8-bit or 16-bit) and 7 (muLaw) WAV files can be read."
	"A few formats in use:
		 1	PCM audio in integer format
		 2	Microsoft adaptive PCM
		 7	muLaw
		17	Intel DVI_ADPCM
		85	ISO/MPEG Layer 3"

	| count header s encoding channels samplingRate bitsPerSample data leftAndRight blockSize |
	count _ self findWAVEChunk: 'fmt ' in: aBinaryStream ifAbsent: [^ self error: 'Bad WAV file'].
	header _ aBinaryStream next: count.

	"process format chunk"
	s _ ReadStream on: header.
	encoding _ s littleEndianUint16.
	channels _ s littleEndianUint16.
	samplingRate _ s littleEndianUint32.
	s littleEndianUint32.  "average bytes per second"
	blockSize _ s littleEndianUint16.  "block alignment"
	bitsPerSample _ s littleEndianUint16.

	"check the format"
	((encoding = 1) | (encoding = 7) | (encoding = 17)) ifFalse: [ "Added encoding = 17 to work with Scratch 2. ALso added bitsPerSample=4 and made it do that correctly"
		^ self error: 'Unsupported WAV format: ', encoding printString].
	((bitsPerSample = 4) | (bitsPerSample = 8) | (bitsPerSample = 16)) ifFalse: [
		^ self error: 'Unsupported wave bits/sample: ', bitsPerSample printString].

	"read samples"
	count _ self findWAVEChunk: 'data' in: aBinaryStream ifAbsent: [^ self error: 'Bad WAV file'].

	bitsPerSample = 8
		ifTrue: [
			data _ aBinaryStream next: count.
			(encoding = 1) ifTrue: [data _ self convert8bitUnsignedTo16Bit: data].
			encoding = 7 ifTrue: [data _ self uLawDecode: data]]
		ifFalse: [
			bitsPerSample = 4 ifTrue: [
			data _ aBinaryStream next: count.
			(encoding = 1) ifTrue: [data _ self convert8bitUnsignedTo16Bit: data].
			(encoding = 7) ifTrue: [data _ self uLawDecode: data].
			(encoding = 17) ifTrue: [data _ self imaDecompress: aBinaryStream blockSize: blockSize]]
			ifFalse: [
				data _ SoundBuffer newMonoSampleCount: count // 2.
				aBinaryStream next: (count // 4) into: data startingAt: 1.  "size is in 32-bit words"
				Smalltalk isBigEndian ifTrue: [data reverseEndiannessStereo: (channels = 2)]]].

	"build sound object"
	channels = 1 ifTrue: [^ self samples: data samplingRate: samplingRate].
	channels = 2 ifTrue: [
		leftAndRight _ data splitStereo.
		^ MixedSound new
			add: (self samples: leftAndRight first samplingRate: samplingRate) pan: 0.0;
			add: (self samples: leftAndRight last samplingRate: samplingRate) pan: 1.0;
			yourself].

	 self error: 'Unsupported number of channels: ', channels printString.
! !


!SampledSound class methodsFor: 'ima decode' stamp: 'EMP 3/14/2016 14:23'!
convert4bitUnsignedTo16Bit: anArray
	"Convert the given array of samples--assumed to be 4-bit unsigned, linear data--into 16-bit signed samples. Return an array containing the resulting samples."

	| n samples byte left right |
	n _ anArray size.
	samples _ SoundBuffer newStereoSampleCount: n.
	1 to: n do: [:i |
    byte _ anArray at: i.
    left _ (byte - 8) bitAnd: 15.                 "lower 4 bits"
    right _ ((byte - 8) >> 4) bitAnd: 15.         "upper 4 bits"
    samples at: (i * 2) put: (left - 8) << 12.
    samples at: ((i * 2) - 1) put: (right - 8) << 12].
	^ samples! !

!SampledSound class methodsFor: 'ima decode' stamp: 'EMP 3/9/2016 12:06'!
imaDecode: number
	| n |
	n _ number.
	n >= 128 ifTrue: [n _ n - 256].
	^ (n) * 16! !

!SampledSound class methodsFor: 'ima decode' stamp: 'EMP 3/14/2016 14:55'!
imaDecompress: compressedData blockSize: blockSize
	| sample index step code delta lastByte out |
	sample _ index _ step _ code _ delta _ 0.
	lastByte _ -1.
	compressedData binary.
	out _ OrderedCollection new.
	(compressedData size = 0) ifTrue: [^ SoundBuffer newMonoSampleCount: 0].
	compressedData position: 0.
	[true] whileTrue: [
	(((compressedData position \\ blockSize) = 0) & (lastByte < 0)) ifTrue: [
	"read block header"
		(compressedData bytesAvailable = 0) ifTrue: [^ (SoundBuffer newMonoSampleCount: 0)].
		sample _ compressedData int16.
		index _ compressedData next.
		compressedData next. "skip extra header byte"
		(index > 88) ifTrue: [index _ 88].
		out add: sample.
	] ifFalse: [
		"read 4-bit code and compute data from previous sample"
		(lastByte < 0) ifTrue: [
			(compressedData bytesAvailable < 4) ifTrue: [^ (SoundBuffer newMonoSampleCount: out size) replaceFrom: 1 to: (out size) with: out startingAt: 1].
			lastByte _ compressedData next.
			code _ (lastByte - 8) bitAnd: 15]
		 ifFalse: [
			code _ ((lastByte - 8) >> 4) bitAnd: 15.
			lastByte _ -1].
	step _ (self imaDviStepTable at: (index + 1) ifAbsent: [^ DialogBoxMorph inform: '1']) - 1.
	delta _ 0.
	((code bitAnd: 4) = 1) ifTrue: [delta _ delta + step].
	((code bitAnd: 3) = 1) ifTrue: [delta _ delta + (step >> 1)].
	((code bitAnd: 2) = 1) ifTrue: [delta _ delta + (step >> 2)].
	delta _ delta + (step >> 3).
	index _ index + (self imaDviIndexTable at: (code + 1)).
	index _ (code min: 88) max: 0.
	sample _ sample + (((code bitAnd: 8) = 1) ifTrue: [delta * -1] ifFalse: [delta]).
	sample _ (sample min: 32767) max: -32767.
	out add: sample].
].! !

!SampledSound class methodsFor: 'ima decode' stamp: 'EMP 3/14/2016 14:53'!
imaDviIndexTable
	^ #(-1 -1 -1 -1 2 4 6 8 -1 -1 -1 -1 2 4 6 8)! !

!SampledSound class methodsFor: 'ima decode' stamp: 'EMP 3/14/2016 14:55'!
imaDviStepTable
	true ifTrue: [^ self uLawDecodeTable].
	^ #(7 8 9 10 11 12 13 14 16 17 19 21 23 25 28 31 34 37 41 45 50 55 60 66 73 80 88 97 107 118 130 143 157 173 190 209 230 253 279 307 337 371 408 449 494 544 598 658 724 796 876 963 1060 1166 1282 1411 1552 1707 1878 2066 2272 2499 2749 3024 3327 3660 4026 4428 4871 5358 5894 6484 7132 7845 8630 9493 10442 11487 12635 13899 15289 16818 18500 20350 22385 24623 27086 29794 32767) reversed! !


SampledSound initialize!
