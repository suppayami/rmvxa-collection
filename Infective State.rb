#==============================================================================
# 
# Å• Yami Engine Symphony - Infective State
# -- Last Updated: 2012.12.14
# -- Level: Easy
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-InfectiveState"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.12.14 - Finished Script.
# 2012.12.12 - Started Script.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides infect feature for specific states.
#
#==============================================================================
# Å• Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below Å• Materials/ëfçﬁ but above Å• Main. Remember to save.
#
# -----------------------------------------------------------------------------
# State Notetags - These notetags go in the state notebox in the database.
# -----------------------------------------------------------------------------
# <infect allies x: y, z%>
# Infects all allies with state x after y turns with a chance of z%.
#
# <infect enemies x: y, z%>
# Infects all enemies with state x after y turns with a chance of z%.
#
# <infect n allias x: y, z%>
# Infects n allies with state x after y turns with a chance of z%.
#
# <infect n enemies x: y, z%>
# Infects n enemies with state x after y turns with a chance of z%.
#
#==============================================================================
# Å• Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjustments.
# 
#==============================================================================

#==============================================================================
# Å• Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

#==============================================================================
# Å° Regular Expression
#==============================================================================

module REGEXP
  module INFECTIVE_STATE
    INFECT_ALLY = /<(?:INFECT ALLIES)[ ](\d+):[ ]*(\d+)(?:,[ ]*(\d+)[%Åì]?)?>/i
    INFECT_ENEMY  = /<(?:INFECT ENEMIES)[ ](\d+):[ ]*(\d+)(?:,[ ]*(\d+)[%Åì]?)?>/i
    INFECT_X_ALLY = /<(?:INFECT (\d+) ALLIES)[ ](\d+):[ ]*(\d+)(?:,[ ]*(\d+)[%Åì]?)?>/i
    INFECT_X_ENEMY = /<(?:INFECT (\d+) ENEMIES)[ ](\d+):[ ]*(\d+)(?:,[ ]*(\d+)[%Åì]?)?>/i
  end # INFECTIVE_STATE
end # REGEXP

#==============================================================================
# Å° DataManager
#==============================================================================

module DataManager
    
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_infective_state load_database; end
  def self.load_database
    load_database_infective_state
    initialize_infective_state
  end
  
  #--------------------------------------------------------------------------
  # new method: initialize_infective_state
  #--------------------------------------------------------------------------
  def self.initialize_infective_state
    groups = [$data_states]
    groups.each { |group|
      group.each { |obj|
        next if obj.nil?
        obj.initialize_infective_state
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
  attr_accessor :infect_allies 
  attr_accessor :infect_enemies

  #--------------------------------------------------------------------------
  # new method: initialize_infective_state
  #--------------------------------------------------------------------------
  def initialize_infective_state
    @infect_allies = {}
    @infect_enemies = {}
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::INFECTIVE_STATE::INFECT_ALLY
        array = [0, $2.to_i, $3.to_i]
        array[2] = 100 if array[2] <= 0
        @infect_allies[$1.to_i] = array if array[1] > 0
      when REGEXP::INFECTIVE_STATE::INFECT_ENEMY
        array = [0, $2.to_i, $3.to_i]
        array[2] = 100 if array[2] <= 0
        @infect_enemies[$1.to_i] = array if array[1] > 0
      when REGEXP::INFECTIVE_STATE::INFECT_X_ALLY
        array = [$1.to_i, $3.to_i, $4.to_i]
        array[2] = 100 if array[2] <= 0
        @infect_allies[$2.to_i] = array if array[1] > 0
      when REGEXP::INFECTIVE_STATE::INFECT_X_ENEMY
        array = [$1.to_i, $3.to_i, $4.to_i]
        array[2] = 100 if array[2] <= 0
        @infect_enemies[$2.to_i] = array if array[1] > 0
      end
    }
  end
  
end # RPG::BaseItem

#==============================================================================
# Å° Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # new method: infective_states
  #--------------------------------------------------------------------------
  def infective_states
    states.select { |state| 
      state.infect_allies.size + state.infect_enemies.size > 0
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: infective_allies
  #--------------------------------------------------------------------------
  def infective_allies
    states.select { |state| 
      state.infect_allies.size > 0
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: infective_enemies
  #--------------------------------------------------------------------------
  def infective_enemies
    states.select { |state| 
      state.infect_enemies.size > 0
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: infect_allies_include?
  #--------------------------------------------------------------------------
  def infect_allies_include?(id)
    infective_allies.any? { |state| state.infect_allies.keys.include?(id) }
  end
  
  #--------------------------------------------------------------------------
  # new method: infect_enemies_include?
  #--------------------------------------------------------------------------
  def infect_enemies_include?(id)
    infective_enemies.any? { |state| state.infect_enemies.keys.include?(id) }
  end
  
  #--------------------------------------------------------------------------
  # new method: infective_calc
  #--------------------------------------------------------------------------
  def update_infective
    @infect_allies ||= {}
    @infect_enemies ||= {}
    #---
    infective_allies.each { |state|
      state.infect_allies.each { |id, hash|
        @infect_allies[id] = hash[1] if @infect_allies[id].nil? || @infect_allies[id] <= 0
        @infect_allies[id] -= 1
      }
    }
    #---
    infective_enemies.each { |state|
      state.infect_enemies.each { |id, hash|
        @infect_enemies[id] = hash[1] if @infect_enemies[id].nil? || @infect_enemies[id] <= 0
        @infect_enemies[id] -= 1
      }
    }
    #---
    infective_allies.each { |state|
      state.infect_allies.each { |id, hash|
        next if @infect_allies[id] > 0
        if self.actor?
          battlers = $game_party.battle_members
        else
          battlers = $game_troop.members
        end
        if hash[0] <= 0
          if rand(100) < hash[2]
            battlers.each { |battler| battler.add_state(id) }
          end
        else
          count = hash[0]
          battlers = battlers.shuffle
          battlers.each { |battler|
            if battler && battler.alive? && !battler.state?(id)
              if rand(100) > hash[2]
                battler.add_state(id)
                count -= 1
              end
            end
            break if count <= 0
          }
        end
      }
    }
    #---
    infective_enemies.each { |state|
      state.infect_enemies.each { |id, hash|
        next if @infect_enemies[id] > 0
        next if rand(100) > hash[2]
        if self.actor?
          battlers = $game_troop.members
        else
          battlers = $game_party.battle_members
        end
        if hash[0] <= 0
          if rand(100) < hash[2]
            battlers.each { |battler| battler.add_state(id) }
          end
        else
          count = hash[0]
          battlers = battlers.shuffle
          battlers.each { |battler|
            if battler && battler.alive? && !battler.state?(id)
              if rand(100) > hash[2]
                battler.add_state(id)
                count -= 1
              end
            end
            break if count <= 0
          }
        end
      }
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: infective_clear
  #--------------------------------------------------------------------------
  def infective_clear
    @infect_allies.each_key { |id| 
      @infect_allies[id] = nil unless infect_allies_include?(id)
    }
    #---
    @infect_enemies.each_key { |id|
      @infect_enemies[id] = nil unless infect_enemies_include?(id)
    }
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_turn_end
  #--------------------------------------------------------------------------
  alias yes_infect_state_on_turn_end on_turn_end
  def on_turn_end
    yes_infect_state_on_turn_end
    update_infective
    infective_clear
  end
  
end # Game_Battler

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================