local function get_bypass_command(fx_on)
    if fx_on then
        return "_SWS_BYPASSFX"
    else
        return "_SWS_UNBYPASSFX"
    end
end

local curr_track = reaper.GetSelectedTrack(0, 0)
local fx_on = reaper.GetMediaTrackInfo_Value(curr_track, "I_FXEN") ~= 0
local sel_children = reaper.NamedCommandLookup("_SWS_SELCHILDREN2")
local command = reaper.NamedCommandLookup(get_bypass_command(fx_on))
local unselect_all_tracks = 40297

reaper.Main_OnCommand(sel_children, 0)
reaper.Main_OnCommand(command, 0)
reaper.Main_OnCommand(unselect_all_tracks, 0)
reaper.SetOnlyTrackSelected(curr_track)
