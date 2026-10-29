// ===== ЖИВАЯ ИЗГОРОДЬ, ВЕРТИКАЛЬНЫЙ СЕГМЕНТ (CREATE) =====
// Модульная изгородь 32x32 (origin — левый верхний угол, ставить по сетке).
// Вариант сегмента выбирается по позиции, чтобы ряд не выглядел копией одного тайла.
var _variants = [spr_village_hedge_mod_v1, spr_village_hedge_mod_v2, spr_village_hedge_mod_v3];
sprite_index = _variants[((x div 32) + (y div 32)) mod array_length(_variants)];
event_inherited();   // obj_village_prop: препятствие, depth = -bbox_bottom
