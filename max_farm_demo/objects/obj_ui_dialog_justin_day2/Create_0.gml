// ===== JUSTIN DAY 2 DIALOG  -  CREATE =====
// Используется для двух моментов:
//   cscene_step 3 = Джастин приходит за пирогом
//   cscene_step 4 = Макс отдаёт пирог
//   cscene_step 8 = Джастин прощается

dialog_step = 3;
if (instance_exists(obj_justin_day2)) {
    dialog_step = obj_justin_day2.cscene_step;
}

speaker     = "";
line1 = "";
line2 = "";
line3 = "";
line4 = "";
speaker_col = c_white;

switch (dialog_step) {

    case 3: // Джастин приходит
        speaker     = "Джастин:";
        line1 = "Привет Макс!";
        line2 = "А я зашёл за пирогом! =)";
        speaker_col = make_color_rgb(120, 190, 255);
        break;

    case 4: // Макс отдаёт пирог
        speaker     = "Макс:";
        line1 = "Пожалуйста вот твой пирог!";
        line2 = "Готовила по рецепту бабули =)";
        speaker_col = make_color_rgb(255, 210, 100);
        break;

    case 8: // Джастин прощается
        speaker     = "Джастин:";
        line1 = "Спасибо Макс!";
        line2 = "Завтра ещё зайду в вашу милую пекарню!";
        line3 = "Пока!";
        speaker_col = make_color_rgb(120, 190, 255);
        break;
}

// Размер окна
win_w = 620;
var _lines = (line4 != "") ? 4 : ((line3 != "") ? 3 : 2);
win_h = 50 + _lines * 24 + 50;
pad    = 14;
line_h = 24;

win_x = (display_get_gui_width()  - win_w) / 2;
win_y = 20;

// Кнопка
if (dialog_step == 8) {
    btn_label = "Пока!";
} else if (dialog_step == 4) {
    btn_label = "Передать пирог";
} else {
    btn_label = "Далее";
}
btn_w  = 140;
btn_h  = 30;
btn_x1 = win_x + win_w - btn_w - pad;
btn_y1 = win_y + win_h - btn_h - pad;
btn_x2 = btn_x1 + btn_w;
btn_y2 = btn_y1 + btn_h;

_click_prev = mouse_check_button(mb_left);
global.control_locked = true;
