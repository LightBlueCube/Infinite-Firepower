global function OnProjectileCollision_weapon_grenade_emp

void function OnProjectileCollision_weapon_grenade_emp( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	if( projectile.ProjectileGetMods().contains( "scp018" ) )
	{
		projectile.SetVelocity( Normalize( projectile.GetVelocity() ) * min( Length( projectile.GetVelocity() ) * 2, 15000 ) )
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