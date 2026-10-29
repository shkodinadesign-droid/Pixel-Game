// ===== ЖИВАЯ ИЗГОРОДЬ, ГОРИЗОНТАЛЬНЫЙ СЕГМЕНТ (CREATE) =====
// Модульная изгородь 32x32 (origin — левый верхний угол, ставить по сетке).
// Вариант сегмента выбирается по позиции, чтобы ряд не выглядел копией одного тайла.
var _variants = [spr_village_hedge_mod_h1, spr_village_hedge_mod_h2, spr_village_hedge_mod_h3, spr_village_hedge_mod_h4];
sprite_index = _variants[((x div 32) + (y div 32)) mod array_length(_variants)];
event_inherited();   // obj_village_prop: препятствие, depth = -bbox_bottom
