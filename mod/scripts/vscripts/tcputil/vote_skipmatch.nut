global function Vote_SkipMatch_Init

void function Vote_SkipMatch_Init()
{
	AddCallback_GameStateEnter( eGameState.Playing, OnPlaying )
}

void function OnPlaying()
{
	VoteEventStruct voteEvent
	voteEvent.voteReleaseFunc = Vote_OnRelease
	voteEvent.onVoteFunc = Vote_EasyVoteFunc
	voteEvent.voteEndFunc = Vote_EasyEndFunc
	voteEvent.callbackFunc = SkipMatch
	voteEvent.voteName = "\x1b[94m要跳过此对局吗？"
	voteEvent.endTime = Time() + 60.0
	StartNewVoteEvent( voteEvent )
}

void function Vote_OnRelease( VoteEventStruct voteEvent )
{
	Chat_ServerBroadcast( "\n\x1b[32m系统发起了一个投票！投票ID为 \x1b[36m"+ voteEvent.id +"\x1b[32m\n投票名为 \x1b[36m"+ voteEvent.voteName, false )
	Chat_ServerBroadcast( "\x1b[32m输入 \x1b[36m!vote 投票ID y \x1b[32m投同意票\n输入 \x1b[36m!vote 投票ID n \x1b[32m投反对票", false )
}

void function SkipMatch( bool vote )
{
	if( !vote )
	{
		Chat_ServerBroadcast( "\x1b[32m结果：\x1b[36m此对局正常继续，不跳过，祝大家玩的开心！", false )
		return
	}
	Chat_ServerBroadcast( "\x1b[32m结果：\x1b[36m即将跳过此对局！", false )
	wait 5
	SetGameState( eGameState.Postmatch )
}