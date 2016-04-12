BitBlt subclass: #Pen
	instanceVariableNames: 'location direction penDown '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Primitives'!
!Pen commentStamp: '<historical>' prior: 0!
My instances can scribble on the screen or some other Form, drawing and printing at any angle. Since I am a BitBlt, the drawing can be done with an arbitary source Form.
!


!Pen methodsFor: 'initialize-release' stamp: 'jm 4/28/1998 04:02'!
defaultNib: widthInteger 
	"Nib is the tip of a pen. This sets up the pen, with a nib of width widthInteger. You can also set the shape of the pen nib using:
		roundNib: widthInteger, or
		squareNib: widthInteger, or
		sourceForm: aForm"
"Example:
	| bic |
	bic _ Pen new sourceForm: Cursor normal.
	bic combinationRule: Form paint; turn: 90.
	10 timesRepeat: [bic down; go: 3; up; go: 10]."

	self color: Color black.
	self squareNib: widthInteger.
! !

!Pen methodsFor: 'initialize-release' stamp: 'EMP 4/6/2016 13:24'!
roundNib: diameter
	"Makes this pen draw with a round dot of the given diameter."

	self sourceForm: (Form dotOfSize: diameter).
	combinationRule _ 31 "Form paint"! !

!Pen methodsFor: 'initialize-release' stamp: 'EMP 4/6/2016 13:23'!
squareNib: widthInteger 
	"Makes this pen draw with a square nib of the given width."

	self sourceForm: (Form extent: widthInteger @widthInteger) fillBlack.
	self combinationRule: 31 "Form paint"  "a bit faster than paint mode"
! !


!Pen methodsFor: 'accessing'!
direction
	"Answer the receiver's current direction. 0 is towards the top of the
	screen."

	^direction! !

!Pen methodsFor: 'accessing'!
location
	"Answer where the receiver is currently located."

	^location! !


!Pen methodsFor: 'operations' stamp: 'jm 4/28/1998 03:40'!
color: aColorOrInteger
	"Set the pen to the given color or to a color chosen from a fixed set of colors."

	| count c |
	aColorOrInteger isInteger
		ifTrue: [
			destForm depth = 1 ifTrue: [^ self fillColor: Color black].
			count _ 19.  "number of colors in color wheel"
			c _ (Color red wheel: count) at: ((aColorOrInteger * 7) \\ count) + 1]
		ifFalse: [c _ aColorOrInteger].  "assume aColorOrInteger is a Color"
	self fillColor: c.
! !

!Pen methodsFor: 'operations'!
down
	"Set the state of the receiver's pen to down (drawing)."

	penDown _ true! !

!Pen methodsFor: 'operations' stamp: 'EMP 12/18/2015 22:11'!
fill: drawBlock color: color
	| region tileForm tilePen shape saveColor recorder |
	drawBlock value: (recorder _ self as: PenPointRecorder).
	region _ Rectangle encompassing: recorder points.
	tileForm _ Form extent: region extent+6.
	tilePen _ Pen newOnForm: tileForm.
	tilePen location: location-(region origin-3)
		direction: direction
		penDown: penDown.
	drawBlock value: tilePen.  "Draw the shape in B/W"
	saveColor _ halftoneForm.
	drawBlock value: self.
	halftoneForm _ saveColor.
	shape _ (tileForm findShapeAroundSeedBlock: [:f | f borderWidth: 1]) reverse.
	shape copy: shape boundingBox from: tileForm to: 0@0 rule: Form erase.
	destForm fillShape: shape fillColor: color at: region origin-3! !

!Pen methodsFor: 'operations'!
go: distance 
	"Move the pen in its current direction a number of bits equal to the 
	argument, distance. If the pen is down, a line will be drawn using the 
	receiver's form source as the shape of the drawing brush."

	self goto: (direction degreeCos @ direction degreeSin) * distance + location! !

!Pen methodsFor: 'operations' stamp: 'di 11/4/97 20:11'!
goto: aPoint 
	"Move the receiver to position aPoint. If the pen is down, a line will be 
	drawn from the current position to the new one using the receiver's 
	form source as the shape of the drawing brush. The receiver's set 
	direction does not change."
	| old |
	old _ location.
	location _ aPoint.
	penDown ifTrue: [self drawFrom: old rounded
								to: location rounded]

	"NOTE:  This should be changed so it does NOT draw the first point, so as
	not to overstrike at line junctions.  At the same time, place should draw
	a single dot if the pen is down, as should down (put-pen-down) if it
	was not down before."! !

!Pen methodsFor: 'operations'!
home
	"Place the receiver at the center of its frame."
	location _ destForm boundingBox center! !

!Pen methodsFor: 'operations'!
north
	"Set the receiver's direction to facing toward the top of the display screen."

	direction _ 270! !

!Pen methodsFor: 'operations'!
place: aPoint 
	"Set the receiver at position aPoint. No lines are drawn."

	location _ aPoint! !

!Pen methodsFor: 'operations' stamp: 'jm 5/29/2003 18:03'!
print: str withFont: font
	"Print the given string in the given font at the current heading"

	| lineStart form charStart rowStart scale wasDown bb pix |
	scale _ sourceForm width.
	wasDown _ penDown.
	lineStart _ location.
	str do:
		[:char |
		char = Character cr ifTrue:
			[self place: lineStart; up; turn: 90; go: font height*scale; turn: -90; down]
		ifFalse:
			[form _ font characterFormAt: char.
			charStart _ location.
wasDown ifTrue: [
			self up; turn: -90; go: font descent*scale; turn: 90; down.
			0 to: form height-1 do:
				[:y |
				rowStart _ location.
				bb _ BitBlt bitPeekerFromForm: form.
				pix _ RunArray newFrom:
					((0 to: form width-1) collect: [:x | bb pixelAt: x@y]).
				pix runs with: pix values do:
					[:run :value |
					value = 0
						ifTrue: [self up; go: run*scale; down]
						ifFalse: [self go: run*scale]].
				self place: rowStart; up; turn: 90; go: scale; turn: -90; down].
].
			self place: charStart; up; go: form width*scale; down].
			].
	wasDown ifFalse: [self up]
"
Display restoreAfter:
[Pen new squareNib: 2; color: Color red; turn: 45;
	print: 'The owl and the pussycat went to sea
in a beautiful pea green boat.' withFont: TextStyle defaultFont]
"! !

!Pen methodsFor: 'operations'!
turn: degrees 
	"Change the direction that the receiver faces by an amount equal to the 
	argument, degrees."

	direction _ direction + degrees! !

!Pen methodsFor: 'operations'!
up
	"Set the state of the receiver's pen to up (no drawing)."

	penDown _ false! !


!Pen methodsFor: 'geometric designs' stamp: 'di 6/11/1998 22:01'!
dragon: n  "Display restoreAfter: [Display fillWhite. Pen new dragon: 10]."
	"Display restoreAfter: [Display fillWhite. 1 to: 4 do:
				[:i | Pen new color: i; turn: 90*i; dragon: 10]]"
	"Draw a dragon curve of order n in the center of the screen."
	n = 0
		ifTrue: [self go: 5]
		ifFalse: [n > 0
				ifTrue: [self dragon: n - 1; turn: 90; dragon: 1 - n]
				ifFalse: [self dragon: -1 - n; turn: -90; dragon: 1 + n]]
! !

!Pen methodsFor: 'geometric designs' stamp: 'di 6/14/1998 13:42'!
filberts: n side: s   "Display restoreAfter: [Pen new filberts: 4 side: 5]"
	"Two Hilbert curve fragments form a Hilbert tile. Draw four interlocking 
	tiles of order n and sides length s."
	| n2 |
	Display fillWhite.
	n2 _ 1 bitShift: n - 1.
	self up; go: 0 - n2 * s; down.
	1 to: 4 do: 
		[:i | 
		self fill: [:p |
				p hilbert: n side: s.
				p go: s.
				p hilbert: n side: s.
				p go: s.
				p up.
				p go: n2 - 1 * s.
				p turn: -90.
				p go: n2 * s.
				p turn: 180.
				p down]
			color: (Color perform: (#(yellow red green blue) at: i))]! !

!Pen methodsFor: 'geometric designs'!
hilbert: n side: s 
	"Draw an nth level Hilbert curve with side length s in the center of the 
	screen. Write directly into the display's bitmap only. A Hilbert curve is 
	a space-filling curve."

	| a m |
	n = 0 ifTrue: [^self turn: 180].
	n > 0
		ifTrue: 
			[a _ 90.
			m _ n - 1]
		ifFalse: 
			[a _ -90.
			m _ n + 1].
	self turn: a.
	self hilbert: 0 - m side: s.
	self turn: a; go: s.
	self hilbert: m side: s.
	self turn: 0 - a; go: s; turn: 0 - a.
	self hilbert: m side: s.
	self go: s; turn: a.
	self hilbert: 0 - m side: s.
	self turn: a
	" 
	(Pen new) hilbert: 3 side: 8. 
	(Pen new sourceForm: Cursor wait) combinationRule: Form under; 
	hilbert: 3 side: 25.
	"! !

!Pen methodsFor: 'geometric designs'!
hilberts: n   "Display restoreAfter: [Display fillWhite.  Pen new hilberts: 5]"
	"Draws n levels of nested Hilbert curves"
	| s |
	self up; turn: 90; go: 128; down.
	1 to: n do: 
		[:i | 
		s _ 256 bitShift: 0 - i.
		self defaultNib: n - i * 2 + 1.
		self color: i+1.
		self up; go: 0 - s / 2; turn: -90; go: s / 2; turn: 90; down.
		self hilbert: i side: s.
		self go: s.
		self hilbert: i side: s.
		self go: s]! !

!Pen methodsFor: 'geometric designs'!
mandala: npoints
	"Display restoreAfter: [Pen new mandala: 30]"
	"On a circle of diameter d, place npoints number of points. Draw all 	possible connecting lines between the circumferential points."
	| l points d |
	Display fillWhite.
	d _ Display height-50.
	l _ 3.14 * d / npoints.
	self home; up; turn: -90; go: d // 2; turn: 90; go: 0 - l / 2; down.
	points _ Array new: npoints.
	1 to: npoints do: 
		[:i | 
		points at: i put: location rounded.
		self go: l; turn: 360.0 / npoints].
	npoints // 2
		to: 1
		by: -1
		do: 
			[:i | 
			self color: i.
			1 to: npoints do: 
				[:j | 
				self place: (points at: j).
				self goto: (points at: j + i - 1 \\ npoints + 1)]]
! !

!Pen methodsFor: 'geometric designs' stamp: 'jm 5/6/1998 22:26'!
spiral: n angle: a 
	"Draw a double squiral (see Papert, MindStorms), where each design is made
	by moving the receiver a distance of n after turning the amount + or -a."

	1 to: n do: 
		[:i | 
		self color: i * 2.
		self go: i; turn: a]
"
	Display restoreAfter: [
		Display fillWhite. Pen new spiral: 200 angle: 89; home; spiral: 200 angle: -89].
"! !

!Pen methodsFor: 'geometric designs' stamp: 'jm 11/8/2005 12:42'!
web   "Display restoreAfter: [Pen new web]"
	"Draw pretty web-like patterns from the mouse movement on the screen.
	Press the mouse button to draw, option-click to exit.
	By Dan Ingalls and Mark Lentczner. "
	| history newPoint ancientPoint lastPoint filter color |
	"self erase."
	color _ 1.
	[ true ] whileTrue:
		[ history _ OrderedCollection new.
		Sensor waitButton.
		Sensor yellowButtonPressed ifTrue: [^ self].
		filter _ lastPoint _ Sensor cursorPoint.
		20 timesRepeat: [ history addLast: lastPoint ].
		self color: (color _ color + 1).
		[ Sensor redButtonPressed ] whileTrue: 
			[ newPoint _ Sensor cursorPoint.
			(newPoint = lastPoint) ifFalse:
				[ ancientPoint _ history removeFirst.
				filter _ filter * 4 + newPoint // 5.
				self place: filter.
				self goto: ancientPoint.
				lastPoint _ newPoint.
				history addLast: filter ] ] ]! !


!Pen methodsFor: 'private' stamp: 'di 6/11/1998 16:09'!
location: aPoint direction: aFloat penDown: aBoolean
	location _ aPoint.
	direction _ aFloat.
	penDown _ aBoolean! !

!Pen methodsFor: 'private'!
sourceForm: aForm
	(aForm depth = 1 and: [destForm depth > 1])
		ifTrue: ["Map 1-bit source to all ones for color mask"
				colorMap _ Bitmap with: 0 with: 16rFFFFFFFF]
		ifFalse: [colorMap _ nil].
	^ super sourceForm: aForm! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Pen class
	instanceVariableNames: ''!

!Pen class methodsFor: 'instance creation'!
new
	^ self newOnForm: Display! !

!Pen class methodsFor: 'instance creation'!
newOnForm: aForm
	| pen |
	pen _ super new.
	pen setDestForm: aForm.
	pen sourceOrigin: 0@0.
	pen home.
	pen defaultNib: 1.
	pen north.
	pen down.
	^ pen! !


!Pen class methodsFor: 'examples' stamp: 'EMP 12/18/2015 22:25'!
example
	"Draw a spiral with a pen that is 2 pixels wide."
	"Display restoreAfter: [Pen example]"

	| bic |
	bic _ self new.
	bic defaultNib: 2.
	bic color: (Color blue alpha: 0.5).
	bic combinationRule: Form over.
	1 to: 100 do: [:i | bic go: i*4. bic turn: 89].
! !

!Pen class methodsFor: 'examples' stamp: 'jm 11/8/2005 12:50'!
scribble
	"A very simple example of drawing using the mouse. Mouse down to draw a stroke, shift-click to exit." 
	"Pen scribble"

	| pen p |
	pen _ Pen newOnForm: Display.
	pen roundNib: 8.
	pen color: Color black.
	Display fillColor: Color white.
	Display restoreAfter: [
		[Sensor shiftPressed and: [Sensor anyButtonPressed]] whileFalse: [
			p _ Sensor cursorPoint.
		     Sensor anyButtonPressed
				ifTrue: [pen goto: p]
				ifFalse: [
					pen color: Color random.
					pen place: p]]].
! !
