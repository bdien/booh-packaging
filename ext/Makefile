
SHELL = /bin/sh

#### Start of system configuration section. ####

srcdir = .
topdir = /usr/lib/ruby/1.8/x86_64-linux
hdrdir = $(topdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
exec_prefix = $(DESTDIR)/usr
prefix = $(DESTDIR)/usr
docdir = $(datarootdir)/doc/$(PACKAGE)
mandir = $(DESTDIR)/usr/share/man
vendorarchdir = $(vendorlibdir)/$(sitearch)
sharedstatedir = $(DESTDIR)/usr/com
vendordir = $(DESTDIR)/usr/lib/ruby/vendor_ruby
pdfdir = $(docdir)
sysconfdir = $(DESTDIR)/etc
localstatedir = $(DESTDIR)/var
sitearchdir = $(sitelibdir)/$(sitearch)
datarootdir = $(prefix)/share
sitelibdir = $(sitedir)/$(ruby_version)
psdir = $(docdir)
dvidir = $(docdir)
libdir = $(DESTDIR)/usr/lib64
htmldir = $(docdir)
archdir = $(prefix)/lib/ruby/$(ruby_version)/$(arch)
includedir = $(DESTDIR)/usr/include
localedir = $(datarootdir)/locale
infodir = $(DESTDIR)/usr/share/info
bindir = $(DESTDIR)/usr/bin
libexecdir = $(DESTDIR)/usr/lib64
vendorlibdir = $(vendordir)/$(ruby_version)
sitedir = $(DESTDIR)/usr/lib/ruby/site_ruby
oldincludedir = $(DESTDIR)/usr/include
datadir = $(DESTDIR)/usr/share
sbindir = $(DESTDIR)/usr/sbin
rubylibdir = $(prefix)/lib/ruby/$(ruby_version)

CC = gcc
LIBRUBY = $(LIBRUBY_SO)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -l$(RUBY_SO_NAME)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static

RUBY_EXTCONF_H = 
CFLAGS   =  -fPIC -O2 -g -pipe -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fstack-protector --param=ssp-buffer-size=4  -fPIC $(cflags) -Wall -I/usr/include/gtk-2.0 -I/usr/include/pango-1.0 -I/usr/include/freetype2 -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/libpng15 -I/usr/include/cairo -I/usr/include/pixman-1 -I/usr/include/directfb -I/usr/include/atk-1.0 -I/usr/lib64/gtk-2.0/include -pthread -D_REENTRANT  
INCFLAGS = -I. -I. -I/usr/lib/ruby/1.8/x86_64-linux -I. -I/usr/lib/ruby/site_ruby/1.8/x86_64-linux  -I/usr/lib/ruby/vendor_ruby/1.8/x86_64-linux 
DEFS     = 
CPPFLAGS = -DHAVE_RB_DEFINE_ALLOC_FUNC -DHAVE_RB_BLOCK_PROC -DHAVE_OBJECT_ALLOCATE -DHAVE_NODE_ATTRASGN -DHAVE_GDK_PIXBUF_SET_OPTION -DHAVE_GDK_PIXBUF_GDK_PIXBUF_IO_H   
CXXFLAGS = $(CFLAGS) 
ldflags  = -L.  -Wl,--as-needed  -Wl,-z,relro -Wl,-O1 -Wl,--build-id -Wl,--enable-new-dtags -rdynamic -Wl,-export-dynamic -pthread -Wl,--export-dynamic 
dldflags = 
archflag = 
DLDFLAGS = $(ldflags) $(dldflags) $(archflag)
LDSHARED = $(CC) -shared
AR = ar
EXEEXT = 

RUBY_INSTALL_NAME = ruby
RUBY_SO_NAME = ruby
arch = x86_64-linux
sitearch = x86_64-linux
ruby_version = 1.8
ruby = /usr/bin/ruby
RUBY = $(ruby)
RM = rm -f
MAKEDIRS = mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp

#### End of system configuration section. ####

preload = 

libpath = . $(libdir)
LIBPATH =  -L. -L$(libdir)
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 

extout = 
extout_prefix = 
target_prefix = /booh
LOCAL_LIBS = 
LIBS = $(LIBRUBYARG_SHARED)  -lgtk-x11-2.0 -lpangoft2-1.0 -lfontconfig -lfreetype -lpango-1.0 -lgmodule-2.0 -lrt -lglib-2.0 -lpcre -lgobject-2.0 -lgio-2.0 -lgdk_pixbuf-2.0 -lpng15 -lcairo -lpixman-1 -ldirectfb -lpthread -ldirect -lfusion -lXrender -lX11 -lxcb -lXau -lXdmcp -latk-1.0 -lgdk-x11-2.0 -lpangocairo-1.0 -lexiv2 -lpthread -lrt -ldl -lcrypt -lm   -lc
SRCS = rbbooh.c
OBJS = rbbooh.o
TARGET = libadds
DLLIB = $(TARGET).so
EXTSTATIC = 
STATIC_LIB = 

BINDIR        = $(bindir)
RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR    = $(sitelibdir)$(target_prefix)
RUBYARCHDIR   = $(sitearchdir)$(target_prefix)

TARGET_SO     = $(DLLIB)
CLEANLIBS     = $(TARGET).so $(TARGET).il? $(TARGET).tds $(TARGET).map
CLEANOBJS     = *.o *.a *.s[ol] *.pdb *.exp *.bak

all:		$(DLLIB)
static:		$(STATIC_LIB)

clean:
		@-$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES)

distclean:	clean
		@-$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		@-$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)

realclean:	distclean
install: install-so install-rb

install-so: $(RUBYARCHDIR)
install-so: $(RUBYARCHDIR)/$(DLLIB)
$(RUBYARCHDIR)/$(DLLIB): $(DLLIB)
	$(INSTALL_PROG) $(DLLIB) $(RUBYARCHDIR)
install-rb: pre-install-rb install-rb-default
install-rb-default: pre-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
$(RUBYARCHDIR):
	$(MAKEDIRS) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .cxx .cpp .C .o

.cc.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cxx.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cpp.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.C.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.c.o:
	$(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) -c $<

$(DLLIB): $(OBJS) Makefile
	@-$(RM) $@
	$(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)



$(OBJS): ruby.h defines.h
