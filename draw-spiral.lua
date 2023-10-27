-- baseado no script de circulo
-- Open dialog, ask user for paramters
function userInput()
    local dlg = Dialog()
    -- Create dialog parameters
    dlg:number{ id="x", label="X:", decimals=0 }
    dlg:number{ id="y", label="Y:", decimals=0 }
    dlg:number{ id="radius", label="Radius:", decimals=0 }
    dlg:button{ id="ok", text="OK" }
    dlg:button{ id="cancel", text="Cancel" }
    -- dlg:show()

    return dlg.data
end

-- Draws the specified circle
function drawSpiral(cx, cy, maxrad, stepradius)
    local image = app.activeCel.image
    local copy = image:clone()

    cx = copy.width / 2
    cy = copy.height / 2

    local x = cx
    local y = cy
    local dx = cx - x
    local dy = cy - y
    dx = dx^2
    dy = dy^2
    local distSquared = dx + dy
    local radSquared = maxrad^2
    local Cradius = stepradius
    
    local Cangle = 0
    limit = 150000
    Climit = 0
    while ( distSquared <= radSquared and Climit < limit ) do 
    -- while ( Cangle < 0.5 ) do 
        Cradius = Cradius + stepradius--- math.sqrt(Cradius)
        stepradius = stepradius + 0.00002
        Cangle = Cangle + 0.01--stepradius --(stepradius - 1/math.sqrt(Cradius))
        x = cx + math.cos(Cangle) * Cradius
        y = cy + math.sin(Cangle) * Cradius
        dx = cx - x
        dy = cy - y
        dx = dx^2
        dy = dy^2
        distSquared = dx + dy
        radSquared = maxrad^2

        copy:drawPixel(math.floor(x), math.floor(y), app.fgColor)
        Climit = Climit + 1 
    end
    app.activeCel.image:drawImage(copy)
end

-- Run script
do
    local userCircle = userInput()
    drawSpiral(16, 16, 128, 0.0001)
    if userCircle.ok then
        -- drawSpiral(userCircle.x, userCircle.y, userCircle.radius, 0.5)
    end
end
