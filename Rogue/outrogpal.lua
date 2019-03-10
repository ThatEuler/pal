local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.rogue

-- To Do

-- Spells

SB.Vanish = 1856
SB.Ambush = 8676
SB.CheapShot = 1833
SB.PreyontheWeak = 131511
SB.KillingSpree = 51690
SB.BladeRush = 271877
SB.BladeFlurry = 13877
SB.RolltheBones = 193316
SB.GhostlyStrike = 196937
SB.AdrenalineRush = 13750
SB.MarkedforDeath = 137619
SB.BetweentheEyes = 199804
SB.RuthlessPrecision = 193357
SB.AceUpYourSleeve = 278676
SB.Deadshot = 272935
SB.Dispatch = 2098
SB.PistolShot = 185763
SB.Opportunity = 195627
SB.SinisterStrike = 193315
SB.SnakeEyes = 275846
SB.SliceandDice = 5171
SB.DeeperStratagem = 193531
SB.TrueBearing = 193359
SB.SkullandCrossbones = 199603
SB.GrandMelee = 193358
SB.Broadside = 193356
SB.BuriedTreasure = 199600
SB.LoadedDice = 256170
SB.Vigor = 14983
SB.CombatPotency = 61329
SB.RestlessBlades = 79096
SB.Bloodlust = 2825
SB.Heroism = 32182
SB.TimeWarp = 80353
SB.Ruthlessness = 14161
SB.Sprint = 2983
SB.GrapplingHook = 195457
SB.Feint = 1966
SB.Elusiveness = 79008
SB.CloakofShadows = 31224
SB.CheatDeath = 31230
SB.CrimsonVial = 185311
SB.Riposte = 199754
SB.Stealth = 1784
SB.Kick = 1766
SB.Gouge = 1776
SB.Blind = 2094

local function combat()
    if target.alive and target.enemy and player.alive and not player.channeling() then

    --Reading from settings
    local intpercentlow = dark_addon.settings.fetch('outrog_settings_intpercentlow',50)
    local intpercenthigh = dark_addon.settings.fetch('outrog_settings_intpercenthigh',65)
    local CVHealth = dark_addon.settings.fetch('outrog_settings_CVHealth',30)
    local FHealth = dark_addon.settings.fetch('outrog_settings_FHealth',40)
    local RHealth = dark_addon.settings.fetch('outrog_settings_RHealth',60)    
    local COSHealth = dark_addon.settings.fetch('outrog_settings_COSHealth',50)

    --Roll the Bones Buff Count
    local rtbcount, rpcount, gmcount, bscount, skcount, btcount, tbcount = 0, 0, 0, 0, 0, 0, 0
    if player.buff(SB.RuthlessPrecision).up then rpcount = 1 else rpcount = 0 end
    if player.buff(SB.GrandMelee).up then gmcount = 1 else gmcount = 0 end
    if player.buff(SB.Broadside).up then bscount = 1 else bscount = 0 end
    if player.buff(SB.SkullandCrossbones).up then skcount = 1 else skcount = 0 end
    if player.buff(SB.BuriedTreasure).up then btcount = 1 else btcount = 0 end
    if player.buff(SB.TrueBearing).up then tbcount = 1 else tbcount = 0 end
    rtbcount = rpcount + gmcount + bscount + skcount + btcount + tbcount

    local function hasazeritetrait(powerid)
    local isSelected        
    for _, itemLocation in AzeriteUtil.EnumerateEquipedAzeriteEmpoweredItems() do
        isSelected = C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerid)
        if isSelected then return true end
    end
        return false
    end

    local deadshottrait = hasazeritetrait(129)
    local aceupyoursleevetrait = hasazeritetrait(411)

    --Targets in range check
    local enemyCount = enemies.around(8)
    if enemyCount == 0 then enemyCount = 1 end
    dark_addon.interface.status_extra('T#:' .. enemyCount .. ' D:' .. target.distance)

    --Auto Attack
    if target.enemy and target.alive and target.distance < 8 then
        auto_attack()
    end

    --Interrupts
        --Define random number for interrupt
        local intpercent = math.random(intpercentlow,intpercenthigh)

        -- Kick
        if toggle('interrupts', false) and castable(SB.Kick) and -spell(SB.Kick) == 0 and target.interrupt(intpercent, false) and target.distance < 8 then
            print('Kick @ ' .. intpercent)
            return cast(SB.Kick, 'target')
        end

        --Gouge
        if toggle('interrupts', false) and castable(SB.Gouge) and -spell(SB.Gouge) == 0 and -spell(SB.Kick) > 0 and target.interrupt(intpercent, false) 
        and target.distance < 8 then
            print('Gouge @ ' .. intpercent)
            return cast(SB.Gouge, 'target')
        end

        --Blind
        if toggle('interrupts', false) and castable(SB.Blind) and -spell(SB.Blind) == 0 and -spell(SB.Kick) > 0 and -spell(SB.Gouge) > 0 
        and target.interrupt(intpercent, false) and target.distance < 8 then
            print('Blind @ ' .. intpercent)
            return cast(SB.Blind, 'target')
        end               

    --Defensive and Utility Abilities
    --Cloak of Shadows
    local dispellable_unit = player.removable('disease', 'magic', 'poison')

    if castable(SB.CloakofShadows) and -spell(SB.CloakofShadows) == 0 and -player.health <= COSHealth and dispellable_unit then
        return cast(SB.CloakofShadows, 'player')
    end
      
    --Feint
    if castable(SB.Feint) and -spell(SB.Feint) == 0 and -player.health <= FHealth and player.power.energy.actual >= 35 then
        return cast(SB.Feint, 'player')
    end

    --Riposte
    if castable(SB.Riposte) and -spell(SB.Riposte) == 0 and -player.health <= RHealth then
        return cast(SB.Riposte, 'player')
    end

    --Vanish

    --Healing
    if castable(SB.CrimsonVial) and -spell(SB.CrimsonVial) == 0 and -player.health <= CVHealth then
        return cast(SB.CrimsonVial, 'player')
    end

--Single Target Rotation
if enemyCount == 1 then

    if not deadshottrait and not aceupyoursleevetrait then
        --Cast 4-5 Combo Point Roll the Bones (see dedicated Roll the Bones section for details).
        if castable(SB.RolltheBones) and -spell(SB.RolltheBones) == 0 and player.power.combopoints.actual >= 4 and not talent(6,3) 
        and ((rtbcount < 2 and player.buff(SB.LoadedDice).up) or (rtbcount < 2 and player.buff(SB.GrandMelee).down and player.buff(SB.RuthlessPrecision).down)) then
          return cast(SB.RolltheBones, 'target')
        end
    end 
    
    if deadshottrait or aceupyoursleevetrait then
        --Cast 4-5 Combo Point Roll the Bones (see dedicated Roll the Bones section for details).
        if castable(SB.RolltheBones) and -spell(SB.RolltheBones) == 0 and player.power.combopoints.actual >= 4 and not talent(6,3) 
        and ((rtbcount < 2 and player.buff(SB.LoadedDice).up) or (rtbcount < 2 and player.buff(SB.RuthlessPrecision).down)) then
          return cast(SB.RolltheBones, 'target')
        end
    end 

    --Cast Ghostly Strike (if talented) on cooldown, unless you will over-cap Combo Points from it.
    if castable(SB.GhostlyStrike) and -spell(SB.GhostlyStrike) == 0 and player.power.combopoints.actual <= 4 and talent(1,3) then
      return cast(SB.GhostlyStrike, 'target')
    end

    --Cast Killing Spree / Blade Rush on cooldown; if Adrenaline Rush is active, delay Killing Spree to prevent over-capping on energy.
    if castable(SB.BladeRush) and -spell(SB.BladeRush) == 0 and talent(7,2) and player.buff(SB.AdrenalineRush).down then
      return cast(SB.BladeRush, 'target')
    end

    --Cast Killing Spree / Blade Rush on cooldown; if Adrenaline Rush is active, delay Killing Spree to prevent over-capping on energy.
    if castable(SB.KillingSpree) and -spell(SB.KillingSpree) == 0 and talent(7,3) then
      return cast(SB.KillingSpree, 'target')
    end        

    --Activate Adrenaline Rush 
    if castable(SB.AdrenalineRush) and -spell(SB.AdrenalineRush) == 0 and toggle('cooldowns', false) then
      return cast(SB.AdrenalineRush, 'target')
    end

    --Cast Marked for Death (if talented) if you have 0-1 Combo Points.
    if castable(SB.MarkedforDeath) and -spell(SB.MarkedforDeath) == 0 and player.power.combopoints.actual <= 1 and talent(3,3) then
      return cast(SB.MarkedforDeath, 'target')
    end

    --Cast Between the Eyes at 5 Combo Points if you have a Ruthless Precision proc, or Ace Up Your Sleeve , or Deadshot
    if castable(SB.BetweentheEyes) and -spell(SB.BetweentheEyes) == 0 and player.power.combopoints.actual >= 5 
    and (player.buff(SB.RuthlessPrecision).up or aceupyoursleevetrait or deadshottrait) then
      return cast(SB.BetweentheEyes, 'target')
    end

    --Cast Dispatch at 5 Combo Points.
    if castable(SB.Dispatch) and -spell(SB.Dispatch) == 0 and player.power.combopoints.actual >= 5 then
      return cast(SB.Dispatch, 'target')
    end

    --Cast Pistol Shot if you have an Opportunity proc and you have 4 or less Combo Points (and will not Energy cap during the global cooldown).
    if castable(SB.PistolShot) and -spell(SB.PistolShot) == 0 and player.buff(SB.Opportunity).up 
    and (player.power.combopoints.actual <= 4 or (player.power.combopoints.actual <= 4 and talent(1,1))) then
      return cast(SB.PistolShot, 'target')
    end

    --Cast Sinister Strike to generate Combo Points.
    if castable(SB.SinisterStrike) and -spell(SB.SinisterStrike) == 0 then
      return cast(SB.SinisterStrike, 'target')
    end
end

--Multi Target Rotation
if enemyCount >= 2 then

    --Cast Blade Flurry if there are 2+ targets.
    if castable(SB.BladeFlurry) and -spell(SB.BladeFlurry) == 0 and target.time_to_die > 6 then
      return cast(SB.BladeFlurry, 'target')
    end

    if not deadshottrait and not aceupyoursleevetrait then
        --Cast 4-5 Combo Point Roll the Bones (see dedicated Roll the Bones section for details).
        if castable(SB.RolltheBones) and -spell(SB.RolltheBones) == 0 and player.power.combopoints.actual >= 4 and not talent(6,3) 
        and ((rtbcount < 2 and player.buff(SB.LoadedDice).up) or (rtbcount < 2 and player.buff(SB.GrandMelee).down and player.buff(SB.RuthlessPrecision).down)) then
          return cast(SB.RolltheBones, 'target')
        end
    end     
    
    if deadshottrait or aceupyoursleevetrait then
        --Cast 4-5 Combo Point Roll the Bones (see dedicated Roll the Bones section for details).
        if castable(SB.RolltheBones) and -spell(SB.RolltheBones) == 0 and player.power.combopoints.actual >= 4 and not talent(6,3) 
        and ((rtbcount < 2 and player.buff(SB.LoadedDice).up) or (rtbcount < 2 and player.buff(SB.RuthlessPrecision).down)) then
          return cast(SB.RolltheBones, 'target')
        end
    end

    --Cast Ghostly Strike (if talented) on cooldown, in sync with Blade Flurry unless you will over-cap Combo Points from it.
    if castable(SB.GhostlyStrike) and -spell(SB.GhostlyStrike) == 0 and player.power.combopoints.actual <= 4 
    and player.buff(SB.BladeFlurry).up and talent(1,3) then
      return cast(SB.GhostlyStrike, 'target')
    end

    --Cast Killing Spree / Blade Rush on cooldown; if Adrenaline Rush is active, delay to prevent over-capping on energy, only if Blade Flurry is currently active.
    if castable(SB.BladeRush) and -spell(SB.BladeRush) == 0 and talent(7,2) and player.buff(SB.AdrenalineRush).down 
    and player.buff(SB.BladeFlurry).up then
      return cast(SB.BladeRush, 'target')
    end

    --Cast Killing Spree / Blade Rush on cooldown; if Adrenaline Rush is active, only if Blade Flurry is currently active.
    if castable(SB.KillingSpree) and -spell(SB.KillingSpree) == 0 and talent(7,3) and player.buff(SB.BladeFlurry).up then
      return cast(SB.KillingSpree, 'target')
    end        

    --Activate Adrenaline Rush 
    if castable(SB.AdrenalineRush) and -spell(SB.AdrenalineRush) == 0 and toggle('cooldowns', false) then
      return cast(SB.AdrenalineRush, 'target')
    end

    --Cast Marked for Death (if talented) if you have 0-1 Combo Points.
    if castable(SB.MarkedforDeath) and -spell(SB.MarkedforDeath) == 0 and player.power.combopoints.actual <= 1 and talent(3,3) then
      return cast(SB.MarkedforDeath, 'target')
    end

    --Cast Between the Eyes at 5 Combo Points if you have a Ruthless Precision proc, or Ace Up Your Sleeve , or Deadshot
    if castable(SB.BetweentheEyes) and -spell(SB.BetweentheEyes) == 0 and player.power.combopoints.actual >= 5 
    and (player.buff(SB.RuthlessPrecision).up or aceupyoursleevetrait or deadshottrait) then
      return cast(SB.BetweentheEyes, 'target')
    end

    --Cast Dispatch at 5 Combo Points.
    if castable(SB.Dispatch) and -spell(SB.Dispatch) == 0 and player.power.combopoints.actual >= 5 then
      return cast(SB.Dispatch, 'target')
    end

    --Cast Pistol Shot if you have an Opportunity proc and you have 4 or less Combo Points (and will not Energy cap during the global cooldown).
    if castable(SB.PistolShot) and -spell(SB.PistolShot) == 0 and player.buff(SB.Opportunity).up 
    and (player.power.combopoints.actual <= 4 or (player.power.combopoints.actual <= 4 and talent(1,1))) then
      return cast(SB.PistolShot, 'target')
    end

    --Cast Sinister Strike to generate Combo Points.
    if castable(SB.SinisterStrike) and -spell(SB.SinisterStrike) == 0 then
      return cast(SB.SinisterStrike, 'target')
    end
end         

end
end

local function resting()

local enemyCount = enemies.around(8)
dark_addon.interface.status_extra('T#:' .. enemyCount .. ' D:' .. target.distance)

--Stealth OOC
if castable(SB.Stealth) and -spell(SB.Stealth) == 0 and player.buff(SB.Stealth).down then 
    return cast(SB.Stealth, 'player')
end

end

local function interface()

    local settings = {
        key = 'outrog_settings',
        title = 'Outlaw Rogue',
        width = 300,
        height = 500,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = "            Rex's Outlaw Rogue Settings" },
            { type = 'text', text = 'Everything on the screen is LIVE.  As you make changes, they are being fed to the engine' },
            { type = 'text', text = 'Suggested Talents - 2 3 1 2 3 2 2' },
            { type = 'text', text = 'Adrenaline Rush is managed by the Cooldowns toggle' },            
            { type = 'text', text = 'If you want automatic AOE then please remember to turn on EnemyNamePlates in WoW (V key)' },
            { type = 'rule' },
            { type = 'text', text = 'Interrupt Settings' },
            { key = 'intpercentlow', type = 'spinner', text = 'Interrupt Low %', default = '50', desc = 'low% cast time to interrupt at', min = 5, max = 50, step = 1 },
            { key = 'intpercenthigh', type = 'spinner', text = 'Interrupt High %', default = '65', desc = 'high% cast time to interrupt at', min = 51, max = 100, step = 1 },
            { type = 'text', text = 'Defensive Settings' },
            { key = 'CVHealth', type = 'spinner', text = 'Crimson Vial at Health %', default = '30', desc = 'cast Crimson Vial at', min = 0, max = 100, step = 1 },
            { key = 'FHealth', type = 'spinner', text = 'Feint at Health %', default = '40', desc = 'cast Feint at', min = 0, max = 100, step = 1 },
            { key = 'RHealth', type = 'spinner', text = 'Riposte at Health %', default = '60', desc = 'cast Riposte at', min = 0, max = 100, step = 1 },
            { key = 'COSHealth', type = 'spinner', text = 'Cloak of Shadows at Health %', default = '50', desc = 'cast Cloak of Shadows at', min = 0, max = 100, step = 1 },    
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

-- This is what actually tells DR about your custom rotation
dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.rogue.outlaw,
    name = 'outrogpal',
    label = 'Rex Outlaw Rogue',
    combat = combat,
    resting = resting,
    interface = interface
})
