// ===== ДИАЛОГ: КОФЕ ГОТОВ (CREATE) =====

speaker     = "Макс:";
speaker_col = make_color_rgb(255, 210, 100);
line1       = "Ммм как вкусно!";
line2       = "Посажу клубнику и картофель — как просила бабуля!";

win_w  = 560;
pad    = 14;
line_h = 24;
win_h  = 50 + 2 * line_h + 50;
cup_anim = 0; // для анимации пара
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
