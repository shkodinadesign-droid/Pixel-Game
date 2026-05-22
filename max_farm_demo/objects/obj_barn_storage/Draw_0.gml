// === HINT OVER BARN STORAGE ===
if (place_meeting(x, y, obj_max)) {
    var inv = variable_global_exists("inv_carrot") ? global.inv_carrot : 0;
    var txt = (inv > 0) ? ("↑ — сдать (" + string(inv) + ")") : "↑ — сдать";
    var yy = y - (sprite_exists(sprite_index) ? sprite_height : 16) - 6;

    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_alpha(0.35);
    draw_rectangle(x-40, yy-14, x+40, yy+2, false);
    draw_set_alpha(1);
    draw_text(x, yy, txt);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
