util.AddNetworkString("PSY_MapVoteStart")
util.AddNetworkString("PSY_MapVoteUpdate")
util.AddNetworkString("PSY_MapVoteCancel")
util.AddNetworkString("RTV_Delay")
util.AddNetworkString("PSY_MapVoteGamemodesDesc")
util.AddNetworkString("PSY_MapVoteMapStatistics")
util.AddNetworkString("PSY_MapVoteGamemodeStatistics")
util.AddNetworkString("PSY_MapVoteGamemodesList")
util.AddNetworkString("PSY_MapVoteCurrentGamemode")
util.AddNetworkString("PSY_MapVoteCountdownSound")
util.AddNetworkString("PSY_MapVoteRatingResults")
util.AddNetworkString("PSY_MapVoteSendRatingsTable")
util.AddNetworkString("PSY_MapVoteSendConfig")
util.AddNetworkString("PSY_MapVoteSendHierarchy")
util.AddNetworkString("PSY_MapVoteAddons")
util.AddNetworkString("PSY_MapVoteCancel2")
util.AddNetworkString("PSY_MapVote_LoadConfig")
util.AddNetworkString("PSY_MapVote_SendConfig")
util.AddNetworkString("MapVote_SetPing")
util.AddNetworkString("MapVote_UpdatePing")
util.AddNetworkString("MapVote_requestVoterCache")
util.AddNetworkString("PSY_MapVoteUpdateReady")
util.AddNetworkString("PSY_MapVoteUpdateConfirmation")
util.AddNetworkString("PSY_mapvote_announceStart")

resource.AddWorkshop( "2428251124" )
gameevent.Listen( "player_connect" )

if file.Find("mapvote/logo.png", "DATA") then
	resource.AddSingleFile("data/mapvote/logo.png")
end

MapVote.Continued = false
local voterQueue = {}
local isProcessingQueue = false
local voterCache = {}
local announceDone = false
local aTime = 3.7
local gamemodesjson = {}

local blacklist = {}
local vote_maps
local gamemodes
local prefix = {}
local votedgamemodetitle
local votedgamemode
local MapVoteCountdown
local ratingresults = {}

local function getMapPreviewHierarchy()
	local xtable = util.JSONToTable(file.Read("mapvote/mappreviewhierarchy.json", "DATA"))
	return xtable
end

local function readRatingsFile()
	local xTable = {}
	if file.Exists( "mapvote/ratingresults.json", "DATA" ) then
		xTable = util.JSONToTable(file.Read("mapvote/ratingresults.json", "DATA"))
	end
	return xTable
end

local function readStatisticsFile()
	local xtable = util.JSONToTable(file.Read("mapvote/statistics.json", "DATA"))
	return xtable
end

local function sortByRating(xtable)
	local x1 = readRatingsFile()
	table.sort( xtable, function(a, b) 	
		if (x1[a]["count"] == 0 and x1[b]["count"] != 0) then return false end
		if (x1[a]["count"] != 0 and x1[b]["count"] == 0) then return true end
		return (x1[a]["rating"]/x1[a]["count"] > x1[b]["rating"]/x1[b]["count"])
	end)
	return xtable
end

local function sortByPlaycount(xtable)
	local x1 = readStatisticsFile()
	table.sort( xtable, function(a, b) 	
		return (x1[a] > x1[b])
	end)
	return xtable
end

local function ProcessVoterQueue()
    if #voterQueue > 0 then
        local ply = voterQueue[1].target
        if IsValid(ply) then
            isProcessingQueue = true
			if not table.IsEmpty(voterQueue) then
					net.Start("PSY_MapVoteUpdate")
						net.WriteUInt(MapVote.UPDATE_VOTE, 3)
						net.WriteEntity(voterQueue[1].player)
						net.WriteUInt(voterQueue[1].map_id, 32)
					net.Send(ply)
				net.Start("PSY_MapVoteUpdateReady")
				net.Send(ply)
			end

			net.Receive("PSY_MapVoteUpdateConfirmation", function(len, ply)
				isProcessingQueue = false
				table.remove(voterQueue, 1)
				ProcessVoterQueue()
			end)
        end
    end
end

net.Receive("MapVote_requestVoterCache", function(len, ply)
    for k,v in ipairs(voterCache) do
		table.insert(voterQueue, {["target"] = ply, ["player"] = v.player, ["map_id"] = v.map_id})
	end
    if not isProcessingQueue then
        ProcessVoterQueue()
    end
end)

net.Receive("MapVote_SetPing", function(len, ply)
    local x = net.ReadInt(32)
    local y = net.ReadInt(32)
    local steamID = net.ReadString()
	local x1 = net.ReadInt(16)
	local y1 = net.ReadInt(16)
    net.Start("MapVote_UpdatePing")
        net.WriteInt(x, 32)
        net.WriteInt(y, 32)
        net.WriteString(steamID)
		net.WriteInt(x1, 16)
        net.WriteInt(y1, 16)
    net.Broadcast()
end)

net.Receive("PSY_MapVoteUpdate", function(len, ply)
    if(MapVote.Allow) then
        if(IsValid(ply)) then
            local update_type = net.ReadUInt(3)
            
            if(update_type == MapVote.UPDATE_VOTE) then
                local map_id = net.ReadUInt(32)
                
                if(MapVote.CurrentMaps[map_id]) then
                    MapVote.Votes[ply:SteamID()] = map_id
                    table.insert(voterCache, {["player"] = ply, ["map_id"] = map_id})
                    net.Start("PSY_MapVoteUpdate")
                        net.WriteUInt(MapVote.UPDATE_VOTE, 3)
                        net.WriteEntity(ply)
                        net.WriteUInt(map_id, 32)
                    net.Broadcast()
                end
            end
        end
    end
end)

function CoolDownDoStuff()
    local cooldownnum = MapVote.Config.MapsBeforeRevote or 3

	if #recentmaps == cooldownnum then 
		table.remove(recentmaps)
	end
	

    local curmap = game.GetMap():lower()..".bsp"

    if not table.HasValue(recentmaps, curmap) then
        table.insert(recentmaps, 1, curmap)
    end

    file.Write("mapvote/recentmaps.txt", util.TableToJSON(recentmaps))
	
end

local function notifyPlayers(msg)
	timer.Simple( 0.1, function()
		for i, ply in pairs( player.GetHumans() ) do
			ply:ChatPrint( msg )
		end
	end)
end

local function sendConfig(xTable, target)
	if target == nil then
		net.Start("PSY_MapVoteSendConfig")
			net.WriteTable(xTable)
		net.Broadcast()
	else
		net.Start("PSY_MapVoteSendConfig")
			net.WriteTable(xTable)
		net.Send(target)
	end
end


local function sendMapPreviewHierarchy(target)
	local xTable = getMapPreviewHierarchy()
	if target == nil then
		net.Start("PSY_MapVoteSendHierarchy")
			net.WriteTable(xTable)
		net.Broadcast()
	else
		net.Start("PSY_MapVoteSendHierarchy")
			net.WriteTable(xTable)
		net.Send(target)
	end
end

local function sendAddons(target)
	local addons = engine.GetAddons()
	local addonsStripped = {}
	for k, v in pairs(addons) do
		addonsStripped[k] = 
		{
			["title"] = v.title,
			["wsid"] = v.wsid,
			["tags"] = v.tags
		}
	end
	if addonsStripped != nil and target == nil then
		net.Start("PSY_MapVoteAddons")
			net.WriteTable( addonsStripped )
		net.Broadcast()
	elseif addonsStripped != nil then
		net.Start("PSY_MapVoteAddons")
			net.WriteTable( addonsStripped )
		net.Send(target)
	end
end

local function sendGamemodeDescriptions(target)
	if file.Exists( "mapvote/gamemodesdesc.json", "DATA" ) then --reads the MapVotesGamemodesDesc.json file to receive gamemode descriptions
		GamemodesDesc=util.JSONToTable(file.Read( "mapvote/gamemodesdesc.json", "DATA")) 
		if target == nil then
			net.Start("PSY_MapVoteGamemodesDesc")
				net.WriteTable(GamemodesDesc)
			net.Broadcast()
		else
			net.Start("PSY_MapVoteGamemodesDesc")
				net.WriteTable(GamemodesDesc)
			net.Send(target)
		end
	end
end

local function sendGamemodes(target)
	local defaultGamemodesList = {["TheFloorisLava!"]="tfil",["ExtremeFootballThrowdown"]="extremefootballthrowdown",["Sacrifun"]="sacrifun",["ArmoryAntics"]="armory-antics",["Base"]="base",["Assassins"]="assassins",["Razborka!"]="razborka",["Slayer"]="slayer",["SuperMarioBoxes"]="supermarioboxes",["Smash"]="smash",["Infection"]="infection",["QuakeIIIArenaTDM"]="q3tdm",["[DATAREQUIRED]"]="datarequired",["FrettaGamemodeBase"]="fretta13",["LastBattleRoyale"]="lastbattleroyale",["Overwatch"]="overwatch",["SourceForts"]="sourceforts",["Deathrun"]="deathrun",["FatKid"]="fatkid",["YouToucheditLast"]="youtoucheditlast",["VirusSurvivalRemake"]="virus_survival_remake",["Jazztronauts"]="jazztronauts",["Homicide"]="homicide",["TheStalker"]="stalker",["g-surf"]="g-surf",["Alien: Isolation"]="ai",["DuckHunt"]="duckhunt",["OneintheChamber"]="oitc",["GuessWho"]="guesswho",["Sts"]="sts",["QuakeIIIArenaFFA"]="q3ffa",["AmongUs"]="amongus",["TrashCompactor"]="trashcompactor",["TheHunt"]="thehunt",["Murder"]="murder",["TheHidden"]="thehidden",["BaseBuild"]="basebuild",["TroubleinTerroristTown"]="terrortown",["CallofDuty-GunGame"]="cod_gungame",["StopitSlender"]="stopitslender",["Slashers"]="slashers",["Screenhack"]="screenhack",["RagdollCombat"]="ragdoll_combat",["LightHideandSeek"]="hideandseek",["QuakeIIIArenaInstagib"]="q3instagib",["BugBoys"]="bugboys",["GroundControl"]="groundcontrol",["Melonbomber"]="melonbomber",["MelonRacer"]="melonracer",["TrenchWar"]="trench_war",["GarryWare]=GarryWareFixed"]="garryware13",["PropHunt"]="prop_hunt",["Sandbox"]="sandbox",["FiveNightsatFreddy's"]="fnafgm",["PirateShipWarsRemix"]="pswremix",["Deathrun2D"]="deathrun2d",["Zombie Survival"]="zombiesurvival"}
	
	local xlist = {}
	for k,v in ipairs(engine.GetGamemodes()) do
		xlist[v.title] = v.name
	end
	table.Inherit( xlist, defaultGamemodesList )
	if target == nil then
		net.Start("PSY_MapVoteGamemodesList")
			net.WriteTable( xlist )
		net.Broadcast()
		
		net.Start("PSY_MapVoteCurrentGamemode")
			net.WriteString( engine.ActiveGamemode() )
		net.Broadcast()
	else
		net.Start("PSY_MapVoteGamemodesList")
			net.WriteTable( xlist )
		net.Send(target)
		
		net.Start("PSY_MapVoteCurrentGamemode")
			net.WriteString( engine.ActiveGamemode() )
		net.Send(target)
	end
end


local function detectInstalledGamemodes()
	if file.Exists( "mapvote/gamemodesenabled.json", "DATA" ) then --reads the gamemodesenabled.json file to receive enabled/disabled gamemodes
		gamemodesenabledjson = util.JSONToTable(file.Read( "mapvote/gamemodesenabled.json", "DATA")) 
	end
	if GetConVar("mapvote_debugmode"):GetInt() == 1 then
		print("The content of gamemodesenabled.json file:")
		PrintTable(gamemodesenabledjson)
	end
	for k, gm in ipairs(engine.GetGamemodes()) do 
		local gmname = gm.name
		if MapVote.Config.PlayercountDependingGamemodes then --automatically detect installed gamemodes if limited to playercount
			if gamemodesenabledjson[gmname]=="enabled" and PlayercountDependingGamemodes[gmname]["min"] <= #player.GetHumans() and PlayercountDependingGamemodes[gmname]["max"] >= #player.GetHumans() then
				gamemodes[#gamemodes+1]=gmname	
			end
		elseif gamemodesenabledjson[gmname]=="enabled" then --automatically detect installed gamemodes
			gamemodes[#gamemodes+1]=gmname	
		end
	end
	if #gamemodes<2 then --skip gamemode vote if there's only one gamemode
		GamemodeVoteCompleted=true 
		votedgamemode=gamemodes[1] 
		return #gamemodes
	end
	
end

local function findMaps()
	prefix={}
	
	if table.IsEmpty(gamemodesjson) then
		if file.Exists( "mapvote/gamemodes.json", "DATA" ) then --reads the gamemodes.json file to receive map prefixes
			gamemodesjson=util.JSONToTable(file.Read( "mapvote/gamemodes.json", "DATA")) 
		end
	end
	
	if gamemodesjson[votedgamemode] then 
		prefix=gamemodesjson[votedgamemode]
	else
		for k, gm in ipairs(engine.GetGamemodes()) do 
			if gm.name==votedgamemode then 
				local temporarystring=gm.maps
				prefix=string.Explode("|", temporarystring) 
				break
			end
		end
				
		for h=1, #prefix do --remove the ^ at the beginning of each map name if found
			if string.sub( prefix[h], 1, 1 ) == "^" then 
				prefix[h]=string.sub( prefix[h], 2, nil ) 
			end 
		end 
	end
	if GetConVar("mapvote_debugmode"):GetInt() == 1 then
		print("The prefixes:")
		PrintTable(prefix)
	end
end

local function getVotedGamemodeTitle()
	for k, gm in pairs(engine.GetGamemodes()) do 
		if ( votedgamemode == gm.name ) then 
			votedgamemodetitle = gm.title
			break
		end
	end
end

local function receiveCSSFilter()
	local xtable = util.JSONToTable(file.Read("mapvote/cssmaps.json", "DATA"))
	return xtable
end

local function receiveBlacklist()
	
	if file.Exists( "ulx/gamemodes/" .. votedgamemodetitle .. "/votemaps.txt", "DATA" ) then --ulx gamemode specific map blacklist
		blacklist=file.Read( "ulx/gamemodes/" .. votedgamemodetitle .. "/votemaps.txt", "DATA" )
		blacklist=string.Explode( "\n", blacklist )
	elseif file.Exists( "ulx/votemaps.txt", "DATA" ) then --use general ulx map blacklist if there is no gamemode specific one
		blacklist=file.Read( "ulx/votemaps.txt", "DATA" )
		blacklist=string.Explode( "\n", blacklist )
	end
	if MapVote.Config.FilterCSSMaps then
		local xCSSMaps = receiveCSSFilter()
		table.Add( blacklist, xCSSMaps )
	end
end

local function addFinalMaps()
	for k, map in RandomPairs(maps) do
		if(cooldown and table.HasValue(recentmaps, map)) then continue end
		for k, v in pairs(prefix) do
			if ConVarExists( "ulx_votemapmapmode" ) and GetConVar("ulx_votemapmapmode"):GetInt() == 0 then
				if ( string.find(map, "^"..v) and table.HasValue( blacklist, map:sub(1, -5) ) ) then --only add map when in blacklist
					vote_maps[#vote_maps + 1] = map:sub(1, -5)
					amt = amt + 1
					break
				end
			else
				if ( string.find(map, "^"..v) and not table.HasValue( blacklist, map:sub(1, -5) ) ) then --only add map when not in blacklist
					vote_maps[#vote_maps + 1] = map:sub(1, -5)
					amt = amt + 1
					break
				end
			end
		end
		--if(limit and amt >= limit) then break end
	end
	for i=1, #prefix do  --if a given prefix contains a whole map name, search for it in the vote_maps list. If found and not yet contained 
		if(cooldown and table.HasValue(recentmaps, prefix[i]..".bsp")) then continue end
		if table.HasValue( maps, prefix[i]..".bsp" ) == true and table.HasValue( vote_maps, prefix[i] ) == false then --put it in
			vote_maps[#vote_maps+1]=prefix[i] 
		end
	end
end


local function checkMapLimitExceeded()
	if MapVote.Config.ReplayMapButton == true and GamemodeVoteCompleted == true then
		table.RemoveByValue( vote_maps, game.GetMap() )
	end

	if (GamemodeVoteCompleted and MV and nominations_backup and engine.ActiveGamemode() == "deathrun") then
		local vote_maps_backup = {}
		local nominations_backup = {}
		table.CopyFromTo( vote_maps, vote_maps_backup )
		table.CopyFromTo( MV.Nominations, nominations_backup )
		
		while #vote_maps<limit do
			if #nominations_backup > 1 then -- Deathrun nominate
				local randnum = math.random( 0, #nominations_backup - 1 )
				table.insert( vote_maps, nominations_backup[ randnum ] )
				table.remove( nominations_backup, randnum )
			elseif #vote_maps_backup > 1 then
				local randnum = math.random( 0, #vote_maps_backup - 1 )
				if not table.HasValue( vote_maps, vote_maps_backup[randnum] ) then
					table.insert( vote_maps, vote_maps_backup[randnum] )
				end
				table.remove( vote_maps_backup, randnum )
			else
				break
			end
		end
	elseif (#vote_maps>limit) then
		print("[Perfect MapVote] Map Limit exceeded. Applying Map Selection Logic")
		xMapSelectionMode = MapVote.Config.MapSelectionMode
		if xMapSelectionMode == "random" then
			while #vote_maps>limit do 
				table.remove( vote_maps, math.random( 1,#vote_maps ))
			end
		elseif xMapSelectionMode == "bestRated" then
			local sortedTable = sortByRating(vote_maps)
			while #vote_maps>limit do 
				table.RemoveByValue( vote_maps, table.remove( sortedTable ) )
			end
		elseif xMapSelectionMode == "leastPlayed" then
			local sortedTable = sortByPlaycount(vote_maps)
			while #vote_maps>limit do 
				table.RemoveByValue( vote_maps, table.remove( sortedTable, 1 ) )
			end
		elseif xMapSelectionMode == "50/50 bestRated & leastPlayed" then
			local playCountSorted = {}
			table.CopyFromTo(sortByPlaycount(vote_maps), playCountSorted)
			local ratingSorted = {}
			table.CopyFromTo(sortByRating(vote_maps), ratingSorted)
			table.Empty(vote_maps)

			for i = 1, (math.floor(limit/2) + limit%2) do
				table.insert( vote_maps, table.remove(playCountSorted) )
				if table.IsEmpty(playCountSorted) then break end
			end
			for i = (math.floor(limit/2) + limit%2 + 1), limit do
				table.insert( vote_maps, table.remove(ratingSorted, 1) )
				if table.IsEmpty(ratingSorted) then break end
			end
		end
	end
	
end

local function sortMapsGamemodes()
	table.sort(vote_maps) 
end

local function shuffleMapsGamemodes()
	table.Shuffle(vote_maps)
end

local function printErrorMessage()
	print("[Mapvote] I couldn't find any maps. Is there something wrong?") 
	print("[Mapvote] Chosen gamemode is: "..votedgamemode)
	print("[Mapvote] Available Maps are: ")
	PrintTable(vote_maps)
	print("[Mapvote] Viable Prefixes are: ")
	PrintTable(prefix)
	print("Cooldown Maps are: ")
	PrintTable(recentmaps)
	if not table.IsEmpty(blacklist) then
		print("ULX blacklisted maps are: ")
		PrintTable(blacklist)
	end
	notifyPlayers("Mapvote cancelled. No maps found. See Server Console for details")
	timer.Destroy("PSY_MapVote")
end



local function addReplayMapButton()
	--apparently some gamemodes stop working when extending the current map so let's do a blacklist
	local blackListedGamemodes = 
	{
		"zombiesurvival"
	}

	if (table.HasValue(blackListedGamemodes, engine.ActiveGamemode())) then
		table.insert(vote_maps,1,"REPLAY MAP AND GM") 
		return
	end
	table.insert(vote_maps,1,"EXTEND CURRENT MAP") 
	return
end

local function insertRandomButton()
	table.insert(vote_maps,1,"RANDOM")
end

local function sendMapsGamemodes(target)
	if target == nil then
		net.Start("PSY_MapVoteStart") --send maps/gamemodes to client
			net.WriteUInt(#vote_maps, 32)
			for i = 1, #vote_maps do
				net.WriteString(vote_maps[i])
			end
			net.WriteBool ( GamemodeVoteCompleted )
			net.WriteUInt( length, 32 )
		net.Broadcast()
	else
		net.Start("PSY_MapVoteStart") --send maps/gamemodes to client
			net.WriteUInt(#vote_maps, 32)
			for i = 1, #vote_maps do
				net.WriteString(vote_maps[i])
			end
			net.WriteBool ( GamemodeVoteCompleted )
			net.WriteUInt( MapVoteCountdown, 32 )
		net.Send(target)
	end
end

local function sendStatistics(target)
	local mapvote_statistics = readStatisticsFile()
	local mapvote_statistics_map = {}
	for i = 1, #vote_maps do	
		mapvote_statistics_map[vote_maps[i]] = mapvote_statistics[vote_maps[i]] or 0
	end

	if target == nil then
		net.Start("PSY_MapVoteMapStatistics")
			net.WriteTable(mapvote_statistics_map)
		net.Broadcast()
	else
		net.Start("PSY_MapVoteMapStatistics")
			net.WriteTable(mapvote_statistics_map)
		net.Send(target)
	end
end

local function prepareGamemodeVote()
	print("[MapVote] Starting Gamemode Vote...")
	if GamemodeDesc then 
		sendGamemodeDescriptions()
	end
	sendGamemodes()
	is_expression = false
	vote_maps = {}
	gamemodes = {} --effective gamemodes for gamemode vote
	local decider = detectInstalledGamemodes()
	
	if decider == 1 then return false elseif decider == 0 then return 0 end
	for i=1,#gamemodes do
		vote_maps[i]=gamemodes[i]
	end
	
	if MapVote.Config.SortMapsBy == "name" then --sorts maps / gamemodes if set to true in config file
		sortMapsGamemodes()
	elseif MapVote.Config.SortMapsBy == "rating" then
		vote_maps = sortByRating(vote_maps)
	elseif MapVote.Config.SortMapsBy == "random" then
		shuffleMapsGamemodes()
	elseif MapVote.Config.SortMapsBy == "playcount" then
		vote_maps = sortByPlaycount(vote_maps)
	end
	
	
	if MapVote.Config.ReplayMapButton then --adds replay current map button if set to true in config file
		addReplayMapButton()
	end
		
	insertRandomButton()
	
	ConvertGamemodes(vote_maps,vote_maps) --change internal gamemode names to more readable ones
	sendMapsGamemodes()
	ConvertGamemodes(vote_maps,vote_maps) --change internal gamemode names to more readable ones

	if MapVote.Config.Statistics then
		sendStatistics()		
	end
end

local function prepareMapVote()
	print("[MapVote] Starting Mapvote...")
	is_expression = false
    maps = file.Find("maps/*.bsp", "GAME")
    vote_maps = {}
    amt = 0
	
	
	gamemodesjson = {}
	findMaps()--finds suitable maps depending on stored map prefixes for chosen gamemode
	getVotedGamemodeTitle()
	receiveBlacklist()
	addFinalMaps()
	checkMapLimitExceeded()
	if (MapVote.Config.GamemodesAndMapsHaveRatings ~= nil and MapVote.Config.GamemodesAndMapsHaveRatings) then
		sendRatingsTable()
	end
	
	if MapVote.Config.SortMapsBy == "name" then 
		sortMapsGamemodes()
	elseif MapVote.Config.SortMapsBy == "rating" then
		vote_maps = sortByRating(vote_maps)
	elseif MapVote.Config.SortMapsBy == "random" then
		shuffleMapsGamemodes()
	end
		

	if #vote_maps==1 then
		MapVote.Change(votedgamemode,vote_maps[1],"[Mapvote] Mapvote has been skipped since there's just one viable map")
		return
	elseif #vote_maps<1 then 
		printErrorMessage()
		
		closeClientPanel()
		GamemodeVoteCompleted = false
		MapVote.Cancel()
		return false
	end
	
	
	if MapVote.Config.ReplayMapButton then --adds replay current map button if set to true in config file
		addReplayMapButton()
	end
		
	
	insertRandomButton()
	sendMapsGamemodes()
	
	if MapVote.Config.Statistics then
		sendStatistics()		
	end
end

local function announceMapVote()
	announceDone = true
	net.Start("PSY_mapvote_announceStart")
	net.Broadcast()
end

function MapVote.Start(xlength, xcurrent, xlimit, xprefix, override)
	if LockedTime then
		if CurTime() < LockedTime then 
			timer.Simple(0.1, function()
				GetGlobalEntity( "MapVoteCallingPly" ):PrintMessage( HUD_PRINTTALK, "MapVote cancelled. A recent MapVote has been unsuccessful. You can start a new one in".." "..math.Round(LockedTime-CurTime()).." ".."seconds")
			end)
		return end
	end

	if inprogress then 
		return 
	else
		inprogress = true
	end

	if not announceDone then
		announceMapVote()
	end

	timer.Simple(aTime, function()
		aTime = 0
		if (#player.GetHumans() == 0) then
			changeNow(engine.ActiveGamemode(),game.GetMap())
			print("[MapVote] No Players online. Reloading gamemode and map")
		end

		if file.Exists( "mapvote/recentmaps.txt", "DATA" ) then
			recentmaps = util.JSONToTable(file.Read("mapvote/recentmaps.txt", "DATA"))
		else
			recentmaps = {}
		end
		
		if file.Exists( "mapvote/config.txt", "DATA" ) then
			MapVote.Config = util.JSONToTable(file.Read("mapvote/config.txt", "DATA"))
		else
			MapVote.Config = {}
		end
		if MapVote.Config==nil then 
			notifyPlayers("[MapVote] ERROR. Mapvote Config File contains a typo!") 
			closeClientPanel()
			GamemodeVoteCompleted = false
			MapVote.Cancel() 
			return 
		end

		if ConVarExists( "mapvote_debugmode" ) and GetConVar("mapvote_debugmode"):GetInt() == 1 then
			print("The Mapvote Config is: ")
			PrintTable(MapVote.Config)
		end
		if xlength == 998 then xlength = nil end
		if (xlength ~= nil) then length2 = xlength else length2 = MapVote.Config.GamemodeTimeLimit end
		if (MapVote.Config.MapLimit ~= nil) then limit = MapVote.Config.MapLimit else limit = 24 end
		if (MapVote.Config.MapCooldown ~= nil) then cooldown = MapVote.Config.MapCooldown else cooldown = false end
		if (MapVote.Config.MapPreviews ~= nil) then previews = MapVote.Config.MapPreviews else previews = true end
		if (MapVote.Config.GamemodeDesc ~= nil) then GamemodeDesc = MapVote.Config.GamemodeDesc else GamemodeDesc = true end
		if (MapVote.Config.GamemodeVote ~= nil) then if (MapVote.Config.GamemodeVote == false and OverrideGamemodeSkipConfig ~= true) then GamemodeVoteCompleted = true votedgamemode = engine.ActiveGamemode() OverrideGamemodeSkipConfig = false if length2~=nil then length = length2 else length = MapVote.Config.MapvoteTimeLimit end end end
		if (MapVote.Config.PlayercountDependingGamemodes ~= nil) then 
			if MapVote.Config.PlayercountDependingGamemodes then
				PlayercountDependingGamemodes = util.JSONToTable( file.Read( "mapvote/playercountdependinggamemodes.json", "DATA") ) 
			end
		end
		if override == "gamemode" then
			GamemodeVoteCompleted = false
		elseif override == "map" then
			GamemodeVoteCompleted = true
			length = xlength or MapVote.Config.MapvoteTimeLimit
			votedgamemode = engine.ActiveGamemode()
		end
		sendAddons()
		sendConfig(MapVote.Config)
		sendMapPreviewHierarchy()
		
		InitMapVote()
	end)
end

function InitMapVote()
	
	
	if not GamemodeVoteCompleted then
		if length2~=nil then 
			length = length2
		else 
			length = MapVote.Config.GamemodeTimeLimit 
		end
		local decider = prepareGamemodeVote()
		if decider == false then 
			prepareMapVote() 
		elseif decider == 0 then 
			notifyPlayers("Mapvote cancelled because there are no gamemodes") 
			GamemodeVoteCompleted = false 
			return 
		end
	elseif GamemodeVoteCompleted then
		if prepareMapVote() == false then return end
	end
	

	
	-----------------------------------------------------------
    MapVote.Allow = true
    MapVote.CurrentMaps = vote_maps
    MapVote.Votes = {}
	--Start hook for late joiners
		MapVoteCountdown = length - 1
		if timer.Exists("MapVoteCountdown") then timer.Remove("MapVoteCountdown") end 
		timer.Create( "MapVoteCountdown", 1, MapVoteCountdown, function() --keep track of MapVote Timer
			MapVoteCountdown = MapVoteCountdown - 1
		end)
		
		local load_queue = {}
		hook.Add( "PlayerInitialSpawn", "mapVoteLateJoiners", function( ply )
			load_queue[ ply ] = true
		end )

		hook.Add( "StartCommand", "mapVoteLateJoiners", function( ply, cmd )
			if load_queue[ ply ] and not cmd:IsForced() then
				load_queue[ ply ] = nil
				
				sendAddons(ply)
				sendConfig(MapVote.Config, ply)
				sendMapPreviewHierarchy(ply)
				sendRatingsTable(ply)
				sendGamemodeDescriptions(ply)
				sendGamemodes(ply)
				sendMapsGamemodes(ply)
			end
		end )
	--End hook for late joiners
	
    timer.Create("PSY_MapVote", length, 1, function()
	
        MapVote.Allow = false
        local map_results = {}
        
        for k, v in pairs(MapVote.Votes) do
            if(not map_results[v]) then
                map_results[v] = 0
            end
            
            for k2, v2 in pairs(player.GetHumans()) do
                if(v2:SteamID() == k) then
                    if(MapVote.HasExtraVotePower(v2)) then
                        map_results[v] = map_results[v] + 2
                    else
                        map_results[v] = map_results[v] + 1
                    end
                end
            end
            
        end
		
        if MapVote.Config.MapCooldown then 
			CoolDownDoStuff()
		end
		local function whoWon(xmap_results)
			--"mostVotesWins","leastVotesWins","randomFromAllVoted","weightedByAmountOfVotes"
			local xmode = MapVote.Config.voteWinnerMode
			if table.Count(xmap_results) == 0 then return math.random(1,#vote_maps) end
			if xmode == "mostVotesWins" then
				return table.GetWinningKey(xmap_results)
			elseif xmode == "leastVotesWins" then
				local lowestValue = 1000
				local lowestKey = 0
				for k,v in pairs(xmap_results) do
					if v <= lowestValue then
						lowestValue = v
						lowestKey = k
					end
				end
				return lowestKey
			elseif xmode == "randomFromAllVoted" then
				return table.Random(table.GetKeys(xmap_results))
			elseif xmode == "weightedByAmountOfVotes" then
				local sum = 0
				for k,v in pairs(xmap_results) do
					sum = sum+v
				end
				local chances = {}
				for k,v in pairs(xmap_results) do
					chances[k] = v/sum
				end
				local rand = math.Rand(0, 1)
				local cumulative = 0
				for name, chance in pairs(chances) do
					cumulative = cumulative + chance
					if rand <= cumulative then
						return name
					end
				end
			end
		end
        local winner = whoWon(map_results)
        net.Start("PSY_MapVoteUpdate")
            net.WriteUInt(MapVote.UPDATE_WIN, 3)
            net.WriteUInt(winner, 32)
        net.Broadcast()
        
        local map = MapVote.CurrentMaps[winner]
		if map == "REPLAY MAP AND GM" then
			timer.Simple(4, function()
				hook.Run("MapVoteChange", game.GetMap())
				MapVote.Change(engine.ActiveGamemode(),game.GetMap(),"[MapVote] Changing Gamemode and Map")
			end)
        elseif map == "EXTEND CURRENT MAP" then
			timer.Simple(4, function()
				closeClientPanel()
				GamemodeVoteCompleted = false
				MapVote.Allow = true
				MapVote.Cancel()
				RTV.resetVotes()
						
				if timer.Exists("GamemodeTimeLimitTimer") then MapVote.StartGamemodeTimer() end
				notifyPlayers("Current Gamemode and Map extended")
				if engine.ActiveGamemode() == "terrortown" then
					SetGlobalInt("ttt_rounds_left", GetConVar("ttt_round_limit"):GetInt() )
					SetGlobalInt("ttt_time_limit_minutes", GetConVar("ttt_time_limit_minutes"):GetInt())
					timer.Start("end2prep")
				end
				return
			end)
			
		elseif map == "RANDOM" then
			timer.Simple(4, function()
				if MapVote.Config.ReplayMapButton then
					map=MapVote.CurrentMaps[math.random( 3, #MapVote.CurrentMaps )]
				else 
					map=MapVote.CurrentMaps[math.random( 2, #MapVote.CurrentMaps )]
				end
				
				if GamemodeVoteCompleted then
					hook.Run("MapVoteChange", map)
					MapVote.Change(votedgamemode,map,"[MapVote] Changing Gamemode and Map")
				else
					votedgamemode=map
					GamemodeVoteCompleted=true 
					inprogress = false
					MapVote.Start(nil, nil, nil, nil)
				end
				
			end)
			
		elseif map == "EXTEND CURRENT MAP" then
			timer.Simple(4, function()
				MapVote.Allow = true
				MapVote.Cancel()
			end)
			
        elseif GamemodeVoteCompleted then --changes gamemode and map after mapvote if "RANDOM" and "REPLAY" didn't get chosen
			timer.Simple(4, function()
				hook.Run("MapVoteChange", map)
				MapVote.Change(votedgamemode,map,"[MapVote] Changing Gamemode and Map")
			end)
			
		else 
			timer.Simple(4, function() --end gamemode voting
				GamemodeVoteCompleted=true 
				votedgamemode=map
				inprogress = false
				MapVote.Start() --start voting for map
			end)
		end
		
    end)
	
end

function ConvertGamemodes( fromgamemode , togamemode )

	if istable(fromgamemode) then --checks if a table or a single gamemode is converted
		for k, gm in pairs(engine.GetGamemodes()) do 
			
			if table.HasValue( fromgamemode, gm.name )==true then 
				togamemode[table.KeyFromValue( fromgamemode, gm.name )]=gm.title	
			elseif table.HasValue( fromgamemode, gm.title )==true then 
				togamemode[table.KeyFromValue( fromgamemode, gm.title )]=gm.name
			end
			
		end
	else
	
		for k, gm in pairs(engine.GetGamemodes()) do --converts gamemode vote winner to internal name

			if ( fromgamemode == gm.title ) then 
				return gm.name
			end

		end
	end
	
end

function closeClientPanel()
	net.Start("PSY_MapVoteCancel")
	net.Broadcast()
	SetGlobalBool( "mapvote_comptest", false )
	inprogress = false
end

function MapVote.Cancel()
    if MapVote.Allow then
		LockedTime = CurTime() + MapVote.Config.StartMapvoteCooldown
		votedgamemode = nil
		GamemodeVoteCompleted = false
		inprogress = false
		MapVote.Allow = false
		ratingResults = {}
		closeClientPanel()
		announceDone = false
		aTime = 3.7
		table.Empty(voterCache)
		timer.Stop("MapVoteCountdown")
		--remove hook for late joiners
		hook.Remove("PlayerInitialSpawn", "mapVoteLateJoiners")
		hook.Remove("StartCommand", "mapVoteLateJoiners")
		---------------------------
		timer.Destroy("PSY_MapVote")
	end
end

function MapVote.Change(xgamemode,map,msg) --initiate gamemode/map change
	MapVote.Statistics(xgamemode,map)
	if MapVote.Config.GamemodesAndMapsHaveRatings then
		writeRatingResultsToFile()
	end
	if engine.ActiveGamemode() == "sandbox" then
		SandboxMapChangeCountdown(xgamemode,map)
		return
	end
	
	if msg ~= nil then
		print(msg)
	end
	inprogress = false
	
	changeNow(xgamemode,map)
	
end

function changeNow(xgamemode,xmap)
	if xgamemode ~= nil then
		timer.Simple( 0.2, function() RunConsoleCommand("gamemode",xgamemode) end )
	end
	if xmap ~= nil then
		timer.Simple( 0.2, function() RunConsoleCommand("changelevel",xmap) end )
	end
end

function MapVote.Statistics(xgamemode,map) --if in config.txt set to true will track how often a gamemode/map has been played
	if MapVote.Config.Statistics then
		mapvote_statistics = readStatisticsFile()
		if xgamemode~=nil then
			if mapvote_statistics[xgamemode] ~= nil then 
				mapvote_statistics[xgamemode] = mapvote_statistics[xgamemode] + 1
			else 
				mapvote_statistics[xgamemode] = 1
			end
		end
		if map!=nil then
			if mapvote_statistics[map] != nil then
				mapvote_statistics[map] = mapvote_statistics[map] + 1
			else 
				mapvote_statistics[map] = 1
			end
		end
		file.Write( "mapvote/statistics.json", util.TableToJSON( mapvote_statistics ) )
	end


end

function playCountdownClientSound()	
	net.Start( "PSY_MapVoteCountdownSound" )
		net.WriteBool(true)
	net.Broadcast()
end

function SandboxMapChangeCountdown(gamemode,map)
	local x = MapVote.Config.SandboxCountdown
	closeClientPanel()
	timer.Create( "MapChangeCountdown", 1, x+1, function()
		for i, ply in ipairs( player.GetHumans() ) do
			ply:PrintMessage( HUD_PRINTCENTER, "Map Change in".." "..x.." ".."seconds. Save your stuff before it's too late!" )
		end
		
		if x%10==0 or x<10 then
			playCountdownClientSound()
		end
		
		x = x - 1
		
		if x < 0 then 
			inprogress = false
			MapVote.Statistics(gamemode,map)
			
			if map != nil then
				timer.Simple( 0.2, function() RunConsoleCommand("changelevel",map) end )
			end
			
			if gamemode != nil then
				timer.Simple( 0.2, function() RunConsoleCommand("gamemode",gamemode) end )
			end
		end
	end)
	
	timer.Start("MapChangeCountdown")
end

local function compressTable(xfile)
	local jsonString = util.TableToJSON(xfile)
	local compressedString = util.Compress(jsonString)
	return compressedString
end

local function uncompressString(xString)
	local jsonString = util.Decompress(xString)
	local xTable = util.JSONToTable(jsonString)
	return xTable
end

net.Receive("PSY_MapVoteRatingResults", function()
    rating1 = net.ReadInt(5)
	rating2 = net.ReadInt(5)
	saveRatingResults(rating1,rating2)
end)

function saveRatingResults(xrating1,xrating2)
	local currentGamemode = engine.ActiveGamemode()
	local map = game.GetMap()
	if ((ratingResults == nil) or (table.Count(ratingResults) < 1)) then
		ratingResults = readRatingsFile()
	end
	
	ratingResults[currentGamemode]["rating"] = ratingResults[currentGamemode]["rating"] + xrating1
	ratingResults[currentGamemode]["count"] = ratingResults[currentGamemode]["count"] + 1
	ratingResults[map]["rating"] = ratingResults[map]["rating"] + xrating2
	ratingResults[map]["count"] = ratingResults[map]["count"] + 1
	changed = true
end

function writeRatingResultsToFile()
	if changed then
		file.Write("mapvote/ratingresults.json", util.TableToJSON( ratingResults, true ) )
		ratingResults = {}
		changed = false
	end
end

function sendRatingsTable(target)
	local xTable1 = readRatingsFile()
	local xTable2 = {}
	for k,v in ipairs(vote_maps) do
		local xValue = xTable1[v]
		if xValue != nil then
			xTable2[v] = xTable1[v]
		end
	end
	-- if not table.IsEmpty(xTable2) then
	-- 	local compressedString = compressTable(xTable2)
		
	-- 	if target == nil then
	-- 		net.Start("PSY_MapVoteSendRatingsTable")
	-- 			net.WriteUInt(#compressedString, 32)
	-- 			net.WriteData(compressedString, #compressedString)
	-- 		net.Broadcast()
	-- 	else 
	-- 		net.Start("PSY_MapVoteSendRatingsTable")
	-- 			net.WriteUInt(#compressedString, 32)
	-- 			net.WriteData(compressedString, #compressedString)
	-- 		net.Send(target)
	-- 	end
	-- end
	if not table.IsEmpty(xTable2) then
		if target == nil then
			net.Start("PSY_MapVoteSendRatingsTable")
				net.WriteTable(xTable2)
			net.Broadcast()
		else 
			net.Start("PSY_MapVoteSendRatingsTable")
				net.WriteTable(xTable2)
			net.Send(target)
		end
	end
end

net.Receive("PSY_MapVoteCancel2", function(len, ply)
	if not ply:IsAdmin() then return end
	local readX = net.ReadString()
	if readX!="1" then
		notifyPlayers("MapVote cancelled. Error Message printed to console")
	else
		print("MapVote was successful!")
	end
	closeClientPanel()
	MapVote.Cancel()
end)

util.AddNetworkString("PSY_MapVote_notifyServerWide")
net.Receive("PSY_MapVote_notifyServerWide", function(len, ply)
	local message = net.ReadString()

	for k,v in pairs(player.GetAll()) do
		v:ChatPrint(message)
	end
end)


---------------------------------------------------------------------------MapVote Client Config GUI-------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


util.AddNetworkString("PSY_MapVote_LoadGamemodeNameList")
net.Receive("PSY_MapVote_LoadGamemodeNameList", function(len, ply)
	if not ply:IsAdmin() then return end
	sendGamemodes()
end)

-- installedAddons and installedMaps Tab Preparation
local xtable = engine.GetAddons()
local sharedMaps = {}
local sharedAddons = {}
for k,v in ipairs(xtable) do
	if string.find(v.tags, "map") then 
		table.insert(sharedMaps, v) 
	else
		table.insert(sharedAddons, v) 
	end
end

-- Config Tab
util.AddNetworkString("PSY_MapVote_LoadConfig")
util.AddNetworkString("PSY_MapVote_SendConfig")
util.AddNetworkString("PSY_MapVote_SaveConfig")

net.Receive("PSY_MapVote_LoadConfig", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/config.txt", "DATA") then return end
	local fileContent = util.JSONToTable(file.Read("mapvote/config.txt", "DATA"))
	net.Start("PSY_MapVote_SendConfig")
		net.WriteTable(fileContent)
	net.Send(ply)
end)

net.Receive("PSY_MapVote_SaveConfig", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/config.txt", "DATA") then return end
	local fileContent = net.ReadTable()
	file.Write("mapvote/config.txt", util.TableToJSON(fileContent))
	print("config.txt has been saved on the server by "..tostring(ply))
	ply:ChatPrint("config.txt has been saved on the server")
end)


-- GameModes Tab
util.AddNetworkString("PSY_MapVote_LoadGameModes")
util.AddNetworkString("PSY_MapVote_SendGameModes")

net.Receive("PSY_MapVote_LoadGameModes", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/gamemodes.json", "DATA") then return end
	local fileContent = util.JSONToTable(file.Read("mapvote/gamemodes.json", "DATA"))
	net.Start("PSY_MapVote_SendGameModes")
		net.WriteTable(fileContent)
	net.Send(ply)
end)



util.AddNetworkString("PSY_MapVote_LoadEnabledGameModes")
util.AddNetworkString("PSY_MapVote_SendEnabledGameModes")
util.AddNetworkString("PSY_MapVote_SaveEnabledGameModes")

net.Receive("PSY_MapVote_LoadEnabledGameModes", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/gamemodesenabled.json", "DATA") then return end
	local fileContent = util.JSONToTable(file.Read("mapvote/gamemodesenabled.json", "DATA"))
	net.Start("PSY_MapVote_SendEnabledGameModes")
		net.WriteTable(fileContent)
	net.Send(ply)
end)

net.Receive("PSY_MapVote_SaveEnabledGameModes", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/gamemodesenabled.json", "DATA") then return end
	local fileContent = net.ReadTable()
	file.Write("mapvote/gamemodesenabled.json", util.TableToJSON(fileContent))
	print("gamemodesenabled.json has been saved on the server by "..tostring(ply))
	ply:ChatPrint("gamemodesenabled.json has been saved on the server")
end)


-- PlayerCountDependingGameModes Tab
util.AddNetworkString("PSY_MapVote_LoadPlayerCount")
util.AddNetworkString("PSY_MapVote_SendPlayerCount")
util.AddNetworkString("PSY_MapVote_SavePlayerCount")

net.Receive("PSY_MapVote_LoadPlayerCount", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/playercountdependinggamemodes.json", "DATA") then return end
	local fileContent = util.JSONToTable(file.Read("mapvote/playercountdependinggamemodes.json", "DATA"))
	net.Start("PSY_MapVote_SendPlayerCount")
		net.WriteTable(fileContent)
	net.Send(ply)
end)

net.Receive("PSY_MapVote_SavePlayerCount", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/playercountdependinggamemodes.json", "DATA") then return end
	local fileContent = net.ReadTable()
	file.Write("mapvote/playercountdependinggamemodes.json", util.TableToJSON(fileContent))
	print("playercountdependinggamemodes.json has been saved on the server by "..tostring(ply))
	ply:ChatPrint("playercountdependinggamemodes.json has been saved on the server")
end)


-- GamemodesDesc Tab
util.AddNetworkString("PSY_MapVote_LoadGamemodesDesc")
util.AddNetworkString("PSY_MapVote_SendGamemodesDesc")
util.AddNetworkString("PSY_MapVote_SaveGamemodesDesc")

net.Receive("PSY_MapVote_LoadGamemodesDesc", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/gamemodesdesc.json", "DATA") then return end
    local fileContent = util.JSONToTable(file.Read("mapvote/gamemodesdesc.json", "DATA"))
    net.Start("PSY_MapVote_SendGamemodesDesc")
    	net.WriteTable(fileContent)
    net.Send(ply)
end)


net.Receive("PSY_MapVote_SaveGamemodesDesc", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/gamemodesdesc.json", "DATA") then return end
    local fileContent = net.ReadTable()
    file.Write("mapvote/gamemodesdesc.json", util.TableToJSON(fileContent))
    print("gamemodesdesc.json has been saved on the server by " .. tostring(ply))
	ply:ChatPrint("gamemodesdesc.json has been saved on the server")
end)

-- MapPreviewHierarchy Tab
util.AddNetworkString("PSY_MapVote_LoadMapPreviewHierarchy")
util.AddNetworkString("PSY_MapVote_SendMapPreviewHierarchy")
util.AddNetworkString("PSY_MapVote_SaveMapPreviewHierarchy")

net.Receive("PSY_MapVote_LoadMapPreviewHierarchy", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/mappreviewhierarchy.json", "DATA") then return end
    local fileContent = util.JSONToTable(file.Read("mapvote/mappreviewhierarchy.json", "DATA"))
    net.Start("PSY_MapVote_SendMapPreviewHierarchy")
    	net.WriteTable(fileContent)
    net.Send(ply)
end)


net.Receive("PSY_MapVote_SaveMapPreviewHierarchy", function(len, ply)
	if not ply:IsAdmin() then return end
    local fileContent = net.ReadTable()
    file.Write("mapvote/mappreviewhierarchy.json", util.TableToJSON(fileContent))
    print("mappreviewhierarchy.json has been saved on the server by " .. tostring(ply))
	ply:ChatPrint("mappreviewhierarchy.json has been saved on the server")
end)



-- RatingResults Tab
util.AddNetworkString("PSY_MapVote_LoadRatingResults")
util.AddNetworkString("PSY_MapVote_SendRatingResults")
util.AddNetworkString("PSY_MapVote_SaveRatingResults")


net.Receive("PSY_MapVote_LoadRatingResults", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/ratingresults.json", "DATA") then return end
	local fileContent = util.JSONToTable(file.Read("mapvote/ratingresults.json", "DATA"))
	local xstring = compressTable(fileContent)
	
	net.Start("PSY_MapVote_SendRatingResults")
		net.WriteUInt(#xstring, 32)
		net.WriteData(xstring, #xstring)
	net.Send(ply)

end)

net.Receive("PSY_MapVote_SaveRatingResults", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/ratingresults.json", "DATA") then return end
	local compressedLength = net.ReadUInt(32)
	local compressedString = net.ReadData(compressedLength)
	local fileContent = uncompressString(compressedString)
	
	file.Write("mapvote/ratingresults.json", util.TableToJSON(fileContent))
	print("ratingresults.json has been saved on the server by "..tostring(ply))
	ply:ChatPrint("ratingresults.json has been saved on the server")
end)


-- Statistics Tab
util.AddNetworkString("PSY_MapVote_LoadStatistics")
util.AddNetworkString("PSY_MapVote_SendStatistics")
util.AddNetworkString("PSY_MapVote_SaveStatistics")

net.Receive("PSY_MapVote_LoadStatistics", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/statistics.json", "DATA") then return end
	local xTable = readStatisticsFile()
	local fileContent = compressTable( xTable )
	
	net.Start("PSY_MapVote_SendStatistics")
		net.WriteUInt(#fileContent, 32)
		net.WriteData(fileContent, #fileContent)
	net.Send(ply)
end)

net.Receive("PSY_MapVote_SaveStatistics", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/statistics.json", "DATA") then return end
	local compressedLength = net.ReadUInt(32)
	local compressedString = net.ReadData(compressedLength) 
	local fileContent = uncompressString(compressedString)
	file.Write( "mapvote/statistics.json", util.TableToJSON(fileContent) )
	print("statistics.json has been saved on the server by "..tostring(ply))
	ply:ChatPrint("statistics.json has been saved on the server")
end)


-- RecentMaps Tab
util.AddNetworkString("PSY_MapVote_LoadRecentMaps")
util.AddNetworkString("PSY_MapVote_SendRecentMaps")
util.AddNetworkString("PSY_MapVote_SaveRecentMaps")

net.Receive("PSY_MapVote_LoadRecentMaps", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/recentmaps.txt", "DATA") then return end
	local fileContent = util.JSONToTable(file.Read("mapvote/recentmaps.txt", "DATA"))
	if fileContent!=nil then
		net.Start("PSY_MapVote_SendRecentMaps")
			net.WriteTable(fileContent)
		net.Send(ply)
	end
end)

net.Receive("PSY_MapVote_SaveRecentMaps", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/recentmaps.txt", "DATA") then return end
	local fileContent = net.ReadTable()
	file.Write("mapvote/recentmaps.txt", util.TableToJSON(fileContent))
	print("recentmaps.txt has been saved on the server by "..tostring(ply))
	ply:ChatPrint("recentmaps.txt has been saved on the server")
end)

-- CSSMaps Tab
util.AddNetworkString("PSY_MapVote_LoadCSSMaps")
util.AddNetworkString("PSY_MapVote_SendCSSMaps")
util.AddNetworkString("PSY_MapVote_SaveCSSMaps")

net.Receive("PSY_MapVote_LoadCSSMaps", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/cssmaps.json", "DATA") then return end
	local fileContent = util.JSONToTable(file.Read("mapvote/cssmaps.json", "DATA"))
	if fileContent!=nil then
		net.Start("PSY_MapVote_SendCSSMaps")
			net.WriteTable(fileContent)
		net.Send(ply)
	end
end)

net.Receive("PSY_MapVote_SaveCSSMaps", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/cssmaps.json", "DATA") then return end
	local fileContent = net.ReadTable()
	file.Write("mapvote/cssmaps.json", util.TableToJSON(fileContent))
	print("cssmaps.json has been saved on the server by "..tostring(ply))
	ply:ChatPrint("cssmaps.json has been saved on the server")
end)

-- Useful Addons Tab
util.AddNetworkString("PSY_MapVote_LoadUsefulAddons")
util.AddNetworkString("PSY_MapVote_OfferUsefulAddons")
net.Receive("PSY_MapVote_LoadUsefulAddons", function(len, ply)
	if not ply:IsAdmin() then return end
	local xtable = {
		{["wsid"] = "2428251124", ["desc"] = "Map Vote - This addon doesn't just provide a Mapvoting System with lots of configuration options but also allows for voting for a Gamemode. It's the best addon for setting up multi-gamemode servers and is being developed actively"},
		{["wsid"] = "2965162101", ["desc"] = "Workshop Download Manager - This addon let's you setup gamemode-specific Workshop Downloads which means players will only download addons that are needed for the active gamemode. This cuts loading times to a fraction, especially on servers with lots of gamemodes"},
		{["wsid"] = "2991367425", ["desc"] = "Super Map Icon Maker - There's lots of maps that don't have a preview image and appear gray or with a default image during Map Votes. This addon let's you make your own map previews and upload them to your server. Additionally you can setup automatic synchronization between server and clients so that the server sends the previews to all players. No need for Map Icon Packs!"},
		{["wsid"] = "3143803678", ["desc"] = "Custom Commands Menu - This menu combines all other menus and grants you easy and quick access to commands and GUIs. You can manually bind commands to its buttons so you'll never have to memorize all the different Gmod commands anymore"},
		{["wsid"] = "3146490878", ["desc"] = "Random Server Starting Map - This addon let's your server start with a random map with a prefix (e.g. ttt_) of your choice! That way you won't get bored starting on the same exact map every time"},
		{["wsid"] = "3137165771", ["desc"] = "Auto Execute Commands Depending On Gamemode - This is already included in this Map Vote addon. It's a separate addon if you want its functionality without this Map Vote System"},
		{["wsid"] = "3222734936", ["desc"] = "Traitor Quickchat - The part of the game where communication grants the traitors a huge advantage over the innocent often comes up short especially when chatting on Discord. A tactical game turns into a deathmatch.To solve this issue and revive tactical gameplay this addon adds a Traitor-Only Quickchat with lots of useful commands. You can ping enemies, ask traitor buddys for help, give general commands and even start a timer for a powerful collective attack!"}
		
	}
	net.Start("PSY_MapVote_OfferUsefulAddons")
		net.WriteTable(xtable)
	net.Send(ply)
end)

-- Installed Addons Tab
util.AddNetworkString("PSY_MapVote_LoadInstalledAddons")
util.AddNetworkString("PSY_MapVote_OfferInstalledAddons")
net.Receive("PSY_MapVote_LoadInstalledAddons", function(len, ply)
	if not ply:IsAdmin() then return end

	table.sort( sharedAddons, function(a, b) return a.title < b.title end )
	local xsharedAddons = compressTable(sharedAddons)
	net.Start("PSY_MapVote_OfferInstalledAddons")
		net.WriteUInt(#xsharedAddons, 32)
		net.WriteData(xsharedAddons, #xsharedAddons)
	net.Send(ply)
end)

-- Installed Maps Tab
util.AddNetworkString("PSY_MapVote_LoadInstalledMaps")
util.AddNetworkString("PSY_MapVote_OfferInstalledMaps")
util.AddNetworkString("PSY_MapVote_LoadMapFromGUI")
net.Receive("PSY_MapVote_LoadInstalledMaps", function(len, ply)
	if not ply:IsAdmin() then return end

	table.sort( sharedMaps, function(a, b) return a.title < b.title end )

	local xsharedMaps = compressTable(sharedMaps)
	net.Start("PSY_MapVote_OfferInstalledMaps")
		net.WriteUInt(#xsharedMaps, 32)
		net.WriteData(xsharedMaps, #xsharedMaps) 
	net.Send(ply)
end)

-- ConCommands Tab
util.AddNetworkString("PSY_MapVote_LoadConCommands")
util.AddNetworkString("PSY_MapVote_OfferConCommands")
util.AddNetworkString("PSY_MapVote_ExecuteConCommands")

-- Cleanup Tab
util.AddNetworkString("PSY_MapVote_LoadCleanupData")
util.AddNetworkString("PSY_MapVote_SendCleanupData")
util.AddNetworkString("PSY_MapVote_CleanupData")

net.Receive("PSY_MapVote_LoadCleanupData", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/ratingresults.json", "DATA")  or not file.Exists("mapvote/statistics.json", "DATA") then return end

	local installedMaps = file.Find("maps/*.bsp", "GAME")
	for k,v in ipairs(installedMaps) do
		installedMaps[k] = string.gsub(v, "%.bsp$", "")
	end

	local installedGamemodes = engine.GetGamemodes()
	for k,v in ipairs(installedGamemodes) do
		installedGamemodes[k] = v.name
	end

	local path1 = "mapvote/ratingresults.json"
	local path2 = "mapvote/statistics.json"

	local file1 = util.JSONToTable(file.Read(path1, "DATA"))
	local file2 = util.JSONToTable(file.Read(path2, "DATA"))
	local uninstalledMapsAndGamemodes = {}

	for k,v in pairs(file1) do
		if not table.HasValue(installedMaps, k) and not table.HasValue(installedGamemodes, k) then
			table.insert(uninstalledMapsAndGamemodes, {["thing"] = k, ["path"] = path1})
		end
	end

	for k,v in pairs(file2) do
		if not table.HasValue(installedGamemodes, k) and not table.HasValue(installedMaps, k) then
			table.insert(uninstalledMapsAndGamemodes, {["thing"] = k, ["path"] = path2})
		end
	end
	
	local xuninstalledMapsAndGamemodes = compressTable(uninstalledMapsAndGamemodes)
	net.Start("PSY_MapVote_SendCleanupData")
		net.WriteUInt(#xuninstalledMapsAndGamemodes, 32)
		net.WriteData(xuninstalledMapsAndGamemodes, #xuninstalledMapsAndGamemodes) 
	net.Send(ply)

	net.Receive("PSY_MapVote_CleanupData", function(len, ply)
		if not ply:IsAdmin() then return end
		if table.IsEmpty(uninstalledMapsAndGamemodes) then return end
		local changed = false
		local counter = 0
		for k,v in ipairs(uninstalledMapsAndGamemodes) do
			if v.path == path1 then
				file1[v.thing] = nil
				changed = true
				counter = counter + 1
			elseif v.path == path2 then
				file2[v.thing] = nil
				changed = true
				counter = counter + 1
			end
		end
		if changed then
			file.Write( path1, util.TableToJSON(file1) )
			file.Write( path2, util.TableToJSON(file2) )
			ply:ChatPrint("Successfully deleted "..counter.." Data Sets")
		end
	end)

end)

util.AddNetworkString("PSY_MapVote_OpenCSGUI")
hook.Add( "PlayerSay", "openMapVoteGUI", function( ply, text )
	if ( string.find( string.lower(text),"!mvmenu" )  ) then
		if ply:IsAdmin() then 
			print("Player "..ply:Nick().." opened the MapVote GUI")
			net.Start("PSY_MapVote_OpenCSGUI")
			net.Send(ply)
			return
		end
	end
end )



------------------------------------------Assign Prefixes and Maps to Gamemodes Panel---------------------------------------

local mapForPrefix = {}

local function getULXMapBlacklist()
	local xtable = ( file.Exists( "ulx/votemaps.txt", "DATA" ) and file.Read( "ulx/votemaps.txt", "DATA" ) ) or ""
	local blackListTable = string.Explode("\n", xtable )
	
	if blackListTable then
		for i = #blackListTable, 1, -1 do
			if blackListTable[i] and ( blackListTable[i] == "" or string.StartsWith(blackListTable[i], ";") ) then
				table.remove(blackListTable, i)
			end
		end

		return blackListTable
	end

	return nil
end

util.AddNetworkString("PSY_MapVote_requestAllMapsForAssignMaps")
util.AddNetworkString("PSY_MapVote_offerAllMapsForAssignMaps")
net.Receive("PSY_MapVote_requestAllMapsForAssignMaps", function(len, ply)
	if not ply:IsAdmin() then return end
	local allMaps = file.Find("maps/*.bsp", "GAME")
	local compressedTable = compressTable(allMaps)
	local blackList = getULXMapBlacklist()

	net.Start("PSY_MapVote_offerAllMapsForAssignMaps")
		net.WriteUInt(#compressedTable, 32)
		net.WriteData(compressedTable, #compressedTable)
		net.WriteTable(blackList)
	net.Send(ply)

end)



util.AddNetworkString("PSY_MapVote_requestGamemodesForAssignMaps")
util.AddNetworkString("PSY_MapVote_offerGamemodesForAssignMaps")
net.Receive("PSY_MapVote_requestGamemodesForAssignMaps", function(len, ply)
	if not ply:IsAdmin() then return end

	local installedGamemodes = engine.GetGamemodes()
	net.Start("PSY_MapVote_offerGamemodesForAssignMaps")
		net.WriteTable(installedGamemodes)
	net.Send(ply)

end)


util.AddNetworkString("PSY_MapVote_requestGamemodesForAssignMaps_fileContent")
util.AddNetworkString("PSY_MapVote_offerGamemodesForAssignMaps_fileContent")
local function findMapsForPrefix(mapPrefix)
	local xtable = file.Find("maps/"..mapPrefix.."*.bsp", "GAME")
	return xtable
end

net.Receive("PSY_MapVote_requestGamemodesForAssignMaps_fileContent", function(len, ply)
	if not ply:IsAdmin() then return end
	local tabName = net.ReadString()
	local blackList = getULXMapBlacklist()
	if tabName == "ULX Blacklist" then
		if not table.IsEmpty(blackList) then
			net.Start("PSY_MapVote_offerGamemodesForAssignMaps_fileContent")
				net.WriteString(tabName)
				net.WriteTable(blackList)
			net.Send(ply)
		end
	else
		local mapCount = {}
		local xfile = file.Exists("mapvote/gamemodes.json", "DATA") and file.Read("mapvote/gamemodes.json", "DATA")
		local fileContent = util.JSONToTable(xfile) or {}

		for k,v in pairs(fileContent[tabName]) do
			if v == "nil" or v == "" then continue end
			local maps = findMapsForPrefix(v)
			mapCount[v] = #maps or 0
			if mapForPrefix[v] == nil then 
				for k,v in ipairs(maps) do
					maps[k] = v:sub(1,-5)
				end
				mapForPrefix[v] = maps
			end
		end

		if fileContent[tabName] then
			net.Start("PSY_MapVote_offerGamemodesForAssignMaps_fileContent")
				net.WriteString(tabName)
				net.WriteTable(fileContent[tabName])
				net.WriteTable(mapCount)
				net.WriteTable(blackList)
			net.Send(ply)
		end
	end

end)

util.AddNetworkString("PSY_MapVote_assignMapsToGamemode")
net.Receive("PSY_MapVote_assignMapsToGamemode", function(len, ply)
	if not ply:IsAdmin() or not file.Exists("mapvote/gamemodes.json", "DATA") then return end

	local gamemodeName = net.ReadString()
	local compressedLength = net.ReadUInt(32)
	local compressedString = net.ReadData(compressedLength)
	local fileContent = uncompressString(compressedString)
	
	local changed = false
	local counter = 0
	local xtable = {}

	if gamemodeName != "ULX Blacklist" then 
		if not file.Exists("mapvote/gamemodes.json", "DATA") then return end
		xtable = util.JSONToTable(file.Read("mapvote/gamemodes.json", "DATA"))
	else
		xtable[gamemodeName] = getULXMapBlacklist()
	end

	for k,v in ipairs(fileContent) do
		if not table.HasValue(xtable[gamemodeName], v) then
			table.insert(xtable[gamemodeName], v)
			counter = counter + 1
			changed = true
		end
		if table.Count(xtable[gamemodeName]) > 1 and table.HasValue(xtable[gamemodeName], "nil") or table.HasValue(xtable[gamemodeName], "") then 
			table.RemoveByValue(xtable[gamemodeName], "nil")
			table.RemoveByValue(xtable[gamemodeName], "")
		end
		
	end

	if changed then
		local path = ""
		if gamemodeName == "ULX Blacklist" then
			path = "ulx/votemaps.txt"
			file.Write(path, table.concat(xtable[gamemodeName], "\n"))
		else
			path = "mapvote/gamemodes.json"
			file.Write(path, util.TableToJSON(xtable))
		end
		ply:ChatPrint("Successfully assigned "..counter.." Maps to "..gamemodeName)
	end
end)

util.AddNetworkString("PSY_MapVote_unassignMapsFromGamemode")
net.Receive("PSY_MapVote_unassignMapsFromGamemode", function(len, ply)
	if not ply:IsAdmin() then return end
	
	local gamemodeName = net.ReadString()
	local compressedLength = net.ReadUInt(32)
	local compressedString = net.ReadData(compressedLength)
	local fileContent = uncompressString(compressedString)
	local xtable = {}

	if gamemodeName != "ULX Blacklist" then 
		if not file.Exists("mapvote/gamemodes.json", "DATA") then return end
		xtable = util.JSONToTable(file.Read("mapvote/gamemodes.json", "DATA"))
	else
		xtable[gamemodeName] = string.Explode( "\n", file.Read("ulx/votemaps.txt", "DATA") )
	end

	local changed = false
	local counter = 0
	

	for k,v in ipairs(fileContent) do
		if table.HasValue(xtable[gamemodeName], v) then
			table.RemoveByValue(xtable[gamemodeName], v)
			counter = counter + 1
			changed = true
		end
	end

	if changed then
		local path = ""
		if gamemodeName == "ULX Blacklist" then
			path = "ulx/votemaps.txt"
			file.Write(path, table.concat(xtable[gamemodeName], "\n"))
		else
			path = "mapvote/gamemodes.json"
			file.Write(path, util.TableToJSON(xtable))
		end
		ply:ChatPrint("Successfully unassigned "..counter.." Maps from "..gamemodeName)
	end

end)

util.AddNetworkString("PSY_MapVote_addMapFromText")
net.Receive("PSY_MapVote_addMapFromText", function(len, ply)
	if not ply:IsAdmin() then return end
	local gamemodeName = net.ReadString()
	local mapTable = net.ReadTable()
	local changed = false
	local counter = 0

	local xfile = util.JSONToTable(file.Read("mapvote/gamemodes.json", "DATA"))

	for k,v in ipairs(mapTable) do
		if xfile[gamemodeName] and not table.HasValue(xfile[gamemodeName], v) then
			table.insert(xfile[gamemodeName], v)
			changed = true
			counter = counter + 1
		end
	end
	
	if changed then
		file.Write("mapvote/gamemodes.json", util.TableToJSON(xfile))
		ply:ChatPrint("Successfully assigned "..counter.." prefixes/maps to "..gamemodeName)
	end

end)

util.AddNetworkString("PSY_MapVote_requestMatchingMapsForPrefix")
util.AddNetworkString("PSY_MapVote_offerMatchingMapsForPrefix")
net.Receive("PSY_MapVote_requestMatchingMapsForPrefix", function(len, ply)
	if not ply:IsAdmin() then return end
	local mapPrefix = net.ReadString()
	local tabName = net.ReadString()
	local xtable = {}

	if mapForPrefix[mapPrefix] then
		xtable = mapForPrefix[mapPrefix]
	else
		xtable = findMapsForPrefix(mapPrefix)
	end
	local xblacklist = getULXMapBlacklist()
	

	net.Start("PSY_MapVote_offerMatchingMapsForPrefix")
		net.WriteString(tabName)
		net.WriteTable(xtable)
		net.WriteTable(xblacklist)
	net.Send(ply)

end)