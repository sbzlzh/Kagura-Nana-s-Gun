AddCSLuaFile()
AddCSLuaFile( "effects/kaguranana_qinai_tracer.lua" )
AddCSLuaFile( "effects/kaguranana_qinai_bounce.lua" )

if SERVER then
	resource.AddWorkshop( "2711087564" )
end

if CLIENT then
    SWEP.PrintName = "Kagura Nana's Gun"
    SWEP.Slot = 6
	SWEP.SlotPos = 5

    -- client side model settings
    SWEP.UseHands = true -- should the hands be displayed
    SWEP.ViewModelFlip      = false -- should the weapon be hold with the left or the right hand
    SWEP.ViewModelFOV = 54
end

SWEP.Category = "sbzl's Weapons"

SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"

SWEP.AllowDrop = true
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.HoldType = "smg"

SWEP.Primary.ClipSize = 1
SWEP.Primary.Delay = 0.1
SWEP.Primary.Damage = 6
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "kaguranana_qinai"

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.Delay = 0.6
SWEP.Secondary.Damage = 8
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "kaguranana_qinai"

game.AddAmmoType( { name = "kaguranana_qinai" } )
if ( CLIENT ) then language.Add( "kaguranana_qinai_ammo", "Annoying Ammo" ) end

--------------------------------- TTT ----------------------------------

local gm = engine.ActiveGamemode()
if string.find(gm,"terrortown") then

    SWEP.EquipMenuData = {
	    type = "item_weapon",
	    desc = [[
	    Hold the left button: a straight ray
        Right-click: 4 dogma rays
        Hold R: shoot an explosive mom
	]]
}

    SWEP.Icon = "qinai/ttt_icon.png"

    SWEP.Kind   = WEAPON_EQUIP2
    SWEP.CanBuy = { ROLE_TRAITOR } --{ ROLE_TRAITOR } or { ROLE_DETECTIVE }
    SWEP.LimitedStock = true

    function SWEP:IsEquipment() return false end
end

------------------------------ TTT -------------------------------------

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 1, "NextIdle" )
end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()

	if ( self.Owner:IsNPC() ) then
		self:EmitSound( "weapons/nanai/nanai/nanai" .. math.random( 1, 2 ) .. ".wav", 100, math.random( 60, 80 ) )
	else
		if ( self.LoopSound ) then
			self.LoopSound:ChangeVolume( 1, 0.1 )
		else
			self.LoopSound = CreateSound( self.Owner, Sound( "weapons/nanai/nanai_loop.ogg" ) )
			if ( self.LoopSound ) then self.LoopSound:Play() end
		end
		if ( self.BeatSound ) then self.BeatSound:ChangeVolume( 0, 0.1 ) end
	end

	if ( IsFirstTimePredicted() ) then
	
		local bullet = {}
		bullet.Num = 1
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector( 0.01, 0.01, 0 )
		bullet.Tracer = 1
		bullet.Force = 5
		bullet.Damage = self.Primary.Damage
		//bullet.AmmoType = "Ar2AltFire" -- For some extremely stupid reason this breaks the tracer effect
		bullet.TracerName = "kaguranana_qinai_tracer"
		self.Owner:FireBullets( bullet )

		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	end

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

	self:Idle()
end

function SWEP:GetHeadshotMultiplier()
	return 1
end

function SWEP:SecondaryAttack()

	if ( IsFirstTimePredicted() ) then
		self:EmitSound( "weapons/nanai/nanai" .. math.random( 1, 2 ) .. ".wav", 100, math.random( 100, 100 ) )

		local bullet = {}
		bullet.Num = 6
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector( 0.10, 0.1, 0 )
		bullet.Tracer = 1
		bullet.Force = 10
		bullet.Damage = self.Secondary.Damage
		//bullet.AmmoType = "Ar2AltFire"
		bullet.TracerName = "kaguranana_qinai_tracer"
		self.Owner:FireBullets( bullet )

		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	end

	self:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	self:Idle()
end

function SWEP:Reload()
	if ( !self.Owner:KeyPressed( IN_RELOAD ) ) then return end
	if ( self:GetNextPrimaryFire() > CurTime() ) then return end

	if ( SERVER ) then
		local ang = self.Owner:EyeAngles()
		local ent = ents.Create( "ent_qinai_bomb" )
		if ( IsValid( ent ) ) then
			ent:SetPos( self.Owner:GetShootPos() + ang:Forward() * 28 + ang:Right() * 24 - ang:Up() * 8 )
			ent:SetAngles( ang )
			ent:SetOwner( self.Owner )
			ent:Spawn()
			ent:Activate()
			
			local phys = ent:GetPhysicsObject()
			if ( IsValid( phys ) ) then phys:Wake() phys:AddVelocity( ent:GetForward() * 1337 ) end
		end
	end
	
	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self:EmitSound( "weapons/nanai/nanai" .. math.random( 1, 2 ) .. ".wav", 100, math.random( 100, 100 ) )

	self:SetNextPrimaryFire( CurTime() + 1 )
	self:SetNextSecondaryFire( CurTime() + 1 )

	self:Idle()
end

function SWEP:DoImpactEffect( trace, damageType )
	local effectdata = EffectData()
	effectdata:SetStart( trace.HitPos )
	effectdata:SetOrigin( trace.HitNormal + Vector( math.Rand( -0.5, 0.5 ), math.Rand( -0.5, 0.5 ), math.Rand( -0.5, 0.5 ) ) )
	util.Effect( "kaguranana_qinai_bounce", effectdata )

	return true
end

function SWEP:FireAnimationEvent( pos, ang, event )
	return true
end

function SWEP:KillSounds()
	if ( self.BeatSound ) then self.BeatSound:Stop() self.BeatSound = nil end
	if ( self.LoopSound ) then self.LoopSound:Stop() self.LoopSound = nil end
	timer.Destroy( "kaguranana_idle" .. self:EntIndex() )
end

function SWEP:OnRemove()
	self:KillSounds()
end

function SWEP:OnDrop()
	self:KillSounds()
	self:Remove()
end

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )

	if ( CLIENT ) then return true end

	self:Idle()

	self.BeatSound = CreateSound( self.Owner, Sound( "weapons/nanai/nanai_beat.wav" ) )
	if ( self.BeatSound ) then self.BeatSound:Play() end

	return true
end

function SWEP:Holster()
	self:KillSounds()
	return true
end

function SWEP:Think()

	if ( self:GetNextIdle() > 0 && CurTime() > self:GetNextIdle() ) then

		self:DoIdleAnimation()
		self:Idle()

	end

	if ( self.Owner:IsPlayer() && ( self.Owner:KeyReleased( IN_ATTACK ) || !self.Owner:KeyDown( IN_ATTACK ) ) ) then
		if ( self.LoopSound ) then self.LoopSound:ChangeVolume( 0, 0.1 ) end
		if ( self.BeatSound ) then self.BeatSound:ChangeVolume( 1, 0.1 ) end
	end
end

function SWEP:DoIdleAnimation()
	self:SendWeaponAnim( ACT_VM_IDLE )
end

function SWEP:Idle()

	self:SetNextIdle( CurTime() + self:GetAnimationTime() )

end

function SWEP:GetAnimationTime()
	local time = self:SequenceDuration()
	if ( time == 0 && IsValid( self.Owner ) && !self.Owner:IsNPC() && IsValid( self.Owner:GetViewModel() ) ) then time = self.Owner:GetViewModel():SequenceDuration() end
	return time
end

if ( SERVER ) then return end

killicon.Add( "weapon_nanaigun", "qinai/killicon", color_white )

SWEP.WepSelectIcon = Material( "qinai/selection.png" )
	
function SWEP:DrawWeaponSelection( x, y, w, h, a )
	surface.SetDrawColor( 255, 255, 255, a )
	surface.SetMaterial( self.WepSelectIcon )

	local size = math.min( w, h )
	surface.DrawTexturedRect( x + w / 2 - size / 2, y, size, size )
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {} 
 
	self.AmmoDisplay.Draw = false

	return self.AmmoDisplay
end

local gm = engine.ActiveGamemode()
if string.find(gm,"terrortown") then
	SWEP.Base = "weapon_tttbase"
	DEFINE_BASECLASS("weapon_tttbase")
end

local gm = engine.ActiveGamemode()
if string.find(gm,"sandbox") then
	SWEP.Base = "weapon_base"
	DEFINE_BASECLASS("weapon_base")
end