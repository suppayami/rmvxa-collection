#==============================================================================
# 
# ▼ Yami Engine Symphony - Battle Symphony
# -- Version: 1.16e (2014.09.11)
# -- Level: Easy, Normal, Hard, Very Hard
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-BattleSymphony"] = true

#==============================================================================
# ▼ Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2014.09.11 - Release Build 1.16e.
# 2014.07.22 - Release Build 1.16d.
# 2014.03.24 - Release Build 1.16c.
# 2014.02.26 - Release Build 1.16b.
# 2014.01.20 - Release Build 1.16.
# 2013.03.04 - Release Build 1.15.
# 2013.02.07 - Release Build 1.14.
# 2013.02.01 - Release Build 1.13.
# 2013.01.12 - Release Build 1.12.
# 2013.01.09 - Release Build 1.11.
# 2013.01.03 - Release Build 1.10.
# 2012.11.29 - Release Build 1.09.
# 2012.11.29 - Release Build 1.08.
# 2012.11.28 - Release Build 1.07.
# 2012.11.25 - Release Build 1.06.
# 2012.11.24 - Release Build 1.05.
# 2012.11.16 - Release Build 1.04.
# 2012.11.15 - Release Build 1.03.
# 2012.11.12 - Release Build 1.02.
# 2012.11.08 - Release Build 1.01.
# 2012.10.20 - Finished Script.
# 2012.07.01 - Started Script.
# 
#==============================================================================
# ▼ Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Core Engine of Symphony. This script provides a complicated visual battle
# which can be customized and many add-on awaited in the future.
# -----------------------------------------------------------------------------
# There are 8 Sections of Script:
# 
# Section I. Basic Settings (S-01)
# Section II. Default Actions (S-02)
# Section III. AutoSymphony (S-03)
# Section IV. Default Symphony Tags (S-04)
# Section V. Imports Symphony Tags (S-05)
# Section VI. Sprites Initialization (S-06)
# Section VII. Icons Sprites Initialization (S-07)
# Section VIII. Core Script (S-08)
#
# You can search these sections by the code next to them (S-xx).
#
#==============================================================================
# ▼ Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
#
# To make this script work correctly with YEA - Battle Engine Ace, you have to
# put this script under YEA - Battle Engine Ace.
# 
#==============================================================================
# ▼ Credits
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Symphony Tags: Yanfly (From his Melody Tags).
# Inspired: Yanfly, Nessiah, EvilEagles.
# Testers: Many Guys in RPG Maker Community.
# Many Descriptions: Yanfly (From his Yanfly Engine Melody)
# 
#==============================================================================

#==============================================================================
# Section I. Basic Settings (S-01)
# -----------------------------------------------------------------------------
# These are all basic requirements for running Battle Engine Symphony.
# Please pay attention to those settings before you touch and read next
# sections and add-ons.
#==============================================================================
module SYMPHONY
  module View
    # Set this to false to set Battle View to Empty.
    # All Sprites of actors as well as Icon (Weapon, Item...) will be hide.
    # All other Symphony Tags are still available.    
    EMPTY_VIEW = false
    
    # Set Party default Direction. For Number of Direction, check NumPad on the
    # Keyboard. Troop Direction will be opposited with Party Direction.
    PARTY_DIRECTION = 4
    
    # Set Party default Location. If You have more than 4 Actors in Battle, You
    # have to add more index in the hash below.
    # For example: If you have 5 Actors, You will have to add default Location
    # for 5th Actor by adding: 4 => [Location X, Location Y], 
    # (Don't forget the comma at the end of each line)
    ACTORS_POSITION = { # Begin.
      0 =>  [480, 224],
      1 =>  [428, 244],
      2 =>  [472, 264],
      3 =>  [422, 284],
    } # End.
  end # View
  module Visual
    # Set this to false to disable Weapon Icon creating for non-charset Battlers.
    # Recommend not to enable this, unless You use a Battler which doesn't show
    # its own weapon in the Battler-set.
    WEAPON_ICON_NON_CHARSET = false
    
    # Set this to true to disable auto Move Posing. When set this to false,
    # You can let the actor to change to any pose while moving.
    DISABLE_AUTO_MOVE_POSE = true
    
    # Set this to true to enable shadow beneath battler.
    BATTLER_SHADOW = true
    
    # Enemies default attack animation ID.
    # First Attack Animation and Second Attack Animation can be defined by
    # notetags <atk ani 1: x> and <atk ani 2: x> respectively.
    ENEMY_ATTACK_ANIMATION = 1
  end # Visual
  module Fixes
    # Set this to false to disable auto turn-off the immortal flag. Many people
    # forgot to turn-off immortal flag in an actions sequence, so the targets
    # remain alive even their HP reach zero.
    # Auto Turn-off Immortal will be push to Finish Actions.
    AUTO_IMMORTAL_OFF = true
  end # Fixes
end # SYMPHONY

#==============================================================================
# Section II. Default Actions (S-02)
# -----------------------------------------------------------------------------
# These are all Default Actions of Symphony. There are Magic Action, 
# Physical Action, Item Action and some Misc Actions. If You are really
# good at Symphony Tags and want to customize all of these actions, please
# pay attention here.
# Note: You can use Symphony Tags in each skills so You don't have to check
# this if these actions settings are good for You.
#==============================================================================
module SYMPHONY
  module DEFAULT_ACTIONS
      
    #==========================================================================
    # Default Magic Actions
    # -------------------------------------------------------------------------
    # These are the default magic actions for all Magic Skills as well as Certain
    # hit Skills. Battlers will play these actions when use a Magic/Certain Hit
    # Skill unless You customize it with Symphony Tags.
    #==========================================================================
    MAGIC_SETUP =[
      ["MESSAGE"],
      ["MOVE USER", ["FORWARD", "WAIT"]],
      ["POSE", ["USER", "CAST"]],
      ["STANCE", ["USER", "CAST"]],
    ] # Do not remove this.
    MAGIC_WHOLE =[
      ["IMMORTAL", ["TARGETS", "TRUE"]],
      ["AUTO SYMPHONY", ["SKILL FULL"]],
    ] # Do not remove this.
    MAGIC_TARGET =[
    ] # Do not remove this.
    MAGIC_FOLLOW =[
      ["WAIT FOR MOVE"],
    ] # Do not remove this.
    MAGIC_FINISH =[
      ["IMMORTAL", ["TARGETS", "FALSE"]],
      ["AUTO SYMPHONY", ["RETURN ORIGIN"]],
      ["WAIT FOR MOVE"],
      ["WAIT", ["12", "SKIP"]],
    ] # Do not remove this.
      
    #==========================================================================
    # Default Physical Actions
    # -------------------------------------------------------------------------
    # These are the default physical actions for all Physical Skills as well as
    # Normal Attack. Battlers will play these actions when use a Physical
    # Skill unless You customize it with Symphony Tags.
    #==========================================================================
    PHYSICAL_SETUP =[
      ["MESSAGE"],
      ["MOVE USER", ["FORWARD", "WAIT"]],
    ] # Do not remove this.
    PHYSICAL_WHOLE =[
    ] # Do not remove this.
    PHYSICAL_TARGET =[
      ["IMMORTAL", ["TARGETS", "TRUE"]],
      ["POSE", ["USER", "FORWARD"]],
      ["STANCE", ["USER", "FORWARD"]],
      ["MOVE USER", ["TARGET", "BODY", "WAIT"]],
      ["AUTO SYMPHONY", ["SINGLE SWING"]],
      ["AUTO SYMPHONY", ["SKILL FULL", "unless attack"]],
      ["AUTO SYMPHONY", ["ATTACK FULL", "if attack"]],
    ] # Do not remove this.
    PHYSICAL_FOLLOW =[
      ["WAIT FOR MOVE"],
    ] # Do not remove this.
    PHYSICAL_FINISH =[
      ["IMMORTAL", ["TARGETS", "FALSE"]],
      ["ICON DELETE", ["USER", "WEAPON"]],
      ["AUTO SYMPHONY", ["RETURN ORIGIN"]],
      ["WAIT FOR MOVE"],
      ["WAIT", ["12", "SKIP"]],
    ] # Do not remove this.
    
    #==========================================================================
    # Default Item Actions
    # -------------------------------------------------------------------------
    # These are the default item actions for all Items. Battlers will play these
    # actions when use an Item unless You customize it with Symphony Tags.
    #==========================================================================
    ITEM_SETUP =[
      ["MESSAGE"],
      ["MOVE USER", ["FORWARD", "WAIT"]],
      ["AUTO SYMPHONY", ["ITEM FLOAT"]],
    ] # Do not remove this.
    ITEM_WHOLE =[
      ["IMMORTAL", ["TARGETS", "TRUE"]],
      ["AUTO SYMPHONY", ["ITEM FULL"]],
    ] # Do not remove this.
    ITEM_TARGET =[
    ] # Do not remove this.
    ITEM_FOLLOW =[
      ["WAIT FOR MOVE"],
      ["IMMORTAL", ["TARGETS", "FALSE"]],
    ] # Do not remove this.
    ITEM_FINISH =[
      ["AUTO SYMPHONY", ["RETURN ORIGIN"]],
      ["WAIT FOR MOVE"],
      ["WAIT", ["12", "SKIP"]],
    ] # Do not remove this.
    
    #==========================================================================
    # Critical Action
    # -------------------------------------------------------------------------
    # This is the critical action. This action will be played when a battler 
    # scores a critical hit.
    #==========================================================================
    CRITICAL_ACTIONS =[
      ["SCREEN", ["FLASH", "30", "255", "255", "255"]],
    ] # Do not remove this.
    
    #==========================================================================
    # Miss Action
    # -------------------------------------------------------------------------
    # This is the miss action. This action will be played when a battler attacks
    # miss.
    #==========================================================================
    MISS_ACTIONS =[
      ["POSE", ["TARGET", "EVADE"]],
    ] # Do not remove this.
    
    #==========================================================================
    # Evade Action
    # -------------------------------------------------------------------------
    # This is the evade action. This action will be played when a battler evades.
    #==========================================================================
    EVADE_ACTIONS =[
      ["POSE", ["TARGET", "EVADE"]],
    ] # Do not remove this.

    #==========================================================================
    # Fail Action
    # -------------------------------------------------------------------------
    # This is the fail action. This action will be played when a battler fails
    # on casting skill.
    #==========================================================================
    FAIL_ACTIONS =[
    
    ] # Do not remove this.
      
    #==========================================================================
    # Damaged Action
    # -------------------------------------------------------------------------
    # This is the damaged action. This action will be played when a battler is
    # damaged.
    #==========================================================================
    DAMAGED_ACTION = [
      ["POSE", ["TARGET", "DAMAGE"]],
      ["STANCE", ["TARGET", "STRUCK"]],
    ] # Do not remove this.
      
    #==========================================================================
    # Counter Action
    # -------------------------------------------------------------------------
    # This is the counter action. This action will be played when a battler
    # counters an attack.
    #==========================================================================
    COUNTER_ACTION = [
      ["MOVE COUNTER SUBJECT", ["FORWARD", "WAIT"]],
      ["AUTO SYMPHONY", ["SINGLE SWING COUNTER"]],
      ["AUTO SYMPHONY", ["SKILL FULL COUNTER"]],
      ["ICON DELETE", ["COUNTER SUBJECT", "WEAPON"]],
      ["POSE", ["COUNTER SUBJECT", "BREAK"]],
      ["STANCE", ["COUNTER SUBJECT", "BREAK"]],
    ] # Do not remove this.
      
    #==========================================================================
    # Reflect Action
    # -------------------------------------------------------------------------
    # This is the reflect action. This action will be played when a battler
    # reflects a magic.
    #==========================================================================
    REFLECT_ACTION = [
      ["MOVE REFLECT SUBJECT", ["FORWARD", "WAIT"]],
      ["POSE", ["REFLECT SUBJECT", "CAST"]],
      ["STANCE", ["REFLECT SUBJECT", "CAST"]],
      ["AUTO SYMPHONY", ["SKILL FULL COUNTER"]],
      ["POSE", ["REFLECT SUBJECT", "BREAK"]],
      ["STANCE", ["REFLECT SUBJECT", "BREAK"]],
    ] # Do not remove this.
    
    #==========================================================================
    # Substitute Action
    # -------------------------------------------------------------------------
    # This is the substitute action. This action will be played when a battler
    # performs substitute.
    #==========================================================================
    SUBSTITUTE_ACTION = [
      ["TELEPORT SUBSTITUTE SUBJECT", ["TARGET", "BODY", "WAIT"]],
    ] # Do not remove this.
    
    SUBSTITUTE_END_ACTION = [
      ["TELEPORT SUBSTITUTE SUBJECT", ["ORIGIN", "WAIT"]],
    ] # Do not remove this.
    
  end # DEFAULT_ACTIONS
end # SYMPHONY

#==============================================================================
# Section III. AutoSymphony (S-03)
# -----------------------------------------------------------------------------
# These are all Settings of AutoSymphony. You can make a sequence of Actions
# and Symphony Tags and reuse it with a single tag: AutoSymphony.
#==============================================================================
module SYMPHONY
  AUTO_SYMPHONY = { # Start
    # "Key" => [Symphony Sequence],
    
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: return origin
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This AutoSymphony returns the active battler and all of its targets back
    # to their original locations. Used often at the end of a skill, item,
    # or any other action sequence.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "RETURN ORIGIN" => [
      ["STANCE", ["USER", "ORIGIN"]],
      ["MOVE USER", ["ORIGIN", "WAIT"]],
      ["POSE", ["USER", "BREAK"]],
      ["MOVE EVERYTHING", ["ORIGIN"]],
    ], # end RETURN ORIGIN
     
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: single swing
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This causes the active battler to perform a single-handed weapon swing
    # downwards.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "SINGLE SWING" => [
      ["ICON CREATE", ["USER", "WEAPON"]],
      ["ICON", ["USER", "WEAPON", "SWING"]],
      ["POSE", ["USER", "2H SWING"]],
      ["STANCE", ["USER", "ATTACK"]],
    ], # end SINGLE SWING
      
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: single swing counter
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This causes the countering battler to perform a single-handed weapon 
    # swing downwards.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "SINGLE SWING COUNTER" => [
      ["ICON CREATE", ["COUNTER SUBJECT", "WEAPON"]],
      ["ICON", ["COUNTER SUBJECT", "WEAPON", "SWING"]],
      ["POSE", ["COUNTER SUBJECT", "2H SWING"]],
      ["STANCE", ["USER", "ATTACK"]],
    ], # end SINGLE SWING COUNTER
             
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: item float
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This causes the active battler to enter a "Cast" stance to make the
    # active battler appear to throw the item upward. The icon of the item
    # is then created and floats upward.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "ITEM FLOAT" => [
      ["POSE", ["USER", "CAST"]],
      ["STANCE", ["USER", "ITEM"]],
      ["ICON CREATE", ["USER", "ITEM"]],
      ["ICON", ["USER", "ITEM", "FLOAT", "WAIT"]],
    ], # end ITEM FLOAT
      
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: attack full
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This triggers the full course for an attack effect. Attack's animation
    # plays and waits until it ends. The damage, status changes, and anything
    # else the attack may do to the target. Once the attack effect is over,
    # the target is sent sliding backwards a little bit.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "ATTACK FULL" => [
      ["ATTACK EFFECT", ["COUNTER CHECK"]],
      ["ATTACK ANIMATION", ["WAIT"]],
      ["ATTACK EFFECT", ["WHOLE"]],
      ["MOVE TARGETS", ["BACKWARD"]],
    ], # end ATTACK FULL
      
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: skill full
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This trigger the full course for a skill's effect. The skill animation
    # plays and waits to the end. The damage, status changes, and anything
    # else the skill may do to the target. Once the skill effect is over, the
    # target is sent sliding backwards a little bit.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "SKILL FULL" => [
      ["SKILL EFFECT", ["COUNTER CHECK"]],
      ["SKILL EFFECT", ["REFLECT CHECK"]],
      ["SKILL ANIMATION", ["WAIT"]],
      ["SKILL EFFECT", ["WHOLE"]],
      ["MOVE TARGETS", ["BACKWARD", "unless skill.for_friend?"]],
    ], # end SKILL FULL
      
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: skill full counter
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This trigger the full course for a skill's effect. The skill animation
    # plays and waits to the end. The damage, status changes, and anything
    # else the skill may do to the target. Once the skill effect is over, the
    # target is sent sliding backwards a little bit.
    # This trigger is used in countering/reflecting skill.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "SKILL FULL COUNTER" => [
      ["ATTACK ANIMATION", ["TARGETS", "WAIT", "if attack"]],
      ["SKILL ANIMATION", ["TARGETS", "WAIT", "unless attack"]],
      ["SKILL EFFECT", ["WHOLE"]],
      ["MOVE TARGETS", ["BACKWARD", "unless skill.for_friend?"]],
    ], # end SKILL FULL COUNTER
    
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # autosymphony: item full
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This triggers the full course for an item's effect. The item animation
    # plays and waits to the end. The damage, status changes, and anything
    # else the item may do to the target. Once the skill effect is over, the
    # target is sent sliding backwards a little bit.
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used AutoSymphony. Do not remove this.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    "ITEM FULL" => [
      ["SKILL EFFECT", ["COUNTER CHECK"]],
      ["SKILL EFFECT", ["REFLECT CHECK", "unless skill.for_all?"]],
      ["SKILL ANIMATION", ["WAIT"]],
      ["ICON", ["USER", "ITEM", "FADE OUT", "WAIT"]],
      ["ICON DELETE", ["USER", "ITEM"]],
      ["SKILL EFFECT", ["WHOLE"]],
      ["MOVE TARGETS", ["BACKWARD", "unless item.for_friend?"]],
    ], # end ITEM FULL
    
  } # Do not remove this.
end # SYMPHONY

#==============================================================================
# Section IV. Default Symphony Tags (S-04)
# -----------------------------------------------------------------------------
# These are all Default Symphony Tags. They define actions that will be played
# when the tags are called. All these tags are optimized for the best
# performance through testings.
# -----------------------------------------------------------------------------
# Do not edit anything below here unless You have read carefully the Tutorial
# at Creating and Editing Symphony Tags.
#==============================================================================
#==============================================================================
# ■ Scene_Battle - Defines Tags Names
#==============================================================================
#==============================================================================
# ■ Scene_Battle - Defines Tags Names
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # new method: perform_actions_list
  #--------------------------------------------------------------------------
  def perform_actions_list(actions, targets)
    #--- Create Formers ---
    former_action = @action
    former_values = (@action_values != nil) ? @action_values.clone : nil
    former_targets = (@action_targets != nil) ? @action_targets.clone : nil
    former_item = (@scene_item != nil) ? @scene_item.clone : nil
    #--- Create Current ---
    @action_targets = targets
    actions.each { |action|
      @action = action[0].upcase; @action_values = action[1]
      @action_values.each { |s| s.upcase! if s.is_a?(String) } if @action_values
      break unless SceneManager.scene_is?(Scene_Battle)
      break if @subject && @subject.dead?
      next unless action_condition_met
      case @action.upcase
      
        when /ANIMATION[ ](\d+)|SKILL ANIMATION|ATTACK ANIMATION|ANIMATION/i
          action_animation
      
        when /ATTACK EFFECT|SKILL EFFECT/i
          action_skill_effect
          
        when /AUTO SYMPHONY|AUTOSYMPHONY/i
          action_autosymphony
          
        when /ICON CREATE|CREATE ICON/i
          action_create_icon
          
        when /ICON DELETE|DELETE ICON/i
          action_delete_icon
          
        when "ICON", "ICON EFFECT"
          action_icon_effect
          
        when /ICON THROW[ ](.*)/i
          action_icon_throw
          
        when /IF[ ](.+)/i
          action_condition
          
        when /JUMP[ ](.*)/i
          action_move
                    
        when /MESSAGE/i
          action_message
          
        when /MOVE[ ](.*)/i
          action_move
          
        when /IMMORTAL/i
          action_immortal
          
        when /POSE/i
          action_pose
          
        when /STANCE/i
          action_stance
          
        when /UNLESS[ ](.+)/i
          action_condition
          
        when /TELEPORT[ ](.*)/i
          action_move
          
        when "WAIT", "WAIT SKIP", "WAIT FOR ANIMATION", "WAIT FOR MOVE",
          "WAIT FOR MOVEMENT", "ANI WAIT"
          action_wait
          
        else
          imported_symphony
      end
    }
    #--- Release Formers ---
    @action = former_action
    @action_values = former_values
    @action_targets = former_targets
    @scene_item = former_item
  end
  
end # Scene_Battle
#==============================================================================
# ■ Scene_Battle - Defines Tags Actions
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # new method: action_condition_met
  #--------------------------------------------------------------------------
  def action_condition_met
    target = @action_targets[0]
    targets = @action_targets
    user = @subject
    skill = item = @scene_item
    attack = false
    if @counter_subject || (user.current_action && user.current_action.attack?)
      attack = true
    end
    weapons = user.weapons if user.actor?
    @action_condition ||= []
    @action_condition.pop if @action.upcase == "END"
    if @action_condition.size > 0
      @action_condition.each { |action_condition|
        action_condition =~ /(IF|UNLESS)[ ](.+)/i
        condition_type = $1.upcase
        condition_value = $2.downcase
        #---
        if condition_type == "IF"
          return false unless eval(condition_value)
        elsif condition_type == "UNLESS"
          return false if eval(condition_value)
        end
      }
    end
    if @action_values
      @action_values.each { |value|
        case value
        when /IF[ ](.*)/i
          eval("return false unless " + $1.to_s.downcase)
        when /UNLESS[ ](.*)/i
          eval("return false if " + $1.to_s.downcase)
        end
      }
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  # new method: get_action_mains
  #--------------------------------------------------------------------------
  def get_action_mains
    result = []
    case @action.upcase
    when /(?:USER)/i
      result.push(@subject) if @subject
    when /(?:TARGET|TARGETS)/i
      result = @action_targets
    when /(?:COUNTER SUBJECT)/i
      result = [@counter_subject]
    when /(?:REFLECT SUBJECT)/i
      result = [@reflect_subject]
    when /(?:SUBSTITUTE SUBJECT)/i
      result = [@substitute_subject]
    when /(?:ACTORS|PARTY|ACTORS LIVING)/i
      result = $game_party.alive_members
    when /(?:ALL ACTORS|ACTORS ALL)/i
      result = $game_party.battle_members
    when /(?:ACTORS NOT USER|PARTY NOT USER)/i
      result = $game_party.alive_members
      result.delete(@subject) if @subject
    when /(?:ENEMIES|TROOP|ENEMIES LIVING)/i
      result = $game_troop.alive_members
    when /(?:ALL ENEMIES|ENEMIES ALL)/i
      result = $game_troop.battle_members
    when /(?:ENEMIES NOT USER|ENEMIES NOT USER)/i
      result = $game_troop.alive_members
      result.delete(@subject) if @subject
    when /ACTOR[ ](\d+)/i
      result.push($game_party.battle_members[$1.to_i])
    when /ENEMY[ ](\d+)/i
      result.push($game_troop.battle_members[$1.to_i])
    when /(?:EVERYTHING|EVERYBODY)/i
      result = $game_party.alive_members + $game_troop.alive_members
    when /(?:EVERYTHING NOT USER|EVERYBODY NOT USER)/i
      result = $game_party.alive_members + $game_troop.alive_members
      result.delete(@subject) if @subject
    when /(?:ALLIES|FRIENDS)/i
      result = @subject.friends_unit.alive_members if @subject
    when /(?:OPPONENTS|RIVALS)/i
      result = @subject.opponents_unit.alive_members if @subject
    when /(?:FRIENDS NOT USER)/i
      if @subject
        result = @subject.friends_unit.alive_members 
        result.delete(@subject)
      end
    when /(?:FOCUS)/i
      result = @action_targets
      result.push(@subject) if @subject
    when /(?:NOT FOCUS|NON FOCUS)/i
      result = $game_party.alive_members + $game_troop.alive_members
      result -= @action_targets
      result.delete(@subject) if @subject
    else;
    end
    return result.compact
  end
  
  #--------------------------------------------------------------------------
  # new method: get_action_targets
  #--------------------------------------------------------------------------
  def get_action_targets
    result = []
    @action_values.reverse.each { |value|
      next if value.nil?
      case value.upcase
      when /(?:USER)/i
        result.push(@subject) if @subject
      when /(?:TARGET|TARGETS)/i
        result = @action_targets
      when /(?:COUNTER SUBJECT)/i
        result = [@counter_subject]
      when /(?:REFLECT SUBJECT)/i
        result = [@reflect_subject]
      when /(?:SUBSTITUTE SUBJECT)/i
        result = [@substitute_subject]
      when /(?:ACTORS|PARTY|ACTORS LIVING)/i
        result = $game_party.alive_members
      when /(?:ALL ACTORS|ACTORS ALL)/i
        result = $game_party.battle_members
      when /(?:ACTORS NOT USER|PARTY NOT USER)/i
        result = $game_party.alive_members
        result.delete(@subject) if @subject
      when /(?:ENEMIES|TROOP|ENEMIES LIVING)/i
        result = $game_troop.alive_members
      when /(?:ALL ENEMIES|ENEMIES ALL)/i
        result = $game_troop.battle_members
      when /(?:ENEMIES NOT USER|ENEMIES NOT USER)/i
        result = $game_troop.alive_members
        result.delete(@subject) if @subject
      when /ACTOR[ ](\d+)/i
        result.push($game_party.battle_members[$1.to_i])
      when /ENEMY[ ](\d+)/i
        result.push($game_troop.battle_members[$1.to_i])
      when /(?:EVERYTHING|EVERYBODY)/i
        result = $game_party.alive_members + $game_troop.alive_members
      when /(?:EVERYTHING NOT USER|EVERYBODY NOT USER)/i
        result = $game_party.alive_members + $game_troop.alive_members
        result.delete(@subject) if @subject
      when /(?:ALLIES|FRIENDS)/i
        result = @subject.friends_unit.alive_members if @subject
      when /(?:OPPONENTS|RIVALS)/i
        result = @subject.opponents_unit.alive_members if @subject
      when /(?:FRIENDS NOT USER)/i
        if @subject
          result = @subject.friends_unit.alive_members 
          result.delete(@subject)
        end
      when /(?:NOT FOCUS|NON FOCUS)/i
        result = $game_party.alive_members + $game_troop.alive_members
        result -= @action_targets
        result.delete(@subject)
      when /(?:FOCUS)/i
        result = @action_targets
        result.push(@subject) if @subject
      else;
      end
    }
    return result.compact
  end
  
  #--------------------------------------------------------------------------
  # new method: action_animation
  #--------------------------------------------------------------------------
  def action_animation
    targets = get_action_targets
    targets = @action_targets if ["SKILL ANIMATION", "ATTACK ANIMATION"].include?(@action.upcase)
    return if targets.size == 0
    #---
    case @action.upcase
    when /ANIMATION[ ](\d+)/i
      animation_id = [$1.to_i]
    when "SKILL ANIMATION", "ANIMATION"
      return unless @subject.current_action.item
      animation_id = [@subject.current_action.item.animation_id]
    when "ATTACK ANIMATION"
      animation_id = [@subject.atk_animation_id1]
      animation_id = [@subject.atk_animation_id2] if @subject.atk_animation_id2 > 0 && @action_values[1].to_i == 2
    when "LAST ANIMATION"
      animation_id = [@last_animation_id]
    end
    mirror = true if @action_values.include?("MIRROR")
    #---
    animation_id = [@subject.atk_animation_id1] if animation_id == [-1]
    #---
    ani_count = 0
    animation_id.each { |id|
      wait_for_animation if ani_count > 0
      mirror = !mirror if ani_count > 0 
      animation = $data_animations[id]
      #---
      return unless animation
      if animation.to_screen?; targets[0].animation_id = id; end
      if !animation.to_screen?
        targets.each {|target| target.animation_id = id}
      end
      targets.each {|target| target.animation_mirror = mirror}
      ani_count += 1
    }
    @last_animation_id = animation_id[0]
    return unless @action_values.include?("WAIT")
    wait_for_animation
  end
  
  #--------------------------------------------------------------------------
  # new method: action_skill_effect
  #--------------------------------------------------------------------------
  def action_skill_effect
    return unless @subject
    return unless @subject.alive?
    return unless @subject.current_action.item
    targets = @action_targets.uniq
    #--- substitute ---
    substitutes = []
    targets.each { |target|
      substitutes.push(target.friends_unit.substitute_battler)
    }
    substitutes = substitutes.uniq
    #---
    item = @subject.current_action.item
    #---
    if @action_values.include?("CLEAR")
      targets.each { |target| target.result.set_calc; target.result.clear }
      return
    end
    #---
    if @action_values.include?("COUNTER CHECK")
      targets.each { |target| target.result.set_counter }
      return
    elsif @action_values.include?("REFLECT CHECK")
      targets.each { |target| target.result.set_reflection }
      return
    end
    #---
    array = []
    array.push("calc") if @action_values.include?("CALC")
    array = ["perfect"] if @action_values.include?("PERFECT")
    @action_values.each {|value| array.push(value.downcase) unless ["PERFECT", "CALC"].include?(value)}
    array = ["calc", "dmg", "effect"] if @action_values.include?("WHOLE") || @action_values.size == 0
    #--- substitute flag ---
    if substitutes
      substitutes.each { |substitute|
        next unless substitute
        substitute.result.clear_bes_flag
        array.each {|value| str = "substitute.result.set_#{value}"; eval(str)}
      }
    end
    #---
    targets.each { |target| 
      target.result.clear_bes_flag
      array.each {|value| str = "target.result.set_#{value}"; eval(str)}
      item.repeats.times { invoke_item(target, item) } 
      target.result.clear_change_target
      @substitute_subject.result.clear_change_target if @substitute_subject
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_autosymphony
  #--------------------------------------------------------------------------
  def action_autosymphony
    key = @action_values[0].to_s.upcase
    return unless SYMPHONY::AUTO_SYMPHONY.include?(key)
    actions_list = SYMPHONY::AUTO_SYMPHONY[key]
    perform_actions_list(actions_list, @action_targets)
  end
  
  #--------------------------------------------------------------------------
  # new method: action_create_icon
  #--------------------------------------------------------------------------
  def action_create_icon
    targets = get_action_targets
    return if targets.size == 0
    return if SYMPHONY::View::EMPTY_VIEW
    #---
    case @action_values[1]
    when "WEAPON", "WEAPON1"
      symbol = :weapon1
      attachment = :hand1
    when "WEAPON2"
      symbol = :weapon2
      attachment = :hand2
    when "SHIELD"
      symbol = :shield
      attachment = :shield
    when "ITEM"
      symbol = :item
      attachment = :middle
    else
      symbol = @action_values[1]
      attachment = :middle
    end
    #---
    case @action_values[2]
    when "HAND", "HAND1"
      attachment = :hand1
    when "HAND2", "SHIELD"
      attachment = :hand2
    when "ITEM"
      attachment = :item
    when "MIDDLE", "BODY"
      attachment = :middle
    when "TOP", "HEAD"
      attachment = :top
    when "BOTTOM", "FEET", "BASE"
      attachment = :base
    end
    #---
    targets.each { |target|
      next if target.sprite.nil?
      next if !target.use_charset? && !SYMPHONY::Visual::WEAPON_ICON_NON_CHARSET && [:weapon1, :weapon2].include?(symbol)
      target.create_icon(symbol, @action_values[3].to_i)
      next if target.icons[symbol].nil?
      target.icons[symbol].set_origin(attachment)
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_delete_icon
  #--------------------------------------------------------------------------
  def action_delete_icon
    targets = get_action_targets
    return if targets.size == 0
    #---
    case @action_values[1]
    when "WEAPON", "WEAPON1"
      symbol = :weapon1
    when "WEAPON2"
      symbol = :weapon2
    when "SHIELD"
      symbol = :shield
    when "ITEM"
      symbol = :item
    else
      symbol = @action_values[1]
    end
    #---
    targets.each { |target| target.delete_icon(symbol) }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_icon_effect
  #--------------------------------------------------------------------------
  def action_icon_effect
    targets = get_action_targets
    return if targets.size == 0
    #---
    case @action_values[1]
    when "WEAPON", "WEAPON1"
      symbol = :weapon1
    when "WEAPON2"
      symbol = :weapon2
    when "SHIELD"
      symbol = :shield
    when "ITEM"
      symbol = :item
    else
      symbol = @action_values[1]
    end
    #---
    targets.each { |target|
      icon = target.icons[symbol]
      next if icon.nil?
      total_frames = 8
      case @action_values[2]
      when "ANGLE"
        angle = @action_values[3].to_i
        icon.set_angle(angle)
      when "ROTATE", "REROTATE"
        angle = @action_values[3].to_i
        angle = -angle if @action_values[2] == "REROTATE"
        total_frames = @action_values[4].to_i
        total_frames = 8 if total_frames == 0
        icon.create_angle(angle, total_frames)
      when /ANIMATION[ ](\d+)/i
        animation = $1.to_i
        if $data_animations[animation].nil?; return; end
        total_frames = $data_animations[animation].frame_max
        total_frames *= 4 unless $imported["YEA-CoreEngine"]
        total_frames *= YEA::CORE::ANIMATION_RATE if $imported["YEA-CoreEngine"]
        icon.start_animation($data_animations[animation])
      when /MOVE_X[ ](\d+)/i
        move_x = $1.to_i
        total_frames = @action_values[3].to_i
        total_frames = 8 if total_frames == 0
        icon.create_movement(move_x, icon.y, total_frames)
      when /MOVE_Y[ ](\d+)/i
        move_y = $1.to_i
        total_frames = @action_values[3].to_i
        total_frames = 8 if total_frames == 0
        icon.create_movement(icon.x, move_y, total_frames)
      when /CUR_X[ ]([\-]?\d+)/i
        move_x = icon.x + $1.to_i
        total_frames = @action_values[3].to_i
        total_frames = 8 if total_frames == 0
        icon.create_movement(move_x, icon.y, total_frames)
      when /CUR_Y[ ]([\-]?\d+)/i
        move_y = icon.y + $1.to_i
        total_frames = @action_values[3].to_i
        total_frames = 8 if total_frames == 0
        icon.create_movement(icon.x, move_y, total_frames)
      when "FADE IN"
        total_frames = @action_values[3].to_i
        total_frames = 8 if total_frames == 0
        rate = Integer(256.0/total_frames)
        icon.set_fade(rate)
      when "FADE OUT"
        total_frames = @action_values[3].to_i
        total_frames = 8 if total_frames == 0
        rate = Integer(256.0/total_frames)
        icon.set_fade(-rate)
      when "FLOAT"
        total_frames = @action_values[3].to_i
        total_frames = 24 if total_frames == 0
        icon.create_move_direction(8, total_frames, total_frames)
      when "SWING"
        total_frames = 10
        icon.set_angle(0)
        icon.create_angle(90, total_frames)
      when "UPSWING"
        total_frames = 10
        icon.set_angle(90)
        icon.create_angle(0, total_frames)
      when "STAB", "THRUST"
        total_frames = 8
        direction = Direction.direction(target.pose)
        direction = Direction.opposite(direction) if target.sprite.mirror
        case direction
        when 8
          icon_direction = 8
          icon.set_angle(-45)
        when 4
          icon_direction = 4
          icon.set_angle(45)
        when 6
          icon_direction = 6
          icon.set_angle(-135)
        when 2
          icon_direction = 2
          icon.set_angle(135)
        end
        icon.create_move_direction(Direction.opposite(icon_direction), 40, 1)
        icon.update
        icon.create_move_direction(icon_direction, 32, total_frames)
      when "CLAW"
        total_frames = 8
        direction = Direction.direction(target.pose)
        direction = Direction.opposite(direction) if target.sprite.mirror
        case direction
        when 8
          icon_direction = 7
          back_direction = 3
        when 4
          icon_direction = 1
          back_direction = 9
        when 6
          icon_direction = 3
          back_direction = 7
        when 2
          icon_direction = 9
          back_direction = 1
        end
        icon.create_move_direction(back_direction, 32, 1)
        icon.update
        icon.create_move_direction(icon_direction, 52, total_frames)
      end
      #--- 
      if @action_values.include?("WAIT")
        update_basic while icon.effecting?
      end
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_icon_throw
  #--------------------------------------------------------------------------
  def action_icon_throw
    mains = get_action_mains
    targets = get_action_targets
    return if mains.size == 0
    #---
    case @action_values[1]
    when "WEAPON", "WEAPON1"
      symbol = :weapon1
    when "WEAPON2"
      symbol = :weapon2
    when "SHIELD"
      symbol = :shield
    when "ITEM"
      symbol = :item
    else
      symbol = @action_values[1]
    end
    #---
    mains.each { |main|
      icon = main.icons[symbol]
      next if icon.nil?
      total_frames = @action_values[3].to_i
      total_frames = 12 if total_frames <= 0
      arc = @action_values[2].to_f
      #---
      targets.each { |target|
        move_x = target.screen_x
        move_y = target.screen_y - target.sprite.height / 2
        icon.create_movement(move_x, move_y, total_frames)
        icon.create_arc(arc)
        if @action_values.include?("WAIT")
          update_basic while icon.effecting?
        end
      }
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_condition
  #--------------------------------------------------------------------------
  def action_condition
    @action_condition ||= []
    @action_condition.push(@action.dup)
  end
  
  #--------------------------------------------------------------------------
  # new method: action_message
  #--------------------------------------------------------------------------
  def action_message
    user = @subject
    return unless user
    item = @subject.current_action.item
    return unless item
    @log_window.display_use_item(@subject, item)
  end
  
  #--------------------------------------------------------------------------
  # new method: action_move
  #--------------------------------------------------------------------------
  def action_move
    movers = get_action_mains
    return unless movers.size > 0
    return if SYMPHONY::View::EMPTY_VIEW
    #--- Get Location ---
    case @action_values[0]
    #---
    when "FORWARD", "BACKWARD"
      distance = @action_values[1].to_i
      distance = @action_values[0] == "FORWARD" ? 16 : 8 if distance <= 0
      frames = @action_values[2].to_i
      frames = 8 if frames <= 0
      movers.each { |mover|
        next unless mover.exist?
        direction = mover.direction
        destination_x = mover.screen_x
        destination_y = mover.screen_y
        case direction
        when 1; move_x = distance / -2; move_y = distance /  2
        when 2; move_x = distance *  0; move_y = distance *  1
        when 3; move_x = distance / -2; move_y = distance /  2
        when 4; move_x = distance * -1; move_y = distance *  0
        when 6; move_x = distance *  1; move_y = distance *  0
        when 7; move_x = distance / -2; move_y = distance / -2
        when 8; move_x = distance *  0; move_y = distance * -1
        when 9; move_x = distance /  2; move_y = distance / -2
        else; return
        end
        destination_x += @action_values[0] == "FORWARD" ? move_x : - move_x
        destination_y += @action_values[0] == "FORWARD" ? move_y : - move_y
        mover.face_coordinate(destination_x, destination_y) unless @action_values[0] == "BACKWARD"
        mover.create_movement(destination_x, destination_y, frames)
        case @action.upcase
        when /JUMP[ ](.*)/i
          arc_scan = $1.scan(/(?:ARC)[ ](\d+)/i)
          arc = $1.to_i
          mover.create_jump(arc)
        end
      }
    #---
    when "ORIGIN", "RETURN"
      frames = @action_values[1].to_i
      frames = 20 if frames <= 0
      movers.each { |mover|
        next unless mover.exist?
        destination_x = mover.origin_x
        destination_y = mover.origin_y
        next if destination_x == mover.screen_x && destination_y == mover.screen_y
        if @action_values[0] == "ORIGIN"
          mover.face_coordinate(destination_x, destination_y)
        end
        mover.create_movement(destination_x, destination_y, frames)
        case @action.upcase
        when /JUMP[ ](.*)/i
          arc_scan = $1.scan(/(?:ARC)[ ](\d+)/i)
          arc = $1.to_i
          mover.create_jump(arc)
        end
      }
    #---
    when "TARGET", "TARGETS", "USER"
      frames = @action_values[2].to_i
      frames = 20 if frames <= 0
      #---
      case @action_values[0]
      when "USER"
        targets = [@subject]
      when "TARGET", "TARGETS"
        targets = @action_targets
      end
      #---
      destination_x = destination_y = 0
      case @action_values[1]
      when "BASE", "FOOT", "FEET"
        targets.each { |target|
          destination_x += target.screen_x; destination_y += target.screen_y
          side_l = target.screen_x - target.sprite.width/2
          side_r = target.screen_x + target.sprite.width/2
          side_u = target.screen_y - target.sprite.height
          side_d = target.screen_y
          movers.each { |mover|
            next unless mover.exist?
            if side_l > mover.origin_x
              destination_x -= target.sprite.width/2
              destination_x -= mover.sprite.width/2
            elsif side_r < mover.origin_x
              destination_x += target.sprite.width/2
              destination_x += mover.sprite.width/2
            elsif side_u > mover.origin_y - mover.sprite.height
              destination_y -= target.sprite.height
            elsif side_d < mover.origin_y - mover.sprite.height
              destination_y += mover.sprite.height
            end
          }
        }
      #---
      when "BODY", "MIDDLE", "MID"
        targets.each { |target|
          destination_x += target.screen_x
          destination_y += target.screen_y - target.sprite.height / 2
          side_l = target.screen_x - target.sprite.width/2
          side_r = target.screen_x + target.sprite.width/2
          side_u = target.screen_y - target.sprite.height
          side_d = target.screen_y
          movers.each { |mover|
            next unless mover.exist?
            if side_l > mover.origin_x
              destination_x -= target.sprite.width/2
              destination_x -= mover.sprite.width/2
            elsif side_r < mover.origin_x
              destination_x += target.sprite.width/2
              destination_x += mover.sprite.width/2
            elsif side_u > mover.origin_y - mover.sprite.height
              destination_y -= target.sprite.height
            elsif side_d < mover.origin_y - mover.sprite.height
              destination_y += mover.sprite.height
            end
            destination_y += mover.sprite.height
            destination_y -= mover.sprite.height/2
            if $imported["BattleSymphony-8D"] && $imported["BattleSymphony-HB"]
              destination_y += mover.sprite.height if mover.use_8d? && target.use_hb?
              destination_y -= mover.sprite.height/4 if mover.use_hb? && target.use_8d?
            end
          }
        }
      #---
      when "CENTER"
        targets.each { |target|
          destination_x += target.screen_x
          destination_y += target.screen_y - target.sprite.height/2
        }
      #---
      when "HEAD", "TOP"
        targets.each { |target|
          destination_x += target.screen_x
          destination_y += target.screen_y - target.sprite.height
          side_l = target.screen_x - target.sprite.width/2
          side_r = target.screen_x + target.sprite.width/2
          side_u = target.screen_y - target.sprite.height
          side_d = target.screen_y
          movers.each { |mover|
            next unless mover.exist?
            if side_l > mover.origin_x
              destination_x -= target.sprite.width/2
              destination_x -= mover.sprite.width/2
            elsif side_r < mover.origin_x
              destination_x += target.sprite.width/2
              destination_x += mover.sprite.width/2
            elsif side_u > mover.origin_y - mover.sprite.height
              destination_y -= target.sprite.height
            elsif side_d < mover.origin_y - mover.sprite.height
              destination_y += mover.sprite.height
            end
            destination_y += mover.sprite.height
            destination_y -= mover.sprite.height/2
            if $imported["BattleSymphony-8D"] && $imported["BattleSymphony-HB"]
              destination_y += mover.sprite.height if mover.use_8d? && target.use_hb?
              destination_y -= mover.sprite.height/4 if mover.use_hb? && target.use_8d?
            end
          }
        }
      #---
      when "BACK"
        targets.each { |target|
          destination_x += target.screen_x
          destination_y += target.screen_y - target.sprite.height
          side_l = target.screen_x - target.sprite.width/2
          side_r = target.screen_x + target.sprite.width/2
          side_u = target.screen_y - target.sprite.height
          side_d = target.screen_y
          movers.each { |mover|
            next unless mover.exist?
            if side_l > mover.origin_x
              destination_x += target.sprite.width/2
              destination_x += mover.sprite.width/2
            elsif side_r < mover.origin_x
              destination_x -= target.sprite.width/2
              destination_x -= mover.sprite.width/2
            elsif side_u > mover.origin_y - mover.sprite.height
              destination_y -= target.sprite.height
            elsif side_d < mover.origin_y - mover.sprite.height
              destination_y += mover.sprite.height
            end
            destination_y += mover.sprite.height
            destination_y -= mover.sprite.height/2
            if $imported["BattleSymphony-8D"] && $imported["BattleSymphony-HB"]
              destination_y += mover.sprite.height if mover.use_8d? && target.use_hb?
              destination_y -= mover.sprite.height/4 if mover.use_hb? && target.use_8d?
            end
          }
        }
      #---
      else
        targets.each { |target|
          destination_x += target.screen_x
          destination_y += target.screen_y
        }
      end
      #---
      destination_x /= targets.size
      destination_y /= targets.size
      movers.each { |mover|
        next unless mover.exist?
        next if mover.screen_x == destination_x && mover.screen_y == destination_y
        case @action.upcase
        when /MOVE[ ](.*)/i
          mover.face_coordinate(destination_x, destination_y)
          mover.create_movement(destination_x, destination_y, frames)
        when /TELEPORT[ ](.*)/i 
          mover.screen_x = destination_x
          mover.screen_y = destination_y
        when /JUMP[ ](.*)/i
          arc_scan = $1.scan(/(?:ARC)[ ](\d+)/i)
          arc = $1.to_i
          mover.face_coordinate(destination_x, destination_y)
          mover.create_movement(destination_x, destination_y, frames)
          mover.create_jump(arc)
        end
      }
    #---
    end
    #---
    return unless @action_values.include?("WAIT")
    wait_for_move
  end
  
  #--------------------------------------------------------------------------
  # new method: action_immortal
  #--------------------------------------------------------------------------
  def action_immortal
    targets = get_action_targets
    return unless targets.size > 0
    targets.each { |target|
      next unless target.alive?
      case @action_values[1].upcase
      when "TRUE", "ON", "ENABLE"
        target.immortal = true
      when "OFF", "FALSE", "DISABLE"
        target.immortal = false
        target.refresh
        perform_collapse_check(target)
      end
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_pose
  #--------------------------------------------------------------------------
  def action_pose
    targets = get_action_targets
    return unless targets.size > 0
    #---
    case @action_values[1]
    when "BREAK", "CANCEL", "RESET", "NORMAL"
      targets.each { |target| target.break_pose }
      return
    when "IDLE", "READY"
      pose_key = :ready
    when "DAMAGE", "DMG"
      pose_key = :damage
    when "PIYORI", "CRITICAL", "DAZED", "DAZE", "DIZZY"
      pose_key = :critical
    when "MARCH", "FORWARD"
      pose_key = :marching
    when "VICTORY", "POSE"
      pose_key = :victory
    when "EVADE", "DODGE"
      pose_key = :dodge
    when "DOWN", "DOWNED", "FALLEN"
      pose_key = :fallen
    when "2H", "2H SWING"
      pose_key = :swing2h
    when "1H", "1H SWING"
      pose_key = :swing1h
    when "2H REVERSE", "2H SWING REVERSE"
      pose_key = :r2hswing
      reverse_pose = true
    when "1H REVERSE", "1H SWING REVERSE"
      pose_key = :r1hswing
      reverse_pose = true
    when "CAST", "INVOKE", "ITEM", "MAGIC"
      pose_key = :cast
    when "CHANT", "CHANNEL", "CHARGE"
      pose_key = :channeling
    else; return
    end
    #---
    return unless $imported["BattleSymphony-8D"]
    #---
    targets.each { |target| 
      next unless target.exist?
      next unless target.use_8d?
      target.pose = pose_key
      target.force_pose = true
      target.reverse_pose = reverse_pose
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: action_stance
  #--------------------------------------------------------------------------
  def action_stance
    targets = get_action_targets
    return unless targets.size > 0
    #---
    case @action_values[1]
    when "BREAK", "CANCEL", "RESET", "NORMAL"
      targets.each { |target| target.break_pose }
      return
    when "IDLE", "READY"
      pose_key = :idle
    when "DAMAGE", "DMG", "STRUCK"
      pose_key = :struck
    when "PIYORI", "CRITICAL", "DAZED", "DAZE", "DIZZY", "WOOZY"
      pose_key = :woozy
    when "VICTORY"
      pose_key = :victory
    when "EVADE", "DODGE", "DEFEND"
      pose_key = :defend
    when "DOWN", "DOWNED", "FALLEN", "DEAD"
      pose_key = :dead
    when "SWING", "ATTACK", "SLASH"
      pose_key = :attack
    when "CAST", "INVOKE", "MAGIC"
      pose_key = :magic
    when "ITEM"
      pose_key = :item
    when "SKILL", "PHYSICAL"
      pose_key = :skill
    when "FORWARD", "MOVE", "TARGET"
      pose_key = :advance
    when "ORIGIN", "BACK", "RETREAT"
      pose_key = :retreat
    else
      pose_key = @action_values[1].downcase.to_sym
    end
    #---
    return if !$imported["BattleSymphony-HB"] && !$imported["BattleSymphony-CBS"]
    #---
    targets.each { |target| 
      next unless target.exist?
      next if !target.use_hb? && !target.use_cbs?
      target.pose = pose_key
      target.force_pose = true
    }
  end
  
  #--------------------------------------------------------------------------
  # action_wait
  #--------------------------------------------------------------------------
  def action_wait
    case @action
    when "WAIT FOR ANIMATION"
      wait_for_animation
      return
    when "WAIT FOR MOVE", "WAIT FOR MOVEMENT"
      wait_for_move
      return
    end
    frames = @action_values[0].to_i
    frames *= $imported["YEA-CoreEngine"] ? YEA::CORE::ANIMATION_RATE : 4 if @action == "ANI WAIT"
    skip = @action_values.include?("SKIP")
    skip = true if @action == "WAIT SKIP"
    skip ? wait(frames) : abs_wait(frames)
  end
  
end # Scene_Battle

#==============================================================================
# Section V. Imports Symphony Tags (S-05)
# -----------------------------------------------------------------------------
# This section is the field for You to create your own Symphony Tags. Please
# read carefully the Tutorial at Creating Symphony Tags before touching this.
#==============================================================================
#==============================================================================
# ■ Scene_Battle - Imported Symphony Configuration
#==============================================================================
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # new method: imported_symphony
  #--------------------------------------------------------------------------
  def imported_symphony
    case @action.upcase
      
      #--- Start Importing ---
      
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      # sample symphony
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # This is the most basic sample, it will put a line which contains 
      # action name and action values in Console.
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      when /SAMPLE SYMPHONY/i
        action_sample_symphony
      
      #--- End Importing ---
      else
        if SYMPHONY::AUTO_SYMPHONY.include?(@action.upcase)
          @action_values = [@action.upcase]
          @action = "AUTO SYMPHONY"
          action_autosymphony
        end
    end
  end

end # Scene_Battle
#==============================================================================
# ■ Scene_Battle - Imported Symphony Actions
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # new method: action_sample_symphony
  #--------------------------------------------------------------------------
  def action_sample_symphony
    str = "#{@action.upcase}: "
    @action_values.each {|value| str += "#{value} "}
    puts str
  end
  
end # Scene_Battle

#==============================================================================
# Section VI. Sprites Initialization (S-06)
# -----------------------------------------------------------------------------
# This section is the first section of core script. It will Initializes and 
# Creates Sprites for all Battlers and Maintains them.
# -----------------------------------------------------------------------------
# Do not touch below script unless You know what You do and How it works.
#==============================================================================
#==============================================================================
# ■ Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :origin_x 
  attr_accessor :origin_y
  attr_accessor :screen_x
  attr_accessor :screen_y
  attr_accessor :pose
  attr_accessor :immortal
  attr_accessor :icons
  attr_accessor :direction
  attr_accessor :force_pose
  attr_accessor :reverse_pose
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias bes_initialize initialize
  def initialize
    bes_initialize
    @screen_x = 0
    @screen_y = 0
    #---
    @move_x_rate = 0
    @move_y_rate = 0
    #---
    @immortal = false
    #---
    @icons = {}
    @force_pose = false
    @reverse_pose = false
    #---
    @hp = 1 # Fix Change Party in Battle.
    #---
    @arc = 0
    @parabola = {}
    @f = 0
    @arc_y = 0
  end
  
  #--------------------------------------------------------------------------
  # new method: use_charset?
  #--------------------------------------------------------------------------
  def use_charset?
    return false
  end  
  
  #--------------------------------------------------------------------------
  # new method: use_8d?
  #--------------------------------------------------------------------------
  def use_8d?
    false
  end
  
  #--------------------------------------------------------------------------
  # new method: use_hb?
  #--------------------------------------------------------------------------
  def use_hb?
    false
  end
  
  #--------------------------------------------------------------------------
  # new method: use_cbs?
  #--------------------------------------------------------------------------
  def use_cbs?
    false
  end
  
  #--------------------------------------------------------------------------
  # new method: emptyview?
  #--------------------------------------------------------------------------
  def emptyview?
    return SYMPHONY::View::EMPTY_VIEW
  end
  
  #--------------------------------------------------------------------------
  # new method: battler
  #--------------------------------------------------------------------------
  def battler
    self.actor? ? self.actor : self.enemy
  end
  
  #--------------------------------------------------------------------------
  # new method: use_custom_charset?
  #--------------------------------------------------------------------------
  def use_custom_charset?
    if $imported["BattleSymphony-8D"]; return true if use_8d?; end
    if $imported["BattleSymphony-HB"]; return true if use_hb?; end
    return false
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    return 100
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_battle_start
  #--------------------------------------------------------------------------
  alias bes_on_battle_start on_battle_start
  def on_battle_start
    reset_position
    #---
    bes_on_battle_start
    #---
    return if self.actor? && !$game_party.battle_members.include?(self)
    set_default_position
  end
  
  #--------------------------------------------------------------------------
  # new method: set_default_position
  #--------------------------------------------------------------------------
  def set_default_position
    @move_rate_x = 0
    @move_rate_y = 0
    #---
    @destination_x = self.screen_x
    @destination_y = self.screen_y
  end
  
  #--------------------------------------------------------------------------
  # new method: correct_origin_position
  #--------------------------------------------------------------------------
  def correct_origin_position
    # Compatible
  end
  
  #--------------------------------------------------------------------------
  # new method: reset_position
  #--------------------------------------------------------------------------
  def reset_position
    break_pose
  end
  
  #--------------------------------------------------------------------------
  # new method: break_pose
  #--------------------------------------------------------------------------
  def break_pose
    @direction = SYMPHONY::View::PARTY_DIRECTION
    @direction = Direction.opposite(@direction) if self.enemy?
    #---
    @pose = Direction.pose(@direction)
    #---
    @force_pose = false
    @reverse_pose = false
  end
  
  #--------------------------------------------------------------------------
  # new method: pose=
  #--------------------------------------------------------------------------
  def pose=(pose)
    @pose = pose
    return if self.actor? && !$game_party.battle_members.include?(self)
    self.sprite.correct_change_pose if SceneManager.scene.spriteset
  end
  
  #--------------------------------------------------------------------------
  # new method: can_collapse?
  #--------------------------------------------------------------------------
  def can_collapse?
    return false unless dead?
    unless actor?
      return false unless sprite.battler_visible
      array = [:collapse, :boss_collapse, :instant_collapse]
      return false if array.include?(sprite.effect_type)
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  # new method: weapons
  #--------------------------------------------------------------------------
  def weapons
    return []
  end
  
  #--------------------------------------------------------------------------
  # new method: equips
  #--------------------------------------------------------------------------
  def equips
    return []
  end
  
  #--------------------------------------------------------------------------
  # alias method: add_state
  #--------------------------------------------------------------------------
  alias bes_add_state add_state
  def add_state(state_id)
    bes_add_state(state_id)
    #--- Fix Death pose ---
    return unless SceneManager.scene_is?(Scene_Battle)
    break_pose if state_id == death_state_id
  end
  
end # Game_Battler

#==============================================================================
# ■ Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # overwrite method: use_sprite?
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  
  #--------------------------------------------------------------------------
  # new method: use_charset?
  #--------------------------------------------------------------------------
  def use_charset?
    return true
  end
  
  #--------------------------------------------------------------------------
  # new method: set_default_position
  #--------------------------------------------------------------------------
  def set_default_position
    super
    return if @origin_x && @origin_y
    return unless $game_party.battle_members.include?(self)
    @origin_x = @screen_x = @destination_x = SYMPHONY::View::ACTORS_POSITION[index][0]
    @origin_y = @screen_y = @destination_y = SYMPHONY::View::ACTORS_POSITION[index][1]
    return unless emptyview?
    @origin_x = @screen_x = @destination_x = self.screen_x
    @origin_y = @screen_y = @destination_y = self.screen_y
  end
  
  #--------------------------------------------------------------------------
  # new method: reset_position
  #--------------------------------------------------------------------------
  def reset_position
    super
    @origin_x = @origin_y = nil
  end
  
  #--------------------------------------------------------------------------
  # alias method: screen_x
  #--------------------------------------------------------------------------
  alias bes_screen_x screen_x
  def screen_x
    emptyview? ? bes_screen_x : @screen_x
  end
  
  #--------------------------------------------------------------------------
  # alias method: screen_y
  #--------------------------------------------------------------------------
  alias bes_screen_y screen_y
  def screen_y
    emptyview? ? bes_screen_y : @screen_y
  end
  
  #--------------------------------------------------------------------------
  # new method: correct_origin_position
  #--------------------------------------------------------------------------
  def correct_origin_position
    return if @origin_x && @origin_y
    @origin_x = @screen_x = SYMPHONY::View::ACTORS_POSITION[index][0]
    @origin_y = @screen_y = SYMPHONY::View::ACTORS_POSITION[index][1]
    return unless emptyview?
    @origin_x = @screen_x = @destination_x = self.screen_x
    @origin_y = @screen_y = @destination_y = self.screen_y
  end
  
  #--------------------------------------------------------------------------
  # new method: sprite
  #--------------------------------------------------------------------------
  def sprite
    index = $game_party.battle_members.index(self)
    return nil unless index
    return nil unless SceneManager.scene_is?(Scene_Battle)
    return SceneManager.scene.spriteset.actor_sprites[index]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: perform_collapse_effect
  #--------------------------------------------------------------------------
  def perform_collapse_effect
    if $game_party.in_battle
      @sprite_effect_type = :collapse unless self.use_custom_charset?
      Sound.play_actor_collapse
    end
  end
    
end # Game_Actor

#==============================================================================
# ■ Game_Enemy
#==============================================================================

class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # new method: correct_origin_position
  #--------------------------------------------------------------------------
  def correct_origin_position
    @origin_x ||= @screen_x
    @origin_y ||= @screen_y
  end
  
  #--------------------------------------------------------------------------
  # new method: use_charset?
  #--------------------------------------------------------------------------
  def use_charset?
    return super
  end  
  
  #--------------------------------------------------------------------------
  # new method: sprite
  #--------------------------------------------------------------------------
  def sprite
    return nil unless SceneManager.scene_is?(Scene_Battle)
    return SceneManager.scene.spriteset.enemy_sprites.reverse[self.index]
  end
  
  #--------------------------------------------------------------------------
  # new method: atk_animation_id1
  #--------------------------------------------------------------------------
  def atk_animation_id1
    return enemy.atk_animation_id1
  end
  
  #--------------------------------------------------------------------------
  # new method: atk_animation_id2
  #--------------------------------------------------------------------------
  def atk_animation_id2
    return enemy.atk_animation_id2
  end
  
end # Game_Enemy

#==============================================================================
# ■ Sprite_Battler
#==============================================================================

class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :effect_type
  attr_accessor :battler_visible
  
  #--------------------------------------------------------------------------
  # new method: pose
  #--------------------------------------------------------------------------
  alias bes_initialize initialize
  def initialize(viewport, battler = nil)
    bes_initialize(viewport, battler)
    correct_change_pose if @battler
    #---
    self.visible = false if SYMPHONY::View::EMPTY_VIEW && (@battler.nil? || @battler.actor?)
    #---
    return if SYMPHONY::View::EMPTY_VIEW
    #---
    return unless SYMPHONY::Visual::BATTLER_SHADOW
    #---
    @charset_shadow = Sprite.new(viewport)
    @charset_shadow.bitmap = Cache.system("Shadow")
    @charset_shadow.ox = @charset_shadow.width / 2
    @charset_shadow.oy = @charset_shadow.height
  end
  
  #--------------------------------------------------------------------------
  # new method: pose
  #--------------------------------------------------------------------------
  def pose
    @battler.pose
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias bes_update update
  def update
    bes_update
    #---
    return if SYMPHONY::View::EMPTY_VIEW
    #---
    return unless SYMPHONY::Visual::BATTLER_SHADOW
    #---
    @charset_shadow.opacity = self.opacity
    @charset_shadow.visible = self.visible
    @charset_shadow.x = self.x + (self.mirror ? 0 : - 2)
    @charset_shadow.y = self.y + 2
    @charset_shadow.z = self.z - 1
    #---
    @charset_shadow.opacity = 0 if @battler.nil?
  end
  
  #--------------------------------------------------------------------------
  # alias method: dispose
  #--------------------------------------------------------------------------
  alias bes_dispose dispose
  def dispose
    bes_dispose
    dispose_shadow
  end
  
  #--------------------------------------------------------------------------
  # new method: dispose_shadow
  #--------------------------------------------------------------------------
  def dispose_shadow
    @charset_shadow.dispose if @charset_shadow
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_bitmap
  #--------------------------------------------------------------------------
  alias bes_update_bitmap update_bitmap
  def update_bitmap
    correct_change_pose if @timer.nil?
    @battler.use_charset? ? update_charset : bes_update_bitmap
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_origin
  #--------------------------------------------------------------------------
  alias bes_update_origin update_origin
  def update_origin
    @battler.update_visual
    @battler.use_charset? ? update_charset_origin : bes_update_origin
  end
  
  #--------------------------------------------------------------------------
  # new method: update_charset
  #--------------------------------------------------------------------------
  def update_charset
    @battler.set_default_position unless pose
    #---
    update_charset_bitmap
    update_src_rect
  end
  
  #--------------------------------------------------------------------------
  # new method: correct_change_pose
  #--------------------------------------------------------------------------
  def correct_change_pose
    @pattern = 1
    @timer = 15
    @back_step = false
    @last_pose = pose
  end
  
  #--------------------------------------------------------------------------
  # new method: update_charset_origin
  #--------------------------------------------------------------------------
  def update_charset_origin
    if bitmap
      self.ox = @cw / 2
      self.oy = @ch
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: graphic_changed?
  #--------------------------------------------------------------------------
  def graphic_changed?
    @character_name != @battler.character_name ||
    @character_index != @battler.character_index
  end
  
  #--------------------------------------------------------------------------
  # new method: set_character_bitmap
  #--------------------------------------------------------------------------
  def set_character_bitmap
    self.bitmap = Cache.character(@character_name)
    sign = @character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      @cw = bitmap.width / 3
      @ch = bitmap.height / 4
    else
      @cw = bitmap.width / 12
      @ch = bitmap.height / 8
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: update_charset_bitmap
  #--------------------------------------------------------------------------
  def update_charset_bitmap
    if graphic_changed?
      @character_name = @battler.character_name
      @character_index = @battler.character_index
      set_character_bitmap
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: update_src_rect
  #--------------------------------------------------------------------------
  def update_src_rect
    @timer -= 1
    if @battler.force_pose
      array = []
      array = Direction.index_8d(pose) if $imported["BattleSymphony-8D"] && @battler.use_8d?
      if !@battler.reverse_pose && @pattern < 2 && @timer <= 0
        @pattern += 1
        @timer = array[2].nil? ? 15 : array[2]
      elsif @battler.reverse_pose && @pattern > 0 && @timer <= 0
        @pattern -= 1
        @timer = array[2].nil? ? 15 : array[2]
      end
    else
      #--- Quick Fix
      @pattern = 2 if @pattern > 2
      @pattern = 0 if @pattern < 0
      #--- End
      if @timer <= 0
        @pattern += @back_step ? -1 : 1
        @back_step = true if @pattern >= 2
        @back_step = false if @pattern <= 0
        @timer = 15
      end
    end
    #---
    @battler.break_pose unless pose
    direction = Direction.direction(pose)
    character_index = @character_index
    #---
    if $imported["BattleSymphony-8D"] && @battler.use_8d?
      array = Direction.index_8d(pose)
      character_index = array[0]
      direction = array[1]
    end
    sx = (character_index % 4 * 3 + @pattern) * @cw
    sy = (character_index / 4 * 4 + (direction - 2) / 2) * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: revert_to_normal
  #--------------------------------------------------------------------------
  def revert_to_normal
    self.blend_type = 0
    self.color.set(0, 0, 0, 0)
    self.opacity = 255
  end
  
  #--------------------------------------------------------------------------
  # alias method: animation_set_sprites
  # Make Animation Opacity independent of Sprite Opacity
  #--------------------------------------------------------------------------
  alias bes_animation_set_sprites animation_set_sprites
  def animation_set_sprites(frame)
    bes_animation_set_sprites(frame)
    cell_data = frame.cell_data
    @ani_sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      sprite.opacity = cell_data[i, 6]
    end
  end
  
end # Sprite_Battler

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================

class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :actor_sprites
  attr_accessor :enemy_sprites
  
  #--------------------------------------------------------------------------
  # overwrite method: create_actors
  # Fixed Large Party.
  #--------------------------------------------------------------------------
  def create_actors
    max_members = $game_party.max_battle_members
    @actor_sprites = Array.new(max_members) { Sprite_Battler.new(@viewport1) }
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: update_actors
  # Fixed Change Party.
  #--------------------------------------------------------------------------
  def update_actors
    @actor_sprites.each_with_index do |sprite, i|
      party_member = $game_party.battle_members[i]
      if party_member != sprite.battler
        sprite.battler = $game_party.battle_members[i]
        #---
        if party_member
          party_member.reset_position
          party_member.correct_origin_position
          party_member.break_pose if party_member.dead?
        end
        sprite.init_visibility if sprite.battler && !sprite.battler.use_custom_charset?
      end
      sprite.update
    end
  end
  
end # Spriteset_Battle

#==============================================================================
# Section VII. Icons Sprites Initialization (S-07)
# -----------------------------------------------------------------------------
# This section is the second section of core script. It will Initializes and 
# Creates Sprites for all Object like Weapons, Items and Maintains them.
# -----------------------------------------------------------------------------
# Do not touch below script unless You know what You do and How it works.
#==============================================================================
#==============================================================================
# ■ Sprite_Object
#==============================================================================

class Sprite_Object < Sprite_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    #---
    @dest_angle = 0
    @dest_x = 0
    @dest_y = 0
    #---
    @angle_rate = 0
    @move_x_rate = 0
    @move_y_rate = 0
    @fade_rate = 0
    #---
    @arc = 0
    @parabola = {}
    @f = 0
    @arc_y = 0
    #---
    @battler = nil
    @offset_x = 0
    @offset_y = 0
    @offset_z = 0
    @attach_x = 0
    @attach_y = 0
    @attachment = :middle
  end
  
  #--------------------------------------------------------------------------
  # set_battler
  #--------------------------------------------------------------------------
  def set_battler(battler = nil)
    @battler = battler
    update
  end
  
  #--------------------------------------------------------------------------
  # set_position
  #--------------------------------------------------------------------------
  def set_position(x, y)
    @dest_x = self.x = x
    @dest_y = self.y = y
  end
  
  #--------------------------------------------------------------------------
  # set_angle
  #--------------------------------------------------------------------------
  def set_angle(angle)
    @dest_angle = self.angle = angle
    @dest_angle = self.angle = -angle if mirror_battler?
  end
  
  #--------------------------------------------------------------------------
  # set_icon
  #--------------------------------------------------------------------------
  def set_icon(index)
    return if index <= 0
    bitmap = Cache.system("Iconset")
    self.bitmap ||= bitmap
    self.src_rect.set(index % 16 * 24, index / 16 * 24, 24, 24)
    self.ox = self.oy = 12
  end
  
  #--------------------------------------------------------------------------
  # set_origin
  #--------------------------------------------------------------------------
  def set_origin(type)
    @offset_z = 2
    @attachment = type
    case type
    when :item
      self.ox = 12
      self.oy = 12
      @offset_y = -@battler.sprite.height
      @offset_x = -@battler.sprite.width / 2
    when :hand1
      self.ox = 24
      self.oy = 24
      @attach_y = -@battler.sprite.height/3
      @attach_x = -@battler.sprite.width/5
    when :hand2
      self.ox = 24
      self.oy = 24
      @attach_y = -@battler.sprite.height/3
      @attach_x = @battler.sprite.width/5
    when :middle
      self.ox = 12
      self.oy = 12
      @offset_y = -@battler.sprite.height/2
    when :top
      self.ox = 12
      self.oy = 24
      @offset_y = -@battler.sprite.height
    when :base
      self.ox = 12
      self.oy = 24
    end
    self.y = @battler.screen_y + @attach_y + @offset_y + @arc_y
  end
  
  #--------------------------------------------------------------------------
  # set_fade
  #--------------------------------------------------------------------------
  def set_fade(rate)
    @fade_rate = rate
  end
  
  #--------------------------------------------------------------------------
  # create_angle
  #--------------------------------------------------------------------------
  def create_angle(angle, frames = 8)
    return if angle == self.angle
    @dest_angle = angle
    @dest_angle = - @dest_angle if mirror_battler?
    frames = [frames, 1].max
    @angle_rate = [(self.angle - @dest_angle).abs / frames, 2].max
  end
  
  #--------------------------------------------------------------------------
  # create_arc
  #--------------------------------------------------------------------------
  def create_arc(arc)
    @arc = arc
    @parabola[:x] = 0
    @parabola[:y0] = 0
    @parabola[:y1] = @dest_y - self.y
    @parabola[:h]  = - (@parabola[:y0] + @arc * 5)
    @parabola[:d]  = (self.x - @dest_x).abs
  end
  
  #--------------------------------------------------------------------------
  # create_movement
  #--------------------------------------------------------------------------
  def create_movement(destination_x, destination_y, frames = 12)
    return if self.x == destination_x && self.y == destination_y
    @arc = 0
    @dest_x = destination_x
    @dest_y = destination_y
    frames = [frames, 1].max
    @f = frames.to_f / 2
    @move_x_rate = [(self.x - @dest_x).abs / frames, 2].max
    @move_y_rate = [(self.y - @dest_y).abs / frames, 2].max
  end
  
  #--------------------------------------------------------------------------
  # create_move_direction
  #--------------------------------------------------------------------------
  def create_move_direction(direction, distance, frames = 12)
    case direction
    when 1; move_x = distance / -2; move_y = distance /  2
    when 2; move_x = distance *  0; move_y = distance *  1
    when 3; move_x = distance / -2; move_y = distance /  2
    when 4; move_x = distance * -1; move_y = distance *  0
    when 6; move_x = distance *  1; move_y = distance *  0
    when 7; move_x = distance / -2; move_y = distance / -2
    when 8; move_x = distance *  0; move_y = distance * -1
    when 9; move_x = distance /  2; move_y = distance / -2
    else; return
    end
    #---
    move_x += self.x
    move_y += self.y
    #---
    create_movement(move_x, move_y, frames)
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    update_angle
    @arc == 0 ? update_movement : update_arc
    update_position
    update_opacity
  end
  
  #--------------------------------------------------------------------------
  # update_angle
  #--------------------------------------------------------------------------
  def update_angle
    return if @angle_rate == 0
    @angle_rate = 0 if self.angle == @dest_angle
    value = [(self.angle - @dest_angle).abs, @angle_rate].min
    self.angle += (@dest_angle > self.angle) ? value : -value
  end
  
  #--------------------------------------------------------------------------
  # update_arc
  #--------------------------------------------------------------------------
  def update_arc
    return unless [@move_x_rate, @move_y_rate].any? { |x| x != 0 }
    #---
    value = [(self.x - @dest_x).abs, @move_x_rate].min
    @offset_x += (@dest_x > self.x) ? value : -value
    @parabola[:x] += value
    #---
    if @dest_x == self.x
      self.y = @dest_y
    else
      a = (2*(@parabola[:y0]+@parabola[:y1])-4*@parabola[:h])/(@parabola[:d]**2)
      b = (@parabola[:y1]-@parabola[:y0]-a*(@parabola[:d]**2))/@parabola[:d]
      @arc_y = a * @parabola[:x] * @parabola[:x] + b * @parabola[:x] + @parabola[:y0]
    end
    #---
    @move_x_rate = 0 if self.x == @dest_x
    @move_y_rate = 0 if self.y == @dest_y
  end
  
  #--------------------------------------------------------------------------
  # update_movement
  #--------------------------------------------------------------------------
  def update_movement
    return unless [@move_x_rate, @move_y_rate].any? { |x| x != 0 }
    @move_x_rate = 0 if self.x == @dest_x
    @move_y_rate = 0 if self.y == @dest_y
    value = [(self.x - @dest_x).abs, @move_x_rate].min
    @offset_x += (@dest_x > self.x) ? value : -value
    value = [(self.y - @dest_y).abs, @move_y_rate].min
    @offset_y += (@dest_y > self.y) ? value : -value
  end
  
  #--------------------------------------------------------------------------
  # update_position
  #--------------------------------------------------------------------------
  def update_position
    if @battler != nil
      self.mirror = mirror_battler?
      update_attachment(self.mirror)
      attach_x = self.mirror ? -@attach_x : @attach_x
      self.x = @battler.screen_x + attach_x + @offset_x
      self.y = @battler.screen_y + @attach_y + @offset_y + @arc_y
      self.z = @battler.screen_z + @offset_z
    else
      self.x = @offset_x
      self.y = @offset_y
      self.z = @offset_z
    end
  end
  
  #--------------------------------------------------------------------------
  # update_attachment
  #--------------------------------------------------------------------------
  def update_attachment(mirror = false)
    case @attachment
    when :hand1
      self.ox = mirror ? 0 : 24
      self.oy = 24
      @attach_y = -@battler.sprite.height/3
      @attach_x = -@battler.sprite.width/5
    when :hand2
      self.ox = mirror ? 0 : 24
      self.oy = 24
      @attach_y = -@battler.sprite.height/3
      @attach_x = @battler.sprite.width/5
    else
      @attach_x = 0
      @attach_y = 0
    end
  end
  
  #--------------------------------------------------------------------------
  # update_attachment
  #--------------------------------------------------------------------------
  def update_opacity
    self.opacity += @fade_rate
  end
  
  #--------------------------------------------------------------------------
  # mirror_battler?
  #--------------------------------------------------------------------------
  def mirror_battler?
    return false if @battler.sprite == nil
    direction = Direction.direction(@battler.pose)
    return true if [9, 6, 3].include?(direction)
    return true if @battler.sprite.mirror
    return false
  end
  
  #--------------------------------------------------------------------------
  # effecting?
  #--------------------------------------------------------------------------
  def effecting?
    [@angle_rate,@move_y_rate,@move_x_rate,@fade_rate].any? { |x| x > 0 }
  end
  
end # Sprite_Object

#==============================================================================
# Section VIII. Core Script (S-08)
# -----------------------------------------------------------------------------
# This section is the most important section of Core SCript. It will Initialize
# Database as well as Symphony Tags and put them in actions.
# -----------------------------------------------------------------------------
# Do not touch below script unless You know what You do and How it works.
#==============================================================================
#==============================================================================
# ■ Regular Expression
#==============================================================================

module REGEXP
  module SYMPHONY
    SETUP_ANI_ON   = /<(?:SETUP_ACTION|setup action|setup)>/i
    SETUP_ANI_OFF  = /<\/(?:SETUP_ACTION|setup action|setup)>/i
    WHOLE_ANI_ON   = /<(?:WHOLE_ACTION|whole action|whole)>/i
    WHOLE_ANI_OFF  = /<\/(?:WHOLE_ACTION|whole action|whole)>/i
    TARGET_ANI_ON  = /<(?:TARGET_ACTION|target action|target)>/i
    TARGET_ANI_OFF = /<\/(?:TARGET_ACTION|target action|target)>/i
    FOLLOW_ANI_ON  = /<(?:FOLLOW_ACTION|follow action|follow)>/i
    FOLLOW_ANI_OFF = /<\/(?:FOLLOW_ACTION|follow action|follow)>/i
    FINISH_ANI_ON  = /<(?:FINISH_ACTION|finish action|finish)>/i
    FINISH_ANI_OFF = /<\/(?:FINISH_ACTION|finish action|finish)>/i
    
    SYMPHONY_TAG_NONE = /[ ]*(.*)/i
    SYMPHONY_TAG_VALUES = /[ ]*(.*):[ ]*(.*)/i
    
    ATK_ANI1 = /<(?:ATK_ANI_1|atk ani 1):[ ]*(\d+)>/i
    ATK_ANI2 = /<(?:ATK_ANI_2|atk ani 2):[ ]*(\d+)>/i

  end
end

# Scan values: /\w+[\s*\w+]*/i

#==============================================================================
# ■ DataManager
#==============================================================================

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_bes load_database; end
  def self.load_database
    load_database_bes
    load_notetags_bes
  end
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_bes
  #--------------------------------------------------------------------------
  def self.load_notetags_bes
    groups = [$data_skills, $data_items, $data_weapons, $data_enemies]
    groups.each { |group|
      group.each { |obj|
        next if obj.nil?
        obj.battle_symphony_initialize
      }
    }
  end
  
end # DataManager

#==============================================================================
# ■ RPG::BaseItem
#==============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :setup_actions_list 
  attr_accessor :whole_actions_list
  attr_accessor :target_actions_list
  attr_accessor :follow_actions_list
  attr_accessor :finish_actions_list
  attr_accessor :atk_animation_id1
  attr_accessor :atk_animation_id2
  
  #--------------------------------------------------------------------------
  # new method: battle_symphony_initialize
  #--------------------------------------------------------------------------
  def battle_symphony_initialize
    create_default_animation
    create_default_symphony
    create_tags_symphony
  end
  
  #--------------------------------------------------------------------------
  # new method: create_default_animation
  #--------------------------------------------------------------------------
  def create_default_animation
    @atk_animation_id1 = SYMPHONY::Visual::ENEMY_ATTACK_ANIMATION
    @atk_animation_id2 = 0
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::SYMPHONY::ATK_ANI1
        @atk_animation_id1 = $1.to_i
      when REGEXP::SYMPHONY::ATK_ANI2
        @atk_animation_id2 = $1.to_i
      end
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: create_default_symphony
  #--------------------------------------------------------------------------
  def create_default_symphony
    @setup_actions_list = []; @finish_actions_list = []
    @whole_actions_list = []; @target_actions_list = []
    @follow_actions_list = []
    #---
    if self.is_a?(RPG::Skill) and !self.physical?
      @setup_actions_list = SYMPHONY::DEFAULT_ACTIONS::MAGIC_SETUP
      @whole_actions_list = SYMPHONY::DEFAULT_ACTIONS::MAGIC_WHOLE
      @target_actions_list = SYMPHONY::DEFAULT_ACTIONS::MAGIC_TARGET
      @follow_actions_list = SYMPHONY::DEFAULT_ACTIONS::MAGIC_FOLLOW
      @finish_actions_list = SYMPHONY::DEFAULT_ACTIONS::MAGIC_FINISH
      return
    elsif self.is_a?(RPG::Skill) and self.physical?
      @setup_actions_list = SYMPHONY::DEFAULT_ACTIONS::PHYSICAL_SETUP
      @whole_actions_list = SYMPHONY::DEFAULT_ACTIONS::PHYSICAL_WHOLE
      @target_actions_list = SYMPHONY::DEFAULT_ACTIONS::PHYSICAL_TARGET
      @follow_actions_list = SYMPHONY::DEFAULT_ACTIONS::PHYSICAL_FOLLOW
      @finish_actions_list = SYMPHONY::DEFAULT_ACTIONS::PHYSICAL_FINISH
      return
    elsif self.is_a?(RPG::Item)
      @setup_actions_list = SYMPHONY::DEFAULT_ACTIONS::ITEM_SETUP
      @whole_actions_list = SYMPHONY::DEFAULT_ACTIONS::ITEM_WHOLE
      @target_actions_list = SYMPHONY::DEFAULT_ACTIONS::ITEM_TARGET
      @follow_actions_list = SYMPHONY::DEFAULT_ACTIONS::ITEM_FOLLOW
      @finish_actions_list = SYMPHONY::DEFAULT_ACTIONS::ITEM_FINISH
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: create_tags_symphony
  #--------------------------------------------------------------------------
  def create_tags_symphony
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::SYMPHONY::SETUP_ANI_ON
        @symphony_tag = true
        @setup_actions_list = []
        @setup_action_flag = true
      when REGEXP::SYMPHONY::SETUP_ANI_OFF
        @symphony_tag = false
        @setup_action_flag = false
      when REGEXP::SYMPHONY::WHOLE_ANI_ON
        @symphony_tag = true
        @whole_actions_list = []
        @whole_action_flag = true
      when REGEXP::SYMPHONY::WHOLE_ANI_OFF
        @symphony_tag = false
        @whole_action_flag = false
      when REGEXP::SYMPHONY::TARGET_ANI_ON
        @symphony_tag = true
        @target_actions_list = []
        @target_action_flag = true
      when REGEXP::SYMPHONY::TARGET_ANI_OFF
        @symphony_tag = false
        @target_action_flag = false
      when REGEXP::SYMPHONY::FOLLOW_ANI_ON
        @symphony_tag = true
        @follow_actions_list = []
        @follow_action_flag = true
      when REGEXP::SYMPHONY::FOLLOW_ANI_OFF
        @symphony_tag = false
        @follow_action_flag = false
      when REGEXP::SYMPHONY::FINISH_ANI_ON
        @symphony_tag = true
        @finish_actions_list = []
        @finish_action_flag = true
      when REGEXP::SYMPHONY::FINISH_ANI_OFF
        @symphony_tag = false
        @finish_action_flag = false
      #---
      else
        next unless @symphony_tag
        case line
        when REGEXP::SYMPHONY::SYMPHONY_TAG_VALUES
          action = $1
          value = $2.scan(/[^, ]+[^,]*/i)
        when REGEXP::SYMPHONY::SYMPHONY_TAG_NONE
          action = $1
          value = [nil]
        else; next
        end
        array = [action, value]
        if @setup_action_flag
          @setup_actions_list.push(array)
        elsif @whole_action_flag
          @whole_actions_list.push(array)
        elsif @target_action_flag
          @target_actions_list.push(array)
        elsif @follow_action_flag
          @follow_actions_list.push(array)
        elsif @finish_action_flag
          @finish_actions_list.push(array)
        end
      end
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: valid_actions?
  #--------------------------------------------------------------------------
  def valid_actions?(phase)
    case phase
    when :setup
      return @setup_actions_list.size > 0
    when :whole
      return @whole_actions_list.size > 0
    when :target
      return @target_actions_list.size > 0
    when :follow
      return @follow_actions_list.size > 0
    when :finish
      return @finish_actions_list.size > 0
    end
  end
  
end # RPG::BaseItem

#==============================================================================
# ■ Direction
#==============================================================================

module Direction
  
  #--------------------------------------------------------------------------
  # self.pose
  #--------------------------------------------------------------------------
  def self.pose(direction)
    case direction
    when 4; return :left
    when 6; return :right
    when 8; return :up
    when 2; return :down
    when 7; return :left
    when 1; return :left
    when 9; return :right
    when 3; return :right
    end
  end
  
  #--------------------------------------------------------------------------
  # self.non8d_pose
  #--------------------------------------------------------------------------
  def self.non8d_pose(pose)
    case pose
    when :down_l; return :left
    when :down_r; return :right
    when :up_l; return :left
    when :up_r; return :right
    end
  end
  
  #--------------------------------------------------------------------------
  # self.pose
  #--------------------------------------------------------------------------
  def self.direction(pose)
    case pose
    when :left; return 4
    when :right; return 6
    when :up; return 8
    when :down; return 2
    end
  end
  
  #--------------------------------------------------------------------------
  # self.opposite
  #--------------------------------------------------------------------------
  def self.opposite(direction)
    case direction
    when 1; return 9
    when 2; return 8
    when 3; return 7
    when 4; return 6
    when 6; return 4
    when 7; return 3
    when 8; return 2
    when 9; return 1
    else; return direction
    end
  end
  
  #--------------------------------------------------------------------------
  # self.face_coordinate
  #--------------------------------------------------------------------------
  def self.face_coordinate(screen_x, screen_y, destination_x, destination_y)
    x1 = Integer(screen_x)
    x2 = Integer(destination_x)
    y1 = Graphics.height - Integer(screen_y)
    y2 = Graphics.height - Integer(destination_y)
    return if x1 == x2 and y1 == y2
    #---
    angle = Integer(Math.atan2((y2-y1),(x2-x1)) * 1800 / Math::PI)
    if (0..225) === angle or (-225..0) === angle
      direction = 6
    elsif (226..675) === angle
      direction = 9
    elsif (676..1125) === angle
      direction = 8
    elsif (1126..1575) === angle
      direction = 7
    elsif (1576..1800) === angle or (-1800..-1576) === angle
      direction = 4
    elsif (-1575..-1126) === angle
      direction = 1
    elsif (-1125..-676) === angle
      direction = 2
    elsif (-675..-226) === angle
      direction = 3
    end
    return direction
  end
  
end # Direction

#==============================================================================
# ■ Game_ActionResult
#==============================================================================

class Game_ActionResult
  
  #--------------------------------------------------------------------------
  # alias method: clear_hit_flags
  #--------------------------------------------------------------------------
  alias bes_clear_hit_flags clear_hit_flags
  def clear_hit_flags
    return unless @calc
    bes_clear_hit_flags
    @temp_missed = @temp_evaded = @temp_critical = nil
  end
  
  #--------------------------------------------------------------------------
  # new method: clear_bes_flag
  #--------------------------------------------------------------------------
  def clear_bes_flag
    @perfect_hit = false
    @calc = false
    @dmg = false
    @effect = false
  end
  
  #--------------------------------------------------------------------------
  # new method: clear_change_target
  #--------------------------------------------------------------------------
  def clear_change_target
    @check_counter = false
    @check_reflection = false
  end
  
  #--------------------------------------------------------------------------
  # new method: set_perfect
  #--------------------------------------------------------------------------
  def set_perfect
    @perfect_hit = true
  end
  
  #--------------------------------------------------------------------------
  # new method: set_calc
  #--------------------------------------------------------------------------
  def set_calc
    @calc = true
  end
  
  #--------------------------------------------------------------------------
  # new method: set_dmg
  #--------------------------------------------------------------------------
  def set_dmg
    @dmg = true
  end
  
  #--------------------------------------------------------------------------
  # new method: set_effect
  #--------------------------------------------------------------------------
  def set_effect
    @effect = true
  end
  
  #--------------------------------------------------------------------------
  # new method: set_counter
  #--------------------------------------------------------------------------
  def set_counter
    @check_counter = true
  end
  
  #--------------------------------------------------------------------------
  # new method: set_reflection
  #--------------------------------------------------------------------------
  def set_reflection
    @check_reflection = true
  end
  
  #--------------------------------------------------------------------------
  # new method: used=
  #--------------------------------------------------------------------------
  def evaded=(flag)
    @evaded = @temp_evaded.nil? ? flag : @temp_evaded
  end
  
  #--------------------------------------------------------------------------
  # new method: used=
  #--------------------------------------------------------------------------
  def critical=(flag)
    @critical = @temp_critical.nil? ? flag : @temp_critical
  end
  
  #--------------------------------------------------------------------------
  # new method: used=
  #--------------------------------------------------------------------------
  def misssed=(flag)
    @missed = @temp_missed.nil? ? flag : @temp_missed
  end
  
  #--------------------------------------------------------------------------
  # alias method: hit?
  #--------------------------------------------------------------------------
  alias bes_hit? hit?
  def hit?
    bes_hit? || (@used && @perfect_hit)
  end
  
  #--------------------------------------------------------------------------
  # new method: dmg?
  #--------------------------------------------------------------------------
  def dmg?
    @dmg || !SceneManager.scene_is?(Scene_Battle)
  end
  
  #--------------------------------------------------------------------------
  # new method: effect?
  #--------------------------------------------------------------------------
  def effect?
    @effect || !SceneManager.scene_is?(Scene_Battle)
  end
  
  #--------------------------------------------------------------------------
  # new method: has_damage?
  #--------------------------------------------------------------------------
  def has_damage?
    [@hp_damage, @mp_damage, @tp_damage].any? { |x| x > 0 }
  end
  
  #--------------------------------------------------------------------------
  # new method: check_counter?
  #--------------------------------------------------------------------------
  def check_counter?
    @check_counter
  end
  
  #--------------------------------------------------------------------------
  # new method: check_reflection?
  #--------------------------------------------------------------------------
  def check_reflection?
    @check_reflection
  end
  
end # Game_ActionResult

#==============================================================================
# ■ Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # new method: force_make_actions
  #--------------------------------------------------------------------------
  def force_make_actions
    clear_actions
    @actions = Array.new(make_action_times) { Game_Action.new(self) }
  end
  
  #--------------------------------------------------------------------------
  # new method: backup_actions
  #--------------------------------------------------------------------------
  def backup_actions
    @backup_actions = @actions.dup if @actions
  end
  
  #--------------------------------------------------------------------------
  # new method: restore_actions
  #--------------------------------------------------------------------------
  def restore_actions
    @actions = @backup_actions.dup if @backup_actions
    @backup_actions.clear
    @backup_actions = nil
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_cnt
  #--------------------------------------------------------------------------
  alias bes_item_cnt item_cnt
  def item_cnt(user, item)
    return 0 if !movable? && !SYMPHONY::Fixes::ALWAYS_COUNTER
    return 0 unless @result.check_counter?
    return bes_item_cnt(user, item)
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_mrf
  #--------------------------------------------------------------------------
  alias bes_item_mrf item_mrf
  def item_mrf(user, item)
    return 0 if !movable? && !SYMPHONY::Fixes::ALWAYS_COUNTER
    return 0 unless @result.check_reflection?
    return 0 if @magic_reflection
    return bes_item_mrf(user, item)
  end
  
  #--------------------------------------------------------------------------
  # alias method: state_resist_set
  #--------------------------------------------------------------------------
  alias bes_state_resist_set state_resist_set
  def state_resist_set
    result = bes_state_resist_set
    result += [death_state_id] if @immortal
    result
  end
  
  #--------------------------------------------------------------------------
  # alias method: execute_damage
  #--------------------------------------------------------------------------
  alias bes_execute_damage execute_damage
  def execute_damage(user)
    return unless @result.dmg?
    bes_execute_damage(user)
  end
  
  #--------------------------------------------------------------------------
  # alias method: make_damage_value
  #--------------------------------------------------------------------------
  alias bes_make_damage_value make_damage_value
  def make_damage_value(user, item)
    return unless @result.dmg?
    bes_make_damage_value(user, item)
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_effect_apply
  #--------------------------------------------------------------------------
  alias bes_item_effect_apply item_effect_apply
  def item_effect_apply(user, item, effect)
    return unless @result.effect?
    bes_item_effect_apply(user, item, effect)
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_user_effect
  #--------------------------------------------------------------------------
  alias bes_item_user_effect item_user_effect
  def item_user_effect(user, item)
    return unless @result.effect?
    bes_item_user_effect(user, item)
  end
  
  #--------------------------------------------------------------------------
  # alias method: make_miss_popups
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleEngine"]
  alias bes_make_miss_popups make_miss_popups
  def make_miss_popups(user, item)
    @result.restore_damage unless @result.effect?
    bes_make_miss_popups(user, item)
    unless @result.effect?
      @result.store_damage
      @result.clear_damage_values
    end
  end
  end
  
  #--------------------------------------------------------------------------
  # new method: face_coordinate
  #--------------------------------------------------------------------------
  def face_coordinate(destination_x, destination_y)
    direction = Direction.face_coordinate(self.screen_x, self.screen_y, destination_x, destination_y)
    #direction = Direction.opposite(direction) if self.sprite.mirror
    @direction = direction
    return if $imported["BattleSymphony-HB"] && self.use_hb?
    return if SYMPHONY::Visual::DISABLE_AUTO_MOVE_POSE && self.use_custom_charset?
    @pose = Direction.pose(direction)
  end
  
  #--------------------------------------------------------------------------
  # new method: create_movement
  #--------------------------------------------------------------------------
  def create_movement(destination_x, destination_y, frames = 12)
    return if @screen_x == destination_x && @screen_y == destination_y
    @destination_x = destination_x
    @destination_y = destination_y
    frames = [frames, 1].max
    @f = frames.to_f / 2
    @move_x_rate = [(@screen_x - @destination_x).abs / frames, 2].max
    @move_y_rate = [(@screen_y - @destination_y).abs / frames, 2].max
  end
  
  #--------------------------------------------------------------------------
  # new method: create_jump
  #--------------------------------------------------------------------------
  def create_jump(arc)
    @arc = arc
    @parabola[:x] = 0
    @parabola[:y0] = 0
    @parabola[:y1] = @destination_y - @screen_y
    @parabola[:h]  = - (@parabola[:y0] + @arc * 5)
    @parabola[:d]  = (@screen_x - @destination_x).abs
  end
  
  #--------------------------------------------------------------------------
  # new method: create_icon
  #--------------------------------------------------------------------------
  def create_icon(symbol, icon_id = 0)
    delete_icon(symbol)
    #---
    case symbol
    when :weapon1
      object = self.weapons[0]
      icon_id = object.nil? ? nil : object.icon_index
    when :weapon2
      object = dual_wield? ? self.weapons[1] : nil
      icon_id = object.nil? ? nil : object.icon_index
    when :shield
      object = dual_wield? ? nil : self.equips[1]
      icon_id = object.nil? ? nil : object.icon_index
    when :item
      object = self.current_action.item
      icon_id = object.nil? ? nil : object.icon_index
    else; end
    return if icon_id.nil? || icon_id <= 0
    icon = Sprite_Object.new(self.sprite.viewport)
    icon.set_icon(icon_id)
    icon.set_battler(self)
    #---
    @icons[symbol] = icon
  end
    
  #--------------------------------------------------------------------------
  # new method: delete_icon
  #--------------------------------------------------------------------------
  def delete_icon(symbol)
    return unless @icons[symbol]
    @icons[symbol].dispose
    @icons.delete(symbol)
  end
  
  #--------------------------------------------------------------------------
  # new method: clear_icons
  #--------------------------------------------------------------------------
  def clear_icons
    @icons.each { |key, value|
      value.dispose
      @icons.delete(key)
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: update_movement
  #--------------------------------------------------------------------------
  def update_movement
    return unless self.is_moving?
    @move_x_rate = 0 if @screen_x == @destination_x || @move_x_rate.nil?
    @move_y_rate = 0 if @screen_y == @destination_y || @move_y_rate.nil?
    value = [(@screen_x - @destination_x).abs, @move_x_rate].min
    @screen_x += (@destination_x > @screen_x) ? value : -value
    value = [(@screen_y - @destination_y).abs, @move_y_rate].min
    @screen_y += (@destination_y > @screen_y) ? value : -value
  end
  
  #--------------------------------------------------------------------------
  # new method: update_jump
  #--------------------------------------------------------------------------
  def update_jump
    return unless self.is_moving?
    #---
    value = [(@screen_x - @destination_x).abs, @move_x_rate].min
    @screen_x += (@destination_x > @screen_x) ? value : -value
    @parabola[:x] += value
    @screen_y -= @arc_y
    #---
    if @destination_x == @screen_x
      @screen_y = @destination_y
      @arc_y = 0
      @arc = 0
    else
      a = (2.0*(@parabola[:y0]+@parabola[:y1])-4*@parabola[:h])/(@parabola[:d]**2)
      b = (@parabola[:y1]-@parabola[:y0]-a*(@parabola[:d]**2))/@parabola[:d]
      @arc_y = a * @parabola[:x] * @parabola[:x] + b * @parabola[:x] + @parabola[:y0]
    end
    #---
    @screen_y += @arc_y
    @move_x_rate = 0 if @screen_x == @destination_x
    @move_y_rate = 0 if @screen_y == @destination_y
  end
  
  #--------------------------------------------------------------------------
  # new method: update_icons
  #--------------------------------------------------------------------------
  def update_icons
    @icons ||= {}
    @icons.each_value { |value| value.update }
  end
  
  #--------------------------------------------------------------------------
  # new method: update_visual
  #--------------------------------------------------------------------------
  def update_visual
    return unless SceneManager.scene_is?(Scene_Battle)
    return unless SceneManager.scene.spriteset
    correct_origin_position
    #---
    @arc == 0 ? update_movement : update_jump
    update_icons
  end
  
  #--------------------------------------------------------------------------
  # new method: is_moving?
  #--------------------------------------------------------------------------
  def is_moving?
    [@move_x_rate, @move_y_rate].any? { |x| x != 0 }
  end
  
  #--------------------------------------------------------------------------
  # new method: is_moving?
  #--------------------------------------------------------------------------
  def dual_attack?
    self.actor? && self.current_action.attack? && self.dual_wield? && self.weapons.size > 1
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_battle_end
  #--------------------------------------------------------------------------
  alias bes_on_battle_end on_battle_end
  def on_battle_end
    bes_on_battle_end
    clear_icons
  end
  
end # Game_Battler

#==============================================================================
# ■ Sprite_Battler
#==============================================================================

class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # new method: is_moving?
  #--------------------------------------------------------------------------
  def is_moving?
    return unless @battler
    @battler.is_moving?
  end
  
end # Sprite_Battler

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================

class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # new method: is_moving?
  #--------------------------------------------------------------------------
  def is_moving?
    self.battler_sprites.any? { |sprite| sprite.is_moving? }
  end
  
end # Spriteset_Battle

#==============================================================================
# ■ Window_BattleLog
#==============================================================================

class Window_BattleLog < Window_Selectable
  
  
  
end # Window_BattleLog

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # overwrite method: use_item
  #--------------------------------------------------------------------------
  def use_item
    @scene_item = item = @subject.current_action.item
    targets = @subject.current_action.make_targets.compact
    #---
    attack = @subject.current_action.attack?
    weapon = @subject.weapons[0]
    w_action = attack && weapon
    #---
    targets = targets * 2 if attack && @subject.dual_attack?
    #--- Setup Actions ---
    actions_list = item.setup_actions_list
    actions_list = weapon.setup_actions_list if w_action && weapon.valid_actions?(:setup)
    perform_actions_list(actions_list, targets)
    #--- Item Costs ---
    @subject.use_item(item)
    refresh_status
    #--- YEA - Cast Animation
    process_casting_animation if $imported["YEA-CastAnimations"]
    #--- YEA - Lunatic Object
    if $imported["YEA-LunaticObjects"]
      lunatic_object_effect(:before, item, @subject, @subject)
    end
    #--- Whole Actions ---
    actions_list = item.whole_actions_list
    actions_list = weapon.whole_actions_list if w_action && weapon.valid_actions?(:whole)
    perform_actions_list(actions_list, targets)
    #--- Target Actions ---
    actions_list = item.target_actions_list
    actions_list = weapon.target_actions_list if w_action && weapon.valid_actions?(:target)
    targets.each { |target| 
      next if target.dead?
      perform_actions_list(actions_list, [target])
    }
    #--- Follow Actions ---
    actions_list = item.follow_actions_list
    actions_list = weapon.follow_actions_list if w_action && weapon.valid_actions?(:follow)
    perform_actions_list(actions_list, targets)
    #--- Finish Actions ---
    actions_list = item.finish_actions_list
    actions_list = weapon.finish_actions_list if w_action && weapon.valid_actions?(:finish)
    immortal_flag = ["IMMORTAL", ["TARGETS", "FALSE"]]
    if !actions_list.include?(immortal_flag)
      if SYMPHONY::Fixes::AUTO_IMMORTAL_OFF
        actions_list = [immortal_flag] + actions_list
      end
    end
    perform_actions_list(actions_list, targets)
    #--- YEA - Lunatic Object
    if $imported["YEA-LunaticObjects"]
      lunatic_object_effect(:after, item, @subject, @subject)
    end
    targets.each { |target| 
      next unless target.actor?
      @status_window.draw_item(target.index)
    }
  end
  
  #--------------------------------------------------------------------------
  # alias method: invoke_item
  #--------------------------------------------------------------------------
  alias bes_invoke_item invoke_item
  def invoke_item(target, item)
    if $imported["YEA-TargetManager"]
      target = alive_random_target(target, item) if item.for_random?
    end
    bes_invoke_item(target, item)
    #--- Critical Actions ---
    actions_list = SYMPHONY::DEFAULT_ACTIONS::CRITICAL_ACTIONS
    perform_actions_list(actions_list, [target]) if target.result.critical
    #--- Miss Actions ---
    actions_list = SYMPHONY::DEFAULT_ACTIONS::MISS_ACTIONS
    perform_actions_list(actions_list, [target]) if target.result.missed
    #--- Evade Actions ---
    actions_list = SYMPHONY::DEFAULT_ACTIONS::EVADE_ACTIONS
    perform_actions_list(actions_list, [target]) if target.result.evaded
    #--- Fail Actions ---
    actions_list = SYMPHONY::DEFAULT_ACTIONS::FAIL_ACTIONS
    perform_actions_list(actions_list, [target]) if !target.result.success
    #--- Damaged Actions
    actions_list = SYMPHONY::DEFAULT_ACTIONS::DAMAGED_ACTION
    perform_actions_list(actions_list, [target]) if target.result.has_damage?
  end
  
  #--------------------------------------------------------------------------
  # alias method: execute_action
  #--------------------------------------------------------------------------
  alias bes_execute_action execute_action
  def execute_action
    bes_execute_action
    #--- Reset Flags ---
    ($game_party.battle_members + $game_troop.members).each { |battler|
      battler.result.set_calc; battler.result.clear
      battler.clear_icons
      battler.set_default_position
      battler.break_pose
    }
    $game_troop.screen.clear_bes_ve if $imported["BattleSymphony-VisualEffect"]
    @status_window.draw_item(@status_window.index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: invoke_counter_attack
  #--------------------------------------------------------------------------
  def invoke_counter_attack(target, item)
    @log_window.display_counter(target, item)
    last_subject = @subject
    @counter_subject = target
    @subject = target
    #---
    @subject.backup_actions
    #---
    @subject.force_make_actions
    @subject.current_action.set_attack
    #---
    actions_list = SYMPHONY::DEFAULT_ACTIONS::COUNTER_ACTION
    perform_actions_list(actions_list, [last_subject])
    #---
    @subject.clear_actions
    @subject = last_subject
    #---
    @counter_subject.restore_actions
    #---
    @counter_subject = nil
    @log_window.display_action_results(@subject, item)
    refresh_status
    perform_collapse_check(@subject)
    perform_collapse_check(target)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: invoke_magic_reflection
  #--------------------------------------------------------------------------
  def invoke_magic_reflection(target, item)
    @subject.magic_reflection = true
    @log_window.display_reflection(target, item)
    last_subject = @subject
    @reflect_subject = target
    @subject = target
    #---
    @subject.backup_actions
    #---
    @subject.force_make_actions
    if item.is_a?(RPG::Skill); @subject.current_action.set_skill(item.id)
      else; @subject.current_action.set_item(item.id); end
    #---
    actions_list = SYMPHONY::DEFAULT_ACTIONS::REFLECT_ACTION
    perform_actions_list(actions_list, [last_subject])
    #---
    @subject.clear_actions
    @subject = last_subject
    #---
    @reflect_subject.restore_actions
    #---
    @reflect_subject = nil
    @log_window.display_action_results(@subject, item)
    refresh_status
    perform_collapse_check(@subject)
    perform_collapse_check(target)
    @subject.magic_reflection = false
  end
  
  #--------------------------------------------------------------------------
  # alias method: apply_substitute
  #--------------------------------------------------------------------------
  alias bes_apply_substitute apply_substitute
  def apply_substitute(target, item)
    substitute = bes_apply_substitute(target, item)
    if target != substitute
      @substitute_subject = substitute
    end
    return substitute
  end
    
  #--------------------------------------------------------------------------
  # new method: wait_for_move
  #--------------------------------------------------------------------------
  def wait_for_move
    update_for_wait
    update_for_wait while @spriteset.is_moving?
  end
  
  #--------------------------------------------------------------------------
  # new method: spriteset
  #--------------------------------------------------------------------------
  def spriteset
    @spriteset
  end
  
  #--------------------------------------------------------------------------
  # compatible overwrite method: separate_ani?
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleEngine"]
  def separate_ani?(target, item)
    return false
  end
  end

  #--------------------------------------------------------------------------
  # new method: perform_collapse_check
  #--------------------------------------------------------------------------
  def perform_collapse_check(target)
    target.perform_collapse_effect if target.can_collapse?
    @log_window.wait_for_effect
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_log_window
  #--------------------------------------------------------------------------
#~   def create_log_window
#~     @log_window = Window_BattleLog.new
#~   end
  
end # Scene_Battle

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================
