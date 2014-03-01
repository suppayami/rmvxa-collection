#==============================================================================
# 
# Å• Yami Engine Symphony - Face Cache
# -- Last Updated: 2012.12.10
# -- Level: Nothing
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-FaceCache"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.12.10 - Fixed: F12 problem.
# 2012.11.14 - Started and Finished Script.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides a Faces-cache for default Window_Base, which enhances
# a little performance for Windows.
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
# it will run with RPG Maker VX without adjusting.
# This script will not work with a custom draw face method.
# 
#==============================================================================

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
  # self.clear_face_cache
  #--------------------------------------------------------------------------
  def self.clear_face_cache
    Cache.clear_face
  end
  
end # YES

#==============================================================================
# Å° Cache
#==============================================================================

module Cache
  
  #--------------------------------------------------------------------------
  # new method: storage_face
  #--------------------------------------------------------------------------
  def self.storage_face(bitmap, name)
    @face_cache ||= {}
    @face_cache[name] = bitmap unless @face_cache.has_key?(name)
    @face_cache[name]
  end
  
  #--------------------------------------------------------------------------
  # new method: restore_face
  #--------------------------------------------------------------------------
  def self.restore_face(name)
    return false if @face_cache.nil? || !@face_cache.has_key?(name)
    @face_cache[name]
  end
  
  #--------------------------------------------------------------------------
  # new method: clear_face
  #--------------------------------------------------------------------------
  def self.clear_face
    @face_cache ||= {}
    @face_cache.each_value { |b| b.dispose unless b.disposed? }
    @face_cache.clear
  end
  
end # Cache

#==============================================================================
# Å° Window_Base
#==============================================================================

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: init
  #--------------------------------------------------------------------------
  class <<self; alias yes_face_cache_init init; end
  def self.init
    Cache.clear_face
    yes_face_cache_init
  end
  
end # DataManager

#==============================================================================
# Å° Window_Base
#==============================================================================

class Window_Base < Window

  #--------------------------------------------------------------------------
  # overwrite method: draw_face
  #--------------------------------------------------------------------------
  def draw_face(face_name, face_index, x, y, enabled = true)
    cache = Cache.restore_face(face_name + face_index.to_s)
    if !cache
      cache = Bitmap.new(96, 96)
      bitmap = Cache.face(face_name)
      rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
      cache.blt(0, 0, bitmap, rect)
      Cache.storage_face(cache, face_name + face_index.to_s)
      bitmap.dispose
    end
    contents.blt(x, y, cache, Rect.new(0, 0, 96, 96), enabled ? 255 : translucent_alpha)
  end
  
end # Window_Base

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================