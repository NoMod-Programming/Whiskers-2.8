Object subclass: #Color
	instanceVariableNames: 'rgb cachedDepth cachedBitPattern '
	classVariableNames: 'Black Blue BlueShift Brown CachedColormaps ColorChart ColorNames ComponentMask ComponentMax Cyan DarkGray Gray GrayToIndexMap Green GreenShift HalfComponentMask HighLightBitmaps IndexedColors LightBlue LightBrown LightCyan LightGray LightGreen LightMagenta LightOrange LightRed LightYellow Magenta MaskingMap Orange PaleBlue PaleBuff PaleGreen PaleMagenta PaleOrange PalePeach PaleRed PaleTan PaleYellow PureBlue PureCyan PureGreen PureMagenta PureRed PureYellow RandomStream Red RedShift TranslucentPatterns Transparent VeryDarkGray VeryLightGray VeryPaleRed VeryVeryDarkGray VeryVeryLightGray White Yellow '
	poolDictionaries: ''
	category: 'Graphics-Primitives'!
!Color commentStamp: '<historical>' prior: 0!
This class represents abstract color, regardless of the depth of bitmap it will be shown in.  At the very last moment a Color is converted to a pixelValue that depends on the depth of the actual Bitmap inside the Form it will be used with.  The supported depths (in bits) are 1, 2, 4, 8, 16, and 32.  The number of actual colors at these depths are: 2, 4, 16, 256, 32768, and 16 million.  (See comment in BitBlt.)  To change the depth of the Display and set how many colors you can see, execute: (Display newDepth: 8).  (See comment in DisplayMedium)
	Color is represented as the amount of light in red, green, and blue.  White is (1.0, 1.0, 1.0) and black is (0, 0, 0).  Pure red is (1.0, 0, 0).  These colors are "additive".  Think of Color's instance variables as:
	r	amount of red, a Float between 0.0 and 1.0.
	g	amount of green, a Float between 0.0 and 1.0.
	b	amount of blue, a Float between 0.0 and 1.0.
(But, in fact, the three are encoded as values from 0 to 1023 and combined in a single integer, rgb.  The user does not need to know this.)
	Many colors are named.  You find a color by name by sending a message to class Color, for example (Color lightBlue).  Also, (Color red: 0.2 green: 0.6 blue: 1.0) or (Color r: 0.2 g: 0.6 b: 1.0) creates a color. (see below)
	A color is essentially immutable.  Once you set red, green, and blue, you cannot change them.  Instead, create a new Color and use it.
	Applications such as contour maps and bar graphs will want to display one of a set of shades based on a number.  Convert the range of this number to an integer from 1 to N.  Then call (Color green lightShades: N) to get an Array of colors from white to green.  Use the Array messages at:, atPin:, or atWrap: to pull out the correct color from the array.  atPin: gives the first (or last) color if the index is out of range.  atWrap: wraps around to the other end if the index is out of range.
	Here are some fun things to run in when your screen has color:
		Pen new mandala: 30 diameter: Display height-100.
		Pen new web  "Draw with the mouse, opt-click to end"
		Display fillWhite.  Pen new hilberts: 5.
		Form toothpaste: 30  "Draw with mouse, opt-click to end"
You might also want to try the comment in
	Form>class>examples>tinyText...


Messages:
	mixed: proportion with: aColor	Answer this color mixed with the given color additively. The proportion, a number between 0.0 and 1.0, determines what what fraction of the receiver to use in the mix.

	+ 	add two colors
	- 	subtract two colors
	*	multiply the values of r, g, b by a number or an Array of factors.  ((Color named: #white) * 0.3) gives a darkish gray.  (aColor * #(0 0 0.9)) gives a color with slightly less blue.
	/	divide a color by a factor or an array of three factors.

	errorForDepth: d     How close the nearest color at this depth is to this abstract color.  Sum of the squares of the RGB differences, square rooted and normalized to 1.0.  Multiply by 100 to get percent.

	hue			Returns the hue of the color. On a wheel from 0 to 360 with pure red at 0 and again at 360.
	saturation	Returns the saturation of the color.  0.0 to 1.0
	brightness	Returns the brightness of the color.  0.0 to 1.0

	name    Look to see if this Color has a name.
	display	Show a swatch of this color tracking the cursor.

	lightShades: thisMany		An array of thisMany colors from white to the receiver. 
	darkShades: thisMany		An array of thisMany colors from black to the receiver.  Array is of length num.
	mix: color2 shades: thisMany		An array of thisMany colors from the receiver to color2.
	wheel: thisMany			An array of thisMany colors around the color wheel starting and ending at the receiver.

	pixelValueForDepth: d    Returns the bits that appear be in a Bitmap of this depth for this color.  Represents the nearest available color at this depth.  Normal users do not need to know which pixelValue is used for which color. 

Messages to Class Color.
	red: r green: g blue: b		Return a color with the given r, g, and b components.
	r: g: b:		Same as above, for fast typing.

 	hue: h saturation: s brightness: b		Create a color with the given hue, saturation, and brightness.

	pink
 	blue
	red ...	Many colors have messages that return an instance of Color.
	canUnderstand: #brown	  Returns true if #brown is a defined color.
	names		An OrderedCollection of the names of the colors.
	named: #notAllThatGray put: aColor    Add a new color to the list and create an access message and a class variable for it.
	fromUser	Shows the palette of colors available at this display depth.  Click anywhere to return the color you clicked on.

	hotColdShades: thisMany	An array of thisMany colors showing temperature from blue to red to white hot.

    stdColorsForDepth: d        An Array of colors available at this depth.  For 16 bit and 32 bits, returns a ColorGenerator.  It responds to at: with a Color for that index, simulating a very big Array. 

   colorFromPixelValue: value depth: d    Returns a Color whose bit pattern (inside a Bitmap) at this depth is the number specified.  Normal users do not need to use this.

(See also comments in these classes: Form, Bitmap, BitBlt, Pattern, MaskedForm.)!


!Color methodsFor: 'access'!
alpha
	"Return the opacity ('alpha') value of opaque so that normal colors can be compared to TransparentColors."

	^ 1.0
! !

!Color methodsFor: 'access' stamp: 'jm 1/24/2008 12:38'!
b255
	"Answer my blue component as an integer in the range [0..255]. If I am the color black, answer 1 rather than 0 to avoid treating this color as transparent in paint mode."

	(rgb = 0 and: [self class = Color]) ifTrue: [^ 1].  "make black not be transparent"

	^ (rgb bitShift: -2) bitAnd: 255

! !

!Color methodsFor: 'access'!
blue
	"Return the blue component of this color, a float in the range [0.0..1.0]."

	^ self privateBlue asFloat / ComponentMax! !

!Color methodsFor: 'access'!
brightness
	"Return the brightness of this color, a float in the range [0.0..1.0]."

	^ ((self privateRed max:
	    self privateGreen) max:
	    self privateBlue) asFloat / ComponentMax! !

!Color methodsFor: 'access' stamp: 'jm 1/24/2008 12:33'!
g255
	"Answer my green component as an integer in the range [0..255]."

	^ (rgb bitShift: -12) bitAnd: 255
! !

!Color methodsFor: 'access'!
green
	"Return the green component of this color, a float in the range [0.0..1.0]."

	^ self privateGreen asFloat / ComponentMax! !

!Color methodsFor: 'access'!
hue
	"Return the hue of this color, an angle in the range [0.0..360.0]."

	| r g b max min span h |
	r _ self privateRed.
	g _ self privateGreen.
	b _ self privateBlue. 

	max _ ((r max: g) max: b).
	min _ ((r min: g) min: b).
	span _ (max - min) asFloat.
	span = 0.0 ifTrue: [ ^ 0.0 ].

	r = max ifTrue: [
		h _ ((g - b) asFloat / span) * 60.0.
	] ifFalse: [
		g = max
			ifTrue: [ h _ 120.0 + (((b - r) asFloat / span) * 60.0). ]
			ifFalse: [ h _ 240.0 + (((r - g) asFloat / span) * 60.0). ].
	].

	h < 0.0 ifTrue: [ h _ 360.0 + h ].
	^ h! !

!Color methodsFor: 'access'!
luminance
	"Return the luminance of this color, a brightness value weighted by the human eye's color sensitivity."

	^ ((299 * self privateRed) +
	   (587 * self privateGreen) +
	   (114 * self privateBlue)) / (1000 * ComponentMax)
! !

!Color methodsFor: 'access' stamp: 'jm 1/24/2008 12:38'!
r255
	"Answer my red component as an integer in the range [0..255]."

	^ (rgb bitShift: -22) bitAnd: 255
! !

!Color methodsFor: 'access'!
red
	"Return the red component of this color, a float in the range [0.0..1.0]."

	^ self privateRed asFloat / ComponentMax! !

!Color methodsFor: 'access'!
saturation
	"Return the saturation of this color, a value between 0.0 and 1.0."

	| r g b max min |
	r _ self privateRed.
	g _ self privateGreen.
	b _ self privateBlue. 

	max _ min _ r.
	g > max ifTrue: [max _ g].
	b > max ifTrue: [max _ b].
	g < min ifTrue: [min _ g].
	b < min ifTrue: [min _ b].

	max = 0
		ifTrue: [ ^ 0.0 ]
		ifFalse: [ ^ (max - min) asFloat / max asFloat ].
! !


!Color methodsFor: 'equality' stamp: 'di 1/6/1999 20:26'!
= aColor
	"Return true if the receiver equals the given color. This method handles TranslucentColors, too."

	aColor isColor ifFalse: [^ false].
	^ aColor privateRGB = rgb and:
		[aColor privateAlpha = self privateAlpha]
! !

!Color methodsFor: 'equality'!
hash

	^ rgb! !


!Color methodsFor: 'queries'!
isColor

	^ true
! !

!Color methodsFor: 'queries' stamp: 'di 12/30/1998 14:33'!
isTranslucent

	^ false
! !

!Color methodsFor: 'queries' stamp: 'di 1/3/1999 12:23'!
isTranslucentColor
	"This means: self isTranslucent, but isTransparent not"
	^ false! !

!Color methodsFor: 'queries'!
isTransparent

	^ false
! !


!Color methodsFor: 'transformations' stamp: 'di 11/2/97 14:05'!
+ aColor
	"Answer this color mixed with the given color in an additive color space.  "
	"(Color blue + Color green) display"

	^ Color basicNew
		setPrivateRed: self privateRed + aColor privateRed
		green: self privateGreen + aColor privateGreen
		blue: self privateBlue + aColor  privateBlue
! !

!Color methodsFor: 'transformations' stamp: 'di 11/2/97 14:05'!
- aColor
	"Answer aColor is subtracted from the given color in an additive color space.  "
	"(Color white - Color red) display"

	^ Color basicNew
		setPrivateRed: self privateRed - aColor privateRed
		green: self privateGreen - aColor privateGreen
		blue: self privateBlue - aColor  privateBlue
! !

!Color methodsFor: 'transformations' stamp: 'jm 9/23/2003 17:24'!
alpha: alphaValue
	"Return a new TransparentColor with the given amount of opacity ('alpha')."

	alphaValue >= 1.0 ifFalse: [
		^ TranslucentColor basicNew
			setRgb: rgb
			alpha: (255.0 * alphaValue) asInteger].
! !

!Color methodsFor: 'transformations' stamp: 'EMP 3/15/2016 15:32'!
alphaMixed: proportion with: aColor 
	"Answer this color mixed with the given color. The proportion, a number 
	between 0.0 and 1.0, determines what what fraction of the receiver to  
	use in the mix. For example, 0.9 would yield a color close to the  
	receiver. This method uses RGB interpolation; HSV interpolation can lead 
	to surprises.  Mixes the alphas (for transparency) also."

	| frac1 frac2 |
	frac1 _ proportion asFloat min: 1.0 max: 0.0.
	frac2 _ 1.0 - frac1.
	^ Color
		r: self red * frac1 + (aColor red * frac2)
		g: self green * frac1 + (aColor green * frac2)
		b: self blue * frac1 + (aColor blue * frac2)
		alpha: self alpha * frac1 + (aColor alpha * frac2)! !

!Color methodsFor: 'transformations' stamp: 'jm 9/6/2005 15:24'!
asPackedRGB
	"Answer a 24-bit packed RGB value (no alpha) for this color."

	| r g b |
	r _ (rgb bitShift: -22) bitAnd: 16rFF.
	g _ (rgb bitShift: -12) bitAnd: 16rFF.
	b _ (rgb bitShift: -2) bitAnd: 16rFF.
	^ (r bitShift: 16) + (g bitShift: 8) + b
! !

!Color methodsFor: 'transformations' stamp: 'di 5/15/1998 21:54'!
dansDarker
	"Return a darker shade of the same color.
	An attempt to do better than the current darker method."
	^ Color h: self hue s: self saturation
		v: (self brightness - 0.16 max: 0.0)! !

!Color methodsFor: 'transformations' stamp: 'jm 6/25/1998 10:12'!
darker
	"Answer a darker shade of this color."

	^ self mixed: 0.8333 with: Color black
! !

!Color methodsFor: 'transformations' stamp: 'jm 6/17/1998 11:23'!
lighter
	"Answer a lighter shade of this color."

	^ self mixed: 0.8333 with: Color white
! !

!Color methodsFor: 'transformations'!
mixed: proportion with: aColor
	"Answer this color mixed with the given color. The proportion, a number between 0.0 and 1.0, determines what what fraction of the receiver to use in the mix. For example, 0.9 would yield a color close to the receiver."
	"Details: This method uses RGB interpolation; HSV interpolation can lead to surprises."

	| frac1 frac2 |
	frac1 _ proportion asFloat min: 1.0 max: 0.0.
	frac2 _ 1.0 - frac1.
	^ Color
		r: (self    red * frac1) + (aColor    red * frac2) 
		g: (self green * frac1) + (aColor green * frac2) 
		b: (self   blue * frac1) + (aColor  blue * frac2)
! !

!Color methodsFor: 'transformations' stamp: 'jm 9/22/97 15:11'!
muchLighter

	^ self mixed: 0.233 with: Color white
! !

!Color methodsFor: 'transformations' stamp: 'ar 6/19/1999 00:36'!
negated
	"Return an RGB inverted color"
	^Color
		r: 1.0 - self red
		g: 1.0 - self green
		b: 1.0 - self blue! !

!Color methodsFor: 'transformations' stamp: 'EMP 12/22/2015 11:20'!
saturation: aValue
	^ self class h: (self hue) s: aValue v: (self brightness)! !

!Color methodsFor: 'transformations' stamp: 'sw 3/6/1999 01:19'!
slightlyDarker
	"Answer a slightly darker shade of this color."

	^ self mixed: 0.93 with: Color black
! !

!Color methodsFor: 'transformations' stamp: 'sw 3/6/1999 01:20'!
slightlyLighter
	"Answer a slightly lighter shade of this color."

	^ self mixed: 0.93 with: Color white
! !

!Color methodsFor: 'transformations' stamp: 'dew 6/18/1999 19:24'!
twiceDarker
	"Answer a significantly darker shade of this color."

	^ self mixed: 0.5 with: Color black
! !

!Color methodsFor: 'transformations' stamp: 'jm 3/29/2005 20:46'!
twiceLighter
	"Answer a significantly lighter shade of this color."

	^ self mixed: 0.6 with: Color white
! !

!Color methodsFor: 'transformations' stamp: 'sw 4/23/1998 18:17'!
veryMuchLighter

	^ self mixed: 0.1165 with: Color white
! !


!Color methodsFor: 'groups of shades' stamp: 'tk 6/18/96'!
mix: color2 shades: thisMany
	"Return an array of thisMany colors from self to color2. Very useful for displaying color based on a variable in your program.  "
	"Color showColors: (Color red mix: Color green shades: 12)"

	| redInc greenInc blueInc rr gg bb c out |
	thisMany = 1 ifTrue: [^ Array with: color2].
	redInc _ color2 red - self red / (thisMany-1).
	greenInc _ color2 green - self green / (thisMany-1).
	blueInc _ color2 blue - self blue / (thisMany-1).
	rr _ self red.  gg _ self green.  bb _ self blue.
	out _ (1 to: thisMany) collect: [:num |
		c _ Color r: rr g: gg b: bb.
		rr _ rr + redInc.
		gg _ gg + greenInc.
		bb _ bb + blueInc.
		c].
	out at: out size put: color2.	"hide roundoff errors"
	^ out
! !

!Color methodsFor: 'groups of shades' stamp: 'EMP 12/22/2015 11:17'!
wheel: thisMany
	"An array of thisMany colors around the color wheel starting at self and ending all the way around the hue space just before self.  Array is of length thisMany.  Very useful for displaying color based on a variable in your program.  "

	| sat bri hue step c |
	thisMany = 1 ifTrue: [^ Array with: self].
	sat _ self saturation.
	bri _ self brightness.
	hue _ self hue.
	step _ 360.0 / thisMany.
	^ (1 to: thisMany) collect: [:num |
		c _ Color h: hue s: sat v: bri.  "hue is taken mod 360"
		hue _ hue + step.
		c].


! !


!Color methodsFor: 'printing' stamp: 'jm 10/16/2007 10:58'!
hex
	"Answer the six-digit hexadecimal representation for this color (RRGGBB)."
	"Note: Although Squeak uses 10-bits per color component; the least significant 2 bits of each component are ignored by this method so, for example, Color transparent and Color black both have the hex representation: '000000'."

	| s |
	s _ WriteStream on: (String new: 6).
	s nextPut: ((self privateRed >> 6) bitAnd: 15) asHexDigit.
	s nextPut: ((self privateRed >> 2) bitAnd: 15) asHexDigit.
	s nextPut: ((self privateGreen >> 6) bitAnd: 15) asHexDigit.
	s nextPut: ((self privateGreen >> 2) bitAnd: 15) asHexDigit.
	s nextPut: ((self privateBlue >> 6) bitAnd: 15) asHexDigit.
	s nextPut: ((self privateBlue >> 2) bitAnd: 15) asHexDigit.
	^ s contents
! !

!Color methodsFor: 'printing' stamp: 'jm 3/25/2005 15:47'!
hsvString

	| s |
	(s _ WriteStream on: String new)
		nextPutAll: '(' , self class name;
		nextPutAll: ' h: ';
		nextPutAll: (self hue roundTo: 0.001) printString;
		nextPutAll: ' s: ';
		nextPutAll: (self saturation roundTo: 0.001) printString;
		nextPutAll: ' v: ';
		nextPutAll: (self brightness roundTo: 0.001) printString;
		nextPutAll: ')'.
	^ s contents
! !

!Color methodsFor: 'printing' stamp: 'bf 5/25/2000 16:52'!
printOn: aStream
	| name |
	(name _ self name) ifNotNil:
		[^ aStream
			nextPutAll: 'Color ';
			nextPutAll: name].
	self storeOn: aStream.
! !

!Color methodsFor: 'printing'!
shortPrintString
	"Return a short (but less precise) print string for use where space is tight."

	| s |
	s _ WriteStream on: ''.
	s
		nextPutAll: '(' , self class name;
		nextPutAll: ' r: ';
		nextPutAll: (self red roundTo: 0.01) printString;
		nextPutAll: ' g: ';
		nextPutAll: (self green roundTo: 0.01) printString;
		nextPutAll: ' b: ';
		nextPutAll: (self blue roundTo: 0.01) printString;
		nextPutAll: ')'.
	^ s contents
! !

!Color methodsFor: 'printing' stamp: 'mir 7/21/1999 11:41'!
storeArrayOn: aStream

	aStream nextPutAll: '#('.
	self storeArrayValuesOn: aStream.
	aStream nextPutAll: ') '
! !

!Color methodsFor: 'printing' stamp: 'mir 7/21/1999 11:41'!
storeArrayValuesOn: aStream

	(self red roundTo: 0.001) storeOn: aStream.
	aStream space.
	(self green roundTo: 0.001) storeOn: aStream.
	aStream space.
	(self blue roundTo: 0.001) storeOn: aStream.

! !

!Color methodsFor: 'printing'!
storeOn: aStream

	aStream
		nextPutAll: '(' , self class name;
		nextPutAll: ' r: ';
		nextPutAll: (self red roundTo: 0.001) printString;
		nextPutAll: ' g: ';
		nextPutAll: (self green roundTo: 0.001) printString;
		nextPutAll: ' b: ';
		nextPutAll: (self blue roundTo: 0.001) printString;
		nextPutAll: ')'.
! !


!Color methodsFor: 'other' stamp: 'sw 2/16/98 03:42'!
colorForInsets
	^ self! !

!Color methodsFor: 'other' stamp: 'jm 12/5/2005 21:04'!
display
	"Show a swatch of this color tracking the cursor until the next mouseClick. "
	"Color red display"

	| f |
	f _ Form extent: 40@20 depth: Display depth.
	f fillColor: self.
	Cursor blank showWhile:
		[f follow: [Sensor cursorPoint] while: [Sensor anyButtonPressed not]].
! !

!Color methodsFor: 'other' stamp: 'EMP 10/11/2015 20:16'!
name
	"Return this color's name, or nil if it has no name. Only returns a name if it exactly matches the named color."

	ColorNames do:
		[:name | (Color perform: name) = self ifTrue: [^ name]].
	^ nil
! !


!Color methodsFor: 'conversions' stamp: 'sw 10/27/1999 10:51'!
asNontranslucentColor
	^ self! !

!Color methodsFor: 'conversions' stamp: 'di 3/25/2000 10:13'!
balancedPatternForDepth: depth
	"A generalization of bitPatternForDepth: as it exists.  Generates a 2x2 stipple of color.
	The topLeft and bottomRight pixel are closest approx to this color"
	| pv1 pv2 mask1 mask2 pv3 c |
	(depth == cachedDepth and:[cachedBitPattern size = 2]) ifTrue: [^ cachedBitPattern].
	(depth between: 4 and: 16) ifFalse: [^ self bitPatternForDepth: depth].
	cachedDepth _ depth.
	pv1 _ self pixelValueForDepth: depth.
"
	Subtract error due to pv1 to get pv2.
	pv2 _ (self - (err1 _ (Color colorFromPixelValue: pv1 depth: depth) - self))
						pixelValueForDepth: depth.
	Subtract error due to 2 pv1's and pv2 to get pv3.
	pv3 _ (self - err1 - err1 - ((Color colorFromPixelValue: pv2 depth: depth) - self))
						pixelValueForDepth: depth.
"
	"Above two statements computed faster by the following..."
	pv2 _ (c _ self - ((Color colorFromPixelValue: pv1 depth: depth) - self))
						pixelValueForDepth: depth.
	pv3 _ (c + (c - (Color colorFromPixelValue: pv2 depth: depth)))
						pixelValueForDepth: depth.

	"Return to a 2-word bitmap that encodes a 2x2 stipple of the given pixelValues."
	mask1 _ (#(- - -	
			16r01010101 - - -			"replicates every other 4 bits"
			16r00010001 - - - - - - -	"replicates every other 8 bits"
			16r00000001) at: depth).	"replicates every other 16 bits"
	mask2 _ (#(- - -	
			16r10101010 - - -			"replicates the other 4 bits"
			16r01000100 - - - - - - -	"replicates the other 8 bits"
			16r00010000) at: depth).	"replicates the other 16 bits"
	^ cachedBitPattern _ Bitmap with: (mask1*pv1) + (mask2*pv2) with: (mask1*pv3) + (mask2*pv1)! !

!Color methodsFor: 'conversions' stamp: 'hmm 4/25/2000 09:40'!
bitPatternForDepth: depth
	"Return a Bitmap, possibly containing a stipple pattern, that best represents this color at the given depth. BitBlt calls this method to convert colors into Bitmaps. The resulting Bitmap may be multiple words to represent a stipple pattern of several lines.  "
	"See also:	pixelValueAtDepth:	-- value for single pixel
				pixelWordAtDepth:	-- a 32-bit word filled with the pixel value"
	"Details: The pattern for the most recently requested depth is cached."
	"Note for depths > 2, there are stippled and non-stippled versions (generated with #balancedPatternForDepth: and #bitPatternForDepth:, respectively). The stippled versions don't work with the window bit caching of StandardSystemView, so we make sure that for these depths, only unstippled patterns are returned"

	(depth == cachedDepth and: [depth <= 2 or: [cachedBitPattern size = 1]]) ifTrue: [^ cachedBitPattern].
	cachedDepth _ depth.

	depth > 2 ifTrue: [^ cachedBitPattern _ Bitmap with: (self pixelWordForDepth: depth)].
	depth = 1 ifTrue: [^ cachedBitPattern _ self halfTonePattern1].
	depth = 2 ifTrue: [^ cachedBitPattern _ self halfTonePattern2].
! !

!Color methodsFor: 'conversions'!
closestPixelValue1
	"Return the nearest approximation to this color for a monochrome Form."

	"fast special cases"
	rgb = 0 ifTrue: [^ 1].  "black"
	rgb = 16r3FFFFFFF ifTrue: [^ 0].  "white"

	self luminance > 0.5
		ifTrue: [^ 0]  "white"
		ifFalse: [^ 1].  "black"
! !

!Color methodsFor: 'conversions'!
closestPixelValue2
	"Return the nearest approximation to this color for a 2-bit deep Form."

	| lum |
	"fast special cases"
	rgb = 0 ifTrue: [^ 1].  "black"
	rgb = 16r3FFFFFFF ifTrue: [^ 2].  "opaque white"

	lum _ self luminance.
	lum < 0.2 ifTrue: [^ 1].  "black"
	lum > 0.6 ifTrue: [^ 2].  "opaque white"
	^ 3  "50% gray"
! !

!Color methodsFor: 'conversions'!
closestPixelValue4
	"Return the nearest approximation to this color for a 4-bit deep Form."

	| bIndex |
	"fast special cases"
	rgb = 0 ifTrue: [^ 1].  "black"
	rgb = 16r3FFFFFFF ifTrue: [^ 2].  "opaque white"

	rgb = PureRed privateRGB ifTrue: [^ 4].
	rgb = PureGreen privateRGB ifTrue: [^ 5].
	rgb = PureBlue privateRGB ifTrue: [^ 6].
	rgb = PureCyan privateRGB ifTrue: [^ 7].
	rgb = PureYellow privateRGB ifTrue: [^ 8].
	rgb = PureMagenta privateRGB ifTrue: [^ 9].

	bIndex _ (self luminance * 8.0) rounded.  "bIndex in [0..8]"
	^ #(
		1	"black"
		10	"1/8 gray"
		11	"2/8 gray"
		12	"3/8 gray"
		3	"4/8 gray"
		13	"5/8 gray"
		14	"6/8 gray"
		15	"7/8 gray"
		2	"opaque white"
	) at: bIndex + 1.
! !

!Color methodsFor: 'conversions'!
closestPixelValue8
	"Return the nearest approximation to this color for an 8-bit deep Form."

	"fast special cases"
	rgb = 0 ifTrue: [^ 1].  "black"
	rgb = 16r3FFFFFFF ifTrue: [^ 255].  "white"

	self saturation < 0.2 ifTrue: [
		^ GrayToIndexMap at: (self privateGreen >> 2) + 1.  "nearest gray"
	] ifFalse: [
		"compute nearest entry in the color cube"
		^ 40 +
		  ((((self privateRed * 5) + HalfComponentMask) // ComponentMask) * 36) +
		  ((((self privateBlue * 5) + HalfComponentMask) // ComponentMask) * 6) +
		  (((self privateGreen * 5) + HalfComponentMask) // ComponentMask)].
! !

!Color methodsFor: 'conversions' stamp: 'di 9/2/97 20:21'!
dominantColor
	^ self! !

!Color methodsFor: 'conversions' stamp: 'di 6/23/97 23:27'!
halfTonePattern1
	"Return a halftone-pattern to approximate luminance levels on 1-bit deep Forms."

	| lum |
	lum _ self luminance.
	lum < 0.1 ifTrue: [^ Bitmap with: 16rFFFFFFFF]. "black"
	lum < 0.4 ifTrue: [^ Bitmap with: 16rBBBBBBBB with: 16rEEEEEEEE]. "dark gray"
	lum < 0.6 ifTrue: [^ Bitmap with: 16r55555555 with: 16rAAAAAAAA]. "medium gray"
	lum < 0.9 ifTrue: [^ Bitmap with: 16r44444444 with: 16r11111111]. "light gray"
	^ Bitmap with: 0  "1-bit white"
! !

!Color methodsFor: 'conversions'!
halfTonePattern2
	"Return a halftone-pattern to approximate luminance levels on 2-bit deep Forms."

	| lum |
	lum _ self luminance.
	lum < 0.125 ifTrue: [^ Bitmap with: 16r55555555].  "black"
	lum < 0.25 ifTrue: [^ Bitmap with: 16r55555555 with: 16rDDDDDDDD].  "1/8 gray"
	lum < 0.375 ifTrue: [^ Bitmap with: 16rDDDDDDDD with: 16r77777777].  "2/8 gray"
	lum < 0.5 ifTrue: [^ Bitmap with: 16rFFFFFFFF with: 16r77777777].  "3/8 gray"
	lum < 0.625 ifTrue: [^ Bitmap with: 16rFFFFFFFF].  "4/8 gray"
	lum < 0.75 ifTrue: [^ Bitmap with: 16rFFFFFFFF with: 16rBBBBBBBB].  "5/8 gray"
	lum < 0.875 ifTrue: [^ Bitmap with: 16rEEEEEEEE with: 16rBBBBBBBB].  "6/8 gray"
	lum < 1.0 ifTrue: [^ Bitmap with: 16rAAAAAAAA with: 16rBBBBBBBB].  "7/8 gray"
	^ Bitmap with: 16rAAAAAAAA  "opaque white"

"handy expression for computing patterns for 2x2 tiles;
 set p to a string of 4 letters (e.g., 'wggw' for a gray-and-
 white checkerboard) and print the result of evaluating:
| p d w1 w2 |
p _ 'wggw'.
d _ Dictionary new.
d at: $b put: '01'.
d at: $w put: '10'.
d at: $g put: '11'.
w1 _ (d at: (p at: 1)), (d at: (p at: 2)).
w1 _ '2r', w1, w1, w1, w1, w1, w1, w1, w1, ' hex'.
w2 _ (d at: (p at: 3)), (d at: (p at: 4)).
w2 _ '2r', w2, w2, w2, w2, w2, w2, w2, w2, ' hex'.
Array with: (Compiler evaluate: w1) with: (Compiler evaluate: w2) 
"! !

!Color methodsFor: 'conversions' stamp: 'tk 4/24/97'!
indexInMap: aColorMap
	"Return the index corresponding to this color in the given color map. RGB colors are truncated to 3-, 4-, or 5-bits per color component when indexing into such a colorMap.  "

	aColorMap size = 2 ifTrue: [^ (self pixelValueForDepth: 1) + 1].
	aColorMap size = 4 ifTrue: [^ (self pixelValueForDepth: 2) + 1].
	aColorMap size = 16 ifTrue: [^ (self pixelValueForDepth: 4) + 1].
	aColorMap size = 256 ifTrue: [^ (self pixelValueForDepth: 8) + 1].
	aColorMap size = 512 ifTrue: [^ (self pixelValueForDepth: 9) + 1].
	aColorMap size = 4096 ifTrue: [^ (self pixelValueForDepth: 12) + 1].
	aColorMap size = 32768 ifTrue: [^ (self pixelValueForDepth: 16) + 1].
	self error: 'unknown pixel depth'.
! !

!Color methodsFor: 'conversions' stamp: 'bf 10/13/1999 14:22'!
makeForegroundColor
        "Make a foreground color contrasting with me"
        ^self luminance >= "Color red luminance" 0.299
                ifTrue: [Color black]
                ifFalse: [Color white]! !

!Color methodsFor: 'conversions' stamp: 'jm 1/26/2001 15:11'!
pixelValueForDepth: d
	"Returns an integer representing the bits that appear in a single pixel of this color in a Form of the given depth. The depth must be one of 1, 2, 4, 8, 16, or 32. Contrast with pixelWordForDepth: and bitPatternForDepth:, which return either a 32-bit word packed with the given pixel value or a multiple-word Bitmap containing a pattern. The inverse is the class message colorFromPixelValue:depth:"
	"Details: For depths of 8 or less, the result is a colorMap index. For depths of 16 and 32, it is a direct color value with 5 or 8 bits per color component."
	"Transparency: The pixel value zero is reserved for transparent. For depths greater than 8, black maps to the darkest possible blue."

	| rgbBlack val |
	d = 8 ifTrue: [^ self closestPixelValue8].  "common case"
	d < 8 ifTrue: [
		d = 4 ifTrue: [^ self closestPixelValue4].
		d = 2 ifTrue: [^ self closestPixelValue2].
		d = 1 ifTrue: [^ self closestPixelValue1]].

	rgbBlack _ 1.  "closest black that is not transparent in RGB"

	d = 16 ifTrue: [
		"five bits per component; top bits ignored"
		val _ (((rgb bitShift: -15) bitAnd: 16r7C00) bitOr:
			 ((rgb bitShift: -10) bitAnd: 16r03E0)) bitOr:
			 ((rgb bitShift: -5) bitAnd: 16r001F).
		^ val = 0 ifTrue: [rgbBlack] ifFalse: [val]].

	d = 32 ifTrue: [
		"eight bits per component; top 8 bits set to all ones (opaque alpha)"
		val _ LargePositiveInteger new: 4.
		val at: 3 put: ((rgb bitShift: -22) bitAnd: 16rFF).
		val at: 2 put: ((rgb bitShift: -12) bitAnd: 16rFF).
		val at: 1 put: ((rgb bitShift: -2) bitAnd: 16rFF).
		val = 0 ifTrue: [val at: 1 put: 1].  "closest non-transparent black"
		val at: 4 put: 16rFF.  "opaque alpha"
		^ val].

	d = 12 ifTrue: [  "for indexing a color map with 4 bits per color component"
		val _ (((rgb bitShift: -18) bitAnd: 16r0F00) bitOr:
			 ((rgb bitShift: -12) bitAnd: 16r00F0)) bitOr:
			 ((rgb bitShift: -6) bitAnd: 16r000F).
		^ val = 0 ifTrue: [rgbBlack] ifFalse: [val]].

	d = 9 ifTrue: [  "for indexing a color map with 3 bits per color component"
		val _ (((rgb bitShift: -21) bitAnd: 16r01C0) bitOr:
			 ((rgb bitShift: -14) bitAnd: 16r0038)) bitOr:
			 ((rgb bitShift: -7) bitAnd: 16r0007).
		^ val = 0 ifTrue: [rgbBlack] ifFalse: [val]].

	self error: 'unknown pixel depth: ', d printString
! !

!Color methodsFor: 'conversions' stamp: 'di 11/30/1998 09:03'!
pixelWordFor: depth filledWith: pixelValue
	"Return to a 32-bit word that concatenates enough copies of the given pixel value to fill the word (i.e., 32/depth copies). Depth should be one of 1, 2, 4, 8, 16, or 32. The pixel value should be an integer in 0..2^depth-1."
	| halfword |
	depth = 32 ifTrue: [^ pixelValue].
	depth = 16
		ifTrue: [halfword _ pixelValue]
		ifFalse: [halfword _ pixelValue * 
					(#(16rFFFF				"replicates at every bit"
						16r5555 -			"replicates every 2 bits"
						16r1111 - - -			"replicates every 4 bits"
						16r0101) at: depth)	"replicates every 8 bits"].
	^ halfword bitOr: (halfword bitShift: 16)! !

!Color methodsFor: 'conversions'!
pixelWordForDepth: depth
	"Return to a 32-bit word that concatenates enough copies of the receiver's pixel value to fill the word (i.e., 32/depth copies). Depth should be one of 1, 2, 4, 8, 16, or 32. The pixel value should be an integer in 0..2^depth-1."

	| pixelValue |
	pixelValue _ self pixelValueForDepth: depth.
	^ self pixelWordFor: depth filledWith: pixelValue
! !

!Color methodsFor: 'conversions' stamp: 'ar 1/14/1999 15:28'!
scaledPixelValue32
	"Return the alpha scaled pixel value for depth 32"
	^self pixelWordForDepth: 32! !


!Color methodsFor: 'private'!
attemptToMutateError
	"A color is immutable. Once a color's red, green, and blue have been initialized, you cannot change them. Instead, create a new Color and use it."

	self error: 'Color objects are immutable once created'
! !

!Color methodsFor: 'private'!
flushCache
	"Flush my cached bit pattern."

	cachedDepth _ nil.
	cachedBitPattern _ nil.
! !

!Color methodsFor: 'private'!
privateAlpha
	"Private!! Return the raw alpha value for opaque. Used only for equality testing."

	^ 255! !

!Color methodsFor: 'private'!
privateBlue
	"Private!! Return the internal representation of my blue component."

	^ rgb bitAnd: ComponentMask! !

!Color methodsFor: 'private'!
privateGreen
	"Private!! Return the internal representation of my green component.
	Replaced >> by bitShift: 0 -. SqR!! 2/25/1999 23:08"

	^ (rgb bitShift: 0 - GreenShift) bitAnd: ComponentMask! !

!Color methodsFor: 'private'!
privateRGB
	"Private!! Return the internal representation of my RGB components."

	^ rgb
! !

!Color methodsFor: 'private'!
privateRed
	"Private!! Return the internal representation of my red component."

	^ (rgb bitShift: 0 - RedShift) bitAnd: ComponentMask! !

!Color methodsFor: 'private'!
setHue: hue saturation: saturation brightness: brightness
	"Initialize this color to the given hue, saturation, and brightness. See the comment in the instance creation method for details."

	| s v hf i f p q t | 
	s _ (saturation asFloat max: 0.0) min: 1.0.
	v _ (brightness asFloat max: 0.0) min: 1.0.

	"zero saturation yields gray with the given brightness"
	s = 0.0 ifTrue: [ ^ self setRed: v green: v blue: v ].

	hf _ hue asFloat.
	(hf < 0.0 or: [hf >= 360.0])
		ifTrue: [hf _ hf - ((hf quo: 360.0) asFloat * 360.0)].
	hf _ hf / 60.0.
	i _ hf asInteger.  "integer part of hue"
	f _ hf fractionPart.         "fractional part of hue"
	p _ (1.0 - s) * v.
	q _ (1.0 - (s * f)) * v.
	t _ (1.0 - (s * (1.0 - f))) * v.

	0 = i ifTrue: [ ^ self setRed: v green: t blue: p ].
	1 = i ifTrue: [ ^ self setRed: q green: v blue: p ].
	2 = i ifTrue: [ ^ self setRed: p green: v blue: t ].
	3 = i ifTrue: [ ^ self setRed: p green: q blue: v ].
	4 = i ifTrue: [ ^ self setRed: t green: p blue: v ].
	5 = i ifTrue: [ ^ self setRed: v green: p blue: q ].

	self error: 'implementation error'.
! !

!Color methodsFor: 'private' stamp: 'di 11/2/97 12:19'!
setPrivateRed: r green: g blue: b
	"Initialize this color's r, g, and b components to the given values in the range [0..ComponentMax].  Encoded in a single variable as 3 integers in [0..1023]."

	rgb == nil ifFalse: [self attemptToMutateError].
	rgb _ ((r min: ComponentMask max: 0) bitShift: RedShift) +
		((g min: ComponentMask max: 0) bitShift: GreenShift) +
		 (b min: ComponentMask max: 0).
	cachedDepth _ nil.
	cachedBitPattern _ nil.
! !

!Color methodsFor: 'private'!
setRed: r green: g blue: b
	"Initialize this color's r, g, and b components to the given values in the range [0.0..1.0].  Encoded in a single variable as 3 integers in [0..1023]."

	rgb == nil ifFalse: [self attemptToMutateError].
	rgb _
		(((r * ComponentMax) rounded bitAnd: ComponentMask) bitShift: RedShift) +
		(((g * ComponentMax) rounded bitAnd: ComponentMask) bitShift: GreenShift) +
		 ((b * ComponentMax) rounded bitAnd: ComponentMask).
	cachedDepth _ nil.
	cachedBitPattern _ nil.
! !

!Color methodsFor: 'private'!
setRed: r green: g blue: b range: range
	"Initialize this color's r, g, and b components to the given values in the range [0..r]."

	rgb == nil ifFalse: [self attemptToMutateError].
	rgb _
		((((r * ComponentMask) // range) bitAnd: ComponentMask) bitShift: RedShift) +
		((((g * ComponentMask) // range) bitAnd: ComponentMask) bitShift: GreenShift) +
		 (((b * ComponentMask) // range) bitAnd: ComponentMask).
	cachedDepth _ nil.
	cachedBitPattern _ nil.
! !

!Color methodsFor: 'private' stamp: 'jm 9/23/2003 17:17'!
setRgb: rgbValue
	"Initialize this color."

	rgb == nil ifFalse: [self attemptToMutateError].
	rgb _ rgbValue.

! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Color class
	instanceVariableNames: ''!

!Color class methodsFor: 'instance creation' stamp: 'sw 11/9/1998 19:25'!
colorFrom: parm
	"Return an instantiated color from parm.  If parm is already a color, return it, else return the result of my performing it if it's a symbol, else just return the thing"
	(parm isKindOf: Color) ifTrue: [^ parm].
	(parm isKindOf: Symbol) ifTrue: [^ self perform: parm].
	^ parm! !

!Color class methodsFor: 'instance creation' stamp: 'jm 2/10/2008 11:20'!
colorFromPixelValue: p depth: d
	"Convert a pixel value for the given display depth into a color."
	"Details: For depths of 8 or less, the pixel value is simply looked up in a table. For greater depths, the color components are extracted and converted into a color."

	| r g b alpha |
	d = 8 ifTrue: [^ IndexedColors at: (p bitAnd: 16rFF) + 1].
	d = 4 ifTrue: [^ IndexedColors at: (p bitAnd: 16r0F) + 1].
	d = 2 ifTrue: [^ IndexedColors at: (p bitAnd: 16r03) + 1].
	d = 1 ifTrue: [^ IndexedColors at: (p bitAnd: 16r01) + 1].

	(d = 16) | (d = 15) ifTrue: [
		"five bits per component"
		r _ (p bitShift: -10) bitAnd: 16r1F.
		g _ (p bitShift: -5) bitAnd: 16r1F.
		b _ p bitAnd: 16r1F.
		^ Color r: r g: g b: b range: 31].

	d = 32 ifTrue: [
		"eight bits per component; 8 bits of alpha"
		r _ (p bitShift: -16) bitAnd: 16rFF.
		g _ (p bitShift: -8) bitAnd: 16rFF.
		b _ p bitAnd: 16rFF.
		alpha _ p bitShift: -24.
		alpha = 0 ifTrue:[^Color transparent].
		alpha < 255
			ifTrue: [^ (Color r: r g: g b: b range: 255) alpha: (alpha asFloat / 255.0)]
			ifFalse: [^ (Color r: r g: g b: b range: 255)]].

	d = 24 ifTrue: [
		"eight bits per component; 8 bits"
		r _ (p bitShift: -16) bitAnd: 16rFF.
		g _ (p bitShift: -8) bitAnd: 16rFF.
		b _ p bitAnd: 16rFF.
		^ (Color r: r g: g b: b range: 255)].

	d = 12 ifTrue: [
		"four bits per component"
		r _ (p bitShift: -8) bitAnd: 16rF.
		g _ (p bitShift: -4) bitAnd: 16rF.
		b _ p bitAnd: 16rF.
		^ Color r: r g: g b: b range: 15].

	d = 9 ifTrue: [
		"three bits per component"
		r _ (p bitShift: -6) bitAnd: 16r7.
		g _ (p bitShift: -3) bitAnd: 16r7.
		b _ p bitAnd: 16r7.
		^ Color r: r g: g b: b range: 7].

	self error: 'unknown pixel depth: ', d printString
! !

!Color class methodsFor: 'instance creation' stamp: 'EMP 3/15/2016 15:29'!
computeColorConvertingMap: targetColor from: sourceDepth to: destDepth keepSubPixelAA: keepSubPix
	"Note: The color converting map for sourceDepth=16 and for sourceDepth=32 are the same"
	sourceDepth < 16 ifTrue: [
		"source is 1-, 2-, 4-, or 8-bit indexed color.
		Assumed not to include subpixelAA"
		^ self computeIndexedColorConvertingMap: targetColor from: sourceDepth to: destDepth
	] ifFalse: [
		"source is 16-bit or 32-bit RGB.
		Might include subpixelAA"
		^ self computeRGBColorConvertingMap: targetColor to: destDepth keepSubPixelAA: keepSubPix
	]! !

!Color class methodsFor: 'instance creation' stamp: 'mir 7/21/1999 11:54'!
fromArray: colorDef
	colorDef size == 3
			ifTrue: [^self r: (colorDef at: 1) g: (colorDef at: 2) b: (colorDef at: 3)].
	colorDef size == 0
			ifTrue: [^Color transparent].
	colorDef size == 4
			ifTrue: [^(TranslucentColor r: (colorDef at: 1) g: (colorDef at: 2) b: (colorDef at: 3)) alpha: (colorDef at: 4)].
	self error: 'Undefined color definition'! !

!Color class methodsFor: 'instance creation' stamp: 'jm 11/29/2007 12:47'!
fromString: aString
	"Answer the color for an HTML color spec such as #FFCCAA or a named color. If the given string cannot be parsed as a color, return Color white."
	"(Color fromString: '#FFccAa') display"
	"(Color fromString: 'white') display"
	"(Color fromString: 'orange') display"

	| s r g b result sel |
	aString isEmptyOrNil ifTrue: [^ Color white].
	((aString first = $#) & (aString size = 7)) ifTrue: [
		[
			s _ (aString copyFrom: 2 to: aString size) asUppercase.
			r _ ('16r', (s copyFrom: 1 to: 2)) asNumber.
			g _ ('16r', (s copyFrom: 3 to: 4)) asNumber.
			b _ ('16r', (s copyFrom: 5 to: 6)) asNumber.
			result _ self r: r g: g b: b range: 255.
		] ifError: []].
	result ifNotNil: [^ result].
	
	"try to match result with known named colors"
	s _ aString asLowercase.
	sel _ ColorNames detect: [:cName | s = cName asLowercase] ifNone: [#white].
	result _ self perform: sel.

	^ result
! !

!Color class methodsFor: 'instance creation' stamp: 'jm 12/4/97 13:05'!
gray: brightness
	"Return a gray shade with the given brightness in the range [0.0..1.0]."

	^ self basicNew setRed: brightness green: brightness blue: brightness
! !

!Color class methodsFor: 'instance creation' stamp: 'EMP 12/22/2015 12:35'!
h: oldHue s: oldSaturation l: oldLightness
	| sat hue arr newSat |
	sat _ oldSaturation * ((oldLightness<0.5)ifTrue:[oldLightness]ifFalse:[1-oldLightness]).
	hue _ oldHue.
	[newSat _ 2*sat/(oldLightness + sat)] ifError: [newSat _ 1 "Fix for division by zero error"].
	arr _ {(hue \\ 360 "One spherical rotation"). newSat. oldLightness + sat}.
	^ Color h: arr first s: arr second v: arr third! !

!Color class methodsFor: 'instance creation'!
h: hue s: saturation v: brightness
	"Create a color with the given hue, saturation, and brightness. Hue is given as the angle in degrees of the color on the color circle where red is zero degrees. Saturation and brightness are numbers in [0.0..1.0] where larger values are more saturated or brighter colors. For example, (Color h: 0 s: 1 v: 1) is pure red."
	"Note: By convention, brightness is abbreviated 'v' to to avoid confusion with blue."

	^ self basicNew setHue: hue saturation: saturation brightness: brightness! !

!Color class methodsFor: 'instance creation'!
new

	^ self r: 0.0 g: 0.0 b: 0.0! !

!Color class methodsFor: 'instance creation' stamp: 'jm 12/4/97 13:04'!
r: r g: g b: b
	"Return a color with the given r, g, and b components in the range [0.0..1.0]."

	^ self basicNew setRed: r green: g blue: b
! !

!Color class methodsFor: 'instance creation'!
r: r g: g b: b alpha: alpha

	^ (self r: r g: g b: b) alpha: alpha! !

!Color class methodsFor: 'instance creation'!
r: r g: g b: b range: range
	"Return a color with the given r, g, and b components specified as integers in the range [0..r]. This avoids the floating point arithmetic in the red:green:blue: message and is thus a bit faster for certain applications (such as computing a sequence of colors for a palette)."

	^ self basicNew setRed: r green: g blue: b range: range! !

!Color class methodsFor: 'instance creation'!
random
	"Return a random color that isn't too dark or under-saturated."

	^ self basicNew
		setHue: (360.0 * RandomStream next)
		saturation: (0.3 + (RandomStream next * 0.7))
		brightness: (0.4 + (RandomStream next * 0.6))! !


!Color class methodsFor: 'class initialization'!
initialize
	"Color initialize"

	"Details: Externally, the red, green, and blue components of color
	are floats in the range [0.0..1.0]. Internally, they are represented
	as integers in the range [0..ComponentMask] packing into a
	small integer to save space and to allow fast hashing and
	equality testing.

	For a general description of color representations for computer
	graphics, including the relationship between the RGB and HSV
	color models used here, see Chapter 17 of Foley and van Dam,
	Fundamentals of Interactive Computer Graphics, Addison-Wesley,
	1982."

	ComponentMask _ 1023.
	HalfComponentMask _ 512.  "used to round up in integer calculations"
	ComponentMax _ 1023.0.  "a Float used to normalize components"
	RedShift _ 20.
	GreenShift _ 10.
	BlueShift _ 0.

	PureRed		 _ self r: 1 g: 0 b: 0.
	PureGreen	 _ self r: 0 g: 1 b: 0.
	PureBlue	 _ self r: 0 g: 0 b: 1.
	PureYellow	 _ self r: 1 g: 1 b: 0.
	PureCyan	 _ self r: 0 g: 1 b: 1.
	PureMagenta _ self r: 1 g: 0 b: 1.

	RandomStream _ Random new.

	self initializeIndexedColors.
	self initializeGrayToIndexMap.
	self initializeNames.
	self initializeHighLights.
! !

!Color class methodsFor: 'class initialization'!
initializeGrayToIndexMap
	"Build an array of gray values available in the 8-bit colormap. This array is indexed by a gray level between black (1) and white (256) and returns the pixel value for the corresponding gray level."
	"Note: This method must be called after initializeIndexedColors, since it uses IndexedColors."
	"Color initializeGrayToIndexMap"

	| grayLevels grayIndices c distToClosest dist indexOfClosest |
	"record the level and index of each gray in the 8-bit color table"
	grayLevels _ OrderedCollection new.
	grayIndices _ OrderedCollection new.
	"Note: skip the first entry, which is reserved for transparent"
	2 to: IndexedColors size do: [:i |
		c _ IndexedColors at: i.
		c saturation = 0.0 ifTrue: [  "c is a gray"
			grayLevels add: (c privateBlue) >> 2.  "top 8 bits; R, G, and B are the same"
			grayIndices add: i - 1]].  "pixel values are zero-based"
	grayLevels _ grayLevels asArray.
	grayIndices _ grayIndices asArray.

	"for each gray level in [0..255], select the closest match"
	GrayToIndexMap _ ByteArray new: 256.
	0 to: 255 do: [:level |
		distToClosest _ 10000.  "greater than distance to any real gray"
		1 to: grayLevels size do: [:i |
			dist _ (level - (grayLevels at: i)) abs.
			dist < distToClosest ifTrue: [
				distToClosest _ dist.
				indexOfClosest _ grayIndices at: i]].
		GrayToIndexMap at: (level + 1) put: indexOfClosest].
! !

!Color class methodsFor: 'class initialization' stamp: 'jm 12/21/2005 18:28'!
initializeHighLights
	"Create a set of Bitmaps for quickly reversing areas of the screen without converting colors. "
	"Note: For 16 and 32 bits, leave least significant bit alone to avoid having white invert to transparent (i.e. a pixel value of zero)."
	"Color initializeHighLights"

	| t |
	t _ Array new: 32.
	t at: 1 put: (Bitmap with: 16rFFFFFFFF).
	t at: 2 put: (Bitmap with: 16rFFFFFFFF).
	t at: 4 put: (Bitmap with: 16r55555555).
	t at: 8 put: (Bitmap with: 16r7070707).
	t at: 16 put: (Bitmap with: 16rFFFEFFFE).
	t at: 32 put: (Bitmap with: 16rFFFFFE).  "don't invert alpha"
	HighLightBitmaps _ t.
! !

!Color class methodsFor: 'class initialization'!
initializeIndexedColors
	"Build an array of colors corresponding to the fixed colormap used
	 for display depths of 1, 2, 4, or 8 bits."
	"Color initializeIndexedColors"

	| a index grayVal |
	a _ Array new: 256.

	"1-bit colors (monochrome)"
	a at: 1 put: (Color r: 1.0 g: 1.0 b: 1.0).		"white or transparent"
	a at: 2 put: (Color r: 0.0 g: 0.0 b: 0.0).	"black"

	"additional colors for 2-bit color"
	a at: 3 put: (Color r: 1.0 g: 1.0 b: 1.0).	"opaque white"
	a at: 4 put: (Color r: 0.5 g: 0.5 b: 0.5).	"1/2 gray"

	"additional colors for 4-bit color"
	a at:  5 put: (Color r: 1.0 g: 0.0 b: 0.0).	"red"
	a at:  6 put: (Color r: 0.0 g: 1.0 b: 0.0).	"green"
	a at:  7 put: (Color r: 0.0 g: 0.0 b: 1.0).	"blue"
	a at:  8 put: (Color r: 0.0 g: 1.0 b: 1.0).	"cyan"
	a at:  9 put: (Color r: 1.0 g: 1.0 b: 0.0).	"yellow"
	a at: 10 put: (Color r: 1.0 g: 0.0 b: 1.0).	"magenta"

	a at: 11 put: (Color r: 0.125 g: 0.125 b: 0.125).		"1/8 gray"
	a at: 12 put: (Color r: 0.25 g: 0.25 b: 0.25).		"2/8 gray"
	a at: 13 put: (Color r: 0.375 g: 0.375 b: 0.375).		"3/8 gray"
	a at: 14 put: (Color r: 0.625 g: 0.625 b: 0.625).		"5/8 gray"
	a at: 15 put: (Color r: 0.75 g: 0.75 b: 0.75).		"6/8 gray"
	a at: 16 put: (Color r: 0.875 g: 0.875 b: 0.875).		"7/8 gray"

	"additional colors for 8-bit color"
	"24 more shades of gray (1/32 increments but not repeating 1/8 increments)"
	index _ 17.
	1 to: 31 do: [:v |
		(v \\ 4) = 0 ifFalse: [
			grayVal _ v / 32.0.
			a at: index put: (Color r: grayVal g: grayVal b: grayVal).
			index _ index + 1]].

	"The remainder of color table defines a color cube with six steps
	 for each primary color. Note that the corners of this cube repeat
	 previous colors, but this simplifies the mapping between RGB colors
	 and color map indices. This color cube spans indices 40 through 255
	 (indices 41-256 in this 1-based array)."
	0 to: 5 do: [:r |
		0 to: 5 do: [:g |
			0 to: 5 do: [:b |
				index _ 41 + ((36 * r) + (6 * b) + g).
				index > 256 ifTrue: [
					self error: 'index out of range in color table compuation'].
				a at: index put: (Color r: r g: g b: b range: 5)]]].

	IndexedColors _ a.
! !

!Color class methodsFor: 'class initialization' stamp: 'dwh 7/7/1999 23:57'!
initializeNames
	"Name some colors."
	"Color initializeNames"

	ColorNames _ OrderedCollection new.
	self named: #black put: (Color r: 0 g: 0 b: 0).
	self named: #veryVeryDarkGray put: (Color r: 0.125 g: 0.125 b: 0.125).
	self named: #veryDarkGray put: (Color r: 0.25 g: 0.25 b: 0.25).
	self named: #darkGray put: (Color r: 0.375 g: 0.375 b: 0.375).
	self named: #gray put: (Color r: 0.5 g: 0.5 b: 0.5).
	self named: #lightGray put: (Color r: 0.625 g: 0.625 b: 0.625).
	self named: #veryLightGray put: (Color r: 0.75 g: 0.75 b: 0.75).
	self named: #veryVeryLightGray put: (Color r: 0.875 g: 0.875 b: 0.875).
	self named: #white put: (Color r: 1.0 g: 1.0 b: 1.0).
	self named: #red put: (Color r: 1.0 g: 0 b: 0).
	self named: #yellow put: (Color r: 1.0 g: 1.0 b: 0).
	self named: #green put: (Color r: 0 g: 1.0 b: 0).
	self named: #cyan put: (Color r: 0 g: 1.0 b: 1.0).
	self named: #blue put: (Color r: 0 g: 0 b: 1.0).
	self named: #magenta put: (Color r: 1.0 g: 0 b: 1.0).
	self named: #brown put: (Color r: 0.6 g: 0.2 b: 0).
	self named: #orange put: (Color r: 1.0 g: 0.6 b: 0).
	self named: #lightRed put: (Color r: 1.0 g: 0.8 b: 0.8).
	self named: #lightYellow put: (Color r: 1.0 g: 1.0 b: 0.8).
	self named: #lightGreen put: (Color r: 0.8 g: 1.0 b: 0.6).
	self named: #lightCyan put: (Color r: 0.4 g: 1.0 b: 1.0).
	self named: #lightBlue put: (Color r: 0.8 g: 1.0 b: 1.0).
	self named: #lightMagenta put: (Color r: 1.0 g: 0.8 b: 1.0).
	self named: #lightBrown put: (Color r: 1.0 g: 0.6 b: 0.2).
	self named: #lightOrange put: (Color r: 1.0 g: 0.8 b: 0.4).
	self named: #transparent put: (TranslucentColor new alpha: 0.0).
	self named: #paleBuff put: (Color r: 254 g: 250 b: 235 range: 255).
	self named: #paleBlue put: (Color r: 222 g: 249 b: 254 range: 255).
	self named: #paleYellow put: (Color r: 255 g: 255 b: 217 range: 255).
	self named: #paleGreen put: (Color r: 223 g: 255 b: 213 range: 255).
	self named: #paleRed put: (Color r: 255 g: 230 b: 230 range: 255).
	self named: #veryPaleRed put: (Color r: 255 g: 242 b: 242 range: 255).
	self named: #paleTan put: (Color r: 235 g: 224 b: 199 range: 255).
	self named: #paleMagenta put: (Color r: 255 g: 230 b: 255 range: 255).
	self named: #paleOrange put: (Color r: 253 g: 237 b: 215 range: 255).
	self named: #palePeach put: (Color r: 255 g: 237 b: 213 range: 255).

! !

!Color class methodsFor: 'class initialization' stamp: 'ar 2/16/2000 21:56'!
initializeTranslucentPatterns
	"Color initializeTranslucentPatterns"
	| mask bits pattern patternList |
	TranslucentPatterns _ Array new: 8.
	#(1 2 4 8) do:[:d|
		patternList _ Array new: 5.
		mask _ (1 bitShift: d) - 1.
		bits _ 2 * d.
		[bits >= 32] whileFalse: [
			mask _ mask bitOr: (mask bitShift: bits).  "double the length of mask"
			bits _ bits + bits].
		"0% pattern"
		pattern _ Bitmap with: 0 with: 0.
		patternList at: 1 put: pattern.
		"25% pattern"
		pattern _ Bitmap with: mask with: 0.
		patternList at: 2 put: pattern.
		"50% pattern"
		pattern _ Bitmap with: mask with: mask bitInvert32.
		patternList at: 3 put: pattern.
		"75% pattern"
		pattern _ Bitmap with: mask with: 16rFFFFFFFF.
		patternList at: 4 put: pattern.
		"100% pattern"
		pattern _ Bitmap with: 16rFFFFFFFF with: 16rFFFFFFFF.
		patternList at: 5 put: pattern.
		TranslucentPatterns at: d put: patternList.
	].! !

!Color class methodsFor: 'class initialization' stamp: 'tk 6/13/96'!
named: newName put: aColor
	"Add a new color to the list and create an access message and a class variable for it.  The name should start with a lowercase letter.  (The class variable will start with an uppercase letter.)  (Color colorNames) returns a list of all color names.  "
	| str cap sym accessor csym |
	(aColor isKindOf: self) ifFalse: [^ self error: 'not a Color'].
	str _ newName asString.
	sym _ str asSymbol.
	cap _ str capitalized.
	csym _ cap asSymbol.
	(self class canUnderstand: sym) ifFalse: [
		"define access message"
		accessor _ str, (String with: Character cr with: Character tab), 			'^', cap.
		self class compile: accessor
			classified: 'named colors'].
	(self classPool includesKey: csym) ifFalse: [
		self addClassVarName: cap].
	(ColorNames includes: sym) ifFalse: [
		ColorNames add: sym].
	^ self classPool at: csym put: aColor! !


!Color class methodsFor: 'examples'!
colorRampForDepth: depth extent: aPoint
	"Returns a form of the given size showing R, G, B, and gray ramps for the given depth. Useful for testing color conversions between different depths."
	"(Color colorRampForDepth: Display depth extent: 256@80) display"
	"(Color colorRampForDepth: 32 extent: 256@80) displayOn: Display at: 0@0 rule: Form paint"

	| f dx dy r |
	f _ Form extent: aPoint depth: depth.
	dx _ aPoint x // 256.
	dy _ aPoint y // 4.
	0 to: 255 do: [:i |
		r _ (dx * i)@0 extent: dx@dy.
		f fill: r fillColor: (Color r: i g: 0 b: 0 range: 255).
		r _ r translateBy: 0@dy.
		f fill: r fillColor: (Color r: 0 g: i b: 0 range: 255).
		r _ r translateBy: 0@dy.
		f fill: r fillColor: (Color r: 0 g: 0 b: i range: 255).
		r _ r translateBy: 0@dy.
		f fill: r fillColor: (Color r: i g: i b: i range: 255)].
	^ f
! !

!Color class methodsFor: 'examples' stamp: 'tk 6/19/96'!
hotColdShades: thisMany
	"An array of thisMany colors showing temperature from blue to red to white hot.  (Later improve this by swinging in hue.)  "
	"Color showColors: (Color hotColdShades: 25)"

	| n s1 s2 s3 s4 s5 |
	thisMany < 5 ifTrue: [^ self error: 'must be at least 5 shades'].
	n _ thisMany // 5.
	s1 _ self white mix: self yellow shades: (thisMany - (n*4)).
	s2 _ self yellow mix: self red shades: n+1.
	s2 _ s2 copyFrom: 2 to: n+1.
	s3 _ self red mix: self green darker shades: n+1.
	s3 _ s3 copyFrom: 2 to: n+1.
	s4 _ self green darker mix: self blue shades: n+1.
	s4 _ s4 copyFrom: 2 to: n+1.
	s5 _ self blue mix: self black shades: n+1.
	s5 _ s5 copyFrom: 2 to: n+1.
	^ s1, s2, s3, s4, s5
! !

!Color class methodsFor: 'examples'!
showColorCube
	"Show a 12x12x12 color cube."
	"Color showColorCube"

	0 to: 11 do: [:r |
		0 to: 11 do: [:g |
			0 to: 11 do: [:b |	
				Display fill: (((r*60) + (b*5)) @ (g*5) extent: 5@5)
					fillColor: (Color r: r g: g b: b range: 11)]]].
! !

!Color class methodsFor: 'examples'!
showColors: colorList
	"Display the given collection of colors across the top of the Display."

	| w r |
	w _ Display width // colorList size.
	r _ 0@0 extent: w@((w min: 30) max: 10).
	colorList do: [:c |
		Display fill: r fillColor: c.
		r _ r translateBy: w@0].
! !

!Color class methodsFor: 'examples'!
wheel: thisMany
	"Return a collection of thisMany colors evenly spaced around the color wheel."
	"Color showColors: (Color wheel: 12)"

	^ Color wheel: thisMany saturation: 0.9 brightness: 0.7
! !

!Color class methodsFor: 'examples'!
wheel: thisMany saturation: s brightness: v
	"Return a collection of thisMany colors evenly spaced around the color wheel, all of the given saturation and brightness."
	"Color showColors: (Color wheel: 12 saturation: 0.4 brightness: 1.0)"
	"Color showColors: (Color wheel: 12 saturation: 0.8 brightness: 0.5)"

	^ (Color h: 0.0 s: s v: v) wheel: thisMany
! !


!Color class methodsFor: 'named colors'!
black
	^Black! !

!Color class methodsFor: 'named colors'!
blue
	^Blue! !

!Color class methodsFor: 'named colors'!
brown
	^Brown! !

!Color class methodsFor: 'named colors'!
cyan
	^Cyan! !

!Color class methodsFor: 'named colors'!
darkGray
	^DarkGray! !

!Color class methodsFor: 'named colors'!
gray
	^Gray! !

!Color class methodsFor: 'named colors'!
green
	^Green! !

!Color class methodsFor: 'named colors'!
lightBlue
	^LightBlue! !

!Color class methodsFor: 'named colors'!
lightBrown
	^LightBrown! !

!Color class methodsFor: 'named colors'!
lightCyan
	^LightCyan! !

!Color class methodsFor: 'named colors'!
lightGray
	^LightGray! !

!Color class methodsFor: 'named colors'!
lightGreen
	^LightGreen! !

!Color class methodsFor: 'named colors'!
lightMagenta
	^LightMagenta! !

!Color class methodsFor: 'named colors'!
lightOrange
	^LightOrange! !

!Color class methodsFor: 'named colors'!
lightRed
	^LightRed! !

!Color class methodsFor: 'named colors'!
lightYellow
	^LightYellow! !

!Color class methodsFor: 'named colors'!
magenta
	^Magenta! !

!Color class methodsFor: 'named colors'!
orange
	^Orange! !

!Color class methodsFor: 'named colors' stamp: 'dwh 7/7/1999 23:56'!
paleBlue
	^PaleBlue! !

!Color class methodsFor: 'named colors' stamp: 'dwh 7/7/1999 23:56'!
paleBuff
	^PaleBuff! !

!Color class methodsFor: 'named colors' stamp: 'dwh 7/7/1999 23:56'!
paleGreen
	^PaleGreen! !

!Color class methodsFor: 'named colors' stamp: 'dwh 7/7/1999 23:56'!
paleMagenta
	^PaleMagenta! !

!Color class methodsFor: 'named colors' stamp: 'dwh 7/7/1999 23:56'!
paleOrange
	^PaleOrange! !

!Color class methodsFor: 'named colors' stamp: 'dwh 7/7/1999 23:56'!
palePeach
	^PalePeach! !

!Color class methodsFor: 'named colors' stamp: 'dwh 7/7/1999 23:56'!
paleRed
	^PaleRed! !

!Color class methodsFor: 'named colors' stamp: 'dwh 7/7/1999 23:56'!
paleTan
	^PaleTan! !

!Color class methodsFor: 'named colors' stamp: 'dwh 7/7/1999 23:56'!
paleYellow
	^PaleYellow! !

!Color class methodsFor: 'named colors'!
red
	^Red! !

!Color class methodsFor: 'named colors' stamp: 'wod 5/24/1998 01:56'!
tan
	^  Color r: 0.8 g: 0.8 b: 0.5! !

!Color class methodsFor: 'named colors'!
transparent
	^Transparent! !

!Color class methodsFor: 'named colors'!
veryDarkGray
	^VeryDarkGray! !

!Color class methodsFor: 'named colors'!
veryLightGray
	^VeryLightGray! !

!Color class methodsFor: 'named colors' stamp: 'dwh 7/7/1999 23:56'!
veryPaleRed
	^VeryPaleRed! !

!Color class methodsFor: 'named colors'!
veryVeryDarkGray
	^VeryVeryDarkGray! !

!Color class methodsFor: 'named colors'!
veryVeryLightGray
	^VeryVeryLightGray! !

!Color class methodsFor: 'named colors'!
white
	^White! !

!Color class methodsFor: 'named colors'!
yellow
	^Yellow! !


!Color class methodsFor: 'colormaps' stamp: 'jm 5/2/1999 07:24'!
cachedColormapFrom: sourceDepth to: destDepth
	"Return a cached colormap for mapping between the given depths. Always return a real colormap, not nil; this allows the client to get an identity colormap that can then be copied and modified to do color transformations."
	"Note: This method returns a shared, cached colormap to save time and space. Clients that need to modify a colormap returned by this method should make a copy and modify that!!"
	"Note: The colormap cache may be cleared by evaluating 'Color shutDown'."

	| srcIndex map |
	CachedColormaps class == Array ifFalse: [CachedColormaps _ (1 to: 9) collect: [:i | Array new: 32]].
	srcIndex _ sourceDepth.
	sourceDepth > 8 ifTrue: [srcIndex _ 9].
	(map _ (CachedColormaps at: srcIndex) at: destDepth) ~~ nil ifTrue: [^ map].

	map _ self computeColormapFrom: sourceDepth to: destDepth.
	(CachedColormaps at: srcIndex) at: destDepth put: map.
	^ map
! !

!Color class methodsFor: 'colormaps'!
colorMapIfNeededFrom: sourceDepth to: destDepth
	"Return a colormap for mapping between the given depths, or nil if no colormap is needed."
	"Note: This method returns a shared, cached colormap to save time and space. Clients that need to modify a colormap returned by this method should make a copy and modify that!!"

	sourceDepth = destDepth ifTrue: [^ nil].  "not needed if depths are the same"

	(sourceDepth >= 16) & (destDepth >= 16) ifTrue: [
		"mapping is done in BitBlt by zero-filling or truncating each color component"
		^ nil].

	^ Color cachedColormapFrom: sourceDepth to: destDepth
! !

!Color class methodsFor: 'colormaps' stamp: 'jm 3/25/1999 19:48'!
computeColormapFrom: sourceDepth to: destDepth
	"Compute a colorMap for translating between the given depths. A colormap is a Bitmap whose entries contain the pixel values for the destination depth. Typical clients use cachedColormapFrom:to: instead."

	| map bitsPerColor |
	sourceDepth < 16 ifTrue: [
		"source is 1-, 2-, 4-, or 8-bit indexed color"
		map _ (IndexedColors copyFrom: 1 to: (1 bitShift: sourceDepth))
					collect: [:c | c pixelValueForDepth: destDepth].
		map _ map as: Bitmap.
	] ifFalse: [
		"source is 16-bit or 32-bit RGB"
		destDepth > 8
			ifTrue: [bitsPerColor _ 5]  "retain maximum color resolution"
			ifFalse: [bitsPerColor _ 4].
		map _ self computeRGBColormapFor: destDepth bitsPerColor: bitsPerColor].

	"Note: zero is transparent except when source depth is one-bit deep"
	sourceDepth > 1 ifTrue: [map at: 1 put: 0].
	^ map
! !

!Color class methodsFor: 'colormaps' stamp: 'EMP 3/15/2016 15:30'!
computeIndexedColorConvertingMap: targetColor from: sourceDepth to: destDepth
	| map |
	
	map _ (self indexedColors copyFrom: 1 to: (1 bitShift: sourceDepth)) collect: [ :cc | | f c |
		f _ 1.0 - (cc red + cc green + cc blue / 3.0 ).
		c _ targetColor
			ifNotNil: [
				destDepth = 32
					ifTrue: [ targetColor * f alpha: f]
					ifFalse: [ targetColor alphaMixed: f*1.5 with: Color white ]]
			ifNil: [ cc ].
		destDepth = 32
			ifTrue: [ c pixelValueForDepth: destDepth]
			ifFalse: [
				f = 0.0
					ifTrue: [ 0 ]
					ifFalse: [ c pixelValueForDepth: destDepth ]]].
	map _ map as: Bitmap.
	^map! !

!Color class methodsFor: 'colormaps' stamp: 'EMP 3/15/2016 15:30'!
computeRGBColorConvertingMap: targetColor to: destDepth keepSubPixelAA: keepSubPix
	"Builds a colormap intended to convert from subpixelAA black values to targetColor values.
	keepSubPix
		ifTrue: [ Answer colors that also include subpixelAA ]
		ifFalse: [ 
			Take fullpixel luminance level. Apply it to targetColor.
			I.e. answer colors with NO subpixelAA ]"

	| mask map c bitsPerColor r g b f v |

	destDepth > 8
		ifTrue: [bitsPerColor _ 5]  "retain maximum color resolution"
		ifFalse: [bitsPerColor _ 4].
	"Usually a bit less is enough, but make it configurable"
	bitsPerColor _ bitsPerColor min: Preferences aaFontsColormapDepth.
	mask _ (1 bitShift: bitsPerColor) - 1.
	map _ Bitmap new: (1 bitShift: (3 * bitsPerColor)).
	0 to: map size - 1 do: [:i |
		r _ (i bitShift: 0 - (2 * bitsPerColor)) bitAnd: mask.
		g _ (i bitShift: 0 - bitsPerColor) bitAnd: mask.
		b _ (i bitShift: 0) bitAnd: mask.
		f _ 1.0 - (r + g + b / 3.0 / mask).
		c _ targetColor
			ifNotNil: [
				(keepSubPix and: [destDepth > 8]) ifTrue: [
						Color
							r: 1.0 - (r asFloat/mask) * targetColor red
							g: 1.0 - (g asFloat/mask) * targetColor green
							b: 1.0 - (b asFloat/mask) * targetColor blue
							alpha: f	* targetColor alpha "alpha will be ignored below, in #pixelValueForDepth: if destDepth ~= 32" ]
				ifFalse: [
					destDepth = 32
						ifTrue: [ targetColor * f alpha: f * targetColor alpha ]
						ifFalse: [ targetColor alphaMixed: f*1.5 with: Color white ]]]
			ifNil: [ Color r: r g: g b: b range: mask].	"This is currently used only to keep some SubPixelAA on destDepth = 8, using a single pass of rule 25"
		v _ destDepth = 32
			ifTrue: [ c pixelValueForDepth: destDepth]
			ifFalse: [
				f < 0.1
					ifTrue: [ 0 ]
					ifFalse: [ c pixelValueForDepth: destDepth ]].
		map at: i + 1 put: v ].
	^ map! !

!Color class methodsFor: 'colormaps' stamp: 'jm 12/4/97 15:25'!
computeRGBColormapFor: destDepth bitsPerColor: bitsPerColor
	"Compute a colorMap for translating from 16-bit or 32-bit RGB color to the given depth, using the given number of of bits per color component."

	| mask map c |
	(#(3 4 5) includes: bitsPerColor)
		ifFalse: [self error: 'BitBlt only supports 3, 4, or 5 bits per color component'].
	mask _ (1 bitShift: bitsPerColor) - 1.
	map _ Bitmap new: (1 bitShift: (3 * bitsPerColor)).
	0 to: map size - 1 do: [:i |
		c _ Color
			r: ((i bitShift: 0 - (2 * bitsPerColor)) bitAnd: mask)
			g: ((i bitShift: 0 - bitsPerColor) bitAnd: mask)
			b: ((i bitShift: 0) bitAnd: mask)
			range: mask.
		map at: i + 1 put: (c pixelValueForDepth: destDepth)].

	map at: 1 put: (Color transparent pixelWordForDepth: destDepth).  "zero always transparent"
	^ map
! !


!Color class methodsFor: 'other'!
colorNames
	"Return a collection of color names."

	^ ColorNames! !

!Color class methodsFor: 'other'!
indexedColors

	^ IndexedColors! !

!Color class methodsFor: 'other' stamp: 'di 3/29/1999 13:33'!
maskingMap: depth
	"Return a color map that maps all colors except transparent to words of all ones. Used to create a mask for a Form whose transparent pixel value is zero. Cache the most recently used map."

	| sizeNeeded |
	depth <= 8
		ifTrue: [sizeNeeded _ 1 bitShift: depth]
		ifFalse: [sizeNeeded _ 4096].

	(MaskingMap == nil or: [MaskingMap size ~= sizeNeeded]) ifTrue:
		[MaskingMap _ Bitmap new: sizeNeeded withAll: 16rFFFFFFFF.
		MaskingMap at: 1 put: 0.  "transparent"].

	^ MaskingMap
! !

!Color class methodsFor: 'other' stamp: 'jm 12/21/2005 18:23'!
quickHighLight: depth
	"Quickly return a BitBlt-ready raw colorValue for highlighting areas."

	^ HighLightBitmaps at: depth
! !

!Color class methodsFor: 'other' stamp: 'jm 1/1/2004 11:07'!
shutDown
	"Clear caches to save space in snapshots."
	"Color shutDown"

	ColorChart _ nil.		"Palette of colors for the user to pick from"
	CachedColormaps _ nil.	"Maps to translate between color depths"
	MaskingMap _ nil.		"Maps all colors except transparent to black for creating a mask"
! !

!Color class methodsFor: 'other' stamp: 'ar 2/16/2000 21:56'!
translucentMaskFor: alphaValue depth: d
	"Return a pattern representing a mask usable for stipple transparency"
	^(TranslucentPatterns at: d) at: ((alphaValue min: 1.0 max: 0.0) * 4) rounded + 1! !


!Color class methodsFor: 'color from user' stamp: 'jm 12/5/97 18:35'!
colorPaletteForDepth: depth extent: chartExtent
	"Display a palette of colors sorted horizontally by hue and vertically by lightness. Useful for eyeballing the color gamut of the display, or for choosing a color interactively."
	"Note: It is slow to build this palette, so it should be cached for quick access."
	"(Color colorPaletteForDepth: 16 extent: 190@60) display"

	| basicHue x y c startHue palette transHt vSteps transCaption grayWidth hSteps |
	palette _ Form extent: chartExtent depth: depth.
	transCaption _ "(DisplayText text: 'no color' asText textStyle: (TextConstants at: #ComicPlain)) form storeString"
		(Form extent: 34@9 depth: 1
			fromArray: #(0 0 256 0 256 0 3808663859 2147483648 2491688266 2147483648 2491688266 0 2491688266 0 2466486578 0 0 0)
			offset: 0@0).
	transHt _ transCaption height.
	palette fillWhite: (0@0 extent: palette width@transHt).
	palette fillBlack: (0@transHt extent: palette width@1).
	transCaption displayOn: palette at: palette boundingBox topCenter - ((transCaption width // 2)@0).
	grayWidth _ 10.
	startHue _ 338.0.
	vSteps _ palette height - transHt // 2.
	hSteps _ palette width - grayWidth.
	x _ 0.
	startHue to: startHue + 360.0 by: 360.0/hSteps do: [:h |
		basicHue _ Color h: h asFloat s: 1.0 v: 1.0.
		y _ transHt+1.
		0 to: vSteps do: [:n |
 			c _ basicHue mixed: (n asFloat / vSteps asFloat) with: Color white.
			palette fill: (x@y extent: 1@1) fillColor: c.
			y _ y + 1].
		1 to: vSteps do: [:n |
 			c _ Color black mixed: (n asFloat / vSteps asFloat) with: basicHue.
			palette fill: (x@y extent: 1@1) fillColor: c.
			y _ y + 1].
		x _ x + 1].
	y _ transHt + 1.
	1 to: vSteps * 2 do: [:n |
 		c _ Color black mixed: (n asFloat / (vSteps*2) asFloat) with: Color white.
		palette fill: (x@y extent: 10@1) fillColor: c.
		y _ y + 1].
	^ palette
! !

!Color class methodsFor: 'color from user' stamp: 'jm 1/19/1999 11:33'!
colorTest: depth extent: chartExtent colorMapper: colorMapper
	"Create a palette of colors sorted horizontally by hue and vertically by lightness. Useful for eyeballing the color gamut of the display, or for choosing a color interactively."
	"Note: It is slow to build this palette, so it should be cached for quick access."
	"(Color colorTest: 32 extent: 570@180 colorMapper: [:c | c]) display"
	"(Color colorTest: 32 extent: 570@180 colorMapper:
		[:c | Color
			r: (c red * 7) asInteger / 7
			g: (c green * 7) asInteger / 7
			b: (c blue * 3) asInteger / 3]) display"
	"(Color colorTest: 32 extent: 570@180 colorMapper:
		[:c | Color
			r: (c red * 5) asInteger / 5
			g: (c green * 5) asInteger / 5
			b: (c blue * 5) asInteger / 5]) display"
	"(Color colorTest: 32 extent: 570@180 colorMapper:
		[:c | Color
			r: (c red * 15) asInteger / 15
			g: (c green * 15) asInteger / 15
			b: (c blue * 15) asInteger / 15]) display"
	"(Color colorTest: 32 extent: 570@180 colorMapper:
		[:c | Color
			r: (c red * 31) asInteger / 31
			g: (c green * 31) asInteger / 31
			b: (c blue * 31) asInteger / 31]) display"

	| basicHue x y c startHue palette transHt vSteps transCaption grayWidth hSteps |
	palette _ Form extent: chartExtent depth: depth.
	transCaption _ "(DisplayText text: 'no color' asText textStyle: (TextConstants at: #ComicPlain)) form storeString"
		(Form extent: 34@9 depth: 1
			fromArray: #(0 0 256 0 256 0 3808663859 2147483648 2491688266 2147483648 2491688266 0 2491688266 0 2466486578 0 0 0)
			offset: 0@0).
	transHt _ transCaption height.
	palette fillWhite: (0@0 extent: palette width@transHt).
	palette fillBlack: (0@transHt extent: palette width@1).
	transCaption displayOn: palette at: palette boundingBox topCenter - ((transCaption width // 2)@0).
	grayWidth _ 10.
	startHue _ 338.0.
	vSteps _ palette height - transHt // 2.
	hSteps _ palette width - grayWidth.
	x _ 0.
	startHue to: startHue + 360.0 by: 360.0/hSteps do: [:h |
		basicHue _ Color h: h asFloat s: 1.0 v: 1.0.
		y _ transHt+1.
		0 to: vSteps do: [:n |
 			c _ basicHue mixed: (n asFloat / vSteps asFloat) with: Color white.
			c _ colorMapper value: c.
			palette fill: (x@y extent: 1@1) fillColor: c.
			y _ y + 1].
		1 to: vSteps do: [:n |
 			c _ Color black mixed: (n asFloat / vSteps asFloat) with: basicHue.
			c _ colorMapper value: c.
			palette fill: (x@y extent: 1@1) fillColor: c.
			y _ y + 1].
		x _ x + 1].
	y _ transHt + 1.
	1 to: vSteps * 2 do: [:n |
 		c _ Color black mixed: (n asFloat / (vSteps*2) asFloat) with: Color white.
		c _ colorMapper value: c.
		palette fill: (x@y extent: 10@1) fillColor: c.
		y _ y + 1].
	^ palette
! !

!Color class methodsFor: 'color from user' stamp: 'di 4/13/1999 14:30'!
fromUser
	"Displays a color palette of colors, waits for a mouse click, and returns the selected color. Any pixel on the Display can be chosen, not just those in the color palette."
	"Note: Since the color chart is cached, you may need to do 'ColorChart _ nil' after changing the oldColorPaletteForDepth:extent: method."
	"Color fromUser"

	| d startPt save tr oldColor c here s |
	d _ Display depth.
	((ColorChart == nil) or: [ColorChart depth ~= Display depth]) 
		ifTrue: [ColorChart _ self oldColorPaletteForDepth: d extent: (2 * 144)@80].
	Sensor cursorPoint y < Display center y 
		ifTrue: [startPt _ 0@(Display boundingBox bottom - ColorChart height)]
		ifFalse: [startPt _ 0@0].

	save _ Form fromDisplay: (startPt extent: ColorChart extent).
	ColorChart displayAt: startPt.
	tr _ ColorChart extent - (50@19) corner: ColorChart extent.
	tr _ tr translateBy: startPt.

	oldColor _ nil.
	[Sensor anyButtonPressed] whileFalse: [
		c _ Display colorAt: (here _ Sensor cursorPoint).
		(tr containsPoint: here)
			ifFalse: [Display fill: (0@61+startPt extent: 20@19) fillColor: c]
			ifTrue: [
				c _ Color transparent.
				Display fill: (0@61+startPt extent: 20@19) fillColor: Color white].
		c = oldColor ifFalse: [
			Display fillWhite: (20@61 + startPt extent: 135@19).
			c isTransparent
				ifTrue: [s _ 'transparent']
				ifFalse: [s _ c shortPrintString.
						s _ s copyFrom: 7 to: s size - 1].
			s displayAt: 20@61 + startPt.
			oldColor _ c]].
	save displayAt: startPt.
	Sensor waitNoButton.
	^ c
! !

!Color class methodsFor: 'color from user' stamp: 'di 4/13/1999 14:28'!
oldColorPaletteForDepth: depth extent: paletteExtent
	"Returns a form of the given size showing a color palette for the given depth."
	"(Color oldColorPaletteForDepth: Display depth extent: 720@100) display"

	| c p f nSteps rect w h q |
	f _ Form extent: paletteExtent depth: depth.
	f fill: f boundingBox fillColor: Color white.
	nSteps _ depth > 8 ifTrue: [12] ifFalse: [6].
	w _ paletteExtent x // (nSteps * nSteps).
	h _ paletteExtent y - 20 // nSteps.
	0 to: nSteps-1 do: [:r |
		0 to: nSteps-1 do: [:g |
			0 to: nSteps-1 do: [:b |
				c _ Color r: r g: g b: b range: nSteps - 1.
				rect _ ((r * nSteps * w) + (b * w)) @ (g * h) extent: w@(h + 1).
				f fill: rect fillColor: c]]].
	q _ Quadrangle origin: paletteExtent - (50@19) corner: paletteExtent.
	q displayOn: f.
	'Trans.' displayOn: f at: q origin + (9@1).

	w _ ((paletteExtent x - q width - 130) // 64) max: 1.
	p _ paletteExtent x - q width - (64 * w) - 1 @ (paletteExtent y - 19).
	0 to: 63 do:
		[:v | c _ Color r: v g: v b: v range: 63.
		f fill: ((v * w)@0 + p extent: (w + 1)@19) fillColor: c].
	^ f
! !


Color initialize!
