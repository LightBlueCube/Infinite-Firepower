global function Vote_SkipMatch_Init
global function VoteToSkipMatch

struct{
	bool hasVoted = false
}file

void function Vote_SkipMatch_Init()
{
	AddCallback_GameStateEnter( eGameState.Prematch, VoteToSkipMatch )
}

void function VoteToSkipMatch()
{
	if( file.hasVoted )
		return
	file.hasVoted = true

	VoteEventStruct voteEvent
	voteEvent.voteReleaseFunc = Vote_OnRelease
	voteEvent.onVoteFunc = Vote_EasyVoteFunc
	voteEvent.voteEndFunc = Vote_OnEndFunc
	voteEvent.callbackFunc = SkipMatch
	voteEvent.voteName = "\x1b[94m要跳过此对局吗？"
	voteEvent.endTime = Time() + 60.0
	StartNewVoteEvent( voteEvent )
}

void function Vote_OnRelease( VoteEventStruct voteEvent )
{
	Chat_ServerBroadcast( "\n\x1b[32m系统发起了一个投票！\x1b[32m投票名为 \x1b[36m"+ voteEvent.voteName, false )
	Chat_ServerBroadcast( "\x1b[32m输入 \x1b[36m!vote "+ voteEvent.id +" y \x1b[32m投同意票\n输入 \x1b[36m!vote "+ voteEvent.id +" n \x1b[32m投反对票", false )
}

void function Vote_OnEndFunc( VoteEventStruct voteEvent )
{
	if( voteEvent.endCode == eVoteEndCode.timeout )
		Chat_ServerBroadcast( "\n\x1b[32m名为 \x1b[36m"+ voteEvent.voteName +"\x1b[32m 的投票目前票数为\n\x1b[36m同意票 "+ voteEvent.voteYesCount +" / "+ voteEvent.voteNoCount +" 反对票", false )
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
	Chat_ServerBroadcast( voteEndText, false )

	voteEvent.callbackFunc( vote )
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