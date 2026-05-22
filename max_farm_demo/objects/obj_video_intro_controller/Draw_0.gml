/// DRAW: draw video fullscreen (без белых полей)

var sw = video_get_width();
var sh = video_get_height();

if (sw > 0 && sh > 0) {

    var gw = display_get_width();
    var gh = display_get_height();

    // max = без белых полей (как кино)
    var scale = max(gw / sw, gh / sh);

    var dw = sw * scale;
    var dh = sh * scale;

    var dx = (gw - dw) * 0.5;
    var dy = (gh - dh) * 0.5;

    draw_video(dx, dy, dw, dh);
}
