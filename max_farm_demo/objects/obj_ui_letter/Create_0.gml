// =============================================
// УНИВЕРСАЛЬНОЕ ОКНО ПИСЬМА (CREATE)
// =============================================

// letter_data задаётся создателем (obj_mailbox) ПОСЛЕ Create
// поэтому читаем данные отложенно в Step через флаг ready
ready = false;

// поля письма (заполняются из letter_data)
sender     = "";
title_text = "";
lines      = [];
hint_text  = "";

// размеры окна (GUI-координаты)
win_w = 620;
win_h = 300;
win_x = (display_get_gui_width()  - win_w) / 2;
win_y = (display_get_gui_height() - win_h) / 2;

pad    = 24;
line_h = 28;

// кнопка «Закрыть»
btn_w  = 180;
btn_h  = 42;
btn_x1 = win_x + win_w - btn_w - pad;
btn_y1 = win_y + win_h - btn_h - pad;
btn_x2 = btn_x1 + btn_w;
btn_y2 = btn_y1 + btn_h;

_click_prev = false;

// блокируем управление
if (!variable_global_exists("control_locked")) global.control_locked = false;
global.control_locked = true;
