local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.priest
local lftime = 0

-------------
---Spells---
-------------
SB.GiftOftheNaaru = 59544
SB.MendingBuff = 41635
local function combat()
-------------
----Fetch----
-------------
local fade = dark_addon.settings.fetch('holypal_settings_fade', 95)
local simultaneousrenews = dark_addon.settings.fetch('holypal_settings_simultaneousrenews', 6)
local max_renews = group.count(function (unit)
  return unit.alive and unit.distance < 40 and unit.buff(SB.Renew).up
end)
local renewlowest = dark_addon.settings.fetch('holypal_settings_renewlowest', 85)
local renewtank = dark_addon.settings.fetch('holypal_settings_renewtank', 90)
local renewmoving = dark_addon.settings.fetch('holypal_settings_renewmoving', 80)
local flashheallowest = dark_addon.settings.fetch('holypal_settings_flashheallowest', 60)
local flashhealsurge = dark_addon.settings.fetch('holypal_settings_flashhealsurge', 80)
local flashhealsurgeemergency = dark_addon.settings.fetch('holypal_settings_flashhealsurgeemergency', 90)

-------------
--Modifiers--
-------------
  if modifier.alt and castable(SB.MassDispell) then
    return cast(SB.MassDispell, ground)
  end
  if modifier.shift and castable(SB.AngelicFeather) and player.buff(SB.AngelicFeather).down then
    return cast(SB.AngelicFeather, player)
  end
  if modifier.control and castable(SB.DivineHymn) then
    return cast(SB.DivineHymn)
  end
-------------
---Dispel----
-------------
  if toggle('dispel', false) and castable(SB.Purify) and player.dispellable(SB.Purify) then
    return cast(SB.Purify, player)
  end
  local unit = group.dispellable(SB.Purify)
  if unit and unit.distance < 40 then
    return cast(SB.Purify, unit)
  end

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
  if lowest.castable(SB.Renew) and lowest.health.effective <= renewmoving and max_renews <= simultaneousrenews  and lowest.buff(SB.Renew).down and player.moving then
    return cast(SB.Renew, lowest)
  end
  if tank.castable(SB.Renew) and tank.health.effective <= renewmoving and max_renews <= simultaneousrenews and tank.buff(SB.Renew).down and player.moving  then
    return cast(SB.Renew, tank)
  end

  --Flash Heal
  if lowest.castable(SB.FlashHeal) and lowest.health.effective <= flashheallowest then
    return cast(SB.FlashHeal, lowest)
  end
  if castable(SB.FlashHeal) and tank.health.effective <= flashheallowest then
    return cast(SB.FlashHeal, tank)  
  end
  if lowest.castable(SB.FlashHeal) and player.buff(SB.SurgeofLight).up and lowest.health.effective <= flashhealsurge then
    return cast(SB.FlashHeal, lowest)
  end
   if tank.castable(SB.FlashHeal) and player.buff(SB.SurgeofLight).up and tank.health.effective <= flashhealsurge then
    return cast(SB.FlashHeal, tank)
  end
  if lowest.castable(SB.FlashHeal) and player.buff(SB.SurgeofLight).remains <= 3 and lowest.health.effective <= flashhealsurgeemergency then
    return cast(SB.FlashHeal, lowest)
  end
  if lowest.castable(SB.FlashHeal) and player.buff(SB.SurgeofLight).remains <= 3 and tank.health.effective <= flashhealsurgeemergency then
    return cast(SB.FlashHeal, tank)
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
  if player.alive and not player.channeling() and toggle('dps', false) then

  if castable(SB.HolyWordChastise) and target.enemy and target.alive then
    return cast(SB.HolyWordChastise, target)
  end
  if target.enemy and target.alive then
    return cast(SB.Smite, target)
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
local renewmoving = dark_addon.settings.fetch('holypal_settings_renewmoving', 80)





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
    height = 320,
    resize = true,
    show = false,
    template = {
      { type = 'header', text = 'Holy Pal - Settings', align= 'center' },
      { type = 'rule' },
      { type = 'text', text = 'Class Settings' },
      { key = 'fade', type = 'spinner', text = 'Fade', desc = 'Health % to cast at', min = 1, max = 100, step = 5 },
      { type = 'rule' },
      { type = 'text', text = 'Renew Settings' },
      { key = 'simultaneousrenews', type = 'spinner', text = 'Max Renews', desc = 'Number of Max Simulataneous Renews', default =6, min = 1, max = 40, step = 5 },
      { key = 'renewlowest', type = 'spinner', text = 'Renew', desc = 'Health % of lowest to cast at', default =85, min = 5, max = 100, step = 5 },
      { key = 'renewtank', type = 'spinner', text = 'Renew', desc = 'Health % of tank to cast at', default =90, min = 5, max = 100, step = 5 },
      { key = 'renewmoving', type = 'spinner', text = 'Renew', desc = 'Health % to cast Renew while moving', default =80, min = 5, max = 100, step = 5 },
      { type = 'text', text = 'Flash Heal Settings' },
      { key = 'flashheallowest', type = 'spinner', text = 'Flash Heal', desc = 'Health % of lowest to cast at', default =60, min = 5, max = 100, step = 5 },
      { key = 'flashhealsurge', type = 'spinner', text = 'Flash Heal', desc = 'Health % of lowest to cast at under Surge of Light', default =80, min = 5, max = 100, step = 5 },
      { key = 'flashhealsurgeemergency', type = 'spinner', text = 'Flash Heal', desc = 'Health % to not Waste SurgeofLight', default =90, min = 5, max = 100, step = 5 },


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