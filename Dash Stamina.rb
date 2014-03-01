#==============================================================================
# 
# ▼ Yami Engine Symphony - Dash Stamina
# -- Last Updated: 2013.02.27
# -- Level: Easy
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-DashStamina"] = true

#==============================================================================
# ▼ Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2013.02.27 - Added recover method.
#            - Added rest area feature.
# 2012.11.18 - Fixed Enable Window option.
# 2012.11.17 - Added recovery frames.
#            - Added stamina variable.
#            - Fixed recovery problem when holding Shift.
# 2012.11.15 - Started and Finished Script.
# 
#==============================================================================
# ▼ Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides stamina feature for dashing on map. Dashing will comsume
# stamina and be disable if run our of stamina.
#
#==============================================================================
# ▼ Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
#
# -----------------------------------------------------------------------------
# Script Calls - These commands are used with script calls.
# -----------------------------------------------------------------------------
# YES.recover_stamina
# Fully recover stamina for player.
#
# YES.recover_stamina(X)
# Recover X stamina for player.
#
#==============================================================================
# ▼ Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjustments.
# 
#==============================================================================

#==============================================================================
# ■ Configuration
#==============================================================================

module YES
  module DASH
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - General Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    STAMINA_DEFAULT    = 200    # Default Stamina for player.
    STAMINA_PER_FRAME  = 1      # Default Stamina cost per frame while dashing.
    MOVE_RESTORE       = false  # Set this to false to disable restoring
                                # stamina while moving.
    RECOVER_FRAMES     = 120    # Start recovering after X frames.
    STAMINA_RESTORE    = 5      # Restoring Stamina per X frames.
    RESTORE_AFTER      = 10     # Restore Stamina after X frames.
    REST_AREA_RATE     = 1      # Restore rate when standing on rest area.
                                # Set this to 1 to disable rest area function.
    REST_AREA_REGION   = 19     # Region ID of rest area.
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Switches and Variables Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    STAMINA_VARIABLE   = 10      # Variable to control stamina.
    DISABLE_SWITCH     = 98      # Switch to toggle Stamina Feature.
                                 # Set to true to disable Stamina Feature.
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Windows Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ENABLE_WINDOW      = true   # Toggle stamina window.
    AUTO_HIDE_WINDOW   = true   # Toggle auto-hide function for Stamina Window.
    HIDE_AFTER_FRAMES  = 300    # Hide after X frames if not dashing.
    STAMINA_TEXT       = "Stamina"
    WINDOW_WIDTH       = 180
    BAR_COLORS         = { # Settings for stamina bar colors.
      :color1          => 28,
      :color2          => 29,
    } # Do not remove this.
    
  end # DASH
end # YES

#==============================================================================
# ▼ Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

#==============================================================================
# ■ Module Yami Engine Symphony
#==============================================================================

module YES
  
  #--------------------------------------------------------------------------
  # self.recover_stamina
  #--------------------------------------------------------------------------
  def self.recover_stamina(amount = :full)
    $game_player.recover_stamina(amount)
  end
  
end # YES

#==============================================================================
# ■ Game_Player
#==============================================================================

class Game_Player < Game_Character
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :stamina_backup
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias dash_initialize initialize
  def initialize
    dash_initialize
    #---
    @stamina = YES::DASH::STAMINA_DEFAULT
    $game_variables[YES::DASH::STAMINA_VARIABLE] = YES::DASH::STAMINA_DEFAULT
    #---
    @recover_frames = 0
    @stamina_backup = {}
  end
    
  #--------------------------------------------------------------------------
  # new method: stamina
  #--------------------------------------------------------------------------
  def stamina
    return @stamina
  end
    
  #--------------------------------------------------------------------------
  # new method: stamina_max
  #--------------------------------------------------------------------------
  def stamina_max
    $game_variables[YES::DASH::STAMINA_VARIABLE]
  end
  
  #--------------------------------------------------------------------------
  # new method: stamina_rate
  #--------------------------------------------------------------------------
  def stamina_rate
    stamina.to_f / stamina_max.to_f
  end
  
  #--------------------------------------------------------------------------
  # new method: stamina_cost
  #--------------------------------------------------------------------------
  def stamina_cost
    [YES::DASH::STAMINA_PER_FRAME, @stamina].min
  end
  
  #--------------------------------------------------------------------------
  # new method: recover_stamina
  #--------------------------------------------------------------------------
  def recover_stamina(amount = :full)
    if amount.is_a?(Integer)
      @stamina += amount
      correct_stamina
    else
      @stamina = stamina_max
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias dash_update update
  def update
    dash_update
    update_dash_stamina
    #---
    correct_stamina
    #---
    update_stamina_recover
  end
  
  #--------------------------------------------------------------------------
  # new method: correct_stamina
  #--------------------------------------------------------------------------
  def correct_stamina
    @stamina = stamina_max if @stamina > stamina_max
    @stamina = 0 if @stamina < 0
  end
  
  #--------------------------------------------------------------------------
  # new method: update_dash_stamina
  #--------------------------------------------------------------------------
  def update_dash_stamina
    return unless moving?
    return unless dash?
    @stamina = @stamina - stamina_cost
    @stamina = 0 if @stamina < 0
    @recover_frames = YES::DASH::RECOVER_FRAMES
  end
  
  #--------------------------------------------------------------------------
  # new method: update_stamina_recover
  #--------------------------------------------------------------------------
  def update_stamina_recover
    @recover_frames -= 1
    return if @recover_frames > 0
    return if moving? && YES::DASH::MOVE_RESTORE
    return unless Graphics.frame_count % YES::DASH::RESTORE_AFTER == 0
    return correct_stamina if @stamina >= stamina_max
    @stamina += stamina_recover
    @stamina = stamina_max if @stamina > stamina_max
  end
    
  #--------------------------------------------------------------------------
  # alias method: dash?
  #--------------------------------------------------------------------------
  alias stamina_dash? dash?
  def dash?
    return false if @stamina <= 0 && !$game_switches[YES::DASH::DISABLE_SWITCH]
    return stamina_dash?
  end
  
  #--------------------------------------------------------------------------
  # new method: stamina_recover
  #--------------------------------------------------------------------------
  def stamina_recover
    YES::DASH::STAMINA_RESTORE * rest_area_rate
  end
  
  #--------------------------------------------------------------------------
  # new method: on_rest_area?
  #--------------------------------------------------------------------------
  def on_rest_area?
    region_id == YES::DASH::REST_AREA_REGION
  end
  
  #--------------------------------------------------------------------------
  # new method: rest_area_rate
  #--------------------------------------------------------------------------
  def rest_area_rate
    on_rest_area? ? YES::DASH::REST_AREA_RATE : 1
  end
  
end # Game_Player

#==============================================================================
# ■ Window_Stamina
#==============================================================================

class Window_Stamina < Window_Base

  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    super(24, Graphics.height - 74, YES::DASH::WINDOW_WIDTH, 50)
    @time = YES::DASH::HIDE_AFTER_FRAMES
    refresh
    #---
    $game_player.stamina_backup[:x] ||= self.x
    $game_player.stamina_backup[:time] ||= @time
    self.x = $game_player.stamina_backup[:x]
    @time = $game_player.stamina_backup[:time]
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return if @stamina && @stamina == $game_player.stamina
    contents.clear
    #---
    draw_stamina_bar(0, 0, YES::DASH::WINDOW_WIDTH - 24)
    #---
    @stamina = $game_player.stamina
  end
  
  #--------------------------------------------------------------------------
  # stamina_bar_color1
  #--------------------------------------------------------------------------
  def stamina_bar_color1
    text_color(YES::DASH::BAR_COLORS[:color1])
  end
  
  #--------------------------------------------------------------------------
  # stamina_bar_color2
  #--------------------------------------------------------------------------
  def stamina_bar_color2
    text_color(YES::DASH::BAR_COLORS[:color2])
  end
  
  #--------------------------------------------------------------------------
  # draw_stamina_bar
  #--------------------------------------------------------------------------
  def draw_stamina_bar(x, y, width = 156)
    draw_gauge(x, y, width,$game_player.stamina_rate, stamina_bar_color1, stamina_bar_color2)
    change_color(system_color)
    draw_text(x, y, contents.width, line_height, YES::DASH::STAMINA_TEXT)
    draw_current_and_max_values(x, y, width, $game_player.stamina, 
      $game_player.stamina_max, normal_color, normal_color)
  end
    
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    update_hide
    update_show
    update_input
    refresh
    $game_switches[YES::DASH::DISABLE_SWITCH] ? self.hide : self.show
    self.hide unless YES::DASH::ENABLE_WINDOW
  end
  
  #--------------------------------------------------------------------------
  # update_hide
  #--------------------------------------------------------------------------
  def update_hide
    return unless YES::DASH::AUTO_HIDE_WINDOW
    return if $game_player.dash?
    @time -= 1
    return unless @time <= 0
    #---
    self.x -= 9 if self.x > -self.width
  end
  
  #--------------------------------------------------------------------------
  # update_show
  #--------------------------------------------------------------------------
  def update_show
    return unless YES::DASH::AUTO_HIDE_WINDOW
    return unless @show
    @time = 180
    self.x += 8 if self.x < 24
    @show = false if self.x >= 24
  end
  
  #--------------------------------------------------------------------------
  # update_input
  #--------------------------------------------------------------------------
  def update_input
    return unless $game_player.dash?
    return unless $game_player.moving?
    @show = true
  end
  
  #--------------------------------------------------------------------------
  # dispose
  #--------------------------------------------------------------------------
  def dispose
    $game_player.stamina_backup[:x] = self.x
    $game_player.stamina_backup[:time] = @time
    super
  end
  
end # Window_Stamina

#==============================================================================
# ■ Scene_Map
#==============================================================================

class Scene_Map < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias method: create_all_windows
  #--------------------------------------------------------------------------
  alias dash_create_all_windows create_all_windows
  def create_all_windows
    dash_create_all_windows
    create_dash_window
  end
  
  #--------------------------------------------------------------------------
  # new method: create_dash_window
  #--------------------------------------------------------------------------
  def create_dash_window
    @stamina_window = Window_Stamina.new
  end
  
end # Scene_Map

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================