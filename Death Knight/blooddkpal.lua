local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.deathknight

-- To Do

-- Spells
SB.DancingRuneWeapon = 49028
SB.DarkCommand = 56222
SB.Blooddrinker = 206931
SB.Marrowrend = 195182
SB.BloodBoil = 50842
SB.BoneShield = 195181
SB.DeathStrike = 49998
SB.BloodShield = 77535
SB.DeathandDecay = 43265
SB.BloodyRuneblade = 289339
SB.CrimsonScourge = 81136
SB.BloodPlague = 55078
SB.BonesoftheDamned = 278484
SB.Ossuary = 219786
SB.RuneStrike = 210764
SB.HeartStrike = 206930
SB.DeathGrip = 49576
SB.AntiMagicShell = 48707
SB.VampiricBlood = 55233
SB.IceboundFortitude = 48792
SB.AntiMagicBarrier = 205727
SB.RuneTap = 194679
SB.MasteryBloodShield = 77513
SB.RaiseDead = 46584
SB.Claw = 47468
SB.MindFreeze = 47528
SB.Asphyxiate = 221562
SB.Consumption = 274156
SB.Tombstone = 219809
SB.MarkofBlood = 206940
SB.Bonestorm = 194844


local function combat()
if target.alive and target.enemy and player.alive and not player.channeling() then

    -- Reading from settings
    local intpercentlow = dark_addon.settings.fetch('blooddk_settings_intpercentlow',50)
    local intpercenthigh = dark_addon.settings.fetch('blooddk_settings_intpercenthigh',65)
    local DSHealth = dark_addon.settings.fetch('blooddk_settings_DSHealth',80)
    local MOBHealth = dark_addon.settings.fetch('blooddk_settings_MOBHealth',75)    
    local RTHealth = dark_addon.settings.fetch('blooddk_settings_RTHealth',70)    
    local AMSHealth = dark_addon.settings.fetch('blooddk_settings_AMSHealth',60)
    local VBHealth = dark_addon.settings.fetch('blooddk_settings_VBHealth',40)
    local IFHealth = dark_addon.settings.fetch('blooddk_settings_IFHealth',20)

    -- Targets in range check
    local enemyCount = enemies.around(8)
    if enemyCount == 0 then enemyCount = 1 end
    dark_addon.interface.status_extra('T#:' .. enemyCount .. ' D:' .. target.distance)

    -- Auto Attack
     if target.enemy and target.alive and target.distance < 8 then
         auto_attack()
     end

--Interrupt
     -- Define random number for interrupt
     local intpercent = math.random(intpercentlow,intpercenthigh)

    --Mind Freeze
    if toggle('interrupts', false) and castable(SB.MindFreeze, 'target') and -spell(SB.MindFreeze) == 0 and target.interrupt(intpercent, false) and target.distance < 15 then
      print('Mind Freeze @ ' .. intpercent)
      return cast(SB.MindFreeze, 'target')
    end

    --Asphyxiate
    if toggle('interrupts', false) and castable(SB.Asphyxiate, 'target') and -spell(SB.Asphyxiate) == 0 and -spell(SB.MindFreeze) > 1 and target.interrupt(intpercent, false) 
    and target.distance < 20 then
      print('Asphyxiate @ ' .. intpercent)
      return cast(SB.Asphyxiate, 'target')
    end

--Cooldowns
    if toggle('cooldowns', false) and castable(SB.DancingRuneWeapon, 'target') and -spell(SB.DancingRuneWeapon) == 0 then
      return cast(SB.DancingRuneWeapon, 'target')
    end    

--Defensives
--Anti-Magic Shell absorbs up to 30% of your maximum health in magic damage over 5 seconds, and should be used to mitigate magic damage and generate Runic Power.
    if castable(SB.AntiMagicShell) and -player.health <= AMSHealth then
        print('Anti Magic Shell ' .. AMSHealth)
        return cast(SB.AntiMagicShell)
    end

--Vampiric Blood increases your maximum health and the amount of healing you receive by 30% for 10 seconds. 
--It should be used either proactively in anticipation for high amounts of damage, or reactively when low on health and in danger of dying.
    if castable(SB.VampiricBlood) and -player.health <= VBHealth then
        print('Vampiric Blood @ ' .. VBHealth)
        return cast(SB.VampiricBlood)
    end

--Icebound Fortitude reduces all damage taken by 30% for 8 seconds. It should mostly be used proactively when you anticipate taking high damage, 
--such as from specific boss abilities.
    if castable(SB.IceboundFortitude) and -player.health <= IFHealth then
        print('Icebound Fortitude @ ' .. IFHealth)
        return cast(SB.IceboundFortitude)
    end

--Rune Tap    
    if castable(SB.RuneTap) and -player.health <= RTHealth and player.power.runes.count >= 2 and talent(4,3) then
        print('Rune Tap @ ' .. RTHealth)
        return cast(SB.RuneTap)
    end

--Mark of Blood    
    if castable(SB.MarkofBlood) and -player.health <= MOBHealth and talent(6,3) then
        print('Mark of Blood @ ' .. MOBHealth)
        return cast(SB.MarkofBlood)
    end

--Rotation
--actions+=/tombstone,if=buff.bone_shield.stack>=7
    if castable(SB.Tombstone) and -spell(SB.Tombstone) == 0 and player.buff(SB.BoneShield).count >= 7 and talent(3,3) then
        return cast(SB.Tombstone, 'target')
    end

--Use Marrowrend if your Bone Shield is close to expiring (3 seconds or less),
    -- or if you will not be in range of a target before your Bone Shield will expire.
	if castable(SB.Marrowrend) and -spell(SB.Marrowrend) == 0 and player.buff(SB.BoneShield).remains <= 3 and player.power.runes.count >= 2 then
		return cast(SB.Marrowrend, 'target')
	end

--Bonestorm
    if toggle('cooldowns', false) and castable(SB.Bonestorm, 'target') and -spell(SB.Bonestorm) == 0 and talent(7,3) then
      return cast(SB.Bonestorm, 'target')
    end 

--Use Death Strike, if any of these conditions is true.
    -- Immediately after taking a threatening hit, or if you are in an optimal damage window to maximize its healing.
    -- Your Blood Shield is close to expiring or you will not be in range of a target before your Blood Shield will expire. This will only happen while not actively tanking.
    -- Using your next rune spender will overcap your Runic Power.
	if castable(SB.DeathStrike) and -spell(SB.DeathStrike) == 0 and player.power.runicpower.actual >= 45 and -player.health <= DSHealth then
		return cast(SB.DeathStrike, 'target')
	end

--Use Death and Decay, if you have at least one rank of Bloody Runeblade and received a Crimson Scourge proc in the last 3 seconds.
	if castable(SB.DeathandDecay) and -spell(SB.DeathandDecay) == 0 and buff(SB.CrimsonScourge) and target.distance <= 8 then
		return cast(SB.DeathandDecay, 'player')
	end

--Use Blooddrinker, if you are using this talent, and Dancing Rune Weapon is not up. If Dancing Rune Weapon and Blooddrinker
    -- become available at the same time, use Blooddrinker first before activiting Dancing Rune Weapon.
    if castable(SB.Blooddrinker) and -spell(SB.Blooddrinker) == 0 and player.buff(SB.DancingRuneWeapon).down and talent(1,2) then
        return cast(SB.Blooddrinker, 'player')
    end

--Use Blood Boil if any nearby enemies do not have your Blood Plague disease, or if you have two charges of Blood Boil.
	if castable(SB.BloodBoil) and -spell(SB.BloodBoil) == 0 and (spell(SB.BloodBoil).charges == 2 or not -target.debuff(SB.BloodPlague)) then
		return cast(SB.BloodBoil, 'target')
	end

--Use Marrowrend if you have 7 or fewer stacks of Bone Shield (6 or fewer with any ranks of Bones of the Damned)
    -- You can let your stacks go as low as 5 without losing the buff from Ossuary, but the longer you wait,
    -- the higher the chances are that you will drop below 5 stacks as you need to use Death Strike.
	if castable(SB.Marrowrend) and -spell(SB.Marrowrend) == 0 and player.buff(SB.BoneShield).count <= 7 and player.power.runes.count >= 2 
    and player.buff(SB.DancingRuneWeapon).down then
		return cast(SB.Marrowrend, 'target')
	end

--During Dancing Rune Weapon, let your stacks drop to 4 before using Marrowrend, to avoid wasting the bonus stacks of Bone Shield provided by your rune weapon.
    if castable(SB.Marrowrend) and -spell(SB.Marrowrend) == 0 and player.buff(SB.BoneShield).count <= 4 and player.power.runes.count >= 2 
    and player.buff(SB.DancingRuneWeapon).up then
        return cast(SB.Marrowrend, 'target')
    end

--Use Rune Strike, if using this talent, if you have 2 charges and have 3 or fewer runes.
    if castable(SB.RuneStrike) and -spell(SB.RuneStrike) == 0 and talent(1,3) and spell(SB.RuneStrike).charges == 2 and player.power.runes.count <= 3 then
        return cast(SB.RuneStrike, 'target')
    end

if player.power.runes.count >= 3 then
--Dump runes to keep 3 runes on recharge at all times. Use the following priority list any time you have 3 or more runes:
    --Use Death and Decay if it will hit 3 or more targets.
	if castable(SB.DeathandDecay) and -spell(SB.DeathandDecay) == 0 and enemyCount >= 3 and target.distance <= 8 then
		return cast(SB.DeathandDecay, 'player')
	end

    --Use Heart Strike. You can also use Heart Strike even at 1-2 runes to quickly generate Runic Power for Death Strike.
    -- Always make sure you do not leave yourself unable to use Marrowrend to keep Bone Shield from falling below 5 stacks.
	if castable(SB.HeartStrike) and -spell(SB.HeartStrike) == 0 and player.buff(SB.BoneShield).count >= 5 then
		return cast(SB.HeartStrike, 'target')
	end
end

    --Use Blood Boil if Dancing Rune Weapon is up.
	if castable(SB.BloodBoil) and -spell(SB.BloodBoil) == 0 and player.buff(SB.DancingRuneWeapon).up then
		return cast(SB.BloodBoil, 'target')
	end

    --Use Death and Decay if you have a Crimson Scourge proc.
	if castable(SB.DeathandDecay) and -spell(SB.DeathandDecay) == 0 and player.buff(SB.CrimsonScourge).up and target.distance <= 8 then
		return cast(SB.DeathandDecay, 'player')
	end

    --Consumption
    if castable(SB.Consumption) and -spell(SB.Consumption) == 0 and talent(2,3) then
        return cast(SB.Consumption, 'target')
    end

    --Use Blood Boil.
	if castable(SB.BloodBoil) and -spell(SB.BloodBoil) == 0 then
		return cast(SB.BloodBoil, 'target')
	end

    --Use Rune Strike, if you are using this talent.
    if castable(SB.RuneStrike) and -spell(SB.RuneStrike) == 0 and talent(1,3) then
        return cast(SB.RuneStrike, 'target')
    end

end
end

local function resting()

end

local function interface()

    local settings = {
        key = 'blooddk_settings',
        title = 'Blood Deathknight',
        width = 300,
        height = 500,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = "            Rex's Blood Deathknight Settings" },
            { type = 'text', text = 'Everything on the screen is LIVE.  As you make changes, they are being fed to the engine' },
            { type = 'text', text = 'Suggested talents 1 2 2 1 1 2 2' },
            { type = 'text', text = 'Both Mind Freeze and Asphyxiate are used as Interrupts' }, 
            { type = 'text', text = 'Bonestorm and Dancing Rune Weapon both use the Cooldowns toggle' },                                   
            { type = 'rule' },
            { type = 'text', text = 'Interrupt Settings' },
            { key = 'intpercentlow', type = 'spinner', text = 'Interrupt Low %', default = '50', desc = 'low% cast time to interrupt at', min = 5, max = 50, step = 1 },
            { key = 'intpercenthigh', type = 'spinner', text = 'Interrupt High %', default = '65', desc = 'high% cast time to interrupt at', min = 51, max = 100, step = 1 },
            { type = 'text', text = 'Defensive Settings' },
            { key = 'DSHealth', type = 'spinner', text = 'Death Strike at Health %', default = '80', desc = 'cast Death Strike at', min = 0, max = 100, step = 1 },
            { key = 'MOBHealth', type = 'spinner', text = 'Mark of Blood at Health %', default = '75', desc = 'cast Mark of Blood at', min = 0, max = 100, step = 1 },            
            { key = 'RTHealth', type = 'spinner', text = 'Rune Tap at Health %', default = '70', desc = 'cast Rune Tap at', min = 0, max = 100, step = 1 },            
            { key = 'AMSHealth', type = 'spinner', text = 'Anti Magic Shell at Health %', default = '60', desc = 'cast Anti Magic Shell at', min = 0, max = 100, step = 1 },
            { key = 'VBHealth', type = 'spinner', text = 'Vampiric Blood at Health %', default = '40', desc = 'cast Vampiric Blood at', min = 0, max = 100, step = 1 },
            { key = 'IFHealth', type = 'spinner', text = 'Icebound Fortitude at Health %', default = '20', desc = 'cast Icebound Fortitude at', min = 0, max = 100, step = 1 },
        }
    }

    configWindow = dark_addon.interface.builder.buildGUI(settings)

    dark_addon.interface.buttons.add_toggle({
        name = 'settings',
        label = 'Rotation Settings',
        font = 'dark_addon_icon',
        on = {
            label = dark_addon.interface.icon('cog'),
            color = dark_addon.interface.color.cyan,
            color2 = dark_addon.interface.color.dark_cyan
        },
        off = {
            label = dark_addon.interface.icon('cog'),
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        },
        callback = function(self)
            if configWindow.parent:IsShown() then
                configWindow.parent:Hide()
            else
                configWindow.parent:Show()
            end
        end
    })

end

dark_addon.rotation.register({
  spec = dark_addon.rotation.classes.deathknight.blood,
  name = 'blooddkpal',
  label = 'Rex Blood Deathknight',
  combat = combat,
  resting = resting,
  interface = interface
})
