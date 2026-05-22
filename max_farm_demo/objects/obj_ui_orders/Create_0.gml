// ===== UI ЗАКАЗЫ CREATE =====

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

panel_w = 500;
panel_h = 340;
panel_x = (gui_w - panel_w) / 2;
panel_y = (gui_h - panel_h) / 2;

card_h   = 86;
card_pad = 8;
cards_y  = panel_y + 50;

btn_w = 100;
btn_h = 26;

// Предотвращаем немедленный клик
_click_prev = true;
