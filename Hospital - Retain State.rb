#==============================================================================
# 
# Å• Yami Engine Symphony - Hospital: Retain State
# -- Last Updated: 2012.11.10
# -- Level: Easy
# -- Requires: YES - Hospital
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-HospitalRS"] = true

#==============================================================================
# Å• Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.11.10 - Started and Finished Script.
# 
#==============================================================================
# Å• Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script keeps some states remain on actors when hospitalize.
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
# Å• Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

#==============================================================================
# Å° Regular Expression
#==============================================================================

module REGEXP
  module HOSPITAL
    RETAIN_STATE = /<(?:RETAIN_STATE|retain state)>/i
  end # HOSPITAL
end # REGEXP

#==============================================================================
# Å° DataManager
#==============================================================================

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_hospital_rs load_database; end
  def self.load_database
    load_database_hospital_rs
    load_notetags_hospital_rs
  end
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_hospital_rs
  #--------------------------------------------------------------------------
  def self.load_notetags_hospital_rs
    $data_states.each { |obj|
      next if obj.nil?
      obj.load_notetags_hospital_rs
    }
  end
  
end # DataManager

#==============================================================================
# Å° RPG::BaseItem
#==============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_hospital_rs
  #--------------------------------------------------------------------------
  def load_notetags_hospital_rs
    @hospital_rs = false
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::HOSPITAL::RETAIN_STATE
        @hospital_rs = true
      end
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: hospital_retain?
  #--------------------------------------------------------------------------
  def hospital_retain?
    @hospital_rs
  end
  
end # RPG::BaseItem

#==============================================================================
# Å° Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # hospitalize_states
  #--------------------------------------------------------------------------
  alias rs_hospitalize_states hospitalize_states
  def hospitalize_states
    rs_hospitalize_states.select { |state| !state.hospital_retain? }
  end
    
end # Game_Actor

#==============================================================================
# 
# Å• End of File
# 
#==============================================================================