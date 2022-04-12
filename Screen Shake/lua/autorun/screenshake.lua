if CLIENT then
CreateClientConVar("scrsk_enable_cl", "1", true, false)
CreateClientConVar("scrsk_amplitude", "1", true, false)
CreateClientConVar("scrsk_frequency", "3", true, false)
CreateClientConVar("scrsk_duration", "1", true, false)

/*
CreateClientConVar("scrsk_enable_pp", "1", true, false)
CreateClientConVar("scrsk_amplitude_pp", "5", true, false)
CreateClientConVar("scrsk_frequency_pp", "3", true, false)

local EnabledPP = false
local NextShake = CurTime()

cvars.AddChangeCallback("scrsk_enable_pp", function(convar_name, value_old, value_new) EnabledPP = tobool(value_new) end)
*/

net.Receive( "DoExplosionShake", function(len)
	if (!GetConVar("scrsk_enable_cl"):GetBool() || EnabledPP) then return end
	local dmg = net.ReadInt(14)
	local ply = net.ReadEntity()
	if !IsValid( ply ) then return end
	if LocalPlayer() != ply then return end

	util.ScreenShake( Vector(0, 0, 0), GetConVar("scrsk_amplitude"):GetFloat() * ( dmg / ply:GetMaxHealth() ), GetConVar("scrsk_frequency"):GetFloat(), GetConVar("scrsk_duration"):GetFloat(), 0 )
end )
/*
hook.Add( "Think", "ScreenShakeHook", function()
	if !EnabledPP then return end
	if ( NextShake > CurTime() && NextShake == 0 ) then return end

	util.ScreenShake( Vector(0, 0, 0), GetConVar("scrsk_amplitude_pp"):GetFloat(), GetConVar("scrsk_frequency_pp"):GetFloat(), 2, 0 )
	NextShake = CurTime() + 2
end )
*/
end

if SERVER then

	util.AddNetworkString( "DoExplosionShake" )

	CreateConVar("scrsk_enable", "1", { FCVAR_ARCHIVE }, "Enable screen shake after explosion" )

	hook.Add( "EntityTakeDamage", "ExplosionShakeHook", function( target, dmginfo )

		if !GetConVar("scrsk_enable"):GetBool() then return end
		if !target:IsPlayer() then return end
		if !dmginfo:IsDamageType(DMG_BLAST) then return end

		net.Start( "DoExplosionShake" )
			net.WriteInt( dmginfo:GetDamage(), 14 )
			net.WriteEntity( target )
		net.Broadcast()
	end)
end

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
/*
list.Set( "PostProcess", "#Screen Shake", {

	icon = "gui/postprocess/accummotionblur.png",
	convar = "scrsk_enable_pp",
	category = "#effects_pp",

	cpanel = function( CPanel )

		//CPanel:AddControl( "Header", { Description = "#motion_blur_pp.desc" } )

		CPanel:AddControl( "CheckBox", { Label = "Enable", Command = "scrsk_enable_pp" } )

		local params = { Options = {}, CVars = {}, MenuButton = "1", Folder = "screenshake" }
		params.Options[ "#preset.default" ] = { scrsk_enable_pp = "0", scrsk_amplitude_pp = "5", scrsk_frequency_pp = "3" }
		params.CVars = table.GetKeys( params.Options[ "#preset.default" ] )
		CPanel:AddControl( "ComboBox", params )

		CPanel:AddControl( "Slider", { Label = "Amplitude", Command = "scrsk_amplitude_pp", Type = "Float", Min = "0", Max = "10" } )
		CPanel:AddControl( "Slider", { Label = "Frequency", Command = "scrsk_frequency_pp", Type = "Float", Min = "0", Max = "10" } )

		//CPanel:AddControl( "Slider", { Label = "#motion_blur_pp.delay", Command = "", Type = "Float", Min = "0", Max = "1" } )

	end

} )
*/