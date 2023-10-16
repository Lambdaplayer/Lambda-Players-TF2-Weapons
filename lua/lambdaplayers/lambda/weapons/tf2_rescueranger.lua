local random = math.random
local Rand = math.Rand
local CurTime = CurTime
local IsValid = IsValid
local DamageInfo = DamageInfo
local ParticleEffect = ParticleEffect
local ParticleEffectAttach = ParticleEffectAttach
local ents_Create = ents.Create
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local IsFirstTimePredicted = IsFirstTimePredicted
local EffectData = EffectData
local util_Effect = util.Effect


local function OnProjTouch( self, ent )
    if !ent or !ent:IsSolid() or ent:GetSolidFlags() == FSOLID_VOLUME_CONTENTS then return end

    local touchTr = self:GetTouchTrace()
    if touchTr.HitSky then self:Remove() return end
    
    local dmgType = ( DMG_BULLET + DMG_PREVENT_PHYSICS_FORCE )
    local owner = self:GetOwner()
    if IsValid( owner ) then 
        if ent == owner then return end

        local dmginfo = DamageInfo()
        dmginfo:SetDamage( self.l_Damage )
        dmginfo:SetAttacker( owner )
        dmginfo:SetInflictor( self )
        dmginfo:SetDamagePosition( self:GetPos() )
        dmginfo:SetDamageForce( self:GetVelocity() * self.l_Damage )
        dmginfo:SetDamageType( dmgType )
   
        dmginfo:SetDamageCustom( TF_DMG_CUSTOM_USEDISTANCEMOD + TF_DMG_CUSTOM_NOCLOSEDISTANCEMOD )
        LAMBDA_TF2:SetCritType( dmginfo, self.l_CritType )

        ent:DispatchTraceAttack( dmginfo, touchTr, self:GetForward() )

        ent:EmitSound( "weapons/fx/rics/arrow_impact_flesh" .. random( 2, 4 ) .. ".wav", nil, nil, 0.7 )
    end
    
    self.l_Stopped = true
    self:AddSolidFlags( FSOLID_NOT_SOLID )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetLocalVelocity( vector_origin )
    self:SetPos( touchTr.HitPos )

    if IsFirstTimePredicted() then
        local effectData = EffectData()
        effectData:SetOrigin( touchTr.HitPos )
        effectData:SetStart( touchTr.StartPos )
        effectData:SetSurfaceProp( touchTr.SurfaceProps )
        effectData:SetHitBox( touchTr.HitBox )
        effectData:SetDamageType( dmgType )
        effectData:SetEntity( touchTr.Entity )
        util_Effect( "Impact", effectData )
    end

    if touchTr.HitWorld then
        SafeRemoveEntityDelayed( self, 10 )

        self:EmitSound( ")weapons/fx/rics/arrow_impact_concrete.wav", nil, nil, nil, CHAN_STATIC )
    else
        self:Remove()
    end
end

local function OnProjThink( self )
    if !self.l_Stopped then self:SetAngles( self:GetVelocity():Angle() ) end
    self:NextThink( CurTime() + 0.1 )
    return true
end

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    tf2_rescueranger = {
        model = "models/lambdaplayers/tf2/weapons/w_rescue_ranger.mdl",
        origin = "Team Fortress 2",
        prettyname = "Rescue Ranger",
        holdtype = "shotgun",
        bonemerge = true,
        killicon = "lambdaplayers/killicons/icon_tf2_rescue_ranger",
        
        clip = 6,
        islethal = true,
        attackrange = 800,
        keepdistance = 500,
        deploydelay = 0.5,

        OnDeploy = function( self, wepent )
            LAMBDA_TF2:InitializeWeaponData( self, wepent )

            wepent:SetWeaponAttribute( "FireBullet", false )
            wepent:SetWeaponAttribute( "Damage", 40 )
            wepent:SetWeaponAttribute( "RateOfFire", { 0.625, 0.7 } )
            wepent:SetWeaponAttribute( "Animation", ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN )
            wepent:SetWeaponAttribute( "Sound", ")weapons/rescue_ranger_fire.wav" )
            wepent:SetWeaponAttribute( "CritSound", ")weapons/rescue_ranger_fire_crit.wav" )
            --wepent:SetWeaponAttribute( "Spread", 0.0675 )
            wepent:SetWeaponAttribute( "FirstShotAccurate", false )

            wepent:SetSkin( self.l_TF_TeamColor )
            wepent:SetWeaponAttribute( "MuzzleFlash", "muzzle_shotgun" )
            wepent:SetWeaponAttribute( "ShellEject", false )

            wepent:EmitSound( random( 1, 4 ) != 1 and "weapons/draw_secondary.wav" or "weapons/draw_shotgun_pyro.wav", nil, nil, 0.5 )
        end,

        OnAttack = function( self, wepent, target )
            local spawnPos = wepent:GetAttachment( wepent:LookupAttachment( "muzzle" ) ).Pos
            local targetPos = target:WorldSpaceCenter()
            local dist = spawnPos:Distance( targetPos )
            targetPos = LAMBDA_TF2:CalculateEntityMovePosition( target, dist, 1000, Rand( 0.5, 1.1 ), targetPos )

            local spawnAng = ( targetPos - spawnPos ):Angle()
            spawnAng.y = ( spawnAng.y + Rand( -1.5, 1.5 ) )
            if self:GetForward():Dot( spawnAng:Forward() ) <= 0.5 then self.l_WeaponUseCooldown = ( CurTime() + 0.1 ) return true end

            local isCrit = wepent:CalcIsAttackCriticalHelper()
            if !LAMBDA_TF2:WeaponAttack( self, wepent, target, isCrit ) then return true end

            local proj = ents_Create( "base_anim" )
            proj:SetPos( spawnPos )
            proj:SetAngles( spawnAng )
            proj:SetModel( "models/weapons/w_models/w_repair_claw.mdl" )
            proj:SetOwner( self )
            proj:Spawn()

            proj:SetSolid( SOLID_BBOX )
            proj:SetMoveType( MOVETYPE_FLYGRAVITY )
            proj:SetMoveCollide( MOVECOLLIDE_FLY_CUSTOM )
            proj:SetGravity( 0.3 )
            
            local trail = LAMBDA_TF2:CreateSpriteTrailEntity( nil, nil, 5.4, 0, 2.3, "effects/repair_claw_trail_" .. ( self.l_TF_TeamColor == 1 and "blue" or "red" ), proj:WorldSpaceCenter(), proj )
            proj:SetSkin( self.l_TF_TeamColor )

            local launchVel = ( spawnAng:Forward() * 2000 )
            proj:SetLocalVelocity( launchVel )

            local critType = self:GetCritBoostType()
            if isCrit then critType = TF_CRIT_FULL end

            if critType == TF_CRIT_FULL then
                ParticleEffectAttach( "critical_rocket_" .. ( self.l_TF_TeamColor == 1 and "blue" or "red" ), PATTACH_ABSORIGIN_FOLLOW, proj, 0 )
            end

            proj.l_IsTFWeapon = true
            proj.l_CritType = critType
            proj.l_Stopped = false
            proj.l_Damage = wepent:GetWeaponAttribute( "Damage" )
            
            proj.IsLambdaWeapon = true
            proj.l_killiconname = wepent.l_killiconname

            proj.Touch = OnProjTouch
            proj.Think = OnProjThink

            if LAMBDA_TF2:WeaponAttack( self, wepent, target ) then
                self:SimpleWeaponTimer( 0.266, function()
                    wepent:EmitSound( "weapons/shotgun_cock_back.wav", 70, nil, nil, CHAN_STATIC )
                end )
                self:SimpleWeaponTimer( 0.416, function()
                    wepent:EmitSound( "weapons/shotgun_cock_forward.wav", 70, nil, nil, CHAN_STATIC )
                    LAMBDA_TF2:CreateShellEject( wepent, "ShotgunShellEject" )
                end )
            end

            return true
        end,

        OnReload = function( self, wepent )
            LAMBDA_TF2:ShotgunReload( self, wepent )
            return true
        end
    }
} )