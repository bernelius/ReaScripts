-- @description a script to create child tracks for each selected track
-- @version 1.0
-- @author bernelius

local count = reaper.CountSelectedTracks(0)

local tracks = {}
for i = 0, count - 1 do
    tracks[#tracks + 1] = reaper.GetSelectedTrack(0, i)
end

if not tracks then
    reaper.ShowMessageBox("Select one or more tracks.", "Make children for all selected tracks", 0)
    return
end

reaper.Undo_BeginBlock()

local deselect_all = 40297
reaper.Main_OnCommand(deselect_all, 0)

for _, track in ipairs(tracks) do
    local parent_idx = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    local child_idx = parent_idx + 1
    reaper.InsertTrackInProject(0, child_idx, 1)
    local child = reaper.GetTrack(0, child_idx)
    reaper.SetTrackSelected(child, true)
    reaper.ReorderSelectedTracks(parent_idx, 1)
    reaper.SetTrackSelected(child, false)
end

for _, track in ipairs(tracks) do
    reaper.SetTrackSelected(track, true)
end

reaper.Undo_EndBlock("Make children for all selected tracks", -1)
