// ===== ДИАЛОГ ИЗ НЕСКОЛЬКИХ СТРАНИЦ (CREATE) =====
// Создаётся через dialog_seq_start(pages, on_finish). Страница: { who:"max"/"frog", speaker, lines:[...] }
// Блокировку управления снимает только если сам её поставил (owns_lock) — чужую не трогает.

forest_episode_init();

pages     = [];
on_finish = "";
page      = 0;

owns_lock = !global.control_locked;
global.control_locked = true;

open_delay  = 2;      // нажатие E, открывшее диалог, не листает первую страницу
closing     = false;  // закрываемся на следующем кадре, чтобы то же нажатие не сработало в мире
layout_page = -1;

win_w  = 640;
pad    = 14;
line_h = 24;
win_x  = (display_get_gui_width() - win_w) / 2;
win_y  = 20;
win_h  = 160;
btn_w  = 140;
btn_h  = 30;
btn_x1 = 0; btn_y1 = 0; btn_x2 = 0; btn_y2 = 0;
btn_label = "Далее";
portrait_size = 80;

_click_prev = mouse_check_button(mb_left);

/// Пересчитать размеры окна под текущую страницу
seq_layout = function() {
    var _n = max(1, array_length(pages[page].lines));
    win_h  = max(50 + _n * line_h + 50, 50 + 2 * line_h + 50);
    btn_x1 = win_x + win_w - btn_w - pad;
    btn_y1 = win_y + win_h - btn_h - pad;
    btn_x2 = btn_x1 + btn_w;
    btn_y2 = btn_y1 + btn_h;
    btn_label = (page < array_length(pages) - 1) ? "Далее" : "Хорошо";
    layout_page = page;
};
