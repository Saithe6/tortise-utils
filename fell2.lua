local tArgs = {...}
local function collumUp()
  turtle.dig()
  while turtle.compareUp() do
    turtle.digUp()
    turtle.dig()
    turtle.up()
  end
  turtle.dig()
end

local function collumDown()
  turtle.dig()
  while turtle.compareDown() do
    turtle.digDown()
    turtle.dig()
    turtle.down()
  end
  turtle.dig()
end

turtle.dig()
turtle.forward()
collumUp()
if tArgs[1] == "r" then turtle.turnLeft()
else turtle.turnRight() end
turtle.dig()
turtle.forward()
if tArgs[1] == "r" then turtle.turnRight()
else turtle.turnLeft() end
collumDown()
