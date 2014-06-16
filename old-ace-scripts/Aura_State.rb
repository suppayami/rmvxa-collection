#==============================================================================
# 
# Å• YSA Battle Add-On: State Aura
# -- Last Updated: 2011.12.14
# -- Level: Easy
# -- Requires: none
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YSA-StateAura"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2011.12.14 - Started Script and Finished.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script will make your state can be an aura, which means as long as this
# state are still remaining, all other battlers (allies or enemies) will have
# a state you decided.
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
# <ally state aura: x>
# This aura will add to all allies state x.
#
# <enemy state aura: x>
# This aura will add to all enemies state x.
# 
#==============================================================================
# Å• Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
#==============================================================================

#==============================================================================
# Å• Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

module YSA
  module REGEXP
  module STATE
    
  ALLY_STATE_AURA = /<(?:ALLY_STATE_AURA|ally state aura):[ ](\d+)?>/i
	ENEMY_STATE_AURA = /<(?:ENEMY_STATE_AURA|enemy state aura):[ ](\d+)?>/i
    
  end # STATE
  end # REGEXP
end # YSA

#==============================================================================
# Å° DataManager
#==============================================================================

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_staura load_database; end
  def self.load_database
    load_database_staura
    load_notetags_staura
  end
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_staura
  #--------------------------------------------------------------------------
  def self.load_notetags_staura
    groups = [$data_states]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_staura
      end
    end
  end
  
end # DataManager

#==============================================================================
# Å° RPG::State
#==============================================================================

class RPG::State < RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :ally_state_aura
  attr_accessor :enemy_state_aura
  
  #--------------------------------------------------------------------------
  # common cache: load_notetags_staura
  #--------------------------------------------------------------------------
  def load_notetags_staura
    #---
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YSA::REGEXP::STATE::ALLY_STATE_AURA
        @ally_state_aura = [] if @ally_state_aura == nil
        @ally_state_aura.push($1.to_i)        
      when YSA::REGEXP::STATE::ENEMY_STATE_AURA
        @enemy_state_aura = [] if @enemy_state_aura == nil
        @enemy_state_aura.push($1.to_i)  
      end
    } # self.note.split
    #---
  end
  
end # RPG::State

#==============================================================================
# Å° Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase

  #--------------------------------------------------------------------------
  # alias method: add_state
  #--------------------------------------------------------------------------
  alias aura_add_state add_state
  def add_state(state_id, aura = false)
    aura_add_state(state_id)
    if $data_states[state_id].ally_state_aura != nil or $data_states[state_id].enemy_state_aura != nil
      for battler in ($game_party.members + $game_troop.members)
        if $data_states[state_id].ally_state_aura != nil
          for state in $data_states[state_id].ally_state_aura
            battler.add_state(state, true) if battler.actor?
          end
        end
        if $data_states[state_id].enemy_state_aura != nil
          for state in $data_states[state_id].enemy_state_aura
            battler.add_state(state, true) if battler.enemy?
          end
        end
      end
    end
    @state_turns[state_id] = 999 if aura
  end
  
  #--------------------------------------------------------------------------
  # alias method: remove_state
  #--------------------------------------------------------------------------
  alias aura_remove_state remove_state
  def remove_state(state_id)
    aura_remove_state(state_id)
    if $data_states[state_id].ally_state_aura != nil or $data_states[state_id].enemy_state_aura != nil
      for battler in ($game_party.members + $game_troop.members)
        if $data_states[state_id].ally_state_aura != nil
          for state in $data_states[state_id].ally_state_aura
            battler.remove_state(state)
          end
        end
        if $data_states[state_id].enemy_state_aura != nil
          for state in $data_states[state_id].enemy_state_aura
            battler.remove_state(state)
          end
        end
      end
    end
  end
  
end # Game_Battler

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================