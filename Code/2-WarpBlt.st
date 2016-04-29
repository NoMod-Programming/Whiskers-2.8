BitBlt subclass: #WarpBlt
	instanceVariableNames: 'p1x p1y p1z p2x p2y p2z p3x p3y p3z p4x p4y p4z cellSize sourceRGBmap '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Primitives'!
!WarpBlt commentStamp: 'jm 2/4/2005 12:37' prior: 0!
WarpBlt is a little warp-drive added on to BitBlt to do scaling and rotation. It scans and read pixels from its source quadrilateral (an Array of four points), then combines those pixels with the pixels of its destination Form using normal BitBlt combination rules (e.g. paint or over).

The source quadrilateral is an array of points starting with the corner that will be mapped to the topLeft of the destination rectangle, and proceeding to successive points CCW around the destination rectangle. Note that in specifying a plain old rectangle source, its non topLeft points must be actual pixels, not outside by 1, as with rectangle bottmRight, eg. See the method Rectangle innerCorners.

!


!WarpBlt methodsFor: 'entry points' stamp: 'jm 2/4/2005 12:16'!
copyQuad: pts toRect: destRect
	"Set the source quadralteral and the destination rectangle and then do the WarpBlt operation."

	cellSize ifNil: [^ self error: 'cellSize must not be nil!!'].
	self sourceQuad: pts destRect: destRect.
	self warpBits.
! !

!WarpBlt methodsFor: 'entry points' stamp: 'jm 2/4/2005 12:17'!
warpBits
	"Call the primitive to do the WarpBlt operation."

	self
		warpBitsSmoothing: cellSize
		sourceMap: (sourceForm colormapIfNeededForDepth: 32).
! !


!WarpBlt methodsFor: 'accessing' stamp: 'jm 2/4/2005 12:18'!
cellSize: s
	"Set my cell size for smoothing. If cell size > 1, then install an output colormap if the destination depth is less than 32 bits."

	cellSize _ s.
	cellSize = 1 ifTrue: [^ self].
	colorMap _ Color colorMapIfNeededFrom: 32 to: destForm depth.
! !

!WarpBlt methodsFor: 'accessing'!
sourceQuad: pts destRect: aRectangle
	| fixedPt1 |
	sourceX _ sourceY _ 0.
	self destRect: aRectangle.
	fixedPt1 _ (pts at: 1) x isInteger ifTrue: [16384] ifFalse: [16384.0].
	p1x _ (pts at: 1) x * fixedPt1.
	p2x _ (pts at: 2) x * fixedPt1.
	p3x _ (pts at: 3) x * fixedPt1.
	p4x _ (pts at: 4) x * fixedPt1.
	p1y _ (pts at: 1) y * fixedPt1.
	p2y _ (pts at: 2) y * fixedPt1.
	p3y _ (pts at: 3) y * fixedPt1.
	p4y _ (pts at: 4) y * fixedPt1.
	p1z _ p2z _ p3z _ p4z _ 16384.  "z-warp ignored for now"
! !


!WarpBlt methodsFor: 'primitives' stamp: 'EMP 4/27/2016 13:51'!
warpBitsSmoothing: n sourceMap: sourceMap

	| deltaP12 deltaP43 pA pB deltaPAB sp fixedPtOne picker poker pix nSteps |
	<primitive: 'primitiveWarpBits' module: 'BitBltPlugin'>

	"Check for compressed source, destination or halftone forms"
	((sourceForm isKindOf: Form) and: [sourceForm unhibernate])
		ifTrue: [^ self warpBitsSmoothing: n sourceMap: sourceMap].
	((destForm isKindOf: Form) and: [destForm unhibernate])
		ifTrue: [^ self warpBitsSmoothing: n sourceMap: sourceMap].
	((halftoneForm isKindOf: Form) and: [halftoneForm unhibernate])
		ifTrue: [^ self warpBitsSmoothing: n sourceMap: sourceMap].

	(width < 1) | (height < 1) ifTrue: [^ self].
	fixedPtOne _ 16384.  "1.0 in fixed-pt representation"
	n > 1 ifTrue:
		[(destForm depth < 16 and: [colorMap == nil])
			ifTrue: ["color map is required to smooth non-RGB dest"
					^ self primitiveFail].
		pix _ Array new: n*n].

	nSteps _ height-1 max: 1.
	deltaP12 _ (self deltaFrom: p1x to: p2x nSteps: nSteps)
			@ (self deltaFrom: p1y to: p2y nSteps: nSteps).
	pA _ (self startFrom: p1x to: p2x offset: nSteps*deltaP12 x)
		@ (self startFrom: p1y to: p2y offset: nSteps*deltaP12 y).
	deltaP43 _ (self deltaFrom: p4x to: p3x nSteps: nSteps)
			@ (self deltaFrom: p4y to: p3y nSteps: nSteps).
	pB _ (self startFrom: p4x to: p3x offset: nSteps*deltaP43 x)
		@ (self startFrom: p4y to: p3y offset: nSteps*deltaP43 y).

	picker _ BitBlt bitPeekerFromForm: sourceForm.
	poker _ BitBlt bitPokerToForm: destForm.
	poker clipRect: self clipRect.
	nSteps _ width-1 max: 1.
	destY to: destY+height-1 do:
		[:y |
		deltaPAB _ (self deltaFrom: pA x to: pB x nSteps: nSteps)
				@ (self deltaFrom: pA y to: pB y nSteps: nSteps).
		sp _ (self startFrom: pA x to: pB x offset: nSteps*deltaPAB x)
			@ (self startFrom: pA y to: pB y offset: nSteps*deltaPAB x).
		destX to: destX+width-1 do:
			[:x | 
			n = 1
			ifTrue:
				[Transcript cr; print: sp // fixedPtOne asPoint.
				poker pixelAt: x@y
						put: (picker pixelAt: sp // fixedPtOne asPoint)]
			ifFalse:
				[0 to: n-1 do:
					[:dx | 0 to: n-1 do:
						[:dy |
						pix at: dx*n+dy+1 put:
								(picker pixelAt: sp
									+ (deltaPAB*dx//n)
									+ (deltaP12*dy//n)
										// fixedPtOne asPoint)]].
				poker pixelAt: x@y put: (self mixPix: pix
										sourceMap: sourceMap
										destMap: colorMap)].
			sp _ sp + deltaPAB].
		pA _ pA + deltaP12.
		pB _ pB + deltaP43]
! !


!WarpBlt methodsFor: 'private-simulation'!
deltaFrom: x1 to: x2 nSteps: n
	"Utility routine for computing Warp increments.
	x1 is starting pixel, x2 is ending pixel;  assumes n >= 1"
	| fixedPtOne |
	fixedPtOne _ 16384.  "1.0 in fixed-pt representation"
	x2 > x1
		ifTrue: [^ x2 - x1 + fixedPtOne // (n+1) + 1]
		ifFalse: [x2 = x1 ifTrue: [^ 0].
				^ 0 - (x1 - x2 + fixedPtOne // (n+1) + 1)]! !

!WarpBlt methodsFor: 'private-simulation' stamp: 'di 6/24/97 00:09'!
mixPix: pix sourceMap: sourceMap destMap: destMap
	"Average the pixels in array pix to produce a destination pixel.
	First average the RGB values either from the pixels directly,
	or as supplied in the sourceMap.  Then return either the resulting
	RGB value directly, or use it to index the destination color map." 
	| r g b rgb nPix bitsPerColor d |
	nPix _ pix size.
	r _ 0. g _ 0. b _ 0.
	1 to: nPix do:
		[:i |   "Sum R, G, B values for each pixel"
		rgb _ sourceForm depth <= 8
				ifTrue: [sourceMap at: (pix at: i) + 1]
				ifFalse: [sourceForm depth = 32
						ifTrue: [pix at: i]
						ifFalse: [self rgbMap: (pix at: i) from: 5 to: 8]].
		r _ r + ((rgb bitShift: -16) bitAnd: 16rFF).
		g _ g + ((rgb bitShift: -8) bitAnd: 16rFF).
		b _ b + ((rgb bitShift: 0) bitAnd: 16rFF)].
	destMap == nil
		ifTrue: [bitsPerColor _ 3.  "just in case eg depth <= 8 and no map"
				destForm depth = 16 ifTrue: [bitsPerColor _ 5].
				destForm depth = 32 ifTrue: [bitsPerColor _ 8]]
		ifFalse: [destMap size = 512 ifTrue: [bitsPerColor _ 3].
				destMap size = 4096 ifTrue: [bitsPerColor _ 4].
				destMap size = 32768 ifTrue: [bitsPerColor _ 5]].
	d _ bitsPerColor - 8.
	rgb _ ((r // nPix bitShift: d) bitShift: bitsPerColor*2)
		+ ((g // nPix bitShift: d) bitShift: bitsPerColor)
		+ ((b // nPix bitShift: d) bitShift: 0).
	destMap == nil
		ifTrue: [^ rgb]
		ifFalse: [^ destMap at: rgb+1]! !

!WarpBlt methodsFor: 'private-simulation' stamp: 'di 6/24/97 00:08'!
rgbMap: sourcePixel from: nBitsIn to: nBitsOut
	"NOTE: This code is copied verbatim from BitBltSimulation so that it
	may be removed from the system"
	"Convert the given pixel value with nBitsIn bits for each color component to a pixel value with nBitsOut bits for each color component. Typical values for nBitsIn/nBitsOut are 3, 5, or 8."
	| mask d srcPix destPix |
	self inline: true.
	(d _ nBitsOut - nBitsIn) > 0
		ifTrue:
			["Expand to more bits by zero-fill"
			mask _ (1 << nBitsIn) - 1.  "Transfer mask"
			srcPix _ sourcePixel << d.
			mask _ mask << d.
			destPix _ srcPix bitAnd: mask.
			mask _ mask << nBitsOut.
			srcPix _ srcPix << d.
			^ destPix + (srcPix bitAnd: mask)
				 	+ (srcPix << d bitAnd: mask << nBitsOut)]
		ifFalse:
			["Compress to fewer bits by truncation"
			d = 0 ifTrue: [^ sourcePixel].  "no compression"
			sourcePixel = 0 ifTrue: [^ sourcePixel].  "always map 0 (transparent) to 0"
			d _ nBitsIn - nBitsOut.
			mask _ (1 << nBitsOut) - 1.  "Transfer mask"
			srcPix _ sourcePixel >> d.
			destPix _ srcPix bitAnd: mask.
			mask _ mask << nBitsOut.
			srcPix _ srcPix >> d.
			destPix _ destPix + (srcPix bitAnd: mask)
					+ (srcPix >> d bitAnd: mask << nBitsOut).
			destPix = 0 ifTrue: [^ 1].  "Dont fall into transparent by truncation"
			^ destPix]! !

!WarpBlt methodsFor: 'private-simulation' stamp: 'EMP 2/7/2016 11:21'!
sourceForm: t1 destRect: t2 
	| t3 t4 |
	sourceForm := t1.
	sourceX := sourceY := 0.
	destX := t2 left.
	destY := t2 top.
	width := t2 width.
	height := t2 height.
	t3 := 16384 * (t1 width - 1).
	t4 := 16384 * (t1 height - 1).
	p1x := 0.
	p2x := 0.
	p3x := t3.
	p4x := t3.
	p1y := 0.
	p2y := t4.
	p3y := t4.
	p4y := 0.
	p1z := p2z := p3z := p4z := 16384! !

!WarpBlt methodsFor: 'private-simulation'!
startFrom: x1 to: x2 offset: sumOfDeltas
	"Utility routine for computing Warp increments."
	x2 >= x1
		ifTrue: [^ x1]
		ifFalse: [^ x2 - sumOfDeltas]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WarpBlt class
	instanceVariableNames: ''!

!WarpBlt class methodsFor: 'initialization' stamp: 'jm 2/4/2005 12:38'!
toForm: destinationForm
	"Default cell size is 1 (no pixel smoothing)"

	^ (super toForm: destinationForm) cellSize: 1
! !


!WarpBlt class methodsFor: 'examples' stamp: 'jm 7/17/2003 22:53'!
test1   "Display restoreAfter: [WarpBlt test1]"
	"Demonstrates variable scale and rotate"
	| warp pts r1 p0 p ext |
	Utilities informUser: 'Choose a rectangle with interesting stuff'
		during: [r1 _ Rectangle originFromUser: 50@50.
				Sensor waitNoButton].
	Utilities informUser: 'Now click down and up
and move the mouse around the dot'
		during: [p0 _ Sensor waitClickButton.
				(Form dotOfSize: 8) displayAt: p0].
	warp _ (self toForm: Display)
		clipRect: (0@0 extent: r1 extent*5);
		sourceForm: Display;
		combinationRule: Form over.
	[Sensor anyButtonPressed] whileFalse:
		[p _ Sensor cursorPoint.
		pts _ {r1 topLeft. r1 bottomLeft. r1 bottomRight. r1 topRight}
			collect: [:pt | pt rotateBy: (p-p0) theta about: r1 center].
		ext _ (r1 extent*((p-p0) r / 20.0 max: 0.1)) truncated.
		warp copyQuad: pts toRect: (r1 extent*5-ext//2 extent: ext)]! !

!WarpBlt class methodsFor: 'examples' stamp: 'jm 7/17/2003 22:53'!
test12   "Display restoreAfter: [WarpBlt test12]"
	"Just like test1, but comparing smooth to non-smooth warps"
	| warp pts r1 p0 p ext warp2 |
	Utilities informUser: 'Choose a rectangle with interesting stuff'
		during: [r1 _ Rectangle originFromUser: 50@50.
				Sensor waitNoButton].
	Utilities informUser: 'Now click down and up
and move the mouse around the dot'
		during: [p0 _ Sensor waitClickButton.
				(Form dotOfSize: 8) displayAt: p0].
	warp _ (self toForm: Display)
		cellSize: 2;  "installs a colormap"
		clipRect: (0@0 extent: r1 extent*5);
		sourceForm: Display;
		combinationRule: Form over.
	warp2 _ (self toForm: Display)
		clipRect: ((0@0 extent: r1 extent*5) translateBy: 250@0);
		sourceForm: Display;
		combinationRule: Form over.
	[Sensor anyButtonPressed] whileFalse:
		[p _ Sensor cursorPoint.
		pts _ {r1 topLeft. r1 bottomLeft. r1 bottomRight. r1 topRight}
			collect: [:pt | pt rotateBy: (p-p0) theta about: r1 center].
		ext _ (r1 extent*((p-p0) r / 20.0 max: 0.1)) truncated.
		warp copyQuad: pts toRect: (r1 extent*5-ext//2 extent: ext).
		warp2 copyQuad: pts toRect: ((r1 extent*5-ext//2 extent: ext) translateBy: 250@0).
		]! !

!WarpBlt class methodsFor: 'examples'!
test3   "Display restoreAfter: [WarpBlt test3]"

	"The Squeak Release Mandala - 9/23/96 di"

	"Move the mouse near the center of the square.
	Up and down affects shrink/grow
	Left and right affect rotation angle"
	| warp pts p0 p box map d t |
	box _ 100@100 extent: 300@300.
	Display border: (box expandBy: 2) width: 2.

	"Make a color map that steps through the color space"
	map _ (Display depth > 8
		ifTrue: ["RGB is a bit messy..."
				d _ Display depth = 16 ifTrue: [5] ifFalse: [8].
				(1 to: 512) collect: [:i | t _ i bitAnd: 511.
					((t bitAnd: 16r7) bitShift: d-3)
					+ ((t bitAnd: 16r38) bitShift: d-3*2)
					+ ((t bitAnd: 16r1C0) bitShift: d-3*3)]]
		ifFalse: ["otherwise simple"
				1 to: (1 bitShift: Display depth)])
			as: Bitmap.
	warp _ (WarpBlt toForm: Display)
		clipRect: box;
		sourceForm: Display;
		colorMap: map;
		combinationRule: Form over.
	p0 _ box center.
	[Sensor anyButtonPressed] whileFalse:
		[p _ Sensor cursorPoint.
		pts _ (box insetBy: p y - p0 y) innerCorners
			collect: [:pt | pt rotateBy: p x - p0 x / 50.0 about: p0].
		warp copyQuad: pts toRect: box]! !

!WarpBlt class methodsFor: 'examples'!
test4   "Display restoreAfter: [WarpBlt test4]"

	"The Squeak Release Mandala - 9/23/96 di
	This version does smoothing"

	"Move the mouse near the center ofhe square.
	Up and dn affects shrink/grow
	Left and right affect rotation angle"
	| warp pts p0 p box |
	box _ 100@100 extent: 300@300.
	Display border: (box expandBy: 2) width: 2.

	warp _ (WarpBlt toForm: Display)
		clipRect: box;
		sourceForm: Display;
		cellSize: 2;  "installs a colormap"
		combinationRule: Form over.
	p0 _ box center.
	[Sensor anyButtonPressed] whileFalse:
		[p _ Sensor cursorPoint.
		pts _ (box insetBy: p y - p0 y) innerCorners
			collect: [:pt | pt rotateBy: p x - p0 x / 50.0 about: p0].
		warp copyQuad: pts toRect: box]! !

!WarpBlt class methodsFor: 'examples'!
test5   "Display restoreAfter: [WarpBlt test5]"
	"Demonstrates variable scale and rotate"
	| warp pts r1 p0 p |
	Utilities informUser: 'Choose a rectangle with interesting stuff'
		during: [r1 _ Rectangle fromUser.
				Sensor waitNoButton].
	Utilities informUser: 'Now click down and up
and move the mouse around the dot'
		during: [p0 _ Sensor waitClickButton.
				(Form dotOfSize: 8) displayAt: p0].
	warp _ (self toForm: Display)
		cellSize: 1;
		sourceForm: Display;
		cellSize: 2;  "installs a colormap"
		combinationRule: Form over.
	[Sensor anyButtonPressed] whileFalse:
		[p _ Sensor cursorPoint.
		pts _ {r1 topLeft. r1 bottomLeft. r1 bottomRight. r1 topRight}
			collect: [:pt | pt rotateBy: (p-p0) theta about: r1 center].
		warp copyQuad: pts toRect: (r1 translateBy: r1 width@0)]! !


!WarpBlt class methodsFor: 'form rotation' stamp: 'jm 10/16/2007 17:27'!
rotate: srcForm degrees: angleInDegrees center: rotationPoint scaleBy: scalePoint smoothing: cellSize
	"Rotate the given Form the given number of degrees about the given center and scale its width and height by x and y of the given scale point. Smooth using the given cell size, an integer between 1 and 3, where 1 means no smoothing. Return a pair where the first element is the rotated Form and the second is the position offset required to align the rotationPoint of the rotated Form with that of the original. Note that the dimensions of the resulting Form generally differ from those of the original."

	| srcRect center radians dstOrigin dstCorner p dstRect dstExtent inverseScale quad warpSrc dstForm  oldOffset newRotationPoint |
	srcRect _ srcForm boundingBox.
	center _ srcRect extent / 2.0.
	radians _ angleInDegrees degreesToRadians.
	dstOrigin _ dstCorner _ center.
	srcRect corners do: [:corner |
		"find the limits of a rectangle that just encloses the rotated
		 original; in general, this rectangle will be larger than the
		 original (e.g., consider a square rotated by 45 degrees)"
		p _ ((corner - center) scaleBy: scalePoint) + center.
		p _ p rotateBy: radians about: center.
		dstOrigin _ dstOrigin min: p.
		dstCorner _ dstCorner max: p].

	"rotate the enclosing rectangle back to get the source quadrilateral"
	dstRect _ dstOrigin corner: dstCorner.
	dstExtent _ dstRect extent rounded.
	inverseScale _ (1.0 / scalePoint x)@(1.0 / scalePoint y).
	quad _ dstRect innerCorners collect: [:corner |
		p _ corner rotateBy: radians negated about: center.
		((p - center) scaleBy: inverseScale) + center].

	"make a Form to hold the result and do the rotation"
	warpSrc _ srcForm.
	(srcForm isKindOf: ColorForm) ifTrue: [
		warpSrc _ Form extent: srcForm extent depth: 32.
		srcForm displayOn: warpSrc].
	dstForm _ Form extent: dstExtent depth: (warpSrc depth max: 16).

	(WarpBlt toForm: dstForm)
		sourceForm: warpSrc;
		colorMap: (dstForm colormapIfNeededForDepth: warpSrc depth);
		cellSize: cellSize;  "installs a new colormap if cellSize > 1"
		combinationRule: Form paint;
		copyQuad: quad toRect: dstForm boundingBox.

	oldOffset _ (rotationPoint - center truncated) * scalePoint.
	newRotationPoint _ (dstForm extent / 2.0) + (oldOffset rotateBy: radians about: 0@0).
	^ Array with: dstForm with: newRotationPoint - rotationPoint
! !

!WarpBlt class methodsFor: 'form rotation' stamp: 'jm 2/4/2005 16:35'!
rotate: srcForm degrees: angleInDegrees scaleBy: scalePoint smoothing: cellSize
	"Rotate the given Form the given number of degrees about the given center and scale its width and height by x and y of the given scale point. Smooth using the given cell size, an integer between 1 and 3, where 1 means no smoothing. Answer the rotated Form. Note that the dimensions of the resulting Form generally differ from those of the original."

	| srcRect center radians dstOrigin dstCorner p fudge dstRect quad dstForm warpSrc |
	srcRect _ srcForm boundingBox.
	center _ srcRect extent / 2.0.
	radians _ angleInDegrees negated degreesToRadians.
	dstOrigin _ dstCorner _ center.
	srcRect corners do: [:corner |
		"find the limits of a rectangle that just encloses the rotated
		 original; in general, this rectangle will be larger than the
		 original (e.g., consider a square rotated by 45 degrees)"
		p _ ((corner - center) scaleBy: scalePoint) + center.
		p _ p rotateBy: radians about: center.
		dstOrigin _ dstOrigin min: p.
		dstCorner _ dstCorner max: p].

	"rotate the enclosing rectangle back to get the source quadrilateral"
	fudge _ (scalePoint x max: scalePoint y) max: 1.
	"Note: expand by fudge due to avoid cutting off corners. Needed because of rounding/truncation
	 when WarpBlt does the reverse mapping from destination pixels back to source pixels."
	dstRect _ (dstOrigin - fudge) corner: (dstCorner + fudge).
	quad _ dstRect innerCorners collect: [:corner |
		p _ corner rotateBy: radians negated about: center.
		(((p - center) / scalePoint) + center) rounded].

	"make a Form to hold the result and do the rotation"
	warpSrc _ srcForm.
	(srcForm isKindOf: ColorForm)
		ifTrue: [
			cellSize > 1
				ifTrue: [
					warpSrc _ Form extent: srcForm extent depth: 16.
					srcForm displayOn: warpSrc.
					dstForm _ Form extent: dstRect extent depth: 16]  "use 16-bit depth to allow smoothing"
				ifFalse: [
					dstForm _ srcForm class extent: dstRect extent depth: srcForm depth]]
		ifFalse: [
			dstForm _ srcForm class extent: dstRect extent depth: srcForm depth].

	(WarpBlt toForm: dstForm)
		sourceForm: warpSrc;
		colorMap: (dstForm colormapIfNeededForDepth: warpSrc depth);
		cellSize: cellSize;  "installs a new colormap if cellSize > 1"
		combinationRule: Form paint;
		copyQuad: quad toRect: dstForm boundingBox.

	(dstForm isKindOf: ColorForm) ifTrue: [dstForm colors: srcForm colors copy].
	^ dstForm
! !

!WarpBlt class methodsFor: 'form rotation' stamp: 'EMP 4/18/2016 12:56'!
scale: srcForm by: scalePoint smoothing: cellSize
	"Rotate the given Form the given number of degrees about the given center and scale its width and height by x and y of the given scale point. Smooth using the given cell size, an integer between 1 and 3, where 1 means no smoothing. Answer the rotated Form. Note that the dimensions of the resulting Form generally differ from those of the original."

	| srcRect center radians dstOrigin dstCorner p fudge dstRect quad dstForm warpSrc |
	srcRect _ srcForm boundingBox.
	center _ srcRect extent / 2.0.
	radians _ 0.
	dstOrigin _ dstCorner _ center.
	srcRect corners do: [:corner |
		"find the limits of a rectangle that just encloses the rotated
		 original; in general, this rectangle will be larger than the
		 original (e.g., consider a square rotated by 45 degrees)"
		p _ ((corner - center) scaleBy: scalePoint) + center.
		p _ p rotateBy: radians about: center.
		dstOrigin _ dstOrigin min: p.
		dstCorner _ dstCorner max: p].

	"rotate the enclosing rectangle back to get the source quadrilateral"
	fudge _ (scalePoint x max: scalePoint y) max: 1.
	"Note: expand by fudge due to avoid cutting off corners. Needed because of rounding/truncation
	 when WarpBlt does the reverse mapping from destination pixels back to source pixels."
	dstRect _ (dstOrigin - fudge) corner: (dstCorner + fudge).
	quad _ dstRect innerCorners collect: [:corner |
		p _ corner rotateBy: radians negated about: center.
		(((p - center) / scalePoint) + center) rounded].

	"make a Form to hold the result and do the rotation"
	warpSrc _ srcForm.
	(srcForm isKindOf: ColorForm)
		ifTrue: [
			cellSize > 1
				ifTrue: [
					warpSrc _ Form extent: srcForm extent depth: 16.
					srcForm displayOn: warpSrc.
					dstForm _ Form extent: dstRect extent depth: 16]  "use 16-bit depth to allow smoothing"
				ifFalse: [
					dstForm _ srcForm class extent: dstRect extent depth: srcForm depth]]
		ifFalse: [
			dstForm _ srcForm class extent: dstRect extent depth: srcForm depth].

	(WarpBlt toForm: dstForm)
		sourceForm: warpSrc;
		colorMap: (dstForm colormapIfNeededForDepth: warpSrc depth);
		cellSize: cellSize;  "installs a new colormap if cellSize > 1"
		combinationRule: Form paint;
		copyQuad: quad toRect: dstForm boundingBox.

	(dstForm isKindOf: ColorForm) ifTrue: [dstForm colors: srcForm colors copy].
	^ dstForm
! !
