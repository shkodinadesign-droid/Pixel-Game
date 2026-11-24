// ===== МЭГГИ ДОМА (DRAW): стул -> Мэгги -> край сиденья -> второй стул -> стол -> чашка -> пар =====
var _f = floor(current_time / 220) mod sprite_get_number(spr_maggie_idle_right);
draw_sprite(spr_cafe_chair_Left, 0, chair_x, chair_y);
draw_sprite_part(spr_maggie_idle_right, _f, 0, 0, 32, MG_CUT, mg_x, mg_y);
draw_sprite_part(spr_cafe_chair_Left, 0, 0, SEAT, sprite_get_width(spr_cafe_chair_Left),
                 sprite_get_height(spr_cafe_chair_Left) - SEAT, chair_x, chair_y + SEAT);
draw_sprite(spr_cafe_chair, 0, chair2_x, chair2_y);
draw_self();
draw_sprite_ext(spr_dish_tea_grandma, 0, cup_x, cup_y, cup_xs, cup_ys, 0, c_white, 1);

// пар над чашкой — три тонких завитка
draw_set_color(c_white);
for (var i = 0; i < 3; i++) {
    var _ph = (current_time / 35 + i * 20) mod 60;
    var _sx = cup_x + 7 + sin(current_time / 300 + i * 2) * 2;
    var _sy = cup_y + 1 - _ph * 0.35;
    draw_set_alpha(0.45 * (1 - _ph / 60));
    draw_rectangle(_sx, _sy, _sx, _sy + 1, false);
}
draw_set_alpha(1);

if (near_player && !global.control_locked) draw_hint("[E] Поговорить", mg_x + 16, mg_y + 2, true);
