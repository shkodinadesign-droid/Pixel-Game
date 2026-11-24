// ===== ЗЕЛЁНАЯ ТЕТРАДЬ (STEP) =====
var _clk = mouse_check_button(mb_left);
if (open_delay > 0) { open_delay--; _click_prev = _clk; exit; }
var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
var _hit = (!_click_prev && _clk && _mx >= btn_x1 && _mx <= btn_x1 + btn_w && _my >= btn_y1 && _my <= btn_y1 + btn_h);
_click_prev = _clk;
if (_hit || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_escape)) {
    if (owns_lock) global.control_locked = false;
    var _ev = then_event;
    instance_destroy();
    if (_ev != "") forest_on_dialog_finished(_ev);
}
