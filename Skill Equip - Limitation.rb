#==============================================================================
# 
# Å• Yami Engine Symphony - Skill Equip: Limitation
# -- Last Updated: 2013.05.12
# -- Level: Easy
# -- Requires: YES - Skill Equip
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-SkillEquipLimitation"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2013.05.12 - Finished Script.
# 2013.05.06 - Started Script.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is an add-on for YES - Skill Equip, allows user to limit skill
# equip by skill tags.
#
#==============================================================================
# Å• Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below Å• Materials/ëfçﬁ but above Å• Main. Remember to save.
#
# -----------------------------------------------------------------------------
# Actor Notetags - These notetags go in the actors notebox in the database.
# -----------------------------------------------------------------------------
# <tag slots x: y>
# Change base slots of tag ID x to y.
#
# <tag slots x: +y>
# <tag slots x: -y>
# Change base slots of tag ID x by y.
#
# -----------------------------------------------------------------------------
# Class Notetags - These notetags go in the classes notebox in the database.
# -----------------------------------------------------------------------------
# <tag slots x: y>
# Change base slots of tag ID x to y.
#
# <tag slots x: +y>
# <tag slots x: -y>
# Change base slots of tag ID x by y.
#
# -----------------------------------------------------------------------------
# Weapon Notetags - These notetags go in the weapons notebox in the database.
# -----------------------------------------------------------------------------
# <tag slots x: +y>
# <tag slots x: -y>
# Change base slots of tag ID x by y.
#
# -----------------------------------------------------------------------------
# Skill Notetags - These notetags go in the skills notebox in the database.
# -----------------------------------------------------------------------------
# <skill tag: x>
# Change x to tag ID configured in script header.
#
#==============================================================================
# Å• Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjustments.
# 
#==============================================================================

#==============================================================================
# Å° Configuration
#==============================================================================

module YES
  module SKILL_EQUIP
    
    #===========================================================================
    # - Limitation Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # The following below will adjust the basic ruleset that the skill equip
    # limitation will use. Visual settings will also be adjusted here.
    #===========================================================================
    SKILL_TAGS = { # Start.
      # Tag ID  =>  ["Tag Name" , Default Limit],
        0       =>  ["Common"   , 3],
        1       =>  ["Epic"     , 2],
        2       =>  ["Legendary", 1],
    } # End.
    DEFAULT_TAG = 0 # Default skill tag.
    LIMITATION_TEXT = "Limitation"

  end
end

#==============================================================================
# Å• Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

#==============================================================================
# Å° Regular Expression
#==============================================================================

module REGEXP
  module SKILL_EQUIP
    TAG_SLOTS = /<TAG SLOTS[ ]*(\d+):[ ]*(\d+)>/i
    CHANGE_TAG_SLOTS = /<TAG SLOTS[ ]*(\d+):[ ]*([\+\-]?\d+)>/i
    SKILL_TAG = /<SKILL TAG:[ ]*(\d+)>/i
  end # SKILL_EQUIP
end # REGEXP

#==============================================================================
# Å° DataManager
#==============================================================================

module DataManager
    
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_skill_equip_el load_database; end
  def self.load_database
    load_database_skill_equip_el
    initialize_skill_equip_el
  end
  
  #--------------------------------------------------------------------------
  # new method: initialize_skill_equip_el
  #--------------------------------------------------------------------------
  def self.initialize_skill_equip_el
    groups = [$data_actors, $data_classes, $data_weapons, $data_armors, $data_skills]
    groups.each { |group|
      group.each { |obj|
        next if obj.nil?
        obj.initialize_skill_equip_el
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
  attr_accessor :tag_slots 
  attr_accessor :tag_slots_change
  attr_accessor :skill_tag

  #--------------------------------------------------------------------------
  # new method: initialize_skill_equip_el
  #--------------------------------------------------------------------------
  def initialize_skill_equip_el
    @skill_tag = YES::SKILL_EQUIP::DEFAULT_TAG
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::SKILL_EQUIP::TAG_SLOTS
        @tag_slots ||= []
        @tag_slots[$1.to_i] = $2.to_i
      when REGEXP::SKILL_EQUIP::CHANGE_TAG_SLOTS
        @tag_slots_change ||= []
        @tag_slots_change[$1.to_i] = $2.to_i
      when REGEXP::SKILL_EQUIP::SKILL_TAG
        @skill_tag = $1.to_i
      end
    }
  end
  
end # RPG::BaseItem

#==============================================================================
# Å° Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # new method: default_tag_slots
  #--------------------------------------------------------------------------
  def default_tag_slots
    result = []
    YES::SKILL_EQUIP::SKILL_TAGS.each { |key, value|
      result[key] = value[1]
    }
    result
  end

  #--------------------------------------------------------------------------
  # new method: base_tag_slots
  #--------------------------------------------------------------------------
  def base_tag_slots
    array = [self.class.tag_slots, self.actor.tag_slots]
    array.compact.size > 0 ? array.compact[0] : default_tag_slots
  end
  
  #--------------------------------------------------------------------------
  # new method: change_tag_slots
  #--------------------------------------------------------------------------
  def change_tag_slots
    result = []
    array = self.equips + [self.class, self.actor]
    array.compact.each { |o| 
      next unless o.tag_slots_change
      o.tag_slots_change.each_with_index { |v, i| 
        result[i] ||= 0; result[i] += v 
      }
    }
    result
  end
  
  #--------------------------------------------------------------------------
  # new method: tag_slots
  #--------------------------------------------------------------------------
  def tag_slots
    result = []
    YES::SKILL_EQUIP::SKILL_TAGS.each_key { |key|
      base = base_tag_slots[key] ? base_tag_slots[key] : default_tag_slots[key]
      change = change_tag_slots[key] ? change_tag_slots[key] : 0
      result[key] = [base + change, 0].max
    }
    result
  end
  
  #--------------------------------------------------------------------------
  # new method: skill_tags
  #--------------------------------------------------------------------------
  def skill_tags(tag_id)
    equipped_skills.count { |o| o.skill_tag == tag_id }
  end
  
  #--------------------------------------------------------------------------
  # alias method: skill_equippable?
  #--------------------------------------------------------------------------
  alias yes_seel_skill_equippable? skill_equippable?
  def skill_equippable?(id)
    return true if id == 0
    skill = $data_skills[id]
    slot_numbers = tag_slots[skill.skill_tag]
    slot_fill = skill_tags(skill.skill_tag)
    return false if slot_fill >= slot_numbers
    return yes_seel_skill_equippable?(id)
  end
  
end # Game_Actor

#==============================================================================
# Å° Window_Properties_Slot
#==============================================================================

class Window_Properties_Slot < Window_Base
  
  #--------------------------------------------------------------------------
  # alias method: refresh
  #--------------------------------------------------------------------------
  alias yes_seel_refresh refresh
  def refresh
    yes_seel_refresh
    #---
    i = YES::SKILL_EQUIP::DEFAULT_PROPERTIES.size
    i += @item.slot_properties.size if @item && @item != 0
    i = 0 if @item.nil? || @item == 0
    dy = (i + 1) * line_height
    change_color(system_color, true)
    draw_text(0, dy, contents.width, line_height, YES::SKILL_EQUIP::LIMITATION_TEXT, 1)
    #---
    j = 1
    change_color(normal_color, true)
    YES::SKILL_EQUIP::SKILL_TAGS.each { |key, value|
      draw_text(0, dy + j * line_height, contents.width, line_height, value[0], 0)
      text = "#{@actor.skill_tags(key)}/#{@actor.tag_slots[key]}" if @actor
      draw_text(0, dy + j * line_height, contents.width, line_height, text, 2)
      j += 1
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_skill_tag
  #--------------------------------------------------------------------------
  def draw_skill_tag(y)
    w = contents.width
    change_color(system_color)
    draw_text(0, y, w, line_height, YES::SKILL_EQUIP::PROPERTIES[:tag])
    change_color(normal_color)
    draw_text(0, y, w, line_height, YES::SKILL_EQUIP::SKILL_TAGS[@item.skill_tag][0], 2)
  end
  
end # Window_Properties_Slot

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================