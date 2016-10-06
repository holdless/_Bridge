tell application "Finder"
	set folderPath to folder "Macintosh HD:Users:hiroshi:Google Drive:send1:"
	set folderPath2 to folder "Macintosh HD:Users:hiroshi:Google Drive:send2:"
	set numberOfFiles to count of (files in folderPath)
end tell


repeat numberOfFiles times
	-- count files in folder
	tell application "Finder"
		set theFile to first file in folderPath as alias
		set fileName to name of theFile
	end tell
	-- set up mail detail
	set theSubject to fileName
	set theBody to "Hello sir. Here is my " & fileName
	set theAddress to "changyht@tsmc.com"
	set theAttachment to theFile
	set theSender to "changyht@gmail.com"
	
	tell application "Mail"
		set theNewMessage to make new outgoing message with properties {subject:theSubject, content:theBody & return & return, visible:true}
		tell theNewMessage
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
			delay 100
		end tell
	end tell
	
	-- move first file in folder to other place
	tell application "Finder"
		move theFile to folderPath2 with replacing
	end tell
	
end repeat
