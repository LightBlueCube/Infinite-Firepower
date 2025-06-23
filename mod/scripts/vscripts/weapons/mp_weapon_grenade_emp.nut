global function OnProjectileCollision_weapon_grenade_emp

void function OnProjectileCollision_weapon_grenade_emp( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	if( projectile.ProjectileGetMods().contains( "scp018" ) )
	{
		thread SCP018VelocityControl(projectile)
		projectile.SetVelocity( Normalize( projectile.GetVelocity() ) * min( Length( projectile.GetVelocity() ) * 1.5, 15000 ) )
		return
	}

	entity player = projectile.GetOwner()
	if ( hitEnt == player )
		return

	table collisionParams =
	{
		pos = pos,
		normal = normal,
		hitEnt = hitEnt,
		hitbox = hitbox
	}

	if ( IsSingleplayer() && ( player && !player.IsPlayer() ) )
		collisionParams.hitEnt = GetEntByIndex( 0 )

	bool result = PlantStickyEntity( projectile, collisionParams )

	if ( projectile.GrenadeHasIgnited() )
		return

	//Triggering this on the client triggers an impact effect.
	#if SERVER
	projectile.GrenadeIgnite()
	#endif
}

void function SCP018VelocityControl( entity projectile )
{
	projectile.EndSignal( "OnDestroy" )
	wait 0.2

	float target_dist = 1145141919
	entity target
	foreach( entAry in [ GetNPCArray(), GetPlayerArray() ] )
	{
		foreach( ent in entAry )
		{
			if( ent.GetTeam() == projectile.GetTeam() )
				continue
			float dist = Distance( ent.GetOrigin(), projectile.GetOrigin() )
			if( dist < target_dist )
				target = ent
				target_dist = dist
		}
	}
	if( !IsValid( target ) )
		return

	vector basevel = Normalize( projectile.GetVelocity() )
	vector targetvel = Normalize( target.GetOrigin() - projectile.GetOrigin() )
	float scale = 1.0
	if( !target.IsPlayer() )
		scale = 2.0
	vector finalvel = Normalize( basevel + ( targetvel * scale ) )

	projectile.SetVelocity( finalvel * min( Length( projectile.GetVelocity() ), 15000 ) )

}
