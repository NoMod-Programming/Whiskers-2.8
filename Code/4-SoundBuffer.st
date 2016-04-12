ArrayedCollection variableWordSubclass: #SoundBuffer
	instanceVariableNames: ''
	classVariableNames: 'EndianTest '
	poolDictionaries: ''
	category: 'Sound-Synthesis'!
!SoundBuffer commentStamp: '<historical>' prior: 0!
SoundBuffers store 16 bit unsigned quantities.  !


!SoundBuffer methodsFor: 'accessing' stamp: 'tk 3/13/2000 14:46'!
bytesPerElement
	"Number of bytes in each item.  This multiplied by (self size)*8 gives the number of bits stored."
	^ 2! !

!SoundBuffer methodsFor: 'accessing' stamp: 'EMP 3/8/2016 16:14'!
copyWithArray: newCollection
	"Answer a copy of the receiver that is 1 bigger than the receiver and has 
	newElement at the last element."

	| newIC |
	newIC _ self species new: super size + newCollection size + 1.
	newIC 
		replaceFrom: 1
		to: self size
		with: self
		startingAt: 1.
	newIC replaceFrom: (super size) to: (newIC size) with: newCollection startingAt: 1.
	^newIC! !

!SoundBuffer methodsFor: 'accessing' stamp: 'jm 9/17/97 13:00'!
monoSampleCount
	"Return the number of monaural 16-bit samples that fit into this SoundBuffer."

	^ super size * 2
! !

!SoundBuffer methodsFor: 'accessing' stamp: 'jm 9/17/97 13:28'!
size
	"Return the number of 16-bit sound samples that fit in this sound buffer. To avoid confusion, it is better to get the size of SoundBuffer using monoSampleCount or stereoSampleCount."

	^ self monoSampleCount
! !

!SoundBuffer methodsFor: 'accessing' stamp: 'jm 9/17/97 13:01'!
stereoSampleCount
	"Return the number of stereo slices that fit into this SoundBuffer. A stereo 'slice' consists of two 16-bit samples, one for each channel."

	^ super size
! !


!SoundBuffer methodsFor: 'primitives' stamp: 'jm 9/17/97 13:03'!
at: index
	"Return the 16-bit integer value at the given index of the receiver."

	<primitive: 143>
	index isInteger ifTrue: [self errorSubscriptBounds: index].
	index isNumber ifTrue: [^ self at: index truncated].
	self errorNonIntegerIndex.
! !

!SoundBuffer methodsFor: 'primitives' stamp: 'jm 9/17/97 13:03'!
at: index put: value
	"Store the given 16-bit integer at the given index in the receiver."

	<primitive: 144>
	index isInteger
		ifTrue: [
			(index >= 1 and: [index <= self size])
				ifTrue: [self errorImproperStore]
				ifFalse: [self errorSubscriptBounds: index]].
	index isNumber ifTrue: [^ self at: index truncated put: value].
	self errorNonIntegerIndex.
! !

!SoundBuffer methodsFor: 'primitives' stamp: 'jm 9/2/97 16:07'!
primFill: aPositiveInteger
	"Fill the receiver, an indexable bytes or words object, with the given positive integer. The range of possible fill values is [0..255] for byte arrays and [0..(2^32 - 1)] for word arrays."
	"Note: Since 16-bit word arrays are not built into the virtual machine, this primitive fills by 32-bit words."

	<primitive: 145>
	self errorImproperStore.
! !


!SoundBuffer methodsFor: 'utilities' stamp: 'jm 8/15/1998 13:03'!
asByteArray
	"Answer a ByteArray containing my sample data serialized in most-significant byte first order."

	| sampleCount bytes dst s |
	sampleCount _ self monoSampleCount.
	bytes _ ByteArray new: 2 * sampleCount.
	dst _ 0.
	1 to: sampleCount do: [:src |
		s _ self at: src.
		bytes at: (dst _ dst + 1) put: ((s bitShift: -8) bitAnd: 255).
		bytes at: (dst _ dst + 1) put: (s bitAnd: 255)].
	^ bytes

	! !

!SoundBuffer methodsFor: 'utilities' stamp: 'jm 3/16/2007 21:39'!
beginsWith: aCollection
	"Return true if I begin with the samples in the given collection (usually a SoundBuffer or Array)."

	self size >= aCollection size ifFalse: [^ false].
	1 to: aCollection size do: [:i |
		(self at: i) = (aCollection at:i) ifFalse: [^ false]].

	^ true
! !

!SoundBuffer methodsFor: 'utilities' stamp: 'jm 7/20/2004 22:30'!
compressBy: anInteger
	"Answer an array where each element is the maximum absolute value over a block of the given number of samples. The resulting buffer will be my size / anInteger."

	| samplesPerBucket inCount out outI inI maxVal v |
	samplesPerBucket _ anInteger rounded.
	inCount _ self monoSampleCount.
	out _ Array new: inCount // samplesPerBucket withAll: 0.
	outI _ inI _ 1.
	maxVal _ 0.
	[inI < inCount] whileTrue: [
		v _ self at: inI.
		v < 0 ifTrue: [v _ 0 - v].
		v > maxVal ifTrue: [maxVal _ v].
		(inI \\ samplesPerBucket) = 0 ifTrue: [
			out at: outI put: maxVal.
			outI _ outI + 1.
			maxVal _ 0].
		inI _ inI + 1].
	^ out
! !

!SoundBuffer methodsFor: 'utilities' stamp: 'jm 8/18/1998 06:49'!
downSampledLowPassFiltering: doFiltering
	"Answer a new SoundBuffer half the size of the receiver consisting of every other sample. If doFiltering is true, a simple low-pass filter is applied to avoid aliasing of high frequencies. Assume that receiver is monophonic."
	"Details: The simple low-pass filter in the current implementation could be improved, at some additional cost."

	| n resultBuf j |
	n _ self monoSampleCount.
	resultBuf _ SoundBuffer newMonoSampleCount: n // 2.
	j _ 0.
	doFiltering
		ifTrue: [
			1 to: n by: 2 do: [:i |
				resultBuf at: (j _ j + 1) put:
					(((self at: i) + (self at: i + 1)) bitShift: -1)]]
		ifFalse: [
			1 to: n by: 2 do: [:i |
				resultBuf at: (j _ j + 1) put: (self at: i)]].

	^ resultBuf! !

!SoundBuffer methodsFor: 'utilities' stamp: 'jm 8/18/1998 06:52'!
extractLeftChannel
	"Answer a new SoundBuffer half the size of the receiver consisting of only the left channel of the receiver, which is assumed to contain stereo sound data."

	| n resultBuf j |
	n _ self monoSampleCount.
	resultBuf _ SoundBuffer newMonoSampleCount: n // 2.
	j _ 0.
	1 to: n by: 2 do: [:i | resultBuf at: (j _ j + 1) put: (self at: i)].
	^ resultBuf! !

!SoundBuffer methodsFor: 'utilities' stamp: 'jm 8/18/1998 06:53'!
extractRightChannel
	"Answer a new SoundBuffer half the size of the receiver consisting of only the right channel of the receiver, which is assumed to contain stereo sound data."

	| n resultBuf j |
	n _ self monoSampleCount.
	resultBuf _ SoundBuffer newMonoSampleCount: n // 2.
	j _ 0.
	2 to: n by: 2 do: [:i | resultBuf at: (j _ j + 1) put: (self at: i)].
	^ resultBuf! !

!SoundBuffer methodsFor: 'utilities' stamp: 'jhm 10/15/97 15:13'!
indexOfFirstSampleOver: threshold
	"Return the index of the first sample whose absolute value is over the given threshold value. Return an index one greater than my size if no sample is over the threshold."

	1 to: self size do: [:i |
		(self at: i) abs > threshold ifTrue: [^ i]].
	^ self size + 1! !

!SoundBuffer methodsFor: 'utilities' stamp: 'jhm 10/15/97 15:13'!
indexOfLastSampleOver: threshold
	"Return the index of the last sample whose absolute value is over the given threshold value. Return zero if no sample is over the threshold."

	self size to: 1 by: -1 do: [:i |
		(self at: i) abs > threshold ifTrue: [^ i]].
	^ 0
! !

!SoundBuffer methodsFor: 'utilities' stamp: 'jm 10/21/2001 10:43'!
lowPassFiltered
	"Answer a simple low-pass filtered copy of this buffer. Assume it is monophonic."

	| sz out last this |
	sz _ self monoSampleCount.
	out _ self clone.
	last _ self at: 1.
	2 to: sz do: [:i |
		this _ self at: i.
		out at: i put: (this + last) // 2.
		last _ this].
	^ out
! !

!SoundBuffer methodsFor: 'utilities' stamp: 'jm 11/15/2001 18:26'!
mergeStereo
	"Answer a new SoundBuffer half the size of the receiver that mixes the left and right stereo channels of the receiver, which is assumed to contain stereo sound data."

	| n resultBuf j |
	n _ self monoSampleCount.
	resultBuf _ SoundBuffer newMonoSampleCount: n // 2.
	j _ 0.
	1 to: n by: 2 do: [:i | resultBuf at: (j _ j + 1) put: (((self at: i) + (self at: i + 1)) // 2)].
	^ resultBuf
! !

!SoundBuffer methodsFor: 'utilities' stamp: 'jm 2/21/2007 13:26'!
mixIn: aSoundBuffer
	"Answer mix the contents of the given SoundBuffers with the receiver. The receiver is modified."

	| n |
	n _  self monoSampleCount min: aSoundBuffer monoSampleCount.
	1 to: n do: [:i | self at: i put: ((self at: i) + (aSoundBuffer at: i)) // 2].

! !

!SoundBuffer methodsFor: 'utilities' stamp: 'jhm 10/15/97 15:13'!
normalized: percentOfFullVolume
	"Increase my amplitudes so that the highest peak is the given percent of full volume. For example 's normalized: 50' would normalize to half of full volume."

	| peak s mult |
	peak _ 0.
	1 to: self size do: [:i |
		s _ (self at: i) abs.
		s > peak ifTrue: [peak _ s]].
	mult _ (32767.0 * percentOfFullVolume) / (100.0 * peak).
	1 to: self size do: [:i | self at: i put: (mult * (self at: i)) asInteger].
! !

!SoundBuffer methodsFor: 'utilities' stamp: 'jm 3/28/1999 07:23'!
splitStereo
	"Answer an array of two SoundBuffers half the size of the receiver consisting of the left and right channels of the receiver (which is assumed to contain stereo sound data)."

	| n leftBuf rightBuf leftIndex rightIndex |
	n _ self monoSampleCount.
	leftBuf _ SoundBuffer newMonoSampleCount: n // 2.
	rightBuf _ SoundBuffer newMonoSampleCount: n // 2.
	leftIndex _ rightIndex _ 0.
	1 to: n by: 2 do: [:i |
		leftBuf at: (leftIndex _ leftIndex + 1) put: (self at: i).
		rightBuf at: (rightIndex _ rightIndex + 1) put: (self at: i + 1)].
	^ Array with: leftBuf with: rightBuf
! !

!SoundBuffer methodsFor: 'utilities' stamp: 'jhm 10/15/97 15:13'!
trimmedThreshold: threshold

	| start end |
	start _ self indexOfFirstSampleOver: threshold.
	end _  self indexOfLastSampleOver: threshold.
	start > end ifTrue: [^ SoundBuffer new].
	start _ (start - 200) max: 1.
	end _ (end + 200) min: self size.
	^ self copyFrom: start to: end
! !


!SoundBuffer methodsFor: 'objects from disk' stamp: 'jm 12/3/2003 14:17'!
reverseEndiannessStereo: stereoFlag
	"Swap the bytes of each 16-bit word, using a fast BitBlt hack. If stereoFlag is true the channels must also be reversed."

	| hack blt |
	hack _ Form new hackBits: self.
	blt _ (BitBlt toForm: hack) sourceForm: hack.
	blt combinationRule: Form reverse.  "XOR"
	blt sourceY: 0; destY: 0; height: self size.
	blt width: 1. "one-byte wide columns"
	stereoFlag
		ifTrue: [
			blt sourceX: 0; destX: 3; copyBits.  "swap byte-wide columns 0 and 3 using XOR"
			blt sourceX: 3; destX: 0; copyBits.
			blt sourceX: 0; destX: 3; copyBits.
			blt sourceX: 1; destX: 2; copyBits.  "swap byte-wide columns 1 and 2 using XOR"
			blt sourceX: 2; destX: 1; copyBits.
			blt sourceX: 1; destX: 2; copyBits]
		ifFalse: [
			blt sourceX: 0; destX: 1; copyBits.  "swap byte-wide columns 0 and 1 using XOR"
			blt sourceX: 1; destX: 0; copyBits.
			blt sourceX: 0; destX: 1; copyBits.
			blt sourceX: 2; destX: 3; copyBits.  "swap byte-wide columns 2 and 3 using XOR"
			blt sourceX: 3; destX: 2; copyBits.
			blt sourceX: 2; destX: 3; copyBits].
! !

!SoundBuffer methodsFor: 'objects from disk' stamp: 'jm 3/20/2007 23:13'!
storeBigEndianOn: aBinaryStream stereo: stereo
	"Store my samples onto the given stream in big-endian format (most-significant byte first)."

	| reverseBytes |
	reverseBytes _ Smalltalk isBigEndian not.

	(aBinaryStream isKindOf: StandardFileStream)
		ifTrue: [  "optimization for file streams: store directly to file"
			reverseBytes ifTrue: [self reverseEndiannessStereo: stereo].
			aBinaryStream next: (self size // 2) putAll: self startingAt: 1.  "size is in 32-bit words"
			reverseBytes ifTrue: [self reverseEndiannessStereo: stereo]]
		ifFalse: [  "for non-file streams:"
			reverseBytes & stereo ifTrue: [self swapStereoChannels].
			1 to: self monoSampleCount do: [:i | aBinaryStream int16: (self at: i)].
			reverseBytes & stereo ifTrue: [self swapStereoChannels]].
! !

!SoundBuffer methodsFor: 'objects from disk' stamp: 'jm 12/3/2003 13:07'!
storeOn: aBinaryStream bigEndian: bigEndianFlag stereo: stereo
	"Store my samples onto the given stream. If bigEndianFlag is true, the samples will be stored in big-endian format (most-significant byte first, as in an AIFF file) otherwise they will be stored in little-endian format (least-significant byte first, as in a WAV file)."

	| reverseBytes |
	reverseBytes _ bigEndianFlag ~= Smalltalk isBigEndian.
	reverseBytes ifTrue: [self reverseEndiannessStereo: stereo].

	(aBinaryStream isKindOf: StandardFileStream)
		ifTrue: [  "optimization for file streams: store directly to file"
			aBinaryStream next: (self size // 2) putAll: self startingAt: 1]  "size is in 32-bit words"
		ifFalse: [  "for non-file streams:"
			1 to: self monoSampleCount do: [:i | aBinaryStream int16: (self at: i)]].

	reverseBytes ifTrue: [self reverseEndiannessStereo: stereo].  "revert to original endianness"
! !

!SoundBuffer methodsFor: 'objects from disk' stamp: 'jm 12/3/2003 10:18'!
swapStereoChannels
	"Swap my left and right stereo channels."

	| hack blt |
	hack _ Form new hackBits: self.
	blt _ (BitBlt toForm: hack) sourceForm: hack.
	blt combinationRule: Form reverse.  "XOR"
	blt sourceY: 0; destY: 0; height: self size; width: 2.

	blt sourceX: 0; destX: 2; copyBits.  "swap 16-bit words using XOR"
	blt sourceX: 2; destX: 0; copyBits.
	blt sourceX: 0; destX: 2; copyBits.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SoundBuffer class
	instanceVariableNames: ''!

!SoundBuffer class methodsFor: 'instance creation' stamp: 'jm 9/17/97 12:39'!
fromArray: anArray
	"Return a new SoundBuffer whose contents are copied from the given Array or ByteArray."

	| new |
	new _ SoundBuffer newMonoSampleCount: anArray size.
	1 to: anArray size do: [:i | new at: i put: (anArray at: i)].
	^ new
! !

!SoundBuffer class methodsFor: 'instance creation' stamp: 'jm 9/17/97 13:25'!
new: anInteger
	"See the comment in newMonoSampleCount:. To avoid confusion, it is best to create new instances using newMonoSampleCount: or newStereoSampleCount:."

	^ self newMonoSampleCount: anInteger
! !

!SoundBuffer class methodsFor: 'instance creation' stamp: 'jm 9/17/97 12:44'!
newMonoSampleCount: anInteger
	"Return a SoundBuffer large enough to hold the given number of monaural samples (i.e., 16-bit words)."
	"Details: The size is rounded up to an even number, since the underlying representation is in terms of 32-bit words."

	^ self basicNew: (anInteger + 1) // 2
! !

!SoundBuffer class methodsFor: 'instance creation' stamp: 'jm 9/17/97 12:52'!
newStereoSampleCount: anInteger
	"Return a SoundBuffer large enough to hold the given number of stereo slices. A stereo 'slice' consists of two 16-bit samples, one for each channel."

	^ self basicNew: anInteger
! !


!SoundBuffer class methodsFor: 'system startup' stamp: 'jm 1/14/2006 20:27'!
initialize
	"self initialize"
	
	EndianTest _ SoundBuffer new: 2.
	EndianTest at: 1 put: 1.
	EndianTest at: 2 put: 2.
! !

!SoundBuffer class methodsFor: 'system startup' stamp: 'jm 1/14/2006 20:47'!
startUp
	"When starting this image on a machine with different byte ordering than the machine that saved it, the two 16-bit samples in each SoundBuffer word must be swapped. This is because the VM swaps the bytes of word array objects (which is what SoundBuffers are to the VM). So if the byte-ordering was (1 2 3 4), it becomes (4 3 2 1). Thus, the byte order for each 16-bit sample is right, but the two 16-bit samples in each word must be swapped to get the desired byte order of (2 1 4 3). This keeps the sample order correct (or the channels correct if the SoundBuffer is stereo)."

	(EndianTest at: 1) = 1 ifTrue: [^ self].  "no swap needed"
	SoundBuffer allInstances do: [:buf | buf swapStereoChannels].
! !


!SoundBuffer class methodsFor: 'file utilities' stamp: 'jm 11/22/2003 19:44'!
appendSamplesFrom: srcStream start: startIndex end: stopIndex toStream: outStream
	"Append a block of 16-bit samples from one binary stream to another. The range of samples from startIndex to stopIndex gives the range of 16-bit sample offsets from 0 within the source stream."

	| finalPosition buf lastFullBufferPosition n |
	finalPosition _ 2 * (stopIndex + 1).
	srcStream size < finalPosition ifTrue: [self error: 'stop index past end of file'].
	buf _ SoundBuffer newMonoSampleCount: 1000000.  "2 megabytes"
	lastFullBufferPosition _ 2 * (stopIndex - buf monoSampleCount).
	srcStream position: 2 * startIndex.
	[srcStream position <= lastFullBufferPosition] whileTrue: [
		n _ srcStream readInto: buf startingAt: 1 count: buf basicSize.
		n = buf basicSize ifFalse: [self error: 'bad read operation'].
		outStream nextPutAll: buf].

	buf _ nil.  "free old buffer in case space is limited"
	buf _ SoundBuffer newMonoSampleCount: (finalPosition - srcStream position).
	n _ srcStream readInto: buf startingAt: 1 count: buf basicSize.
	n = buf basicSize ifFalse: [self error: 'bad read operation'].
	outStream nextPutAll: buf.

	srcStream position = finalPosition ifFalse: [self error: 'implementation error'].
! !

!SoundBuffer class methodsFor: 'file utilities' stamp: 'jm 11/22/2003 21:18'!
copyFromStream: srcStream start: startPos end: endPos toStream: outStream
	"Copy data from one binary stream to another. The range of samples from startPos up to endPos is the range of source stream byte offsets."

	| buf lastFullBufferPosition n |
	srcStream size < endPos ifTrue: [self error: 'stop index is past end of file'].
	buf _ ByteArray new: 10000.
	lastFullBufferPosition _ endPos - buf size.
	srcStream position: startPos.
	[srcStream position <= lastFullBufferPosition] whileTrue: [
		n _ srcStream readInto: buf startingAt: 1 count: buf size.
		n = buf size ifFalse: [self error: 'bad read operation'].
		outStream nextPutAll: buf].

	buf _ nil.  "free old buffer in case space is very limited"
	buf _ ByteArray new: (endPos - srcStream position).
	n _ srcStream readInto: buf startingAt: 1 count: buf size.
	n = buf size ifFalse: [self error: 'bad read operation'].
	outStream nextPutAll: buf.

	srcStream position = endPos ifFalse: [self error: 'implementation error'].
! !

!SoundBuffer class methodsFor: 'file utilities' stamp: 'jm 9/15/2004 08:43'!
writeAIFFHeaderOn: aBinaryStream sampleCount: sampleCount samplingRate: samplingRate isStereo: isStereo
	"Write the header for a 16-bit AIFF file for the given number of 16-bit samples at the given sampling rate."

	| sampleBytes |
	sampleBytes _ 2 * sampleCount.

	"write AIFF file header:"
	aBinaryStream nextPutAll: 'FORM' asByteArray.
	aBinaryStream int32: (54 - 8) + sampleBytes.
	aBinaryStream nextPutAll: 'AIFF' asByteArray.

	aBinaryStream nextPutAll: 'COMM' asByteArray.
	aBinaryStream int32: 18.
	aBinaryStream int16: (isStereo ifTrue: [2] ifFalse: [1]).
	aBinaryStream int32: sampleCount.
	aBinaryStream int16: 16. "bits/sample"
	AbstractSound new storeExtendedFloat: samplingRate on: aBinaryStream. "10 bytes"

	aBinaryStream nextPutAll: 'SSND' asByteArray.
	aBinaryStream int32: sampleBytes + 8.
	aBinaryStream int32: 0.
	aBinaryStream int32: 0.

	(aBinaryStream isKindOf: FileStream) ifTrue: [
		(FileDirectory forFileName: aBinaryStream name)
			setMacFileNamed: aBinaryStream localName type: 'AIFF' creator: 'SCPL'].
! !


SoundBuffer initialize!
