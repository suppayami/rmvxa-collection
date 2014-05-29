# use comment tag to define event sizes
# the sizes will be used as unit, one unit = 32 pixels
#
# comment tag:
#
# big event: X Y
# with X is the width
# with Y is the height
#
# Free for commercial usages.
# Author: Dr.Yami

class Game_Event < Game_Character

  def note
    begin
      data = []
      @page.list.each do |item|
        next unless item && (item.code == 108 || item.code == 408)
        data.push(item.parameters[0])
      end
      return data
    rescue
      return []
    end
  end

  def event_height
    note.each do |line|
      if line =~ /big event:[ ]*(\d+)[ ]+(\d+)/i
        return $2.to_i - 1
      end
    end
    return 0
  end

  def event_width
    note.each do |line|
      if line =~ /big event:[ ]*(\d+)[ ]+(\d+)/i
        return $1.to_i - 1
      end
    end
    return 0
  end

  def pos?(x, y)
    (x <= @x + event_width) && (x >= @x) &&
      (y >= @y - event_height) && (y <= @y)
  end

end
