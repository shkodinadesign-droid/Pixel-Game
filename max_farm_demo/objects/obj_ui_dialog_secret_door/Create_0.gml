// ===== ДИАЛОГ: ЗАКРЫТАЯ ТАЙНАЯ ДВЕРЬ (CREATE) =====

speaker     = "Макс:";
speaker_col = make_color_rgb(255, 210, 100);

forest_episode_init();
if (!variable_instance_exists(id, "recognized_now")) recognized_now = false;

if (room == rm_joshua_shop) {
    // Дверь в магазине Майли — просто закрыто
    line1 = "Тут закрыто.";
    line2 = "";
    line3 = "";
    line4 = "";
    line_count = 1;
} else if (global.door_sign_found) {
    // Пекарня — Макс узнала знак с камня
    line1 = "Это же тот самый знак! Как на камне в лесу.";
    line2 = "Бабушка правда знала, что он означает...";
    line3 = "Она далеко, письмом такое не спросишь.";
    line4 = "Может, Мэгги знает, что это за дверь?";
    line_count = 4;
    if (!recognized_now) {
        line1 = "Заперто. Знак как на камне в лесу.";
        line2 = "Надо спросить Мэгги, что это за дверь.";
        line3 = "";
        line4 = "";
        line_count = 2;
    }
} else {
    // Пекарня — до разговора с лягушонком: просто странная запертая дверь
    line1 = "Заперто. Эта дверь выглядит необычно.";
    line2 = "На ней вырезан какой-то узор.";
    line3 = "";
    line4 = "";
    line_count = 2;
}

win_w  = 560;
pad    = 14;
line_h = 26;
win_h  = pad + round(line_h * 1.5) + line_h * (line_count + 0.5) + pad * 2 + 40;
win_x  = (display_get_gui_width()  - win_w) / 2;
win_y  = 20;

// Портрет Макса
icon_size = 64;
icon_x    = win_x + pad;
icon_y    = scr_dialog_body_top(win_x, win_y, win_w, win_h);

btn_label = "Понятно";
btn_w  = 130;
btn_h  = 30;
btn_x1 = win_x + win_w - btn_w - pad;
btn_y1 = win_y + win_h - btn_h - pad;
btn_x2 = btn_x1 + btn_w;
btn_y2 = btn_y1 + btn_h;

_click_prev = mouse_check_button(mb_left);
if (!variable_global_exists("control_locked")) global.control_locked = false;
global.control_locked = true;
