#==============================================================================
# 
# Å• Yami Engine Symphony - Skill Equip
# -- Last Updated: 2013.01.02
# -- Level: Easy
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-SkillEquip"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2013.01.02 - Fixed: Added Skills.
#            - Added: Non equip skill, notetag: <non equip skill>.
#              Non equip skills will always be usable in battle.
# 2012.12.17 - Fixed: Big slots list.
# 2012.12.12 - Fixed: Reverting slots issue.
# 2012.12.08 - Compatible with: YEA - Victory Aftermath.
# 2012.12.05 - Finished Script.
# 2012.12.03 - Started Script.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script requires the player to make decisions as to which skills to bring
# into battle for each character.
#
#==============================================================================
# Å• Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below Å• Materials/ëfçﬁ but above Å• Main. Remember to save.
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
    # - Basic Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # The following below will adjust the basic ruleset that the skill equip
    # system will use. Visual settings will also be adjusted here.
    #===========================================================================
    COMMAND = "Equip Skill"     # This is the category title that appears for 
                                # the skill equip option.
    EQUIP_SKILL_SWITCH = 43     # This switch must be enabled in order for the 
                                # Equip Skill command to appear in the skill menu.
    
    # These are the visual settings used when a skill isn't equipped.
    EMPTY_SKILL_HELP = "No skill is equipped in this slot.\n
                        Press Enter to assign skill."
    EMPTY_SKILL_TEXT = "<Empty Slot>"        # Text used for no skill equipped.
    EMPTY_SKILL_ICON = 185                   # Icon used for no skill equipped.
    
    # This constant adjusts the default maximum amount of equipped skills that
    # an actor can have without modifications.
    DEFAULT_MAX_EQUIPS = 4
    
    #===========================================================================
    # - Description Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # The following below will adjust the description window, which includes 
    # skill's properties and description.
    # Here's the list of default properties:
    # -------------------------------------------------------------------------
    # :symbol          Description
    # -------------------------------------------------------------------------
    # :stype           Skill Type.
    # :cost            Skill Cost.
    # :speed           Speed Fix.
    # :success         Success Rate.
    #===========================================================================
    
    # Default displayed properties of each skill.
    DEFAULT_PROPERTIES = [ # Start.
        :stype,   # Skill Type
        :cost,    # Mana/TP Cost
        :speed,   # Speed Fix
        :success, # Success Rate
    ] # End.
    
    # Default displaying texts for properties.
    PROPERTIES = { # Start.
      :stype    =>  "Skill Type",
      :cost     =>  "Skill Cost",
      :speed    =>  "Speed Fix",
      :success  =>  "Hit Rate",
    } # End.
    
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
    MAX_EQUIPS = /<(?:SKILL_SLOTS|skill slots):[ ]*(\d+)>/i
    CHANGE_EQUIPS  = /<(?:CHANGE_SLOTS|change slots):[ ]*([\+\-]?\d+)>/i
    VALUE_DESCRIPTION  = /<(?:SKILL_INFO|skill info)[ ](.*):[ ]*(.*)>/i
    NON_EQUIP = /<(?:NON_EQUIP_SKILL|non equip skill)>/i
  end # SKILL_EQUIP
end # REGEXP

#==============================================================================
# Å° DataManager
#==============================================================================

module DataManager
    
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_skill_equip load_database; end
  def self.load_database
    load_database_skill_equip
    initialize_skill_equip
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_game_objects
  #--------------------------------------------------------------------------
  class <<self; alias create_game_objects_skill_equip create_game_objects; end
  def self.create_game_objects
    create_game_objects_skill_equip
    $game_switches[YES::SKILL_EQUIP::EQUIP_SKILL_SWITCH] = true
  end
  
  #--------------------------------------------------------------------------
  # new method: initialize_skill_equip
  #--------------------------------------------------------------------------
  def self.initialize_skill_equip
    groups = [$data_actors, $data_classes, $data_weapons, $data_armors, $data_skills]
    groups.each { |group|
      group.each { |obj|
        next if obj.nil?
        obj.initialize_skill_equip
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
  attr_accessor :skill_slots 
  attr_accessor :change_slots
  attr_accessor :slot_properties
  attr_accessor :non_equip_skill

  #--------------------------------------------------------------------------
  # new method: initialize_skill_equip
  #--------------------------------------------------------------------------
  def initialize_skill_equip
    @change_slots = 0
    @slot_properties = []
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::SKILL_EQUIP::MAX_EQUIPS
        @skill_slots = $1.to_i
      when REGEXP::SKILL_EQUIP::CHANGE_EQUIPS
        @change_slots = $1.to_i
      when REGEXP::SKILL_EQUIP::VALUE_DESCRIPTION
        @slot_properties.push([$1.to_s, $2.to_s])
      when REGEXP::SKILL_EQUIP::NON_EQUIP
        @non_equip_skill = true
      end
    }
  end
  
end # RPG::BaseItem

#==============================================================================
# Å° Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader :equip_skills 

  #--------------------------------------------------------------------------
  # alias method: setup
  #--------------------------------------------------------------------------
  alias yes_skill_equip_setup setup
  def setup(actor_id)
    yes_skill_equip_setup(actor_id)
    correct_equip_skills
  end
  
  #--------------------------------------------------------------------------
  # alias method: refresh
  #--------------------------------------------------------------------------
  alias yes_skill_equip_refresh refresh
  def refresh
    yes_skill_equip_refresh
    correct_equip_skills
    correct_skill_slots
  end
  
  #--------------------------------------------------------------------------
  # new method: base_skill_slots
  #--------------------------------------------------------------------------
  def base_skill_slots
    array = [self.class.skill_slots, self.actor.skill_slots]
    default = YES::SKILL_EQUIP::DEFAULT_MAX_EQUIPS
    array.compact.size > 0 ? array.compact[0] : default
  end
  
  #--------------------------------------------------------------------------
  # new method: change_slots
  #--------------------------------------------------------------------------
  def change_slots
    array = self.equips + [self.class, self.actor]
    array.compact.inject(0) { |r, o| r += o.change_slots }
  end
  
  #--------------------------------------------------------------------------
  # new method: skill_slots
  #--------------------------------------------------------------------------
  def skill_slots
    [base_skill_slots + change_slots, 0].max
  end

  #--------------------------------------------------------------------------
  # new method: correct_skill_slots
  #--------------------------------------------------------------------------
  def correct_skill_slots
    if @equip_skills.size < skill_slots
      @equip_skills = @equip_skills + Array.new(skill_slots - @equip_skills.size, 0)
    else
      @equip_skills = @equip_skills[0, skill_slots]
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: correct_equip_skills
  #--------------------------------------------------------------------------
  def correct_equip_skills
    if @equip_skills.nil?
      @equip_skills = Array.new(skill_slots, 0)
      #---
      j = 0
      all_skills.each_index { |i|
        break if i == @equip_skills.size
        while all_skills[j] && $data_skills[all_skills[j]].non_equip_skill
          j += 1
        end
        @equip_skills[i] = all_skills[j]
        j += 1
      }
    end
    #---
    @equip_skills.each_index { |i|
      id = @equip_skills[i]
      next if id == 0
      @equip_skills[i] = 0 unless all_skills.include?(id)
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: all_skills
  #--------------------------------------------------------------------------
  def all_skills
    (@skills | added_skills).sort
  end
  
  #--------------------------------------------------------------------------
  # new method: equip_skill
  #--------------------------------------------------------------------------
  def equip_skill(index, id)
    return false unless skill_equippable?(id)
    if @equip_skills.include?(id) && id != 0
      @equip_skills[@equip_skills.index(id)] = @equip_skills[index]
    end
    @equip_skills[index] = id
  end
  
  #--------------------------------------------------------------------------
  # new method: skill_equippable?
  #--------------------------------------------------------------------------
  def skill_equippable?(id)
    return true
  end
  
  #--------------------------------------------------------------------------
  # new method: equipped_skills
  #--------------------------------------------------------------------------
  def equipped_skills
    @equip_skills.select{|id|id != 0}.collect{|id|$data_skills[id]}
  end

  #--------------------------------------------------------------------------
  # alias method: skills
  # Overwrite in Battle
  #--------------------------------------------------------------------------
  alias yes_skill_equip_skills skills
  def skills
    if $game_party.in_battle && !$game_troop.all_dead?
      return equipped_skills + yes_skill_equip_skills.select{|s|s.non_equip_skill}
    else
      return yes_skill_equip_skills
    end
  end
    
end # Game_Actor

#==============================================================================
# Å° Window_SkillSlots
#==============================================================================

class Window_SkillSlots < Window_Selectable
    
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, Graphics.width / 2, height)
    self.index = 0
    self.hide
  end
  
  #--------------------------------------------------------------------------
  # item_max
  #--------------------------------------------------------------------------
  def item_max
    @actor.nil? ? 1 : @actor.skill_slots
  end
  
  #--------------------------------------------------------------------------
  # current_item_enabled?
  #--------------------------------------------------------------------------
  def current_item_enabled?
    @actor && @actor.skill_slots > 0
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    update_padding
    create_contents
    refresh
    self.oy = 0
    @index = 0
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill_id = @actor.equip_skills[index]
    #---
    return if skill_id.nil?
    reset_font_settings
    draw_item_none(index) if skill_id <= 0
    draw_item_name(index, skill_id) if skill_id > 0
  end
  
  #--------------------------------------------------------------------------
  # draw_item_none
  #--------------------------------------------------------------------------
  def draw_item_none(index)
    rect = item_rect(index)
    #---
    change_color(normal_color, false)
    draw_icon(YES::SKILL_EQUIP::EMPTY_SKILL_ICON, rect.x, rect.y, false)
    rect.x += 24
    draw_text(rect, YES::SKILL_EQUIP::EMPTY_SKILL_TEXT, 0)
  end
  
  #--------------------------------------------------------------------------
  # draw_item_name
  #--------------------------------------------------------------------------
  def draw_item_name(index, skill_id, enabled = true)
    rect = item_rect(index)
    item = $data_skills[skill_id]
    #---
    change_color(normal_color, enabled)
    draw_icon(item.icon_index, rect.x, rect.y, enabled)
    rect.x += 24
    draw_text(rect, item.name, 0)
  end
  
  #--------------------------------------------------------------------------
  # propertise_window=
  #--------------------------------------------------------------------------
  def properties_window=(properties_window)
    @properties_window = properties_window
    id = @actor.equip_skills[index]
    item = id.nil? ? nil : $data_skills[id]
    @properties_window.set_item(item)
  end
  
  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_help
    id = @actor.equip_skills[index]
    item = id.nil? ? nil : $data_skills[id]
    empty_text = YES::SKILL_EQUIP::EMPTY_SKILL_HELP
    item.nil? ? @help_window.set_text(empty_text) : @help_window.set_item(item)
    @properties_window.set_item(item) if @properties_window
  end
  
end # Window_SkillSlots

#==============================================================================
# Å° Window_SkillList_Equip
#==============================================================================

class Window_SkillList_Equip < Window_SkillList
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    self.hide
    self.index = 0
  end
  
  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  
  #--------------------------------------------------------------------------
  # enable?
  #--------------------------------------------------------------------------
  def enable?(item)
    @actor
  end
  
  #--------------------------------------------------------------------------
  # include?
  #--------------------------------------------------------------------------
  def include?(item)
    item
  end
  
  #--------------------------------------------------------------------------
  # make_item_list
  #--------------------------------------------------------------------------
  def make_item_list
    super
    @data = [0] + @data.select{|s|!s.non_equip_skill}
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill = @data[index]
    if skill && skill.is_a?(RPG::Skill)
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(skill, rect.x, rect.y, enable?(skill))
    else
      rect = item_rect(index)
      rect.width -= 4
      change_color(normal_color, false)
      draw_icon(YES::SKILL_EQUIP::EMPTY_SKILL_ICON, rect.x, rect.y, false)
      rect.x += 24
      draw_text(rect, YES::SKILL_EQUIP::EMPTY_SKILL_TEXT, 0)
    end
  end
  
  #--------------------------------------------------------------------------
  # item
  #--------------------------------------------------------------------------
  def item
    @data && @data[index] == 0 ? @data[index] : super
  end
  
  #--------------------------------------------------------------------------
  # properties_window=
  #--------------------------------------------------------------------------
  def properties_window=(properties_window)
    @properties_window = properties_window
  end
  
  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_help
    empty_text = YES::SKILL_EQUIP::EMPTY_SKILL_HELP
    item == 0 ? @help_window.set_text(empty_text) : @help_window.set_item(item)
    @properties_window.set_item(item) if @properties_window
  end
  
end # Window_SkillList_Equip

#==============================================================================
# Å° Window_Properties_Slot
#==============================================================================

class Window_Properties_Slot < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item = nil
    @actor = nil
    self.hide
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @actor
    if @item.nil? || @item == 0
      reset_font_settings
      change_color(normal_color, false)
      draw_icon(YES::SKILL_EQUIP::EMPTY_SKILL_ICON, 0, 0, false)
      draw_text(24, 0, contents.width, line_height, YES::SKILL_EQUIP::EMPTY_SKILL_TEXT)
    end
    return if @item.nil? || @item == 0
    reset_font_settings
    #---
    draw_item_name(@item, 0, 0)
    #---
    i = 0; hash = YES::SKILL_EQUIP::DEFAULT_PROPERTIES
    contents.font.size -= 2
    hash.each { |p| h = (i + 1) * line_height
      case p
      when :stype
        draw_skill_type(h)
      when :cost
        draw_skill_cost(h)
      when :speed
        draw_skill_speed(h)
      when :success
        draw_skill_rate(h)
      end
      i += 1
    }
    #---
    i = hash.size
    @item.slot_properties.each { |a| h = (i + 1) * line_height
      draw_skill_properties(a, h)
      i += 1 }
  end
    
  #--------------------------------------------------------------------------
  # draw_skill_type
  #--------------------------------------------------------------------------
  def draw_skill_type(y)
    w = contents.width
    change_color(system_color)
    draw_text(0, y, w, line_height, YES::SKILL_EQUIP::PROPERTIES[:stype])
    change_color(normal_color)
    draw_text(0, y, w, line_height, $data_system.skill_types[@item.stype_id], 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_skill_cost
  #--------------------------------------------------------------------------
  def draw_skill_cost(h)
    if $imported["YEA-SkillCostManager"]
      draw_skill_cost_advanced(h)
    else
      rect = Rect.new(0,h,contents.width,line_height)
      #---
      change_color(system_color)
      draw_text(rect, YES::SKILL_EQUIP::PROPERTIES[:cost])
      #---
      if @actor.skill_tp_cost(@item) > 0
        change_color(tp_cost_color)
        text = @actor.skill_tp_cost(@item).to_s + Vocab.tp_a
        draw_text(rect, text, 2)
        rect.width -= text_size(text).width + 4
      end
      #---
      if @actor.skill_mp_cost(@item) > 0
        change_color(mp_cost_color)
        text = @actor.skill_mp_cost(@item).to_s + Vocab.mp_a
        draw_text(rect, text, 2)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_skill_cost_advanced
  #--------------------------------------------------------------------------
  def draw_skill_cost_advanced(h)
    rect = Rect.new(0,h,contents.width,line_height)
    #---
    change_color(system_color)
    draw_text(rect, YES::SKILL_EQUIP::PROPERTIES[:cost])
    #---
    draw_tp_skill_cost(rect, @item) unless $imported["YEA-BattleEngine"]
    draw_mp_skill_cost(rect, @item)
    draw_tp_skill_cost(rect, @item) if $imported["YEA-BattleEngine"]
    draw_hp_skill_cost(rect, @item)
    draw_gold_skill_cost(rect, @item)
    draw_custom_skill_cost(rect, @item)
  end
  
  #--------------------------------------------------------------------------
  # draw_skill_speed
  #--------------------------------------------------------------------------
  def draw_skill_speed(y)
    w = contents.width
    change_color(system_color)
    draw_text(0, y, w, line_height, YES::SKILL_EQUIP::PROPERTIES[:speed])
    change_color(normal_color)
    draw_text(0, y, w, line_height, @item.speed.to_s, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_skill_rate
  #--------------------------------------------------------------------------
  def draw_skill_rate(y)
    w = contents.width
    change_color(system_color)
    draw_text(0, y, w, line_height, YES::SKILL_EQUIP::PROPERTIES[:success])
    change_color(normal_color)
    draw_text(0, y, w, line_height, @item.success_rate.to_s + "%", 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_skill_properties
  #--------------------------------------------------------------------------
  def draw_skill_properties(a, y)
    w = contents.width
    change_color(system_color)
    draw_text(0, y, w, line_height, a[0])
    change_color(normal_color)
    draw_text(0, y, w, line_height, a[1], 2)
  end
  
  #--------------------------------------------------------------------------
  # set_item
  #--------------------------------------------------------------------------
  def set_item(item)
    if @item != item
      @item = item
      refresh
    end
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(actor)
    @actor = actor
  end
  
  #--------------------------------------------------------------------------
  # Yanfly Engine Ace - Skill Cost Manager
  #--------------------------------------------------------------------------
  if $imported["YEA-SkillCostManager"]
    #--------------------------------------------------------------------------
    # new method: draw_mp_skill_cost
    #--------------------------------------------------------------------------
    def draw_mp_skill_cost(rect, skill)
      return unless @actor.skill_mp_cost(skill) > 0
      contents.font.size -= 2
      change_color(mp_cost_color)
      #---
      icon = Icon.mp_cost
      if icon > 0
        draw_icon(icon, rect.x + rect.width-24, rect.y)
        rect.width -= 24
      end
      #---
      contents.font.size = YEA::SKILL_COST::MP_COST_SIZE
      cost = @actor.skill_mp_cost(skill)
      text = sprintf(YEA::SKILL_COST::MP_COST_SUFFIX, cost.group)
      draw_text(rect, text, 2)
      cx = text_size(text).width + 4
      rect.width -= cx
      reset_font_settings
    end
    
    #--------------------------------------------------------------------------
    # new method: draw_tp_skill_cost
    #--------------------------------------------------------------------------
    def draw_tp_skill_cost(rect, skill)
      return unless @actor.skill_tp_cost(skill) > 0
      contents.font.size -= 2
      change_color(tp_cost_color)
      #---
      icon = Icon.tp_cost
      if icon > 0
        draw_icon(icon, rect.x + rect.width-24, rect.y)
        rect.width -= 24
      end
      #---
      contents.font.size = YEA::SKILL_COST::TP_COST_SIZE
      cost = @actor.skill_tp_cost(skill)
      text = sprintf(YEA::SKILL_COST::TP_COST_SUFFIX, cost.group)
      draw_text(rect, text, 2)
      cx = text_size(text).width + 4
      rect.width -= cx
      reset_font_settings
    end
    
    #--------------------------------------------------------------------------
    # new method: draw_hp_skill_cost
    #--------------------------------------------------------------------------
    def draw_hp_skill_cost(rect, skill)
      return unless @actor.skill_hp_cost(skill) > 0
      contents.font.size -= 2
      change_color(hp_cost_color)
      #---
      icon = Icon.hp_cost
      if icon > 0
        draw_icon(icon, rect.x + rect.width-24, rect.y)
        rect.width -= 24
      end
      #---
      contents.font.size = YEA::SKILL_COST::HP_COST_SIZE
      cost = @actor.skill_hp_cost(skill)
      text = sprintf(YEA::SKILL_COST::HP_COST_SUFFIX, cost.group)
      draw_text(rect, text, 2)
      cx = text_size(text).width + 4
      rect.width -= cx
      reset_font_settings
    end
    
    #--------------------------------------------------------------------------
    # new method: draw_gold_skill_cost
    #--------------------------------------------------------------------------
    def draw_gold_skill_cost(rect, skill)
      return unless @actor.skill_gold_cost(skill) > 0
      contents.font.size -= 2
      change_color(gold_cost_color)
      #---
      icon = Icon.gold_cost
      if icon > 0
        draw_icon(icon, rect.x + rect.width-24, rect.y)
        rect.width -= 24
      end
      #---
      contents.font.size = YEA::SKILL_COST::GOLD_COST_SIZE
      cost = @actor.skill_gold_cost(skill)
      text = sprintf(YEA::SKILL_COST::GOLD_COST_SUFFIX, cost.group)
      draw_text(rect, text, 2)
      cx = text_size(text).width + 4
      rect.width -= cx
      reset_font_settings
    end
    
    #--------------------------------------------------------------------------
    # new method: draw_custom_skill_cost
    #--------------------------------------------------------------------------
    def draw_custom_skill_cost(rect, skill)
      return unless skill.use_custom_cost
      contents.font.size -= 2
      change_color(text_color(skill.custom_cost_colour))
      icon = skill.custom_cost_icon
      if icon > 0
        draw_icon(icon, rect.x + rect.width-24, rect.y)
        rect.width -= 24
      end
      contents.font.size = skill.custom_cost_size
      text = skill.custom_cost_text
      draw_text(rect, text, 2)
      cx = text_size(text).width + 4
      rect.width -= cx
      reset_font_settings
    end
  end
  
end # Window_Properties_Slot

#==============================================================================
# Å° Window_SkillCommand
#==============================================================================

class Window_SkillCommand < Window_Command
  
  #--------------------------------------------------------------------------
  # alias method: make_command_list
  #--------------------------------------------------------------------------
  unless $imported["YEA-SkillMenu"]
  alias yes_skill_equip_make_command_list make_command_list
  def make_command_list
    yes_skill_equip_make_command_list
    add_command(YES::SKILL_EQUIP::COMMAND, :equip_skill, $game_switches[YES::SKILL_EQUIP::EQUIP_SKILL_SWITCH])
  end
  end
  
end # Window_SkillCommand

#==============================================================================
# Å° Scene_Skill
#==============================================================================

class Scene_Skill < Scene_ItemBase
  
  #--------------------------------------------------------------------------
  # alias method: start
  #--------------------------------------------------------------------------
  alias yes_skill_equip_start start
  def start
    yes_skill_equip_start
    create_slots_window
    create_skill_equip_window
    create_properties_window
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_command_window
  #--------------------------------------------------------------------------
  alias yes_skill_equip_create_command_window create_command_window
  def create_command_window
    yes_skill_equip_create_command_window
    @command_window.set_handler(:equip_skill, method(:command_equip_skill))
  end
  
  #--------------------------------------------------------------------------
  # new method: create_slots_window
  #--------------------------------------------------------------------------
  def create_slots_window
    wx = 0
    wy = @status_window.y + @status_window.height
    wh = Graphics.height - wy
    @slots_window = Window_SkillSlots.new(wx, wy, wh)
    @slots_window.viewport = @viewport
    @slots_window.help_window = @help_window
    @slots_window.actor = @actor
    @slots_window.set_handler(:ok, method(:on_slot_ok))
    @slots_window.set_handler(:cancel, method(:on_slot_cancel))
  end
  
  #--------------------------------------------------------------------------
  # new method: create_skill_equip_window
  #--------------------------------------------------------------------------
  def create_skill_equip_window
    wx = 0
    wy = @status_window.y + @status_window.height
    ww = Graphics.width / 2
    wh = Graphics.height - wy
    @skill_equip = Window_SkillList_Equip.new(wx, wy, ww, wh)
    @skill_equip.viewport = @viewport
    @skill_equip.help_window = @help_window
    @skill_equip.actor = @actor
    @skill_equip.set_handler(:ok, method(:on_skill_equip_ok))
    @skill_equip.set_handler(:cancel, method(:on_skill_equip_cancel))
  end
  
  #--------------------------------------------------------------------------
  # new method: create_properties_window
  #--------------------------------------------------------------------------
  def create_properties_window
    wx = @slots_window.width
    wy = @status_window.y + @status_window.height
    ww = Graphics.width / 2
    wh = Graphics.height - wy
    @properties_window = Window_Properties_Slot.new(wx, wy, ww, wh)
    @properties_window.viewport = @viewport
    @properties_window.actor = @actor
    @slots_window.properties_window = @properties_window
    @skill_equip.properties_window = @properties_window
  end
  
  #--------------------------------------------------------------------------
  # new method: command_equip_skill
  #--------------------------------------------------------------------------
  def command_equip_skill
    @slots_window.activate
  end
  
  #--------------------------------------------------------------------------
  # new method: on_slot_ok
  #--------------------------------------------------------------------------
  def on_slot_ok
    @slots_window.deactivate.hide
    @skill_equip.show.activate
  end
  
  #--------------------------------------------------------------------------
  # new method: on_slot_cancel
  #--------------------------------------------------------------------------
  def on_slot_cancel
    @slots_window.deactivate
    @command_window.activate
  end
  
  #--------------------------------------------------------------------------
  # new method: on_skill_equip_ok
  #--------------------------------------------------------------------------
  def on_skill_equip_ok
    id = @skill_equip.item == 0 ? 0 : @skill_equip.item.id
    @actor.equip_skill(@slots_window.index, id)
    @slots_window.refresh
    @skill_equip.deactivate.hide
    @slots_window.show.activate   
  end
  
  #--------------------------------------------------------------------------
  # new method: on_skill_equip_cancel
  #--------------------------------------------------------------------------
  def on_skill_equip_cancel
    @skill_equip.deactivate.hide
    @slots_window.show.activate    
  end
  
  #--------------------------------------------------------------------------
  # super method: update
  #--------------------------------------------------------------------------
  def update
    super
    if @command_window.active
      if @command_window.current_symbol == :equip_skill
        @item_window.hide
        @slots_window.show
        @properties_window.show
      else
        @slots_window.hide
        @properties_window.hide
        @item_window.show
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_actor_change
  #--------------------------------------------------------------------------
  alias yes_skill_equip_on_actor_change on_actor_change
  def on_actor_change
    yes_skill_equip_on_actor_change
    @slots_window.index = 0
    @skill_equip.index = 0
    @slots_window.actor = @actor
    @skill_equip.actor = @actor
    @properties_window.actor = @actor
    @slots_window.properties_window = @properties_window
  end
  
end # Scene_Skill

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================