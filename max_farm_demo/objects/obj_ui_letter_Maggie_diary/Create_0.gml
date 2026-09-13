// ===== MEGGI DIARY DIALOG CREATE =====

// размеры окна
win_w = 620;
win_h = 200;

pad    = 14;
line_h = 22;

// GUI координаты (вверху экрана)
win_x = (display_get_gui_width()  - win_w) / 2;
win_y = 20;

// текст диалога
line1_bold = "Бабуля Мэгги:";
line2 = "Вот дневник твоей бабули, тут рецепты";
line3 = "и много много интересного, чтобы управлять фермой.";
line4 = "Обязательно изучи его.";
line5 = "Всего тебе хорошего, дорогая!";

// кнопка
btn_w = 140;
btn_h = 30;

btn_x1 = win_x + win_w - btn_w - pad;
btn_y1 = win_y + win_h - btn_h - pad;
btn_x2 = btn_x1 + btn_w;
btn_y2 = btn_y1 + btn_h;

_click_prev = false;
