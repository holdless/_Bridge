theKey = "[file move]"; --or "[file copy]" or "[notes]", "[evernote]"
repeat
	theKeyMsgs = check_new_mail_with_key_in_title(theKey) -- problem occurred on 643.2.1018
	set read status of theKeyMsgs to true

	repeat thisMsg in theKeyMsgs
		theCurrentPath = parse_info_in_content(thisMsg, currentPath)
		theTargetPath = parse_info_in_content(thisMsg, targetPath)
		theMailAddress = parse_info_in_content(thisMsg, mailAddress)
		theFolder = parse_info_in_content(thisMsg, folderPath)
		theBody = parse_info_in_content(thisMsg, body)
		theTag = parse_info_in_content(thisMsg, tag)
		
		if theKey is "[file move]" then
			move file the currentPath to theTargetpath
		else if theKey is "[file copy]"
			copy file the currentPath to theTargetpath
		else if theKey is "[file mail]"
			send_mail_with_attachment(theCurrentPath, theHostAddress, theTargetAddress)
		else if theKey is "[notes]" then
			create_new_note_in_notes(theFolder, theBody)
		else if theKey is "[evernotes]" then
			create_new_note_in_evernote(theFolder, theBody)
		end if
	end repeat
end repeat


on check_new_mail_with_key_in_title(_keyword)
	tell application "Mail"
		check for new mail
    	
		repeat until (background activity count) = 0
       		delay 0.5 --wait until all new messages are in the box
    	end repeat
	
    	set myInbox to every message of inbox
    	repeat with msg in myInbox
        	-- and look at only the ones that are unread
        	if read status of msg is false then
            	-- and if the subject of the unread message is what we want 
            	if msg's subject contains _keyword then
                	return it
            	end if
        	end if
    	end repeat
	end tell
end check_new_mail_with_key_in_title

on parse_info_in_content(_msg, _tag)
	set theMsgContent to the content of _msg
	-- parse html format
	-- https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/ParseHTML.html
end parse_info_in_content

on send_mail_with_attachment(_path, _fromAddress, _toAddress)
	-- count files in folder
	tell application "Finder"
		set theFile to _path as alias
		set theFileName to name of theFile
	end tell
	
	-- set up mail detail
	set theSubject to theFileName
	set theBody to "Hello sir. Here is my " & theFileName
	set theAddress to _toAddress
	set theAttachment to theFile
	set theSender to _fromAddress
	
	tell application "Mail"
		set theNewMsg to make new outgoing message with properties {subject:theSubject, content:theBody & return & return, visible:true}
		tell theNewMsg
			set visibile to true
			set sender to theSender
			make new to recipient at end of to recipients with properties {address:theAddress}
			try
				make new attachment with properties {file name:theAttachment} at after the last word of the last paragraph
				set message_attachment to 0
			on error errmess -- oops
				log errmess -- log the error
				set message_attachment to 1
			end try
			log "message_attachment = " & message_attachment
			delay 10
			send
		end tell
	end tell
end send_mail_with_attachment

on create_new_note_in_notes(_folderName, _body)
end create_new_note_in_notes

on create_new_note_in_evernote(_folderName, _body)
end create_new_note_in_evernote

---------------
-- [file move/copy] 
--	<cpath>"file path"</cpath>
-- 	<tpath>"target path"</tpath>

-- [file mail]
--	<cpath>"file path"</cpath>
--	<mail>"mail address"</mail>

-- [folder tree]
--	<cpath>"file path"</cpath>

---------------
-- [note] 643.3.1019 i'm title
-- 	<folder>_remote_add</folder>
-- 	<body> balidsalfj </body>

---------------
-- [evernotes] 643.3.1019 i'm title
-- 	<folder>_remote_add</folder>
-- 	<body> balidsalfj </body>
-- 	<tag>pi,c/c++,matlab,...</tag>
