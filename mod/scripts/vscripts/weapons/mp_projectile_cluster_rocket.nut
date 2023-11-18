
global function OnProjectileCollision_ClusterRocket

void function OnProjectileCollision_ClusterRocket( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	array<string> mods = projectile.ProjectileGetMods()
	if ( mods.contains( "archon_stun_impact" ) )
		return OnProjectileCollision_titanweapon_stun_impact( projectile, pos, normal, hitEnt, hitbox, isCritical )

	float duration = mods.contains( "pas_northstar_cluster" ) ? PAS_NORTHSTAR_CLUSTER_ROCKET_DURATION : CLUSTER_ROCKET_DURATION

	#if SERVER
		float explosionDelay = expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "projectile_explosion_delay" ) )

		ClusterRocket_Detonate( projectile, normal )
		CreateNoSpawnArea( TEAM_INVALID, TEAM_INVALID, pos, ( duration + explosionDelay ) * 0.5 + 1.0, CLUSTER_ROCKET_BURST_RANGE + 100 )
	#endif
}

void function OnProjectileCollision_titanweapon_stun_impact( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
    // force stick on server
	// genericlly a copy of PlantSuperStickyGrenade(), remove hitEnt checks.
	// be sure to keep on date
    if ( hitEnt.IsWorld() )
	{
		projectile.StopPhysics()
	}
	else
	{
		if ( !projectile.IsMarkedForDeletion() && !hitEnt.IsMarkedForDeletion() )
		{
			if ( hitbox > 0 )
				projectile.SetParentWithHitbox( hitEnt, hitbox, true )
			else // Hit a func_brush
				projectile.SetParent( hitEnt )

			// modified: remove player only disappering parent check.
			// breaks vanilla behavior but whatever, this is better for npc combats
			//if ( hitEnt.IsPlayer() )
			//{
				thread HandleDisappearingParent( projectile, hitEnt )
			//}
		}
	}

	// same as mp_weapon_grenade_emp does
#if SERVER
    if ( projectile.GrenadeHasIgnited() )
        return
    //Triggering this on the client triggers an impact effect.
    projectile.GrenadeIgnite()
#endif
}
void function HandleDisappearingParent( entity ent, entity parentEnt )
{
	parentEnt.EndSignal( "OnDeath" )
	ent.EndSignal( "OnDestroy" )

	parentEnt.WaitSignal( "StartPhaseShift" )

	ent.ClearParent()
}
