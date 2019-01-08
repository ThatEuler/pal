-- modifiers:
-- Holding down shift will first cast Magna Totem if you got the talent then/or Earthquake - all at cursor. Shift == AOE
-- Holding down Control will cast stun totem at cursor
-- Holding down ALT will drop your totems - if you got the talent

local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.warlock


local function combat()
end -- end combat


local function resting()
end -- end resting

function interface()
    dark_addon.interface.buttons.add_toggle({
        name = 'DEF',
        label = 'Defensive CD',
        on = {
            label = 'DEF',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'DEF',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
end

dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.warlock.destruction,
    name = 'destro_3man_arena',
    label = 'dev',
    combat = combat,
    resting = resting,
    interface = interface

})