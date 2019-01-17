-- Holy Priest for 8.1 by Rebecca Pal Project 01/2019
-- Talents: 2323132
-- Alt = Mass Dispell
-- Shift = Angelic Feather
-- Control = Holy Word Serenity
local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.priest
local lftime = 0
local falltime = 0
-------------
---Spells---
-------------
SB.GiftOftheNaaru = 59544
SB.MendingBuff = 41635
SB.AncestralCall = 274738
SB.LightsJudgement = 255647

local function combat()
-------------
----Fetch----
-------------
local fade = dark_addon.settings.fetch('holypal_settings_fade', 95)
local simultaneousrenews = dark_addon.settings.fetch('holypal_settings_simultaneousrenews', 6)
local max_renews = group.count(function (unit)
  return unit.alive and unit.distance < 40 and unit.buff(SB.Renew).up
end)
local race = UnitRace('player')
local renewlowest = dark_addon.settings.fetch('holypal_settings_renewlowest', 85)
local renewtank = dark_addon.settings.fetch('holypal_settings_renewtank', 90)
local flashheallowest = dark_addon.settings.fetch('holypal_settings_flashheallowest', 60)
local flashhealsurge = dark_addon.settings.fetch('holypal_settings_flashhealsurge',75)
local flashhealsurgeemergency = dark_addon.settings.fetch('holypal_settings_flashhealsurgeemergency', 80)
local healpercent = dark_addon.settings.fetch('holypal_settings_healpercent', 70)
local desperateprayerpercent = dark_addon.settings.fetch('holypal_settings_desperateprayerpercent', 35)
local serenitypercent = dark_addon.settings.fetch('holypal_settings_serenitypercent', 50)
local guardianspirit = dark_addon.settings.fetch('holypal_settings_guardianspirit', 30)
local guardianspirittarget = dark_addon.settings.fetch('holypal_settings_guardianspirittarget', "gs_tank")
local prayerofhealingpercent = dark_addon.settings.fetch('holypal_settings_prayerofhealingpercent', 70)
local prayerofhealingnumberofplayer = dark_addon.settings.fetch('holypal_settings_prayerofhealingnumberofplayer', 3)
local mendingpercent = dark_addon.settings.fetch('holypal_settings_mendingpercent', 85)
local flashhealonme = dark_addon.settings.fetch('holypal_settings_flashhealonme', 25)
local serenetionme = dark_addon.settings.fetch('holypal_settings_serenetionme', 25)
local apotheosisflash = dark_addon.settings.fetch('holypal_settings_apotheosisflash', 85)
local apotheosisserenetiycd = dark_addon.settings.fetch('holypal_settings_apotheosisserenetiycd', 15)
local apotheosispoh = dark_addon.settings.fetch('holypal_settings_apotheosispoh', 90)
local apotheosispohplayers = dark_addon.settings.fetch('holypal_settings_apotheosispohplayers', 3)
local movingrenews = dark_addon.settings.fetch('holypal_settings_movingrenews', "always")


-------------
--Modifiers--
-------------
if not player.channeling() then

  if modifier.alt and castable(SB.MassDispell) then
    return cast(SB.MassDispell, ground)
  end
  if modifier.shift and castable(SB.AngelicFeather) and player.buff(SB.AngelicFeather).down then
    return cast(SB.AngelicFeather, player)
  end
  if modifier.control and castable(SB.HolyWordSanctify) then
    return cast(SB.HolyWordSanctify, ground)
  end
-------------
---Dispel----
-------------
    local dispellable_unit = group.removable('disease', 'magic')
    if toggle('dispel', false) and dispellable_unit and spell(SB.Purify).cooldown == 0 then
        return cast(SB.Purify, dispellable_unit)
    end

    -- self-cleanse
    local dispellable_unit = player.removable('disease', 'magic')
    if toggle('dispel', false) and dispellable_unit and spell(SB.Purify).cooldown == 0 then
        return cast(SB.Purify, dispellable_unit)
end


-------------
---Racials---
-------------
if toggle('racial', false) then
  if race == "Orc" and castable(SB.BloodFury) then
    return cast(SB.BloodFury)
  end
  if race == "Troll" and castabe(SB.Berserking) then
    return cast(SB.Berserking)
  end
  if race == "Mag'har Orc" and castable(SB.AncestralCall) then
    return cast(SB.AncestralCall)
  end
  if race == "LightforgedDraenei" and castable(SB.LightsJudgement) then
    return cast(SB.LightsJudgement)
  end
  if race == "Draenei" and lowest.castable(SB.GiftOftheNaaru) and lowest.health.effective >= 50 then
    return cast(SB.GiftOftheNaaru, lowest)
  end
end


-------------
--Self Heal--
-------------
  if player.castable(SB.FlashHeal) and player.health.effective <= flashhealonme then
    return cast(SB.FlashHeal, player)
  end
  if player.castable(SB.HolyWordSerenity) and player.health.effective <= serenetionme then
    return cast(SB.HolyWordSerenity, player)
  end

--------------
--Apotheosis--
--------------
if player.buff(SB.Apotheosis).up then
  if lowest.castable(SB.FlashHeal) and lowest.health.effective <= apotheosisflash and spell(SB.HolyWordSerenity).cooldown >= apotheosisserenetiycd then
    return cast(SB.FlashHeal, lowest)
  elseif tank.castable(SB.FlashHeal) and tank.health.effective <= apotheosisflash and spell(SB.HolyWordSerenity).cooldown >= apotheosisserenetiycd then
    return cast(SB.FlashHeal, tank)
  end
  if castable(SB.PrayerofHealing) and group.under(apotheosispoh, 40, true) >= apotheosispohplayers then
    return cast(SB.PrayerofHealing, player)
  end
   if castable(SB.HolyWordSerenity) and lowest.health.effective <= serenitypercent then
    return cast(SB.HolyWordSerenity, lowest)
  elseif castable(SB.HolyWordSerenity) and tank.health.effective <= serenitypercent then
    return cast(SB.HolyWordSerenity, tank)
  end

end
-------------
----Heal-----
-------------
--Prayer of Mending
  if castable(SB.PrayerofMending) and lowest.health.effective <= mendingpercent then 
    return cast(SB.PrayerofMending, lowest)
  elseif castable(SB.PrayerofMending) and tank.health.effective <= mendingpercent then
   return cast(SB.PrayerofMending, tank)
  end

--Prayer of Healing 
  if castable(SB.PrayerofHealing) and group.under(prayerofhealingpercent, 40, true) >= prayerofhealingnumberofplayer then
    return cast(SB.PrayerofHealing, player)
  end

--Guardian Spirit
  if guardianspirittarget == 'gs_tank' and tank.castable(SB.GuardianSpirit) and tank.health.percent <= guardianspirit then
    return cast(SB.GuardianSpirit, tank)
    elseif guardianspirittarget == 'gs_all' and lowest.castable(SB.GuardianSpirit) and lowest.health.percent <= guardianspirit then
      return cast (SB.GuardianSpirit, lowest)
    end

--Serenity
  if castable(SB.HolyWordSerenity) and lowest.health.effective <= serenitypercent then
    return cast(SB.HolyWordSerenity, lowest)
  elseif castable(SB.HolyWordSerenity) and tank.health.effective <= serenitypercent then
    return cast(SB.HolyWordSerenity, tank)
  end

--Halo
  if talent(6, 3) and group.under(90, 40, true) >= 2 and castable(SB.Halo) then
    return cast(SB.Halo)
  end

--Renew
  if movingrenews == 'renew_always' then
    if lowest.castable(SB.Renew) and lowest.health.effective <= renewlowest and max_renews <= simultaneousrenews and lowest.buff(SB.Renew).down then
      return cast(SB.Renew, lowest)
    elseif tank.castable(SB.Renew) and tank.health.effective <= renewtank and max_renews <= simultaneousrenews and tank.buff(SB.Renew).down then
      return cast(SB.Renew, tank)
    end
  end
  if movingrenews == 'renew_moving' then
    if lowest.castable(SB.Renew) and lowest.health.effective <= renewlowest and max_renews <= simultaneousrenews and lowest.buff(SB.Renew).down and player.moving then
      return cast(SB.Renew, lowest)
    elseif tank.castable(SB.Renew) and tank.health.effective <= renewtank and max_renews <= simultaneousrenews and tank.buff(SB.Renew).down and player.moving then
      return cast(SB.Renew, tank)
    end
  end

--Flash Heal
  if lowest.castable(SB.FlashHeal) and lowest.health.effective <= flashheallowest then
    return cast(SB.FlashHeal, lowest)
  elseif castable(SB.FlashHeal) and tank.health.effective <= flashheallowest then
    return cast(SB.FlashHeal, tank)  
  end
  if lowest.castable(SB.FlashHeal) and player.buff(SB.SurgeofLight).up and player.buff(SB.SurgeofLight).remains > 3 and lowest.health.effective <= flashhealsurge then
    return cast(SB.FlashHeal, lowest)
  elseif lowest.castable(SB.FlashHeal) and player.buff(SB.SurgeofLight).up and player.buff(SB.SurgeofLight).remains < 3 and lowest.health.effective <= flashhealsurgeemergency then
    return cast(SB,FlashHeal, lowest)
  end
  
  if tank.castable(SB.FlashHeal) and player.buff(SB.SurgeofLight).up and player.buff(SB.SurgeofLight).remains > 3 and tank.health.effective <= flashhealsurge then
   return cast(SB.FlashHeal, tank)
  elseif tank.castable(SB.FlashHeal) and player.buff(SB.SurgeofLight).up and player.buff(SB.SurgeofLight).remains < 3 and tank.health.effective <= flashhealsurgeemergency then
    return cast(SB,FlashHeal, tank)
  end
  
--Heal
  if lowest.castable(SB.Heal) and lowest.health.effective <= healpercent then
    return cast(SB.Heal, lowest)
  elseif tank.castable(SB.Heal) and tank.health.effective <= healpercent then
    return cast(SB.Heal, tank)
  end

--Desperate Prayer
  if player.health.effective < desperateprayerpercent and castable(SB.DesperatePrayer) then
    return cast(SB.DesperatePrayer, player)
  end



-------------
---Utility---
-------------
  if player.health.percent <= fade and castable(SB.Fade) then
    return cast(SB.Fade, player)
  end
end
-------------
-----DPS-----
-------------
  if toggle('dps', false) and not isCC("target") then
    if castable(SB.HolyWordChastise) and target.enemy and target.alive then
      return cast(SB.HolyWordChastise, target)
    end
    if target.enemy and target.alive then
      return cast(SB.Smite, target)
    end

  end

end
local function resting()
-------------
----Fetch----
-------------
local lfg = GetLFGProposal();
local hasData = GetLFGQueueStats(LE_LFG_CATEGORY_LFD);
local hasData2 = GetLFGQueueStats(LE_LFG_CATEGORY_LFR);
local hasData3 = GetLFGQueueStats(LE_LFG_CATEGORY_RF);
local hasData4 = GetLFGQueueStats(LE_LFG_CATEGORY_SCENARIO);
local hasData5 = GetLFGQueueStats(LE_LFG_CATEGORY_FLEXRAID);
local hasData6 = GetLFGQueueStats(LE_LFG_CATEGORY_WORLDPVP);
local bgstatus = GetBattlefieldStatus(1);
local autojoin = dark_addon.settings.fetch('holypal_utility_autojoin', true)
local fade = dark_addon.settings.fetch('holypal_settings_fade', 95)
local simultaneousrenews = dark_addon.settings.fetch('holypal_settings_simultaneousrenews', 6)
local max_renews = group.count(function (unit)
  return unit.alive and unit.distance < 40 and unit.buff(SB.Renew).up
end)
local renewlowest = dark_addon.settings.fetch('holypal_settings_renewlowest', 85)
local renewtank = dark_addon.settings.fetch('holypal_settings_renewtank', 90)
local flashheallowest = dark_addon.settings.fetch('holypal_settings_flashheallowest', 60)
local flashhealsurge = dark_addon.settings.fetch('holypal_settings_flashhealsurge',75)
local flashhealsurgeemergency = dark_addon.settings.fetch('holypal_settings_flashhealsurgeemergency', 80)
local healpercent = dark_addon.settings.fetch('holypal_settings_healpercent', 70)
local desperateprayerpercent = dark_addon.settings.fetch('holypal_settings_desperateprayerpercent', 35)
local serenitypercent = dark_addon.settings.fetch('holypal_settings_serenitypercent', 50)
local guardianspirit = dark_addon.settings.fetch('holypal_settings_guardianspirit', 30)
local guardianspirittarget = dark_addon.settings.fetch('holypal_settings_guardianspirittarget', "gs_tank")
local prayerofhealingpercent = dark_addon.settings.fetch('holypal_settings_prayerofhealingpercent', 70)
local prayerofhealingnumberofplayer = dark_addon.settings.fetch('holypal_settings_prayerofhealingnumberofplayer', 3)
local mendingpercent = dark_addon.settings.fetch('holypal_settings_mendingpercent', 85)
local flashhealonme = dark_addon.settings.fetch('holypal_settings_flashhealonme', 25)
local serenetionme = dark_addon.settings.fetch('holypal_settings_serenetionme', 25)
local levitate = dark_addon.settings.fetch('holypal_utility_levitate', true)

-------------
----Heal-----
-------------
--Renew
  if lowest.castable(SB.Renew) and lowest.health.effective <= renewlowest and max_renews <= simultaneousrenews and lowest.buff(SB.Renew).down and not player.moving then
    return cast(SB.Renew, lowest)
  end
  if tank.castable(SB.Renew) and tank.health.effective <= renewtank and max_renews <= simultaneousrenews and tank.buff(SB.Renew).down and not player.moving then
    return cast(SB.Renew, tank)
  end
--Heal
  if lowest.castable(SB.Heal) and lowest.health.effective <= healpercent then
    return cast(SB.Heal, lowest)
  elseif tank.castable(SB.Heal) and tank.health.effective <= healpercent then
    return cast(SB.Heal, tank)
  end

  --Prayer of Healing 
  if castable(SB.PrayerofHealing) and group.under(prayerofhealingpercent, 40, true) >= prayerofhealingnumberofplayer then
    return cast(SB.PrayerofHealing, player)
  end
-------------
--Levitate---
-------------
local falling = IsFalling()

  if falling == true and levitate == true then
    falltime = falltime + 1
  elseif falling == false then
    falltime = 0
  end

  if falltime >= 20 and levitate == true then
    return cast(SB.Levitate, player)
  end


-------------
--Auto Join--
-------------
  if autojoin == true and hasData == true or hasData2 == true or hasData4 == true or hasData5 == true or hasData6 == true or bgstatus == "queued" then
    SetCVar ("Sound_EnableSoundWhenGameIsInBG",1)
  elseif autojoin == false and hasdata == nil or hasData2 == nil or hasData3 == nil or hasData4 == nil or hasData5 == nil or hasData6 == nil or bgstatus == "none" then
    SetCVar ("Sound_EnableSoundWhenGameIsInBG",0)
  end

  if autojoin ==true and lfg == true or bgstatus == "confirm" then
    PlaySound(SOUNDKIT.IG_PLAYER_INVITE, "Dialog", false);
    lftime = lftime + 1
  end

  if lftime >=math.random(20,35) then
    SetCVar ("Sound_EnableSoundWhenGameIsInBG",0)
    macro('/click LFGDungeonReadyDialogEnterDungeonButton')
    lftime = 0
  end    


-------------
--Modifiers--
-------------
  if modifier.alt and castable(SB.MassDispell) then
    return cast(SB.MassDispell, 'ground')
  end
  if modifier.shift and castable(SB.AngelicFeather) and player.buff(SB.AngelicFeather).down then
    return cast(SB.AngelicFeather, 'player')
  end
-------------
----Buff-----
-------------
  local allies_without_my_buff = group.count(function (unit)
    return unit.alive and unit.distance < 40 and unit.buff(SB.PowerWordFortitude).down
  end)
  if allies_without_my_buff > 2 and castable(SB.PowerWordFortitude) then
    return cast(SB.PowerWordFortitude, 'player')
    end
    if player.buff(SB.PowerWordFortitude).down and castable(SB.PowerWordFortitude) then
        return cast(SB.PowerWordFortitude, 'player')
    end
    
end
function interface()
  local settings = {
    key = 'holypal_settings',
    title = 'Holy Pal - Settings',
    width = 250,
    height = 750,
    resize = true,
    show = false,
    template = {
      { type = 'header', text = 'Holy Pal - Settings', align= 'center' },
      { type = 'rule' },
      { type = 'text', text = 'Class Settings' },
      { key = 'fade', type = 'spinner', text = 'Fade', desc = 'Health % to cast at', min = 1, max = 100, step = 5 },
      { key = 'heal', type = 'spinner', text = 'Heal', desc = 'Health % of lowest in Group to Cast at',default = 70, min = 5, max = 100, step = 5 },
      { key = 'sanctifypercent', type = 'spinner', text = 'Holy Word Serenity', desc = 'Health % of lowest in Group to Cast at',default = 50, min = 5, max = 100, step = 5 },
      { key = 'prayerofhealingpercent', type = 'spinner', text = 'Prayer of Healing', desc = 'Health % of Group to Cast at',default = 70, min = 5, max = 100, step = 5 },
      { key = 'prayerofhealingnumberofplayer', type = 'spinner', text = 'Prayer of Healing Targets', desc = 'Number of damaged players near you',default = 3, min = 1, max = 6, step = 1 },
      { key = 'mendingpercent', type = 'spinner', text = 'Prayer of Mending', desc = 'Health % of lowest in Group to cast at',default = 85, min = 5, max = 100, step = 5 },
      { key = 'guardianspirit', type = 'spinner', text = 'Guardian Spirit', desc = 'Health % to Cast at',default = 30, min = 5, max = 100, step = 5 },
      { key = 'guardianspirittarget', type = 'dropdown',
      text = 'GS Target',
      desc = 'Use Guardian Spirit on...',
      default = 'gs_tank',
      list = {
      { key = 'gs_all', text = 'ALL' },
      { key = 'gs_tank', text = 'Only Tanks' },
      }
      },
      { type = 'rule' },
      { type = 'text', text = 'Renew Settings' },
      { key = 'simultaneousrenews', type = 'spinner', text = 'Max Renews', desc = 'Number of Max Simulataneous Renews', default =6, min = 1, max = 40, step = 1 },
      { key = 'renewlowest', type = 'spinner', text = 'Renew Lowest', desc = 'Health % of lowest in Group to cast at', default =85, min = 5, max = 100, step = 5 },
      { key = 'renewtank', type = 'spinner', text = 'Renew Tank', desc = 'Health % of Tank to cast at', default =90, min = 5, max = 100, step = 5 },
      { key = 'renewmoving', type = 'dropdown',
      text = 'Renew while',
      desc = 'Use Renew while...',
      default = 'renew_always',
      list = {
      { key = 'renew_always', text = 'Always' },
      { key = 'renew_moving', text = 'Only Moving' },
      }
      },
      { type = 'rule' },
      { type = 'text', text = 'Flash Heal Settings' },
      { key = 'flashheallowest', type = 'spinner', text = 'Flash Heal Lowest', desc = 'Health % of lowest in Group to cast at', default =60, min = 5, max = 100, step = 5 },
      { key = 'flashhealsurge', type = 'spinner', text = 'Flash Heal Surge of Light', desc = 'Health % of lowest in Group to cast at under Surge of Light', default =75, min = 5, max = 100, step = 5 },
      { key = 'flashhealsurgeemergency', type = 'spinner', text = 'Flash Heal Surge of Light Emergency', desc = 'Health % to not Waste SurgeofLight', default =80, min = 5, max = 100, step = 5 },
      { type = 'rule' },
      { type = 'text', text = 'Emergency Self Heals' },
      { key = 'desperateprayerpercent', type = 'spinner', text = 'Desperate Prayer', desc = 'Health % of Player to Cast at',default = 35, min = 5, max = 100, step = 5 },
      { key = 'flashhealonme', type = 'spinner', text = 'Self Flash Heal', desc = 'Health % of Player to Cast at',default = 25, min = 5, max = 100, step = 5 },
      { key = 'serenetyonme', type = 'spinner', text = 'Self Serenity', desc = 'Health % of Player to Cast at',default = 25, min = 5, max = 100, step = 5 },
      { type = 'rule' },
      { type = 'text', text = 'Apotheosis Settings' },
      { key = 'apotheosisflash', type = 'spinner', text = 'Apotheosis Flash Heal', desc = 'Use Flash Heal while Apotheosis is active',default = 85, min = 5, max = 100, step = 5 },
      { key = 'apotheosisserenetiycd', type = 'spinner', text = 'Apotheosis Serenity CD', desc = 'Use Flash Heal only if Serenity CD is above this',default = 15, min = 5, max = 60, step = 5 },
      { key = 'apotheosispoh', type = 'spinner', text = 'Apotheosis Prayer of Healing', desc = 'Use PoH while Apotheosis is active',default = 90, min = 5, max = 100, step = 5 },
      { key = 'apotheosispohplayers', type = 'spinner', text = 'Apotheosis PoH Targets', desc = 'Number of damaged players near you',default = 3, min = 1, max = 6, step = 1 },


    }
  }

  configWindowtwo = dark_addon.interface.builder.buildGUI(settings)
  local utility = {
    key = 'holypal_utility',
    title = 'Holy Pal - Utility',
    width = 250,
    height = 320,
    resize = true,
    show = false,
    template = {
      { type = 'header', text = 'Holy Pal - Utility', align= 'center' },
      { type = 'rule' },
      { type = 'text', text = 'Dungeon Settings' },
      { key = 'autojoin', type = 'checkbox', text = 'Auto Join', desc = 'Automatically accept Dungeon/Battleground Invites', default = true },
      { type = 'rule' },
      { type = 'text', text = 'Priest Utility' },
      { key = 'levitate', type = 'checkbox', text = 'Levitate', desc = 'Use Levitate during long falls', default = true },
    }
  }

  configWindow = dark_addon.interface.builder.buildGUI(utility)
    dark_addon.interface.buttons.add_toggle({
    name = 'dispel',
    label = 'Auto Dispel',
    on = {
      label = 'Dispel',
      color = dark_addon.interface.color.blue,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.blue, 0.5)
    },
    off = {
      label = 'Dispel',
      color = dark_addon.interface.color.red,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.red, 0.5)
    }
    })
    dark_addon.interface.buttons.add_toggle({
    name = 'dps',
    label = 'Use Damage Spells',
    on = {
      label = 'DPS ON',
      color = dark_addon.interface.color.blue,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.blue, 0.5)
    },
    off = {
      label = 'DPS OFF',
      color = dark_addon.interface.color.red,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.red, 0.5)
    }
  })
    dark_addon.interface.buttons.add_toggle({
    name = 'racial',
    label = 'Use Racials',
    on = {
      label = 'Racials ON',
      color = dark_addon.interface.color.blue,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.blue, 0.5)
    },
    off = {
      label = 'Racials OFF',
      color = dark_addon.interface.color.red,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.red, 0.5)
    }
  })
    dark_addon.interface.buttons.add_toggle({
    name = 'settings',
    label = 'Rotation Settings',
    font = 'dark_addon_icon',
    on = {
      label = dark_addon.interface.icon('cog'),
      color = dark_addon.interface.color.blue,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.blue, 0.5)
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
        --logwindows.parent:Show()
        configWindow.parent:Show()
      end
            if configWindowtwo.parent:IsShown() then
        configWindowtwo.parent:Hide()
      else
        --logwindows.parent:Show()
        configWindowtwo.parent:Show()
      end
    end
  })
end
dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.priest.holy,
    name = 'holypal',
    label = 'PAL: Holy Priest',
    combat = combat,
    resting = resting,
    interface = interface
})