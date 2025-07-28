local geo = peripheral.wrap("right")
tBlocks = geo.scan(8)

whitelist = {
  "minecraft:diamond_ore","minecraft:deepslate_diamond_ore",
  "minecraft:ancient_debris",
  "minecraft:chest",
  --"create:zinc_ore","create:deepslate_zinc_ore,"
  "minecraft:wet_sponge"
  }

local function checkList(id)
  for i,v in ipairs(whitelist) do
    if id == whitelist[i] then
      return true
    end
  end
  return false
end

local function filter()
  local filtered = {}
  local count = 1
  for i,v in ipairs(tBlocks) do
    if checkList(tBlocks[i].name) then
      filtered[count] = v
      count = count+1
    end
  end
  return filtered
end

local function samePos(pivot,block)
  if block.x == pivot.x and block.y == pivot.y and block.z == pivot.z then
    return true
  end
  return false
end

local function checkPos(pivot,block)
  if block.x > pivot.x-2 and block.x < pivot.x+2
  and block.y > pivot.y-2 and block.y < pivot.y+2
  and block.z > pivot.z-2 and block.z < pivot.z+2
  and not samePos(pivot,block) then
    return true
  end
  return false
end

local function markSeen(seenBlock,unseen)
  for i,v in ipairs(unseen) do
    if v == seenBlock then
      table.remove(unseen,i)
      return
    end
  end
end

local function getNeighbors(pivot,neighbors,unseen)
  markSeen(pivot,unseen)
  for i,v in ipairs(unseen) do
    if checkPos(pivot,v) then
      neighbors[#neighbors+1] = v
      getNeighbors(v,neighbors,unseen)
    end
  end
end

local function getVein(unseen)
  local vein = {}
  for i,v in ipairs(unseen) do
    vein[i] = {unseen[i]}
    getNeighbors(unseen[i],vein[i],unseen)
  end
  return vein
end

local function main()
  local unseen = filter()
  local vein = getVein(unseen)
  for i,v in ipairs(vein) do
    local colon = string.find(v[1].name,":")
    local name = string.sub(v[1].name,colon+1,-1)
    print(name..": "..#v)
    if #v == 0 then
      print("**")
    else
      print(v[1].x..","..v[1].y..","..v[1].z)
    end
  end
end
main()
