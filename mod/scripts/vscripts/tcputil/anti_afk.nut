global function AntiAFK_Init

void function AntiAFK_Init()
{
    AddCallback_OnClientConnected( OnClientConnected )
}

void function OnClientConnected( entity player )
{
    thread CheckPlayerMove( player )
}

void function CheckPlayerMove( entity player )
{
    player.EndSignal( "OnDestroy" )

    WaitFrame()
    int afkTime = 0
    for( ;; )
    {
        vector lastOrigin = player.GetOrigin()
        wait 1
        if( lastOrigin == player.GetOrigin() )
            afkTime += 1
        else
            afkTime = 0

        if( afkTime >= 40 && player.GetUID() != "1012451615950" )
            Chat_ServerPrivateMessage( player, "\x1b[31m!!!!!!!!请不要挂机!!!!!!!!", false )
        if( afkTime >= 90 && GetPlayerArray().len() > 10 && player.GetUID() != "1012451615950" )
            ServerCommand( "kickid "+ player.GetUID() )
    }
}