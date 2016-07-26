set myMail to GetRecentSpecialMail("Aaa")

tell application "Mail"
	if myMail is false then
		-- no message in inbox with keyword
		set myText to "no mail found"
	else
		set myText to content of myMail
		--set result to ReplyResponse()
	end if
	
	--	log myText
	
end tell

ReplyResponse(myMail)

on GetRecentSpecialMail(keyWord)
	tell application "Mail"
		repeat with receivedMessage in messages in inbox
			set receivedDate to date received of receivedMessage
			set messageContent to (get content of receivedMessage)
			if ((current date) - receivedDate) < 24 * hours then
				if (messageContent contains keyWord) then
					return receivedMessage
				end if
				--else
				--	return false
			end if
		end repeat
		
		return false
		
	end tell
end GetRecentSpecialMail

on ReplyResponse(myMail)
	tell application "Mail"
		
		
		if myMail is false then
			-- no message in inbox with keyword
			--			set myText to "no mail found"
			return 0
		else
			set theAddress to the sender of myMail
			--			set this_subject to the subject of myMail
			set theSubject to "from jarvis"
			set theBody to "response from jarvis: Jack loves Frances!"
			set theSender to "changyht@gmail.com"
			set myText to content of myMail
			set theNewMessage to make new outgoing message with properties {subject:theSubject, content:theBody & return & return, visible:true}
			tell theNewMessage
				set visibile to true
				set sender to theSender
				make new to recipient at end of to recipients with properties {address:theAddress}
				--delay 1
				send
			end tell
			
			return 1
		end if
		
		
	end tell
end ReplyResponse
