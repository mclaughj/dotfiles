local drawing = require 'hs.drawing'
local geometry = require 'hs.geometry'
local screen = require 'hs.screen'
local styledtext = require 'hs.styledtext'

local statusmessage = {}
statusmessage.new = function(messageText)
  local buildParts = function(messageText)
    local frame = screen.primaryScreen():frame()

    local styledTextAttributes = {
      font = { name = 'SF Mono Light', size = 18 },
      color = { red = 1, green = 1, blue = 1, alpha = 1 }
    }

    local styledText = styledtext.new("⌨️ " .. messageText, styledTextAttributes)

    local styledTextSize = drawing.getTextDrawingSize(styledText)
    local textRect = {
      x = frame.w - styledTextSize.w - 40,
      y = frame.h - styledTextSize.h + 1,
      w = styledTextSize.w + 40,
      h = styledTextSize.h + 40,
    }
    local text = drawing.text(textRect, styledText):setAlpha(0.85)

    local background = drawing.rectangle(
      {
        x = frame.w - styledTextSize.w - 50,
        y = frame.h - styledTextSize.h - 0,
        w = styledTextSize.w + 20,
        h = styledTextSize.h + 6
      }
    )
    background:setRoundedRectRadii(10, 10)
    background:setFillColor({ red = 0.2, green = 0.2, blue = 0.2, alpha = 0.7 })
    background:setStroke(false)

    return background, text
  end

  return {
    _buildParts = buildParts,
    show = function(self)
      self:hide()

      self.background, self.text = self._buildParts(messageText)
      self.background:show()
      self.text:show()
    end,
    hide = function(self)
      if self.background then
        self.background:delete()
        self.background = nil
      end
      if self.text then
        self.text:delete()
        self.text = nil
      end
    end,
    notify = function(self, seconds)
      local seconds = seconds or 1
      self:show()
      hs.timer.delayed.new(seconds, function() self:hide() end):start()
    end
  }
end

return statusmessage
