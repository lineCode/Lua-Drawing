SCREEN_BPP      = 16
SCREEN_WIDTH    = 640
SCREEN_HEIGHT   = 480

COLOR = {
    RED     = 1,
    BLUE    = 2,
    YELLOW  = 3,
    GREEN   = 4,
    VIOLETTE= 5,
    CYAN    = 6,
    BLACK   = 7,
    GRAY    = 8,
    PALETTE = 5
}
Max_palette = 7

COLORS_RGB = {
     {196,40,40,254},   -- rot
     {40,40,196,254},   -- blau
     {196, 196, 40,254},-- gelb
     {40, 196, 40,254}, -- gruen
     {196,40,196,254},  -- violet
     {40, 196, 40,254}, -- cyan
     {40,40,40,255,254},-- black
     {196,196,196,254}, -- grau
}

local function parse(x, y, w, h, color)
    local result = {x=0, y=0, w=0, h=0, r=0, g=0, b=0, a=0}
    if not(x==nil) then result.x = x end
    if not(y==nil) then result.y = y end
    if not(w==nil) then result.w = w end
    if not(h==nil) then result.h = h end
    if not(COLORS_RGB[color][1]==nil) then result.r = COLORS_RGB[color][1] end
    if not(COLORS_RGB[color][2]==nil) then result.g = COLORS_RGB[color][2] end
    if not(COLORS_RGB[color][3]==nil) then result.b = COLORS_RGB[color][3] end
    if not(COLORS_RGB[color][4]==nil) then result.a = COLORS_RGB[color][4] end
    return result
end

local function init_actor(x, y, w, h, color)
    local Actor = {
        id = 0,
        color = GRAY,
        render = parse(x, y, w, h, color),
        tweens = {}
    }
    return Actor
end

local function init_tween(credit, target)
    local Tween = {
        credit= {x=0, y=0, w=0, h=0, r=0, g=0, b=0, a=0},
        target= {x=0, y=0, w=0, h=0, r=0, g=0, b=0, a=0},
        speed = 4
    }
    if not(credit==nil) then
        Tween.credit = credit
    end
    if not(target==nil) then
        Tween.target = target
    end
    return Tween
end

local function actor_add_tween(actor, x, y, w, h, color)
    local tween = init_tween(actor.render, parse(x, y, w, h, color))
    table.insert(actor.tweens, tween)
end

local function tween_logic(actor)
    if actor.tweens[1]==nil then
        do return end
    end
    local running = false

    if (actor.tweens[1].credit.x - actor.tweens[1].target.x) > actor.tweens[1].speed then
        actor.tweens[1].credit.x = actor.tweens[1].credit.x - actor.tweens[1].speed; running = true
    elseif (actor.tweens[1].credit.x - actor.tweens[1].target.x) < -actor.tweens[1].speed then
        actor.tweens[1].credit.x = actor.tweens[1].credit.x + actor.tweens[1].speed; running = true
    end

    if (actor.tweens[1].credit.y - actor.tweens[1].target.y) > actor.tweens[1].speed then
        actor.tweens[1].credit.y = actor.tweens[1].credit.y - actor.tweens[1].speed; running = true
    elseif (actor.tweens[1].credit.y - actor.tweens[1].target.y) < -actor.tweens[1].speed then
        actor.tweens[1].credit.y = actor.tweens[1].credit.y + actor.tweens[1].speed; running = true
    end

    if (actor.tweens[1].credit.w - actor.tweens[1].target.w) > actor.tweens[1].speed then
        actor.tweens[1].credit.w = actor.tweens[1].credit.w - actor.tweens[1].speed; running = true
    elseif (actor.tweens[1].credit.w - actor.tweens[1].target.w) < -actor.tweens[1].speed then
        actor.tweens[1].credit.w = actor.tweens[1].credit.w + actor.tweens[1].speed; running = true
    end

    if (actor.tweens[1].credit.h - actor.tweens[1].target.h) > actor.tweens[1].speed then
        actor.tweens[1].credit.h = actor.tweens[1].credit.h - actor.tweens[1].speed; running = true
    elseif (actor.tweens[1].credit.h - actor.tweens[1].target.h) < -actor.tweens[1].speed then
        actor.tweens[1].credit.h = actor.tweens[1].credit.h + actor.tweens[1].speed; running = true
    end

    if (actor.tweens[1].credit.r - actor.tweens[1].target.r) > actor.tweens[1].speed then
        actor.tweens[1].credit.r = actor.tweens[1].credit.r - actor.tweens[1].speed; running = true
    elseif (actor.tweens[1].credit.r - actor.tweens[1].target.r) < -actor.tweens[1].speed then
        actor.tweens[1].credit.r = actor.tweens[1].credit.r + actor.tweens[1].speed; running = true
    end

    if (actor.tweens[1].credit.g - actor.tweens[1].target.g) > actor.tweens[1].speed then
        actor.tweens[1].credit.g = actor.tweens[1].credit.g - actor.tweens[1].speed; running = true
    elseif (actor.tweens[1].credit.g - actor.tweens[1].target.g) < -actor.tweens[1].speed then
        actor.tweens[1].credit.g = actor.tweens[1].credit.g + actor.tweens[1].speed; running = true
    end

    if (actor.tweens[1].credit.b - actor.tweens[1].target.b) > actor.tweens[1].speed then
        actor.tweens[1].credit.b = actor.tweens[1].credit.b - actor.tweens[1].speed; running = true
    elseif (actor.tweens[1].credit.b - actor.tweens[1].target.b) < -actor.tweens[1].speed then
        actor.tweens[1].credit.b = actor.tweens[1].credit.b + actor.tweens[1].speed; running = true
    end

    if (actor.tweens[1].credit.a - actor.tweens[1].target.a) > actor.tweens[1].speed then
        actor.tweens[1].credit.a = actor.tweens[1].credit.a - actor.tweens[1].speed; running = true
    elseif (actor.tweens[1].credit.a - actor.tweens[1].target.a) < -actor.tweens[1].speed then
        actor.tweens[1].credit.a = actor.tweens[1].credit.a + actor.tweens[1].speed; running = true
    end

    if running == false then
        actor.render = actor.tweens[1].credit
        table.remove(actor.tweens, 1)
        if #actor.tweens > 0 then
            actor.tweens[1].credit = actor.render
        end
    end
end

local function actor_render(actor)
    if not (actor.tweens[1] == nil) then
        set_color(
            actor.tweens[1].credit.r,
            actor.tweens[1].credit.g,
            actor.tweens[1].credit.b,
            actor.tweens[1].credit.a
        )
        fill_rect(
            actor.tweens[1].credit.x,
            actor.tweens[1].credit.y,
            actor.tweens[1].credit.w,
            actor.tweens[1].credit.h
        )
    else
        set_color(
            actor.render.r,
            actor.render.g,
            actor.render.b,
            actor.render.a
        )
        fill_rect(
            actor.render.x,
            actor.render.y,
            actor.render.w,
            actor.render.h
        )
    end
end


function main()
    local actor = init_actor(10, 10, 50, 50, COLOR.RED)

    actor_add_tween(actor, 500, 400, 70, 40, COLOR.VIOLETTE)
    actor_add_tween(actor, 40, 110, 100, 100, COLOR.BLUE)
    actor_add_tween(actor, 500, 400, 70, 40, COLOR.VIOLETTE)
    actor_add_tween(actor, 40, 110, 100, 100, COLOR.BLUE)

    set_background(255, 255, 255, 255)

    while #actor.tweens > 0 do
        clear_background()
        tween_logic(actor)
        actor_render(actor)
        render()
        delay(0, 100000)
    end
    delay(1, 0)
end
