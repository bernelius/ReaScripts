-- @description a script to create child tracks for each selected track
-- @version 1.1
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
    local _, name = reaper.GetTrackName(track)
    local parent = {
        track = track,
        idx = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER"),
        name = name,
    }

    local child = {
        idx = parent.idx + 1,
        name = parent.name .. " child",
    }
    reaper.InsertTrackInProject(0, child.idx, 1)
    child.track = reaper.GetTrack(0, child.idx)
    reaper.GetSetMediaTrackInfo_String(child.track, "P_NAME", child.name, true)
    reaper.SetTrackSelected(child.track, true)
    reaper.ReorderSelectedTracks(parent.idx, 1)
    reaper.SetTrackSelected(child.track, false)
end

for _, track in ipairs(tracks) do
    reaper.SetTrackSelected(track, true)
end

reaper.Undo_EndBlock("Make children for all selected tracks", -1)
