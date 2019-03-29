local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.warlock

local function combat()
	if target.alive and target.enemy and not player.channeling() then
		
		-- Summon Darkglare
		if modifier.control and castable(SB.SummonDarkglare) then
			return cast(SB.SummonDarkglare)
		end
		
		-- Drain Life
		if modifier.alt and castable(SB.DrainLife) then
			return cast(SB.DrainLife, 'target')
		end
		
		-- Seed of Corruption AoE
		if modifier.shift and castable(SB.SeedOfCorruption) then
			return cast(SB.SeedOfCorruption, 'target')
		end
		
		-- Blood Fury
		if castable(SB.BloodFury) then
			return cast(SB.BloodFury)
		end
		
		-- Dark Soul Misery
		if castable(SB.DarkSoulMisery) then
			return cast(SB.DarkSoulMisery)
		end
		
		-- Agony
		if castable(SB.Agony) and not -target.debuff(SB.Agony) or target.debuff(SB.Agony).remains <= 3 then
			return cast(SB.Agony, 'target')
		end
		
		-- Corruption
		if castable(SB.Corruption) and not -target.debuff(SB.CorruptionDebuff) or target.debuff(SB.CorruptionDebuff).remains <= 3 then
			return cast(SB.Corruption, 'target')
		end
		
		-- Siphon Life
		if castable(SB.SiphonLife) and not -target.debuff(SB.SiphonLife) or target.debuff(SB.SiphonLife).remains <= 3 then
			return cast(SB.SiphonLife, 'target')
		end
		
		-- Haunt
		if castable(SB.Haunt) and (not -target.debuff(SB.Haunt) or target.debuff(SB.Haunt).remains <= 3) then
			return cast(SB.Haunt, 'target')
		end
		
		-- Phantom Singularity
		if castable(SB.PhantomSingularity) and not -target.debuff(SB.PhantomSingularity) then
			return cast(SB.PhantomSingularity, 'target')
		end
		
		-- Unstable Affliction
		if castable(SB.UnstableAffliction) and player.power.soulshards.actual >= 1 then
			return cast(SB.UnstableAffliction, 'target')
		end
		
		-- Deathbolt after Darkglare
		if castable(SB.Deathbolt) and lastcast(SB.SummonDarkglare) then
			return cast(SB.Deathbolt, 'target')
		end
		
		-- Deathbolt
		if castable(SB.Deathbolt) then
			return cast(SB.Deathbolt, 'target')
		end
		
		-- Shadow Bolt
		if castable(SB.ShadowBolt1) then
			return cast(SB.ShadowBolt1, 'target')
		end
	end
end

local function resting()
	if target.alive and target.enemy and not player.channeling() then
		-- Corruption
		if castable(SB.Corruption) and not -target.debuff(SB.CorruptionDebuff) then
			return cast(SB.Corruption, 'target')
		end
	end
end

dark_addon.rotation.register({
  spec = dark_addon.rotation.classes.warlock.affliction,
  name = 'affpal',
  label = 'Affliction Warlock',
  combat = combat,
  resting = resting,
})

