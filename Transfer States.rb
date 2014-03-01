#==============================================================================
# 
# Å• Yami Engine Symphony - Transfer States
# -- Last Updated: 2012.12.16
# -- Level: Easy
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-TransferStates"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.12.16 - Started and Finished Script.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides transfering states ability for battlers.
#
#==============================================================================
# Å• Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below Å• Materials/ëfçﬁ but above Å• Main. Remember to save.
#
# -----------------------------------------------------------------------------
# Skill Notetags - These notetags go in the skill notebox in the database.
# -----------------------------------------------------------------------------
# <transfer allow: x, x, x>
# Limits states id that skill can transfer. Replace x with state ID.
#
# <transfer n states: string>
# Transfers n states from user to target. String can be:
#   last states
#   high priority
#   low priority
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
  module TRANSFER_STATES
    TRANSFER_ALLOW = /<(?:TRANSFER_ALLOW|transfer allow):[ ]*(.*)>/i
    TRANSFER_STATE = /<(?:TRANSFER (\d+) STATES):[ ]*(.*)>/i
  end # TRANSFER_STATES
end # REGEXP

#==============================================================================
# Å° DataManager
#==============================================================================

module DataManager
    
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_transfer_states load_database; end
  def self.load_database
    load_database_transfer_states
    initialize_transfer_states
  end
  
  #--------------------------------------------------------------------------
  # new method: initialize_transfer_states
  #--------------------------------------------------------------------------
  def self.initialize_transfer_states
    groups = [$data_skills, $data_items]
    groups.each { |group|
      group.each { |obj|
        next if obj.nil?
        obj.initialize_transfer_states
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
  attr_accessor :transfer_allow
  attr_accessor :transfer_states

  #--------------------------------------------------------------------------
  # new method: initialize_transfer_states
  #--------------------------------------------------------------------------
  def initialize_transfer_states
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::TRANSFER_STATES::TRANSFER_ALLOW
        @transfer_allow ||= []
        $1.scan(/\d+/).each { |id| @transfer_allow.push(id.to_i) }
      when REGEXP::TRANSFER_STATES::TRANSFER_STATE
        @transfer_states = [$1.to_i, $2.to_s]
      end
    }
  end
  
end # RPG::BaseItem

#==============================================================================
# Å° Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # alias method: item_test
  #--------------------------------------------------------------------------
  alias yes_transfer_states_item_test item_test
  def item_test(user, item)
    return true if transfering_states(user, item).size > 0
    return yes_transfer_states_item_test(user, item)
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_apply
  #--------------------------------------------------------------------------
  alias yes_transfer_states_item_user_effect item_user_effect
  def item_user_effect(user, item)
    item_effect_transfer_states(user, item)
    yes_transfer_states_item_user_effect(user, item)
  end
  
  #--------------------------------------------------------------------------
  # new method: item_effect_transfer_states
  #--------------------------------------------------------------------------
  def item_effect_transfer_states(user, item)
    return unless @result.hit?
    return unless item.transfer_states
    @result.success = true
    hash = transfering_states(user, item)
    hash.each { |id|
      self.add_state(id)
      user.remove_state(id)
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: transfering_states
  #--------------------------------------------------------------------------
  def transfering_states(user, item)
    return [] unless item.transfer_states
    result = []
    hash = item.transfer_states
    allow = item.transfer_allow
    states_hash = user.states
    #---
    case hash[1].upcase
    when "last", "last states", "last state"
      states_hash = user.result.added_states.reverse
    when "low", "low priority", "lower priority"
      states_hash.reverse!
    when "random"
      states_hash.shuffle!
    end
    #---
    states_hash.each { |state|
      next if allow && !allow.include?(state.id)
      result.push(state.id) unless result.include?(state.id)
      break if result.size >= hash[0]
    }
    return result
  end

end # Game_Battler

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================