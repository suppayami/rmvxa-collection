#==============================================================================
# 
# Å• Yami Engine Symphony - Hospital
# -- Last Updated: 2013.05.15
# -- Level: Easy
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-Hospital"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2013.05.15 - Fixed States Cost.
# 2013.05.09 - Fixed Gold Window.
#            - Fixed Heal All price.
# 2012.11.13 - Compatible with Hospital Prizes.
# 2012.11.10 - Started and Finished Script.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides a hospital scene, where you have to pay money for 
# healing and recovering.
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
  module HOSPITAL
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Price Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # These settings are adjusted for the prices of recovering in hospital.
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    HP_COST = 5       # Gold cost for each HP lost.
    MP_COST = 10      # Gold cost for each MP lost.
    STATE_COST = 100  # Default cost for each Removed State.
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Visual Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # These settings are adjusted for the visual and text of Hospital Scene.
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    NURSE_FACE = ["People2", 1]   # Setting for nurse face.
                                  # ["FaceSet", Index]
    NURSE_MESSAGE = [ # Setting for nurse greeting message.
      # "Message",
      "\\C[17]Nurse\\C[0]\nHello,\nHow can I help you?", # Message 1
      "\\C[17]Nurse\\C[0]\nGood Morning, \nDo you need something?", # Message 2
      "\\C[17]Nurse\\C[0]\nOhai, \nWelcome to Hospital!", # Message 3
    ] # End Message.
    HELP_MESSAGE = { # Setting for texts in Help Window.
      # Commands help.
      :heal_one         => "Heals members individually.",
      :heal_all_treat   => "Heals all members at cost %d\\C[1]G.",
      :heal_all_healthy => "All members are healthy.",
      :prize            => "Claim your prizes.",
      :exit             => "Go out.",
      # Choose Actor help. 
      :actor_treat      => "%s needs treatment.",
      :actor_healthy    => "%s is healthy.",
    } # End Help.
    COMMAND_TEXT = { # Setting for commands text.
      :heal_one => "Heal One",
      :heal_all => "Heal All",
      :prize    => "Prize",
      :exit     => "Exit",
    } # End Commands Text.
    COMMAND_ARRAY = [ # Setting for Commands.
      :heal_one,
      :heal_all,
      :prize,
      :exit,
    ] # End Commands
    
  end # HOSPITAL
end # YES

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
  # self.hospital
  #--------------------------------------------------------------------------
  def self.hospital
    SceneManager.call(Scene_Hospital)
  end
  
end # YES

#==============================================================================
# Å° Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # hospital_fee
  #--------------------------------------------------------------------------
  def hospital_fee
    lost_hp = mhp - @hp
    lost_mp = mmp - @mp
    #---
    fee = lost_hp * hp_fee_rate
    fee += lost_mp * mp_fee_rate
    self.hospitalize_states.inject(fee) { |f, s| f += state_fee_rate(s.id) }
  end
  
  #--------------------------------------------------------------------------
  # hp_fee_rate
  #--------------------------------------------------------------------------
  def hp_fee_rate
    YES::HOSPITAL::HP_COST
  end
  
  #--------------------------------------------------------------------------
  # mp_fee_rate
  #--------------------------------------------------------------------------
  def mp_fee_rate
    YES::HOSPITAL::MP_COST
  end
  
  #--------------------------------------------------------------------------
  # state_fee_rate
  #--------------------------------------------------------------------------
  def state_fee_rate(state_id)
    YES::HOSPITAL::STATE_COST
  end
  
  #--------------------------------------------------------------------------
  # hospitalize_states
  #--------------------------------------------------------------------------
  def hospitalize_states
    self.states
  end
  
  #--------------------------------------------------------------------------
  # hospital_recover
  #--------------------------------------------------------------------------
  def hospital_recover
    if $game_party.gold >= self.hospital_fee
      Sound.play_recovery
      $game_party.lose_gold(self.hospital_fee)
      #---
      @hp = mhp
      @mp = mmp
      self.hospitalize_states.each { |s| remove_state(s.id) }
    else
      Sound.play_buzzer
    end
  end
  
  #--------------------------------------------------------------------------
  # hospital_need
  #--------------------------------------------------------------------------
  def hospital_need
    @hp < mhp || @mp < mmp || self.hospitalize_states.size > 0
  end
  
end # Game_Actor

#==============================================================================
# Å° Game_Party
#==============================================================================

class Game_Party < Game_Unit
  
  #--------------------------------------------------------------------------
  # hospital_fee
  #--------------------------------------------------------------------------
  def hospital_fee
    self.members.inject(0) { |f, m| f += m.hospital_fee }
  end
  
  #--------------------------------------------------------------------------
  # hospital_recover
  #--------------------------------------------------------------------------
  def hospital_recover
    if hospital_available
      Sound.play_recovery
      #$game_party.lose_gold(self.hospital_fee)
      self.members.each { |m| m.hospital_recover }
    else
      Sound.play_buzzer
    end
  end
  
  #--------------------------------------------------------------------------
  # hospital_need
  #--------------------------------------------------------------------------
  def hospital_need
    self.members.any? { |m| m.hospital_need }
  end
  
  #--------------------------------------------------------------------------
  # hospital_available
  #--------------------------------------------------------------------------
  def hospital_available
    self.hospital_need && $game_party.gold >= hospital_fee
  end
  
end # Game_Party

#==============================================================================
# Å° Window_HospitalCommand
#==============================================================================

class Window_HospitalCommand < Window_Command
  
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
    YES::HOSPITAL::COMMAND_ARRAY.each { |command|
      enable = command == :heal_all ? $game_party.hospital_available : true
      add_command(YES::HOSPITAL::COMMAND_TEXT[command], command, enable)
    }
  end
  
  #--------------------------------------------------------------------------
  # alignment
  #--------------------------------------------------------------------------
  def alignment
    1
  end
  
end # Window_HospitalCommand

#==============================================================================
# Å° Window_HospitalHelp
#==============================================================================

class Window_HospitalHelp < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    super(x, y, width, fitting_height(1))
    @text = ""
  end
  
  #--------------------------------------------------------------------------
  # set_text
  #--------------------------------------------------------------------------
  def set_text(text)
    if text != @text
      @text = text
      refresh
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_text_ex(4, 0, @text)
  end
  
end # Window_HospitalHelp

#==============================================================================
# Å° Window_HospitalNurse
#==============================================================================

class Window_HospitalNurse < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    super(x, y, width, fitting_height(4))
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    #--- Draw Nurse Face ---
    face_setting = YES::HOSPITAL::NURSE_FACE
    draw_face(face_setting[0], face_setting[1], 0, 0)
    #--- Draw Nurse Message ---
    text = YES::HOSPITAL::NURSE_MESSAGE.sample
    draw_text_ex(100, 0, text)
  end
  
end # Window_HospitalNurse

#==============================================================================
# Å° Window_HospitalActors
#==============================================================================

class Window_HospitalActors < Window_Selectable
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, Graphics.width, height)
    @last_index = 0
    refresh
  end
  
  #--------------------------------------------------------------------------
  # item_max
  #--------------------------------------------------------------------------
  def item_max
    $game_party.members.size
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.members[index]
    rect = item_rect(index)
    #---
    draw_actor_name(actor, rect.x + 4, rect.y)
    draw_actor_icons(actor, rect.x + 120, rect.y, 72)
    #---
    gauge_width = contents.width - 332
    draw_actor_hp(actor, rect.x + 196, rect.y, gauge_width / 2 - 2)
    draw_actor_mp(actor, rect.x + 200 + gauge_width / 2, rect.y, gauge_width / 2 - 2)
    #---
    draw_actor_hospital(actor, contents.width - 136, rect.y, 136)
  end
  
  #--------------------------------------------------------------------------
  # draw_actor_hospital
  #--------------------------------------------------------------------------
  def draw_actor_hospital(actor, x, y, width)
    draw_currency_value(actor.hospital_fee, Vocab::currency_unit, x, y, width)
  end
  
  #--------------------------------------------------------------------------
  # deactivate
  #--------------------------------------------------------------------------
  def deactivate
    @last_index = @index
    self.index = -1
    return super
  end
  
  #--------------------------------------------------------------------------
  # activate
  #--------------------------------------------------------------------------
  def activate
    self.index = @last_index
    return super
  end
  
  #--------------------------------------------------------------------------
  # actor
  #--------------------------------------------------------------------------
  def actor
    $game_party.members[index]
  end
  
end # Window_HospitalActors

#==============================================================================
# Å° Scene_Hospital
#==============================================================================

class Scene_Hospital < Scene_MenuBase
  
  #--------------------------------------------------------------------------
  # start
  #--------------------------------------------------------------------------
  def start
    super
    create_gold_window
    create_help_window
    create_command_window
    create_nurse_window
    create_actors_window
    initialize_windows
  end
  
  #--------------------------------------------------------------------------
  # create_gold_window
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = Graphics.height - @gold_window.height
  end
  
  #--------------------------------------------------------------------------
  # create_help_window
  #--------------------------------------------------------------------------
  def create_help_window
    ww = Graphics.width - @gold_window.width
    @help_window = Window_HospitalHelp.new(0, @gold_window.y, ww)
  end
  
  #--------------------------------------------------------------------------
  # create_command_window
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_HospitalCommand.new(0, 0)
    @command_window.set_handler(:heal_one,    method(:command_heal_one))
    @command_window.set_handler(:heal_all,    method(:command_heal_all))
    @command_window.set_handler(:exit,        method(:return_scene)    )
    @command_window.set_handler(:cancel,      method(:return_scene)    ) 
  end
  
  #--------------------------------------------------------------------------
  # create_nurse_window
  #--------------------------------------------------------------------------
  def create_nurse_window
    wx = @command_window.width
    ww = Graphics.width - @command_window.width
    @nurse_window = Window_HospitalNurse.new(wx, 0, ww)
  end
  
  #--------------------------------------------------------------------------
  # create_actors_window
  #--------------------------------------------------------------------------
  def create_actors_window
    wy = @command_window.height
    wh = Graphics.height - @gold_window.height - @command_window.height
    @actors_window = Window_HospitalActors.new(0, wy, wh)
    @actors_window.set_handler(:ok,          method(:actor_ok)    ) 
    @actors_window.set_handler(:cancel,      method(:actor_cancel)) 
  end
  
  #--------------------------------------------------------------------------
  # initialize_windows
  #--------------------------------------------------------------------------
  def initialize_windows
    text = YES::HOSPITAL::HELP_MESSAGE[@command_window.current_symbol] rescue ""
    if @command_window.current_symbol == :heal_all
      symbol = @command_window.current_symbol.to_s
      symbol += $game_party.hospital_need ? "_treat" : "_healthy"
      symbol = symbol.to_sym
      text = YES::HOSPITAL::HELP_MESSAGE[symbol] rescue ""
      if $game_party.hospital_need
        text = sprintf(text, $game_party.hospital_fee)
      end
    end
    @help_window.set_text(text)
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    if @command_window.active
      text = YES::HOSPITAL::HELP_MESSAGE[@command_window.current_symbol] rescue ""
      if @command_window.current_symbol == :heal_all
        symbol = @command_window.current_symbol.to_s
        symbol += $game_party.hospital_need ? "_treat" : "_healthy"
        symbol = symbol.to_sym
        text = YES::HOSPITAL::HELP_MESSAGE[symbol] rescue ""
        if $game_party.hospital_need
          text = sprintf(text, $game_party.hospital_fee)
        end
      end
      @help_window.set_text(text)
    elsif @actors_window.active
      if @actors_window.actor.hospital_need
        text = YES::HOSPITAL::HELP_MESSAGE[:actor_treat]
      else
        text = YES::HOSPITAL::HELP_MESSAGE[:actor_healthy]
      end
      text = sprintf(text, @actors_window.actor.name)
      @help_window.set_text(text)
    end
  end
  
  #--------------------------------------------------------------------------
  # command_heal_one
  #--------------------------------------------------------------------------
  def command_heal_one
    @actors_window.activate
  end
  
  #--------------------------------------------------------------------------
  # command_heal_one
  #--------------------------------------------------------------------------
  def command_heal_all
    $game_party.hospital_recover
    @command_window.refresh
    @command_window.activate
    @actors_window.refresh
    @gold_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # actor_ok
  #--------------------------------------------------------------------------
  def actor_ok
    @actors_window.activate
    #---
    actor = @actors_window.actor
    #---
    actor.hospital_recover
    @actors_window.redraw_current_item
    @command_window.refresh
    @gold_window.refresh
  end 
  
  #--------------------------------------------------------------------------
  # actor_cancel
  #--------------------------------------------------------------------------
  def actor_cancel
    @actors_window.deactivate
    @command_window.activate
  end 
  
end # Scene_Hospital

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================