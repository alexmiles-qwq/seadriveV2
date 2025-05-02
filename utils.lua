local module = {}

local DEBUGENABLED = _G.CONFIG.debug

-- Assuming 'fs' and 'path' are available similar to Node.js/Luvit
-- If using a different environment, the specific function calls might need adjustment.
local fs = require('fs')
-- 'path' is not strictly needed for these functions but good practice to include if
-- path manipulation might be added later.
-- local path = require('path') -- Uncomment if path manipulation is needed elsewhere


local function printTable(t)
    local output

    for k, v in pairs(t) do
        local key, value
        
        if type(k) == 'table' then
            key = printTable(k)
        end
        if type(v) == 'table' then
            value = printTable(v)
        end

        if type(k) == 'function' then
            k = "function"
        end
        
        print(tostring(key) .. " = " .. tostring(value))

    end
end

--- Creates a directory synchronously, including parent directories if they don't exist.
-- Mimics 'mkdir -p'.
-- @param dirPath (string) The full path of the directory to create.
-- @return boolean, err Success status (true if created or already exists), or false and an error object/message on failure.
function module:CreateDirSync(dirPath)
    -- Use pcall (protected call) to catch errors from fs.mkdirSync
    local ok, err = pcall(fs.mkdirSync, dirPath)
    
    
    if ok then
      return true -- Directory created or already exists
    else
      -- Check if error is because it already exists (EEXIST) - treat as success
      -- Note: Error codes/properties might vary slightly between Lua FS implementations
      if err and (err.code == 'EEXIST') then
         -- To be more robust, we could stat the path to ensure it's actually a directory
         local statOk, statInfo = pcall(fs.statSync, dirPath)
         if statOk and statInfo:isDirectory() then
           return true -- It exists and is a directory, which is fine
         else
           -- It exists but isn't a directory, or stat failed for other reasons
           return false, err -- Return the original mkdir error or a new one
         end
      end
      -- Other error occurred
      return false, err
    end
  end
  
  --- Creates a directory asynchronously, including parent directories if they don't exist.
  -- @param dirPath (string) The full path of the directory to create.
  -- @param callback (function) Called upon completion. Signature: function(err)
  --                            'err' is nil on success (or if dir already exists and is a directory),
  --                            otherwise it's an error object/message.
  function module:CreateDir(dirPath, callback)
    assert(type(callback) == 'function', "CreateDir requires a callback function")
  
    fs.mkdir(dirPath, { recursive = true }, function(err)
      if err then
        -- Check if error is because it already exists (EEXIST)
        if err.code == 'EEXIST' then
          -- Verify it's actually a directory asynchronously
          fs.stat(dirPath, function(statErr, statInfo)
            if statErr then
              -- Stat failed after EEXIST, report original mkdir error maybe? Or statErr?
              callback(err) -- Report the original mkdir EEXIST error
            elseif statInfo:isDirectory() then
              callback(nil) -- It exists and is a directory, success.
            else
              -- It exists but isn't a directory
              local notDirError = Error("Path exists but is not a directory: " .. dirPath)
              notDirError.code = 'ENOTDIR' -- Mimic standard error code
              callback(notDirError)
            end
          end)
        else
          -- Different mkdir error
          callback(err)
        end
      else
        -- mkdir succeeded without error
        callback(nil)
      end
    end)
  end
  
  --- Checks synchronously if a path exists and is a directory.
  -- @param dirPath (string) The path to check.
  -- @return boolean True if the path exists and is a directory, false otherwise.
  function module:FindDir(dirPath)
    local ok, statInfo = pcall(fs.statSync, dirPath)
   
    if ok and statInfo then
      return true
    else
      return false
    end
  end
  
  --- Checks synchronously if a path exists and is a file.
  -- @param filePath (string) The path to check.
  -- @return boolean True if the path exists and is a file, false otherwise.
  function module:FindFileSync(filePath)
    local ok, statInfo = pcall(fs.statSync, filePath)



    if ok and statInfo and (statInfo.type == "file" or statInfo.type == 'string') then
        return true
    else
        return false
    end
end
  --- Checks asynchronously if a path exists and is a file.
  -- @param filePath (string) The path to check.
  -- @param callback (function) Called upon completion. Signature: function(isFile, err)
  --                            'isFile' is true if it exists and is a file, false otherwise.
  --                            'err' is the error object if stat failed, otherwise nil.
  function module:FindFile(filePath, callback)
   assert(type(callback) == 'function', "FindFile requires a callback function")
  
   fs.stat(filePath, function(err, statInfo)
     if err then
       -- File not found (ENOENT) or other access error
       callback(false, err)
     elseif statInfo:isFile() then
       -- Exists and is a file
       callback(true, nil)
     else
       -- Exists but is not a file (e.g., a directory)
       callback(false, nil) -- Not a file, but no access error occurred
     end
   end)
  end

  function module:ReadFileSync(path)
    local filefound = module:FindFileSync(path)

    if filefound then
        return fs.readFileSync(path)
    end
  end
  function module:WriteFileSync(path, data)
    return fs.writeFileSync(path, data)
  end

function module:print2(prefix, str)
  local stringi = '['..prefix..']: '..tostring(str)
  print(stringi)
end

-- Prints a message if debugging is enabled
function module:dprint(...)
  if not DEBUGENABLED then
       return
  end
    
   print(...)
end

-- Prints a message if debugging is enabled, using print2()
function module:dprint2(prefix, str)
  if not DEBUGENABLED then
        return
  end
    
  module:print2(prefix, str)
end


return module