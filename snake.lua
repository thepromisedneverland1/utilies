-- global vars
Size = 15
QuadSize = 50
LineSize = 5

-- local state vars
local MainQuad = {}
local Quads = {}
local SnakeSize = 4
local SnakePos = {} -- {x = 1..15, y = 1..15}
local SnakeQuads = {}
local HeadX = 8
local HeadY = 8
local Mode = 1      -- 1 = droite, 2 = gauche, 3 = haut, 4 = bas gros
local NextMode = 1  -- veski les morts
local SnakeTime = 0
local Apple = {}
local AppleGrid = {x = 0, y = 0}

IsFullscreen = false 

-- Fonction utilitaire gg
local function GetScreenPos(gx, gy)
    local offsetX = gx - 1 - Size/2
    local offsetY = gy - Size/2
    local x = Engine.Graphics.ScreenWidth/2 + (offsetX * QuadSize) + LineSize * offsetX
    local y = Engine.Graphics.ScreenHeight/2 + (offsetY * QuadSize) + LineSize * offsetY
    return x, y
end

function OnScriptInit()
    EnterFullscreen()
    CreateArena()
    RestartSnake()
    return true
end

function OnEnterFullscreen()
    IsFullscreen = true
    print("enter fullscreen")
end

function OnExitFullscreen()
    IsFullscreen = false
    print("exit fullscreen")
end

function CreateArena()
    Quads = {}
    -- mieux que un while true haha pas vraie ??? ... 
    for y = 1, Size do
        for x = 1, Size do
            local sx, sy = GetScreenPos(x, y)
            table.insert(Quads, QuadItem(sx, sy, QuadSize, QuadSize))
        end
    end
    MainQuad = {
        QuadItem(
            Engine.Graphics.ScreenWidth/2 - QuadSize/2 - LineSize/2,
            Engine.Graphics.ScreenHeight/2 + QuadSize/2 + LineSize/2,
            QuadSize * (Size + 1) - Size/2 + LineSize * Size/2,
            QuadSize * (Size + 1) + Size/2 + LineSize/2 * Size/2
        )
    }
end

function CreateApple()
    local valid = false
    local rx, ry = 1, 1
    
    -- plus de crash EZZ
    while not valid do
        rx = math.random(1, Size)
        ry = math.random(1, Size)
        valid = true
        for i = 1, #SnakePos do
            if SnakePos[i].x == rx and SnakePos[i].y == ry then
                valid = false
                break
            end
        end
    end

    AppleGrid = {x = rx, y = ry}
    local sx, sy = GetScreenPos(rx, ry)
    Apple = {QuadItem(sx, sy, QuadSize, QuadSize)}
end

function RestartSnake()
    SnakeSize = 4
    SnakePos = {}
    SnakeQuads = {}
    HeadX = 8
    HeadY = 8
    Mode = 1 
    NextMode = 1
    SnakeTime = Game.Client.LocalTime + 0.2
    
    -- le serpent est ici voilà
    for i = 1, SnakeSize do
        HeadX = HeadX + 1
        table.insert(SnakePos, {x = HeadX, y = HeadY})
        local sx, sy = GetScreenPos(HeadX, HeadY)
        table.insert(SnakeQuads, QuadItem(sx, sy, QuadSize, QuadSize))
    end
    
    CreateApple()
end

-- ici c'est les mouvement collision etc... et la pomme ! Pomme pomme sahur
function SnakeMove()
    Mode = NextMode
    local nextX, nextY = HeadX, HeadY

    if Mode == 1 then nextX = nextX + 1
    elseif Mode == 2 then nextX = nextX - 1
    elseif Mode == 3 then nextY = nextY - 1
    elseif Mode == 4 then nextY = nextY + 1
    end

    if nextX > Size then nextX = 1 elseif nextX < 1 then nextX = Size end
    if nextY > Size then nextY = 1 elseif nextY < 1 then nextY = Size end

    for i = 1, #SnakePos do
        if SnakePos[i].x == nextX and SnakePos[i].y == nextY then
            RestartSnake()
            return
        end
    end

    HeadX, HeadY = nextX, nextY

    table.insert(SnakePos, {x = HeadX, y = HeadY})
    local sx, sy = GetScreenPos(HeadX, HeadY)
    table.insert(SnakeQuads, QuadItem(sx, sy, QuadSize, QuadSize))

    if HeadX == AppleGrid.x and HeadY == AppleGrid.y then
        SnakeSize = SnakeSize + 1
        CreateApple()
    else
        while #SnakePos > SnakeSize do
            table.remove(SnakePos, 1)
            table.remove(SnakeQuads, 1)
        end
    end
end

function DrawArena()
    if not IsFullscreen then return end
    
    if Game.Client.LocalTime > SnakeTime then
        SnakeMove()
        SnakeTime = Game.Client.LocalTime + 0.2
    end
    
    Engine.Graphics:TextureSet(-1)
    Engine.Graphics:MapScreen(0, 0, Engine.Graphics.ScreenWidth, Engine.Graphics.ScreenHeight)
    
    Engine.Graphics:QuadsBegin()
        Engine.Graphics:SetColor(0.9, 0.4, 0, 1)
        Engine.Graphics:QuadsDraw(MainQuad)
    Engine.Graphics:QuadsEnd()
    
    Engine.Graphics:QuadsBegin()
        Engine.Graphics:SetColor(0.8, 0.3, 0, 1)
        Engine.Graphics:QuadsDraw(Quads)
    Engine.Graphics:QuadsEnd()
    
    Engine.Graphics:QuadsBegin()
        Engine.Graphics:SetColor(1, 0.9, 0.8, 1)
        Engine.Graphics:QuadsDraw(SnakeQuads)
    Engine.Graphics:QuadsEnd()
    
    Engine.Graphics:QuadsBegin()
        Engine.Graphics:SetColor(0.7, 0.9, 0.4, 1)
        Engine.Graphics:QuadsDraw(Apple)
    Engine.Graphics:QuadsEnd()
    
    Engine.Graphics:QuadsBegin()
        Engine.Graphics:SetColor(0.9, 0.2, 0.2, 0.4)
        Engine.Graphics:QuadsDraw({SnakeQuads[#SnakeQuads]})
    Engine.Graphics:QuadsEnd()
    
    local d = ""
    if Mode == 1 then d = "→"
    elseif Mode == 2 then d = "←"
    elseif Mode == 3 then d = "↑"
    elseif Mode == 4 then d = "↓"
    end
    
    local headScreenX, headScreenY = GetScreenPos(HeadX, HeadY)
    Game.Ui:DoLabelScaled(UIRect(headScreenX - QuadSize/2, headScreenY - 12, QuadSize, QuadSize), d, 20, 0, -1, nil, 0)
end

function OnKeyPress(Key)
    if (Key == "right" or Key == "d") and Mode ~= 2 then
        NextMode = 1
    elseif (Key == "left" or Key == "a") and Mode ~= 1 then
        NextMode = 2 
    elseif (Key == "up" or Key == "w") and Mode ~= 4 then
        NextMode = 3
    elseif (Key == "down" or Key == "s") and Mode ~= 3 then
        NextMode = 4
    end
end

RegisterEvent("OnRenderLevel22", "DrawArena")
