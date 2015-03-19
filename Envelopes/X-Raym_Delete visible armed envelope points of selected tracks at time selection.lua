--[[
 * ReaScript Name: Delete visible armed envelope points of selected tracks at time selection
 * Description: A way to delete multiple points accros different envelopes and tracks.
 * Instructions: Make a selection area. Execute the script.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URl: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * Version: 1.0
 * Version Date: 2015-03-19
 * REAPER: 5.0 pre 17
 * Extensions: SWS 2.6.3 #0
 --]]
 
--[[
 * Changelog:
 * v9.0 (2015-03-19)
	+ beta
 --]]

--[[ ----- DEBUGGING ====>

local info = debug.getinfo(1,'S');

local full_script_path = info.source

local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name

if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "..\\Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "../Functions/?.lua"
end

require("X-Raym_Functions - console debug messages")


debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.
]]
--msg_clean()
-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- GET CURSOR POS
	offset = reaper.GetCursorPosition()

	startLoop, endLoop = reaper.GetSet_LoopTimeRange2(0, false, true, 0, 0, false)
	--reaper.ShowConsoleMsg("startLoop\n"..tostring(startLoop).."\n")
	--reaper.ShowConsoleMsg("endLoop\n"..tostring(endLoop).."\n")
	startLoop = math.floor(startLoop * 100000000+0.5)/100000000
	endLoop = math.floor(endLoop * 100000000+0.5)/100000000
	--reaper.ShowConsoleMsg("startRound\n"..tostring(startLoop).."\n")
	--reaper.ShowConsoleMsg("endRound\n"..tostring(endLoop).."\n")

		-- LOOP TRHOUGH SELECTED TRACKS
		selected_tracks_count = reaper.CountSelectedTracks(0)
		for i = 0, selected_tracks_count-1  do
			
			-- GET THE TRACK
			track = reaper.GetSelectedTrack(0, i) -- Get selected track i

			-- LOOP THROUGH ENVELOPES
			env_count = reaper.CountTrackEnvelopes(track)
			for j = 0, env_count-1 do

				-- GET THE ENVELOPE
				env = reaper.GetTrackEnvelope(track, j)
				br_env = reaper.BR_EnvAlloc(env, false)
				active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)
				
				-- IF VISIBLE AND ARMED
				--[[retval, strNeedBig = reaper.GetEnvelopeStateChunk(env, "", true)
				x, y = string.find(strNeedBig, "VIS 1")
				w, z = string.find(strNeedBig, "ARM 1")]]
				if visible == true and active == true then
					
					env_points_count = reaper.CountEnvelopePoints(env)

					if env_points_count > 0 then

						for k = 0, env_points_count-1 do
							retval, timeOut, valueOut, shapeOutOptional, tensionOutOptional, selectedOutOptional = reaper.GetEnvelopePoint(env, k)
							position, value, shape, selected, bezier = reaper.BR_EnvGetPoint(br_env, k)
							--reaper.ShowConsoleMsg("pointTime:\n"..tostring(timeOut).."\n")
							--reaper.ShowConsoleMsg("startRound\n"..tostring(startLoop).."\n")
							reaper.ShowConsoleMsg("BR_Time: "..tostring(position).."\n")
							-- IF IN TIME SELECTION
							if timeOut == startLoop or timeOut == endLoop then -- une boucle while vace un get poitn at time serait mieux
								--reaper.ShowConsoleMsg("MATCH\n")
								delete = reaper.BR_EnvDeletePoint(br_env, k)
								--reaper.DeleteEnvelopePointRange(env, timeOut-0.000000001, timeOut+0.000000001)
								reaper.ShowConsoleMsg("delete: "..tostring(delete).."\n")
							end

							reaper.ShowConsoleMsg("------\n")

						end

					end
					
					reaper.BR_EnvFree(br_env, false)
					reaper.Envelope_SortPoints(env)
				
				end -- ENFIF visible
				
			end -- ENDLOOP through envelopes

		end -- ENDLOOP through selected tracks

		reaper.Undo_EndBlock("Delete visible armed envelope points of selected tracks at time selection", 0) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

--msg_start() -- Display characters in the console to show you the begining of the script execution.

--[[ reaper.PreventUIRefresh(1) ]]-- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

--[[ reaper.PreventUIRefresh(-1) ]] -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.

-- Update the TCP envelope value at edit cursor position
function HedaRedrawHack()
	reaper.PreventUIRefresh(1)

	track=reaper.GetTrack(0,0)

	trackparam=reaper.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT")	
	if trackparam==0 then
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 1)
	else
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0)
	end
	reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", trackparam)

	reaper.PreventUIRefresh(-1)
	
end

HedaRedrawHack()
