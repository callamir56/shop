-- Configuration
local Functions = require("config.functions")

-- Modules
local ShopPeds = require("client.modules.shop-ped")
local checkJob = require("client.modules.job")
local checkLicense = require("client.modules.license")

local shopVoices = {
	shop = {
		"sounds/super1.m4a",
		-- "sounds/super2.m4a",
	},
	weapon_shop = {
		-- "sounds/weapon1.m4a",
	},
	digital_shop = {
		-- "sounds/digital1.m4a",
	},
	weed_shop = {
		-- "sounds/weed1.m4a",
	},
}

---@param shopKey string
local function openShopUI(shopKey)
	Functions.ToggleHud(false)

	SetNuiFocus(true, true)
	SendNUIMessage({ action = "toggleShop", showShop = true })
	local voices = shopVoices[shopKey]
	if voices and #voices > 0 then
		local selectedVoice = voices[math.random(#voices)]
		SendNUIMessage({ action = "playCustomVoice", file = selectedVoice })
	end

	while IsScreenblurFadeRunning() do
		Wait(50)
	end
	TriggerScreenblurFadeIn(200)

	LocalPlayer.state:set("currentShop", shopKey, true)

	ShopPeds.ApplySpeech("Generic_Hi", "Speech_Params_Force")
end

---@param shopKey string
---@param shopData table
local function openShop(shopKey, shopData)
	if not shopKey or not shopData then return end

	log.verbose("[openShop]", json.encode({ "Categories:", shopData.Categories, "Items:", shopData.Items }))

	if shopData.Requirement.Job.required and not checkJob(shopData) then return end
	if shopData.Requirement.License.required and not checkLicense(shopKey, shopData) then return end

	openShopUI(shopKey)
end

local function closeShopUI()
	SetNuiFocus(false, false)
	SendNUIMessage({ action = "toggleShop", showShop = false })

	while IsScreenblurFadeRunning() do
		Wait(50)
	end
	TriggerScreenblurFadeOut(200)

	Functions.ToggleHud(true)

	LocalPlayer.state:set("currentShop", nil, true)
end

local function closeShop()
	closeShopUI()
	ShopPeds.ApplySpeech("Generic_Bye", "Speech_Params_Force")
end

return {
	Open = openShop,
	OpenUI = openShopUI,
	Close = closeShop,
	CloseUI = closeShopUI,
}
