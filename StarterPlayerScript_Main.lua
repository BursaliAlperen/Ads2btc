-- ============================================================
--  SHINIGAMI LEGENDS | StarterPlayerScript (Main LocalScript)
--  StarterPlayerScripts > Main
--
--  Özellikler:
--  ● Karanlık sinematik karakter seçim ekranı
--  ● V1:3 / V2:5 / V3:6 yetenek sayısına göre değişen HUD
--  ● Versiyon yükseltme paneli + gereksinim bilgisi
--  ● Coin & Kill takibi
--  ● CFrame tabanlı UI animasyonları
--  ● Admin popup mesaj sistemi
-- ============================================================

local Players          = game:GetService("Players")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local player    = Players.LocalPlayer
local playerGui = player.PlayerGui

-- ─── Remotes ──────────────────────────────────────────────────
local Remotes          = ReplicatedStorage:WaitForChild("Remotes")
local selectCharRemote = Remotes:WaitForChild("SelectCharacter")
local useSkillRemote   = Remotes:WaitForChild("UseSkill")
local upgradeRemote    = Remotes:WaitForChild("UpgradeCharacter")
local getDataRemote    = Remotes:WaitForChild("GetPlayerData")
local charSelectedEvt  = Remotes:WaitForChild("CharacterSelected")
local versionUpgEvt    = Remotes:WaitForChild("VersionUpgraded")
local adminMsgEvt      = Remotes:WaitForChild("AdminMessage")

-- ─── Renk Paleti ──────────────────────────────────────────────
local C = {
	bg      = Color3.fromRGB(4,   4,   12),
	panel   = Color3.fromRGB(9,   9,   22),
	panel2  = Color3.fromRGB(14,  14,  30),
	border  = Color3.fromRGB(30,  30,  58),
	accent  = Color3.fromRGB(115, 75,  255),
	gold    = Color3.fromRGB(255, 205, 70),
	red     = Color3.fromRGB(220, 55,  55),
	green   = Color3.fromRGB(80,  220, 120),
	text    = Color3.fromRGB(238, 232, 255),
	muted   = Color3.fromRGB(120, 112, 155),
	v1      = Color3.fromRGB(80,  125, 255),
	v2      = Color3.fromRGB(172, 58,  255),
	v3      = Color3.fromRGB(255, 42,  42),
	leg     = Color3.fromRGB(255, 205, 70),
}

-- ─── Yetenek Tanımları ────────────────────────────────────────
local SKILL_DEFS = {
	V1 = {
		{ key="Q", name="Zanpakuto Slash",  color=C.v1,                          cd=5  },
		{ key="E", name="Byakurai",          color=Color3.fromRGB(200,215,255),   cd=8  },
		{ key="R", name="Kyoka Suigetsu",    color=C.v2,                          cd=16 },
	},
	V2 = {
		{ key="Q", name="Empowered Slash",   color=C.v2,                          cd=5  },
		{ key="E", name="Raikoho",           color=Color3.fromRGB(190,100,255),   cd=9  },
		{ key="R", name="Kyoka Suigetsu II", color=C.v2,                          cd=15 },
		{ key="F", name="Kurohitsugi",       color=Color3.fromRGB(82,0,185),      cd=22 },
		{ key="Z", name="Fragor",            color=Color3.fromRGB(205,85,255),    cd=13 },
	},
	V3 = {
		{ key="Q", name="Hogyoku Slash",       color=C.v3,                        cd=4  },
		{ key="E", name="Hogyoku Beam",        color=Color3.fromRGB(255,80,80),   cd=9  },
		{ key="R", name="Absolute Hypnosis",   color=C.v3,                        cd=15 },
		{ key="F", name="Kurohitsugi Release", color=Color3.fromRGB(100,0,225),   cd=23 },
		{ key="Z", name="Reconstruction",      color=Color3.fromRGB(255,90,90),   cd=12 },
		{ key="X", name="★ BANKAI",            color=C.gold,                      cd=32 },
	},
}

-- ─── Karakter Verisi ──────────────────────────────────────────
local CHARS = {
	{
		id      = "AIZEN",
		name    = "Sosuke Aizen",
		desc    = "5. Bölük eski kaptanı.\nMükemmel hipnozun ustası.",
		rarity  = "LEGENDARY",
		rarityColor = C.leg,
		price   = 2500,
		icon    = "⚔",
		versions = {
			{ v="V1", label="Shinigami Arc",   color=C.v1, req="2.500 Coin",                        skills=3 },
			{ v="V2", label="TYBW Arc",        color=C.v2, req="10.000 Coin\n+ Hogyoku Parçası",    skills=5 },
			{ v="V3", label="Hogyoku Füzyonu", color=C.v3, req="25.000 Coin\n+ Hogyoku Füzyonu",    skills=6 },
		},
	},
	{ id="CS1", name="Yakında", desc="Yeni bir savaşçı geliyor...", rarity="KİLİTLİ", rarityColor=Color3.fromRGB(55,55,65), locked=true, icon="?" },
	{ id="CS2", name="Yakında", desc="Ölçülemez güç...",           rarity="KİLİTLİ", rarityColor=Color3.fromRGB(55,55,65), locked=true, icon="?" },
}

-- ─── Yardımcılar ──────────────────────────────────────────────
local function tw(obj, info, props)
	TweenService:Create(obj, info, props):Play()
end

local function inst(cls, props, parent)
	local o = Instance.new(cls)
	for k, v in pairs(props) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end

local function corner(r, parent)
	return inst("UICorner", { CornerRadius = UDim.new(0, r) }, parent)
end

local function stroke(color, thick, alpha, parent)
	return inst("UIStroke", { Color=color, Thickness=thick, Transparency=alpha or 0 }, parent)
end

local function grad(c0, c1, rot, parent)
	return inst("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, c0),
			ColorSequenceKeypoint.new(1, c1),
		}),
		Rotation = rot or 90,
	}, parent)
end

local function pulse(label, color, period)
	period = period or 1.4
	task.spawn(function()
		while label and label.Parent do
			tw(label, TweenInfo.new(period/2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ TextColor3 = color:Lerp(Color3.new(1,1,1), 0.38) })
			task.wait(period/2)
			if not label.Parent then break end
			tw(label, TweenInfo.new(period/2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ TextColor3 = color })
			task.wait(period/2)
		end
	end)
end

-- ─── ScreenGui ────────────────────────────────────────────────
local sg = inst("ScreenGui", {
	Name             = "ShinigamiUI",
	ResetOnSpawn     = false,
	ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
}, playerGui)

-- ══════════════════════════════════════════════════════════════
--  KARAKTERSEÇİM EKRANI
-- ══════════════════════════════════════════════════════════════
local selScreen = inst("Frame", {
	Name             = "SelectionScreen",
	Size             = UDim2.fromScale(1, 1),
	BackgroundColor3 = C.bg,
	BorderSizePixel  = 0,
	ZIndex           = 10,
}, sg)
grad(Color3.fromRGB(7, 4, 22), C.bg, 135, selScreen)

-- Yüzen yıldızlar (arka plan animasyonu)
local starCanvas = inst("Frame", {
	Size                 = UDim2.fromScale(1,1),
	BackgroundTransparency = 1,
	ZIndex               = 11,
}, selScreen)

task.spawn(function()
	while selScreen and selScreen.Parent and selScreen.Visible do
		task.wait(math.random() * 0.7 + 0.18)
		local star = inst("Frame", {
			Size             = UDim2.new(0, math.random(1,3), 0, math.random(1,3)),
			Position         = UDim2.new(math.random(), 0, math.random(), 0),
			BackgroundColor3 = Color3.fromRGB(
				180 + math.random()*75,
				170 + math.random()*85,
				255),
			BackgroundTransparency = 0.28 + math.random()*0.45,
			BorderSizePixel  = 0,
			ZIndex           = 12,
		}, starCanvas)
		corner(2, star)
		tw(star, TweenInfo.new(3 + math.random()*3, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1,
			Position = star.Position - UDim2.new(0, 0, 0.08 + math.random()*0.12, 0),
		})
		game:GetService("Debris"):AddItem(star, 7)
	end
end)

-- ─── ÜST BAR ──────────────────────────────────────────────────
local topBar = inst("Frame", {
	Name             = "TopBar",
	Size             = UDim2.new(1,0,0,74),
	BackgroundColor3 = C.panel,
	BackgroundTransparency = 0.08,
	BorderSizePixel  = 0,
	ZIndex           = 13,
}, selScreen)
grad(C.panel, Color3.fromRGB(6,5,20), 180, topBar)

-- Alt çizgi
inst("Frame", {
	Size             = UDim2.new(1,0,0,1),
	Position         = UDim2.new(0,0,1,-1),
	BackgroundColor3 = C.accent,
	BackgroundTransparency = 0.48,
	BorderSizePixel  = 0,
	ZIndex           = 14,
}, topBar)

local logoLabel = inst("TextLabel", {
	Size             = UDim2.new(0,540,1,0),
	Position         = UDim2.new(0,24,0,0),
	BackgroundTransparency = 1,
	Text             = "SHINIGAMI LEGENDS",
	Font             = Enum.Font.GothamBold,
	TextSize         = 40,
	TextColor3       = C.text,
	TextXAlignment   = Enum.TextXAlignment.Left,
	TextStrokeColor3 = C.accent,
	TextStrokeTransparency = 0.32,
	ZIndex           = 14,
}, topBar)

local subText = inst("TextLabel", {
	Size             = UDim2.new(0,360,0,22),
	Position         = UDim2.new(0,26,0,48),
	BackgroundTransparency = 1,
	Text             = "SAVAŞÇINI SEÇ",
	Font             = Enum.Font.Gotham,
	TextSize         = 13,
	TextColor3       = C.muted,
	TextXAlignment   = Enum.TextXAlignment.Left,
	ZIndex           = 14,
}, topBar)

-- Coin rozeti (sağ üst)
local coinBadge = inst("Frame", {
	Size             = UDim2.new(0,195,0,46),
	Position         = UDim2.new(1,-210,0,14),
	BackgroundColor3 = C.panel2,
	BackgroundTransparency = 0.1,
	BorderSizePixel  = 0,
	ZIndex           = 14,
}, topBar)
corner(14, coinBadge)
stroke(C.gold, 1.5, 0.42, coinBadge)

inst("TextLabel", {
	Size             = UDim2.new(0,38,1,0),
	BackgroundTransparency = 1,
	Text             = "🪙",
	TextSize         = 22,
	ZIndex           = 15,
}, coinBadge)

local coinLabel = inst("TextLabel", {
	Name             = "CoinLabel",
	Size             = UDim2.new(1,-42,1,0),
	Position         = UDim2.new(0,42,0,0),
	BackgroundTransparency = 1,
	Text             = "0",
	Font             = Enum.Font.GothamBold,
	TextSize         = 20,
	TextColor3       = C.gold,
	TextXAlignment   = Enum.TextXAlignment.Left,
	ZIndex           = 15,
}, coinBadge)

-- ─── KARTLAR ALANI ────────────────────────────────────────────
local cardsArea = inst("Frame", {
	Size             = UDim2.new(1,-32,0,390),
	Position         = UDim2.new(0,16,0,82),
	BackgroundTransparency = 1,
	ZIndex           = 12,
}, selScreen)
inst("UIListLayout", {
	FillDirection        = Enum.FillDirection.Horizontal,
	HorizontalAlignment  = Enum.HorizontalAlignment.Center,
	VerticalAlignment    = Enum.VerticalAlignment.Center,
	Padding              = UDim.new(0,18),
}, cardsArea)

-- ─── DETAY PANELİ (alt) ───────────────────────────────────────
local detailH = 238
local detailPanel = inst("Frame", {
	Name             = "DetailPanel",
	Size             = UDim2.new(1,-32,0,detailH),
	Position         = UDim2.new(0,16,1,-(detailH+14)),
	BackgroundColor3 = C.panel,
	BackgroundTransparency = 0.07,
	BorderSizePixel  = 0,
	ZIndex           = 12,
}, selScreen)
corner(22, detailPanel)
stroke(C.border, 1.5, 0.18, detailPanel)
grad(C.panel, Color3.fromRGB(7,6,22), 180, detailPanel)

-- Üst vurgu çizgisi
local accentLine = inst("Frame", {
	Size             = UDim2.new(0,0,0,2),
	Position         = UDim2.new(0.05,0,0,0),
	BackgroundColor3 = C.accent,
	BorderSizePixel  = 0,
	ZIndex           = 13,
}, detailPanel)
corner(2, accentLine)

-- Sol taraf: isim, nadirlik, açıklama
local detailName = inst("TextLabel", {
	Name             = "DetailName",
	Size             = UDim2.new(0.36,0,0,52),
	Position         = UDim2.new(0,22,0,14),
	BackgroundTransparency = 1,
	Text             = "Karakter Seç",
	Font             = Enum.Font.GothamBold,
	TextSize         = 30,
	TextColor3       = C.text,
	TextXAlignment   = Enum.TextXAlignment.Left,
	ZIndex           = 13,
}, detailPanel)

local detailRarity = inst("TextLabel", {
	Size             = UDim2.new(0.36,0,0,24),
	Position         = UDim2.new(0,22,0,62),
	BackgroundTransparency = 1,
	Text             = "",
	Font             = Enum.Font.GothamBold,
	TextSize         = 13,
	TextColor3       = C.gold,
	TextXAlignment   = Enum.TextXAlignment.Left,
	ZIndex           = 13,
}, detailPanel)

local detailDesc = inst("TextLabel", {
	Size             = UDim2.new(0.36,0,0,75),
	Position         = UDim2.new(0,22,0,90),
	BackgroundTransparency = 1,
	Text             = "",
	Font             = Enum.Font.Gotham,
	TextSize         = 13,
	TextColor3       = C.muted,
	TextXAlignment   = Enum.TextXAlignment.Left,
	TextYAlignment   = Enum.TextYAlignment.Top,
	TextWrapped      = true,
	ZIndex           = 13,
}, detailPanel)

-- Sağ taraf: versiyon kartları
local verFrame = inst("Frame", {
	Size             = UDim2.new(0.62,-16,1,-16),
	Position         = UDim2.new(0.38,8,0,8),
	BackgroundTransparency = 1,
	ZIndex           = 13,
}, detailPanel)
inst("UIListLayout", {
	FillDirection       = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment   = Enum.VerticalAlignment.Center,
	Padding             = UDim.new(0,12),
}, verFrame)

-- Seç düğmesi (sol alt)
local selectBtn = inst("TextButton", {
	Name             = "SelectBtn",
	Size             = UDim2.new(0.32,0,0,48),
	Position         = UDim2.new(0,22,1,-62),
	BackgroundColor3 = C.accent,
	BorderSizePixel  = 0,
	Text             = "▶  SAVAŞA GİR",
	Font             = Enum.Font.GothamBold,
	TextSize         = 15,
	TextColor3       = Color3.new(1,1,1),
	ZIndex           = 14,
}, detailPanel)
corner(14, selectBtn)
grad(Color3.fromRGB(138,88,255), Color3.fromRGB(88,48,200), 90, selectBtn)

selectBtn.MouseEnter:Connect(function()
	tw(selectBtn, TweenInfo.new(0.18), { BackgroundColor3=Color3.fromRGB(148,98,255) })
end)
selectBtn.MouseLeave:Connect(function()
	tw(selectBtn, TweenInfo.new(0.18), { BackgroundColor3=C.accent })
end)

-- ─── State ────────────────────────────────────────────────────
local selectedChar    = nil
local selectedVersion = "V1"
local cardFrames      = {}
local verBtns         = {}

-- ─── Versiyon Kartları ────────────────────────────────────────
local function buildVersionCards(charData)
	for _, b in pairs(verBtns) do b:Destroy() end
	verBtns = {}
	tw(accentLine, TweenInfo.new(0.5, Enum.EasingStyle.Expo), { Size = UDim2.new(0.88,0,0,2) })

	if not charData or charData.locked then return end

	for _, ver in ipairs(charData.versions or {}) do
		local isV1 = (ver.v == "V1")
		local card = inst("TextButton", {
			Name             = "Ver_"..ver.v,
			Size             = UDim2.new(0,175,1,-10),
			BackgroundColor3 = C.panel2,
			BackgroundTransparency = isV1 and 0 or 0.3,
			BorderSizePixel  = 0,
			Text             = "",
			ZIndex           = 14,
		}, verFrame)
		corner(18, card)
		local cs = stroke(ver.color, 1.8, isV1 and 0.05 or 0.5, card)

		-- Üst renk bandı
		local topClr = inst("Frame", {
			Size             = UDim2.new(1,0,0,3),
			BackgroundColor3 = ver.color,
			BackgroundTransparency = 0.35,
			BorderSizePixel  = 0,
			ZIndex           = 15,
		}, card)
		corner(4, topClr)

		-- Versiyon etiketi
		inst("TextLabel", {
			Size             = UDim2.new(1,0,0,42),
			Position         = UDim2.new(0,0,0,8),
			BackgroundTransparency = 1,
			Text             = ver.v,
			Font             = Enum.Font.GothamBold,
			TextSize         = 30,
			TextColor3       = ver.color,
			ZIndex           = 15,
		}, card)

		-- Arc etiketi
		inst("TextLabel", {
			Size             = UDim2.new(1,-12,0,32),
			Position         = UDim2.new(0,6,0,50),
			BackgroundTransparency = 1,
			Text             = ver.label,
			Font             = Enum.Font.GothamBold,
			TextSize         = 13,
			TextColor3       = C.text,
			TextWrapped      = true,
			ZIndex           = 15,
		}, card)

		-- Gereksinim
		inst("TextLabel", {
			Size             = UDim2.new(1,-12,0,52),
			Position         = UDim2.new(0,6,0,84),
			BackgroundTransparency = 1,
			Text             = ver.req,
			Font             = Enum.Font.Gotham,
			TextSize         = 11,
			TextColor3       = C.muted,
			TextWrapped      = true,
			ZIndex           = 15,
		}, card)

		-- Yetenek sayısı rozeti
		local sb = inst("Frame", {
			Size             = UDim2.new(0,100,0,26),
			Position         = UDim2.new(0.5,-50,1,-34),
			BackgroundColor3 = ver.color,
			BackgroundTransparency = 0.55,
			BorderSizePixel  = 0,
			ZIndex           = 15,
		}, card)
		corner(8, sb)
		inst("TextLabel", {
			Size             = UDim2.fromScale(1,1),
			BackgroundTransparency = 1,
			Text             = ver.skills .. " Yetenek",
			Font             = Enum.Font.GothamBold,
			TextSize         = 12,
			TextColor3       = Color3.new(1,1,1),
			ZIndex           = 16,
		}, sb)

		-- Kilit ikonu (V2/V3)
		if ver.v ~= "V1" then
			inst("TextLabel", {
				Size             = UDim2.new(0,26,0,26),
				Position         = UDim2.new(1,-30,0,6),
				BackgroundTransparency = 1,
				Text             = "🔒",
				TextSize         = 16,
				ZIndex           = 16,
			}, card)
		end

		card.MouseEnter:Connect(function()
			tw(card, TweenInfo.new(0.2), { BackgroundTransparency=0 })
			tw(cs,   TweenInfo.new(0.2), { Transparency=0 })
		end)
		card.MouseLeave:Connect(function()
			if selectedVersion ~= ver.v then
				tw(card, TweenInfo.new(0.2), { BackgroundTransparency=0.3 })
				tw(cs,   TweenInfo.new(0.2), { Transparency=0.5 })
			end
		end)
		card.MouseButton1Click:Connect(function()
			selectedVersion = ver.v
			for _, b2 in pairs(verBtns) do
				local s2 = b2:FindFirstChildOfClass("UIStroke")
				tw(b2, TweenInfo.new(0.18), { BackgroundTransparency=0.3 })
				if s2 then tw(s2, TweenInfo.new(0.18), { Transparency=0.5 }) end
			end
			tw(card, TweenInfo.new(0.18), { BackgroundTransparency=0 })
			tw(cs,   TweenInfo.new(0.18), { Transparency=0 })
		end)

		table.insert(verBtns, card)
	end
end

-- ─── Detay Güncelleme ─────────────────────────────────────────
local function updateDetail(charData)
	selectedChar    = charData
	selectedVersion = "V1"
	detailName.Text   = charData.name
	detailRarity.Text = "◆ " .. charData.rarity
	detailRarity.TextColor3 = charData.rarityColor
	detailDesc.Text   = charData.desc or ""
	buildVersionCards(charData)
	if charData.locked then
		selectBtn.Text             = "YAKINDA"
		selectBtn.BackgroundColor3 = Color3.fromRGB(30,28,40)
	else
		selectBtn.Text             = "▶  SAVAŞA GİR"
		selectBtn.BackgroundColor3 = C.accent
	end
end

-- ─── Karakter Kartları ────────────────────────────────────────
local CARD_W = 242

for _, ch in ipairs(CHARS) do
	local card = inst("TextButton", {
		Name             = "Card_"..ch.id,
		Size             = UDim2.new(0, CARD_W, 0, 368),
		BackgroundColor3 = C.panel,
		BackgroundTransparency = 0.05,
		BorderSizePixel  = 0,
		Text             = "",
		ZIndex           = 12,
	}, cardsArea)
	corner(22, card)
	local cs = stroke(ch.rarityColor, 2, ch.locked and 0.7 or 0.35, card)
	grad(C.panel, Color3.fromRGB(6,5,18), 180, card)

	-- Üst renkli bant
	local band = inst("Frame", {
		Size             = UDim2.new(1,0,0,4),
		BackgroundColor3 = ch.rarityColor,
		BackgroundTransparency = ch.locked and 0.9 or 0.2,
		BorderSizePixel  = 0,
		ZIndex           = 13,
	}, card)
	corner(4, band)

	-- Portre alanı
	local portrait = inst("Frame", {
		Size             = UDim2.new(1,-16,0,215),
		Position         = UDim2.new(0,8,0,12),
		BackgroundColor3 = ch.locked
			and Color3.fromRGB(12,10,22)
			or  ch.rarityColor:Lerp(C.bg, 0.88),
		BorderSizePixel  = 0,
		ZIndex           = 13,
	}, card)
	corner(16, portrait)

	-- İkon
	local iconLbl = inst("TextLabel", {
		Size             = UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		Text             = ch.icon or "?",
		Font             = Enum.Font.GothamBold,
		TextSize         = 88,
		TextColor3       = ch.locked
			and Color3.fromRGB(35,33,48)
			or  ch.rarityColor:Lerp(Color3.new(1,1,1), 0.35),
		ZIndex           = 14,
	}, portrait)
	if not ch.locked then
		pulse(iconLbl, ch.rarityColor:Lerp(Color3.new(1,1,1), 0.3), 2)
	end

	-- Nadirlik rozeti
	local badge = inst("Frame", {
		Size             = UDim2.new(0,118,0,26),
		Position         = UDim2.new(0,8,0,8),
		BackgroundColor3 = ch.rarityColor,
		BackgroundTransparency = ch.locked and 0.85 or 0.28,
		BorderSizePixel  = 0,
		ZIndex           = 15,
	}, portrait)
	corner(9, badge)
	inst("TextLabel", {
		Size             = UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		Text             = ch.rarity,
		Font             = Enum.Font.GothamBold,
		TextSize         = 11,
		TextColor3       = Color3.new(1,1,1),
		ZIndex           = 16,
	}, badge)

	-- İsim
	inst("TextLabel", {
		Size             = UDim2.new(1,-16,0,38),
		Position         = UDim2.new(0,8,0,232),
		BackgroundTransparency = 1,
		Text             = ch.name,
		Font             = Enum.Font.GothamBold,
		TextSize         = 18,
		TextColor3       = ch.locked and C.muted or C.text,
		TextXAlignment   = Enum.TextXAlignment.Left,
		TextWrapped      = true,
		ZIndex           = 13,
	}, card)

	-- Fiyat
	if not ch.locked and ch.price and ch.price > 0 then
		inst("TextLabel", {
			Size             = UDim2.new(1,-16,0,26),
			Position         = UDim2.new(0,8,0,268),
			BackgroundTransparency = 1,
			Text             = "🪙 " .. tostring(ch.price) .. " Coin (V1)",
			Font             = Enum.Font.GothamBold,
			TextSize         = 13,
			TextColor3       = C.gold,
			TextXAlignment   = Enum.TextXAlignment.Left,
			ZIndex           = 13,
		}, card)
	end

	-- Versiyon pillleri
	if not ch.locked and ch.versions then
		local pillRow = inst("Frame", {
			Size             = UDim2.new(1,-16,0,30),
			Position         = UDim2.new(0,8,0,300),
			BackgroundTransparency = 1,
			ZIndex           = 13,
		}, card)
		inst("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding       = UDim.new(0,6),
		}, pillRow)
		local pColors = { C.v1, C.v2, C.v3 }
		for vi, ver in ipairs(ch.versions) do
			local pill = inst("Frame", {
				Size             = UDim2.new(0,52,0,26),
				BackgroundColor3 = pColors[vi],
				BackgroundTransparency = 0.5,
				BorderSizePixel  = 0,
				ZIndex           = 14,
			}, pillRow)
			corner(8, pill)
			inst("TextLabel", {
				Size             = UDim2.fromScale(1,1),
				BackgroundTransparency = 1,
				Text             = ver.v,
				Font             = Enum.Font.GothamBold,
				TextSize         = 12,
				TextColor3       = Color3.new(1,1,1),
				ZIndex           = 15,
			}, pill)
		end
	end

	-- Hover / Tıklama
	card.MouseEnter:Connect(function()
		if not ch.locked then
			tw(card, TweenInfo.new(0.2), { BackgroundColor3=ch.rarityColor:Lerp(C.panel, 0.92) })
			tw(cs,   TweenInfo.new(0.2), { Transparency=0 })
		end
	end)
	card.MouseLeave:Connect(function()
		tw(card, TweenInfo.new(0.2), { BackgroundColor3=C.panel })
		tw(cs,   TweenInfo.new(0.2), { Transparency=ch.locked and 0.7 or 0.35 })
	end)
	card.MouseButton1Click:Connect(function()
		if ch.locked then return end
		for _, cf in pairs(cardFrames) do
			tw(cf, TweenInfo.new(0.18), { BackgroundColor3=C.panel })
		end
		tw(card, TweenInfo.new(0.18), { BackgroundColor3=ch.rarityColor:Lerp(C.panel, 0.86) })
		updateDetail(ch)
	end)
	cardFrames[ch.id] = card
end

-- ─── Seç Düğmesi ──────────────────────────────────────────────
selectBtn.MouseButton1Click:Connect(function()
	if not selectedChar or selectedChar.locked then return end
	selectCharRemote:FireServer(selectedChar.id, selectedVersion)
	tw(selScreen, TweenInfo.new(0.55, Enum.EasingStyle.Quad), { BackgroundTransparency=1 })
	task.wait(0.6)
	selScreen.Visible = false
end)

-- ══════════════════════════════════════════════════════════════
--  OYUN İÇİ HUD
-- ══════════════════════════════════════════════════════════════
local hudFrame = inst("Frame", {
	Name                 = "HUD",
	Size                 = UDim2.fromScale(1,1),
	BackgroundTransparency = 1,
	Visible              = false,
	ZIndex               = 5,
}, sg)

-- ─── HP Barı ──────────────────────────────────────────────────
local hpBg = inst("Frame", {
	Size             = UDim2.new(0,310,0,19),
	Position         = UDim2.new(0,18,1,-86),
	BackgroundColor3 = Color3.fromRGB(14,4,4),
	BackgroundTransparency = 0.15,
	BorderSizePixel  = 0,
	ZIndex           = 6,
}, hudFrame)
corner(9, hpBg)
stroke(Color3.fromRGB(40,10,10), 1, 0.6, hpBg)

local hpBar = inst("Frame", {
	Size             = UDim2.fromScale(1,1),
	BackgroundColor3 = Color3.fromRGB(55,200,55),
	BorderSizePixel  = 0,
	ZIndex           = 7,
}, hpBg)
corner(9, hpBar)
grad(Color3.fromRGB(80,220,80), Color3.fromRGB(40,170,40), 0, hpBar)

local hpLabel = inst("TextLabel", {
	Size             = UDim2.new(0,310,0,18),
	Position         = UDim2.new(0,18,1,-108),
	BackgroundTransparency = 1,
	Text             = "HP  250 / 250",
	Font             = Enum.Font.GothamBold,
	TextSize         = 13,
	TextColor3       = C.text,
	TextXAlignment   = Enum.TextXAlignment.Left,
	ZIndex           = 6,
}, hudFrame)

-- ─── YETENEKCUBUĞu ────────────────────────────────────────────
local skillBar = inst("Frame", {
	Name             = "SkillBar",
	Size             = UDim2.new(0,540,0,88),
	Position         = UDim2.new(0.5,-270,1,-106),
	BackgroundColor3 = C.panel,
	BackgroundTransparency = 0.2,
	BorderSizePixel  = 0,
	ZIndex           = 6,
}, hudFrame)
corner(20, skillBar)
stroke(C.border, 1.5, 0.3, skillBar)
grad(C.panel, Color3.fromRGB(6,5,18), 180, skillBar)

inst("UIListLayout", {
	FillDirection       = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment   = Enum.VerticalAlignment.Center,
	Padding             = UDim.new(0,8),
}, skillBar)

local skillSlots = {}
local cdConns    = {}

local function buildSkillBar(version)
	for _, c in pairs(cdConns)    do pcall(function() c:Disconnect() end) end
	for _, s in pairs(skillSlots) do if s.Parent then s:Destroy() end end
	cdConns    = {}
	skillSlots = {}

	local defs = SKILL_DEFS[version]
	if not defs then return end

	local slotW = 76
	local total = #defs * slotW + (#defs - 1) * 8 + 24
	tw(skillBar, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
		Size     = UDim2.new(0, total, 0, 88),
		Position = UDim2.new(0.5, -total/2, 1, -106),
	})

	for i, def in ipairs(defs) do
		local slot = inst("Frame", {
			Size             = UDim2.new(0, slotW, 0, 72),
			BackgroundColor3 = C.panel2,
			BackgroundTransparency = 0.08,
			BorderSizePixel  = 0,
			ZIndex           = 7,
		}, skillBar)
		corner(14, slot)
		stroke(def.color, 1.8, 0.25, slot)
		grad(def.color:Lerp(C.panel2, 0.82), C.panel2, 270, slot)

		-- Tuş etiketi
		inst("TextLabel", {
			Size             = UDim2.new(1,0,0,38),
			Position         = UDim2.new(0,0,0,4),
			BackgroundTransparency = 1,
			Text             = def.key,
			Font             = Enum.Font.GothamBold,
			TextSize         = 24,
			TextColor3       = def.color,
			ZIndex           = 8,
		}, slot)

		-- Yetenek adı
		inst("TextLabel", {
			Size             = UDim2.new(1,-4,0,22),
			Position         = UDim2.new(0,2,0,42),
			BackgroundTransparency = 1,
			Text             = def.name,
			Font             = Enum.Font.Gotham,
			TextSize         = 10,
			TextColor3       = C.muted,
			TextWrapped      = true,
			ZIndex           = 8,
		}, slot)

		-- Cooldown overlay
		local cdOv = inst("Frame", {
			Name             = "CDOverlay",
			Size             = UDim2.fromScale(1,0),
			Position         = UDim2.fromScale(0,1),
			BackgroundColor3 = Color3.new(0,0,0),
			BackgroundTransparency = 0.35,
			BorderSizePixel  = 0,
			ZIndex           = 9,
			Visible          = false,
		}, slot)
		corner(14, cdOv)

		local cdLabel = inst("TextLabel", {
			Size             = UDim2.new(1,0,0,40),
			Position         = UDim2.new(0,0,0,4),
			BackgroundTransparency = 1,
			Text             = "",
			Font             = Enum.Font.GothamBold,
			TextSize         = 22,
			TextColor3       = Color3.new(1,1,1),
			ZIndex           = 10,
		}, cdOv)

		slot._cdOverlay = cdOv
		slot._cdLabel   = cdLabel
		slot._key       = def.key
		slot._cd        = def.cd
		slot._index     = i
		table.insert(skillSlots, slot)
	end
end

-- Cooldown görsel geri bildirimi
local function triggerCooldownVFX(slotIndex)
	local slot = skillSlots[slotIndex]
	if not slot then return end
	local ov  = slot._cdOverlay
	local lbl = slot._cdLabel
	if not ov then return end

	local cd      = slot._cd
	local elapsed = 0
	ov.Visible = true
	ov.Size    = UDim2.fromScale(1, 1)

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		local remaining = math.max(0, cd - elapsed)
		lbl.Text  = string.format("%.0f", remaining)
		local ratio = 1 - (elapsed / cd)
		ov.Size     = UDim2.new(1, 0, ratio, 0)
		ov.Position = UDim2.new(0, 0, 1 - ratio, 0)
		if elapsed >= cd then
			ov.Visible = false
			conn:Disconnect()
		end
	end)
	table.insert(cdConns, conn)
end

-- ─── COIN & KILL HUD ──────────────────────────────────────────
local statsRow = inst("Frame", {
	Size             = UDim2.new(0,196,0,44),
	Position         = UDim2.new(1,-212,0,14),
	BackgroundColor3 = C.panel,
	BackgroundTransparency = 0.14,
	BorderSizePixel  = 0,
	ZIndex           = 6,
}, hudFrame)
corner(14, statsRow)
stroke(C.gold, 1.5, 0.42, statsRow)

inst("TextLabel", {
	Size             = UDim2.new(0,36,1,0),
	BackgroundTransparency = 1,
	Text             = "🪙",
	TextSize         = 22,
	ZIndex           = 7,
}, statsRow)

local hudCoin = inst("TextLabel", {
	Name             = "HudCoin",
	Size             = UDim2.new(1,-40,1,0),
	Position         = UDim2.new(0,38,0,0),
	BackgroundTransparency = 1,
	Text             = "0 Coin",
	Font             = Enum.Font.GothamBold,
	TextSize         = 18,
	TextColor3       = C.gold,
	TextXAlignment   = Enum.TextXAlignment.Left,
	ZIndex           = 7,
}, statsRow)

local killRow = inst("Frame", {
	Size             = UDim2.new(0,158,0,38),
	Position         = UDim2.new(1,-172,0,64),
	BackgroundColor3 = C.panel,
	BackgroundTransparency = 0.14,
	BorderSizePixel  = 0,
	ZIndex           = 6,
}, hudFrame)
corner(12, killRow)
stroke(C.red, 1.5, 0.42, killRow)

inst("TextLabel", {
	Size             = UDim2.new(0,32,1,0),
	BackgroundTransparency = 1,
	Text             = "⚔",
	TextSize         = 20,
	ZIndex           = 7,
}, killRow)

local hudKill = inst("TextLabel", {
	Name             = "HudKill",
	Size             = UDim2.new(1,-36,1,0),
	Position         = UDim2.new(0,34,0,0),
	BackgroundTransparency = 1,
	Text             = "0 Kill",
	Font             = Enum.Font.GothamBold,
	TextSize         = 16,
	TextColor3       = C.red,
	TextXAlignment   = Enum.TextXAlignment.Left,
	ZIndex           = 7,
}, killRow)

-- ─── VERSİYON ROZETİ ──────────────────────────────────────────
local verBadge = inst("Frame", {
	Size             = UDim2.new(0,95,0,36),
	Position         = UDim2.new(0,18,0,14),
	BackgroundColor3 = C.v1,
	BackgroundTransparency = 0.22,
	BorderSizePixel  = 0,
	ZIndex           = 6,
}, hudFrame)
corner(11, verBadge)

local verBadgeLbl = inst("TextLabel", {
	Size             = UDim2.fromScale(1,1),
	BackgroundTransparency = 1,
	Text             = "V1",
	Font             = Enum.Font.GothamBold,
	TextSize         = 21,
	TextColor3       = Color3.new(1,1,1),
	ZIndex           = 7,
}, verBadge)

-- ─── YÜKSELT DÜĞMESİ ─────────────────────────────────────────
local upgradeBtn = inst("TextButton", {
	Name             = "UpgradeBtn",
	Size             = UDim2.new(0,160,0,40),
	Position         = UDim2.new(0,18,0,58),
	BackgroundColor3 = C.panel2,
	BackgroundTransparency = 0.14,
	BorderSizePixel  = 0,
	Text             = "⬆  YÜKSELT",
	Font             = Enum.Font.GothamBold,
	TextSize         = 14,
	TextColor3       = C.gold,
	ZIndex           = 6,
}, hudFrame)
corner(12, upgradeBtn)
stroke(C.gold, 1.5, 0.48, upgradeBtn)

upgradeBtn.MouseButton1Click:Connect(function()
	if not selectedChar then return end
	local ok, data = pcall(function() return getDataRemote:InvokeServer() end)
	if not ok or not data then return end

	local nextVer = data.version=="V1" and "V2"
		or data.version=="V2" and "V3"
		or nil

	if not nextVer then
		-- Zaten max, rozeti yanıp söndür
		tw(verBadge, TweenInfo.new(0.15), { BackgroundTransparency=0 })
		task.delay(0.15, function()
			tw(verBadge, TweenInfo.new(0.28), { BackgroundTransparency=0.22 })
		end)
		return
	end
	upgradeRemote:FireServer(selectedChar.id, nextVer)
end)

-- ─── ADMİN POPUP ──────────────────────────────────────────────
local function showAdminPopup(text, color)
	color = color or C.green
	local popup = inst("Frame", {
		Size             = UDim2.new(0,540,0,64),
		Position         = UDim2.new(0.5,-270,0,-74),
		BackgroundColor3 = C.panel2,
		BackgroundTransparency = 0.1,
		BorderSizePixel  = 0,
		ZIndex           = 30,
	}, sg)
	corner(16, popup)
	stroke(color, 2, 0.2, popup)
	grad(color:Lerp(C.panel2, 0.85), C.panel2, 180, popup)

	inst("TextLabel", {
		Size             = UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		Text             = text,
		Font             = Enum.Font.GothamBold,
		TextSize         = 16,
		TextColor3       = color,
		TextWrapped      = true,
		ZIndex           = 31,
	}, popup)

	-- Aşağıdan yukarı kay
	tw(popup, TweenInfo.new(0.42, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, -270, 0, 18),
	})

	task.delay(3.4, function()
		tw(popup, TweenInfo.new(0.38), {
			Position         = UDim2.new(0.5,-270,0,-74),
			BackgroundTransparency = 1,
		})
		task.wait(0.42)
		if popup.Parent then popup:Destroy() end
	end)
end

adminMsgEvt.OnClientEvent:Connect(function(text, color)
	showAdminPopup(text, color)
end)

-- ─── VERSİYON YÜKSELTİLDİ ────────────────────────────────────
local function onVersionUpgrade(charId, newVer)
	if charId ~= (selectedChar and selectedChar.id) then return end
	local vColors = { V1=C.v1, V2=C.v2, V3=C.v3 }
	tw(verBadge, TweenInfo.new(0.32, Enum.EasingStyle.Back), {
		BackgroundColor3 = vColors[newVer] or C.v1,
	})
	verBadgeLbl.Text = newVer
	buildSkillBar(newVer)
	selectedVersion = newVer

	-- Bildirim mesajı
	local msg = inst("TextLabel", {
		Size             = UDim2.new(0,430,0,58),
		Position         = UDim2.new(0.5,-215,0.08,0),
		BackgroundColor3 = (vColors[newVer] or C.v1):Lerp(C.panel, 0.62),
		BackgroundTransparency = 0.1,
		Text             = "★  AIZEN " .. newVer .. " KİLİDİ AÇILDI!",
		Font             = Enum.Font.GothamBold,
		TextSize         = 22,
		TextColor3       = vColors[newVer] or C.v1,
		TextTransparency = 1,
		BorderSizePixel  = 0,
		ZIndex           = 20,
	}, hudFrame)
	corner(16, msg)
	tw(msg, TweenInfo.new(0.38, Enum.EasingStyle.Back), { TextTransparency=0 })
	task.delay(2.8, function()
		tw(msg, TweenInfo.new(0.42), {
			TextTransparency     = 1,
			BackgroundTransparency = 1,
		})
		task.wait(0.48)
		if msg.Parent then msg:Destroy() end
	end)
end

versionUpgEvt.OnClientEvent:Connect(onVersionUpgrade)

-- Karakter seçildi → HUD aç
charSelectedEvt.OnClientEvent:Connect(function(charId, version)
	local vColors = { V1=C.v1, V2=C.v2, V3=C.v3 }
	verBadge.BackgroundColor3 = vColors[version] or C.v1
	verBadgeLbl.Text          = version
	buildSkillBar(version)
	selectedVersion  = version
	hudFrame.Visible = true
end)

-- ─── HP SYNC ──────────────────────────────────────────────────
player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")
	hum.HealthChanged:Connect(function(hp)
		local ratio = math.clamp(hp / hum.MaxHealth, 0, 1)
		tw(hpBar, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
			Size = UDim2.new(ratio, 0, 1, 0),
		})
		hpLabel.Text = string.format("HP  %d / %d",
			math.floor(hp), math.floor(hum.MaxHealth))
		local col = ratio > 0.5
			and Color3.fromRGB(55 + math.floor((1-ratio)*360), 200, 55)
			or  Color3.fromRGB(215, math.floor(ratio*280), 55)
		tw(hpBar, TweenInfo.new(0.28), { BackgroundColor3=col })
	end)
end)

-- ─── VERİ SENKRON DÖNGÜSÜ ─────────────────────────────────────
task.spawn(function()
	while true do
		task.wait(2)
		local ok, data = pcall(function() return getDataRemote:InvokeServer() end)
		if ok and data then
			local c = data.coins or 0
			coinLabel.Text = tostring(c)
			hudCoin.Text   = tostring(c) .. " Coin"
			hudKill.Text   = tostring(data.kills or 0) .. " Kill"
		end
	end
end)

-- ─── GİRİŞ → YETENEKATEŞİ ────────────────────────────────────
local KEY_MAP = {
	[Enum.KeyCode.Q] = 1,
	[Enum.KeyCode.E] = 2,
	[Enum.KeyCode.R] = 3,
	[Enum.KeyCode.F] = 4,
	[Enum.KeyCode.Z] = 5,
	[Enum.KeyCode.X] = 6,
}

UserInputService.InputBegan:Connect(function(input, gp)
	if gp or not hudFrame.Visible then return end
	local idx = KEY_MAP[input.KeyCode]
	if not idx or not selectedChar then return end
	local defs = SKILL_DEFS[selectedVersion]
	if not defs or idx > #defs then return end
	useSkillRemote:FireServer(selectedChar.id, selectedVersion, idx)
	triggerCooldownVFX(idx)
end)

-- ─── GİRİŞ ANİMASYONU ────────────────────────────────────────
selScreen.BackgroundTransparency = 1
logoLabel.TextTransparency       = 1
subText.TextTransparency         = 1
tw(selScreen, TweenInfo.new(0.72, Enum.EasingStyle.Quad), { BackgroundTransparency=0 })
task.delay(0.22, function()
	tw(logoLabel, TweenInfo.new(0.82, Enum.EasingStyle.Quad), { TextTransparency=0 })
end)
task.delay(0.52, function()
	tw(subText, TweenInfo.new(0.6), { TextTransparency=0 })
end)

-- İlk kartı detay panelinde göster
updateDetail(CHARS[1])

print("[ShinigamiLegends] StarterPlayerScript | Admin Popup + HUD + SkillBar ✓")
