Magnitude subclass: #Date
	instanceVariableNames: 'julianDayNumber '
	classVariableNames: 'DaysInMonth FirstDayOfMonth MonthNames SecondsInDay WeekDayNames '
	poolDictionaries: ''
	category: 'Kernel-Magnitudes'!
!Date commentStamp: '<historical>' prior: 0!
Refactored to use Julian Day Numbers internally.

Julian Day Numbers are the number of days which have elapsed since 24 November -4713 Gregorian.

The algorithm was published in the Communications of the ACM, volume 11, Number 10, October 1968.

See also: 
http://www.magnet.ch/serendipity/hermetic/cal_stud/jdn.htm
http://www.cs.ubc.ca/spider/flinn/docs/scham/primitives/time.html

!


!Date methodsFor: 'accessing' stamp: 'BP 5/21/2000 19:17'!
day
	"Answer the day of the year represented by the receiver."

	^self dayOfYear! !

!Date methodsFor: 'accessing' stamp: 'BP 5/18/2000 18:28'!
julianDayNumber
	"Answer the number of days (or part of a day) elapsed since noon GMT on January 1st, 4713 B.C."

	^julianDayNumber

! !

!Date methodsFor: 'accessing' stamp: 'BP 5/18/2000 18:29'!
julianDayNumber: anInteger
	"Set the number of days (or part of a day) elapsed since noon GMT on January 1st, 4713 B.C."

	julianDayNumber _ anInteger.

! !

!Date methodsFor: 'accessing' stamp: 'BP 5/21/2000 16:39'!
leap
	"Answer whether the receiver's year is a leap year."

	^Date leapYear: self year! !

!Date methodsFor: 'accessing' stamp: 'jm 5/23/2003 21:19'!
monthIndex
	"Answer the index of the month in which the receiver falls."

	^ self asGregorian second
! !

!Date methodsFor: 'accessing' stamp: 'BP 5/18/2000 18:05'!
monthName
	"Answer the name of the month in which the receiver falls."

	^MonthNames at: self monthIndex! !

!Date methodsFor: 'accessing' stamp: 'EMP 11/18/2015 12:36'!
shortYear
	"Answer the year in which the receiver falls."

	^ (self asGregorian last asString copyFrom: 3 to: 4) asNumberNoError! !

!Date methodsFor: 'accessing' stamp: 'BP 5/18/2000 18:05'!
weekday
	"Answer the name of the day of the week on which the receiver falls."

	^WeekDayNames at: self weekdayIndex! !

!Date methodsFor: 'accessing' stamp: 'rca 6/15/2000 14:51'!
weekdayIndex
	"Monday=1, ... , Sunday=7"
	^ (self julianDayNumber rem: 7) + 1! !

!Date methodsFor: 'accessing' stamp: 'EMP 10/11/2015 19:11'!
weekdayIndexForScratchTwo
	"Sunday=1, ... , Saturday=7"
	^ ((self julianDayNumber + 1) rem: 7) + 1! !

!Date methodsFor: 'accessing' stamp: 'BP 5/18/2000 19:34'!
year
	"Answer the year in which the receiver falls."

	^self asGregorian last! !


!Date methodsFor: 'arithmetic' stamp: 'BP 5/18/2000 18:46'!
addDays: dayCount 
	"Answer a Date that is dayCount days after the receiver."

	^self class fromJulianDayNumber: self julianDayNumber + dayCount.! !

!Date methodsFor: 'arithmetic' stamp: 'RAH 5/23/2000 11:32'!
subtractDate: aDate 
	"Answer the number of days between the receiver and aDate."

	^self julianDayNumber - aDate asJulianDayNumber! !

!Date methodsFor: 'arithmetic' stamp: 'BP 5/18/2000 18:48'!
subtractDays: dayCount 
	"Answer a Date that is dayCount days before the receiver."

	^self addDays: dayCount negated.! !


!Date methodsFor: 'comparing' stamp: 'RAH 5/23/2000 11:04'!
< aDate 
	"Answer whether aDate precedes the date of the receiver." 

	^julianDayNumber < aDate asJulianDayNumber! !

!Date methodsFor: 'comparing' stamp: 'BP 5/18/2000 18:31'!
= aDate 
	"Answer whether aDate is the same day as the receiver."

	^julianDayNumber = aDate asJulianDayNumber.
! !

!Date methodsFor: 'comparing' stamp: 'BP 5/18/2000 19:09'!
hash
	"Hash is reimplemented because = is implemented."

	^julianDayNumber hash! !


!Date methodsFor: 'inquiries' stamp: 'BP 5/21/2000 19:18'!
dayOfMonth
	"Answer which day of the month is represented by the receiver."

	^self asGregorian first! !

!Date methodsFor: 'inquiries' stamp: 'BP 5/21/2000 19:18'!
dayOfYear

	^self firstDayOfMonth + self dayOfMonth - 1! !

!Date methodsFor: 'inquiries' stamp: 'BP 5/18/2000 18:05'!
daysInMonth
	"Answer the number of days in the month represented by the receiver."

	^(DaysInMonth at: self monthIndex)
		+ (self monthIndex = 2
				ifTrue: [self leap]
				ifFalse: [0])! !

!Date methodsFor: 'inquiries' stamp: 'BP 5/21/2000 16:40'!
daysInYear
	"Answer the number of days in the year represented by the receiver."

	^Date daysInYear: self year! !

!Date methodsFor: 'inquiries' stamp: 'BP 5/21/2000 17:28'!
daysLeftInYear
	"Answer the number of days in the year after the date of the receiver."

	^self daysInYear - self dayOfYear! !

!Date methodsFor: 'inquiries' stamp: 'BP 5/21/2000 17:31'!
firstDayOfMonth
	"Answer the index of the day of the year that is the first day of the receiver's month."

	^(FirstDayOfMonth at: self monthIndex)
		+ (self monthIndex > 2
				ifTrue: [self leap]
				ifFalse: [0])! !

!Date methodsFor: 'inquiries' stamp: 'BP 5/18/2000 19:10'!
previous: dayName 
	"Answer the previous date whose weekday name is dayName."

	^self subtractDays: 7 + self weekdayIndex - (self class dayOfWeek: dayName) \\ 7! !


!Date methodsFor: 'converting' stamp: 'BP 5/18/2000 18:21'!
asDate

	^self! !

!Date methodsFor: 'converting' stamp: 'BP 5/21/2000 17:32'!
asGregorian
	"Return an array of integers #(dd mm yyyy)"

	| l n i j dd mm yyyy |

	l _ self julianDayNumber + 68569.
	n _ (4 * l) // 146097.
	l _ l - ( (146097 * n + 3) // 4 ).
	i _ (4000 * (l + 1) ) // 1461001.
	l _ l - ( (1461 * i) // 4 ) + 31.
	j _ (80 *l) // 2447.
	dd _ l - ( (2447 * j) // 80 ).
	l _ j // 11.
	mm _ j + 2 - (12 * l).
	yyyy _ 100 * (n -49) + i + l.

	^Array with: dd with: mm with: yyyy.! !

!Date methodsFor: 'converting' stamp: 'BP 5/21/2000 19:19'!
asJulianDayNumber

	^self julianDayNumber
! !

!Date methodsFor: 'converting' stamp: 'BP 5/18/2000 18:05'!
asSeconds
	"Answer the seconds between a time on 1 January 1901 and the same 
	time in the receiver's day."

	^SecondsInDay * (self subtractDate: (Date newDay: 1 year: 1901))! !

!Date methodsFor: 'converting' stamp: 'BP 5/18/2000 18:05'!
month
	^ Month fromDate: self! !

!Date methodsFor: 'converting' stamp: 'BP 5/18/2000 18:05'!
week
	^ Week fromDate: self! !


!Date methodsFor: 'printing' stamp: 'BP 5/18/2000 18:05'!
mmddyyyy
	"Answer the receiver rendered in standard fmt mm/dd/yyyy.  Good for avoiding year 2000 bugs.  Note that the name here is slightly misleading -- the month and day numbers don't show leading zeros, so that for example feb 1 1996 is 2/1/96"

	"Date today mmddyyyy"

	^ self printFormat: #(2 1 3 $/ 1 1)! !

!Date methodsFor: 'printing' stamp: 'BP 5/18/2000 18:22'!
printFormat: formatArray 
	"Answer a String describing the receiver using the argument formatArray."

	| aStream |
	aStream _ WriteStream on: (String new: 16).
	self printOn: aStream format: formatArray.
	^aStream contents! !

!Date methodsFor: 'printing' stamp: 'BP 5/18/2000 18:05'!
printOn: aStream

	self printOn: aStream format: #(1 2 3 $  3 1 )! !

!Date methodsFor: 'printing' stamp: 'jm 5/23/2003 21:20'!
printOn: aStream format: formatArray 
	"Print a description of the receiver on aStream using the format denoted the argument, formatArray:
		#(item item item sep monthfmt yearfmt twoDigits)
		items:  1=day  2=month  3=year  will appear in the order given,
		separated by sep which is eaither an ascii code or character.
		monthFmt:  1=09  2=Sep  3=September
		yearFmt:  1=1996  2=96
		digits:  (missing or)1=9  2=09.
	See the examples in printOn: and mmddyy"

	| gregorian twoDigits element monthFormat  |
	gregorian _ self asGregorian.
	twoDigits _ formatArray size > 6 and: [ (formatArray at: 7) > 1 ].

	1 to: 3 do: 
	[ :i | 
		element _ formatArray at: i.
		element = 1 ifTrue:
		[ 
			twoDigits 
				ifTrue: [ aStream nextPutAll: (gregorian first asString padded: #left to: 2 with: $0) ]
				ifFalse: [ gregorian first printOn: aStream ]
		].
		element = 2 ifTrue: 
		[
			monthFormat _ formatArray at: 5.
			monthFormat = 1 ifTrue:
			[
				twoDigits 
					ifTrue: [ aStream nextPutAll: (gregorian second asString padded: #left to: 2 with: $0) ]
					ifFalse: [ gregorian second printOn: aStream ].
			].
			monthFormat = 2 ifTrue:
			[
				aStream nextPutAll: ((MonthNames at: gregorian second) copyFrom: 1 to: 3)
			].
			monthFormat = 3 ifTrue:
			[
				aStream nextPutAll: (MonthNames at: gregorian second)
			].
		].
		element = 3 ifTrue: 
		[
			(formatArray at: 6) = 1
				ifTrue: [ gregorian last printOn: aStream ]
				ifFalse: [ aStream nextPutAll: ((gregorian last \\ 100) asString padded: #left to: 2 with: $0) ].
		].
		i < 3 ifTrue: 
		[
			(formatArray at: 4) ~= 0 
				ifTrue: [ aStream nextPut: (formatArray at: 4) asCharacter ] 
		].
	].! !

!Date methodsFor: 'printing' stamp: 'BP 5/18/2000 18:05'!
storeOn: aStream

	aStream nextPutAll: '(', self class name, ' readFromString: ';
		print: self printString;
		nextPut: $)! !


!Date methodsFor: 'obsolete' stamp: 'BP 5/21/2000 17:24'!
day: dayInteger year: yearInteger

	self error: 'obsolete'
! !

!Date methodsFor: 'obsolete' stamp: 'BP 5/21/2000 17:30'!
firstDayOfMonthIndex: monthIndex 
	"Answer the day of the year (an Integer) that is the first day of my month"

	self error: 'obsolete'! !

!Date methodsFor: 'obsolete' stamp: 'BP 5/18/2000 18:23'!
mmddyy
	"Please use mmddyyyy instead, so dates in 2000 will be unambiguous"

	^ self printFormat: #(2 1 3 $/ 1 2)! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Date class
	instanceVariableNames: ''!

!Date class methodsFor: 'class initialization' stamp: 'BP 5/18/2000 18:59'!
initialize
	"Initialize class variables representing the names of the months and days and
	the number of seconds, days in each month, and first day of each month."

	MonthNames _
		#(January February March April May June July August September October November December ).
	SecondsInDay _ 24 * 60 * 60.
	DaysInMonth _ #(31 28 31 30 31 30 31 31 30 31 30 31 ).
	FirstDayOfMonth _ #(1 32 60 91 121 152 182 213 244 274 305 335 ).
	WeekDayNames _ #(Monday Tuesday Wednesday Thursday Friday Saturday Sunday ).

	"Date initialize."
! !


!Date class methodsFor: 'instance creation' stamp: 'BP 5/21/2000 17:36'!
fromDays: dayCount
	"Answer an instance of me which is dayCount days after January 1, 1901.  Works for negative days before 1901.  Works over a huge range, both BC and AD."

	^self fromJulianDayNumber: dayCount +  2415386 "Julian Day Number of 1 Jan 1901" 
! !

!Date class methodsFor: 'instance creation' stamp: 'BP 5/18/2000 18:38'!
fromJulianDayNumber: aJulianDayNumber

	^self new julianDayNumber: aJulianDayNumber.! !

!Date class methodsFor: 'instance creation' stamp: 'BP 5/21/2000 19:26'!
fromSeconds: seconds
	"Answer an instance of me which is 'seconds' seconds after January 1, 1901."

	^self fromDays: seconds // SecondsInDay! !

!Date class methodsFor: 'instance creation' stamp: 'BP 5/18/2000 18:57'!
fromString: aString
	"Answer an instance of created from a string with format DD.MM.YYYY."

	^self readFrom: (ReadStream on: aString).
! !

!Date class methodsFor: 'instance creation' stamp: 'BP 5/18/2000 19:02'!
newDay: day month: month year: year 
	"Arguments day, month and year are all integers, except month may be a string
	 Two digit dates are always from 1900. 1/1/01 will NOT mean 2001."

	| monthIndex daysInMonth p q r s |

	year < 100 ifTrue: [ ^self newDay: day month: month year: 1900 + year].

	monthIndex _ month isInteger ifTrue: [month] ifFalse: [self indexOfMonth: month].
	monthIndex = 2
		ifTrue: [ daysInMonth _ (DaysInMonth at: monthIndex) + (self leapYear: year) ]
		ifFalse: [ daysInMonth _ DaysInMonth at: monthIndex ].
	(day < 1 or: [day > daysInMonth]) ifTrue: [ self error: 'illegal day in month' ].

	p _ (monthIndex - 14) quo: 12.
	q _ year + 4800 + p.
	r _ monthIndex - 2 - (12 * p).
	s _ (year + 4900 + p) quo: 100.
 
	^self fromJulianDayNumber: 
		( (1461 * q) quo: 4 ) + 
			( (367 * r) quo: 12 ) - 
				( (3 * s) quo: 4 ) + 
					( day - 32075 ).
	

! !

!Date class methodsFor: 'instance creation' stamp: 'BP 5/22/2000 16:46'!
newDay: dayCount year: referenceYear 
	"Answer an instance of me which is dayCount days after the beginning of the year referenceYear."

	| day year daysInYear date |
	day _ dayCount.
	year _ referenceYear.
	[ day > (daysInYear _ self daysInYear: year) ] whileTrue: 
	[
		year _ year + 1.
		day _ day - daysInYear
	].

	[ day <= 0 ] whileTrue: 
	[
		year _ year - 1.
		day _ day + (self daysInYear: year)
	].
	
	date _ self newDay: 1 month: 1 year: year.
	^date addDays: (day - 1).
! !

!Date class methodsFor: 'instance creation' stamp: 'BP 5/21/2000 16:48'!
readFrom: aStream
	"Read a Date from the stream in any of the forms:
		<day> <monthName> <year>		(5 April 1982; 5-APR-82)
		<monthName> <day> <year>		(April 5, 1982)
		<monthNumber> <day> <year>	(4/5/82)"

	| day month |
	aStream peek isDigit ifTrue: [day _ Integer readFrom: aStream].
	[aStream peek isAlphaNumeric] whileFalse: [aStream skip: 1].
	aStream peek isLetter
		ifTrue:		"number/name... or name..."
			[month _ WriteStream on: (String new: 10).
			[aStream peek isLetter] whileTrue: [month nextPut: aStream next].
			month _ month contents.
			day isNil ifTrue:		"name/number..."
				[[aStream peek isAlphaNumeric] whileFalse: [aStream skip: 1].
				day _ Integer readFrom: aStream]]
		ifFalse:		"number/number..."
			[month _ Date nameOfMonth: day.
			day _ Integer readFrom: aStream].
	[aStream peek isAlphaNumeric] whileFalse: [aStream skip: 1].
	^self newDay: day month: month year: (Integer readFrom: aStream)

	"Date readFrom: (ReadStream on: '5APR82')"
! !

!Date class methodsFor: 'instance creation' stamp: 'BP 5/21/2000 19:26'!
today
	"Answer an instance of me representing the day and year right now."

	^self dateAndTimeNow first! !


!Date class methodsFor: 'general inquiries' stamp: 'BP 5/18/2000 18:05'!
dateAndTimeNow
	"Answer an Array whose first element is Date today and second element 
	is Time now."

	^Time dateAndTimeNow! !

!Date class methodsFor: 'general inquiries' stamp: 'BP 5/18/2000 18:59'!
dayOfWeek: dayName 
	"Answer the index in a week, 1-7, of the day named dayName. Create an 
	error notification if no such day exists."

	1 to: 7 do: [ :index | (WeekDayNames at: index) = dayName ifTrue: [^index] ].

	self error: dayName asString , ' is not a day of the week'! !

!Date class methodsFor: 'general inquiries' stamp: 'BP 5/18/2000 19:00'!
daysInMonth: monthName forYear: yearInteger 
	"Answer the number of days in the month named monthName in the year yearInteger."

	^(self newDay: 1 month: monthName year: yearInteger) daysInMonth! !

!Date class methodsFor: 'general inquiries' stamp: 'BP 5/18/2000 18:05'!
daysInYear: yearInteger 
	"Answer the number of days in the year, yearInteger."

	^365 + (self leapYear: yearInteger)! !

!Date class methodsFor: 'general inquiries' stamp: 'BP 5/18/2000 18:05'!
firstWeekdayOfMonth: mn year: yr
	"Answer the weekday index (Sunday=1, etc) of the first day in the month named mn in the year yr."

	^(self newDay: 1 month: mn year: yr) weekdayIndex + 7 \\ 7 + 1! !

!Date class methodsFor: 'general inquiries' stamp: 'BP 5/18/2000 18:05'!
indexOfMonth: monthName 
	"Answer the index, 1-12, of the month monthName. Create an error 
	notification if no such month exists."

	1 to: 12 do: 
		[ :index | 
			(monthName , '*' match: (MonthNames at: index))
						ifTrue: [^index]].
	self error: monthName , ' is not a recognized month name'! !

!Date class methodsFor: 'general inquiries' stamp: 'BP 5/18/2000 18:05'!
leapYear: yearInteger
 "Answer 1 if the year yearInteger is a leap year; answer 0 if it is not."

    | adjustedYear |
    adjustedYear := yearInteger > 0
        ifTrue: [yearInteger]
        ifFalse: [(yearInteger + 1) negated "There is no year 0!!!!"].
     (adjustedYear \\ 4 ~= 0 or: [adjustedYear \\ 100 = 0 and: [adjustedYear \\ 400 ~= 0]])
        ifTrue: [^0]
        ifFalse: [^1]! !

!Date class methodsFor: 'general inquiries' stamp: 'BP 5/18/2000 19:01'!
nameOfDay: dayIndex 
	"Answer a symbol representing the name of the day indexed by dayIndex, 1-7."

	^WeekDayNames at: dayIndex! !

!Date class methodsFor: 'general inquiries' stamp: 'BP 5/18/2000 19:01'!
nameOfMonth: monthIndex 
	"Answer a String representing the name of the month indexed by monthIndex, 1-12."

	^MonthNames at: monthIndex! !


!Date class methodsFor: 'obsolete' stamp: 'BP 5/18/2000 18:05'!
absoluteDaysToYear: gregorianYear
	"Computes the number of days from (or until) January 1 of the year 1 A.D. upto (or since) January 1 of a given year. [Alan Lovejoy]"

	| days yearDelta quadCenturies centuries quadYears years isInADEra |
	days := 0.
	isInADEra := gregorianYear > 0.

	gregorianYear = 0 ifTrue: [gregorianYear = -1]. "There is no year 0"
	isInADEra
		ifTrue: [yearDelta := gregorianYear - 1]
		ifFalse: [yearDelta := (gregorianYear + 1) negated].
	quadCenturies := yearDelta // 400.
	yearDelta := yearDelta rem: 400.
	centuries := yearDelta // 100.
	yearDelta := yearDelta rem: 100.
	quadYears := yearDelta // 4.
	years := yearDelta rem: 4.
	days := (quadCenturies * 146097 "days per quad century") +
		(centuries * 36524 "days per century")  +
		(quadYears * 1461 "days per quad year") +
		(years * 365).
	isInADEra ifFalse:
			[days := days + 366.  "1 B.C. is a leap year"
			days := days negated].
	^ days! !

!Date class methodsFor: 'obsolete' stamp: 'BP 5/18/2000 18:05'!
yearAndDaysFromDays: days into: aTwoArgBlock
	"Compute the Gregorian year, and the day of the year, from the number of days since (or until) January 1 of the year 1 A.D. Return the values in a block.  [Alan Lovejoy]"

	| quadCentury year dayInYear isInADEra century quadYear |
	dayInYear := days.
	isInADEra := days >= 0.

	isInADEra
		ifTrue: [year := 0]
		ifFalse: [dayInYear := dayInYear abs.
			dayInYear >= 366 "days per leap year" 
				ifTrue: [year := 1.
						dayInYear := dayInYear - 366]	"Subtract the year 1 B.C."
				ifFalse: [year := 0]].

	quadCentury := dayInYear // 146097 "days per quad century".
	dayInYear := dayInYear \\ 146097 "days per quad century".
	century := dayInYear // 36524 "days per century".
	dayInYear := dayInYear \\ 36524 "days per century".
	quadYear := dayInYear // 1461 "days per quad year".
	dayInYear := dayInYear \\ 1461 "days per quad year".
	dayInYear >= 365 "days per standard year" ifTrue: ["e.g., 1 AD or 2 BC"
		dayInYear := dayInYear - 365 "days per standard year".
		year := year + 1.
		dayInYear >= 365 "days per standard year" ifTrue: ["e.g., 2 AD or 3 BC"
			dayInYear := dayInYear - 365 "days per standard year".
			year := year + 1.
			dayInYear >= 365 "days per standard year" ifTrue: ["e.g., 3 AD or 4 BC"
				dayInYear := dayInYear - 365 "days per standard year".
				year := year + 1.
				dayInYear >= 366 "days per leap year" ifTrue: [
					"e.g., 4 AD or 5 BC (although this won't occur in the AD case)"
					dayInYear := dayInYear - 366 "days per leap year".
					year := year + 1]]]].

	year := year + (quadCentury * 400) + (century * 100) + (quadYear * 4) + 1.
	isInADEra ifFalse: [
		year := year negated.
		dayInYear > 0 ifTrue: [
			(Date leapYear: year) = 1
				ifTrue: [dayInYear := 366 "days per leap year" - dayInYear]
				ifFalse: [dayInYear := 365 "days per standard year" - dayInYear]]].
	^ aTwoArgBlock value: year value: dayInYear+1 "the way Dates do it"! !


Date initialize!
