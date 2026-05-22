// === HINT OVER READY CARROT ===
if (place_meeting(x, y, obj_max)) {
    var yy = y - (sprite_exists(sprite_index) ? sprite_height : 16) - 6;
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_alpha(0.35);
    draw_rectangle(x-28, yy-14, x+28, yy+2, false);
    draw_set_alpha(1);
    draw_text(x, yy, "↑ — собрать");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
