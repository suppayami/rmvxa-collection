#==============================================================================
# 
# ▼ YSA Battle Add-On: Team Combo
# -- Last Updated: 2011.12.26
# -- Level: Easy
# -- Requires: YSA Core Script: Fix Force Actions
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YSA-TeamCombo"] = true

#==============================================================================
# ▼ Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2011.12.26 - Changed Actor notetags to Class notetags.
# 2011.12.18 - Started Script and Finished.
# 
#==============================================================================
# ▼ Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This will make your party's members attack enemy if an actor explode that 
# enemy's weakness. You can decide team combo type of each actor, which means
# only actors have the same type as exploding actor can combo with him.
# 
#==============================================================================
# ▼ Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 and below YSA Core Script: Fix Force Actions
# but above ▼ Main. Remember to save.
# 
# -----------------------------------------------------------------------------
# Class Notetags - These notetags go in the class notebox in the database.
# -----------------------------------------------------------------------------
# <tc type: x>
# This will decide which type your class is. Default is type 0.
#
# <combo skill: x>
# This will decide which skill this class use when team combo is actived. 
# 
#==============================================================================
# ▼ Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
#==============================================================================

module YSA
  module TEAM_COMBO
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Mechanical Config -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # About when will stop combo counting.
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    
    # Default skill for combo.
    DEFAULT_COMBO_SKILL = 51

    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Battlelog Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # These are the various battlelog settings made for skill stealing. Change
    # the text and message duration for a successful skill stealing.
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    MSG_COMBO       = "%s started a combo!"   # Text for starting a combo.
    MSG_END         = "%s's combo ended!"   # Text for ending a combo.
    MSG_DURATION    = 4                       # Lower number = shorter duration.

  end
end

#==============================================================================
# ▼ Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

module YSA
  module REGEXP
  module CLASS
    
  TC_TYPE = /<(?:TC_TYPE|tc type):[ ](\d+)?>/i
	COMBO_SKILL_ID = /<(?:COMBO_SKILL|combo skill):[ ](\d+)?>/i
    
  end # ACTOR
  end # REGEXP
end # YSA

#==============================================================================
# ■ DataManager
#==============================================================================

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_tcombo load_database; end
  def self.load_database
    load_database_tcombo
    load_notetags_tcombo
  end
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_tcombo
  #--------------------------------------------------------------------------
  def self.load_notetags_tcombo
    groups = [$data_classes]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_tcombo
      end
    end
  end
  
end # DataManager

#==============================================================================
# ■ RPG::Class
#==============================================================================

class RPG::Class < RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :tctype
  attr_accessor :comboskill
  
  #--------------------------------------------------------------------------
  # common cache: load_notetags_tcombo
  #--------------------------------------------------------------------------
  def load_notetags_tcombo
    @tctype = 0
    @comboskill = YSA::TEAM_COMBO::DEFAULT_COMBO_SKILL
    #---
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YSA::REGEXP::CLASS::TC_TYPE
        @tctype = $1.to_i
      #---
      when YSA::REGEXP::CLASS::COMBO_SKILL_ID
        @comboskill = $1.to_i
      #---
      end
    } # self.note.split
    #---
  end
  
end # RPG::Class

#==============================================================================
# ■ RPG::Actor
#==============================================================================

class RPG::Actor < RPG::BaseItem

  #--------------------------------------------------------------------------
  # compatible method: tctype
  #--------------------------------------------------------------------------
  def tctype
    return $data_classes[class_id].tctype
  end
  
  #--------------------------------------------------------------------------
  # compatible method: comboskill
  #--------------------------------------------------------------------------
  def comboskill
    return $data_classes[class_id].comboskill
  end
  
end # RPG::Actor

#==============================================================================
# ■ Game_BattlerBase
#==============================================================================

class Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # alias method: movable?
  #--------------------------------------------------------------------------
  alias team_combo_movable? movable?
  def movable?
    team_combo_movable? || (exist? && self.force_tcombo)
  end
  
end

#==============================================================================
# ■ Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase

  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :team_combo
  attr_accessor :being_combo
  attr_accessor :force_tcombo
  attr_accessor :backup_actions_combo
  
  #--------------------------------------------------------------------------
  # alias method: make_damage_value
  #--------------------------------------------------------------------------
  alias team_combo_make_damage_value_p100 make_damage_value
  def make_damage_value(user, item)
    team_combo_make_damage_value_p100(user, item)
    rate = item_element_rate(user, item)
    if user.actor? && rate > 1.0 && self.alive?
      user.team_combo = true
      self.being_combo = true
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: force_action
  #--------------------------------------------------------------------------
  alias team_combo_force_action force_action
  def force_action(skill_id, target_index)
    @backup_actions_combo = @actions.dup
    team_combo_force_action(skill_id, target_index)
  end
  
  #--------------------------------------------------------------------------
  # new method: restore_actions
  #--------------------------------------------------------------------------
  def restore_actions
    @actions = @backup_actions_combo.dup if @backup_actions_combo != nil
    @backup_actions_combo.clear if @backup_actions_combo != nil
    @backup_actions_combo = nil
  end
  
end # Game_Battler

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias method: use_item
  #--------------------------------------------------------------------------
  alias team_combo_use_item_ysa_p100 use_item
  def use_item
    team_combo_use_item_ysa_p100
    targets = @subject.current_action.make_targets.compact
    if @subject.team_combo && !targets.empty?
      string = YSA::TEAM_COMBO::MSG_COMBO
      text = sprintf(string, @subject.name)
      @log_window.add_text(text)
      YSA::TEAM_COMBO::MSG_DURATION.times do @log_window.wait end
      @log_window.back_one      
      for target in targets
        do_team_combo_ysa(@subject, target) if target.being_combo
        target.being_combo = false
      end
      @subject.team_combo = false 
      @team_combo_running = true
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: do_team_combo_ysa
  #--------------------------------------------------------------------------
  def do_team_combo_ysa(subject, target)
    for battler in $game_party.members
      next if battler == subject
      next if battler.dead?
      next unless battler.movable?
      next if battler.actor.tctype != subject.actor.tctype
      battler.force_action(battler.actor.comboskill, target.index)
      BattleManager.force_action(battler)
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: process_forced_action
  #--------------------------------------------------------------------------
  alias team_combo_process_forced_action process_forced_action
  def process_forced_action
    team_combo_process_forced_action
    if @team_combo_running
      for member in $game_party.members
        member.restore_actions
        status_redraw_target(member)
      end
      string = YSA::TEAM_COMBO::MSG_END
      text = sprintf(string, @subject.name)
      @log_window.add_text(text)
      YSA::TEAM_COMBO::MSG_DURATION.times do @log_window.wait end
      @log_window.back_one
      @team_combo_running = false
    end
  end
  
end

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================