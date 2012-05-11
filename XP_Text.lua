--
-- time of day string display
--   some code ganked from the system UI XP Bar, also
--   borrowed basic structure from tyroney's Game_Clock, which
--   borrowed code from thanto_
--

require "string"
require "math"
require "table"

local math = math;

--CONSTANTS
local FRAME = Component.GetFrame("Main")
local XP_TEXT = Component.GetWidget("XP_Text")

-- TWEAKUI INFO
require "lib/lib_TweakUI"
TWEAKUI = {}
TWEAKUI.FRAMENAME  = "Main"
TWEAKUI.FORMAT    = "<Xpct><Ypct><WIDTH><HEIGHT>"
TWEAKUI.DEFAULTS  = {
  _VERSION    = 1,
  Xpct = {key="left:", value="5", link="; "},
  Ypct = {key="bottom:", value="100%%-30", link="; "},  
  WIDTH = {key="width:", value=120, link="; "},
  HEIGHT = {key="height:", value=20, link="; "},
  SCALE = 1,
  ENABLED = "true",
}
TweakUI.AddOption({id="ENABLED", label="Show XP Text", button="checkbox", reply="self"})
TweakUI.AddOption({id="SCALE", label="Scale", button="slider", min=0.5, max=2.0, inc=0.01, format="%0.0f", convert="percent", unit="%", reply="tweakui", disable={id="ENABLED",is="=",to="false"}})

--VARIABLES
local g_enabled = true
local g_HUDShow = true
local cb_update = nil 

local g_XPinfo    = {};

-- %%%%%%%%%%%%% Edit these if you want %%%%%%%%%%%%
local daystrings = {"midnight", "past midnight", "early", "dawn", "morning", "late morning", "midday", "afternoon", "evening", "dark", "late", "extra", "error"}

--EVENTS
function OnComponentLoad()
  
end

function OnShow(args)
  g_HUDShow = args.show
  FRAME:ParamTo("alpha", tonumber(g_HUDShow), args.dur);
end

function OnMessage(args)
  if args.type == "ENABLED" then
    g_enabled = (args.data == true or args.data == "true")
    FRAME:Show(g_enabled and not Player.IsSpectating())
    if g_enabled then
      CancelUpdate()
      --UpdateTime()
      if g_XPinfo.remaining ~= nil then
        local xp_string = string.format("%d / %d [%d to next level]", g_XPinfo.player_level_xp, g_XPinfo.total_level_xp, g_XPinfo.remaining);
        log(xp_string);
        XP_TEXT:SetText(xp_string);
      else
        log("No XP Info loaded yet!");
        UpdateXP();
        local xp_string = string.format("%d / %d [%d to next level]", g_XPinfo.player_level_xp, g_XPinfo.total_level_xp, g_XPinfo.remaining);
        log(xp_string);
        XP_TEXT:SetText(xp_string);
      end
    elseif cb_update then
      cancel_callback(cb_update)
      cb_update = nil
    end
  end
end

function OnExperienceChanged()
  UpdateXP();
end

function OnBattleframeChanged()
  UpdateXP();
end

function UpdateXP()
  log("UpdateXP called!")
  g_XPinfo = Player.GetClassProgression();
  if g_XPinfo.total_level_xp > 0 then
    g_XPinfo.percent = g_XPinfo.player_level_xp / g_XPinfo.total_level_xp;
    g_XPinfo.remaining = g_XPinfo.total_level_xp - g_XPinfo.player_level_xp;
    local xp_string = string.format("%d / %d [%d to next level]", g_XPinfo.player_level_xp, g_XPinfo.total_level_xp, g_XPinfo.remaining);
    log(xp_string);
    XP_TEXT:SetText(xp_string);
  else
    g_XPinfo.percent = 0
    g_XPinfo.remaining = 0
  end
end

function CancelUpdate()
  if cb_update then
    cancel_callback(cb_update)
    cb_update = nil;
  end
end
