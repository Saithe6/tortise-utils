local tor = require("libs/tortise")
local tArgs = {...}

--Whether or not the turtle should try to store items in a shulker box placed in its first slot
local storageBlind = false

local function checkSpace(storageAware)
  if turtle.getItemSpace(16) ~= 64 and storageAware and not storageBlind then
    tor.turn("left")
    tor.turn("left")
    tor.placePeripheral()
    for i = 2,16 do
      turtle.select(i)
      turtle.drop()
    end
    turtle.select(1)
    turtle.dig()
    tor.turn("left")
    tor.turn("left")
  end
end

local function hasShulker()
  local shulker = turtle.getItemDetail(1)
  if shulker ~= nil and string.find("shulker",shulker.name) ~= nil then return true end
  return false
end

local function layer(right,up,udfe,storageAware)
  local dist = tonumber(tArgs[1])
  local strips = tonumber(tArgs[2])
  local turn = -1
  local r = 1
  if right then dist,turn,r = -dist,-turn,-1 end
  tor.directMove(dist.."l",true)
  for i = 1,strips do
    if udfe == "f" or udfe == "e" then
      if up then
        tor.directMove("1y",true)
      else
        tor.directMove("-1y",true)
      end
      tor.directMove("-"..math.abs(dist).."f",true)
    else
      tor.directMove(turn.."l",true)
      tor.directMove(turn*r*dist.."l",true)
      turn = -turn
    end
    checkSpace(storageAware)
  end
end

local function turnHandler(dir,rStart)
  local opposites = {
    left = "right",
    right = "left"
  }
  if rStart then
    tor.turn(opposites[dir])
  else
    tor.turn(dir)
  end
end

local function volume(right,udfe,storageAware)
  local layers = tonumber(tArgs[3])
  local ud,up
  if udfe == "f" then up = true end
  layer(right,up,udfe)
  if udfe == "d" then ud = "-1y" else ud = "1y" end
  if layers > 0 then
    for i = 1,layers do
      if udfe == "d" or udfe == "u" then
        if tonumber(tArgs[2])%2 == 0 then
          turnHandler("left",right)
        else
          if right then tor.turn("left") else tor.turn("right") end
          right = not right
        end
        tor.directMove(ud,true)
        layer(right,udfe)
      elseif udfe == "f" or udfe == "e" then
        if tonumber(tArgs[2])%2 == 0 then
          if right then tor.turn("left") else tor.turn("right") end
          right = not right
        else
          turnHandler("left",right)
        end
        tor.directMove("1f",true)
        up = not up
        layer(right,up,udfe,storageAware)
      end
    end
  end
end

local function main()
  if #tArgs == 0 then
    print("error: no arguments")
  else
    local right
    local udfe = "d"
    turtle.select(1)
    local storageAware = hasShulker()
    if string.sub(tArgs[1],1,1) == "+" then
      if string.sub(tArgs[1],2,2) == "r" then right = true end
      udfe = string.sub(tArgs[1],-1,-1)
      if udfe == "r" then udfe = "d" end
      table.remove(tArgs,1)
    end
    if udfe == "d" or udfe == "u" or udfe =="f" or udfe == "e" then
      if tArgs[1] == "f" or tArgs[1] == "y" or tArgs[1] == "-y" then
        local initialMoves = {
          f = "1f",
          y = "1y",
          ["-y"] = "-1y"
        }
        tor.directMove(initialMoves[tArgs[1]],true)
        table.remove(tArgs,1)
      end
      volume(right,udfe,storageAware)
    else
      print("error: empty plus argument")
    end
  end
end
main()
