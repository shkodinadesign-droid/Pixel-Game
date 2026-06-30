// ===== MAX PUDDING DIALOG — CREATE =====

speaker     = "Макс:";
speaker_col = make_color_rgb(255, 210, 100);

line1 = "Пуддинг готов!";
line2 = "Теперь как стемнеет — положу его на крыльцо.";
line3 = "Интересно что будет дальше...";
line4 = "";

win_w  = 620;
pad    = 14;
line_h = 24;

var _lines_used = 3;
win_h = 50 + _lines_used * line_h + 50;

win_x = (display_get_gui_width()  - win_w) / 2;
win_y = 20;

btn_label = "Далее";
btn_w  = 120;
btn_h  = 30;
btn_x1 = win_x + win_w - btn_w - pad;
btn_y1 = win_y + win_h - btn_h - pad;
btn_x2 = btn_x1 + btn_w;
btn_y2 = btn_y1 + btn_h;

_click_prev = mouse_check_button(mb_left);
