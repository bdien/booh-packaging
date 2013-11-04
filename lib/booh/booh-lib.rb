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
# Copyright (c) 2004-2010 Guillaume Cottenceau
#
# This software may be freely redistributed under the terms of the GNU
# public license version 2.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

require 'iconv'
require 'timeout'
require 'tempfile'
require 'monitor'

require 'booh/rexml/document'

require 'gettext'
include GetText
bindtextdomain("booh")

require 'booh/config.rb'
require 'booh/version.rb'
begin
    require 'gtk2'
rescue LoadError
    $no_gtk2 = true
end
begin
    require 'booh/libadds'
rescue LoadError
    $no_libadds = true
end

module Booh
    $verbose_level = 2
    $CURRENT_CHARSET = `locale charmap`.chomp
    #- check charset availability. a locale configuration of C or POSIX yields the unsupported 'ANSI_X3.4-1968'.
    begin
        REXML::XMLDecl.new(REXML::XMLDecl::DEFAULT_VERSION, $CURRENT_CHARSET)
    rescue
        $CURRENT_CHARSET = 'UTF-8'
    end
    $convert = 'convert -interlace line +profile "*"'
    $convert_enhance = '-contrast -enhance -normalize'

    def utf8(string)
        begin
            return Iconv::iconv("UTF-8", $CURRENT_CHARSET, string).to_s
        rescue
            return "???"
        end
    end

    def utf8cut(string, maxlen)
        begin
            return Iconv::iconv("UTF-8", $CURRENT_CHARSET, string[0..maxlen-1]).to_s
        rescue Iconv::InvalidCharacter
            return utf8cut(string, maxlen-1)
        rescue
            return "???"
        end
    end

    def sizename(key, translate)
        #- fake for gettext to find these; if themes need more sizes, english name for them should be added here
        sizenames = { 'small' => N_("small"), 'medium' => N_("medium"), 'large' => N_("large"),
                      'x-large' => N_("x-large"), 'xx-large' => N_("xx-large"),
                      'original' => N_("original") }
        sizename = sizenames[key] || key
        if translate
            return utf8(_(sizename))
        else
            return sizename
        end
    end

    SUPPORTED_LANGUAGES = %w(en de fr ja eo)

    def langname(lang)
        langnames = { 'en' => _("english"), 'de' => _("german"), 'fr' => _("french"), 'ja' => _("japanese"), 'eo' => _("esperanto") }
        return langnames[lang]
    end
    
    def from_utf8(string)
        return Iconv::iconv($CURRENT_CHARSET, "UTF-8", string).to_s
    end

    def from_utf8_safe(string)
        begin
            return Iconv::iconv($CURRENT_CHARSET, "UTF-8", string).to_s
        rescue Iconv::IllegalSequence
            return ''
        end
    end

    def make_dest_filename_old(orig_filename)
        #- we remove non alphanumeric characters but need to do that
        #- cleverly to not end up with two similar dest filenames. we won't
        #- urlencode because urldecode might happen in the browser.
        return orig_filename.unpack("C*").collect { |v| v.chr =~ /[a-zA-Z\-_0-9\.\/]/ ? v.chr : sprintf("%2X", v) }.to_s
    end

    def make_dest_filename(orig_filename)
        #- we remove non alphanumeric characters but need to do that
        #- cleverly to not end up with two similar dest filenames. we won't
        #- urlencode because urldecode might happen in the browser.
        return orig_filename.unpack("C*").collect { |v| v.chr =~ /[a-zA-Z\-_0-9\.\/]/ ? v.chr : sprintf("~%02X", v) }.to_s
    end

    def msg(verbose_level, msg)
        if verbose_level <= $verbose_level
            if verbose_level == 0
                warn _("\t***ERROR***: %s\n") % msg
            elsif verbose_level == 1
                warn _("\tWarning: %s\n") % msg
            else
                puts msg
            end
        end
    end

    def msg_(verbose_level, msg)
        if verbose_level <= $verbose_level
            if verbose_level == 0
                warn _("\t***ERROR***: %s") % msg
            elsif verbose_level == 1
                warn _("\tWarning: %s") % msg
            else
                print msg
            end
        end
    end

    def die_(msg)
        puts msg
        exit 1
    end

    def select_theme(name, limit_sizes, optimizefor32, nperrow)
        $theme = name
        msg 3, _("Selecting theme '%s'") % $theme
        $themedir = "#{$FPATH}/themes/#{$theme}"
        if !File.directory?($themedir)
            themedir2 = File.expand_path("~/.booh-themes/#{$theme}")
            if !File.directory?(themedir2)
                die_ _("Theme was not found (tried %s and %s directories).") % [ $themedir, themedir2 ]
            end
            $themedir = themedir2
        end
        eval File.open("#{$themedir}/metadata/parameters.rb").readlines.join

        if limit_sizes
            if limit_sizes != 'all'
                sizes = limit_sizes.split(/,/)
                $images_size = $images_size.find_all { |e| sizes.include?(e['name']) }
                if $images_size.length == 0
                    die_ _("Can't carry on, no valid size selected.")
                end
            end
        else
            $images_size = $images_size.find_all { |e| !e['optional'] }
        end

        if optimizefor32
            $images_size.each { |e|
                e['fullscreen'].gsub!(/(\d+x)(\d+)/) { $1 + ($2.to_f*8/9).to_i.to_s }
                e['thumbnails'].gsub!(/(\d+x)(\d+)/) { $1 + ($2.to_f*8/9).to_i.to_s }
            }
            $albums_thumbnail_size.gsub!(/(\d+x)(\d+)/) { $1 + ($2.to_f*8/9).to_i.to_s }
        end

        if nperrow && nperrow != $default_N
            ratio = nperrow.to_f / $default_N.to_f
            $images_size.each { |e|
                e['thumbnails'].gsub!(/(\d+)x(\d+)/) { ($1.to_f/ratio).to_i.to_s + 'x' + ($2.to_f/ratio).to_i.to_s }
            }
        end

        $default_size = $images_size.detect { |sizeobj| sizeobj['default'] }
        if $default_size == nil
            $default_size = $images_size[0]
        end
    end

    def entry2type(entry)
        #- /usr/lib/gdk-pixbuf/loaders/libpixbufloader-bmp.so
        #- /usr/lib/gdk-pixbuf/loaders/libpixbufloader-gif.so
        #- /usr/lib/gdk-pixbuf/loaders/libpixbufloader-ico.so
        #- /usr/lib/gdk-pixbuf/loaders/libpixbufloader-jpeg.so
        #- /usr/lib/gdk-pixbuf/loaders/libpixbufloader-png.so
        #- /usr/lib/gdk-pixbuf/loaders/libpixbufloader-pnm.so
        #- /usr/lib/gdk-pixbuf/loaders/libpixbufloader-ras.so
        #- /usr/lib/gdk-pixbuf/loaders/libpixbufloader-tiff.so
        #- /usr/lib/gdk-pixbuf/loaders/libpixbufloader-xbm.so
        #- /usr/lib/gdk-pixbuf/loaders/libpixbufloader-xpm.so
        if entry =~ /\.(bmp|gif|ico|jpg|jpe|png|pnm|tif|xbm|xpm)$/i && entry !~ /['"\[\]]/
            return 'image'
        elsif !$ignore_videos && entry =~ /\.(mov|avi|mpg|mpeg|mpe|wmv|asx|3gp|mp4|ogm|ogv|flv|f4v|f4p|dv)$/i && entry !~ /['"\[\]]/
            #- might consider using file magic later..
            return 'video'
        else
            return nil
        end
    end

    def sys(cmd)
        msg 2, cmd
        system(cmd)
    end

    def waitjob
        finished = Process.wait2
        $pids.delete(finished[0])
        $pids = $pids.find_all { |pid| Process.waitpid(pid, Process::WNOHANG) == nil }
    end

    def waitjobs
        while $pids && $pids.length > 0
            waitjob
        end
    end

    #- parallelizable sys
    def psys(cmd)
        if $mproc
            if pid = fork
                $pids << pid
            else
                msg 2, cmd + ' &'
                system(cmd)
                exit 0
            end
            if $pids.length == $mproc
                waitjob
            end
        else
            sys(cmd)
        end
    end

    def get_image_size(fullpath)
        if !$no_identify
            if $sizes_cache.nil?
                $sizes_cache = {}
            end
            if $sizes_cache[fullpath].nil?
                #- identify is slow, try with gdk if available (negligible vs 35ms)
                if $no_gtk2
                    if `identify '#{fullpath}'` =~ / JPEG (\d+)x(\d+) /
                        $sizes_cache[fullpath] = { :x => $1.to_i, :y => $2.to_i }
                    end
                else
                    format, width, height = Gdk::Pixbuf.get_file_info(fullpath)
                    if width
                        $sizes_cache[fullpath] = { :x => width, :y => height }
                    end
                end
            end
            return $sizes_cache[fullpath]
        else
            return nil
        end
    end

    #- commify from http://pleac.sourceforge.net/ (pleac rulz)
    def commify(n)
        n.to_s =~ /([^\.]*)(\..*)?/
        int, dec = $1.reverse, $2 ? $2 : ""
        sep = _(",")
        while int.gsub!(/(#{Regexp.quote(sep)}|\.|^)(\d{3})(\d)/, '\1\2' + sep + '\3')
        end
        int.reverse + dec
    end

    def guess_rotate(filename)
        #- identify is slow, try with libexiv2 if available (4ms vs 35ms)
        if $no_libadds
            if $no_identify
                return 0
            end
            orientation = `identify -format "%[EXIF:orientation]" '#{filename}'`.chomp.to_i
        else
            orientation = Exif.orientation(filename)
        end

        if orientation == 6
            angle = 90
        elsif orientation == 8
            angle = -90
        else
            return 0
        end

        #- remove rotate if image is obviously already in portrait (situation can come from gthumb)
        size = get_image_size(filename)
        if size && size[:x] < size[:y]
            return 0
        else
            return angle
        end
    end

    def angle_to_exif_orientation(angle)
        if angle == 90
            return 6
        elsif angle == 270 || angle == -90
            return 8
        else
            return 0
        end
    end

    def rotate_pixbuf(pixbuf, angle)
        return pixbuf.rotate(angle ==  90 ? Gdk::Pixbuf::ROTATE_CLOCKWISE :
                             angle == 180 ? Gdk::Pixbuf::ROTATE_UPSIDEDOWN :
                             (angle == 270 || angle == -90) ? Gdk::Pixbuf::ROTATE_COUNTERCLOCKWISE :
                                            Gdk::Pixbuf::ROTATE_NONE)
    end

    def gen_thumbnails_element(orig, xmldirorelem, allow_background, dests)
        rexml_thread_protect {
            if xmldirorelem.name == 'dir'
                xmldirorelem = xmldirorelem.elements["*[@filename='#{utf8(File.basename(orig))}']"]
            end
        }
        gen_thumbnails(orig, allow_background, dests, xmldirorelem, '')
    end

    def gen_thumbnails_subdir(orig, xmldirorelem, allow_background, dests, type)
        #- type can be `subdirs' or `thumbnails' 
        gen_thumbnails(orig, allow_background, dests, xmldirorelem, type + '-')
    end

    def gen_video_thumbnail(orig, colorswap, seektime)
        if colorswap
            #- ignored for the moment. is mplayer subject to blue faces problem?
        end
        #- it's not possible to specify a basename for the output jpeg file with mplayer (file will be named 00000001.jpg); as this can
        #- be called from multiple threads, we must come up with a unique directory where to put the file
        tmpfile = Tempfile.new("boohvideotmp")
        Thread.critical = true
        tmpdirname = tmpfile.path
        tmpfile.close!
        begin
            Dir.mkdir(tmpdirname)
        rescue Errno::EEXIST
            raise "Tmp directory #{tmpdirname} already exists"
        ensure
            Thread.critical = false
        end
        cmd = "mplayer '#{orig}' -nosound -vo jpeg:outdir='#{tmpdirname}' -frames 1 -ss #{seektime} -slave >/dev/null 2>/dev/null"
        sys(cmd)
        if ! File.exists?("#{tmpdirname}/00000001.jpg")
            msg 0, _("specified seektime too large? that may also be another probleme. try another value.")
            Dir.rmdir(tmpdirname)
            return nil
        end
        return tmpdirname
    end

    def gen_thumbnails(orig, allow_background, dests, felem, attributes_prefix)
        if !dests.detect { |dest| !File.exists?(dest['filename']) } 
            return true
        end

        convert_options = ''
        dest_dir = make_dest_filename(File.dirname(dests[0]['filename']))

        if entry2type(orig) == 'image'
            if felem
                if whitebalance = rexml_thread_protect { felem.attributes["#{attributes_prefix}white-balance"] }
                    neworig = "#{dest_dir}/#{File.basename(orig)}-whitebalance#{whitebalance}.jpg"
                    cmd = "booh-fix-whitebalance '#{orig}' '#{neworig}' #{whitebalance}"
                    sys(cmd)
                    if File.exists?(neworig)
                        orig = neworig
                    end
                end
                if gammacorrect = rexml_thread_protect { felem.attributes["#{attributes_prefix}gamma-correction"] }
                    neworig = "#{dest_dir}/#{File.basename(orig)}-gammacorrect#{gammacorrect}.jpg"
                    cmd = "booh-gamma-correction '#{orig}' '#{neworig}' #{gammacorrect}"
                    sys(cmd)
                    if File.exists?(neworig)
                        orig = neworig
                    end
                end
                rotate = rexml_thread_protect { felem.attributes["#{attributes_prefix}rotate"] }
                if !rotate
                    rexml_thread_protect { felem.add_attribute("#{attributes_prefix}rotate", rotate = guess_rotate(orig).to_s) }
                end
                convert_options += "-rotate #{rotate} "
                if rexml_thread_protect { felem.attributes["#{attributes_prefix}enhance"] }
                    convert_options += ($config['convert-enhance'] || $convert_enhance) + " "
                end
            end
            for dest in dests
                if !File.exists?(dest['filename'])
                    cmd = nil
                    cmd ||= "#{$convert} #{convert_options}-size #{dest['size']} -resize '#{dest['size']}>' '#{orig}' '#{dest['filename']}'"
                    if allow_background
                        psys(cmd)
                    else
                        sys(cmd)
                    end
                end
            end
            if neworig
                if allow_background
                    waitjobs
                end
                begin
                    File.delete(neworig)
                rescue Errno::ENOENT
                    #- can happen on race conditions for generating multiple times a thumbnail for a given image. for the moment,
                    #- silently ignore, it is not a so big deal.
                end
            end
            return true

        elsif entry2type(orig) == 'video'
            if felem
                #- seektime is an attribute that allows to specify where the frame to use for the thumbnail must be taken
                seektime = rexml_thread_protect { felem.attributes["#{attributes_prefix}seektime"] }
                if ! seektime
                    rexml_thread_protect { felem.add_attribute("#{attributes_prefix}seektime", seektime = "0") }
                end
                seektime = seektime.to_f
                if rotate = rexml_thread_protect { felem.attributes["#{attributes_prefix}rotate"] }
                    convert_options += "-rotate #{rotate} "
                end
                if rexml_thread_protect { felem.attributes["#{attributes_prefix}enhance"] }
                    convert_options += ($config['convert-enhance'] || $convert_enhance) + " "
                end
            end
            for dest in dests
                if ! File.exists?(dest['filename'])
                    tmpdir = gen_video_thumbnail(orig, felem && rexml_thread_protect { felem.attributes["#{attributes_prefix}color-swap"] }, seektime)
                    if tmpdir.nil?
                        return false
                    end
                    tmpfile = "#{tmpdir}/00000001.jpg"
                    alltmpfiles = [ tmpfile ]
                    if felem && whitebalance = rexml_thread_protect { felem.attributes["#{attributes_prefix}white-balance"] }
                        if whitebalance.to_f != 0
                            neworig = "#{tmpdir}/whitebalance#{whitebalance}.jpg"
                            cmd = "booh-fix-whitebalance '#{tmpfile}' '#{neworig}' #{whitebalance}"
                            sys(cmd)
                            if File.exists?(neworig)
                                tmpfile = neworig
                                alltmpfiles << neworig
                            end
                        end
                    end
                    if felem && gammacorrect = rexml_thread_protect { felem.attributes["#{attributes_prefix}gamma-correction"] }
                        if gammacorrect.to_f != 0
                            neworig = "#{tmpdir}/gammacorrect#{gammacorrect}.jpg"
                            cmd = "booh-gamma-correction '#{tmpfile}' '#{neworig}' #{gammacorrect}"
                            sys(cmd)
                            if File.exists?(neworig)
                                tmpfile = neworig
                                alltmpfiles << neworig
                            end
                        end
                    end
                    sys("#{$convert} #{convert_options}-size #{dest['size']} -resize #{dest['size']} '#{tmpfile}' '#{dest['filename']}'")
                    alltmpfiles.each { |file| File.delete(file) }
                    Dir.rmdir(tmpdir)
                end
            end
            return true
        end
    end

    def invornil(obj, methodname)
        if obj == nil
            return nil
        else
            return obj.method(methodname).call
        end
    end

    def find_subalbum_info_type(xmldir)
        #- first look for subdirs info; if not, means there is no subdir
        if xmldir.attributes['subdirs-caption']
            return 'subdirs'
        else
            return 'thumbnails'
        end
    end

    def find_subalbum_caption_info(xmldir)
        type = find_subalbum_info_type(xmldir)
        return [ from_utf8(xmldir.attributes["#{type}-captionfile"]), xmldir.attributes["#{type}-caption"] ]
    end

    def file_size(path)
        begin
            return File.size(path)
        rescue
            return -1
        end
    end

    def max(a, b)
        a > b ? a : b
    end

    def clamp(n, a, b)
        n < a ? a : n > b ? b : n
    end

    def pano_amount(elem)
        if pano_amount = elem.attributes['pano-amount']
            if $N_per_row
                return clamp(pano_amount.to_f, 1, $N_per_row.to_i)
            else
                return clamp(pano_amount.to_f, 1, $default_N.to_i)
            end
        else
            return nil
        end
    end

    def substInFile(name)
        newcontent = IO.readlines(name).collect { |l| yield l }
        ios = File.open(name, "w")
        ios.write(newcontent)
        ios.close
    end

    $xmlaccesslock = Monitor.new

    def rexml_thread_protect(&proc)
        $xmlaccesslock.synchronize {
            proc.call
        }
    end

    def check_multi_binaries(input)
        #- e.g. check at least one binary from '/usr/bin/gimp-remote %f || /usr/bin/gimp %f' is available
        for attempts in input.split('||')
            binary = attempts.split.first
            if binary && File.executable?(binary)
                return nil
            end
        end
        #- return last tried binary for error message
        return binary
    end

    def check_browser
        if last_failed_binary = check_multi_binaries($config['browser'])
            show_popup($main_window, utf8(_("The configured browser seems to be unavailable.
You should fix this in Edit/Preferences so that you can open URLs.

Problem was: '%s' is not an executable file.") % last_failed_binary), { :pos_centered => true, :not_transient => true })
            return false
        else
            return true
        end
    end

    def open_url(url)
        if check_browser
            cmd = $config['browser'].gsub('%f', "'#{url}'") + ' &'
            msg 2, cmd
            system(cmd)
        end
    end

    def get_license
        return <<"EOF"
		    GNU GENERAL PUBLIC LICENSE
		       Version 2, June 1991

 Copyright (C) 1989, 1991 Free Software Foundation, Inc.
                          675 Mass Ave, Cambridge, MA 02139, USA
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

			    Preamble

  The licenses for most software are designed to take away your
freedom to share and change it.  By contrast, the GNU General Public
License is intended to guarantee your freedom to share and change free
software--to make sure the software is free for all its users.  This
General Public License applies to most of the Free Software
Foundation's software and to any other program whose authors commit to
using it.  (Some other Free Software Foundation software is covered by
the GNU Library General Public License instead.)  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
this service if you wish), that you receive source code or can get it
if you want it, that you can change the software or use pieces of it
in new free programs; and that you know you can do these things.

  To protect your rights, we need to make restrictions that forbid
anyone to deny you these rights or to ask you to surrender the rights.
These restrictions translate to certain responsibilities for you if you
distribute copies of the software, or if you modify it.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must give the recipients all the rights that
you have.  You must make sure that they, too, receive or can get the
source code.  And you must show them these terms so they know their
rights.

  We protect your rights with two steps: (1) copyright the software, and
(2) offer you this license which gives you legal permission to copy,
distribute and/or modify the software.

  Also, for each author's protection and ours, we want to make certain
that everyone understands that there is no warranty for this free
software.  If the software is modified by someone else and passed on, we
want its recipients to know that what they have is not the original, so
that any problems introduced by others will not reflect on the original
authors' reputations.

  Finally, any free program is threatened constantly by software
patents.  We wish to avoid the danger that redistributors of a free
program will individually obtain patent licenses, in effect making the
program proprietary.  To prevent this, we have made it clear that any
patent must be licensed for everyone's free use or not licensed at all.

  The precise terms and conditions for copying, distribution and
modification follow.


		    GNU GENERAL PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. This License applies to any program or other work which contains
a notice placed by the copyright holder saying it may be distributed
under the terms of this General Public License.  The "Program", below,
refers to any such program or work, and a "work based on the Program"
means either the Program or any derivative work under copyright law:
that is to say, a work containing the Program or a portion of it,
either verbatim or with modifications and/or translated into another
language.  (Hereinafter, translation is included without limitation in
the term "modification".)  Each licensee is addressed as "you".

Activities other than copying, distribution and modification are not
covered by this License; they are outside its scope.  The act of
running the Program is not restricted, and the output from the Program
is covered only if its contents constitute a work based on the
Program (independent of having been made by running the Program).
Whether that is true depends on what the Program does.

  1. You may copy and distribute verbatim copies of the Program's
source code as you receive it, in any medium, provided that you
conspicuously and appropriately publish on each copy an appropriate
copyright notice and disclaimer of warranty; keep intact all the
notices that refer to this License and to the absence of any warranty;
and give any other recipients of the Program a copy of this License
along with the Program.

You may charge a fee for the physical act of transferring a copy, and
you may at your option offer warranty protection in exchange for a fee.

  2. You may modify your copy or copies of the Program or any portion
of it, thus forming a work based on the Program, and copy and
distribute such modifications or work under the terms of Section 1
above, provided that you also meet all of these conditions:

    a) You must cause the modified files to carry prominent notices
    stating that you changed the files and the date of any change.

    b) You must cause any work that you distribute or publish, that in
    whole or in part contains or is derived from the Program or any
    part thereof, to be licensed as a whole at no charge to all third
    parties under the terms of this License.

    c) If the modified program normally reads commands interactively
    when run, you must cause it, when started running for such
    interactive use in the most ordinary way, to print or display an
    announcement including an appropriate copyright notice and a
    notice that there is no warranty (or else, saying that you provide
    a warranty) and that users may redistribute the program under
    these conditions, and telling the user how to view a copy of this
    License.  (Exception: if the Program itself is interactive but
    does not normally print such an announcement, your work based on
    the Program is not required to print an announcement.)


These requirements apply to the modified work as a whole.  If
identifiable sections of that work are not derived from the Program,
and can be reasonably considered independent and separate works in
themselves, then this License, and its terms, do not apply to those
sections when you distribute them as separate works.  But when you
distribute the same sections as part of a whole which is a work based
on the Program, the distribution of the whole must be on the terms of
this License, whose permissions for other licensees extend to the
entire whole, and thus to each and every part regardless of who wrote it.

Thus, it is not the intent of this section to claim rights or contest
your rights to work written entirely by you; rather, the intent is to
exercise the right to control the distribution of derivative or
collective works based on the Program.

In addition, mere aggregation of another work not based on the Program
with the Program (or with a work based on the Program) on a volume of
a storage or distribution medium does not bring the other work under
the scope of this License.

  3. You may copy and distribute the Program (or a work based on it,
under Section 2) in object code or executable form under the terms of
Sections 1 and 2 above provided that you also do one of the following:

    a) Accompany it with the complete corresponding machine-readable
    source code, which must be distributed under the terms of Sections
    1 and 2 above on a medium customarily used for software interchange; or,

    b) Accompany it with a written offer, valid for at least three
    years, to give any third party, for a charge no more than your
    cost of physically performing source distribution, a complete
    machine-readable copy of the corresponding source code, to be
    distributed under the terms of Sections 1 and 2 above on a medium
    customarily used for software interchange; or,

    c) Accompany it with the information you received as to the offer
    to distribute corresponding source code.  (This alternative is
    allowed only for noncommercial distribution and only if you
    received the program in object code or executable form with such
    an offer, in accord with Subsection b above.)

The source code for a work means the preferred form of the work for
making modifications to it.  For an executable work, complete source
code means all the source code for all modules it contains, plus any
associated interface definition files, plus the scripts used to
control compilation and installation of the executable.  However, as a
special exception, the source code distributed need not include
anything that is normally distributed (in either source or binary
form) with the major components (compiler, kernel, and so on) of the
operating system on which the executable runs, unless that component
itself accompanies the executable.

If distribution of executable or object code is made by offering
access to copy from a designated place, then offering equivalent
access to copy the source code from the same place counts as
distribution of the source code, even though third parties are not
compelled to copy the source along with the object code.


  4. You may not copy, modify, sublicense, or distribute the Program
except as expressly provided under this License.  Any attempt
otherwise to copy, modify, sublicense or distribute the Program is
void, and will automatically terminate your rights under this License.
However, parties who have received copies, or rights, from you under
this License will not have their licenses terminated so long as such
parties remain in full compliance.

  5. You are not required to accept this License, since you have not
signed it.  However, nothing else grants you permission to modify or
distribute the Program or its derivative works.  These actions are
prohibited by law if you do not accept this License.  Therefore, by
modifying or distributing the Program (or any work based on the
Program), you indicate your acceptance of this License to do so, and
all its terms and conditions for copying, distributing or modifying
the Program or works based on it.

  6. Each time you redistribute the Program (or any work based on the
Program), the recipient automatically receives a license from the
original licensor to copy, distribute or modify the Program subject to
these terms and conditions.  You may not impose any further
restrictions on the recipients' exercise of the rights granted herein.
You are not responsible for enforcing compliance by third parties to
this License.

  7. If, as a consequence of a court judgment or allegation of patent
infringement or for any other reason (not limited to patent issues),
conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot
distribute so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you
may not distribute the Program at all.  For example, if a patent
license would not permit royalty-free redistribution of the Program by
all those who receive copies directly or indirectly through you, then
the only way you could satisfy both it and this License would be to
refrain entirely from distribution of the Program.

If any portion of this section is held invalid or unenforceable under
any particular circumstance, the balance of the section is intended to
apply and the section as a whole is intended to apply in other
circumstances.

It is not the purpose of this section to induce you to infringe any
patents or other property right claims or to contest validity of any
such claims; this section has the sole purpose of protecting the
integrity of the free software distribution system, which is
implemented by public license practices.  Many people have made
generous contributions to the wide range of software distributed
through that system in reliance on consistent application of that
system; it is up to the author/donor to decide if he or she is willing
to distribute software through any other system and a licensee cannot
impose that choice.

This section is intended to make thoroughly clear what is believed to
be a consequence of the rest of this License.


  8. If the distribution and/or use of the Program is restricted in
certain countries either by patents or by copyrighted interfaces, the
original copyright holder who places the Program under this License
may add an explicit geographical distribution limitation excluding
those countries, so that distribution is permitted only in or among
countries not thus excluded.  In such case, this License incorporates
the limitation as if written in the body of this License.

  9. The Free Software Foundation may publish revised and/or new versions
of the General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

Each version is given a distinguishing version number.  If the Program
specifies a version number of this License which applies to it and "any
later version", you have the option of following the terms and conditions
either of that version or of any later version published by the Free
Software Foundation.  If the Program does not specify a version number of
this License, you may choose any version ever published by the Free Software
Foundation.

  10. If you wish to incorporate parts of the Program into other free
programs whose distribution conditions are different, write to the author
to ask for permission.  For software which is copyrighted by the Free
Software Foundation, write to the Free Software Foundation; we sometimes
make exceptions for this.  Our decision will be guided by the two goals
of preserving the free status of all derivatives of our free software and
of promoting the sharing and reuse of software generally.

			    NO WARRANTY

  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.
EOF
    end

    def call_about
        Gtk::AboutDialog.set_url_hook { |dialog, url| open_url(url) }
        Gtk::AboutDialog.show($main_window, { :name => 'booh',
                                              :version => $VERSION,
                                              :copyright => 'Copyright (c) 2005-2010 Guillaume Cottenceau',
                                              :license => get_license,
                                              :website => 'http://booh.org/',
                                              :authors => [ 'Guillaume Cottenceau' ],
                                              :artists => [ 'Ayo73' ],
                                              :comments => utf8(_("''The Web-Album of choice for discriminating Linux users''")),
                                              :translator_credits => utf8(_('Esperanto: Stephane Fillod
Japanese: Masao Mutoh
German: Roland Eckert
French: Guillaume Cottenceau')),
                                              :logo => Gdk::Pixbuf.new("#{$FPATH}/images/logo.png") })
    end

    def smartsort(entries, sort_criterions)
        #- sort "entries" according to "sort_criterions" but find a good fallback for all entries without a
        #- criterion value (still next to the item they were next to)
        sorted_entries = sort_criterions.keys.sort { |a,b| sort_criterions[a] <=> sort_criterions[b] }
        for i in 0 .. entries.size - 1
            if ! sorted_entries.include?(entries[i])
                j = i - 1
                while j > 0 && ! sorted_entries.include?(entries[j])
                    j -= 1
                end
                sorted_entries[(sorted_entries.index(entries[j]) || -1 ) + 1, 0] = entries[i]
            end
        end
        return sorted_entries
    end

    def defer_translation(msg)
        return "@@#{msg}@@"
    end

    def create_window
        w = Gtk::Window.new
        w.icon_list = [ Gdk::Pixbuf.new("#{$FPATH}/images/booh-16x16.png"),
                        Gdk::Pixbuf.new("#{$FPATH}/images/booh-32x32.png"),
                        Gdk::Pixbuf.new("#{$FPATH}/images/booh-48x48.png") ]
        return w
    end

end

class Object
    def to_b
        if !self || self.to_s == 'false'
            return false
        else
            return true
        end
    end
end

class File
    def File.reduce_path(path)
        return path.gsub(/\w+\/\.\.\//, '')
    end
end

module Enumerable
    def collect_with_index
        out = []
        each_with_index { |e,i|
            out << yield(e,i)
        }
        return out
    end
end

class Array
    def sum
        retval = 0
        each { |v| retval += v.to_i }
        return retval
    end
end

class REXML::Element
    def previous_element_byname(name)
        n = self
        while n = n.previous_element
            if n.name == name
                return n
            end
        end
        return nil
    end

    def previous_element_byname_notattr(name, attr)
        n = self
        while n = n.previous_element
            if n.name == name && !n.attributes[attr]
                return n
            end
        end
        return nil
    end

    def next_element_byname(name)
        n = self
        while n = n.next_element
            if n.name == name
                return n
            end
        end
        return nil
    end

    def next_element_byname_notattr(name, attr)
        n = self
        while n = n.next_element
            if n.name == name && !n.attributes[attr]
                return n
            end
        end
        return nil
    end

    def child_byname_notattr(name, attr)
        elements.each(name) { |element|
            if !element.attributes[attr]
                return element
            end
        }
        return nil
    end
end

        
