FileStream subclass: #StandardFileStream
	instanceVariableNames: 'name fileID buffer1 '
	classVariableNames: 'Registry '
	poolDictionaries: ''
	category: 'System-Files'!
!StandardFileStream commentStamp: 'jm 3/5/2005 09:52' prior: 0!
Provides a simple, platform-independent, interface to a file system. The instance variable rwmode indicates whether the file was opened read/write; false means is was opened read-only.
!


!StandardFileStream methodsFor: 'open/close' stamp: 'jm 12/3/2003 11:25'!
close
	"Close this file."

	fileID ifNotNil: [
		self primClose: fileID.
		self class unregister: self.
		fileID _ nil].
! !

!StandardFileStream methodsFor: 'open/close' stamp: 'jm 2/6/2002 08:33'!
closed
	"Answer true if this file is closed."

	^ fileID isNil or: [(self primSizeNoError: fileID) isNil]
! !

!StandardFileStream methodsFor: 'open/close' stamp: 'jm 9/21/1998 16:20'!
ensureOpen
	"Make sure that this file really is open."

	self closed ifTrue: [^ self reopen].
	(self primSizeNoError: fileID) ifNotNil: [^ self].
	self reopen.
! !

!StandardFileStream methodsFor: 'open/close'!
isReadable: fileName
	"Answer true if the file with the given name is can be opened for reading."
	"Details: The given file is opened and immediately closed without modification."

	| tmpFileID |
	tmpFileID _ self primOpen: fileName writable: false.
	tmpFileID ifNil: [^ false].
	self primCloseNoError: tmpFileID.
	^ true
! !

!StandardFileStream methodsFor: 'open/close'!
isWritable: fileName
	"Answer true if the file with the given name is writable. Used to test if anyone is writing the given file. The given file is opened and immediately closed without modification. Note that this means that a zero-length file will be created if the file did not exist before."

	| tmpFileID |
	tmpFileID _ self primOpen: fileName writable: true.
	tmpFileID ifNil: [^ false].  "not writable"
	self primCloseNoError: tmpFileID.
	^ true
! !

!StandardFileStream methodsFor: 'open/close'!
open
	"For compatibility with a few existing things.  2/14/96 sw"

	^ self reopen! !

!StandardFileStream methodsFor: 'open/close' stamp: 'jm 12/3/2003 11:27'!
open: fileName forWrite: writeMode 
	"Open the file with the given name. If writeMode is true, allow writing, otherwise open the file in read-only mode."
	"Changed to do a GC and retry before failing ar 3/21/98 17:25"

	fileID _ self retryWithGC: [self primOpen: fileName writable: writeMode] until:[:id | id notNil].
	fileID ifNil: [^ nil].  "allows sender to detect failure"
	self class register: self.
	name _ fileName.
	rwmode _ writeMode.
	buffer1 _ String new: 1.
! !

!StandardFileStream methodsFor: 'open/close'!
openReadOnly
	"Open the receiver as a read-only file.  1/31/96 sw"

	^ self open: name forWrite: false! !

!StandardFileStream methodsFor: 'open/close' stamp: 'jm 9/21/1998 13:58'!
reopen
	"Close and reopen this file. The file position is reset to zero."
	"Details: Files that were open when a snapshot occurs are no longer valid when the snapshot is resumed. This operation re-opens the file if that has happened."

	fileID ifNotNil: [self primCloseNoError: fileID].
	self open: name forWrite: rwmode.
! !


!StandardFileStream methodsFor: 'properties-setting'!
asHtml
	"Convert me in to an HtmlFileStream. 4/11/96 tk"

	^ self as: HtmlFileStream 
! !

!StandardFileStream methodsFor: 'properties-setting'!
ascii
	"opposite of binary"
	buffer1 _ String new: 1! !

!StandardFileStream methodsFor: 'properties-setting'!
binary
	buffer1 _ ByteArray new: 1! !

!StandardFileStream methodsFor: 'properties-setting'!
insertLineFeeds
	"(FileStream oldFileNamed: 'BBfix2.st') insertLineFeeds"
	| s crLf f |
	crLf _ String with: Character cr with: (Character value: 10).
	s _ ReadStream on: (self next: self size).
	self close.
	f _ FileStream newFileNamed: self name.
	[s atEnd] whileFalse: 
		[f nextPutAll: (s upTo: Character cr); nextPutAll: crLf].
	f close! !

!StandardFileStream methodsFor: 'properties-setting'!
isBinary
	^ buffer1 class == ByteArray! !

!StandardFileStream methodsFor: 'properties-setting' stamp: 'tk 11/4/1998 19:17'!
isReadOnly

	^ rwmode not
! !

!StandardFileStream methodsFor: 'properties-setting' stamp: 'jm 9/21/1998 13:56'!
readOnly
	"Make this file read-only."

	rwmode _ false.
! !

!StandardFileStream methodsFor: 'properties-setting' stamp: 'jm 12/5/97 15:14'!
setFileTypeToObject
	"On the Macintosh, set the file type and creator of this file to be a Squeak object file. On other platforms, do nothing. Setting the file type allows Squeak object files to be sent as email attachments and launched by double-clicking. On other platforms, similar behavior is achieved by creating the file with the '.sqo' file name extension."

	FileDirectory default
		setMacFileNamed: self fullName
		type: 'SOBJ'
		creator: 'FAST'.
! !


!StandardFileStream methodsFor: 'access' stamp: 'jm 9/21/1998 14:16'!
directory
	"Return the directory containing this file."

	^ FileDirectory forFileName: self fullName
! !

!StandardFileStream methodsFor: 'access'!
file
	"Answer the object representing the receiver's file.  Need for compatibility with some calls -- check senders.  2/14/96 sw"

	^ self! !

!StandardFileStream methodsFor: 'access' stamp: 'jm 9/21/1998 14:19'!
fullName
	"Answer this file's full path name."

	^ name
! !

!StandardFileStream methodsFor: 'access'!
isDirectory
	"Answer whether the receiver represents a directory.  For the post-transition case, uncertain what to do.  2/14/96 sw"
	^ false! !

!StandardFileStream methodsFor: 'access' stamp: 'ar 11/24/1998 14:00'!
localName
	^ name ifNotNil: [(name findTokens: FileDirectory pathNameDelimiter asString) last]! !

!StandardFileStream methodsFor: 'access' stamp: 'jm 9/21/1998 14:19'!
name
	"Answer this file's full path name."

	^ name
! !

!StandardFileStream methodsFor: 'access' stamp: 'di 6/27/97 12:18'!
peekFor: item 
	"Answer false and do not advance if the next element is not equal to item, or if this stream is at the end.  If the next element is equal to item, then advance over it and return true"
	| next |
	"self atEnd ifTrue: [^ false]. -- SFStream will give nil"
	(next _ self next) == nil ifTrue: [^ false].
	item = next ifTrue: [^ true].
	self skip: -1.
	^ false! !

!StandardFileStream methodsFor: 'access'!
printOn: aStream
	"Put a printed version of the receiver onto aStream.  1/31/96 sw"

	aStream nextPutAll: self class name; nextPutAll: ': '; print: name! !

!StandardFileStream methodsFor: 'access'!
reset
	^ self reopen! !

!StandardFileStream methodsFor: 'access'!
size
	"Answer the size of the file in characters.  2/12/96 sw"

	^ self primSize: fileID! !


!StandardFileStream methodsFor: 'read, write, position' stamp: 'sw 2/12/96'!
atEnd
	"Answer whether the receiver is at its end.  "
	^ self primAtEnd: fileID! !

!StandardFileStream methodsFor: 'read, write, position' stamp: 'mir 2/25/2000 12:37'!
basicNext
	"Answer the next byte from this file, or nil if at the end of the file."

	| count |
	count _ self primRead: fileID into: buffer1 startingAt: 1 count: 1.
	count = 1
		ifTrue: [^ buffer1 at: 1]
		ifFalse: [^ nil].
! !

!StandardFileStream methodsFor: 'read, write, position' stamp: 'tk 3/15/2000 10:31'!
compressFile
	"Write a new file that has the data in me compressed in GZip format."
	| zipped buffer |

	self readOnly; binary.
	zipped _ self directory newFileNamed: (self name, FileDirectory dot, 'gz').
	zipped binary; setFileTypeToObject.
		"Type and Creator not to be text, so can be enclosed in an email"
	zipped _ GZipWriteStream on: zipped.
	buffer _ ByteArray new: 50000.
	'Compressing ', self fullName displayProgressAt: Sensor cursorPoint
		from: 0 to: self size
		during: [:bar |
			[self atEnd] whileFalse: [
				bar value: self position.
				zipped nextPutAll: (self nextInto: buffer)].
			zipped close.
			self close].
! !

!StandardFileStream methodsFor: 'read, write, position'!
flush
	"In some OS's seeking to 0 and back will do a flush"
	| p |
	p _ self position.
	self position: 0; position: p! !

!StandardFileStream methodsFor: 'read, write, position' stamp: 'mir 2/25/2000 12:37'!
next
	"Answer the next byte from this file, or nil if at the end of the file."

	^ self basicNext! !

!StandardFileStream methodsFor: 'read, write, position'!
next: n
	"Return a string with the next n characters of the filestream in it.  1/31/96 sw"
	^ self nextInto: (buffer1 class new: n)! !

!StandardFileStream methodsFor: 'read, write, position' stamp: 'ar 12/23/1999 15:02'!
next: n into: aString startingAt: startIndex
	"Read n bytes into the given string.
	Return aString or a partial copy if less than
	n elements have been read."
	| count |
	count _ self primRead: fileID into: aString
				startingAt: startIndex count: n.
	count = n
		ifTrue:[^aString]
		ifFalse:[^aString copyFrom: 1 to: startIndex+count-1]! !

!StandardFileStream methodsFor: 'read, write, position' stamp: 'ar 1/2/2000 15:33'!
next: anInteger putAll: aString startingAt: startIndex
	"Store the next anInteger elements from the given collection."
	rwmode ifFalse: [^ self error: 'Cannot write a read-only file'].
	self primWrite: fileID from: aString startingAt: startIndex count: anInteger.
	^aString! !

!StandardFileStream methodsFor: 'read, write, position' stamp: 'jm 9/21/1998 13:55'!
nextPut: char
	"Write the given character to this file."

	rwmode ifFalse: [^ self error: 'Cannot write a read-only file'].
	buffer1 at: 1 put: char.
	self primWrite: fileID from: buffer1 startingAt: 1 count: 1.
	^ char
! !

!StandardFileStream methodsFor: 'read, write, position' stamp: 'tk 2/5/2000 21:43'!
nextPutAll: aString
	"Write all the characters of the given string to this file."

	rwmode ifFalse: [^ self error: 'Cannot write a read-only file'].
	self primWrite: fileID from: aString startingAt: 1 count: aString basicSize.
	^ aString
! !

!StandardFileStream methodsFor: 'read, write, position' stamp: 'mir 2/25/2000 12:37'!
peek
	"Answer what would be returned if the message next were sent to the receiver. If the receiver is at the end, answer nil.  "
	| next |
	self atEnd ifTrue: [^ nil].
	next _ self basicNext.
	self position: self position - 1.
	^ next! !

!StandardFileStream methodsFor: 'read, write, position'!
position
	"Return the receiver's current file position.  2/12/96 sw"

	^ self primGetPosition: fileID! !

!StandardFileStream methodsFor: 'read, write, position'!
position: pos
	"Set the receiver's position as indicated.  2/12/96 sw"

	^ self primSetPosition: fileID to: pos! !

!StandardFileStream methodsFor: 'read, write, position'!
readInto: byteArray startingAt: startIndex count: count
	"Read into the given array as specified, and return the count
	actually transferred.  index and count are in units of bytes or
	longs depending on whether the array is Bitmap, String or ByteArray"
	^ self primRead: fileID into: byteArray
			startingAt: startIndex count: count
! !

!StandardFileStream methodsFor: 'read, write, position'!
readOnlyCopy
	^ StandardFileStream readOnlyFileNamed: self name! !

!StandardFileStream methodsFor: 'read, write, position'!
setToEnd
	"Set the position of the receiver to the end of file.  1/31/96 sw"

	self position: self size! !

!StandardFileStream methodsFor: 'read, write, position'!
skip: n
	"Set the character position to n characters from the current position.
	Error if not enough characters left in the file.  1/31/96 sw"

	self position: self position + n! !

!StandardFileStream methodsFor: 'read, write, position' stamp: 'di 7/14/97 23:15'!
upTo: delim 
	"Fast version to speed up nextChunk"
	| pos buffer count |
	pos _ self position.
	buffer _ self next: 2000.
	(count _ buffer indexOf: delim) > 0 ifTrue: 
		["Found the delimiter part way into buffer"
		self position: pos + count.
		^ buffer copyFrom: 1 to: count - 1].
	self atEnd ifTrue:
		["Never found it, and hit end of file"
		^ buffer].
	"Never found it, but there's more..."
	^ buffer , (self upTo: delim)! !

!StandardFileStream methodsFor: 'read, write, position' stamp: 'jm 10/27/2002 10:45'!
upToEnd
	"Answer a subcollection from the current access position through the last element of the receiver."

	| buffer |
	buffer _ buffer1 species new: (self size - self position).
	self nextInto: buffer.
	^ buffer
! !

!StandardFileStream methodsFor: 'read, write, position' stamp: 'jm 9/21/1998 13:56'!
verbatim: aString
	"A version of nextPutAll that can be called knowing it won't call nextPut: "

	^ self nextPutAll: aString
! !


!StandardFileStream methodsFor: 'primitives' stamp: 'bf 5/11/2012 17:21'!
primAtEnd: id
	"Answer true if the file position is at the end of the file."

	<primitive: 'primitiveFileAtEnd' module: 'FilePlugin'>
	self primitiveFailed
! !

!StandardFileStream methodsFor: 'primitives' stamp: 'bf 5/11/2012 17:21'!
primClose: id
	"Close this file."

	<primitive: 'primitiveFileClose' module: 'FilePlugin'>
	self primitiveFailed
! !

!StandardFileStream methodsFor: 'primitives' stamp: 'bf 5/11/2012 17:21'!
primCloseNoError: id
	"Close this file. Don't raise an error if the primitive fails."

	<primitive: 'primitiveFileClose' module: 'FilePlugin'>
! !

!StandardFileStream methodsFor: 'primitives' stamp: 'bf 5/11/2012 17:21'!
primGetPosition: id
	"Get this files current position."

	<primitive: 'primitiveFileGetPosition' module: 'FilePlugin'>
	self primitiveFailed
! !

!StandardFileStream methodsFor: 'primitives' stamp: 'bf 5/11/2012 17:21'!
primOpen: fileName writable: writableFlag
	"Open a file of the given name, and return the file ID obtained.
	If writableFlag is true, then
		if there is none with this name, then create one
		else prepare to overwrite the existing from the beginning
	otherwise
		if the file exists, open it read-only
		else return nil"

	<primitive: 'primitiveFileOpen' module: 'FilePlugin'>
	^ nil
! !

!StandardFileStream methodsFor: 'primitives' stamp: 'bf 5/11/2012 17:22'!
primRead: id into: byteArray startingAt: startIndex count: count
	"Read up to count bytes of data from this file into the given string or byte array starting at the given index. Answer the number of bytes actually read."

	<primitive: 'primitiveFileRead' module: 'FilePlugin'>
	self closed ifTrue: [^ self error: 'File is closed'].
	self error: 'File read failed'.
! !

!StandardFileStream methodsFor: 'primitives' stamp: 'bf 5/11/2012 17:22'!
primSetPosition: id to: anInteger
	"Set this file to the given position."

	<primitive: 'primitiveFileSetPosition' module: 'FilePlugin'>
	self primitiveFailed
! !

!StandardFileStream methodsFor: 'primitives' stamp: 'bf 5/11/2012 17:22'!
primSize: id
	"Answer the size of this file."

	<primitive: 'primitiveFileSize' module: 'FilePlugin'>
	self primitiveFailed
! !

!StandardFileStream methodsFor: 'primitives' stamp: 'bf 5/11/2012 17:22'!
primSizeNoError: id
	"Answer the size of this file. Answer nil if the primitive fails; this indicates that the file handle has become stale."

	<primitive: 'primitiveFileSize' module: 'FilePlugin'>
	^ nil
! !

!StandardFileStream methodsFor: 'primitives' stamp: 'bf 5/11/2012 17:22'!
primWrite: id from: stringOrByteArray startingAt: startIndex count: count
	"Write count bytes onto this file from the given string or byte array starting at the given index. Answer the number of bytes written."

	<primitive: 'primitiveFileWrite' module: 'FilePlugin'>
	self closed ifTrue: [^ self error: 'File is closed'].
	self error: 'File write failed'.
! !


!StandardFileStream methodsFor: 'finalization' stamp: 'ar 3/21/98 18:16'!
actAsExecutor
	super actAsExecutor.
	name := nil.! !

!StandardFileStream methodsFor: 'finalization' stamp: 'ar 10/7/1998 15:44'!
finalize
	self primCloseNoError: fileID.! !


!StandardFileStream methodsFor: 'dnd requests' stamp: 'jm 5/3/2003 20:13'!
primDropRequestFileHandle: dropIndex
	"Answer a read-only file handle for the dropped file with the given index. The first dropped file is index 1. Answer nil if there is no dropped file with the given index or the primitive is not supported."

	<primitive: 'primitiveDropRequestFileHandle' module:' DropPlugin'>
	^ nil
! !

!StandardFileStream methodsFor: 'dnd requests' stamp: 'jm 5/3/2003 20:13'!
primDropRequestFileName: dropIndex
	"Answer the file name for the dropped file with the given index. The first dropped file is index 1. Answer nil if there is no dropped file with the given index or the primitive is not supported."

	<primitive: 'primitiveDropRequestFileName' module: 'DropPlugin'>
	^ nil
! !

!StandardFileStream methodsFor: 'dnd requests' stamp: 'jm 12/3/2003 11:27'!
requestDropStream: dropIndex
	"Initialize me to be a read-only stream for a file that the user has just dropped onto the Squeak window. The first dropped file is index 1. Answer nil if there is no dropped file with the given index."

	name _ self primDropRequestFileName: dropIndex.
	fileID _ self primDropRequestFileHandle: dropIndex.
	fileID ifNil: [
		name ifNil: [^ nil].
		"try to open by name (needed for Squeak 3.0):"
		self open: name forWrite: false.
		fileID ifNil: [^ nil].
		^ self].

	self class register: self.
	rwmode _ false.
	buffer1 _ String new: 1.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

StandardFileStream class
	instanceVariableNames: ''!

!StandardFileStream class methodsFor: 'file creation' stamp: 'TPR 8/13/1999 21:22'!
fileNamed: fileName
	"Open a file with the given name for reading and writing. If the name has no directory part, then the file will be created in the default directory. If the file already exists, its prior contents may be modified or replaced, but the file will not be truncated on close."

	^ self new open: (self fullName: fileName) forWrite: true
! !

!StandardFileStream class methodsFor: 'file creation' stamp: 'mpw 9/18/1999 00:05'!
isAFileNamed: fileName
	"Answer true if a file of the given name exists."

	| f |
	f _ self new open: fileName forWrite: false.
	f ifNil: [^ false].
	f close.
	^ true
! !

!StandardFileStream class methodsFor: 'file creation' stamp: 'sma 5/12/2000 10:36'!
newFileNamed: fileName
 	"Create a new file with the given name, and answer a stream opened for writing on that file. If the file already exists, ask the user what to do."

	| dir localName choice newName fullName |
	fullName _ self fullName: fileName.
	(self isAFileNamed: fullName)
		ifFalse: [^ self new open: fullName forWrite: true].

	"file already exists:"
	dir _ FileDirectory forFileName: fullName.
	localName _ FileDirectory localNameFor: fullName.
	choice _ (PopUpMenu
		labels:
'overwrite that file
choose another name
cancel')
		startUpWithCaption: localName, '
already exists.'.

	choice = 1 ifTrue: [
		dir deleteFileNamed: localName
			ifAbsent: [self error: 'Could not delete the old version of that file'].
		^ self new open: fullName forWrite: true].

	choice = 2 ifTrue: [
		newName _ FillInTheBlank request: 'Enter a new file name' initialAnswer: 'fullName'.
		newName isEmpty ifFalse: [
			fullName _ self fullName: newName.
			^ self newFileNamed: fullName]].

	self error: 'Please close this to abort file opening'! !

!StandardFileStream class methodsFor: 'file creation' stamp: 'jm 6/29/2009 17:25'!
newScratchFileNamed: fileName
	"Create a new file with the given name, and answer a stream opened for writing on that file. If the file already exists, ask the user what to do."

	| dir localName choice newName fullName result ext |
	fullName _ self fullName: fileName.
	(self isAFileNamed: fullName) ifFalse: [
		result _ self new open: fullName forWrite: true.
		result ifNil: [DialogBoxMorph inform: 'Could not write file' withDetails: 'Is the folder read-only?' localized].
		^ result].

	"file already exists:"
	dir _ FileDirectory forFileName: fullName.
	localName _ FileDirectory localNameFor: fullName.
	choice _ DialogBoxMorph
		askWithCancel: 'The file name already exists. Overwrite existing file?'.
	choice = #cancelled ifTrue: [^ nil].

	choice
		ifTrue: [
			dir deleteFileNamed: localName ifAbsent: [].
			result _ self new open: fullName forWrite: true.
			result ifNil: [DialogBoxMorph inform: 'Could not write file' withDetails: 'Is the folder read-only?' localized].
			^ result]
		ifFalse: [
			newName _ StringDialog askWithCancel: 'New file name?'.
			newName size = 0 ifTrue: [^ nil].
			fullName _ dir fullNameFor: newName.
			ext _ FileDirectory extensionFor: fileName.
			(ext size > 0 and: [(newName endsWith: ext) not]) ifTrue: [
				fullName _ fullName, '.', ext].

			^ self newScratchFileNamed: fullName].
! !

!StandardFileStream class methodsFor: 'file creation' stamp: 'TPR 8/13/1999 21:26'!
oldFileNamed: fileName
	"Open an existing file with the given name for reading and writing. If the name has no directory part, then the file will be created in the default directory. If the file already exists, its prior contents may be modified or replaced, but the file will not be truncated on close."

	| selection fullName newName |
	fullName _ self fullName: fileName.
	(self isAFileNamed: fullName) ifTrue:
		[^ self new open: fullName forWrite: true].

	"File does not exist..."
	selection _ (PopUpMenu labels:
'create a new file
choose another name
cancel')
			startUpWithCaption: (FileDirectory localNameFor: fullName) , '
does not exist.'.
	selection = 1 ifTrue:
		[^ self new open: fullName forWrite: true].
	selection = 2 ifTrue:
		[ newName _ FillInTheBlank request: 'Enter a new file name'
						initialAnswer:  fullName.
		^ self oldFileNamed:
			(self fullName: newName)].
	self halt! !

!StandardFileStream class methodsFor: 'file creation' stamp: 'EMP 12/2/2015 14:23'!
readOnlyFileNamed: fileName 
	"Open an existing file with the given name for reading."
	"Changed to open a more usefull popup menu.  It now also includes the most likely choices.  jaf"
	| selection dir files choices newName fullName |
	fullName _ self fullName: fileName.
	(self isAFileNamed: fullName)
		ifTrue: [^ self new open: fullName forWrite: false].
	"File does not exist..."
	dir _ FileDirectory forFileName: fullName.
	files _ dir fileNames.
	choices _ (FileDirectory localNameFor: fullName) correctAgainst: files.
	choices add: 'Choose another name'.
	choices add: 'Cancel'.
	selection _ (PopUpMenu labelArray: choices lines: (Array with: 5) )
		startUpWithCaption: (FileDirectory localNameFor: fullName), '
does not exist.'.
	selection < (choices size - 1) ifTrue: [
		newName _ (dir pathName , FileDirectory slash , (choices at: selection))].
	selection = (choices size - 1) ifTrue: [
		newName _ FillInTheBlank 
							request: 'Enter a new file name' 
							initialAnswer: fileName].
	newName ifNil: [^ nil].
	newName = '' ifFalse: [^ self readOnlyFileNamed: (self fullName: newName)].
	^ self error: 'Could not open a file'! !


!StandardFileStream class methodsFor: 'registry' stamp: 'ar 10/7/1998 14:41'!
register: anObject
	WeakArray isFinalizationSupported ifFalse:[^anObject].
	self registry add: anObject! !

!StandardFileStream class methodsFor: 'registry' stamp: 'ar 10/7/1998 14:41'!
registry
	WeakArray isFinalizationSupported ifFalse:[^nil].
	^Registry isNil
		ifTrue:[Registry := WeakRegistry new]
		ifFalse:[Registry].! !

!StandardFileStream class methodsFor: 'registry' stamp: 'ar 10/7/1998 15:23'!
unregister: anObject
	WeakArray isFinalizationSupported ifFalse:[^anObject].
	self registry remove: anObject ifAbsent:[]! !
