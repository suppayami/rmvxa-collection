#==============================================================================
# 
# Å• Yami Engine Symphony - Add-on: 8D/Kaduki Battlers
# -- Last Updated: 2013.02.01
# -- Level: Nothing
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["BattleSymphony-8D"] = true

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
#    Down            Down Left       Down Dash       Down Left Dash
#    Left            Upper Left      Left Dash       Upper Left Dash
#    Right           Down Right      Right Dash      Down Right Dash
#    Up              Upper Right     Up Dash         Up Right Dash
# 
#    Ready/Idle      Victory Pose    2H Swing        
#    Damage          Evade/Dodge     1H Swing        
#    Dazed/Critical  Dead 1-3        Cast/Use Item   
#    Marching        Downed/Fallen   Channeling      
#==============================================================================

$imported = {} if $imported.nil?
$imported["BattleSymphony-8D"] = true

#==============================================================================
# Å° Direction - Advanced Configuration
#==============================================================================

module Direction
  
  #--------------------------------------------------------------------------
  # self.index_8d
  #--------------------------------------------------------------------------
  def self.index_8d(pose)
    case pose
    # array = [index, direction, frames]
    # frames is optional, default is 15
    when :down
      array = [0, 2]
    when :left
      array = [0, 4]
    when :right
      array = [0, 6]
    when :up
      array = [0, 8]
    #---
    when :down_l
      array = [1, 2]
    when :up_l
      array = [1, 4]
    when :down_r
      array = [1, 6]
    when :up_l
      array = [1, 8]
    #---
    when :down_d
      array = [2, 2]
    when :left_d
      array = [2, 4]
    when :right_d
      array = [2, 6]
    when :up_d
      array = [2, 8]
    #---
    when :down_l_d
      array = [3, 2]
    when :up_l_d
      array = [3, 4]
    when :down_r_d
      array = [3, 6]
    when :up_l_d
      array = [3, 8]
    #--- Pose Creation ---
    when :ready
      array = [4, 2, 12]
    when :damage
      array = [4, 4, 10]
    when :critical
      array = [4, 6, 12]
    when :marching
      array = [4, 8, 12]
    #---
    when :victory
      array = [5, 2]
    when :dodge
      array = [5, 4, 5]
    when :dead
      array = [5, 6]
    when :fallen
      array = [5, 8]
    #---
    when :swing2h
      array = [6, 2, 6]
    when :r2hswing
      array = [6, 2, 6]
    when :swing1h
      array = [6, 4, 6]
    when :r1hswing
      array = [6, 4, 6]
    when :cast
      array = [6, 6, 6]
    when :channeling
      array = [6, 8, 8]
    else; array = [4, 2]
    end
    return array
  end
  
  #--------------------------------------------------------------------------
  # self.auto_pose
  #--------------------------------------------------------------------------
  def self.auto_pose(battler)
    return :fallen if battler.dead?
    return :critical if battler.hp < battler.mhp / 4
    return :move if [7, 9, 1, 3].include?(SYMPHONY::View::PARTY_DIRECTION)
    return :ready
  end
    
end # Direction

#==============================================================================
# Å° BattleManager
#==============================================================================

module BattleManager
  
  #--------------------------------------------------------------------------
  # alias method: process_victory
  #--------------------------------------------------------------------------
  class <<self; alias bes_8d_process_victory process_victory; end
  def self.process_victory
    $game_party.alive_members.each { |battler| battler.force_pose_8d(:victory) }
    return bes_8d_process_victory
  end

  #--------------------------------------------------------------------------
  # alias method: process_defeat
  #--------------------------------------------------------------------------
  class <<self; alias bes_8d_process_defeat process_defeat; end
  def self.process_defeat
    $game_troop.alive_members.each { |battler| battler.force_pose_8d(:victory) }
    return bes_8d_process_defeat
  end
  
end # BattleManager

#==============================================================================
# Å° Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # new method: use_8d?
  #--------------------------------------------------------------------------
  def use_8d?
    return @character_name =~ /(_8D)/i if use_charset?
  end
  
  #--------------------------------------------------------------------------
  # alias method: set_default_position
  #--------------------------------------------------------------------------
  alias bes_8d_set_default_position set_default_position
  def set_default_position
    bes_8d_set_default_position
    set_8d_default_position if self.use_8d?
  end
  
  #--------------------------------------------------------------------------
  # new method: set_8d_default_position
  #--------------------------------------------------------------------------
  def set_8d_default_position
    self.pose = Direction.auto_pose(self)
  end
  
  #--------------------------------------------------------------------------
  # alias method: break_pose
  #--------------------------------------------------------------------------
  alias bes_8d_break_pose break_pose
  def break_pose
    bes_8d_break_pose
    break_pose_8d if self.use_8d?
  end
  
  #--------------------------------------------------------------------------
  # new method: break_pose_8d
  #--------------------------------------------------------------------------
  def break_pose_8d
    @pose = Direction.auto_pose(self) 
    #---
    return unless SceneManager.scene.spriteset
    return unless self.sprite
    @direction = SYMPHONY::View::PARTY_DIRECTION
    @direction = Direction.opposite(@direction) if self.enemy?
    self.sprite.mirror = [9, 6, 3].include?(@direction)
    #@direction = Direction.opposite(@direction) if self.sprite.mirror
  end
  
  #--------------------------------------------------------------------------
  # new method: force_pose_8d
  #--------------------------------------------------------------------------
  def force_pose_8d(pose, reverse = false)
    return unless self.use_8d?
    return unless self.exist?
    #---
    self.break_pose
    self.pose = pose
    @reverse_pose = reverse
    @force_pose = true
  end
  
end # Game_Battler

#==============================================================================
# Å° Sprite_Battler
#==============================================================================

class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # alias method: correct_change_pose
  #--------------------------------------------------------------------------
  alias bes_8d_correct_change_pose correct_change_pose
  def correct_change_pose
    bes_8d_correct_change_pose unless @battler.use_8d?
    correct_change_pose_8d if @battler.use_8d?
  end
  
  #--------------------------------------------------------------------------
  # new method: correct_change_pose_8d
  #--------------------------------------------------------------------------
  def correct_change_pose_8d
    array = Direction.index_8d(pose)
    @pattern = array[0] > 3 ? (@battler.reverse_pose ? 2 : 0) : 1
    @timer = array[2].nil? ? 15 : array[2]
    @back_step = false
    @last_pose = pose
  end
  
end # Sprite_Battler

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================