// ===== СТАРАЯ ФОТОГРАФИЯ: СОНЯ И МЭГГИ У МОЛОДОЙ ЯБЛОНИ (CREATE) =====
// Мэгги показывает её Макс. Два ориентира: молодая яблоня и большой плоский камень со звёздочкой у корней.
// Картинка — spr_photo_sonya_maggie (рисунок автора, 480x360, tools/characters/photo_sonya_maggie.py).
// Если спрайта нет — временная картинка в сепии, нарисованная кодом.
// then_event — событие для forest_on_dialog_finished после закрытия (задаёт создатель).
then_event  = "";
open_delay  = 10;
owns_lock   = !global.control_locked;
global.control_locked = true;
_click_prev = true;
photo_spr   = asset_get_index("spr_photo_sonya_maggie");

pw = 480; ph = 360;                                   // сама фотография (1:1 со спрайтом)
px = (display_get_gui_width() - pw) / 2;
py = (display_get_gui_height() - ph - 74) / 2;        // под фото — подпись и кнопка
btn_w = 140; btn_h = 30;
btn_x1 = (display_get_gui_width() - btn_w) / 2; btn_y1 = py + ph + 40;
caption = "Бабушка Соня и Мэгги в детстве";
