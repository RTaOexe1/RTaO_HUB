local HttpService = game:GetService("HttpService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WebhookInputGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

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

    local mainCode = game:HttpGet("https://raw.githubusercontent.com/RTaOexe1/RTaO_HUB/main/Main.lua")
    mainCode = mainCode:gsub("{{WEBHOOK}}", webhook)
    loadstring(mainCode)()

    ScreenGui:Destroy()
end)
