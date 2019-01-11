-- Protection Paladin for 8.1 by Laksmackt - 12/2018 - based on original by Rotations

-- Holding Shift = Hammer of Justice

--Supported talents
--all - EXCEPT blessed hammer and Aegis of light - use manually if selected
-- hand of protector currently will only heal self, so a bit of a waste ... take unbreakable spirit instead



local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.paladin
local PB = dark_addon.rotation.spellbooks.purgeables
local race = UnitRace("player")

local function combat()


    -----------------------------
    --- Reading from settings
    -----------------------------

    local autoStun = dark_addon.settings.fetch('holypal_settings_autoStun', true)
    local usehealthstone = dark_addon.settings.fetch('holypal_settings_healthstone.check', true)
    local healthstonepercent = dark_addon.settings.fetch('holypal_settings_healthstone.spin', 35)
    local autoRacial = dark_addon.settings.fetch('holypal_settings_autoRacial', true)
    local useTrinkets = dark_addon.settings.fetch('holypal_settings_useTrinkets', true)

    if not target.alive or not target.enemy then
        return
    end

    if target.enemy and target.distance <= 8 then
        auto_attack()
    end

    -- Interupts
    if toggle('interrupts', false) and target.interrupt() and target.distance < 8 and -spell(SB.Rebuke) == 0 then
        return cast(SB.Rebuke, 'target')
    end
    if toggle('interrupts', false) and target.interrupt() and target.distance < 8 and -spell(SB.Rebuke) > 0 and -spell(SB.BlindingLight) == 0 then
        return cast(SB.BlindingLight, 'target')
    end
    if autoStun and toggle('interrupts', false) and target.interrupt() and target.distance < 8 and -spell(SB.Rebuke) > 0 and -spell(SB.BlindingLight) > 0 and -spell(SB.HammerofJustice) == 0 then
        return cast(SB.HammerofJustice, 'target')
    end

    if talent(SB.BastionofLight) and spell(SB.ShieldoftheRighteous).charges == 0 and toggle('cooldowns', false) and -spell(SB.BastionofLight) == 0 then
        return cast(SB.BastionofLight)
    end



    --Trinkets

    local Trinket13 = GetInventoryItemID("player", 13)
    local Trinket14 = GetInventoryItemID("player", 14)

    --print(Trinket13)



    --doomsfury trinket
    if useTrinkets then
        if Trinket13 == 161463 and player.buff(SB.AvengingWrath).up and GetItemCooldown(161463) == 0 then
            macro('/use 13')
        end
        if Trinket14 == 161463 and player.buff(SB.AvengingWrath).up and GetItemCooldown(161463) == 0 then
            macro('/use 14')
        end
        --Jes Howler (159622)
        if Trinket13 == 159622 and target.enemy and target.distance < 8 and target.health.percent > 50 and GetItemCooldown(159627) == 0 and -spell(SB.AvengingWrath) > 10 and player.buff(SB.AvengingWrath).down then
            macro('/use 13')
        end
        if Trinket14 == 159622 and target.enemy and target.distance < 8 and target.health.percent > 50 and GetItemCooldown(159627) == 0 and -spell(SB.AvengingWrath) > 10 and player.buff(SB.AvengingWrath).down then
            macro('/use 14')
        end
        --Razdunk big red button  (159611)
        if Trinket13 == 159611 and target.enemy and target.distance < 8 and target.health.percent > 50 and GetItemCooldown(159611) == 0 and -spell(SB.AvengingWrath) > 10 and player.buff(SB.AvengingWrath).down then
            macro('/use [@player] 13 ')
        end
        if Trinket14 == 159611 and target.enemy and target.distance < 8 and target.health.percent > 50 and GetItemCooldown(159611) == 0 and -spell(SB.AvengingWrath) > 10 and player.buff(SB.AvengingWrath).down then
            macro('/use [@player] 14 ')
        end
    end


    --use healthstone at 40% health and we are in combat
    if usehealthstone and GetItemCooldown(5512) == 0 and player.health.percent < healthstonepercent then
        macro('/use Healthstone')
    end

    if modifier.shift and -spell(SB.HammerofJustice) == 0 then
        return cast(SB.HammerofJustice, 'target')
    end


    --use Seraphim if we picked it
    if talent(7, 3) and -spell(SB.Seraphim) == 0 and spell(SB.ShieldoftheRighteous).charges > 0 and target.distance < 8 then
        return cast(SB.Seraphim)
    end


    -- added check for armor buff
    if spell(SB.ShieldoftheRighteous).charges > 0 and target.distance < 8 and not -buff(SB.ShieldoftheRighteousBuff) and not -buff(SB.InnerLight) then
        return cast(SB.ShieldoftheRighteous, 'target')
    end

    if modifier.alt and -spell(SB.ShieldoftheRighteous) == 0 then
        return cast(SB.ShieldoftheRighteous, 'target')
    end

    -- Lets use our blessings/LoH
    -- BoP bad players

    if toggle('BoP', false) and lowest.castable(SB.BlessingofProtection) and lowest.health.percent <= 20 and lowest.debuff(SB.Forbearance).down and lowest ~= tank and lowest ~= player then
        return cast(SB.BlessingofProtection, lowest)
    end
    --autoracial and purgeables
    if autoRacial == true and race == "Blood Elf" and target.distance <= 8 and -spell(SB.ArcaneTorrent) == 0 then
        for i = 1, 40 do
            local name, _, _, count, debuff_type, _, _, _, _, spell_id = UnitAura("target", i)
            if spell_id == nil then
                break
            end
            if name and PB[spell_id] then
                print("Purging " .. name .. " off the target.")
                return cast(SB.ArcaneTorrent)
            end
        end
    end

    --BlessingofSacrifice	on semi bad players

    if not talent(4, 3) and lowest.castable(SB.BlessingofSacrifice) and lowest.health.percent <= 40 and lowest ~= tank and lowest ~= player then
        return cast(SB.BlessingofSacrifice, lowest)
    end


    -- LoH on dying players
    if lowest.castable(SB.LayonHands) and lowest.debuff(SB.Forbearance).down and lowest.health.percent <= 15 then
        return cast(SB.LayonHands, lowest)
    end

    if -spell(SB.LayonHands) == 0 and player.debuff(SB.Forbearance).down and player.health.percent <= 15 then
        return cast(SB.LayonHands, player)
    end

    -- Ok Lets start healing ourselves because we are taking a beating..
    if -player.health < 60 and -spell(SB.LightoftheProtector) == 0 then
        return cast(SB.LightoftheProtector, 'player')
    end

    if -player.health < 55 and -spell(SB.ArdentDefender) == 0 then
        return cast(SB.ArdentDefender, 'player')
    end

    if -player.health < 45 and -spell(SB.ArdentDefender) > 0 and -spell(SB.GuardianofAncientKings) == 0 then
        return cast(SB.GuardianofAncientKings, 'player')
    end

    -- self-cleanse
    local dispellable_unit = player.removable('poison', 'disease')
    if dispellable_unit then
        return cast(SB.CleanseToxins, dispellable_unit)
    end


    -- Ok Lets do some cooldowns
    if toggle('cooldowns', false) and -spell(SB.AvengingWrath) == 0 and target.distance <= 8 then
        return cast(SB.AvengingWrath, 'player')
    end

    -- Rotation standard
    if -spell(SB.Judgment) == 0 and target.distance < 30 then
        --print (tank.name)
        return cast(SB.Judgment, target)
    end

    if -spell(SB.AvengersShield) == 0 and target.distance < 40 then
        return cast(SB.AvengersShield, target)
    end

    if -spell(SB.ConsecrationProt) == 0 and target.distance < 4 then
        return cast(SB.ConsecrationProt)
    end

    if -spell(SB.HammerOfTheRighteous) == 0 and target.distance < 8 then
        return cast(SB.HammerOfTheRighteous)
    end

    -- taunt if we do not have aggro
    -- if target's target is not me - cast HandofReckoning'


end

local function resting()
    -- self-cleanse
    local dispellable_unit = player.removable('poison', 'disease')
    if dispellable_unit then
        return cast(SB.CleanseToxins, dispellable_unit)
    end


end

local function interface()
    local settings = {
        key = 'protpal_settings',
        title = 'Protection Paladin',
        width = 250,
        height = 380,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = '               Prot Paladin Settings' },
            { type = 'text', text = 'Everything on the screen is LIVE.  As you make changes, they are being fed to the engine.' },
            { type = 'rule' },
            { type = 'text', text = 'General Settings' },
            { key = 'healthstone', type = 'checkspin', text = 'Healthstone', desc = 'Auto use Healthstone at health %', min = 5, max = 100, step = 5 },
            -- { key = 'input', type = 'input', text = 'TextBox', desc = 'Description of Textbox' },
            { key = 'intpercent', type = 'spinner', text = 'Interrupt %', desc = '% cast time to interrupt at', min = 5, max = 100, step = 5 },
            { type = 'rule' },
            { type = 'text', text = 'Utility' },
            { key = 'autoStun', type = 'checkbox', text = 'Stun', desc = 'Use stun as an interrupt' },
            { key = 'autoRacial', type = 'checkbox', text = 'Racial', desc = 'Use Racial on CD (Blood Elf only)', "true" },
            { type = 'rule' },
            { key = 'useTrinkets', type = 'checkbox', text = 'Use Trinkets?', desc = '' },
            { type = 'rule' },
        }
    }

    configWindow = dark_addon.interface.builder.buildGUI(settings)

    dark_addon.interface.buttons.add_toggle({
        name = 'DISPELL',
        label = 'DISP',
        on = {
            label = 'DISP',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'DISP',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
    dark_addon.interface.buttons.add_toggle({
        name = 'BoP',
        label = 'BoP',
        on = {
            label = 'BoP',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'BoP',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
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
    spec = dark_addon.rotation.classes.paladin.protection,
    name = 'protpal',
    label = 'Pal  - PROT',
    combat = combat,
    resting = resting,
    interface = interface,
})