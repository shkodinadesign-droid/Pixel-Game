// ===== ЛЕСНОЙ КУСТ (CREATE) =====
// Чередуем два существующих спрайта кустов, сортировка глубины — по низу куста.
if (((x div 32) + (y div 32)) mod 2 == 1) sprite_index = spr_bush_2;
depth = -bbox_bottom;
