local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WebhookInputGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 400, 0, 150)
Frame.Position = UDim2.new(0.5, -200, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Parent = ScreenGui

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0, 380, 0, 50)
TextBox.Position = UDim2.new(0, 10, 0, 20)
TextBox.PlaceholderText = "กรุณาใส่ Discord Webhook URL"
TextBox.ClearTextOnFocus = false
TextBox.TextColor3 = Color3.new(1, 1, 1)
TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TextBox.Parent = Frame

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 380, 0, 50)
Button.Position = UDim2.new(0, 10, 0, 80)
Button.Text = "ตั้งค่าและรันสคริปต์"
Button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
Button.TextColor3 = Color3.new(1, 1, 1)
Button.Parent = Frame

Button.MouseButton1Click:Connect(function()
    local webhook = TextBox.Text
    if webhook == "" then
        warn("กรุณากรอก Webhook URL ก่อน")
        return
    end

    -- แปลง webhook เป็น base64
    local function encodeBase64(data)
        local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        return ((data:gsub('.', function(x)
            local r,bits='',x:byte()
            for i=8,1,-1 do r=r..(bits%2^i-bits%2^(i-1)>0 and '1' or '0') end
            return r
        end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if #x < 6 then return '' end
            local c=0
            for i=1,6 do c=c + (x:sub(i,i)=='1' and 2^(6-i) or 0) end
            return b:sub(c+1,c+1)
        end)..({ '', '==', '=' })[#data%3+1])
    end

    local base64Webhook = encodeBase64(webhook)

    local success, mainCode = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/RTaOexe1/RTaO_HUB/main/Main.lua")
    end)

    if not success then
        warn("โหลด Main.lua ไม่สำเร็จ")
        return
    end

    mainCode = mainCode:gsub("{{WEBHOOK}}", base64Webhook)
    loadstring(mainCode)()
    ScreenGui:Destroy()
end)
