
package.path = package.path
.. ";data/scripts/lib/?.lua"
.. ";data/scripts/sector/?.lua"
.. ";data/scripts/?.lua"

require("utility")

function initialize(Command,...)

	if(onServer())
	then
		-- printTable({...})
		UpgradeInventory(Command,...)
	end

	return terminate()
end

--------------------------------------------------------------------------------

function ReplaceInventoryItem(Armory,Index,Thing,Count)
-- replace the inventory item at the specified index with the specified thing.
-- this hot swaps the thing with the updated version.

	Armory:removeAll(Index)
	Armory:addAt(Thing,Index,Count)
	return
end

function UpgradeInventory(Command,...)
-- pull things out your your inventory to process.

	local Inv = Player():getInventory()

	for Iter,Things in pairs({Inv:getItemsByType(InventoryItemType.Turret)})
	do
		UpgradeInventoryWeapon(Inv,Things,Command,...)
	end

	for Iter,Things in pairs({Inv:getItemsByType(InventoryItemType.TurretTemplate)})
	do
		UpgradeInventoryWeapon(Inv,Things,Command,...)
	end

	return
end

function UpgradeInventoryWeapon(Inv,Things,Command,...)
-- handling upgrading weapons.

	local Item
	local Count

	if(Command == "open")
	then
		Entity(Player().craftIndex)
		:removeScript("lib/dcc-turret-editor/ui-turret-editor")

		Entity(Player().craftIndex)
		:addScriptOnce("lib/dcc-turret-editor/ui-turret-editor")
		return
	end

	for Iter,Thing in pairs(Things)
	do
		Item = Thing.item
		Count = Thing.amount

		if(Command == "targeting" and not (Item.automatic and Item.simultaneousShooting))
		then
			print("Adding Targeting to " .. Item.weaponName)
			Item.automatic = true
			Item.simultaneousShooting = true
			ReplaceInventoryItem(Inv,Iter,Item,Count)

		elseif(Command == "tracking")
		then
			local Speed = ...

			if(Speed == nil)
			then Speed = 1.0 end

			print("Upgrading Tracking Speed on " .. Item.weaponName .. " to " .. Speed)
			Item.turningSpeed = Speed
			ReplaceInventoryItem(Inv,Iter,Item,Count)

		elseif(Command == "energy")
		then
			if(Arg == nil)
			then Arg = 1.0
			else Arg = tonumber(Arg)
			end

			print("Removing excess energy buildup on " .. Item.weaponName)
			Item.energyIncreasePerSecond = Arg
			ReplaceInventoryItem(Inv,Iter,Item,Count)

		elseif(Command == "heat")
		then
			if(Arg == nil)
			then Arg = 1.0
			else Arg = tonumber(Arg)
			end

			print("Removing excess heat buildup on " .. Item.weaponName)
			Item.heatPerShot = Arg
			ReplaceInventoryItem(Inv,Iter,Item,Count)

		elseif(Command == "range")
		then
			local Range = ...

			if(Range == nil)
			then Range = 1.0 end

			print("Upgrading Range on " .. Item.weaponName .. " to " .. Range)
			local WeapList = {Item:getWeapons()}
			Item:clearWeapons()

			for WeapIter,Weap in pairs(WeapList)
			do
				Weap.reach = Range
				Item:addWeapon(Weap)
			end

			ReplaceInventoryItem(Inv,Iter,Item,Count)

		elseif(Command == "rate")
		then
			local Rate = ...

			if(Rate == nil)
			then Rate = 1.0 end

			print("Upgrading Fire Rate on " .. Item.weaponName .. " to " .. Rate)
			local WeapList = {Item:getWeapons()}
			Item:clearWeapons()

			for WeapIter,Weap in pairs(WeapList)
			do
				Weap.fireRate = Rate
				Item:addWeapon(Weap)
			end

			ReplaceInventoryItem(Inv,Iter,Item,Count)

		elseif(Command == "colour")
		then
			local H, S, V = ...

			if(H == nil)
			then H = 0 end

			if(S == nil)
			then S = 1.0 end

			if(V == nil)
			then V = 1.0 end

			print(
				"Upgrading Colour on " .. Item.weaponName ..
				" to " .. H .. " " .. S .. " " .. V
			)

			local WeapList = {Item:getWeapons()}
			Item:clearWeapons()

			for WeapIter,Weap in pairs(WeapList)
			do
				if(Weap.bouterColor ~= nil)
				then Weap.bouterColor = ColorHSV(H,S,V) end

				if(Weap.binnerColor ~= nil)
				then Weap.binnerColor = ColorHSV(H,S,V) end

				if(Weap.pcolor ~= nil)
				then Weap.pcolor = ColorHSV(H,S,V) end

				Item:addWeapon(Weap)
			end

			ReplaceInventoryItem(Inv,Iter,Item,Count)
		end
	end

	return
end
