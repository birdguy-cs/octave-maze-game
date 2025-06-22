-- Maze generator in Lua
-- Joe Wingbermuehle 2013-10-06
Mazegenerator = {}

-- Create an empty maze array.
function init_maze(width, height)
   local result = {}
   for y = 0, height - 1 do
      for x = 0, width - 1 do
         result[y * width + x] = 1
      end
      result[y * width + 0] = 0
      result[y * width + width - 1] = 0
   end
   for x = 0, width - 1 do
      result[0 * width + x] = 0
      result[(height - 1) * width + x] = 0
   end
   return result
end

-- Show a maze.
function show_maze(maze, width, height)
   for y = 0, height - 1 do
      for x = 0, width - 1 do
         if maze[y * width + x] == 0 then
            io.write("  ")
         else
            io.write("[]")
         end
      end
      io.write("\n")
   end
end

-- Carve the maze starting at x, y.
function carve_maze(maze, width, height, x, y)
   local r = math.random(0, 3)
   maze[y * width + x] = 0
   for i = 0, 3 do
      local d = (i + r) % 4
      local dx = 0
      local dy = 0
      if d == 0 then
         dx = 1
      elseif d == 1 then
         dx = -1
      elseif d == 2 then
         dy = 1
      else
         dy = -1
      end
      local nx = x + dx
      local ny = y + dy
      local nx2 = nx + dx
      local ny2 = ny + dy
      if maze[ny * width + nx] == 1 then
         if maze[ny2 * width + nx2] == 1 then
            maze[ny * width + nx] = 0
            carve_maze(maze, width, height, nx2, ny2)
         end
      end
   end
end

function Mazegenerator:Start()
   -- The size of the maze (must be odd).
   width = 49
   height = 49

   -- Initialize random number generator
   math.randomseed(os.time())

   -- Generate and display a random maze.
   maze = init_maze(width, height)
   carve_maze(maze, width, height, 2, 2)
   maze[width + 2] = 0
   maze[(height - 2) * width + width - 3] = 0
   --show_maze(maze, width, height)
   place_blocks(maze, width, height)
end

function place_blocks(maze, width, height)
   local offsetX = -width // 2
   local offsetZ = -height // 2

   for y = 0, height - 1 do
      for x = 0, width - 1 do
         local index = y * width + x
         local value = maze[index]
         local spacing = 2 -- or try 1.5, 3.0, etc.

         if value == 1 then
            local world = Engine.GetWorld(1)
            local selfnode = world:FindNode("Maze Generator")
            local createdNode = selfnode:CreateChild("StaticMesh3D")
            createdNode:SetWorldPosition(Vec((x + offsetX) * spacing, 0, (y + offsetZ) * spacing))
            createdNode:SetName("mazeWall")
            createdNode:SetMaterialOverride("M_plasterwall")
            createdNode:SetScale(Vec(1,40,1))
         end
      end
   end
end
