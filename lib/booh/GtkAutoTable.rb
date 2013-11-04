#                         *  BOOH  *
#
# A.k.a `Best web-album Of the world, Or your money back, Humerus'.
#
# The acronyn sucks, however this is a tribute to Dragon Ball by
# Akira Toriyama, where the last enemy beaten by heroes of Dragon
# Ball is named "Boo". But there was already a free software project
# called Boo, so this one will be it "Booh". Or whatever.
#
#
# Copyright (c) 2004 Guillaume Cottenceau <gc3 at bluewin.ch>
#
# This software may be freely redistributed under the terms of the GNU
# public license version 2.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

require 'gtk2'

require 'booh/booh-lib'
include Booh

class Gtk::Allocation
    def to_s
        "width:#{width} heigth:#{height}"
    end
end

class Gtk::AutoTable < Gtk::EventBox

    attr_accessor :queue_draws

    def initialize(row_spacings)
        @children = []
        @containers = []
        @width = -1
        @old_widths = []
        @queue_draws = []
        @row_spacings = row_spacings
        @table = nil
        super()
        recreate_table
        signal_connect('size-allocate') { |w, allocation|
            msg 3, "got self allocation: #{allocation}"
            if @width != allocation.width
                if !@old_widths.include?(allocation.width)
                    @width = allocation.width
                    @old_widths.unshift(@width)
                    @old_widths = @old_widths[0..2]
                    redistribute(false)
                else
                    msg 3, "\tDISABLING: #{allocation.width} - #{@old_widths.join(',')}"
                end
            end
        }
        @timeout = Gtk.timeout_add(100) {
            if @queue_draws.size > 0
                @queue_draws.each { |elem| elem.call }
                @queue_draws.clear
            end
            true
        }
    end


    def destroy
        Gtk.timeout_remove(@timeout)
        super.destroy
    end

    #- add (append) a widget to the list of automatically handled widgets
    def append(widget, name)
        #- create my child hash
        child = { :widget => widget, :name => name }
        #- put it in the table if last container's widget has been allocated
        last_container = @containers[-1]
        if !last_container || last_container[:contained_element] && last_container[:contained_element][:allocation]
            put(child, (last_container ? last_container[:x] : -1) + 1, last_container ? last_container[:y] : 0)
        end
        #- add it to the internal children array
        @children << child

        #- connect 'size-allocate' signal to be sure to update allocation when received
        widget.signal_connect('size-allocate') { |w, allocation|
            msg 3, "got allocation for #{w.hash}: #{allocation} (#{allocation.hash})"
            chld = @children.find { |e| e[:widget] == w }
            if chld
                old = chld[:allocation]
                #- need to copy values because the object will be magically exploded when widget is removed
                chld[:allocation] = { :width => allocation.width, :height => allocation.height }
                if !old #|| old[:width] != allocation.width # || old[:height] != allocation.height
                    msg 3, "redistribute!"
                    chld == @children[0] && old and msg 3, "************ old was #{old[:width]} #{old[:height]}"
                    redistribute(true)
                end
            else
                warn "Critical: child not found!"
            end
        }
    end

    #- remove a widget from the list of automatically handled widgets
    def remove_widget(widget)
        @children.each_with_index { |chld, index|
            if chld[:widget] == widget
                @children.delete_at(index)
                redistribute(true)
                return true
            end
        }
        return false
    end

    #- re-insert a widget at a given pos
    def reinsert(pos, widget, name)
        child = { :widget => widget, :name => name }
        @children[pos, 0] = child
        redistribute(true)
    end

    #- remove all widgets
    def clear
        @children = []
        redistribute(false)
    end

    #- get current order of widget
    def current_order
        return @children.collect { |chld| chld[:name] }
    end

    #- get current [x, y] position of widget within automatically handled table
    def get_current_pos(widget)
        chld = @children.find { |e| e[:widget] == widget }
        if chld
            return [ chld[:x], chld[:y] ]
        else
            return nil
        end
    end

    #- get current number (rank in current ordering) of widget within automatically handled table
    def get_current_number(widget)
        @children.each_with_index { |chld, index|
            if chld[:widget] == widget
                return index
            end
        }
        return -1
    end

    #- move widgets by numbers
    def move(src, dst)
        if src != dst
            chld = @children.delete_at(src)
            @children[dst > src ? dst - 1 : dst, 0] = chld
            redistribute(true)
        end
    end

    #- get widget at [x, y] position of automatically handled table
    def get_widget_at_pos(x, y)
        @children.each { |chld|
            if chld[:x] == x && chld[:y] == y
                return chld[:widget]
            end
        }
        return nil
    end

    #- get maximum `y' position within the automatically handled table
    def get_max_y
        return @children[-1][:y]
    end

    #- get the current `previous' widget (table-wise); important since widgets can be reordered with mouse drags
    def get_previous_widget(widget)
        @children.each_with_index { |chld, index|
            if chld[:widget] == widget
                if index == 0
                    return nil
                else
                    return @children[index - 1][:widget]
                end
            end
        }
        return nil
    end

    #- get the current `next' widget (table-wise); important since widgets can be reordered with mouse drags
    def get_next_widget(widget)
        @children.each_with_index { |chld, index|
            if chld[:widget] == widget
                if index == @children.size - 1
                    return nil
                else
                    return @children[index + 1][:widget]
                end
            end
        }
        return nil
    end

    #- move specified widget `up' in the table
    def move_up(widget)
        @children.each_with_index { |chld, index|
            if chld[:widget] == widget && chld[:y] > 0
                @children.each_with_index { |chld2, index2|
                    if chld2[:x] == chld[:x] && chld[:y] == chld2[:y] + 1
                        @children[index], @children[index2] = chld2, chld
                        redistribute(true)
                        return true
                    end
                }
            end
        }
        return false
    end

    #- move specified widget `down' in the table
    def move_down(widget)
        @children.each_with_index { |chld, index|
            if chld[:widget] == widget && chld[:y] < get_max_y
                @children.each_with_index { |chld2, index2|
                    if chld2[:x] == chld[:x] && chld[:y] == chld2[:y] - 1
                        @children[index], @children[index2] = chld2, chld
                        redistribute(true)
                        return true
                    end
                }
            end
        }
        return false
    end

    #- move specified widget `left' in the table
    def move_left(widget)
        @children.each_with_index { |chld, index|
            if chld[:widget] == widget && chld[:x] > 0
                @children[index], @children[index - 1] = @children[index - 1], @children[index]
                redistribute(true)
                return true
            end
        }
        return false
    end

    #- move specified widget `right' in the table
    def move_right(widget)
        @children.each_with_index { |chld, index|
            if chld[:widget] == widget && @children[index + 1] && chld[:x] < @children[index + 1][:x]
                @children[index], @children[index + 1] = @children[index + 1], @children[index]
                redistribute(true)
                return true
            end
        }
        return false
    end


    private

    def put(element, x, y)
        msg 3, "putting #{element[:widget].hash} at #{x},#{y}"
        element[:x] = x
        element[:y] = y
        container = @containers.find { |e| e[:x] == x && e[:y] == y }
        if !container
            container = { :x => x, :y => y, :widget => Gtk::VBox.new, :fake => Gtk::Label.new('fake') }
            msg 3, "attaching at #{x},#{y}"
            @table.attach(container[:widget], x, x + 1, y, y + 1, Gtk::FILL, Gtk::FILL, 5, 0)
            @containers << container
        end
        if container[:contained_element]
            container[:widget].remove(container[:contained_element][:widget])
        end
        container[:contained_element] = element
        container[:widget].add(element[:widget])
        @table.show_all
    end

    def recreate_table
        @containers.each { |e|
            if e[:contained_element]
                e[:widget].remove(e[:contained_element][:widget])
            end
        }
        @containers = []
        if @table
            remove(@table)
            @table.hide     #- should be #destroy, but that triggers an Abort in booh, and I cannot really understand why and fix 
                            #- this is a memory leak, so ideally it should be either fixed in ruby-gtk2 0.16.0, or at least checked if
                            #- it's not fixed from a side effect of another fix in the future
        end
        add(@table = Gtk::Table.new(0, 0, true))
        @table.set_row_spacings(@row_spacings)
    end

    def redistribute(force)
        msg 3, "redistribute: "
        @children.each { |e| msg_ 3, e[:allocation] ? 'O' : '.' }; msg 3, ''
        if unallocated = @children.find { |e| !e[:allocation] }
            #- waiting for allocations. replace last displayed widget with first unallocated.
            last_container = @containers[-1]
            put(unallocated, last_container ? last_container[:x] : 0, last_container ? last_container[:y]: 0)

        else
            if @children.size == 0
                recreate_table
                return

            else
                totalwidth = allocation.width
                maxwidth = @children.collect { |chld| chld[:allocation][:width] }.max
                xpix = 5 + maxwidth + 5
                x = 1
                y = 0
                @children[1..-1].each { |e|
                    if xpix + 5 + maxwidth + 5 > totalwidth - 1
                        x = 0
                        y += 1
                        xpix = 0
                    end
                    e[:xnew] = x
                    e[:ynew] = y
                    x += 1
                    xpix += 5 + maxwidth + 5
                }
                if @children[1..-1].find { |e| e[:xnew] != e[:x] || e[:ynew] != e[:y] } || force
                    msg 3, "I can proceed with #{allocation}"
                    recreate_table
                    put(@children[0], 0, 0)
                    @children[1..-1].each { |e|
                        put(e, e[:xnew], e[:ynew])
                    }
                    show_all
                    @queue_draws << proc { queue_draw }
                end
            end
        end
    end

end
