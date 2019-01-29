-- Beastmastery Hunter for 8.1 by Pixels 12/2018
-- Talents: All  - except Camouflage / Binding Shot / Barrage / Stampede / Spitting Cobra
-- Alt = Tar Trap
-- Shift = Freezing Trap
-- RShift = MultiShot

local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.hunter
local lftime = 0

--Local Spells not in default spellbook
SB.Bite = 17253
SB.Smack = 49962
SB.PetFrenzy = 272790
SB.AncestralCall = 274738
SB.Fireblood = 265221
SB.SpittingCobra = 194407
SB.LightsJudgement = 255647
SB.BloodFury = 20572
SB.Berserking = 26297
SB.LightsJudgement = 247427

local function GroupType()
   return IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
end

local function combat()
    local usetraps = dark_addon.settings.fetch('bmpal_settings_traps', false)
    local usemisdirect = dark_addon.settings.fetch('bmpal_settings_misdirect', false)
    local race = UnitRace('player')
    local group_type = GroupType()
    local opener = 0

    if target.alive and target.enemy and not player.channeling() then
        auto_shot()

        if usetraps and modifier.shift and not modifier.alt and castable(SB.FreezingTrap) then
            return cast(SB.FreezingTrap, 'ground')
        end
        if usetraps and modifier.alt and not modifier.shift and castable(SB.TarTrap) then
            return cast(SB.TarTrap, 'ground')
        end
        if toggle('interrupts') and castable(SB.CounterShot) and target.interrupt(50) then
            return cast(SB.CounterShot)
        end
        if toggle('cooldowns', false) and castable(SB.AspectOfTheWild) then
            return cast(SB.AspectOfTheWild)
        end
        if toggle('cooldowns', false) and castable(SB.BeastialWrath) and (-spell(SB.AspectOfTheWild) > 20 or target.time_to_die < 15) then
            return cast(SB.BeastialWrath)
        end
        if toggle('racial', false) and -spell(SB.BeastialWrath) > 30 then
            if race == "Orc" and castable(SB.BloodFury) then
                cast(SB.BloodFury)
            end
            if race == "Troll" and castable(SB.Berserking) then
                cast(SB.Berserking)
            end
            if race == "Mag'har Orc" and castable(SB.AncestralCall) then
                cast(SB.AncestralCall)
            end
            if race == "LightforgedDraenei" and castable(SB.LightsJudgement) then
                cast(SB.LightsJudgement)
            end
        end
        if spell(SB.BarbedShot).charges >= 1 and pet.buff(SB.PetFrenzy).remains <= 1.75 then
            return cast(SB.BarbedShot, 'target')
        end
        if talent(7,3) and castable(SB.SpittingCobra) then
            return cast(SB.SpittingCobra)
        end
        if talent(4,3) and castable(SB.AMurderOfCrows) then
            return cast(SB.AMurderOfCrows, 'target')
        end
        if talent(6,3) and castable(SB.Stampede) and buff(SB.AspectOfTheWild).up and buff(SB.BeastialWrath).up or target.time_to_die < 15 then
            return cast(SB.Stampede)
        end
        if toggle('multitarget', false) and enemies.around(40) > 2 and target.castable(SB.MultiShot) then
            return cast(SB.MultiShot)
        end
        if toggle('multitarget', false) and talent(6,2) and enemies.around(40) > 2 and castable(SB.Barrage) then
            return cast(SB.Barrage)
        end
        if talent(2,3) and -power.focus < 90 and castable(SB.ChimaeraShot) then
            return cast(SB.ChimaeraShot, 'target')
        end
        if -power.focus >= 30 and castable(SB.KillCommand) then
            return cast(SB.KillCommand, 'target')
        end
        if talent(1,3) and castable(SB.DireBeast) then
            return cast(SB.DireBeast, 'target')
        end
        if -power.focus >=80 and castable(SB.CobraShot) and -spell(SB.KillCommand) >= 2.5 then
            return cast(SB.CobraShot, 'target')
        end
        -- Pet Management
        if pet.exists and not pet.alive then
            return cast (SB.RevivePet)
        end
        if pet.alive and pet.health.percent <= 70 and castable(SB.MendPet) then
            return cast(SB.MendPet)
        end

        -- Defensives
        if (player.health.percent <= 50 or pet.health.percent <= 20) and castable(SB.Exhilaration) then
            return cast(SB.Exhilaration)
        end
        if player.health.percent < 50 and not castable(SB.Exhilaration) then
            return cast(SB.AspectOfTheTurtle)
        end
    end
end

local function resting()
    local lfg = GetLFGProposal();
    local hasData = GetLFGQueueStats(LE_LFG_CATEGORY_LFD);
    local hasData2 = GetLFGQueueStats(LE_LFG_CATEGORY_LFR);
    local hasData3 = GetLFGQueueStats(LE_LFG_CATEGORY_RF);
    local hasData4 = GetLFGQueueStats(LE_LFG_CATEGORY_SCENARIO);
    local hasData5 = GetLFGQueueStats(LE_LFG_CATEGORY_FLEXRAID);
    local hasData6 = GetLFGQueueStats(LE_LFG_CATEGORY_WORLDPVP);
    local bgstatus = GetBattlefieldStatus(1);
    local autojoin = dark_addon.settings.fetch('bmpal_settings_autojoin', true)
    local usemisdirect = dark_addon.settings.fetch('bmpal_settings_misdirect')
    local petselection = dark_addon.settings.fetch('bmpal_settings_petselector')

    if not pet.exists then
        if petselection == 'key_1' then
            return cast(SB.CallPet1)
        elseif petselection == 'key_2' then
            return cast(SB.CallPet2)
        elseif petselection == 'key_3' then
            return cast(SB.CallPet3)
        elseif petselection == 'key_4' then
            return cast(SB.CallPet4)
        elseif petselection == 'key_5' then
            return cast(SB.CallPet5)
        end
    end
    if pet.exists and not pet.alive then
        return cast (SB.RevivePet)
    end
    if pet.alive and pet.health.percent <= 70 and -spell(SB.MendPet) == 0 then
        return cast(SB.MendPet)
    end

end

function interface()

    local settings = {
        key = 'bmpal_settings',
        title = 'Beastmaster Pal',
        width = 250,
        height = 380,
        fontheight = 10,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = 'BM Pal Settings'},
            { type = 'rule'},
            { type = 'text', text = 'General Settings'},
            { key = 'autojoin', type = 'checkbox', text = 'Auto Join', desc = 'Automatically accept Dungeon/Battleground Invites', default = true },
            { key = 'traps', type = 'checkbox',
            text = 'Traps',
            desc = 'Auto use Traps',
            default = false
            },
            { type = 'rule'},
            { type = 'text', text = 'Pet Management'},
            { key = 'petselector', type = 'dropdown',
                text = 'Pet Selector',
                desc = 'select your active pet',
                default = 'key_3',
                list = {
                    { key = 'key_1', text = 'Pet 1'},
                    { key = 'key_2', text = 'Pet 2'},
                    { key = 'key_3', text = 'Pet 3'},
                    { key = 'key_4', text = 'Pet 4'},
                    { key = 'key_5', text = 'Pet 5'}
                },
            }
        }
    }

    configWindow = dark_addon.interface.builder.buildGUI(settings)

    dark_addon.interface.buttons.add_toggle({
        name = 'racial',
        label = 'Use Racial',
        on = {
            label = 'Racial',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'Racial',
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
    spec = dark_addon.rotation.classes.hunter.beastmastery,
    name = 'bmpal',
    label = 'PAL: Beastmastery Hunter',
    combat = combat,
    resting = resting,
    interface = interface,
})
