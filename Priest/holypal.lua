local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.priest

-------------
---Spells---
-------------
SB.GiftOftheNaaru = 59544
SB.MendingBuff = 41635


local function combat()

-------------
--Modifiers--
-------------
    if modifier.alt and castable(SB.MassDispell) then
      return cast(SB.MassDispell, 'ground')
    end

    if modifier.shift and castable(SB.AngelicFeather) and player.buff(SB.AngelicFeather).down then
      return cast(SB.AngelicFeather, 'player')
    end

    if modifier.control and castable(SB.DivineHymn) then
      return cast(SB.DivineHymn)
    end

-------------
---Dispel----
-------------
    if toggle('dispel', false) and castable(SB.Purify) and player.dispellable(SB.Purify) then
        return cast(SB.Purify, 'player')
    end
    local unit = group.dispellable(SB.Purify)
    if unit and unit.distance < 40 then
        return cast(SB.Purify, unit)
    end



end
local function resting()

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
    
    }
  }

  configWindow = dark_addon.interface.builder.buildGUI(utility)

  dark_addon.interface.buttons.add_toggle({
    name = 'settings',
    label = 'Rotation Settings',
    font = 'dark_addon_icon',
    on = {
      label = dark_addon.interface.icon('cog'),
      color = dark_addon.interface.color.blue,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.blue, 0.7)
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
