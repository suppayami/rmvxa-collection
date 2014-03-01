#==============================================================================
# 
# Å• Yami Engine Symphony - Add-on: Enemy Character Set
# -- Last Updated: 2012.10.20
# -- Level: Nothing
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["BattleSymphony-EnemyCharset"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.10.20 - Finished Script.
# 2012.07.01 - Started Script.
#
#==============================================================================
# Å• Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# Remember to put this script under Battle Symphony.
# 
#==============================================================================

#==============================================================================
# Å° Regular Expression
#==============================================================================

module REGEXP
  module SYMPHONY

    CHARSET = /<(?:BATTLER_SET|battler set):[ ]*(.*)>/i
    WEAPON1 = /<(?:WEAPON_1|weapon 1):[ ]*(\d+)>/i
    WEAPON2 = /<(?:WEAPON_2|weapon 2):[ ]*(\d+)>/i
    SHIELD = /<(?:SHIELD):[ ]*(\d+)>/i
    
  end
end

#==============================================================================
# Å° DataManager
#==============================================================================

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_bes_ec load_database; end
  def self.load_database
    load_database_bes_ec
    load_notetags_bes_ec
  end
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_bes_ec
  #--------------------------------------------------------------------------
  def self.load_notetags_bes_ec
    groups = [$data_enemies]
    groups.each { |group|
      group.each { |obj|
        next if obj.nil?
        obj.battle_symphony_enemy_charset
      }
    }
  end
  
end # DataManager

#==============================================================================
# Å° RPG::BaseItem
#==============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :character_name 
  attr_accessor :character_index
  attr_accessor :eweapon_1
  attr_accessor :eweapon_2
  attr_accessor :eshield
  
  #--------------------------------------------------------------------------
  # new method: battle_symphony_enemy_charset
  #--------------------------------------------------------------------------
  def battle_symphony_enemy_charset
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::SYMPHONY::CHARSET
        str_scan = $1.scan(/[^,]+/i)
        @character_name = str_scan[0]
        @character_index = str_scan[1].to_i
      when REGEXP::SYMPHONY::WEAPON1
        @eweapon_1 = $1.to_i
      when REGEXP::SYMPHONY::WEAPON2
        @eweapon_2 = $1.to_i
      when REGEXP::SYMPHONY::SHIELD
        @eshield = $1.to_i
      end
    }
  end
  
end # RPG::BaseItem

#==============================================================================
# Å° Game_Enemy
#==============================================================================

class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :character_name
  attr_reader   :character_index

  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias bes_ec_initialize initialize
  def initialize(index, enemy_id)
    bes_ec_initialize(index, enemy_id)
    @character_name = enemy.character_name
    @character_index = enemy.character_index
  end
  
  #--------------------------------------------------------------------------
  # alias method: use_charset?
  #--------------------------------------------------------------------------
  alias bes_ec_use_charset? use_charset?
  def use_charset?
    flag = @character_name.nil? && @character_index.nil?
    return true if !flag
    return bes_ec_use_charset?
  end
  
  #--------------------------------------------------------------------------
  # new method: use_8d?
  #--------------------------------------------------------------------------
  def use_8d?
    return @character_name =~ /(_8D)/i if use_charset?
  end
  
  #--------------------------------------------------------------------------
  # new method: dual_wield?
  #--------------------------------------------------------------------------
  def dual_wield?
    self.enemy.eweapon_1 && self.enemy.eweapon_2
  end
  
  #--------------------------------------------------------------------------
  # new method: weapons
  #--------------------------------------------------------------------------
  def weapons
    result = []
    result.push($data_weapons[self.enemy.eweapon_1]) if self.enemy.eweapon_1
    result.push($data_weapons[self.enemy.eweapon_2]) if self.enemy.eweapon_2
    result
  end
  
  #--------------------------------------------------------------------------
  # new method: equips
  #--------------------------------------------------------------------------
  def equips
    result = []
    result.push($data_armors[self.enemy.eshield]) if self.enemy.eshield
  end
  
end # Game_Enemy

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================