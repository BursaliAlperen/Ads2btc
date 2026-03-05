-- ============================================================
--  SHINIGAMI LEGENDS | AizenServer (Script)
--  ServerScriptService > AizenServer
--
--  V1: 3 yetenek  |  V2: 5 yetenek  |  V3: 6 yetenek
--  Para sistemi: öldürme = +120 coin
--  Admin komutu SelectionServer'da yönetilir
-- ============================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes          = ReplicatedStorage:WaitForChild("Remotes")
local useSkillRemote   = Remotes:WaitForChild("UseSkill")
local vfxRemote        = Remotes:WaitForChild("PlayVFX")
local upgradeRemote    = Remotes:WaitForChild("UpgradeCharacter")
local charSelectRemote = Remotes:WaitForChild("SelectCharacter")
local charSelectedEvt  = Remotes:WaitForChild("CharacterSelected")
local versionUpgEvt    = Remotes:WaitForChild("VersionUpgraded")

-- ─── Oyuncu Verisi (bellek içi) ────────────────────────────────
-- Üretimde DataStoreService ile kalıcı hale getir
local playerData = {}

local function initData(player)
	playerData[player.UserId] = {
		coins     = 0,
		kills     = 0,
		deaths    = 0,
		character = nil,
		version   = "V1",
		owned     = {},
		inventory = {
			HogyokuPiece  = 0,
			HogyokuFusion = 0,
		},
	}
end

local function getData(player)
	return playerData[player.UserId]
end

-- ─── Yetenek Konfigürasyonu ────────────────────────────────────
local AIZEN_SKILLS = {
	-- V1: 3 temel yetenek (az hasar, kısa menzil)
	V1 = {
		[1] = { name="Zanpakuto Slash",  cooldown=5,  damage=28,  range=10, aoe=false },
		[2] = { name="Byakurai",         cooldown=8,  damage=42,  range=44, aoe=false, isBeam=true },
		[3] = { name="Kyoka Suigetsu",   cooldown=16, damage=32,  range=9,  aoe=true,  aoeR=8  },
	},
	-- V2: 5 yetenek (orta güç)
	V2 = {
		[1] = { name="Empowered Slash",   cooldown=5,  damage=55,  range=12, aoe=false },
		[2] = { name="Raikoho",           cooldown=9,  damage=82,  range=52, aoe=false, isBeam=true },
		[3] = { name="Kyoka Suigetsu II", cooldown=15, damage=60,  range=11, aoe=true,  aoeR=13 },
		[4] = { name="Kurohitsugi",       cooldown=22, damage=115, range=57, aoe=false, isBeam=true },
		[5] = { name="Fragor",            cooldown=13, damage=72,  range=14, aoe=true,  aoeR=15 },
	},
	-- V3: 6 dev yetenek (Hogyoku Canavar Formu)
	V3 = {
		[1] = { name="Hogyoku Slash",       cooldown=4,  damage=88,  range=14, aoe=false },
		[2] = { name="Hogyoku Beam",        cooldown=9,  damage=145, range=64, aoe=false, isBeam=true },
		[3] = { name="Absolute Hypnosis",   cooldown=15, damage=100, range=13, aoe=true,  aoeR=20 },
		[4] = { name="Kurohitsugi Release", cooldown=23, damage=190, range=68, aoe=false, isBeam=true },
		[5] = { name="Reconstruction",      cooldown=12, damage=110, range=15, aoe=true,  aoeR=22 },
		[6] = { name="BANKAI",              cooldown=32, damage=280, range=20, aoe=true,  aoeR=24 },
	},
}

-- ─── Cooldown Takibi ───────────────────────────────────────────
local cooldowns = {}

local function onCooldown(uid, ver, idx)
	local key  = ver .. "_" .. idx
	if not cooldowns[uid]      then return false end
	local last = cooldowns[uid][key]
	if not last                then return false end
	local skill = AIZEN_SKILLS[ver] and AIZEN_SKILLS[ver][idx]
	if not skill               then return true  end
	return (os.clock() - last) < skill.cooldown
end

local function setCooldown(uid, ver, idx)
	if not cooldowns[uid] then cooldowns[uid] = {} end
	cooldowns[uid][ver .. "_" .. idx] = os.clock()
end

-- ─── Geri İtme ─────────────────────────────────────────────────
local function knockback(targetRoot, sourcePos, force)
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.Velocity = (targetRoot.Position - sourcePos).Unit * force + Vector3.new(0, 20, 0)
	bv.Parent   = targetRoot
	game:GetService("Debris"):AddItem(bv, 0.22)
end

-- ─── Hasar & Hedef Tespiti ────────────────────────────────────
local function dealDamage(attacker, char, skillData)
	local root    = char:FindFirstChild("HumanoidRootPart")
	if not root   then return end
	local origin  = root.Position
	local forward = root.CFrame.LookVector
	local data    = getData(attacker)

	for _, target in ipairs(Players:GetPlayers()) do
		if target == attacker then continue end
		local tChar = target.Character
		if not tChar then continue end
		local hum   = tChar:FindFirstChild("Humanoid")
		local tRoot = tChar:FindFirstChild("HumanoidRootPart")
		if not hum or not tRoot or hum.Health <= 0 then continue end

		local dist = (tRoot.Position - origin).Magnitude
		local hit  = false

		if skillData.aoe then
			hit = dist <= (skillData.aoeR or skillData.range)
		elseif skillData.isBeam then
			local toTarget = (tRoot.Position - origin).Unit
			local dot = forward:Dot(toTarget)
			hit = dist <= skillData.range and dot >= 0.42
		else
			local toTarget = (tRoot.Position - origin).Unit
			local dot = forward:Dot(toTarget)
			hit = dist <= skillData.range and dot >= 0.52
		end

		if hit then
			hum:TakeDamage(skillData.damage)
			knockback(tRoot, origin, 40)

			-- Öldürme ödülü
			if hum.Health <= 0 and data then
				data.kills += 1
				data.coins += 120

				local ls = attacker:FindFirstChild("leaderstats")
				if ls then
					local kv = ls:FindFirstChild("Kills")
					local cv = ls:FindFirstChild("Coins")
					if kv then kv.Value = data.kills end
					if cv then cv.Value = data.coins end
				end

				print(string.format("[Server] %s öldürdü: %s | Coins: %d | Kills: %d",
					attacker.Name, target.Name, data.coins, data.kills))
			end
		end
	end
end

-- ─── Yetenek Remote ────────────────────────────────────────────
useSkillRemote.OnServerEvent:Connect(function(player, charId, version, skillIdx)
	if charId ~= "AIZEN" then return end

	local data = getData(player)
	if not data or data.character ~= "AIZEN" then return end
	if data.version ~= version then return end  -- exploit koruması

	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChild("Humanoid")
	if not hum or hum.Health <= 0 then return end

	local vSkills = AIZEN_SKILLS[version]
	if not vSkills or not vSkills[skillIdx] then return end
	if onCooldown(player.UserId, version, skillIdx) then return end

	setCooldown(player.UserId, version, skillIdx)
	dealDamage(player, char, vSkills[skillIdx])
	vfxRemote:FireAllClients("AIZEN", version, skillIdx, char)
end)

-- ─── Karakter Seçimi ───────────────────────────────────────────
charSelectRemote.OnServerEvent:Connect(function(player, charId, version)
	local data = getData(player)
	if not data then return end
	version = version or "V1"

	if charId == "AIZEN" then
		if not data.owned["AIZEN_V1"] then
			if data.coins < 2500 then
				print(string.format("[Server] %s yetersiz coin (%d/2500)", player.Name, data.coins))
				return
			end
			data.coins -= 2500
			data.owned["AIZEN_V1"] = true
			local ls = player:FindFirstChild("leaderstats")
			if ls then
				local cv = ls:FindFirstChild("Coins")
				if cv then cv.Value = data.coins end
			end
		end
	end

	data.character = charId
	if     data.owned["AIZEN_V3"] then data.version = "V3"
	elseif data.owned["AIZEN_V2"] then data.version = "V2"
	else                               data.version = "V1"
	end

	local ls = player:FindFirstChild("leaderstats")
	if ls then
		local ch = ls:FindFirstChild("Character")
		if ch then ch.Value = charId .. " " .. data.version end
	end

	player:LoadCharacter()
	task.delay(0.8, function()
		charSelectedEvt:FireClient(player, charId, data.version)
	end)

	print(string.format("[Server] %s → %s %s seçildi", player.Name, charId, data.version))
end)

-- ─── Versiyon Yükseltme ────────────────────────────────────────
upgradeRemote.OnServerEvent:Connect(function(player, charId, targetVer)
	local data = getData(player)
	if not data or data.character ~= charId then return end

	local success = false

	if charId == "AIZEN" then
		if targetVer == "V2" and data.version == "V1" then
			if data.coins >= 10000 and data.inventory.HogyokuPiece >= 1 then
				data.coins -= 10000
				data.inventory.HogyokuPiece -= 1
				data.version = "V2"
				data.owned["AIZEN_V2"] = true
				success = true
			else
				warn(string.format("[Server] %s V2 yükseltme başarısız | Coins:%d/10000 | Hogyoku:%d/1",
					player.Name, data.coins, data.inventory.HogyokuPiece))
			end

		elseif targetVer == "V3" and data.version == "V2" then
			if data.coins >= 25000 and data.inventory.HogyokuFusion >= 1 then
				data.coins -= 25000
				data.inventory.HogyokuFusion -= 1
				data.version = "V3"
				data.owned["AIZEN_V3"] = true
				success = true
			else
				warn(string.format("[Server] %s V3 yükseltme başarısız | Coins:%d/25000 | HogyokuFusion:%d/1",
					player.Name, data.coins, data.inventory.HogyokuFusion))
			end
		end
	end

	if success then
		local ls = player:FindFirstChild("leaderstats")
		if ls then
			local cv = ls:FindFirstChild("Coins")
			if cv then cv.Value = data.coins end
			local ch = ls:FindFirstChild("Character")
			if ch then ch.Value = charId .. " " .. targetVer end
		end
		versionUpgEvt:FireClient(player, charId, targetVer)
		print(string.format("[Server] ✓ %s → %s %s yükseltildi", player.Name, charId, targetVer))
	end
end)

-- ─── GetPlayerData (InvokeServer) ─────────────────────────────
Remotes:WaitForChild("GetPlayerData").OnServerInvoke = function(player)
	return getData(player)
end

-- ─── Oyuncu Olayları ───────────────────────────────────────────
Players.PlayerAdded:Connect(function(player)
	initData(player)

	if not player:FindFirstChild("leaderstats") then
		local ls = Instance.new("Folder")
		ls.Name   = "leaderstats"
		ls.Parent = player

		local coins = Instance.new("IntValue")
		coins.Name = "Coins"; coins.Value = 0; coins.Parent = ls

		local kills = Instance.new("IntValue")
		kills.Name = "Kills"; kills.Value = 0; kills.Parent = ls

		local char = Instance.new("StringValue")
		char.Name = "Character"; char.Value = "None"; char.Parent = ls
	end

	player.CharacterAdded:Connect(function(character)
		local hum = character:WaitForChild("Humanoid")
		hum.Died:Connect(function()
			local data = getData(player)
			if data then data.deaths += 1 end
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	playerData[player.UserId] = nil
	cooldowns[player.UserId]  = nil
end)

-- ══════════════════════════════════════════════════════════════
--  PUBLIC MODULE API (Boss scriptleri için)
-- ══════════════════════════════════════════════════════════════
local module = {}

-- Coin ver (boss öldürme vb.)
function module.GiveCoins(player, amount)
	local data = getData(player)
	if not data then return end
	data.coins += amount
	local ls = player:FindFirstChild("leaderstats")
	if ls then
		local cv = ls:FindFirstChild("Coins")
		if cv then cv.Value = data.coins end
	end
	print(string.format("[Server] %s +%d coin | Toplam: %d",
		player.Name, amount, data.coins))
end

-- Envanter eşyası ver (HogyokuPiece / HogyokuFusion)
function module.GiveItem(player, itemName, amount)
	local data = getData(player)
	if not data then return end
	amount = amount or 1
	data.inventory[itemName] = (data.inventory[itemName] or 0) + amount
	print(string.format("[Server] %s +%dx %s | Sahip: %d",
		player.Name, amount, itemName, data.inventory[itemName]))
end

-- Veri oku
function module.GetData(player)
	return getData(player)
end

print("[ShinigamiLegends] AizenServer yüklendi | V1:3 V2:5 V3:6 ✓")
return module
