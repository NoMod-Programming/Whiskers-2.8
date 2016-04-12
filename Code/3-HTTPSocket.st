SimpleClientSocket subclass: #HTTPSocket
	instanceVariableNames: 'headerTokens headers responseCode '
	classVariableNames: 'HTTPBlabEmail HTTPPort HTTPProxyPort HTTPProxyServer ParamDelimiters '
	poolDictionaries: ''
	category: 'Network-Protocols'!
!HTTPSocket commentStamp: '<historical>' prior: 0!
HTTPSockets support HTTP requests, either directly or via an HTTP proxy server. An HTTPSocket saves the parse of the last ASCII header it saw, to avoid having to parse it repeatedly.

The real action is in httpGet:accept:.  See the examples in the class, especially httpFileInNewChangeSet: and httpShowGif:.!
]style[(206 15 45 23 5 13)f1,f1LHTTPSocket class httpGet:accept:;,f1,f1LHTTPSocket class httpFileInNewChangeSet:;,f1,f1LHTTPSocket class httpShowGif:;!


!HTTPSocket methodsFor: 'as yet unclassified' stamp: 'ls 8/14/1998 10:17'!
contentType
	| type i |
	type _ self getHeader: 'content-type' default: nil.
	type ifNil: [ ^nil ].
	type _ type withBlanksTrimmed.
	i _ type indexOf: $;.
	i = 0 ifTrue: [ ^type ].
	^(type copyFrom: 1 to: i-1) withBlanksTrimmed	! !

!HTTPSocket methodsFor: 'as yet unclassified' stamp: 'ls 8/12/1998 00:23'!
contentType: header
	"extract the content type from the header.  Content-type: text/plain<cr><lf>,  User may look in headerTokens afterwards."

	| this |
	headerTokens ifNil: [ headerTokens _ header findTokens: ParamDelimiters keep: (String with: CR) ].
	1 to: headerTokens size do: [:ii | 
		this _ headerTokens at: ii.
		(this first asLowercase = $c and: [#('content-type:' 'content type') includes: this asLowercase]) ifTrue: [
			^ (headerTokens at: ii+1)]].
	^ nil	"not found"! !

!HTTPSocket methodsFor: 'as yet unclassified' stamp: 'jm 9/15/97 11:35'!
contentsLength: header
	"extract the data length from the header.  Content-length: 1234<cr><lf>,  User may look in headerTokens afterwards."

	| this |
	headerTokens _ header findTokens: ParamDelimiters keep: (String with: CR).
	1 to: headerTokens size do: [:ii | 
		this _ headerTokens at: ii.
		(this first asLowercase = $c and: [this asLowercase = 'content-length:']) ifTrue: [
			^ (headerTokens at: ii+1) asNumber]].
	^ nil	"not found"! !

!HTTPSocket methodsFor: 'as yet unclassified' stamp: 'ls 8/12/1998 00:37'!
getHeader: name 
	^self getHeader: name  default: nil! !

!HTTPSocket methodsFor: 'as yet unclassified' stamp: 'ls 8/12/1998 00:36'!
getHeader: name  default: defaultValue
	^headers at: name  ifAbsent: [ defaultValue ]! !

!HTTPSocket methodsFor: 'as yet unclassified' stamp: 'tk 9/22/1998 11:39'!
getResponseUpTo: markerString
	"Keep reading until the marker is seen.  Return three parts: header, marker, beginningOfData.  Fails if no marker in first 2000 chars." 

	| buf response bytesRead tester mm |
	buf _ String new: 2000.
	response _ WriteStream on: buf.
	tester _ 1. mm _ 1.
	[tester _ tester - markerString size + 1 max: 1.  "rewind a little, in case the marker crosses a read boundary"
	tester to: response position do: [:tt |
		(buf at: tt) = (markerString at: mm) ifTrue: [mm _ mm + 1] ifFalse: [mm _ 1].
			"Not totally correct for markers like xx0xx"
		mm > markerString size ifTrue: ["got it"
			^ Array with: (buf copyFrom: 1 to: tt+1-mm)
				with: markerString
				with: (buf copyFrom: tt+1 to: response position)]].
	 tester _ 1 max: response position.	"OK if mm in the middle"
	 (response position < buf size) & (self isConnected | self dataAvailable)] whileTrue: [
		(self waitForDataUntil: (Socket deadlineSecs: 5)) ifFalse: [
			Transcript show: 'data was late'; cr].
		bytesRead _ self primSocket: socketHandle receiveDataInto: buf 
			startingAt: response position + 1 count: buf size - response position.
		"response position+1 to: response position+bytesRead do: [:ii | 
			response nextPut: (buf at: ii)].	totally redundant, but needed to advance position!!"
		response instVarAt: 2 "position" put: 
			(response position + bytesRead)].	"horrible, but fast"

	^ Array with: response contents
		with: ''
		with: ''		"Marker not found and connection closed"
! !

!HTTPSocket methodsFor: 'as yet unclassified' stamp: 'tao 6/22/1999 07:56'!
getResponseUpTo: markerString ignoring: ignoreString
	"Keep reading, until the marker is seen, skipping characters in ignoreString when
      comparing to the marker.  Return three parts: header, marker, beginningOfData.
     Fails if no marker in first 2000 chars." 

	| buf response bytesRead tester mm skipped |
	buf _ String new: 2000.
	response _ WriteStream on: buf.
	tester _ 1. mm _ 1.
	skipped _ 0.
	[tester _ tester - markerString size + 1 max: 1.  "rewind a little, in case the marker crosses a read boundary"
	tester to: response position do: [:tt |
		(buf at: tt) = (markerString at: mm) ifFalse:
			[[ignoreString includes: (markerString at: mm)] whileTrue:
				[mm _ mm + 1. skipped _ skipped + 1]].
		(buf at: tt) = (markerString at: mm)
			ifTrue: [mm _ mm + 1]
			ifFalse: [mm _ 1. skipped _ 0].
			"Not totally correct for markers like xx0xx"
		mm > markerString size ifTrue: ["got it"
			^ Array with: (buf copyFrom: 1 to: tt+1-mm+skipped)
				with: markerString
				with: (buf copyFrom: tt+1 to: response position)]].
	 tester _ 1 max: response position.	"OK if mm in the middle"
	 (response position < buf size) & (self isConnected | self dataAvailable)] whileTrue: [
		(self waitForDataUntil: (Socket deadlineSecs: 5)) ifFalse: [
			Transcript show: 'data was late'; cr].
		bytesRead _ self primSocket: socketHandle receiveDataInto: buf 
			startingAt: response position + 1 count: buf size - response position.
		"response position+1 to: response position+bytesRead do: [:ii | 
			response nextPut: (buf at: ii)].	totally redundant, but needed to advance position!!"
		response instVarAt: 2 "position" put: 
			(response position + bytesRead)].	"horrible, but fast"

	^ Array with: response contents
		with: ''
		with: ''		"Marker not found and connection closed"
! !

!HTTPSocket methodsFor: 'as yet unclassified' stamp: 'tk 9/22/1998 12:24'!
getRestOfBuffer: beginning
	"We don't know the length.  Keep going until connection is closed.  Part of it has already been received.  Response is of type text, not binary."

	| buf response bytesRead |
	response _ RWBinaryOrTextStream on: (String new: 2000).
	response nextPutAll: beginning.
	buf _ String new: 2000.

	[self isConnected | self dataAvailable] 
	whileTrue: [
		(self waitForDataUntil: (Socket deadlineSecs: 5)) ifTrue: [
	 		Transcript show: 'data was slow'; cr].
		bytesRead _ self primSocket: socketHandle receiveDataInto: buf 
				startingAt: 1 count: buf size. 
		bytesRead > 0 ifTrue: [  
			response nextPutAll: (buf copyFrom: 1 to: bytesRead)] ].
	Transcript cr; show: 'data byte count: ', response position printString.
	response reset.	"position: 0."
	^ response
! !

!HTTPSocket methodsFor: 'as yet unclassified' stamp: 'sma 4/22/2000 17:34'!
getRestOfBuffer: beginning totalLength: length
	"Reel in a string of a fixed length.  Part of it has already been received.  Close the connection after all chars are received.  We do not strip out linefeed chars.  tk 6/16/97 22:32" 
	"if length is nil, read until connection close.  Response is of type text, not binary."

	| buf response bytesRead |
	length ifNil: [^ self getRestOfBuffer: beginning].
	buf _ String new: length.
	response _ RWBinaryOrTextStream on: buf.
	response nextPutAll: beginning.
	buf _ String new: length.

	[(response position < length) & (self isConnected | self dataAvailable)] 
	whileTrue: [
		(self waitForDataUntil: (Socket deadlineSecs: 5)) ifFalse: [
	 		Transcript show: 'data was slow'; cr].
		bytesRead _ self primSocket: socketHandle receiveDataInto: buf startingAt: 1 
				count: (length - response position). 
		bytesRead > 0 ifTrue: [  
			response nextPutAll: (buf copyFrom: 1 to: bytesRead)] ].
	"Transcript cr; show: 'data byte count: ', response position printString."
	"Transcript cr; show: ((self isConnected) ifTrue: ['Over length by: ', bytesRead printString] 
		ifFalse: ['Socket closed'])."
	response position < length ifTrue: [^ 'server aborted early'].
	response reset.	"position: 0."
	^ response! !

!HTTPSocket methodsFor: 'as yet unclassified' stamp: 'ls 8/13/1998 00:33'!
header: headerText
	"set the headers.  Then getHeader: can be used"

	"divide into basic lines"
	| lines foldedLines i statusLine |
	lines _ headerText findTokens: (String with: Character cr  with: Character linefeed).
	statusLine _ lines first.
	lines _ lines copyFrom: 2 to: lines size.

	"parse the status (pretty trivial right now)"
	responseCode _ (statusLine findTokens: ' ') second.

	"fold lines that start with spaces into the previous line"
	foldedLines _ OrderedCollection new.
	lines do: [ :line |
		line first isSeparator ifTrue: [
			foldedLines at: foldedLines size  put: (foldedLines last, line) ]
		ifFalse: [ foldedLines add: line ] ].

	"make a dictionary mapping headers to header contents"
	headers _ Dictionary new.
	foldedLines do: [ :line |
		i _ line indexOf: $:.
		i > 0 ifTrue: [
			headers 
			at: (line copyFrom: 1 to: i-1) asLowercase 
			put: (line copyFrom: i+1 to: line size) withBlanksTrimmed ] ]..
! !

!HTTPSocket methodsFor: 'as yet unclassified' stamp: 'jm 9/26/97 18:28'!
redirect
	"See if the header has a 'Location: url CrLf' in it.  If so, return the new URL of this page.  tk 6/24/97 18:03"

	| this |
	1 to: headerTokens size do: [:ii | 
		this _ headerTokens at: ii.
		(this first asLowercase = $l and: [this asLowercase = 'location:']) ifTrue: [
			^ (headerTokens at: ii+1)]].
	^ nil	"not found"
! !

!HTTPSocket methodsFor: 'as yet unclassified' stamp: 'ls 8/12/1998 00:41'!
responseCode
	^responseCode! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HTTPSocket class
	instanceVariableNames: ''!

!HTTPSocket class methodsFor: 'class initialization' stamp: 'tk 9/21/1998 10:45'!
blabEmail: aRequest
	"Of the form 'From: me@isp.com <crlf>'"
	HTTPBlabEmail _ aRequest! !

!HTTPSocket class methodsFor: 'class initialization' stamp: 'msk 
9/28/1998 15:51'!
initialize
	"HTTPSocket initialize"

	ParamDelimiters _ ' ', CrLf.
	HTTPPort _ 80.
	HTTPProxyServer _ nil.
	HTTPBlabEmail _ ''.  "	'From: tedk@disney.com', CrLf	"
! !


!HTTPSocket class methodsFor: 'get the page' stamp: 'di 5/6/1998 16:40'!
httpFileInNewChangeSet: url
	"Do a regular file-in of a file that is served from a web site.  Put it into a new changeSet."
	"Notes: To store a file on an HTTP server, use the program 'Fetch'.  After indicating what file to store, choose 'Raw Data' from the popup menu that has MacBinary/Text/etc.  Use any file extension as long as it is not one of the common ones."
	"	HTTPSocket httpFileInNewChangeSet: '206.18.68.12/squeak/updates/83tk_test.cs'	 "

	| doc |
	doc _ self httpGet: url accept: 'application/octet-stream'.
	doc class == String ifTrue: [
			PopUpMenu notify: 'Cannot seem to contact the web site'].
	doc reset.
	ChangeSorter newChangesFromStream: doc
				named: (url findTokens: '/') last.! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'jm 11/4/97 08:25'!
httpGet: url
	"Return the exact contents of a web page or other web object. The parsed header is saved.  Use a proxy server if one has been registered.  tk 7/23/97 17:21"
	"	HTTPSocket httpShowPage: 'http://www.altavista.digital.com/index.html'	 "
	"	HTTPSocket httpShowPage: 'www.webPage.com/~kaehler2/ab.html'	 "
	"	HTTPSocket httpShowPage: 'www.exploratorium.edu/index.html'	 "
	"	HTTPSocket httpShowPage: 'www.apple.com/default.html'	 "
	"	HTTPSocket httpShowPage: 'www.altavista.digital.com/'	 "
	"	HTTPSocket httpShowPage: 'jumbo/tedk/ab.html'	 "

	^ self httpGet: url accept: 'application/octet-stream'
! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'ls 9/15/1998 23:57'!
httpGet: url accept: mimeType
	"Return the exact contents of a web object. Asks for the given MIME type. If mimeType is nil, use 'text/html'. The parsed header is saved. Use a proxy server if one has been registered.  tk 7/23/97 17:12"
	"Note: To fetch raw data, you can use the MIMI type 'application/octet-stream'."

	^self httpGet: url  args: nil accept: mimeType! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'jm 9/16/1998 10:31'!
httpGet: url args: args accept: mimeType
	"Return the exact contents of a web object. Asks for the given MIME type. If mimeType is nil, use 'text/html'. The parsed header is saved. Use a proxy server if one has been registered.  tk 7/23/97 17:12"
	"Note: To fetch raw data, you can use the MIMI type 'application/octet-stream'."

	| document |
	document _ self httpGetDocument: url  args: args  accept: mimeType.
	(document isKindOf: String) ifTrue: [
		"strings indicate errors"
		^ document ].

	^ (RWBinaryOrTextStream with: document content) reset
! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'tk 9/22/1998 23:25'!
httpGetDocument: url
	"Return the exact contents of a web page or other web object. The parsed header is saved.  Use a proxy server if one has been registered.  tk 7/23/97 17:21"
	"	HTTPSocket httpShowPage: 'http://www.altavista.digital.com/index.html'	 "
	"	HTTPSocket httpShowPage: 'www.webPage.com/~kaehler2/ab.html'	 "
	"	HTTPSocket httpShowPage: 'www.exploratorium.edu/index.html'	 "
	"	HTTPSocket httpShowPage: 'www.apple.com/default.html'	 "
	"	HTTPSocket httpShowPage: 'www.altavista.digital.com/'	 "
	"	HTTPSocket httpShowPage: 'jumbo/tedk/ab.html'	 "

	^ self httpGetDocument: url args: nil accept: 'application/octet-stream' request: ''
! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'tk 9/22/1998 23:26'!
httpGetDocument: url accept: mimeType
	"Return the exact contents of a web object. Asks for the given MIME type. If mimeType is nil, use 'text/html'. The parsed header is saved. Use a proxy server if one has been registered.  tk 7/23/97 17:12"
	^self httpGetDocument: url args: nil accept: mimeType request: ''! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'tk 9/22/1998 23:26'!
httpGetDocument: url args: args
	"Return the exact contents of a web object. Asks for the given MIME type. If mimeType is nil, use 'text/html'. The parsed header is saved. Use a proxy server if one has been registered.  tk 7/23/97 17:12"
	"Note: To fetch raw data, you can use the MIMI type 'application/octet-stream'."
	^self httpGetDocument: url args: args accept: 'application/octet-stream' request: ''! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'tk 9/22/1998 17:48'!
httpGetDocument: url args: args accept: mimeType
	"Return the exact contents of a web object. Asks for the given MIME type. If mimeType is nil, use 'text/html'. The parsed header is saved. Use a proxy server if one has been registered.  Note: To fetch raw data, you can use the MIME type 'application/octet-stream'."

	^ self httpGetDocument: url args: args accept: mimeType request: ''! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'jm 2/29/2008 20:52'!
httpGetDocument: url args: args accept: mimeType request: requestString
	"Return the exact contents of a web object. Asks for the given MIME 
type. If mimeType is nil, use 'text/html'. An extra requestString may be 
submitted and must end with crlf.  The parsed header is saved. Use a 
proxy server if one has been registered.  tk 7/23/97 17:12"
	"Note: To fetch raw data, you can use the MIME type 
'application/octet-stream'."

	| serverName serverAddr port sock header length bare page list firstData 
aStream index connectToHost connectToPort type newUrl |
	Socket initializeNetwork.
	bare _ (url asLowercase beginsWith: 'http://') 
		ifTrue: [url copyFrom: 8 to: url size]
		ifFalse: [url].
	bare _ bare copyUpTo: $#.  "remove fragment, if specified"
	serverName _ bare copyUpTo: $/.
	page _ bare copyFrom: serverName size + 1 to: bare size.
	(serverName includes: $:) 
		ifTrue: [ index _ serverName indexOf: $:.
			port _ (serverName copyFrom: index+1 to: serverName size) asNumber.
			serverName _ serverName copyFrom: 1 to: index-1. ]
		ifFalse: [ port _ self defaultPort ].
	page size = 0 ifTrue: [page _ '/'].
	"add arguments"
	args ifNotNil: [page _ page, (self argString: args) ].


	HTTPProxyServer isNil
		ifTrue: [ 
			connectToHost _ serverName.
			connectToPort _ port ]
		ifFalse:  [
			page _ 'http://', serverName, ':', port printString, page.		"put back 
together"
			connectToHost _ HTTPProxyServer.
			connectToPort _ HTTPProxyPort].
	
	self flag: #XXX.  "this doesn't make sense if a user isn't available for 
questioning...  -ls"
	self retry: [serverAddr _ NetNameResolver addressForName: connectToHost 
timeout: 20.
				serverAddr ~~ nil] 
		asking: 'Trouble resolving server name.  Keep trying?'
		ifGiveUp: [^ 'Could not resolve the server named: ', connectToHost].

3 timesRepeat: [
	sock _ HTTPSocket new.
	sock connectTo: serverAddr port: connectToPort.
	(sock waitForConnectionUntil: (self deadlineSecs: 30)) ifFalse: [
		sock destroy.
		^ 'Server ',connectToHost,' is not responding'].
	Transcript cr; cr; show: url; cr.
	sock sendCommand: 'GET ', page, ' HTTP/1.0', CrLf, 
		(mimeType ifNotNil: ['ACCEPT: ', mimeType, CrLf] ifNil: ['']),
		'ACCEPT: text/html', CrLf,	"Always accept plain text"
		HTTPBlabEmail,	"may be empty"
		requestString,	"extra user request. Authorization"
		'User-Agent: Squeak 1.31', CrLf,
		'Host: ', serverName, ':', port printString, CrLf.	"blank line 
automatically added"

	list _ sock getResponseUpTo: CrLf, CrLf ignoring: (String with: CR).	"list = header, CrLf, CrLf, 
beginningOfData"
	header _ list at: 1.
	"Transcript show: page; cr; show: header; cr."
	firstData _ list at: 3.
	header isEmpty 
		ifTrue: [aStream _ 'server aborted early']
		ifFalse: [
			"dig out some headers"
			sock header: header.
			length _ sock getHeader: 'content-length'.
			length ifNotNil: [ length _ length asNumber ].
			type _ sock getHeader: 'content-type'.
			sock responseCode first = $3 ifTrue: [
				newUrl _ sock getHeader: 'location'.
				newUrl ifNotNil: [ 
					Transcript show: 'redirecting to ', newUrl; cr.
					sock destroy.
					^self httpGetDocument: newUrl  args: args  accept: mimeType ] ].
			aStream _ sock getRestOfBuffer: firstData totalLength: length.
			sock responseCode = '401' ifTrue: [^ header, aStream contents].
			].
	sock destroy.	"Always OK to destroy!!"
	aStream class ~~ String ifTrue: [
 		^ MIMEDocument contentType: type content: aStream contents url: url].
	aStream = 'server aborted early' ifFalse: [
		]
	].! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'EMP 11/18/2015 17:24'!
httpGetNoError: url
	"Return the exact contents of a web file.  Do better error checking.  Asks for the given MIME type.  To fetch raw data, you can use the MIMI type 'application/octet-stream'.  If mimeType is nil, use 'text/html'.  The parsed header is saved. Use a proxy server if one has been registered."

"Edited to remove a lineFeed from the source 4/4/99 - di"

	| document data |
	document _ self httpGetNoErrorDocument: url  args: nil  accept: 'application/octet-stream' request: ''.
	(document isKindOf: String) ifTrue: [
		"strings indicate errors"
		^ document ].
	document ifNil: [^ nil].
	data _ document content.
	(data beginsWith: '<HTML><HEAD>' , (String with: Character linefeed) , '<TITLE>4')
		ifTrue: ["an error message  404 File not found"
				^ data copyFrom: 21 to: data size-16].	

	^ (RWBinaryOrTextStream with: data) reset
! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'di 4/4/1999 09:57'!
httpGetNoError: url args: args accept: mimeType
	"Return the exact contents of a web file.  Do better error checking.  Asks for the given MIME type.  To fetch raw data, you can use the MIMI type 'application/octet-stream'.  If mimeType is nil, use 'text/html'.  The parsed header is saved. Use a proxy server if one has been registered."

"Edited to remove a lineFeed from the source 4/4/99 - di"

	| document data |
	document _ self httpGetDocument: url  args: args  accept: mimeType.
	(document isKindOf: String) ifTrue: [
		"strings indicate errors"
		^ document ].
	data _ document content.
	(data beginsWith: '<HTML><HEAD>' , (String with: Character linefeed) , '<TITLE>4')
		ifTrue: ["an error message  404 File not found"
				^ data copyFrom: 21 to: data size-16].	

	^ (RWBinaryOrTextStream with: data) reset
! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'EMP 2/11/2016 15:32'!
httpGetNoErrorDocument: url args: args accept: mimeType request: requestString
	"Return the exact contents of a web object. Asks for the given MIME 
type. If mimeType is nil, use 'text/html'. An extra requestString may be 
submitted and must end with crlf.  The parsed header is saved. Use a 
proxy server if one has been registered.  tk 7/23/97 17:12"
	"Note: To fetch raw data, you can use the MIME type 
'application/octet-stream'."

	| serverName serverAddr port sock header length bare page list firstData 
aStream index connectToHost connectToPort type newUrl |
	Socket initializeNetwork.
	bare _ (url asLowercase beginsWith: 'http://') 
		ifTrue: [url copyFrom: 8 to: url size]
		ifFalse: [url].
	bare _ bare copyUpTo: $#.  "remove fragment, if specified"
	serverName _ bare copyUpTo: $/.
	page _ bare copyFrom: serverName size + 1 to: bare size.
	(serverName includes: $:) 
		ifTrue: [ index _ serverName indexOf: $:.
			port _ (serverName copyFrom: index+1 to: serverName size) asNumber.
			serverName _ serverName copyFrom: 1 to: index-1. ]
		ifFalse: [ port _ self defaultPort ].
	page size = 0 ifTrue: [page _ '/'].
	"add arguments"
	args ifNotNil: [page _ page, (self argString: args) ].


	HTTPProxyServer isNil
		ifTrue: [ 
			connectToHost _ serverName.
			connectToPort _ port ]
		ifFalse:  [
			page _ 'http://', serverName, ':', port printString, page.		"put back 
together"
			connectToHost _ HTTPProxyServer.
			connectToPort _ HTTPProxyPort].
	
	self flag: #XXX.  "this doesn't make sense if a user isn't available for 
questioning...  -ls"
	[serverAddr _ NetNameResolver addressForName: connectToHost 
timeout: 10.
				serverAddr ~~ nil] value ifFalse: [^ nil].

3 timesRepeat: [
	sock _ HTTPSocket new.
	sock connectTo: serverAddr port: connectToPort.
	(sock waitForConnectionUntil: (self deadlineSecs: 30)) ifFalse: [
		sock destroy.
		^ 'Server ',connectToHost,' is not responding'].
	Transcript cr; cr; show: url; cr.
	sock sendCommand: 'GET ', page, ' HTTP/1.0', CrLf, 
		(mimeType ifNotNil: ['ACCEPT: ', mimeType, CrLf] ifNil: ['']),
		'ACCEPT: text/html', CrLf,	"Always accept plain text"
		HTTPBlabEmail,	"may be empty"
		requestString,	"extra user request. Authorization"
		'User-Agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36', CrLf,
		'Host: ', serverName, ':', port printString, CrLf.	"blank line 
automatically added"

	list _ sock getResponseUpTo: CrLf, CrLf ignoring: (String with: CR).	"list = header, CrLf, CrLf, 
beginningOfData"
	header _ list at: 1.
	"Transcript show: page; cr; show: header; cr."
	firstData _ list at: 3.
	header isEmpty 
		ifTrue: [aStream _ 'server aborted early']
		ifFalse: [
			"dig out some headers"
			sock header: header.
			length _ sock getHeader: 'content-length'.
			length ifNotNil: [ length _ length asNumber ].
			type _ sock getHeader: 'content-type'.
			sock responseCode first = $3 ifTrue: [
				newUrl _ sock getHeader: 'location'.
				newUrl ifNotNil: [ 
					Transcript show: 'redirecting to ', newUrl; cr.
					sock destroy.
					^self httpGetNoErrorDocument: newUrl  args: args  accept: mimeType request: requestString ] ].
			aStream _ sock getRestOfBuffer: firstData totalLength: length.
			sock responseCode = '401' ifTrue: [^ header, aStream contents].
			].
	sock destroy.	"Always OK to destroy!!"
	aStream class ~~ String ifTrue: [
 		^ MIMEDocument contentType: type content: aStream contents url: url].
	aStream = 'server aborted early' ifFalse: [
		]
	].! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'jm 12/1/2005 16:42'!
httpGif: url
	"Fetch the given URL, parse it using the GIF reader, and return the resulting Form."
	"	HTTPSocket httpShowGif: 'www.altavista.digital.com/av/pix/default/av-adv.gif'	 "
	"	HTTPSocket httpShowGif: 'www.webPage.com/~kaehler2/ainslie.gif'	 "

	| doc |
	doc _ self httpGet: url accept: 'image/gif'.
	doc class == String ifTrue: [
		self inform: 'The server with that GIF is not responding'.
		^ ColorForm extent: 20@20 depth: 8].
	doc binary; reset.
	^ (GIFReadWriter setStream: doc) nextImage.
! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'jm 12/1/2005 16:41'!
httpJpeg: url
	"Fetch the given URL, parse it using the JPEG reader, and return the resulting Form."

	| doc |
	doc _ self httpGet: url.
	^ FastJPEG uncompress: (doc binary; reset; contents)
! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'tk 9/22/1998 23:27'!
httpPost: url  args: argsDict accept: mimeType 
	"like httpGET, except it does a POST instead of a GET.  POST allows data to be uploaded"
	| document |
	document _ self httpPostDocument: url  args: argsDict  accept: mimeType  request: ''.
	(document isKindOf: String) ifTrue: [ 
		"strings indicate errors"
		^document ].

	
	^RWBinaryOrTextStream with: document content! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'tk 9/22/1998 23:27'!
httpPostDocument: url  args: argsDict
	"like httpGET, except it does a POST instead of a GET.  POST allows data to be uploaded"

	^self httpPostDocument: url args: argsDict accept: 'application/octet-stream' request: ''! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'tk 9/22/1998 20:16'!
httpPostDocument: url  args: argsDict accept: mimeType 
	"like httpGET, except it does a POST instead of a GET.  POST allows data to be uploaded"

	^ self httpPostDocument: url args: argsDict accept: mimeType request: ''
! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'tao 6/22/1999 07:46'!
httpPostDocument: url  args: argsDict accept: mimeType request: requestString
	"like httpGET, except it does a POST instead of a GET.  POST allows data to be uploaded"

	| serverName serverAddr s header length bare page list firstData aStream port argsStream first specifiedServer type newUrl |
	Socket initializeNetwork.

	"parse url"
	bare _ (url asLowercase beginsWith: 'http://') 
		ifTrue: [url copyFrom: 8 to: url size]
		ifFalse: [url].
	serverName _ bare copyUpTo: $/.
	specifiedServer _ serverName.
	(serverName includes: $:) ifFalse: [ port _ self defaultPort ] ifTrue: [
		port _ (serverName copyFrom: (serverName indexOf: $:) + 1 
				to: serverName size) asNumber.
		serverName _ serverName copyUpTo: $:.
	].

	page _ bare copyFrom: (bare indexOf: $/) to: bare size.
	page size = 0 ifTrue: [page _ '/'].
	HTTPProxyServer ifNotNil: [ 
		page _ 'http://', serverName, ':', port printString, page.		"put back together"
		serverName _ HTTPProxyServer.
		port _ HTTPProxyPort].

	"encode the arguments dictionary"
	argsStream _ WriteStream on: String new.
	first _ true.
	argsDict associationsDo: [ :assoc |
		assoc value do: [ :value |
			first ifTrue: [ first _ false ] ifFalse: [ argsStream nextPut: $& ].
			argsStream nextPutAll: assoc key encodeForHTTP.
			argsStream nextPut: $=.
			argsStream nextPutAll: value encodeForHTTP.
	] ].

  	"make the request"	
	self retry: [serverAddr _ NetNameResolver addressForName: serverName timeout: 20.
				serverAddr ~~ nil] 
		asking: 'Trouble resolving server name.  Keep trying?'
		ifGiveUp: [^ 'Could not resolve the server named: ', serverName].

	s _ HTTPSocket new.
	s connectTo: serverAddr port: port.
	s waitForConnectionUntil: self standardDeadline.
	Transcript cr; show: url; cr.
	s sendCommand: 'POST ', page, ' HTTP/1.0', CrLf, 
		(mimeType ifNotNil: ['ACCEPT: ', mimeType, CrLf] ifNil: ['']),
		'ACCEPT: text/html', CrLf,	"Always accept plain text"
		HTTPBlabEmail,	"may be empty"
		requestString,	"extra user request. Authorization"
		'User-Agent: Squeak 1.31', CrLf,
		'Content-type: application/x-www-form-urlencoded', CrLf,
		'Content-length: ', argsStream contents size printString, CrLf,
		'Host: ', specifiedServer, CrLf.  "blank line automatically added"

	s sendCommand: argsStream contents.

	"get the header of the reply"
	list _ s getResponseUpTo: CrLf, CrLf ignoring: (String with: CR).	"list = header, CrLf, CrLf, beginningOfData"
	header _ list at: 1.
	"Transcript show: page; cr; show: argsStream contents; cr; show: header; cr."
	firstData _ list at: 3.

	"dig out some headers"
	s header: header.
	length _ s getHeader: 'content-length'.
	length ifNotNil: [ length _ length asNumber ].
	type _ s getHeader: 'content-type'.
	s responseCode first = $3 ifTrue: [
		newUrl _ s getHeader: 'location'.
		newUrl ifNotNil: [
			Transcript show: 'redirecting to: ', newUrl; cr.
			s destroy.
			^self httpPostDocument: newUrl  args: argsDict  accept: mimeType ] ].

	aStream _ s getRestOfBuffer: firstData totalLength: length.
	s responseCode = '401' ifTrue: [^ header, aStream contents].
	s destroy.	"Always OK to destroy!!"

	^ MIMEDocument contentType: type  content: aStream contents url: url! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'tk 5/4/1998 17:00'!
httpShowChunk: url
	"From a Swiki server, get a text chunk in the changes file.  Show its text in a window with style.  Vertical bar separates class and selector.  BE SURE TO USE ; instead of : in selectors!!"
	"	HTTPSocket httpShowChunk: 'http://206.16.12.145:80/OurOwnArea.chunk.Socket|Comment'	 "
	"	HTTPSocket httpShowChunk: 'http://206.16.12.145:80/OurOwnArea.chunk.Point|class|x;y;'	"

	| doc text |
	doc _ (self httpGet: url accept: 'application/octet-stream').
"	doc size = 0 ifTrue: [doc _ 'The server does not seem to be responding']."
	doc class == String ifTrue: [text _ doc] ifFalse: [text _ doc nextChunkText].
	(StringHolder new contents: text) openLabel: url.
! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'sma 4/30/2000 09:50'!
httpShowGif: url
	"Display the picture retrieved from the given URL, which is assumed to be a GIF file.
	See examples in httpGif:."

	self showImage: (self httpGif: url) named: (url findTokens: '/') last! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'sma 4/30/2000 09:51'!
httpShowJpeg: url
	"Display the picture retrieved from the given URL, which is assumed to be a JPEG file.
	See examples in httpGif:."

	self showImage: (self httpJpeg: url) named: (url findTokens: '/') last! !

!HTTPSocket class methodsFor: 'get the page' stamp: 'tk 5/4/1998 17:01'!
httpShowPage: url
	"Display the exact contents of the given URL as text. See examples in httpGet:"

	| doc |
	doc _ (self httpGet: url accept: 'application/octet-stream') contents.
	doc size = 0 ifTrue: [^ self error: 'Document could not be fetched'].
	(StringHolder new contents: doc) openLabel: url.
! !


!HTTPSocket class methodsFor: 'proxy settings' stamp: 'jm 9/15/97 12:06'!
proxyTestingComment
	"Test Kevin's SmartCache on this machine"
	"	HTTPSocket useProxyServerNamed: '127.0.0.1' port: 8080.
		HTTPSocket httpShowPage: 'http://www.disneyblast.com/default.html'.
		HTTPSocket stopUsingProxyServer.	"

	"Test getting to outside world from DOL"
	"	HTTPSocket useProxyServerNamed: 'web-proxy.online.disney.com' port: 8080.
		HTTPSocket httpShowPage: 'http://www.apple.com/default.html'.
		HTTPSocket stopUsingProxyServer.	"

	"Test Windows Machine in our cubicle at DOL"
	"	HTTPSocket useProxyServerNamed: '206.18.67.150' port: 8080.
		HTTPSocket httpShowPage: 'http://kids.online.disney.com/~kevin/squeak/k_t.morph'.
		HTTPSocket stopUsingProxyServer.	"

	"	HTTPSocket httpShowPage: 'kids.online.disney.com/'	"
	"	HTTPSocket httpShowGif: 'kids.online.disney.com/~kevin/images/dlogo.gif'	"
! !

!HTTPSocket class methodsFor: 'proxy settings' stamp: 'ls 9/17/1998 07:18'!
stopUsingProxyServer
	"Stop directing HTTP request through a proxy server."

	HTTPProxyServer _ nil.
	HTTPProxyPort _ 80.
! !

!HTTPSocket class methodsFor: 'proxy settings' stamp: 'msk 9/28/1998 15:52'!
useProxyServerNamed: proxyServerName port: portNum
	"Direct all HTTP requests to the HTTP proxy server with the given name and port number."

	proxyServerName ifNil: [  "clear proxy settings"
		HTTPProxyServer _ nil.
		HTTPProxyPort _ 80.
		^ self].

	proxyServerName class == String
		ifFalse: [self error: 'Server name must be a String or nil'].
	HTTPProxyServer _ proxyServerName.

	HTTPProxyPort _ portNum.
	HTTPProxyPort class == String ifTrue: [HTTPPort _ portNum asNumber].
	HTTPProxyPort ifNil: [HTTPProxyPort _ self defaultPort].! !


!HTTPSocket class methodsFor: 'utilities' stamp: 'tk 7/16/1999 16:46'!
argString: args
	"Return the args in a long string, as encoded in a url"

	| argsString first |
	args class == String ifTrue: ["sent in as a string, not a dictionary"
		^ (args first = $? ifTrue: [''] ifFalse: ['?']), args].
	argsString _ WriteStream on: String new.
	argsString nextPut: $?.
	first _ true.
	args associationsDo: [ :assoc |
		assoc value do: [ :value |
			first ifTrue: [ first _ false ] ifFalse: [ argsString nextPut: $& ].
			argsString nextPutAll: assoc key encodeForHTTP.
			argsString nextPut: $=.
			argsString nextPutAll: value encodeForHTTP. ] ].
	^ argsString contents
! !

!HTTPSocket class methodsFor: 'utilities' stamp: 'jm 9/15/97 11:10'!
retry: tryBlock asking: troubleString ifGiveUp: abortActionBlock
	"Execute the given block. If it evaluates to true, return true. If it evaluates to false, prompt the user with the given string to see if he wants to try again. If not, evaluate the abortActionBlock and return false."

	| response |
	[tryBlock value] whileFalse: [
		response _ (PopUpMenu labels: 'Retry\Give Up' withCRs)
			startUpWithCaption: troubleString.
		response = 2 ifTrue: [abortActionBlock value. ^ false]].
	^ true
! !

!HTTPSocket class methodsFor: 'utilities' stamp: 'jm 12/7/2005 09:35'!
showImage: image named: imageName

	Smalltalk isMorphic
		ifTrue: [World activeHand attachMorph: (SketchMorph withForm: image)]
		ifFalse: [FormView open: image named: imageName].
! !


!HTTPSocket class methodsFor: 'magic numbers' stamp: 'ls 9/17/1998 07:17'!
defaultPort
	"default port to connect on"
	^80! !


HTTPSocket initialize!
