-- ============================================================
--  SHINIGAMI LEGENDS | SelectionServer (Script)
--  ServerScriptService > SelectionServer
--  ILKK CALISTIRILMALI — tüm RemoteEvent/Function burada olusur
-- ============================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ─── Remotes Klasörü ──────────────────────────────────────────
local Remotes = Instance.new("Folder")
Remotes.Name   = "Remotes"
Remotes.Parent = ReplicatedStorage

local function re(name)
	local r = Instance.new("RemoteEvent")
	r.Name   = name
	r.Parent = Remotes
	return r
end
local function rf(name)
	local r = Instance.new("RemoteFunction")
	r.Name   = name
	r.Parent = Remotes
	return r
end

re("SelectCharacter")    -- Client→Server: karakter seç
re("UseSkill")           -- Client→Server: yetenek kullan
re("UpgradeCharacter")   -- Client→Server: versiyon yükselt
re("PlayVFX")            -- Server→AllClients: VFX tetikle
re("CharacterSelected")  -- Server→Client: seçim onayı
re("VersionUpgraded")    -- Server→Client: yükseltme onayı
re("AdminMessage")       -- Server→Client: admin popup mesajı
rf("GetPlayerData")      -- Client invoke: anlık veri al

-- ─── Karakter İstatistikleri ──────────────────────────────────
local STATS = {
	AIZEN = {
		base = { hp = 250, speed = 18, jump = 60 },
		V1   = { hpMult = 1.0,  spdMult = 1.0  },
		V2   = { hpMult = 1.6,  spdMult = 1.14 },
		V3   = { hpMult = 2.5,  spdMult = 1.32 },
	},
}

local SEL_COLORS = {
	V1 = Color3.fromRGB(80,  120, 255),
	V2 = Color3.fromRGB(170, 55,  255),
	V3 = Color3.fromRGB(255, 38,  38),
}

local function applyStats(player, charId, version)
	local char = player.Character
	if not char then return end
	local hum  = char:FindFirstChild("Humanoid")
	if not hum  then return end

	local cfg   = STATS[charId]
	if not cfg  then return end
	local base  = cfg.base
	local bonus = cfg[version] or cfg.V1

	hum.MaxHealth = math.floor(base.hp * bonus.hpMult)
	hum.Health    = hum.MaxHealth
	hum.WalkSpeed = base.speed * bonus.spdMult
	hum.JumpPower = base.jump

	task.delay(0.3, function()
		if not char.Parent then return end
		for _, v in ipairs(char:GetChildren()) do
			if v:IsA("SelectionBox") then v:Destroy() end
		end
		local sb = Instance.new("SelectionBox")
		sb.Adornee             = char
		sb.Color3              = SEL_COLORS[version] or SEL_COLORS.V1
		sb.LineThickness       = 0.05
		sb.SurfaceTransparency = 0.90
		sb.SurfaceColor3       = SEL_COLORS[version] or SEL_COLORS.V1
		sb.Parent              = char
	end)

	print(string.format("[SelectionServer] Stats uygulandı: %s %s | HP=%d Speed=%.1f",
		charId, version, hum.MaxHealth, hum.WalkSpeed))
end

Remotes:WaitForChild("SelectCharacter").OnServerEvent:Connect(function(player, charId, version)
	player.CharacterAdded:Wait()
	task.wait(0.6)
	applyStats(player, charId, version or "V1")
end)

-- ─── Leaderstats (yedek oluşturucu) ───────────────────────────
Players.PlayerAdded:Connect(function(player)
	if not player:FindFirstChild("leaderstats") then
		local ls = Instance.new("Folder")
		ls.Name   = "leaderstats"
		ls.Parent = player
		for _, pair in ipairs({
			{"Coins",     "IntValue",    0},
			{"Kills",     "IntValue",    0},
			{"Character", "StringValue", "None"},
		}) do
			local v = Instance.new(pair[2])
			v.Name   = pair[1]
			v.Value  = pair[3]
			v.Parent = ls
		end
	end
end)

-- ══════════════════════════════════════════════════════════════
--  ADMİN KOMUTU: /GiveCharAizenV1 / V2 / V3 / Hogyoku
--  Büyük/küçük harf farketmez. Sadece oyun yapımcısı kullanabilir.
-- ══════════════════════════════════════════════════════════════
local GAME_CREATOR_ID = game.CreatorId  -- Otomatik algılanır

local function isAdmin(player)
	return player.UserId == GAME_CREATOR_ID
end

local function sendAdminMsg(player, text, color)
	Remotes:WaitForChild("AdminMessage"):FireClient(player, text, color)
end

-- Alias tablosu — tüm geçerli versiyon isimleri
local VERSION_ALIASES = {
	v1      = "V1",
	v2      = "V2",
	v3      = "V3",
	hogyoku = "V3",  -- Hogyoku = V3 ile aynı
}

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		-- Boşlukları kaldır, küçük harfe çevir
		local lower = msg:lower():gsub("%s+", "")

		-- /givecharaizen<suffix> kalıbını ara
		local suffix = lower:match("^/givecharaizen(.+)$")
		if not suffix then return end

		-- Admin kontrolü
		if not isAdmin(player) then
			sendAdminMsg(player,
				"⛔  Bu komutu kullanma yetkin yok! Sadece oyun yapımcısı kullanabilir.",
				Color3.fromRGB(255, 60, 60))
			return
		end

		-- Versiyon kontrolü
		local ver = VERSION_ALIASES[suffix]
		if not ver then
			sendAdminMsg(player,
				"⚠  Geçersiz versiyon! Kullanım: /GiveCharAizenV1 / V2 / V3 / Hogyoku",
				Color3.fromRGB(255, 180, 40))
			return
		end

		-- AizenServer modülünü bul ve veriyi güncelle
		local ok, AizenServer = pcall(function()
			return require(game.ServerScriptService:FindFirstChild("AizenServer"))
		end)
		if not ok or not AizenServer then
			sendAdminMsg(player, "⚠  AizenServer modülü bulunamadı!", Color3.fromRGB(255, 180, 40))
			return
		end

		local data = AizenServer.GetData(player)
		if not data then
			sendAdminMsg(player, "⚠  Oyuncu verisi bulunamadı.", Color3.fromRGB(255, 180, 40))
			return
		end

		-- Veriyi güncelle
		data.character         = "AIZEN"
		data.version           = ver
		data.owned["AIZEN_V1"] = true
		if ver == "V2" or ver == "V3" then data.owned["AIZEN_V2"] = true end
		if ver == "V3" then                data.owned["AIZEN_V3"] = true end

		-- Leaderstats güncelle
		local ls = player:FindFirstChild("leaderstats")
		if ls then
			local ch = ls:FindFirstChild("Character")
			if ch then ch.Value = "AIZEN " .. ver end
		end

		-- Karakteri yeniden yükle
		player:LoadCharacter()
		task.delay(0.9, function()
			Remotes:WaitForChild("CharacterSelected"):FireClient(player, "AIZEN", ver)
			applyStats(player, "AIZEN", ver)
		end)

		sendAdminMsg(player,
			"✅  Admin komutu uygulandı → AIZEN " .. ver .. " verildi!",
			Color3.fromRGB(80, 255, 130))

		print(string.format("[ADMIN] %s → AIZEN %s verildi (komut: '%s')",
			player.Name, ver, msg))
	end)
end)

print("[ShinigamiLegends] SelectionServer + Admin Komutları yüklendi ✓")
