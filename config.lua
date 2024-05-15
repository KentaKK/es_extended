Config = {}
Config.Locale = 'hu'

Config.Accounts = {
	bank = {
		label = _U('account_bank'),
		round = true
	},
	black_money = {
		label = _U('account_black_money'),
		round = true
	},
	money = {
		label = _U('account_money'),
		round = true
	}
}

Config.DefaultSpawn 			= {x = -269.4, y = -955.3, z = 31.2, heading = 205.8}

Config.StartingAccountMoney 	= {bank = 5000}

Config.EnableSocietyPayouts 	= false -- pay from the society account that the player is employed at? Requirement: esx_society
Config.EnableHud            	= false -- enable the default hud? Display current job and accounts (black, bank & cash)
Config.MaxWeight            	= 40   -- the max inventory weight without backpack
Config.PaycheckInterval         = 40 * 60000 -- how often to recieve pay checks in milliseconds
Config.EnableDebug              = false -- Use Debug options?
Config.EnableDefaultInventory   = false -- Display the default Inventory ( F2 )
Config.EnableWantedLevel    	= false -- Use Normal GTA wanted Level?
Config.EnablePVP                = true -- Allow Player to player combat
Config.NativeNotify             = true -- true = old esx notification
Config.DisableVehicleRewards    = true
Config.LegacyFuel               = true -- true = Using LegacyFuel & you want Fuel to Save.
Config.Multichar                = false -- Enable support for esx_multicharacter
Config.Identity                 = false -- Select a characters identity data before they have loaded in (this happens by default with multichar)
Config.DistanceGive 		    = 4.0 -- Max distance when giving items, weapons etc.
Config.OnDuty                   = true -- Default state of the on duty system
Config.NoclipSpeed              = 4.0 -- change it to change the speed in noclip
Config.DisableHealthRegen         = true -- Player will no longer regenerate health
Config.DisableVehicleRewards      = false -- Disables Player Recieving weapons from vehicles
Config.DisableNPCDrops            = true -- stops NPCs from dropping weapons on death
Config.DisableWeaponWheel         = false -- Disables default weapon wheel
Config.DisableAimAssist           = false -- disables AIM assist (mainly on controllers)
Config.RemoveHudCommonents = {
	[1] = true, --WANTED_STARS,
	[2] = true, --WEAPON_ICON
	[3] = true, --CASH
	[4] = true,  --MP_CASH
	[5] = false, --MP_MESSAGE
	[6] = false, --VEHICLE_NAME
	[7] = false,-- AREA_NAME
	[8] = true,-- VEHICLE_CLASS
	[9] = false, --STREET_NAME
	[10] = false, --HELP_TEXT
	[11] = false, --FLOATING_HELP_TEXT_1
	[12] = false, --FLOATING_HELP_TEXT_2
	[13] = true, --CASH_CHANGE
	[14] = false, --RETICLE
	[15] = false, --SUBTITLE_TEXT
	[16] = false, --RADIO_STATIONS
	[17] = true, --SAVING_GAME,
	[18] = false, --GAME_STREAM
	[19] = false, --WEAPON_WHEEL
	[20] = true, --WEAPON_WHEEL_STATS
	[21] = false, --HUD_COMPONENTS
	[22] = false, --HUD_WEAPONS
}

Config.MaxAdminVehicles = false -- admin vehicles spawn with max vehcle settings
Config.CustomAIPlates = 'ESX.A111' -- Custom plates for AI vehicles 
-- Pattern string format
--1 will lead to a random number from 0-9.
--A will lead to a random letter from A-Z.
-- . will lead to a random letter or number, with 50% probability of being either.
--^1 will lead to a literal 1 being emitted.
--^A will lead to a literal A being emitted.
--Any other character will lead to said character being emitted.
-- A string shorter than 8 characters will be padded on the right.
