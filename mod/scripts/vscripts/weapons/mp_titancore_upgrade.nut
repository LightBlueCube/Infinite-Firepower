global function UpgradeCore_Init
global function OnWeaponPrimaryAttack_UpgradeCore
#if SERVER
global function OnWeaponNpcPrimaryAttack_UpgradeCore
#endif
#if CLIENT
global function ServerCallback_VanguardUpgradeMessage
#endif

const LASER_CHAGE_FX_1P = $"P_handlaser_charge"
const LASER_CHAGE_FX_3P = $"P_handlaser_charge"
const FX_SHIELD_GAIN_SCREEN		= $"P_xo_shield_up"

void function UpgradeCore_Init()
{
	RegisterSignal( "OnSustainedDischargeEnd" )
	RegisterSignal( "AmmoCoreStart" )

	PrecacheParticleSystem( FX_SHIELD_GAIN_SCREEN )
	PrecacheParticleSystem( LASER_CHAGE_FX_1P )
	PrecacheParticleSystem( LASER_CHAGE_FX_3P )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_UpgradeCore( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if( weapon.HasMod( "tcp_ammo_core" ) )
	{
		weapon.GetWeaponOwner().Signal( "AmmoCoreStart" )
	}
	OnWeaponPrimaryAttack_UpgradeCore( weapon, attackParams )
	return 1
}
#endif

var function OnWeaponPrimaryAttack_UpgradeCore( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if ( !CheckCoreAvailable( weapon ) )
		return false

	entity owner = weapon.GetWeaponOwner()
	entity soul = owner.GetTitanSoul()
	#if SERVER
		float coreDuration = weapon.GetCoreDuration()
		thread UpgradeCoreThink( weapon, coreDuration )
		int currentUpgradeCount
		if( weapon.HasMod( "tcp_ammo_core" ) )
			currentUpgradeCount = 114514
		else
			currentUpgradeCount = soul.GetTitanSoulNetInt( "upgradeCount" )
		if ( currentUpgradeCount == 3 )
		{
			//Energy Transfer
			entity offhandWeapon = owner.GetOffhandWeapon( OFFHAND_LEFT )
			if ( IsValid( offhandWeapon ) )
			{
				array<string> mods = offhandWeapon.GetMods()
				mods.append( "energy_transfer" )
				offhandWeapon.SetMods( mods )
			}
			if ( owner.IsPlayer() )
			{
				int conversationID = GetConversationIndex( "upgradeTo1" )
				Remote_CallFunction_Replay( owner, "ServerCallback_PlayTitanConversation", conversationID )
				Remote_CallFunction_NonReplay( owner, "ServerCallback_VanguardUpgradeMessage", 3 )
			}
		}
		else if ( currentUpgradeCount == 4 )
		{
			//Missile Racks
			entity offhandWeapon = owner.GetOffhandWeapon( OFFHAND_RIGHT )
			if ( IsValid( offhandWeapon ) )
			{
				array<string> mods = offhandWeapon.GetMods()
				mods.append( "missile_racks" )
				offhandWeapon.SetMods( mods )
			}
			if ( owner.IsPlayer() )
			{
				int conversationID = GetConversationIndex( "upgradeTo1" )
				Remote_CallFunction_Replay( owner, "ServerCallback_PlayTitanConversation", conversationID )
				Remote_CallFunction_NonReplay( owner, "ServerCallback_VanguardUpgradeMessage", 2 )
			}
		}
		else if ( currentUpgradeCount == 5 )
		{
			// Arc Rounds
			array<entity> weapons = GetPrimaryWeapons( owner )
			if ( weapons.len() > 0 )
			{
				entity primaryWeapon = weapons[0]
				if ( IsValid( primaryWeapon ) )
				{
					array<string> mods = primaryWeapon.GetMods()
					mods.append( "arc_rounds" )
					primaryWeapon.SetMods( mods )
					primaryWeapon.SetWeaponPrimaryClipCount( primaryWeapon.GetWeaponPrimaryClipCount() + 10 )
				}
			}
			if ( owner.IsPlayer() )
			{
				int conversationID = GetConversationIndex( "upgradeTo1" )
				Remote_CallFunction_Replay( owner, "ServerCallback_PlayTitanConversation", conversationID )
				Remote_CallFunction_NonReplay( owner, "ServerCallback_VanguardUpgradeMessage", 1 )
			}
		}
		else if ( currentUpgradeCount == 6 )
		{
			//Energy Field
			entity offhandWeapon = owner.GetOffhandWeapon( OFFHAND_LEFT )
			if ( IsValid( offhandWeapon ) )
			{
				array<string> mods = offhandWeapon.GetMods()
				if ( mods.contains( "energy_transfer" ) )
				{
					array<string> mods = offhandWeapon.GetMods()
					mods.fastremovebyvalue( "energy_transfer" )
					mods.append( "energy_field_energy_transfer" )
					offhandWeapon.SetMods( mods )
				}
				else
				{
					array<string> mods = offhandWeapon.GetMods()
					mods.append( "energy_field" )
					offhandWeapon.SetMods( mods )
				}
			}
			if ( owner.IsPlayer() )
			{
				int conversationID = GetConversationIndex( "upgradeTo2" )
				Remote_CallFunction_Replay( owner, "ServerCallback_PlayTitanConversation", conversationID )
				Remote_CallFunction_NonReplay( owner, "ServerCallback_VanguardUpgradeMessage", 6 )
			}
		}
		else if ( currentUpgradeCount == 7 )
		{
			// Rapid Rearm
			entity offhandWeapon = owner.GetOffhandWeapon( OFFHAND_ANTIRODEO )
			if ( IsValid( offhandWeapon ) )
			{
				array<string> mods = offhandWeapon.GetMods()
				mods.append( "rapid_rearm" )
				offhandWeapon.SetMods( mods )
			}
			array<entity> weapons = GetPrimaryWeapons( owner )
			if ( weapons.len() > 0 )
			{
				entity primaryWeapon = weapons[0]
				if ( IsValid( primaryWeapon ) )
				{
					array<string> mods = primaryWeapon.GetMods()
					mods.append( "rapid_reload" )
					primaryWeapon.SetMods( mods )
				}
			}
			if ( owner.IsPlayer() )
			{
				int conversationID = GetConversationIndex( "upgradeTo2" )
				Remote_CallFunction_Replay( owner, "ServerCallback_PlayTitanConversation", conversationID )
				Remote_CallFunction_NonReplay( owner, "ServerCallback_VanguardUpgradeMessage", 4 )
			}
		}
		else if ( currentUpgradeCount == 8 )
		{
			//Maelstrom
			entity offhandWeapon = owner.GetOffhandWeapon( OFFHAND_INVENTORY )
			if ( IsValid( offhandWeapon ) )
			{
				array<string> mods = offhandWeapon.GetMods()
				mods.append( "maelstrom" )
				offhandWeapon.SetMods( mods )
			}
			if ( owner.IsPlayer() )
			{
				int conversationID = GetConversationIndex( "upgradeTo2" )
				Remote_CallFunction_Replay( owner, "ServerCallback_PlayTitanConversation", conversationID )
				Remote_CallFunction_NonReplay( owner, "ServerCallback_VanguardUpgradeMessage", 5 )
			}
		}
		else if ( currentUpgradeCount == 9 )
		{
			// Multi-Target Missiles
			if ( owner.IsPlayer() )
			{
				array<string> conversations = [ "upgradeTo3", "upgradeToFin" ]
				int conversationID = GetConversationIndex( conversations.getrandom() )
				Remote_CallFunction_Replay( owner, "ServerCallback_PlayTitanConversation", conversationID )
				Remote_CallFunction_NonReplay( owner, "ServerCallback_VanguardUpgradeMessage", 7 )
			}

			entity ordnance = owner.GetOffhandWeapon( OFFHAND_RIGHT )
			array<string> mods
			if ( ordnance.HasMod( "missile_racks") )
				mods = [ "upgradeCore_MissileRack_Vanguard" ]
			else
				mods = [ "upgradeCore_Vanguard" ]

			if ( ordnance.HasMod( "fd_balance" ) )
				mods.append( "fd_balance" )

			float ammoFrac = float( ordnance.GetWeaponPrimaryClipCount() ) / float( ordnance.GetWeaponPrimaryClipCountMax() )
			owner.TakeWeaponNow( ordnance.GetWeaponClassName() )
			owner.GiveOffhandWeapon( "mp_titanweapon_shoulder_rockets", OFFHAND_RIGHT, mods )
			ordnance = owner.GetOffhandWeapon( OFFHAND_RIGHT )
			ordnance.SetWeaponChargeFractionForced( 1 - ammoFrac )
		}
		else if ( currentUpgradeCount == 10 )
		{
			//Superior Chassis
			if ( owner.IsPlayer() )
			{
				array<string> conversations = [ "upgradeTo3", "upgradeToFin" ]
				int conversationID = GetConversationIndex( conversations.getrandom() )
				Remote_CallFunction_Replay( owner, "ServerCallback_PlayTitanConversation", conversationID )
				Remote_CallFunction_NonReplay( owner, "ServerCallback_VanguardUpgradeMessage", 8 )

				if ( !GetDoomedState( owner ) )
				{
					int missingHealth = owner.GetMaxHealth() - owner.GetHealth()
					array<string> settingMods = owner.GetPlayerSettingsMods()
					settingMods.append( "core_health_upgrade" )
					owner.SetPlayerSettingsWithMods( owner.GetPlayerSettings(), settingMods )
					owner.SetHealth( max( owner.GetMaxHealth() - missingHealth, VANGUARD_CORE8_HEALTH_AMOUNT ) )

					//Hacky Hack - Append core_health_upgrade to setFileMods so that we have a way to check that this upgrade is active.
					soul.soul.titanLoadout.setFileMods.append( "core_health_upgrade" )
				}
				else
				{
					owner.SetHealth( owner.GetMaxHealth() )
				}
			}
			else
			{
				if ( !GetDoomedState( owner ) )
		  		{
					owner.SetMaxHealth( owner.GetMaxHealth() + VANGUARD_CORE8_HEALTH_AMOUNT )
					owner.SetHealth( owner.GetHealth() + VANGUARD_CORE8_HEALTH_AMOUNT )
				}
			}
			entity soul = owner.GetTitanSoul()
			soul.SetPreventCrits( true )
		}
		else if ( currentUpgradeCount == 11 )
		{
			//XO-16 Battle Rifle
			array<entity> weapons = GetPrimaryWeapons( owner )
			if ( weapons.len() > 0 )
			{
				entity primaryWeapon = weapons[0]
				if ( IsValid( primaryWeapon ) )
				{
					if ( primaryWeapon.HasMod( "arc_rounds" ) )
					{
						primaryWeapon.RemoveMod( "arc_rounds" )
						array<string> mods = primaryWeapon.GetMods()
						mods.append( "arc_rounds_with_battle_rifle" )
						primaryWeapon.SetMods( mods )
					}
					else
					{
						array<string> mods = primaryWeapon.GetMods()
						mods.append( "battle_rifle" )
						mods.append( "battle_rifle_icon" )
						primaryWeapon.SetMods( mods )
					}
				}
			}

			if ( owner.IsPlayer() )
			{
				array<string> conversations = [ "upgradeTo3", "upgradeToFin" ]
				int conversationID = GetConversationIndex( conversations.getrandom() )
				Remote_CallFunction_Replay( owner, "ServerCallback_PlayTitanConversation", conversationID )
				Remote_CallFunction_NonReplay( owner, "ServerCallback_VanguardUpgradeMessage", 9 )
			}
		}
		else
		{
			if ( owner.IsPlayer() )
			{
				int conversationID = GetConversationIndex( "upgradeShieldReplenish" )
				Remote_CallFunction_Replay( owner, "ServerCallback_PlayTitanConversation", conversationID )
			}
		}
		if( weapon.HasMod( "tcp_ammo_core" ) )
		{
			if( IsValid( owner.GetMainWeapons()[0] ) )
			{
				owner.GetMainWeapons()[0].AddMod( "tcp_ammo_core" )
				owner.GetMainWeapons()[0].SetWeaponPrimaryClipCount( min( owner.GetWeaponAmmoLoaded( owner.GetMainWeapons()[0] ) + 150, 1000 ) )
			}
		}
		if( !weapon.HasMod( "tcp_ammo_core" ) )
		{
			soul.SetTitanSoulNetInt( "upgradeCount", currentUpgradeCount + 1 )
			int statesIndex = owner.FindBodyGroup( "states" )
			owner.SetBodygroup( statesIndex, 1 )
		}
	#endif

	#if CLIENT
		if ( owner.IsPlayer() )
		{
			entity cockpit = owner.GetCockpit()
			if ( IsValid( cockpit ) )
				StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( FX_SHIELD_GAIN_SCREEN	), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		}
	#endif
	OnAbilityCharge_TitanCore( weapon )
	OnAbilityStart_TitanCore( weapon )

	return 1
}

#if SERVER
void function UpgradeCoreThink( entity weapon, float coreDuration )
{
	weapon.EndSignal( "OnDestroy" )
	entity owner = weapon.GetWeaponOwner()
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDeath" )
	owner.EndSignal( "DisembarkingTitan" )
	owner.EndSignal( "TitanEjectionStarted" )

	EmitSoundOnEntityOnlyToPlayer( owner, owner, "Titan_Monarch_Smart_Core_Activated_1P" )
	EmitSoundOnEntityOnlyToPlayer( owner, owner, "Titan_Monarch_Smart_Core_ActiveLoop_1P" )
	EmitSoundOnEntityExceptToPlayer( owner, owner, "Titan_Monarch_Smart_Core_Activated_3P" )
	entity soul = owner.GetTitanSoul()
	if( !weapon.HasMod( "tcp_ammo_core" ) )
		soul.SetShieldHealth( soul.GetShieldHealthMax() )
	if( weapon.HasMod( "tcp_ammo_core" ) )
		thread PressReloadCheck( owner, weapon )

	OnThreadEnd(
	function() : ( weapon, owner, soul )
		{
			if ( IsValid( owner ) )
			{
				StopSoundOnEntity( owner, "Titan_Monarch_Smart_Core_ActiveLoop_1P" )
				//EmitSoundOnEntityOnlyToPlayer( owner, owner, "Titan_Monarch_Smart_Core_Activated_1P" )
			}

			if ( IsValid( weapon ) )
			{
				OnAbilityChargeEnd_TitanCore( weapon )
				OnAbilityEnd_TitanCore( weapon )
			}

			if ( IsValid( soul ) )
			{
				CleanupCoreEffect( soul )
			}
		}
	)
	wait coreDuration
}
#endif

void function PressReloadCheck( entity owner, entity weapon )
{
	weapon.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDeath" )
	owner.EndSignal( "DisembarkingTitan" )
	owner.EndSignal( "TitanEjectionStarted" )
	owner.EndSignal( "AmmoCoreStart" )

	OnThreadEnd(
		function() : ( weapon, owner )
		{
			if( !IsValid( owner ) )
				return
			if( owner.GetMainWeapons().len() == 0 )
				return
			if( !owner.IsTitan() )
				return
			if( !IsValid( owner.GetMainWeapons()[0] ) )
				return
			if( owner.GetMainWeapons()[0].GetWeaponClassName() != "mp_titanweapon_xo16_shorty" )
				return
			owner.GetMainWeapons()[0].SetWeaponPrimaryClipCount( 0 )
			owner.GetMainWeapons()[0].SetWeaponPrimaryAmmoCount( 1140 )
			owner.GetMainWeapons()[0].RemoveMod( "tcp_ammo_core" )
		}
	)

	owner.GetMainWeapons()[0].SetWeaponPrimaryAmmoCount( 0 )
	float clip = min( owner.GetWeaponAmmoLoaded( owner.GetMainWeapons()[0] ) + 150, 1000 )
	while( true )
	{
		WaitFrame()
		if( !IsValid( owner ) )
			return
		if( owner.GetMainWeapons().len() == 0 )
			return
		if( IsValid( owner.GetMainWeapons()[0] ) )
		{
			if( owner.GetWeaponAmmoLoaded( owner.GetMainWeapons()[0] ) < 1 )
			{
				return
			}
			if( owner.GetWeaponAmmoLoaded( owner.GetMainWeapons()[0] ) > 1000  )
			{
				owner.GetMainWeapons()[0].SetWeaponPrimaryClipCount( clip )
			}
		}
	}
}


#if CLIENT
void function ServerCallback_VanguardUpgradeMessage( int upgradeID )
{
	switch ( upgradeID )
	{
		case 1:
			AnnouncementMessageSweep( GetLocalClientPlayer(), Localize( "#GEAR_VANGUARD_CORE1" ), Localize( "#GEAR_VANGUARD_CORE1_UPGRADEDESC" ), <255, 135, 10> )
			break
		case 2:
			AnnouncementMessageSweep( GetLocalClientPlayer(), Localize( "#GEAR_VANGUARD_CORE2" ), Localize( "#GEAR_VANGUARD_CORE2_UPGRADEDESC" ), <255, 135, 10> )
			break
		case 3:
			AnnouncementMessageSweep( GetLocalClientPlayer(), Localize( "#GEAR_VANGUARD_CORE3" ), Localize( "#GEAR_VANGUARD_CORE3_UPGRADEDESC" ), <255, 135, 10> )
			break
		case 4:
			AnnouncementMessageSweep( GetLocalClientPlayer(), Localize( "#GEAR_VANGUARD_CORE4" ), Localize( "#GEAR_VANGUARD_CORE4_UPGRADEDESC" ), <255, 135, 10> )
			break
		case 5:
			AnnouncementMessageSweep( GetLocalClientPlayer(), Localize( "#GEAR_VANGUARD_CORE5" ), Localize( "#GEAR_VANGUARD_CORE5_UPGRADEDESC" ), <255, 135, 10> )
			break
		case 6:
			AnnouncementMessageSweep( GetLocalClientPlayer(), Localize( "#GEAR_VANGUARD_CORE6" ), Localize( "#GEAR_VANGUARD_CORE6_UPGRADEDESC" ), <255, 135, 10> )
			break
		case 7:
			AnnouncementMessageSweep( GetLocalClientPlayer(), Localize( "#GEAR_VANGUARD_CORE7" ), Localize( "#GEAR_VANGUARD_CORE7_UPGRADEDESC" ), <255, 135, 10> )
			break
		case 8:
			AnnouncementMessageSweep( GetLocalClientPlayer(), Localize( "#GEAR_VANGUARD_CORE8" ), Localize( "#GEAR_VANGUARD_CORE8_UPGRADEDESC" ), <255, 135, 10> )
			break
		case 9:
			AnnouncementMessageSweep( GetLocalClientPlayer(), Localize( "#GEAR_VANGUARD_CORE9" ), Localize( "#GEAR_VANGUARD_CORE9_UPGRADEDESC" ), <255, 135, 10> )
			break
	}
}
#endif