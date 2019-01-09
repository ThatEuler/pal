-- modifiers:


local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.warlock
local specLookup = dark_addon.rotation.specs
local function combat()

    local dps1 = nil
    local dps2 = nil
    local healer = nil


    --general util
    --distance to each
    --class of each healer, dps1 and dps2



    for i = 1, 3 do
        if UnitExists('arena' .. i) then
            local spec = specLookup[GetInspectSpecialization('arena' .. i)]
            print("arena " .. i "is an " .. spec.name .. " role: " .. spec.role)

        end
    end


    -- loop  1-3  arenaN    arena1 arena2 arena3

    for i = 1, 3 do
        if UnitExists('arena' .. i) and IsSpellInRange('Immolate', 'arena' .. i) == 1 and not isCC('arena' .. i) then
            local iTarget = dark_addon.environment.conditions.unit('arena' .. i)
            if iTarget.debuff(SB.Immolate).down then
                return cast(SB.Immolate, iTarget)
            end
        end
    end

    -- ground spell?  2)Cast [Cataclysm] (spell152108) : [when there are more than 2 enemy players are grouped up  or standing within 8 yard range of each other.  But Do not use if the other enemy that is within 8 yard of  it have the following   Debuff :Freezing trap (spell:187650)  or Hex (spell:51514)  or Sap(spell:6770)  or Gouge :(spelll :76582)  Repentance(spell:29511) Polymorph (spell :118)(edited)


    if target.debuff(SB.Conflagrate).down and target.castable(SB.Conflagrate) then
        return cast(SB.Conflagrate, target)
    end

    if target.castable(SB.Incinerate) then
        return cast(SB.Incinerate, target)
    end

    --[[
5) use Havoc(spell:80240)  On other DPS that is not your  current target.  ALso must have this Conditions before havoc on other Dps that is not your current target..
1) Conflagrate (spell:17962) off  cooldown.11sec cd)               2) Mortal Coil (spell: 6789) off cooldown 45 sec cooldown)              3)  must have 4 shards.                                   IN 3V3 Arena . You want to use it On other DPS.  so next Conflagrate (spell:17962)with pvp talent of Entrenched in flame (spell : 233581)  .
Followed by casting Chaos Bol (spell:77069)  t on the target  that has no havoc de buff on them.  next step cast Mortal Coil (spell: 6789)  on the current target. to Double Mortal Coil (spell: 6789)  both targets. Followed BY   Chaos Bol (spell:77069) on the target.
6) keep Building shards by have Immolate on all targets. and Conflagrate (spell:17962) and Incinerate]target.  also casting Cataclysm off cooldown when 2 enemys are standing within 7 yard of each other. Cataclysom must be Done manually!! so a key bind for using it. when  its pressed it will drop it where mouse  is.


]]


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