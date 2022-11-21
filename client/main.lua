local ESX = exports['es_extended']:getSharedObject()
local PlayerData              	= {}
local currentZone               = ''
local LastZone                  = ''
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}

local consegne                  = {}
local consegnerandom            = 1
local isTaken                   = 0
local consegnato                = 0
local firstspawn                = false
local car						= 0
local copblip
local blipconsegna
disattivadialoghi = Config.DisattivaDialoghi

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

-- GPS 
RegisterCommand('_FurtoVeicoloGPS', function(souce, args)
    if args[1] then
        local metaCercata = CAP[tostring(args[1])]
        if metaCercata then
            SetNewWaypoint(metaCercata.x, metaCercata.y)
        end
    end
end)

CAP = {
    ["Tony"] = {
        x = 1454.16,
        y = -1651.8
    }
}

-- Furto Veicolo
Citizen.CreateThread(function()
	local deliveryids = 1
	for k,v in pairs(Config.DestinazioniAuto) do
		table.insert(consegne, {
				id = deliveryids,
				posx = v.Coordinate.x,
				posy = v.Coordinate.y,
				posz = v.Coordinate.z,
				car = v.Auto,
		})
		deliveryids = deliveryids + 1  
	end
end)

function SpawnCar()
	ESX.TriggerServerCallback('zenit_furtoveicolo:attivo', function(isActive, cooldown)
		if cooldown <= 0 then
			if isActive == 0 then
				ESX.TriggerServerCallback('zenit_furtoveicolo:poliziotti', function(anycops)
					if anycops >= Config.MinPolizia then

						consegnerandom = math.random(1,#consegne)
						
						ClearAreaOfVehicles(1452.24,-1646.57,66.37, 10.0, false, false, false, false, false)
						
						SetEntityAsNoLongerNeeded(car)
						DeleteVehicle(car)
						RemoveBlip(blipconsegna)

						autorandom = math.random(1,#consegne[consegnerandom].car)

						local vehiclehash = GetHashKey(consegne[consegnerandom].car[autorandom])
						RequestModel(vehiclehash)
						while not HasModelLoaded(vehiclehash) do
							RequestModel(vehiclehash)
							Citizen.Wait(1)
						end
						car = CreateVehicle(vehiclehash, 1452.24,-1646.57,66.37, true, false)
						SetEntityAsMissionEntity(car, true, true)
						
						TaskWarpPedIntoVehicle(GetPlayerPed(-1), car, -1)

						blipconsegna = AddBlipForCoord(consegne[consegnerandom].posx, consegne[consegnerandom].posy, consegne[consegnerandom].posz)
						SetBlipSprite(blipconsegna, 1)
						SetBlipDisplay(blipconsegna, 4)
						SetBlipScale(blipconsegna, 1.0)
						SetBlipColour(blipconsegna, 5)
						SetBlipAsShortRange(blipconsegna, true)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString("Punto Di Arrivo")
						EndTextCommandSetBlipName(blipconsegna)
						
						SetBlipRoute(blipconsegna, true)

						TriggerServerEvent('zenit_furtoveicolo:registraattivita', 1)

						isTaken = 1

						consegnato = 0
					else
						lib.notify({id = 'msgmpol', title = 'Allarme', description = 'Non ci sono abbastanza poliziotti in città!', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'globe', iconColor = '#fcfdfd'})
					end
				end)
			else
				lib.notify({id = 'msgcorso', title = 'Allarme', description = 'C\'è già un furto d\'auto in corso!', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'globe', iconColor = '#fcfdfd'})
			end
		else
			lib.notify({id = 'msgcooldown', title = 'Allarme', description = 'Un furto d\'auto è stato recentemente completato. Attendi per rubarne un altro.', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'globe', iconColor = '#fcfdfd'})
		end
	end)
end

function FinishDelivery()
  if(GetVehiclePedIsIn(GetPlayerPed(-1), false) == car) and GetEntitySpeed(car) < 3 then

		SetEntityAsNoLongerNeeded(car)
		DeleteEntity(car)

    RemoveBlip(blipconsegna)

		local finalpayment = Config.Paga
		TriggerServerEvent('zenit_furtoveicolo:pagamento', finalpayment)

		TriggerServerEvent('zenit_furtoveicolo:registraattivita', 0)

    isTaken = 0

    consegnato = 1

    TriggerServerEvent('zenit_furtoveicolo:stopalertpol')
	else
		lib.notify({id = 'msgauto', title = 'Allarme', description = 'Devi usare l\'auto che ti è stata fornita e devi fermarti completamente.', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'globe', iconColor = '#fcfdfd'})
  	end
end

function AbortDelivery()
	SetEntityAsNoLongerNeeded(car)
	DeleteEntity(car)
	RemoveBlip(blipconsegna)
	TriggerServerEvent('zenit_furtoveicolo:registraattivita', 0)
	isTaken = 0
	consegnato = 1
	TriggerServerEvent('zenit_furtoveicolo:stopalertpol')
end

--Controllo Player Lascia Auto
Citizen.CreateThread(function()
  while true do
    Wait(1000)
		if isTaken == 1 and consegnato == 0 and not (GetVehiclePedIsIn(GetPlayerPed(-1), false) == car) then
			lib.notify({id = 'msg15sec', title = 'Tony', description = 'Hai 15 secondi per tornare in macchina', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'commenting', iconColor = '#fcfdfd'})
			Wait(9000)
			if isTaken == 1 and consegnato == 0 and not (GetVehiclePedIsIn(GetPlayerPed(-1), false) == car) then
				lib.notify({id = 'msg5sec', title = 'Tony', description = 'Hai 5 secondi per tornare in macchina', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'commenting', iconColor = '#fcfdfd'})
				Wait(5000)
				lib.notify({id = 'msgfallito', title = 'Tony', description = 'Furto D\'auto Fallito', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'commenting', iconColor = '#fcfdfd'})
				AbortDelivery()
			end
		end
	end
end)

-- Manda Posizione/Allarme Alla Polizia
Citizen.CreateThread(function()
	Wait(Config.StartPosizione)
  while true do
    Citizen.Wait(Config.RefreshPosizione)
    if isTaken == 1 and IsPedInAnyVehicle(GetPlayerPed(-1)) then
			local coords = GetEntityCoords(GetPlayerPed(-1))
      TriggerServerEvent('zenit_furtoveicolo:alertpol', coords.x, coords.y, coords.z)
		elseif isTaken == 1 and not IsPedInAnyVehicle(GetPlayerPed(-1)) then
			TriggerServerEvent('zenit_furtoveicolo:stopalertpol')
    end
  end
end)

RegisterNetEvent('zenit_furtoveicolo:rimuovipolblip')
AddEventHandler('zenit_furtoveicolo:rimuovipolblip', function()
	RemoveBlip(copblip)
end)

RegisterNetEvent('zenit_furtoveicolo:setpolblip')
AddEventHandler('zenit_furtoveicolo:setpolblip', function(cx,cy,cz)
	RemoveBlip(copblip)
    copblip = AddBlipForCoord(cx,cy,cz)
    SetBlipSprite(copblip , 11)
    SetBlipScale(copblipy , 1.0)
	SetBlipColour(copblip, 1)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Furto Auto In Corso")
	EndTextCommandSetBlipName(copblip)
end)

RegisterNetEvent('zenit_furtoveicolo:setnotificapol')
AddEventHandler('zenit_furtoveicolo:setnotificapol', function()
	lib.notify({id = 'msgpolice', title = 'Allarme', description = 'Furto d\'auto in corso. Il tracker del veicolo sarà attivo sul tuo radar tra non molto.', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'globe', iconColor = '#fcfdfd'})
end)

-- Consegna Veicolo
Citizen.CreateThread(function()
    for k,v in pairs(Config.DestinazioniAuto) do 
        TriggerEvent('gridsystem:registerMarker', {
            name = 'ZenitConsegnaVeicolo_'..k,
            pos = v.Coordinate,
            scale = vector3(2.5, 2.5, 2.5),
            size = vector3(2.5, 2.5, 2.5),
            drawDistance = 7.0,
			msg = '', 
			type = 36,
            color = { r = 255, g = 255, b = 255 },
            control = 'E',
            action = function()
				lib.progressCircle({duration = 2000, label = 'Consegnando Veicolo...', position = 'bottom', useWhileDead = false, canCancel = false,})
				FinishDelivery()
				Wait(300)
				ExecuteCommand("e dancehorse2")
				Wait(1300)
				ExecuteCommand("e c")
            end,
			onEnter = function()
				lib.showTextUI('[E] Consegna il veicolo')
			end,
			onExit = function()
				lib.hideTextUI()
			end
        })
    end
end)

-- Dialogo Arturo
Citizen.CreateThread(function()
	if not disattivadialoghi then
		
TriggerEvent('gridsystem:registerMarker', {
    name = 'ZenitArturo_', 150.06,
    pos = vector3(-2066.23,-311.99, 13.00), 
    scale = vector3(0.5, 0.5, 0.5),
    msg = '', 
    drawDistance = 7.0,
    type = 32,
    color = { r = 255, g = 255, b = 255 },
    control = 'E', 
    action = function()
		if not disattivadialoghi then
			lib.progressCircle({duration = 2000, label = 'Parlando con Arturo...', position = 'bottom', useWhileDead = false, canCancel = false,disable = {car = true,},})
			ExecuteCommand("e think2")
		Wait(300)
		lib.notify({id = 'msg1', title = 'Tu', description = 'Mi servirebbe un lavoretto', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'user', iconColor = '#fcfdfd'})
        Wait(3000)
		lib.notify({id = 'msgarturo1', title = 'Arturo', description = 'Ti serve un lavoretto eh...', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'commenting', iconColor = '#fcfdfd'})
		Wait(3000)
		lib.notify({id = 'msgarturo2', title = 'Arturo', description = 'Bene, Vai da mio cugino Tony, dall\'altra parte della città', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'commenting', iconColor = '#fcfdfd'})
		Wait(3000)
		lib.notify({id = 'msgarturo3', title = 'Arturo', description = 'Ci penserà lui a te, Ti ho appena messo il gps al suo nascondiglio (Civico 189)', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'commenting', iconColor = '#fcfdfd'})
		Wait(700)
		ExecuteCommand('_FurtoVeicoloGPS Tony')
		ExecuteCommand("e c")
end
    end,

	onEnter = function()
		lib.showTextUI('[E] Parla Con Arturo')
	end,
	onExit = function()
		lib.hideTextUI()
	end

}) end 
end)

-- Dialogo Tony
TriggerEvent('gridsystem:registerMarker', {
    name = 'ZenitTony_', 150.06,
    pos = vector3(1454.23,-1651.72, 67.00), 
    scale = vector3(0.5, 0.5, 0.5),
    msg = '', 
    drawDistance = 7.0,
    type = 32,
    color = { r = 255, g = 255, b = 255 },
    control = 'E', 
    action = function()
		if not disattivadialoghi then
			
		lib.progressCircle({duration = 2000, label = 'Parlando con Tony...', position = 'bottom', useWhileDead = false, canCancel = false,disable = {car = true,},})
		ExecuteCommand("e think2")

		Wait(300)
		lib.notify({id = 'msg', title = 'Tu', description = 'Mi manda Arturo, mi servirebbe un lavoretto', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'user', iconColor = '#fcfdfd'})
		Wait(3000)
		lib.notify({id = 'msgtony1', title = 'Tony', description = 'Si, Mi ha parlato di te', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'commenting', iconColor = '#fcfdfd'})
		Wait(3000)
		lib.notify({id = 'msgtony2', title = 'Tony', description = 'Quello che devi fare è semplice, devi solo sbloccare un veicolo e portarlo a destinazione', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'commenting', iconColor = '#fcfdfd'})
		Wait(3000)
		lib.notify({id = 'msgtony4', title = 'Tony', description = 'Mi raccomando, non farti prendere dalla polizia!', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'commenting', iconColor = '#fcfdfd'})
		Wait(3000)

		ExecuteCommand("e c")
		SpawnCar()

		if lib.skillCheck('easy') then
			TriggerServerEvent("furtolog")
			lib.notify({id = 'msgtony6', title = 'Tony', description = 'Vai Uomo!', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'check', iconColor = '#1cf440'})
		else
			AbortDelivery()
			Wait(500)
			lib.notify({id = 'msgtony7', title = 'Tony', description = 'Non sei riuscito a sbloccare il veicolo', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'times', iconColor = '#C53030'})
		end
	else
		lib.notify({id = 'msgfv', title = 'Furto Veicolo', description = 'Arriva a destinazione senza farti prendere dalla polizia', position = 'top', style = {backgroundColor = '#141517',color = '#909296'},icon = 'check', iconColor = '#fcfdfd'})
		Wait(1000)
		TriggerServerEvent("furtolog")
		SpawnCar()
	end
    end,

	onEnter = function()
		lib.showTextUI('[E] Parla Con Tony')
	end,
	onExit = function()
		lib.hideTextUI()
	end

})

-- Spawn Dei Vari Ped
-- Spawn Ped Arturo
Citizen.CreateThread(function()
    RequestModel(GetHashKey("cs_old_man2"))

    while not HasModelLoaded(GetHashKey("cs_old_man2")) do
        Wait(1000)
    end

	local npc = CreatePed(6, 0x98F9E770, -2066.18,-312.47, 12.27, 351.0, false, false)

    SetEntityHeading(npc, 351.0)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

end)

--Spawn Ped Tony
Citizen.CreateThread(function()
    RequestModel(GetHashKey("cs_omega"))

    while not HasModelLoaded(GetHashKey("cs_omega")) do
        Wait(1000)
    end

	local npc = CreatePed(6, 0x8B70B405, 1454.75,-1651.53, 66.00, 115.0, false, false)

    SetEntityHeading(npc, 115.0)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

end)

-- Blip Mappa
Citizen.CreateThread(function()
	if not disattivadialoghi then
blipfurto = AddBlipForCoord(-2066.23,-311.89, 13.23)
SetBlipSprite(blipfurto, 545)
SetBlipDisplay(blipfurto, 4)
SetBlipScale(blipfurto, 0.6)
SetBlipColour(blipfurto, 1)
SetBlipAsShortRange(blipfurto, true)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString("Furto D'auto")
EndTextCommandSetBlipName(blipfurto)
	else
blipfurto = AddBlipForCoord(1454.23,-1651.72, 67.00)
SetBlipSprite(blipfurto, 545)
SetBlipDisplay(blipfurto, 4)
SetBlipScale(blipfurto, 0.6)
SetBlipColour(blipfurto, 1)
SetBlipAsShortRange(blipfurto, true)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString("Furto D'auto")
EndTextCommandSetBlipName(blipfurto)
	end
end)