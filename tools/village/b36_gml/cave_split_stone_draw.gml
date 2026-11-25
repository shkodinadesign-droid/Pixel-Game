// ===== РАСКОЛОТЫЙ КАМЕНЬ (DRAW) — две половинки большого камня с трещиной =====
var _s = spr_forest_big_stone, _k = 0.55, _x = 800, _y = 205, _hw = 36;
draw_sprite_part_ext(_s, 0, 0,   0, _hw,      56, _x,                _y,     _k, _k, c_white, 1);
draw_sprite_part_ext(_s, 0, _hw, 0, 72 - _hw, 56, _x + _hw * _k + 3, _y + 1, _k, _k, c_white, 1);
