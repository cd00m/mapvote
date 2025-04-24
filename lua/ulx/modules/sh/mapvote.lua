local CATEGORY_NAME = "MapVote"
------------------------------ VoteMap ------------------------------

local function sendCallingPly( ply )
	SetGlobalEntity( "MapVoteCallingPly", ply )
end

function AMB_mapvote( calling_ply, votetime, should_cancel )
	sendCallingPly( calling_ply )
	if not should_cancel then
		OverrideGamemodeSkipConfig = false
		MapVote.Start(votetime, nil, nil, nil, "map")
		ulx.fancyLogAdmin( calling_ply, "#A called a votemap! You can use !gmvote to vote for gamemodes instead" )
	else
		MapVote.Cancel()
		ulx.fancyLogAdmin( calling_ply, "#A canceled the votemap" )
	end
end

function AMB_gmvote( calling_ply, votetime, should_cancel )
	sendCallingPly( calling_ply )
	if not should_cancel then
		OverrideGamemodeSkipConfig = true
		MapVote.Start(votetime, nil, nil, nil, "gamemode")
		ulx.fancyLogAdmin( calling_ply, "#A called a gamemode vote! You can use !mapvote to directly vote for maps instead" )
	else
		OverrideGamemodeSkipConfig = false
		MapVote.Cancel()
		ulx.fancyLogAdmin( calling_ply, "#A canceled the gamemode vote" )
	end
end



local mapvotecmd = ulx.command( CATEGORY_NAME, "mapvote", AMB_mapvote, "!mapvote" )
mapvotecmd:addParam{ type=ULib.cmds.NumArg, min=5, default=998, hint="time", ULib.cmds.optional, ULib.cmds.round }
mapvotecmd:addParam{ type=ULib.cmds.BoolArg, invisible=true }
mapvotecmd:defaultAccess( ULib.ACCESS_ADMIN )
mapvotecmd:help( "Invokes the map vote logic" )
mapvotecmd:setOpposite( "unmapvote", {_, _, true}, "!unmapvote" )

local gmvote = ulx.command( CATEGORY_NAME, "gmvote", AMB_gmvote, "!gmvote" )
gmvote:addParam{ type=ULib.cmds.NumArg, min=5, default=998, hint="time", ULib.cmds.optional, ULib.cmds.round }
gmvote:addParam{ type=ULib.cmds.BoolArg, invisible=true }
gmvote:defaultAccess( ULib.ACCESS_ADMIN )
gmvote:help( "Invokes the gamemode vote logic" )
gmvote:setOpposite( "ungmvote", {_, _, true}, "!ungmvote" )

