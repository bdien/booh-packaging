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

# holds static data to merge in the html "themes"

require 'gettext'
bindtextdomain("booh")

require 'booh/booh-lib'
require 'booh/version.rb'
include Booh

$image_head_code = '<meta name="generator" content="Booh-' + $VERSION + <<'EOF'
 http://booh.org/"/>

<script language="JavaScript1.1" type="text/JavaScript">
var images = new Array(~~images~~);
var types = new Array(~~types~~);
var videos = new Array(~~videos~~);
var widths = new Array(~~widths~~);
var heights = new Array(~~heights~~);
~~other_images~~
var thumbnailspages = new Array(~~thumbnailspages~~);
var other_sizes = new Array(~~other_sizes~~);
var captions = new Array(~~captions~~);

dbltilda_current_size = '~~current_size~~';
dbltilda_theme = '~~theme~~';
dbltilda_stop_slideshow = '~~stop_slideshow~~';
dbltilda_run_slideshow = '~~run_slideshow~~';
dbltilda_htmlsuffix = '~~htmlsuffix~~';
dbltilda_pathtobase = '~~pathtobase~~';
dbltilda_flowplayer_active = '~~flowplayer_active~~';
</script>
EOF

$image_head_code.sub!('~~run_slideshow~~', defer_translation(N_('Run slideshow!')))
$image_head_code.sub!('~~stop_slideshow~~', defer_translation(N_('Stop slideshow')))

$body_additions = <<'EOF'
onload="init()" id="body"
EOF

$button_first = '
    <form action="fake"><input type="button"
                 onclick="first()"
                 value="' + defer_translation(N_('<<- First')) + '"
                 id="b_first"/></form>'

$button_previous = '
    <form action="fake"><input type="button"
                 onclick="previous()"
                 value="' + defer_translation(N_('<- Previous')) + '"
                 id="b_previous"/></form>'

$button_next = '
    <form action="fake"><input type="button"
                 onclick="next()"
                 value="' + defer_translation(N_('Next ->')) + '"
                 id="b_next"/></form>'

$button_last = '
    <form action="fake"><input type="button"
                 onclick="last()"
                 value="' + defer_translation(N_('Last ->>')) + '"
                 id="b_last"/></form>'

$button_slideshow = '
    <input type="button"
           onclick="toggle_slideshow(true)"
           value="' + defer_translation(N_('Run slideshow!')) + '"
           id="b_slideshow"/>'

$pause_slideshow = '
    <font size="-2">' + defer_translation(N_('pause:')) + '<input type="text" id="secs" size="1" value="3"/>' + defer_translation(N_('secs')) + '</font>'


$image = <<'EOF'
  <span id="main_img">Loading image, please wait...</span>
EOF

$image_counter_additions = <<'EOF'
  id="image_counter"
EOF

$caption_additions = <<'EOF'
  id="main_text"
EOF

$body_code = <<'EOF'
EOF


$thumbnails_head_code = '<meta name="generator" content="Booh-' + $VERSION + <<'EOF'
 http://booh.org/"/>

<script language="JavaScript1.1" type="text/JavaScript">
function set_preferred_size(val) {
    var expires = new Date(new Date().getTime() + (30 * 86400000));  // 30 days
    document.cookie = 'booh-preferred-size-~~theme~~='
                      + val
                      + '; expires=' + expires.toGMTString()
                      + '; path=/';
}
</script>
EOF


$preferred_size_reloader = <<'EOF'
<html>
    <head>
        <script language="JavaScript1.1" type="text/JavaScript">

var sizes = new Array(~~all_sizes~~);

function getPreferredSize() {
    if (document.cookie) {
        var index = document.cookie.indexOf('booh-preferred-size-~~theme~~');
        if (index != -1) {
            var oleft = document.cookie.indexOf('=', index) + 1;
            var oright = document.cookie.indexOf(';', index);
            if (oright == -1) {
                oright = document.cookie.length;
            }
            size = document.cookie.substring(oleft, oright);
            for (i = 0; i < sizes.length; i++) {
                if (sizes[i] == size) {
                    return 'thumbnails-' + size + '-0~~htmlsuffix~~';
                }
            }
        }
    }
    w = document.body.offsetWidth;
    ~~size_auto_chooser~~
    return 'thumbnails-~~default_size~~-0~~htmlsuffix~~';
}

        </script>

        <meta http-equiv="refresh" content="0.1;url=thumbnails-~~default_size~~-nojs-0~~htmlsuffix~~" />
    </head>
    <body onload="window.location.href = getPreferredSize()">
    </body>
</html>
EOF


$index_head_code = '<meta name="generator" content="Booh-' + $VERSION + ' http://booh.org/"/>
<script language="JavaScript1.1" type="text/JavaScript">
function init() {
    if (!document.cookie || document.cookie.indexOf("booh-not-a-newbie") == -1) {
        document.getElementById("title").innerHTML += "<br/><br/>' + defer_translation(N_("<i>Hint: you can click on the images to open the albums!</i>")) + '";
    }
    var expires = new Date(new Date().getTime() + (10 * 86400000));  // 10 days
    document.cookie = "booh-not-a-newbie=true"
                      + "; expires=" + expires.toGMTString()
                      + "; path=/";
}
</script>'
