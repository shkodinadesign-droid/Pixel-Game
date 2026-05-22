// ===== UI ВИТРИНА CREATE =====

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

panel_w = 520;
panel_h = 300;
panel_x = (gui_w - panel_w) / 2;
panel_y = (gui_h - panel_h) / 2;

// Левая колонка — инвентарь (товары для выставки)
inv_list_x = panel_x + 16;
inv_list_y  = panel_y + 52;
item_h      = 36;

// Правая колонка — витрина
vit_col_x = panel_x + panel_w / 2 + 8;
vit_col_y = panel_y + 52;

// Кнопка "Забрать монеты"
btn_w = 148;
btn_h = 28;
btn_x = panel_x + panel_w - btn_w - 12;
btn_y = panel_y + panel_h - btn_h - 14;

// Предотвращаем немедленный клик
_click_prev = true;
