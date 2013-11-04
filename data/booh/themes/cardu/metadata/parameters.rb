#
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

bindtextdomain("booh")

#- we often will want to have one size to nicely fit 800x600 screens,
#- one for 1024x768 and one for 1280x1024
#- it's necessary to fit according to the typical space taken by
#- widgets defined in the skeleton of the theme
#-
#- ***IMPORTANT***: CHOOSE 4/3 ASPECT RATIO SIZES (for thumbnails)!
$images_size = [
    {
        'name' => 'small',
        'description' => _("Sizes that should fit browsers in fullscreen for 800x600 screens"),
        'fullscreen' => '600x331',
        'thumbnails' => '192x144',
        'optimizedforwidth' => '800',
        'optional' => true,
    },
    {
        'name' => 'medium',
        'description' => _("Sizes that should fit browsers in fullscreen for 1024x768 screens"),
        'fullscreen' => '758x422',
        'thumbnails' => '240x180',
        'optimizedforwidth' => '1024',
        'default' => true,
    },
    {
        'name' => 'large',
        'description' => _("Sizes that should fit browsers in fullscreen for 1280x1024 screens"),
        'fullscreen' => '960x528',
        'thumbnails' => '309x232',
        'optimizedforwidth' => '1280',
    },
    {
        'name' => 'x-large',
        'description' => _("Sizes that should fit browsers in fullscreen for 1400x1050 screens"),
        'fullscreen' => '1050x576',
        'thumbnails' => '328x245',
        'optimizedforwidth' => '1400',
        'optional' => true,
    },
    {
        'name' => 'xx-large',
        'description' => _("Sizes that should fit browsers in fullscreen for 1600x1200 screens"),
        'fullscreen' => '1200x660',
        'thumbnails' => '375x281',
        'optimizedforwidth' => '1600',
        'optional' => true,
    }
]

$allowed_N_values = [ 3, 4, 5, 6, 8, 12 ]
$default_N = 3

$albums_thumbnail_size = '300x225'

$hooks = {
    :image_iteration => proc { |content, type|
        return content.sub(/width:(\d+)px/) { "width:" + ($1.to_i + 8).to_s + "px" }
    }
}
