StringHolder subclass: #FileList
	instanceVariableNames: 'fileName directory volList volListIndex list listIndex pattern sortMode brevityState '
	classVariableNames: 'RecentDirs '
	poolDictionaries: ''
	category: 'Tools-FileList'!
!FileList commentStamp: '<historical>' prior: 0!
I am model that can be used to navigate the host file system. By omitting the volume list, file list, and template panes from the view, I can also be used as the model for an editor on an individual file.

FileLists can now see FTP servers anywhere on the net.  In the volume list menu: 
fill in server info...		Gives you a form to register a new ftp server you want to use.
open server...		Choose a server to connect to.
local disk			Go back to looking at your local volume.

Still undone (you can contribute code):
[ ] Using a Proxy server to get out through a firewall.  What is the convention for proxy servers with FTP?
[ ] Fill in the date and size info in the list of remote files.  Allow sorting by it.  New smarts needed in (ServerDirectory fileNameFormattedFrom:sizePad:sortMode:).
[ ] Currently the FileList has no way to delete a directory.  Since you can't select a directory without going into it, it would have to be deleting the current directory.  Which would usually be empty.

!


!FileList methodsFor: 'initialization' stamp: 'di 5/16/2000 09:42'!
directory: dir
	"Set the path of the volume to be displayed."

	self okToChange ifFalse: [^ self].

	self modelSleep.
	directory _ dir.
	self modelWakeUp.

	sortMode == nil ifTrue: [sortMode _ #date].
	volList _ ((Array with: '[]'), directory pathParts)  "Nesting suggestion from RvL"
			withIndexCollect: [:each :i | ( String new: i-1 withAll: $ ), each].
	self changed: #relabel.
	self changed: #volumeList.
	self pattern: pattern! !

!FileList methodsFor: 'initialization' stamp: 'tk 5/18/1998 17:22'!
labelString
	^ directory pathName contractTo: 50! !

!FileList methodsFor: 'initialization' stamp: 'jm 7/17/2003 22:30'!
modelSleep
	"User has exited or collapsed the window--close any remote connections."
! !

!FileList methodsFor: 'initialization' stamp: 'sbw 12/30/1999 15:53'!
optionalButtonHeight

	^ 15! !

!FileList methodsFor: 'initialization' stamp: 'jm 10/13/2002 18:06'!
optionalButtonRow
	| aRow aButton |
	aRow _ AlignmentMorph newRow.
	aRow isSticky: true.
	aRow setProperty: #clipToOwnerWidth toValue: true.
	aRow addTransparentSpacerOfSize: (5@0).
	self optionalButtonSpecs do:
			[:spec |
				aButton _ PluggableButtonMorph
					on: self
					getState: nil
					action: spec second.
				aButton useRoundedCorners;
					label: spec first asString;
					askBeforeChanging: true;
					onColor: Color transparent offColor: Color transparent.
				aRow addMorphBack: aButton.
				aRow addTransparentSpacerOfSize: (3 @ 0).
				aButton setBalloonText: spec fourth.
				aRow addTransparentSpacerOfSize: (3 @ 0).

				(spec second == #sortBySize)
					ifTrue:
						[aRow addTransparentSpacerOfSize: (4@0)]].
	^ aRow! !

!FileList methodsFor: 'initialization' stamp: 'sw 1/7/2000 15:55'!
optionalButtonSpecs
	^ #(	
		('Name' 		sortByName				sortingByName	'sort entries by name')
		('Date'			sortByDate				sortingByDate	'sort entries by date')
		('Size'			sortBySize				sortingBySize	'sort entries by size')
		('Changes'		browseChanges			none			'open a changelist browser on selected file')
		('File-in'		fileInSelection			none			'fileIn the selected file')
		('File-in to New'	fileIntoNewChangeSet	none			'fileIn the selected file into a new change set')
		('Delete'			deleteFile				none			'delete the seleted item'))
! !

!FileList methodsFor: 'initialization' stamp: 'sw 1/7/2000 15:56'!
optionalButtonView

	| aView bHeight windowWidth offset previousView aButtonView wid specs |
	aView _ View new model: self.
	bHeight _ self optionalButtonHeight.
	windowWidth _ 120.
	aView window: (0@0 extent: windowWidth@bHeight).
	offset _ 0.
	specs _ self optionalButtonSpecs copyFrom: 1 to: 6.  "Too cramped for the seventh!!"
	previousView _ nil.
	specs do: [:quad |
		aButtonView _ PluggableButtonView on: self getState: (quad third == #none ifTrue: [nil] ifFalse: [quad third]) action: quad second.
		quad second = specs last second
			ifTrue:
				[wid _ windowWidth - offset]
			ifFalse:
				[aButtonView borderWidthLeft: 0 right: 1 top: 0 bottom: 0.
				wid _ (windowWidth // (specs size)) - 2].
		aButtonView
			label: quad first asParagraph;
			window: (offset@0 extent: wid@bHeight).
		offset _ offset + wid.
		quad second = specs first second
			ifTrue: [aView addSubView: aButtonView]
			ifFalse: [aView addSubView: aButtonView toRightOf: previousView].
		previousView _ aButtonView].
	^aView
! !

!FileList methodsFor: 'initialization' stamp: 'di 5/11/1999 22:25'!
release

	self modelSleep! !

!FileList methodsFor: 'initialization' stamp: 'tk 5/21/1998 12:28'!
setFileStream: aStream
	"Used to initialize a spawned file editor.  Sets directory too."

	self directory: aStream directory.
	fileName _ aStream localName.
	pattern _ '*'.
	listIndex _ 1.  "pretend a file is selected"
	aStream close.
	brevityState _ #needToGetBrief.
	self changed: #contents.
! !


!FileList methodsFor: 'volume list and pattern' stamp: 'jm 11/18/2003 09:16'!
deleteDirectory
	"Remove the currently selected directory."

	| localDir |
	directory entries size = 0 ifFalse:[^ self inform: 'Directory must be empty'].
	localDir _ directory pathParts last.
	(self confirm: 'Really delete ' , localDir printString, '?') ifFalse: [^ self].
	self volumeListIndex: self volumeListIndex - 1.
	directory deleteDirectory: localDir.
	self updateFileList.
! !

!FileList methodsFor: 'volume list and pattern' stamp: 'jm 11/18/2003 10:25'!
fileNameFormattedFrom: entry sizePad: sizePad
	"Answer a formated file description string for the given DirectoryEntry."

	| dateStr sizeStr nameStr |
	dateStr _
		((Date fromSeconds: entry modificationTime) printFormat: #(3 2 1 $. 1 1 2)), ' ',
		(String streamContents: [:s | (Time fromSeconds: entry modificationTime \\ 86400) print24: true on: s]).

	sizeStr _ entry fileSize asStringWithCommas.

	entry isDirectory
		ifTrue: [
			nameStr _ entry name, self folderString.
			sortMode = #date ifTrue: [^ '(', dateStr, ') ', nameStr].
			^ nameStr, ' (', dateStr, ')']
		ifFalse: [
			nameStr _ entry name.
			sortMode = #name ifTrue: [^ nameStr, '    (', dateStr, ' ', sizeStr, ')'].
			sortMode = #date ifTrue: [^ '(', dateStr, ' ', sizeStr, ') ', nameStr].
			sortMode = #size ifTrue: [^ '(', ((sizeStr size to: sizePad) collect: [:i | $ ]), sizeStr, ' ', dateStr, ') ', nameStr]].
! !

!FileList methodsFor: 'volume list and pattern' stamp: 'jm 11/18/2003 09:37'!
listForPattern: pat
	"Make the list be only those file names that match the pattern."

	| sortBlock entries sizePad |
	"create a sort block to decide what order to display the entries"
	sortBlock _ [:x :y |
		x isDirectory = y isDirectory
			ifTrue: [
				"sort by user-specified criterion"
				sortMode = #name
					ifTrue: [  "sort by name"
						(x name compare: y name) <= 2]
					ifFalse: [
						sortMode = #date
							ifTrue: [  "sort by time, then name"
								x modificationTime = y modificationTime
									ifTrue: [(x name compare: y name) <= 2]
									ifFalse: [x modificationTime > y modificationTime]]
							ifFalse: [  "sort by size, then name"
								x fileSize = y fileSize
									ifTrue: [(x name compare: y name) <= 2]
									ifFalse: [x fileSize > y fileSize]]]]
			ifFalse: [  "directories always follow files"
				x isDirectory not]].

	entries _ directory entries.
	pat = '*' ifFalse: [  "filter file names"
		entries _ entries select: [:e |e isDirectory or: [pat match: e name]]].
	entries sort: sortBlock.

	sizePad _ (entries inject: 0 into: [:mx :entry | mx max: entry fileSize])
					asStringWithCommas size - 1.
	^ entries collect: [:e | self fileNameFormattedFrom: e sizePad: sizePad]
! !

!FileList methodsFor: 'volume list and pattern' stamp: 'tk 4/7/98 15:26'!
pattern

	^ pattern ifNil: ['*']
! !

!FileList methodsFor: 'volume list and pattern' stamp: 'jm 5/3/1998 19:01'!
pattern: textOrStringOrNil

	textOrStringOrNil
		ifNil: [pattern _ '*']
		ifNotNil: [pattern _ textOrStringOrNil asString].
	self updateFileList.
	^ true
! !

!FileList methodsFor: 'volume list and pattern' stamp: 'jm 5/3/1998 18:20'!
volumeList
	"Answer the current list of volumes."

	^ volList
! !

!FileList methodsFor: 'volume list and pattern' stamp: 'jm 5/3/1998 18:21'!
volumeListIndex
	"Answer the index of the currently selected volume."

	^ volListIndex
! !

!FileList methodsFor: 'volume list and pattern' stamp: 'stp 12/11/1999 19:37'!
volumeListIndex: index
	"Select the volume name having the given index."

	| delim path |
	volListIndex := index.
	index = 1 
		ifTrue: [self directory: (FileDirectory on: '')]
		ifFalse: [delim := directory pathNameDelimiter.
				path := String streamContents: [:strm |
					2 to: index do: [:i |
						strm nextPutAll: (volList at: i) withBlanksTrimmed.
						i < index ifTrue: [strm nextPut: delim]]].
				self directory: (directory on: path)].
	brevityState := #FileList.
	self addPath: path.
	self changed: #fileList.
	self changed: #contents! !

!FileList methodsFor: 'volume list and pattern' stamp: 'jm 5/23/2003 13:22'!
volumeMenu: aMenu

	^ aMenu labels:
'recent...
delete directory...'
		lines: # (1)
		selections: #(recentDirs deleteDirectory)
! !


!FileList methodsFor: 'file list'!
fileList
	"Answer the list of files in the current volume."

	^ list! !

!FileList methodsFor: 'file list'!
fileListIndex
	"Answer the index of the currently selected file."

	^ listIndex! !

!FileList methodsFor: 'file list' stamp: 'jm 5/23/2003 13:19'!
fileListIndex: anInteger
	"Select the file name having the given index, and display its contents."

	| item name |
	self okToChange ifFalse: [^ self].
	listIndex := anInteger.
	listIndex = 0 
		ifTrue: [fileName := nil]
		ifFalse:
			[item := self fileNameFromFormattedItem: (list atPin: anInteger).
			(item endsWith: self folderString)
				ifTrue:
					["remove [...] folder string and open the folder"
					name := item copyFrom: 1 to: item size - self folderString size.
					listIndex := 0.
					brevityState := #FileList.
					self addPath: name.
					name first = $^
						ifTrue: [self error: 'remote directories not supported']
						ifFalse: [volListIndex = 1 ifTrue: [name _ name, directory slash].
							self directory: (directory directoryNamed: name)]]
				ifFalse: [fileName := item]].  "open the file selected"

	brevityState := #needToGetBrief.
	self changed: #fileListIndex.
	self changed: #contents! !


!FileList methodsFor: 'file list menu' stamp: 'jm 3/5/2005 08:48'!
addNew: aString byEvaluating: aBlock
	"A parameterization of earlier versions of #addNewDirectory and #addNewFile.  Fixes the bug in each that pushing the cancel button in the FillInTheBlank dialog gave a walkback."

	| newName index ending |
	self okToChange ifFalse: [^ self].
	newName _ FillInTheBlank
		request: 'New ',aString,' Name?'
 		initialAnswer: aString,'Name'.
	newName isEmpty ifTrue: [^ self].

	Cursor wait showWhile: [aBlock value: newName].
	self updateFileList.
	index _ list indexOf: newName.
	index = 0 ifTrue: [
		ending _ ') ', newName.
		index _ list findFirst: [:line | line endsWith: ending]].

	self fileListIndex: index.
! !

!FileList methodsFor: 'file list menu' stamp: 'sge 11/28/1999 09:04'!
addNewDirectory
	self 
		addNew: 'Directory'
		byEvaluating: [:newName | directory createDirectory: newName]
! !

!FileList methodsFor: 'file list menu' stamp: 'sge 11/28/1999 09:04'!
addNewFile
	self 
		addNew: 'File'
		byEvaluating: [:newName | (directory newFileNamed: newName) close]
! !

!FileList methodsFor: 'file list menu' stamp: 'jm 12/9/2004 10:55'!
browseChanges
	"Browse the selected file in fileIn format."

	fileName
		ifNotNil: [ChangeList browseStream: (directory readOnlyFileNamed: fileName)]
		ifNil: [self beep].
! !

!FileList methodsFor: 'file list menu' stamp: 'tk 3/15/2000 10:32'!
compressFile
	"Compress the currently selected file"

	(directory readOnlyFileNamed: self fullName) compressFile.
	self updateFileList! !

!FileList methodsFor: 'file list menu' stamp: 'jm 4/6/2007 11:17'!
convertToUnixWinLineEnds
	"Replace CR or CR LF line endings with with LF's."

	| bytes in out ch |
	bytes _ (FileStream readOnlyFileNamed: self fullName) binary contentsOfEntireFile.
	in _ ReadStream on: bytes.
	out _ WriteStream on: (ByteArray new: bytes size).
	[in atEnd] whileFalse: [
		ch _ in next.
		ch = 13 ifTrue: [
				in peek = 10 ifTrue: [in next].
				out nextPut: 10]
			ifFalse: [
				out nextPut: ch]].

	(FileStream newFileNamed: self fullName)
		binary;
		nextPutAll: out contents;
		close.
! !

!FileList methodsFor: 'file list menu' stamp: 'di 4/28/1999 11:33'!
copyName

	listIndex = 0 ifTrue: [^ self].
	ParagraphEditor clipboardTextPut: self fullName asText.
! !

!FileList methodsFor: 'file list menu' stamp: 'di 8/16/1998 12:22'!
deleteFile
	"Delete the currently selected file"
	listIndex = 0 ifTrue: [^ self].
	(self confirm: 'Really delete ' , fileName , '?') ifFalse: [^ self].
	directory deleteFileNamed: fileName.
	self updateFileList.
	brevityState _ #FileList.
	self get! !

!FileList methodsFor: 'file list menu'!
editFile
	"Open a simple Edit window"
	listIndex = 0 ifTrue: [^ self].
	(directory oldFileNamed: fileName) edit! !

!FileList methodsFor: 'file list menu' stamp: 'sma 5/20/2000 18:30'!
fileAllIn
	"File in all of the currently selected file, if any."
	"wod 5/24/1998: open the file read only."

	| fn ff |
	listIndex = 0 ifTrue: [^ self].
	ff _ directory readOnlyFileNamed: (fn _ self uncompressedFileName).
	((self getSuffix: fn) sameAs: 'html') ifTrue: [ff _ ff asHtml].
	ff fileIn! !

!FileList methodsFor: 'file list menu' stamp: 'jm 11/20/2004 13:44'!
fileContentsMenu: aMenu shifted: shifted

| shiftMenu |
^ shifted 
	ifFalse: [aMenu 
		labels: 
'get entire file
view as hex
browse changes
find...(f)
find again (g)
set search string (e)
do again (j)
undo (z)
copy (c)
cut (x)
paste (v)
paste...
do it (d)
print it (p)
inspect it (i)
fileIn selection
accept (s)
cancel (l)
more...' 
		lines: #(3 6 8 12 16 18)
		selections: #(get getHex browseChanges
find findAgain setSearchString
again undo
copySelection cut paste pasteRecent
doIt printIt inspectIt fileItIn
accept cancel
shiftedYellowButtonActivity)]

	ifTrue: [shiftMenu _ ParagraphEditor shiftedYellowButtonMenu.
		aMenu 
			labels: shiftMenu labelString 
			lines: shiftMenu lineArray
			selections: shiftMenu selections]

! !

!FileList methodsFor: 'file list menu' stamp: 'tk 4/13/1998 23:10'!
fileInSelection
	"FileIn all of the selected file."
	self canDiscardEdits ifFalse: [^ self changed: #flash].
	self fileAllIn.
! !

!FileList methodsFor: 'file list menu' stamp: 'jwh 5/24/2000 12:35'!
fileIntoNewChangeSet
	"File in all of the contents of the currently selected file,
	if any, into a new change set." 

	| fn ff |
	listIndex = 0 ifTrue: [^ self].
	ff _ directory readOnlyFileNamed: (fn _ self uncompressedFileName).
	((self getSuffix: fn) sameAs: 'html') ifTrue: [ff _ ff asHtml].
	ChangeSorter newChangesFromStream: ff named: (FileDirectory localNameFor: fn)! !

!FileList methodsFor: 'file list menu' stamp: 'tk 4/7/98 15:18'!
fileListMenu: aMenu

	fileName
		ifNil: [^ self noFileSelectedMenu: aMenu]
		ifNotNil: [^ self fileSelectedMenu: aMenu].
! !

!FileList methodsFor: 'file list menu' stamp: 'sma 5/20/2000 18:29'!
fileNameSuffix
	^ self getSuffix: self fullName! !

!FileList methodsFor: 'file list menu' stamp: 'di 8/20/1998 16:06'!
fileSelectedMenu: aMenu
	| firstItems secondItems thirdItems n1 n2 n3 |
	firstItems _ self itemsForFileEnding: self fileNameSuffix asLowercase.
	secondItems _ self itemsForAnyFile.
	thirdItems _ self itemsForNoFile.
	n1 _ firstItems first size.
	n2 _ n1 + secondItems first size.
	n3 _ n2 + thirdItems first size.
	^ aMenu
		labels: firstItems first , secondItems first , thirdItems first , #('more...')
		lines: firstItems second
				, (Array with: n1 with: n2)
				, (thirdItems second collect: [:n | n + n2])
				, (Array with: n3)
		selections: firstItems third , secondItems third , thirdItems third , #(offerAllFileOptions)! !

!FileList methodsFor: 'file list menu' stamp: 'jm 5/3/1998 18:03'!
get
	"Get contents of file again, it may have changed. Do this by making the cancel string be the contents, and doing a cancel."

	Cursor read showWhile: [
		self okToChange ifFalse: [^ nil].
		brevityState == #briefHex
			ifTrue: [brevityState _ #needToGetFullHex]
			ifFalse: [brevityState _ #needToGetFull].
		self changed: #contents].
! !

!FileList methodsFor: 'file list menu' stamp: 'jm 5/3/1998 18:04'!
getHex
	"Get contents of file again, and display in Hex. Do this by making the cancel string be the contents, and doing a cancel."

	Cursor read showWhile: [
		brevityState _ #needToGetBriefHex.
		self changed: #contents].
! !

!FileList methodsFor: 'file list menu' stamp: 'ar 1/2/2000 15:30'!
itemsForAnyFile
	^ #(('copy name to clipboard' 'rename' 'delete' 'compress')
		()
		(copyName renameFile deleteFile compressFile)
		)! !

!FileList methodsFor: 'file list menu' stamp: 'jm 4/6/2007 11:24'!
itemsForFileEnding: suffix

	| labels lines selectors |
	labels _ OrderedCollection new.
	lines _ OrderedCollection new.
	selectors _ OrderedCollection new.

	(#('bmp' 'gif' 'jpg' 'jpeg' 'form' 'png' '*') includes: suffix) ifTrue: [
		labels addAll: #('open image in a window').
		selectors addAll: #(openImageInWindow)].
	(#('mid' 'midi' '*') includes: suffix) ifTrue: [
		labels add: 'play midi file'.
		selectors add: #playMidiFile].
	lines add: labels size.

	(#('st' 'cs' '*') includes: suffix) ifTrue: [
		suffix = '*' ifTrue: [lines add: labels size].
		labels addAll: #('fileIn' 'file into new change set' 'browse changes' 'browse code' 'convert to Mac' 'convert to Win/Unix').
		lines add: labels size - 2.
		selectors addAll: #(fileInSelection fileIntoNewChangeSet browseChanges browseFile removeLinefeeds convertToUnixWinLineEnds)].

	(#('gz' '*') includes: suffix) ifTrue: [
		lines add: labels size.
		labels addAll: #('view decompressed' 'decompress to file').
		selectors addAll: #(viewGZipContents saveGZipContents)].

	(#('image' 'ima' '*') includes: suffix) ifTrue: [
		lines add: labels size.
		labels addAll: #('set Mac file type to Squeak image').
		selectors addAll: #(setMacImageType)].

	^ Array with: labels with: lines with: selectors
! !

!FileList methodsFor: 'file list menu' stamp: 'di 11/19/1998 14:25'!
itemsForNoFile
	^ #(
		('sort by name' 'sort by size' 'sort by date'
		'browse code files'
		'add new file' 'add new directory')
		(3 4)
		(sortByName sortBySize sortByDate
		browseFiles
		addNewFile addNewDirectory)
		)! !

!FileList methodsFor: 'file list menu' stamp: 'di 8/20/1998 09:34'!
noFileSelectedMenu: aMenu
	| items |
	items _ self itemsForNoFile.
	^ aMenu
		labels: items first
		lines: items second
		selections: items third
! !

!FileList methodsFor: 'file list menu' stamp: 'di 8/20/1998 16:05'!
offerAllFileOptions
	| items action |
	items _ self itemsForFileEnding: '*'.
	action _ (SelectionMenu labels: items first lines: items second selections: items third)
			startUp.
	action ifNotNil: [self perform: action]! !

!FileList methodsFor: 'file list menu' stamp: 'sma 4/30/2000 09:38'!
openImageInWindow
	"Handle five file formats: GIF, JPG, PNG, Form stoteOn: (run coded), and BMP.
	Fail if file format is not recognized."

	| image |
	image _ Form fromFileNamed: self fullName.

	Smalltalk isMorphic
		ifTrue: [World addMorph: (SketchMorph withForm: image)]
		ifFalse: [FormView open: image named: fileName]! !

!FileList methodsFor: 'file list menu' stamp: 'jm 1/21/2004 14:19'!
perform: selector orSendTo: otherTarget
	"Selector was just chosen from a menu by a user.  If can respond, then perform it on myself.  If not, send it to otherTarget, presumably the editPane from which the menu was invoked." 

	(#(get getHex browseChanges
sortByDate sortBySize sortByName
fileInSelection fileIntoNewChangeSet browseChanges copyName
openImageInWindow playMidiFile setMacImageType
renameFile deleteFile addNewFile) includes: selector)
		ifTrue: [^ self perform: selector]
		ifFalse: [^ super perform: selector orSendTo: otherTarget]! !

!FileList methodsFor: 'file list menu' stamp: 'jm 5/29/1998 17:09'!
playMidiFile
	"Play a MIDI file."
 
	| f score |
	Smalltalk at: #MIDIFileReader ifPresent: [:midiReader |
		Smalltalk at: #ScorePlayerMorph ifPresent: [:scorePlayer |
			f _ (directory oldFileNamed: self fullName) binary.
			score _ (midiReader new readMIDIFrom: f) asScore.
			f close.
			scorePlayer openOn: score title: fileName]].
! !

!FileList methodsFor: 'file list menu' stamp: 'ar 9/3/1999 13:05'!
removeLinefeeds
	"Remove any line feeds by converting to CRs instead"
	| fileContents |
	fileContents _ (CrLfFileStream readOnlyFileNamed: self fullName) contentsOfEntireFile.
	(StandardFileStream newFileNamed: self fullName) 
		nextPutAll: fileContents;
		close.! !

!FileList methodsFor: 'file list menu' stamp: 'jm 3/5/2005 08:50'!
renameFile
	"Rename the currently selected file"

	| newName |
	listIndex = 0 ifTrue: [^ self].
	self okToChange ifFalse: [^ self].

	newName _ FillInTheBlank
		request: 'NewFileName?'
 		initialAnswer: fileName.
	newName isEmpty ifTrue: [^ self].
	newName = fileName ifTrue: [^ self].

	directory rename: fileName toBe: newName.
	self updateFileList.
	listIndex _ list findFirst: [:item | (self fileNameFromFormattedItem: item) = newName].
	listIndex > 0 ifTrue: [fileName _ newName].
	self changed: #fileListIndex.
! !

!FileList methodsFor: 'file list menu' stamp: 'jm 6/20/2003 09:51'!
saveGZipContents
	"Save the contents of a gzipped file."

	| newName unzipped zipped buffer |
	newName _ FileDirectory baseNameFor: fileName.
	unzipped _ directory newFileNamed: newName.
	zipped _ GZipReadStream on: (directory readOnlyFileNamed: self fullName).
	buffer _ String new: 50000.
	'Extracting ' , self fullName
		displayProgressAt: Sensor cursorPoint
		from: 0
		to: zipped sourceStream size
		during: 
			[:bar | 
			[zipped atEnd]
				whileFalse: 
					[bar value: zipped sourceStream position.
					unzipped nextPutAll: (zipped nextInto: buffer)].
			zipped close.
			unzipped close].
	self updateFileList.
	^ newName! !

!FileList methodsFor: 'file list menu' stamp: 'jm 1/21/2004 14:23'!
setMacImageType

	directory setMacFileNamed: fileName type: 'STim' creator: 'FAST'.
! !

!FileList methodsFor: 'file list menu' stamp: 'di 4/15/98 12:36'!
sortByDate
	self resort: #date! !

!FileList methodsFor: 'file list menu' stamp: 'di 4/15/98 12:37'!
sortByName
	self resort: #name! !

!FileList methodsFor: 'file list menu' stamp: 'di 4/15/98 12:36'!
sortBySize
	self resort: #size! !

!FileList methodsFor: 'file list menu' stamp: 'tk 5/21/1998 12:39'!
spawn: code
	"Open a simple Edit window"
	listIndex = 0 ifTrue: [^ self].
	FileList openEditorOn: (directory readOnlyFileNamed: fileName)
				"read only just for initial look"
			editString: code! !

!FileList methodsFor: 'file list menu' stamp: 'mjg 9/1/1998 14:10'!
templateFile
	^'<head>
<title><?request name?></title>
</head>
<body>
<?request formatted?>
</body>
'
! !

!FileList methodsFor: 'file list menu' stamp: 'ar 1/2/2000 15:31'!
viewGZipContents
	"View the contents of a gzipped file"
	| f |
	f _ (directory readOnlyFileNamed: self fullName).
	contents _ f contentsOfEntireFile.
	Cursor wait showWhile:[contents _ (GZipReadStream on: contents) upToEnd].
	contents replaceAll: Character lf with: Character cr.
	(StringHolder new)
		contents: contents;
		openLabel:'Contents of ', fileName printString! !


!FileList methodsFor: 'private' stamp: 'stp 12/11/1999 20:05'!
addPath: aString
	"Add the given string to the list of recently visited directories."

	| full |
	aString ifNil: [^self].
	full := String streamContents: 
		[ :strm | 2 to: volList size do: 
			[ :i | strm nextPutAll: (volList at: i) withBlanksTrimmed.
			strm nextPut: FileDirectory pathNameDelimiter]].
	full := full, aString.
"Remove and super-directories of aString from the collection."
	RecentDirs removeAllSuchThat: [ :aDir | ((aDir, '*') match: full)].

"If a sub-directory is in the list, do nothing."
	(RecentDirs detect: [ :aDir | ((full, '*') match: aDir)] ifNone: [nil])
		ifNotNil: [^self].

	[RecentDirs size >= 10]
		whileTrue: [RecentDirs removeFirst].
	RecentDirs addLast: full! !

!FileList methodsFor: 'private' stamp: 'di 8/16/1998 09:26'!
contents
	"Answer the contents of the file, reading it first if needed."
	"Possible brevityState values:
		FileList,
		fullFile, briefFile, needToGetFull, needToGetBrief,
		fullHex, briefHex, needToGetFullHex, needToGetBriefHex"

	(listIndex = 0) | (brevityState == #FileList) ifTrue: [^ self defaultContents].  "no file selected"
	brevityState == #fullFile ifTrue: [^ contents].
	brevityState == #fullHex ifTrue: [^ contents].
	brevityState == #briefFile ifTrue: [^ contents].
	brevityState == #briefHex ifTrue: [^ contents].

	brevityState == #needToGetFullHex ifTrue: [^ self readContentsHex: false].
	brevityState == #needToGetBriefHex ifTrue: [^ self readContentsHex: true].

	brevityState == #needToGetFull ifTrue: [^ self readContentsBrief: false].
	brevityState == #needToGetBrief ifTrue: [^ self readContentsBrief: true].  "default"

	self halt: 'unknown state ' , brevityState printString! !

!FileList methodsFor: 'private' stamp: 'di 8/16/1998 09:25'!
defaultContents
	contents _ list == nil
		ifTrue: [String new]
		ifFalse: [String streamContents:
					[:s | s nextPutAll: 'NO FILE SELECTED'; cr.
					s nextPutAll: '  -- Folder Summary --'; cr.
					list do: [:item | s nextPutAll: item; cr]]].
	brevityState _ #FileList.
	^ contents! !

!FileList methodsFor: 'private' stamp: 'sma 4/30/2000 09:41'!
errorMustBeMorph
	self inform: 'Can only load a single morph
into an mvc project via this mechanism.'! !

!FileList methodsFor: 'private'!
fileNameFromFormattedItem: item
	"Extract fileName and folderString from a formatted fileList item string"
	| i |
	(i _ item indexOf: $( ifAbsent: [0]) = 0 ifTrue: [^ item withBlanksTrimmed].
	^ (item copyReplaceFrom: i to: (item findFirst: [:c | c = $)]) with: '') withBlanksTrimmed! !

!FileList methodsFor: 'private' stamp: 'jm 11/18/2003 10:16'!
folderString

	^ ' []'
! !

!FileList methodsFor: 'private' stamp: 'jm 5/3/1998 18:29'!
fullName
	"Answer the full name for the currently selected file."

	^ directory fullNameFor: fileName
! !

!FileList methodsFor: 'private' stamp: 'sma 5/20/2000 18:29'!
getSuffix: aString
	| i |
	i _ aString findLast: [:each | $. = each].
	^ i = 0
		ifTrue: ['']
		ifFalse: [aString copyFrom: i + 1 to: aString size]! !

!FileList methodsFor: 'private' stamp: 'di 8/16/1998 09:46'!
put: aText
	| ff type |
	brevityState == #fullFile ifTrue:
		[ff _ directory newFileNamed: self fullName.
		Cursor write showWhile: [ff nextPutAll: aText asString; close].
		fileName = ff localName 
			ifTrue: [contents _ aText asString]
			ifFalse: [self updateFileList].		"user renamed the file"
		^ true  "accepted"].

	listIndex = 0 ifTrue:
		[PopUpMenu notify: 'No fileName is selected'.
		^ false  "failed"].
	type _ 'These'.
	brevityState = #briefFile ifTrue: [type _ 'Abbreviated'].
	brevityState = #briefHex ifTrue: [type _ 'Abbreviated'].
	brevityState = #fullHex ifTrue: [type _ 'Hexadecimal'].
	brevityState = #FileList ifTrue: [type _ 'Directory'].
	PopUpMenu notify: type , ' contents cannot
meaningfully be saved at present.'.
	^ false  "failed"
! !

!FileList methodsFor: 'private' stamp: 'jm 5/23/2003 13:21'!
readContentsBrief: brevityFlag
	"Read the contents of the receiver's selected file, unless it is too long, in which case show just the first 5000 characters. Don't create a file if it doesn't already exist."

	| f fileSize first5000 |
	f _ directory oldFileOrNoneNamed: self fullName.
	f ifNil: [^ 'For some reason, this file cannot be read'].
	(brevityFlag not or: [(fileSize _ f size) <= 100000]) ifTrue:
		[contents _ f contentsOfEntireFile.
		brevityState _ #fullFile.   "don't change till actually read"
		^ contents].

	"if brevityFlag is true, don't display long files when first selected"
	first5000 _ f next: 5000.
	f close.
	contents _ 'File ''', fileName, ''' is ', fileSize printString, ' bytes long.
You may use the ''get'' command to read the entire file.

Here are the first 5000 characters...
------------------------------------------
', first5000 , '
------------------------------------------
... end of the first 5000 characters.'.
	brevityState _ #briefFile.   "don't change till actually read"
	^ contents.
! !

!FileList methodsFor: 'private' stamp: 'di 8/16/1998 09:20'!
readContentsHex: brevity
	"retrieve the contents from the external file unless it is too long.
	  Don't create a file here.  Check if exists."
	| f size data hexData s |

	f _ directory oldFileOrNoneNamed: self fullName. 
	f == nil ifTrue: [^ 'For some reason, this file cannot be read'].
	((size _ f size)) > 5000 & brevity
		ifTrue: [data _ f next: 10000. f close. brevityState _ #briefHex]
		ifFalse: [data _ f contentsOfEntireFile. brevityState _ #fullHex].

	s _ WriteStream on: (String new: data size*4).
	0 to: data size-1 by: 16 do:
		[:loc | s nextPutAll: loc hex; space;
			nextPut: $(; print: loc; nextPut: $); space; tab.
		loc+1 to: (loc+16 min: data size) do: [:i | s nextPutAll: (data at: i) hex; space].
		s cr].
	hexData _ s contents.

	^ contents _ ((size > 5000) & brevity
		ifTrue: ['File ''', fileName, ''' is ', size printString, ' bytes long.
You may use the ''get'' command to read the entire file.

Here are the first 5000 characters...
------------------------------------------
', hexData , '
------------------------------------------
... end of the first 5000 characters.']
		ifFalse: [hexData]).
! !

!FileList methodsFor: 'private' stamp: 'stp 12/11/1999 20:03'!
recentDirs
	"Put up a menu and let the user select from the list of recently visited directories."

	| dirName |
	RecentDirs isEmpty ifTrue: [^self].
	dirName := (SelectionMenu selections: RecentDirs) startUp.
	dirName == nil ifTrue: [^self].
	self directory: (FileDirectory on: dirName)! !

!FileList methodsFor: 'private' stamp: 'ls 9/11/1998 04:15'!
resort: newMode
	"Re-sort the list of files."
	| name |
	listIndex > 0
		ifTrue: [name _ self fileNameFromFormattedItem: (list at: listIndex)].
	sortMode _ newMode.
	self pattern: pattern.
	name ifNotNil: [
		fileName _ name.
		listIndex _ list findFirst: [:item | (self fileNameFromFormattedItem: item) = name. ].
		self changed: #fileListIndex].
	listIndex = 0 ifTrue: [self changed: #contents]
! !

!FileList methodsFor: 'private' stamp: 'sw 1/7/2000 15:58'!
sortingByDate
	^ sortMode == #date! !

!FileList methodsFor: 'private' stamp: 'sw 1/7/2000 15:57'!
sortingByName
	^ sortMode == #name! !

!FileList methodsFor: 'private' stamp: 'sw 1/7/2000 15:58'!
sortingBySize
	^ sortMode == #size! !

!FileList methodsFor: 'private' stamp: 'sma 5/20/2000 18:31'!
uncompressedFileName
	| f |
	f _ self fullName.
	((f endsWith: '.gz') and: [self confirm: f , '
appears to be a compressed file.
Do you want to uncompress it?'])
		ifFalse: [^ f].
	^ self saveGZipContents! !

!FileList methodsFor: 'private' stamp: 'wod 5/27/1998 17:47'!
updateFileList
	"Update my files list with file names in the current directory that match the pattern."
	"wod 5/27/1998: nil out the fileName."
	Cursor execute showWhile:
		[list _ (pattern includes: $*) | (pattern includes: $#)
			ifTrue: [self listForPattern: pattern]
			ifFalse: [
				pattern isEmpty
					ifTrue: [self listForPattern: '*']
					ifFalse: [self listForPattern: '*', pattern, '*']].
		listIndex _ 0.
		volListIndex _ volList size.
		fileName _ nil.
		contents _ ''.
		self changed: #volumeListIndex.
		self changed: #fileList].
! !


!FileList methodsFor: 'menu messages' stamp: 'wod 5/13/1998 04:10'!
browseFile

	FileContentsBrowser browseFile: self fullName.! !

!FileList methodsFor: 'menu messages' stamp: 'wod 5/13/1998 04:10'!
browseFiles
	| selectionPattern fileList |
	selectionPattern := FillInTheBlank request:'What files?' initialAnswer: self pattern.
	fileList _ (directory fileNamesMatching: selectionPattern) 
		collect: [:each | directory fullNameFor: each].
	FileContentsBrowser browseFiles: fileList.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

FileList class
	instanceVariableNames: ''!

!FileList class methodsFor: 'instance creation' stamp: 'sma 4/30/2000 09:30'!
open
	"Open a view of an instance of me on the default directory."
	"FileList open"
	| dir aFileList topView volListView templateView fileListView fileContentsView underPane pHeight |
	Smalltalk isMorphic ifTrue: [^ self openAsMorph].

	dir _ FileDirectory default.
	aFileList _ self new directory: dir.
	topView _ StandardSystemView new.
	topView
		model: aFileList;
		label: dir pathName;
		minimumSize: 200@200.
	topView borderWidth: 1.

	volListView _ PluggableListView on: aFileList
		list: #volumeList
		selected: #volumeListIndex
		changeSelected: #volumeListIndex:
		menu: #volumeMenu:.
	volListView autoDeselect: false.
	volListView window: (0@0 extent: 80@45).
	topView addSubView: volListView.

	templateView _ PluggableTextView on: aFileList
		text: #pattern
		accept: #pattern:.
	templateView askBeforeDiscardingEdits: false.
	templateView window: (0@0 extent: 80@15).
	topView addSubView: templateView below: volListView.

	Preferences optionalButtons
		ifTrue: [
			underPane _ aFileList optionalButtonView.
			underPane isNil
				ifTrue: [pHeight _ 60]
				ifFalse: [
					topView addSubView: underPane toRightOf: volListView.
					pHeight _ 60 - aFileList optionalButtonHeight]]
		ifFalse: [
			underPane _ nil.
			pHeight _ 60].

	fileListView _ PluggableListView on: aFileList
		list: #fileList
		selected: #fileListIndex
		changeSelected: #fileListIndex:
		menu: #fileListMenu:.
	fileListView window: (0@0 extent: 120@pHeight).
	underPane isNil
		ifTrue: [topView addSubView: fileListView toRightOf: volListView]
		ifFalse: [topView addSubView: fileListView below: underPane].
	fileListView controller terminateDuringSelect: true.  "Pane to left may change under scrollbar"

	fileContentsView _ PluggableTextView on: aFileList
		text: #contents accept: #put:
		readSelection: #contentsSelection menu: #fileContentsMenu:shifted:.
	fileContentsView window: (0@0 extent: 200@140).
	topView addSubView: fileContentsView below: templateView.

	topView controller open.
! !

!FileList class methodsFor: 'instance creation' stamp: 'sw 12/13/1999 10:26'!
openAsMorph
	"Open a morphic view of a FileList on the default directory."
	| dir aFileList window fileListTop |
	dir _ FileDirectory default.
	aFileList _ self new directory: dir.
	window _ (SystemWindow labelled: dir pathName) model: aFileList.

	window addMorph: ((PluggableListMorph on: aFileList list: #volumeList selected: #volumeListIndex
				changeSelected: #volumeListIndex: menu: #volumeMenu:) autoDeselect: false)
		frame: (0@0 corner: 0.3@0.2).
	window addMorph: (PluggableTextMorph on: aFileList text: #pattern accept: #pattern:)
		frame: (0@0.2 corner: 0.3@0.3).
	Preferences optionalButtons
		ifTrue:
			[window addMorph: aFileList optionalButtonRow frame: (0.3 @ 0 corner: 1 @ 0.08).
			fileListTop _ 0.08]
		ifFalse:
			[fileListTop _ 0].

	window addMorph: (PluggableListMorph on: aFileList list: #fileList selected: #fileListIndex
				changeSelected: #fileListIndex: menu: #fileListMenu:)
		frame: (0.3 @ fileListTop corner: 1@0.3).
	window addMorph: (PluggableTextMorph on: aFileList text: #contents accept: #put:
			readSelection: #contentsSelection menu: #fileContentsMenu:shifted:)
		frame: (0@0.3 corner: 1@1).
	^ window! !

!FileList class methodsFor: 'instance creation' stamp: 'sma 4/30/2000 09:31'!
openEditorOn: aFileStream editString: editString
	"Open an editor on the given FileStream."
	| fileModel topView fileContentsView |
	Smalltalk isMorphic ifTrue: [^ (self openMorphOn: aFileStream editString: editString) openInWorld].

	fileModel _ FileList new setFileStream: aFileStream.	"closes the stream"
	topView _ StandardSystemView new.
	topView
		model: fileModel;
		label: aFileStream fullName;
		minimumSize: 180@120.
	topView borderWidth: 1.

	fileContentsView _ PluggableTextView on: fileModel 
		text: #contents accept: #put:
		readSelection: #contentsSelection menu: #fileContentsMenu:shifted:.
	fileContentsView window: (0@0 extent: 180@120).
	topView addSubView: fileContentsView.
	editString ifNotNil: [fileContentsView editString: editString.
			fileContentsView hasUnacceptedEdits: true].

	topView controller open.
! !

!FileList class methodsFor: 'instance creation' stamp: 'di 10/18/1999 22:34'!
openMorphOn: aFileStream editString: editString 
	"Open a morphic view of a FileList on the given file."
	| fileModel window fileContentsView |

	fileModel _ FileList new setFileStream: aFileStream.	"closes the stream"
	window _ (SystemWindow labelled: aFileStream fullName) model: fileModel.

	window addMorph: (fileContentsView _ PluggableTextMorph on: fileModel 
			text: #contents accept: #put:
			readSelection: #contentsSelection 
			menu: #fileContentsMenu:shifted:)
		frame: (0@0 corner: 1@1).
	editString ifNotNil: [fileContentsView editString: editString.
			fileContentsView hasUnacceptedEdits: true].

	^ window! !


!FileList class methodsFor: 'class initialization' stamp: 'stp 12/11/1999 19:47'!
initialize
	"FileList initialize"

	RecentDirs := OrderedCollection new! !

!FileList class methodsFor: 'class initialization' stamp: 'EMP 11/20/2015 12:57'!
registerFileReader: aProviderClass
	"register the given class as providing services for reading files"

	^ nil! !


FileList initialize!
