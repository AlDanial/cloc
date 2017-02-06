"SimpleChat -- a SimpleTCP handler for a chat server"
"http://sblinn.jottit.com/gnu_smalltalk_simplechat_tcp_server"

Namespace current addSubspace: #SimpleChat!
Namespace current: SimpleChat!

Object subclass: #Handler
  instanceVariableNames: 'clients'
  classVariableNames: ''
  poolDictionaries: ''
  category: ''!

!Handler class methodsFor: 'instance creation'!

new
  | chatHandler |
  chatHandler := super new.
  chatHandler init.
  ^chatHandler
!!

!Handler methodsFor: 'initialization'!

init
  clients := Dictionary new.
  ^self
!!

!Handler methodsFor: 'handling'!

handle: aSocket
  [self handleSocket: aSocket] fork
!!

!Handler methodsFor: 'internal handling'!

handleSocket: aSocket
  | Name |
  'Name: ' displayOn: aSocket.
  aSocket flush.
  Name := (aSocket nextLine).
  (clients includesKey: Name) ifTrue: [
    'Sorry, that name is in use.' displayOn: aSocket.
    (Character nl asString) displayOn: aSocket.
    self handle: aSocket
  ] ifFalse: [
    self handleMessage: ('New user: ', Name) from: '[System]'.
    clients at: Name put: aSocket.
    self handleClient: aSocket named: Name
  ]
!

handleClient: aSocket named: Name
  [
    | Message |
    self sendPrompt: aSocket.
    Message := (aSocket nextLine).
    self handleMessage: Message from: Name.
  ] repeat
!

handleMessage: Message from: Name
  clients associationsDo: [ :assoc |
    (Name = (assoc key)) ifFalse: [
      self sendMessage: ((Character nl asString), Name, ' sent: ', Message) to: (assoc value).
      self sendPrompt: (assoc value)
    ] ifTrue: [
      self sendMessage: ('You sent: ', Message) to: (assoc value)
    ]]
!

sendMessage: Message to: aSocket
  Message displayOn: aSocket.
  (Character nl asString) displayOn: aSocket
!

sendPrompt: aSocket
    '> ' displayOn: aSocket.
    aSocket flush
!!

Namespace current: SimpleChat superspace!
