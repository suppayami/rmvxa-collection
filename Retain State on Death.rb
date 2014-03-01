#==============================================================================
# 
# Å• Yami Engine Symphony - Retain State on Death
# -- Last Updated: 2013.03.03
# -- Level: Easy
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-RetainStateDeath"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2013.03.03 - Started and Finished Script.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script will make some kind of states can be retained on death.
#
#==============================================================================
# Å• Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below Å• Materials/ëfçﬁ but above Å• Main. Remember to save.
#
# -----------------------------------------------------------------------------
# State Notetags - These notetags go in the states notebox in the database.
# -----------------------------------------------------------------------------
# <retain on death>
# Makes that state can be retained on death.
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
  module RETAIN_STATE_ON_DEATH
    RETAIN = /<retain on death>/i
  end
end

#==============================================================================
# Å° RPG::State
#==============================================================================

class RPG::State < RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # new method: retain_on_death?
  #--------------------------------------------------------------------------
  def retain_on_death?
    self.note =~ REGEXP::RETAIN_STATE_ON_DEATH::RETAIN
  end
  
end # RPG::State

#==============================================================================
# Å° Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # alias method: die
  #--------------------------------------------------------------------------
  alias yes_rsod_die die
  def die
    retains = states.inject([]) { |r, state| 
      next unless state.retain_on_death?
      r.push([state.id, @state_turns[state.id], @state_steps[state.id]])
    }
    retains = [] if retains.nil?
    #---
    yes_rsod_die
    #---
    retains.each { |retain|
      @states.push(retain[0])
      @state_turns[retain[0]] = retain[1]
      @state_steps[retain[0]] = retain[2]
    }
    sort_states
  end
  
end # Game_Battler

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================