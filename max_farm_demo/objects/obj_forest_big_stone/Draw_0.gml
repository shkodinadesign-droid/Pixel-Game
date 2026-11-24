// ===== ЛЕС: БОЛЬШОЙ КАМЕНЬ (DRAW) =====
draw_self();

// Знак прежнего владельца Меча героя: загорается, когда лягушонок говорит «Ищи такую отметку», и светится дальше.
var _show = global.frog_talk_done;
if (!_show && instance_exists(obj_ui_dialog_seq)) {
    with (obj_ui_dialog_seq) if (on_finish == "frog_talk" && variable_instance_exists(id, "sign_page") && page >= sign_page) _show = true;
}
if (_show) forest_draw_sign(x + 38, y + 26, 0.65 + 0.35 * sin(current_time / 300));
