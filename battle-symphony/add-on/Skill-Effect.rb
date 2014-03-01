#==============================================================================
# 
# Å• Yami Engine Symphony - Add-on: Skill Effect Tags
# -- Last Updated: 2012.10.20
# -- Level: Nothing
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["BattleSymphony-SkillEffect"] = true

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
# Å° Scene_Battle - Imported Symphony Configuration
#==============================================================================

class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # alias method: imported_symphony
  #--------------------------------------------------------------------------
  alias bes_se_imported_symphony imported_symphony
  def imported_symphony
    case @action.upcase
      
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      # add state x: tune1
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # tune1
      # - refer to target typing; See Symphony Manual for more info.
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Replace x with the state ID you wish to add onto the target. If you
      # wish to add more than one state to the target, use more than one x
      # and separate them with comma.
      # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # add state 9: user
      # add state 10, 11, 12: targets
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      when /(?:ADD_STATE|ADD STATE)[ ](\d+(?:\s*,\s*\d+)*)/i
        action_add_state
        
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      # remove state x: tune1
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # tune1
      # - refer to target typing; See Symphony Manual for more info.
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Replace x with the state ID you wish to remove from the target. If you
      # wish to remove more than one state from the target, use more than one x
      # and separate them with comma.
      # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # remove state 9: user
      # remove state 10, 11, 12: targets
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      when /(?:REMOVE_STATE|REMOVE STATE)[ ](\d+(?:\s*,\s*\d+)*)/i
        action_remove_state
    
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      # damage change: tune1
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # tune1
      # - x%; This is the percent the damage inflation will change to.
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # This will inflate the damage dealt for the rest of the turn to x% of
      # what it usually deals. This affects both HP and MP damage, so you'll
      # have to calculate them separately if needed.
      # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # damage change: 125%
      # damage change: 80%
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      when /DAMAGE CHANGE/i
        action_damage_change
        
      else
        bes_se_imported_symphony        
    end
  end

end # Scene_Battle

#==============================================================================
# Å° Game_ActionResult
#==============================================================================

class Game_ActionResult
  
  #--------------------------------------------------------------------------
  # alias method: make_damage
  #--------------------------------------------------------------------------
  alias bes_se_make_damage make_damage
  def make_damage(value, item)
    value = (value * self.damage_ratio.to_f / 100).to_i
    bes_se_make_damage(value, item)
  end
  
  #--------------------------------------------------------------------------
  # new method: damage_ratio
  #--------------------------------------------------------------------------
  def damage_ratio
    @damage_ratio ? @damage_ratio : 100
  end
  
  #--------------------------------------------------------------------------
  # new method: set_damage_ratio
  #--------------------------------------------------------------------------
  def set_damage_ratio(ratio = 100)
    @damage_ratio = ratio
  end
  
end # Game_ActionResult

#==============================================================================
# Å° Scene_Battle - Imported Symphony Actions
#==============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # new method: action_add_state
  #--------------------------------------------------------------------------
  def action_add_state
    targets = get_action_targets.uniq
    return if targets.size == 0
    case @action
    when /(?:ADD_STATE|ADD STATE)[ ](\d+(?:\s*,\s*\d+)*)/i
      states = []
      $1.scan(/\d+/).each { |num| states.push(num.to_i) if num.to_i > 0 }
    end
    targets.each { |target| states.each { |i| target.add_state(i) } }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_remove_state
  #--------------------------------------------------------------------------
  def action_remove_state
    targets = get_action_targets.uniq
    return if targets.size == 0
    case @action
    when /(?:REMOVE_STATE|REMOVE STATE)[ ](\d+(?:\s*,\s*\d+)*)/i
      states = []
      $1.scan(/\d+/).each { |num| states.push(num.to_i) if num.to_i > 0 }
    end
    targets.each { |target| states.each { |i| target.remove_state(i) } }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_damage_change
  #--------------------------------------------------------------------------
  def action_damage_change
    return unless @subject
    return unless @subject.alive?
    ratio = @action_values[0].to_i
    @action_targets.each { |target| target.result.set_damage_ratio(ratio) }
  end
  
  #--------------------------------------------------------------------------
  # alias method: use_item
  #--------------------------------------------------------------------------
  alias bes_se_use_item use_item
  def use_item
    bes_se_use_item
    #---
    ($game_party.battle_members + $game_troop.members).each { |battler|
      battler.result.set_damage_ratio(100)
    }
  end
  
end # Scene_Battle

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================