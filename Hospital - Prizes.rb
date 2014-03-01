#==============================================================================
# 
# Å• Yami Engine Symphony - Hospital: Hospital Prizes
# -- Last Updated: 2012.11.13
# -- Level: Easy
# -- Requires: YES - Hospital
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-HospitalPrizes"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.11.13 - Started and Finished Script.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides some hospital prizes for party. Prizes are depended
# on how often party use hospital's service.
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
# Å• Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

#==============================================================================
# Å° Regular Expression
#==============================================================================

module REGEXP
  module HOSPITAL
    PRIZE_MAX = /<(?:PRIZE_MAX|prize max):[ ]*(\d+)>/i
    PRIZE_HP  = /<(?:PRIZE_HP|prize hp):[ ]*(\d+)>/i
    PRIZE_MP  = /<(?:PRIZE_MP|prize mp):[ ]*(\d+)>/i
    PRIZE_STATE  = /<(?:PRIZE_STATE|prize state)[ ]*(\d+):[ ]*(\d+)>/i
    PRIZE_STATES  = /<(?:PRIZE_STATES|prize states):[ ]*(\d+)>/i
  end # HOSPITAL
end # REGEXP

#==============================================================================
# Å° DataManager
#==============================================================================

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias create_game_objects_hospital_prize create_game_objects; end
  def self.create_game_objects
    create_game_objects_hospital_prize
    initialize_hospital_prize
  end
  
  #--------------------------------------------------------------------------
  # new method: initialize_hospital_prize
  #--------------------------------------------------------------------------
  def self.initialize_hospital_prize
    $data_prizes = []
    #---
    groups = [$data_items, $data_weapons, $data_armors]
    groups.each { |group|
      group.each { |obj|
        next if obj.nil?
        obj.initialize_hospital_prize
      }
    }
  end
  
end # DataManager

#==============================================================================
# Å° RPG::BaseItem
#==============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # new method: initialize_hospital_prize
  #--------------------------------------------------------------------------
  def initialize_hospital_prize
    prize = false
    @prize_req = [0,0,0,{},0] # Limit, HP, MP, State, States
    #---
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::HOSPITAL::PRIZE_MAX
        @prize_req[0] = $1.to_i
      when REGEXP::HOSPITAL::PRIZE_HP
        prize = true
        @prize_req[1] = $1.to_i
      when REGEXP::HOSPITAL::PRIZE_MP
        prize = true
        @prize_req[2] = $1.to_i
      when REGEXP::HOSPITAL::PRIZE_STATE
        prize = true
        @prize_req[3][$1.to_i] = $2.to_i
      when REGEXP::HOSPITAL::PRIZE_STATE
        prize = true
        @prize_req[4] = $1.to_i
      end
    }
    #---
    $data_prizes.push(self) if prize
  end
  
  #--------------------------------------------------------------------------
  # new method: prize_total
  #--------------------------------------------------------------------------
  def prize_total
    n = nil
    if @prize_req[1] > 0
      m = $game_party.prize_hp / @prize_req[1]
      n = n.nil? ? m : [m, n].min
    end
    if @prize_req[2] > 0
      m = $game_party.prize_mp / @prize_req[2]
      n = n.nil? ? m : [m, n].min
    end
    if @prize_req[3].size > 0
      @prize_req[3].each { |s, i|
        x = $game_party.prize_state[s]
        x = x.nil? ? 0 : x
        m = x / i
        n = n.nil? ? m : [m, n].min
      }
    end
    if @prize_req[4] > 0
      m = $game_party.prize_states / @prize_req[4]
      n = n.nil? ? m : [m, n].min
    end
    return n.nil? ? 0 : n
  end
  
  #--------------------------------------------------------------------------
  # new method: prize_available
  #--------------------------------------------------------------------------
  def prize_available
    [[prize_total - prize_received, prize_limit - prize_received].min, 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: prize_received
  #--------------------------------------------------------------------------
  def prize_received
    $game_party.prize_received(self)
  end
  
  #--------------------------------------------------------------------------
  # new method: prize_limit
  #--------------------------------------------------------------------------
  def prize_limit
    @prize_req[0] > 0 ? @prize_req[0] : $game_party.max_item_number(self)
  end
  
end # RPG::BaseItem

#==============================================================================
# Å° Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # alias method: hospital_recover
  #--------------------------------------------------------------------------
  alias prize_hospital_recover hospital_recover
  def hospital_recover
    if $game_party.gold >= self.hospital_fee
      storage_hospital
    end
    #---
    prize_hospital_recover
  end
  
  #--------------------------------------------------------------------------
  # new method: storage_hospital
  #--------------------------------------------------------------------------
  def storage_hospital
    shp = [mhp - @hp, 0].max
    smp = [mmp - @mp, 0].max
    #---
    $game_party.storage_hospital(shp, smp, self.hospitalize_states)
  end
  
end # Game_Actor

#==============================================================================
# Å° Game_Party
#==============================================================================

class Game_Party < Game_Unit
  
  #--------------------------------------------------------------------------
  # Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :prize_hp
  attr_reader   :prize_mp
  attr_reader   :prize_state
  attr_reader   :prize_states
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias hospital_prize_initialize initialize
  def initialize
    hospital_prize_initialize
    #---
    @prize_hp = 0
    @prize_mp = 0
    @prize_state = {}
    @prize_states = 0
    #---
    @prize_receieved = {}
    @prize_receieved[:item] = {}
    @prize_receieved[:weapon] = {}
    @prize_receieved[:armor] = {}
  end
  
  #--------------------------------------------------------------------------
  # new method: storage_hospital
  #--------------------------------------------------------------------------
  def storage_hospital(hp, mp, states)
    @prize_hp += hp
    @prize_mp += mp
    #---
    states.each { |state| 
      @prize_state[state.id] ||= 0
      @prize_state[state.id] += 1 
    }
    #---
    @prize_states += states.size
  end
  
  #--------------------------------------------------------------------------
  # new method: prize_received
  #--------------------------------------------------------------------------
  def prize_received(item)
    return 0 unless item
    if item.is_a?(RPG::Item)
      r = @prize_receieved[:item][item.id]
    elsif item.is_a?(RPG::Weapon)
      r = @prize_receieved[:weapon][item.id]
    elsif item.is_a?(RPG::Armor)
      r = @prize_receieved[:armor][item.id]
    else; return 0; end
    return r.nil? ? 0 : r
  end
    
  #--------------------------------------------------------------------------
  # new method: claim_prize
  #--------------------------------------------------------------------------
  def claim_prize(item)
    if item.nil?
      Sound.play_buzzer
      return
    end
    if item_number(item) < max_item_number(item)
      amount = [max_item_number(item) - item_number(item), item.prize_available].min
      gain_item(item, amount)
      if item.is_a?(RPG::Item)
        @prize_receieved[:item][item.id] ||= 0
        @prize_receieved[:item][item.id] += amount
      elsif item.is_a?(RPG::Weapon)
        @prize_receieved[:weapon][item.id] ||= 0
        @prize_receieved[:weapon][item.id] += amount
      elsif item.is_a?(RPG::Armor)
        @prize_receieved[:armor][item.id] ||= 0
        @prize_receieved[:armor][item.id] += amount
      else; return; end
    else
      Sound.play_buzzer
    end
  end
  
end # Game_Party

#==============================================================================
# Å° Window_HospitalPrizes
#==============================================================================

class Window_HospitalPrizes < Window_Selectable
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, Graphics.width, height)
    refresh
    self.hide
  end
  
  #--------------------------------------------------------------------------
  # init_data
  #--------------------------------------------------------------------------
  def init_data
    @data = $data_prizes.select { |p| p.prize_available > 0 }
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    init_data
    super
  end
  
  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  
  #--------------------------------------------------------------------------
  # item_max
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 0
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y)
      draw_item_number(rect, item)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_item_number
  #--------------------------------------------------------------------------
  def draw_item_number(rect, item)
    draw_text(rect, sprintf("x%2d", item.prize_available), 2)
  end
    
  #--------------------------------------------------------------------------
  # activate
  #--------------------------------------------------------------------------
  def activate
    self.index = 0 if self.index < 0
    return super
  end
  
  #--------------------------------------------------------------------------
  # item
  #--------------------------------------------------------------------------
  def item
    @data[index]
  end
  
end # Window_HospitalPrizes

#==============================================================================
# Å° Scene_Hospital
#==============================================================================

class Scene_Hospital < Scene_MenuBase
  
  #--------------------------------------------------------------------------
  # alias method: start
  #--------------------------------------------------------------------------
  alias prize_start start
  def start
    prize_start
    create_prize_windows
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_command_window
  #--------------------------------------------------------------------------
  alias prize_create_command_window create_command_window
  def create_command_window
    prize_create_command_window
    @command_window.set_handler(:prize,    method(:command_prize))
  end
  
  #--------------------------------------------------------------------------
  # new method: create_prize_windows
  #--------------------------------------------------------------------------
  def create_prize_windows
    @prize_help_window = Window_Help.new
    @prize_help_window.hide
    @prize_help_window.y = Graphics.height - @prize_help_window.height
    #---
    wy = @command_window.height
    wh = Graphics.height - @gold_window.height - @command_window.height
    @prize_window = Window_HospitalPrizes.new(0, wy, wh)
    @prize_window.set_handler(:ok,            method(:prize_ok))
    @prize_window.set_handler(:cancel,    method(:prize_cancel))
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias prize_udpate update
  def update
    prize_udpate
    #---
    if @command_window.active
      if @command_window.current_symbol == :prize
        @actors_window.hide
        @prize_window.show
      else
        @prize_window.hide
        @actors_window.show
      end
    end
    #---
    if @prize_window.active
      @prize_help_window.set_item(@prize_window.item)
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: command_heal_all
  #--------------------------------------------------------------------------
  alias prize_command_heal_all command_heal_all
  def command_heal_all
    prize_command_heal_all
    @prize_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # alias method: actor_ok
  #--------------------------------------------------------------------------
  alias prize_actor_ok actor_ok
  def actor_ok
    prize_actor_ok
    @prize_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # new method: command_prize
  #--------------------------------------------------------------------------
  def command_prize
    @prize_window.height = Graphics.height - @prize_help_window.height - @command_window.height
    @prize_window.refresh
    @prize_window.show.activate
    @prize_help_window.show
    @help_window.hide
    @gold_window.hide
  end
  
  #--------------------------------------------------------------------------
  # new method: prize_ok
  #--------------------------------------------------------------------------
  def prize_ok
    $game_party.claim_prize(@prize_window.item)
    @prize_window.activate.refresh
  end
  
  #--------------------------------------------------------------------------
  # new method: prize_cancel
  #--------------------------------------------------------------------------
  def prize_cancel
    @prize_window.height = Graphics.height - @gold_window.height - @command_window.height
    @prize_window.deactivate
    @command_window.activate
    @prize_help_window.hide
    @help_window.show
    @gold_window.show
  end
    
end # Scene_Hospital

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================