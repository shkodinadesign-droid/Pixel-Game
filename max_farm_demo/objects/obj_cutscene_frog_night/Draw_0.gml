if (phase < 4 || phase > 6) exit;

var _frame = (frog_anim div 8) mod 4;

var _spr = -1;
switch (phase) {
    case 4: _spr = spr_frog_walk_side_left;  break; // идёт к пуддингу (влево)
    case 5: _spr = spr_frog_idle_down;        break; // стоит, берёт
    case 6: _spr = spr_frog_walk_side_right;  break; // убегает вправо
}

if (sprite_exists(_spr)) {
    draw_sprite(_spr, _frame, x, y);
}
