// ===== СТАРАЯ ФОТОГРАФИЯ: СОНЯ И МЭГГИ У МОЛОДОЙ ЯБЛОНИ (CREATE) =====
// Мэгги показывает её Макс. Два ориентира: молодая яблоня и большой плоский камень со звёздочкой у корней.
// Временная графика рисуется кодом. Если появится спрайт spr_photo_sonya_maggie — будет показан он.
// then_event — событие для forest_on_dialog_finished после закрытия (задаёт создатель).
then_event  = "";
open_delay  = 10;
owns_lock   = !global.control_locked;
global.control_locked = true;
_click_prev = true;
photo_spr   = asset_get_index("spr_photo_sonya_maggie");

pw = 360; ph = 250;                                   // сама фотография
px = (display_get_gui_width() - pw) / 2;
py = (display_get_gui_height() - ph) / 2 - 24;
btn_w = 140; btn_h = 30;
btn_x1 = (display_get_gui_width() - btn_w) / 2; btn_y1 = py + ph + 40;
