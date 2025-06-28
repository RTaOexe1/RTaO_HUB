local HttpService=game:GetService("HttpService")
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local function b64decode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data=data:gsub('[^'..b..'=]', '')
    return (data:gsub('.',function(x)
        if x=='=' then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?',function(x)
        if #x~=8 then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

_G = _G or {}

-- ตรงนี้แทนที่ {{WEBHOOK}} ด้วย base64 encoded webhook จริง โดย Loader.lua จะทำการแทนที่นี้ก่อนรัน
_G.WebhookURL = b64decode("{{WEBHOOK}}")

_G.Enabled=true

local Players=Players
local ReplicatedStorage=ReplicatedStorage
local HttpService=HttpService
local LocalPlayer=Players.LocalPlayer
local DataStream=ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DataStream")

local function a(c)
    local d=""
    for e,f in pairs(c) do
        local g=f.EggName or e
        d=d..g.." x"..f.Stock.."\n"
    end
    return d
end

local function c(h,i,j)
    if not _G.Enabled then return end
    if i=="" then return end
    local requestFunc = syn and syn.request or http_request or request
    if not requestFunc then return end

    local body={
        embeds={{title=h,description=i,color=j,timestamp=DateTime.now():ToIsoDate(),footer={text="Grow a Garden Stock Bot (Mobile)"}}}
    }

    requestFunc({
        Url=_G.WebhookURL,
        Method="POST",
        Headers={["Content-Type"]="application/json"},
        Body=HttpService:JSONEncode(body)
    })
end

local function d(k,l)
    for m,n in ipairs(k) do
        if n[1]==l then return n[2] end
    end
end

local layout = {
    ["ROOT/SeedStock/Stocks"]={title="🌱 SEEDS STOCK",color=65280},
    ["ROOT/GearStock/Stocks"]={title="🛠️ GEAR STOCK",color=16753920},
    ["ROOT/PetEggStock/Stocks"]={title="🥚 EGG STOCK",color=16776960},
    ["ROOT/CosmeticStock/ItemStocks"]={title="🎨 COSMETIC STOCK",color=16737792},
    ["ROOT/EventShopStock/Stocks"]={title="🎁 EVENT STOCK",color=10027263}
}

DataStream.OnClientEvent:Connect(function(o,p,q)
    if o~="UpdateData" then return end
    if not p:find(LocalPlayer.Name) then return end
    for r,s in pairs(layout) do
        local t=d(q,r)
        if t then
            local u=a(t)
            if u~="" then
                c(s.title,u,s.color)
            end
        end
    end
end)

print("[✅] Stock Checker พร้อมทำงาน (แบบ Obfuscate & base64)")

