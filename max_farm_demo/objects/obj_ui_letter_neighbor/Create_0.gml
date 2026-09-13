// ===== NEIGHBOR DIALOG CREATE =====

// размеры окна (компактное, смещено ниже; ширина увеличена под портрет справа)
win_w = 700;
win_h = 200;

pad    = 14;
line_h = 22;

// GUI координаты (всегда поверх камеры, смещено вниз на 100)
win_x = (display_get_gui_width()  - win_w) / 2;
win_y = (display_get_gui_height() - win_h) / 2 + 100;

// текст
line1_bold = "Бабуля Мэгги:";
line2 = "Внученька! Приехала наконец - я так ждала тебя!";
line3 = "Ты так выросла, умница моя =)";
line4 = "Сначала проверь почтовый ящик - я оставила тебе кое-что!";
line5 = "А потом покажу всё хозяйство - нас ждёт столько дел!";

// кнопка
btn_w = 120;
btn_h = 32;

btn_x1 = win_x + win_w - btn_w - pad;
btn_y1 = win_y + win_h - btn_h - pad;
btn_x2 = btn_x1 + btn_w;
btn_y2 = btn_y1 + btn_h;

_click_prev = false;

// управление держим заблокированным, пока окно открыто
if (!variable_global_exists("control_locked")) global.control_locked = false;
global.control_locked = true;
