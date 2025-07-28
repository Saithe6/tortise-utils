--- a library for turtle movement and related complex operation
tor = {}
tor.blacklist = {
  mods = {
    "computercraft",
    "create",
    "advancedperipherals",
    "cccbridge",
    "vampirism",
    "fantasyfurniture",
    "farmersdelight",
    "minecolonies",
    "mcwfences",
    "domum_ornamentum",
    "estrogen",
    "structurize",
    "mcwwindows",
    "sophisticatedstorage",
    "nethersdelight",
    "supplementaries",
    "create_enchantment_industry",
    "rats",
    "toms_storage",
    "morevillagers",
    "mna:vinteum_ore",
    "vampirism:cursed_earth",
    "vampirism:dark_stone"
  },
  overrides = {
    "create:zinc_ore",
    "create:raw_zinc_block",
    "create:deepslate_zinc_ore",
    "create:asurine",
    "create:crimsite",
    "create:limestone",
    "create:ochrum",
    "create:scoria",
    "create:scorchia",
    "create:veridium",
    "mna:vinteum_ore",
    "sophisticatedstorage:shulker_box",
    "sophisticatedstorage:copper_shulker_box",
    "sophisticatedstorage:iron_shulker_box",
    "sophisticatedstorage:diamond_shulker_box",
    "sophisticatedstorage:netherite_shulker_box"
  },
  types = {
    "chest",
    "barrel",
    "table",
    "bedrock",
    "bed"
  }
}
---@alias vector {x:integer,y:integer,z:integer}
---@alias cardinalDirection "north"|"east"|"south"|"west"
---@alias turtleDirection "forward"|"up"|"down"
tor.data = {
  home = {
    x = 0,
    y = 0,
    z = 0
  },
  facing = "south"
}
tor.toolSide = "left"

local function checkPath(dir)
  local block,isBlock = tor.detect(dir)
  print(isBlock)
  if isBlock then
    if not tor.checkBlacklist(block.name) then
      if dir == "up" then
        turtle.digUp(tor.toolSide)
      elseif dir == "down" then
        turtle.digDown(tor.toolSide)
      else
        turtle.dig(tor.toolSide)
      end
    end
    return tor.checkBlacklist(block.name)
  end
  return true
end

local function tryMove(dir)
  print("trying...")
  if turtle.getFuelLevel() == 0 then
    print("Out of Fuel")
    return true
  elseif not turtle[dir]() then
    print("checking path...")
    if checkPath(dir) then
      return true
    else
      tryMove(dir)
    end
  end
  return false
end

---more advanced, direction agnostic turtle basic movemnt function
---@param dist integer
---@param dir turtleDirection the direction to move in
---@param mine? boolean whether or not to mine blocks along the way
---@return boolean returns false if an obstacle is hit
function tor.move(dist,dir,mine)
  if mine then
    for i = 1,dist do
      print(turtle.getFuelLevel())
      if tryMove(dir) then return false end
    end
    return true
  else
    for i = 1,dist do
      if turtle.getFuelLevel() == 0 then print("Out of Fuel") else
        print(turtle.getFuelLevel())
        if not turtle[dir]() then return false end
      end
    end
    return true
  end
end

---a direction agnostic inspect function 
---@param dir turtleDirection 
---@return table
---@return boolean
function tor.detect(dir)
  local isBlock = false
  local block = {}
  if dir == "up" then
    isBlock,block = turtle.inspectUp()
  elseif dir == "down" then
    isBlock,block = turtle.inspectDown()
  else
    isBlock,block = turtle.inspect()
  end
  return block,isBlock
end

local function checkTypes(block)
  for i,v in ipairs(tor.blacklist.types) do
    if string.find(block,v) ~= nil then return true end
  end
  return false
end

local function checkOverrides(block)
  for i,v in ipairs(tor.blacklist.overrides) do
    if block == v then return false end
  end
  return true
end

local function checkMods(block)
  if block ~= nil then
    for i,v in ipairs(tor.blacklist.mods) do
      local blockMod = v..":"
      if string.find(block,blockMod) ~= nil then return checkOverrides(block) end
    end
  end
  return false
end

function tor.checkBlacklist(block) return checkMods(block) or checkTypes(block) end

local function changeDir(turn)
  local facings = {
    north = {
      right = "east",
      left = "west"
    },
    east = {
      right = "south",
      left = "north"
    },
    south = {
      right = "west",
      left = "east"
    },
    west = {
      right = "north",
      left = "south"
    }
  }
  tor.data.facing = facings[tor.data.facing][turn]
end

---a direction agnostic turn function; also updates tor.facing
---@param dir string|"left"|"right"
function tor.turn(dir)
  if dir == "left" then
    turtle.turnLeft()
    changeDir(dir)
  elseif dir == "right" then
    turtle.turnRight()
    changeDir(dir)
  end
end

---translates an absolute vector to a relative one based on the value of tor.facing
---@param absVec vector
---@return vector
function tor.toRelative(absVec)
  local relVec = {y = absVec.y}
  local facing = tor.data.facing
  if facing == "north" then
    relVec.z = -absVec.z
    relVec.x = -absVec.x
  elseif facing == "east" then
    relVec.z = -absVec.x
    relVec.x = absVec.z
  elseif facing == "west" then
    relVec.z = absVec.x
    relVec.x = -absVec.z
  else
    relVec.z = absVec.z
    relVec.x = absVec.x
  end
  return relVec
end

---moves the turtle along a relative vector, first moving up, then forward, then left
---@param v vector
---@param mine? boolean whether or not to mine blocks along the way
---@return boolean returns false if the turtle encounters an obstruction
function tor.vecMove(v,mine)
  if v.y > 0 then
    if not tor.move(v.y,"up",mine) then return false end
  elseif v.y < 0 then
    if not tor.move(math.abs(v.y),"down",mine) then return false end
  end

  if v.z > 0 then
    if not tor.move(v.z,"forward",mine) then return false end
  elseif v.z < 0 then
    tor.turn("left")
    tor.turn("left")
    v.x = -v.x
    if not tor.move(math.abs(v.z),"forward",mine) then return false end
  end

  if v.x > 0 then
    tor.turn("left")
    if not tor.move(v.x,"forward",mine) then return false end
  elseif v.x < 0 then
    tor.turn("right")
    if not tor.move(math.abs(v.x),"forward",mine) then return false end
  end
  return true
end

---directly moves turtle using instruction
---@param instruction string composed of an integer with an axis(l for left/right, x for east/west, y for y, f for forward/back, z for south/north) appended to the end
---@param mine? boolean whether or not to mine blocks along the way
function tor.directMove(instruction,mine)
  local dir = string.sub(instruction,-1,-1)
  local dist = tonumber(string.sub(instruction,1,-2))
  local moves = {}

  function moves.f()
    if dist < 0 then
      tor.turn("left")
      tor.turn("left")
      dist = math.abs(dist)
    end
    tor.move(dist,"forward",mine)
  end

  function moves.l()
    if dist < 0 then
      tor.turn("right")
    else
      tor.turn("left")
    end
    tor.move(math.abs(dist),"forward",mine)
  end

  function moves.y()
    if dist < 0 then
      dir = "down"
    else
      dir = "up"
    end
    tor.move(math.abs(dist),dir,mine)
  end

  function moves.z()
    if dist < 0 then
      tor.orient("north")
      tor.move(math.abs(dist),"forward",mine)
    else
      tor.orient("south")
      tor.move(math.abs(dist),"forward",mine)
    end
  end

  function moves.x()
    if dist < 0 then
      tor.orient("west")
      tor.move(math.abs(dist),"forward",mine)
    else
      tor.orient("east")
      tor.move(math.abs(dist),"forward",mine)
    end
  end
  moves[dir]()
end

---places the peripheral in the current slot and wraps it
---@return table
function tor.placePeripheral()
  if not turtle.place() then
    turtle.dig()
  end
  return peripheral.wrap("front")
end

---orients the turtle to be facing a certain direction
---@param goal cardinalDirection
function tor.orient(goal)
  local instructions = {
    north = {
      east = "right",
      west = "left",
      south = "reverse"
    },
    east = {
      south = "right",
      north = "left",
      west = "reverse"
    },
    south = {
      west = "right",
      east = "left",
      north = "reverse"
    },
    west = {
      north = "right",
      south = "left",
      east = "reverse"
    }
  }
  local operation = instructions[tor.data.facing][goal]
  if operation == "reverse" then
    tor.turn("left")
    tor.turn("left")
  else
    tor.turn(operation)
  end
end

---returns the x, y, and z of gps.locate as a vector
---@return vector
function tor.gpsVec()
  local vec = {}
  vec.x,vec.y,vec.z = gps.locate()
  return vec
end

---uses gps to find the direction the turtle is facing
---@param goBack? boolean whether or not to return to starting position after sending the second gps ping
---@return cardinalDirection
function tor.gpsFacing(goBack)
  if goBack == nil then goBack = false end

  local pos = {}
  local pos1 = tor.gpsVec()
  tor.move(1,"forward",true)
  local pos2 = tor.gpsVec()
  local x = pos2.x - pos1.x
  local z = pos2.z - pos1.z

  local dirsx = {}
  dirsx[1] = "east"
  dirsx[-1] = "west"
  local dirsz = {}
  dirsz[1] = "south"
  dirsz[-1] = "north"

  local dir
  if x == 0 then dir = dirsz[z]
  elseif z == 0 then dir = dirsx[x] end
  if goBack then turtle.back() end
  return dir
end

return tor
