local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.warlock

local frame = CreateFrame("FRAME")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

SB.ExplosivePotential = 275395
SB.Felstorm = 89753

local impTime, impCast = {}, {}
local alreadyRegistered = false
local impCount = 0
local playerGUID

frame:SetScript(
	"OnEvent",
	function(self, event)
		local gettime = GetTime()
		playerGUID = UnitGUID("player")
		--print(playerGUID)
		local timestamp,
			type,
			hideCaster,
			sourceGUID,
			sourceName,
			sourceFlags,
			sourceRaidFlags,
			destGUID,
			destName,
			destFlags,
			destRaidFlags,
			spellID = CombatLogGetCurrentEventInfo()

		if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
			-- time out any Imps (12 seconds)
			for index, value in pairs(impTime) do
				if (value + 12) < gettime then
					impTime[index] = nil
					impCount = impCount - 1

				--print(("Imp timed out. Count: |cff00ff00%d|r"):format(impCount))
				end
			end

			-- imp imploded
			if (type == "SPELL_CAST_SUCCESS") and sourceGUID == playerGUID and spellID == 196277 then
				table.wipe(impTime)
				table.wipe(impCast)
				impCount = 0
			--print(("Imp imploded. Count: |cff00ff00%d|r"):format(impCount))
			end

			-- imp died
			if (type == "UNIT_DIED") and (sourceName == "Wild Imp" or destName == "Wild Imp") then
				for index, value in pairs(impTime) do
					if destGUID == index then
						impTime[index] = nil
						impCast[index] = nil
						impCount = impCount - 1

					--print(("Imp died. Count: |cff00ff00%d|r"):format(impCount))
					end
				end
			end

			-- imp died from casting (5 casts)
			if (type == "SPELL_CAST_SUCCESS") and sourceName == "Wild Imp" then
				for index, value in pairs(impCast) do
					if sourceGUID == index then
						-- remove cast
						impCast[index] = impCast[index] - 1

						-- wild imp has casted 5 times so it dies
						if impCast[index] == 0 then
							impCast[index] = nil
							impTime[index] = nil
							impCount = impCount - 1

						--print(("Imp casted 5 times and died. Count: |cff00ff00%d|r"):format(impCount))
						end
					end
				end
			end

			-- imp summoned
			if (type == "SPELL_SUMMON") and destName == "Wild Imp" and sourceGUID == playerGUID then
				--print("imp Summoned")
				impTime[destGUID] = gettime
				impCast[destGUID] = 5
				impCount = impCount + 1
			--print(("Imp spawned. Count: |cff00ff00%d|r"):format(impCount))
			end
		end
	end
)

local function combat()
	if target.alive and target.enemy and not player.channeling() then
		-- Blood Fury - only used if playing an Orc
		if castable(SB.BloodFury) and -spell(SB.BloodFury) == 0 then
			return cast(SB.BloodFury)
		end

		-- Health Funnel to heal your pet while in combat
		if pet.exists and castable(SB.HealthFunnel) and player.health.percent >= 50 and pet.health.percent <= 50 then
			return cast(SB.HealthFunnel)
		end

		-- Implosion for AoE and buff uptime (Azerite trait Explosive Potential)
		if
			castable(SB.Implosion) and (not buff(SB.ExplosivePotential).up or buff(SB.ExplosivePotential).remains < 2) and
				impCount >= 3 and
				target.distance <= 40
		 then
			return cast(SB.Implosion, "target")
		end

		-- Call Dreadstalkers with Demonic Calling buff
		if castable(SB.CallDreadStalkers) and player.buff(SB.DemonicCalling) and player.power.soulshards.actual >= 1 then
			return cast(SB.CallDreadStalkers, "target")
		end

		-- Grimoire Felguard
		if castable(SB.GrimoireFelguard) and -spell(SB.GrimoireFelguard) == 0 and player.power.soulshards.actual >= 1 then
			return cast(SB.GrimoireFelguard, "target")
		end

		-- Hand of Gul'dan for Explosive Potential
		if
			castable(SB.HandOfGuldan) and not buff(SB.ExplosivePotential).up and player.power.soulshards.actual >= 3 and
				not spell(SB.HandOfGuldan).lastcast
		 then
			return cast(SB.HandOfGuldan, "target")
		end

		-- Demonic Strength
		if castable(SB.DemonicStrength) and not pet.buff(SB.Felstorm).up and -spell(SB.DemonicStrength) == 0 then
			return cast(SB.DemonicStrength)
		end

		-- Call Dreadstalkers
		if castable(SB.CallDreadStalkers) and player.power.soulshards.actual >= 2 then
			return cast(SB.CallDreadStalkers, "target")
		end

		-- Summon Demonic Tyrant - best to use when you have many demons summoned!
		if modifier.shift and not modifier.alt and castable(SB.SummonDemonicTyrant) and player.power.soulshards.actual >= 2 then
			return cast(SB.SummonDemonicTyrant)
		end

		-- Hand of Gul'dan filler
		if castable(SB.HandOfGuldan) and player.power.soulshards.actual >= 3 and not spell(SB.HandOfGuldan).lastcast then
			return cast(SB.HandOfGuldan, "target")
		end

		-- Demonbolt @ 2+ stacks of Demonic Core
		if castable(SB.Demonbolt) and player.buff(SB.DemonicCore).count >= 2 then
			return cast(SB.Demonbolt, "target")
		end

		-- Nether Portal
		if castable(SB.NetherPortal) and -spell(SB.NetherPortal) == 0 and player.power.soulshards.actual >= 1 then
			return cast(SB.NetherPortal)
		end

		-- Summon Vilefiend
		if castable(SB.SummonVilefiend) and -spell(SB.SummonVilefiend) == 0 and player.power.soulshards.actual >= 1 then
			return cast(SB.SummonVilefiend)
		end
		-- Soul Strike
		if castable(SB.SoulStrike) and -spell(SB.SoulStrike) == 0 then
			return cast(SB.SoulStrike)
		end

		-- Bilescourge Bombers
		if castable(SB.BilescourgeBombers) and -spell(SB.BilescourgeBombers) == 0 and player.power.soulshards.actual >= 2 then
			return cast(SB.BilescourgeBombers, "ground")
		end
		-- Summon Felguard
		if
			not pet.exists and castable(SB.SummonFelguard) and -spell(SB.SummonFelguard) == 0 and not UnitInVehicle("player") and
				not player.spell(SB.SummonFelguard).lastcast
		 then
			return cast(SB.SummonFelguard)
		end

		-- Shadowbolt spam to generate shards
		if castable(SB.ShadowBolt2) then
			return cast(SB.ShadowBolt2, "target")
		end
	end
end

local function resting()
	-- Shadow Bolt to start combat
	--if target.alive and target.enemy and player.alive and not player.channeling() then
	--	if castable(SB.ShadowBolt2) then
	--		return cast(SB.ShadowBolt2, 'target')
	--	end
	--end

	-- Summon Felguard
	if
		not pet.exists and castable(SB.SummonFelguard) and -spell(SB.SummonFelguard) == 0 and not UnitInVehicle("player") and
			not player.spell(SB.SummonFelguard).lastcast
	 then
		return cast(SB.SummonFelguard)
	end
end

dark_addon.rotation.register(
	{
		spec = dark_addon.rotation.classes.warlock.demonology,
		name = "demopal",
		label = "Demonology Warlock by Pal Team",
		combat = combat,
		resting = resting
	}
)
