local g=Instance.new("ScreenGui",game.CoreGui)
g.Name="ExplorerUI"
g.ResetOnSpawn=false

local open=Instance.new("TextButton",g)
open.Size=UDim2.new(0,120,0,35)
open.Position=UDim2.new(0,20,0,20)
open.Text="Open"
open.BackgroundColor3=Color3.fromRGB(30,30,30)
open.TextColor3=Color3.new(1,1,1)

local f=Instance.new("Frame",g)
f.Size=UDim2.new(0,500,0,350)
f.Position=UDim2.new(0.5,-250,0.5,-175)
f.BackgroundColor3=Color3.fromRGB(20,20,20)
f.Visible=false

local top=Instance.new("Frame",f)
top.Size=UDim2.new(1,0,0,30)
top.BackgroundColor3=Color3.fromRGB(35,35,35)

local close=Instance.new("TextButton",top)
close.Size=UDim2.new(0,30,1,0)
close.Position=UDim2.new(1,-30,0,0)
close.Text="X"
close.BackgroundColor3=Color3.fromRGB(120,30,30)
close.TextColor3=Color3.new(1,1,1)

local scan=Instance.new("TextButton",top)
scan.Size=UDim2.new(0,80,1,0)
scan.Text="Scan"
scan.BackgroundColor3=Color3.fromRGB(40,40,40)
scan.TextColor3=Color3.new(1,1,1)

local mode=Instance.new("TextButton",top)
mode.Size=UDim2.new(0,140,1,0)
mode.Position=UDim2.new(0,80,0,0)
mode.Text="Mode: All"
mode.BackgroundColor3=Color3.fromRGB(40,40,40)
mode.TextColor3=Color3.new(1,1,1)

local copy=Instance.new("TextButton",top)
copy.Size=UDim2.new(0,80,1,0)
copy.Position=UDim2.new(0,220,0,0)
copy.Text="Copy"
copy.BackgroundColor3=Color3.fromRGB(40,40,40)
copy.TextColor3=Color3.new(1,1,1)

local box=Instance.new("ScrollingFrame",f)
box.Size=UDim2.new(1,0,1,-30)
box.Position=UDim2.new(0,0,0,30)
box.CanvasSize=UDim2.new(0,0,0,0)
box.ScrollBarThickness=6
box.BackgroundColor3=Color3.fromRGB(25,25,25)

local list=Instance.new("UIListLayout",box)
list.SortOrder=Enum.SortOrder.LayoutOrder

local dragging=false
local dragInput
local dragStart
local startPos

top.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 then
		dragging=true
		dragStart=i.Position
		startPos=f.Position
		i.Changed:Connect(function()
			if i.UserInputState==Enum.UserInputState.End then
				dragging=false
			end
		end)
	end
end)

top.InputChanged:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseMovement then
		dragInput=i
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(i)
	if i==dragInput and dragging then
		local delta=i.Position-dragStart
		f.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
	end
end)

open.MouseButton1Click:Connect(function()
	f.Visible=true
end)

close.MouseButton1Click:Connect(function()
	f.Visible=false
end)

local currentMode="All"

mode.MouseButton1Click:Connect(function()
	if currentMode=="All" then
		currentMode="Remotes"
	elseif currentMode=="Remotes" then
		currentMode="Services"
	else
		currentMode="All"
	end
	mode.Text="Mode: "..currentMode
end)

local function add(text)
	local l=Instance.new("TextLabel")
	l.Size=UDim2.new(1,-10,0,18)
	l.TextXAlignment=Enum.TextXAlignment.Left
	l.BackgroundTransparency=1
	l.TextColor3=Color3.new(1,1,1)
	l.Font=Enum.Font.Code
	l.TextSize=14
	l.Text=text
	l.Parent=box
end

scan.MouseButton1Click:Connect(function()
	for _,v in pairs(box:GetChildren()) do
		if v:IsA("TextLabel") then v:Destroy() end
	end

	local content=""

	if currentMode=="All" or currentMode=="Services" then
		for _,v in pairs(game:GetChildren()) do
			local t=v.ClassName.." - "..v.Name
			add(t)
			content=content..t.."\n"
		end
	end

	if currentMode=="All" or currentMode=="Remotes" then
		for _,v in pairs(game:GetDescendants()) do
			if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
				local t=v.ClassName.." - "..v:GetFullName()
				add(t)
				content=content..t.."\n"
			end
		end
	end

	box.CanvasSize=UDim2.new(0,0,0,list.AbsoluteContentSize.Y)
	box:SetAttribute("data",content)
end)

copy.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard(box:GetAttribute("data") or "")
	end
end)
