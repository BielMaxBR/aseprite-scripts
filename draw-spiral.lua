-- baseado no script de circulo
local image = app.activeCel.image
copy = image:clone()


function hashCoordinates(x, y, z)
    local prime1 = 73856093
    local prime2 = 19349663
    local prime3 = 83492791
    local index = (x * prime1) + (y * prime2) + (z * prime3)
    index = math.floor(index)
    return index
end

function deg2rad(deg)
    return deg * (math.pi / 180)
end

function rotateVector3D(vector, origin, angles)
    -- Converter ângulos para radianos
    local radX = deg2rad(angles.x)
    local radY = deg2rad(angles.y)
    local radZ = deg2rad(angles.z)

    local X = vector.x - origin.x
    local Y = vector.y - origin.y
    local Z = vector.z - origin.z

    -- Rotação em torno do eixo X
    local rotatedX = X
    local rotatedY = Y * math.cos(radX) - Z * math.sin(radX)
    local rotatedZ = Y * math.sin(radX) + Z * math.cos(radX)

    -- Rotação em torno do eixo Y
    local tempX = rotatedX * math.cos(radY) + rotatedZ * math.sin(radY)
    local tempY = rotatedY
    local tempZ = -rotatedX * math.sin(radY) + rotatedZ * math.cos(radY)

    -- Rotação em torno do eixo Z
    local finalX = tempX * math.cos(radZ) - tempY * math.sin(radZ)
    local finalY = tempX * math.sin(radZ) + tempY * math.cos(radZ)
    local finalZ = tempZ

    -- Vetor rotacionado
    local rotatedVector = newVector(finalX + origin.x, finalY + origin.y, finalZ + origin.z)

    return rotatedVector
end

function userInput()
    local dlg = Dialog()
    -- Create dialog parameters
    dlg:number{
        id = "x",
        label = "X:",
        decimals = 0
    }
    dlg:number{
        id = "y",
        label = "Y:",
        decimals = 0
    }
    dlg:number{
        id = "radius",
        label = "Radius:",
        decimals = 0
    }
    dlg:button{
        id = "ok",
        text = "OK"
    }
    dlg:button{
        id = "cancel",
        text = "Cancel"
    }
    -- dlg:show()

    return dlg.data
end


-- create the specified spiral
function createSpiral(maxrad, stepradius)
    local points = {}
    local x = 0
    local y = 0
    local dx = x ^ 2
    local dy = y ^ 2
    local distSquared = dx + dy
    local radSquared = maxrad ^ 2
    local Cradius = stepradius

    local Cangle = 0
    limit = 150000
    Climit = 0
    while (distSquared <= radSquared and Climit < limit) do
        Cradius = Cradius + stepradius
        stepradius = stepradius + 0.00002
        Cangle = Cangle + 0.01

        x = math.cos(Cangle) * Cradius
        y = math.sin(Cangle) * Cradius
        dx = x ^ 2
        dy = y ^ 2

        distSquared = dx + dy
        radSquared = maxrad ^ 2

        z = Cradius -- posso mudar pra outra coisa
        index = hashCoordinates(x, y, z)

        if (not points[index]) then
            points[index] = newVector(x, y, z)
            -- copy:drawPixel(fx, fy, app.fgColor)
        end
        Climit = Climit + 1
    end
    return points
end

function rotatePoints(points, origin, rotation)

    local newPoints = {}
    for k, point in pairs(points) do
        local rotated = rotateVector3D(point, origin, rotation)
        newPoints[k] = rotated
    end
    return newPoints
end

function lerp(a, b, t)
    return a + (b - a) * 0.5 * t
end

function drawSpiral(points, origin)
    for k, point in pairs(points) do
        x = point.x
        y = point.y
        z = point.z + origin.z

        perspective = 128 * 0.8 -- valores origin.x e origin.y são do centro da tela
        scale = (perspective / (perspective + z))
        px = x * scale
        py = y * scale

        color = app.fgColor
        -- color.red = math.max((color.red * 1 / (z)), 0, color.red)
        -- color.green = math.max((color.green * 1 / (z)), 0, color.green)
        -- color.blue = math.max((color.blue * 1 / (z)), 0, color.blue)

        if z < 0 then
            color = app.bgColor
            -- print(z)
        end
        -- copy = image:clone()    
        copy:drawPixel(px + origin.x, py + origin.y, color)
    end
    app.activeCel.image:drawImage(copy)

end
-- Run script
do

    -- local userCircle = userInput()
    local origin = newVector(64, 64, 0)
    local rotateOrigin = newVector(0, 0, 0)

    for i = 2, 180 + 1 do
        if app.activeSprite.frames[i] then
            app.frame = i
        else
            app.activeSprite:newFrame(1)
            app.activeFrame.duration = 0.02
        end
        copy = Image(image.width,image.height)
        points = createSpiral(64, 1 / 200) -- valor padrão do arg 3 = 0.0001
        points = rotatePoints(points, rotateOrigin, newVector(0, 0, i*20))
        points = rotatePoints(points, rotateOrigin, newVector(i*2, 0, 0))
        drawSpiral(points, origin)
        
    end
    app.activeSprite:deleteFrame(1)

    -- if userCircle.ok then
    --     -- drawSpiral(userCircle.x, userCircle.y, userCircle.radius, 0.5)
    -- end
end