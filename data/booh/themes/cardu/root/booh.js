var images_ary = new Array();
var images_loaded = new Array();
var current = 0;
var slideshow = 0;
var slideshow_pause = null;
var slideshow_timer = null;

for (i = 0; i < images.length; i++) { 
    /* this array will contain 0 if image not yet loaded, 1 when loading,
     * 2 when complete */
    images_loaded[i] = 0;
}

function dbg(t) {
    document.getElementById('dbg_text').innerHTML += t + "<br/>";
}

/* load image, return 1 if image is finished loading */
function load(i) {
    if (images_loaded[i] == 0) {
        images_ary[i] = new Image();
        images_ary[i].src = images[i];
        images_loaded[i] = 1;
    }
    if (images_loaded[i] == 1) {
        if (images_ary[i].complete) {
            images_loaded[i] = 2;
        } else {
            return 0;
        }
    }
    return 1;
}

function getparam(key) {
    all_params = location.href.split("#")
    if (all_params.length > 1) {
        params = all_params[1].split("&");
        for (i = 0; i < params.length; i++) {
            keyvalue = params[i].split("=");
            if (keyvalue[0] == key) {
                return keyvalue[1];
            }
        }
    }
    return null;
}

function loadcurrent(img) {
    for (i = 0; i < images.length; i++) {
        if (images[i] == img) {
            current = i;
            display_current();
            return;
        }
    }
    current = 0;
    display_current();
}

function browser_href() {
    all = location.href.split("/");
    return all[all.length - 1];
}

/* check URL for changes; allows the URL to reflect currently showed image */
var currentURL = '';
function checkURL() {
    if (currentURL == 'ignore1') {
        // do nothing
    } else if (currentURL == 'ignore2') {
        currentURL = browser_href();
    } else {
        href = browser_href();
        if (href != currentURL) {
            currentURL = href;
            img = getparam('current');
            loadcurrent(img);
        }
    }
    setTimeout("checkURL()", 50);
}

function preload() { 

    /* favor current image, if user clicked on `last' or something */
    load(current);

    /* don't blindly preload all images at the beginning,
     * but rather load them one by one, in order to get
     * next ones faster, beginning with next to current
     */
    if (current + 1 < images.length && load(current + 1) == 0) {
        setTimeout("preload()", 50);
        return;
    }
    if (current - 1 >= 0 && load(current - 1) == 0) {
        setTimeout("preload()", 50);
        return;
    }

    for (i = current + 2; i < images.length && i <= current + 5; i++) { 
        if (load(i) == 0) {
            setTimeout("preload()", 50);
            return;
        }
    }
    for (i = current - 2; i >= current - 3; i--) { 
        if (i >= 0) {
            if (load(i) == 0) {
                setTimeout("preload()", 50);
                return;
            }
        }
    }

    setTimeout("preload()", 50);
}

function add_cookie(val) {
    var expires = new Date(new Date().getTime() + (30 * 86400000));  // 30 days
    document.cookie = val
                      + '; expires=' + expires.toGMTString()
                      + '; path=/';
}

function get_cookie(key) {
    if (document.cookie) {
        var index = document.cookie.indexOf(key);
        if (index != -1) {
            var oleft = (document.cookie.indexOf('=', index) + 1);
            var oright = document.cookie.indexOf(';', index);
            if (oright == -1) {
                oright = document.cookie.length;
            }
            return document.cookie.substring(oleft, oright);
        }
    }
    return null;
}

function init() {

    preferred_pause = get_cookie('booh-slideshow-pause-' + dbltilda_theme);
    if (preferred_pause != null) {
        document.getElementById('secs').value = preferred_pause;
    }

    if (getparam('run_slideshow')) {
        toggle_slideshow();
    }

    checkURL();

    preload();

    if (images.length == 1) {
        document.getElementById("b_slideshow").disabled = true;
        document.getElementById("b_slideshow").setAttribute("class", "disabled");
    }

    if (navigator.userAgent.indexOf('Opera') == -1) {
        document.onkeydown = keyDownEvent;
    }
}

function change_basename(input, newend) {
    position = input.lastIndexOf('/');
    if (position == -1) {
        return newend;
    } else {
        return input.substring(0, position + 1).concat(newend);
    }
}

function update_sensibilities() {
    var img_first = document.getElementById("img_first");
    var img_previous = document.getElementById("img_previous");
    if (current == 0) {
        img_first.src = change_basename(img_first.src, 'first_dark.gif');
        img_previous.src = change_basename(img_previous.src, 'previous_dark.gif');
        img_first.style['cursor'] = 'default';
        img_previous.style['cursor'] = 'default';
    } else {
        img_first.src = change_basename(img_first.src, 'first_light.gif');
        img_previous.src = change_basename(img_previous.src, 'previous_light.gif');
        img_first.style['cursor'] = 'pointer';  // to work on IE and FF, but warns on FF :/
        img_first.style['cursor'] = 'hand';
        img_previous.style['cursor'] = 'pointer';
        img_previous.style['cursor'] = 'hand';
    }

    var img_next = document.getElementById("img_next");
    var img_last = document.getElementById("img_last");
    if (current == images.length - 1) {
        img_next.src = change_basename(img_next.src, 'next_dark.gif');
        img_last.src = change_basename(img_last.src, 'last_dark.gif');
        img_next.style['cursor'] = 'default';
        img_last.style['cursor'] = 'default';
    } else {
        img_next.src = change_basename(img_next.src, 'next_light.gif');
        img_last.src = change_basename(img_last.src, 'last_light.gif');
        img_next.style['cursor'] = 'pointer';
        img_next.style['cursor'] = 'hand';
        img_last.style['cursor'] = 'pointer';
        img_last.style['cursor'] = 'hand';
    }
}

function set_cursor_(value, element) {

    if (!element || !element.style) {
        return;
    }

    element.style.cursor = value;

    children = element.childNodes;
    for (i = 0; i < children.length; i++) {
        set_cursor_(value, children.item[i]);
    }
}

function set_cursor(value) {
    set_cursor_(value, document.getElementById('body'));
}

function show_current_text() {
    /* don't show text if image not yet loaded because navigator
     * won't refresh it during load */
    if (images_loaded[current] == 2) {
        document.getElementById('image_counter').innerHTML = ( current + 1 ) + "/" + images.length;
        document.getElementById('main_text').innerHTML = captions[current];
        for (i = 0; i < other_sizes.length; i++) { 
            if (other_sizes[i] == "original") {
                var original = eval("elements_" + other_sizes[i] + "[current]");
                if (original != undefined) {
                    document.getElementById('link' + other_sizes[i]).href = original;
                    document.getElementById('link' + other_sizes[i]).style.display = '';
                } else {
                    document.getElementById('link' + other_sizes[i]).style.display = 'none';
                }
            } else {
                document.getElementById('link' + other_sizes[i]).href = 'image-' + other_sizes[i] + dbltilda_htmlsuffix + '#current=' + eval("elements_" + other_sizes[i] + "[current]");
            }
        }
        document.getElementById('thumbnails').href = 'thumbnails-' + dbltilda_current_size + '-' + thumbnailspages[current] + dbltilda_htmlsuffix + '#' + images[current];
        set_cursor("default");
    } else {
        setTimeout("show_current_text()", 50);
        set_cursor("wait");
    }
}

function display_current() {
    var main_img = document.getElementById('main_img');
    if (types[current] == 'image') {
        main_img.innerHTML = '<div class="fullscreen_image"><img src="' + images[current] + '"/></div>';
    } else {
        main_img.innerHTML = '<a class="fullscreenvideolink" href="' + videos[current] + '" '
                           + '   style="display:block;width:' + videos_widths[current] + 'px;height:' + (videos_heights[current] + 24) + 'px" id="player">'
                           + '  <div class="fullscreen_video"><img src="' + images[current] + '"/></div>'
                           + '  <img src="' + dbltilda_pathtobase + 'play_video.png" style="position:relative;top:-' + (videos_heights[current] + 48)/2 + 'px;border:0;background-color:transparent"/>'
                           + '</a>';
        if (dbltilda_flowplayer_active == 'true') {
            flowplayer("player", dbltilda_pathtobase + "flowplayer-3.2.2.swf");
        }
    }
    oldhref = browser_href();
    newhref = 'image-' + dbltilda_current_size + dbltilda_htmlsuffix + '#current=' + images[current];
    if (oldhref != newhref) {
        currentURL = 'ignore1';
        location.href = newhref;
        currentURL = 'ignore2';
    }
    show_current_text();
    update_sensibilities();
}

function first() {
    if (slideshow == 1) {
        toggle_slideshow(true);
    }
    
    current = 0;
    display_current();
}

function next() {
    if (slideshow == 1) {
        toggle_slideshow(true);
    }

    if (current < images.length - 1) {
        current++;
        display_current();
    }
}

function next10() {
    if (slideshow == 1) {
        toggle_slideshow(true);
    }

    if (current < images.length - 11) {
        current += 10;
    } else {
        current = images.length - 1;
    }
    display_current();
}

function previous() {
    if (slideshow == 1) {
        toggle_slideshow(true);
    }

    if (current > 0) {
        current--;
        display_current();
    }
}

function previous10() {
    if (slideshow == 1) {
        toggle_slideshow(true);
    }

    if (current > 10) {
        current -= 10;
    } else {
        current = 0;
    }
    display_current();
}

function last() {
    if (slideshow == 1) {
        toggle_slideshow(true);
    }

    current = images.length - 1;
    display_current();
}

function toggle_video() {
    if (types[current] == 'video' && dbltilda_flowplayer_active == 'true') {
        var player = flowplayer('player');
        if (player.isLoaded()) {
            player.toggle();
        } else {
            player.play();
        }
    }
}

function keyDownEvent(key) {
    if (!key) {
        key = event;
        key.which = key.keyCode;
    }
    if (key.altKey || key.ctrlKey || key.shiftKey) {
        return;
    }
    switch (key.which) {
      case 32: // space
        toggle_video();
        break;
      case 36: // home
        first();
        break;
      case 35: // end
        last();
        break;
      case 37: // left
        previous();
        break;
      case 39: // right
        next();
        break;
      case 38: // up
        previous10();
        break;
      case 40: // down
        next10();
        break;
    }
}

function toggle_slideshow(now) {
    if (slideshow == 0) {
        slideshow_pause = document.getElementById('secs').value;
        add_cookie('booh-slideshow-pause-' + dbltilda_theme + '=' + slideshow_pause)
        document.getElementById("b_slideshow").value = dbltilda_stop_slideshow;
        slideshow = 1;
        if (current == images.length - 1) {
            current = -1;
        }
        if (now) {
            run_slideshow();
        } else {
            setTimeout("run_slideshow()", slideshow_pause * 1000);
        }
    } else {
        clearTimeout(slideshow_timer);
        document.getElementById("b_slideshow").value = dbltilda_run_slideshow;
        slideshow = 0;
    }
}

function run_slideshow() {
    if (slideshow == 0) {
        return;
    }

    if (images_loaded[current + 1] == 2) {
        current++;
        display_current();
        slideshow_timer = setTimeout("run_slideshow()", slideshow_pause * 1000);
    } else {
        slideshow_timer = setTimeout("run_slideshow()", 50);
    }

    if (current == images.length - 1) {
        toggle_slideshow(true);
    }
}

function set_preferred_size(val) {
    var expires = new Date(new Date().getTime() + (30 * 86400000));  // 30 days
    document.cookie = 'booh-preferred-size-' + dbltilda_theme + '='
                      + val
                      + '; expires=' + expires.toGMTString()
                      + '; path=/';
}

