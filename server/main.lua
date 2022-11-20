local ESX = exports['es_extended']:getSharedObject()

local activity = 0
local activitySource = 0
local cooldown = 0

RegisterServerEvent('zenit_furtoveicolo:pagamento')
AddEventHandler('zenit_furtoveicolo:pagamento', function(payment)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.addAccountMoney(Config.TipoPagamento,tonumber(payment))
	
	-- Cooldown
	cooldown = Config.MinutiDiCooldown * 60000
end)

ESX.RegisterServerCallback('zenit_furtoveicolo:poliziotti',function(source, cb)
  local anycops = 0
  local playerList = ESX.GetPlayers()
  for i=1, #playerList, 1 do
    local _source = playerList[i]
    local xPlayer = ESX.GetPlayerFromId(_source)
    local playerjob = xPlayer.job.name
    if playerjob == Config.NomeJobPol then
      anycops = anycops + 1
    end
  end
  cb(anycops)
end)

ESX.RegisterServerCallback('zenit_furtoveicolo:attivo',function(source, cb)
  cb(activity, cooldown)
end)

RegisterServerEvent('zenit_furtoveicolo:registraattivita')
AddEventHandler('zenit_furtoveicolo:registraattivita', function(value)
	activity = value
	if value == 1 then
		activitySource = source
		local xPlayers = ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == Config.NomeJobPol then
				TriggerClientEvent('zenit_furtoveicolo:setnotificapol', xPlayers[i])
			end
		end
	else
		activitySource = 0
	end
end)

RegisterServerEvent('zenit_furtoveicolo:alertpol')
AddEventHandler('zenit_furtoveicolo:alertpol', function(cx,cy,cz)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == Config.NomeJobPol then
			TriggerClientEvent('zenit_furtoveicolo:setpolblip', xPlayers[i], cx,cy,cz)
		end
	end
end)

RegisterServerEvent('zenit_furtoveicolo:stopalertpol')
AddEventHandler('zenit_furtoveicolo:stopalertpol', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == Config.NomeJobPol then
			TriggerClientEvent('zenit_furtoveicolo:rimuovipolblip', xPlayers[i])
		end
	end
end)

RegisterServerEvent('furtolog')
AddEventHandler('furtolog', function(data)

    local playerName = GetPlayerName(source)
    local playerHex = GetPlayerIdentifier(source)

    local logs = {
        {
            ["color"] = Config.ColoreEmbed,
            ["title"] = "Log Furto D\'auto" ,
            ["description"] = "**Segnalazione - Hanno Appena Avviato Un Furto D\'auto \n\n Steam: **"..playerName.."**\n\n Steam HEX: **"..playerHex.."**",
        }

    }
    PerformHttpRequest(Config.WebHook, function(err, text, headers) end, 'POST', json.encode({embeds = logs}), { ['Content-Type'] = 'application/json' })
end)
