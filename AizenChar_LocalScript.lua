-- ============================================================
--  SHINIGAMI LEGENDS | AizenChar (LocalScript)
--  StarterPlayerScripts > AizenChar
--
--  V1 → 3 Yetenek  (Shinigami Arc — temel güç)
--  V2 → 5 Yetenek  (TYBW Arc — güçlendirilmiş)
--  V3 → 6 Yetenek  (Hogyoku Füzyonu — Canavar Formu)
-- ============================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local SoundService      = game:GetService("SoundService")
local Lighting          = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ─── Remotes ──────────────────────────────────────────────────
local Remotes         = ReplicatedStorage:WaitForChild("Remotes")
local vfxRemote       = Remotes:WaitForChild("PlayVFX")
local charSelectedEvt = Remotes:WaitForChild("CharacterSelected")
local versionUpgEvt   = Remotes:WaitForChild("VersionUpgraded")

-- ─── VFX Klasörü ──────────────────────────────────────────────
local VFXFolder = workspace:FindFirstChild("VFX")
if not VFXFolder then
	VFXFolder        = Instance.new("Folder")
	VFXFolder.Name   = "VFX"
	VFXFolder.Parent = workspace
end

local origAmbient    = Lighting.Ambient
local origOutdoor    = Lighting.OutdoorAmbient
local origBrightness = Lighting.Brightness

-- ══════════════════════════════════════════════════════════════
--  SES EFEKTLERİ
--  (Roblox ücretsiz asset ID'leri — kendi ID'nle değiştir)
-- ══════════════════════════════════════════════════════════════
local SOUNDS = {
	slash      = "rbxassetid://9120432866",
	beam       = "rbxassetid://9120386460",
	explosion  = "rbxassetid://9120242410",
	hypnosis   = "rbxassetid://1369158732",
	transform  = "rbxassetid://4865205613",
	bankai     = "rbxassetid://4504539975",
	whoosh     = "rbxassetid://4905547301",
	lightning  = "rbxassetid://9119736244",
	dark_pulse = "rbxassetid://3740760060",
	power_up   = "rbxassetid://4612720692",
	hogyoku    = "rbxassetid://4504540358",
}

local function playSound(id, vol, pitch, pos)
	local s = Instance.new("Sound")
	s.SoundId           = id
	s.Volume            = vol or 1
	s.PlaybackSpeed     = pitch or 1
	s.RollOffMaxDistance = 80
	if pos then
		local anchor = Instance.new("Part")
		anchor.Anchored     = true
		anchor.CanCollide   = false
		anchor.Transparency = 1
		anchor.Size         = Vector3.new(0.1, 0.1, 0.1)
		anchor.CFrame       = CFrame.new(pos)
		anchor.Parent       = workspace
		s.Parent            = anchor
		game:GetService("Debris"):AddItem(anchor, 5)
	else
		s.Parent = SoundService
	end
	s:Play()
	game:GetService("Debris"):AddItem(s, 6)
end

-- ══════════════════════════════════════════════════════════════
--  TEMEL YARDIMCILAR
-- ══════════════════════════════════════════════════════════════
local function tw(obj, info, props)
	TweenService:Create(obj, info, props):Play()
end
local function db(obj, t)
	game:GetService("Debris"):AddItem(obj, t)
end

local function part(props, parent)
	local p = Instance.new("Part")
	p.Anchored   = true
	p.CanCollide = false
	p.CastShadow = false
	p.Material   = Enum.Material.Neon
	for k, v in pairs(props) do p[k] = v end
	p.Parent = parent or VFXFolder
	return p
end

-- Kamera Sarsıntısı
local _sm = 0
RunService.RenderStepped:Connect(function()
	if _sm > 0.001 then
		camera.CFrame = camera.CFrame * CFrame.Angles(
			(math.random() - 0.5) * _sm,
			(math.random() - 0.5) * _sm, 0)
		_sm = _sm * 0.86
	end
end)
local function shake(mag, dur)
	_sm = mag
	task.delay(dur, function() _sm = 0 end)
end

-- Işık Flaşı
local function lFlash(color, dur)
	Lighting.Ambient        = color
	Lighting.OutdoorAmbient = color
	Lighting.Brightness     = 3.8
	task.delay(dur, function()
		tw(Lighting, TweenInfo.new(dur * 2.5), {
			Ambient        = origAmbient,
			OutdoorAmbient = origOutdoor,
			Brightness     = origBrightness,
		})
	end)
end

-- Parçacık Patlaması
local function burst(origin, color, n, spd, life, s0, s1)
	s0 = s0 or 0.35
	s1 = s1 or 0.04
	for i = 1, n do
		local p = part({
			Color       = color,
			Size        = Vector3.new(s0, s0, s0),
			Transparency = 0.1,
			Shape       = Enum.PartType.Ball,
			CFrame      = CFrame.new(origin),
		})
		local d = Vector3.new(
			math.random() - 0.5,
			math.random() * 0.75 + 0.35,
			math.random() - 0.5
		).Unit * spd * (0.4 + math.random() * 0.6)
		tw(p, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame       = CFrame.new(origin + d * life),
			Size         = Vector3.new(s1, s1, s1),
			Transparency = 1,
		})
		db(p, life + 0.05)
	end
end

-- Zemin Halkası
local function ring(center, color, r0, r1, dur, a0)
	a0 = a0 or 0.15
	local p = part({
		Color       = color,
		Size        = Vector3.new(0.25, r0 * 2, r0 * 2),
		Transparency = a0,
		Shape       = Enum.PartType.Cylinder,
		CFrame      = CFrame.new(center + Vector3.new(0, 0.12, 0))
		              * CFrame.Angles(0, 0, math.pi / 2),
	})
	tw(p, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size         = Vector3.new(0.05, r1 * 2, r1 * 2),
		Transparency = 1,
	})
	db(p, dur + 0.05)
end

-- Enerji Sütunu
local function pillar(pos, color, w, h, dur)
	local p = part({
		Color        = color,
		Size         = Vector3.new(w, 0.1, w),
		Transparency = 0.2,
		CFrame       = CFrame.new(pos),
	})
	tw(p, TweenInfo.new(dur * 0.35, Enum.EasingStyle.Back), {
		Size   = Vector3.new(w, h, w),
		CFrame = CFrame.new(pos + Vector3.new(0, h / 2, 0)),
	})
	task.delay(dur * 0.35, function()
		if p.Parent then
			tw(p, TweenInfo.new(dur * 0.65), {
				Transparency = 1,
				Size         = Vector3.new(w * 0.2, h * 1.1, w * 0.2),
			})
		end
	end)
	db(p, dur + 0.05)
end

-- Kılıç Yayı
local function slash(origin, dir, color, n, len, spread)
	spread = spread or 55
	for i = 1, n do
		local ang = math.rad(-spread / 2 + (spread / (math.max(n - 1, 1))) * (i - 1))
		local sd  = CFrame.Angles(0, ang, 0) * dir
		local p   = part({
			Color        = color,
			Size         = Vector3.new(0.18, len * 0.28, 0.18),
			Transparency = 0.05,
			CFrame       = CFrame.new(origin, origin + sd) * CFrame.new(0, 0, -len * 0.14),
		})
		tw(p, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
			Size         = Vector3.new(0.04, len, 0.04),
			Transparency = 1,
			CFrame       = CFrame.new(origin, origin + sd) * CFrame.new(0, 0, -len * 0.58),
		})
		db(p, 0.32)
	end
end

-- Işın Demeti
local function beam(origin, dir, color, w, len, dur)
	local b = part({
		Color        = color,
		Size         = Vector3.new(w, w, 0.1),
		Transparency = 0.06,
		CFrame       = CFrame.new(origin, origin + dir) * CFrame.new(0, 0, -len / 2),
	})
	tw(b, TweenInfo.new(dur * 0.25, Enum.EasingStyle.Quad), {
		Size = Vector3.new(w * 1.2, w * 1.2, len),
	})
	task.delay(dur * 0.25, function()
		if b.Parent then
			tw(b, TweenInfo.new(dur * 0.75), {
				Transparency = 1,
				Size         = Vector3.new(0.05, 0.05, len * 1.1),
			})
		end
	end)
	db(b, dur + 0.05)

	-- Dış parıltı
	local g = part({
		Color        = color:Lerp(Color3.new(1, 1, 1), 0.4),
		Size         = Vector3.new(w * 3, w * 3, len * 0.92),
		Transparency = 0.65,
		CFrame       = CFrame.new(origin, origin + dir) * CFrame.new(0, 0, -len / 2),
	})
	tw(g, TweenInfo.new(dur), { Transparency = 1 })
	db(g, dur + 0.05)
end

-- Küre Genişleme
local function sphere(center, color, maxS, dur, a0)
	a0 = a0 or 0.15
	local p = part({
		Color        = color,
		Size         = Vector3.new(1, 1, 1),
		Transparency = a0,
		Shape        = Enum.PartType.Ball,
		CFrame       = CFrame.new(center),
	})
	tw(p, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size         = Vector3.new(maxS, maxS, maxS),
		Transparency = 1,
	})
	db(p, dur + 0.05)
end

-- Şimşek Çakması
local function lightning(top, bot, color, segs, dur)
	segs = segs or 12
	local step  = (bot - top) / segs
	local parts = {}
	for i = 0, segs - 1 do
		local a   = top + step * i       + Vector3.new((math.random() - 0.5) * 2.2, 0, (math.random() - 0.5) * 2.2)
		local b   = top + step * (i + 1) + Vector3.new((math.random() - 0.5) * 2.2, 0, (math.random() - 0.5) * 2.2)
		local mid = (a + b) / 2
		local len = (b - a).Magnitude
		local p   = part({
			Color        = color,
			Size         = Vector3.new(0.14, len, 0.14),
			Transparency = 0.08,
			CFrame       = CFrame.new(mid, b) * CFrame.Angles(math.pi / 2, 0, 0),
		})
		table.insert(parts, p)
	end
	task.delay(dur, function()
		for _, p in ipairs(parts) do
			if p.Parent then
				tw(p, TweenInfo.new(0.08), { Transparency = 1 })
				db(p, 0.1)
			end
		end
	end)
	for _, p in ipairs(parts) do db(p, dur + 0.18) end
end

-- Kurohitsugi köşeli parça
local function shard(pos, color, size, dur)
	local p = part({
		Color        = color,
		Size         = Vector3.new(size, size, size),
		Transparency = 0.08,
		CFrame       = CFrame.new(pos)
		              * CFrame.Angles(
		                  math.random() * math.pi,
		                  math.random() * math.pi,
		                  math.random() * math.pi),
	})
	tw(p, TweenInfo.new(dur, Enum.EasingStyle.Quad), {
		Size         = Vector3.new(0.05, 0.05, 0.05),
		Transparency = 1,
	})
	db(p, dur + 0.05)
end

-- Spiral Yörüngeli Toplar
local function spawnSpiralOrbs(center, color, count, radius, height, dur)
	for i = 1, count do
		local ang0 = (math.pi * 2 / count) * i
		local orb  = part({
			Color        = color,
			Size         = Vector3.new(0.58, 0.58, 0.58),
			Transparency = 0.14,
			Shape        = Enum.PartType.Ball,
			CFrame       = CFrame.new(center + Vector3.new(
				math.cos(ang0) * radius, 0, math.sin(ang0) * radius)),
		})
		local t = 0
		local conn
		conn = RunService.Heartbeat:Connect(function(dt)
			t += dt
			if not orb.Parent then conn:Disconnect() return end
			local ang = ang0 + t * 3.5
			local h   = math.sin(t * 2) * height
			orb.CFrame = CFrame.new(
				center + Vector3.new(math.cos(ang) * radius, h, math.sin(ang) * radius))
		end)
		task.delay(dur, function()
			conn:Disconnect()
			if orb.Parent then
				tw(orb, TweenInfo.new(0.3), {
					Transparency = 1,
					Size         = Vector3.new(0.05, 0.05, 0.05),
				})
				db(orb, 0.35)
			end
		end)
	end
end

-- ══════════════════════════════════════════════════════════════
--  SİNEMATİK CUTSCENE
-- ══════════════════════════════════════════════════════════════
local function cutscene(title, sub, color, hold)
	hold = hold or 2.2
	local sg = player.PlayerGui:FindFirstChild("ShinigamiUI")
	if not sg then return end

	local frame = Instance.new("Frame")
	frame.Size                  = UDim2.fromScale(1, 1)
	frame.BackgroundColor3      = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel       = 0
	frame.ZIndex                = 200
	frame.Parent                = sg
	tw(frame, TweenInfo.new(0.18), { BackgroundTransparency = 0.1 })

	local function bar(anchorBot)
		local b = Instance.new("Frame", frame)
		b.Size               = UDim2.new(1, 0, 0, 0)
		b.BackgroundColor3   = Color3.new(0, 0, 0)
		b.BorderSizePixel    = 0
		b.ZIndex             = 201
		if anchorBot then
			b.Position = UDim2.new(0, 0, 1, 0)
		end
		tw(b, TweenInfo.new(0.48, Enum.EasingStyle.Quint),
			anchorBot
				and { Size = UDim2.new(1, 0, 0, 92), Position = UDim2.new(0, 0, 1, -92) }
				or  { Size = UDim2.new(1, 0, 0, 92) })
		return b
	end
	bar(false); bar(true)

	task.wait(0.32)

	local line = Instance.new("Frame", frame)
	line.Size              = UDim2.new(0, 0, 0, 2)
	line.AnchorPoint       = Vector2.new(0.5, 0.5)
	line.Position          = UDim2.new(0.5, 0, 0.5, -1)
	line.BackgroundColor3  = color
	line.BorderSizePixel   = 0
	line.ZIndex            = 202
	tw(line, TweenInfo.new(0.5, Enum.EasingStyle.Expo), { Size = UDim2.new(0.62, 0, 0, 2) })

	task.wait(0.18)

	local function lbl(text, size, yOff, font, useStroke)
		local l = Instance.new("TextLabel", frame)
		l.Size               = UDim2.new(1, 0, 0, size + 10)
		l.Position           = UDim2.new(0, 0, 0.5, yOff)
		l.BackgroundTransparency = 1
		l.Text               = text
		l.Font               = font or Enum.Font.GothamBold
		l.TextSize           = size
		l.TextColor3         = Color3.new(1, 1, 1)
		l.TextTransparency   = 1
		l.ZIndex             = 203
		if useStroke then
			l.TextStrokeColor3      = color
			l.TextStrokeTransparency = 0.15
		end
		return l
	end

	local t1 = lbl(title,  62, -82, Enum.Font.GothamBold, true)
	local t2 = lbl(sub or "", 21, 22, Enum.Font.Gotham,    false)
	t2.TextColor3 = color

	tw(t1, TweenInfo.new(0.52, Enum.EasingStyle.Back), { TextTransparency = 0 })
	task.wait(0.22)
	tw(t2, TweenInfo.new(0.4),  { TextTransparency = 0 })

	task.wait(hold)
	for _, o in ipairs(frame:GetDescendants()) do
		pcall(function()
			tw(o, TweenInfo.new(0.3), { BackgroundTransparency = 1, TextTransparency = 1 })
		end)
	end
	tw(frame, TweenInfo.new(0.35), { BackgroundTransparency = 1 })
	db(frame, 0.5)
end

-- ══════════════════════════════════════════════════════════════
--  AURA SİSTEMİ
-- ══════════════════════════════════════════════════════════════
local AURA = {
	V1 = { color = Color3.fromRGB(80,  120, 255), n = 4, r = 2.8, spd = 1.4, sz = 0.38 },
	V2 = { color = Color3.fromRGB(170, 55,  255), n = 6, r = 3.4, spd = 2.0, sz = 0.48 },
	V3 = { color = Color3.fromRGB(255, 38,  38),  n = 9, r = 4.2, spd = 2.5, sz = 0.62 },
}

local auraConn, auraOrbs = nil, {}

local function stopAura()
	if auraConn then auraConn:Disconnect(); auraConn = nil end
	for _, o in ipairs(auraOrbs) do
		if o.Parent then o:Destroy() end
	end
	auraOrbs = {}
end

local function startAura(version)
	stopAura()
	local cfg = AURA[version] or AURA.V1

	for i = 1, cfg.n do
		local orb = part({
			Color        = cfg.color,
			Size         = Vector3.new(cfg.sz, cfg.sz, cfg.sz),
			Transparency = 0.28,
			Shape        = Enum.PartType.Ball,
		})
		-- İç parlaklık gölgesi
		part({
			Color        = cfg.color:Lerp(Color3.new(1, 1, 1), 0.38),
			Size         = Vector3.new(cfg.sz * 2.6, cfg.sz * 2.6, cfg.sz * 2.6),
			Transparency = 0.72,
			Shape        = Enum.PartType.Ball,
			Parent       = orb,
		})
		table.insert(auraOrbs, orb)
	end

	local t = 0
	auraConn = RunService.Heartbeat:Connect(function(dt)
		t += dt
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		for i, orb in ipairs(auraOrbs) do
			if not orb.Parent then continue end
			local ph  = (math.pi * 2 / cfg.n) * (i - 1)
			local ang = t * cfg.spd + ph
			local h   = math.sin(t * 1.8 + ph) * 1.6
			local pos = root.Position + Vector3.new(
				math.cos(ang) * cfg.r, h + 2.0, math.sin(ang) * cfg.r)
			orb.CFrame = CFrame.new(pos)
			local g = orb:FindFirstChildOfClass("Part")
			if g then g.CFrame = orb.CFrame end
		end

		-- V2: mor kıvılcımlar
		if version == "V2" and math.random() < 0.04 then
			local root2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root2 then
				local sp = part({
					Color        = cfg.color,
					Size         = Vector3.new(0.15, 0.15, 0.15),
					Transparency = 0.15,
					Shape        = Enum.PartType.Ball,
					CFrame       = CFrame.new(root2.Position
					               + Vector3.new((math.random() - 0.5) * 4, 0.1, (math.random() - 0.5) * 4)),
				})
				tw(sp, TweenInfo.new(0.5), {
					CFrame       = sp.CFrame + Vector3.new(0, math.random() * 4 + 1, 0),
					Transparency = 1,
					Size         = Vector3.new(0.02, 0.02, 0.02),
				})
				db(sp, 0.55)
			end
		end

		-- V3: kırmızı/turuncu kor kıvılcımlar
		if version == "V3" and math.random() < 0.07 then
			local root2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root2 then
				local col = math.random() < 0.5
					and Color3.fromRGB(255, 38,  38)
					or  Color3.fromRGB(255, 160, 30)
				local sp = part({
					Color        = col,
					Size         = Vector3.new(0.18, 0.18, 0.18),
					Transparency = 0.12,
					Shape        = Enum.PartType.Ball,
					CFrame       = CFrame.new(root2.Position
					               + Vector3.new((math.random() - 0.5) * 5.5, 0.1, (math.random() - 0.5) * 5.5)),
				})
				tw(sp, TweenInfo.new(0.48), {
					CFrame       = sp.CFrame + Vector3.new(0, math.random() * 4.5 + 1, 0),
					Transparency = 1,
					Size         = Vector3.new(0.02, 0.02, 0.02),
				})
				db(sp, 0.52)
			end
		end
	end)
end

-- ══════════════════════════════════════════════════════════════
--  V3 HOGYOKU CANAVAR DÖNÜŞÜMÜ
-- ══════════════════════════════════════════════════════════════
local function hogyokuTransform(char)
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local pos = root.Position

	playSound(SOUNDS.hogyoku, 1.1, 0.9, pos)
	cutscene("HOGYOKU FÜZYONU", "Tam Dönüşüm", Color3.fromRGB(255, 25, 25), 3.2)
	shake(0.42, 3.8)
	lFlash(Color3.fromRGB(75, 0, 0), 0.38)

	-- İçe çöken halkalar
	for i = 1, 12 do
		task.delay(i * 0.08, function()
			ring(pos, Color3.fromRGB(185, 0, 0), 22 - i * 1.7, 1, 0.6, 0.38)
		end)
	end

	-- Büyüyen karanlık çekirdek
	local core = part({
		Color        = Color3.fromRGB(16, 0, 26),
		Size         = Vector3.new(1, 1, 1),
		Transparency = 0.04,
		Shape        = Enum.PartType.Ball,
		CFrame       = CFrame.new(pos + Vector3.new(0, 3, 0)),
	})
	tw(core, TweenInfo.new(1.8, Enum.EasingStyle.Quad), {
		Size         = Vector3.new(20, 20, 20),
		Transparency = 0.2,
	})

	-- Spiral yörüngeli toplar dönüşüm sırasında
	spawnSpiralOrbs(pos + Vector3.new(0, 3, 0), Color3.fromRGB(200, 20, 255), 6, 7, 2.5, 1.8)

	task.wait(1.8)

	playSound(SOUNDS.explosion, 1.2, 0.8, pos)
	shake(0.6, 2.8)
	lFlash(Color3.fromRGB(110, 0, 0), 0.55)

	tw(core, TweenInfo.new(0.28, Enum.EasingStyle.Back), {
		Size         = Vector3.new(38, 38, 38),
		Transparency = 1,
	})
	db(core, 0.35)

	burst(pos + Vector3.new(0, 3, 0), Color3.fromRGB(255, 35, 35),  280, 65, 3.2, 0.68, 0.06)
	burst(pos + Vector3.new(0, 3, 0), Color3.fromRGB(255, 160, 0),  145, 48, 2.6, 0.52, 0.05)
	burst(pos + Vector3.new(0, 3, 0), Color3.fromRGB(140, 0,   230), 100, 42, 2.2, 0.42, 0.04)

	sphere(pos + Vector3.new(0, 2, 0), Color3.fromRGB(255, 28, 28), 60, 1.8, 0.07)
	sphere(pos + Vector3.new(0, 2, 0), Color3.fromRGB(205, 0,  0),  40, 1.2, 0.05)

	for i = 1, 16 do
		task.delay(i * 0.09, function()
			ring(pos, Color3.fromRGB(255, 45, 45), 1, 7 + i * 5, 1.5)
		end)
	end

	for i = 1, 12 do
		task.delay(0.1 + i * 0.08, function()
			local a = math.rad(i * 30)
			pillar(pos + Vector3.new(math.cos(a) * 12, 0, math.sin(a) * 12),
				Color3.fromRGB(225, 25, 25), 3, 36, 2.8)
		end)
	end

	for i = 1, 10 do
		task.delay(i * 0.14, function()
			local a = math.rad(i * 36 + math.random() * 28)
			lightning(
				pos + Vector3.new(math.cos(a) * 10, 34, math.sin(a) * 10),
				pos + Vector3.new(math.cos(a) * 10, 0,  math.sin(a) * 10),
				Color3.fromRGB(255, 75, 75), 18, 0.42)
		end)
	end

	-- Hogyoku topu (yukarıda yüzer)
	task.delay(0.9, function()
		local hog = part({
			Color        = Color3.fromRGB(200, 20, 255),
			Size         = Vector3.new(2.5, 2.5, 2.5),
			Transparency = 0.05,
			Shape        = Enum.PartType.Ball,
			CFrame       = CFrame.new(pos + Vector3.new(0, 7, 0)),
		})
		local pt = 0
		local hConn
		hConn = RunService.Heartbeat:Connect(function(dt)
			pt += dt
			if not hog.Parent then hConn:Disconnect() return end
			hog.CFrame = CFrame.new(pos + Vector3.new(0, 7 + math.sin(pt * 2.2) * 0.45, 0))
		end)
		task.delay(3.5, function()
			hConn:Disconnect()
			if hog.Parent then
				tw(hog, TweenInfo.new(0.6), {
					Transparency = 1,
					Size         = Vector3.new(0.1, 0.1, 0.1),
				})
				db(hog, 0.7)
			end
		end)
	end)

	task.delay(0.65, function() startAura("V3") end)
end

-- ══════════════════════════════════════════════════════════════
--  V1 YETENEKLERİ — 3 ADET (Temel Güç)
-- ══════════════════════════════════════════════════════════════

-- Q: Zanpakuto Vuruşu
local function v1_Q(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position
	local fwd  = root.CFrame.LookVector

	playSound(SOUNDS.slash, 0.85, 1.1, pos)
	shake(0.07, 0.4)
	slash(pos + fwd * 2, fwd, Color3.fromRGB(140, 175, 255), 5, 8, 55)
	burst(pos + fwd * 5, Color3.fromRGB(100, 145, 255), 22, 14, 0.48, 0.28, 0.04)
	ring(pos, Color3.fromRGB(80, 120, 255), 0.5, 6, 0.5)
end

-- E: Hadō #4 Byakurai (beyaz şimşek)
local function v1_E(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position
	local fwd  = root.CFrame.LookVector

	playSound(SOUNDS.beam, 0.9, 1.2, pos)
	shake(0.09, 0.55)
	beam(pos + fwd * 2 + Vector3.new(0, 1.4, 0), fwd,
		Color3.fromRGB(210, 215, 255), 1.4, 48, 0.58)
	lightning(
		pos + fwd * 6 + Vector3.new(0, 10, 0),
		pos + fwd * 6,
		Color3.fromRGB(200, 215, 255), 11, 0.32)
	burst(pos + fwd * 46, Color3.fromRGB(215, 220, 255), 30, 16, 0.58, 0.34, 0.05)
end

-- R: Kyoka Suigetsu (V1 — illüzyon darbesi)
local function v1_R(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position

	playSound(SOUNDS.hypnosis, 0.9, 1.0, pos)
	cutscene("Kyoka Suigetsu", "Kır...", Color3.fromRGB(160, 95, 255), 1.8)
	shake(0.14, 1.2)
	lFlash(Color3.fromRGB(32, 0, 65), 0.16)

	for i = 1, 7 do task.delay(i * 0.1, function()
		ring(pos, Color3.fromRGB(160, 75, 255), 1 + i, 4 + i * 2.8, 0.98)
	end) end

	burst(pos, Color3.fromRGB(180, 100, 255), 65, 24, 1.15, 0.44, 0.06)
	burst(pos + Vector3.new(0, 1.6, 0), Color3.fromRGB(120, 55, 200), 35, 18, 0.88, 0.32, 0.04)

	for i = 1, 6 do task.delay(i * 0.11, function()
		local a = math.rad(i * 60)
		slash(
			pos + Vector3.new(math.cos(a) * 4, 1, math.sin(a) * 4),
			Vector3.new(math.cos(a), 0, math.sin(a)),
			Color3.fromRGB(200, 150, 255), 3, 6, 42)
	end) end
end

-- ══════════════════════════════════════════════════════════════
--  V2 YETENEKLERİ — 5 ADET (TYBW Arc)
-- ══════════════════════════════════════════════════════════════

-- Q: Güçlendirilmiş Vuruş (üç katmanlı)
local function v2_Q(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position
	local fwd  = root.CFrame.LookVector

	playSound(SOUNDS.slash, 1.0, 0.9, pos)
	shake(0.12, 0.68)

	for i = -1, 1 do task.delay(math.abs(i) * 0.07, function()
		slash(pos + fwd * 2 + Vector3.new(i * 1.0, 0, 0), fwd,
			Color3.fromRGB(178, 72, 255), 6, 12, 65)
	end) end

	burst(pos + fwd * 7, Color3.fromRGB(200, 95, 255), 42, 22, 0.68, 0.38, 0.05)
	ring(pos, Color3.fromRGB(180, 58, 255), 1, 10, 0.72)
	pillar(pos + fwd * 9, Color3.fromRGB(160, 55, 240), 2.4, 15, 0.68)
end

-- E: Hadō #63 Raikoho (gök gürültüsü topu)
local function v2_E(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position
	local fwd  = root.CFrame.LookVector

	playSound(SOUNDS.power_up, 0.9, 1.1, pos)
	shake(0.17, 1.0)
	lFlash(Color3.fromRGB(32, 0, 68), 0.2)

	-- Şarj topu
	local ch = part({
		Color        = Color3.fromRGB(155, 55, 255),
		Size         = Vector3.new(1, 1, 1),
		Transparency = 0.18,
		Shape        = Enum.PartType.Ball,
		CFrame       = CFrame.new(pos + fwd * 2 + Vector3.new(0, 1.5, 0)),
	})
	tw(ch, TweenInfo.new(0.34, Enum.EasingStyle.Back), { Size = Vector3.new(3.4, 3.4, 3.4) })
	task.wait(0.34)
	playSound(SOUNDS.beam, 1.0, 0.95, pos)
	tw(ch, TweenInfo.new(0.12), { Transparency = 1 }); db(ch, 0.15)

	beam(pos + fwd * 2 + Vector3.new(0, 1.5, 0), fwd,
		Color3.fromRGB(178, 75, 255), 3.2, 54, 0.72)

	for i = 1, 6 do task.delay(i * 0.07, function()
		lightning(
			pos + fwd * (5 + i * 5) + Vector3.new(0, 10, 0),
			pos + fwd * (5 + i * 5),
			Color3.fromRGB(198, 98, 255), 11, 0.28)
	end) end

	burst(pos + fwd * 52, Color3.fromRGB(200, 98, 255), 70, 32, 1.0, 0.48, 0.05)
	sphere(pos + fwd * 52, Color3.fromRGB(180, 55, 255), 18, 0.9, 0.2)
end

-- R: Kyoka Suigetsu TYBW (gelişmiş illüzyon fırtınası)
local function v2_R(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position

	playSound(SOUNDS.hypnosis, 1.0, 0.85, pos)
	cutscene("Kyoka Suigetsu", "Mükemmel Hipnoz", Color3.fromRGB(198, 72, 255), 2.2)
	shake(0.22, 1.7)
	lFlash(Color3.fromRGB(44, 0, 88), 0.24)

	for i = 1, 12 do task.delay(i * 0.09, function()
		ring(pos, Color3.fromRGB(178, 55, 255), 1, 5 + i * 4, 1.28)
	end) end

	burst(pos, Color3.fromRGB(200, 75, 255), 118, 38, 1.7, 0.54, 0.06)
	burst(pos + Vector3.new(0, 2, 0), Color3.fromRGB(130, 38, 255), 70, 28, 1.4, 0.44, 0.05)
	sphere(pos, Color3.fromRGB(180, 55, 255), 34, 1.4, 0.1)

	for i = 1, 9 do task.delay(i * 0.09, function()
		local a = math.rad(i * 40)
		slash(
			pos + Vector3.new(math.cos(a) * 7, 1, math.sin(a) * 7),
			Vector3.new(math.cos(a), 0, math.sin(a)),
			Color3.fromRGB(218, 138, 255), 4, 10, 54)
	end) end
end

-- F: Hadō #90 Kurohitsugi (kara tabut)
local function v2_F(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position
	local fwd  = root.CFrame.LookVector

	playSound(SOUNDS.dark_pulse, 1.0, 0.88, pos)
	cutscene("Hadō #90", "Kurohitsugi — Kara Tabut", Color3.fromRGB(55, 0, 120), 2.3)
	shake(0.26, 2.0)
	lFlash(Color3.fromRGB(14, 0, 35), 0.3)

	for i = 1, 8 do task.delay(i * 0.09, function()
		ring(pos, Color3.fromRGB(50, 0, 110), 17 - i * 1.9, 1, 0.52, 0.4)
	end) end

	task.wait(0.68)
	playSound(SOUNDS.beam, 1.0, 0.8, pos)
	beam(pos + fwd * 2 + Vector3.new(0, 1.5, 0), fwd,
		Color3.fromRGB(78, 0, 190), 5.0, 58, 1.0)

	task.delay(0.44, function()
		local hit = pos + fwd * 55
		playSound(SOUNDS.explosion, 1.1, 0.85, hit)

		for i = 1, 14 do
			shard(
				hit + Vector3.new(
					(math.random() - 0.5) * 16,
					(math.random() - 0.5) * 10 + 5,
					(math.random() - 0.5) * 16),
				Color3.fromRGB(18, 0, 40), 4.2, 1.1)
		end

		shake(0.32, 1.2)
		sphere(hit, Color3.fromRGB(65, 0, 155), 26, 1.2, 0.1)
		burst(hit, Color3.fromRGB(108, 0, 220), 95, 40, 1.4, 0.54, 0.06)

		for i = 1, 8 do task.delay(i * 0.1, function()
			ring(hit, Color3.fromRGB(55, 0, 130), 1, 5 + i * 4.5, 1.1)
		end) end
	end)
end

-- Z: Fragor (yıkıcı şok dalgası)
local function v2_Z(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position
	local fwd  = root.CFrame.LookVector

	playSound(SOUNDS.explosion, 0.9, 1.05, pos)
	shake(0.24, 1.6)

	for i = 1, 9 do task.delay(i * 0.07, function()
		ring(pos, Color3.fromRGB(198, 72, 255), 1, 8 + i * 4.5, 1.08)
	end) end

	local wave = part({
		Color        = Color3.fromRGB(178, 55, 255),
		Size         = Vector3.new(14, 14, 0.4),
		Transparency = 0.07,
		CFrame       = CFrame.new(pos, pos + fwd) * CFrame.new(0, 1.5, -3),
	})
	tw(wave, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
		CFrame       = CFrame.new(pos + fwd * 48, pos + fwd * 49) * CFrame.new(0, 1.5, 0),
		Size         = Vector3.new(22, 22, 0.4),
		Transparency = 0.78,
	})
	db(wave, 0.68)

	slash(pos + fwd * 5, fwd, Color3.fromRGB(210, 120, 255), 10, 16, 74)
	burst(pos + fwd * 46, Color3.fromRGB(200, 75, 255), 82, 35, 1.3, 0.55, 0.06)
	pillar(pos + fwd * 46, Color3.fromRGB(178, 55, 255), 4.0, 22, 1.2)
end

-- ══════════════════════════════════════════════════════════════
--  V3 YETENEKLERİ — 6 ADET (Hogyoku Canavar Formu)
-- ══════════════════════════════════════════════════════════════

-- Q: Hogyoku Vuruşu (gerçekliği yırtan)
local function v3_Q(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position
	local fwd  = root.CFrame.LookVector

	playSound(SOUNDS.slash, 1.1, 0.82, pos)
	shake(0.16, 0.78)

	for i = 1, 12 do task.delay(i * 0.04, function()
		slash(
			pos + fwd * 2 + Vector3.new(
				(math.random() - 0.5) * 2.8,
				(math.random() - 0.5) * 2, 0),
			fwd, Color3.fromRGB(255, 52, 52), 5, 14, 70)
	end) end

	burst(pos + fwd * 9, Color3.fromRGB(255, 72,  72),  62, 32, 0.9, 0.46, 0.05)
	burst(pos + fwd * 9, Color3.fromRGB(255, 195, 45),  36, 22, 0.68, 0.32, 0.04)
	ring(pos, Color3.fromRGB(255, 45, 45), 2, 17, 0.75)
	spawnSpiralOrbs(pos, Color3.fromRGB(255, 60, 60), 3, 3, 1.2, 0.8)
end

-- E: Hogyoku Işını (kıyamet ışını)
local function v3_E(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position
	local fwd  = root.CFrame.LookVector

	playSound(SOUNDS.power_up, 1.1, 0.78, pos)
	shake(0.3, 1.4)
	lFlash(Color3.fromRGB(90, 0, 0), 0.24)
	sphere(pos + Vector3.new(0, 2, 0), Color3.fromRGB(255, 45, 45), 10, 0.58, 0.1)
	spawnSpiralOrbs(pos, Color3.fromRGB(255, 80, 80), 4, 4, 1.5, 0.55)

	task.wait(0.55)
	playSound(SOUNDS.beam, 1.2, 0.75, pos)
	beam(pos + fwd * 2 + Vector3.new(0, 1.5, 0), fwd,
		Color3.fromRGB(255, 36, 36), 6, 65, 0.95)

	for _, s in ipairs({ -1, 1 }) do
		task.delay(0.1, function()
			beam(
				pos + fwd * 2 + Vector3.new(0, 1.5, 0),
				(CFrame.Angles(0, math.rad(s * 22), 0) * fwd).Unit,
				Color3.fromRGB(220, 72, 72), 2.4, 55, 0.8)
		end)
	end

	task.delay(0.55, function()
		local hit = pos + fwd * 63
		playSound(SOUNDS.explosion, 1.3, 0.72, hit)
		sphere(hit, Color3.fromRGB(255, 25, 25), 42, 1.4, 0.07)
		burst(hit, Color3.fromRGB(255, 55,  55),  180, 60, 2.4, 0.65, 0.06)
		burst(hit, Color3.fromRGB(255, 195, 45),   95, 42, 1.8, 0.50, 0.05)
		shake(0.46, 1.7)
		lFlash(Color3.fromRGB(112, 0, 0), 0.35)
		for i = 1, 18 do task.delay(i * 0.09, function()
			ring(hit, Color3.fromRGB(255, 45, 45), 1, 6 + i * 5.2, 1.4)
		end) end
	end)
end

-- R: Mutlak Hipnoz (tam alan kontrolü)
local function v3_R(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position

	playSound(SOUNDS.hypnosis, 1.2, 0.78, pos)
	cutscene("Kyoka Suigetsu", "MUTLAK HİPNOZ", Color3.fromRGB(255, 35, 35), 2.6)
	shake(0.32, 2.4)
	lFlash(Color3.fromRGB(88, 0, 0), 0.3)

	for i = 1, 20 do task.delay(i * 0.09, function()
		ring(pos, Color3.fromRGB(255, 55, 55), 1, 6 + i * 5.5, 1.7)
	end) end

	sphere(pos, Color3.fromRGB(255, 25, 25), 52, 2.0, 0.05)
	burst(pos, Color3.fromRGB(255, 45,  45),  210, 62, 2.9, 0.65, 0.06)
	burst(pos + Vector3.new(0, 2, 0),
		Color3.fromRGB(255, 175, 45), 115, 45, 2.4, 0.55, 0.05)
	spawnSpiralOrbs(pos, Color3.fromRGB(255, 50, 50), 8, 9, 2.5, 2.2)

	for i = 1, 14 do task.delay(i * 0.09, function()
		local a = math.rad(i * 26)
		slash(
			pos + Vector3.new(math.cos(a) * 9, 1, math.sin(a) * 9),
			Vector3.new(math.cos(a), 0, math.sin(a)),
			Color3.fromRGB(255, 95, 95), 5, 13, 60)
		pillar(
			pos + Vector3.new(math.cos(a) * 12, 0, math.sin(a) * 12),
			Color3.fromRGB(220, 25, 25), 2.4, 28, 1.8)
	end) end
end

-- F: Kurohitsugi Tam Serbest Bırakma
local function v3_F(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position
	local fwd  = root.CFrame.LookVector

	playSound(SOUNDS.dark_pulse, 1.2, 0.72, pos)
	cutscene("Hadō #90", "TAM SERBEST BIRAKILMA — KUROHİTSUGİ",
		Color3.fromRGB(28, 0, 80), 2.9)
	shake(0.42, 2.9)
	lFlash(Color3.fromRGB(18, 0, 58), 0.46)

	for i = 1, 12 do task.delay(i * 0.09, function()
		ring(pos, Color3.fromRGB(40, 0, 110), 22 - i * 1.7, 1, 0.6, 0.38)
	end) end

	task.wait(1.0)
	playSound(SOUNDS.beam, 1.2, 0.7, pos)

	for idx, off in ipairs({ 0, -24, 24, -12, 12 }) do
		task.delay((idx - 1) * 0.09, function()
			beam(
				pos + Vector3.new(0, 1.5, 0),
				(CFrame.Angles(0, math.rad(off), 0) * fwd).Unit,
				Color3.fromRGB(62, 0, 172), 5.5, 70, 1.1)
		end)
	end

	task.delay(0.92, function()
		local hit = pos + fwd * 68
		playSound(SOUNDS.explosion, 1.4, 0.68, hit)

		for i = 1, 28 do
			shard(
				hit + Vector3.new(
					(math.random() - 0.5) * 24,
					(math.random() - 0.5) * 16 + 9,
					(math.random() - 0.5) * 24),
				Color3.fromRGB(14, 0, 34), 5.8, 1.4)
		end

		shake(0.6, 2.4)
		sphere(hit, Color3.fromRGB(62, 0, 192), 58, 2.1, 0.07)
		burst(hit, Color3.fromRGB(82,  0, 220), 245, 75, 3.5, 0.75, 0.06)
		burst(hit, Color3.fromRGB(185, 0, 255), 125, 52, 2.4, 0.55, 0.05)

		for i = 1, 25 do task.delay(i * 0.09, function()
			ring(hit, Color3.fromRGB(62, 0, 162), 1, 7 + i * 5.5, 1.7)
		end) end
	end)
end

-- Z: Hogyoku Yeniden Yapılandırma (diken alanı)
local function v3_Z(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position

	playSound(SOUNDS.explosion, 1.1, 0.88, pos)
	shake(0.35, 2.2)
	lFlash(Color3.fromRGB(88, 0, 0), 0.34)

	for i = 1, 20 do task.delay(i * 0.07, function()
		local a = math.rad(i * 18)
		local r = 4 + i * 1.4
		local sp = part({
			Color        = Color3.fromRGB(210, 25, 25),
			Size         = Vector3.new(1.7, 0.2, 1.7),
			Transparency = 0.18,
			CFrame       = CFrame.new(pos + Vector3.new(math.cos(a) * r, 0.15, math.sin(a) * r)),
		})
		tw(sp, TweenInfo.new(0.32, Enum.EasingStyle.Back), {
			Size   = Vector3.new(1.7, 16 + i * 0.9, 1.7),
			CFrame = CFrame.new(pos + Vector3.new(math.cos(a) * r, 8 + i * 0.45, math.sin(a) * r)),
		})
		task.delay(0.65, function()
			if sp.Parent then
				tw(sp, TweenInfo.new(0.42), {
					Transparency = 1,
					Size         = Vector3.new(0.08, 0.08, 0.08),
				})
			end
		end)
		db(sp, 1.3)
	end) end

	burst(pos, Color3.fromRGB(255, 45, 45), 148, 50, 2.1, 0.55, 0.06)
	sphere(pos, Color3.fromRGB(230, 25, 25), 44, 1.7, 0.1)
	spawnSpiralOrbs(pos, Color3.fromRGB(255, 60, 60), 5, 10, 3, 1.8)
end

-- X: BANKAI — Kannonbiraki Benihime Aratame (Canavar Form Ultimi)
local function v3_X(char)
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local pos  = root.Position

	playSound(SOUNDS.bankai, 1.3, 0.82, pos)
	cutscene("BANKAI", "Kannonbiraki Benihime Aratame",
		Color3.fromRGB(255, 22, 22), 3.4)
	shake(0.65, 5.0)
	lFlash(Color3.fromRGB(120, 0, 0), 0.6)

	for i = 1, 24 do task.delay(i * 0.1, function()
		ring(pos, Color3.fromRGB(255, 45, 45), 1, 8 + i * 7, 2.4)
		if i % 3 == 0 then
			local a = math.rad(i * 15)
			pillar(
				pos + Vector3.new(math.cos(a) * 14, 0, math.sin(a) * 14),
				Color3.fromRGB(255, 25, 25), 4.2, 48, 3.2)
		end
	end) end

	spawnSpiralOrbs(pos, Color3.fromRGB(255, 50,  50), 10, 12, 4,  4.5)
	spawnSpiralOrbs(pos, Color3.fromRGB(255, 160, 30),  6,  8, 3,  3.8)

	burst(pos, Color3.fromRGB(255, 25,  25),  360, 92, 5.0, 0.88, 0.07)
	burst(pos, Color3.fromRGB(255, 175, 45),  220, 72, 3.8, 0.70, 0.06)
	burst(pos, Color3.fromRGB(215, 0,   255), 145, 60, 3.2, 0.58, 0.05)

	sphere(pos, Color3.fromRGB(255, 25,  25), 82, 3.5, 0.06)
	sphere(pos, Color3.fromRGB(255, 100,  0), 55, 2.4, 0.10)
	sphere(pos, Color3.fromRGB(200, 0,  255), 38, 1.8, 0.15)

	for i = 1, 28 do task.delay(i * 0.15, function()
		lightning(
			pos + Vector3.new((math.random() - 0.5) * 40, 42, (math.random() - 0.5) * 40),
			pos + Vector3.new((math.random() - 0.5) * 24,  0, (math.random() - 0.5) * 24),
			Color3.fromRGB(255, 80, 80), 20, 0.44)
	end) end

	task.delay(1.5, function()
		playSound(SOUNDS.explosion, 1.4, 0.7, pos)
		shake(0.45, 2.0)
		lFlash(Color3.fromRGB(130, 0, 0), 0.4)
		for i = 1, 16 do task.delay(i * 0.08, function()
			ring(pos, Color3.fromRGB(255, 30, 30), 1, 10 + i * 8, 1.8)
		end) end
	end)
end

-- ══════════════════════════════════════════════════════════════
--  SKILL TABLOSU
-- ══════════════════════════════════════════════════════════════
local SKILLS = {
	V1 = { v1_Q, v1_E, v1_R },
	V2 = { v2_Q, v2_E, v2_R, v2_F, v2_Z },
	V3 = { v3_Q, v3_E, v3_R, v3_F, v3_Z, v3_X },
}

-- ─── Remote Dinleyiciler ──────────────────────────────────────
local currentVersion = "V1"

vfxRemote.OnClientEvent:Connect(function(charId, version, skillIdx, targetChar)
	if charId ~= "AIZEN" then return end
	local char = targetChar or player.Character
	if not char then return end
	local tbl = SKILLS[version]
	if tbl and tbl[skillIdx] then
		task.spawn(tbl[skillIdx], char)
	end
end)

charSelectedEvt.OnClientEvent:Connect(function(charId, version)
	if charId ~= "AIZEN" then return end
	currentVersion = version or "V1"
	task.delay(1.2, function() startAura(currentVersion) end)
end)

versionUpgEvt.OnClientEvent:Connect(function(charId, newVer)
	if charId ~= "AIZEN" then return end
	currentVersion = newVer
	stopAura()

	if newVer == "V3" then
		local char = player.Character
		if char then task.spawn(hogyokuTransform, char) end
	else
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local pos = root.Position
			playSound(SOUNDS.power_up, 1.0, 0.88, pos)
			cutscene("TYBW AIZEN", "Güç Uyanıyor", Color3.fromRGB(175, 55, 255), 2.1)
			shake(0.28, 2.0)
			lFlash(Color3.fromRGB(44, 0, 88), 0.32)
			burst(pos, Color3.fromRGB(178, 55, 255), 145, 52, 2.4, 0.55, 0.06)
			sphere(pos, Color3.fromRGB(160, 38, 255), 36, 1.7, 0.1)
			spawnSpiralOrbs(pos, Color3.fromRGB(178, 55, 255), 5, 5, 1.8, 1.8)
			for i = 1, 9 do task.delay(i * 0.1, function()
				ring(pos, Color3.fromRGB(178, 55, 255), 1, 5 + i * 4, 1.4)
			end) end
		end
		task.delay(0.95, function() startAura(newVer) end)
	end
end)

print("[ShinigamiLegends] AizenChar | V1:3 V2:5 V3:6 + CanvarForm + Ses ✓")
