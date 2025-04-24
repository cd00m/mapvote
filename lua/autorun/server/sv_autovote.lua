util.AddNetworkString( "PSY_mapvote_getGamemodeTimeLimit" )
hook.Add( "Initialize", "AutoMapVote", function()
	CreateConVar( "mapvote_debugmode", "0", {FCVAR_ARCHIVE,FCVAR_REPLICATED}, "Activate Debug Mode to receive Table Contents", 0, 1 )
	-- if GAMEMODE_NAME == "prop_hunt" then
		-- hook.Add("InitPostEntity", "X2ZCompat", function()
			-- RunConsoleCommand("ph_enable_mapvote", "0")
			-- RunConsoleCommand("ph_use_custom_mapvote", "1")
			-- RunConsoleCommand("ph_custom_mv_func", "MapVote.Start()")
			-- RunConsoleCommand("ph_custom_mv_concmd", "mapvote")
			-- print("X2Z Compatibility applied by default")
		-- end)

	-- end
	
	local mapvote_autovote = 
	{
		["laststand2"] = {["convarName"] = "mapvote_lst_maxrounds", ["convarValue"] = "1",["hookName"] = "MapChange"},
		["screenhack"] = {["convarName"] = "mapvote_sc_maxrounds", ["convarValue"] = "3", ["hookName"] = "SC_RoundEnd"},
		["amongus"] = {["convarName"] = "mapvote_au_maxrounds", ["convarValue"] = "3", ["hookName"] = "GMAU GameEnd"},
		["guesswho"] = {["convarName"] = "mapvote_gw_maxrounds", ["convarValue"] = "6", ["hookName"] = "GWPostRound"},
		["hideandseek"] = {["convarName"] = "mapvote_hns_maxrounds", ["convarValue"] = "6", ["hookName"] = "HASVotemapStart"},
		["bugboys"] = {["convarName"] = "mapvote_bb_maxrounds", ["convarValue"] = "1", ["hookName"] = "GameRestart"},
		["basebuild"] = {["convarName"] = "mapvote_baseb_maxrounds", ["convarValue"] = "1", ["hookName"] = "round.End"},
		["zombiesurvival"] = {["convarName"] = "mapvote_zombiesurvival_maxrounds", ["convarValue"] = "3", ["hookName"] = "RealMap"},
		["melonbomber"] = {["convarName"] = "mapvote_melonbomber_maxrounds", ["convarValue"] = "8", ["hookName"] = "OnEndRound"},
		["prop_hunt"] = {["convarName"] = "mapvote_prophunt_maxrounds", ["convarValue"] = "8", ["hookName"] = "OnRoundEnd"},
		["g-surf"] = {["convarName"] = "mapvote_g-surf_maxtime", ["convarValue"] = "600", ["hookName"] = nil},
		["murder"] = {["convarName"] = "mapvote_murder_maxrounds", ["convarValue"] = "8", ["hookName"] = "OnEndRound"},
		["homicide_modded"] = {["convarName"] = "mapvote_homicide_modded_maxrounds", ["convarValue"] = "8", ["hookName"] = "StartNewRound"}
		
	}
	

	do
		for k,v in pairs(mapvote_autovote) do
			if !ConVarExists(v.convarName) then 
				CreateConVar( v.convarName, v.convarValue, {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Set round limit before mapvote" )
				mapvote_autovote[k].convarValue = GetConVar(v.convarName):GetString()
				cvars.AddChangeCallback(v.convarName, function(name, value_old, value_new)
					mapvote_autovote[k].convarValue = value_new
				end)
			end
		end
	end
	

	util.AddNetworkString( "PSY_mapvote_offerGamemodeTimeLimit")

	if mapvote_autovote[GAMEMODE_NAME] ~= nil and mapvote_autovote[GAMEMODE_NAME]["hookName"] ~= nil and tonumber(mapvote_autovote[GAMEMODE_NAME]["convarValue"]) > 0 then
		local currentRound = 0
		
		function StartupMapVote()
			if GetConVar(mapvote_autovote[GAMEMODE_NAME]["convarName"]):GetInt() <= 0 then return end
			currentRound = currentRound + 1
			if currentRound >= GetConVar(mapvote_autovote[GAMEMODE_NAME]["convarName"]):GetInt() then
				MapVote.Start()
				currentRound = 0
				return
			end
		end
		hook.Add(mapvote_autovote[GAMEMODE_NAME]["hookName"], GAMEMODE_NAME.."Mapvote", StartupMapVote)
		
	elseif mapvote_autovote[GAMEMODE_NAME] ~= nil and mapvote_autovote[GAMEMODE_NAME]["hookName"] == nil and tonumber(mapvote_autovote[GAMEMODE_NAME]["convarValue"]) > 0 then
		function MapVote.StartGamemodeTimer()
			local timelimit = tonumber(mapvote_autovote[GAMEMODE_NAME]["convarValue"])
			if timelimit == 0 then return end
			timer.Create("GamemodeTimeLimitTimer", 1, 0, function()
				timelimit = timelimit - 1
				if timelimit <= 0 then timer.Stop("GamemodeTimeLimitTimer") MapVote.Start() timelimit = tonumber(mapvote_autovote[GAMEMODE_NAME]["convarValue"]) end
			end)
			net.Start("PSY_mapvote_offerGamemodeTimeLimit")
				net.WriteInt(timelimit,15)
			net.Broadcast()
			
			net.Receive("PSY_mapvote_getGamemodeTimeLimit", function(len, ply) 
				net.Start("PSY_mapvote_offerGamemodeTimeLimit")
					net.WriteInt(timelimit,15)
				net.Send(ply)
			end)
		end
		MapVote.StartGamemodeTimer()
	end
	
	
	util.AddNetworkString( "mapvote_changeConVar" )
	util.AddNetworkString( "mapvote_offerGUIConVars" )
	util.AddNetworkString( "mapvote_requestGUIConVars" )
	
	net.Receive("mapvote_changeConVar", function(len,ply)
		if not ply:IsAdmin() then return end
		local xname = net.ReadString()
		local xvalue = net.ReadString()
		GetConVar(xname):SetString(xvalue)
	end)

	net.Receive("mapvote_requestGUIConVars", function(len,ply)
		if not ply:IsAdmin() then return end
		net.Start("mapvote_offerGUIConVars")
			net.WriteTable(mapvote_autovote)
		net.Send(ply)
	end)
	
	if GAMEMODE_NAME == "terrortown" then
		
		for k,v in ipairs(engine.GetGamemodes()) do
			if v.name == "terrortown" then
				if v.title == "Trouble in Terrorist Town 2" then
					function gameloop.CheckForMapSwitch()
						if not gameloop.HasLevelLimits() then
							return
						end

						local roundsLeft = gameloop.GetRoundsLeft()
						local timeLeft = gameloop.GetLevelTimeLeft()
						local nextMap = string.upper(game.GetMapNext())

						if roundsLeft <= 0 or timeLeft <= 0 then
							gameloop.StopTimers()
							gameloop.SetPhaseEnd(CurTime())

							MapVote.Start()
						else
							LANG.Msg("limit_left", { num = roundsLeft, time = math.ceil(timeLeft / 60) })
						end
					end
					return
				else
					function CheckForMapSwitch()
						-- Check for mapswitch
						local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
						SetGlobalInt("ttt_rounds_left", rounds_left)
						 
						local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())
						local switchmap = false
						local nextmap = string.upper(game.GetMapNext())
						 
						if rounds_left <= 0 then
							LANG.Msg("limit_round", {mapname = nextmap})
							switchmap = true
						elseif time_left <= 0 then
							LANG.Msg("limit_time", {mapname = nextmap})
							switchmap = true
						end
						
						if switchmap then
							timer.Stop("end2prep")
							MapVote.Start()
						end
					end
					return
				end
			end
		end
		
	end

	if GAMEMODE_NAME == "deathrun" then
	
		function RTV.Start()
			MapVote.Start(nil, nil, nil, nil)
		end
		
	end


	
end )


