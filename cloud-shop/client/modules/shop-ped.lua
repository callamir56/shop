local peds = {}

---@param shopData table
---@param shopCoords vector4
---@return number|nil
local function spawnPed(shopData, shopCoords)
	local pedConfig = shopData.Indicator.Ped
	local pedPos = shopCoords
	local pedModel = pedConfig.model
	local isFemale = false
	if pedConfig.models and #pedConfig.models > 0 then
		local chosen = pedConfig.models[math.random(#pedConfig.models)]
		pedModel = chosen.model
		isFemale = chosen.gender == "female"
	end
	local pedScenario = pedConfig.scenario

	if not IsModelInCdimage(pedModel) or not IsModelAPed(pedModel) then
		log.error("[spawnPed] Ped hash is not valid, failed to spawn ped.")
		return nil
	end

	lib.requestModel(pedModel)
	local ped = CreatePed(0, pedModel, pedPos.x, pedPos.y, pedPos.z - 1, pedPos.w, false, false)
	SetModelAsNoLongerNeeded(pedModel)

	ped = lib.waitFor(function()
		if DoesEntityExist(ped) and ped ~= 0 then return ped end
	end, "[spawnPed] Could not create ped in time.", 3000)

	if not ped or ped == 0 then
		log.error("[spawnPed] Ped creation failed or timed out.")
		return nil
	end

	SetPedFleeAttributes(ped, 0, false)
	SetBlockingOfNonTemporaryEvents(ped, true)
	SetEntityInvincible(ped, true)
	FreezeEntityPosition(ped, true)
	TaskStartScenarioInPlace(ped, pedScenario, 0, true)

	peds[#peds + 1] = { ped = ped, pos = pedPos, isFemale = isFemale }
	return ped
end

---@return boolean
local function isNearestPedFemale()
	local playerPos = GetEntityCoords(cache.ped)
	for i = 1, #peds do
		if #(playerPos - vec3(peds[i].pos.x, peds[i].pos.y, peds[i].pos.z)) <= 15.0 then
			return peds[i].isFemale == true
		end
	end
	return false
end

---@return number|nil
local function getNearestPed()
	local playerPos = GetEntityCoords(cache.ped)
	for i = 1, #peds do
		local ped, pedPos = peds[i].ped, peds[i].pos

		if not DoesEntityExist(ped) then
			log.error("[getNearestPed] Ped does not exist.")
			return nil
		end

		local distance = #(vector3(pedPos.x, pedPos.y, pedPos.z) - playerPos)
		if distance <= 15.0 then return ped end
	end
	log.error("[getNearestPed] No valid peds found within 15.0 units.")
	return nil
end

---@param ped number
local function removePed(ped)
	if not DoesEntityExist(ped) then return end
	DeletePed(ped)

	for i = #peds, 1, -1 do
		if peds[i].ped == ped then
			peds[i] = peds[#peds]
			peds[#peds] = nil
			break
		end
	end
end

local function removeAllPeds()
	for i = 1, #peds do
		local ped = peds[i].ped
		if DoesEntityExist(ped) then DeletePed(ped) end
	end
	peds = {}
end

---@param speechName string
---@param speechParam string
local function applySpeechToPed(speechName, speechParam)
	return
end

return {
	Spawn = spawnPed,
	Delete = removePed,
	DeleteAll = removeAllPeds,
	ApplySpeech = applySpeechToPed,
	IsNearestFemale = isNearestPedFemale,
}
