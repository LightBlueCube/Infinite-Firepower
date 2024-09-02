global function Vote_SkipMatch_Init
global function VoteToSkipMatch

struct{
	bool hasVoted = false
	bool onVote = false
	int voteId = -1
}file

void function Vote_SkipMatch_Init()
{
	AddCallback_GameStateEnter( eGameState.Playing, VoteToSkipMatch )
	AddChatCommandCallback( "!skip", StartNewSkipMatchVoteEvemt )
	AddChatCommandCallback( "！skip", StartNewSkipMatchVoteEvemt )
	AddChatCommandCallback( "!sy", SkipMatchOnVoteYes )
	AddChatCommandCallback( "！sy", SkipMatchOnVoteYes )
	AddChatCommandCallback( "!sn", SkipMatchOnVoteNo )
	AddChatCommandCallback( "！sn", SkipMatchOnVoteNo )
}

bool function SkipMatchOnVoteYes( entity player, array<string> args )
{
	return SkipMatchOnVote( player, "y" )
}

bool function SkipMatchOnVoteNo( entity player, array<string> args )
{
	return SkipMatchOnVote( player, "n" )
}

bool function SkipMatchOnVote( entity player, string vote )
{
	if( !HasVoteEvent( file.voteId ) )
		return false

	return GetVoteEvent( file.voteId ).onVoteFunc( GetVoteEvent( file.voteId ), player, vote )
}

bool function StartNewSkipMatchVoteEvemt( entity player, array<string> args )
{
	if( file.onVote )
	{
		Chat_ServerPrivateMessage( player, "\x1b[31m已经有一个跳过对局的投票了！", false, false )
		return true
	}
	file.hasVoted = true
	file.onVote = true

	VoteEventStruct voteEvent
	voteEvent.voteReleaseFunc = Vote_OnRelease
	voteEvent.onVoteFunc = Vote_OnVoteFunc
	voteEvent.voteEndFunc = Vote_OnEndFunc
	voteEvent.callbackFunc = SkipMatch
	voteEvent.voteName = "\x1b[94m要跳过此对局吗？"
	voteEvent.endTime = Time() + 60.0
	voteEvent.s.ownerName <- player.GetPlayerName()
	file.voteId = StartNewVoteEvent( voteEvent )
	Chat_ServerPrivateMessage( player, "\x1b[33m提示：你只是发起了投票，但并没有投，你可以使用指令投票一次", false, false )
	return false
}

void function VoteToSkipMatch()
{
	if( file.hasVoted || file.onVote )
		return
	file.hasVoted = true
	file.onVote = true

	VoteEventStruct voteEvent
	voteEvent.voteReleaseFunc = Vote_OnRelease
	voteEvent.onVoteFunc = Vote_OnVoteFunc
	voteEvent.voteEndFunc = Vote_OnEndFunc
	voteEvent.callbackFunc = SkipMatch
	voteEvent.voteName = "\x1b[94m要跳过此对局吗？"
	voteEvent.endTime = Time() + 60.0
	file.voteId = StartNewVoteEvent( voteEvent )
}

void function Vote_OnRelease( VoteEventStruct voteEvent )
{
	string name = "系统"
	if( "ownerName" in voteEvent.s )
		name = expect string( voteEvent.s.ownerName )
	foreach( ent in GetPlayerArray() )
		Chat_ServerPrivateMessage( ent, "\n\x1b[36m"+ name +" \x1b[32m发起了一个投票！投票名为 \x1b[36m"+ voteEvent.voteName, false, false )
	foreach( ent in GetPlayerArray() )
		Chat_ServerPrivateMessage( ent, "\x1b[32m输入 \x1b[36m!sy \x1b[32m投同意票\n输入 \x1b[36m!sn \x1b[32m投反对票", false, false )
}

void function Vote_OnEndFunc( VoteEventStruct voteEvent )
{
	if( voteEvent.endCode == eVoteEndCode.timeout )
		foreach( ent in GetPlayerArray() )
			Chat_ServerPrivateMessage( ent, "\n\x1b[32m名为 \x1b[36m"+ voteEvent.voteName +"\x1b[32m 的投票目前票数为\n\x1b[36m同意票 "+ voteEvent.voteYesCount +" / "+ voteEvent.voteNoCount +" 反对票", false, false )
	string voteEndText = "\x1b[33m此投票已结束！投票结果为："
	int yes = voteEvent.voteYesCount
	int no = voteEvent.voteNoCount
	bool vote = false
	if( yes == no )
		voteEndText += "\x1b[36m票数持平，按反对票居多处理"
	else if( yes > no )
	{
		voteEndText += "\x1b[36m同意票居多"
		if( yes <= float( GetPlayerArray().len() ) * 0.2 )
			voteEndText += "，但未达到最低同意人数要求，按反对票居多处理"
		else
			vote = true

	}
	else
		voteEndText += "\x1b[36m反对票居多"
	foreach( ent in GetPlayerArray() )
		Chat_ServerPrivateMessage( ent, voteEndText, false, false )

	file.voteId = -1

	voteEvent.callbackFunc( vote )
}

bool function Vote_OnVoteFunc( VoteEventStruct voteEvent, entity player, string vote )
{
	if( ![ "y", "n" ].contains( vote ) )
	{
		Chat_ServerPrivateMessage( player, "\x1b[31m无效投票选项，请注意大小写！", false, false )
		Vote_ShowList( player )
		return true
	}

	if( voteEvent.hasVotedPlayers.contains( player.GetUID() ) )
	{
		Chat_ServerPrivateMessage( player, "\x1b[31m你已经投过票了！", false, false )
		return true
	}

	voteEvent.hasVotedPlayers.append( player.GetUID() )
	if( vote == "y" )
		voteEvent.voteYesCount += 1
	else
		voteEvent.voteNoCount += 1

	foreach( ent in GetPlayerArray() )
		Chat_ServerPrivateMessage( ent, "\n\x1b[32m名为 \x1b[36m"+ voteEvent.voteName +"\x1b[32m 的投票目前票数为\n\x1b[36m同意票 "+ voteEvent.voteYesCount +" / "+ voteEvent.voteNoCount +" 反对票", false, false )
	if( Vote_ShouldEarlyEnd( voteEvent ) )
	{
		EndVoteEvent( voteEvent, eVoteEndCode.complete )
		return false
	}

	foreach( ent in GetPlayerArray() )
		Chat_ServerPrivateMessage( ent, "\x1b[32m输入 \x1b[36m!sy \x1b[32m投同意票\n输入 \x1b[36m!sn \x1b[32m投反对票\n\x1b[35m注意！如果你不投票则会被视为弃权，如果你不想跳过对局请投反对票", false, false )
	return false
}

void function SkipMatch( bool vote )
{
	if( !vote )
	{
		foreach( ent in GetPlayerArray() )
			Chat_ServerPrivateMessage( ent, "\x1b[32m结果：\x1b[36m此对局正常继续，不跳过\n\x1b[35m如果想再次发起跳过对局投票，输入 \x1b[36m!skip \x1b[35m来发起投票", false, false )
		file.onVote = false
		return
	}
	foreach( ent in GetPlayerArray() )
		Chat_ServerPrivateMessage( ent, "\x1b[32m结果：\x1b[31m即将跳过此对局！", false, false )
	wait 3
	SetGameState( eGameState.Postmatch )
}