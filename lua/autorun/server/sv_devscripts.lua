--------------------
// Made by Dev for Werwolf //
--------------------
util.AddNetworkString("radio_addtext")
util.AddNetworkString("urgency_addtext")
util.AddNetworkString("request_add")
util.AddNetworkString("mayor_sounds")
util.AddNetworkString("mayor_citysweep")
util.AddNetworkString("mayor_citysweepend")
util.AddNetworkString("antiAFKCheck")
util.AddNetworkString("looc_chatadd")
util.AddNetworkString("mayor_bankannouncement")
util.AddNetworkString("mayor_bankannouncementend")
--------------------
// Config //
--------------------
local policeGroups = { -- Those listed can use /radio and can hear /radio
TEAM_VOLUNTEERPOLICE, TEAM_POLICE, TEAM_ARMEDPOLICE, TEAM_POLICECHIEF, TEAM_SWAT, TEAM_SWATCQC,
TEAM_SWATLEADER, TEAM_REGIONALPOLICERANGER, TEAM_REGIONALARMEDRANGER, TEAM_DELTAENFORCERIFLE, TEAM_DELTAENFORCERCQC,
TEAM_DELTAENFORCETL, TEAM_REGIONALADVISOR, TEAM_CENTRALPOLICE, TEAM_CENTRALPOLICECHIEF, TEAM_MILITARYRIFLE, TEAM_MILITARYCQC,
TEAM_MILITARYSNIPER, TEAM_MILITARYJUGGERNAUT, TEAM_ALPHAENFORCERS, TEAM_ALPHACQC, TEAM_ALPHALEADER, TEAM_ALPHAENFORCERSSNIP, 
TEAM_ALPHAENFORCERSLEADER, TEAM_MAYOR
}
local alpha = {
TEAM_ALPHACQC, TEAM_ALPHALEADER, TEAM_ALPHAENFORCERSSNIP, 
TEAM_ALPHAENFORCERSLEADER
}
local radio_timeout = 10 -- Time in seconds for radio timeout

local urgency_timeout = 10

local request_timeout = 10 
--------------------
// Main //
--------------------

local function radioChat(text,plyname)
	for k,v in pairs(player.GetAll()) do
		if table.HasValue(policeGroups, v:Team()) then
			net.Start("radio_addtext")
				net.WriteString(text)
				net.WriteString(plyname)
			net.Send(v)
		end
	end
end

local function urgencyChat(plyname)
	for k,v in pairs(player.GetAll()) do
		if table.HasValue(policeGroups, v:Team()) then
			net.Start("urgency_addtext")
				net.WriteString(plyname)
			net.Send(v)
		end
	end
end

local function request(plyname,text)
	for k,v in pairs(player.GetAll()) do
		if table.HasValue(policeGroups, v:Team()) then
			net.Start("request_add")
				net.WriteString(plyname)
				net.WriteString(text)
			net.Send(v)
		end
	end
end

hook.Add("PlayerSay", "radioCallFunc", function(ply,text) -- Radio call function
	local temp = string.Split(text, " ")
	if temp[1] ~= "/radio" then return end
	if !table.HasValue(policeGroups,ply:Team()) then ply:SendLua('notification.AddLegacy("You may not use the government radio!", NOTIFY_ERROR, 5)') return "" end
	if ply.radioTimeout == 1 then ply:SendLua('notification.AddLegacy("You may not use radio again yet!", NOTIFY_ERROR, 5)') return "" end
	if #temp == 1 then ply:SendLua('notification.AddLegacy("Invalid radio message", NOTIFY_ERROR, 5)') return "" end
	radioChat(string.gsub(text, "/radio", ""), ply:Name())
	ply.radioTimeout = 1
	timer.Simple(radio_timeout, function() ply.radioTimeout = 0 end)
	ply:ConCommand("say /me radios in: " .. string.gsub(text, "/radio ", ""))
	return ""
end)

hook.Add("PlayerSay", "urgencyCallFunc", function(ply,text) -- Radio call function
	local temp = string.Split(text, " ")
	if temp[1] ~= "/panic" then return end
	if !table.HasValue(policeGroups,ply:Team()) then ply:SendLua('notification.AddLegacy("You may not use the government radio!", NOTIFY_ERROR, 5)') return "" end
	if ply.urgencyTimeout == 1 then ply:SendLua('notification.AddLegacy("You may not use your panic button again yet!", NOTIFY_ERROR, 5)') return "" end
	urgencyChat(ply:Name())
	sound.Play("HL1/fvox/beep.wav", ply:GetPos(), 75, 100, 1)
	ply.urgencyTimeout = 1
	timer.Simple(urgency_timeout, function() ply.urgencyTimeout = 0 end)
	return ""
end)

hook.Add("PlayerSay", "requestCallFunc", function(ply,text) -- Radio call function
	local temp = string.Split(text, " ")
	if temp[1] ~= "/request" then return end
	if ply.requestTimeout == 1 then ply:SendLua('notification.AddLegacy("You may not request again yet!", NOTIFY_ERROR, 5)') return "" end
	request(ply:Name(), string.gsub(text, "/request", ""))
	ply.requestTimeout = 1
	timer.Simple(request_timeout, function() ply.requestTimeout = 0 end)
	ply:ChatPrint("Request sent to government officals")
	return ""
end)

-- Realistic changes

hook.Add("PlayerSpawn", "changeStunStick", function(ply)
	timer.Simple(1, function()
		for k,v in pairs(ply:GetWeapons()) do
			if v:GetClass() == "stunstick" then
				ply:StripWeapon("stunstick")
			elseif v:GetClass() == "cw_ws_kabar" then
				ply:StripWeapon("cw_ws_kabar")
			end
		end
	end)
end)

hook.Add("CanPlayerSuicide", "refuseSuicide", function(ply)
	ply:SendLua('notification.AddLegacy("You may not suicide!", NOTIFY_ERROR, 5)')
	return false
end)

hook.Add("PlayerSay", "giverppp", function(ply,text)
	local temp = string.Split(text, " ")
	if temp[1] ~= "/giverpp" then return end
	if !ply:CheckGroup("headadmin") then ply:ChatPrint("You may not award RP points!") return "" end
	if #temp == 1 or #temp == 2 then ply:ChatPrint("/giverpp [player] [reason]") return "" end
	local target = temp[2]
	local targetPlys = {}
	for k,v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Name()), string.lower(target)) then
			table.insert(targetPlys, v)
		end
	end
	if #targetPlys ~= 1 then ply:ChatPrint("You may only target one player! Players targetted: " .. table.ToString(targetPlys)) return "" end
	local target = targetPlys[1]
	local reason = string.gsub(string.gsub(text,"/giverpp ", ""), temp[2] .. " ","")
	target:SetPData("roleplay_points", target:GetPData("roleplay_points", 0) + 1)
	target:SetNWInt("roleplay_points", target:GetNWInt("roleplay_points") + 1)
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint("[teal](RPP) [white]" .. ply:Name() .. " gave " .. target:Name() .. " an RP point for: " .. reason)
	end
	return ""
end)

hook.Add("PlayerInitialSpawn", "giveexistingrppp", function(ply)
	ply:SetNWInt("roleplay_points", ply:GetPData("roleplay_points"))
end)

hook.Add("PlayerSpawn", "giveEquip", function(ply)
	if !table.HasValue(policeGroups, ply:Team()) then return end
	ply:Give("weapon_stungun")
	ply:Give("weapon_cuff_police")
	ply:Give("weapon_kidnapper")
	timer.Simple(2, function()
		ply:ConCommand("say /me equips kevlar vest - proven to block damage by around 50%!")
	end)

	-- Ammo
	ply:GiveAmmo(20, ".338 Lapua")
	ply:GiveAmmo(250, "9x19MM")
	ply:GiveAmmo(20, "12 Gauge")
	ply:GiveAmmo(250, "5.56x45MM")
	ply:GiveAmmo(50, ".45 ACP")

	timer.Simple(1, function()
		ply:StripWeapon("unarrest_stick")
		ply:StripWeapon("arrest_stick")
	end)
end)

hook.Add("ScalePlayerDamage", "kevalrArmour", function(ply,hit,dmginfo)
	if !table.HasValue(policeGroups, ply:Team()) then return end
	if (hit == HITGROUP_HEAD) and !table.HasValue(alpha, ply:Team()) then return end
	dmginfo:ScaleDamage(0.5)
end)

-- Mayor chat commands

local announcementsAC = {
{"npc/overwatch/cityvoice/f_anticivil1_5_spkr.wav", "You are charged with anticivil activity level 1; Protection Units prosecution code: Duty, Sword, Operate."},
{"npc/overwatch/cityvoice/f_anticitizenreport_spkr.wav", "Attention Ground Units, anticitizen reported in this community. Code: Lock, Cauterise, Stabilize. "},
{"npc/overwatch/cityvoice/f_localunrest_spkr.wav", "Alert community ground Protection Units, local unrest structure detected: Assemble, Administer, Pacify."},
{"npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav", "Attention please, unidentified person of interest - confirm your civil status with local protection team immediantly."},
}

local announcementsACS = {
{"npc/overwatch/cityvoice/f_citizenshiprevoked_6_spkr.wav", "Individual, you are convicted of multi-anticivil violations. Implicite citizenship revoked - status: Malignant."},
{"npc/overwatch/cityvoice/f_capitalmalcompliance_spkr.wav", "Individual, you are charged with capital malcompliance - anti-citizen status approved."},
{"npc/overwatch/cityvoice/f_ceaseevasionlevelfive_spkr.wav", "Individual, you are now charged with social endangerment level 5 - seace evasion immediantly; recieve your verdict."},

}

local announcementsPassive = {
{"npc/overwatch/cityvoice/f_innactionisconspiracy_spkr.wav", "Citizen reminder: inaction is conspiracy, report counter-behaviour to a civil protection team immediantly."},
}

hook.Add("PlayerSay", "mayor_cmdssounds", function(ply,text)
	if ply:Team() ~= TEAM_MAYOR then return end
	local temp = string.Split(text, " ")
	if temp[1] ~= "/announce" then return end
	local typeAn = temp[2]
	if typeAn == "passive" then
		local random = table.Random(announcementsPassive)
		net.Start("mayor_sounds")
			net.WriteString(random[1])
			net.WriteString(random[2])
		net.Broadcast()
		return ""
	elseif typeAn == "anticivil" then
		local random = table.Random(announcementsAC)
		net.Start("mayor_sounds")
			net.WriteString(random[1])
			net.WriteString(random[2])
		net.Broadcast()
		return ""
	elseif typeAn == "serious" then
		local random = table.Random(announcementsACS)
		net.Start("mayor_sounds")
			net.WriteString(random[1])
			net.WriteString(random[2])
		net.Broadcast()
		return ""
	elseif typeAn == "citysweep" then
		ply:ConCommand("say /me grabs the pieces of paper, profusely signing his name at the bottom.")
		timer.Simple(3, function()
			net.Start("mayor_citysweep")
			net.Broadcast()
		end)
		ply:SetNWBool("citysweep_enabled", true)
		return ""
	elseif typeAn == "endcitysweep" then
		ply:ConCommand("say /me grabs the pieces of paper, signing the end of the city sweep")
		timer.Simple(3, function()
			net.Start("mayor_citysweepend")
			net.Broadcast()
		end)
		ply:SetNWBool("citysweep_enabled", false)
		return ""
	elseif typeAn == "event" then
		net.Start("mayor_bankannouncement")
		net.Broadcast()
		timer.Create("seriousAnnouncements", 25, 0, function()
			local ran1 = table.Random(announcementsPassive)
			local ran2 = table.Random(announcementsAC)
			local ran3 = table.Random(announcementsACS)
			local random = table.Random({ran1,ran2,ran3})
			net.Start("mayor_sounds")
				net.WriteString(random[1])
				net.WriteString(random[2])
			net.Broadcast()
		end)
		return ""
	elseif typeAn == "endevent" then
		net.Start("mayor_bankannouncementend")
		net.Broadcast()
		timer.Remove("seriousAnnouncements")
		return ""
	else
		ply:SendLua('notification.AddLegacy("Invalid announcement ID!", NOTIFY_ERROR, 5)')
		return ""
	end
end)

hook.Add("PlayerDisconnected", "endMayorSweep", function(ply)
	if ply:GetNWBool("citysweep_enabled") == true then
		net.Start("mayor_citysweepend")
		net.Broadcast()
	end
	if ply:Team() == TEAM_MAYOR and timer.Exists("seriousAnnouncements") then timer.Remove("seriousAnnouncements") end
end)

-- Prop money

hook.Add("PlayerSpawnedProp", "chargeforprop", function(ply)
	if ply:CheckGroup("vip") then
		ply:addMoney(-5)
		ply:SendLua('notification.AddLegacy("You have been charged $5!", NOTIFY_ERROR, 5)')
	else
		ply:addMoney(-10)
		ply:SendLua('notification.AddLegacy("You have been charged $10!", NOTIFY_ERROR, 5)')
	end
end)

-- Fists on spawn

hook.Add("PlayerSpawn", "fistsonspawn", function(ply)
	ply:Give("weapon_fists")
	ply:Give('weapon_arc_atmcard')
	if table.HasValue({TEAM_DELTAENFORCERIFLE, TEAM_DELTAENFORCERCQC,
		TEAM_DELTAENFORCETL, TEAM_REGIONALADVISOR, TEAM_CENTRALPOLICE, TEAM_CENTRALPOLICECHIEF, TEAM_MILITARYRIFLE, TEAM_MILITARYCQC,
		TEAM_MILITARYSNIPER, TEAM_MILITARYJUGGERNAUT, TEAM_ALPHAENFORCERS, TEAM_ALPHACQC, TEAM_ALPHALEADER, TEAM_ALPHAENFORCERSSNIP, 
		TEAM_ALPHAENFORCERSLEADER}, ply:Team()) then ply:Give("weapon_policeshield") end
end)

hook.Add("PlayerSpawn", "cloakonspawn", function(ply)
	if ply:Team() == TEAM_ADMIN then
		ply:ConCommand("say !cloak ^")
	end
end)

hook.Add("PlayerSay", "lawscommand", function(ply,text)
	local temp = string.Split(text, " ")
	if temp[1] ~= "!laws" then return end
	ply:SendLua('gui.OpenURL("http://werwolfgamingsite.enjin.com/forum/m/30155425/viewthread/26742321-official-citizen-laws-interest")')
	return ""
end)

-- LOOC

hook.Add("PlayerSay", "loocfunc", function(ply, text)
	local temp = string.Split(text, " ")
	if (temp[1] == "/looc") then
		local text = string.gsub(text, "/looc ", "")
		for k,v in pairs(player.GetAll()) do
			if v:GetPos():Distance(ply:GetPos()) < 550 then
				net.Start("looc_chatadd")
					net.WriteString(ply:Name())
					net.WriteString(text)
				net.Send(v)
			end
		end
		return ""
	elseif (temp[1] == ".//") then
		local text = string.gsub(text, ".// ", "")
		for k,v in pairs(player.GetAll()) do
			if v:GetPos():Distance(ply:GetPos()) < 550 then
				net.Start("looc_chatadd")
					net.WriteString(ply:Name())
					net.WriteString(text)
				net.Send(v)
			end
		end
		return ""
	end
end)

-- Stop handcuffing each other CPS OMFG

hook.Add("CuffsCanHandcuff", "cpstophandcuffs", function(ply,target)
	if target:isCP() then return false end
end)

-- BODY groups

hook.Add("PlayerSpawn", "setbosygroupss", function(ply)
	if ply:Team() == TEAM_MAYOR then
		ply:SetBodyGroups("5403")
	elseif ply:Team() == TEAM_HITMAN then
		ply:SetBodyGroups("2210")
	end
end)
