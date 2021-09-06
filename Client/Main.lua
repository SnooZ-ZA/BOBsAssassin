ESX             = nil

local PlayerData = {}

MenuOpened = false
OnDuty = false
CurrentJob = nil
LastVehicle = 0

MainBlip = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	while true do
		if ESX == nil then
			Citizen.Wait(1)
		else
			ESX.PlayerData = xPlayer
			break
		end
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterCommand("coords", function()
	print(GetEntityCoords(PlayerPedId()))
end)

function OpenLocker()
	MenuOpened = true

	ESX.UI.Menu.Open("default", GetCurrentResourceName(), "locker_menu", {
		title = Config.TranslationList[Config.Translation]["LOCKER_MENU"],
		align = "bottom-right",
		elements = {
			{label = Config.TranslationList[Config.Translation]["WORK_CLOTHES"], value = "work_clothes"},
			{label = Config.TranslationList[Config.Translation]["NORMAL_CLOTHES"], value = "normal_clothes"}
		}
	}, 
	function(Data, LockerMenu) -- Selection
		if Data.current.value == "normal_clothes" then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(CurrentSkin, jobSkin)
				local isMale = CurrentSkin.sex == 0

				TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
					ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(CurrentSkin)
						TriggerEvent('skinchanger:loadSkin', CurrentSkin)
						OnDuty = false
					end)
				end)
			end)
		elseif Data.current.value == "work_clothes" then
			WorkClothesData = {}

			TriggerEvent('skinchanger:getSkin', function(CurrentSkin)
				if CurrentSkin.sex == 0 then
					WorkClothesData = Config.Uniforms.Male
				else
					WorkClothesData = Config.Uniforms.FeMale
				end

				if WorkClothesData ~= {} then
					TriggerEvent('skinchanger:loadClothes', CurrentSkin, WorkClothesData)
				end

				OnDuty = true
			end)
		end

		LockerMenu.close()
		MenuOpened = false
	end, 
	function(Data, LockerMenu) -- Close
		LockerMenu.close()
		MenuOpened = false
	end)
end

function OpenGarage()
	MenuOpened = true

	MenuList = {}

	for Index, CurrentVehicle in pairs(Config.Vehicles) do
		table.insert(MenuList, {label = CurrentVehicle.Name, value = CurrentVehicle.SpawnName})
	end

	ESX.UI.Menu.Open("default", GetCurrentResourceName(), "garage_menu", {
		title = Config.TranslationList[Config.Translation]["GARAGE_MENU"],
		align = "bottom-right",
		elements = MenuList
	}, 
	function(Data, GarageMenu) -- Selection
		for Index, CurrentVehicle in pairs(Config.Vehicles) do
			if Data.current.value == CurrentVehicle.SpawnName then
				VehicleHash = GetHashKey(CurrentVehicle.SpawnName)

				RequestModel(VehicleHash)

				Citizen.CreateThread(function()
					TimeWaited = 0

					while not HasModelLoaded(VehicleHash) do
						Citizen.Wait(100)
						TimeWaited = TimeWaited + 100

						if TimeWaited >= 5000 then
							ESX.ShowNotification(Config.TranslationList[Config.Translation]["GARAGE_PROBLEM"], false, true, 90)
							break
						end
					end

					NewVehicle = CreateVehicle(
						VehicleHash, 
						Config.VehicleSpawn.X, Config.VehicleSpawn.Y, Config.VehicleSpawn.Z,
						Config.VehicleSpawn.Heading,
						true, false
					)

					if (Config.LicensePlate ~= "") then
						SetVehicleNumberPlateText(NewVehicle, Config.LicensePlate)
					end

					SetVehicleOnGroundProperly(NewVehicle)
					SetModelAsNoLongerNeeded(VehicleHash)

					TaskWarpPedIntoVehicle(PlayerPedId(), NewVehicle, -1)
				end)
			end
		end

		GarageMenu.close()
		MenuOpened = false
	end, 
	function(Data, GarageMenu) -- Close
		GarageMenu.close()
		MenuOpened = false
	end)
end

function OpenMenu()
	MenuOpened = true

	ESX.UI.Menu.Open("default", GetCurrentResourceName(), "menu_menu", {
		title = Config.TranslationList[Config.Translation]["MENU_MENU"],
		align = "bottom-right",
		elements = {
			{label = Config.TranslationList[Config.Translation]["MENU_NEW"], value = "new_job"},
			{label = Config.TranslationList[Config.Translation]["MENU_CANCEL"], value = "cancel_job"}
		}
	}, 
	function(Data, MenuMenu) -- Selection
		if Data.current.value == "new_job" then
			if CurrentJob == nil then
			ShowAdvancedNotification('CHAR_LESTER', 'AGENCY', 'AGENT L', '~w~Stand by for Target Confirmation!')
			--ESX.UI.Menu.CloseAll()
				local wait = math.random(60000, 120000)
				Citizen.Wait(wait)
				RandomJob = Config.Jobs[math.random(1, #Config.Jobs)]
				
				CurrentJob = {}

				CurrentJob["X"] = RandomJob.X
				CurrentJob["Y"] = RandomJob.Y
				CurrentJob["Z"] = RandomJob.Z

				CurrentJob["Blip"] = AddBlipForCoord(CurrentJob.X, CurrentJob.Y, CurrentJob.Z)
				SetBlipSprite(CurrentJob.Blip, 433)
				SetBlipDisplay(CurrentJob.Blip, 4)
				SetBlipScale(CurrentJob.Blip, 1.0)
				SetBlipColour(CurrentJob.Blip, 64)
				SetBlipAsShortRange(CurrentJob.Blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(Config.JobBlipName)
				EndTextCommandSetBlipName(CurrentJob.Blip)

				SetNewWaypoint(CurrentJob.X, CurrentJob.Y)

				CurrentJob["Enabled"] = false

				--ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_CREATED"], false, true, 210)
				ShowAdvancedNotification('CHAR_LESTER', 'AGENCY', 'AGENT L', '~w~Target Confirmed! Eliminate the ~r~Kingpin.')
			else
				--ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_ALREADY"], false, true, 90)
				ShowAdvancedNotification('CHAR_LESTER', 'AGENCY', 'AGENT L', '~r~Already have a new Target!')
			end
		elseif Data.current.value == "cancel_job" then
			if CurrentJob ~= {} then
				RemoveBlip(CurrentJob.Blip)
				DeleteWaypoint()
				CurrentJob = nil
				ShowAdvancedNotification('CHAR_LESTER', 'AGENCY', 'AGENT L', '~r~Target Cancelled!')
				--ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_CANCELED"], false, true, 210)
				if DoesEntityExist(dealer) then
				DeleteEntity(dealer)
				DeleteEntity(goon)
				DeleteEntity(goon2)
				end
			else
				ShowAdvancedNotification('CHAR_LESTER', 'AGENCY', 'AGENT L', '~r~No Target!')
				--ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_NONE"], false, true, 90)
			end
		end

		MenuMenu.close()
		MenuOpened = false
	end, 
	function(Data, MenuMenu) -- Close
		MenuMenu.close()
		MenuOpened = false
	end)
end

RegisterNUICallback("main", function(RequestData)
	if RequestData.ReturnType == "EXIT" then
		if CurrentJob ~= {} then
			CurrentJob.Enabled = false

			SetNuiFocus(false, false)
			SendNUIMessage({RequestType = "Visibility", RequestData = false})
		else
			ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_NONE"], false, true, 90)
		end
	elseif RequestData.ReturnType == "DONE" then
		if CurrentJob ~= {} then
			SetNuiFocus(false, false)
			SendNUIMessage({RequestType = "Visibility", RequestData = false})

			RemoveBlip(CurrentJob.Blip)
			DeleteWaypoint()
			CurrentJob = nil

			TriggerServerEvent('esx_assassin:PayMoney', CurrentJob)
			
			ESX.ShowNotification(Config.TranslationList[Config.Translation]["JOB_DONE"], false, true, 210)
		else
			ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_NONE"], false, true, 90)
		end
	end
end)

LockerCoords = vector3(Config.Locker.X, Config.Locker.Y, Config.Locker.Z)
GarageCoords = vector3(Config.Garage.X, Config.Garage.Y, Config.Garage.Z)
DeleteCoords = vector3(Config.VehicleDelete.X, Config.VehicleDelete.Y, Config.VehicleDelete.Z)

Citizen.CreateThread(function() -- Locker
	while true do
		Citizen.Wait(1)

		if ESX ~= nil then
			PlayerJobInfo = ESX.PlayerData.job

			if PlayerJobInfo ~= nil then
				if PlayerJobInfo.name == "assassin" then
					PlayerCoords = GetEntityCoords(PlayerPedId())
					PlayerVehicle = GetVehiclePedIsIn(PlayerPedId())

					if Vdist2(PlayerCoords, LockerCoords) <= 1.5 and PlayerVehicle == 0 then
						ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["LOCKER_HELP"], true, false, 1)
					
						if IsControlJustPressed(1, 51) then
							if MenuOpened == false then
								OpenLocker()
							end
						end
					end

					-- Blip
					if MainBlip == nil then
						MainBlip = AddBlipForCoord(Config.Locker.X, Config.Locker.Y, Config.Locker.Z)
						SetBlipSprite(MainBlip, 480)
						SetBlipDisplay(MainBlip, 4)
						SetBlipScale(MainBlip, 1.0)
						SetBlipColour(MainBlip, 57)
						SetBlipAsShortRange(MainBlip, true)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString(Config.BlipName)
						EndTextCommandSetBlipName(MainBlip)
					end

					-- Circle
					DrawMarker(
						25, -- Type
						Config.Locker.X, Config.Locker.Y, Config.Locker.Z - 0.98, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						1.5, 1.5, 1.5, -- Scale
						255, 120, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

					-- Stripes
					DrawMarker(
						30, -- Type
						Config.Locker.X, Config.Locker.Y, Config.Locker.Z, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						0.75, 0.75, 0.75, -- Scale
						255, 120, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

				else
					if MainBlip ~= nil then
						RemoveBlip(MainBlip)
						MainBlip = nil
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function() -- Garage
	while true do
		Citizen.Wait(1)

		if ESX ~= nil then
			if OnDuty == true then
				PlayerCoords = GetEntityCoords(PlayerPedId())
				PlayerVehicle = GetVehiclePedIsIn(PlayerPedId())

				-- Circle
				DrawMarker(
					25, -- Type
					Config.Garage.X, Config.Garage.Y, Config.Garage.Z - 0.98, -- Position
					0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
					1.5, 1.5, 1.5, -- Scale
					255, 120, 0, 155, -- Color
					false, true, 2, nil, nil, false -- Extra
				)

				-- Car
				DrawMarker(
					36, -- Type
					Config.Garage.X, Config.Garage.Y, Config.Garage.Z, -- Position
					0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
					0.75, 0.75, 0.75, -- Scale
					255, 120, 0, 155, -- Color
					false, true, 2, nil, nil, false -- Extra
				)

				if Vdist2(PlayerCoords, GarageCoords) <= 1.5 and PlayerVehicle == 0 then
					ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["GARAGE_HELP"], true, false, 1)
				
					if IsControlJustPressed(1, 51) then
						if MenuOpened == false then
							OpenGarage()
						end
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function() -- Deleter
	while true do
		Citizen.Wait(1)

		if ESX ~= nil then
			if OnDuty == true then
				PlayerCoords = GetEntityCoords(PlayerPedId())
				PlayerVehicle = GetVehiclePedIsIn(PlayerPedId())

				IsVehicle = false

				for Index, CurrentVehicle in pairs(Config.Vehicles) do
					if IsVehicleModel(PlayerVehicle, GetHashKey(CurrentVehicle.SpawnName)) then
						IsVehicle = true
					end
				end

				if IsVehicle == true then
					-- Circle
					DrawMarker(
						25, -- Type
						Config.VehicleDelete.X, Config.VehicleDelete.Y, Config.VehicleDelete.Z - 0.98, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						3.5, 3.5, 3.5, -- Scale
						255, 0, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

					-- Car
					DrawMarker(
						36, -- Type
						Config.VehicleDelete.X, Config.VehicleDelete.Y, Config.VehicleDelete.Z + 0.5, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						3.0, 3.0, 3.0, -- Scale
						255, 0, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

					if Vdist2(PlayerCoords, DeleteCoords) <= 3.0 then
						ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["DELETE_HELP"], true, false, 1)
					
						if IsControlJustPressed(1, 51) then
							SetEntityAsMissionEntity(PlayerVehicle, true, true)
							DeleteVehicle(PlayerVehicle)
						end
					else
						if LastVehicle ~= PlayerVehicle then
							LastVehicle = PlayerVehicle
							ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["MENU_HELP"], false, false, 5000)
						end
					end

					if IsControlJustPressed(1, 10) then
						if MenuOpened == false then
							OpenMenu()
						end
					end
				else
					LastVehicle = 0
				end
			end
		end
	end
end)

local oPlayer = false
local InVehicle = false
local playerpos = false

Citizen.CreateThread(function()
    while(true) do
		oPlayer = PlayerPedId()
        InVehicle = IsPedInAnyVehicle(oPlayer, true)
		playerpos = GetEntityCoords(oPlayer)
        Citizen.Wait(500)
    end
end)


local relationshipTypes = {
  "a_m_y_business_03",
  "s_m_y_dealer_01",
} 

Citizen.CreateThread(function() -- Jobs
	while true do
		Citizen.Wait(1)

		if ESX ~= nil then
			if OnDuty == true and CurrentJob ~= nil then
				if CurrentJob.Enabled == false then
					PlayerCoords = GetEntityCoords(PlayerPedId())
					PlayerVehicle = GetVehiclePedIsIn(PlayerPedId())
					JobCoords = vector3(CurrentJob.X, CurrentJob.Y, CurrentJob.Z)
					
					if not DoesEntityExist(dealer) then
						RequestModel("a_m_y_business_01")
						while not HasModelLoaded("a_m_y_business_01") do
						Wait(10)
						end
					dealer = CreatePed(4, "a_m_y_business_01", CurrentJob.X, CurrentJob.Y, CurrentJob.Z, 268.9422, false, true)
						SetPedFleeAttributes(dealer, 0, 0)
						SetPedCombatAttributes(dealer, 46, 1)
						SetPedCombatAbility(dealer, 100)
						SetPedCombatMovement(dealer, 2)
						SetPedCombatRange(dealer, 2)
						SetPedKeepTask(dealer, true)
						GiveWeaponToPed(dealer, GetHashKey('WEAPON_CARBINERIFLE'),250,false,true)
					end
						if not DoesEntityExist(goon) then
						RequestModel("s_m_y_dealer_01")
						while not HasModelLoaded("s_m_y_dealer_01") do
						Wait(10)
						end
					goon = CreatePed(4, "s_m_y_dealer_01", CurrentJob.X -1, CurrentJob.Y -1, CurrentJob.Z, 168.9422, false, true)
						SetPedFleeAttributes(goon, 0, 0)
						SetPedCombatAttributes(goon, 46, 1)
						SetPedCombatAbility(goon, 100)
						SetPedCombatMovement(goon, 2)
						SetPedCombatRange(goon, 2)
						SetPedKeepTask(goon, true)
						GiveWeaponToPed(goon, GetHashKey('WEAPON_CARBINERIFLE'),250,false,true)
					end
						if not DoesEntityExist(goon2) then
						RequestModel("s_m_y_dealer_01")
						while not HasModelLoaded("s_m_y_dealer_01") do
						Wait(10)
						end
					goon2 = CreatePed(4, "s_m_y_dealer_01", CurrentJob.X +1.5, CurrentJob.Y +1.5, CurrentJob.Z, 68.9422, false, true)
						SetPedFleeAttributes(goon2, 0, 0)
						SetPedCombatAttributes(goon2, 46, 1)
						SetPedCombatAbility(goon2, 100)
						SetPedCombatMovement(goon2, 2)
						SetPedCombatRange(goon2, 2)
						SetPedKeepTask(goon2, true)
						GiveWeaponToPed(goon2, GetHashKey('WEAPON_CARBINERIFLE'),250,false,true)
					local playerped = PlayerPedId()
					
					AddRelationshipGroup('DrugsNPC')
					AddRelationshipGroup('PlayerPed')
					SetPedRelationshipGroupHash(dealer, 'DrugsNPC')
					SetPedRelationshipGroupHash(goon, 'DrugsNPC')
					SetPedRelationshipGroupHash(goon2, 'DrugsNPC')
					SetRelationshipBetweenGroups(5,GetPedRelationshipGroupDefaultHash(playerped),'DrugsNPC')
					SetRelationshipBetweenGroups(5,'DrugsNPC',GetPedRelationshipGroupDefaultHash(playerped))
					
					SetPedCombatRange(dealer,2)
					--TaskCombatPed(dealer,playerped, 0, 16)

					SetPedCombatRange(goon,2)
					--TaskCombatPed(goon,playerped, 0, 16)

					SetPedCombatRange(goon2,2)
					--TaskCombatPed(goon2,playerped, 0, 16)
					end

					-- Circle
					local pos = GetEntityCoords(dealer)
					local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, playerpos.x, playerpos.y, playerpos.z, true)
					DrawMarker(
						25, -- Type
						pos.x, pos.y, pos.z - 0.90, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						1.5, 1.5, 1.5, -- Scale
						0, 255, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

					if distance < 2 then
					drawText3D(pos.x, pos.y, pos.z + 1.0, '[~g~E~s~]~b~Search for Identity~s~')
					
						if IsControlJustPressed(1, 51) and IsEntityDead(dealer) and GetEntityModel(dealer) == GetHashKey("a_m_y_business_01") then
							CurrentJob.Enabled = true

							--SetNuiFocus(true, true)
							--SendNUIMessage({RequestType = "Visibility", RequestData = true})
							
							exports.rprogress:Custom({
								Async = true,
								x = 0.5,
								y = 0.5,
								From = 0,
								To = 100,
								Duration = 10000,
								Radius = 60,
								Stroke = 10,
								MaxAngle = 360,
								Rotation = 0,
								Easing = "easeLinear",
								Label = "Checking Identity",
								LabelPosition = "right",
								Color = "rgba(255, 255, 255, 1.0)",
								BGColor = "rgba(107, 109, 110, 0.95)",
								Animation = {
								scenario = "CODE_HUMAN_MEDIC_TEND_TO_DEAD", -- https://pastebin.com/6mrYTdQv
								--animationDictionary = "anim@heists@prison_heiststation@cop_reactions", -- https://alexguirre.github.io/animations-list/
								--animationName = "cop_b_idle",
								},
								DisableControls = {
								Mouse = false,
								Player = true,
								Vehicle = true
								},
								})
								Citizen.Wait(10500)
								if DoesEntityExist(dealer) then
								DeleteEntity(dealer)
								DeleteEntity(goon)
								DeleteEntity(goon2)
								end
								RemoveBlip(CurrentJob.Blip)
								DeleteWaypoint()
								CurrentJob = nil

								TriggerServerEvent('esx_assassin:PayMoney', CurrentJob)
								ShowAdvancedNotification('CHAR_LESTER', 'AGENCY', 'AGENT L', '~w~Identity Confirmed, Target Eliminated! Wire transfer complete!')
								--ESX.ShowNotification(Config.TranslationList[Config.Translation]["JOB_DONE"], false, true, 210)
						end
					end
				end
			end
		end
	end
end)

drawText3D = function(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
  
	local scale = 0.50
   
	if onScreen then
		SetTextScale(scale, scale)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 650
        DrawRect(_x, _y + 0.0120, 0.030 + factor , 0.030, 66, 66, 66, 100)
	end
end

function ShowAdvancedNotification(icon, sender, title, text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    SetNotificationMessage(icon, icon, true, 4, sender, title, text)
    DrawNotification(false, true)
end

AddEventHandler('esx:onPlayerDeath', function(data)
	if CurrentJob ~= {} then
	RemoveBlip(CurrentJob.Blip)
	DeleteWaypoint()
	CurrentJob = nil
	ShowAdvancedNotification('CHAR_LESTER', 'AGENCY', 'AGENT L', '~r~Mission Failed!')
	end
	if DoesEntityExist(dealer) then
	DeleteEntity(dealer)
	DeleteEntity(goon)
	DeleteEntity(goon2)
	end
end)
