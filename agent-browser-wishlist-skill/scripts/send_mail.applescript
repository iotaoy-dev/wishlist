on run argv
  if (count of argv) < 3 then
    error "Usage: osascript send_mail.applescript <to> <subject> <body> [attachment_path]"
  end if

  set recipientAddress to item 1 of argv
  set subjectLine to item 2 of argv
  set bodyText to item 3 of argv
  set attachmentPath to ""
  if (count of argv) ≥ 4 then
    set attachmentPath to item 4 of argv
  end if

  tell application "Mail"
    set newMessage to make new outgoing message with properties {subject:subjectLine, content:bodyText & return & return, visible:false}
    tell newMessage
      make new to recipient at end of to recipients with properties {address:recipientAddress}
      if attachmentPath is not "" then
        try
          make new attachment with properties {file name:(POSIX file attachmentPath as alias)} at after the last paragraph
        end try
      end if
      send
    end tell
  end tell
end run
