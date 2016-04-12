SharedPool subclass: #ZipConstants
	instanceVariableNames: ''
	classVariableNames: 'BaseDistance BaseLength BitLengthOrder DistanceCodes DynamicBlock EndBlock ExtraBitLengthBits ExtraDistanceBits ExtraLengthBits FixedBlock FixedDistanceTree FixedLiteralTree HashBits HashMask HashShift MatchLengthCodes MaxBitLengthBits MaxBitLengthCodes MaxBits MaxDistCodes MaxDistance MaxLengthCodes MaxLiteralCodes MaxMatch MinMatch NumLiterals Repeat11To138 Repeat3To10 Repeat3To6 StoredBlock WindowMask WindowSize '
	poolDictionaries: ''
	category: 'Compression-Streams'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ZipConstants class
	instanceVariableNames: ''!

!ZipConstants class methodsFor: 'pool initialization' stamp: 'EMP 11/20/2015 12:55'!
associationAt: aName ifAbsent: aBlock
	^ aBlock value! !

!ZipConstants class methodsFor: 'pool initialization' stamp: 'ar 5/18/2003 19:09'!
initialize
	"ZipConstants initialize"
	self initializeDeflateConstants.
	self initializeWriteStreamConstants.! !

!ZipConstants class methodsFor: 'pool initialization' stamp: 'ar 5/18/2003 19:06'!
initializeDeflateConstants

	WindowSize := 16r8000.
	WindowMask := WindowSize - 1.
	MaxDistance := WindowSize.

	MinMatch := 3.
	MaxMatch := 258.

	HashBits := 15.
	HashMask := (1 << HashBits) - 1.
	HashShift := (HashBits + MinMatch - 1) // MinMatch.
! !

!ZipConstants class methodsFor: 'pool initialization' stamp: 'ar 5/18/2003 19:08'!
initializeDistanceCodes
	| dist |
	BaseDistance := WordArray new: MaxDistCodes.
	DistanceCodes := WordArray new: 512.
	dist := 0.
	1 to: 16 do:[:code|
		BaseDistance at: code put: dist.
		1 to: (1 bitShift: (ExtraDistanceBits at: code)) do:[:n|
			dist := dist + 1.
			DistanceCodes at: dist put: code-1]].
	dist = 256 ifFalse:[self error:'Whoops?!!'].
	dist := dist >> 7.
	17 to: MaxDistCodes do:[:code|
		BaseDistance at: code put: dist << 7.
		1 to: (1 bitShift: (ExtraDistanceBits at: code)-7) do:[:n|
			dist := dist + 1.
			DistanceCodes at: 256 + dist put: code-1]].
! !

!ZipConstants class methodsFor: 'pool initialization' stamp: 'ar 5/18/2003 19:07'!
initializeExtraBits
	ExtraLengthBits := 
		WordArray withAll: #(0 0 0 0 0 0 0 0 1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 0).
	ExtraDistanceBits := 
		WordArray withAll: #(0 0 0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10 11 11 12 12 13 13).
	ExtraBitLengthBits := 
		WordArray withAll: #(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 3 7).
	BitLengthOrder :=
		WordArray withAll: #(16 17 18 0 8 7 9 6 10 5 11 4 12 3 13 2 14 1 15).
! !

!ZipConstants class methodsFor: 'pool initialization' stamp: 'ar 5/18/2003 19:08'!
initializeFixedTrees
	"ZipWriteStream initializeFixedTrees"
	| counts nodes |
	FixedLiteralTree := ZipEncoderTree new.
	FixedLiteralTree maxCode: 287.
	counts := WordArray new: MaxBits+1.
	counts at: 7+1 put: 24.
	counts at: 8+1 put: 144+8.
	counts at: 9+1 put: 112.
	nodes := Array new: 288.
	1 to: 288 do:[:i| nodes at: i put: (ZipEncoderNode value: i-1 frequency: 0 height: 0)].
	0 to: 143 do:[:i| (nodes at: i+1) setBitLengthTo: 8].
	144 to: 255 do:[:i| (nodes at: i+1) setBitLengthTo: 9].
	256 to: 279 do:[:i| (nodes at: i+1) setBitLengthTo: 7].
	280 to: 287 do:[:i| (nodes at: i+1) setBitLengthTo: 8].
	FixedLiteralTree buildCodes: nodes counts: counts maxDepth: MaxBits.
	FixedLiteralTree setValuesFrom: nodes.

	FixedDistanceTree := ZipEncoderTree new.
	FixedDistanceTree maxCode: MaxDistCodes.
	FixedDistanceTree
		bitLengths: ((WordArray new: MaxDistCodes+1) atAllPut: 5)
		codes: ((0 to: MaxDistCodes) collect:[:i| FixedDistanceTree reverseBits: i length: 5]).! !

!ZipConstants class methodsFor: 'pool initialization' stamp: 'ar 5/18/2003 19:07'!
initializeLengthCodes
	| length |
	BaseLength := WordArray new: MaxLengthCodes.
	MatchLengthCodes := WordArray new: MaxMatch - MinMatch + 1.
	length := 0.
	1 to: MaxLengthCodes - 1 do:[:code|
		BaseLength at: code put: length.
		1 to: (1 bitShift: (ExtraLengthBits at: code)) do:[:n|
			length := length + 1.
			MatchLengthCodes at: length put: NumLiterals + code]].
! !

!ZipConstants class methodsFor: 'pool initialization' stamp: 'ar 5/18/2003 19:09'!
initializeWriteStreamConstants

	MaxBits := 15.
	MaxBitLengthBits := 7.
	EndBlock := 256.

	StoredBlock := 0.
	FixedBlock := 1.
	DynamicBlock := 2.

	NumLiterals := 256.
	MaxLengthCodes := 29.
	MaxDistCodes := 30.
	MaxBitLengthCodes := 19.
	MaxLiteralCodes := NumLiterals + MaxLengthCodes + 1. "+ End of Block"

	Repeat3To6 := 16. "Repeat previous bit length 3-6 times (2 bits repeat count)"
	Repeat3To10 := 17. "Repeat previous bit length 3-10 times (3 bits repeat count)"
	Repeat11To138 := 18. "Repeat previous bit length 11-138 times (7 bits repeat count)"

	self initializeExtraBits.
	self initializeLengthCodes.
	self initializeDistanceCodes.
	self initializeFixedTrees.
! !


ZipConstants initialize!
