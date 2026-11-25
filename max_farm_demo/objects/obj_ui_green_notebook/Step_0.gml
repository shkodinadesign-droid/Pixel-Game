// ===== ЗЕЛЁНАЯ ТЕТРАДЬ (STEP) =====
// Дальше: кнопка / Enter / Пробел / стрелка вправо. Назад: кнопка / стрелка влево. Esc — закрыть.
var _clk = mouse_check_button(mb_left);
if (open_delay > 0) { open_delay--; _click_prev = _clk; exit; }
var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
var _press = (!_click_prev && _clk);
_click_prev = _clk;
var _hit_next = _press && _mx >= btn_x1 && _mx <= btn_x1 + btn_w && _my >= btn_y1 && _my <= btn_y1 + btn_h;
var _hit_back = _press && spread > 0 && _mx >= back_x1 && _mx <= back_x1 + btn_w && _my >= btn_y1 && _my <= btn_y1 + btn_h;

var _next  = _hit_next || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_right);
var _back  = _hit_back || (keyboard_check_pressed(vk_left) && spread > 0);
var _close = keyboard_check_pressed(vk_escape) || (_next && spread >= SPREADS - 1);

if (_close) {
    if (owns_lock) global.control_locked = false;
    var _ev = then_event;
    instance_destroy();
    if (_ev != "") forest_on_dialog_finished(_ev);
    exit;
}
if (_next) spread += 1;
else if (_back) spread -= 1;
