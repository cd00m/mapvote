RTV = RTV or {}

RTV.ChatCommands = {
	
	"!rtv",
	"/rtv",
	"rtv"

}

RTV.TotalVotes = 0

local xconfig = {
	RTVPlayerPercent = 60,
	RTVCooldownAfterMapChange = 60,
	CooldownBetweenRTVs = 10,
	RTVMinimumPlayersRequired = 3
}

if file.Exists( "mapvote/config.txt", "DATA" ) then 
	xconfig = util.JSONToTable(file.Read( "mapvote/config.txt", "DATA" ))
end
RTV.PlayerPercent = tonumber(xconfig.RTVPlayerPercent) / 100
RTV.CooldownBetweenRTVs = tonumber(xconfig.CooldownBetweenRTVs)
RTV.Wait = tonumber(xconfig.RTVCooldownAfterMapChange)
RTV._ActualWait = CurTime() + RTV.Wait
RTV._ActualWaitPlayers = {}
RTV._ActualWaitUnRTVPlayers = {}

function RTV.ShouldChange()
	return RTV.TotalVotes >= math.Round(#player.GetHumans()*RTV.PlayerPercent)
end

function RTV.RemoveVoteOnLeave()
	RTV.TotalVotes = math.Clamp( RTV.TotalVotes - 1, 0, math.huge )
	PrintMessage( HUD_PRINTTALK, "A player has left. RTV: ("..RTV.TotalVotes.."/"..math.Round(#player.GetHumans()*RTV.PlayerPercent)..")".."["..math.Round(100*RTV.TotalVotes/#player.GetHumans()).."% / "..(RTV.PlayerPercent*100).."%]"  )
end

function RTV.Start()
	RTV.ChangingMaps = true
	if GAMEMODE_NAME == "terrortown" then
		net.Start("RTV_Delay")
		net.Broadcast()

		hook.Add("TTTEndRound", "MapvoteDelayed", function()
			MapVote.Start(nil, nil, nil, nil)
			hook.Remove("TTTEndRound", "MapvoteDelayed")
		end)
	elseif GAMEMODE_NAME == "deathrun" then
		net.Start("RTV_Delay")
		net.Broadcast()

		hook.Add("RoundEnd", "MapvoteDelayed", function()
			MapVote.Start(nil, nil, nil, nil)
			hook.Remove("RoundEnd", "MapvoteDelayed")
		end)

	else
		PrintMessage( HUD_PRINTTALK, "The vote has been rocked, MapVote imminent")
		timer.Simple(4, function()
			MapVote.Start(nil, nil, nil, nil)
		end)
	end
end


function RTV.AddVote( ply )

	if (#player.GetHumans() >= xconfig.RTVMinimumPlayersRequired) and RTV.CanVote( ply ) then
		RTV.TotalVotes = RTV.TotalVotes + 1
		ply.RTVoted = true
		MsgN( ply:Nick().." has voted to Rock the Vote." )
		PrintMessage( HUD_PRINTTALK, ply:Nick().." has voted to Rock the Vote. ("..RTV.TotalVotes.."/"..math.Round(#player.GetHumans()*RTV.PlayerPercent)..")".." ["..math.Round(100*RTV.TotalVotes/#player.GetHumans()).."% / "..(RTV.PlayerPercent*100).."%]"  )
		
		RTV._ActualWaitUnRTVPlayers[ply] = CurTime() + RTV.CooldownBetweenRTVs
		if RTV.ShouldChange() then
			RTV.Start()
		end
	elseif (#player.GetHumans() < xconfig.RTVMinimumPlayersRequired) then
		ply:ChatPrint("Not enough players to use RTV. Required: "..tostring(xconfig.RTVMinimumPlayersRequired))	
	end
	
end

function RTV.resetVotes()
	for i, ply in ipairs(player.GetHumans()) do
		if ply.RTVoted != nil and ply.RTVoted then
			ply.RTVoted = false
			RTV.TotalVotes = RTV.TotalVotes - 1
		end
	end
	RTV.ChangingMaps = false
end

function RTV.RemoveVote( ply )
	local can, err = RTV.CanUnVote(ply)

	if not can then
		ply:PrintMessage( HUD_PRINTTALK, err )
		return
	end
	
	ply.RTVoted = false
	RTV.TotalVotes = RTV.TotalVotes - 1
	PrintMessage( HUD_PRINTTALK, ply:Nick().." has unvoted to Rock the Vote. ("..RTV.TotalVotes.."/"..math.Round(#player.GetHumans()*RTV.PlayerPercent)..")".." ["..math.Round(100*RTV.TotalVotes/#player.GetHumans()).."% / "..(RTV.PlayerPercent*100).."%]"  )
	RTV._ActualWaitPlayers[ply] = CurTime() + RTV.CooldownBetweenRTVs
end

hook.Add( "PlayerDisconnected", "Remove RTV", function( ply )
	local can, err = RTV.CanUnVoteOnLeave(ply)
	if can then
		RTV.RemoveVoteOnLeave()
	end
end )

function RTV.CanVote( ply )
	local plyCount = table.Count(player.GetHumans())
	
	if RTV._ActualWaitPlayers and RTV._ActualWaitPlayers[ply] then
		if RTV._ActualWaitPlayers[ply] >= CurTime() then
			return false, "You must wait a bit before voting again!"
		end
	end
	
	if RTV._ActualWait >= CurTime() then
		return false, "You must wait a bit before voting!"
	end
	
	if GetGlobalBool( "In_Voting" ) then
		return false, "There is currently a vote in progress!"
	end

	if ply.RTVoted then
		return false, "You have already voted to Rock the Vote!"
	end

	if RTV.ChangingMaps then
		return false, "There has already been a vote, the map is going to change!"
	end
	
	if plyCount < 1 then
        return false, "You need more players before you can rock the vote!"
    end

	return true

end

function RTV.CanUnVote( ply )

	if RTV._ActualWaitUnRTVPlayers and RTV._ActualWaitUnRTVPlayers[ply] then
		if RTV._ActualWaitUnRTVPlayers[ply] >= CurTime() then
			return false, "You must wait a bit before unvoting again!"
		end
	end

	if GetGlobalBool( "In_Voting" ) then
		return false, "There is currently a vote in progress!"
	end

	if not ply.RTVoted then
		return false, "You haven't voted to Rock the Vote!"
	end

	if RTV.ChangingMaps then
		return false, "Can't revoke your vote, the map is going to change!"
	end

	return true

end

function RTV.CanUnVoteOnLeave( ply )

	if GetGlobalBool( "In_Voting" ) then
		return false, "There is currently a vote in progress!"
	end

	if not ply.RTVoted then
		return false, "You haven't voted to Rock the Vote!"
	end

	if RTV.ChangingMaps then
		return false, "Can't revoke your vote, the map is going to change!"
	end

	return true

end

function RTV.StartVote( ply )

	local can, err = RTV.CanVote(ply)

	if not can then
		ply:PrintMessage( HUD_PRINTTALK, err )
		return
	end

	RTV.AddVote( ply )

end

concommand.Add( "rtv_start", RTV.StartVote )

hook.Add( "PlayerSay", "RTV Chat Commands", function( ply, text )
	if table.HasValue( RTV.ChatCommands, string.lower(text) ) then
		RTV.StartVote( ply )
		return ""
	elseif(string.lower(text) == "!unrtv") then
		RTV.RemoveVote( ply )
		return ""
	end	

end )