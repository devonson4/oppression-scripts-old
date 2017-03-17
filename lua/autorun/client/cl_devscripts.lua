--------------------
// Made by Dev for Werwolf //
--------------------

--------------------
// Main //
--------------------

net.Receive("radio_addtext", function()
	local text = net.ReadString()
	local plyname = net.ReadString()

	chat.AddText(Color(75,78,84), "(", Color(43,105,204), "Radio", Color(75,78,84), ") ", Color(255,255,255), plyname .. ":", Color(255,255,255), text )
end)

net.Receive("urgency_addtext", function()
	local plyname = net.ReadString()

	chat.AddText(Color(75,78,84), "(", Color(161,26,26), "Urgency", Color(75,78,84), ") ", Color(255,255,255), plyname , Color(255,255,255), " has activated their panic alarm!" )
	surface.PlaySound("HL1/fvox/beep.wav")

end)

net.Receive("request_add", function()
	local plyname = net.ReadString()
	local text = net.ReadString()

	chat.AddText(Color(75,78,84), "(", Color(9,105,24), "Request", Color(75,78,84), ") ", Color(255,255,255), plyname .. ":" , Color(255,255,255), text)
	surface.PlaySound("HL1/fvox/bell.wav")
end)

net.Receive("mayor_sounds", function()
	local sound = net.ReadString()
	local text = net.ReadString()

	surface.PlaySound(sound)
	chat.AddText(Color(75,78,84), "(", Color(138,26,11), text, Color(75,78,84), ")")
end)

net.Receive("mayor_citysweep", function()
	local sound = "npc/overwatch/cityvoice/f_protectionresponse_4_spkr.wav"
	local text = "Attention all ground protection teams, autonomous judgement is now in place - sentencing is now discretionary. Code: Amputate, 0, Confirm."

	surface.PlaySound(sound)
	chat.AddText(Color(75,78,84), "(", Color(138,26,11), text, Color(75,78,84), ")")
	timer.Simple(15, function()
		chat.AddText(Color(75,78,84), "***", Color(15,96,150), "A city sweep has begun! Policing teams may search your residence!", Color(75,78,84), "***")
		surface.PlaySound("music/HL2_song8.mp3")
	end)

	timer.Create("citySweepSounds", 60, 0, function()
		RunConsoleCommand('stopsound')
		chat.AddText(Color(75,78,84), "***", Color(15,96,150), "A city sweep is in place! Policing teams may search your residence!", Color(75,78,84), "***")
		timer.Simple(2, function() surface.PlaySound("music/HL2_song8.mp3") end)
	end)
end)

net.Receive("mayor_citysweepend", function()
	timer.Remove("citySweepSounds")
	chat.AddText(Color(75,78,84), "***", Color(15,96,150), "The Ambassador has signed the ending of the city sweep! Policing teams now need a reason to search households!", Color(75,78,84), "***")
	RunConsoleCommand("stopsound")
end)

net.Receive("looc_chatadd", function()
	local plyName = net.ReadString()
	local text = net.ReadString()
	chat.AddText(Color(176,25,25), "(LOOC) ", Color(255,255,255), plyName .. ": ", Color(255,255,255), text)
end)

net.Receive("mayor_bankannouncement", function()
	local sound = "npc/overwatch/cityvoice/f_protectionresponse_5_spkr.wav"
	local text = "Attention all ground protection teams, judgement waver now in place - capital prosecution is discretionary."

	chat.AddText(Color(75,78,84), "(", Color(138,26,11), text, Color(75,78,84), ")")
	surface.PlaySound(sound)

	timer.Simple(10, function()
		chat.AddText(Color(75,78,84), "***", Color(15,96,150), "Serious anticivil actions have taken place in your community! Hide or comply with protection teams!", Color(75,78,84), "***")
		surface.PlaySound("music/HL2_song16.mp3")
	end)
end)

net.Receive("mayor_bankannouncementend", function()
	RunConsoleCommand("stopsound")
end)