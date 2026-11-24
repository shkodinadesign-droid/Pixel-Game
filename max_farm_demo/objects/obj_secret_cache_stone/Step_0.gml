// ===== КАМЕНЬ СО ЗВЁЗДОЧКОЙ (STEP) =====
near_player = false;
if (!instance_exists(obj_max) || !global.maggie_sign_talk_done || global.secret_cache_found) exit;
var _p = instance_find(obj_max, 0);
near_player = point_distance(x + 15, y + 18, (_p.bbox_left + _p.bbox_right) * 0.5, _p.bbox_bottom) < 44;
if (!near_player || global.control_locked || !keyboard_check_pressed(ord("E"))) exit;

dialog_seq_start([
    forest_page("max", ["Яблоня... и камень у корней.", "Как на фотографии!"]),
    forest_page("max", ["Звёздочка почти вся под мхом."]),
    forest_page("max", ["Тяжёлый... Ну же!"]),
    forest_page("max", ["Жестяная коробка!"]),
    forest_page("max", ["Ключ... пара стеклянных шариков...", "и записка."]),
    forest_page("max", ["Бумага совсем свежая.", "Значит, бабушка открывала эту коробку", "совсем недавно..."])
], "cache_open");
