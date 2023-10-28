-- baseado no script de circulo
-- Open dialog, ask user for paramters
function hashCoordinates(x, y, z)
    local prime1 = 73856093
    local prime2 = 19349663
    local prime3 = 83492791
    local index = (x * prime1) + (y * prime2) + (z * prime3)
    index = math.floor(index)
    return index
end

function deg2rad(deg)
    return deg * (math.pi/180)
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
  local rotatedZ = Z * math.sin(radX) + Z * math.cos(radX)

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
    dlg:number{ id="x", label="X:", decimals=0 }
    dlg:number{ id="y", label="Y:", decimals=0 }
    dlg:number{ id="radius", label="Radius:", decimals=0 }
    dlg:button{ id="ok", text="OK" }
    dlg:button{ id="cancel", text="Cancel" }
    -- dlg:show()

    return dlg.data
end

function newVector(x,y,z) 
    return { ["x"]=x, ["y"]=y, ["z"]=z }
end

-- create the specified spiral
function createSpiral(origin, maxrad, stepradius)
    local points = {}
    local x = origin.x
    local y = origin.y
    local dx = origin.x - x
    local dy = origin.y - y
    dx = dx^2
    dy = dy^2
    local distSquared = dx + dy
    local radSquared = maxrad^2
    local Cradius = stepradius
    
    local Cangle = 0
    limit = 150000
    Climit = 0
    while ( distSquared <= radSquared and Climit < limit ) do 
        Cradius = Cradius + stepradius
        stepradius = stepradius + 0.00002
        Cangle = Cangle + 0.01

        x = origin.x + math.cos(Cangle) * Cradius
        y = origin.y + math.sin(Cangle) * Cradius

        dx = origin.x - x
        dy = origin.y - y
        dx = dx^2
        dy = dy^2

        distSquared = dx + dy
        radSquared = maxrad^2

        z = Cradius -- posso mudar pra outra coisa
        index = hashCoordinates(x, y, z)

        if (not points[index]) then
            points[index] = newVector(x,y,z)
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

function drawSpiral(points, origin)
    local image = app.activeCel.image
    local copy = image:clone()
    
    for k, point in pairs(points) do
        x = point.x
        y = point.y
        z = point.z
        
        perspective = 128 * 0.8 -- valores origin.x e origin.y são do centro da tela
        scale = (perspective / (perspective + z))
        px = (x - origin.x) * scale + origin.x
        py = (y - origin.y) * scale + origin.y
        -- px = rx / rz
        -- py = ry / rz
        color = app.fgColor
        color.red = math.max(color.red - 1/z)
        color.green = math.max(color.green - 1/z)
        color.blue = math.max(color.blue - 1/z)
        copy:drawPixel(px, py, color)
    end

    app.activeCel.image:drawImage(copy)
end

-- Run script
do
    local userCircle = userInput()
    local origin = newVector(64,64,0)

    points = createSpiral(origin, 64, 1/200) -- valor padrão do arg 3 = 0.0001
    points = rotatePoints(points, origin, newVector(-55,0,15))
    drawSpiral(points, origin)

    if userCircle.ok then
        -- drawSpiral(userCircle.x, userCircle.y, userCircle.radius, 0.5)
    end
end
