;// ZosMsg.h - Messages
;
;#pragma once
;

MessageIdTypedef=DWORD

SeverityNames=(Success=0x0:STATUS_SEVERITY_SUCCESS
               Informational=0x1:STATUS_SEVERITY_INFORMATIONAL
               Warning=0x2:STATUS_SEVERITY_WARNING
               Error=0x3:STATUS_SEVERITY_ERROR
              )

FacilityNames=(App=0x100:FACILITY_APPLICATION
               Xml=0x00C:FACILITY_XML)

LanguageNames=(English=0x409:MSG00409)

MessageId= Facility=App Severity=Error SymbolicName=MSG_APPL_NOT_AVAILABLE
Language=English
%2 is not available on this system: %1
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_ATL_INIT_FAILED
Language=English
ATL initialization failed.
.

MessageId= Facility=App Severity=Success SymbolicName=MSG_AUDIT_LOCK_RESET
Language=English
Audit lock reset.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_BINARY_CRLF_NOT_SUPPORTED
Language=English
Binary CRLF format is not supported by this version of the server.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_BINARY_DATA_NOT_SUPPORTED
Language=English
Binary format is not supported by this version of the server.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_CHECKING_IN1
Language=English
Checking in component: %1
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_CHECKING_IN2
Language=English
Checking in %1!d! component(s) of type %2.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_CHECKING_OUT1
Language=English
Checking out component: %1
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_CHECKING_OUT2
Language=English
Checking out %1!d! component(s) of type %2.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_CODE_PAGE_INCORRECT
Language=English
Code page for %1 is incorrect.  Code page number on server connection properties must match the "LCLCCSID=%2" parameter specified on the mainframe started task.  To disable this check, uncheck the "Validate code page" check box in the logon dialog box.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_COMMAND_DISABLED
Language=English
Command disabled: %1.
.

MessageId= Facility=App Severity=Warning SymbolicName=MSG_CONFIRM_CANCEL
Language=English
Are you sure you want to cancel the operation?
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_CREATE_EVENT_FAILED
Language=English
Failed to create start notification event: %1.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_CREATE_DIRECTORY_FAILED
Language=English
Failed to create directory "%1": %2.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_DBCS_UNSUPPORTED
Language=English
Server software version does not support DBCS code page.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_DISCONNECTUSER_INPROGRESS
Language=English
Detach user %1 connection from server %2 in progress.  Time remaing %3!d! minute(s).
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_DRIVER_ERROR
Language=English
Error connecting to Serena Network file system driver: %1
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_DRIVER_NOT_STARTED
Language=English
Serena Network file system driver not started.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_DRIVER_PAUSED
Language=English
Serena Network file system has been paused.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_DUMP_CREATED
Language=English
Dump file created:%n%1
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_DUMP_FAILED
Language=English
Unable to create dump.%n%1
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_EMPTY_FILE
Language=English
File is empty.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_FILE_NOT_FOUND
Language=English
File not found: %1
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_FUNCTION_NOT_COMPLETED
Language=English
Server failed to complete this function.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_INCORRECT_CHANGEMAN_PORT
Language=English
Incorrect %1 port specified: %2.  The ChangeMan port number must match the "CMN=nnnn" parameter specified on the mainframe started task.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_INCORRECT_SERVER_PORT
Language=English
Incorrect %1 port specified: %2.  This server port number must match the "XCH=nnnn" parameter specified on the mainframe started task.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_JCL_TEXT_INVALID
Language=English
JCL text is not valid.  JCL statements must begin with "//".
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_JOB_STATEMENT_MISSING
Language=English
JOB statement missing.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_MAX_CHARS
Language=English
Maximum number of characters that can be specified is %1.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_MAX_LINES
Language=English
Maximum number of lines that can be specified is %1.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_NETWORK_ALREADY_STARTED
Language=English
Serena Network already started.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_NOT_ALPHA_FIRST
Language=English
First character must be alphabetic.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_NOT_ALPHANUMERIC
Language=English
Text must contain only alphanumeric characters.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_NOTIFY_MESSAGE1
Language=English
%1.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_NOTIFY_MESSAGE2
Language=English
%1: %2.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_NOTIFY_MESSAGE3
Language=English
%1(%2): %3.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_PACKAGE_NOT_PARTICIPATING
Language=English
Package %1 not a participating package.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_PART_PACKAGE_ALREADY_BELONGS
Language=English
Participating package %1 already belongs to package %2.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_PASSWORD_MISMATCH
Language=English
New password and confirm password do not match.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_PASSWORD_TOO_SHORT
Language=English
New password phrase must be longert than 8 characters.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_REG_VERSION_MISMATCH
Language=English
Version mismatch with product registration.  Register ChangeMan ZDD again using ZosReg.dll.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_REQUIRED_FIELD
Language=English
Required field is empty.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_SERVER_SHUTDOWN
Language=English
Server %1  shutdown in progress.  Immediate termination.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_SERVER_SHUTDOWN_INPROGRESS
Language=English
Server %1  shutdown in progress.  Time remaining %2!d! minute(s).
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_SERVER_VERSION_UNSUPPORTED
Language=English
Server software version is unsupported.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_STARTED
Language=English
Serena Network started.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_STARTING
Language=English
Serena Network starting.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_STOPPING
Language=English
Serena Network stopping.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_SYSTEM
Language=English
%%%1
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_TEMP_FOLDER
Language=English
Serena Network temporary folder: "%1".
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_TEXT
Language=English
%1
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_UNSUCCESSFUL
Language=English
The requested operation was unsuccessful.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_UPLOAD_TOO_LARGE
Language=English
File "%1" size (%2) exceeds maximum upload size (%3).
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_UPLOAD_WAIT
Language=English
Waiting for server to process uploaded data.
This may take several minutes.
.

MessageId= Facility=App Severity=Informational SymbolicName=MSG_VALIDATE_VERSIONS_WAIT
Language=English
Waiting for server to validate rocess uploaded data.
This may take several minutes.
.

MessageId= Facility=App Severity=Warning SymbolicName=MSG_VERSION_SERVER
Language=English
Server version does not support this function.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_WAIT_FAILED
Language=English
Wait failed: %1
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_WINSOCK_INIT_FAILED
Language=English
WinSock initialization failed (%1): %2
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_XML_ATTRIBUTE_REQUIRED
Language=English
Required "%2!hs!=" attribute is missing in <%1!hs!> element.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_XML_ATTRIBUTE_NAME_UNRECOGNIZED
Language=English
Unrecognized "%2!hs!=" attribute in <%1!hs!> element.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_XML_ATTRIBUTE_VALUE_INVALID
Language=English
Invalid value "%3" specified for "%2!hs!=" attribute in <%1!hs!> element.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_XML_ATTRIBUTE_VALUE_INVALID2
Language=English
Invalid value "%4" specified for "%3!hs!=" attribute in <%1!hs! name="%2"> element.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_XML_ELEMENT_NOT_FOUND
Language=English
Element <%1!hs!> not found.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_XML_ELEMENT_NAME_UNRECOGNIZED
Language=English
Unrecognized element name specified: <%1!hs!>
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_XML_LOCATION
Language=English
%1  (Line %2!d!, Position %3!d!)
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_XML_PARSER_NOT_INSTALLED
Language=English
XML parser is not installed. XML services will not work.
.

MessageId= Severity=Error SymbolicName=MSG_XML_WRITER_STATE_INCORRECT
Language=English
XML writer is in incorrect state for requested operation.
.

MessageId= Facility=App Severity=Error SymbolicName=MSG_ZDDOPTS_ERROR
Language=English
Server %1 has invalid XML data specified in ZDDOPTS member %2.
.

