ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_assassin:PayMoney')
AddEventHandler('esx_assassin:PayMoney', function()
    xPlayer = ESX.GetPlayerFromId(source)
    PlayerJob = xPlayer.getJob()

    if PlayerJob.name == "assassin" then
        if Config.MoneyType == true then
            xPlayer.addMoney(Config.MoneyAmount)
        else
            xPlayer.addAccountMoney('bank', Config.MoneyAmount)
        end
    end
	
	if Config.Society then
        TriggerEvent('esx_addonaccount:getSharedAccount', Config.SocietyName, function(account)
            account.addMoney(Config.MoneyAmount*.10)
		end)			
	end
end)
