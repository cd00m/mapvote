MapVote = {}
MapVote.Config = {}
local conCommands = {}

--Default Config
local MapVoteConfigDefault = {
	AdminsHaveMoreVotePower = false,
	MapCooldown = false,
	GamemodeDesc = true,
	GamemodeTimeLimit = 15,
	GamemodeVote = true,
    MapLimit = 24,
	MapPreviews = true,
	MapsBeforeRevote = 3,
	ReplayMapButton = true,
	RTVPlayerPercent = 60,
    SortMapsBy = "name",
	Statistics = false,
    MapvoteTimeLimit = 28,
	PlayercountDependingGamemodes = false,
	GamemodesAndMapsHaveRatings = true,
	DisplayGamemodeIcons = true,
	SandboxCountdown = 60,
	StartMapvoteCooldown = 10,
	FilterCSSMaps = false,
	RTVCooldownAfterMapChange = 60,
	ColorUnplayedMapsGray = true,
	PlayersCanPingDuringVote = true,
	CooldownBetweenRTVs = 10,
	advertisementText = "",
	RTVMinimumPlayersRequired = 3,
	voteWinnerMode = "mostVotesWins",
	MapSelectionMode = "random"
    }


local gamemodesdefault = {
["sandbox"] = {"nil"},
["fretta"] = {"nil"},
["base"] = {"nil"},
["fretta13"] = {"nil"},
["terrortown"] = {"ttt_"}
}

local MapVoteGamemodesDesc = {
["prop_hunt"] = "Players: 2+\nRecommended Players: 8\nWhile the first team disguises as props the hunters have to find and kill them",
["flood"] = "Build a raft, survive and destroy the enemy's raft",
["bugboys"] = "Players: 4 - 20\nRecommended Players: >6\nA fun gamemode about defending and attacking, building fortresses and blasting off your enemy with bug-like aliens",
["sourceforts"] = "Players: 4 - 20\nRecommended Players: 10\nA game about building with blocks to defend your own base while attacking the enemy",
["garryware13"] = "Players: 2 - 20\nRecommended Players: >3\nA Mario Party-like gamemode with over 50 minigames",
["g-surf"] = "Players: 1+\nClassic surf game where you have to slide along obstacles and reach the finish line",
["youtoucheditlast"] = "Players: 2 - 20\nRecommended Players: 8\nAlso known as Ball Tag or Hot Potato. Try to hit your enemy with a ball! Contains several gametypes players can choose from",
["datarequired"] = "Players: 2 - 8\nRecommended Players: 5\nA Top-Down Deathmatch inside a maze with guns",
["melonbomber"] = "Players: 2 - 8\nRecommended Players: 6\nThe classic Bomberman but with melons!",
["slashers"] = "Players: 2+\nRecommended Players: 5\nJust like in every horror movie there's very naive survivors who are trying to escape a very powerful psychopathic murderer",
["groundcontrol"] = "Players: 2 - 20\nRecommended Players: 10\nA realistic close combat shooter where communication with your team mates is key",
["amongus"] = "Players: 2+\nRecommended Players: 6\nEveryone knows Among Us",
["assassins"] = "Players: 2 - 12\nRecommended Players: 5\nDisguise as a NPC while trying to find and assassinate your target",
["murder"] = "Players: 2+\nRecommended Players: 6\nThere's a killer around. Get yourself a gun and try to kill him before he stabs you",
["base"] = "nil",
["thehunt"] = "Players: 1 - 4\nRecommended Players: 3\nYou're facing troops of enemy combine soldiers and have to survive. Work together and try being stealthy!",
["nzombies"] = "Players: 1 - 8\nRecommended Players: 4\nA Zombie survival gamemode",
["supermarioboxes"] = "Players: 2 - 10\nRecommended Players: 6\nA Mario-themed 2D gamemode with various game types",
["hardcoreracing"] = "Car Racing, YEAHHH!",
["fretta"] = "nil",
["lastbattleroyale"] = "Players: 2 - 40\nRecommended Players: 15\nA Battle Royale Gamemode on massive maps with lots of vehicles and guns",
["sandbox"] = "The only limit is your imagination",
["homicide"] = "Players: 4 - 20\nRecommended Players: 8\nA more realistic murder game with lots of weapons",
["extremefootballthrowdown"] = "Players: 4+\nRecommended Players: 8\nAmerican Football but with extreme weapons and stuff to throw around!",
["q3ffa"] = "Players: 2+\nQuake 3 Free for all",
["sts"] = "Players: 2 - 4\nRecommended Players: 4\nA strategy game where you're the commander of an army that you put together and upgrade yourself. Fight against your opponent's army to win!",
["deathrun2d"] = "Players: 2+\nRecommended Players: 8\nDeathrun but in 2D",
["zombiesurvival"] = "Players: 2+\nRecommended Players: 8\nEither play as a zombie or as a human. Try to survive or infect all humans",
["oitc"] = "Players: 2+\nRecommended Players: 4\nA jump n run racing gamemode where players compete against each other",
["razborka"] = "Players: 2+\nSeriously, I don't know!",
["dart"] = "Players: 2+\nRecommended Players: 6\nA simple PvP tank game",
["cod_gungame"] = "Players: 2+\nThe classic arms race from CSGO and CoD with CoD-like effects",
["stopitslender"] = "Players: 2 - 7\nRecommended Players: 4\nThe classic slender game, but this time a player can play as slender!",
["q3tdm"] = "Players: 2+\nQuake 3 Team Deathmatch",
["deathrun"] = "Players: 2+\nRecommended Players: 8\nTry to get through a parcour while a player is using traps to get you killed",
["trashcompactor"] = "Players: 2+\nRecommended Players: 8\nA fun gamemode known from Halo 3 and GTA V where a trashman throws down props to kill the remaining players",
["ragdoll_combat"] = "Players: 1+\nSmash your opponent's head in this ridiculous boxing gamemode!",
["prophunters"] = "Players: 2+\nRecommended Players: 8\nWhile the first team disguises as props the hunters have to find and kill them. Allows for locking your prop rotation",
["screenhack"] = "Players: 2 - 6\nRecommended Players: 4\nEveryone is invisible, but you can see other player's screens and estimate where they are",
["dogfightarcade"] = "Players: 2 - 20\nRecommended Players: 8\nImagine a Dogfight with planes made out of random props",
["planes_deathmatch"] = "Fly your plane through the air, shoot your enemies and destroy the enemy base",
["breach"] = "Escape from the facility or kill all humans",
["fnafgm"] = "Players: 1 - 4\nRecommended Players: 2\nThe classic Five Nights at Freddy's with multiplayer support. Always wanted to scare the s#1t out of your friends? Well, now you can!",
["virus_survival_remake"] = "Players: 2 - 30\nRecommended Players: 8\nA PvP gamemode about zombies infecting human beings. Known from Tower Unite",
["jazztronauts"] = "Players: 2+\nRecommended Players: 5\nA very well made and fun gamemode about invading random workshop maps, stealing maps and basically destroying everything",
["bedwars"] = "Players: 2+\nRecommended Players: 8\nThe popular Bedwars Minigame from Minecraft. Build your way to surrounding islands and destroy the enemy's bed",
["slayer"] = "Players: 2+\nRecommended Players: 10\nA Gmod remake of Halo",
["stopitslenderprxe"] = "The classic slender game. But this time a player can play the slender! - extended immersion",
["tfil"] = "Players: 2+\nRecommended Players: 6\nBeware! The floor is lava! And it's gonna rise each minute. A fun gamemode with special abilities",
["terrortown"] = "Players: 3+\nRecommended Players: 10\nEveryone's a terrorist, but there are traitors around. Try to identify and eliminate them before they get you",
["guesswho"] = "Players: 2 - 14\nRecommended Players: 7\nThe first team disguises as NPCs while the other team tries to identify and eliminate them",
["thehidden"] = "Players: 2+\nRecommended Players: 4\nThere's a strong, nearly invisible and fast manlike monster hungry for blood, facing a group of highly specialized soldiers with a ton of advanced equipment",
["horror"] = "Players: 1 - 4\nRecommended Players: 2\nHorror Story Maps",
["fretta13"] = "nil",
["pswremix"] = "Players: 2+\nRecommended Players: 10\nSimilar to Sea of Thieves and Blackwake where two teams on pirate ships try to sink the enemy ship",
["overwatch"] = "Players: 2+\nRecommended Players: 8\nA team of special forces tries to fight its way out of a facility controlled by the 'Overwatch' who controls traps and NPCs",
["q3instagib"] = "Players: 2+\nQuake 3 Instagib",
["hideandseek"] = "Players: 2 - 20\nRecommended Players: 6\nThe classic hide and seek game where the first team tries to hide while the second team has to find and catch them",
["smash"] = "You're standing on platforms which break one after the other. Can you stay on them long enough to win?",
["gungame"] = "Players: 2+\nThe classic arms race from CSGO and CoD",
["ai"] = "Players: 2+\nRecommended Players: 6\nThe popular Alien Isolation horror game in gmod!",
["melonracer"] = "Players: 2 - 12\nRecommended Players: 5\nA racing gamemode with Melons"
}

local CSSMaps = {
	"cs_assault",
	"cs_compound",
	"cs_havana",
	"cs_italy",
	"cs_meridian",
	"cs_militia",
	"cs_office",
	"cs_office_unlimited_oc",
	"de_aztec",
	"de_cbble",
	"de_chateau",
	"de_dust",
	"de_dust2",
	"de_inferno",
	"de_nuke",
	"de_piranesi",
	"de_port",
	"de_prodigy",
	"de_tides",
	"de_train",
	"ttt_67thway_v15",
	"ttt_airbus_b3",
	"ttt_community_bowling_v5a",
	"ttt_dolls",
	"ttt_fastfood_a6",
	"ttt_forest_final",
	"ttt_hedgemaze",
	"ttt_kakariko_v4a",
	"ttt_mall",
	"ttt_mcdonalds_chmilk",
	"ttt_metropolis",
	"ttt_nostalgiahouse_halloween",
	"ttt_ouhhh",
	"ttt_rooftops_2016_v1",
	"ttt_silence_v3",
	"ttt_skyscraper",
	"ttt_worlds",
	"ttt_mw2_terminal",
	"vsh_tinyrock"
}

local mapPreviewHierarchy = {
	{["directory"] = "maps/thumb/",["path"] = "GAME"},
	{["directory"] = "maps/",["path"] = "GAME"},
	{["directory"] = "mapicon/",["path"] = "DATA"},
	{["directory"] = "maps/thumbs/",["path"] = "DATA"}
}

local function fixGamemodeJsonChanges()
	if not file.Exists("mapvote/gamemodes.json", "DATA") then return end

	local xfile = util.JSONToTable(file.Read("mapvote/gamemodes.json", "DATA"))
	local changed = false
	for k,v in pairs(xfile) do
		if type(v) == "string" then
			local xstring = string.Explode(",", v)
			xfile[k] = {}
			xfile[k] = xstring
			changed = true

			for x, y in ipairs(xfile[k]) do
				local xstring2 = string.gsub(y, "^%s+", "")
				local xstring3 = string.gsub(xstring2, "%s+$", "")
				xfile[k][x] = xstring3
			end
		end
	end
	if changed then
		file.Write("mapvote/gamemodes.json", util.TableToJSON(xfile))
	end

end

local function createConfigDir()
	if not file.Exists( "mapvote", "DATA" ) then
		file.CreateDir("mapvote")
    end
end


local function createPlayercountDependingGamemodes()
	local PlayercountDependingGamemodes = {}
	for k, v in pairs ( engine.GetGamemodes() ) do
	
		PlayercountDependingGamemodes[v.name] = {
		["min"] = 1,
		["max"] = 999
		}
		
	end
	
	if not file.Exists( "mapvote/playercountdependinggamemodes.json", "DATA" ) then
		file.Write("mapvote/playercountdependinggamemodes.json", util.TableToJSON( PlayercountDependingGamemodes ) )
    end
	
end

local function createRatingResults()
	local xfile = {}
	if file.Exists( "mapvote/ratingresults.json", "DATA" ) then 
		xfile = util.JSONToTable(file.Read("mapvote/ratingresults.json", "DATA")) or {}
	end
	
	if (not file.Exists( "mapvote/ratingresults.json", "DATA" )) or table.IsEmpty(xfile) then
		local ratingResultsTable = {}
		
		for k, v in pairs( engine.GetGamemodes() ) do
			ratingResultsTable[v.name] = {
			["rating"] = 0, --math.random( 1, 10 )
			["count"] = 0
			}
		end
		
		local allmaps=file.Find("maps/*.bsp", "GAME") --makes a table containing all maps and gamemodes to create a file once

		for k,v in pairs (allmaps) do
			ratingResultsTable[string.TrimRight( v, ".bsp" )] = {
			["rating"] = 0,
			["count"] = 0
			}
		end
		
		file.Write("mapvote/ratingresults.json", util.TableToJSON( ratingResultsTable ) )
    end
end

local function createCSSMaps()
	if not file.Exists( "mapvote/cssmaps.json", "DATA" ) then
		file.Write("mapvote/cssmaps.json", util.TableToJSON( CSSMaps ) )
	end
	local xCSSMaps = util.JSONToTable(file.Read("mapvote/cssmaps.json", "DATA"))
	local changed = false
	
	for k, v in pairs( CSSMaps ) do
		if not table.HasValue(xCSSMaps,v) then 
			xCSSMaps[table.Count(xCSSMaps) + 1] = v 
			changed = true
		end
	end
	if changed then
		file.Write("mapvote/cssmaps.json", util.TableToJSON( xCSSMaps ) )
	end
end

local function createMapPreviewHierarchy()
	if not file.Exists( "mapvote/mappreviewhierarchy.json", "DATA" ) then
		file.Write("mapvote/mappreviewhierarchy.json", util.TableToJSON( mapPreviewHierarchy ) )
    end
end

local function fixRatingResults()
	local xratingResults = util.JSONToTable(file.Read("mapvote/ratingresults.json", "DATA"))
	local changed = false
	
	for k, v in pairs( engine.GetGamemodes() ) do
		if xratingResults[v.name] == nil then 
			xratingResults[v.name] = {
			["rating"] = 0,
			["count"] = 0
			}
			changed = true
		end
	end
	local allmaps=file.Find("maps/*.bsp", "GAME")

	for k,v in pairs (allmaps) do
		if xratingResults[string.TrimRight( v, ".bsp" )] == nil then
			xratingResults[string.TrimRight( v, ".bsp" )] = {
			["rating"] = 0,
			["count"] = 0
			}
			changed = true
		end
	end
	
	if changed then
		file.Write("mapvote/ratingresults.json", util.TableToJSON( xratingResults ) )
	end
	
end

local function fixPlayercountDependingGamemodes()
	local PlayercountDependingGamemodes = util.JSONToTable(file.Read("mapvote/playercountdependinggamemodes.json", "DATA"))
	local changed = false
	for k, v in pairs ( engine.GetGamemodes() ) do
	
		if PlayercountDependingGamemodes[v.name] == nil then
			PlayercountDependingGamemodes[v.name] = {
			["min"] = 1,
			["max"] = 999
			}
			changed = true
		end
		
	end
	if changed then
		file.Write("mapvote/playercountdependinggamemodes.json", util.TableToJSON( PlayercountDependingGamemodes ) )
	end
end

local function fixConfig()
	if not file.Exists( "mapvote/config.txt", "DATA" ) then
		file.Write( "mapvote/config.txt", util.TableToJSON( MapVoteConfigDefault ) )
    else
		MapVote.Config = util.JSONToTable(file.Read("mapvote/config.txt", "DATA")) --checks if config.txt has all config options to override 
		if MapVote.Config == nil then MapVote.Config = {} end
		local changed = false													   --old config file if necessary
		for k, v in pairs( MapVoteConfigDefault ) do
			if MapVote.Config[k] == nil then
				MapVote.Config[k] = MapVoteConfigDefault[k]
				changed = true
			end
		end
		for k, v in pairs( MapVote.Config ) do
			if MapVoteConfigDefault[k] == nil then
				MapVote.Config[k] = nil
				changed = true
			end
		end
		
		if changed == true then
			file.Write( "mapvote/config.txt", util.TableToJSON ( MapVote.Config ) )
			print("[MapVote] config.txt was possibly broken and has been repaired")
		end
	end
	
end

local function fixGamemodeDesc()

	if not file.Exists( "mapvote/gamemodesdesc.json", "DATA" ) then
        file.Write( "mapvote/gamemodesdesc.json", util.TableToJSON( MapVoteGamemodesDesc ) )
    else 																						--add missing gamemodes to gamemodesdesc file
		local changed = false
		local gmtable = util.JSONToTable(file.Read( "mapvote/gamemodesdesc.json", "DATA")) 
		
		for k,v in pairs (engine.GetGamemodes()) do

			if (gmtable[v.name] == "nil" or gmtable[v.name] == nil) and MapVoteGamemodesDesc[v.name] then
				if MapVoteGamemodesDesc[v.name] ~= "nil" then
					gmtable[v.name] = MapVoteGamemodesDesc[v.name]
					changed = true
				end
			elseif MapVoteGamemodesDesc[v.name] == nil and gmtable[v.name] == nil then
				gmtable[v.name] = "nil"
				changed = true
			end
		end
		
		if changed == true then
			file.Write( "mapvote/gamemodesdesc.json", util.TableToJSON( gmtable ) )
			changed = false
		end
	
	end
	
end

local function fixStatistics()
	if not file.Exists( "mapvote/statistics.json", "DATA") or file.Size( "mapvote/statistics.json", "DATA" ) == 0 then
		local allmaps=file.Find("maps/*.bsp", "GAME") --makes a table containing all maps and gamemodes to create a file once
		local maplist = {}
		
		for k,v in pairs (allmaps) do
			maplist[string.TrimRight( v, ".bsp" )] = 0
		end
		
		for k,v in pairs (engine.GetGamemodes()) do
			maplist[v.name] = 0
		end

		file.Write( "mapvote/statistics.json", util.TableToJSON(maplist))
		
	else
		local statistics = util.JSONToTable(file.Read("mapvote/statistics.json", "DATA"))
		local changed = false	
		local allmaps = file.Find("maps/*.bsp", "GAME")
		local maplist = {}

		for k,v in pairs (allmaps) do
			table.Add(maplist, string.TrimRight( v, ".bsp" ))
		end

		for k,v in pairs (maplist) do
			if statistics[v] == nil then
				changed = true
				statistics[v] = 0
			end
		end
		
		if changed == true then
			file.Write( "mapvote/statistics.json", util.TableToJSON ( statistics ) )
		end
	end
end

local function fixGamemodePrefixes()

	if not file.Exists( "mapvote/gamemodes.json", "DATA") then
        file.Write( "mapvote/gamemodes.json", util.TableToJSON( gamemodesdefault ) )
    end
	
	local xgamemodes = util.JSONToTable( file.Read( "mapvote/gamemodes.json", "DATA" ) )
	if xgamemodes==nil then xgamemodes = {} end
	local changed = false
	
	for k,v in ipairs (engine.GetGamemodes()) do
		if xgamemodes[v.name]==nil and v.maps~=nil and v.maps~="" then
			
			local maps = string.gsub(v.maps , "|^", ",")
			maps = string.gsub(maps , "|", ",")
			if string.StartsWith( maps, "^" ) then maps = maps:sub(2,nil) end
			maps = string.Explode( ",", maps )
			xgamemodes[v.name] = {}

			xgamemodes[v.name] = maps
			changed = true
		elseif xgamemodes[v.name]==nil and (v.maps==nil or v.maps=="") then
			xgamemodes[v.name] = {[1] = ""}
			changed = true
		end
		
		if type(xgamemodes[v.name]) == "table" and table.Count(xgamemodes[v.name])>1 then
			for x,y in ipairs(xgamemodes[v.name]) do
				if y == "nil" or y == nil or y == "" then table.remove(xgamemodes[v.name], x) changed = true end
			end
		end
	end
	if changed then
		file.Write( "mapvote/gamemodes.json", util.TableToJSON( xgamemodes ) )
		changed = false
	end
end

local function fixGamemodes()
	if not file.Exists("mapvote/gamemodesenabled.json", "DATA") then
		local xtable = {}
		for k,v in ipairs(engine.GetGamemodes()) do
			xtable[v.name] = "enabled"
		end
		xtable["sandbox"] = "disabled"
		xtable["base"] = "disabled"
		xtable["fretta13"] = "disabled"
		file.Write("mapvote/gamemodesenabled.json", util.TableToJSON(xtable))
	end

	local xfile = file.Read("mapvote/gamemodesenabled.json", "DATA")
	local fileContent = util.JSONToTable(xfile)
	local gamemodesTable = {}
	local changed = false

	for k,v in ipairs(engine.GetGamemodes()) do
		if fileContent[v.name] == nil then
			fileContent[v.name] = "enabled"
			changed = true
		end
	end
	if changed then
		file.Write("mapvote/gamemodesenabled.json", util.TableToJSON(fileContent))
	end

end

local function blockCSSMap(ply)
	local xcssmaps = util.JSONToTable(file.Read("mapvote/cssmaps.json", "DATA"))
	local changed = false
	if not table.HasValue(xcssmaps,game.GetMap()) then
		xcssmaps[table.Count(xcssmaps)+1] = game.GetMap()
		changed = true
	end
	if changed then
		file.Write( "mapvote/cssmaps.json", util.TableToJSON( xcssmaps ) )
	end
	ply:ChatPrint("Successfully set this map on blacklist for CSS content")
end

local function fixConfigChange() -- remove or rewrite late config changes to avoid messing up people's mapvote settings
	local xconfig = util.JSONToTable(file.Read("mapvote/config.txt", "DATA")) 
	local changed = false
	if xconfig["RTVPlayerCount"] then 
		xconfig["RTVPlayerCount"] = nil
		changed = true
	end
	
	if xconfig["EnableCooldown"] then 
		xconfig["MapCooldown"] = xconfig["EnableCooldown"]
		xconfig["EnableCooldown"] = nil
		changed = true
	end

	if file.Exists("mapvote/localization.txt", "DATA") then
		file.Delete( "mapvote/localization.txt", "DATA" )
	end
	
	if changed then 
		file.Write( "mapvote/config.txt", util.TableToJSON ( xconfig ) )
	end
end

if SERVER then
	util.AddNetworkString("printServerToClientConsole")
	local function printToPlayerConsole(ply, message)
		net.Start("printServerToClientConsole")
			net.WriteTable(message)
		net.Send(ply)
	end

	local function mapvote_getGamemodes(ply)
		local xtable = engine.GetGamemodes()
		PrintTable( xtable )
		if ply then ply:ChatPrint("List of all Gamemodes has been printed to Console") printToPlayerConsole(ply, xtable) end
	end

	local function mapvote_getMaps(ply)
		local x = file.Find("maps/*.bsp", "GAME")
		if x then PrintTable( x ) end
		if ply then ply:ChatPrint("List of all installed Maps has been printed to Console") printToPlayerConsole(ply, x) end
	end

	local function mapvote_writeAddonListToFile(ply)
		file.Write( "mapvote/addonslist.txt", util.TableToJSON ( engine.GetAddons(), true ) )
		if ply then ply:ChatPrint("A list containing all server's installed addons has been written to /data/mapvote/addonslist.txt") end
	end

	local function mapvote_getCurrentGamemode(ply)
		local xtable = {}
		for k, v in pairs( engine.GetGamemodes() ) do
			if v.name == engine.ActiveGamemode() then
				xtable = v
				PrintTable(xtable)
				break
			end
		end
		if ply then ply:ChatPrint("Current Gamemode Information printed to Console") printToPlayerConsole(ply, xtable) end
	end

	local function mapvote_genGamemodeNameList(ply)
		local xlist = {}
		for k,v in pairs(engine.GetGamemodes()) do
			xlist[v.title] = v.name
		end
		file.Write( "mapvote/gamemodeNameList.txt", util.TableToJSON (  xlist, true ) )
		if ply then ply:ChatPrint("A list containing Gamemode Names and Titles has been saved to Server's /data/mapvote/gamemodeNameList.txt") end
	end

	hook.Add( "Initialize", "MapVoteConfigSetup", function()
		
		concommand.Add("mapvote_getGamemodes", function( ply, cmd, args ) 
			if not ply:IsAdmin() then return end
			mapvote_getGamemodes(ply)
		end)
		table.insert(conCommands, {["command"] = "mapvote_getGamemodes", ["desc"] = "Print a List of all installed Gamemodes to Console"})
		
		concommand.Add("mapvote_getMaps", function( ply, cmd, args ) 
			if not ply:IsAdmin() then return end
			mapvote_getMaps(ply)
		end)
		table.insert(conCommands, {["command"] = "mapvote_getMaps", ["desc"] = "Print a List of all installed Maps to Console"})
		
		concommand.Add("mapvote_comptest", function( ply, cmd, args ) 
			if not ply:IsAdmin() then return end
			SetGlobalBool( "mapvote_comptest", true )
			MapVote.Start()
		end)
		table.insert(conCommands, {["command"] = "mapvote_comptest", ["desc"] = "Test whether or not the current gamemode conflicts with the MapVoting System"})
		
		concommand.Add("mapvote_writeAddonListToFile", function( ply, cmd, args ) 
			if not ply:IsAdmin() then return end
			mapvote_writeAddonListToFile(ply)
		end)
		table.insert(conCommands, {["command"] = "mapvote_writeAddonListToFile", ["desc"] = "Save a List of all installed Addons to /data/mapvote"})
		
		concommand.Add("mapvote_getCurrentGamemode", function( ply, cmd, args ) 
			if not ply:IsAdmin() then return end
			mapvote_getCurrentGamemode(ply)
		end)
		table.insert(conCommands, {["command"] = "mapvote_getCurrentGamemode", ["desc"] = "Print Information about the current Gamemode to Console"})
		
		concommand.Add("mapvote_genGamemodeNameList", function( ply, cmd, args ) 
			if not ply:IsAdmin() then return end
			mapvote_genGamemodeNameList(ply)
		end)
		table.insert(conCommands, {["command"] = "mapvote_genGamemodeNameList", ["desc"] = "Save a List of matching Gamemode Names and Gamemode Titles to data/mapvote"})
		
		concommand.Add("mapvote_reportcssmap", function( ply, cmd, args ) 
			if not ply:IsAdmin() then return end
			blockCSSMap(ply)
		end)
		table.insert(conCommands, {["command"] = "mapvote_reportcssmap", ["desc"] = "Add the current Map to the CSS Blacklist meaning that it contains CSS content and will be affected by the CSS Filter Config"})

		if not file.Exists( "mapvote", "DATA") then
			file.CreateDir( "mapvote" )
		end
		
			fixGamemodeJsonChanges()
		createConfigDir()
		createPlayercountDependingGamemodes()
		createRatingResults()
		createCSSMaps()
		createMapPreviewHierarchy()
		fixRatingResults()
		fixPlayercountDependingGamemodes()
		fixGamemodePrefixes()
		fixGamemodes()
		fixConfig() 
			fixConfigChange()
		fixGamemodeDesc()
		fixStatistics()
		local activeGamemode = engine.ActiveGamemode()
		timer.Simple( 5, function()
			if file.Exists( "mapvote/" .. activeGamemode .. ".txt", "DATA" )==true and file.Size( "mapvote/" .. activeGamemode .. ".txt", "DATA" ) > 0 then
				
				local concoms = file.Read("mapvote/" .. activeGamemode .. ".txt", "DATA")
				local temptable={}
				local temptable2={}
				temptable=string.Explode( "\n", concoms )
				
				for k,v in pairs (temptable) do
					if string.sub( temptable[k], 1, 2 )~="//" and temptable[k]~=nil and temptable[k]~="\n" then
							temptable2=string.Explode( " ", temptable[k] )
							
							if #temptable2 == 5 then
								RunConsoleCommand( temptable2[1], temptable2[2], temptable2[3], temptable2[4], temptable2[5] )
								print("[MapVote] Ran command: ",temptable2[1]," ",temptable2[2]," ",temptable2[3]," ",temptable2[4]," ",temptable2[5])
							elseif #temptable2 == 4 then
								RunConsoleCommand( temptable2[1], temptable2[2], temptable2[3], temptable2[4] )
								print("[MapVote] Ran command: ",temptable2[1]," ",temptable2[2]," ",temptable2[3]," ",temptable2[4])
							elseif #temptable2 == 3 then
								RunConsoleCommand( temptable2[1], temptable2[2], temptable2[3] )
								print("[MapVote] Ran command: ",temptable2[1]," ",temptable2[2]," ",temptable2[3])
							elseif #temptable2 == 2 then
								RunConsoleCommand( temptable2[1], temptable2[2] )
								print("[MapVote] Ran command: ",temptable2[1]," ",temptable2[2])
							elseif #temptable2 == 1 then
								RunConsoleCommand( string.Trim(temptable2[1]),"" )
								print("[MapVote] Ran command: ",temptable2[1])
							end
					end
				end
			elseif file.Size( "mapvote/" .. activeGamemode .. ".txt", "DATA" ) == 0 then
				file.Delete( "mapvote/" .. activeGamemode .. ".txt", "DATA" )
			end
		end)
	

		-- ConCommands Tab
		--util.AddNetworkString("PSY_MapVote_LoadConCommands") --Moved to sv_mapvote.lua
		--util.AddNetworkString("PSY_MapVote_OfferConCommands")
		--util.AddNetworkString("PSY_MapVote_ExecuteConCommands")

		net.Receive("PSY_MapVote_LoadConCommands", function(len, ply)
			if not ply:IsAdmin() then return end
			net.Start("PSY_MapVote_OfferConCommands")
				net.WriteTable(conCommands)
			net.Send(ply)
		end)

		net.Receive("PSY_MapVote_ExecuteConCommands", function(len, ply)
			if not ply:IsAdmin() then return end
			local xcommand = net.ReadString()
			game.ConsoleCommand( xcommand.."\n" )
		end)
		
	end )
end
function MapVote.HasExtraVotePower(ply)
    if ply:IsAdmin() and MapVote.Config["AdminsHaveMoreVotePower"]==true then

		return true
	else 
		return false
	end
end


MapVote.CurrentMaps = {}
MapVote.Votes = {}

MapVote.Allow = false

MapVote.UPDATE_VOTE = 1
MapVote.UPDATE_WIN = 3

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("mapvote/cl_mapvote.lua")
    include("mapvote/sv_mapvote.lua")
    include("mapvote/rtv.lua")
	
	if ulx == nil then
		hook.Add( "PlayerSay", "addMapvoteCommandWithoutUlx", function( ply, text )
			if ( string.find( string.lower(text),"!mapvote" )  ) then
				text = string.Explode( " ", text )
				if ply:IsSuperAdmin() then 
					MapVote.Start(text[2], nil, nil, nil, "map")
					return
				end
			end
			if ( string.find( string.lower(text),"!gmvote" )  ) then
				text = string.Explode( " ", text )
				if ply:IsSuperAdmin() then 
					MapVote.Start(text[2], nil, nil, nil, "gamemode")
					return
				end
			end
			if ( string.find( string.lower(text),"!unmapvote" ) or string.find( string.lower(text),"!ungmvote" )  ) then
				if ply:IsSuperAdmin() then 
					MapVote.Cancel()
					return
				end
			end
		end )	
		concommand.Add("mapvote", function( ply, cmd, args ) 
			if not ply:IsSuperAdmin() then return end
			MapVote.Start(args[1], nil, nil, nil, "map")
		end)
		concommand.Add("mapvote", function( ply, cmd, args ) 
			if not ply:IsSuperAdmin() then return end
			MapVote.Start(args[1], nil, nil, nil, "gamemode")
		end)
		concommand.Add("unmapvote", function( ply, cmd, args ) 
			if not ply:IsSuperAdmin() then return end
			MapVote.Cancel()
		end)
		concommand.Add("ungmvote", function( ply, cmd, args ) 
			if not ply:IsSuperAdmin() then return end
			MapVote.Cancel()
		end)
	end
else
    include("mapvote/cl_mapvote.lua")
end
