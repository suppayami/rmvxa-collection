#==============================================================================
# 
# Å• Yami Engine Symphony - Pop Message
# -- Last Updated: 2013.01.29
# -- Level: Easy
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-PopMessage"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2013.01.29 - Compatible with: YEA - Ace Message System Namebox.
# 2013.01.29 - Fixed a minor crash with Bubble Tag.
# 2013.01.28 - Finished Script.
# 2013.01.25 - Started Script.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides bubble messages feature, which makes message window pop
# over player's or event's head.
#
#==============================================================================
# Å• Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below Å• Materials/ëfçﬁ but above Å• Main. Remember to save.
#
# -----------------------------------------------------------------------------
# Message Window text Codes - These go inside of your message window.
# -----------------------------------------------------------------------------
#  Code:       Effect:
#    \bm[x]     - Pops message on event ID x head.
#                 Set x to 0 for player pop.
#    \cbm       - Cancel pops message manually.
#    \cbt[name] - Set bubble tag filename to name.
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
  module POP_MESSAGE
    
    #===========================================================================
    # - Limit Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # The following below will adjust the limit options for pop message.
    #===========================================================================
    LIMIT_SETTING = { # Start.
      :width            =>  0, # Set to 0 to disable limitation.
      :lines            =>  4, # Set to 0 to disable limitation.
    } # End.
    
    #===========================================================================
    # - Effect Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # The following below will adjust the effect options for pop message.
    #===========================================================================
    EFFECT_SETTING = { # Start.
      :default_face     =>  false,# Use default face draw.
      # Effects for non-default face draw.
      :face_fade        =>  true, # Makes face to be fading when start message.
      :face_move        =>  true, # Makes face to be moving in when start message.
      # Bubble tag settings.
      :bubble_tag       =>  true, # Enables bubble tag for pop message.
      :bubble_name      =>  "BubbleTag", # Put bubble tag image into 
                                         # Graphics/System
      :bubble_offset_y  =>  -6,
    } # End.
    
  end
end

#==============================================================================
# Å• Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

#==============================================================================
# Å° Window_MessageFace
#==============================================================================

class Window_MessageFace < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 120, 120)
    self.opacity = 0
    self.contents_opacity = 0
    self.close
    @move_x = 0
  end
  
  #--------------------------------------------------------------------------
  # draw_content_face
  #--------------------------------------------------------------------------
  def draw_content_face
    if $game_message.face_name.empty?
      hide_face
    else
      self.y = - self.height
      contents.clear
      draw_face($game_message.face_name, $game_message.face_index, 0, 0)
    end
  end
  
  #--------------------------------------------------------------------------
  # fade_time
  #--------------------------------------------------------------------------
  def fade_time
    17
  end
  
  #--------------------------------------------------------------------------
  # move_time
  #--------------------------------------------------------------------------
  def move_time
    17
  end
  
  #--------------------------------------------------------------------------
  # move_rate
  #--------------------------------------------------------------------------
  def move_rate
    2
  end
  
  #--------------------------------------------------------------------------
  # show_face
  #--------------------------------------------------------------------------
  def show_face
    return if $game_message.face_name.empty?
    self.open
    #---
    if (YES::POP_MESSAGE::EFFECT_SETTING[:face_fade] ||
        YES::POP_MESSAGE::EFFECT_SETTING[:face_move])
        self.openness = 255
    end
    #---
    if YES::POP_MESSAGE::EFFECT_SETTING[:face_fade]
      self.contents_opacity = 0
    else
      self.contents_opacity = 255
    end
    #---
    if YES::POP_MESSAGE::EFFECT_SETTING[:face_move]
      @move_x = move_time * move_rate
      self.x -= @move_x
    end
  end
  
  #--------------------------------------------------------------------------
  # hide_face
  #--------------------------------------------------------------------------
  def hide_face
    close
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    #---
    self.contents_opacity += 255.0 / fade_time
    #---
    if @move_x > 0
      rate = [move_rate, @move_x].min
      @move_x -= rate
      self.x += rate      
    end
  end
  
end # Window_MessageFace

#==============================================================================
# Å° Window_Message
#==============================================================================

class Window_Message < Window_Base
  
  #--------------------------------------------------------------------------
  # new method: pop_message_initialize
  #--------------------------------------------------------------------------
  def pop_message_initialize(text)
    if text =~ /\\BM\[(\d+)\]/i
      setup_pop_message($1.to_i)
    end
    if text =~ /\\CBM/i
      cancel_pop_message
    end
    if text =~ /\\CBT\[(.*)\]/i
      create_bubble_sprite($1)
      @bubble_sprite.opacity = 255
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: process_pop_message
  #--------------------------------------------------------------------------
  def process_pop_message(text)
    text.gsub!(/\eCBT\[(.*)\]/i) { "" }
    text.gsub!(/\eBM\[(\d+)\]/i) { "" }
    text.gsub!(/\eCBM/i) { "" }
    text
  end
  
  #--------------------------------------------------------------------------
  # alias method: convert_escape_characters
  #--------------------------------------------------------------------------
  alias yes_pm_convert_escape_characters convert_escape_characters
  def convert_escape_characters(text)
    result = yes_pm_convert_escape_characters(text)
    result = process_pop_message(result)
    result
  end
  
  #--------------------------------------------------------------------------
  # new method: setup_pop_message
  #--------------------------------------------------------------------------
  def setup_pop_message(id)
    create_bubble_sprite
    adjust_window_size
    adjust_window_position(id)
    @bubble_sprite.opacity = 255
  end
  
  #--------------------------------------------------------------------------
  # new method: create_bubble_sprite
  #--------------------------------------------------------------------------
  def create_bubble_sprite(filename = nil)
    return unless YES::POP_MESSAGE::EFFECT_SETTING[:bubble_tag]
    filename = YES::POP_MESSAGE::EFFECT_SETTING[:bubble_name] unless filename
    bitmap = Cache.system(filename)
    @bubble_sprite ||= Sprite.new
    @bubble_sprite.z = self.z
    @bubble_sprite.opacity = 0
    @bubble_sprite.bitmap = bitmap
    @bubble_sprite.src_rect.set(0, 0, bitmap.width, bitmap.height / 2)
  end
  
  #--------------------------------------------------------------------------
  # new method: adjust_window_position
  #--------------------------------------------------------------------------
  def adjust_window_position(id)
    hash = $game_map.events
    character = id <= 0 ? $game_player : hash[id]
    #---
    bitmap = Cache.character(character.character_name)
    sign = character.character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      ch = bitmap.height / 4
    else
      ch = bitmap.height / 8
    end
    #---
    self.x = character.screen_x - self.width / 2
    self.y = character.screen_y - self.height - ch
    if @bubble_sprite
      @bubble_sprite.x = character.screen_x - @bubble_sprite.width / 2
      @bubble_sprite.y = self.y + self.height
      @bubble_sprite.y += YES::POP_MESSAGE::EFFECT_SETTING[:bubble_offset_y]
    end
    #---
    end_x = self.x + self.width
    self.x = 0 if self.x < 0
    self.x = Graphics.width - self.width if end_x > Graphics.width
    if self.y < 0
      self.y = character.screen_y 
      if @bubble_sprite
        @bubble_sprite.y = self.y - @bubble_sprite.height
        @bubble_sprite.y -= YES::POP_MESSAGE::EFFECT_SETTING[:bubble_offset_y]
        @bubble_sprite.src_rect.set(0, @bubble_sprite.height, 
                                    @bubble_sprite.width, @bubble_sprite.height)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: adjust_window_size
  #--------------------------------------------------------------------------
  def adjust_window_size
    text = convert_escape_characters($game_message.all_text)
    #---
    width = cal_width_line(text) + standard_padding * 2
    width = width + new_line_x
    if YES::POP_MESSAGE::LIMIT_SETTING[:width] > 0
      width = [YES::POP_MESSAGE::LIMIT_SETTING[:width], width]
    end
    #---
    lines = cal_number_line(text)
    if YES::POP_MESSAGE::LIMIT_SETTING[:lines] > 0
      lines = [YES::POP_MESSAGE::LIMIT_SETTING[:lines], lines].min
    end
    if YES::POP_MESSAGE::EFFECT_SETTING[:default_face]
      unless $game_message.face_name.empty?
        lines = [4, lines].max
      end
    end
    #---
    self.width = width
    self.height = fitting_height(lines)
    create_contents
  end
    
  #--------------------------------------------------------------------------
  # new method: cal_number_line
  #--------------------------------------------------------------------------
  def cal_number_line(text)
    result = 0
    text.each_line { result += 1 }
    return result
  end
  
  #--------------------------------------------------------------------------
  # new method: cal_width_line
  #--------------------------------------------------------------------------
  def cal_width_line(text)
    result = 0
    text.each_line { |line|
      result = text_size(line).width if result < text_size(line).width
    }
    return result
  end
  
  #--------------------------------------------------------------------------
  # new method: cancel_pop_message
  #--------------------------------------------------------------------------
  def cancel_pop_message
    update_placement
    reset_size
    create_bubble_sprite
  end
  
  #--------------------------------------------------------------------------
  # new method: reset_size
  #--------------------------------------------------------------------------
  def reset_size
    self.width = window_width
    self.height = window_height
    update_padding
    create_contents
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_face
  #--------------------------------------------------------------------------
  alias yes_pop_message_draw_face draw_face
  def draw_face(face_name, face_index, x, y, enabled = true)
    return unless YES::POP_MESSAGE::EFFECT_SETTING[:default_face]
    yes_pop_message_draw_face(face_name, face_index, x, y, enabled)
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_placement
  #--------------------------------------------------------------------------
  alias yes_pop_message_update_placement update_placement
  def update_placement
    yes_pop_message_update_placement
    self.x = 0
  end
  
  #--------------------------------------------------------------------------
  # alias method: process_all_text
  #--------------------------------------------------------------------------
  alias yes_pop_message_process_all_text process_all_text
  def process_all_text
    pop_message_initialize($game_message.all_text)
    yes_pop_message_process_all_text
  end
  
  #--------------------------------------------------------------------------
  # alias method: open_and_wait
  #--------------------------------------------------------------------------
  alias yes_pop_message_open_and_wait open_and_wait
  def open_and_wait
    yes_pop_message_open_and_wait
    @face_window ||= Window_MessageFace.new
    @face_window.draw_content_face
    @face_window.x = self.x + 8
    @face_window.y += self.y + self.height
    @face_window.show_face
  end
  
  #--------------------------------------------------------------------------
  # alias method: close_and_wait
  #--------------------------------------------------------------------------
  alias yes_pop_message_close_and_wait close_and_wait
  def close_and_wait
    @face_window.hide_face
    @bubble_sprite.opacity = 0 if @bubble_sprite
    yes_pop_message_close_and_wait
    cancel_pop_message
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias yes_pop_message_update update
  def update
    yes_pop_message_update
    if @face_window
      @face_window.update 
      @face_window.z = self.z
    end
    if @bubble_sprite
      @bubble_sprite.update 
      @bubble_sprite.z = self.z
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: adjust_message_window_size
  # YEA - Message System Compatible
  #--------------------------------------------------------------------------
  def adjust_message_window_size
    start_name_window
  end
  
end # Window_Message

#==============================================================================
# Å° Window_NameMessage
#==============================================================================
if $imported["YEA-MessageSystem"]
class Window_NameMessage < Window_Base
  
  #--------------------------------------------------------------------------
  # set_x_position
  #--------------------------------------------------------------------------
  alias yes_pm_set_x_position set_x_position
  def set_x_position(x_position)
    yes_pm_set_x_position(x_position)
    self.x += @message_window.new_line_x if x_position == 1
    self.z = @message_window.z
  end
  
end # Window_NameMessage
end

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================