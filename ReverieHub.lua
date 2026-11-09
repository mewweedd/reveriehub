--[[
    Reverie Hub
    Developed by Opium
    Loader — no key system, free/open load.
]]

local Directory = "https://raw.githubusercontent.com/flazhy/QuantumOnyx/refs/heads/main/Games" -- FILL: point at your own repo once Games/ is rehosted
local Scripts = {
	[994732206] = Directory .. "/BloxFruits.lua",
	[9186719164] = Directory .. "/SailorPiece.lua",
	[8191429227] = Directory .. "/CutTrees.lua",
}

local FOLDER = "Reverie Hub"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local GameId = game.GameId

local IsFolderFunc = isfolder or function() return false end
local MakeFolderFunc = makefolder or function() end

local function Tween(obj, props, t, style, dir)
	style = style or Enum.EasingStyle.Quint
	dir = dir or Enum.EasingDirection.Out
	TweenService:Create(obj, TweenInfo.new(t, style, dir), props):Play()
end

local function Protect(gui)
	local env = (getgenv and getgenv()) or _G
	if env.HIDEUI then
		gui.Parent = env.HIDEUI
	elseif gethui then
		gui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(gui)
		gui.Parent = game:GetService("CoreGui")
	else
		gui.Parent = game:GetService("CoreGui")
	end
end

local function New(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Children" and k ~= "Parent" then
			pcall(function() inst[k] = v end)
		end
	end
	if props.Children then
		for _, c in ipairs(props.Children) do
			pcall(function() c.Parent = inst end)
		end
	end
	inst.Parent = props.Parent or parent
	return inst
end

local function CircleRipple(btn, mx, my)
	task.spawn(function()
		btn.ClipsDescendants = true
		local nx = mx - btn.AbsolutePosition.X
		local ny = my - btn.AbsolutePosition.Y
		local sz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.6
		local c = New("ImageLabel", {
			Name = "Ripple",
			Image = "rbxassetid://266543268",
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 0.85,
			BackgroundTransparency = 1,
			ZIndex = btn.ZIndex + 5,
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0, nx, 0, ny),
		}, btn)
		Tween(c, { Size = UDim2.new(0, sz, 0, sz), Position = UDim2.new(0.5, -sz/2, 0.5, -sz/2) }, 0.45, Enum.EasingStyle.Quad)
		Tween(c, { ImageTransparency = 1 }, 0.45, Enum.EasingStyle.Linear)
		task.wait(0.46)
		c:Destroy()
	end)
end

local function Notify(title, desc, duration)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title or "Reverie Hub",
			Text = desc or "",
			Duration = duration or 4,
		})
	end)
end

local function LoadScript()
	local url = Scripts[GameId]
	if url then
		pcall(function() loadstring(game:HttpGet(url))() end)
	else
		Notify("Reverie Hub", "No script registered for this game yet.", 4)
		warn("[Reverie Hub] No script for GameId: " .. tostring(GameId))
	end
end

-- Glass-panel loader UI: dark frosted base with layered translucent strokes/
-- blur-fakes (real GaussianBlur isn't exposed to executors, so depth is faked
-- with stacked low-opacity frames + a soft top highlight sheen).
local function ShowLoaderUI()
	local SG = Instance.new("ScreenGui")
	SG.Name = "RH_" .. tostring(math.random(1e6))
	SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
	SG.ResetOnSpawn = false
	SG.IgnoreGuiInset = true
	Protect(SG)

	local Backdrop = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 200,
		Parent = SG,
	})

	local W, H = 400, 220
	local Card = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, W, 0, H),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.88, -- glass body: mostly see-through, tinted white
		BorderSizePixel = 0,
		ZIndex = 201,
		ClipsDescendants = true,
		Parent = SG,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0, 18) }),
			New("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Transparency = 0.55,
				Thickness = 1.2,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}),
			New("UIGradient", {
				Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 160, 255)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(130, 200, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 140, 255)),
				},
				Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.82),
					NumberSequenceKeypoint.new(0.5, 0.92),
					NumberSequenceKeypoint.new(1, 0.82),
				},
				Rotation = 45,
			}),
		}
	})

	-- soft top sheen to sell the glass highlight
	New("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 202,
		Parent = Card,
		Children = { New("UIGradient", {
			Color = ColorSequence.new(Color3.fromRGB(255,255,255)),
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(1, 1),
			},
			Rotation = 90,
		}) }
	})

	local Header = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 50),
		ZIndex = 203,
		Parent = Card,
	})

	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 22, 0, 0),
		Size = UDim2.new(1, -60, 1, 0),
		Font = Enum.Font.FredokaOne,
		Text = "Reverie Hub",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 204,
		Parent = Header,
	})

	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 22, 0, 30),
		Size = UDim2.new(1, -60, 0, 16),
		Font = Enum.Font.Gotham,
		Text = "by Opium",
		TextColor3 = Color3.fromRGB(220, 220, 240),
		TextTransparency = 0.25,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 204,
		Parent = Header,
	})

	local CloseBtn = New("ImageButton", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0, 25),
		Size = UDim2.new(0, 18, 0, 18),
		Image = "rbxassetid://79324227570635",
		ImageColor3 = Color3.fromRGB(255, 160, 160),
		ZIndex = 204,
		Parent = Header,
	})
	CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

	local StatusLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 22, 0, 90),
		Size = UDim2.new(1, -44, 0, 20),
		Font = Enum.Font.Gotham,
		Text = "Ready to load.",
		TextColor3 = Color3.fromRGB(230, 230, 250),
		TextTransparency = 0.1,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 204,
		Parent = Card,
	})

	local function MakeBtn(label, y, bg, cb)
		local btn = New("TextButton", {
			BackgroundColor3 = bg,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 22, 0, y),
			Size = UDim2.new(1, -44, 0, 42),
			AutoButtonColor = false,
			Text = "",
			ClipsDescendants = true,
			ZIndex = 204,
			Parent = Card,
			Children = {
				New("UICorner", { CornerRadius = UDim.new(0, 12) }),
				New("UIStroke", { Color = Color3.fromRGB(255,255,255), Transparency = 0.6, Thickness = 1 }),
				New("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Font = Enum.Font.GothamBold,
					Text = label,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 15,
					ZIndex = 205,
				}),
			}
		})
		btn.MouseEnter:Connect(function()
			Tween(btn, { BackgroundTransparency = 0.15 }, 0.12)
		end)
		btn.MouseLeave:Connect(function()
			Tween(btn, { BackgroundTransparency = 0.35 }, 0.16)
		end)
		btn.MouseButton1Click:Connect(function()
			CircleRipple(btn, Mouse.X, Mouse.Y)
			cb()
		end)
		return btn
	end

	local function AnimateClose()
		Tween(Card, { Size = UDim2.new(0, W * 0.7, 0, H * 0.7), BackgroundTransparency = 1 }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		Tween(Backdrop, { BackgroundTransparency = 1 }, 0.2, Enum.EasingStyle.Quint)
		task.delay(0.22, function() SG:Destroy() end)
	end

	MakeBtn("Load Script", 130, Color3.fromRGB(140, 110, 255), function()
		if not Scripts[GameId] then
			StatusLabel.Text = "No script for this game."
			StatusLabel.TextColor3 = Color3.fromRGB(255, 160, 140)
			return
		end
		StatusLabel.Text = "Loading..."
		StatusLabel.TextColor3 = Color3.fromRGB(150, 230, 180)
		AnimateClose()
		LoadScript()
	end)
end

if not IsFolderFunc(FOLDER) then MakeFolderFunc(FOLDER) end
ShowLoaderUI()
