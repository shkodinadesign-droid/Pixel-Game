// ===== ДИАЛОГ МАЙЛИ — МАГАЗИН (CREATE) =====

phase = 0;
// 0 → Майли приветствует
// 1 → Макс отвечает
// 2 → Майли предлагает посмотреть → потом открывается магазин

win_w  = 680;
pad    = 14;
line_h = 24;
win_h  = 50 + 3 * line_h + 50;
win_x  = (display_get_gui_width()  - win_w) / 2;
win_y  = 20;

btn_label = "Далее";
btn_w  = 120;
btn_h  = 30;
btn_x1 = win_x + win_w - btn_w - pad;
btn_y1 = win_y + win_h - btn_h - pad;
btn_x2 = btn_x1 + btn_w;
btn_y2 = btn_y1 + btn_h;

_click_prev = mouse_check_button(mb_left);
global.control_locked = true;
