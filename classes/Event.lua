--[[
  Event Module for Luvit

  Provides an event signaling mechanism similar to Roblox's RBXScriptSignal.

  Features:
  - Create new Event objects via Event.new().
  - Connect listener functions (:Connect).
  - Fire the event, passing arguments to listeners (:Fire).
  - Wait for the event to fire (coroutine-based :Wait).
  - Disconnect listeners (:Disconnect on the connection object).
  - Basic error handling for listeners using pcall.
--]]

local core = require('core') -- Often needed for coroutine.running check
local utils = require('../utils')

-- Forward declarations for metatables
local Event = {}
Event.__index = Event
Event.ClassName = "EventSignal" -- Mimic Roblox naming convention

local Connection = {}
Connection.__index = Connection
Connection.ClassName = "EventConnection"

local nextConnectionId = 1

-- ==================
-- Connection Methods
-- ==================

-- Disconnects the listener associated with this connection.
function Connection:Disconnect()
  if not self.Connected then
    return -- Already disconnected
  end

  -- Remove the listener from the event's listener table
  if self._event and self._event._listeners then
      self._event._listeners[self._id] = nil
  end

  self.Connected = false
  self._event = nil -- Clear reference to the event
  self._listener = nil -- Clear reference to the listener function
end

-- ==================
-- Event Methods
-- ==================

--[[
  Connects a listener function to this event.
  @param listener (function): The function to call when the event is fired.
  @returns (Connection): An object with a :Disconnect() method.
--]]
function Event:Connect(listener)
  assert(type(listener) == "function", "Attempt to connect non-function to EventSignal.")

  local connectionId = nextConnectionId
  nextConnectionId = nextConnectionId + 1

  local connection = setmetatable({
    _event = self,
    _id = connectionId,
    _listener = listener, -- Store listener reference primarily for debugging/inspection
    Connected = true,
  }, Connection)

  self._listeners[connectionId] = listener -- Store the actual listener function by ID

  return connection
end

--[[
  Fires the event, calling all connected listeners with the provided arguments.
  Listeners are called safely using pcall.
  @param ...: Arguments to pass to the listeners.
--]]
function Event:Fire(...)
  local args = {...}

  -- Create a copy of the listeners table to handle cases where a listener
  -- might connect or disconnect another listener during the Fire call.
  local listenersToCall = {}
  for id, listener in pairs(self._listeners) do
    listenersToCall[id] = listener
  end

  -- Call listeners from the copied table
  for id, listener in pairs(listenersToCall) do
    -- Double-check if the listener still exists in the *original* table
    -- This handles cases where a listener disconnects itself or another
    -- listener *before* it gets called in this loop iteration.
    if self._listeners[id] == listener then
      local success, err = pcall(listener, unpack(args))
      if not success then
        utils:dprint2("Event", "Error in EventSignal listener: ".. err)
        -- Consider adding more context, like stack trace if possible
        -- log:error(debug.traceback(err, 2))
      end
    end
  end
end

--[[
  Waits until the event is fired and returns the arguments passed to :Fire.
  Must be called from within a coroutine managed by Luvit's event loop
  or a coroutine runner.
  @returns ...: The arguments passed to the :Fire call that resumed the wait.
--]]
function Event:Wait()
  local currentCoroutine = coroutine.running()
  if not currentCoroutine then
    error("EventSignal:Wait() must be called from within a coroutine.", 2)
  end

  local connection
  local results

  connection = self:Connect(function(...)
    -- Store results before disconnecting/resuming, in case of weird edge cases
    results = {...}

    -- Important: Disconnect *before* resuming. If the waiting coroutine
    -- immediately calls Wait() again, this prevents the old temporary
    -- listener from sticking around.
    if connection.Connected then
        connection:Disconnect()
    end

    -- Resume the waiting coroutine, passing the event arguments
    -- Use core.defer to ensure resumption happens in the next loop tick,
    -- preventing potential stack overflows if events fire rapidly.
    core.defer(coroutine.resume, currentCoroutine, unpack(results))
  end)

  -- Yield the current coroutine until resumed by the Connect listener
  return coroutine.yield()
end

-- ==================
-- Internal Constructor Function
-- ==================

-- This function actually creates the event object.
-- It's kept internal and called by EventModule.new
local function createEventInstance()
  local self = setmetatable({
    _listeners = {}, -- Table to store listeners [connectionId] = listenerFn
  }, Event)
  return self
end

-- ==================
-- Module Export
-- ==================

-- Create the module table that will be returned by require()
local EventModule = {}

--[[
  Constructor function to create a new EventSignal object.
  @returns (Event): The new event object.
--]]
function EventModule.new()
  return createEventInstance()
end

-- Return the module table containing the .new constructor
return EventModule