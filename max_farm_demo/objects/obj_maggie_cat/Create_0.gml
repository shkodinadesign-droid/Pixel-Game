// ===== КОТ МЭГГИ — CREATE =====
// Спит на крыше дома Мэгги и тихонько дышит (анимация спрайта, 2 кадра/с).
// Рисуется сразу над домом: дом (obj_village_prop) стоит на глубине -bbox_bottom, кот — на 1 ближе.
var _house = instance_nearest(x, y, obj_maggie_house);
depth = (_house != noone) ? -_house.bbox_bottom - 1 : -y;
