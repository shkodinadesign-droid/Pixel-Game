// ===== ДИАЛОГ МЭГГИ  -  КОТИК (CREATE) =====
// dialog_step:
//   1  -  Мэгги: "Привет моя девочка!.. его зовут Кекс..."
//   2  -  Макс:  "О тётушка Мэгги  -  как здорово!.."
//   3  -  Мэгги: "Я рада моя дорогая девочка  -  мне пора!.."

dialog_step = 1;

speaker     = "";
line1       = "";
line2       = "";
line3       = "";
speaker_col = c_white;

switch (dialog_step) {
    case 1:
        speaker     = "Тётя Мэгги:";
        line1       = "Привет моя девочка! Как ты? Справляешься на ферме?";
        line2       = "А я привела к тебе дружочка твоей бабули  -  его зовут Кекс.";
        line3       = "Он был у меня пока ты не приехала.";
        speaker_col = make_color_rgb(200, 140, 200);
        break;
    case 2:
        speaker     = "Макс:";
        line1       = "О тётушка Мэгги  -  как здорово!";
        line2       = "Теперь мне не будет одиноко здесь! =)";
        speaker_col = make_color_rgb(255, 210, 100);
        break;
    case 3:
        speaker     = "Тётя Мэгги:";
        line1       = "Я рада моя дорогая девочка  -  мне пора!";
        line2       = "Если что-то нужно  -  приходи ко мне в гости! =)";
        speaker_col = make_color_rgb(200, 140, 200);
        break;
}

win_w  = 640;
pad    = 14;
line_h = 24;

var _lines = (line3 != "") ? 3 : ((line2 != "") ? 2 : 1);
win_h = 50 + _lines * line_h + 50;

win_x = (display_get_gui_width()  - win_w) / 2;
win_y = 20;

btn_label = (dialog_step == 3) ? "Пока!" : "Далее";
btn_w  = 140;
btn_h  = 30;
btn_x1 = win_x + win_w - btn_w - pad;
btn_y1 = win_y + win_h - btn_h - pad;
btn_x2 = btn_x1 + btn_w;
btn_y2 = btn_y1 + btn_h;

_click_prev = mouse_check_button(mb_left);
global.control_locked = true;
