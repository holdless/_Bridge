set theKey to "[jarvis]"
tell application "Mail"
	repeat
		--	set theMail to check_new_mail_with_key_in_title(theKey) -- problem occurred on 643.2.1018
		
		check for new mail
		
		delay 3 --wait until all new messages are in the box
		
		set myInbox to every message of inbox
		repeat with msg in myInbox
			-- and look at only the ones that are unread
			if read status of msg is false then
				-- and if the subject of the unread message is what we want 
				if msg's subject contains "[jarvis]" then
					set theMail to msg
					set read status of theMail to true
					set theMsgContent to the content of theMail as string
					set theCurrentPath to my parseMarkupText(theMsgContent, "<currentPath>", "</currentPath>")
					log theCurrentPath
					set theTargetPath to my parseMarkupText(theMsgContent, "<targetPath>", "</targetPath>")
					set theMailAddress to my parseMarkupText(theMsgContent, "<mailAddress>", "</mailAddress>")
					set theFolder to my parseMarkupText(theMsgContent, "<folderPath>", "</folderPath>")
					set theTitle to my parseMarkupText(theMsgContent, "<title>", "</title>")
					set theBody to my parseMarkupText(theMsgContent, "<body>", "</body>")
					set theTag to my parseMarkupText(theMsgContent, "<tag>", "</tag>")
					
					try
						if the subject of theMail contains "[file move]" then
							move file the currentPath to theTargetPath
						else if the subject of theMail contains "[file copy]" then
							copy file the currentPath to theTargetPath
						else if the subject of theMail contains "[file mail]" then
							my send_mail_with_attachment(theCurrentPath, theHostAddress, theTargetAddress)
						else if the subject of theMail contains "[folder tree]" then
							my show_folder_tree(theCurrentPath)
						else if the subject of theMail contains "[notes]" then
							my create_new_note_in_notes(theFolder, theBody)
						else if the subject of theMail contains "[evernotes]" then
							my create_new_note_in_evernote(theFolder, theBody)
						end if
					end try
					
				end if
			else
				set theMail to false
			end if
		end repeat
		
		delay 10
	end repeat
end tell

on parseMarkupText(_text, _frontTag, _backTag)
	-- https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/ParseHTML.html
	set textBeginFlag to false
	set tagDetectedFlag to false
	set theCleanTextCandidate to ""
	set theFinalText to ""
	set theTag to ""
	repeat with a from 1 to length of _text
		set theCurrentCharacter to character a of _text
		if theCurrentCharacter is "<" then
			set tagDetectedFlag to true
			set theTag to theTag & theCurrentCharacter as string
		else if theCurrentCharacter is ">" then
			set tagDetectedFlag to false
			set theTag to theTag & theCurrentCharacter as string
			if theTag is equal to _frontTag then
				log theTag
				set textBeginFlag to true
				set theTag to ""
			else if theTag is equal to _backTag then
				log theTag
				log theFinalText
				set theFinalText to theCleanTextCandidate
				return theFinalText
			else
				set theTag to ""
			end if
		else if tagDetectedFlag is true then
			set theTag to theTag & theCurrentCharacter as string
		else if tagDetectedFlag is false and textBeginFlag is true then
			set theCleanTextCandidate to theCleanTextCandidate & theCurrentCharacter as string
		end if
	end repeat
	return false
end parseMarkupText

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

on show_folder_tree(theCurrentPath)
	tell application "Finder"
		set theFileList to name of every file of entire contents of theCurrentPath
		log theFileList
	end tell
end show_folder_tree

on create_new_note_in_notes(_folderName, _title, _body)
	set noteHTMLText to "<pre style=\"font-family:Helvetica,sans-serif;\">" & (the clipboard as Unicode text) & "</pre>"
	tell application "Notes"
		activate
		set thisAccountName to my getNameOfTargetAccount("Choose an account:")
		tell account thisAccountName
			if not (exists folder _folderName) then
				make new folder with properties {name:_folderName}
			end if
			make new note at folder _folderName with properties {name:_title, body:noteHTMLText}
		end tell
	end tell
end create_new_note_in_notes

on create_new_note_in_evernote(_folderName, _body)
end create_new_note_in_evernote

on getNameOfTargetAccount(thisPrompt)
	tell application "Notes"
		if the (count of accounts) is greater than 1 then
			set theseAccountNames to the name of every account
			set thisAccountName to (choose from list theseAccountNames with prompt thisPrompt)
			if thisAccountName is false then error number -128
			set thisAccountName to thisAccountName as string
		else
			set thisAccountName to the name of account 1
		end if
		return thisAccountName
	end tell
end getNameOfTargetAccount



---------------
-- [file move/copy] 
--	<currentPath>"file path"</currentPath>
-- 	<targetPath>"target path"</targetPath>

-- [file mail]
--	<currentPath>"file path"</currentPath>
--	<mailAddress>"mail address"</mailAddress>

-- [folder tree]
--	<currentPath>"file path"</currentPath>

---------------
-- [note] 643.3.1019 i'm title
-- 	<folder>_remote_add</folder>
-- 	<title> i title </title>
-- 	<body> balidsalfj </body>

---------------
-- [evernotes] 643.3.1019 i'm title
-- 	<folder>_remote_add</folder>
-- 	<title> i title </title>
-- 	<body> balidsalfj </body>
-- 	<tag>pi,c/c++,matlab,...</tag>
