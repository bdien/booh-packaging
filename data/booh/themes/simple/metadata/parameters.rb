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

#- it's necessary to fit according to the typical space taken by
#- widgets defined in the skeleton of the theme
#-
#- ***IMPORTANT***: CHOOSE 4/3 ASPECT RATIO SIZES (for thumbnails)!
$images_size = [
    {
        'name' => 'medium',
        'description' => _("Sizes that should fit browsers in fullscreen for 1024x768 screens"),
        'fullscreen' => '960x528',
        'thumbnails' => '240x180',
        'optimizedforwidth' => '1024',
        'default' => true,
    },
    {
        'name' => 'large',
        'description' => _("Sizes that should fit browsers in fullscreen for 1280x1024 screens"),
        'fullscreen' => '1200x724',
        'thumbnails' => '300x225',
        'optimizedforwidth' => '1280',
        'optional' => true,
    },
    {
        'name' => 'x-large',
        'description' => _("Sizes that should fit browsers in fullscreen for 1400x1050 screens"),
        'fullscreen' => '1312x750',
        'thumbnails' => '328x245',
        'optimizedforwidth' => '1400',
        'optional' => true,
    },
    {
        'name' => 'xx-large',
        'description' => _("Sizes that should fit browsers in fullscreen for 1600x1200 screens"),
        'fullscreen' => '1500x900',
        'thumbnails' => '375x281',
        'optimizedforwidth' => '1600',
        'optional' => true,
    },
    {
        'name' => 'widescreen',
        'description' => _("Sizes that should fit browsers in fullscreen for 1680x1050 screens"),
        'fullscreen' => '1580x750',
        'thumbnails' => '390x292',
        'optimizedforwidth' => '1680',
        'optional' => true,
    },
    {
        'name' => 'fullhd',
        'description' => _("Sizes that should fit browsers in fullscreen for 1920x1080 screens"),
        'fullscreen' => '1820x780',
        'thumbnails' => '445x333',
        'optimizedforwidth' => '1920',
        'optional' => true,
    },
]

$allowed_N_values = [ 3, 4, 5, 6, 8, 12 ]
$default_N = 4

$albums_thumbnail_size = '300x225'
