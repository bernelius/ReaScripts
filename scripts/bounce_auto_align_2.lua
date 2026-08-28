-- @description a convenience script to make auto-align 2 workflow much faster with drum multitracks
-- @version 1.6
-- @author bernelius
-- @about
--   bounce_auto_align_2.lua
--   bounces all child tracks of a selected folder, on the conditions that they have:
--   1: an input channel assigned
--   2: at least one plugin
--   3: they do not have "stem" in the name

-- Get the selected track (folder track)
local selected_track = reaper.GetSelectedTrack(0, 0)

-- Check if the selected track is a folder track
local is_folder_track = reaper.GetMediaTrackInfo_Value(selected_track, "I_FOLDERDEPTH") ~= 0

if not is_folder_track then
    reaper.ShowMessageBox("Please select a folder track.", "Error", 0)
else
    local parent_index = reaper.GetMediaTrackInfo_Value(selected_track, "IP_TRACKNUMBER") - 1
    -- Count the total number of tracks in the project
    local track_count = reaper.CountTracks(0)
    local descendant_tracks = {}

    -- Loop through all tracks in the project
    for i = parent_index + 1, track_count - 1 do
        local track = reaper.GetTrack(0, i)

        -- Get track information
        local _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
        local input = reaper.GetMediaTrackInfo_Value(track, "I_RECINPUT")
        local fx_count = reaper.TrackFX_GetCount(track)

        -- Skip tracks ending with "stem" in the name, input disabled, or no plugins
        if not track_name:match("stem$") and input >= 0 and fx_count > 0 then
            -- Check if this track is a descendant of the selected folder track
            local parent = reaper.GetParentTrack(track)
            while parent ~= nil do
                if parent == selected_track then
                    table.insert(descendant_tracks, track)
                    break
                end
                parent = reaper.GetParentTrack(parent)
            end
        end
    end

    -- Clear all selections and only select valid descendant tracks
    reaper.Main_OnCommand(40297, 0) -- Unselect all tracks

    Items_to_delete = {}

    for _, track in ipairs(descendant_tracks) do
        reaper.SetTrackSelected(track, true)
        local item_count = reaper.CountTrackMediaItems(track)
        for j = 0, item_count - 1 do
            local item = reaper.GetTrackMediaItem(track, j)
            table.insert(Items_to_delete, item)
        end
    end

    -- Bypass all plugins except the first (Auto-Align 2) on selected tracks
    for i = 0, reaper.CountSelectedTracks(0) - 1 do
        local track = reaper.GetSelectedTrack(0, i)
        if track ~= nil then
            local fx_count = reaper.TrackFX_GetCount(track)
            if fx_count > 1 then
                for j = 1, fx_count - 1 do
                    reaper.TrackFX_SetEnabled(track, j, false)
                end
            end
        end
    end

    -- Call the SWS Auto Render Mono Smart action
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWRENDERMONOSMART"), 0)
end

reaper.Main_OnCommand(40289, 0) -- Unselect all items

-- Loop through selected tracks
local num_selected_tracks = reaper.CountSelectedTracks(0)

for i = 0, num_selected_tracks - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    local item_count = reaper.CountTrackMediaItems(track)

    -- Loop through all media items on the track
    for j = 0, item_count - 1 do
        local item = reaper.GetTrackMediaItem(track, j)
        reaper.SetMediaItemSelected(item, true)
    end
end

reaper.Main_OnCommand(40032, 0) -- Item: Group items

-- Delete all files on original descendant tracks
for i = #Items_to_delete, 1, -1 do
    reaper.DeleteTrackMediaItem(reaper.GetMediaItem_Track(Items_to_delete[i]), Items_to_delete[i])
end
