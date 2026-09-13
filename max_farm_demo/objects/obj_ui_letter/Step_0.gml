// =============================================
// УНИВЕРСАЛЬНОЕ ОКНО ПИСЬМА (STEP)
// =============================================

// --- Отложенная инициализация: читаем letter_data на первом кадре ---
if (!ready) {
    if (variable_instance_exists(id, "letter_data") && is_struct(letter_data)) {
        sender     = letter_data.sender;
        title_text = letter_data.title;
        lines      = letter_data.lines;
        hint_text  = variable_struct_exists(letter_data, "hint") ? letter_data.hint : "";

        // пересчитываем высоту окна по содержимому (с учётом переноса строк —
        // текст сужен портретом справа, поэтому длинные строки могут занимать 2 визуальные строки)
        var _scale_x     = win_w / 580;
        var _portrait_x1 = win_x + 565 * _scale_x - 8 - 140;
        var _text_x      = win_x + 15 * _scale_x + 8;
        var _text_max_w  = _portrait_x1 - _text_x - 16;

        var _content_h = 0;
        for (var i = 0; i < array_length(lines); i++) {
            _content_h += string_height_ext(lines[i], -1, _text_max_w) + 6;
        }
        var _hint_extra = (hint_text != "") ? (line_h * 0.5 + string_height_ext("Подсказка: " + hint_text, -1, _text_max_w)) : 0;

        win_h = pad + _content_h + _hint_extra + btn_h + pad * 3;
        win_h = max(win_h, 260);

        // перерасчёт позиций
        win_y  = (display_get_gui_height() - win_h) / 2;
        btn_y1 = win_y + win_h - btn_h - pad;
        btn_y2 = btn_y1 + btn_h;
        btn_x1 = win_x + win_w - btn_w - pad;
        btn_x2 = btn_x1 + btn_w;
    }
    ready = true;
}

// --- Закрытие ---
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

var click_now   = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev = click_now;

if ((hover && click_press)
    || keyboard_check_pressed(vk_enter)
    || keyboard_check_pressed(vk_space)) {

    global.control_locked = false;
    instance_destroy();
}
