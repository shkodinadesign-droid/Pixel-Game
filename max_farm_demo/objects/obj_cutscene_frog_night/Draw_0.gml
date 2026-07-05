if (phase < 1 || phase > 3) exit;

var _frame = (frog_anim div 8) mod 4;

var _spr = -1;
switch (phase) {
    case 1: _spr = spr_frog_walk_side_right; break; // идёт к пуддингу
    case 2: _spr = spr_frog_idle_down;       break; // стоит, ест
    case 3: _spr = spr_frog_walk_side_left;  break; // уходит обратно
}

if (sprite_exists(_spr)) {
    draw_sprite(_spr, _frame, x, y);
}
