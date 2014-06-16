#==============================================================================
# 
# Å• Yanfly Engine Ace - Skill Steal v1.00
#   Yami's Unofficial Edition
# -- Last Updated: 2011.12.11
# -- Level: Normal
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YEA-SkillSteal"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2011.12.11 - Edited (Yami).
# 2011.12.10 - Started Script and Finished.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script enables items and skills to have skill stealing properties. When
# an actor uses that said item or skill on an enemy and the enemy has skills
# that can be stolen, that actor will learn all of the skills the enemy has to
# provide. This skill stealing system is madeakin to the Final Fantasy X's
# Lancet skill from Kimahri.
# 
#==============================================================================
# Å• Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below Å• Materials/ëfçﬁ but above Å• Main. Remember to save.
# 
# -----------------------------------------------------------------------------
# Skill Notetags - These notetags go in the skills notebox in the database.
# -----------------------------------------------------------------------------
# <skill steal>
# If this skill targets an enemy, the actor who uses it will learn all of the
# stealable skills the enemy knows in its action list.
#
# <skill steal temp>
# If this skill targets an enemy, the actor who uses it will learn all of the
# stealable skills the enemy knows in its action list, but all learned skills
# will be forget when the battle ends.
# 
# <stealable skill: x>
# A skill with this notetag can be stolen from enemies if it is listed within
# the enemy's action list. x is the chance this skill can be stolen.
# 
# -----------------------------------------------------------------------------
# Item Notetags - These notetags go in the items notebox in the database.
# -----------------------------------------------------------------------------
# <skill steal>
# If this item targets an enemy, the actor who uses it will learn all of the
# stealable skills the enemy knows in its action list.
#
# <skill steal temp>
# If this skill targets an enemy, the actor who uses it will learn all of the
# stealable skills the enemy knows in its action list, but all learned skills
# will be forget when the battle ends.
# 
#==============================================================================
# Å• Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
#==============================================================================

module YEA
  module SKILL_STEAL
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Battlelog Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # These are the various battlelog settings made for skill stealing. Change
    # the text and message duration for a successful skill stealing.
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    MSG_SKILL_STEAL = "%s learns %s from %s!" # Text for successful steal.
    MSG_FAIL        = "%s fails on learning %s from %s!" # Text for successful steal.
    MSG_DURATION    = 4                       # Lower number = shorter duration.
    
  end # SKILL_STEAL
end # YEA

#==============================================================================
# Å• Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

module YEA
  module REGEXP
  module USABLEITEM
    
    SKILL_STEAL     = /<(?:SKILL_STEAL|skill steal)>/i
    SKILL_STEAL_TEM = /<(?:SKILL_STEAL_TEMP|skill steal temp)>/i
    STEALABLE_SKILL = /<(?:STEALABLE_SKILL|stealable skill):[ ](\d+)?>/i
    
  end # USABLEITEM
  end # REGEXP
end # YEA

#==============================================================================
# Å° DataManager
#==============================================================================

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_ss load_database; end
  def self.load_database
    load_database_ss
    load_notetags_ss
  end
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_ss
  #--------------------------------------------------------------------------
  def self.load_notetags_ss
    groups = [$data_skills, $data_items]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_ss if obj.is_a?(RPG::Skill)
        obj.load_notetags_ss if obj.is_a?(RPG::Item)
      end
    end
  end
  
end # DataManager

#==============================================================================
# Å° RPG::UsableItem
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :skill_steal
  attr_accessor :skill_steal_temp
  attr_accessor :stealable_skill
  attr_accessor :stealable_skill_chance
  
  #--------------------------------------------------------------------------
  # common cache: load_notetags_s
  #--------------------------------------------------------------------------
  def load_notetags_ss
    #---
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YEA::REGEXP::USABLEITEM::SKILL_STEAL
        @skill_steal = true
      when YEA::REGEXP::USABLEITEM::SKILL_STEAL_TEM
        @skill_steal_temp = true
      when YEA::REGEXP::USABLEITEM::STEALABLE_SKILL
        next unless self.is_a?(RPG::Skill)
        @stealable_skill = true
        @stealable_skill_chance = $1.to_i
        @stealable_skill_chance = 0 if @stealable_skill_chance < 0
        @stealable_skill_chance = 100 if @stealable_skill_chance > 100
      #---
      end
    } # self.note.split
    #---
  end
  
end # RPG::UsableItem

#==============================================================================
# Å° Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :stolen_skills
  
  #--------------------------------------------------------------------------
  # alias method: on_battle_start
  #--------------------------------------------------------------------------
  alias steal_skill_on_battle_start on_battle_start
  def on_battle_start
    steal_skill_on_battle_start
    @stolen_skills = [] if self.actor?
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_battle_end
  #--------------------------------------------------------------------------
  alias steal_skill_on_battle_end on_battle_end
  def on_battle_end
    steal_skill_on_battle_end
    if self.actor?
      for i in @stolen_skills
        forget_skill(i)
      end
      @stolen_skills = []
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_user_effect
  #--------------------------------------------------------------------------
  alias game_battler_item_user_effect_ss item_user_effect
  def item_user_effect(user, item)
    game_battler_item_user_effect_ss(user, item)
    item_skill_steal_effect(user, item)
  end
  
  #--------------------------------------------------------------------------
  # new method: item_skill_steal_effect
  #--------------------------------------------------------------------------
  def item_skill_steal_effect(user, item)
    return unless item.skill_steal
    return unless user.actor?
    return if self.actor?
    for skill in stealable_skills
      next if user.skill_learn?(skill)
      @result.success = true
      break
    end
  end
  
end # Game_Battler

#==============================================================================
# Å° Game_Enemy
#==============================================================================

class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # stealable_skills
  #--------------------------------------------------------------------------
  def stealable_skills
    array = []
    for action in enemy.actions
      skill = $data_skills[action.skill_id]
      array.push(skill) if skill.stealable_skill
    end
    return array
  end
  
end # Game_Enemy

#==============================================================================
# Å° Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias method: apply_item_effects
  #--------------------------------------------------------------------------
  alias scene_battle_apply_item_effects_ss apply_item_effects
  def apply_item_effects(target, item)
    scene_battle_apply_item_effects_ss(target, item)
    apply_skill_steal(target, item)
  end
  
  #--------------------------------------------------------------------------
  # new method: apply_skill_steal
  #--------------------------------------------------------------------------
  def apply_skill_steal(target, item)
    return unless item.skill_steal or item.skill_steal_temp
    return if target.actor?
    return unless @subject.actor?
    for skill in target.stealable_skills
      next if @subject.skill_learn?(skill)
      if rand(100) <= skill.stealable_skill_chance
        @subject.learn_skill(skill.id) if !item.skill_steal_temp
        if item.skill_steal_temp
          @subject.learn_skill(skill.id)
          @subject.stolen_skills.push(skill.id) if !@subject.stolen_skills.include?(skill.id)
        end
        string = YEA::SKILL_STEAL::MSG_SKILL_STEAL
        skill_text = sprintf("\\i[%d]%s", skill.icon_index, skill.name)
        text = sprintf(string, @subject.name, skill_text, target.name)
        @log_window.add_text(text)
        YEA::SKILL_STEAL::MSG_DURATION.times do @log_window.wait end
        @log_window.back_one
      else
        string = YEA::SKILL_STEAL::MSG_FAIL
        skill_text = sprintf("\\i[%d]%s", skill.icon_index, skill.name)
        text = sprintf(string, @subject.name, skill_text, target.name)
        @log_window.add_text(text)
        YEA::SKILL_STEAL::MSG_DURATION.times do @log_window.wait end
        @log_window.back_one
      end
    end
  end
  
end # Scene_Battle

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================