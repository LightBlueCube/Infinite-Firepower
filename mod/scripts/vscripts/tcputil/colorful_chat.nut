global function ColorfulChat_Init

struct{
	array<string> ansiColors = [
		"\x1b[30m", "\x1b[31m", "\x1b[32m", "\x1b[33m", "\x1b[34m", "\x1b[35m", "\x1b[36m", "\x1b[37m",
		"\x1b[90m", "\x1b[91m", "\x1b[92m", "\x1b[93m", "\x1b[94m", "\x1b[95m", "\x1b[96m", "\x1b[97m"
	]
}file

void function ColorfulChat_Init()
{
	AddCallback_OnReceivedSayTextMessage_AfterChatCommand( OnReceiveChatMessage )
}

ClServer_MessageStruct function OnReceiveChatMessage( ClServer_MessageStruct msgStruct )
{
	// colors //
	string msg = msgStruct.message
	for( int i = file.ansiColors.len() - 1; i >= 0; i-- )
		msg = AddChatColors( msg, "!"+ i +" ", i )
	msg = AddChatColors( msg, "!a ", RandomInt( file.ansiColors.len() ) )
	msg = AddChatColors( msg, "!r ", 0, true )

	msgStruct.message = msg
	return msgStruct
}

string function AddChatColors( string text, string targetcmd, int color, bool random = false )
{
	string str = ""
	array<string> splitArray = split( text, targetcmd )
	if( splitArray == [] )
		return text
	foreach( string val in splitArray )
	{
		if( val == splitArray[0] )
		{
			str += val
			continue
		}

		str += file.ansiColors[ random ? RandomInt( file.ansiColors.len() ) : color ] + val
	}
	return str
}