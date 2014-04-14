$imported = {} if $imported.nil?
$imported["YES-BattlePopup"] = true

#==============================================================================
# ■ BattleLuna
#==============================================================================

module BattleLuna
  module Addon
    
    BATTLE_POPUP = {
      # Basic Configuration.
      :basic_setting  =>  {
        :enable      =>  true,       # Set to false to disable popup.
        :state_popup =>  true,       # Set to false to disable state popup.
        :buff_popup  =>  true,       # Set to false to disable buff popup.
        :delay       =>  6,          # Delay between each popup.
        :no_delay    =>  [:critical, :drained, :weakpoint, :resistant, :absorbed],
      },
      
      # Configuration for words.
      :word_setting   =>  {
        :default    => "%s",        # SprintF for Default.
        :hp_dmg     => "-%s ",      # SprintF for HP damage.
        :hp_heal    => "+%s ",      # SprintF for HP healing.
        :mp_dmg     => "-%s MP",    # SprintF for MP damage.
        :mp_heal    => "+%s MP",    # SprintF for MP healing.
        :tp_dmg     => "-%s TP",    # SprintF for MP damage.
        :tp_heal    => "+%s TP",    # SprintF for MP healing.
        :drained    => "DRAIN",     # Text display for draining HP/MP.
        :critical   => "CRITICAL!", # Text display for critical hit.
        :missed     => "MISS",      # Text display for missed attack.
        :evaded     => "EVADE!",    # Text display for evaded attack.
        :nulled     => "NULL",      # Text display for nulled attack.
        :failed     => "FAILED",    # Text display for a failed attack.
        :add_state  => "+%s",       # SprintF for added states.
        :rem_state  => "-%s",       # SprintF for removed states.
        :dur_state  => "%s",        # SprintF for during states.
        :weakpoint  => "WEAKPOINT", # Appears if foe is weak to element.
        :resistant  => "RESIST",    # Appears if foe is resistant to element.
        :immune     => "IMMUNE",    # Appears if foe is immune to element.
        :absorbed   => "ABSORB",    # Appears if foe can absorb the element.
        :add_buff   => "%s",        # Appears when a positive buff is applied.
        :add_debuff => "%s",        # Appears when a negative buff is applied.
      },
      
      # Configuration for popup visual.
      :style_setting  =>  {
        # Type      => [Red, Green, Blue, Size, Bold, Italic, Font],
        :default    => [255,   255,  255,   32, true,  false, Font.default_name],
        :hp_dmg     => [255,   255,  255,   32, true,  false, Font.default_name],
        :hp_heal    => [255,   255,  255,   32, true,  false, Font.default_name],
        :mp_dmg     => [255,   255,  255,   32, true,  false, Font.default_name],
        :mp_heal    => [255,   255,  255,   32, true,  false, Font.default_name],
        :tp_dmg     => [255,   255,  255,   32, true,  false, Font.default_name],
        :tp_heal    => [255,   255,  255,   32, true,  false, Font.default_name],
        :drained    => [255,   255,  255,   32, true,  false, Font.default_name],
        :critical   => [255,   255,  255,   32, true,  false, Font.default_name],
        :missed     => [255,   255,  255,   32, true,  false, Font.default_name],
        :evaded     => [255,   255,  255,   32, true,  false, Font.default_name],
        :nulled     => [255,   255,  255,   32, true,  false, Font.default_name],
        :failed     => [255,   255,  255,   32, true,  false, Font.default_name],
        :add_state  => [255,   255,  255,   32, true,  false, Font.default_name],
        :rem_state  => [255,   255,  255,   32, true,  false, Font.default_name],
        :dur_state  => [255,   255,  255,   32, true,  false, Font.default_name],
        :weakpoint  => [255,   255,  255,   32, true,  false, Font.default_name],
        :resistant  => [255,   255,  255,   32, true,  false, Font.default_name],
        :immune     => [255,   255,  255,   32, true,  false, Font.default_name],
        :absorbed   => [255,   255,  255,   32, true,  false, Font.default_name],
        :add_buff   => [255,   255,  255,   32, true,  false, Font.default_name],
        :add_debuff => [255,   255,  255,   32, true,  false, Font.default_name],
        :lvup       => [255,   255,  255,   20, false, false, Font.default_name],
      },
      
      # Configuration for popup effect.
      :effect_setting =>  {
        # Type      => [Effect sequence],
        :default    => [:up, :wait],
        :hp_dmg     => [:jump_1, :jump_2, :wait],
        :hp_heal    => [:jump_1, :jump_2, :wait],
        :mp_dmg     => [:jump_1, :jump_2, :wait],
        :mp_heal    => [:jump_1, :jump_2, :wait],
        :tp_dmg     => [:jump_1, :jump_2, :wait],
        :tp_heal    => [:jump_1, :jump_2, :wait],
        :drained    => [:affect, :up    , :wait],
        :critical   => [:affect, :up    , :wait],
        :missed     => [:up    , :wait],
        :evaded     => [:up    , :wait],
        :nulled     => [:up    , :wait],
        :failed     => [:up    , :wait],
        :add_state  => [:affect, :up    , :wait],
        :rem_state  => [:affect, :up    , :wait],
        :dur_state  => [:affect, :up    , :wait],
        :weakpoint  => [:affect, :up    , :wait],
        :resistant  => [:affect, :up    , :wait],
        :immune     => [:up    , :wait],
        :absorbed   => [:affect, :up    , :wait],
        :add_buff   => [:affect, :up    , :wait],
        :add_debuff => [:affect, :up    , :wait],
        :lvup       => [:up, :wait],
      },
      
      :effect_setup   =>  {
        #:type   => [ZoomX, ZoomY, StartX, StartY, MoveX, MoveY, Gravt, Opacity, Dur, Random],
        :up      => [1.0  , 1.0  , 0.0   , 0.0   , 0.0  , -1.0 , 0.0  , 255    , 32 , false ],
        :jump_1  => [1.0  , 1.0  , 0.0   , 0.0   , 0.0  , -6.4 , 0.4  , 255    , 33 , false ],
        :jump_2  => [1.0  , 1.0  , 0.0   , 0.0   , 0.0  , -3.2 , 0.2  , 255    , 33 , false ],
        :wait    => [1.0  , 1.0  , 0.0   , 0.0   , 0.0  , 0.0  , 0.0  , 0      , 20 , false ],
        :affect  => [1.0  , 1.0  , 0.0   , -32.0 , 0.0  , 0.0  , 0.0  , 255    , 1  , false ],
      },
      
    } # End BATTLE_POPUP.
    
  end # Addon
end # BattleLuna

#==============================================================================
# ■ Game_BattlerBase
#==============================================================================

class Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :popups
  
  #--------------------------------------------------------------------------
  # new method: create_popup
  #--------------------------------------------------------------------------
  def create_popup(data, rule = :default)
    return unless SceneManager.scene_is?(Scene_Battle)
    return unless BattleLuna::Addon::BATTLE_POPUP[:basic_setting][:enable]
    @popups ||= []
    @popups.push([data, rule])
  end
  
  #--------------------------------------------------------------------------
  # new method: make_damage_popups
  #--------------------------------------------------------------------------
  def make_damage_popups(user)
    if @result.hp_drain != 0
      rule = :drained
      user.create_popup(["", nil], rule)
      rule = :hp_dmg  if @result.hp_drain < 0
      rule = :hp_heal if @result.hp_drain > 0
      value = @result.hp_drain.abs
      user.create_popup(["#{value}", nil], rule)
    end
    if @result.mp_drain != 0
      rule = :drained
      user.create_popup(["", nil], rule)
      rule = :mp_dmg  if @result.mp_drain < 0
      rule = :mp_heal if @result.mp_drain > 0
      value = @result.mp_drain.abs
      user.create_popup(["#{value}", nil], rule)
    end
    #---
    rule = :critical
    create_popup(["", nil], rule) if @result.critical
    if @result.hp_damage != 0
      rule = :hp_dmg  if @result.hp_damage > 0
      rule = :hp_heal if @result.hp_damage < 0
      value = @result.hp_damage.abs
      create_popup(["#{value}", nil], rule)
    end
    if @result.mp_damage != 0
      rule = :mp_dmg  if @result.mp_damage > 0
      rule = :mp_heal if @result.mp_damage < 0
      value = @result.mp_damage.abs
      create_popup(["#{value}", nil], rule)
    end
    if @result.tp_damage != 0
      rule = :tp_dmg  if @result.tp_damage > 0
      rule = :tp_heal if @result.tp_damage < 0
      value = @result.tp_damage.abs
      create_popup(["#{value}", nil], rule)
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: erase_state
  #--------------------------------------------------------------------------
  alias battle_luna_dp_erase_state erase_state unless $imported["YEA-BattleEngine"]
  def erase_state(state_id)
    make_state_popup(state_id, :rem_state) if @states.include?(state_id)
    if $imported["YEA-BattleEngine"]
      game_battlerbase_erase_state_abe(state_id)
    else
      battle_luna_dp_erase_state(state_id)
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: make_during_state_popup
  #--------------------------------------------------------------------------
  def make_during_state_popup
    state_id = most_important_state_id
    return if state_id == 0
    make_state_popup(state_id, :dur_state)
  end
  
  #--------------------------------------------------------------------------
  # new method: most_important_state_id
  #--------------------------------------------------------------------------
  def most_important_state_id
    states.each {|state| return state.id unless state.message3.empty? }
    return 0
  end
  
  #--------------------------------------------------------------------------
  # new method: make_state_popup
  #--------------------------------------------------------------------------
  def make_state_popup(state_id, type)
    return unless BattleLuna::Addon::BATTLE_POPUP[:basic_setting][:state_popup]
    state = $data_states[state_id]
    return if state.icon_index == 0
    create_popup(["#{state.name}", state.icon_index], type)
  end
  
  #--------------------------------------------------------------------------
  # new method: make_miss_popups
  #--------------------------------------------------------------------------
  def make_miss_popups(user, item)
    return if dead?
    if @result.missed
      rule = :missed
      create_popup(["", nil], rule)
    end
    if @result.evaded
      rule = :evaded
      create_popup(["", nil], rule)
    end
    if @result.hit? && !@result.success
      rule = :failed
      create_popup(["", nil], rule)
    end
    if @result.hit? && item.damage.to_hp?
      if @result.hp_damage == 0 && @result.mp_damage == 0
        rule = :nulled
        create_popup(["", nil], rule)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: make_rate_popup
  #--------------------------------------------------------------------------
  def make_rate_popup(rate)
    return if rate == 1.0
    if rate > 1.0
      rule = :weakpoint
    elsif rate == 0.0
      rule = :immune
    elsif rate < 0.0
      rule = :absorbed
    else
      rule = :resistant
    end
    create_popup(["", nil], rule)
  end
  
  #--------------------------------------------------------------------------
  # new method: make_buff_popup
  #--------------------------------------------------------------------------
  def make_buff_popup(param_id, positive = true)
    return unless BattleLuna::Addon::BATTLE_POPUP[:basic_setting][:buff_popup]
    return unless SceneManager.scene_is?(Scene_Battle)
    return unless alive?
    name = Vocab::param(param_id)
    if positive
      rule = :add_buff
      buff_level = 1
    else
      rule = :add_debuff
      buff_level = -1
    end
    icon = buff_icon_index(buff_level, param_id)
    create_popup(["#{name}", icon], rule)
  end

end # Game_BattlerBase

#==============================================================================
# ■ Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # alias method: on_battle_end
  #--------------------------------------------------------------------------
  alias battle_luna_dp_on_battle_end on_battle_end
  def on_battle_end
    battle_luna_dp_on_battle_end
    @popups ||= []
    @popups.clear
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_apply
  #--------------------------------------------------------------------------
  alias battle_luna_dp_item_apply item_apply unless $imported["YEA-BattleEngine"]
  def item_apply(user, item)
    if $imported["YEA-BattleEngine"]
      game_battler_item_apply_abe(user, item)
    else
      battle_luna_dp_item_apply(user, item)
    end    
    make_miss_popups(user, item)
  end
  
  #--------------------------------------------------------------------------
  # alias method: make_damage_value
  #--------------------------------------------------------------------------
  alias battle_luna_dp_make_damage_value make_damage_value unless $imported["YEA-BattleEngine"]
  def make_damage_value(user, item)
    if $imported["YEA-BattleEngine"]
      game_battler_make_damage_value_abe(user, item)
    else
      battle_luna_dp_make_damage_value(user, item)
    end    
    rate = item_element_rate(user, item)
    make_rate_popup(rate)
  end
  
  #--------------------------------------------------------------------------
  # alias method: execute_damage
  #--------------------------------------------------------------------------
  alias battle_luna_dp_execute_damage execute_damage unless $imported["YEA-BattleEngine"]
  def execute_damage(user)
    if $imported["YEA-BattleEngine"]
      game_battler_execute_damage_abe(user)
    else
      battle_luna_dp_execute_damage(user)
    end    
    make_damage_popups(user)
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_effect_recover_hp
  #--------------------------------------------------------------------------
  alias battle_luna_dp_item_effect_recover_hp item_effect_recover_hp unless $imported["YEA-BattleEngine"]
  def item_effect_recover_hp(user, item, effect)
    if $imported["YEA-BattleEngine"]
      game_battler_item_effect_recover_hp_abe(user, item, effect)
    else
      battle_luna_dp_item_effect_recover_hp(user, item, effect)
    end    
    make_damage_popups(user)
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_effect_recover_mp
  #--------------------------------------------------------------------------
  alias battle_luna_item_effect_recover_mp item_effect_recover_mp unless $imported["YEA-BattleEngine"]
  def item_effect_recover_mp(user, item, effect)
    if $imported["YEA-BattleEngine"]
      game_battler_item_effect_recover_mp_abe(user, item, effect)
    else
      battle_luna_item_effect_recover_mp(user, item, effect)
    end  
    make_damage_popups(user)
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_effect_gain_tp
  #--------------------------------------------------------------------------
  alias battle_luna_item_effect_gain_tp item_effect_gain_tp unless $imported["YEA-BattleEngine"]
  def item_effect_gain_tp(user, item, effect)
    if $imported["YEA-BattleEngine"]
      game_battler_item_effect_gain_tp_abe(user, item, effect)
    else
      battle_luna_item_effect_gain_tp(user, item, effect)
    end  
    make_damage_popups(user)
  end
  
  #--------------------------------------------------------------------------
  # alias method: add_new_state
  #--------------------------------------------------------------------------
  alias battle_luna_dp_add_new_state add_new_state unless $imported["YEA-BattleEngine"]
  def add_new_state(state_id)
    if $imported["YEA-BattleEngine"]
      game_battler_add_new_state_abe(state_id)
    else
      battle_luna_dp_add_new_state(state_id)
    end  
    make_state_popup(state_id, :add_state) if @states.include?(state_id)
  end
  
  #--------------------------------------------------------------------------
  # alias method: add_buff
  #--------------------------------------------------------------------------
  alias battle_luna_dp_add_buff add_buff unless $imported["YEA-BattleEngine"]
  def add_buff(param_id, turns)
    make_buff_popup(param_id, true)
    if $imported["YEA-BattleEngine"]
      game_battler_add_buff_abe(param_id, turns)
    else
      battle_luna_dp_add_buff(param_id, turns)
    end  
  end
  
  #--------------------------------------------------------------------------
  # alias method: add_debuff
  #--------------------------------------------------------------------------
  alias battle_luna_dp_add_debuff add_debuff unless $imported["YEA-BattleEngine"]
  def add_debuff(param_id, turns)
    make_buff_popup(param_id, false)
    if $imported["YEA-BattleEngine"]
      game_battler_add_debuff_abe(param_id, turns)
    else
      battle_luna_dp_add_debuff(param_id, turns)
    end  
  end
  
  #--------------------------------------------------------------------------
  # alias method: regenerate_all
  #--------------------------------------------------------------------------
  alias battle_luna_dp_regenerate_all regenerate_all unless $imported["YEA-BattleEngine"]
  def regenerate_all
    if $imported["YEA-BattleEngine"]
      game_battler_regenerate_all_abe
    else
      battle_luna_dp_regenerate_all
    end  
    return unless alive?
    make_damage_popups(self)
  end
    
end # Game_Battler

#==============================================================================
# ■ Sprite_Battler
#==============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  unless Game_Actor.instance_methods.include?(:screen_x)
  def screen_x
    0
  end
  end

  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  unless Game_Actor.instance_methods.include?(:screen_y)
  def screen_y
    0
  end
  end

  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  unless Game_Actor.instance_methods.include?(:screen_z)
  def screen_y
    0
  end
  end
  
end # Game_Actor

#==============================================================================
# ■ Sprite_Battler
#==============================================================================

class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias battle_luna_dp_initialize initialize
  def initialize(viewport, battler = nil)
    battle_luna_dp_initialize(viewport, battler)
    @popups = []
    @popup_delay = 0
  end
  
  #--------------------------------------------------------------------------
  # alias method: setup_new_effect
  #--------------------------------------------------------------------------
  alias battle_luna_dp_setup_new_effect setup_new_effect
  def setup_new_effect
    battle_luna_dp_setup_new_effect
    setup_popups
  end
  
  #--------------------------------------------------------------------------
  # new method: setup_popups
  #--------------------------------------------------------------------------
  def setup_popups
    setting = BattleLuna::Addon::BATTLE_POPUP
    return unless @battler.use_sprite?
    @battler.popups ||= []
    @popup_delay -= 1
    return if @popup_delay > 0
    array = @battler.popups.shift
    return if array.nil?
    create_new_popup(array[0], array[1])
    return if @battler.popups.size == 0
    return if setting[:basic_setting][:no_delay].include?(array[1])
    @popup_delay = setting[:basic_setting][:delay]
  end
  
  #--------------------------------------------------------------------------
  # new method: create_new_popup
  #--------------------------------------------------------------------------
  def create_new_popup(data, rule)
    return unless @battler
    return unless SceneManager.scene.is_a?(Scene_Battle)
    viewport = self.viewport
    popup = Sprite_PopupLuna.new(viewport, @battler, data, rule)
    @popups.push(popup)
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias battle_luna_dp_update update
  def update
    battle_luna_dp_update
    update_popups
  end
  
  #--------------------------------------------------------------------------
  # new method: update_popups
  #--------------------------------------------------------------------------
  def update_popups
    @popups.each { |popup| popup.update }
    @popups.each_with_index { |sprite, index|
      next unless sprite.disposed?
      @popups[index] = nil
    }
    @popups.compact!
  end
  
  #--------------------------------------------------------------------------
  # alias method: dispose
  #--------------------------------------------------------------------------
  alias battle_luna_dp_dispose dispose
  def dispose
    @popups.each { |popup| popup.dispose }
    @popups.clear
    battle_luna_dp_dispose
  end
  
end # Sprite_Battler

#==============================================================================
# ■ Sprite_PopupLuna
#==============================================================================

class Sprite_PopupLuna < Sprite
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, battler, data, rule)
    super(viewport)
    @data = data
    @rule = rule
    #---
    @style = rule
    @style = :default unless setting[:style_setting].has_key?(@style)
    @style = setting[:style_setting][@style]
    #---
    @effects = rule
    @effects = :default unless setting[:effect_setting].has_key?(@effects)
    @effects = setting[:effect_setting][@effects].dup
    #---
    @current_effect = nil
    @duration = 0
    @battler = battler
    #---
    start_popup
    start_effect
    update
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::Addon::BATTLE_POPUP
  end
  
  #--------------------------------------------------------------------------
  # start_popup
  #--------------------------------------------------------------------------
  def start_popup
    self.bitmap = create_bitmap
    self.x = @battler.screen_x
    self.y = @battler.screen_y
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height
    self.z = @battler.screen_z + 350
  end
  
  #--------------------------------------------------------------------------
  # create_bitmap
  #--------------------------------------------------------------------------
  def create_bitmap
    bw = Graphics.width
    bw = bw + 48 if @data[1]
    bh = @style[3] * 2
    bitmap = Bitmap.new(bw, bh)
    #---
    bitmap.font.color.set(@style[0], @style[1], @style[2])
    bitmap.font.size   = @style[3]
    bitmap.font.bold   = @style[4]
    bitmap.font.italic = @style[5]
    bitmap.font.name   = @style[6]
    #---
    dx = @data[1] ? 24 : 0; dy = 0
    text = setting[:word_setting][@rule]
    text = setting[:word_setting][:default] unless text
    text = sprintf(text, @data[0])
    bitmap.draw_text(dx, dy, bw - dx, bh, text, 1)
    #---
    text_width = bitmap.text_size(text).width
    if @data[1]
      icon_bitmap = Cache.system("Iconset")
      icon_index = @data[1].to_i
      rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
      bitmap.blt((bw-text_width)/2-32, (bh - 24)/2, icon_bitmap, rect)
    end
    bitmap
  end
  
  #--------------------------------------------------------------------------
  # start_effect
  #--------------------------------------------------------------------------
  def start_effect
    @current_effect = @effects.shift
    return dispose if @current_effect.nil?
    effect = setting[:effect_setup][@current_effect]
    @duration = effect[8]
    #---
    @zoom_x_rate = (effect[0] - self.zoom_x) / @duration
    @zoom_y_rate = (effect[1] - self.zoom_y) / @duration
    #---
    @move_x = effect[4]
    @move_y = effect[5]
    if effect[9]
      @move_x = @move_x * rand(0)
      @move_x = rand(10) % 2 == 0 ? -@move_x : @move_x
    end
    #---
    @gravity = effect[6]
    #---
    @opacity_rate = (effect[7] - self.opacity) / @duration.to_f
    #---
    self.x += effect[2]
    self.y += effect[3]
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    update_zoom
    update_move
    update_opacity
    update_effect
  end
  
  #--------------------------------------------------------------------------
  # update_effect
  #--------------------------------------------------------------------------
  def update_effect
    @duration -= 1
    return if @duration > 0
    start_effect
  end
  
  #--------------------------------------------------------------------------
  # update_zoom
  #--------------------------------------------------------------------------
  def update_zoom
    self.zoom_x += @zoom_x_rate
    self.zoom_y += @zoom_y_rate
  end
  
  #--------------------------------------------------------------------------
  # update_move
  #--------------------------------------------------------------------------
  def update_move
    self.x += @move_x
    self.y += @move_y
    @move_y += @gravity
  end
  
  #--------------------------------------------------------------------------
  # update_opacity
  #--------------------------------------------------------------------------
  def update_opacity
    self.opacity += @opacity_rate
  end
  
  #--------------------------------------------------------------------------
  # dispose
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose if self.bitmap
    super
  end
  
end # Sprite_PopupLuna

#==============================================================================
# ■ Window_BattleHelp
#==============================================================================
if $imported["YEA-BattleEngine"]
class Window_BattleHelp < Window_Help
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias battle_luna_yea_be_update update
  def update
    battle_luna_yea_be_update
    return unless $imported["YEA-BattleEngine"]
    return unless @actor_window && @enemy_window
    if !self.visible and @text != ""
      @text = ""
      return refresh
    end
    update_battler_name
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_battler_name
  #--------------------------------------------------------------------------
  alias battle_luna_yea_be_update_battler_name update_battler_name
  def update_battler_name
    return unless @actor_window
    return unless @enemy_window
    return unless @actor_window.active || @enemy_window.active
    battle_luna_yea_be_update_battler_name
    self.show
  end
  
end # Window_BattleHelp
end