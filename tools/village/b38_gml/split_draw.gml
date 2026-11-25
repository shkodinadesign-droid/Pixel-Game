// ===== РАСКОЛОТЫЙ КАМЕНЬ (DRAW) =====
var _s = spr_forest_big_stone, _k = 0.55, _hw = 36;
draw_sprite_part_ext(_s, 0, 0,   0, _hw,      56, x,                y,     _k, _k, c_white, 1);
draw_sprite_part_ext(_s, 0, _hw, 0, 72 - _hw, 56, x + _hw * _k + 3, y + 1, _k, _k, c_white, 1);
