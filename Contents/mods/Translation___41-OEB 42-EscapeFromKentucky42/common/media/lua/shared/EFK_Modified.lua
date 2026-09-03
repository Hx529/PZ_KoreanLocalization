local Verbose = false

local function adjustItem(Name, Property, Value)
  local success, err = pcall(function()
    local Item = ScriptManager.instance:getItem(Name)
    if not Item then
      if Verbose then
        error("Item not found: " .. Name)
      else
        return
      end
    end

      Item:DoParam(Property .. " = ".. Value)
  end)

  if not success then
    print("Error adjusting item: " .. Name .. ". Reason: " .. tostring(err))
  end
end

local function EFKMod()
    adjustItem("Gunpart.WB_SST", "Tooltip", "Tooltip_Grip_WB_SST")
    adjustItem("Gunpart.TshiftGrip", "Tooltip", "Tooltip_Grip_TshiftGrip")
    adjustItem("Gunpart.SE", "Tooltip", "Tooltip_Grip_SE")
    adjustItem("Gunpart.AFG_Blk", "Tooltip", "Tooltip_Grip_AFG_Blk")
    adjustItem("Gunpart.ASh", "Tooltip", "Tooltip_Grip_ASh")
    adjustItem("Gunpart.WB_xie", "Tooltip", "Tooltip_Grip_WB_xie")
    adjustItem("Gunpart.CobraGrip", "Tooltip", "Tooltip_Grip_CobraGrip")
    adjustItem("Gunpart.HeraCQR_Grip", "Tooltip", "Tooltip_Grip_HeraCQR_Grip")

    adjustItem("Gunpart.leupold", "Tooltip", "Tooltip_Scope_leupold")
    adjustItem("Gunpart.G33_cat", "Tooltip", "Tooltip_Scope_G33_cat")
    adjustItem("Gunpart.AmmoPD", "Tooltip", "Tooltip_Scope_AmmoPD")
    adjustItem("Gunpart.MZ_RMR", "Tooltip", "Tooltip_Scope_MZ_RMR")
    adjustItem("Gunpart.MZ_paoduijing", "Tooltip", "Tooltip_Scope_MZ_paoduijing")
    adjustItem("Gunpart.PEScope_cat", "Tooltip", "Tooltip_Scope_PEScope_cat")
    adjustItem("Gunpart.PSO_1_cat", "Tooltip", "Tooltip_Scope_PSO_1_cat")
    adjustItem("Gunpart.Unertl8X_cat", "Tooltip", "Tooltip_Scope_Unertl8X_cat")
    adjustItem("Gunpart.HAMR_cat", "Tooltip", "Tooltip_Scope_HAMR_cat")
    adjustItem("Gunpart.TA11_4X_Scope", "Tooltip", "Tooltip_Scope_TA11_4X_Scope")
    adjustItem("Gunpart.VortexSight", "Tooltip", "Tooltip_Scope_VortexSight")
    adjustItem("Gunpart.COMPM4", "Tooltip", "Tooltip_Scope_COMPM4")
    adjustItem("Gunpart.ATACR", "Tooltip", "Tooltip_Scope_ATACR")
    adjustItem("Gunpart.WaltherMRS_1", "Tooltip", "Tooltip_Scope_WaltherMRS_1")
    adjustItem("Gunpart.MZ_UH1", "Tooltip", "Tooltip_Scope_MZ_UH1")
    adjustItem("Gunpart.WaltherMRS_2", "Tooltip", "Tooltip_Scope_WaltherMRS_2")
    adjustItem("Gunpart.CQBR_ACOG_RU", "Tooltip", "Tooltip_Scope_CQBR_ACOG_RU")
    adjustItem("Gunpart.Carryhandle", "Tooltip", "Tooltip_Scope_Carryhandle")
    adjustItem("Gunpart.558holo", "Tooltip", "Tooltip_Scope_558holo")
    adjustItem("Gunpart.XM157_cat", "Tooltip", "Tooltip_Scope_XM157_cat")

    adjustItem("Gunpart.Harris_Open", "Tooltip", "Tooltip_Stool_Harris_Open")
    adjustItem("Gunpart.Harris_Open1", "Tooltip", "Tooltip_Stool_Harris_Open1")

    adjustItem("Gunpart.Clip_LWMMG_cat", "Tooltip", "Tooltip_Clip_LWMMG_cat")
    adjustItem("Gunpart.Clip_M91_cat", "Tooltip", "Tooltip_Clip_M91_cat")
    adjustItem("Gunpart.Clip_mk47_cat", "Tooltip", "Tooltip_Clip_mk47_cat")
    adjustItem("Gunpart.Clip_9mmDrum_cat", "Tooltip", "Tooltip_Clip_9mmDrum_cat")
    adjustItem("Gunpart.Clip_QLU_11", "Tooltip", "Tooltip_Clip_QLU_11")
    adjustItem("Gunpart.Clip_Saiga12_cat", "Tooltip", "Tooltip_Clip_Saiga12_cat")
    adjustItem("Gunpart.Clip_origin12_cat", "Tooltip", "Tooltip_Clip_origin12_cat")
    adjustItem("Gunpart.Clip_MDR_cat", "Tooltip", "Tooltip_Clip_MDR_cat")
    adjustItem("Gunpart.Clip_QLU_11_cat", "Tooltip", "Tooltip_Clip_QLU_11_cat")
    adjustItem("Gunpart.Clip_AA12_cat", "Tooltip", "Tooltip_Clip_AA12_cat")
    adjustItem("Gunpart.Clip_GM6_cat", "Tooltip", "Tooltip_Clip_GM6_cat")
    adjustItem("Gunpart.Clip_AWM_cat", "Tooltip", "Tooltip_Clip_AWM_cat")
    adjustItem("Gunpart.Clip_M200_cat", "Tooltip", "Tooltip_Clip_M200_cat")
    adjustItem("Gunpart.Clip_Factor_cat", "Tooltip", "Tooltip_Clip_Factor_cat")
    adjustItem("Gunpart.Clip_FactorMax_cat", "Tooltip", "Tooltip_Clip_FactorMax_cat")
    adjustItem("Gunpart.Clip_MP7_cat", "Tooltip", "Tooltip_Clip_MP7_cat")
    adjustItem("Gunpart.Clip_556Drum_cat", "Tooltip", "Tooltip_Clip_556Drum_cat")
    adjustItem("Gunpart.Clip_M14Drum_cat", "Tooltip", "Tooltip_Clip_M14Drum_cat")
    adjustItem("Gunpart.Clip_762Drum_cat", "Tooltip", "Tooltip_Clip_762Drum_cat")
    adjustItem("Gunpart.Clip_AK103_cat", "Tooltip", "Tooltip_Clip_AK103_cat")
    adjustItem("Gunpart.Clip_ar_10_cat", "Tooltip", "Tooltip_Clip_ar_10_cat")
    adjustItem("Gunpart.Clip_AX50_cat", "Tooltip", "Tooltip_Clip_AX50_cat")
    adjustItem("Gunpart.Clip_Beowulf_cat", "Tooltip", "Tooltip_Clip_Beowulf_cat")
    adjustItem("Gunpart.Clip_AssaultRifle", "Tooltip", "Tooltip_Clip_AssaultRifle")
    adjustItem("Gunpart.Clip_COLT902_60cat", "Tooltip", "Tooltip_Clip_COLT902_60cat")
    adjustItem("Gunpart.Clip_COLT902_100cat", "Tooltip", "Tooltip_Clip_COLT902_100cat")
    adjustItem("Gunpart.Clip_KrissVector_cat", "Tooltip", "Tooltip_Clip_KrissVector_cat")
    adjustItem("Gunpart.Clip_M82_cat", "Tooltip", "Tooltip_Clip_M82_cat")
    adjustItem("Gunpart.Clip_HuntingRifle", "Tooltip", "Tooltip_Clip_HuntingRifle")
    adjustItem("Gunpart.Clip_QBZ191_cat", "Tooltip", "Tooltip_Clip_QBZ191_cat")
    adjustItem("Gunpart.Clip_R301_cat", "Tooltip", "Tooltip_Clip_R301_cat")
    adjustItem("Gunpart.Clip_ScarH_cat", "Tooltip", "Tooltip_Clip_ScarH_cat")
    adjustItem("Gunpart.Clip_MK12_cat", "Tooltip", "Tooltip_Clip_MK12_cat")
    adjustItem("Gunpart.Clip_HK416_cat", "Tooltip", "Tooltip_Clip_HK416_cat")

    adjustItem("Gunpart.ArmytekPredator_Bottom", "Tooltip", "Tooltip_ArmytekPredator_Bottom")
    adjustItem("Gunpart.ArmytekPredator_Bottom2", "Tooltip", "Tooltip_ArmytekPredator_Bottom2")

    adjustItem("Gunpart.QG_TAB", "Tooltip", "Tooltip_QG_TAB")
    adjustItem("Gunpart.QG_CSB", "Tooltip", "Tooltip_QG_CSB")
    adjustItem("Gunpart.QG_CFWSB", "Tooltip", "Tooltip_QG_CFWSB")
    adjustItem("Gunpart.QG_ATSB", "Tooltip", "Tooltip_QG_ATSB")
    adjustItem("Gunpart.QG_TTAB", "Tooltip", "Tooltip_QG_TTAB")
    adjustItem("Gunpart.QG_CCB", "Tooltip", "Tooltip_QG_CCB")

    adjustItem("Gunpart.QT_lugerP80", "Tooltip", "Tooltip_Stock_QT_lugerP80")
    adjustItem("Gunpart.QT_F93", "Tooltip", "Tooltip_Stock_QT_F93")
    adjustItem("Gunpart.Mk18Stock", "Tooltip", "Tooltip_Stock_Mk18Stock")
    adjustItem("Gunpart.QT_LDT416", "Tooltip", "Tooltip_Stock_QT_LDT416")
    adjustItem("Gunpart.QT_Gen3", "Tooltip", "Tooltip_Stock_QT_Gen3")
    adjustItem("Gunpart.VltorEmod_Blk_Stock", "Tooltip", "Tooltip_Stock_VltorEmod_Blk_Stock")
    adjustItem("Gunpart.AK12Stock", "Tooltip", "Tooltip_Stock_AK12Stock")
    adjustItem("Gunpart.CombatOps_Stock_blk", "Tooltip", "Tooltip_Stock_CombatOps_Stock_blk")
    adjustItem("Gunpart.HeraCQR_Stock", "Tooltip", "Tooltip_Stock_HeraCQR_Stock")
    adjustItem("Gunpart.TroyM7_Blk", "Tooltip", "Tooltip_Stock_TroyM7_Blk")
    adjustItem("Gunpart.ViperStock", "Tooltip", "Tooltip_Stock_ViperStock")
    adjustItem("Gunpart.MagpulStock", "Tooltip", "Tooltip_Stock_MagpulStock")
    adjustItem("Gunpart.ar15Stock", "Tooltip", "Tooltip_Stock_ar15Stock")

    adjustItem("Gunpart.Sling_cat", "Tooltip", "Tooltip_Sling_cat")
    adjustItem("Gunpart.AmmoStraps_cat", "Tooltip", "Tooltip_AmmoStraps_cat")
    adjustItem("Gunpart.Recoilpad_cat", "Tooltip", "Tooltip_Recoilpad_cat")

    adjustItem("Gunpart.XY_Beowulf", "Tooltip", "Tooltip_Canon_XY_Beowulf")
    adjustItem("Gunpart.XY_XDZT", "Tooltip", "Tooltip_Canon_XY_XDZT")
    adjustItem("Gunpart.XY_1911", "Tooltip", "Tooltip_Canon_XY_1911")
    adjustItem("Gunpart.XY_CARVER", "Tooltip", "Tooltip_Canon_XY_CARVER")
    adjustItem("Gunpart.XY_109", "Tooltip", "Tooltip_Canon_XY_109")
    adjustItem("Gunpart.XY_MK18", "Tooltip", "Tooltip_Canon_XY_MK18")
    adjustItem("Gunpart.XY_4guan", "Tooltip", "Tooltip_Canon_XY_4guan")
    adjustItem("Gunpart.AACMini7_Silencer", "Tooltip", "Tooltip_Canon_AACMini7_Silencer")
    adjustItem("Gunpart.XY_fang1_Silencer", "Tooltip", "Tooltip_Canon_XY_fang1_Silencer")
    adjustItem("Gunpart.XY_baoguo", "Tooltip", "Tooltip_Canon_XY_baoguo")
    adjustItem("Gunpart.XY_kac", "Tooltip", "Tooltip_Canon_XY_kac")
    adjustItem("Gunpart.XY_fang", "Tooltip", "Tooltip_Canon_XY_fang")
    adjustItem("Gunpart.XY_M4MK18", "Tooltip", "Tooltip_Canon_XY_M4MK18")
    adjustItem("Gunpart.XY_pomen", "Tooltip", "Tooltip_Canon_XY_pomen")
    adjustItem("Gunpart.XY_yazhui", "Tooltip", "Tooltip_Canon_XY_yazhui")
    adjustItem("Gunpart.VP09", "Tooltip", "Tooltip_Canon_VP09")
    adjustItem("Gunpart.M82_cat_muzzle", "Tooltip", "Tooltip_Canon_M82_cat_muzzle")
    adjustItem("Gunpart.FortisNitride_RED2", "Tooltip", "Tooltip_Canon_FortisNitride_RED2")
    adjustItem("Gunpart.kriss_muzzle_d_Silencer", "Tooltip", "Tooltip_Canon_kriss_muzzle_d_Silencer")
    adjustItem("Gunpart.M82_cat_Silencer", "Tooltip", "Tooltip_Canon_M82_cat_Silencer")
    adjustItem("Gunpart.SMSUP_cat", "Tooltip", "Tooltip_Canon_SMSUP_cat")
    adjustItem("Gunpart.AR15_slience", "Tooltip", "Tooltip_Canon_AR15_slience")

    adjustItem("Gunpart.DBAL_9021_Bottom", "Tooltip", "Tooltip_Light_DBAL_9021_Bottom")
    adjustItem("Gunpart.DBAL77Laser_cat", "Tooltip", "Tooltip_Light_DBAL77Laser_cat")
    adjustItem("Gunpart.PEQ_cat", "Tooltip", "Tooltip_Light_PEQ_cat")

    adjustItem("Gunpart.AmmoBag", "Tooltip", "Tooltip_AmmoBag")

    adjustItem("Gunpart.ArmorShieldHand", "Tooltip", "Tooltip_Shield_ArmorShieldHand")
    adjustItem("Gunpart.ArmorShieldHand_cat", "Tooltip", "Tooltip_Shield_ArmorShieldHand_cat")
    adjustItem("Gunpart.ArmorShieldBody", "Tooltip", "Tooltip_Shield_ArmorShieldBody")

    adjustItem("Base.AirDropMarker", "Tooltip", "Tooltip_AirDropMarker")
    adjustItem("Base.AirDrop", "Tooltip", "Tooltip_AirDrop")
end

local function InitSettings()
  if getActivatedMods():contains("\\EscapeFromKentucky42") then
    EFKMod()
  end
end

Events.OnGameStart.Add(InitSettings)
