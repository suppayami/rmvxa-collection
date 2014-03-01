#==============================================================================
# 
# Å• Yami Engine Symphony - Equipment Learning
# -- Last Updated: 2012.12.21
# -- Level: Easy
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-EquipmentLearning"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.12.21 - Add compatible method for YEA - Ace Equip Engine.
# 2012.12.09 - Fixed: Victory bugs.
#            - Fixed: Major crash with more than one equipment.
# 2012.12.08 - Finished Script.
# 2012.12.05 - Started Script.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides a feature which allows actors to learn skills through
# their equipments by earning Ability Point (AP).
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
# <el require: x>
# Changes requiring Ability Point (AP) to learn skill to x.
#
# -----------------------------------------------------------------------------
# Enemy Notetags - These notetags go in the enemy notebox in the database.
# -----------------------------------------------------------------------------
# <el gain: x>
# Changes gaining Ability Point (AP) from killing enemy to x.
#
# -----------------------------------------------------------------------------
# Actor Notetags - These notetags go in the actor notebox in the database.
# -----------------------------------------------------------------------------
# <el rate: x%>
# Changes Ability Point (AP) gaining rate to x percent.
#
# -----------------------------------------------------------------------------
# Class Notetags - These notetags go in the class notebox in the database.
# -----------------------------------------------------------------------------
# <el rate: x%>
# Changes Ability Point (AP) gaining rate to x percent.
#
# -----------------------------------------------------------------------------
# Weapon Notetags - These notetags go in the weapon notebox in the database.
# -----------------------------------------------------------------------------
# <el skill: x>
# Adds skill id x to weapon's learning skills pool.
#
# -----------------------------------------------------------------------------
# Armor Notetags - These notetags go in the armor notebox in the database.
# -----------------------------------------------------------------------------
# <el skill: x>
# Adds skill id x to armor's learning skills pool.
#
# -----------------------------------------------------------------------------
# Script Calls - These commands are used with script calls.
# -----------------------------------------------------------------------------
# $game_actors[x].el_gain(y)
# This will cause actor x to gain y amount of AP.
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
  module EQUIPMENT_LEARNING
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - General AP Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # This adjusts the way AP appears visually in your game. AP is the kind of
    # point need to learn skill from Equipments.
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ICON   = 0           # Icon index used to represent AP.
    VOCAB  = "AP"        # What AP will be called in your game.
    # Below options are the Settings for Learning Window.
    LEARN_TITLE = "Available Skills"
    SHOW_GAUGE = true
    COLOR_GAUGE = { # Start.
      :color1 => 9,
      :color2 => 1,
    } # End.
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Scenes Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # This adjusts the way Learning Skills appears in your game.
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ENABLE_WINDOW = true # Enable Learning Window in Scene Equip.
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Default AP Gain Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # The following constants adjust how much AP is earned by default through
    # enemy kills, leveling up, and performing actions.
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ENEMY_KILL = 10     # AP earned for the whole party.
    LEVEL_UP   = 100    # AP earned when leveling up!
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Default AP Required Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # The following constants adjust how much AP is required by default to learn
    # skills from equipments.
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    REQUIRE_AP  = 100   # AP required for learning skill.
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Victory Message -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # This adjusts the victory message shown for the default battle system and
    # the Yanfly Engine Ace - Victory Aftermath script (if used together).
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    VICTORY_MESSAGE   = "%s has earned %s %s!"
    VICTORY_LEARN = "%s has learned new abilities!"
    # Below options are compatible settings for YEA - Victory Aftermath
    VICTORY_AFTERMATH = "+%s%s"
    VICTORY_AFTERMATH_QUOTES = { # Start.
      :el_learn => [ # Occurs when actor has learnt skills from Equipments.
                   '"I have mastered some skills from equipments!"',
                   '"Yeah! New skills!"',
                   ],# Do not remove this.
    } # End.
    
  end
end

#==============================================================================
# Å• Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

#==============================================================================
# Å° YEA - Victory Aftermath Compatible Area.
#==============================================================================

module YEA
  module VICTORY_AFTERMATH
    if $imported["YEA-VictoryAftermath"]
      VICTORY_QUOTES.merge!(YES::EQUIPMENT_LEARNING::VICTORY_AFTERMATH_QUOTES)
    end
  end
end

#==============================================================================
# Å° Regular Expression
#==============================================================================

module REGEXP
  module EQUIPMENT_LEARNING
    AP_RATE = /<(?:EL_RATE|el rate):[ ]*(\d+)(?:[%Åì])*>/i
    AP_GAIN = /<(?:EL_GAIN|el gain):[ ]*(\d+)>/i
    TEACH_SKILL = /<(?:EL_SKILL|el skill):[ ]*(\d+)>/i
    TEACH_REQ = /<(?:EL_REQUIRE|el require):[ ]*(\d+)>/i
    EL_QUOTE_ON    = /<(?:EL_QUOTES|el quote|el quotes)>/i
    EL_QUOTE_OFF   = /<\/(?:EL_QUOTES|el quote|el quotes)>/i
  end # EQUIPMENT_LEARNING
end # REGEXP

#==============================================================================
# Å° BattleManager
#==============================================================================

module BattleManager
  
  unless $imported["YEA-VictoryAftermath"]
    #--------------------------------------------------------------------------
    # alias method: display_exp
    #--------------------------------------------------------------------------
    class<< self; alias yes_equip_learning_display_exp display_exp; end
    def self.display_exp
      yes_equip_learning_display_exp
      if $game_troop.elp_total > 0
        text = ""
        $game_party.all_members.each { |actor|
          s = YES::EQUIPMENT_LEARNING::VICTORY_MESSAGE
          name = actor.name
          amount = ($game_troop.elp_total * actor.elr / 100).round
          vocab = YES::EQUIPMENT_LEARNING::VOCAB
          text += "\n" if text != ""
          text += sprintf(s, name, amount.to_s, vocab)
        }
        $game_message.add('\.' + text)
      end
    end
    
    #--------------------------------------------------------------------------
    # alias method: gain_exp
    #--------------------------------------------------------------------------
    class<< self; alias yes_equip_learning_gain_exp gain_exp; end
    def self.gain_exp
      yes_equip_learning_gain_exp
      $game_party.all_members.each { |actor|
        result = actor.el_gain($game_troop.elp_total)
        if result
          $game_message.new_page
          $game_message.add(sprintf(YES::EQUIPMENT_LEARNING::VICTORY_LEARN, actor.name))
          result.uniq.each do |skill|
            $game_message.add(sprintf(Vocab::ObtainSkill, skill.name))
          end
        end
      }
      wait_for_message
    end
  else
    #--------------------------------------------------------------------------
    # alias method: gain_exp
    #--------------------------------------------------------------------------
    class<< self; alias yes_equip_learning_gain_exp gain_exp; end
    def self.gain_exp
      @temp = {}
      $game_party.all_members.each { |actor|
        @temp[actor.object_id] = Marshal.load(Marshal.dump(actor))
      }
      yes_equip_learning_gain_exp
      gain_el
    end
    
    #--------------------------------------------------------------------------
    # new method: gain_el
    #--------------------------------------------------------------------------
    def self.gain_el
      $game_party.all_members.each { |actor|
        temp_actor = @temp[actor.object_id]
        actor.el_gain($game_troop.elp_total)
        next if actor.skills == temp_actor.skills
        SceneManager.scene.show_victory_el_learn(actor, temp_actor)
        set_victory_text(actor, :el_learn)
        wait_for_message
      }
    end
  end
  
end # BattleManager

#==============================================================================
# Å° DataManager
#==============================================================================

module DataManager
    
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_equipment_learning load_database; end
  def self.load_database
    load_database_equipment_learning
    initialize_equipment_learning
  end
  
  #--------------------------------------------------------------------------
  # new method: initialize_equipment_learning
  #--------------------------------------------------------------------------
  def self.initialize_equipment_learning
    groups = [$data_actors, $data_classes, $data_weapons, $data_armors, 
              $data_skills, $data_enemies, $data_items]
    groups.each { |group|
      group.each { |obj|
        next if obj.nil?
        obj.initialize_equipment_learning
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
  attr_accessor :el_skills 
  attr_accessor :el_rate
  attr_accessor :el_gain
  attr_accessor :el_require
  attr_accessor :el_quotes

  #--------------------------------------------------------------------------
  # new method: initialize_equipment_learning
  #--------------------------------------------------------------------------
  def initialize_equipment_learning
    @el_quotes = [""]
    @el_skills = []
    @el_gain = self.is_a?(RPG::Item) ? 0 : YES::EQUIPMENT_LEARNING::ENEMY_KILL
    @el_require = YES::EQUIPMENT_LEARNING::REQUIRE_AP
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::EQUIPMENT_LEARNING::AP_RATE
        @el_rate = $1.to_i
      when REGEXP::EQUIPMENT_LEARNING::AP_GAIN
        @el_gain = $1.to_i
      when REGEXP::EQUIPMENT_LEARNING::TEACH_SKILL
        @el_skills.push($1.to_i)
      when REGEXP::EQUIPMENT_LEARNING::TEACH_REQ
        @el_require = $1.to_i
      end
    }
    if $imported["YEA-VictoryAftermath"]
      self.note.split(/[\r\n]+/).each { |line|
        case line
        when REGEXP::EQUIPMENT_LEARNING::EL_QUOTE_ON
          @victory_quote_type = :el_quote
        when REGEXP::EQUIPMENT_LEARNING::EL_QUOTE_OFF
          @victory_quote_type = nil
        #---
        when YEA::REGEXP::BASEITEM::NEW_QUOTE
          case @victory_quote_type
          when nil; next
          when :el_quote;   @el_quotes.push("")
          end
        #---
        else
          case @victory_quote_type
          when nil; next
          when :el_quote;   @el_quotes[@el_quote.size-1] += line.to_s
          end
        end
      }
      return unless self.is_a?(RPG::Class)
      quotes = YEA::VICTORY_AFTERMATH::VICTORY_QUOTES
      @el_quotes = quotes[:el_learn].clone if @el_quotes == [""]
    end
  end
  
end # RPG::BaseItem

#==============================================================================
# Å° Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # alias method: setup
  #--------------------------------------------------------------------------
  alias yes_equip_learning_setup setup
  def setup(actor_id)
    yes_equip_learning_setup(actor_id)
    init_equip_learning
  end
  
  #--------------------------------------------------------------------------
  # new method: init_equip_learning
  #--------------------------------------------------------------------------
  def init_equip_learning
    @equip_learning ||= {}
  end
  
  #--------------------------------------------------------------------------
  # new method: el_skills
  #--------------------------------------------------------------------------
  def el_skills
    result = []
    self.equips.each { |e| 
      next if e.nil?
      e.el_skills.inject(result) { |r, i| r.push(i) }
    }
    result.compact.uniq
  end
  
  #--------------------------------------------------------------------------
  # new method: elr
  #--------------------------------------------------------------------------
  def elr
    [self.class.el_rate, self.actor.el_rate, 100].compact[0].to_f
  end
  
  #--------------------------------------------------------------------------
  # new method: req_elp
  #--------------------------------------------------------------------------
  def req_elp(skill_id)
    return 0 unless $data_skills[skill_id]
    $data_skills[skill_id].el_require
  end
  
  #--------------------------------------------------------------------------
  # new method: cur_elp
  #--------------------------------------------------------------------------
  def cur_elp(skill_id)
    return 0 unless $data_skills[skill_id]
    if skill_learn?($data_skills[skill_id])
      r = req_elp(skill_id)
    else
      r = @equip_learning.has_key?(skill_id) ? @equip_learning[skill_id] : 0
    end
    return r
  end
  
  #--------------------------------------------------------------------------
  # new method: fin_elp
  #--------------------------------------------------------------------------
  def fin_elp(skill_id)
    return req_elp(skill_id) == cur_elp(skill_id)
  end
  
  #--------------------------------------------------------------------------
  # new method: per_elp
  #--------------------------------------------------------------------------
  def per_elp(skill_id)
    cur_elp(skill_id) / req_elp(skill_id).to_f
  end
  
  #--------------------------------------------------------------------------
  # new method: el_gain
  #--------------------------------------------------------------------------
  def el_gain(amount = 0)
    return unless self.el_skills.size > 0
    return unless amount > 0
    learn = []
    point = (amount * elr / 100).round
    self.el_skills.each { |id|
      next unless $data_skills[id]
      @equip_learning.has_key?(id) ? @equip_learning[id] += point : @equip_learning[id] = point
      if @equip_learning[id] >= req_elp(id)
        learn.push(id) unless skill_learn?($data_skills[id])
        learn_skill(id)
        @equip_learning[id] = req_elp(id)
      end
    }
    return learn.size > 0 ? learn.collect { |id| $data_skills[id] } : false
  end
  
  #--------------------------------------------------------------------------
  # alias method: level_up
  #--------------------------------------------------------------------------
  alias yes_equip_learning_level_up level_up
  def level_up
    yes_equip_learning_level_up
    el_gain(YES::EQUIPMENT_LEARNING::LEVEL_UP)
  end
  
  #--------------------------------------------------------------------------
  # alias method: victory_quotes
  # Compatible with Yanfly Engine Ace - Victory Aftermath
  #--------------------------------------------------------------------------
  if $imported["YEA-VictoryAftermath"]
  alias yes_equip_learning_victory_quotes victory_quotes
  def victory_quotes(type)
    case type
    when :el_learn
      return self.actor.el_quotes if self.actor.el_quotes != [""]
      return self.class.el_quotes
    else
      return yes_equip_learning_victory_quotes(type)
    end
  end
  end
  
end # Game_Actor

#==============================================================================
# Å° Game_Enemy
#==============================================================================

class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # new method: elp
  #--------------------------------------------------------------------------
  def elp
    enemy.el_gain
  end
  
end # Game_Enemy

#==============================================================================
# Å° Game_Troop
#==============================================================================

class Game_Troop < Game_Unit
  
  #--------------------------------------------------------------------------
  # new method: elp_total
  #--------------------------------------------------------------------------
  def elp_total
    dead_members.inject(0) {|r, enemy| r += enemy.elp }
  end
  
end # Game_Troop

#==============================================================================
# Å° Window_VictoryEXP_Back
#==============================================================================

class Window_VictoryEXP_Back < Window_Selectable
  
  #--------------------------------------------------------------------------
  # alias method: draw_exp_gain
  # Compatible with Yanfly Engine Ace - Victory Aftermath
  #--------------------------------------------------------------------------
  if $imported["YEA-VictoryAftermath"]
    alias yes_equip_learning_draw_exp_gain draw_exp_gain
    def draw_exp_gain(actor, rect)
      yes_equip_learning_draw_exp_gain(actor, rect)
      draw_el_gain(actor, rect)
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_el_gain
  # Compatible with Yanfly Engine Ace - Victory Aftermath
  #--------------------------------------------------------------------------
  def draw_el_gain(actor, rect)
    dw = rect.width - (rect.width - [rect.width, 96].min) / 2
    dy = rect.y + line_height * 4 + 96
    dy += line_height if $imported["YEA-JPManager"]
    fmt = YES::EQUIPMENT_LEARNING::VICTORY_AFTERMATH
    text = sprintf(fmt, actor_elp_gain(actor).to_s, YES::EQUIPMENT_LEARNING::VOCAB)
    contents.font.size = YEA::VICTORY_AFTERMATH::FONTSIZE_EXP
    change_color(power_up_color)
    draw_text(rect.x, dy, dw, line_height, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # actor_elp_gain
  #--------------------------------------------------------------------------
  def actor_elp_gain(actor)
    n = $game_troop.elp_total
    if actor.exp + actor_exp_gain(actor) > actor.exp_for_level(actor.level + 1)
      n += YES::EQUIPMENT_LEARNING::LEVEL_UP unless actor.max_level?
    end
    return (n * actor.elr / 100).round
  end
  
end # Window_VictoryEXP_Back

#==============================================================================
# Å° Window_EquipLearning
#==============================================================================

class Window_EquipLearning < Window_Selectable
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    self.opacity = 0
  end
  
  #--------------------------------------------------------------------------
  # ap_gauge_color1
  #--------------------------------------------------------------------------
  def ap_gauge_color1
    text_color(YES::EQUIPMENT_LEARNING::COLOR_GAUGE[:color1])
  end
  
  #--------------------------------------------------------------------------
  # ap_gauge_color2
  #--------------------------------------------------------------------------
  def ap_gauge_color2
    text_color(YES::EQUIPMENT_LEARNING::COLOR_GAUGE[:color2])
  end
  
  #--------------------------------------------------------------------------
  # item_max
  #--------------------------------------------------------------------------
  def item_max
    @data.nil? ? 1 : @data.size
  end
  
  #--------------------------------------------------------------------------
  # current_item_enabled?
  #--------------------------------------------------------------------------
  def current_item_enabled?
    false
  end
  
  #--------------------------------------------------------------------------
  # enable?
  #--------------------------------------------------------------------------
  def enable?(skill)
    true
  end
  
  #--------------------------------------------------------------------------
  # equip=
  #--------------------------------------------------------------------------
  def equip=(equip)
    contents.clear
    @equip = equip
    return unless @equip
    @data = @equip.el_skills.collect { |i| $data_skills[i] }
    refresh
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(actor)
    @actor = actor
  end
  
  #--------------------------------------------------------------------------
  # item
  #--------------------------------------------------------------------------
  def item
    @data.nil? ? nil : @data[index]
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill = @data[index]
    if skill
      rect = item_rect(index)
      rect.width -= 4
      draw_ap(skill, rect.x + 2, rect.y, rect.width, enable?(skill))
      draw_item_name(skill, rect.x, rect.y, enable?(skill))
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_ap
  #--------------------------------------------------------------------------
  def draw_ap(item, x, y, width, enable = true)
    if @actor
      draw_gauge(x, y, width - 4, @actor.per_elp(item.id), 
                 ap_gauge_color1, ap_gauge_color2)
      draw_current_and_max_values(x, y, width - 4, @actor.cur_elp(item.id), 
                                  @actor.req_elp(item.id), normal_color, normal_color)
    else
      draw_gauge(x, y, width - 4, 0, 
                 ap_gauge_color1, ap_gauge_color2)
      draw_current_and_max_values(x, y, width - 4, 0, 
                                  item.el_require, normal_color, normal_color)
    end
  end
    
  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item)
  end
  
  #--------------------------------------------------------------------------
  # activate
  #--------------------------------------------------------------------------
  def activate
    self.index = 0
    super
  end
  
end # Window_EquipLearning

#==============================================================================
# Å° Window_EquipLearning
#==============================================================================

class Window_EquipLearningBack < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    text = YES::EQUIPMENT_LEARNING::LEARN_TITLE
    change_color(system_color)
    draw_text(0,0,contents.width,line_height,text,1)
  end
  
end # Window_EquipLearningBack

#==============================================================================
# Å° Window_EquipItem
#==============================================================================

class Window_EquipItem < Window_ItemList
  
  if YES::EQUIPMENT_LEARNING::ENABLE_WINDOW
  #--------------------------------------------------------------------------
  # overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  
  #--------------------------------------------------------------------------
  # new method: equip_learning_window
  #--------------------------------------------------------------------------
  def equip_learning_window=(window)
    @equip_learning_window = window
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_help
  #--------------------------------------------------------------------------
  alias yes_equip_learning_update_help update_help
  def update_help
    yes_equip_learning_update_help
    @equip_learning_window.equip = self.item
  end
  end
  
end # Window_EquipItem

#==============================================================================
# Å° Window_EquipSlot
#==============================================================================

class Window_EquipSlot < Window_Selectable
  
  if YES::EQUIPMENT_LEARNING::ENABLE_WINDOW  
  #--------------------------------------------------------------------------
  # new method: equip_learning_window
  #--------------------------------------------------------------------------
  def equip_learning_window=(window)
    @equip_learning_window = window
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_help
  #--------------------------------------------------------------------------
  alias yes_equip_learning_update_help update_help
  def update_help
    yes_equip_learning_update_help
    @equip_learning_window.equip = self.item
  end
  end
  
end # Window_EquipSlot

#==============================================================================
# Å° Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # new method: show_victory_el_learn
  #--------------------------------------------------------------------------
  def show_victory_el_learn(actor, temp_actor)
    @victory_exp_window_back.hide
    @victory_exp_window_front.hide
    #---
    fmt = YES::EQUIPMENT_LEARNING::VICTORY_LEARN
    text = sprintf(fmt, actor.name)
    @victory_title_window.refresh(text)
    #---
    @victory_level_window.show
    @victory_level_window.refresh(actor, temp_actor)
    @victory_level_skills.show
    @victory_level_skills.refresh(actor, temp_actor)
  end
  
end # Scene_Battle

#==============================================================================
# Å° Scene_Equip
#==============================================================================

class Scene_Equip < Scene_MenuBase
  
  if YES::EQUIPMENT_LEARNING::ENABLE_WINDOW
  #--------------------------------------------------------------------------
  # alias method: start
  #--------------------------------------------------------------------------
  alias yes_equip_learning_start start
  def start
    yes_equip_learning_start
    create_equip_learning
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_item_window
  #--------------------------------------------------------------------------
  alias yes_equip_learning_create_item_window create_item_window
  def create_item_window
    yes_equip_learning_create_item_window
    unless $imported["YEA-AceEquipEngine"]
      @item_window.width = Graphics.width / 2
      @item_window.create_contents
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: create_equip_learning
  #--------------------------------------------------------------------------
  def create_equip_learning
    wx = @item_window.width
    wy = @item_window.y
    ww = Graphics.width - @item_window.width
    wh = @item_window.height
    @equip_learning_back = Window_EquipLearningBack.new(wx, wy, ww, wh)
    @equip_learning_back.viewport = @viewport
    @equip_learning = Window_EquipLearning.new(wx, wy + 24, ww, wh - 24)
    @equip_learning.viewport = @viewport
    @equip_learning.help_window = @help_window
    @equip_learning.actor = @actor
    @item_window.equip_learning_window = @equip_learning
    @slot_window.equip_learning_window = @equip_learning
    #---
    if $imported["YEA-AceEquipEngine"]
      @equip_learning_back.hide
      @equip_learning.hide
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_slot_cancel
  #--------------------------------------------------------------------------
  alias yes_equip_learning_on_slot_cancel on_slot_cancel
  def on_slot_cancel
    yes_equip_learning_on_slot_cancel
    @equip_learning.equip = nil
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_actor_change
  #--------------------------------------------------------------------------
  alias yes_equip_learning_on_actor_change on_actor_change
  def on_actor_change
    yes_equip_learning_on_actor_change
    @equip_learning.actor = @actor
    @equip_learning.equip = nil
  end
  
  #--------------------------------------------------------------------------
  # new method: command_learning
  #--------------------------------------------------------------------------
  def command_learning
    if !@equip_learning.visible
      @equip_learning.show
      @equip_learning_back.show
      @status_window.hide
    else
      @equip_learning.hide
      @equip_learning_back.hide
      @status_window.show
    end
    @command_window.activate
  end
  end
  
end # Scene_Equip

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================