/*
 *                         *  BOOH  *
 *
 * A.k.a `Best web-album Of the world, Or your money back, Humerus'.
 *
 * The acronyn sucks, however this is a tribute to Dragon Ball by
 * Akira Toriyama, where the last enemy beaten by heroes of Dragon
 * Ball is named "Boo". But there was already a free software project
 * called Boo, so this one will be it "Booh". Or whatever.
 *
 *
 * Copyright (c) 2005-2010 Guillaume Cottenceau
 *
 * This software may be freely redistributed under the terms of the GNU
 * public license version 2.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 */

#include <math.h>

#include <exiv2/image.hpp>
#include <exiv2/exif.hpp>

#define GDK_PIXBUF_ENABLE_BACKEND
#include <gtk/gtk.h>
#include "rbgobject.h"

#define _SELF(s) GDK_PIXBUF(RVAL2GOBJ(s)) 

static VALUE whitebalance(VALUE self, VALUE level) {
        double red_filter[256], blue_filter[256];
        int i, x, y;
        guchar* pixels = gdk_pixbuf_get_pixels(_SELF(self));
        int rowstride = gdk_pixbuf_get_rowstride(_SELF(self));

        double factor = 1 + fabs(NUM2DBL(level))/100;
        if (NUM2DBL(level) < 0) {
                factor = 1/factor;
        }

        for (i = 0; i < 256; i++) {
                red_filter[i]  = pow(((double)i)/255, 1/factor) * 255;
                blue_filter[i] = pow(((double)i)/255, factor) * 255;
        }
    
        for (y = 0; y < gdk_pixbuf_get_height(_SELF(self)); y++) {
                guchar* pixline = &(pixels[rowstride*y]);
                for (x = 0; x < gdk_pixbuf_get_width(_SELF(self)); x++) {
                        pixline[x*3]   = (guchar) red_filter[pixline[x*3]];
                        pixline[x*3+2] = (guchar) blue_filter[pixline[x*3+2]];
                }
        }

        return self;
}

static VALUE gammacorrect(VALUE self, VALUE level) {
        double filter[256];
        int i, x, y;
        guchar* pixels = gdk_pixbuf_get_pixels(_SELF(self));
        int rowstride = gdk_pixbuf_get_rowstride(_SELF(self));

        double factor = 1 + fabs(NUM2DBL(level))/100;
        if (NUM2DBL(level) > 0) {
                factor = 1/factor;
        }

        for (i = 0; i < 256; i++) {
                filter[i] = pow(((double)i)/255, factor) * 255;
        }
    
        for (y = 0; y < gdk_pixbuf_get_height(_SELF(self)); y++) {
                guchar* pixline = &(pixels[rowstride*y]);
                for (x = 0; x < gdk_pixbuf_get_width(_SELF(self)); x++) {
                        pixline[x*3]   = (guchar) filter[pixline[x*3]];
                        pixline[x*3+1] = (guchar) filter[pixline[x*3+1]];
                        pixline[x*3+2] = (guchar) filter[pixline[x*3+2]];
                }
        }

        return self;
}

static VALUE exif_orientation(VALUE module, VALUE filename) {
        try {
                Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(StringValuePtr(filename));
                image->readMetadata();
                Exiv2::ExifData &exifData = image->exifData();
                if (exifData.empty()) {
                        return Qnil;
                }
                Exiv2::ExifData::const_iterator i = exifData.findKey(Exiv2::ExifKey("Exif.Image.Orientation"));
                if (i != exifData.end()) {
                        return INT2NUM(i->value().toLong());
                }
                return Qnil;
        } catch (Exiv2::AnyError& e) {
                // actually, I don't care about exceptions because I will try non JPG images
                // std::cerr << "Caught Exiv2 exception: " << e << "\n";
                return Qnil;
        }
}

static VALUE exif_set_orientation(VALUE module, VALUE filename, VALUE val) {
        try {
                Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(StringValuePtr(filename));
                image->readMetadata();
                Exiv2::ExifData &exifData = image->exifData();
                exifData["Exif.Image.Orientation"] = uint16_t(NUM2INT(val));
                image->writeMetadata();
        } catch (Exiv2::AnyError& e) {
                // actually, I don't care about exceptions because I will try non JPG images
                // std::cout << "Caught Exiv2 exception: " << e << "\n";
        }
        return Qnil;
}

static VALUE exif_datetimeoriginal(VALUE module, VALUE filename) {
        try {
                Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(StringValuePtr(filename));
                image->readMetadata();
                Exiv2::ExifData &exifData = image->exifData();
                if (exifData.empty()) {
                        return Qnil;
                }
                Exiv2::ExifData::const_iterator i = exifData.findKey(Exiv2::ExifKey("Exif.Photo.DateTimeOriginal"));
                if (i != exifData.end()) {
                        return rb_str_new2(i->value().toString().c_str());
                }
                return Qnil;
        } catch (Exiv2::AnyError& e) {
                // actually, I don't care about exceptions because I will try non JPG images
                // std::cout << "Caught Exiv2 exception: " << e << "\n";
                return Qnil;
        }
}

// internalize drawing "video" borders, it is too slow in ruby (0.12 secs on my p4 2.8 GHz, whereas it's barely measurable with this implementation)
static VALUE draw_borders(VALUE self, VALUE pixbuf, VALUE x1, VALUE x2, VALUE ystart, VALUE yend) {
        GdkDrawable* drawable = GDK_DRAWABLE(RVAL2GOBJ(self));
        int y = NUM2INT(ystart);
        int yend_ = NUM2INT(yend);
        GdkPixbuf* pb = GDK_PIXBUF(RVAL2GOBJ(pixbuf));
        int height = gdk_pixbuf_get_height(pb);
        while (y < yend_) {
                int render_height = MIN(height, yend_ - y);
                gdk_draw_pixbuf(drawable, NULL, pb, 0, 0, NUM2INT(x1), y, -1, render_height, GDK_RGB_DITHER_NONE, -1, -1);
                gdk_draw_pixbuf(drawable, NULL, pb, 0, 0, NUM2INT(x2), y, -1, render_height, GDK_RGB_DITHER_NONE, -1, -1);
                y += height;
        }
        return self;
}

// internalize memory leak fix for GdkPixbuf.rotate
// (bugged as of rg2 0.16.0)
static VALUE rotate_noleak(VALUE self, VALUE angle) {
        VALUE ret;
        GdkPixbuf* dest = gdk_pixbuf_rotate_simple(_SELF(self), (GdkPixbufRotation) RVAL2GENUM(angle, GDK_TYPE_PIXBUF_ROTATION));
        if (dest == NULL)
                return Qnil;
        ret = GOBJ2RVAL(dest);
        g_object_unref(dest);
        return ret;
}

// internalize allowing to pass Qnil to RVAL2BOXED to have NULL passed to Gtk
// (bugged as of rg2 0.16.0)
static VALUE modify_bg(VALUE self, VALUE state, VALUE color) {
        gtk_widget_modify_bg(GTK_WIDGET(RVAL2GOBJ(self)), (GtkStateType) RVAL2GENUM(state, GTK_TYPE_STATE_TYPE),
                             NIL_P(color) ? NULL : (GdkColor*) RVAL2BOXED(color, GDK_TYPE_COLOR));
        return self;
}

// internalize pixbuf loading for 30% more speedup
static VALUE load_not_freezing_ui(VALUE self, VALUE path, VALUE offset) {
        char buf[65536];
        size_t amount;
        size_t off = NUM2INT(offset);
        GdkPixbufLoader* loader = GDK_PIXBUF_LOADER(RVAL2GOBJ(self));
        GError* error = NULL;
        FILE* f = fopen(RVAL2CSTR(path), "r");
        if (!f) {
                gdk_pixbuf_loader_close(loader, NULL);
                rb_raise(rb_eRuntimeError, "Unable to open file %s for reading", RVAL2CSTR(path));
        }
        if (off > 0) {
                if (fseek(f, off, SEEK_SET) != 0) {
                        rb_raise(rb_eRuntimeError, "Unable to seek file %s", RVAL2CSTR(path));
                        fclose(f);
                        return 0;
                }
        }
        while ((amount = fread(buf, 1, 65536, f)) > 0) {
                if (!gdk_pixbuf_loader_write(loader, (const guchar*) buf, amount, &error)) {
                        gdk_pixbuf_loader_close(loader, NULL);
                        fclose(f);
                        RAISE_GERROR(error);
                }
                off += amount;
                if (gtk_events_pending() && !feof(f)) {
                        // interrupted, case when the user clicked/keyboarded too quickly for this image to
                        // display; we temporarily interrupt this loading
                        fclose(f);
                        return INT2NUM(off);
                }
        }
        gdk_pixbuf_loader_close(loader, NULL);
        fclose(f);
        return INT2NUM(0);
}

extern "C" {
void 
Init_libadds()
{
    RGObjClassInfo* cinfo = (RGObjClassInfo*)rbgobj_lookup_class_by_gtype(GDK_TYPE_PIXBUF, Qnil);
    rb_define_method(cinfo->klass, "whitebalance!", (VALUE (*)(...)) whitebalance, 1); 
    rb_define_method(cinfo->klass, "gammacorrect!", (VALUE (*)(...)) gammacorrect, 1); 
    rb_define_method(cinfo->klass, "rotate", (VALUE (*)(...)) rotate_noleak, 1); 

    cinfo = (RGObjClassInfo*)rbgobj_lookup_class_by_gtype(GDK_TYPE_DRAWABLE, Qnil);
    rb_define_method(cinfo->klass, "draw_borders", (VALUE (*)(...)) draw_borders, 5);

    cinfo = (RGObjClassInfo*)rbgobj_lookup_class_by_gtype(GTK_TYPE_WIDGET, Qnil);
    rb_define_method(cinfo->klass, "modify_bg", (VALUE (*)(...)) modify_bg, 2);

    cinfo = (RGObjClassInfo*)rbgobj_lookup_class_by_gtype(GDK_TYPE_PIXBUF_LOADER, Qnil);
    rb_define_method(cinfo->klass, "load_not_freezing_ui", (VALUE (*)(...)) load_not_freezing_ui, 2);

    VALUE exif = rb_define_module("Exif");
    rb_define_module_function(exif, "orientation", (VALUE (*)(...)) exif_orientation, 1);
    rb_define_module_function(exif, "set_orientation", (VALUE (*)(...)) exif_set_orientation, 2);
    rb_define_module_function(exif, "datetimeoriginal", (VALUE (*)(...)) exif_datetimeoriginal, 1);
}
}
