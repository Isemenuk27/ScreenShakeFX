if CLIENT then
	local scrsk_enable_cl = CreateClientConVar("scrsk_enable_cl", "1", true, false)
	local scrsk_amplitude = CreateClientConVar("scrsk_amplitude", "3", true, false)
	local scrsk_frequency = CreateClientConVar("scrsk_frequency", "3", true, false)
	local scrsk_duration = CreateClientConVar("scrsk_duration", "2", true, false)

	local Enabled = scrsk_enable_cl:GetBool()
	local Amplitude = scrsk_amplitude:GetFloat()
	local Frequency = scrsk_frequency:GetFloat()
	local Duration = scrsk_duration:GetFloat()

	cvars.AddChangeCallback("scrsk_enable_cl", function(CVarName, OldVar, NewVar) Enabled = tobool(NewVar) end)
	cvars.AddChangeCallback("scrsk_amplitude", function(CVarName, OldVar, NewVar) Amplitude = tonumber(NewVar) end)
	cvars.AddChangeCallback("scrsk_frequency", function(CVarName, OldVar, NewVar) Frequency = tonumber(NewVar) end)
	cvars.AddChangeCallback("scrsk_duration", function(CVarName, OldVar, NewVar) Duration = tonumber(NewVar) end)

	net.Receive( "DoExplosionShake", function(len)
		if !Enabled then return end
		local dmg = net.ReadInt(14)
		util.ScreenShake( Vector(0, 0, 0), Amplitude * ( ply:GetMaxHealth() / dmg ), Frequency, Duration, 0 )
	end )
	
	hook.Add( "AddToolMenuCategories", "postprocessingMenuShake", function()
		spawnmenu.AddToolCategory( "Options", "postprocessing", "#spawnmenu.category.postprocess" )
	end )

	hook.Add( "PopulateToolMenu", "ScreenShakeMenu", function()
		spawnmenu.AddToolMenuOption( "Options", "postprocessing", "postprocessingMenuShake", "#Screen Shake", "", "", function( panel )
			panel:ClearControls()

			if LocalPlayer():IsAdmin() then
				panel:CheckBox( "Enable on all clients", "scrsk_enable" )
			end
			panel:CheckBox( "Enable", "scrsk_enable_cl" )
			panel:NumSlider( "Amplitude", "scrsk_amplitude", 0.1, 7 )
			panel:NumSlider( "Frequency", "scrsk_frequency", 0.01, 5 )
			panel:NumSlider( "Duration", "scrsk_duration", 0.5, 5 )
		end )
	end )
end

if SERVER then
	util.AddNetworkString( "DoExplosionShake" )

	local Enabled = CreateConVar("scrsk_enable", "1", { FCVAR_ARCHIVE }, "Enable screen shake after explosion" )

	hook.Add( "EntityTakeDamage", "ExplosionShakeHook", function( target, dmginfo )

		if !Enabled:GetBool() then return end
		if !target:IsPlayer() then return end
		if !dmginfo:IsDamageType(DMG_BLAST) then return end

		net.Start( "DoExplosionShake" )
			net.WriteInt( dmginfo:GetDamage(), 14 )
		net.Send(target)
	end)
end