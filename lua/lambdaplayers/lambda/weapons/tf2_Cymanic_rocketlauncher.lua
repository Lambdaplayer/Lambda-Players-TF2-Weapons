local random = math.random
local Rand = math.Rand
local CurTime = CurTime

local rocketAttributes = {
    Speed = 645,
}

local reloadData = {
    StartDelay = 0.09,
    CycleSound = "weapons/rocket_reload.wav",
    CycleDelay = 0.09,
    LayerCycle = 0.09,
    LayerPlayRate = 1.20,
    EndFunction = false
}

table.Merge( _LAMBDAPLAYERSWEAPONS, { 
     tf2_mvm_cymanic_rocket_launcher = {
        model = "models/lambdaplayers/tf2/weapons/w_rocket_launcher.mdl",
        origin = "Team Fortress 2",
        prettyname = "Machine Attacks: Cymanic Rocket",
        holdtype = "rpg",
        bonemerge = true,
        killicon = "lambdaplayers/killicons/icon_tf2_rocketlauncher",

        clip = 400,
        islethal = true,
        attackrange = 3000,
        keepdistance = 850,
        deploydelay = 0.5,

        OnDeploy = function( self, wepent )
            LAMBDA_TF2:InitializeWeaponData( self, wepent )
           
            wepent:SetWeaponAttribute( "FireBullet", false )
            wepent:SetWeaponAttribute( "Damage", 35 )
            wepent:SetWeaponAttribute( "RateOfFire", { 0.1, 0.1 } )
            wepent:SetWeaponAttribute( "Animation", ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW )
            wepent:SetWeaponAttribute( "Sound", "mvm/giant_soldier/giant_soldier_rocket_shoot.wav" )
            wepent:SetWeaponAttribute( "CritSound", "mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav" )
            wepent:SetWeaponAttribute( "MuzzleFlash", 7 )
            wepent:SetWeaponAttribute( "ShellEject", false )

            wepent:EmitSound( "weapons/draw_primary.wav", nil, nil, 0.5 )
        end,

        OnAttack = function( self, wepent, target )
            local spawnPos = wepent:GetAttachment( wepent:LookupAttachment( "muzzle" ) ).Pos
            local targetPos = ( ( !target:IsOnGround() or random( 1, 2 ) == 1 and self:IsInRange( target, 500 ) ) and target:WorldSpaceCenter() or target:GetPos() )
            targetPos = LAMBDA_TF2:CalculateEntityMovePosition( target, spawnPos:Distance( targetPos ), 1100, Rand( 0.5, 1.1 ), targetPos )

            local spawnAng = ( ( targetPos + ( ( target:IsNextBot() and target.loco or target ):GetVelocity() * ( ( self:GetRangeTo( targetPos ) * Rand( 0.66, 1.1 ) ) / 1100 ) ) ) - spawnPos ):Angle()
            spawnAng = ( ( targetPos + spawnAng:Right() * random( -5, 5 ) + spawnAng:Up() * random( -5, 5 ) ) - spawnPos ):Angle()
            if self:GetForward():Dot( spawnAng:Forward() ) <= 0.5 then self.l_WeaponUseCooldown = ( CurTime() + 0.1 ) return true end

            local isCrit = wepent:CalcIsAttackCriticalHelper()
            if !LAMBDA_TF2:WeaponAttack( self, wepent, target, isCrit ) then return true end
            
            LAMBDA_TF2:CreateRocketProjectile( spawnPos, spawnAng, self, wepent, isCrit, rocketAttributes )
            return true
        end,

        OnReload = function( self, wepent )
            LAMBDA_TF2:ShotgunReload( self, wepent, reloadData )
            return true
        end
    }
} )