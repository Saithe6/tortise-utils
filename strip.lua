local tArgs = {...}

for i = 1,tArgs[1] do
  turtle.dig()
  turtle.forward()
  turtle.digDown()
  print(turtle.getFuelLevel())
end
