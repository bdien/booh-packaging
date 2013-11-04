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

require 'gettext'
require 'gtk2'
include GetText
bindtextdomain("booh")

module UndoHandler

    @undo_actions = []
    @redo_actions = []
    @batch_mode = false

    module_function

    def save_undo(name, closure, params)
        entry = { :name => name, :closure => closure, :params => params }
        if @batch_mode
            @batch << entry
        else
            @undo_actions << [ entry ]
        end
        @redo_actions = []
    end

    def undo(statusbar)
        all_todos = @undo_actions.pop
        redos = []
        all_todos.reverse.each { |todo|
            redo_closure = todo[:closure].call(*todo[:params])
            statusbar.pop(0)
            statusbar.push(0, utf8(_("Undo %s.") % todo[:name]))
            redos << { :name => todo[:name], :redo => redo_closure, :undo => todo }
        }
        @redo_actions << redos
        return !@undo_actions.empty?
    end

    def redo(statusbar)
        all_redos = @redo_actions.pop
        undos = []
        all_redos.reverse.each { |redo_item|
            redo_item[:redo].call
            statusbar.pop(0)
            statusbar.push(0, utf8(_("Redo %s.") % redo_item[:name]))
            undos << redo_item[:undo]
        }
        @undo_actions << undos
        return !@redo_actions.empty?
    end

    def begin_batch
        @batch_mode = true
        @batch = []
    end

    def end_batch
        @batch_mode = false
        @undo_actions << @batch
    end

    def cleanup
        @undo_actions.clear
        @redo_actions.clear
    end

end
