local tor = require("libs/tortise")
local tArgs = {...}

local function vector(absolute)
  local vec = {}
  if #tArgs < 4 then
    print("error: not enough arguments")
  else
    if absolute then
      vec.x,vec.y,vec.z = tArgs[2],tArgs[3],tArgs[4]
      vec = tor.toRelative(vec)
    end
    tor.vecMove(vec,true)
  end
end

local function main()
  if #tArgs == 0 then
    print("error: no arguments")
  else
    if tArgs[1] == "vec" then
      vector(false)
    elseif tArgs[1] == "abs" then
      vector(true)
    else
      for i,v in ipairs(tArgs) do
        tor.directMove(v,true)
      end
    end
  end
end
main()
