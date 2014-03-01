#==============================================================================
# 
# Å• Yami Engine Symphony - Skill Shop
# -- Last Updated: 2012.12.19
# -- Level: Easy
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-SkillShop"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.12.19 - Finished Script.
# 2012.12.18 - Started Script.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides a skills shop where player can buys skill from.
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
# <buy gold cost: x>
# Set gold cost for skill to x.
#
# <buy custom text>
# string: String
# icon: Icon ID
# color: Color ID
# </buy custom text>
# Add more require text for skill.
#
# <buy custom require>
# string
# string
# </buy custom require>
# Add requirement for skill by eval. To separate code line, use !break.
# Those code lines are evaled inside Game_Actor.
#
# <buy custom cost>
# string
# string
# </buy custom cost>
# Perform those string by eval when buy skill, use for custom costs. To separate
# code line, use !break.
# Those code lines are evaled inside Game_Actor.
#
# -----------------------------------------------------------------------------
# Script Calls - These commands are used with script calls.
# -----------------------------------------------------------------------------
# YES.skill_shop(shop_id)
# Call Scene Skills Shop with Shop ID defined in Configuration.
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
  module SKILL_SHOP
    
    #===========================================================================
    # - Basic Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # The following below will adjust the basic options for skill shop.
    #===========================================================================
    DEFAULT_GOLD  = 100   # Default Gold cost for each skill.
    # Below option setups skills shop.
    SHOP_SETUP = { # Start.
      # Shop ID =>  [Skill IDs]
      1 =>  [51..56],
      2 =>  [85, 88, 89],
    } # End.
    
    #===========================================================================
    # - Visual Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # The following below will adjust the visual options for skill shop.
    #===========================================================================
    BUY_COST      = "Gold Cost"     # Title for buying gold cost.
    BUY_REQUIRE   = "Require"       # Title for buying requirement.
    
  end
end

#==============================================================================
# Å• Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

#==============================================================================
# Å° Module Yami Engine Symphony
#==============================================================================

module YES
  
  #--------------------------------------------------------------------------
  # skill_shop
  #--------------------------------------------------------------------------
  def self.skill_shop(shop_id)
    return unless SKILL_SHOP::SHOP_SETUP.has_key?(shop_id)
    SceneManager.call(Scene_SkillShop)
    SceneManager.scene.prepare(shop_id)
  end

  module SKILL_SHOP
        
    #--------------------------------------------------------------------------
    # convert_integer_array
    #--------------------------------------------------------------------------
    def self.convert_integer_array(array)
      result = []
      array.each { |i|
        case i
        when Range; result |= i.to_a
        when Integer; result |= [i]
        end }
      return result
    end
    
    #--------------------------------------------------------------------------
    # convert_full_hash
    #--------------------------------------------------------------------------
    def self.convert_full_hash(hash)
      result = {}
      hash.each { |key| result[key[0]] = convert_integer_array(key[1]) }
      return result
    end
    
    #--------------------------------------------------------------------------
    # converted_contants
    #--------------------------------------------------------------------------
    SHOP_SETUP = convert_full_hash(SHOP_SETUP)
    
  end
end # YES

#==============================================================================
# Å° Cache
#==============================================================================

module Cache
  
  #--------------------------------------------------------------------------
  # new method: storage_mface
  #--------------------------------------------------------------------------
  def self.storage_mface(bitmap, name)
    @mface_cache ||= {}
    @mface_cache[name] = bitmap unless @mface_cache.has_key?(name)
    @mface_cache[name]
  end
  
  #--------------------------------------------------------------------------
  # new method: restore_mface
  #--------------------------------------------------------------------------
  def self.restore_mface(name)
    return false if @mface_cache.nil? || !@mface_cache.has_key?(name)
    @mface_cache[name]
  end
  
  #--------------------------------------------------------------------------
  # new method: clear_mface
  #--------------------------------------------------------------------------
  def self.clear_mface
    @mface_cache ||= {}
    @mface_cache.each_value { |b| b.dispose unless b.disposed? }
    @mface_cache.clear
  end
  
end

#==============================================================================
# Å° Regular Expression
#==============================================================================

module REGEXP
  module SKILL_SHOP
    GOLD_COST = /<(?:BUY_GOLD_COST|buy gold cost):[ ]*(\d+)>/i
    
    CUSTOM_STRING_ON = /<(?:BUY_CUSTOM_TEXT|buy custom text)>/i
    CUSTOM_STRING_OFF = /<\/(?:BUY_CUSTOM_TEXT|buy custom text)>/i
    CUSTOM_STRING = /[ ]*(.*):[ ](.*)/i
    
    CUSTOM_REQUIRE_ON = /<(?:BUY_CUSTOM_REQUIRE|buy custom require)>/i
    CUSTOM_REQUIRE_OFF = /<\/(?:BUY_CUSTOM_REQUIRE|buy custom require)>/i
    
    CUSTOM_COST_ON = /<(?:BUY_CUSTOM_COST|buy custom cost)>/i
    CUSTOM_COST_OFF = /<\/(?:BUY_CUSTOM_COST|buy custom cost)>/i
  end # SKILL_SHOP
end # REGEXP

#==============================================================================
# Å° DataManager
#==============================================================================

module DataManager
    
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_skill_shop load_database; end
  def self.load_database
    load_database_skill_shop
    initialize_skill_shop
  end
  
  #--------------------------------------------------------------------------
  # new method: initialize_skill_shop
  #--------------------------------------------------------------------------
  def self.initialize_skill_shop
    Cache.clear_mface
    groups = [$data_skills]
    groups.each { |group|
      group.each { |obj|
        next if obj.nil?
        obj.initialize_skill_shop
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
  attr_accessor :buyskill_gold_cost
  attr_accessor :buyskill_custom_string
  attr_accessor :buyskill_custom_require
  attr_accessor :buyskill_custom_cost

  #--------------------------------------------------------------------------
  # new method: initialize_skill_shop
  #--------------------------------------------------------------------------
  def initialize_skill_shop
    @buyskill_gold_cost = YES::SKILL_SHOP::DEFAULT_GOLD
    @buyskill_custom_string = []
    @buyskill_custom_require = "true"
    @buyskill_custom_cost = ""
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::SKILL_SHOP::GOLD_COST
        @buyskill_gold_cost = $1.to_i
      when REGEXP::SKILL_SHOP::CUSTOM_STRING_ON
        @buyskill_custom_string_on = true
        @buyskill_string_dummy = ["", 0, 0]
      when REGEXP::SKILL_SHOP::CUSTOM_STRING_OFF
        @buyskill_custom_string_on = false
        @buyskill_custom_string.push(@buyskill_string_dummy)
      when REGEXP::SKILL_SHOP::CUSTOM_REQUIRE_ON
        @buyskill_custom_require_on = true
        @buyskill_custom_require = ""
      when REGEXP::SKILL_SHOP::CUSTOM_REQUIRE_OFF
        @buyskill_custom_require_on = false
      when REGEXP::SKILL_SHOP::CUSTOM_COST_ON
        @buyskill_custom_cost_on = true
      when REGEXP::SKILL_SHOP::CUSTOM_COST_OFF
        @buyskill_custom_cost_on = false
      else
        case line
        when REGEXP::SKILL_SHOP::CUSTOM_STRING
          action = $1; value = $2
          if @buyskill_custom_require_on
            @buyskill_custom_require += line
          elsif @buyskill_custom_cost_on
            @buyskill_custom_cost += line
          elsif @buyskill_custom_string_on
            case action.downcase
            when "string"
              @buyskill_string_dummy[0] = $2
            when "icon"
              @buyskill_string_dummy[1] = $2.to_i
            when "color"
              @buyskill_string_dummy[2] = $2.to_i
            end
          end
        else
          if @buyskill_custom_require_on
            if line =~ /!break/i
              @buyskill_custom_require += "\n"
            else
              @buyskill_custom_require += line
            end
          elsif @buyskill_custom_cost_on
            if line =~ /!break/i
              @buyskill_custom_cost += "\n"
            else
              @buyskill_custom_cost += line
            end
          end
        end
      end
    }
  end
  
end # RPG::BaseItem

#==============================================================================
# Å° Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # buy_skill?
  #--------------------------------------------------------------------------
  def buy_skill?(skill_id)
    skill = $data_skills[skill_id]
    return false unless skill
    custom_match = true
    skill.buyskill_custom_require.each_line { |e|
      custom_match = custom_match && eval(e)
    }
    return true if custom_match
    return false
  end
  
  #--------------------------------------------------------------------------
  # buy_skill
  #--------------------------------------------------------------------------
  def buy_skill(skill_id)
    skill = $data_skills[skill_id]
    return unless skill
    return unless $game_party.gold >= skill.buyskill_gold_cost
    return unless buy_skill?(skill_id)
    return if self.skill_learn?(skill)
    $game_party.lose_gold(skill.buyskill_gold_cost)
    eval(skill.buyskill_custom_cost)
    learn_skill(skill_id)
  end
  
end # Game_Actor

#==============================================================================
# Å° Window_SkillShopCommand
#==============================================================================

class Window_SkillShopCommand < Window_Command
  
  #--------------------------------------------------------------------------
  # visible_line_number
  #--------------------------------------------------------------------------
  def visible_line_number
    4
  end
  
  #--------------------------------------------------------------------------
  # make_command_list
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::ShopBuy, :buy)
    add_command(Vocab::ShopCancel, :exit)
  end
  
  #--------------------------------------------------------------------------
  # alignment
  #--------------------------------------------------------------------------
  def alignment
    1
  end
  
end # Window_SkillShopCommand

#==============================================================================
# Å° Window_SkillShop
#==============================================================================

class Window_SkillShop < Window_Selectable
    
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, Graphics.width / 2, height)
    self.index = 0
  end
  
  #--------------------------------------------------------------------------
  # shop_id
  #--------------------------------------------------------------------------
  def shop_id=(id)
    @data = YES::SKILL_SHOP::SHOP_SETUP[id]
    update_padding
    create_contents
    refresh
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
    @data && enable?(self.index)
  end
  
  #--------------------------------------------------------------------------
  # enable?
  #--------------------------------------------------------------------------
  def enable?(index)
    skill_id = @data[index]
    skill = $data_skills[skill_id]
    return $game_party.gold >= skill.buyskill_gold_cost
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill_id = @data[index]
    #---
    return if skill_id.nil?
    reset_font_settings
    draw_item_name(index, skill_id, enable?(index)) if skill_id > 0
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
    return unless @data
    id = @data[index]
    item = id.nil? ? nil : $data_skills[id]
    @properties_window.set_item(item)
  end
  
  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_help
    id = @data[index]
    item = id.nil? ? nil : $data_skills[id]
    @help_window.set_item(item)
    @properties_window.set_item(item) if @properties_window
  end
  
  #--------------------------------------------------------------------------
  # item
  #--------------------------------------------------------------------------
  def item
    id = @data[index]
    return id.nil? ? nil : $data_skills[id]
  end
  
end # Window_SkillShop

#==============================================================================
# Å° Window_SkillShopActors
#==============================================================================

class Window_SkillShopActors < Window_Selectable
    
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, Graphics.width / 2, height)
    self.index = 0
    self.hide
  end
  
  #--------------------------------------------------------------------------
  # skill_id
  #--------------------------------------------------------------------------
  def skill_id=(id)
    @skill_id = id
    update_padding
    create_contents
    refresh
  end
  
  #--------------------------------------------------------------------------
  # item_max
  #--------------------------------------------------------------------------
  def item_max
    $game_party.members.size
  end
  
  #--------------------------------------------------------------------------
  # current_item_enabled?
  #--------------------------------------------------------------------------
  def current_item_enabled?
    @skill_id && enable?(self.index)
  end
  
  #--------------------------------------------------------------------------
  # enable?
  #--------------------------------------------------------------------------
  def enable?(index)
    skill = $data_skills[@skill_id]
    return false if $game_party.members[index].skill_learn?(skill)
    return $game_party.members[index].buy_skill?(@skill_id)
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.members[index]
    rect = item_rect(index)
    face_rect = Rect.new(rect.x + 1, rect.y + 1, item_height - 2, item_height - 2)
    reset_font_settings
    draw_thumb_face(actor, face_rect)
    draw_actor_name(actor, rect.x, rect.y, rect.width)
  end
  
  #--------------------------------------------------------------------------
  # draw_thumb_face
  #--------------------------------------------------------------------------
  def draw_thumb_face(actor, dest_rect)
    cache = Cache.restore_mface(actor.face_name + actor.face_index.to_s)
    if !cache
      bitmap = Cache.face(actor.face_name)
      rect = Rect.new(actor.face_index % 4 * 96, actor.face_index / 4 * 96, 96, 96)
      bitmap.blur
      cache = Bitmap.new(dest_rect.width, dest_rect.height)
      cache.stretch_blt(Rect.new(0,0,dest_rect.width, dest_rect.height), bitmap, rect) 
      Cache.storage_mface(cache, actor.face_name + actor.face_index.to_s)
      bitmap.dispose
    end
    contents.stretch_blt(dest_rect, cache, cache.rect) 
  end
    
  #--------------------------------------------------------------------------
  # draw_actor_name
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, dx, dy, dw)
    change_color(normal_color, enable?(actor.index))
    draw_text(dx + item_height + 2, dy, dw, line_height, actor.name)
  end
  
  #--------------------------------------------------------------------------
  # actor
  #--------------------------------------------------------------------------
  def actor
    $game_party.members[self.index]
  end
  
  #--------------------------------------------------------------------------
  # status_window=
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    @status_window.actor = self.actor
  end
  
  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_status
    @status_window.actor = self.actor
  end
  
  #--------------------------------------------------------------------------
  # call_update_help
  #--------------------------------------------------------------------------
  def call_update_help
    super
    update_status if active && @status_window
  end
  
end # Window_SkillShopActors

#==============================================================================
# Å° Window_SkillShop_Properties
#==============================================================================

class Window_SkillShop_Properties < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item = nil
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return if @item.nil?
    reset_font_settings
    rect = Rect.new(0, line_height, contents.width, line_height)
    #---
    draw_item_name(@item, 0, 0)
    draw_item_gold(@item, rect)
    @item.buyskill_custom_string.each { |hash|
      rect.y += line_height
      draw_custom_require(rect, hash)
    }
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
  # draw_item_gold
  #--------------------------------------------------------------------------
  def draw_item_gold(item, rect)
    change_color(system_color)
    text = YES::SKILL_SHOP::BUY_COST
    draw_text(rect, text, 0)
    draw_currency_value(item.buyskill_gold_cost, Vocab.currency_unit, rect.x, rect.y, rect.width)
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_custom_require
  #--------------------------------------------------------------------------
  def draw_custom_require(rect, hash)
    return unless hash
    change_color(system_color)
    text = YES::SKILL_SHOP::BUY_REQUIRE
    draw_text(rect, text, 0)
    change_color(text_color(hash[2]))
    icon = hash[1]
    if icon > 0
      draw_icon(icon, rect.x + rect.width-24, rect.y)
      rect.width -= 24
    end
    text = hash[0]
    draw_text(rect, text, 2)
    rect.width += 24 if icon > 0
    reset_font_settings
  end
  
end # Window_SkillShop_Properties

#==============================================================================
# Å° Window_SkillShopGold
#==============================================================================

class Window_SkillShopGold < Window_Gold
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2
  end
  
end # Window_SkillShopGold

#==============================================================================
# Å° Scene_SkillShop
#==============================================================================

class Scene_SkillShop < Scene_MenuBase
  
  #--------------------------------------------------------------------------
  # prepare
  #--------------------------------------------------------------------------
  def prepare(shop_id)
    @shop_id = shop_id
  end
  
  #--------------------------------------------------------------------------
  # start
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_command_window
    create_status_window
    create_skill_window
    create_actors_window
    create_gold_window
    create_properties_window
  end
  
  #--------------------------------------------------------------------------
  # create_help_window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new
    @help_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # create_command_window
  #--------------------------------------------------------------------------
  def create_command_window
    wx = 0
    wy = @help_window.height
    @command_window = Window_SkillShopCommand.new(wx, wy)
    @command_window.set_handler(:buy,         method(:command_buy) )
    @command_window.set_handler(:exit,        method(:return_scene))
    @command_window.set_handler(:cancel,      method(:return_scene)) 
    @command_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # create_status_window
  #--------------------------------------------------------------------------
  def create_status_window
    wx = @command_window.width
    wy = @help_window.height
    @status_window = Window_SkillStatus.new(wx, wy)
    @status_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # create_skill_window
  #--------------------------------------------------------------------------
  def create_skill_window
    wx = 0
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @skills_window = Window_SkillShop.new(wx, wy, wh)
    @skills_window.set_handler(:ok,          method(:skill_ok)    ) 
    @skills_window.set_handler(:cancel,      method(:skill_cancel)) 
    @skills_window.viewport = @viewport
    @skills_window.help_window = @help_window
    @skills_window.shop_id = @shop_id
  end
  
  #--------------------------------------------------------------------------
  # create_actors_window
  #--------------------------------------------------------------------------
  def create_actors_window
    wx = 0
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @actors_window = Window_SkillShopActors.new(wx, wy, wh)
    @actors_window.set_handler(:ok,          method(:actor_ok)    ) 
    @actors_window.set_handler(:cancel,      method(:actor_cancel)) 
    @actors_window.status_window = @status_window
    @actors_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # create_gold_window
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_SkillShopGold.new
    @gold_window.x = @skills_window.width
    @gold_window.y = @command_window.y + @command_window.height
    @gold_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # create_properties_window
  #--------------------------------------------------------------------------
  def create_properties_window
    wx = @skills_window.width
    wy = @gold_window.y + @gold_window.height
    ww = Graphics.width - wx
    wh = Graphics.height - wy
    @properties_window = Window_SkillShop_Properties.new(wx, wy, ww, wh)
    @properties_window.viewport = @viewport
    @skills_window.properties_window = @properties_window
  end
  
  #--------------------------------------------------------------------------
  # command_buy
  #--------------------------------------------------------------------------
  def command_buy
    @skills_window.activate
  end
  
  #--------------------------------------------------------------------------
  # skill_ok
  #--------------------------------------------------------------------------
  def skill_ok
    @skills_window.hide
    @actors_window.skill_id = @skills_window.item.id if @skills_window.item
    @actors_window.show.activate
  end
  
  #--------------------------------------------------------------------------
  # skill_cancel
  #--------------------------------------------------------------------------
  def skill_cancel
    @command_window.activate
  end
  
  #--------------------------------------------------------------------------
  # actor_ok
  #--------------------------------------------------------------------------
  def actor_ok
    @actors_window.actor.buy_skill(@skills_window.item.id)
    @skills_window.show.activate
    @actors_window.hide
    @gold_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # actor_cancel
  #--------------------------------------------------------------------------
  def actor_cancel
    @skills_window.show.activate
    @actors_window.hide
  end
      
end # Scene_SkillShop

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================