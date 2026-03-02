-- [[ UI LIBRARY STUFF ]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Fluent_Toggle = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nexos-Exos/Returns/refs/heads/main/Fluent%20Toggle.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
  Title = "Key Eater",
  SubTitle = "by Lil Nas X",
  TabWidth = 160,
  Size = UDim2.fromOffset(480, 380),
  Acrylic = true,
  Theme = "Dark",
  MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
  Main = Window:AddTab({ Title = "Main", Icon = "" }),
  Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

SaveManager:SetIgnoreIndexes({})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent_Toggle:Init()

Fluent:Notify({
  Title = "Fluent",
  Content = "The script has been loaded.",
  Duration = 8
})

SaveManager:LoadAutoloadConfig()

-- [[ VARIABLES ]]

local Place_ID = game.PlaceId
local Server_ID = game.JobId

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BankEvent = ReplicatedStorage:WaitForChild("Bank")

local Http_Service = game:GetService("HttpService")
local Teleport_Service = game:GetService("TeleportService")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player.Backpack

local Character = Player.Character
local Humanoid = Character.Humanoid
local HumanoidHRP = Character.HumanoidRootPart

local Store_List = {
  "Uncanny Key",
  "Canny Key"
}

local Get_Keys_State: bool
local Store_Keys_State: bool
local Serverhop_State: bool

local Webhook_Link: string = getgenv().Link or ""

-- [[ FUNCTIONS ]]

Player.CharacterAdded:Connect(function()
  task.wait(2)
  local New_Char = Player.Character or Player.CharacterAdded:Wait()
  
  Backpack = Player.Backpack
  Character = New_Char
  Humanoid = New_Char:FindFirstChild("Humanoid")
  HumanoidHRP = New_Char:FindFirstChild("HumanoidRootPart")
    
  print('Character Variables Updated')
end)

local function Serverhop()
  local Servers_IDS = {}
  local Servers_Url = "https://games.roblox.com/v1/games/" .. Place_ID .. "/servers/Public?sortOrder=Asc&limit=100"
  local Servers_Data = Http_Service:JSONDecode(game:HttpGetAsync(Servers_Url)).data
  
  for _, Servers_Table in ipairs(Servers_Data) do
    
    if type(Servers_Table) == "table" and
    Servers_Table.maxPlayers > Servers_Table.playing and
    Servers_Table.id ~= Server_ID then
      table.insert(Servers_IDS, Servers_Table.id)
		  end
	  end
	  
	  if #Servers_IDS > 0 then
	    Teleport_Service:TeleportToPlaceInstance(
	      Place_ID,
	      Servers_IDS[ math.random(1, #Servers_IDS) ]
	      )
	  end
end

local function Grab_Tool(Tool_Name: string)
  for _, Items in pairs(Workspace:GetChildren()) do
    if Items:IsA("Tool") and
    Items.Name == Tool_Name and
    Items:FindFirstChild("Handle") then
      Items.Handle.CFrame = HumanoidHRP.CFrame
      
      Humanoid:UnequipTools()
    end
  end
end

local function Check_For_Items(Items: Table)
  local Check_Level = 0
  
  if Check_Level == 0 then
    for _, Tool in ipairs(Workspace:GetChildren()) do
      if not table.find(Items, Tool.Name) then
        Check_Level = 1
      end
    end
  end
  
  if Check_Level == 1 then
    for _, Tools in ipairs(Backpack:GetChildren()) do
      if not table.find(Items, Tools.Name) then
        return false
      end
    end
  end
  
end

local function Store_Item(Item: Instance)
  local Items_UI = PlayerGui.BankNEW.Right.ImageLabel.ItemSlots.Slots
  
  for _, Slots in (Items_UI:GetChildren()) do
    if Slots:IsA("Frame") then
      local ItemStored = Slots.ItemName
      
      if ItemStored.Value == "Nothing" then
        Humanoid:EquipTool(Item)
        
        print('EmptySlot Found!')
        local ItemSlot = "Slot" .. Slots.Name
        
        local args = {
          ItemSlot,
          false,
          false
        }
        BankEvent:FireServer(unpack(args))
        
        break
      end
    end
  end
end

-- [[ User-Interface ]]

local Get_Key_Toggle = Tabs.Main:AddToggle("Toggle1", {
  Title = "Get Keys",
  Default = false
})

local Store_Key_Toggle = Tabs.Main:AddToggle("Toggle2", {
  Title = "Store Keys",
  Default = false
})

local Serverhop_Toggle = Tabs.Main:AddToggle("Toggle3", {
  Title = "Auto ServerHop",
  Default = false
})

-- Toggle Functionality

Get_Key_Toggle:OnChanged(function(Value)
  Get_Keys_State = Value
end)

Store_Key_Toggle:OnChanged(function(Value)
  Store_Keys_State = Value
end)

Serverhop_Toggle:OnChanged(function(Value)
  Serverhop_State = Value
end)

-- Toggle Loops

task.defer(function()
  while task.wait(1) do
    if Get_Keys_State then
      for _, Items in ipairs(Store_List) do
        Grab_Tool(Items)
      end
      
    end
  end
end)

task.defer(function()
  while task.wait(5) do
    if Store_Keys_State then
      for _, Items in ipairs(Backpack:GetChildren()) do
        if table.find(Store_List, Items.Name) then
          Store_Item(Items)
        end
      end
      
    end
  end
end)

task.defer(function()
  while task.wait(17.5) do
    if Serverhop_State then
      local Found = false
      
      for _, Ground_Tools in ipairs(Workspace:GetChildren()) do
        if Ground_Tools:IsA("Tool") and
        table.find(Store_List, Ground_Tools.Name) then
          Found = true
        end
      end
      
      for _, Bag_Tools in ipairs(Backpack:GetChildren()) do
        if table.find(Store_List, Bag_Tools.Name) then
          Found = true
        end
      end
      
      for _, Item_Names in ipairs(Store_List) do
        if Character:FindFirstChild(Item_Names) then
          Found = true
        end
      end
      
      if not Found then
        Serverhop()
      end
      
    end
  end
end)
