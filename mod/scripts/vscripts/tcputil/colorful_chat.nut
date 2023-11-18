global function ColorfulChat_Init

struct
{
	array<string> ansiColors = [
		"\x1b[31m", "\x1b[32m", "\x1b[33m", "\x1b[34m", "\x1b[35m", "\x1b[36m", "\x1b[37m",
		"\x1b[96m", "\x1b[95m", "\x1b[94m", "\x1b[93m", "\x1b[92m", "\x1b[91m"
	]

	int lastColor = 0
} file

void function ColorfulChat_Init()
{
	AddCallback_OnReceivedSayTextMessage_AfterChatCommand( OnReceiveChatMessage )
}

ClServer_MessageStruct function OnReceiveChatMessage( ClServer_MessageStruct msgStruct )
{
	file.lastColor++
	if( file.lastColor >= file.ansiColors.len() )
		file.lastColor = 0
	msgStruct.message = file.ansiColors[ file.lastColor ] + msgStruct.message

	return msgStruct
}