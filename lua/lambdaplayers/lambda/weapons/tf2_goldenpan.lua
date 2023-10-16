table.Merge( _LAMBDAPLAYERSWEAPONS, {
    tf2_goldenfryingpan = {
        model = "models/lambdaplayers/tf2/weapons/w_frying_pan.mdl",
        origin = "Team Fortress 2",
        prettyname = "Golden Frying Pan",
        holdtype = "melee",
        bonemerge = true,

        killicon = "lambdaplayers/killicons/icon_tf2_frying_pan",
        keepdistance = 10,
        attackrange = 45,        
		islethal = true,
        ismelee = true,
        deploydelay = 0.5,

        OnDeploy = function( self, wepent )
            LAMBDA_TF2:InitializeWeaponData( self, wepent )

            wepent:SetWeaponAttribute( "IsMelee", true )
            wepent:SetWeaponAttribute( "DamageType", DMG_SLASH )
            wepent:SetWeaponAttribute( "HitSound", ")weapons/pan/melee_frying_pan_04.wav")
            wepent:SetWeaponAttribute( "Sound", ")weapons/machete_swing.wav" )
            wepent:SetWeaponAttribute( "CritSound", ")weapons/machete_swing_crit.wav" )
            wepent:SetWeaponAttribute( "DamageCustom", TF_DMG_CUSTOM_TURNGOLD )

            wepent:SetSkin( 3 )
            wepent:EmitSound( "weapons/draw_melee.wav", nil, nil, 0.5 )
        end,
        
		OnAttack = function( self, wepent, target )
            LAMBDA_TF2:WeaponAttack( self, wepent, target )
            return true 
        end
    }
} )