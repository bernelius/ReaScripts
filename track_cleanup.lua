-- description:
-- deletes any track that is empty, has no name, has no fx, is not a parent folder, and has no sends/receives.
-- renames (send/recv) and recolors any empty track that has active sends or receives but apart from that fits the first condition.
-- renames (FOLDER) and recolors any folder without a name, that meet the previous conditions.
-- changes color and adds prefix NOMEDIA to any track without sends/receives that has active fx but no media on the timeline.

-- author bernelius

-- version 1.0


local total = reaper.CountTracks(0)
for i = total-1, 0, -1 do
  local tr = reaper.GetTrack(0, i)
  
  -- Check the track name
  local _, name = reaper.GetTrackName(tr)
  
  -- Check if the name matches a default pattern like "Track X" (replace with your REAPER defaults)
  local has_default_name = name:match("^Track %d+$")
  
  local is_stem = name:match("stem$")
  
  -- Additional checks
  local has_no_media = reaper.GetTrackNumMediaItems(tr) == 0
  local fx_count = reaper.TrackFX_GetCount(tr)
  local is_folder = reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERDEPTH") == 1
  local has_receives = reaper.GetTrackNumSends(tr,-1) == 1
  local has_sends = reaper.GetTrackNumSends(tr,0) == 1
  
  -- delete the track if it has no custom name, no FX, and is not a parent folder track
  if (not name or name == "" or has_default_name or is_stem) 
    and fx_count == 0
    and has_no_media
    and not is_folder
    and not has_receives
    and not has_sends then
    reaper.DeleteTrack(tr)
	
  -- rename and recolor empty tracks that have active sends or receives
  elseif (not name or name == "" or has_default_name)
    and has_no_media
    and fx_count == 0
    and not is_folder then
    if has_receives and not has_sends then
      reaper.SetTrackColor(tr,reaper.ColorToNative(255,0,0))
      reaper.GetSetMediaTrackInfo_String(tr,"P_NAME","recv",1)
    elseif has_sends and not has_receives then
      reaper.SetTrackColor(tr,reaper.ColorToNative(0,255,0))
      reaper.GetSetMediaTrackInfo_String(tr,"P_NAME","send",1)
    end
	
  -- rename and recolor folders without names
  elseif (not name or name == "" or has_default_name)
    and has_no_media
    and is_folder
    and not has_receives
    and not has_sends
    and fx_count == 0 then
    reaper.SetTrackColor(tr,reaper.ColorToNative(0,0,255))
    reaper.GetSetMediaTrackInfo_String(tr,"P_NAME","FOLDER",1)
	
  -- identifies tracks that have no media but fx active, changes color to pink
  elseif has_no_media and not is_folder and not has_receives and not has_sends and fx_count~=0 and not name:match("hild$") then
    reaper.SetTrackColor(tr,reaper.ColorToNative(245,86,189))
    local new_name = "NOMEDIA " .. name
    if name:match("^NOMEDIA ") == nil then
	reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", new_name, true)
    end
  end
end

