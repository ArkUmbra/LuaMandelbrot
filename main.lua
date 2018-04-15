
local MAX_ITERATIONS = 200

local colorRange = {}

local PX_WIDTH = 1100
local PX_HEIGHT = 700
local BLACK = {0,0,0}
local WHITE = {255, 255, 255}
local BOUND_PERCENT_CHANGE = 0.5 

local bound = 2.0
local xUnitOffset = 0
local yUnitOffset = 0

local minX = 0
local maxX = 0
local minY = 0
local maxY = 0

local debugDrawTime = 0
local debugCalcTime = 0

local dataSetIsStale = true
local mandelbrotList = {}


----------------------------

function love.load()
  --love.window.setMode(PX_WIDTH, PX_HEIGHT)
  love.window.setFullscreen(true)
  --love.graphics.setMode(0, 0, false, false)
  PX_WIDTH = love.graphics.getWidth()
  PX_HEIGHT = love.graphics.getHeight()
  
  for i=0, MAX_ITERATIONS, 1 do
    -- nice colour combos
    -- 4, 3, 7
    -- 12, 15, 2
    
    --r = overflow256(i * 3)
    --g = overflow256(i * 5)
    --b = overflow256(i * 19)
    r = 150 * i / MAX_ITERATIONS
    g = 150 * i / MAX_ITERATIONS
    b = 255 * i / MAX_ITERATIONS
    
    colorRange[i] = {r, g, b}
    
  end
  colorRange[MAX_ITERATIONS] = WHITE
end

function love.draw(dt)
  local timeAtDrawStart = os.time()
  
  for index, data in ipairs(mandelbrotList) do
    x = data[1]
    y = data[2]
    colour = data[3]
    love.graphics.setColor(colour[1], colour[2], colour[3])
    love.graphics.points(x, y)
  end
  
  love.graphics.setColor(WHITE)
  
  love.graphics.print("minX " .. minX, 10, 10)
  love.graphics.print("maxX " .. maxX, 10, 25)
  love.graphics.print("minY " .. minY, 10, 40)
  love.graphics.print("maxY " .. maxY, 10, 55)
  love.graphics.print("brot size " .. #mandelbrotList, 10, 70)
  love.graphics.print("draw seconds " .. debugDrawTime, 10, 85)
  love.graphics.print("calc seconds " .. debugCalcTime, 10, 100)
  
  local debugDrawTime = os.time() - timeAtDrawStart

end

function love.update()
  if (dataSetIsStale) then
    updateMandelbrotSet()
  end
  
end

function love.keypressed(key)
  
  if (key == "w") then
    -- zoom in, by decreasing the bounds we're looking at
    bound = bound + (bound * -BOUND_PERCENT_CHANGE)
    dataSetIsStale = true
  end
  
  if (key == "s") then
    -- zoom out, by increasing the bounds we're looking at
    bound = bound + (bound * BOUND_PERCENT_CHANGE)
    dataSetIsStale = true
  end
  
  if (key == "up") then
    yUnitOffset = yUnitOffset - (getYUnitRange() * BOUND_PERCENT_CHANGE * 0.3)
    dataSetIsStale = true
  end
  
  if (key == "down") then
    yUnitOffset = yUnitOffset + (getYUnitRange() * BOUND_PERCENT_CHANGE * 0.3)
    dataSetIsStale = true
  end
  
  if (key == "left") then
    xUnitOffset = xUnitOffset - (getXUnitRange() * BOUND_PERCENT_CHANGE * 0.3)
    dataSetIsStale = true
  end
  
  if (key == "right") then
    xUnitOffset = xUnitOffset + (getXUnitRange() * BOUND_PERCENT_CHANGE * 0.3)
    dataSetIsStale = true
  end
  
end

----------------------------
function overflow256(num) 
  if num >= 256 then
    return overflow256(num - 256)
  end

  return num
end

function getXUnitRange() 
  return maxX - minX
end

function getYUnitRange() 
  return maxY - minY
end

function updateMandelbrotSet()
  local timeAtStartOfCalc = os.time()
  
  recalculateBounds()
  
  local newMandelbrotList = {}
  for x = 0, PX_WIDTH, 1 do
    --mandelbrotSet[x] = {}
          
    for y = 0, PX_HEIGHT, 1 do
      local a = getOriginCentredXPosition(x)
      local b = getOriginCentredYPosition(y)
      
      local iterationCount = getNumberOfIterationsWithinMandelbroBound(a, b)
      local color = getColorValueBasedOnIteration(iterationCount)
      
      --if iterationCount == MAX_ITERATIONS then
      --  color = BLACK
      --end
      
      --mandelbrotSet[x][y] = color
    
      if iterationCount < MAX_ITERATIONS then
        local data = {x, y, color}
        table.insert(newMandelbrotList, data)
      end
      
    end
  end
  
  mandelbrotList = newMandelbrotList
  dataSetIsStale = false
  
  debugCalcTime = os.time() - timeAtStartOfCalc
end

function recalculateBounds() 
-- set up minmax bounds depending on screen dimensions
  -- use width as priority to set bounds
  minX = -bound + xUnitOffset
  maxX = bound + xUnitOffset
  local yRatio = (PX_HEIGHT / PX_WIDTH)
  minY = (-bound + yUnitOffset) * yRatio 
  maxY = (bound + yUnitOffset) * yRatio
end


function getOriginCentredXPosition(col)
  return (minX + col * ((maxX - minX) / PX_WIDTH))
end

function getOriginCentredYPosition(row)
  return (minY + row * ((maxY - minY) / PX_HEIGHT))
end



-- Any value above 2 is considered to have 'escaped' the set
-- so we will return the count of the last number within that bound
-- Function we are considering: zNext = z^2 + c
function getNumberOfIterationsWithinMandelbroBound(a, b)
  local x = 0.0
  local y = 0.0
  
  local iterations = 0
  
  while withinBounds(x, y)  and iterations < MAX_ITERATIONS do
    xNew = x*x - y*y + a
    yNew = 2*x*y + b
    
    x = xNew
    y = yNew
    
    iterations = iterations + 1
  end
  
  return iterations
end

function withinBounds(x, y) 
  --return x <= PX_WIDTH and y <= PX_HEIGHT
  --return x <= bound and y <= bound
  return x*x+y*y <= 4
end

function getColorValueBasedOnIteration(iterationCount)

  return colorRange[iterationCount]
end

    
