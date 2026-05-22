// ===== ДИАЛОГ: ЗАКРЫТАЯ ТАЙНАЯ ДВЕРЬ (CREATE) =====

speaker     = "Макс:";
speaker_col = make_color_rgb(255, 210, 100);

var _quest = variable_global_exists("secret_quest_started") && global.secret_quest_started;

if (_quest) {
    line1 = "Эта дверь закрыта. Это похоже на";
    line2 = "тайную комнату из письма бабули.";
    line3 = "Чтобы её открыть я должна";
    line4 = "выполнить все задания бабушки.";
    line_count = 4;
} else {
    line1 = "Эта дверь закрыта.";
    line2 = "Это похоже на тайную комнату =)";
    line3 = "";
    line4 = "";
    line_count = 2;
}

win_w  = 520;
pad    = 14;
line_h = 26;
win_h  = pad + round(line_h * 1.5) + line_h * (line_count + 0.5) + pad * 2 + 40;
win_x  = (display_get_gui_width()  - win_w) / 2;
win_y  = 20;

// Портрет Макса
icon_size = 64;
icon_x    = win_x + pad;
icon_y    = win_y + pad + round(line_h * 1.5);

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
