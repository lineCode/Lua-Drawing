SCREEN_BPP      = 16
SCREEN_WIDTH    = 640
SCREEN_HEIGHT   = 480

EASING          = 7
EASING_THRESHOLD= 1/8

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
    if not (actor.tweens[1] == nil) then
        local running = false
        for k, v in pairs(actor.tweens[1].credit) do
            local x = (v - actor.tweens[1].target[k]) / EASING
            if (x > -EASING_THRESHOLD) and (x < EASING_THRESHOLD) then
                x = (v - actor.tweens[1].target[k])
            end
            if not(x == 0) then
                running = true
                actor.tweens[1].credit[k] = v - x
            end
        end
        if running == false then
            actor.render = actor.tweens[1].credit
            table.remove(actor.tweens, 1)
            if #actor.tweens > 0 then
                actor.tweens[1].credit = actor.render
            end
        end
    end
end

local function actor_render(actor)
    if not (actor.tweens[1] == nil) then
        set_color(
            math.floor(actor.tweens[1].credit.r),
            math.floor(actor.tweens[1].credit.g),
            math.floor(actor.tweens[1].credit.b),
            math.floor(actor.tweens[1].credit.a)
        )
        fill_rect(
            math.floor(actor.tweens[1].credit.x),
            math.floor(actor.tweens[1].credit.y),
            math.floor(actor.tweens[1].credit.w),
            math.floor(actor.tweens[1].credit.h)
        )
    else
        set_color(
            math.floor(actor.render.r),
            math.floor(actor.render.g),
            math.floor(actor.render.b),
            math.floor(actor.render.a)
        )
        fill_rect(
            math.floor(actor.render.x),
            math.floor(actor.render.y),
            math.floor(actor.render.w),
            math.floor(actor.render.h)
        )
    end
end

function main()
    local actor = init_actor(10, 10, 50, 50, COLOR.RED)

    actor_add_tween(actor, SCREEN_WIDTH-70, SCREEN_HEIGHT-40, 70, 40, COLOR.VIOLETTE)
    actor_add_tween(actor, 0, SCREEN_HEIGHT-200, 100, 200, COLOR.GREEN)
    actor_add_tween(actor, SCREEN_WIDTH-200, 0, 200, 30, COLOR.YELLOW)
    actor_add_tween(actor, 0, 0, 100, 100, COLOR.BLUE)

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
