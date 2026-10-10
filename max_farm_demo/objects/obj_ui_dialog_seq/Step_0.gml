// ===== ДИАЛОГ ИЗ НЕСКОЛЬКИХ СТРАНИЦ (STEP) =====

if (closing) {
    if (owns_lock) global.control_locked = false;
    var _ev = on_finish;
    instance_destroy();
    if (_ev != "") forest_on_dialog_finished(_ev);
    exit;
}

if (array_length(pages) == 0) { closing = true; visible = false; exit; }
if (layout_page != page) seq_layout();

if (open_delay > 0) {
    open_delay--;
    _click_prev = mouse_check_button(mb_left);
    exit;
}

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

var click_now   = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev     = click_now;

var advance = (hover && click_press)
           || keyboard_check_pressed(vk_enter)
           || keyboard_check_pressed(vk_space)
           || keyboard_check_pressed(ord("E"));

if (advance) {
    page++;
    if (page >= array_length(pages)) {
        page    = array_length(pages) - 1;
        closing = true;
        visible = false;
    }
}
