local addons = {}
local mapvote_statistics_map = {}
local mapvote_statistics_gamemode = {}
local GamemodesList = {}
local xMapVoteConfig
local xMapPreviewHierarchy = {}
local GamemodeVoteCompleted = false
local MapVoteLocalization = {}
local rating
local rating1
local rating2
local receivedRatings = {}
local mapThumbnailCache = {}
local gamemodeThumbnailCache = {}
local langPanel = false

CreateClientConVar( "mapvote_language", "english", true, true, "Set the language for the MapVote menu")

local localizationDefault = {
	
	english = { -- English
		["timer"] = "seconds",
		["randombutton"] = "RANDOM",
		["extendbutton"] = "EXTEND CURRENT MAP",
		["replaybutton"] = "REPLAY MAP AND GM",
		["ratingpanel1"] = "What do you rate this gamemode?",
		["ratingpanel2"] = "How do you rate this map?",
		["ratingpanel3"] = "Rating sent!",
		["sandbox_countdown1"] = "Map Change in",
		["sandbox_countdown2"] = "seconds. Save your stuff before it's too late!",
		["mapvote_cooldown1"] = "MapVote cancelled. A recent MapVote has been unsuccessful. You can start a new one in",
		["MapVote Starting in"] = "MapVote Starting in",
		["seconds"] = "seconds"
	},
	
	chinese = { -- Vereinfacht Chinesische
		["timer"] = "秒",
		["randombutton"] = "随机",
		["extendbutton"] = "延长当前地图",
		["replaybutton"] = "重播地图和GM",
		["ratingpanel1"] = "您如何评价此游戏模式？",
		["ratingpanel2"] = "你如何评价这张地图？",
		["ratingpanel3"] = "评分已发送！",
		["sandbox_countdown1"] = "地图更改在",
		["sandbox_countdown2"] = "秒内。 在为时已晚之前保存您的东西！",
		["mapvote_cooldown1"] = "地图投票取消。 最近的地图投票未成功。 您可以在",
		["MapVote Starting in"] = "地图投票开始于",
		["seconds"] = "秒"
	},

	japanese = { -- Japanisch
		["timer"] = "秒",
		["randombutton"] = "ランダム",
		["extendbutton"] = "現在のマップを延長",
		["replaybutton"] = "マップとGMをリプレイ",
		["ratingpanel1"] = "このゲームモードをどのように評価しますか？",
		["ratingpanel2"] = "この地図をどう評価しますか？",
		["ratingpanel3"] = "評価が送信されました！",
		["sandbox_countdown1"] = "マップ変更まで",
		["sandbox_countdown2"] = "秒。 遅くなる前に保存してください！",
		["mapvote_cooldown1"] = "マップ投票がキャンセルされました。 最近のマップ投票が失敗しました。 新しいマップ投票を開始できます",
		["MapVote Starting in"] = "MapVote が開始されました",
		["seconds"] = "秒"
	},

	korean = { -- Koreanisch
		["timer"] = "초",
		["randombutton"] = "랜덤",
		["extendbutton"] = "현재 맵 연장",
		["replaybutton"] = "맵 및 GM 재플레이",
		["ratingpanel1"] = "이 게임 모드를 어떻게 평가 하시겠습니까?",
		["ratingpanel2"] = "이 지도를 어떻게 평가하시나요?",
		["ratingpanel3"] = "평가가 전송되었습니다!",
		["sandbox_countdown1"] = "맵 변경까지",
		["sandbox_countdown2"] = "초. 너무 늦기 전에 당신의 물건을 저장하세요!",
		["mapvote_cooldown1"] = "맵 투표가 취소되었습니다. 최근의 맵 투표가 실패했습니다. 새로운 것을 시작할 수 있습니다",
		["MapVote Starting in"] = "MapVote가 시작되었습니다",
		["seconds"] = "초"
	},

	german = { -- Deutsch
		["timer"] = "Sekunden",
		["randombutton"] = "ZUFÄLLIG",
		["extendbutton"] = "AKTUELLE MAP VERLÄNGERN",
		["replaybutton"] = "Karte und GM wiederholen",
		["ratingpanel1"] = "Wie bewertest du diesen Spielmodus?",
		["ratingpanel2"] = "Wie bewertest du diese Map?",
		["ratingpanel3"] = "Bewertung gesendet!",
		["sandbox_countdown1"] = "Kartenwechsel in",
		["sandbox_countdown2"] = "Sekunden. Speichern Sie Ihre Sachen, bevor es zu spät ist!",
		["mapvote_cooldown1"] = "MapVote abgebrochen. Ein kürzlich durchgeführter MapVote war nicht erfolgreich. Sie können einen neuen starten in",
		["MapVote Starting in"] = "MapVote beginnt in",
		["seconds"] = "Sekunden"
	},

	spanish = { -- Spanisch
		["timer"] = "segundos",
		["randombutton"] = "ALEATORIO",
		["extendbutton"] = "EXTENDER MAPA ACTUAL",
		["replaybutton"] = "REPRODUCIR MAPA Y GM",
		["ratingpanel1"] = "¿Cómo calificas este modo de juego?",
		["ratingpanel2"] = "¿Cómo evalúas este mapa?",
		["ratingpanel3"] = "¡Calificación enviada!",
		["sandbox_countdown1"] = "Cambio de mapa en",
		["sandbox_countdown2"] = "segundos. ¡Guarda tus cosas antes de que sea demasiado tarde!",
		["mapvote_cooldown1"] = "MapVote cancelado. Un MapVote reciente no ha tenido éxito. Puedes comenzar uno nuevo en",
		["MapVote Starting in"] = "MapVote comienza en",
		["seconds"] = "segundos"
	},

	french = { -- Französisch
		["timer"] = "secondes",
		["randombutton"] = "ALÉATOIRE",
		["extendbutton"] = "PROLONGER LA CARTE ACTUELLE",
		["replaybutton"] = "REJOUER LA CARTE ET GM",
		["ratingpanel1"] = "Comment évaluez-vous ce mode de jeu?",
		["ratingpanel2"] = "Comment évalues-tu cette carte ?",
		["ratingpanel3"] = "Évaluation envoyée!",
		["sandbox_countdown1"] = "Changement de carte dans",
		["sandbox_countdown2"] = "secondes. Enregistrez vos affaires avant qu'il ne soit trop tard!",
		["mapvote_cooldown1"] = "MapVote annulé. Un MapVote récent a échoué. Vous pouvez en démarrer un nouveau dans",
		["MapVote Starting in"] = "MapVote commence dans",
		["seconds"] = "secondes"
	},

	italian = { -- Italienisch
		["timer"] = "secondi",
		["randombutton"] = "CASUALE",
		["extendbutton"] = "ESTENDI MAPPA CORRENTE",
		["replaybutton"] = "RIPRODUCI MAPPA E GM",
		["ratingpanel1"] = "Come valuti questa modalità di gioco?",
		["ratingpanel2"] = "Come valuti questa mappa?",
		["ratingpanel3"] = "Valutazione inviata!",
		["sandbox_countdown1"] = "Cambio mappa in",
		["sandbox_countdown2"] = "secondi. Salva le tue cose prima che sia troppo tardi!",
		["mapvote_cooldown1"] = "MapVote annullato. Un MapVote recente non è riuscito. Puoi avviarne uno nuovo in",
		["MapVote Starting in"] = "MapVote inizia in",
		["seconds"] = "secondi"
	},
		
	norwegian = { -- Norwegisch
		["timer"] = "sekunder",
		["randombutton"] = "TILFELDIG",
		["extendbutton"] = "FORLENG NÅVÆRENDE KART",
		["replaybutton"] = "SPILL AV KART OG GM PÅ NYTT",
		["ratingpanel1"] = "Hvordan vurderer du denne spillmodusen?",
		["ratingpanel2"] = "Hvordan vurderer du dette kartet?",
		["ratingpanel3"] = "Vurdering sendt!",
		["sandbox_countdown1"] = "Kartendring om",
		["sandbox_countdown2"] = "sekunder. Lagre tingene dine før det er for sent!",
		["mapvote_cooldown1"] = "MapVote avbrutt. En nylig MapVote var mislykket. Du kan starte en ny om",
		["MapVote Starting in"] = "MapVote starter om",
		["seconds"] = "sekunder"
	},
	
	russian = { -- Russisch
		["timer"] = "секунды",
		["randombutton"] = "СЛУЧАЙНЫЙ",
		["extendbutton"] = "ПРОДЛИТЬ ТЕКУЩУЮ КАРТУ",
		["replaybutton"] = "ПОВТОРНО ВОСПРОИЗВЕСТИ КАРТУ И GM",
		["ratingpanel1"] = "Как вы оцениваете этот игровой режим?",
		["ratingpanel2"] = "Как вы оцениваете эту карту?",
		["ratingpanel3"] = "Оценка отправлена!",
		["sandbox_countdown1"] = "Смена карты через",
		["sandbox_countdown2"] = "секунд. Сохраните свои вещи, пока не поздно!",
		["mapvote_cooldown1"] = "MapVote отменен. Недавний MapVote не удался. Вы можете начать новый через",
		["MapVote Starting in"] = "MapVote начнется через",
		["seconds"] = "секунд"
	},
	
	swedish = { -- Schwedisch
		["timer"] = "sekunder",
		["randombutton"] = "SLUMP",
		["extendbutton"] = "FÖRLÄNG AKTUELL KARTA",
		["replaybutton"] = "SPELA OM KARTA OCH GM",
		["ratingpanel1"] = "Hur betygsätter du den här spelinställningen?",
		["ratingpanel2"] = "Hur bedömer du den här kartan?",
		["ratingpanel3"] = "Betyg skickat!",
		["sandbox_countdown1"] = "Kartbyte om",
		["sandbox_countdown2"] = "sekunder. Spara dina saker innan det är för sent!",
		["mapvote_cooldown1"] = "MapVote avbruten. En nyligen genomförd MapVote har misslyckats. Du kan starta en ny om",
		["MapVote Starting in"] = "MapVote börjar om",
		["seconds"] = "sekunder"
	},
	
	turkish = { -- Türkisch
		["timer"] = "saniye",
		["randombutton"] = "RASTGELE",
		["extendbutton"] = "MEVCUT HARİTAYI UZAT",
		["replaybutton"] = "HARİTA VE GM'Yİ TEKRARLA",
		["ratingpanel1"] = "Bu oyun modunu nasıl değerlendirirsiniz?",
		["ratingpanel2"] = "Bu haritayı nasıl değerlendiriyorsun?",
		["ratingpanel3"] = "Değerlendirme gönderildi!",
		["sandbox_countdown1"] = "Harita değişimi",
		["sandbox_countdown2"] = "saniye içinde. İş işten geçmeden önce eşyalarınızı kaydedin!",
		["mapvote_cooldown1"] = "MapVote iptal edildi. Son MapVote başarısız oldu. Yeni bir tane başlatabilirsiniz",
		["MapVote Starting in"] = "MapVote şu sürede başlayacak",
		["seconds"] = "saniye"
	}

}

local defaultMapPreviewHierarchy = {
	{["directory"] = "maps/thumb/",["path"] = "GAME"},
	{["directory"] = "maps/",["path"] = "GAME"},
	{["directory"] = "mapicon/",["path"] = "DATA"},
	{["directory"] = "maps/thumbs/",["path"] = "DATA"}
}

CreateConVar( "mapvote_LayoutMenu", 1, FCVAR_ARCHIVE )
local function calcScaling()
	if ScrW() >= 3840 and ScrH() >= 2160 then
		return 1.3
	elseif ScrW() >= 2560 and ScrH() >= 1440 then
		return 1
	elseif ScrW() >= 1920 and ScrH() >= 1080 then
		return 1
	else
		return 1/2
	end
end

local function saveToFiles(name, path)
	if not file.Exists("maps/thumbs", "DATA") then
		file.CreateDir( "maps/thumbs" )
	end
	if not file.Exists("maps/thumbs/"..name:lower()..".png", "DATA") then
		file.Write( "maps/thumbs/"..name:lower()..".png", file.Read( path, "GAME" ) )
	end
end

local function notifyServerWide(message)
	net.Start("PSY_MapVote_notifyServerWide")
		net.WriteString(message)
	net.SendToServer()
end

-- concommand.Add("mapvote_testhttp", function()
	-- http.Fetch("85.215.151.114:5000",
		-- function(body, len, headers, code)
			-- print("Erfolg! Antwort erhalten:")
			-- print(body)
		-- end,
		-- function(error)
			-- print("Fehler bei der Anfrage: " .. error)
		-- end
	-- )
-- end)


--gameModesPanel:SetSize(500, 350)


local function getLocalization(phrase)
	local xlang = GetConVar( "mapvote_language" ):GetString()
	if localizationDefault[xlang][phrase] ~= nil then
		return localizationDefault[xlang][phrase]
	else 
		return "NOTFOUND"
	end
end

net.Receive("PSY_MapVoteGamemodesDesc", function()
	GamemodesDesc = net.ReadTable()
end)

net.Receive("PSY_MapVoteCountdownSound", function()
	if(net.ReadBool()) then
		surface.PlaySound( "UI/buttonclick.wav" )
	end
end)

net.Receive("PSY_MapVoteSendConfig", function()
	xMapVoteConfig = net.ReadTable()
end)

net.Receive("PSY_MapVoteSendHierarchy", function()
	xMapPreviewHierarchy = net.ReadTable()
end)

net.Receive("PSY_MapVoteGamemodesList", function()
	GamemodesList = net.ReadTable()
end)

net.Receive("PSY_MapVoteCurrentGamemode", function()
	CurrentGamemode = net.ReadString()
end)

net.Receive("PSY_MapVoteAddons", function()
	addons = net.ReadTable() or {}
end)

net.Receive("PSY_MapVoteMapStatistics", function()
	if GamemodeVoteCompleted then
		mapvote_statistics_map = net.ReadTable()
	else 
		mapvote_statistics_gamemode = net.ReadTable()
	end
	
end)

net.Receive("printServerToClientConsole", function()
	local message = net.ReadTable()
	print("Received Server Console Message:")
	PrintTable(message)
end)

surface.CreateFont("PSY_ConfigMenu", {
	font = "DermaDefault",
	size = 19 * calcScaling(),
	weight = 700,
})

surface.CreateFont("PSY_RatingFont", {
	font = "DermaDefault",
	size = 24 * calcScaling(),
	weight = 400,
})

surface.CreateFont("PSY_GUIFont", {
	font = "DermaDefault",
	size = 19,
	weight = 600,
})

surface.CreateFont("PSY_VoteFont", {
	font = "Trebuchet MS",
	size = 19,
	weight = 700,
	antialias = true,
	shadow = false
})

surface.CreateFont("PSY_VoteFontCountdown", {
	font = "Tahoma",
	size = 32 * calcScaling(),
	weight = 700,
	antialias = true,
	shadow = true
})

surface.CreateFont("PSY_AnnounceStart", {
	font = "DermaLarge",
	size = 60,
	weight = 600,
	antialias = true,
	shadow = false
})



MapVote.EndTime = 0
MapVote.Panel = false
local ratingPanelCounter = 0
local iconcache = {}
net.Receive("PSY_mapvote_announceStart", function()
	--if GamemodeVoteCompleted then return end

    local panel1 = vgui.Create("DPanel")
   	panel1:SetSize(1000, 4)
    panel1:Center()
	panel1:SetPos(-300, ScrH() / 8 - 50)
    panel1:MoveTo(( ScrW() - panel1:GetWide() )/ 2, panel1:GetY(), 1, 0, -1)
	panel1.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(215, 87, 87))
	end
	--Color(211, 211, 211)
	local panel2 = vgui.Create("DPanel")
   	panel2:SetSize(1000, 4)
	panel2:SetPos(ScrW() + 1, ScrH() / 8  + 50)
    panel2:MoveTo(( ScrW() - panel2:GetWide() ) / 2, panel2:GetY(), 1, 0, -1)
	panel2.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(122, 175, 255))
	end
   
	local backgroundPanel = vgui.Create("DPanel")
	
	backgroundPanel.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(173, 216, 230))
	end

    local label = vgui.Create("DLabel", backgroundPanel)
	
    label:SetFont("PSY_AnnounceStart")
	label:Dock(FILL)
    label:SetContentAlignment(5) 
    label:SetText(getLocalization("MapVote Starting in").." 3 "..getLocalization("seconds"))
	label:SetTextColor(Color(255,255,255))
	--label:SizeToContentsY()
	--label:SizeToContentsX()

	backgroundPanel:SetSize(800, label:GetTall() + 40)
	backgroundPanel:SetContentAlignment(5) 

	local panelMid = panel1:GetY() + ((panel2:GetY() - panel1:GetY()) / 2) - backgroundPanel:GetTall() / 2
	backgroundPanel:SetPos(ScrW() + 10, panelMid)
	backgroundPanel:MoveTo((ScrW() - backgroundPanel:GetWide()) / 2, panelMid, 1, 0, -1) 


    local countdown = 4
    local function UpdateCountdown()
		surface.PlaySound( "hl1/fvox/blip.wav" )
        countdown = countdown - 1
        if countdown >= 2 then
            label:SetText(getLocalization("MapVote Starting in").." "..countdown.." "..getLocalization("seconds"))
            timer.Simple(1, UpdateCountdown)
		elseif countdown == 1 then
			local function decreaseAlpha(x)
				if x < 5 or not IsValid(panel1) then return end 
				panel1:SetAlpha(x)
				panel2:SetAlpha(x)
				backgroundPanel:SetAlpha(x)
				timer.Simple(0.03, function() decreaseAlpha(x - 10) end)
			end
			decreaseAlpha(255)

			label:SetText(getLocalization("MapVote Starting in").." "..countdown.." "..getLocalization("seconds"))
            timer.Simple(1, UpdateCountdown)
		elseif countdown <= 0 then
            panel1:Remove()
			panel2:Remove()
			backgroundPanel:Remove()
        end
    end
    timer.Simple(1, UpdateCountdown)
end)


net.Receive("PSY_MapVoteStart", function()
	
    MapVote.CurrentMaps = {}
    MapVote.Allow = true
    MapVote.Votes = {}

    local amt = net.ReadUInt(32)
    for i = 1, amt do
        local map = net.ReadString()
        
        MapVote.CurrentMaps[#MapVote.CurrentMaps + 1] = map
		
    end
	
	GamemodeVoteCompleted = net.ReadBool()
    MapVote.EndTime = CurTime() + net.ReadUInt(32)
	

	if GamemodeVoteCompleted then
		for k, v in pairs(MapVote.CurrentMaps) do
			for k, addonInfo in ipairs(addons) do
				if string.find( addonInfo.title:lower() , v:lower() ) then
					local wsid = tonumber(addonInfo.wsid) 
					if iconcache[wsid] == nil and not getMapThumbnail(v) then
						steamworks.FileInfo(wsid, function(result)
							if file.Exists("cache/workshop/"..result.previewid..".cache", "GAME") then
								iconcache[wsid] = "cache/workshop/"..result.previewid..".cache"
							else
								steamworks.Download(result.previewid, true, function(cachePath)
									if cachePath ~= nil then
										iconcache[wsid] = cachePath
									end
								end) 
							end
						end)
					end
				end
			end
		end
	end
	
	if(IsValid(MapVote.Panel)) then
		MapVote.Panel:Remove()
	end
	
	MapVote.Panel = vgui.Create("VoteScreen")
	timer.Simple(0.1, function()

		local succ, err = pcall(function() MapVote.Panel:SetMaps(MapVote.CurrentMaps) end)
		if err then
			print(err)
			net.Start( "PSY_MapVoteCancel2" )
				net.WriteString("This gamemode might be incompatible with the MapVote addon\n"..err)
			net.SendToServer()
		else
			if GetGlobalBool( "mapvote_comptest", false ) == true then	
				net.Start( "PSY_MapVoteCancel2" )
					net.WriteString("1")
				net.SendToServer()
			end
		end
	end)
end)

net.Receive("PSY_MapVoteUpdate", function()
    local update_type = net.ReadUInt(3)
    
    if(update_type == MapVote.UPDATE_VOTE) then
        local ply = net.ReadEntity()
        
        if(IsValid(ply)) then
            local map_id = net.ReadUInt(32)
            MapVote.Votes[ply:SteamID()] = map_id
        
            if(IsValid(MapVote.Panel)) then
                MapVote.Panel:AddVoter(ply)
            end
        end
    elseif(update_type == MapVote.UPDATE_WIN) then      
        if(IsValid(MapVote.Panel)) then
            MapVote.Panel:Flash(net.ReadUInt(32))
        end
    end
end)

net.Receive("PSY_MapVoteCancel", function()
    if IsValid(MapVote.Panel) then
        MapVote.Panel:Remove()
		ratingPanelCounter = 0
    end
end)

net.Receive("RTV_Delay", function()
    chat.AddText(Color( 102,255,51 ), "[RTV]", Color( 255,255,255 ), " The vote has been rocked, map vote will begin on round end")
end)

local PANEL = {}

function PANEL:Init()
    self:ParentToHUD()
    
    self.Canvas = vgui.Create("Panel", self)
    self.Canvas:MakePopup()
	self.Canvas:SetDrawOnTop( true )
    self.Canvas:SetKeyboardInputEnabled(false)
	self.Canvas:SetSize(ScrW(),ScrH())
	self.Canvas:SetPos(0,0)
	MapvoteCanvas = self.Canvas

    self.countDown = vgui.Create("DLabel", self.Canvas)
    self.countDown:SetTextColor(color_white)
    self.countDown:SetFont("PSY_VoteFontCountdown")
    self.countDown:SetText("")
	self.countDown:MakePopup()
	self.countDown:SetKeyboardInputEnabled(false)
    self.countDown:SetPos(ScrW()/2, 14 * calcScaling())
	self.countDown:SetContentAlignment( 5 )
	
	
    

    self.Voters = {}

	local mylogo21 = vgui.Create("DImageButton", self.Canvas)	--print my logo
	mylogo21:SetImage("materials/icons/mylogo.png")
	mylogo21:SetPos(ScrW()-100, ScrH()-50)
	mylogo21:SetSize(100,50)
	mylogo21.DoClick = function()
		gui.OpenURL( "https://steamcommunity.com/id/Psychotrickser/" )
	end
	
	-- local mylogo21text = vgui.Create("DLabel", self.Canvas)
	-- mylogo21text:SetFont("PSY_VoteFont")
	-- --mylogo21text:SetPos(ScrW()-340, ScrH()-50)
	-- --mylogo21text:SetText('made by Koray2021 / Psychotrickser')
	-- --mylogo21text:SetSize(250,50)
	
	-- mylogo21text:SetPos(ScrW()-500, ScrH()-50)
	-- mylogo21text:SetText('Public Server with more than 50 gamemodes: 85.215.151.114')
	-- mylogo21text:SetSize(250,50)
	-- mylogo21text:SizeToContentsX(  )
end

local function sendPingToMapvote(x,y)
	if xMapVoteConfig.PlayersCanPingDuringVote then
		local x1 = ScrW()
		local y1 = ScrH()
		net.Start("MapVote_SetPing")
			net.WriteInt(x, 32)
			net.WriteInt(y, 32)
			net.WriteString(LocalPlayer():Nick())
			net.WriteInt(x1, 16)
			net.WriteInt(y1, 16)
		net.SendToServer()
	end
end

function PANEL:PerformLayout()
    local cx, cy = chat.GetChatBoxPos()
	
    self:SetPos(0, 0)
    self:SetSize(ScrW(), ScrH())

	self.Canvas:SetPos(0, 0)
    self.Canvas:SetSize(ScrW(), ScrH())
	
    local extra = math.Clamp(300, 0, ScrW() - 640)
	
    self.Canvas:StretchToParent(0, 0, 0, 0)
	self.Canvas.OnMousePressed = function(pnl, keyCode)
		if keyCode == MOUSE_RIGHT then
			local x, y = gui.MousePos()
			sendPingToMapvote(x,y)
		end
	end
end

local heart_mat = Material("icon16/heart.png")
local star_mat = Material("icon16/star.png")
local shield_mat = Material("icon16/shield.png")

function PANEL:AddVoter(voter)

    for k, v in pairs(self.Voters) do
        if(v.Player and v.Player == voter) then
            return false
        end
    end
    
    
    local icon_container = vgui.Create("Panel", self.mapList:GetCanvas())
    local icon = vgui.Create("AvatarImage", icon_container)
    icon:SetSize(16, 16)
    icon:SetZPos(1000)
    icon:SetTooltip(voter:Name())
    icon_container.Player = voter
    icon_container:SetTooltip(voter:Name())
    icon:SetPlayer(voter, 16)


    if MapVote.HasExtraVotePower(voter) then
        icon_container:SetSize(40, 20)
        icon:SetPos(21, 2)
        icon_container.img = star_mat
    else
        icon_container:SetSize(20, 20)
        icon:SetPos(2, 2)
    end
    
    icon_container.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(255, 0, 0, 80))
        
        if(icon_container.img) then
            surface.SetMaterial(icon_container.img)
            surface.SetDrawColor(Color(255, 255, 255))
            surface.DrawTexturedRect(2, 2, 16, 16)
        end
    end
    table.insert(self.Voters, icon_container)
end

function PANEL:Think()
	if IsValid(self.mapList) then
		for k, v in pairs(self.mapList:GetItems()) do
			v.NumVotes = 0
		end
	end
    for k, v in pairs(self.Voters) do
        if(not IsValid(v.Player)) then
            v:Remove()
        else
            if(not MapVote.Votes[v.Player:SteamID()]) then
                v:Remove()
            else
                local bar = self:GetMapButton(MapVote.Votes[v.Player:SteamID()])
                
                if(MapVote.HasExtraVotePower(v.Player)) then
                    bar.NumVotes = bar.NumVotes + 2
                else
                    bar.NumVotes = bar.NumVotes + 1
                end
                
                if(IsValid(bar)) then
                    local CurrentPos = Vector(v.x, v.y, 0)
                    local NewPos = Vector((bar.x + bar:GetWide()) - 21 * bar.NumVotes - 2, bar.y + (bar:GetTall() * 0.5 -10), 0)
                    --if xMapVoteConfig.ImageBasedMapVote then NewPos = NewPos + Vector(10,0,0) end
                    if(not v.CurPos or v.CurPos ~= NewPos) then
                        v:MoveTo(NewPos.x, NewPos.y, 0.3)
                        v.CurPos = NewPos
                    end
					
                end
            end
        end
    end
    
    local timeLeft = math.Round(math.Clamp(MapVote.EndTime - CurTime(), 0, math.huge))
    self.countDown:SetText(tostring(timeLeft or 0).." "..getLocalization("timer"))
    self.countDown:SizeToContents()
    self.countDown:CenterHorizontal()
end

function PANEL:SetMaps(maps)
	if xMapVoteConfig.GamemodesAndMapsHaveRatings then
		if not IsValid(ratingPanel) and ratingPanelCounter == 0 then
			initRatingPanel()
			setStarImage()
			initStarFunctions()
		end
	end
	self.mapList = vgui.Create("DPanelList", self.Canvas)
	

	self.closeButton = vgui.Create("DButton", self.Canvas)
	self.closeButton:SetText("")
	self.closeButton:SetSize(31, 31)
	self.closeButton:SetVisible(true)
	self.closeButton.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "WindowCloseButton", panel, w, h)
	end
	self.closeButton.DoClick = function()
		self:SetVisible(false)
		self.Canvas:SetDrawOnTop( false )
		if IsValid(ratingPanel) then
			ratingPanel:SetVisible(false)
		end
	end

	self.maximButton = vgui.Create("DButton", self.Canvas)
	self.maximButton:SetText("")
	self.maximButton:SetDisabled(true)
	self.maximButton:SetSize(31, 31)
	self.maximButton:SetVisible(true)
	self.maximButton.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "WindowMaximizeButton", panel, w, h)
	end

	self.minimButton = vgui.Create("DButton", self.Canvas)
	self.minimButton:SetText("")
	self.minimButton:SetDisabled(true)
	self.minimButton:SetSize(31, 31)
	self.minimButton:SetVisible(true)
	self.minimButton.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "WindowMinimizeButton", panel, w, h)
	end


	if GetConVar("mapvote_LayoutMenu"):GetBool() then
		local xhoch = ScrH()*0.9
		local xbreit = ScrW()*0.6
		self.mapList:Clear()
		self.mapList:SetSpacing(8)
		self.mapList:SetPadding(4)
		self.mapList:SetSize(xbreit,xhoch)
		self.mapList:SetPos((ScrW()-xbreit) / 2,(ScrH()-xhoch) / 2)
		self.mapList:EnableHorizontal(true)
		self.mapList:EnableVerticalScrollbar()

		local buttonPos = self:GetWide() * 5/6
		self.closeButton:SetPos(buttonPos - 31 * 0, 4)
		self.maximButton:SetPos(buttonPos - 31 * 1, 4)
		self.minimButton:SetPos(buttonPos - 31 * 2, 4)

		if GetGlobalBool( "mapvote_comptest", false ) == true then	
			net.Start( "PSY_MapVoteCancel" )
			net.SendToServer()
			return
		end
		
		
		if xMapVoteConfig.GamemodesAndMapsHaveRatings then
			if ratingPanelCounter < 2 then
				if not IsValid(ratingPanel) then
					initRatingPanel() 
				end
				setStarImage()
				initStarFunctions()
			end
		end			
								
		for k, v in pairs(maps) do
			local button = vgui.Create("DButton", self.mapList)
			button:SetText("")
			button.ID = k
			button:SetTall(200)
			button:SetWide(200)
			
			if GamemodeVoteCompleted == false and xMapVoteConfig.DisplayGamemodeIcons then
				if v == getLocalization("randombutton") then
					button.Material = Material("materials/icons/mv_randomsmall.png")
				elseif v == getLocalization("extendbutton") or v == getLocalization("replaybutton") then
					button.Material = Material("materials/icons/mv_replaysmall.png")
				elseif getGamemodeThumbnail(v) == "materials/icons/gmod_logo.png" then
					local found = false
					for k, addonInfo in pairs(addons) do
						if string.find( addonInfo.title:lower() ,  v:lower() ) and string.find( addonInfo.tags:lower() , "gamemode" ) then
							local wsid = tonumber(addonInfo.wsid) 
							button.Material = Material("icon16/joystick.png")
							if iconcache[wsid] and file.Exists(iconcache[wsid], "GAME") then
								local iconMaterial = AddonMaterial(iconcache[wsid])
								button.Material = iconMaterial
								found = true
							else
								steamworks.FileInfo(addonInfo.wsid, function(result)
									steamworks.Download(result.previewid, true, function(cachePath)
										if cachePath ~= nil then
											button.Material = AddonMaterial(cachePath)
											iconcache[wsid] = cachePath
											saveToFiles(getGamemodeName(v), cachePath)
											found = true
										end
									end) 
								end)
							end
							break
						end
					end
					if not found then button.Material = Material("materials/icons/gmod_logo.png") end
				else
					local thumb = getGamemodeThumbnail(v)
					button.Material = Material(thumb)
				end

			elseif GamemodeVoteCompleted then
				if getMapThumbnail(v) then
					button.Material = Material(getMapThumbnail(v))
				else
					local found = false
					for k, addonInfo in ipairs(addons) do
						if string.find( addonInfo.title:lower() , v:lower() ) then
							
							local wsid = tonumber(addonInfo.wsid)
							if wsid == nil then return end
							if iconcache[wsid] and file.Exists(iconcache[wsid], "GAME") then
								local iconMaterial = AddonMaterial(iconcache[wsid])
								button.Material = iconMaterial
								found = true
							else
								steamworks.FileInfo(addonInfo.wsid, function(result)
									steamworks.Download(result.previewid, true, function(cachePath)
										if cachePath ~= nil then
											local iconMaterial = AddonMaterial(cachePath)
											button.Material = AddonMaterial(cachePath)
											iconcache[wsid] = cachePath
											saveToFiles(v, cachePath)
											found = true
										end
									end) 
								end)
							end
						end
					end
					if not found then button.Material = Material("materials/icons/gmod_logo.png")end
				end
			end

			local buttonLabel = vgui.Create("DLabel", button)
			buttonLabel:SetSize(button:GetWide(),button:GetTall()*0.1)
			buttonLabel:SetFont("PSY_VoteFont")
			buttonLabel:SetContentAlignment(5)
			buttonLabel:SetText(v)
			buttonLabel.Paint = function(self, w, h)
				local boxColor = Color(120, 120, 120, 200)
				local cornerRadius = 10
				draw.RoundedBox(cornerRadius, 0, 0, w, h, boxColor)
			end
			buttonLabel:SizeToContentsX()
			buttonLabel:SetPos((button:GetWide()-buttonLabel:GetWide()) / 2,button:GetTall()-30)

			local buttonDesc = vgui.Create("DLabel", button)
			buttonDesc:SetSize(button:GetWide(),button:GetTall())
			buttonDesc:SetFont("PSY_VoteFont")
			buttonDesc:SetWrap(true)

			local Paint = button.Paint
			button.Paint = function(self, w, h)
				if self.Material then
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(self.Material)
					surface.DrawTexturedRect(0, 0, w, h)
				end
				if self:IsHovered() then
					if not GamemodeVoteCompleted and GamemodesDesc[getGamemodeName(v)] ~= nil and GamemodesDesc[getGamemodeName(v)] ~= "nil" then
						buttonDesc:SetText(GamemodesDesc[getGamemodeName(v)])
						if xMapVoteConfig.Statistics then
							if mapvote_statistics_gamemode[getGamemodeName(v)] ~= nil then
								buttonDesc:SetText("Playcount: "..mapvote_statistics_gamemode[getGamemodeName(v)].."\n"..buttonDesc:GetText())
							else
								buttonDesc:SetText("Playcount: 0".."\n"..buttonDesc:GetText())
							end
						end
					elseif (xMapVoteConfig.Statistics) then
						if mapvote_statistics_map[v]~=nil then
							buttonDesc:SetText("Playcount: "..mapvote_statistics_map[v])
						else
							buttonDesc:SetText("Playcount: 0".."\n")
						end
					end
					buttonDesc:SetPaintBackgroundEnabled( true )
					buttonDesc:SetBGColor( Color(0, 0, 0, 220) )
				else
					buttonDesc:SetText("")
					buttonDesc:SetPaintBackgroundEnabled( false )
				end
				if self.bgColor then
					draw.RoundedBox(0, 0, 0, w, h, self.bgColor)
				end
				-- local col = Color(255, 255, 255, 10)
				-- if(button.bgColor) then
				-- 	col = button.bgColor
				-- end
				-- Paint(self, w, h)
				-- draw.RoundedBox(25, 0, 0, w, h, col)
			end
			
			local found = false
			if xMapVoteConfig.GamemodesAndMapsHaveRatings then
				if ratingPanelCounter < 2 then
					setStarImage()
					initStarFunctions()
				end
				if v != getLocalization("randombutton") and v != getLocalization("extendbutton") and v != getLocalization("replaybutton") then
					local voteStars = vgui.Create("DImage", button)
					voteStars:SetPos(button:GetWide()/2 - 50,0)
					voteStars:SetSize(100,20)
					if GamemodeVoteCompleted==false and v != getLocalization("randombutton") then
						voteStars:SetImage(getRatingImage(getRating(getGamemodeName(v))))
					else
						voteStars:SetImage(getRatingImage(getRating(v)))
					end
				end
			end
			

			button.DoClick = function()
				
				net.Start("PSY_MapVoteUpdate")
					net.WriteUInt(MapVote.UPDATE_VOTE, 3)
					net.WriteUInt(button.ID, 32)
				net.SendToServer()
			end
			
			if v == getLocalization("randombutton") or v == getLocalization("extendbutton") or v == getLocalization("replaybutton") then 
				buttonLabel:SetTextColor(Color( 137, 255, 19)) 
			else 
				buttonLabel:SetTextColor(color_white) 
				if ( xMapVoteConfig.Statistics and xMapVoteConfig.ColorUnplayedMapsGray ) then
					if GamemodeVoteCompleted then
						if mapvote_statistics_map[v]~=nil and mapvote_statistics_map[v] == 0 then
							buttonLabel:SetTextColor(Color(200, 200, 200, 255))
						end
					else
						if mapvote_statistics_gamemode[getGamemodeName(v)] ~= nil and mapvote_statistics_gamemode[getGamemodeName(v)] == 0  then
							buttonLabel:SetTextColor(Color(200, 200, 200, 255))
						end
					end
				end
			end
			button:SetContentAlignment(4)
			button:SetTextInset(8, 0)
			button:SetFont("PSY_VoteFont")
			button:SetPaintBackground( false )
			button.NumVotes = 0
			
			self.mapList:AddItem(button)

			button.OnMousePressed = function(pnl, keyCode) --Ping Functionality
				if keyCode == MOUSE_RIGHT then
					local x, y = gui.MousePos()
					sendPingToMapvote(x,y)
				elseif keyCode == MOUSE_LEFT then
					pnl:DoClick()
				end
			end
		end
		
	else
		if GetGlobalBool( "mapvote_comptest", false ) == true then	
			net.Start( "PSY_MapVoteCancel" )
			net.SendToServer()
			return
		end

		
		self.mapList:SetDrawBackground(false)
		self.mapList:SetSpacing(4)
		self.mapList:SetPadding(4)
		self.mapList:EnableHorizontal(true)
		self.mapList:EnableVerticalScrollbar()

		local xhoch = ScrH()*0.7
		local xbreit = ScrW()*0.6
		self.mapList:SetSize(1200 * calcScaling(),xhoch)
		self.mapList:SetPos((ScrW() - self.mapList:GetWide())/2, 80)

		
	
		if xMapVoteConfig.MapPreviews then
			local previewX = 512 * calcScaling()
			local previewY = 512 * calcScaling()
			
			previewImage = vgui.Create("DImage", self.Canvas)
			previewImage:SetSize( previewX, previewY )
		end

		if xMapVoteConfig.GamemodeDesc or xMapVoteConfig.Statistics then
			MapVoteInfoText = vgui.Create( "DLabel", self.Canvas )
			MapVoteInfoText:SetFont("DermaLarge")
			MapVoteInfoText:SetText( "" )
		end

		local buttonPos = self:GetWide() * 5/6
		
		self.closeButton:SetPos(buttonPos - 31 * 0, 4)
		self.maximButton:SetPos(buttonPos - 31 * 1, 4)
		self.minimButton:SetPos(buttonPos - 31 * 2, 4)
				
		for k, v in pairs(maps) do
			local button = vgui.Create("DButton", self.mapList)
			button:SetPaintBackground( false )
			button:SetTall(24)
			button:SetWide((575) * calcScaling())
			button.NumVotes = 0
			button.ID = k

			local found = false
			if GamemodeVoteCompleted == false and xMapVoteConfig.DisplayGamemodeIcons then
				local smallPreviewIcon = vgui.Create("DImage", button)
				button:SetText("     "..v)
				smallPreviewIcon:SetSize(24,24)
				if v == getLocalization("randombutton") then
					smallPreviewIcon:SetMaterial( "materials/icons/mv_randomsmall.png"  )
				elseif v == getLocalization("extendbutton") or v == getLocalization("replaybutton") then
					smallPreviewIcon:SetMaterial( "materials/icons/mv_replaysmall.png"  )
				elseif getGamemodeThumbnail(v) == "materials/icons/gmod_logo.png" then
					for k, addonInfo in pairs(addons) do
						if string.find( addonInfo.title:lower() ,  v:lower() ) and string.find( addonInfo.tags:lower() , "gamemode" ) then
							local wsid = tonumber(addonInfo.wsid) 
							smallPreviewIcon:SetMaterial( "icon16/joystick.png"  )
							steamworks.FileInfo(addonInfo.wsid, function(result)
								if file.Exists("cache/workshop/"..result.previewid..".cache", "GAME") then
									smallPreviewIcon:SetMaterial( AddonMaterial("cache/workshop/"..result.previewid..".cache") )
									saveToFiles(getGamemodeName(v), "cache/workshop/"..result.previewid..".cache")
									found = true
								else
									steamworks.Download(result.previewid, true, function(cachePath)
										if cachePath ~= nil then
											smallPreviewIcon:SetMaterial( AddonMaterial(cachePath) )
											saveToFiles(getGamemodeName(v), cachePath)
											found = true
										end
									end) 
								end
							end)
							break
						end
					end
					if not found then smallPreviewIcon:SetMaterial( "materials/icons/gmod_logo.png"  ) end
				else
					smallPreviewIcon:SetMaterial( getGamemodeThumbnail(v) )
				end
			else
				button:SetText(v)
			end
			
			if xMapVoteConfig.GamemodesAndMapsHaveRatings then
				if ratingPanelCounter < 2 then
					if not IsValid(ratingPanel) then
						initRatingPanel() 
					end
					setStarImage()
					initStarFunctions()
				end
				if v != getLocalization("randombutton") and v != getLocalization("extendbutton") and v != getLocalization("replaybutton") then
					local voteStars = vgui.Create("DImage", button)
					voteStars:SetPos(button:GetWide() - 100,0)
					voteStars:SetSize(100,20)

					if GamemodeVoteCompleted==false then
						voteStars:SetImage(getRatingImage(getRating(getGamemodeName(v))))
					else
						voteStars:SetImage(getRatingImage(getRating(v)))
					end
				end
			end
			
			button.DoClick = function()
				if IsValid(MapVoteInfoText) then MapVoteInfoText:SetText("") end
				if GamemodeVoteCompleted then
					if xMapVoteConfig.MapPreviews then --show map preview on click
						if getMapThumbnail(v) then
							previewImage:SetMaterial(getMapThumbnail(v))
						else
							local found = false
							for k, addonInfo in ipairs(addons) do
								if string.find( addonInfo.title:lower() , v:lower() ) then
									local wsid = tonumber(addonInfo.wsid)
									if wsid == nil then return end
									if iconcache[wsid] and file.Exists(iconcache[wsid], "GAME") then
										local iconMaterial = AddonMaterial(iconcache[wsid])
										previewImage:SetMaterial(iconMaterial)
										found = true
									else
										steamworks.FileInfo(addonInfo.wsid, function(result)
											steamworks.Download(result.previewid, true, function(cachePath)
												if cachePath ~= nil then
													local iconMaterial = AddonMaterial(cachePath)
													previewImage:SetMaterial(iconMaterial)
													iconcache[wsid] = cachePath
													saveToFiles(v, cachePath)
													found = true
												end
											end) 
										end)
									end
								end
							end
							if not found then previewImage:SetMaterial( "materials/icons/gmod_logo.png"  ) end
						end
					end
				else
					if GamemodesDesc~=nil and xMapVoteConfig.GamemodeDesc then
						if GamemodesDesc[getGamemodeName(v)]~=nil then
							local t = GamemodesDesc[getGamemodeName(v)]
							if t == "nil" then t = "" end
							MapVoteInfoText:SetText(t.."\n")
						end
					end
				end
				
				if ( xMapVoteConfig.Statistics ) then
					if GamemodeVoteCompleted then
						if mapvote_statistics_map[v]~=nil then
							MapVoteInfoText:SetText("Playcount: "..mapvote_statistics_map[v].."\n"..MapVoteInfoText:GetText())
						else 
							MapVoteInfoText:SetText("Playcount: 0".."\n"..MapVoteInfoText:GetText())
						end
					else
						if mapvote_statistics_gamemode[getGamemodeName(v)] ~= nil then
							MapVoteInfoText:SetText("Playcount: "..mapvote_statistics_gamemode[getGamemodeName(v)].."\n"..MapVoteInfoText:GetText())
						else
							MapVoteInfoText:SetText("Playcount: 0".."\n"..MapVoteInfoText:GetText())
						end
					end
					MapVoteInfoText:SizeToContents()
					if IsValid(previewImage) then
						MapVoteInfoText:SetY( previewImage:GetY() )
					else
						MapVoteInfoText:SetY( self.mapList:GetTall() + 150 )
					end
					MapVoteInfoText:CenterHorizontal()
				end
				
				
				

				net.Start("PSY_MapVoteUpdate")
					net.WriteUInt(MapVote.UPDATE_VOTE, 3)
					net.WriteUInt(button.ID, 32)
				net.SendToServer()
			end
			
			do
				local Paint = button.Paint
				button.Paint = function(s, w, h)
					local col = Color(255, 255, 255, 10)
						
					if(button.bgColor) then
						col = button.bgColor
					end
						
					draw.RoundedBox(4, 0, 0, w, h, col)
					Paint(s, w, h)
				end
			end
			
			if v == getLocalization("randombutton") or v == getLocalization("extendbutton") or v == getLocalization("replaybutton") then 
				button:SetTextColor(Color( 137, 255, 19)) 
			else 
				button:SetTextColor(color_white) 
				if ( xMapVoteConfig.Statistics and xMapVoteConfig.ColorUnplayedMapsGray ) then
					if GamemodeVoteCompleted then
						if mapvote_statistics_map[v] and mapvote_statistics_map[v] == 0 then
							button:SetTextColor(Color(200, 200, 200, 255))
						end
					else
						if mapvote_statistics_gamemode[getGamemodeName(v)] and mapvote_statistics_gamemode[getGamemodeName(v)] == 0  then
							button:SetTextColor(Color(200, 200, 200, 255))
						end
					end
				end
			end
			button:SetContentAlignment(4)
			button:SetTextInset(8, 0)
			button:SetFont("PSY_VoteFont")
			
			self.mapList:AddItem(button)
			button.OnMousePressed = function(pnl, keyCode)
				if keyCode == MOUSE_RIGHT then
					local x, y = gui.MousePos()
					sendPingToMapvote(x,y)
				elseif keyCode == MOUSE_LEFT then
					pnl:DoClick()
				end
			end
		end

		local xlimit = ScrH() * 9/16
		self.mapList:SizeToContentsX()
		self.mapList:SizeToContentsY()
		if self.mapList:GetTall() >= xlimit then
			self.mapList:SetTall(xlimit)
		end
		
		if IsValid(previewImage) then
			previewImage:SetPos((ScrW() - previewImage:GetWide())/2, self.mapList:GetTall() + previewImage:GetTall()/5)
			if IsValid(MapVoteInfoText) then
				MapVoteInfoText:SizeToContents()
				if IsValid(previewImage) then
					MapVoteInfoText:SetY( previewImage:GetY() )
				else
					MapVoteInfoText:SetY( self.mapList:GetTall() + 150 )
				end
			end
		end
		
		
	end
	self.mapList.OnMousePressed = function(pnl, keyCode)
		if keyCode == MOUSE_RIGHT then
			local x, y = gui.MousePos()
			sendPingToMapvote(x,y)
		end
	end

	do
		-- if 	   LocalPlayer():Nick() == "PietSmiet" 
		-- 	or LocalPlayer():Nick() == "Husarenchris" 
		-- 	or LocalPlayer():Nick() == "Sep" 
		-- 	or LocalPlayer():Nick() == "Jul3s" 
		-- 	or LocalPlayer():Nick() == "Svenson"
		-- 	or LocalPlayer():Nick() == "Jay brrrrr"
		-- 	or LocalPlayer():Nick() == "Br4mm3n"
		-- 	--or LocalPlayer():Nick() == "Psychotrickser"
		-- then
		
		local logo21 = vgui.Create("DImage", self.Canvas)
		if file.Exists("download/data/mapvote/logo.png", "GAME") then
			local logoMaterial = Material("download/data/mapvote/logo.png")
			logo21:SetMaterial(logoMaterial)
		elseif LocalPlayer():Nick() == "PietSmiet" 
			or LocalPlayer():Nick() == "Husarenchris" 
			or LocalPlayer():Nick() == "Sep" 
			or LocalPlayer():Nick() == "Jul3s" 
			or LocalPlayer():Nick() == "Svenson"
			or LocalPlayer():Nick() == "Jay brrrrr"
			or LocalPlayer():Nick() == "Br4mm3n"
			--or LocalPlayer():Nick() == "Psychotrickser"
		then
			local logoMaterial = Material("materials/icons/pcontroller.png")
			logo21:SetMaterial(logoMaterial)
		end
		
		logo21:SetSize(200,140)

		local logoText21 = vgui.Create("DLabel", self.Canvas)
		logoText21:SetFont("PSY_VoteFont")
		if LocalPlayer():Nick() == "PietSmiet" 
			or LocalPlayer():Nick() == "Husarenchris" 
			or LocalPlayer():Nick() == "Sep" 
			or LocalPlayer():Nick() == "Jul3s" 
			or LocalPlayer():Nick() == "Svenson"
			or LocalPlayer():Nick() == "Jay brrrrr"
			or LocalPlayer():Nick() == "Br4mm3n" 
			--or LocalPlayer():Nick() == "Psychotrickser"
			then
			logoText21:SetText('"Also habt ihrs geschafft,\nTTT ist ein wiederkehrendes\nFormat!" - Brammen 01.01.2025')
		else
			logoText21:SetText(xMapVoteConfig["advertisementText"] or "")
		end
		logoText21:SetSize(300,300)

		local x21 = ScrW() - logoText21:GetWide()
		local y21 = ScrH()/16
		logoText21:SetPos(x21, y21+30)
		logo21:SetPos(x21, y21)
		-- end

		local changeLayoutPanel = vgui.Create("DPanel", self.Canvas)
		changeLayoutPanel:SetDrawBackground(false)

		local changeLayoutButton = vgui.Create("DButton", changeLayoutPanel)
		changeLayoutButton:SetText("")
		changeLayoutButton:SetMaterial("icon16/arrow_refresh.png")
		changeLayoutButton:SetSize(25,25)
		changeLayoutButton.DoClick = function()
			GetConVar("mapvote_LayoutMenu"):SetBool( !(GetConVar("mapvote_LayoutMenu"):GetBool()) )
			for k,v in pairs(MapVote.Panel.Voters) do
				v:Remove()
			end
			self.mapList:Clear()
			table.Empty(self.Voters)
			table.Empty(MapVote.Votes)
			self.closeButton:Remove()
			self.maximButton:Remove()
			self.minimButton:Remove()
			net.Receive("PSY_MapVoteUpdateReady", function()
				net.Start("PSY_MapVoteUpdateConfirmation")
				net.SendToServer()
			end)
			
			net.Start("MapVote_requestVoterCache")
			net.SendToServer()

			MapVote.Panel:SetMaps(maps)
		end

		local changeLayoutLabel = vgui.Create("DLabel", changeLayoutPanel)
		changeLayoutLabel:SetText("Switch Layout")
		changeLayoutLabel:SetFont("PSY_RatingFont")
		changeLayoutLabel:SizeToContents()
		changeLayoutLabel:SetX(changeLayoutButton:GetX() + 30, changeLayoutButton:GetY())

		changeLayoutPanel:SetWide(changeLayoutButton:GetWide() + changeLayoutLabel:GetWide() + 10)
		changeLayoutPanel:SetTall(changeLayoutButton:GetTall()+10)
		changeLayoutPanel:SetPos(ScrW() - changeLayoutPanel:GetWide() - 10,ScrH() - 100)

		local votingModePanel = vgui.Create("DPanel", self.Canvas)
		votingModePanel:SetDrawBackground(false)
		votingModePanel:SetPos(2,ScrH())

		local votingModeLabel = vgui.Create("DLabel", votingModePanel)
		votingModeLabel:SetText("Current Voting Mode: " .. xMapVoteConfig.voteWinnerMode)
		votingModeLabel:SetFont("PSY_RatingFont")
		votingModeLabel:SetColor(Color(255, 165, 0))
		votingModeLabel:SizeToContents()

		votingModePanel:SetWide(votingModeLabel:GetWide() + 150)
		votingModePanel:SetTall(votingModeLabel:GetTall() + 5)
		votingModePanel:SetPos(2,ScrH() - votingModeLabel:GetTall())
		if not langPanel then
			langPanel = true
			local languagePanel = vgui.Create("DPanel", self.Canvas)
			languagePanel:SetDrawBackground(false)
			languagePanel:SetPos(2,ScrH()-100)
			local languageButton = vgui.Create("DImageButton", languagePanel)
			languageButton:SetSize(80,45)
			languageButton:SetText(GetConVar("mapvote_language"):GetString())
			languageButton:SetImage("materials/icons/"..GetConVar("mapvote_language"):GetString()..".png")

			languagePanel:SetWide(languageButton:GetWide() + 5)
			languagePanel:SetTall(languageButton:GetTall() + 5)
			local languageSelectorFrameOpen = false
			languageButton.DoClick = function()
				if languageSelectorFrameOpen then return end
				local languageSelectorFrame = vgui.Create("DFrame", self.Canvas)
				languageSelectorFrameOpen = true
				languageSelectorFrame.Paint = function(self, w, h)
					draw.RoundedBox(0, 0, 0, w, h, Color(125, 125, 125, 0))
				end
				languageSelectorFrame:SetTitle("Select Language")
				languageSelectorFrame:SetPos(2,ScrH() - 360)
				function languageSelectorFrame:OnClose()
					languageSelectorFrameOpen = false
				end
				local languageSelectorLayout = vgui.Create("DIconLayout", languageSelectorFrame)
				languageSelectorLayout:Dock(FILL)
				languageSelectorLayout:SetSpaceY( 5 )
				languageSelectorLayout:SetSpaceX( 5 )

				for k,v in pairs(localizationDefault) do
					local langButton = languageSelectorLayout:Add( "DImageButton" )
					langButton:SetMaterial("materials/icons/"..k..".png")
					langButton:SetSize(80,45)
					langButton:SetTooltip(k)
					langButton.DoClick = function()
						GetConVar("mapvote_language"):SetString(k)
						languageButton:SetText(GetConVar("mapvote_language"):GetString())
						languageButton:SetImage("materials/icons/"..GetConVar("mapvote_language"):GetString()..".png")
						languageSelectorFrame:Close()
					end
				end
				languageSelectorFrame:SetSize(280,240)
			end
		end
	end
end

function getRating(x)

	if receivedRatings[x] then
		if receivedRatings[x]["count"] >= 1 then
			return (receivedRatings[x]["rating"]/receivedRatings[x]["count"])
		else
			return 0
		end
	else 
		return 0
	end
end

function getRatingImage(x)

	if x >= 9.5 then
		return "materials/icons/10stars.png"
	elseif x >= 8.5 then
		return "materials/icons/9stars.png"
	elseif x >= 7.5 then
		return "materials/icons/8stars.png"
	elseif x >= 6.5 then
		return "materials/icons/7stars.png"
	elseif x >= 5.5 then
		return "materials/icons/6stars.png"
	elseif x >= 4.5 then
		return "materials/icons/5stars.png"
	elseif x >= 3.5 then
		return "materials/icons/4stars.png"
	elseif x >= 2.5 then
		return "materials/icons/3stars.png"
	elseif x >= 1.5 then
		return "materials/icons/2stars.png"
	elseif x >= 0.5 then
		return "materials/icons/1stars.png"
	else
		return "materials/icons/0stars.png"
	end
	-- else
	-- 	return "materials/icons/transparent.png"
	-- end
end

function PANEL:GetMapButton(id)
    for k, v in pairs(self.mapList:GetItems()) do
        if(v.ID == id) then return v end
    end
    
    return false
end

function PANEL:Paint()
    --Derma_DrawBackgroundBlur(self)
    
    local CenterY = ScrH() / 2
    local CenterX = ScrW() / 2
    
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, ScrW(), ScrH())
end

function initRatingPanel()
	local starhoch = 50 * calcScaling()
	local starbreit = starhoch/2 * calcScaling()
	local starDistance = 5
	local starY = 50
	local starX = 0
	
	ratingPanel = vgui.Create( "DPanel", MapvoteCanvas )
	ratingPanel:SetSize(400 * calcScaling(), starY * 3)
	if calcScaling()>1 then ratingPanel:SetSize(500 * calcScaling(), starY * 3) end
	ratingPanel:SetPaintBackground( false )
	
	question = vgui.Create( "DLabel", ratingPanel )
	question:SetPos( 0, 0 )
	question:SetFont("PSY_RatingFont")
	--question:SetTextColor(Color( 102, 204, 0)) 
	question:SetTextColor(color_white) 
	if not xMapVoteConfig.GamemodeVote then ratingPanelCounter = 1 end
	if ratingPanelCounter == 1 then 
		question:SetText( getLocalization("ratingpanel2") )
	elseif ratingPanelCounter < 1 then
		question:SetText( getLocalization("ratingpanel1") )
	end
	question:SizeToContents()

	star1 = vgui.Create("DImageButton", ratingPanel)
	star1:SetPos(starX+starbreit*0,starY)
	star1:SetSize( starbreit, starhoch )

	star2 = vgui.Create("DImageButton", ratingPanel)
	star2:SetPos(starX+starbreit*1,starY)
	star2:SetSize( starbreit, starhoch )
	
	star3 = vgui.Create("DImageButton", ratingPanel)
	star3:SetPos(starX+starbreit*2,starY)
	star3:SetSize( starbreit, starhoch )
	
	star4 = vgui.Create("DImageButton", ratingPanel)
	star4:SetPos(starX+starbreit*3,starY)
	star4:SetSize( starbreit, starhoch )
	
	star5 = vgui.Create("DImageButton", ratingPanel)
	star5:SetPos(starX+starbreit*4,starY)
	star5:SetSize( starbreit, starhoch )
	
	star6 = vgui.Create("DImageButton", ratingPanel)
	star6:SetPos(starX+starbreit*5,starY)
	star6:SetSize( starbreit, starhoch )
	
	star7 = vgui.Create("DImageButton", ratingPanel)
	star7:SetPos(starX+starbreit*6,starY)
	star7:SetSize( starbreit, starhoch )
	
	star8 = vgui.Create("DImageButton", ratingPanel)
	star8:SetPos(starX+starbreit*7,starY)
	star8:SetSize( starbreit, starhoch )
	
	star9 = vgui.Create("DImageButton", ratingPanel)
	star9:SetPos(starX+starbreit*8,starY)
	star9:SetSize( starbreit, starhoch )
	
	star10 = vgui.Create("DImageButton", ratingPanel)
	star10:SetPos(starX+starbreit*9,starY)
	star10:SetSize( starbreit, starhoch )
	
	sendButton = vgui.Create("DImageButton", ratingPanel)
	sendButton:SetPos(star10:GetX()+starbreit+5,star10:GetY())
	sendButton:SetSize( 50*calcScaling(), 50*calcScaling() )
	ratingPanel:SizeToContents()
	ratingPanel:SetSize(ratingPanel:GetWide()-60,ratingPanel:GetTall())
	ratingPanel:SetPos(ScrW() - ratingPanel:GetWide(),ScrH() * 3/8)
end

function getStarImage(starName)
	return "materials/icons/"..starName..".png"
end

function setStarImage()
	star1:SetImage(getStarImage("starhalfemptyleft"))
	star2:SetImage(getStarImage("starhalfemptyright"))
	star3:SetImage(getStarImage("starhalfemptyleft"))
	star4:SetImage(getStarImage("starhalfemptyright"))
	star5:SetImage(getStarImage("starhalfemptyleft"))
	star6:SetImage(getStarImage("starhalfemptyright"))
	star7:SetImage(getStarImage("starhalfemptyleft"))
	star8:SetImage(getStarImage("starhalfemptyright"))
	star9:SetImage(getStarImage("starhalfemptyleft"))
	star10:SetImage(getStarImage("starhalfemptyright"))
	sendButton:SetImage(getStarImage("sendbutton"))
end

function initStarFunctions()
	star1.DoClick = function()
		rating = 1
		paintStars(1)
	end
	star2.DoClick = function()
		rating = 2
		paintStars(2)
	end
	star3.DoClick = function()
		rating = 3
		paintStars(3)
	end
	star4.DoClick = function()
		rating = 4
		paintStars(4)
	end
	star5.DoClick = function()
		rating = 5
		paintStars(5)
	end
	star6.DoClick = function()
		rating = 6
		paintStars(6)
	end
	star7.DoClick = function()
		rating = 7
		paintStars(7)
	end
	star8.DoClick = function()
		rating = 8
		paintStars(8)
	end
	star9.DoClick = function()
		rating = 9
		paintStars(9)
	end
	star10.DoClick = function()
		rating = 10
		paintStars(10)
	end
	
	sendButton.DoClick = function()
		if ratingPanelCounter == 0 then
			ratingPanelCounter = ratingPanelCounter + 1
			rating1 = rating
			setStarImage()
			question:SetText( getLocalization("ratingpanel2") )
			surface.PlaySound( "hl1/fvox/blip.wav" )
			question:SizeToContents()
		elseif ratingPanelCounter == 1 then
			ratingPanelCounter = 2
			rating2 = rating
			sendRatingResults(rating1,rating2)
			surface.PlaySound( "hl1/fvox/blip.wav" )
			notifyServerWide("Player "..LocalPlayer():Nick().." has rated this map!")
			ratingPanel:Remove()
		end
	end
end

function sendRatingResults(xrating1,xrating2)
	if xrating1==nil then xrating1 = 0 end
	if xrating2==nil then xrating2 = 0 end
	net.Start( "PSY_MapVoteRatingResults" )
		net.WriteInt(xrating1,5)
		net.WriteInt(xrating2,5)
	net.SendToServer()
end

-- net.Receive( "PSY_MapVoteSendRatingsTable", function( )
-- 	local compressedLength = net.ReadUInt(32)
--     local compressedString = net.ReadData(compressedLength)
--     local jsonString = util.Decompress(compressedString)
--     receivedRatings = util.JSONToTable(jsonString)
-- end )
net.Receive( "PSY_MapVoteSendRatingsTable", function( )
    receivedRatings = net.ReadTable()
end )

function paintStars(starNumber)
	if starNumber >= 1 then
		star1:SetImage(getStarImage("starhalfleft"))
	end
	
	if starNumber >= 2 then
		star2:SetImage(getStarImage("starhalfright"))
	else
		star2:SetImage(getStarImage("starhalfemptyright"))
	end
	
	if starNumber >= 3 then
		star3:SetImage(getStarImage("starhalfleft"))
	else
		star3:SetImage(getStarImage("starhalfemptyleft"))
	end
	
	if starNumber >= 4 then
		star4:SetImage(getStarImage("starhalfright"))
	else
		star4:SetImage(getStarImage("starhalfemptyright"))
	end
	
	if starNumber >= 5 then
		star5:SetImage(getStarImage("starhalfleft"))
	else
		star5:SetImage(getStarImage("starhalfemptyleft"))
	end
	
	if starNumber >= 6 then
		star6:SetImage(getStarImage("starhalfright"))
	else
		star6:SetImage(getStarImage("starhalfemptyright"))
	end
	
	if starNumber >= 7 then
		star7:SetImage(getStarImage("starhalfleft"))
	else
		star7:SetImage(getStarImage("starhalfemptyleft"))
	end
	
	if starNumber >= 8 then
		star8:SetImage(getStarImage("starhalfright"))
	else
		star8:SetImage(getStarImage("starhalfemptyright"))
	end
	
	if starNumber >= 9 then
		star9:SetImage(getStarImage("starhalfleft"))
	else
		star9:SetImage(getStarImage("starhalfemptyleft"))
	end
	
	if starNumber >= 10 then
		star10:SetImage(getStarImage("starhalfright"))
	else
		star10:SetImage(getStarImage("starhalfemptyright"))
	end
		
	
end

function getGamemodeThumbnail(name)
	if gamemodeThumbnailCache[name] then 
		return gamemodeThumbnailCache[name]
	elseif name == getLocalization("randombutton") then
		gamemodeThumbnailCache[name] = "materials/icons/transparentsmall.png"
	elseif name == getLocalization("extendbutton") or name == getLocalization("replaybutton") then
		gamemodeThumbnailCache[name] = "materials/icons/transparentsmall.png"
	elseif file.Exists( "materials/icons/" .. getGamemodeName(name) .. ".png", "GAME") then
		gamemodeThumbnailCache[name] = "materials/icons/" .. getGamemodeName(name) .. ".png"
	elseif file.Exists( "gamemodes/" .. getGamemodeName(name) .. "/" .. "icon24.png", "GAME") then --Previews for Gamemodes
		gamemodeThumbnailCache[name] = "gamemodes/" .. getGamemodeName(name) .. "/" .. "icon24.png"
	elseif file.Exists( "maps/thumbs/" .. getGamemodeName(name) .. ".png", "DATA") then
		gamemodeThumbnailCache[name] = "data/maps/thumbs/" .. getGamemodeName(name) .. ".png"
	elseif iconcache[getGamemodeName(name)] then
		gamemodeThumbnailCache[name] = AddonMaterial(iconcache[getGamemodeName(name)])
	else
		gamemodeThumbnailCache[name] =  "materials/icons/gmod_logo.png"
    end
	return gamemodeThumbnailCache[name]
end

function getMapThumbnail(name)
	if mapThumbnailCache[name] then 
		return mapThumbnailCache[name] 
	elseif name == getLocalization("randombutton") then
		mapThumbnailCache[name] = "materials/icons/mv_random.png"
	elseif name == getLocalization("extendbutton") or name == getLocalization("replaybutton") then
		mapThumbnailCache[name] = "materials/icons/mv_replay.png"
	
	else 
		if table.IsEmpty(xMapPreviewHierarchy) then table.CopyFromTo(defaultMapPreviewHierarchy, xMapPreviewHierarchy) end
		for k,v in ipairs(xMapPreviewHierarchy) do
			local directory = v.directory..name..".png"
			if file.Exists(directory, v.path) then
				if v.path == "DATA" then directory = "data/"..directory end
				mapThumbnailCache[name] = directory
				break
			end
		end
		return mapThumbnailCache[name]
	end
end

function getGamemodeName( name )
	if GamemodesList[name] ~= nil then
		return GamemodesList[name]
	else 
		return name
	end
end

local function getGamemodeTitle(name)
	if table.HasValue(GamemodesList, name) then
		return table.KeyFromValue( GamemodesList, name )
	else
		return name
	end
end

function PANEL:Flash(id)
    self:SetVisible(true)

    local bar = self:GetMapButton(id)
    
    if(IsValid(bar)) then
        timer.Simple( 0.0, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "hl1/fvox/blip.wav" ) end )
        timer.Simple( 0.2, function() bar.bgColor = nil end )
        timer.Simple( 0.4, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "hl1/fvox/blip.wav" ) end )
        timer.Simple( 0.6, function() bar.bgColor = nil end )
        timer.Simple( 0.8, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "hl1/fvox/blip.wav" ) end )
        timer.Simple( 1.0, function() bar.bgColor = Color( 0, 255, 200 ) end )
    end
end

derma.DefineControl("VoteScreen", "", PANEL, "DPanel")

MapVote.PingCount = MapVote.PingCount or 0

net.Receive("MapVote_UpdatePing", function()
    local x = net.ReadInt(32)
    local y = net.ReadInt(32)
    local steamID = net.ReadString()
    local x1 = net.ReadInt(16)
    local y1 = net.ReadInt(16)
	x = ScrW() / x1 * x
	y = ScrH() / y1 * y

    MapVote.PingCount = MapVote.PingCount + 1
    local pingId = "PingFadeOutTimer" .. tostring(MapVote.PingCount)
    MapVote.PingActive = true
	MapVote.PingStartTime = CurTime()
	MapVote.PingX = x
	MapVote.PingY = y
	
    local pingLabel = vgui.Create("DLabel", MapVote.Panel.Canvas)
    pingLabel:SetPos(x, y)
    pingLabel:SetText(steamID)
    pingLabel:SizeToContents()
    pingLabel:SetTextColor(Color(255, 255, 255, 255))
    pingLabel:SetExpensiveShadow(1, Color(0, 0, 0, 200))

    local function fadeOut()
        local alpha = 255
        return function()
            alpha = alpha - 255 * FrameTime()
            if alpha <= 0 then
                pingLabel:Remove()
                timer.Remove(pingId)
            else
				if IsValid(pingLabel) then
                	pingLabel:SetTextColor(Color(255, 255, 255, alpha))
				end
            end
        end
    end

    timer.Simple(1, function()
        if IsValid(pingLabel) then
            timer.Create(pingId, 0.01, 0, fadeOut())
        end
    end)
end)

hook.Add("HUDPaint", "DrawPingEffect", function()
    if MapVote.PingActive then
        local alpha = math.max(0, 255 - (CurTime() - MapVote.PingStartTime) * 255)
        local size = (CurTime() - MapVote.PingStartTime) * 200
        surface.SetDrawColor(255, 255, 255, alpha)
        surface.DrawCircle(MapVote.PingX, MapVote.PingY, size, 255, 255, 255, alpha)
        if alpha == 0 then
            MapVote.PingActive = false
        end
    end
end)

net.Receive("PSY_mapvote_offerGamemodeTimeLimit", function()
	local timelimit = net.ReadInt(15)
	timer.Create("GamemodeTimeLimitDecrease", 1, 0, function()
		timelimit = timelimit - 1
		if timelimit <= 0 then timer.Remove("GamemodeTimeLimitDecrease") hook.Remove("HUDPaint", "DisplayGamemodeTimeLimit") end
	end)
	hook.Add("HUDPaint", "DisplayGamemodeTimeLimit", function()
		local pos = {["x"] = ScrW()/2, ["y"] = ScrH() / 8}
		local boxWidth = 200
		local boxHeight = 80
		local boxX = pos.x - boxWidth / 2
		local boxY = pos.y - boxHeight / 2
		draw.RoundedBox(8, boxX, boxY, boxWidth, boxHeight, Color(137,163,232))
		draw.SimpleText(timelimit.." seconds left", "DermaLarge", pos.x, pos.y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)
end)

local function uncompressString(xString)
	local jsonString = util.Decompress(xString)
	local xTable = util.JSONToTable(jsonString)
	return xTable
end

local function compressTable(xfile)
	local jsonString = util.TableToJSON(xfile)
	local compressedString = util.Compress(jsonString)
	return compressedString
end
---------------------------------------------------------------------------MapVote Config GUI-------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function openAssignMapsPanel() -------------------------------- Assign Maps and Prefixes to Gamemode Panel------------------------------------------------------------------------------
	local panel = vgui.Create("DFrame")
	panel:MakePopup()
	panel:SetSize(ScrW() * 0.75, ScrH() * 0.75)
	panel:Center()
	panel:SetTitle("")
	panel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(125, 125, 125, 0))
	end

	surface.CreateFont( "ButtonFont", {
		font = "DermaLarge", 
		size = 22,
		weight = 900,
	} )
	local outerFilterPanel = vgui.Create("DPanel", panel)
	outerFilterPanel:SetWide(200)
	outerFilterPanel:SetPos(0,30)
	outerFilterPanel:StretchToParent(nil,nil,nil,100)
	outerFilterPanel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(125, 125, 125, 232))
	end
	
	local innerFilterPanel = vgui.Create("DPanel", outerFilterPanel)
	innerFilterPanel:StretchToParent(10,10,10,10)
	innerFilterPanel.Paint = function(self, w, h)
		draw.RoundedBox(14, 0, 0, w, h, Color(255, 255, 255))
	end

	local searchTextFieldLabel = vgui.Create("DLabel", innerFilterPanel)
	searchTextFieldLabel:SetSize(innerFilterPanel:GetWide(), 40)
	searchTextFieldLabel:SetText(" Search")
	searchTextFieldLabel:SetTextColor(Color(78,149,230))
	searchTextFieldLabel:SetFont("DermaLarge")

	local searchTextField = vgui.Create("DTextEntry", innerFilterPanel)
	searchTextField:SetPos(0,30)
	searchTextField:StretchToParent(5,40,5,nil)
	searchTextField:SetPlaceholderText("Search Maps...")
	searchTextField:SetEditable( true )
	searchTextField.OnEnter = function( self )
		chat.AddText( self:GetValue() )
	end

	local selectAllButton = vgui.Create("DButton", innerFilterPanel)
	selectAllButton:SetPos(0,searchTextField:GetY() + 28)
	selectAllButton:StretchToParent(5,nil,5,nil)
	selectAllButton:SetTall(40)
	selectAllButton:SetText("Select All")
	selectAllButton:SetFontInternal("ButtonFont")
	selectAllButton:SetTextColor(Color(255,255,255))
	selectAllButton.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, Color(128, 197, 240))
	end

	local unSelectAllButton = vgui.Create("DButton", innerFilterPanel)
	unSelectAllButton:SetPos(0,selectAllButton:GetY() + selectAllButton:GetTall() + 2)
	unSelectAllButton:StretchToParent(5,nil,5,nil)
	unSelectAllButton:SetTall(selectAllButton:GetTall())
	unSelectAllButton:SetText("Unselect All")
	unSelectAllButton:SetFontInternal("ButtonFont")
	unSelectAllButton:SetTextColor(Color(255,255,255))
	unSelectAllButton.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, Color(128, 197, 240))
	end

	local assignToGMButton = vgui.Create("DButton", innerFilterPanel)
	assignToGMButton:SetPos(0,unSelectAllButton:GetY() + unSelectAllButton:GetTall() + 2)
	assignToGMButton:StretchToParent(5,nil,5,nil)
	assignToGMButton:SetTall(selectAllButton:GetTall())
	assignToGMButton:SetText("Assign to...")
	assignToGMButton:SetFontInternal("ButtonFont")
	assignToGMButton:SetTextColor(Color(255,255,255))
	assignToGMButton.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, Color(128, 197, 240))
	end
	
	local comboGMMenu = vgui.Create("DComboBox", innerFilterPanel) 
	comboGMMenu:SetSize(200,20)
	comboGMMenu:StretchToParent(5,nil,5,nil)
	comboGMMenu:SetPos(assignToGMButton:GetX(), assignToGMButton:GetY() + 42)
	comboGMMenu:SetVisible(false)

	local unassignButton = vgui.Create("DButton", innerFilterPanel) 
	unassignButton:StretchToParent(5,nil,5,nil)
	unassignButton:SetTall(assignToGMButton:GetTall())
	unassignButton:SetPos(comboGMMenu:GetX(), comboGMMenu:GetY() +25)
	unassignButton:SetText("Unassign")
	unassignButton:SetFontInternal("ButtonFont")
	unassignButton:SetTextColor(Color(255,255,255))
	unassignButton.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, Color(128, 197, 240))
	end

	outerFilterPanel:SetTall(panel:GetTall() - 50)
	innerFilterPanel:SetTall(outerFilterPanel:GetTall() - 40)

	local dprop = vgui.Create("DPropertySheet", panel)
	dprop:StretchToParent(outerFilterPanel:GetWide(),0,33,0)
	dprop:DockMargin(10, 25, 10, 10)
	dprop.Paint = function(self, w, h)
		draw.RoundedBox(20, 0, 0, w, h, Color(125, 125, 125, 232))
	end
	
	selectAllButton.DoClick = function()
		selectAllButton.Paint = function(self, w, h)
			draw.RoundedBox(6, 0, 0, w, h, Color(206, 236, 255))
		end
		timer.Simple(0.1, function() 
			selectAllButton.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, Color(128, 197, 240))
			end
		end)

		if not table.IsEmpty(dprop:GetActiveTab():GetPanel():GetItems()) then
			for _,child in ipairs(dprop:GetActiveTab():GetPanel():GetItems()) do
				local xchild = child:GetChildren()[1]:GetChildren()[2]
				if not xchild:GetChecked() and child:IsVisible() then
					xchild:SetChecked(true)
				end
			end
		end
	end

	unSelectAllButton.DoClick = function()
		unSelectAllButton.Paint = function(self, w, h)
			draw.RoundedBox(6, 0, 0, w, h, Color(206, 236, 255))
		end
		timer.Simple(0.1, function() 
			unSelectAllButton.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, Color(128, 197, 240))
			end
		end)

		if not table.IsEmpty(dprop:GetActiveTab():GetPanel():GetItems()) then
			for _,child in ipairs(dprop:GetActiveTab():GetPanel():GetItems()) do
				local xchild = child:GetChildren()[1]:GetChildren()[2]

				if xchild:GetChecked() and child:IsVisible() then
					xchild:SetChecked(false)
				end
			end
		end
	end

	searchTextField.OnChange = function(self)
		local searchText = searchTextField:GetText():lower()

		for _, xchild in ipairs(dprop:GetActiveTab():GetPanel():GetItems()) do
			local child = xchild:GetChildren()[2]

			if IsValid(child) and child:GetName() == "DLabel" then
				if string.find(child:GetText():lower(), searchText) then
					xchild:SetVisible(true)
				else
					xchild:SetVisible(false)
				end
			end
		end
		dprop:GetActiveTab():GetPanel():GetCanvas():InvalidateLayout(true)
	end

	
	local function addContentToPanel(pnl, title, amount, blacklisted )
		local tabName = dprop:GetActiveTab():GetText()
		local mapPanel = vgui.Create("DPanel", pnl)
		mapPanel:SetSize(200,240)
		mapPanel:SetBackgroundColor(Color(0, 0, 0, 0))
		if amount and tabName != "All Maps" then mapPanel:SetTooltip("Rightclick to show matching maps") end

		local mapImage = vgui.Create("DImageButton", mapPanel)
		mapImage:SetSize(200,200)
		mapImage:SetPos(0,0)
		mapImage:SetMaterial(getMapThumbnail(title) or "icon16/map.png")
		if title == "nil" or title == "" then mapImage:SetMaterial("icon16/delete.png") end

		local mapImageCheckbox = vgui.Create("DCheckBox", mapImage)
		mapImageCheckbox:SetSize(25,25)
		mapImageCheckbox:SetPos(mapImage:GetWide() - mapImageCheckbox:GetWide(),0)
		mapImage.DoClick = function()
			mapImageCheckbox:Toggle()
		end
		if blacklisted then
			local mapImageCross = vgui.Create("DImage", mapImage)
			mapImageCross:SetSize(50,50)
			mapImageCross:SetPos(0,0)
			mapImageCross:SetMaterial("icon16/cross.png")
			mapPanel:SetTooltip("Is ULX blacklisted")
		end

		local mapLabel = vgui.Create("DLabel", mapPanel)
		mapLabel:SetText(title)
		if title == "nil" or title == "" then mapLabel:SetText("nil") end

		mapLabel:SetSize(200,40)
		mapLabel:SetPos(0,mapPanel:GetTall() - mapLabel:GetTall())
		mapLabel:SetTextColor(Color(0, 0, 0))
		mapLabel:SetContentAlignment(5)
		mapLabel.Paint = function(self, w, h)
			draw.RoundedBox(8, 0, 0, w, h, Color(134, 191, 255))
		end

		if tabName != "All Maps" and tabName != "ULX Blacklist" then 
			mapImage.DoRightClick = function()
				pnl:Clear()
				net.Start("PSY_MapVote_requestMatchingMapsForPrefix")
					net.WriteString(mapLabel:GetText())
					net.WriteString(tabName)
				net.SendToServer()
			end
		end

		if amount then
			local countLabel = vgui.Create("DLabel", mapLabel)
			countLabel:SetText(amount.." matching Maps")
			countLabel:SetSize(200,40)
			countLabel:SetPos(0,14)
			countLabel:SetTextColor(Color(68, 68, 68))
			countLabel:SetContentAlignment(5)
			countLabel.Paint = function(self, w, h)
				draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 0))
			end
		end
		pnl:AddItem(mapPanel)
	end

	local function requestAllMapsTab()
		net.Start("PSY_MapVote_requestAllMapsForAssignMaps")
		net.SendToServer()
	end
	local TabToPnlList = {}

	local scrollP = vgui.Create("DPanelList", dprop) --all maps tab
	TabToPnlList["All Maps"] = scrollP
	scrollP:SetSpacing(4)
	scrollP:SetPadding(4)
	scrollP:EnableHorizontal(true)
	scrollP:EnableVerticalScrollbar()
	local icon = "icon16/world.png"
	local sheet = dprop:AddSheet("All Maps", scrollP, icon)
	dprop:GetItems()[1].Tab:GetChildren()[1]:SetSize(16,16)
	
	requestAllMapsTab()

	net.Receive("PSY_MapVote_offerAllMapsForAssignMaps", function(len, ply)
		local compressedLength = net.ReadUInt(32)
		local compressedString = net.ReadData(compressedLength)
		local fileContent = uncompressString(compressedString)

		local blackListTable = net.ReadTable()
		TabToPnlList["All Maps"]:Clear()
		
		for x,y in pairs(fileContent) do
			local map = y:gsub("%.bsp$", "")
			addContentToPanel( scrollP, map, nil, table.HasValue(blackListTable, map) )
		end
	end)


	net.Start("PSY_MapVote_requestGamemodesForAssignMaps")
	net.SendToServer()

	net.Receive("PSY_MapVote_offerGamemodesForAssignMaps", function(len, ply)
		local installedGamemodes = net.ReadTable()
		table.insert(installedGamemodes, 1, {["name"] = "ULX Blacklist", ["title"] = "ULX Blacklist", ["workshopid"] = nil})

		for k, v in ipairs(installedGamemodes) do --gamemode specific tab
			local scrollP = vgui.Create("DPanelList", dprop)
			TabToPnlList[v.name] = scrollP
			scrollP:SetSpacing(4)
			scrollP:SetPadding(4)
			scrollP:EnableHorizontal(true)
			scrollP:EnableVerticalScrollbar()
	
			local icon = getGamemodeThumbnail(v.name, v.workshopid)
			if v.name == "ULX Blacklist" then icon = "icon16/cross.png" end
			local sheet = dprop:AddSheet(v.title, scrollP, icon)
			
			dprop:GetItems()[k + 1].Tab:GetChildren()[1]:SetSize(16,16)
		end
	end)

	local function assignMapsToGamemode_request(tabName)
		local tabNameSend = getGamemodeName(tabName)

		net.Start("PSY_MapVote_requestGamemodesForAssignMaps_fileContent")
			net.WriteString(tabNameSend)
		net.SendToServer()
	end

	function dprop:OnActiveTabChanged( old, new )
		local xtext = tostring(new:GetText())
		if xtext == "All Maps" then
			requestAllMapsTab()
		else
			assignMapsToGamemode_request(xtext)
		end
		
	end

	net.Receive("PSY_MapVote_offerGamemodesForAssignMaps_fileContent", function(len, ply)
		local tabName = net.ReadString()
		if tabName == "ULX Blacklist" then
			local ulxBlackList = net.ReadTable()
			TabToPnlList[tabName]:Clear()

			for k,v in ipairs(ulxBlackList) do
				addContentToPanel(TabToPnlList[tabName], v, nil, true)
			end
		else
			local gamemodeMapList = net.ReadTable()
			local mapCount = net.ReadTable()
			local blackListTable = net.ReadTable() or {}

			TabToPnlList[tabName]:Clear()

			for k,v in ipairs(gamemodeMapList) do
				addContentToPanel(TabToPnlList[tabName], v, mapCount[v] or 0, table.HasValue(blackListTable, v))
			end
		end
	end)

	local function sendNewAssignedMaps(gamemodeName, mapsList)
		local compressedTable = compressTable(mapsList)

		net.Start("PSY_MapVote_assignMapsToGamemode")
			net.WriteString(gamemodeName)
			net.WriteUInt(#compressedTable, 32)
			net.WriteData(compressedTable, #compressedTable)
		net.SendToServer()

	end

	local function sendUnassignedMaps(gamemodeName, mapsList)
		local compressedTable = compressTable(mapsList)

		net.Start("PSY_MapVote_unassignMapsFromGamemode")
			net.WriteString(gamemodeName)
			net.WriteUInt(#compressedTable, 32)
			net.WriteData(compressedTable, #compressedTable)
		net.SendToServer()
	end

	assignToGMButton.DoClick = function()
		local toAssignMaps = {}
		comboGMMenu:Clear()
		
		assignToGMButton.Paint = function(self, w, h)
			draw.RoundedBox(6, 0, 0, w, h, Color(206, 236, 255))
		end

		timer.Simple(0.1, function() 
			assignToGMButton.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, Color(128, 197, 240))
			end
		end)

		for _,child in ipairs(dprop:GetActiveTab():GetPanel():GetItems()) do
			local xchild = child:GetChildren()[1]:GetChildren()[2] --DCheckBox
			if xchild:GetChecked() then
				table.insert(toAssignMaps, child:GetChildren()[2]:GetText() )
			end
		end

		if not table.IsEmpty(dprop:GetActiveTab():GetPanel():GetItems()) and not table.IsEmpty(toAssignMaps) then
			comboGMMenu:SetVisible(true)
			comboGMMenu:SetSortItems( false )
			for k,v in ipairs(dprop:GetItems()) do
				if not (v.Name == "All Maps") then
					comboGMMenu:AddChoice( v.Name, nil, nil, getGamemodeThumbnail(getGamemodeName(v.Name)) )
				end
			end
			timer.Simple(0, function() 
				comboGMMenu:OpenMenu()
				comboGMMenu:SetMouseInputEnabled(true)
				comboGMMenu:SetKeyboardInputEnabled(false)
			end)
			function comboGMMenu:OnSelect( index, gmode, data )
				self:SetValue( "" )
				sendNewAssignedMaps(getGamemodeName(gmode), toAssignMaps)
				comboGMMenu:SetVisible(false)
			end
		end
		
	end

	unassignButton.DoClick = function()
		if dprop:GetActiveTab():GetText() == "All Maps" then return end
		local toUnassignMaps = {}
		
		unassignButton.Paint = function(self, w, h)
			draw.RoundedBox(6, 0, 0, w, h, Color(206, 236, 255))
		end

		timer.Simple(0.1, function() 
			unassignButton.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, Color(128, 197, 240))
			end
		end)

		for _,child in ipairs(dprop:GetActiveTab():GetPanel():GetItems()) do
			local xchild = child:GetChildren()[1]:GetChildren()[2] --DCheckBox
			if xchild:GetChecked() and child:GetChildren()[2]:GetText() ~= "nil" then
				table.insert(toUnassignMaps, child:GetChildren()[2]:GetText() )
			end
		end

		if not table.IsEmpty(dprop:GetActiveTab():GetPanel():GetItems()) and not table.IsEmpty(toUnassignMaps) then
			sendUnassignedMaps(getGamemodeName(dprop:GetActiveTab():GetText()), toUnassignMaps)
			dprop:GetActiveTab():GetPanel():Clear() 
			
			timer.Simple(0, function() dprop:OnActiveTabChanged(dprop:GetActiveTab(), dprop:GetActiveTab()) end)
		end
		
	end
	


	local function sendMapFromText(tabName, text)
		local inputTable = string.Explode("\n", text)
		net.Start("PSY_MapVote_addMapFromText")
			net.WriteString(tabName)
			net.WriteTable(inputTable)
		net.SendToServer()
	end


	local addFromText = vgui.Create("DButton", innerFilterPanel) 
	addFromText:StretchToParent(5,nil,5,nil)
	addFromText:SetTall(unassignButton:GetTall())
	addFromText:SetPos(unassignButton:GetX(), unassignButton:GetY() + unassignButton:GetTall() + 2)
	addFromText:SetText("Manual Add")
	addFromText:SetFontInternal("ButtonFont")
	addFromText:SetTextColor(Color(255,255,255))
	addFromText.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, Color(128, 197, 240))
	end
	addFromText.DoClick = function()
		local frame = vgui.Create("DFrame",panel)
		frame:SetSize(300, 200)
		frame:Center()
		frame:SetTitle("Enter Prefix or Map Name")
		frame:SetVisible(true)
		frame:SetDraggable(true)
		frame:MakePopup()

		local textEntry = vgui.Create("DTextEntry", frame)
		textEntry:SetMultiline(true)
		textEntry:SetPos(0, 40)
		textEntry:StretchToParent(5,50,5,27)
		textEntry:SetPlaceholderText( "Can be prefix e.g.\n ttt_ or map name e.g. ttt_minecraft_b5" )

		local gmCombBox = vgui.Create("DComboBox", frame)
		gmCombBox:SetSize(textEntry:GetWide(),20)
		gmCombBox:SetPos(5, textEntry:GetY() - 20)
		gmCombBox:SetValue("Select Gamemode...")
		for k,v in ipairs(dprop:GetItems()) do
			if not (v.Name == "All Maps") then
				gmCombBox:AddChoice( v.Name, nil, nil, getGamemodeThumbnail(getGamemodeName(v.Name)) )
			end
		end
		gmCombBox:SetSortItems( false )

		local submitButton = vgui.Create("DButton", frame)
		submitButton:Dock(BOTTOM)
		submitButton:SetText("Submit")

		submitButton.DoClick = function()
			local enteredText = textEntry:GetValue()
			if gmCombBox:GetValue() == "Select Gamemode..." or gmCombBox:GetValue() == "Please choose a Gamemode!" then 
				gmCombBox:SetValue("Please choose a Gamemode!")
				return
			else
				sendMapFromText(getGamemodeName(gmCombBox:GetValue()),enteredText)
				frame:Close()
			end
		end
	end

	local refreshTabButton = vgui.Create("DButton", innerFilterPanel) 
	refreshTabButton:StretchToParent(5,nil,5,nil)
	refreshTabButton:SetTall(addFromText:GetTall())
	refreshTabButton:SetPos(addFromText:GetX(), addFromText:GetY() + addFromText:GetTall() + 2)
	refreshTabButton:SetText("Refresh Tab")
	refreshTabButton:SetFontInternal("ButtonFont")
	refreshTabButton:SetTextColor(Color(255,255,255))
	refreshTabButton.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, Color(128, 197, 240))
	end
	refreshTabButton.DoClick = function()
		dprop:OnActiveTabChanged(dprop:GetActiveTab(), dprop:GetActiveTab())
	end


	net.Receive("PSY_MapVote_offerMatchingMapsForPrefix", function(len, ply)
		local tabName = net.ReadString()
		local xtable = net.ReadTable()
		local blackListTable = net.ReadTable() or {}

		for k,v in ipairs(xtable) do
			addContentToPanel( TabToPnlList[getGamemodeName(tabName)], v, nil, table.HasValue(blackListTable, v) )
		end
	end)
end


---------------------------------------------------------------------------GENERAL MAPVOTE MENU GUI-------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


local function MapVote_CreateGUI()

	local function LoadGamemodeNameList()
		net.Start("PSY_MapVote_LoadGamemodeNameList")
		net.SendToServer()
	end

	local function LoadConfig21()
		net.Start("PSY_MapVote_LoadConfig")
		net.SendToServer()
	end

	local function SaveConfig21(xtext)
		local fileContent = xtext
		net.Start("PSY_MapVote_SaveConfig")
			net.WriteTable(fileContent)
		net.SendToServer()
	end
	
	local function LoadGameModes21()
		net.Start("PSY_MapVote_LoadGameModes")
		net.SendToServer()
	end

	local function LoadEnabledGamemodes21()
		net.Start("PSY_MapVote_LoadEnabledGameModes")
		net.SendToServer()
	end
	
	local function SaveEnabledGamemodes21(xtable)
		local fileContent = xtable
		net.Start("PSY_MapVote_SaveEnabledGameModes")
			net.WriteTable(fileContent)
		net.SendToServer()
	end
	
	
	local function LoadPlayerCount21()
		net.Start("PSY_MapVote_LoadPlayerCount")
		net.SendToServer()
	end
	
	local function SavePlayerCount21(xtext)
		local fileContent = xtext
		net.Start("PSY_MapVote_SavePlayerCount")
			net.WriteTable(fileContent)
		net.SendToServer()
	end
	
	local function LoadGamemodesDesc21()
		net.Start("PSY_MapVote_LoadGamemodesDesc")
		net.SendToServer()
	end

	local function SaveGamemodesDesc21(xtext)
		local fileContent = xtext
		net.Start("PSY_MapVote_SaveGamemodesDesc")
			net.WriteTable(fileContent)
		net.SendToServer()
	end

	local function LoadMapPreviewHierarchy21()
		net.Start("PSY_MapVote_LoadMapPreviewHierarchy")
		net.SendToServer()
	end

	local function SaveMapPreviewHierarchy21(xtext)
		local fileContent = xtext
		net.Start("PSY_MapVote_SaveMapPreviewHierarchy")
			net.WriteTable(fileContent)
		net.SendToServer()
	end
	
	local function LoadRatingResults21()
		net.Start("PSY_MapVote_LoadRatingResults")
		net.SendToServer()
	end
	
	local function SaveRatingResults21(xtext)
		local fileContent = compressTable(xtext)
		net.Start("PSY_MapVote_SaveRatingResults")
			net.WriteUInt(#fileContent, 32)
			net.WriteData(fileContent, #fileContent)
		net.SendToServer()
	end
	
	local function LoadStatistics21()
		net.Start("PSY_MapVote_LoadStatistics")
		net.SendToServer()
	end
	
	local function SaveStatistics21(xtext)
		local fileContent = compressTable(xtext)

		net.Start("PSY_MapVote_SaveStatistics")
			net.WriteUInt(#fileContent, 32)
			net.WriteData(fileContent, #fileContent)
		net.SendToServer()
	end
	
	local function LoadRecentMaps21()
		net.Start("PSY_MapVote_LoadRecentMaps")
		net.SendToServer()
	end
	
	local function SaveRecentMaps21(xtext)
		local fileContent = xtext
		net.Start("PSY_MapVote_SaveRecentMaps")
			net.WriteTable(fileContent)
		net.SendToServer()
	end

	local function LoadCSSMaps()
		net.Start("PSY_MapVote_LoadCSSMaps")
		net.SendToServer()
	end

	local function SaveCSSMaps(xtext)
		local fileContent = xtext
		net.Start("PSY_MapVote_SaveCSSMaps")
			net.WriteTable(fileContent)
		net.SendToServer()
	end

	local function LoadConVars()
		LoadGameModes21()
		net.Start("mapvote_requestGUIConVars")
		net.SendToServer()
	end

	local function LoadInstalledAddons()
		net.Start("PSY_MapVote_LoadInstalledAddons")
		net.SendToServer()
	end

	local function LoadInstalledMaps()
		net.Start("PSY_MapVote_LoadInstalledMaps")
		net.SendToServer()
	end

	local function LoadConCommands()
		net.Start("PSY_MapVote_LoadConCommands")
		net.SendToServer()
	end

	local function LoadUsefulAddons()
		net.Start("PSY_MapVote_LoadUsefulAddons")
		net.SendToServer()
	end

	local function LoadCleanupData()
		net.Start("PSY_MapVote_LoadCleanupData")
		net.SendToServer()
	end

	local frame21 = vgui.Create("DFrame")
	--frame21:SetSize(800, 600)
	frame21:SetSize(ScrW() * 0.5, ScrH() * 0.51)
	frame21:Center()
	--frame21:SetTitle("Config Editor")
	frame21:SetTitle("MapVote Config Editor")
	frame21:SetVisible(true)
	frame21:SetDraggable(true)
	frame21:ShowCloseButton(true)
	frame21:SetDeleteOnClose( true )
	frame21:MakePopup()
	frame21.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, Color(116, 149, 172))
	end

	local tabPanel21 = vgui.Create("DPropertySheet", frame21)
	tabPanel21:SetPos(5, 30)
	tabPanel21:SetSize(frame21:GetWide() - 10, frame21:GetTall() - 35)
	LoadGamemodeNameList()

	local functiontable = {
		["Gamemode Prefixes"] = LoadGameModes21,
		["Gamemodes Enabler"] = LoadEnabledGamemodes21,
		["PlayerCountDependingGameModes"] = LoadPlayerCount21,
		["GamemodesDesc"] = LoadGamemodesDesc21,
		["MapPreviewHierarchy"] = LoadMapPreviewHierarchy21,
		["RatingResults"] = LoadRatingResults21,
		["Statistics"] = LoadStatistics21,
		["RecentMaps"] = LoadRecentMaps21,
		["CSSMaps"] = LoadCSSMaps,
		["ConVars"] = LoadConVars,
		["UsefulAddons"] = LoadUsefulAddons,
		["ConCommands"] = LoadConCommands,
		["InstalledAddons"] = LoadInstalledAddons,
		["InstalledMaps"] = LoadInstalledMaps
	}

	local tooltips = {
		["Config"] = "Change Map Vote Addon Configuration",
		["Gamemode Prefixes"] = "Change Map Prefixes for Gamemodes",
		["Gamemodes Enabler"] = "Enable or Disable Gamemodes during Gamemode Votes",
		["PlayerCountDependingGameModes"] = "Change Player Limits for a Gamemode to appear in Gamemode Votes",
		["GamemodesDesc"] = "Change Gamemode Descriptions shown during a Gamemode Vote",
		["MapPreviewHierarchy"] = "Change the order in which the client's game looks through files to find suitable map thumbnails for each map",
		["RatingResults"] = "Change Rating and Rating Count for Maps and Gamemodes",
		["Statistics"] = "Change Playcount Statistics of Maps and Gamemodes",
		["RecentMaps"] = "Change recently played Maps (only applies with Config>MapCooldown)",
		["CSSMaps"] = "Change Maps that contain CSS content",
		["ConVars"] = "Set round limits before a MapVote is started",
		["UsefulAddons"] = "Here are some useful addons for your server",
		["InstalledAddons"] = "A List of All installed Addons on the Server",
		["InstalledMaps"] = "A List of All installed Maps on the Server",
		["Cleanup"] = "Automatically delete unused Maps and Gamemodes from save files"
		
	}

	function tabPanel21:OnActiveTabChanged( old, new )
		local xtext = tostring(new:GetText())
		if functiontable[xtext]!=nil then
			functiontable[xtext]()
		end
	end

	
	
	-- Config Tab
	local configPanel21 = vgui.Create("DScrollPanel", tabPanel21)
	configPanel21.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255))
	end

	--Color(147, 190, 219, 255)
	
	net.Receive("PSY_MapVote_SendConfig", function()
		configPanel21:Clear()
		configPanel21:Dock(FILL)
		local fileContent = net.ReadTable()
		local configTooltips = {
			["DisplayGamemodeIcons"] = "Shows Gamemode Icons during a Gamemode Vote",
			["GamemodeDesc"] = "Shows a short Gamemode Description when clicking on or hovering over a gamemode",
			["ReplayMapButton"] = "Allows to vote to replay the current Gamemode and Map",
			["GamemodesAndMapsHaveRatings"] = "Shows Ratings for Gamemodes and Maps",
			["Statistics"] = "Shows a Playcount Statistic for Gamemodes and Maps",
			["GamemodeVote"] = "Enable or disable Gamemode Vote to only vote for Maps",
			["MapPreviews"] = "Shows Map Preview Images when clicking on a map",
			["PlayercountDependingGamemodes"] = "Removes/Adds Gamemodes from Gamemode Vote if there's more/less players than specified",
			["AdminsHaveMoreVotePower"] = "Gives Admins two Votes at once instead of one",
			["PlayersCanPingDuringVote"] = "Allow Players to send out small Pings during Votes",
			["ColorUnplayedMapsGray"] = "Colors unplayed Gamemode/Map Names in a darker grey",
			["MapCooldown"] = "Cooldown for Maps before reappearing in Map Vote (applies MapsBeforeRevote)",
			["FilterCSSMaps"] = "Removes Maps that contain CSS content from Map Votes",
			["MapsBeforeRevote"] = "If EnableCooldown is true, specifies how many rounds to play before a played Map reappears in Map Vote",
			["MapvoteTimeLimit"] = "How long a Map Vote lasts in seconds",
			["SortMapsBy"] = "What to sort Gamemodes and Maps by",
			["SandboxCountdown"] = "How long to switch from Sandbox to voted Gamemode/Map in seconds",
			["RTVPlayerPercent"] = "What Percentage of players have to type !rtv to start a Vote",
			["StartMapvoteCooldown"] = "How long in seconds before there can be a new Vote after one was unsuccessful",
			["MapLimit"] = "How many selectable Maps to show during a Map Vote",
			["GamemodeTimeLimit"] = "How long a Gamemode Vote lasts in seconds",
			["RTVCooldownAfterMapChange"] = "How long in seconds after a Map Change before players can use !rtv",
			["voteWinnerMode"] = "Set the method to determine the mapvote winner",
			["RTVMinimumPlayersRequired"] = "How many players need to be on the server in order for the RTV feature to be enabled",
			["advertisementText"] = "Display a text in the top right of the mapvote screen",
			["CooldownBetweenRTVs"] = "Prevent people spamming !rtv and !unrtv by setting a cooldown (in seconds)",
			["MapSelectionMode"] = "How should the maps for the mapvote be selected if there's not enough space to fit them all?"
		}
		local tempval
		local function AddElementToConfigPanel(panel, key, value, tooltip)
			if isbool(value) then
				local checkbox = vgui.Create("DCheckBoxLabel", panel)
				checkbox:Dock(TOP)
				checkbox:SetSize(300, 20)
				checkbox:SetText(key)
				checkbox:SetTextColor(Color(0,0,0))
				checkbox:SetChecked(value)
				checkbox:SetTooltip(tooltip)
				checkbox:DockMargin( 10, 5, 40, 0 )
				function checkbox:OnChange( xvalue )
					fileContent[key] = xvalue
					SaveConfig21(fileContent)
				end
			elseif isnumber(value) then
				local slider = vgui.Create("DNumSlider", panel)
				slider:Dock(TOP)
				slider.Label:SetTextColor(Color(0, 0, 0))
				slider:SetText(key)
				slider:SetMinMax(0, 100)
				slider:SetDecimals(0)
				slider:SetValue(math.Round( tonumber(value), 0 ))
				slider:SetTooltip(tooltip)
				slider:DockMargin( 10, 5, 40, 0 )
				function slider:OnValueChanged( xvalue )	
					local roundedValue = math.Round( xvalue, 0 )
					slider:SetValue(roundedValue)
					tempval = roundedValue
					if not timer.Exists("isEditingTimer") then
						timer.Create( "isEditingTimer", 0.5, 0, function() 
							if not slider:IsEditing() then
								fileContent[key] = tempval
								SaveConfig21(fileContent)
								timer.Remove("isEditingTimer")
							end
						end )
					end
				end
			elseif key == "advertisementText" then
				local textLabel = vgui.Create("DLabel", panel)
				textLabel:Dock(TOP)
				textLabel:SetText(key)
				textLabel:SetTextColor(Color(0, 0, 0))
				textLabel:DockMargin(10, 5, 40, 0)

				local textEntry = vgui.Create("DTextEntry", panel)
				textEntry:Dock(TOP)
				textEntry:SetValue(value)
				textEntry:SetTooltip(tooltip)
				textEntry:DockMargin(10, 5, 40, 0)

				textEntry.OnLoseFocus = function( self )
					fileContent[key] = self:GetValue()
					SaveConfig21(fileContent)
				end
			elseif isstring(value) then
				local dropdownLabel = vgui.Create("DLabel", panel)
				dropdownLabel:Dock(TOP)
				dropdownLabel:SetText(key)
				dropdownLabel:SetTextColor(Color(0, 0, 0))
				dropdownLabel:DockMargin( 10, 5, 40, 0 )

				local dropdown = vgui.Create("DComboBox", panel)
				dropdown:Dock(TOP)
				local choices = {}
				if key == "SortMapsBy" then
					choices = {"name", "rating", "random", "playcount"}
				elseif key == "Language" then
					choices = table.GetKeys( LanguageCode )
				elseif key == "voteWinnerMode" then
					choices = {"mostVotesWins","leastVotesWins","randomFromAllVoted","weightedByAmountOfVotes"}
				elseif key == "MapSelectionMode" then
					choices = {"random","bestRated","leastPlayed","50/50 bestRated & leastPlayed"}
				end
				for _, v in ipairs(choices) do
					dropdown:AddChoice(v)
				end
				dropdown:SetValue(value)
				dropdown:SetTooltip(tooltip)
				dropdown:DockMargin( 10, 5, 40, 0 )
				function dropdown:OnSelect( index, text, data )
					fileContent[key] = text
					SaveConfig21(fileContent)
				end
			end
		end

		local boolElements = {}
		local numElements = {}
		local textElements = {}
	
		for i, text in pairs(fileContent) do
			if isbool(text) then
				table.insert(boolElements, {i, text})
			elseif isnumber(text) then
				table.insert(numElements, {i, text})
			elseif isstring(text) then
				table.insert(textElements, {i, text})
			end
		end
	
		table.sort(boolElements, function(a, b) return a[1] < b[1] end)
		table.sort(numElements, function(a, b) return a[1] < b[1] end)
		table.sort(textElements, function(a, b) return a[1] < b[1] end)
	
		for _, element in ipairs(boolElements) do
			AddElementToConfigPanel(configPanel21, element[1], element[2], configTooltips[element[1]])
		end
		for _, element in ipairs(numElements) do
			AddElementToConfigPanel(configPanel21, element[1], element[2], configTooltips[element[1]])
		end
		for _, element in ipairs(textElements) do
			AddElementToConfigPanel(configPanel21, element[1], element[2], configTooltips[element[1]])
		end
	end)
	
	tabPanel21:AddSheet("Config", configPanel21, "icon16/wrench_orange.png")
	LoadConfig21()


	-- GameMode Prefixes Tab
	local gameModesPanel21 = vgui.Create("DPanel", tabPanel21)
	gameModesPanel21:SetBackgroundColor(Color(240, 240, 240))

	net.Receive("PSY_MapVote_SendGameModes", function()
		gameModesPanel21:Clear()
		local fileContent = net.ReadTable()
		
		local gameModesPrefixList = vgui.Create("DListView", gameModesPanel21)
		gameModesPrefixList:Dock(FILL)
		gameModesPrefixList:AddColumn("Gamemode"):SetFixedWidth(160)
		gameModesPrefixList:AddColumn("Map Prefixes")
		--gameModesPrefixList:SetSize(500,500)
		for k,v in pairs(fileContent) do
			gameModesPrefixList:AddLine(getGamemodeTitle(k),util.TableToJSON(v)):SetTooltip(k)
		end
		gameModesPrefixList:SortByColumn( 1 )

		local assignMapsToGamemodeButton = vgui.Create("DButton", gameModesPanel21)
		assignMapsToGamemodeButton:SetText("Assign Maps and Prefixes to Gamemodes")
		assignMapsToGamemodeButton:SetSize(100, 30)
		assignMapsToGamemodeButton:Dock(BOTTOM)
		assignMapsToGamemodeButton.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(202, 232, 253))
		end
		
		assignMapsToGamemodeButton.DoClick = function()
			frame21:Remove()
			openAssignMapsPanel()
		end
	end)

	tabPanel21:AddSheet("Gamemode Prefixes", gameModesPanel21, "icon16/joystick.png")

	-- Gamemode Enabler Tab
	local gameModesEnablerPanel21 = vgui.Create("DPanel", tabPanel21)
	gameModesEnablerPanel21:SetBackgroundColor(Color(240, 240, 240))

	net.Receive("PSY_MapVote_SendEnabledGameModes", function()
		gameModesEnablerPanel21:Clear()
		local fileContent = net.ReadTable()
		
		local gameModesEnablerPanelList = vgui.Create("DScrollPanel", gameModesEnablerPanel21)
		gameModesEnablerPanelList:Dock(FILL)

		for gamemodeName, status in pairs(fileContent) do
			local itemPanel = vgui.Create("DPanel", gameModesEnablerPanelList)
			itemPanel:SetTall(30)
			itemPanel:Dock(TOP)
			itemPanel:DockMargin(0, 0, 0, 5) 
			
			local label = vgui.Create("DLabel", itemPanel)
			label:SetText(getGamemodeTitle(gamemodeName))
			label:Dock(LEFT)
			label:DockMargin(5, 0, 0, 0) 
			label:SetTextColor(Color(0, 0, 0))
			label:SetFont("PSY_GUIFont")
			label:SizeToContentsX()

			local checkbox = vgui.Create("DCheckBox", itemPanel)
			checkbox:Dock(RIGHT)
			checkbox:DockMargin(0, 0, 5, 0)
			if status == "enabled" then 
				checkbox:SetChecked(true)
			else
				checkbox:SetChecked(false)
			end
			checkbox.DoClick = function()
				checkbox:Toggle()
				if checkbox:GetChecked() then 
					fileContent[gamemodeName] = "enabled"
				else
					fileContent[gamemodeName] = "disabled"
				end
			end
			checkbox:SetSize(32,13)
		end

		local saveGameModesEnabledButton = vgui.Create("DButton", gameModesEnablerPanel21)
		saveGameModesEnabledButton:SetText("Save")
		saveGameModesEnabledButton:SetSize(100, 30)
		saveGameModesEnabledButton:Dock(BOTTOM)
		saveGameModesEnabledButton.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(148, 205, 243))
		end
		saveGameModesEnabledButton.DoClick = function()
			SaveEnabledGamemodes21(fileContent)
		end
	end)

	tabPanel21:AddSheet("Gamemodes Enabler", gameModesEnablerPanel21, "icon16/joystick.png")
	

	-- PlayerCountDependingGameModes Tab
	local playerCountPanel = vgui.Create("DPanel", tabPanel21)
	playerCountPanel:SetBackgroundColor(Color(240, 240, 240))

	net.Receive("PSY_MapVote_SendPlayerCount", function()
		playerCountPanel:Clear()
		local fileContent = net.ReadTable()
		playerCountPanel:SetSize(500,500)
		
		local playerCountList = vgui.Create("DListView", playerCountPanel)
		playerCountList:Dock(FILL)
		--playerCountList:SetSize(500,500)
		playerCountList:AddColumn("Gamemode")
		playerCountList:AddColumn("Min Players")
		playerCountList:AddColumn("Max Players")
		for k,v in pairs(fileContent) do
			playerCountList:AddLine(getGamemodeTitle(k), v.min, v.max)
		end
		playerCountList:SortByColumn( 1 )
		function playerCountList:DoDoubleClick(lineID, line)
			local currentItem = self:GetLine(lineID)
			local xgamemode = getGamemodeName(currentItem:GetColumnText(1))
			local minPlayers = currentItem:GetColumnText(2)
			local maxPlayers = currentItem:GetColumnText(3)
		
			local frame = vgui.Create("DFrame")
			frame:SetSize(200, 150)
			frame:SetTitle("Set Min and Max Players")
			frame:Center()
			frame:MakePopup()
		
			local minLabel = vgui.Create("DLabel", frame)
			minLabel:SetPos(10, 30)
			minLabel:SetText("Min Players:")
		
			local minTextEntry = vgui.Create("DTextEntry", frame)
			minTextEntry:SetPos(100, 30)
			minTextEntry:SetSize(80, 20)
			minTextEntry:SetText(minPlayers)
		
			local maxLabel = vgui.Create("DLabel", frame)
			maxLabel:SetPos(10, 60)
			maxLabel:SetText("Max Players:")
		
			local maxTextEntry = vgui.Create("DTextEntry", frame)
			maxTextEntry:SetPos(100, 60)
			maxTextEntry:SetSize(80, 20)
			maxTextEntry:SetText(maxPlayers)
		
			local confirmButton = vgui.Create("DButton", frame)
			confirmButton:SetPos(60, 100)
			confirmButton:SetSize(80, 30)
			confirmButton:SetText("Confirm")
			confirmButton.DoClick = function()
				local newMinPlayers = tonumber(minTextEntry:GetText())
				local newMaxPlayers = tonumber(maxTextEntry:GetText())
		
				if newMinPlayers and newMaxPlayers then
					currentItem:SetColumnText(2, newMinPlayers)
					currentItem:SetColumnText(3, newMaxPlayers)
					fileContent[xgamemode].min = newMinPlayers
					fileContent[xgamemode].max = newMaxPlayers
					frame:Close()
				else
					Derma_Message("Please insert valid values", "Error", "OK")
				end
			end
		end
		local savePlayerCountButton21 = vgui.Create("DButton", playerCountPanel)
		savePlayerCountButton21:SetText("Save")
		savePlayerCountButton21:SetSize(100, 30)
		savePlayerCountButton21:Dock(BOTTOM)
		savePlayerCountButton21.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(148, 205, 243))
		end
		savePlayerCountButton21.DoClick = function()
			SavePlayerCount21(fileContent)
		end
	end)
	
	
	tabPanel21:AddSheet("PlayerCountDependingGameModes", playerCountPanel, "icon16/tag.png")
	
	-- GamemodesDesc Tab
	local gamemodesDescPanel21 = vgui.Create("DPanel", tabPanel21)
	gamemodesDescPanel21:SetBackgroundColor(Color(240, 240, 240))

	net.Receive("PSY_MapVote_SendGamemodesDesc", function()
		gamemodesDescPanel21:Clear()
		local fileContent = net.ReadTable()
		local gamemodeDescList = vgui.Create("DComboBox", gamemodesDescPanel21)
		gamemodeDescList:Dock(TOP)
		for k,v in pairs(fileContent) do
			gamemodeDescList:AddChoice(getGamemodeTitle(k))
		end

		local gamemodesDescText = vgui.Create("DTextEntry", gamemodesDescPanel21)
		gamemodesDescText:SetMultiline(true)
		gamemodesDescText:Dock(FILL)
		gamemodesDescText:SetFont("PSY_ConfigMenu")

		function gamemodeDescList:OnSelect( index, text, data )
			gamemodesDescText:SetText(fileContent[getGamemodeName(text)])
		end

		function gamemodesDescText:OnChange()
			fileContent[getGamemodeName(gamemodeDescList:GetSelected())] = gamemodesDescText:GetText()
		end
		gamemodeDescList:ChooseOptionID(1)
		local saveGamemodesDescButton21 = vgui.Create("DButton", gamemodesDescPanel21)
		saveGamemodesDescButton21:SetText("Save")
		saveGamemodesDescButton21:SetSize(100, 30)
		saveGamemodesDescButton21:Dock(BOTTOM)
		saveGamemodesDescButton21.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(148, 205, 243))
		end
		saveGamemodesDescButton21.DoClick = function()
			SaveGamemodesDesc21(fileContent)
		end
	end)

	
	tabPanel21:AddSheet("GamemodesDesc", gamemodesDescPanel21, "icon16/style.png")

	-- Map Preview Hierarchy Tab
	local function OpenTwoInputRequest(title, message, default1, default2, onConfirm)
		local frame = vgui.Create("DFrame")
		frame:SetTitle(title)
		frame:SetSize(400, 180)
		frame:Center()
		frame:MakePopup()
	
		local label = vgui.Create("DLabel", frame)
		label:SetPos(10, 30)
		label:SetSize(380, 20)
		label:SetText(message)
	
		local textEntry1 = vgui.Create("DTextEntry", frame)
		textEntry1:SetPos(10, 60)
		textEntry1:SetSize(380, 20)
		textEntry1:SetPlaceholderText(default1 or "")
	
		local textEntry2 = vgui.Create("DTextEntry", frame)
		textEntry2:SetPos(10, 90)
		textEntry2:SetSize(380, 20)
		textEntry2:SetPlaceholderText(default2 or "")
	
		local confirmButton = vgui.Create("DButton", frame)
		confirmButton:SetText("OK")
		confirmButton:SetPos(10, 120)
		confirmButton:SetSize(185, 30)
		confirmButton.DoClick = function()
			local val1 = textEntry1:GetValue()
			local val2 = textEntry2:GetValue()
			frame:Close()
			if onConfirm then onConfirm(val1, val2) end
		end
	
		local cancelButton = vgui.Create("DButton", frame)
		cancelButton:SetText("Cancel")
		cancelButton:SetPos(205, 120)
		cancelButton:SetSize(185, 30)
		cancelButton.DoClick = function()
			frame:Close()
		end
	end

	local mapPreviewHierarchyPanel21 = vgui.Create("DPanel", tabPanel21)
	mapPreviewHierarchyPanel21:SetBackgroundColor(Color(240, 240, 240))

	net.Receive("PSY_MapVote_SendMapPreviewHierarchy", function()
		mapPreviewHierarchyPanel21:Clear()
		local fileContent = net.ReadTable()
		--PrintTable(fileContent)
		local mapPreviewHierarchyList = vgui.Create("DListView", mapPreviewHierarchyPanel21)
		mapPreviewHierarchyList:Dock(FILL)
		mapPreviewHierarchyList:AddColumn("Number"):SetFixedWidth(160)
		mapPreviewHierarchyList:AddColumn("Directory")
		mapPreviewHierarchyList:AddColumn("Path")
		--gameModesPrefixList:SetSize(500,500)
		for k,v in ipairs(fileContent) do
			mapPreviewHierarchyList:AddLine(k, v.directory, v.path)
		end
		mapPreviewHierarchyList:SortByColumn( 1 )

		local saveFileButton = vgui.Create("DButton", mapPreviewHierarchyPanel21)
		saveFileButton:SetText("Save")
		saveFileButton:SetSize(100, 30)
		saveFileButton:Dock(BOTTOM)
		saveFileButton.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(174, 217, 246))
		end
		
		saveFileButton.DoClick = function()
			SaveMapPreviewHierarchy21(fileContent)
			LoadMapPreviewHierarchy21()
		end

		local addPathButton = vgui.Create("DButton", mapPreviewHierarchyPanel21)
		addPathButton:SetText("Add Path")
		addPathButton:SetSize(100, 30)
		addPathButton:Dock(BOTTOM)
		addPathButton.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(202, 232, 253))
		end
		
		addPathButton.DoClick = function()
			OpenTwoInputRequest("Two Inputs required", "Type in Path (e.g. DATA) and directory (e.g. /maps/thumbs)", "DATA", "/maps/thumbs", function( path, directory )
				path = string.upper( path )
				directory = string.lower(directory)
				table.insert( fileContent, {["path"] = path, ["directory"] = directory} )
				mapPreviewHierarchyList:AddLine(#fileContent, directory, path)
			end)
		end

		local removePathButton = vgui.Create("DButton", mapPreviewHierarchyPanel21)
		removePathButton:SetText("Remove Path")
		removePathButton:SetSize(100, 30)
		removePathButton:Dock(BOTTOM)
		removePathButton.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(174, 217, 246))
		end
		
		removePathButton.DoClick = function()
			if mapPreviewHierarchyList:GetSelectedLine() == nil then return end
			local xlinei, xlinep = mapPreviewHierarchyList:GetSelectedLine()
			table.remove( fileContent, xlinei )
			mapPreviewHierarchyList:Clear()
			for k,v in ipairs(fileContent) do
				mapPreviewHierarchyList:AddLine(k, v.directory, v.path)
			end
		end

		local moveDownButton = vgui.Create("DButton", mapPreviewHierarchyPanel21)
		moveDownButton:SetText("Move down")
		moveDownButton:SetSize(100, 30)
		moveDownButton:Dock(BOTTOM)
		moveDownButton.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(202, 232, 253))
		end
		
		moveDownButton.DoClick = function()
			if mapPreviewHierarchyList:GetSelectedLine() == nil then return end
			local xtable = mapPreviewHierarchyList:GetLines()
			local xlinei, xlinep = mapPreviewHierarchyList:GetSelectedLine()
			if xlinei == #mapPreviewHierarchyList:GetLines() then return end
			
			local movedLine = table.remove( fileContent, xlinei )
			table.insert( fileContent, xlinei+1, movedLine )
			mapPreviewHierarchyList:Clear()
			for k,v in ipairs(fileContent) do
				mapPreviewHierarchyList:AddLine(k, v.directory, v.path)
			end
		end

		local moveUpButton = vgui.Create("DButton", mapPreviewHierarchyPanel21)
		moveUpButton:SetText("Move up")
		moveUpButton:SetSize(100, 30)
		moveUpButton:Dock(BOTTOM)
		moveUpButton.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(174, 217, 246))
		end
		
		moveUpButton.DoClick = function()
			if mapPreviewHierarchyList:GetSelectedLine() == nil then return end
			local xtable = mapPreviewHierarchyList:GetLines()
			local xlinei, xlinep = mapPreviewHierarchyList:GetSelectedLine()
			if xlinei == 1 then return end
			
			local movedLine = table.remove( fileContent, xlinei )
			table.insert( fileContent, xlinei-1, movedLine )
			mapPreviewHierarchyList:Clear()
			for k,v in ipairs(fileContent) do
				mapPreviewHierarchyList:AddLine(k, v.directory, v.path)
			end
		end
	end)

	tabPanel21:AddSheet("MapPreviewHierarchy", mapPreviewHierarchyPanel21, "icon16/arrow_branch.png")

	
	-- RatingResults Tab
	local ratingResultsPanel21 = vgui.Create("DPanel", tabPanel21)
	ratingResultsPanel21:SetBackgroundColor(Color(240, 240, 240))

	net.Receive("PSY_MapVote_SendRatingResults", function()
		ratingResultsPanel21:Clear()
		local compressedLength = net.ReadUInt(32)
		local compressedString = net.ReadData(compressedLength)
		local fileContent = uncompressString(compressedString)
		
		ratingResultsPanel21:SetSize(500,500)

		local ratingResultsList = vgui.Create("DListView", ratingResultsPanel21)
		ratingResultsList:Dock(FILL)
		--ratingResultsList:SetSize(500,500)
		ratingResultsList:AddColumn("Gamemode / Map")
		ratingResultsList:AddColumn("Total Stars")
		ratingResultsList:AddColumn("Count Votes")
		ratingResultsList:AddColumn("Effective Rating")
		for k,v in pairs(fileContent) do
			ratingResultsList:AddLine(k, v.rating, v.count, (math.Round(v.rating/v.count,1)) )
		end
		ratingResultsList:SortByColumn( 1 )
		function ratingResultsList:DoDoubleClick(lineID, line)
			local currentItem = self:GetLine(lineID)
			local gamemode = currentItem:GetColumnText(1)
			local ratingValue = currentItem:GetColumnText(2)
			local countValue = currentItem:GetColumnText(3)
		
			local frame = vgui.Create("DFrame")
			frame:SetSize(200, 150)
			frame:SetTitle("Set Rating and Vote Counts")
			frame:Center()
			frame:MakePopup()
		
			local ratingLabel = vgui.Create("DLabel", frame)
			ratingLabel:SetPos(10, 30)
			ratingLabel:SetText("Total Stars:")
		
			local ratingEntry = vgui.Create("DTextEntry", frame)
			ratingEntry:SetPos(100, 30)
			ratingEntry:SetSize(80, 20)
			ratingEntry:SetText(ratingValue)
		
			local countLabel = vgui.Create("DLabel", frame)
			countLabel:SetPos(10, 60)
			countLabel:SetText("Vote Count:")
		
			local countEntry = vgui.Create("DTextEntry", frame)
			countEntry:SetPos(100, 60)
			countEntry:SetSize(80, 20)
			countEntry:SetText(countValue)
		
			local confirmButton = vgui.Create("DButton", frame)
			confirmButton:SetPos(60, 100)
			confirmButton:SetSize(80, 30)
			confirmButton:SetText("Confirm")
			confirmButton.DoClick = function()
				local newRating = tonumber(ratingEntry:GetText())
				local newCount = tonumber(countEntry:GetText())
		
				if newRating and newCount then
					currentItem:SetColumnText(2, newRating)
					currentItem:SetColumnText(3, newCount)
					currentItem:SetColumnText(4, newRating/newCount)
					fileContent[gamemode].rating = newRating
					fileContent[gamemode].count = newCount
					frame:Close()
				else
					Derma_Message("Please insert valid values", "Error", "OK")
				end
			end
		end
		local saveRatingButton = vgui.Create("DButton", ratingResultsPanel21)
		saveRatingButton:SetText("Save")
		saveRatingButton:SetSize(100, 30)
		saveRatingButton:Dock(BOTTOM)
		saveRatingButton.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(148, 205, 243))
		end
		saveRatingButton.DoClick = function()
			SaveRatingResults21(fileContent)
		end
	end)
	
	tabPanel21:AddSheet("RatingResults", ratingResultsPanel21, "icon16/star.png")

	--Statistics
	local statisticsPanel21 = vgui.Create("DPanel", tabPanel21)
	statisticsPanel21:SetBackgroundColor(Color(240, 240, 240))

	net.Receive("PSY_MapVote_SendStatistics", function()
		statisticsPanel21:Clear()
		local compressedLength = net.ReadUInt(32)
		local compressedString = net.ReadData(compressedLength)
		local fileContent = uncompressString(compressedString)
		
		local fileContentGamemodes = {}
		local fileContentMaps = {}
		for k,v in pairs(fileContent) do
			if table.HasValue(GamemodesList, k) then
				fileContentGamemodes[k] = v
			else
				fileContentMaps[k] = v
			end
		end
		local statisticsDivider = vgui.Create("DCategoryList", statisticsPanel21)
		statisticsDivider:Dock(FILL)

		local Cat = statisticsDivider:Add( "Gamemodes" )
		Cat:SetExpanded(false)
		local Cat2 = statisticsDivider:Add( "Maps" )
		Cat2:SetExpanded(false)

		local statisticsList = vgui.Create("DListView")
		statisticsList:Dock(TOP)
		statisticsList:AddColumn("Gamemode")
		statisticsList:AddColumn("Playcount"):SetFixedWidth(80)
		statisticsList:SetSize(500,500)

		for k,v in pairs(fileContentGamemodes) do
			statisticsList:AddLine(getGamemodeTitle(k),v)
		end
		statisticsList:SortByColumn( 1 )

		function statisticsList:DoDoubleClick(lineID, line)
			local currentItem = self:GetLine(lineID)
			local currentName = getGamemodeName(currentItem:GetColumnText(1))
			local currentValue = currentItem:GetColumnText(2)
			Derma_StringRequest(
				"",
				"",
				currentValue,
				function(text)
					currentItem:SetColumnText(2, text)
					fileContent[currentName] = tonumber(text)
				end
			)
		end

		local statisticsList2 = vgui.Create("DListView")
		statisticsList2:Dock(TOP)
		statisticsList2:AddColumn("Map")
		statisticsList2:AddColumn("Playcount"):SetFixedWidth(80)
		statisticsList2:SetSize(500,500)

		for k,v in pairs(fileContentMaps) do
			statisticsList2:AddLine(k,v)
		end
		statisticsList2:SortByColumn( 1 )

		function statisticsList2:DoDoubleClick(lineID, line)
			local currentItem = self:GetLine(lineID)
			local currentName = currentItem:GetColumnText(1)
			local currentValue = currentItem:GetColumnText(2)
			Derma_StringRequest(
				"",
				"",
				currentValue,
				function(text)
					currentItem:SetColumnText(2, text)
					local xtable = statisticsList2:GetLines()
					for k,v in ipairs(xtable) do
						fileContent[v:GetColumnText(1)] = tonumber(v:GetColumnText(2))
					end
				end
			)
		end

		Cat:SetContents( statisticsList )
		Cat2:SetContents( statisticsList2 )
		statisticsDivider:InvalidateLayout( true )

		local saveStatisticsButton21 = vgui.Create("DButton", statisticsPanel21)
		saveStatisticsButton21:SetText("Save")
		saveStatisticsButton21:SetSize(100, 30)
		saveStatisticsButton21:Dock(BOTTOM)
		saveStatisticsButton21.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(148, 205, 243))
		end
		saveStatisticsButton21.DoClick = function()
			SaveStatistics21(fileContent)
		end
	end)
	
	tabPanel21:AddSheet("Statistics", statisticsPanel21, "icon16/layout.png")
	
	-- RecentMaps Tab
	local recentMapsPanel21 = vgui.Create("DPanel", tabPanel21)
	recentMapsPanel21:SetBackgroundColor(Color(240, 240, 240))

	net.Receive("PSY_MapVote_SendRecentMaps", function()
		recentMapsPanel21:Clear()
		local fileContent = net.ReadTable()

		local recentMapsList = vgui.Create("DListView", recentMapsPanel21)
		recentMapsList:Dock(FILL)
		recentMapsList:SetMultiSelect(false) 
		recentMapsList:AddColumn("Recently played Maps") 
	
		for _, mapName in ipairs(fileContent) do
			recentMapsList:AddLine(mapName)
		end
	
		local addEntryButton = vgui.Create("DButton", recentMapsPanel21)
		addEntryButton:SetText("Add Entry")
		addEntryButton:SetSize(100, 30)
		addEntryButton:Dock(BOTTOM)
		addEntryButton.DoClick = function()
			Derma_StringRequest(
				"Add Entry",
				"Enter the map name:",
				"",
				function(text)
					recentMapsList:AddLine(text)
					table.insert(fileContent,text)
				end
			)
		end

		local removeEntryButton = vgui.Create("DButton", recentMapsPanel21)
		removeEntryButton:SetText("Remove Entry")
		removeEntryButton:SetSize(100, 30)
		removeEntryButton:Dock(BOTTOM)
		removeEntryButton.DoClick = function()
			local selectedLine = recentMapsList:GetSelectedLine()
			if selectedLine then
				recentMapsList:RemoveLine(selectedLine) 
				table.remove(fileContent, selectedLine)
			end
		end

		local saveRecentMapsButton = vgui.Create("DButton", recentMapsPanel21)
		saveRecentMapsButton:SetText("Save")
		saveRecentMapsButton:SetSize(100, 30)
		saveRecentMapsButton:Dock(BOTTOM)
		saveRecentMapsButton.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(148, 205, 243))
		end
		saveRecentMapsButton.DoClick = function()
			SaveRecentMaps21(fileContent)
		end
	end)

	
	tabPanel21:AddSheet("RecentMaps", recentMapsPanel21, "icon16/application_view_list.png")
	
	-- CSSMaps Tab
	local CSSMapsPanel = vgui.Create("DPanel", tabPanel21)
	CSSMapsPanel:SetBackgroundColor(Color(240, 240, 240))

	net.Receive("PSY_MapVote_SendCSSMaps", function()
		CSSMapsPanel:Clear()
		local fileContent = net.ReadTable()

		local CSSMapsList = vgui.Create("DListView", CSSMapsPanel)
		CSSMapsList:Dock(FILL)
		CSSMapsList:SetMultiSelect(false)
		CSSMapsList:AddColumn("Maps containing CSS content")
	
		for _, mapName in ipairs(fileContent) do
			CSSMapsList:AddLine(mapName)
		end
	
		local addEntryButton = vgui.Create("DButton", CSSMapsPanel)
		addEntryButton:SetText("Add Entry")
		addEntryButton:SetSize(100, 30)
		addEntryButton:Dock(BOTTOM)
		addEntryButton.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(148, 205, 243))
		end
		addEntryButton.DoClick = function()
			Derma_StringRequest(
				"Add Entry",
				"Enter the map name:",
				"",
				function(text)
					CSSMapsList:AddLine(text)
					table.insert(fileContent,text)
				end
			)
		end

		local removeEntryButton = vgui.Create("DButton", CSSMapsPanel)
		removeEntryButton:SetText("Remove Entry")
		removeEntryButton:SetSize(100, 30)
		removeEntryButton:Dock(BOTTOM)
		removeEntryButton.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(174, 217, 246))
		end
		removeEntryButton.DoClick = function()
			local selectedLine = CSSMapsList:GetSelectedLine()
			if selectedLine then
				CSSMapsList:RemoveLine(selectedLine) 
				table.remove(fileContent, selectedLine)
			end
		end

		local saveCSSMapsButton = vgui.Create("DButton", CSSMapsPanel)
		saveCSSMapsButton:SetText("Save")
		saveCSSMapsButton:SetSize(100, 30)
		saveCSSMapsButton:Dock(BOTTOM)
		saveCSSMapsButton.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(148, 205, 243))
		end
		saveCSSMapsButton.DoClick = function()
			saveCSSMaps(fileContent)
		end
	end)

	
	tabPanel21:AddSheet("CSSMaps", CSSMapsPanel, "icon16/exclamation.png")

	-- ConVars Tab
	local conVarsPanel = vgui.Create("DPanel", tabPanel21)
	conVarsPanel:SetBackgroundColor(Color(240, 240, 240))

	net.Receive("mapvote_offerGUIConVars", function()
		conVarsPanel:Clear()
		local fileContent = net.ReadTable()

		local conVarsList = vgui.Create("DListView", conVarsPanel)
		conVarsList:Dock(FILL)
		conVarsList:AddColumn("Gamemode")
		conVarsList:AddColumn("Max rounds before MapVote")
		--conVarsList:SetSize(500,500)
		for k,v in pairs(fileContent) do
			conVarsList:AddLine(getGamemodeTitle(k),v.convarValue) --:SetTooltip(getGamemodeTitle(k)
		end
		conVarsList:SortByColumn( 1 )
		
		function conVarsList:DoDoubleClick(lineID, line)
			local currentItem = self:GetLine(lineID)
			local xgamemode = getGamemodeName(currentItem:GetColumnText(1))
			local currentValue = currentItem:GetColumnText(2)

			Derma_StringRequest(
				"",
				"",
				currentValue,
				function(text)
					currentItem:SetColumnText(2, text)
					net.Start("mapvote_changeConVar")
						net.WriteString(fileContent[xgamemode].convarName)
						net.WriteString(tostring(text))
					net.SendToServer()
				end
			)
		end
		
	end)

	tabPanel21:AddSheet("ConVars", conVarsPanel, "icon16/joystick.png")

	-- Useful Addons Tab
	local usefulAddonsPanel = vgui.Create("DScrollPanel", tabPanel21)
	usefulAddonsPanel:SetBackgroundColor(Color(240, 240, 240))
	usefulAddonsPanel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(209, 209, 209)) 
	end
	net.Receive("PSY_MapVote_OfferUsefulAddons", function()
		usefulAddonsPanel:Clear()
		local xtable = net.ReadTable()

		local function AddElementToUsefulAddonsPanel(wsid, desc)
			local addonPanel = vgui.Create("DPanel", usefulAddonsPanel)
			addonPanel:Dock(TOP)
			addonPanel:SetSize(usefulAddonsPanel:GetWide(), usefulAddonsPanel:GetTall() / 4)
			addonPanel:DockMargin( 10, 5, 10, 0 )
			addonPanel.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, Color(158, 221, 255)) 
			end

			local addonPanelImage = vgui.Create("DImageButton", addonPanel)
			addonPanelImage:SetSize(addonPanel:GetTall() - 20,addonPanel:GetTall() - 20)
			addonPanelImage:SetPos(10,(addonPanel:GetTall() - addonPanelImage:GetTall()) / 2)
			steamworks.FileInfo(wsid, function(result)
				if file.Exists("cache/workshop/"..result.previewid..".cache", "GAME") then
					addonPanelImage:SetMaterial(AddonMaterial("cache/workshop/"..result.previewid..".cache"))
				else
					steamworks.Download(result.previewid, true, function(cachePath)
						if cachePath ~= nil then 
							addonPanelImage:SetMaterial(AddonMaterial(cachePath))
						else
							addonPanelImage:SetMaterial( "materials/icons/gmod_logo.png"  )
						end
					end) 
				end
			end)
			

			local addonPanelLabel = vgui.Create("DLabel", addonPanel)
			addonPanelLabel:SetSize(addonPanel:GetWide() - 210, addonPanelImage:GetTall())
			addonPanelLabel:SetPos(addonPanelImage:GetX() + addonPanelImage:GetWide() + 5,(addonPanel:GetTall() - addonPanelLabel:GetTall()) / 2)
			addonPanelLabel:SetTextColor( Color(0,0,0) )
			addonPanelLabel:SetFont( "PSY_GUIFont" )
			addonPanelLabel:SetText(desc)
			addonPanelLabel:SetTextInset( 5, 0 )
			addonPanelLabel:SetWrap(true)
			addonPanelLabel.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255)) 
			end

			addonPanelImage.DoClick = function()
				steamworks.ViewFile( wsid )
			end
		end

		for k,v in ipairs(xtable) do
			AddElementToUsefulAddonsPanel(v.wsid, v.desc)
		end
	end)
	tabPanel21:AddSheet("UsefulAddons", usefulAddonsPanel, "icon16/thumb_up.png")

	-- Installed Addons Tab
	local installedAddonsPanel = vgui.Create("DScrollPanel", tabPanel21)
	installedAddonsPanel:SetBackgroundColor(Color(240, 240, 240))
	installedAddonsPanel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(209, 209, 209)) 
	end

	local installedAddonsPanel2 = vgui.Create("DScrollPanel", installedAddonsPanel)
	installedAddonsPanel2:Dock(FILL)
	installedAddonsPanel2:SetSize(500,640)

	local searchEntry = vgui.Create("DTextEntry", installedAddonsPanel)
	searchEntry:SetPlaceholderText("Search Addons...")
	searchEntry:SetSize(200, 25)
	searchEntry:Dock(TOP)

	net.Receive("PSY_MapVote_OfferInstalledAddons", function()
		installedAddonsPanel2:Clear()
		
		local compressedLength = net.ReadUInt(32)
		local compressedString = net.ReadData(compressedLength) 
		local xtable = uncompressString(compressedString)
		searchEntry.OnChange = function(self)
			local searchText = searchEntry:GetText()
			for _, child in ipairs(installedAddonsPanel2:GetCanvas():GetChildren()) do
				if IsValid(child) and child:GetName() ~= "DTextEntry" then
					local title = child:GetChildren()[2]:GetText():lower()
					if searchText == "" or title:find(searchText, 1, true) then
						child:SetVisible(true)
					else
						child:SetVisible(false)
					end
				end
			end
			installedAddonsPanel2:GetCanvas():InvalidateLayout(true)
		end
		
		local function setContentOfPanel(k, wsid, desc, title)
			if not IsValid(installedAddonsPanel2:GetCanvas():GetChildren()[k]) then return end
			local img = installedAddonsPanel2:GetCanvas():GetChildren()[k]:GetChildren()[1]
			local lab = installedAddonsPanel2:GetCanvas():GetChildren()[k]:GetChildren()[2]
			lab:SetText(title.."\n"..desc)
			if IsValid(img) then
				if iconcache[wsid] ~= nil then 
					img:SetMaterial(AddonMaterial(iconcache[wsid])) 
				else
					steamworks.FileInfo(wsid, function(result)
						if file.Exists("cache/workshop/"..result.previewid..".cache", "GAME") then
							iconcache[wsid] = "cache/workshop/"..result.previewid..".cache"
							img:SetMaterial(AddonMaterial("cache/workshop/"..result.previewid..".cache"))
						else
							steamworks.Download(result.previewid, true, function(cachePath)
								if cachePath ~= nil and IsValid(img) then 
									iconcache[wsid] = cachePath
									img:SetMaterial(AddonMaterial(cachePath))
								elseif IsValid(img) then
									img:SetMaterial(Material("materials/icons/gmod_logo.png")) 
								end
							end) 
						end
					end)
				end

				if IsValid(img) then 
					img.DoClick = function()
						steamworks.ViewFile( wsid )
					end
				end
			end
		end

		local function AddElementToinstalledAddonsPanel(k)
			local addonPanel = vgui.Create("DPanel", installedAddonsPanel2)
			addonPanel.index = k
			addonPanel:Dock(TOP)
			addonPanel:SetSize(installedAddonsPanel2:GetWide(), installedAddonsPanel2:GetTall() / 4)
			addonPanel:DockMargin(10, 5, 10, 0)
			addonPanel.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, Color(158, 221, 255)) 
			end

			local addonPanelImage = vgui.Create("DImageButton", addonPanel)
			addonPanelImage:SetSize(addonPanel:GetTall() - 20,addonPanel:GetTall() - 20)
			addonPanelImage:SetPos(10, (addonPanel:GetTall() - addonPanelImage:GetTall()) / 2)
			
			local addonPanelLabel = vgui.Create("DLabel", addonPanel)
			addonPanelLabel:SetSize(addonPanel:GetWide() - 210, addonPanelImage:GetTall())
			addonPanelLabel:SetPos(addonPanelImage:GetX() + addonPanelImage:GetWide() + 5, (addonPanel:GetTall() - addonPanelLabel:GetTall()) / 2)
			addonPanelLabel:SetTextColor( Color(0,0,0) )
			addonPanelLabel:SetFont( "PSY_GUIFont" )
			
			addonPanelLabel:SetTextInset(5, 0)
			addonPanelLabel:SetWrap(true)
			addonPanelLabel.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255)) 
			end
		end
		
		for k,v in ipairs(xtable) do
			local xresult = {}
			AddElementToinstalledAddonsPanel(k)
			steamworks.FileInfo(tonumber(v.wsid), function(result) 
				if searchEntry:GetValue() == "" or result.title:lower():find(searchEntry:GetValue():lower(), 1, true) then
					setContentOfPanel(k, v.wsid, result.description, result.title)
				end
			end)
		end
	end)
	tabPanel21:AddSheet("InstalledAddons", installedAddonsPanel, "icon16/script.png")


	-- Installed Maps Tab
	local installedMapsPanel = vgui.Create("DScrollPanel", tabPanel21)
	installedMapsPanel:SetBackgroundColor(Color(240, 240, 240))
	installedMapsPanel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(209, 209, 209)) 
	end

	local installedMapsPanel2 = vgui.Create("DScrollPanel", installedMapsPanel)
	installedMapsPanel2:Dock(FILL)
	installedMapsPanel2:SetSize(500,640)

	local searchEntry = vgui.Create("DTextEntry", installedMapsPanel)
	searchEntry:SetPlaceholderText("Search Maps...")
	searchEntry:SetSize(200, 25)
	searchEntry:Dock(TOP)

	net.Receive("PSY_MapVote_OfferInstalledMaps", function()
		installedMapsPanel2:Clear()
		local compressedLength = net.ReadUInt(32)
		local compressedString = net.ReadData(compressedLength)
		local xtable = uncompressString(compressedString)
		
		searchEntry.OnChange = function(self)
			local searchText = searchEntry:GetText()
			for _, child in ipairs(installedMapsPanel2:GetCanvas():GetChildren()) do
				if IsValid(child) and child:GetName() ~= "DTextEntry" and child:GetName() ~= "Panel" then
					local title = child:GetChildren()[2]:GetText():lower()
					if searchText == "" or title:find(searchText, 1, true) then
						child:SetVisible(true)
					else
						child:SetVisible(false)
					end
				end
			end
			installedMapsPanel2:GetCanvas():InvalidateLayout(true)
		end
		
		local function setContentOfPanel(k, wsid, desc, title)
			if not IsValid(installedMapsPanel2:GetCanvas():GetChildren()[k]) then return end
			local img = installedMapsPanel2:GetCanvas():GetChildren()[k]:GetChildren()[1]
			local lab = installedMapsPanel2:GetCanvas():GetChildren()[k]:GetChildren()[2]
			--local mapButton = installedMapsPanel2:GetCanvas():GetChildren()[k]:GetChildren()[3]:GetChildren()[1]

			lab:SetText(title.."\n"..desc)
			if IsValid(img) then
				if iconcache[wsid] ~= nil then 
					img:SetMaterial(AddonMaterial(iconcache[wsid])) 
				else
					steamworks.FileInfo(wsid, function(result)
						if file.Exists("cache/workshop/"..result.previewid..".cache", "GAME") and IsValid(img) then
							iconcache[wsid] = "cache/workshop/"..result.previewid..".cache"
							img:SetMaterial(AddonMaterial("cache/workshop/"..result.previewid..".cache"))
						else
							steamworks.Download(result.previewid, true, function(cachePath)
								if cachePath ~= nil and IsValid(img) then 
									iconcache[wsid] = cachePath
									img:SetMaterial(AddonMaterial(cachePath))
								elseif IsValid(img) then
									img:SetMaterial(Material("materials/icons/gmod_logo.png")) 
								end
							end) 
						end
					end)
				end

				if IsValid(img) then 
					img.DoClick = function()
						steamworks.ViewFile( wsid )
					end
				end
			end

		end

		local function AddElementToinstalledMapsPanel(k)
			local mapsPanel = vgui.Create("DPanel", installedMapsPanel2)
			mapsPanel.index = k
			mapsPanel:Dock(TOP)
			mapsPanel:SetSize(installedMapsPanel2:GetWide(), installedMapsPanel2:GetTall() / 4)
			mapsPanel:DockMargin(10, 5, 10, 0)
			mapsPanel.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, Color(158, 221, 255)) 
			end

			local mapsPanelImage = vgui.Create("DImageButton", mapsPanel)
			mapsPanelImage:SetSize(mapsPanel:GetTall() - 20,mapsPanel:GetTall() - 20)
			mapsPanelImage:SetPos(10, (mapsPanel:GetTall() - mapsPanelImage:GetTall()) / 2)
			
			local mapsPanelLabel = vgui.Create("DLabel", mapsPanel)
			mapsPanelLabel:SetSize(mapsPanel:GetWide() - 210, mapsPanelImage:GetTall())
			mapsPanelLabel:SetPos(mapsPanelImage:GetX() + mapsPanelImage:GetWide() + 5, (mapsPanel:GetTall() - mapsPanelLabel:GetTall()) / 2)
			mapsPanelLabel:SetTextColor( Color(0,0,0) )
			mapsPanelLabel:SetFont( "PSY_GUIFont" )

			
			
			
			mapsPanelLabel:SetTextInset(5, 0)
			mapsPanelLabel:SetWrap(true)
			mapsPanelLabel.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255)) 
			end

			--local mapsPanelLoadMapPanel =  vgui.Create("Panel", mapsPanel)
			--mapsPanelLoadMapPanel:SetSize(25,25)
			--mapsPanelLoadMapPanel:SetText("")
			--mapsPanelLoadMapPanel:SetPos(mapsPanel:GetWide() - mapsPanelLoadMapPanel:GetWide() * 3 - 12, 120)
			--local mapsPanelLoadMapButton = vgui.Create("DImageButton", mapsPanelLoadMapPanel)
			--mapsPanelLoadMapButton:Dock(FILL)
			--mapsPanelLoadMapButton:SetText("")
			--mapsPanelLoadMapButton:SetMaterial("materials/icons/redo.png")
			--mapsPanelLoadMapButton:SetTooltip("Switch to this Map")
		end
		
		for k,v in ipairs(xtable) do
			local xresult = {}
			AddElementToinstalledMapsPanel(k)
			steamworks.FileInfo(tonumber(v.wsid), function(result) 
				if (searchEntry:GetValue() == "" or result.title:lower():find(searchEntry:GetValue():lower(), 1, true)) and result.description ~= nil then
					setContentOfPanel(k, v.wsid, result.description, result.title)
				end
			end)
		end
	end)
	tabPanel21:AddSheet("InstalledMaps", installedMapsPanel, "icon16/script.png")


	-- ConCommands Tab
	local conCommandsPanel = vgui.Create("DScrollPanel", tabPanel21)
	conCommandsPanel:SetBackgroundColor(Color(240, 240, 240))
	conCommandsPanel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(209, 209, 209)) 
	end
	net.Receive("PSY_MapVote_OfferConCommands", function()
		conCommandsPanel:Clear()
		local xtable = net.ReadTable()

		local function AddElementToConCommandsPanel(command, desc)
			local conCommandButton = vgui.Create("DButton", conCommandsPanel)
			conCommandButton:Dock(TOP)
			conCommandButton:SetSize(conCommandsPanel:GetWide(), conCommandsPanel:GetTall() / 10)
			conCommandButton:DockMargin( 10, 5, 10, 0 )
			conCommandButton:SetText(command)
			conCommandButton:SetTooltip(desc)
			conCommandButton:SetFontInternal("DermaLarge")
			conCommandButton:SetTextColor(Color(255, 255, 255))
			conCommandButton.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, Color(158, 221, 255)) 
			end

			conCommandButton.DoClick = function()
				net.Start("PSY_MapVote_ExecuteConCommands")
					net.WriteString(command)
				net.SendToServer()
			end
		end

		for k,v in ipairs(xtable) do
			AddElementToConCommandsPanel(v.command, v.desc)
		end
	end)
	tabPanel21:AddSheet("ConCommands", conCommandsPanel, "icon16/application_osx_terminal.png")

	-- CleanUp Tab
	local cleanupPanel = vgui.Create("DPanel", tabPanel21)
	cleanupPanel:SetBackgroundColor(Color(240, 240, 240))
	do

		local cleanupListView = vgui.Create("DListView", cleanupPanel)
		cleanupListView:Dock(FILL)
		cleanupListView:AddColumn("Map / Gamemode")
		cleanupListView:AddColumn("Path")

		local cleanupTextPanel = vgui.Create("DPanel", cleanupPanel)
		cleanupTextPanel:Dock(BOTTOM)
		cleanupTextPanel:SetSize(500,50)
		cleanupTextPanel:SetText("")

		local generateListButton = vgui.Create("DButton", cleanupTextPanel)
		generateListButton:SetText("Generate List")
		generateListButton:SetTooltip("Generates a List of all Maps and Gamemodes that take up space in saved files but aren't installed on the server")
		generateListButton:Dock(BOTTOM)
		generateListButton.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(148, 205, 243))
		end
		generateListButton.DoClick = function()
			generateListButton:Remove()
			local cleanDataButton = vgui.Create("DButton", cleanupTextPanel)
			cleanDataButton:SetText("Clean Data")
			cleanDataButton:Dock(BOTTOM)
			cleanDataButton.Paint = function(self, w, h)
				draw.RoundedBox(0, 0, 0, w, h, Color(148, 205, 243))
			end
			cleanDataButton.DoClick = function()
				net.Start("PSY_MapVote_CleanupData")
				net.SendToServer()
				cleanupListView:Clear()
			end
			LoadCleanupData()
		end

		local cleanupTextLabel = vgui.Create("DLabel", cleanupTextPanel)
		cleanupTextLabel:Dock(TOP)
		cleanupTextLabel:SetText("")

		net.Receive("PSY_MapVote_SendCleanupData", function()
			local compressedLength = net.ReadUInt(32)
			local compressedString = net.ReadData(compressedLength)
			local data = uncompressString(compressedString)
			
			cleanupListView:Clear()
			for _, row in ipairs(data) do
				cleanupListView:AddLine(row.thing, row.path)
			end
			
			cleanupTextLabel:SetContentAlignment( 8 )
			if not table.IsEmpty(data) then
				cleanupTextLabel:SetText("Unused Data Sets in total: "..table.Count(data))
			else
				cleanupTextLabel:SetText("Can't Cleanup. No unused Data Sets found!")
			end
			cleanupTextLabel:SetTextColor(Color(0,0,0))
		end)
	end

	tabPanel21:AddSheet("Cleanup", cleanupPanel, "icon16/bin_closed.png")

	local function SetTabTooltips(propertySheet)
		
		for _, tab in pairs(propertySheet.Items) do
			local tabName = tab.Tab:GetText()
			if tooltips[tabName] then
				tab.Tab:SetTooltip(tooltips[tabName])
			end
		end
	end
	SetTabTooltips(tabPanel21)
end


hook.Add("InitPostEntity", "CreateConfigEditorGUI", function()
	if LocalPlayer():IsAdmin() then
		concommand.Add("mapvote_menu", function()
			MapVote_CreateGUI()
		end)
	end
end)

net.Receive("PSY_MapVote_OpenCSGUI", function()
	MapVote_CreateGUI()
end)


--hook.Add( "OnPlayerChat", "OpenMapVoteMenu", function( ply, strText, bTeam, bDead ) 
--    if ( ply != LocalPlayer() ) then return end

--	if string.lower(strText) == "!mvmenu" then
--		MapVote_CreateGUI()
--		return
--	end
	
--end )