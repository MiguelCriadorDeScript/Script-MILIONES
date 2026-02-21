--// ^^______^^^^^^______^^^_______^^^^^^_____^^^_______^^^^________^^^^_________^^^^^______^^^^^_______^^^^^^^^^^^_^^^^^^^^^_____^^^_____^^^________^^^^^^^____^^^^____^^^^^^^^^____^^^^^^^^^^__^^^ 
--// .'^____^\^^^.'^___^^|^|_^^^__^\^^^^|_^^^_|^|_^^^__^\^^|^^_^^^_^^|^^^|_^^^_^\^^^|_^^^__^\^^^^^^^^^/^\^^^^^^|_^^^_|^|_^^^\|_^^^_|^|_^^^__^\^^^^^.'^^^`.^^|^^_^^^_^^|^^^|_^^_|^|_^^_|^^/^____^`.^^^^^^.'^^^^'.^^^^^^^/^^|^^ 
--// |^(___^\_|^/^.'^^^\_|^^^|^|__)^|^^^^^|^|^^^^^|^|__)^|^|_/^|^|^\_|^^^^^|^|_)^|^^^^|^|__)^|^^^^^^^/^_^\^^^^^^^|^|^^^^^|^^^\^|^|^^^^^|^|__)^|^^^/^^.-.^^\^|_/^|^|^\_|^^^^^\^\^^^/^/^^^^`'^^__)^|^^^^^|^^.--.^^|^^^^^^`|^|^^ 
--// ^_.____`.^^|^|^^^^^^^^^^|^^__^/^^^^^^|^|^^^^^|^^___/^^^^^^|^|^^^^^^^^^|^^__'.^^^^|^^__^/^^^^^^^/^___^\^^^^^^|^|^^^^^|^|\^\|^|^^^^^|^^__^/^^^^|^|^^^|^|^^^^^|^|^^^^^^^^^^\^\^/^/^^^^^_^^|__^'.^^^^^|^|^^^^|^|^^^^^^^|^|^^ 
--// |^\____)^|^\^`.___.'\^^_|^|^^\^\_^^^_|^|_^^^_|^|_^^^^^^^^_|^|_^^^^^^^^_|^|__)^|^^_|^|^^\^\_^^^_/^/^^^\^\_^^^_|^|_^^^_|^|_\^^^|_^^^_|^|^^\^\_^^\^^`-'^^/^^^^_|^|_^^^^^^^^^^\^'^/^^^^^|^\____)^|^^_^^|^^`--'^^|^^_^^^_|^|_^ 
--// ^\______.'^^`.____^.'^|____|^|___|^|_____|^|_____|^^^^^^|_____|^^^^^|_______/^^|____|^|___|^|____|^|____|^|_____|^|_____|\____|^|____|^|___|^^`.___.'^^^^|_____|^^^^^^^^^^^\_/^^^^^^^\______.'^(_)^^'.____.'^^(_)^|_____|
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                    SCRIPT BRAINROT — KEY SYSTEM                         ║
-- ║                         by ByteBandit_Ofici                             ║
-- ║                              v3.0.1                                     ║
-- ╠══════════════════════════════════════════════════════════════════════════╣
-- ║  To get your daily key visit:                                            ║
-- ║  → https://key-systemz.netlify.app/                                     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local KEY_SITE = "https://key-systemz.netlify.app/"
local KEY_FILE = "SB_Session.dat"

local function Trim(s)
    return (tostring(s or "")):match("^%s*(.-)%s*$")
end

local function DateStamp()
    return tostring(os.date("%Y%m%d"))
end

local function Safe(fn, ...)
    return pcall(fn, ...)
end

local function ValidateKey(key)
    if type(key) ~= "string" then return false, "Invalid key." end
    key = Trim(key)
    if key == "" then return false, "Key is empty." end
    if #key < 25 or #key > 35 then
        return false, "Invalid key.\nPlease enter your key correctly.\nSite: " .. KEY_SITE
    end
    return true, "Key accepted!"
end

local function SaveKey(key)
    Safe(function() writefile(KEY_FILE, key .. "|" .. DateStamp()) end)
end

local function DeleteKey()
    Safe(function() delfile(KEY_FILE) end)
end

local function LoadKey()
    local ok, raw = Safe(readfile, KEY_FILE)
    if not ok or not raw or raw == "" then return nil end
    local stored, date = raw:match("^(.+)|(%d%d%d%d%d%d%d%d)$")
    if not stored or not date then return nil end
    if date ~= DateStamp() then DeleteKey(); return nil end
    local valid, _ = ValidateKey(stored)
    return valid and stored or nil
end

local S = {
    Unlocked = false, Key = nil, ValidatedAt = 0,
    Attempts = 0, MaxAttempts = 5, Source = "-",
}

local lblStatus, lblSession, lblAttempts

local Rayfield
local rfOk, rfErr = pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not rfOk or not Rayfield then
    warn("[Script Brainrot] Rayfield failed: " .. tostring(rfErr))
    local sg = Instance.new("ScreenGui")
    sg.Name = "SBKeyErr"; sg.ResetOnSpawn = false
    pcall(function() sg.Parent = CoreGui end)
    local bg = Instance.new("Frame", sg)
    bg.Size = UDim2.new(0,460,0,120)
    bg.Position = UDim2.new(0.5,-230,0.07,0)
    bg.BackgroundColor3 = Color3.fromRGB(3,6,12)
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,12)
    local stroke = Instance.new("UIStroke", bg)
    stroke.Color = Color3.fromRGB(180,30,30); stroke.Thickness = 1
    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1,-24,1,-20); lbl.Position = UDim2.new(0,12,0,10)
    lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(255,85,85)
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
    lbl.TextWrapped = true; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "Script Brainrot: Failed to load Rayfield UI.\nEnable HTTP Requests and re-execute.\nError: " .. tostring(rfErr):sub(1,90)
    return
end

local function OnUnlock(key, source)
    S.Unlocked = true; S.Key = key
    S.ValidatedAt = os.time(); S.Source = source
    _G.ScriptBrainrotUnlocked = true
    _G.ScriptBrainrotKey = key
    _G.ValidateScriptBrainrotKey = ValidateKey
    if lblStatus then lblStatus:Set("Status: Unlocked via " .. source) end
    if lblSession then
        lblSession:Set(
            "UNLOCKED\n" ..
            "Player: " .. LP.Name .. "\n" ..
            "Key: ..." .. key:sub(-6) .. "  (" .. #key .. " chars)\n" ..
            "Source: " .. source .. "\n" ..
            "Time:   " .. os.date("%H:%M:%S", S.ValidatedAt)
        )
    end
    task.wait(1.5)
    Rayfield:Destroy()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MiguelCriadorDeScript/Script-MILIONES/refs/heads/main/script.lua"))()
end

local Win = Rayfield:CreateWindow({
    Name = "Script Brainrot  -  Key System",
    LoadingTitle = "Script Brainrot",
    LoadingSubtitle = "by ByteBandit_Ofici  -  v3.0.1",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
    Theme = "Default",
})

local function Notify(title, body, dur, img)
    Rayfield:Notify({ Title = title, Content = body, Duration = dur or 5, Image = img or 4483347087 })
end

local TabKey = Win:CreateTab("Key System", 4483347087)

TabKey:CreateSection("How to Get Your Key")
TabKey:CreateLabel(
    "Step 1 - Click the button below to copy the site link.\n" ..
    "Step 2 - Open your browser and paste the link.\n" ..
    "Step 3 - Complete the tasks on the site.\n" ..
    "Step 4 - Copy your key and paste it below.\n\n" ..
    "Keys are FREE and refresh every 24 hours."
)

TabKey:CreateButton({
    Name = "Get My Key  ->  key-systemz.netlify.app",
    Callback = function()
        pcall(function() setclipboard(KEY_SITE) end)
        Notify("Link Copied!", "Open your browser and paste:\n" .. KEY_SITE, 9, 4483347087)
    end,
})

TabKey:CreateDivider()
TabKey:CreateSection("Enter Your Key")

local keyValue = ""

TabKey:CreateInput({
    Name = "Paste Your Key Here",
    PlaceholderText = "Paste your key here...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        keyValue = Trim(text or "")
    end,
})

lblStatus = TabKey:CreateLabel("Status: Waiting for key...")

TabKey:CreateButton({
    Name = "Validate Key",
    Callback = function()
        if S.Attempts >= S.MaxAttempts then
            Notify("Too Many Attempts", "You have used all " .. S.MaxAttempts .. " attempts.\nPlease restart the script.", 6, 4483347087)
            return
        end

        local key = Trim(keyValue or "")

        if key == "" then
            lblStatus:Set("Status: Empty field - paste your key first.")
            Notify("Empty Field", "Paste your key in the field before validating.", 4, 4483347087)
            return
        end

        lblStatus:Set("Status: Checking key...")
        S.Attempts += 1
        if lblAttempts then lblAttempts:Set("Attempts: " .. S.Attempts .. " / " .. S.MaxAttempts) end

        local valid, msg = ValidateKey(key)

        if valid then
            SaveKey(key)
            Notify("Key Accepted!", "Welcome, " .. LP.Name .. "!\nLoading script...", 8, 4483347087)
            OnUnlock(key, "manual input")
        else
            lblStatus:Set("Status: Key rejected.")
            Notify("Invalid Key", msg, 7, 4483347087)
            _G.ScriptBrainrotUnlocked = false
        end
    end,
})

TabKey:CreateDivider()
TabKey:CreateSection("Saved Key")
TabKey:CreateLabel(
    "Your key is saved locally after successful validation.\n" ..
    "It auto-loads next time - no need to paste again today.\n" ..
    "Expired keys are deleted automatically."
)

lblAttempts = TabKey:CreateLabel("Attempts: 0 / " .. S.MaxAttempts)

TabKey:CreateButton({
    Name = "Delete Saved Key",
    Callback = function()
        DeleteKey()
        S.Unlocked = false; S.Key = nil; keyValue = ""
        _G.ScriptBrainrotUnlocked = false
        lblStatus:Set("Status: Saved key cleared. Enter a new key above.")
        Notify("Cleared", "Saved key deleted. Enter a new key to unlock.", 5, 4483347087)
    end,
})

local TabSess = Win:CreateTab("Session", 4483347087)

TabSess:CreateSection("Player Info")
TabSess:CreateLabel("Player:   " .. LP.Name)
TabSess:CreateLabel("User ID:  " .. tostring(LP.UserId))
TabSess:CreateLabel("Date:     " .. tostring(os.date("%d/%m/%Y")))
TabSess:CreateLabel("Time:     " .. tostring(os.date("%H:%M:%S")))

TabSess:CreateDivider()
TabSess:CreateSection("Key Status")

lblSession = TabSess:CreateLabel("No key validated yet this session.")

TabSess:CreateButton({
    Name = "Refresh Info",
    Callback = function()
        if S.Unlocked and S.Key then
            lblSession:Set("UNLOCKED\nPlayer: " .. LP.Name .. "\nKey: ..." .. S.Key:sub(-6) .. "\nSource: " .. S.Source)
        else
            lblSession:Set("LOCKED\nGo to Key System tab to validate.\nAttempts: " .. S.Attempts .. " / " .. S.MaxAttempts)
        end
    end,
})

TabSess:CreateDivider()
TabSess:CreateSection("About")
TabSess:CreateLabel("Script Brainrot  -  Key System  v3.0.1")
TabSess:CreateLabel("Author:     ByteBandit_Ofici")
TabSess:CreateLabel("Framework:  Rayfield by Sirius")
TabSess:CreateLabel("Key site:   key-systemz.netlify.app")

TabSess:CreateButton({
    Name = "Copy Key Site URL",
    Callback = function()
        pcall(function() setclipboard(KEY_SITE) end)
        Notify("Copied!", KEY_SITE, 4, 4483347087)
    end,
})

task.defer(function()
    task.wait(2.2)
    local saved = LoadKey()
    if saved then
        Notify("Auto-Unlocked!", "Your key from today was loaded automatically.\nWelcome back, " .. LP.Name .. "!", 7, 4483347087)
        OnUnlock(saved, "auto-saved key")
    else
        pcall(function() setclipboard(KEY_SITE) end)
        Notify("Key Required", "Get your daily key at:\n" .. KEY_SITE .. "\n\nLink copied to your clipboard!", 12, 4483347087)
    end
end)

LP.AncestryChanged:Connect(function(_, parent)
    if parent == nil then
        S.Unlocked = false; S.Key = nil
        _G.ScriptBrainrotUnlocked = false
        _G.ScriptBrainrotKey = nil
    end
end)

_G.ValidateScriptBrainrotKey = ValidateKey
if not _G.ScriptBrainrotUnlocked then _G.ScriptBrainrotUnlocked = false end
