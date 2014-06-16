#==============================================================================
# 
# Å• Yami Script Ace - Overlay Mapping
# -- Last Updated: 2011.12.29
# -- Level: Easy
# -- Requires: n/a
# -- Credit: Hanzo Kimura for Original Script
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YSA-OverlayMapping"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2011.12.29 - Bugfix for transfer.
# 2011.12.10 - Started and Finished Script.
#
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script based on Hanzo Kimura's idea. This will automatically load map's
# overlay by map ID, and a map can have more than one image per layer, so you
# don't have to create two or more map just for day/night or when an event occur.
# 
#==============================================================================
# Å• Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Create a folder in Graphics and name it Overlay.
# Put all of your overlay into Graphics/Overlay.
# Your overlay file will have the name: "Filename Prefix" + Map-ID + "-" + Number
# which "Filename Prefix" is the one you will config below
# Map-ID is your map's ID
# Number is 1, 2, 3, ... using for Overlay Variables.
#
# Example: Graphics/Overlay/ground2-1.png
# Which means this will be ground layer, for map 2, variable = 1
#
# Light/Shadow must be .jpg
# Parallax/Ground must be .png
#
#==============================================================================

module YSA
  module OVERLAY
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Overlay Switches -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # These are switches which are enable overlay layers. Turn them on to show
    # them in your maps.
    #--------------------------------------------------------------------------
    # Default: ON
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    LIGHT_SWITCH = 1        # Turn on/off light layer
    SHADOW_SWITCH = 2       # Turn on/off shadow layer
    PARALLAX_SWITCH = 3     # Turn on/off parallax layer
    GROUND_SWITCH = 4       # Turn on/off ground layer

    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Overlay Variables -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # A map can have more than one image per layer, that means you can have a
    # different light/shadow for day and night, or have a different ground when
    # an event occured.
    #--------------------------------------------------------------------------
    # Default: 1
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    LIGHT_VARIABLE = 2      # Switch to another light
    SHADOW_VARIABLE = 2     # Switch to another shadow
    PARALLAX_VARIABLE = 1   # Switch to another parallax
    GROUND_VARIABLE = 1     # Switch to another ground
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Filename Prefix -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # This will make this script automatic, it will check if there are layers in
    # overlay folder
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    LIGHT = "light"         # Light layer's filename prefix
    SHADOW = "shadow"       # Shadow layer's filename prefix
    PARALLAX = "par"        # Parallax layer's filename prefix
    GROUND = "ground"       # Ground layer's filename prefix
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Overlay Opacity -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # This will make this script automatic, it will check if there are layers in
    # overlay folder
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    GROUND_OPACITY = 255
    PARALLAX_OPACITY = 255
    LIGHT_OPACITY = 128
    SHADOW_OPACITY = 96
  end #OVERLAY
end # YSA

#==============================================================================
# Å• Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

#==============================================================================
# Å° Cache
#==============================================================================

module Cache
  
  #--------------------------------------------------------------------------
  # new method: overlay
  #--------------------------------------------------------------------------
  def self.overlay(filename)
    load_bitmap("Graphics/Overlay/", filename)
  end
  
end # Cache

#==============================================================================
# Å° DataManager
#==============================================================================

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: setup_new_game
  #--------------------------------------------------------------------------
  class <<self; alias ovm_setup_new_game setup_new_game; end
  def self.setup_new_game
    ovm_setup_new_game
    setup_overlay_mapping
  end
  
  #--------------------------------------------------------------------------
  # new method: setup_overlay_mapping
  #--------------------------------------------------------------------------
  def self.setup_overlay_mapping
    # Control switches
    $game_switches[YSA::OVERLAY::LIGHT_SWITCH] = true
    $game_switches[YSA::OVERLAY::SHADOW_SWITCH] = true
    $game_switches[YSA::OVERLAY::GROUND_SWITCH] = true
    $game_switches[YSA::OVERLAY::PARALLAX_SWITCH] = true
    
    # Control variables
    $game_variables[YSA::OVERLAY::LIGHT_VARIABLE] = 1
    $game_variables[YSA::OVERLAY::SHADOW_VARIABLE] = 1
    $game_variables[YSA::OVERLAY::GROUND_VARIABLE] = 1
    $game_variables[YSA::OVERLAY::PARALLAX_VARIABLE] = 1
  end
  
end # DataManager

#==============================================================================
# Å° Spriteset_Map
#==============================================================================

class Spriteset_Map
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias overlay_initialize initialize
  def initialize
    overlay_initialize
    create_overlay_map
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: check_file
  #--------------------------------------------------------------------------
  def check_file(type)
    filename = "Graphics/Overlay/"
    filename += YSA::OVERLAY::GROUND if type == "ground"
    filename += YSA::OVERLAY::LIGHT if type == "light"
    filename += YSA::OVERLAY::SHADOW if type == "shadow"
    filename += YSA::OVERLAY::PARALLAX if type == "par"
    filename += $game_map.map_id.to_s
    filename += "-" + $game_variables[YSA::OVERLAY::GROUND_VARIABLE].to_s if type == "ground"
    filename += "-" + $game_variables[YSA::OVERLAY::LIGHT_VARIABLE].to_s if type == "light"
    filename += "-" + $game_variables[YSA::OVERLAY::SHADOW_VARIABLE].to_s if type == "shadow"
    filename += "-" + $game_variables[YSA::OVERLAY::PARALLAX_VARIABLE].to_s if type == "par"
    filename += ".jpg" if type == "light" || type == "shadow"
    filename += ".png" if type == "par" || type == "ground"
    return FileTest.exist?(filename)
  end
  
  #--------------------------------------------------------------------------
  # new method: create_overlay_map
  #--------------------------------------------------------------------------
  def create_overlay_map
    w = Graphics.width
    h = Graphics.height
    @current_light = 0
    @current_shadow = 0
    @current_par = 0
    @current_ground = 0
    # Ground Layer
    @ground = Sprite.new(@viewport1)
    @ground.z = 1
    @ground.opacity = YSA::OVERLAY::GROUND_OPACITY
    # Light Layer
    @light_viewport = Viewport.new(0, 0, w, h)
    @light_viewport.z = 10
    @light = Sprite.new(@light_viewport)
    @light.opacity = YSA::OVERLAY::LIGHT_OPACITY
    @light.blend_type = 1 
    # Shadow Layer
    @shadow_viewport = Viewport.new(0, 0, w, h)
    @shadow_viewport.z = 9
    @shadow = Sprite.new(@shadow_viewport)
    @shadow.opacity = YSA::OVERLAY::SHADOW_OPACITY
    @shadow.blend_type = 2
    # Parallax Layer
    @par_viewport = Viewport.new(0, 0, w, h)
    @par_viewport.z = 8
    @par = Sprite.new(@par_viewport)
    @par.opacity = YSA::OVERLAY::PARALLAX_OPACITY
  end
  
  #--------------------------------------------------------------------------
  # alias method: dispose_parallax
  #--------------------------------------------------------------------------
  alias overlay_dispose_parallax dispose_parallax
  def dispose_parallax
    overlay_dispose_parallax
    dispose_overlay_map
  end
  
  #--------------------------------------------------------------------------
  # new method: dispose_overlay_map
  #--------------------------------------------------------------------------
  def dispose_overlay_map
    @ground.dispose
    @shadow_viewport.dispose
    @light_viewport.dispose
    @light.dispose
    @shadow.dispose
    @par_viewport.dispose
    @par.dispose
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_parallax
  #--------------------------------------------------------------------------
  alias overlay_update_parallax update_parallax
  def update_parallax
    overlay_update_parallax
    # Parallax
    if @ground != nil
      if check_file("ground")
        @ground.visible = $game_switches[YSA::OVERLAY::GROUND_SWITCH] if @ground.visible != $game_switches[YSA::OVERLAY::GROUND_SWITCH]
        @ground.ox = $game_map.display_x * 32 if @ground.ox != $game_map.display_x * 32
        @ground.oy = $game_map.display_y * 32 if @ground.oy != $game_map.display_y * 32
        @ground.tone = $game_map.screen.tone
        if @current_ground != $game_variables[YSA::OVERLAY::GROUND_VARIABLE]
          filename = YSA::OVERLAY::GROUND
          filename += $game_map.map_id.to_s
          filename += "-" + $game_variables[YSA::OVERLAY::GROUND_VARIABLE].to_s
          @ground.bitmap = Cache.overlay(filename)
          @current_ground = $game_variables[YSA::OVERLAY::GROUND_VARIABLE]
        end
      else
        @ground.visible = false
      end
    end
    # Light
    if @light != nil && @light_viewport != nil
      if check_file("light")
        @light.visible = $game_switches[YSA::OVERLAY::LIGHT_SWITCH] if @light.visible != $game_switches[YSA::OVERLAY::LIGHT_SWITCH]
        @light.ox = $game_map.display_x * 32 if @light.ox != $game_map.display_x * 32
        @light.oy = $game_map.display_y * 32 if @light.oy != $game_map.display_y * 32
        @light.tone = $game_map.screen.tone
        @light_viewport.ox = $game_map.screen.shake
        @light_viewport.color = $game_map.screen.flash_color
        if @current_light != $game_variables[YSA::OVERLAY::LIGHT_VARIABLE]
          filename = YSA::OVERLAY::LIGHT
          filename += $game_map.map_id.to_s
          filename += "-" + $game_variables[YSA::OVERLAY::LIGHT_VARIABLE].to_s
          @light.bitmap = Cache.overlay(filename)
          @current_light = $game_variables[YSA::OVERLAY::LIGHT_VARIABLE]
        end
      else
        @light.visible = false
      end    
    end
    # Shadow
    if @shadow != nil && @shadow_viewport != nil
      if check_file("shadow")
        @shadow.visible = $game_switches[YSA::OVERLAY::SHADOW_SWITCH] if @shadow.visible != $game_switches[YSA::OVERLAY::SHADOW_SWITCH]
        @shadow.ox = $game_map.display_x * 32 if @shadow.ox != $game_map.display_x * 32
        @shadow.oy = $game_map.display_y * 32 if @shadow.oy != $game_map.display_y * 32
        @shadow.tone = $game_map.screen.tone
        @shadow_viewport.ox = $game_map.screen.shake
        @shadow_viewport.color = $game_map.screen.flash_color
        if @current_shadow != $game_variables[YSA::OVERLAY::SHADOW_VARIABLE]
          filename = YSA::OVERLAY::SHADOW
          filename += $game_map.map_id.to_s
          filename += "-" + $game_variables[YSA::OVERLAY::SHADOW_VARIABLE].to_s
          @shadow.bitmap = Cache.overlay(filename)
          @current_shadow = $game_variables[YSA::OVERLAY::SHADOW_VARIABLE]
        end
      else
        @shadow.visible = false
      end
    end
    # Parallax
    if @par != nil && @par_viewport != nil
      if check_file("par")
        @par.visible = $game_switches[YSA::OVERLAY::PARALLAX_SWITCH] if @par.visible != $game_switches[YSA::OVERLAY::PARALLAX_SWITCH]
        @par.ox = $game_map.display_x * 32 if @par.ox != $game_map.display_x * 32
        @par.oy = $game_map.display_y * 32 if @par.oy != $game_map.display_y * 32
        @par.tone = $game_map.screen.tone
        @par_viewport.ox = $game_map.screen.shake
        @par_viewport.color = $game_map.screen.flash_color
        if @current_par != $game_variables[YSA::OVERLAY::PARALLAX_VARIABLE]
          filename = YSA::OVERLAY::PARALLAX
          filename += $game_map.map_id.to_s
          filename += "-" + $game_variables[YSA::OVERLAY::PARALLAX_VARIABLE].to_s
          @par.bitmap = Cache.overlay(filename)
          @current_par = $game_variables[YSA::OVERLAY::PARALLAX_VARIABLE]
        end
      else
        @par.visible = false
      end
    end
  end
  
end # Spriteset_Map

#==============================================================================
# Å° Scene_Map
#==============================================================================

class Scene_Map < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias method: post_transfer
  #--------------------------------------------------------------------------
  alias overlay_post_transfer post_transfer
  def post_transfer
    @spriteset.dispose_overlay_map
    @spriteset.create_overlay_map
    @spriteset.update
    overlay_post_transfer
  end

end # Scene_Map

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================