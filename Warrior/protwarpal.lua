---  Protection Warrior for 8.1 by Laksmackt - 01/2019
---
--- Holding Shift =
--- Supported talents:


local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.warrior
local PB = dark_addon.rotation.spellbooks.purgeables
local race = UnitRace("player")
local badguy = UnitClassification("target")

--missing spells
SB.RevengeProc = 5302

local function combat()

    if toggle('multitarget', false) then
        enemyCount = enemies.around(8)
    elseif toggle('multitarget', true) then
        enemyCount = 1
    end


    -----------------------------
    --- Reading from settings
    -----------------------------

    local shoutInt = dark_addon.settings.fetch('protwarrior_settings_shoutInt', true)
    local shockwaveInt = dark_addon.settings.fetch('protwarrior_settings_shockwaveInt', true)
    local stormboltInt = dark_addon.settings.fetch('protwarrior_settings_stormboltInt', true)
    local usehealthstone = dark_addon.settings.fetch('protwarrior_settings_usehealthstone', true)
    local healthPop = dark_addon.settings.fetch('protwarrior_settings_healthPop', 35)
    local usehealpot = dark_addon.settings.fetch('protwarrior_settings_usehealpot', true)
    local useTrinkets = dark_addon.settings.fetch('protwarrior_settings_useTrinkets', true)

    if not target.alive or not target.enemy then
        return
    end

    if target.enemy and target.distance <= 8 then
        auto_attack()
    end
    -------------------------
    --- INTERRUPT OPTIONS ---
    -------------------------

    if toggle('interrupts', false) and target.interrupt(math.random(25, 75)) and target.distance < 8 then
        if target.castable(SB.Pummel) then
            return cast(SB.Pummel, 'target')
        elseif shoutInt and castable(SB.IntimidatingShout) then
            return cast(SB.IntimidatingShout)
        elseif shockwaveInt and castable(SB.ShockWave) then
            return cast(SB.ShockWave)
        elseif stormboltInt and target.castable(SB.StormBolt) then
            return cast(SB.StormBolt, target)
        end
    end

    -------------------------
    --- Trinkets /Healthstones
    -------------------------
    local Trinket13 = GetInventoryItemID("player", 13)
    local Trinket14 = GetInventoryItemID("player", 14)

    if useTrinkets then
        --doomsfury trinket
        if Trinket13 == 161463 and player.buff(SB.Avatar).up and GetItemCooldown(161463) == 0 then
            macro('/use 13')
        end
        if Trinket14 == 161463 and player.buff(SB.Avatar).up and GetItemCooldown(161463) == 0 then
            macro('/use 14')
        end
        --Jes Howler (159622)
        if Trinket13 == 159622 and target.enemy and target.distance < 8 and target.health.percent > 50 and GetItemCooldown(159627) == 0 and -spell(SB.Avatar) > 10 and player.buff(SB.Avatar).down then
            macro('/use 13')
        end
        if Trinket14 == 159622 and target.enemy and target.distance < 8 and target.health.percent > 50 and GetItemCooldown(159627) == 0 and -spell(SB.Avatar) > 10 and player.buff(SB.Avatar).down then
            macro('/use 14')
        end
        --Razdunk big red button  (159611)
        if Trinket13 == 159611 and target.enemy and target.distance < 8 and target.health.percent > 50 and GetItemCooldown(159611) == 0 and -spell(SB.Avatar) > 10 and player.buff(SB.Avatar).down then
            macro('/use [@player] 13 ')
        end
        if Trinket14 == 159611 and target.enemy and target.distance < 8 and target.health.percent > 50 and GetItemCooldown(159611) == 0 and -spell(SB.Avatar) > 10 and player.buff(SB.Avatar).down then
            macro('/use [@player] 14 ')
        end
    end


    --Health stone
    if usehealthstone and player.health.percent < healthPop and GetItemCount(5512) >= 1 and GetItemCooldown(5512) == 0 then
        macro('/use Healthstone')
    end
    --health pot
    if usehealpot == true and GetItemCount(152494) >= 1 and player.health.percent < healthPop and GetItemCooldown(5512) > 0 then
        macro('/use Coastal Healing Potion')
    end

    --done with equipment stuff
    -------------------------
    --- Cool Downs
    -------------------------
    --avatar - on CD, but dont pop if mobs almost ead or trash - cant wait up to 4 seconds to get shield slam in
    if toggle('cooldowns', false) and target.time_to_die > 8 and badguy ~= "normal" and badguy ~= "minus" then
        if castable(SB.Avatar) and (-spell(SB.ShieldSlam) == 0 or -spell(SB.ShieldSlam) > 4) then
            return cast(SB.Avatar)
        end
        --Intercept/charge  (always keep one charge for movement) ..might need to rethink this ..not sure ...might get us in trouble ;)
        if IsInRaid() == false and target.castable(SB.Intercept) and player.spell(SB.Intercept).count > 1 then
            return cast(SB.Intercept, target)
        end
        --TODO: need to do this only if we took talent booing voice - otherwise it becomes a defensive CD
        if castable(SB.DemoralizingShout) and (-spell(SB.ShieldSlam) == 0 or -spell(SB.ShieldSlam) > 4) then
            return cast(SB.DemoralizingShout)
        end
    end

    -------------------------
    --- single Target Standard Rotation
    -------------------------
    if enemyCount == 1 and target.enemy and target.distance <= 8 then
        if target.castable(SB.ShieldSlam) then
            return cast(SB.ShieldSlam, target)
        elseif target.castable(SB.Revenge) and player.buff(SB.RevengeProc).up then
            return cast(SV.Revenge, target)
        elseif castable(SB.ThunderClap) then
            return cast(SB.ThunderClap)
        elseif target.castable(SB.Devastate) then
            return cast(SB.Devastate, target)
        end
    end

    -------------------------
    --- multi Target Standard Rotation
    -------------------------
    if enemyCount >= 2 and target.enemy and target.distance <= 8 then
        if castable(SB.ThunderClap) then
            return cast(SB.ThunderClap)
        elseif player.health.percent >= 50 and target.castable(SB.Revenge) then
            return cast(SB.Revenge, target)
        elseif target.castable(SB.ShieldSlam) then
            return cast(SB.ShieldSlam, target)
        elseif target.castable(SB.Devastate) then
            return cast(SB.Devastate, target)
        end
    end


end

local function resting()




end

local function interface()
    local settings = {
        key = 'protwarrior_settings',
        title = 'Protection Warrior - the REAL tank!',
        width = 250,
        height = 380,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = '               Protection Warrior - the REAL tank!' },
            { type = 'text', text = 'Everything on the screen is LIVE.  As you make changes, they are being fed to the engine.' },
            { type = 'rule' },
            { type = 'text', text = 'General Settings' },
            { key = 'usehealthstone', type = 'checkbox', text = 'Healthstone', desc = 'Use Healthstone', "true" },
            { key = 'useTrinkets', type = 'checkbox', text = 'Auto Trinket', desc = '', "true" },

            { key = 'healthPop', type = 'checkspin', text = '', desc = 'Auto use Healthstone/Healpot at health %', min = 5, max = 100, step = 5 },
            -- { key = 'input', type = 'input', text = 'TextBox', desc = 'Description of Textbox' },
            { key = 'intpercent', type = 'spinner', text = 'Interrupt %', desc = '% cast time to interrupt at', min = 5, max = 100, step = 5 },
            { type = 'rule' },
            { type = 'text', text = 'Interrupts' },
            { key = 'shoutInt', type = 'checkbox', text = 'Stun', desc = 'Use shout as an interrupt' },
            { key = 'shockwaveInt', type = 'checkbox', text = 'Stun', desc = 'Use shockwave as an interrupt', "true" },
            { key = 'stormboltInt', type = 'checkbox', text = 'Stun', desc = 'Use Storm Bolt as an interrupt' "true" },
            { key = 'autoRacial', type = 'checkbox', text = 'Racial', desc = 'Use Racial on CD (Blood Elf only)', "true" },
            { type = 'rule' },
            { key = 'useTrinkets', type = 'checkbox', text = 'Use Trinkets?', desc = '' },
            { type = 'rule' },
        }
    }

    configWindow = dark_addon.interface.builder.buildGUI(settings)

    dark_addon.interface.buttons.add_toggle({
        name = 'XxX',
        label = 'XxX',
        on = {
            label = 'XxX',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'xXx',
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


--[[

4.1. Shield Block

Shield Block Icon Shield Block is your primary active mitigation ability. In the vast majority of situations, most of the damage you will take is blockable. As such, keeping Shield Block up as much as possible is key to smoothing out damage and helping you survive. Shield Block scales with the damage you are taking since it is a percent reduction to damage rather than a flat amount like Ignore Pain Icon Ignore Pain is.

It is important to understand the difference between overall Shield Block Icon Shield Block uptime and effective uptime. You want to have as much effective Shield Block uptime as possible. All that means is having Shield Block up when you are tanking something that actually melees you.

Essentially, anytime you are tanking something, you should be keeping Shield Block Icon Shield Block up as much as possible. It should still, however, be used intelligently, much like you would use major cooldowns. Timing is important, so there are a few things to look out for in this regard:

Shield Block Icon Shield Block works against all melee attacks (as in, auto-attacks/white hits), but there are also many boss abilities/mechanics that are blockable as well. Sometimes, things that you would expect to be blockable are not, and things that you would not expect to be blockable are. You simply have to have knowledge of what these blockable mechanics are. The point here is that if you do know a higher damage ability is blockable, you are much better off delaying Shield Block so that the last bit of its duration blocks that ability.
For further benefit, you can time Shield Block Icon Shield Block with the enemy's melee swings. Most enemies have a swing timer between 1.5 and 2 seconds. If you cast Shield Block right after a melee, you essentially just lost 2 seconds of effective uptime. Sometimes it can be difficult to tell when an enemy is actually melee attacking you, so this point is not super important, but can be beneficial if done properly.
Also be aware of the enemy's spell casts/channels. If the boss is about to spend 5 seconds casting a spell, you should delay Shield Block Icon Shield Block accordingly.
Similar to the first point, but if you know an enemy is about to deal increased damage, you should delay Shield Block Icon Shield Block for those periods as well. For example, in Mythic+, enemies deal significantly more damage once they hit 30% health if the Raging Icon Raging affix is active. While this is not a specific ability, its a mechanic you should be aware of and adjust Shield Block usage around.
If you are not currently tanking, and there is a good amount of time before you do tank again, use Shield Block Icon Shield Block to increase Shield Slam Icon Shield Slam's damage. Just be sure to time it in such a way that as you are about to tank again, you have close to 2 charges of Shield Block, so you can maximize effective uptime.

As said above, Shield Block Icon Shield Block is your primary active mitigation ability. It takes priority over Ignore Pain Icon Ignore Pain assuming you are taking blockable damage (which is almost always).

4.1.1. Last Stand

When using Bolster Icon Bolster, Last Stand Icon Last Stand should be used like Shield Block Icon Shield Block assuming you do not need Last Stand for a specific mechanic. You should do your best to not overlap Last Stand and Shield Block, as it does not add to Shield Block's duration. Having them both up at the same time provides no additional benefit. Since Last Stand lasts 15 seconds, it gives you the time to gain very close to, or a full Shield Block charge (depending on your Haste). So if used when you have a charge of Shield Block available, you risk wasting a bit of Shield Block cooldown time. Essentially, once you have used both charges of Shield Block and the actual Shield Block buff has expired, further increase your effective block uptime by using Last Stand.

4.2. Ignore Pain

Ignore Pain Icon Ignore Pain reduces damage by a flat amount, and with its current tuning, is much weaker than Shield Block Icon Shield Block. As such, it should be used in addition to Shield Block, not in place of it.

Shield Block Icon Shield Block is limited by its cooldown, where Ignore Pain Icon Ignore Pain is simply limited by the amount of Rage you have available. So, once you have Shield Block up and on cooldown, spend your remaining Rage on Ignore Pain, making sure you save enough Rage to use Shield Block once it comes off cooldown. More or less, Ignore Pain should be used to further smooth out your damage intake.

Just like Shield Block Icon Shield Block though, it can and should be used intelligently if doing so provides a benefit.

It is very important to track your current absorb amount so you are not spending Rage on Ignore Pain Icon Ignore Pain if you are at, or close to, the cap. Since Ignore Pain's cap is 1.3 times Ignore Pain on cast, you generally should not cast Ignore Pain again until your absorb is close to depleting. This WeakAura tracks your current absorb and cap.
If you are not tanking, and are taking very little or no damage, do not use your Rage on Ignore Pain Icon Ignore Pain. Depending on how long you are not tanking for, it will simply expire, wasting that Rage. Instead, try to cast an Ignore Pain right before you start tanking again. If you are taking damage while not tanking, cast Ignore Pain as needed to help out your healers.
While generally speaking you will want to use Ignore Pain Icon Ignore Pain to smooth out your damage intake, it can also be very important to pool your Rage and cast Ignore Pain right before a large spike of damage, increasing the chance that you survive that spike.
Additionally, if you are ever in the extremely rare situation where there is very, very little blockable damage, or none at all, you will of course want to prioritize Ignore Pain Icon Ignore Pain over Shield Block Icon Shield Block.

5. Rotation during Avatar

This section only applies if you are using Unstoppable Force Icon Unstoppable Force.

With Unstoppable Force Icon Unstoppable Force, when you cast Avatar Icon Avatar, your ability priority stays the same, but you have to approach it in a different way.

During Avatar Icon Avatar, Thunder Clap Icon Thunder Clap is available every other global cooldown. This means that you will be rotating between Thunder Clap and another ability based on the ability priority. For example, if you get lucky and many of your Thunder Clap casts reset Shield Slam Icon Shield Slam, you will find yourself alternating between Thunder Clap and Shield Slam.

As another example, you might have a cast sequence that looks like this: Shield Slam Icon Shield Slam, Thunder Clap Icon Thunder Clap, Shield Slam Icon Shield Slam, Thunder Clap Icon Thunder Clap, Revenge Icon Revenge (free), Thunder Clap Icon Thunder Clap, Ignore Pain Icon Ignore Pain...

Again, your ability priority does not change. Shield Slam Icon Shield Slam is still above Thunder Clap Icon Thunder Clap. Just be aware that during Avatar Icon Avatar, Thunder Clap has a significantly reduced cooldown and adjust accordingly.

Also, it is very easy to Rage cap during Avatar Icon Avatar, so be ready to dump Rage into Ignore Pain Icon Ignore Pain / Revenge Icon Revenge.

If going purely for damage, Thunder Clap Icon Thunder Clap takes priority over Shield Slam Icon Shield Slam. This is true for single-target as well, with the exception being that if and only if Shield Block Icon Shield Block is up, Shield Slam deals more damage on single-target.

6. Cooldown Usage for Protection Warriors

As a Protection Warrior, you have a number of defensive cooldowns. Using your defensive cooldowns properly is extremely important. You want to plan out your cooldowns before going into an encounter and maximize their usage as much as possible. Outlined below are your various defensive cooldowns and how they should be used. For more info on cooldown usage in general, see the mistakes page.

6.1. Last Stand

Last Stand Icon Last Stand can and should be used in two different ways depending on the situation. With Bolster Icon Bolster, Last Stand should be used to extend effective block uptime as outlined above in the Shield Block Icon Shield Block section. If there are many high-damage mechanics or if you are able to have Shield Block up for the majority of your active tanking time, then Last Stand should instead be used as an emergency cooldown - if your health drops to a dangerously low level unexpectedly - or as a pre-emptive cooldown to prepare for a large damage spike.

If you are not running Bolster Icon Bolster, then simply use it as an emergency or preemptive cooldown.

6.2. Shield Wall

Shield Wall Icon Shield Wall should be used to prepare for a large damage spike, or during periods of high damage. It is not recommended to use it if your health suddenly drops low, as it does nothing to get your health back up, but in situations where you have nothing else, you want to use it if it increases your chance to survive.

6.3. Demoralizing Shout

With Booming Voice Icon Booming Voice, Demoralizing Shout Icon Demoralizing Shout should be used on cooldown and for damage purposes. Its cooldown is fairly short, particularly with Anger Management Icon Anger Management, so you will have fairly high uptime on the damage reduction. More often than not you will have it up at a good time, helping you smooth out damage.


]]