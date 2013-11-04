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
#- ***IMPORTANT***: CHOOSE 4/3 ASPECT RATIO SIZES!
$images_size = [
    {
        'name' => 'small',
        'description' => _("Sizes that should fit browsers in fullscreen for 800x600 screens"),
        'fullscreen' => '552x414',
        'thumbnails' => '184x138',
        'optimizedforwidth' => '800',
        'optional' => true,
    },
    {
        'name' => 'medium',
        'description' => _("Sizes that should fit browsers in fullscreen for 1024x768 screens"),
        'fullscreen' => '704x528',
        'thumbnails' => '232x174',
        'optimizedforwidth' => '1024',
        'default' => true,
    },
    {
        'name' => 'large',
        'description' => _("Sizes that should fit browsers in fullscreen for 1280x1024 screens"),
        'fullscreen' => '880x660',
        'thumbnails' => '292x219',
        'optimizedforwidth' => '1280',
    },
    {
        'name' => 'x-large',
        'description' => _("Sizes that should fit browsers in fullscreen for 1400x1050 screens"),
        'fullscreen' => '962x721',
        'thumbnails' => '320x240',
        'optimizedforwidth' => '1400',
        'optional' => true,
    },
    {
        'name' => 'xx-large',
        'description' => _("Sizes that should fit browsers in fullscreen for 1600x1200 screens"),
        'fullscreen' => '1100x825',
        'thumbnails' => '368x276',
        'optimizedforwidth' => '1600',
        'optional' => true,
    }
]

$allowed_N_values = [ 3, 4, 5, 6, 8, 12 ]
$default_N = 4

$albums_thumbnail_size = '300x225'
