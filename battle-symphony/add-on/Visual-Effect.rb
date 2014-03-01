#==============================================================================
# 
# Å• Yami Engine Symphony - Add-on: Visual Effect Tags
# -- Last Updated: 2012.10.20
# -- Level: Nothing
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["BattleSymphony-VisualEffect"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.10.20 - Finished Script.
# 2012.07.01 - Started Script.
#
#==============================================================================
# Å• Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# Remember to put this script under Battle Symphony.
# 
#==============================================================================

#==============================================================================
# Å° Default Actions - Imported Symphony Configuration
#==============================================================================

module SYMPHONY
  
  VE_AUTO_SYMPHONY = {
  
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: hide nonfocus
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This hides whatever isn't the active battler and its targets. Great for
    # long action sequences or summoning sequences when the allied party
    # members, who aren't involved, will disappear. In addition to that, the
    # screen will also fade black and the battle waits 32 frames.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "HIDE NONFOCUS" => [
      ["VANISH", ["NOT FOCUS", "TRUE"]],
      ["SCREEN", ["DARKEN"]],
      ["WAIT", [32]],
    ], # end HIDE NONFOCUS
    
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: show nonfocus
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This removes the hidden effect from the vanished units in the hidden
    # version of this AutoSymphony. Returns all of the hidden non-participating
    # party members back into view. The screen's fade will return back to
    # normal and the battle waits 16 frames.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "SHOW NONFOCUS" => [
      ["VANISH", ["NOT FOCUS", "FALSE"]],
      ["SCREEN", ["LIGHTEN"]],
      ["WAIT", [16]],
    ], # end SHOW NONFOCUS
    
  } # Do not remove this.
  
  AUTO_SYMPHONY.merge!(VE_AUTO_SYMPHONY)
  
end # SYMPHONY

#==============================================================================
# Å° Scene_Battle - Imported Symphony Configuration
#==============================================================================

class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # alias method: imported_symphony
  #--------------------------------------------------------------------------
  alias bes_ve_imported_symphony imported_symphony
  def imported_symphony
    case @action.upcase
      
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      # afterimage: tune1, tune2
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # tune1
      # - refer to target typing; See Symphony Manual for more info.
      # tune2
      # - refer to flag; true or false.
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Switch the Afterimage effect for targets, which creates some
      # afterimage behind targets.
      # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # afterimage: user, true
      # afterimage: targets, false
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      when /AFTERIMAGE|MIRAGE/i
        action_afterimage
    
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      # effect: tune1, tune2
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # tune1
      # - refer to target typing; See Symphony Manual for more info.
      # tune2
      # - refer to effect; There are 2 default effects for sprites:
      #   + whiten
      #   + blink
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Start effect on targets sprites for short duration.
      # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # effect: user, whiten
      # effect: targets, blink
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      when /EFFECT/i
        action_effect
        
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      # movie: tune1
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # tune1
      # - refer to movie filename.
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Play a movie file when action is called. Movie has to be put in folder
      # Graphics/Movies.
      # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # movie: thunder.ogg
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      when /MOVIE/i
        action_movie
    
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      # screen: tune1
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # tune1
      # - fade out, x; This will fade the screen out in x frames.
      # - fade in, x; This will fade the screen in in x frames.
      # - shake, x, y, z; Shakes screen with y power, z speed, x frames.
      # - weather, x, y, z; Sets weather type y, z power, x frames.
      # - tone, x, r, g, b, gr; x frames, rgb, gr is gray.
      # - flash, x, r, g, b, a; x frames, rgb, a is alpha.
      # - darken; This darkens the battleback.
      # - lighten; This removes the darkened battleback.
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # This will produce unique effects using the screen. Each tuneset uses
      # a different set of rules so pay attention to the examples below on
      # how it's all used.
      # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # screen: fade out, 30
      # screen: fade in, 30
      # screen: shake, 60, 5, 5
      # screen: weather, 30, rain, 5
      # screen: tone, 60, 5, 5, 5, 0
      # screen: flash, 30, 255, 255, 255, 96
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      when /SCREEN/i
        action_screen
    
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      # vanish: tune1, tune2, tune3
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # tune1
      # - refer to target typing; See Symphony Manual for more info.
      # tune2
      # - refer to flag; true or false.
      # tune3 (optional)
      # - refer to instant flag; Put instant here.
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Make targets appear or disappear. If tune3 is true, the targets will
      # be disappear or appear instantly.
      # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # vanish: targets, true
      # vanish: user, false, instant
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      when /VANISH/i
        action_vanish
        
      else
        bes_ve_imported_symphony        
    end
  end

end # Scene_Battle

#==============================================================================
# Å° Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :afterimage
  attr_reader   :vanishing
  
  #--------------------------------------------------------------------------
  # new method: set_vanish
  #--------------------------------------------------------------------------
  def set_vanish(code)
    case code
    when 0
      @vanishing = false
      sprite.start_effect(:appear)
    when 1
      @vanishing = true
      sprite.start_effect(:disappear)
    when 2
      @vanishing = false
      sprite.start_effect(:appear)
      sprite.set_effect_instant
    when 3
      @vanishing = true
      sprite.start_effect(:disappear)
      sprite.set_effect_instant
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: set_afterimage
  #--------------------------------------------------------------------------
  def set_afterimage(flag)
    @afterimage = flag
  end
  
end # Game_Battler

#==============================================================================
# Å° Game_Screen
#==============================================================================

class Game_Screen
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :alpha
  
  #--------------------------------------------------------------------------
  # alias method: clear
  #--------------------------------------------------------------------------
  alias bes_ve_clear clear
  def clear
    bes_ve_clear
    clear_bes_ve
  end
  
  #--------------------------------------------------------------------------
  # new method: clear_bes_ve
  #--------------------------------------------------------------------------
  def clear_bes_ve
    clear_alpha
  end
  
  #--------------------------------------------------------------------------
  # new method: clear_alpha
  #--------------------------------------------------------------------------
  def clear_alpha
    @alpha = 0
    @darken_duration = 0
    @lighten_duration = 0
  end
  
  #--------------------------------------------------------------------------
  # new method: start_darken_background
  #--------------------------------------------------------------------------
  def start_darken_background
    @darken_duration = 32
  end
  
  #--------------------------------------------------------------------------
  # new method: start_lighten_background
  #--------------------------------------------------------------------------
  def start_lighten_background
    @lighten_duration = 16
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias bes_ve_update update
  def update
    bes_ve_update
    update_darken
    update_lighten
  end
  
  #--------------------------------------------------------------------------
  # new method: update_darken
  #--------------------------------------------------------------------------
  def update_darken
    return if @darken_duration <= 0
    @alpha = (32 - @darken_duration) * 4
    @darken_duration -= 1
  end
  
  #--------------------------------------------------------------------------
  # new method: update_lighten
  #--------------------------------------------------------------------------
  def update_lighten
    return if @lighten_duration <= 0
    @alpha = @lighten_duration * 8
    @lighten_duration -= 1
  end
  
end # Game_Screen

#==============================================================================
# Å° Sprite_Battler
#==============================================================================

class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # overwrite method: setup_new_effect
  #--------------------------------------------------------------------------
  def setup_new_effect
    if !@battler_visible && @battler.alive?
      start_effect(:appear) unless @battler.vanishing
    elsif @battler_visible && @battler.hidden?
      start_effect(:disappear)
    end
    if @battler_visible && @battler.sprite_effect_type
      start_effect(@battler.sprite_effect_type)
      @battler.sprite_effect_type = nil
    end
    setup_popups if $imported["YEA-BattleEngine"]
  end
  
  #--------------------------------------------------------------------------
  # new method: set_effect_instant
  #--------------------------------------------------------------------------
  def set_effect_instant
    return if @effect_type.nil?
    @effect_duration = 1
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_position
  #--------------------------------------------------------------------------
  alias bes_ve_update_position update_position
  def update_position
    bes_ve_update_position
    update_afterimage
  end
  
  #--------------------------------------------------------------------------
  # new method: update_afterimage
  #--------------------------------------------------------------------------
  def update_afterimage
    @afterimage_sprites ||= []
    @afterimage_sprites.each { |sprite|
      @afterimage_sprites.delete(sprite) if sprite.disposed?
      next if sprite.disposed?
      sprite.update
    }
    return unless @battler.afterimage
    if @afterimage_sprites.size < 3
      sprite = Sprite_AfterImage.new(self.viewport, self)
      @afterimage_sprites << sprite
    end
  end
  
end # Sprite_Battler

#==============================================================================
# Å° Sprite_AfterImage
#==============================================================================

class Sprite_AfterImage < Sprite_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, sprite)
    super(viewport)
    @sprite = sprite
    @time = 12
    @fade_time_start = @time / 2
    @fade_time = (@time - @fade_time_start).to_f
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    self.x = @sprite.x; self.y = @sprite.y
    self.ox = @sprite.ox; self.oy = @sprite.oy
    self.bitmap = @sprite.bitmap
    self.opacity = @sprite.opacity - 95
    self.src_rect.set(@sprite.src_rect)
    self.mirror = @sprite.mirror
    self.visible = @sprite.visible
    @opacity_rate = self.opacity / @fade_time
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    @time -= 1
    if @time < @fade_time_start
      self.opacity -= @opacity_rate
    end
    self.dispose if self.opacity <= 0
  end
  
end # Sprite_AfterImage

#==============================================================================
# Å° Spriteset_Battle
#==============================================================================

class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # alias method: update_battleback1
  #--------------------------------------------------------------------------
  alias bes_ve_update_battleback1 update_battleback1
  def update_battleback1
    bes_ve_update_battleback1
    @back1_sprite.color.alpha = $game_troop.screen.alpha
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_battleback2
  #--------------------------------------------------------------------------
  alias bes_ve_update_battleback2 update_battleback2
  def update_battleback2
    bes_ve_update_battleback2
    @back2_sprite.color.alpha = $game_troop.screen.alpha
  end
  
end # Spriteset_Battle

#==============================================================================
# Å° Scene_Battle - Imported Symphony Actions
#==============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # new method: action_afterimage
  #--------------------------------------------------------------------------
  def action_afterimage
    targets = get_action_targets.uniq
    return if targets.size == 0
    case @action_values[1].upcase
    when "ON", "TRUE", "ENABLE"
      flag = true
    when "OFF", "FALSE", "DISABLE"
      flag = false
    end
    targets.each { |target|
      next unless target.exist?
      target.set_afterimage(flag)
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_effect
  #--------------------------------------------------------------------------
  def action_effect
    targets = get_action_targets.uniq
    return if targets.size == 0
    symbol = @action_values[1].downcase.to_sym
    targets.each { |target| 
      next unless target.exist?
      target.sprite.start_effect(symbol)
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_effect
  #--------------------------------------------------------------------------
  def action_movie
    return if @action_values[0].nil?
    return if @action_values[0].size == 0
    filename = "Graphics/Movies/#{@action_values[0]}"
    return unless FileTest.exist?(filename)
    Graphics.play_movie(filename)
  end
  
  #--------------------------------------------------------------------------
  # new method: action_screen
  #--------------------------------------------------------------------------
  def action_screen
    case @action_values[0]
    when "FADEOUT", "FADE OUT"
      duration = @action_values[1].to_i
      duration = 30 if duration <= 0
      $game_troop.screen.start_fadeout(duration)
    when "FADEIN", "FADE IN"
      duration = @action_values[1].to_i
      duration = 30 if duration <= 0
      $game_troop.screen.start_fadein(duration)
    when "TONE"
      duration = @action_values[1].to_i
      duration = 30 if duration <= 0
      r = @action_values[2].to_i; g = @action_values[3].to_i; b = @action_values[4].to_i
      gr = @action_values[5].to_i
      tone = Tone.new(r, g, b, gr)
      $game_troop.screen.start_tone_change(tone, duration)
    when "FLASH"
      duration = @action_values[1].to_i
      duration = 30 if duration <= 0
      r = @action_values[2].to_i; g = @action_values[3].to_i; b = @action_values[4].to_i
      a = @action_values[5].to_i
      a = 255 if a <= 0
      color = Color.new(r, g, b, a)
      $game_troop.screen.start_flash(color, duration)
    when "SHAKE"
      duration = @action_values[1].to_i
      duration = 30 if duration <= 0
      power = @action_values[2].to_i
      power = 5 if power <= 0
      speed = @action_values[3].to_i
      speed = 5 if speed <= 0
      $game_troop.screen.start_shake(power, speed, duration)
    when "WEATHER"
      duration = @action_values[1].to_i
      duration = 30 if duration <= 0
      type = @action_values[2].to_sym
      power = @action_values[3].to_i
      $game_troop.screen.change_weather(type, power, duration)
    when "DARKEN"
      $game_troop.screen.start_darken_background
    when "LIGHTEN"
      $game_troop.screen.start_lighten_background
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: action_vanish
  #--------------------------------------------------------------------------
  def action_vanish
    targets = get_action_targets.uniq
    return if targets.size == 0
    case @action_values[1]
    when "ON", "TRUE", "ENABLE", "HIDE"
      vanish_code = 1
    when "OFF", "FALSE", "DISABLE", "SHOW"
      vanish_code = 0
    end
    vanish_code += 2 if @action_values.include?("INSTANT")
    targets.each { |target| 
      next unless target.exist?
      target.set_vanish(vanish_code)
    }
  end
  
end # Scene_Battle

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================