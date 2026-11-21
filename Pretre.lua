-- ============================================================
--  Forever Cast Bars — pack Prêtre
--  Deux cadres : sacré (filigrane d'or qui s'allume) et ombre (runes
--  du Vide qui s'allument). Effets des prototypes prêtre, composés
--  avec le kit de la base (PropsKit.lua). Exige ForeverCastBars.
-- ============================================================

if not (FCB and FCB.Looks and FCB.Looks.RegisterPack and FCB.Props and FCB.Props.Kit) then return end

local M = "Interface\\AddOns\\ForeverCastBars_Pretre\\textures\\"
local B = FCB.TEX_PATH .. "crafts\\"
local Props, K = FCB.Props, FCB.Props.Kit
local Put, END, PutWH = Props.Put, Props.END, K.PutWH
local sin, pi, min, max = math.sin, math.pi, math.min, math.max
local GOLD, WHITE, VOID, MANA = { 1, .88, .5 }, { 1, .97, .85 }, { .7, .35, 1 }, { .45, .6, 1 }
local function Y(c) return c.cy + 4 end
local function EX(c) return END(c) - 12 end
local function Part(slots, Draw) return { slots = slots, Draw = Draw } end
local function R(name, parts) Props.RegisterKit("priest_" .. name, parts) end

-- entraves : des anneaux de lumière se referment autour de la pointe
local SHACKLES = Part(3, function(st, c, o)
    local k = c.te and 1 or c.p; local x = min(c.frontX, EX(c) - 10)
    for i = 0, 2 do
        local r = (8 + 18 * (1 - k)) * (1 + i * .25)
        PutWH(st, o + i + 1, B .. "P_Bubble", x, Y(c), r * 2, r, c.t * (1 + i) * (i % 2 == 1 and 57 or -57), c.te and max(0, 1 - c.te / .5) or .9, WHITE, true)
    end
end)
-- fouet / contrôle mental : tentacules d'ombre ondulants de l'icône vers la pointe (points lumineux)
local function Tendrils(col, n)
    local DOTS = 9
    return Part(n * DOTS, function(st, c, o)
        if c.te and c.te > .4 then return end
        local x0, x1 = c.iconX + 15, min(c.frontX, EX(c)); local a = c.te and 1 - c.te / .4 or 1
        for i = 0, n - 1 do
            for j = 0, DOTS - 1 do
                local u = (j + 1) / (DOTS + 1)
                local y = Y(c) + sin(j * 1.6 - c.t * 7 + i * 1.6) * (5 + i * 2) * sin(pi * u)
                Put(st, o + i * DOTS + j + 1, B .. "P_Glow", x0 + (x1 - x0) * u, y, 16 - 3 * i, 0, a, { .5 + col[1] * .5, .5 + col[2] * .5, .5 + col[3] * .5 }, true)   -- cœur clair : lisible sur le violet
            end
        end
    end)
end
-- attaque mentale : ondes psychiques à la pointe, de plus en plus rapides
local PULSE = Part(3, function(st, c, o)
    local k = c.te and 1 or c.p; local hz = 1 + 3 * k; local x = min(c.frontX, EX(c) - 10)
    for j = 0, 2 do
        local u = (c.t * hz + j / 3) % 1; local r = 4 + 20 * u
        PutWH(st, o + j + 1, B .. "P_Bubble", x, Y(c), r * 2, r * 1.4, 0, (1 - u) * k * (c.te and max(0, 1 - c.te / .4) or 1), VOID, true)
    end
end)

local function Single(size)
    return { K.Rise(WHITE, "P_Glow", 8, { speed = 30, size = 5 }), K.Converge(WHITE, 8 + size), K.IconGlow(WHITE), K.Pillar(WHITE, { width = 30 + size * 3 }), K.Burst(WHITE, "P_Cross", 10, 60) }
end
local function With(list, ...) for _, p in ipairs({ ... }) do list[#list + 1] = p end return list end

R("smite",       { K.Converge(GOLD, 12), K.TipGlow(GOLD, 45), K.Pillar({ 1, .95, .7 }, { width = 40 }), K.Ring(GOLD, 160) })
R("lheal",       Single(0))
R("heal",        Single(2))
R("gheal",       With(Single(4), K.RuneCircle(GOLD, { at = "icon", r0 = 26, r1 = 36, flat = .45, dy = 0, spin = 1 })))
R("flash",       { K.FromIcon(WHITE, "P_Glow", 12, 1.6), K.TipGlow(WHITE, 40, 10), K.Flash(WHITE, 180, .2), K.Burst(WHITE, "P_Star", 10, 50) })
R("prayer",      { K.Halos(WHITE, 5), K.Rise(WHITE, "P_Cross", 10, { speed = 30, size = 6 }), K.Flash(WHITE, 280) })
R("holyfire",    { K.Rise({ 1, .85, .5 }, "P_Flame", 10, { speed = 40, size = 9 }), K.FrontSprite("P_Flame", 30, { grow = { .6, 1.6 }, col = { 1, .85, .45 }, add = true }), K.Converge({ 1, .9, .55 }, 10), K.TipGlow({ 1, .8, .4 }, 50), K.Pillar({ 1, .85, .5 }, { width = 45 }), K.Ring({ 1, .85, .5 }, 180) })
R("mindblast",   { PULSE, K.Converge(VOID, 10), K.TipGlow(VOID, 45), K.Ring(VOID, 180), K.Flash({ .85, .6, 1 }, 180) })
R("mindcontrol", { Tendrils(VOID, 3), K.RuneCircle(VOID), K.Ring(VOID, 160) })
R("mindflay",    { Tendrils({ .75, .45, 1 }, 3), K.ToIcon(VOID, "P_Glow", 8, .7) })
R("soothe",      { K.Orbit({ .8, .8, 1 }, "P_Smoke", 6, { r = 22, speed = 1.5, size = 16 }), K.TipGlow({ .7, .7, 1 }, 40, 2), K.Ring({ .8, .8, 1 }, 140) })
R("manaburn",    { K.Rise(MANA, "P_Flame", 10, { speed = 45, size = 8 }), K.Converge({ .5, .65, 1 }, 10), K.TipGlow(MANA, 45), K.Burst({ .5, .65, 1 }, "P_Flame", 12, 60) })
R("shackle",     { SHACKLES, K.Ring(WHITE, 140) })
R("resurrection", { K.Rise(WHITE, "P_Glow", 12, { speed = 25, size = 6 }), K.Converge(WHITE, 12, "P_Star", 60), K.Pillar(WHITE, { atEnd = false, width = 40 }), K.Pillar({ 1, 1, .9 }, { width = 70 }), K.Burst(WHITE, "P_Cross", 12, 70) })
R("starshards",  { K.Fall({ .9, .92, 1 }, "P_Star", 14, { speed = 70, size = 9 }), K.ToIcon({ .8, .85, 1 }, "P_Star", 8, .5, 9) })
R("binding",     { K.FromIcon(WHITE, "P_Glow", 10, 1.2), K.ToIcon(WHITE, "P_Glow", 10, 1.2), K.Flash(WHITE, 200), K.Burst(WHITE, "P_Cross", 10, 50) })
R("penance",     { K.TipGlow(GOLD, 40, 6), K.FromIcon(GOLD, "P_Heat", 6, 1.5, 12) })
R("confound",    { K.Flash({ 1, 1, 1 }, 300, .3), K.Burst({ 1, 1, 1 }, "P_Star", 16, 80) })

local HF, SF = B .. "Fill_holy", B .. "Fill_shadow"
local function H(props, veil, extra)
    local L = { family = "priest_holy", fill = HF, props = { "priest_" .. props }, veil = veil or GOLD, veilAlpha = { .1, .25 } }
    for k, v in pairs(extra or {}) do L[k] = v end
    return L
end
local function S(props, veil, extra)
    local L = H(props, veil or VOID, extra); L.family, L.fill = "priest_shadow", SF
    return L
end
local FAST = { wakeCurve = 1.4 }
FCB.Looks:RegisterPack(M, {
    families = { "priest_holy", "priest_shadow" },
    spells = {
        pr_smite = H("smite"), pr_lheal = H("lheal"), pr_heal = H("heal"), pr_gheal = H("gheal"),
        pr_flash = H("flash", nil, FAST), pr_prayer = H("prayer"), pr_holyfire = H("holyfire"),
        pr_mindblast = S("mindblast", nil, FAST), pr_mindcontrol = S("mindcontrol"), pr_mindflay = S("mindflay"),
        pr_soothe = S("soothe", { .6, .6, 1 }, FAST), pr_manaburn = S("manaburn", { .45, .55, 1 }),
        pr_shackle = H("shackle", nil, FAST), pr_resurrection = H("resurrection"), pr_starshards = H("starshards", { .8, .85, 1 }),
        pr_binding = H("binding", nil, FAST), pr_penance = H("penance"), pr_confound = H("confound", { 1, 1, 1 }, { wakeCurve = 1 }),
    },
})
