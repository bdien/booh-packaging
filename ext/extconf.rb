=begin
extconf.rb for booh lib additions
=end

PACKAGE_NAME = "booh/libadds"

#- some adds to Gdk::Pixbuf
require 'mkmf-gnome2'
PKGConfig.have_package('gtk+-2.0') or exit 1
have_func("gdk_pixbuf_set_option")
have_header("gdk-pixbuf/gdk-pixbuf-io.h")

#- direct exiv2 access for some EXIF stuff
PKGConfig.have_package('exiv2') or exit 1

#- does it do something good, actually?
setup_win32(PACKAGE_NAME)

begin
    create_makefile_at_srcdir(PACKAGE_NAME, File.dirname(__FILE__))
rescue NoMethodError
    #- bug in rg2 0.17.0rc1, unfortunately on "stable" ubuntu jaunty
    create_makefile_at_srcdir(PACKAGE_NAME, 'ext')
end
