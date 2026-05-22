// ===== JUSTIN DIALOG  -  CREATE =====
// Используется для всех 3 шагов катсцены Джастина.
// dialog_step читается из obj_justin.cscene_step:
//   3 = реплика Джастина (приветствие)
//   4 = реплика Макс (знакомство)
//   5 = реплика Джастина (прощание)

// Узнаём текущий шаг
dialog_step = 3;
if (instance_exists(obj_justin)) {
    dialog_step = obj_justin.cscene_step;
}

// === Контент по шагу ===
speaker    = "";
line1 = "";
line2 = "";
line3 = "";
line4 = "";
speaker_col = c_white;

switch (dialog_step) {

    case 3: // Джастин входит
        speaker     = "Джастин:";
        line1 = "Хэй привет!";
        line2 = "А где Бабушка Соня?";
        line3 = "Я пришел за своим любимым картофельным пирогом!";
        speaker_col = make_color_rgb(120, 190, 255);
        break;

    case 4: // Макс за стойкой
        speaker     = "Макс:";
        line1 = "Меня зовут Макс! Я внучка бабушки Сони.";
        line2 = "Она приболела и уехала на лечение в город";
        line3 = "а я приехала помочь =)";
        line4 = "Я попробую изготовить пирог по рецепту бабули  -  приходи завтра!";
        speaker_col = make_color_rgb(255, 210, 100);
        break;

    case 5: // Джастин прощается
        speaker     = "Джастин:";
        line1 = "Спасибо! Приятно было познакомиться!";
        line2 = "Я обязательно приду завтра!";
        speaker_col = make_color_rgb(120, 190, 255);
        break;
}

// === Размер окна ===
win_w = 620;
var _lines_used = 2;
if (line4 != "") {
    _lines_used = 4;
} else if (line3 != "") {
    _lines_used = 3;
}
win_h = 50 + _lines_used * 24 + 50;  // pad + строки + кнопка

pad    = 14;
line_h = 24;

win_x = (display_get_gui_width()  - win_w) / 2;
win_y = 20;  // вверху  -  как у Мэгги

// === Кнопка ===
if (dialog_step == 5) {
    btn_label = "Пока!";
} else {
    btn_label = "Далее";
}
btn_w = 120;
btn_h = 30;
btn_x1 = win_x + win_w - btn_w - pad;
btn_y1 = win_y + win_h - btn_h - pad;
btn_x2 = btn_x1 + btn_w;
btn_y2 = btn_y1 + btn_h;

_click_prev = mouse_check_button(mb_left);
global.control_locked = true;
