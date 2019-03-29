local addon, dark_addon = ...
local SB = dark_addon.rotation.spellbooks.warlock

local function combat()
	if target.alive and target.enemy and not player.channeling() then
		
		-- Drain Life
		if modifier.alt and castable(SB.DrainLife) then
			return cast(SB.DrainLife, 'target')
		end
		
		-- Seed of Corruption AoE
		if modifier.shift and castable(SB.SeedOfCorruption) then
			return cast(SB.SeedOfCorruption, 'target')
		end
		
		-- Blood Fury
		--if castable(SB.BloodFury) then
		--	return cast(SB.BloodFury)
		--end
		
		-- Dark Soul Misery
		if -spell(SB.DarksoulMisery) == 0 then
			return cast(SB.DarksoulMisery)
		end
		
		-- Darkglare
		if -target.debuff(SB.CorruptionDebuff) and -target.debuff(SB.Agony) and player.power.soulshards.actual == 0 and -target.debuff(SB.UAdebuffTwo) and toggle('cooldowns', false) and -spell(SB.SummonDarkglare) == 0 and (-target.debuff(SB.SiphonLife) or not talent(2,3)) then
		    return cast(SB.Darkglare)
		end
		-- Agony
		if not target.debuff(SB.Agony) or target.debuff(SB.Agony).remains <= 5.4 then
		  return cast(SB.Agony, 'target')
		end
		
		-- Corruption
		if not target.debuff(SB.CorruptionDebuff) or target.debuff(SB.CorruptionDebuff).remains <= 4.2 then
		  return cast(SB.Corruption, 'target')
		end
		
		-- Siphon Life
		if not target.debuff(SB.SiphonLife) or target.debuff(SB.SiphonLife).remains <= 4.5 and talent(2,3) then
		  return cast(SB.SiphonLife)
		end
		
		-- Haunt
		if -spell(SB.Haunt) == 0 then
			return cast(SB.Haunt, 'target')
		end
		
		-- Phantom Singularity
		if castable(SB.PhantomSing) then
			return cast(SB.PhantomSing, 'target')
		end
		
		-- Unstable Affliction
		if -spell(SB.UnstableAffliction) == 0 and player.power.soulshards.actual > 0 then
			return cast(SB.UnstableAffliction, 'target')
		end
		
		-- Deathbolt
		if -spell(SB.DeathBolt) == 0 then
			return cast(SB.DeathBolt, 'target')
		end
		
		-- Shadow Bolt
		if -spell(SB.ShadowBolt) == 0 then
			return cast(SB.ShadowBolt, 'target')
		end
	end
end

local function resting()

end

dark_addon.rotation.register({
  spec = dark_addon.rotation.classes.warlock.affliction,
  name = 'affliction',
  label = 'Affliction Warlock',
  combat = combat,
  resting = resting,
})

