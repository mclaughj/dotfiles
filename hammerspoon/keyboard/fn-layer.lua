local eventtap = hs.eventtap
local eventTypes = hs.eventtap.event.types
local message = require('keyboard.status-message')

local fnLayer = {
  statusMessage = message.new('fn layer'),
  enter = function(self)
    if not self.active then self.statusMessage:show() end
    self.active = true
  end,
  reset = function(self)
    self.active = false
    self.modifiers = {}
    self.statusMessage:hide()
  end,
}
fnLayer:reset()

--------------------------------------------------------------------------------
-- Hold down the fn key to enter the function layer
--------------------------------------------------------------------------------
fnLayerActivationListener = eventtap.new({ eventTypes.flagsChanged }, function(event)

  local newMods = event:getFlags()
  
  if newMods['fn'] == true then
    fnLayer:enter()
  end
  
end):start()

fnLayerDeactivationListener = eventtap.new({ eventTypes.flagsChanged }, function(event)

  local newMods = event:getFlags()
  
  if newMods['fn'] == nil then
    fnLayer:reset()
  end
  
end):start()

--------------------------------------------------------------------------------
-- Watch for j/k/l/; key down events in fn layer, and trigger the
-- corresponding arrow key events
--------------------------------------------------------------------------------
fnLayerNavListener = eventtap.new({ eventTypes.keyDown }, function(event)
  if not fnLayer.active then
    return false
  end

  local charactersToKeystrokes = {
    j = 'down',
    k = 'up',
    l = 'left'
  }
  charactersToKeystrokes[';'] = 'right'
  charactersToKeystrokes[':'] = 'right' -- Account for the shifted case, which isn't accounted for with the call to lower() below

  local keystroke = charactersToKeystrokes[event:getCharacters(true):lower()]
  if keystroke then
    local modifiers = {}
    n = 0
    -- Apply the standard modifier keys that are active (if any)
    for k, v in pairs(event:getFlags()) do
      n = n + 1
      modifiers[n] = k
    end

    keyUpDown(modifiers, keystroke)
    return true
  end
end):start()

--------------------------------------------------------------------------------
-- Watch for u/i/o/p key down events in fn layer, and trigger the corresponding
-- key events to navigate to the first/previous/next/last tab respectively
--------------------------------------------------------------------------------
fnLayerTabNavKeyListener = eventtap.new({ eventTypes.keyDown }, function(event)
  if not fnLayer.active then
    return false
  end

  local charactersToKeystrokes = {
    u = { {'cmd'}, '1' },          -- go to first tab
    i = { {'cmd', 'shift'}, '[' }, -- go to previous tab
    o = { {'cmd', 'shift'}, ']' }, -- go to next tab
    p = { {'cmd'}, '9' },          -- go to last tab
  }
  local keystroke = charactersToKeystrokes[event:getCharacters()]

  if keystroke then
    keyUpDown(table.unpack(keystroke))
    return true
  end
end):start()
