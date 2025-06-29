-- Grow a Garden: Stock Bot Script (Encoded Webhook Edition)
-- Version: 1.2 - เข้ารหัส Webhook URLs ด้วย Base64

-- ✅ CONFIG
_G.Enabled = true

-- Base64 ถอดรหัสใน Lua (ไม่ใช้ syn, ใช้ทั่วไปได้)
local function base64Decode(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r, f = '', (b:find(x) - 1)
		for i = 6, 1, -1 do
			r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0')
		end
		return r
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		local c = 0
		for i = 1, 8 do
			c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0)
		end
		return string.char(c)
	end))
end

-- Webhook
local encodedWebhooks = {
    ["ROOT/SeedStock/Stocks"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM4ODc5OTkyODI5NzU4NjcwOS9PZjl1NmQxTWRtS1Z2ZVJPY0YySmFkcUNmVlBZWjhVWWZJb1hPbHhtOE1DdG5OTFlNMnhLckpOd2tQb0RTR0VTVWJnNQ==",
    ["ROOT/PetEggStock/Stocks"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM4ODgwMDU3MDA4ODg4MjIwNy9TcC1iS2c4SXJBLXRmNDhCZ2VrRlJEdkJoRzZFdW5xcVhSWGdvT1ZMX2t3Zl9OTnJGRXpjOFAwZmE2UjdqWHFZdkp6eA==",
    ["ROOT/GearStock/Stocks"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM4ODgwMDQwNDcxMTUzODgwOS91eHdZMVgtWTNCQ1dwNElwNGlOWGYtejJTWTFCRU1BaEQ3R0Y2WXBGX25XUk1QU1dkLVJ1dHA0UW1ueWtNYXFtVHJoTA==",
    ["ROOT/CosmeticStock/ItemStocks"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM4ODgwMTAyMTM3OTM1MDU0MC9mUzhfeFJCRmE5ckl6WGV2M3N4OXgwbjhScWRoZkx2RVp0em9rM0JnZGV6MU5nT1NkSkZ3NWZrMlJ4TFV2Y2s1WVhxNQ==",
    ["ROOT/EventShopStock/Stocks"] = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTM4ODgwMDgxNjY3NjIxMjc1Ny9ZY0Z0YTBJaTIwcXdKV0tFZEJPbldXMTFacFhESHR5SGxHUVpmQ0ZFX0YwU0VvVUVWLVFFVGFjTzNsV3BEUklhWm1GSg=="
}

-- รูปภาพ Embed ใช้ร่วมกัน
local defaultImage = "https://cdn.discordapp.com/attachments/1217027368825262144/1388582267881914568/1717516914963.png"

-- Layout ข้อมูล Embed
_G.Layout = {
    ["ROOT/SeedStock/Stocks"] = { title = "🌱 SEEDS STOCK", color = 65280 },
    ["ROOT/PetEggStock/Stocks"] = { title = "🥚 EGG STOCK", color = 16776960 },
    ["ROOT/GearStock/Stocks"] = { title = "🛠️ GEAR STOCK", color = 16753920 },
    ["ROOT/CosmeticStock/ItemStocks"] = { title = "🎨 COSMETIC STOCK", color = 16737792 },
    ["ROOT/EventShopStock/Stocks"] = { title = "🎁 EVENT STOCK", color = 10027263 }
}

-- 📡 SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local DataStream = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DataStream")

-- 🌐 HTTP fallback
local requestFunc = http_request or request or syn and syn.request
if not requestFunc then
    warn("[❌] HTTP request ไม่รองรับบน executor นี้")
end

-- 🔁 แปลง stock object เป็นข้อความ
local function GetStockString(stock)
    local s = ""
    for name, data in pairs(stock) do
        local display = data.EggName or name
        s ..= (`{display} x{data.Stock}\n`)
    end
    return s
end

-- 📤 ส่ง webhook แยก embed ต่อหมวด พร้อมรูป
local function SendSingleEmbed(title, bodyText, color, encodedWebhook, imageUrl)
    if not _G.Enabled or not requestFunc then return end
    if bodyText == "" or not encodedWebhook then return end

    local webhookUrl = base64Decode(encodedWebhook)

    local embed = {
        title = title,
        description = bodyText,
        color = color,
        timestamp = DateTime.now():ToIsoDate(),
        footer = { text = "Grow a Garden Stock Bot (BY RTaO)" }
    }

    if imageUrl then
        embed.image = { url = imageUrl }
    end

    local body = {
        embeds = {embed}
    }

    local success, result = pcall(function()
        return requestFunc({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(body)
        })
    end)

    if success and result and (result.StatusCode == 200 or result.StatusCode == 204) then
        print("[📤] ส่ง " .. title .. " ไปยัง Webhook เรียบร้อย")
    else
        warn("[❌] ส่ง " .. title .. " ไม่สำเร็จ: " .. tostring(result and result.StatusCode or "Unknown Error"))
    end
end

-- 🔍 ค้นหาข้อมูล stock ตาม path
local function GetPacket(data, key)
    for _, packet in ipairs(data) do
        if packet[1] == key then
            return packet[2]
        end
    end
end

-- 📥 รับ Event แล้วแยกส่ง Embed ตามหมวด
DataStream.OnClientEvent:Connect(function(eventType, profile, data)
    if eventType ~= "UpdateData" then return end
    if not profile:find(LocalPlayer.Name) then return end

    for path, layout in pairs(_G.Layout) do
        local stockData = GetPacket(data, path)
        if stockData then
            local stockStr = GetStockString(stockData)
            if stockStr ~= "" then
                local encodedWebhook = encodedWebhooks[path]
                SendSingleEmbed(layout.title, stockStr, layout.color, encodedWebhook, defaultImage)
            end
        end
    end
end)

print("[✅] Stock Checker พร้อมทำงาน (Webhook แบบเข้ารหัส + ภาพ Embed)")

-- 🟢 แจ้งเตือนเมื่อรันสคริปต์สำเร็จ
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "RTaO HOOKS",
        Text = "รัน RTaO HOOKS สำเร็จ",
        Duration = 3
    })
end)
