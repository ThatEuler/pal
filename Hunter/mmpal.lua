local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.hunter

--Local Spells not in default spellbook
SB.CarefulAim = 260228
SB.DoubleTap = 260402

local function GroupType()
  return IsInRaid() and "raid" or IsInGroup() and "party" or "solo"
end

local function combat()
  local usetraps = dark_addon.settings.fetch("mmpal_settings_traps", false)
  local usemisdirect = dark_addon.settings.fetch("mmpal_settings_misdirect", false)
  local race = UnitRace("player")

  if target.alive and target.enemy and not player.channeling() then
    auto_shot()
    if usetraps and modifier.shift and castable(SB.FreezingTrap) and spell(SB.FreezingTrap).cooldown == 0 then
      return cast(SB.FreezingTrap, "ground")
    end
    if usetraps and modifier.alt and castable(SB.TarTrap) and spell(SB.TarTrap).cooldown == 0 then
      return cast(SB.TarTrap, "ground")
    end
    if toggle("interrupts") and castable(SB.CounterShot) and spell(SB.CounterShot).cooldown == 0 and target.interrupt(50) then
      return cast(SB.CounterShot, "target")
    end
    if castable(SB.DoubleTap) and spell(SB.DoubleTap).cooldown == 0 and spell(SB.AimedShot).charges >= 1 then
      return cast(SB.DoubleTap)
    end
    if castable(SB.Trueshot) and spell(SB.Trueshot).cooldown and -buff(SB.CarefulAim) then
      return cast(SB.Trueshot)
    end
    if castable(SB.AimedShot) and spell(SB.AimedShot).charges >= 1 and not -buff(SB.PreciseShots) then
      return cast(SB.AimedShot, "target")
    end
    if castable(SB.ArcaneShot) and spell(SB.ArcaneShot).cooldown == 0 and -buff(SB.PreciseShots) then
      return cast(SB.ArcaneShot, "target")
    end
    if castable(SB.RapidFire) and spell(SB.RapidFire).cooldown == 0 then
      return cast(SB.RapidFire, "target")
    end
    if castable(SB.SteadyShot) and spell(SB.SteadyShot).cooldown == 0 then
      return cast(SB.SteadyShot, "target")
    end
  end
end

local function resting()
  local group_type = GroupType()
  local lfg = GetLFGProposal()
  local hasData = GetLFGQueueStats(LE_LFG_CATEGORY_LFD)
  local hasData2 = GetLFGQueueStats(LE_LFG_CATEGORY_LFR)
  local hasData3 = GetLFGQueueStats(LE_LFG_CATEGORY_RF)
  local hasData4 = GetLFGQueueStats(LE_LFG_CATEGORY_SCENARIO)
  local hasData5 = GetLFGQueueStats(LE_LFG_CATEGORY_FLEXRAID)
  local hasData6 = GetLFGQueueStats(LE_LFG_CATEGORY_WORLDPVP)
  local bgstatus = GetBattlefieldStatus(1)
  local autojoin = dark_addon.settings.fetch("mmpal_settings_autojoin", true)
  local usemisdirect = dark_addon.settings.fetch("mmpal_settings_misdirect")
  local petselection = dark_addon.settings.fetch("mmpal_settings_petselector")

  if not pet.exists then
    if petselection == "key_1" then
      return cast(SB.CallPet1)
    elseif petselection == "key_2" then
      return cast(SB.CallPet2)
    elseif petselection == "key_3" then
      return cast(SB.CallPet3)
    elseif petselection == "key_4" then
      return cast(SB.CallPet4)
    elseif petselection == "key_5" then
      return cast(SB.CallPet5)
    end
  end
  if pet.exists and not pet.alive and castable(SB.RevivePet) and spell(SB.RevivePet).cooldown == 0 then
    return cast(SB.RevivePet)
  end
  if pet.alive and pet.health.percent <= 70 and castable(SB.MendPet) and spell(SB.MendPet).cooldown == 0 then
    return cast(SB.MendPet)
  end
end

function interface()
  local settings = {
    key = "mmpal_settings",
    title = "Marksmanship Hunter by Pal Team",
    width = 300,
    height = 380,
    fontheight = 10,
    resize = true,
    show = false,
    template = {
      {type = "header", text = "Pal Settings"},
      {type = "rule"},
      {type = "text", text = "Rotation: mmpal    Author: mPixels    Version: 81502"},
      {type = "text", text = "Class: Hunter    Spec: Marksmanship    Build: 1123232"},
      {type = "rule"},
      {type = "header", text = "General Settings"},
      {
        key = "autojoin",
        type = "checkbox",
        text = "Auto Join",
        desc = "Automatically accept Dungeon/Battleground Invites",
        default = true
      },
      {type = "rule"},
      {
        key = "traps",
        type = "checkbox",
        text = "Traps",
        desc = "Auto use Traps",
        default = false
      },
      {type = "rule"},
      {type = "header", text = "Pet Management"},
      {
        key = "petselector",
        type = "dropdown",
        text = "Pet Selector",
        desc = "select your active pet",
        default = "key_3",
        list = {
          {key = "key_1", text = "Pet 1"},
          {key = "key_2", text = "Pet 2"},
          {key = "key_3", text = "Pet 3"},
          {key = "key_4", text = "Pet 4"},
          {key = "key_5", text = "Pet 5"}
        }
      }
    }
  }
  configWindow = dark_addon.interface.builder.buildGUI(settings)

  dark_addon.interface.buttons.add_toggle(
    {
      name = "racial",
      label = "Use Racial",
      on = {
        label = "Racial",
        color = dark_addon.interface.color.orange,
        color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
      },
      off = {
        label = "Racial",
        color = dark_addon.interface.color.grey,
        color2 = dark_addon.interface.color.dark_grey
      }
    }
  )

  dark_addon.interface.buttons.add_toggle(
    {
      name = "settings",
      label = "Rotation Settings",
      font = "dark_addon_icon",
      on = {
        label = dark_addon.interface.icon("cog"),
        color = dark_addon.interface.color.cyan,
        color2 = dark_addon.interface.color.dark_cyan
      },
      off = {
        label = dark_addon.interface.icon("cog"),
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
    }
  )
end

dark_addon.rotation.register(
  {
    spec = dark_addon.rotation.classes.hunter.marksmanship,
    name = "mmpal",
    label = "Marksmanship Hunter by Pal Team",
    combat = combat,
    resting = resting,
    interface = interface
  }
)
