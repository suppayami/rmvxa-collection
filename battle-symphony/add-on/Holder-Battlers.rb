#==============================================================================
# 
# Å• Yami Engine Symphony - Add-on: Holder Battlers
# -- Last Updated: 2013.02.01
# -- Level: Nothing
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["BattleSymphony-HB"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2013.02.01 - Adjust for Symphony v1.13.
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

$imported = {} if $imported.nil?
$imported["BattleSymphony-HB"] = true

#==============================================================================
# Å° Direction - Advanced Configuration
#==============================================================================

module Direction
  
  #--------------------------------------------------------------------------
  # self.index_hb
  #--------------------------------------------------------------------------
  def self.index_hb(pose)
    case pose
    # array = [row, frames]
    # frames is optional, default is 15
    when :idle
      array = [0, 12]
    when :struck
      array = [3, 10]
    when :woozy
      array = [2, 12]
    #---
    when :victory
      array = [10]
    when :defend
      array = [1, 5]
    when :dead
      array = [12]
    #---
    when :attack
      array = [4, 4]
    when :skill
      array = [6, 6]
    when :magic
      array = [7, 6]
    when :item
      array = [5, 6]
    #---
    when :advance
      array = [8, 5]
    when :retreat
      array = [9, 5]
    else; array = [0, 12]
    end
    return array
  end
    
  #--------------------------------------------------------------------------
  # self.auto_pose_hb
  #--------------------------------------------------------------------------
  def self.auto_pose_hb(battler)
    return :dead if battler.dead?
    return :woozy if battler.hp < battler.mhp / 4
    return :idle
  end
    
end # Direction

#==============================================================================
# Å° BattleManager
#==============================================================================

module BattleManager
  
  #--------------------------------------------------------------------------
  # alias method: process_victory
  #--------------------------------------------------------------------------
  class <<self; alias bes_hb_process_victory process_victory; end
  def self.process_victory
    $game_party.alive_members.each { |battler| battler.force_pose_hb(:victory) }
    return bes_hb_process_victory
  end

  #--------------------------------------------------------------------------
  # alias method: process_defeat
  #--------------------------------------------------------------------------
  class <<self; alias bes_hb_process_defeat process_defeat; end
  def self.process_defeat
    $game_troop.alive_members.each { |battler| battler.force_pose_hb(:victory) }
    return bes_hb_process_defeat
  end
  
end # BattleManager

#==============================================================================
# Å° Regular Expression
#==============================================================================

module REGEXP
  module SYMPHONY

    HOLDERS_BATTLER = /<(?:HOLDERS_BATTLER|holders battler):[ ]*(.*)>/i
    
  end
end

#==============================================================================
# Å° DataManager
#==============================================================================

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_bes_hb load_database; end
  def self.load_database
    load_database_bes_hb
    load_notetags_bes_hb
  end
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_bes_hb
  #--------------------------------------------------------------------------
  def self.load_notetags_bes_hb
    groups = [$data_actors, $data_enemies]
    groups.each { |group|
      group.each { |obj|
        next if obj.nil?
        obj.battle_symphony_holders_battler
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
  attr_accessor :holders_name 
  
  #--------------------------------------------------------------------------
  # new method: battle_symphony_holders_battler
  #--------------------------------------------------------------------------
  def battle_symphony_holders_battler
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::SYMPHONY::HOLDERS_BATTLER
        @holders_name = $1.to_s
      end
    }
  end
  
end # RPG::BaseItem

#==============================================================================
# Å° Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # new method: use_hb?
  #--------------------------------------------------------------------------
  def use_hb?
    self.actor? ? !actor.holders_name.nil? : !enemy.holders_name.nil?
  end
  
  #--------------------------------------------------------------------------
  # new method: holders_name
  #--------------------------------------------------------------------------
  def holders_name
    self.actor? ? actor.holders_name : enemy.holders_name
  end
  
  #--------------------------------------------------------------------------
  # alias method: set_default_position
  #--------------------------------------------------------------------------
  alias bes_hb_set_default_position set_default_position
  def set_default_position
    bes_hb_set_default_position
    set_hb_default_position if self.use_hb?
  end
  
  #--------------------------------------------------------------------------
  # new method: set_8d_default_position
  #--------------------------------------------------------------------------
  def set_hb_default_position
    self.pose = Direction.auto_pose_hb(self)
  end
  
  #--------------------------------------------------------------------------
  # alias method: break_pose
  #--------------------------------------------------------------------------
  alias bes_hb_break_pose break_pose
  def break_pose
    bes_hb_break_pose
    break_pose_hb if self.use_hb?
  end
  
  #--------------------------------------------------------------------------
  # new method: break_pose_hb
  #--------------------------------------------------------------------------
  def break_pose_hb
    @pose = Direction.auto_pose_hb(self) 
    #---
    return unless SceneManager.scene.spriteset
    return unless self.sprite
    @direction = SYMPHONY::View::PARTY_DIRECTION
    @direction = Direction.opposite(@direction) if self.enemy?
    self.sprite.mirror = [9, 6, 3].include?(@direction)
    #@direction = Direction.opposite(@direction) if self.sprite.mirror
  end
  
  #--------------------------------------------------------------------------
  # new method: force_pose_hb
  #--------------------------------------------------------------------------
  def force_pose_hb(pose)
    return unless self.use_hb?
    return unless self.exist?
    #---
    self.break_pose
    self.pose = pose
    @force_pose = true
  end

end # Game_Battler

#==============================================================================
# Å° Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # alias method: use_charset?
  #--------------------------------------------------------------------------
  alias bes_hb_use_charset? use_charset?
  def use_charset?
    return false if use_hb?
    return bes_hb_use_charset?
  end
  
end # Game_Actor

#==============================================================================
# Å° Game_Enemy
#==============================================================================

class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # alias method: use_charset?
  #--------------------------------------------------------------------------
  alias bes_hb_use_charset? use_charset?
  def use_charset?
    return false if use_hb?
    return bes_hb_use_charset?
  end
  
end # Game_Enemy

#==============================================================================
# Å° Sprite_Battler
#==============================================================================

class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # alias method: update_bitmap
  #--------------------------------------------------------------------------
  alias bes_hb_update_bitmap update_bitmap
  def update_bitmap
    correct_change_pose if @timer.nil?
    @battler.use_hb? ? update_hbset : bes_hb_update_bitmap
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_origin
  #--------------------------------------------------------------------------
  alias bes_hb_update_origin update_origin
  def update_origin
    bes_hb_update_origin
    update_origin_hb if @battler.use_hb?
  end
  
  #--------------------------------------------------------------------------
  # new method: update_charset
  #--------------------------------------------------------------------------
  def update_hbset
    @battler.set_default_position unless pose
    #---
    update_hbset_bitmap
    update_src_rect
  end
  
  #--------------------------------------------------------------------------
  # alias method: correct_change_pose
  #--------------------------------------------------------------------------
  alias bes_hb_correct_change_pose correct_change_pose
  def correct_change_pose
    bes_hb_correct_change_pose unless @battler.use_hb?
    correct_change_pose_hb if @battler.use_hb?
  end
  
  #--------------------------------------------------------------------------
  # new method: correct_change_pose_hb
  #--------------------------------------------------------------------------
  def correct_change_pose_hb
    array = Direction.index_hb(pose)
    @pattern = @battler.reverse_pose ? 3 : 0
    @timer = array[1].nil? ? 15 : array[1]
    @last_pose = pose
    @back_step = false
  end
  
  #--------------------------------------------------------------------------
  # new method: update_charset_origin
  #--------------------------------------------------------------------------
  def update_origin_hb
    if bitmap
      self.ox = @cw / 2
      self.oy = @ch
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: hb_graphic_changed?
  #--------------------------------------------------------------------------
  def hb_graphic_changed?
    self.bitmap.nil? || @character_name != @battler.holders_name
  end
  
  #--------------------------------------------------------------------------
  # alias method: set_character_bitmap
  #--------------------------------------------------------------------------
  alias bes_hb_set_character_bitmap set_character_bitmap
  def set_character_bitmap
    bes_hb_set_character_bitmap unless @battler.use_hb?
    return unless @battler.use_hb?
    self.bitmap = Cache.character(@character_name)
    @cw = bitmap.width / 4
    @ch = bitmap.height / 14
  end
  
  #--------------------------------------------------------------------------
  # new method: update_hbset_bitmap
  #--------------------------------------------------------------------------
  def update_hbset_bitmap
    if hb_graphic_changed?
      @character_name = @battler.holders_name
      set_character_bitmap
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_src_rect
  #--------------------------------------------------------------------------
  alias bes_hb_update_src_rect update_src_rect
  def update_src_rect
    bes_hb_update_src_rect unless @battler.use_hb?
    return unless @battler.use_hb?
    @timer -= 1
    if @battler.force_pose
      if @timer <= 0 && @pattern < 3
        array = []
        array = Direction.index_hb(pose)
        @pattern += 1
        @timer = array[1].nil? ? 15 : array[1]
      end
    else
      if @timer <= 0
        @pattern += 1
        @pattern = 0 if @pattern > 3
        @timer = 15
      end
    end
    #---
    line_no = Direction.index_hb(pose)[0]
    sx = @pattern * @cw
    sy = line_no * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
  
end # Sprite_Battler

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================