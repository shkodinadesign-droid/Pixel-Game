// ===== BOOKCASE DIALOG CREATE =====

// Размеры окна
win_w = 620;
win_h = 200;

pad    = 14;
line_h = 22;

// GUI координаты (внизу экрана — мысли Макс)
win_x = (display_get_gui_width()  - win_w) / 2;
win_y = display_get_gui_height() - win_h - 75; // выше панели инструментов

// Текст - внутренний монолог Макс
speaker   = "Макс:";
line1 = "Любимые книги бабушки...";
var _q = chr(34);
line2 = "Вот эта сказка - " + _q + "Волшебник Изумрудного города" + _q + "...";
line3 = "Она читала мне её в детстве,";
line4 = "когда я была совсем маленькой -";
line5 = "в этом уютном домике...";

// Кнопка
btn_w = 130;
btn_h = 30;

btn_x1 = win_x + win_w - btn_w - pad;
btn_y1 = win_y + win_h - btn_h - pad;
btn_x2 = btn_x1 + btn_w;
btn_y2 = btn_y1 + btn_h;

_click_prev = false;

// Блокируем управление
global.control_locked = true;
