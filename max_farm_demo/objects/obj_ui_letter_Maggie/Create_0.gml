// ===== MEGGI DIALOG CREATE =====

// размеры окна
win_w = 620;
win_h = 220;

pad    = 14;
line_h = 22;

// GUI координаты (вверху экрана, над персонажами)
win_x = (display_get_gui_width()  - win_w) / 2;
win_y = 20;

// текст диалога — приветствие (дневник отдаётся вторым диалогом сразу следом)
line1_bold = "Бабуля Мэгги:";
line2 = "Дорогая Макс - я так рада что ты приехала!";
line3 = "Помнишь меня? Я Мэгги - подруга твоей бабушки,";
line4 = "я помню как ты была ещё совсем малышкой.";

// кнопка
btn_w = 140;
btn_h = 30;

btn_x1 = win_x + win_w - btn_w - pad;
btn_y1 = win_y + win_h - btn_h - pad;
btn_x2 = btn_x1 + btn_w;
btn_y2 = btn_y1 + btn_h;

_click_prev = false;

// управление заблокировано
if (!variable_global_exists("control_locked")) global.control_locked = false;
global.control_locked = true;
