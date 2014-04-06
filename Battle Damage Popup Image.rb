$imported = {} if $imported.nil?
$imported["YES-BattlePopupImage"] = true

#==============================================================================
# ■ BattleLuna
#==============================================================================

module BattleLuna
  module Addon
    
    BATTLE_POPUP[:image_setup] = {
      # For numbers, there are some options below.
      :enable_numbers =>  false,
      
      # For words, this script will search for image in Graphics/Systems 
      # with name is the word display in default. Config in :word_setting.
      # Will create default text if cannot find image.
      # For example:
      # "MISS" will search for image MISS in Graphics/System
      # If :add_state  => "%s", it will search for image STATENAME
      :enable_words   =>  false,
      
      # Setup for numbers
      :numbers_setup  =>  {
        # Setup images.
        :hp_number_dmg    =>  "Number+",
        :hp_number_heal   =>  "Number-",
        :mp_number_dmg    =>  "MP_Number+",
        :mp_number_heal   =>  "MP_Number-",
        :tp_number_dmg    =>  "MP_Number+",
        :tp_number_heal   =>  "MP_Number-",
        
        # Setup style.
        :spacing          =>  -4,
      },
    } # Basic setting for image
    
  end # Addon
end # BattleLuna

#==============================================================================
# ■ Sprite_PopupLuna
#==============================================================================
if $imported["YES-BattlePopup"]
class Sprite_PopupLuna < Sprite
  
  #--------------------------------------------------------------------------
  # new method: setting_image
  #--------------------------------------------------------------------------
  def setting_image
    BattleLuna::Addon::BATTLE_POPUP[:image_setup]
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_bitmap
  #--------------------------------------------------------------------------
  alias battle_luna_dpip_create_bitmap create_bitmap
  def create_bitmap
    case @rule
    when :hp_dmg, :hp_heal, :mp_dmg, :mp_heal, :tp_dmg, :tp_heal
      if setting_image[:enable_numbers]
        create_image_bitmap
      else
        battle_luna_dpip_create_bitmap
      end
    else
      if setting_image[:enable_words]
        create_word_bitmap
      else
        battle_luna_dpip_create_bitmap
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: create_image_bitmap
  #--------------------------------------------------------------------------
  def create_image_bitmap
    case @rule
    when :hp_dmg; num_bitmap = setting_image[:numbers_setup][:hp_number_dmg]
    when :mp_dmg; num_bitmap = setting_image[:numbers_setup][:mp_number_dmg]
    when :tp_dmg; num_bitmap = setting_image[:numbers_setup][:tp_number_dmg]
    when :hp_heal; num_bitmap = setting_image[:numbers_setup][:hp_number_heal]
    when :mp_heal; num_bitmap = setting_image[:numbers_setup][:mp_number_heal]
    when :tp_heal; num_bitmap = setting_image[:numbers_setup][:tp_number_heal]
    end
    num_bitmap = Cache.system(num_bitmap)
    #---
    bw = Graphics.width
    bh = num_bitmap.height * 2
    bitmap = Bitmap.new(bw, bh)
    #---
    spacing  = setting_image[:numbers_setup][:spacing]
    nwidth   = num_bitmap.width / 10
    nheight  = num_bitmap.height
    ncount   = @data[0].size
    twidth   = ncount * (nwidth + spacing) - spacing
    offset_x = [(bw - twidth) / 2, 0].max
    #---
    (0...ncount).each { |index|
      x = offset_x + index * (nwidth + spacing)
      number = @data[0][index].to_i
      rect   = Rect.new(nwidth * number, 0, nwidth, nheight)
      bitmap.blt(x, 0, num_bitmap, rect)
    }
    bitmap
  end
  
  #--------------------------------------------------------------------------
  # new method: create_word_bitmap
  #--------------------------------------------------------------------------
  def create_word_bitmap
    begin
      word_bitmap = Cache.system(@data[0])
    rescue
      return battle_luna_dpip_create_bitmap
    end
    #---
    bw = Graphics.width
    bh = word_bitmap.height
    bitmap = Bitmap.new(bw, bh)    
    offset_x = [(bw - word_bitmap.width) / 2, 0].max
    bitmap.blt(offset_x, 0, word_bitmap, word_bitmap.rect)
    bitmap
  end
  
end # Sprite_PopupLuna
end