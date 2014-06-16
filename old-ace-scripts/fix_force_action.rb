#==============================================================================
# 
# ▼ YSA Core Script: Fix Force Actions
# -- Last Updated: 2011.12.18
# -- Level: Easy
# -- Requires: none
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YSA-ForceActions"] = true

#==============================================================================
# ▼ Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2011.12.18 - Started Script and Finished.
# 
#==============================================================================
# ▼ Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This will fix the mechanic of force actions.
# Firstly, forced battler can be not removed from action list when he is being 
# forced through a switch. By default, if a battler have not acted and being forced
# , he will lost his current action.
# Secondly, for advanced users, you can put as many as you like battler in
# force action pending.
# 
#==============================================================================
# ▼ Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save. 
# 
#==============================================================================
# ▼ Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
#==============================================================================

module YSA
  module FORCE_ACTION
    REMOVE_SWITCH = 10
  end
end

#==============================================================================
# ■ BattleManager
#==============================================================================

module BattleManager
  
  #--------------------------------------------------------------------------
  # rewrite method: force_action
  #--------------------------------------------------------------------------
  def self.force_action(battler)
    @action_forced = [] if @action_forced == nil
    @action_forced.push(battler)
    @action_battlers.delete(battler) if $game_switches[YSA::FORCE_ACTION::REMOVE_SWITCH]
  end
  
  #--------------------------------------------------------------------------
  # rewrite method: action_forced?
  #--------------------------------------------------------------------------
  def self.action_forced?
    @action_forced != nil
  end
  
  #--------------------------------------------------------------------------
  # rewrite method: action_forced_battler
  #--------------------------------------------------------------------------
  def self.action_forced_battler
    @action_forced.shift
  end
  
  #--------------------------------------------------------------------------
  # rewrite method: clear_action_force
  #--------------------------------------------------------------------------
  def self.clear_action_force
    @action_forced = nil if @action_forced.empty?
  end
  
end # BattleManager

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # rewrite method: process_forced_action
  #--------------------------------------------------------------------------
  def process_forced_action
    while BattleManager.action_forced?
      last_subject = @subject
      @subject = BattleManager.action_forced_battler
      process_action
      @subject = last_subject
      BattleManager.clear_action_force
    end
  end
  
end