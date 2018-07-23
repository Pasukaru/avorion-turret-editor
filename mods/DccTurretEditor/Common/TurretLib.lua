
local This = {};
local Config = require("mods.DccTurretEditor.Common.ConfigLib")

--------------------------------------------------------------------------------
-- these ones need to deal with each individual weapon on the turret -----------

function This:GetWeaponType(Item)
-- returns "projectile" or "beam"

	local WeapList = {Item:getWeapons()}

	for WeapIter,Weap in pairs(WeapList) do
		if(Weap.isProjectile) then
			return "projectile"
		else
			return "beam"
		end
	end

	return
end

function This:BumpWeaponNameMark(Item)
-- bump the mark names on weapons. we do this mainly to trick the game into
-- never stacking the items.

	local WeapList = {Item:getWeapons()}
	local Value = 0
	local Mark
	Item:clearWeapons()

	for WeapIter,Weap in pairs(WeapList) do

		print("[DccTurretEditor] Weapon Name: " .. Weap.name .. ", Prefix: " .. Weap.prefix)

		Mark = string.match(Weap.name," Mk (%d+)$")
		if(Mark == nil) then
			Weap.name = Weap.name .. " Mk 1"
			Weap.prefix = Weap.prefix .. " Mk 1"
		else
			Mark = tonumber(Mark) + 1
			Weap.name = string.gsub(Weap.name," Mk (%d+)$"," Mk " .. Mark)
			Weap.prefix = string.gsub(Weap.prefix," Mk (%d+)$"," Mk " .. Mark)
		end

		Item:addWeapon(Weap)
	end

	return
end

function This:GetWeaponCount(Item)
-- get how many guns are on this turret.

	local WeapList = {Item:getWeapons()}
	local Count = 0

	for WeapIter,Weap in pairs(WeapList) do
		Count = Count + 1
	end

	return Count
end

--------

function This:GetWeaponFireRate(Item)
-- get how fast this turret shoots

	local WeapList = {Item:getWeapons()}

	for WeapIter,Weap in pairs(WeapList) do
		return round(Weap.fireRate,3)
	end

	return
end

function This:ModWeaponFireRate(Item,Per)
-- modify the fire rate by a percent

	This:BumpWeaponNameMark(Item)

	local WeapList = {Item:getWeapons()}
	local Value = 0
	Item:clearWeapons()

	for WeapIter,Weap in pairs(WeapList) do
		Value = ((Weap.fireRate * (Per / 100)) + Weap.fireRate)

		if(Value < 0) then
			Value = 0
		end

		print("[DccTurretEditor] Fire Rate: " .. Weap.fireRate .. " " .. Value)

		Weap.fireRate = Value
		Item:addWeapon(Weap)
	end

	return
end

--------

function This:GetWeaponRange(Item)
-- get weapon range in km.

	local WeapList = {Item:getWeapons()}

	for WeapIter,Weap in pairs(WeapList)
	do
		return round(Weap.reach / 100,3)
	end

	return
end

function This:ModWeaponRange(Item,Per)
-- modify the range by a percent

	This:BumpWeaponNameMark(Item)

	local WeapList = {Item:getWeapons()}
	local Value = 0
	Item:clearWeapons()

	for WeapIter,Weap in pairs(WeapList) do
		Value = ((Weap.reach * (Per / 100)) + Weap.reach)

		if(Value < 0) then
			Value = 0
		end

		Weap.reach = Value
		Item:addWeapon(Weap)
	end

	return
end

--------

function This:GetWeaponDamage(Item)
-- get weapon range in km.

	local WeapList = {Item:getWeapons()}

	for WeapIter,Weap in pairs(WeapList)
	do
		return round(Weap.damage,3)
	end

	return
end

function This:ModWeaponDamage(Item,Per)
-- modify the range by a percent

	This:BumpWeaponNameMark(Item)

	local WeapList = {Item:getWeapons()}
	local Value = 0
	Item:clearWeapons()

	for WeapIter,Weap in pairs(WeapList) do
		Value = ((Weap.damage * (Per / 100)) + Weap.damage)

		if(Value < 0) then
			Value = 0
		end

		print(
			"[DccTurretEditor] Weapon Dmg: " .. Weap.damage .. " " .. Value
		)

		Weap.damage = Value
		Item:addWeapon(Weap)
	end

	return
end

--------

function This:GetWeaponAccuracy(Item)
-- get weapon accuracy.

	local WeapList = {Item:getWeapons()}

	for WeapIter,Weap in pairs(WeapList)
	do
		return round(Weap.accuracy,3)
	end

	return
end

function This:ModWeaponAccuracy(Item,Per)
-- modify the accuracy by a percent

	This:BumpWeaponNameMark(Item)

	local WeapList = {Item:getWeapons()}
	local Value = 0
	Item:clearWeapons()

	for WeapIter,Weap in pairs(WeapList) do
		Value = ((Weap.accuracy * (Per / 100)) + Weap.accuracy)

		if(Value < 0) then
			Value = 0.0
		elseif(Value > 1) then
			Value = 1.0
		end

		Weap.accuracy = Value
		Item:addWeapon(Weap)
	end

	return
end

--------

function This:GetWeaponEfficiency(Item)
-- get weapon accuracy, autodetecting mining or scav.

	local WeapList = {Item:getWeapons()}

	for WeapIter,Weap in pairs(WeapList)
	do
		if(Item.category == WeaponCategory.Mining) then
			return round(Weap.stoneEfficiency,5)
		elseif(Item.category == WeaponCategory.Salvaging) then
			return round(Weap.metalEfficiency,5)
		else
			return 0
		end
	end

	return
end

function This:ModWeaponEfficiency(Item,Per)
-- modify the accuracy by a percent, autodetecting mining or scav.

	This:BumpWeaponNameMark(Item)

	local WeapList = {Item:getWeapons()}
	local Value = 0
	local Initial = 0
	Item:clearWeapons()

	for WeapIter,Weap in pairs(WeapList) do

		if(Item.category == WeaponCategory.Mining) then
			Initial = Weap.stoneEfficiency
		elseif(Item.category == WeaponCategory.Salvaging) then
			Initial = Weap.metalEfficiency
		end

		Value = ((Initial * (Per / 100)) + Initial)

		if(Value < 0) then
			Value = 0.0
		elseif(Value > 1) then
			Value = 1.0
		end

		-- it appears there is a bug where stone and metal eff may not be
		-- included in the decision on if items should stack or not. so,
		-- we will also include a super stupid damage increase until koon
		-- gets back with me on it.

		if(Item.category == WeaponCategory.Mining) then
			print("[DccTurretEditor] Modding Mining Gun: " .. Item.weaponName .. " " .. Initial .. " " .. Value)
			Weap.stoneEfficiency = Value
		elseif(Item.category == WeaponCategory.Salvaging) then
			print("[DccTurretEditor] Modding Scav Gun: " .. Item.weaponName .. " " .. Initial .. " " .. Value)
			Weap.metalEfficiency = Value
		end

		Item:addWeapon(Weap)
	end

	return
end

--------

function This:GetWeaponColour(Item)
-- get what colour this turret

	local WeapList = {Item:getWeapons()}

	for WeapIter,Weap in pairs(WeapList) do
		if(Weap.isProjectile) then
			return Weap.pcolor
		else
			return Weap.binnerColor
		end
	end

	return
end

function This:SetWeaponColour(Item,Colour)
-- modify the fire rate by a percent

	This:BumpWeaponNameMark(Item)

	local WeapList = {Item:getWeapons()}
	local Value = 0
	Item:clearWeapons()

	-- screw with the colours the player set a little bit to create something
	-- that visually looks slightly nicer in practice.

	local Colour1 = Color()
	local Colour2 = Color()

	Colour1:setHSV(
		Colour.hue,
		(Colour.saturation * Config.Colour1Mod.Sat),
		(Colour.value * Config.Colour1Mod.Val)
	)

	Colour2:setHSV(
		Colour.hue,
		(Colour.saturation * Config.Colour2Mod.Sat),
		(Colour.value * Config.Colour2Mod.Val)
	)

	for WeapIter,Weap in pairs(WeapList) do

		if(Weap.isProjectile) then
			Weap.pcolor = Colour2
		else
			Weap.binnerColor = Colour1
			Weap.bouterColor = Colour2
		end

		Item:addWeapon(Weap)
	end

	return
end

--------------------------------------------------------------------------------
-- these ones need to deal with the turret as a whole --------------------------

function This:GetWeaponRarityValue(Item)
-- get the rarity value we can use for math.

	-- petty items start at -1 for some reason. i am not even sure the
	-- game drops them. oh nvm yes it does, they are dark grey i always
	-- forget that.

	local Value = 1

	if(Item.rarity.value == RarityType.Petty) then
		Value = 0.5
	elseif(Item.rarity.value == RarityType.Common) then
		Value = 1
	elseif(Item.rarity.value == RarityType.Uncommon) then
		Value = 2
	elseif(Item.rarity.value == RarityType.Rare) then
		Value = 3
	elseif(Item.rarity.value == RarityType.Exceptional) then
		Value = 4
	elseif(Item.rarity.value == RarityType.Exotic) then
		Value = 5
	elseif(Item.rarity.value == RarityType.Legendary) then
		Value = 6
	end

	return Value
end

--------

function This:GetWeaponCategory(Item)
-- returns the WeaponType

	return Item.category
end

--------

function This:GetWeaponHeatRate(Item)
-- get the heat per shot of this item.

	return round(Item.heatPerShot,3)
end

function This:ModWeaponHeatRate(Item,Per)
-- modify the heat per shot value by a percent.

	This:BumpWeaponNameMark(Item)

	local Value = ((Item.heatPerShot * (Per / 100)) + Item.heatPerShot)

	if(Value < 0) then
		Value = 0
	end

	Item.heatPerShot = Value
	return
end

--------

function This:GetWeaponCoolRate(Item)
-- get the cooling rate for this turret.

	return round(Item.coolingRate,3)
end

function This:ModWeaponCoolRate(Item,Per)
-- modify the cooling rate value by a percent.

	This:BumpWeaponNameMark(Item)

	local Value = ((Item.coolingRate * (Per / 100)) + Item.coolingRate)

	if(Value < 0) then
		Value = 0
	end

	Item.coolingRate = Value
	return
end

--------

function This:GetWeaponMaxHeat(Item)
-- get the max heat for this turret.

	return round(Item.maxHeat,3)
end

function This:ModWeaponMaxHeat(Item,Per)
-- modify the max heat value by a percent.

	This:BumpWeaponNameMark(Item)

	local Value = ((Item.maxHeat * (Per / 100)) + Item.maxHeat)

	if(Value < 0) then
		Value = 0
	end

	Item.maxHeat = Value
	return
end

--------

function This:GetWeaponBaseEnergy(Item)
-- get the base energy per second.

	return round(Item.baseEnergyPerSecond,3)
end

function This:ModWeaponBaseEnergy(Item,Per)
-- modify the base energy value by a percent.

	This:BumpWeaponNameMark(Item)

	local Value = ((Item.baseEnergyPerSecond * (Per / 100)) + Item.baseEnergyPerSecond)

	if(Value < 0) then
		Value = 0
	end

	Item.baseEnergyPerSecond = Value
	return
end

--------

function This:GetWeaponAccumEnergy(Item)
-- get the energy accumulation over time.

	return round(Item.energyIncreasePerSecond,3)
end

function This:ModWeaponAccumEnergy(Item,Per)
-- modify the energy accumulation value by a percent.

	This:BumpWeaponNameMark(Item)

	local Value = ((Item.energyIncreasePerSecond * (Per / 100)) + Item.energyIncreasePerSecond)

	if(Value < 0) then
		Value = 0
	end

	Item.energyIncreasePerSecond = Value
	return
end

--------

function This:GetWeaponSpeed(Item)
-- get the turret tracking speed

	return round(Item.turningSpeed,3)
end

function This:ModWeaponSpeed(Item,Per)
-- modify the energy accumulation value by a percent.

	This:BumpWeaponNameMark(Item)

	local Value = ((Item.turningSpeed * (Per / 100)) + Item.turningSpeed)

	if(Value < 0) then
		Value = 0
	end

	Item.turningSpeed = Value
	return
end

--------

function This:GetWeaponTargeting(Item)
-- get turret targeting.

	return Item.automatic
end

function This:SetWeaponTargeting(Item,Val)
-- set automatic targeting.

	This:BumpWeaponNameMark(Item)

	Item.automatic = Val
	return
end

function This:ToggleWeaponTargeting(Item)
-- set automatic targeting.

	This:BumpWeaponNameMark(Item)

	Item.automatic = not Item.automatic
	return
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


function This:GetWeaponCrew(Item)
-- get required crew. if its a civil cannon it returns the miner count and if
-- an offensive weapon it returns the gunner count.



	return
end

function This:SetWeaponCrew(Item,Val)
-- set required crew. if a civil cannon it sets the miner count and if an
-- offensive weapon it sets the gunner count.

	return
end

return This