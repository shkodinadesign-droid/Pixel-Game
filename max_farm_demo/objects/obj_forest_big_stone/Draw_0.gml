// ===== ЛЕС: БОЛЬШОЙ КАМЕНЬ (DRAW) =====
draw_self();

// Знак на камне — появляется, когда Макс его замечает (последняя реплика разговора) и остаётся потом.
var _show = global.frog_talk_done;
if (!_show && instance_exists(obj_ui_dialog_seq)) {
    with (obj_ui_dialog_seq) if (on_finish == "frog_talk" && page >= 4) _show = true;
}
if (_show) {
    // Временная графика: светящаяся спираль-знак
    var _cx = x + 38, _cy = y + 26;
    var _a  = 0.65 + 0.35 * sin(current_time / 300);
    draw_set_alpha(_a);
    draw_set_color(make_color_rgb(150, 235, 220));
    draw_circle(_cx, _cy, 7, true);
    draw_circle(_cx, _cy, 3, true);
    draw_line(_cx - 10, _cy, _cx - 7, _cy);
    draw_line(_cx + 7, _cy, _cx + 10, _cy);
    draw_line(_cx, _cy - 10, _cx, _cy - 7);
    draw_point(_cx, _cy);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
