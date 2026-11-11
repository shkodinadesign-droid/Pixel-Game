// === КОЛОДЕЦ (DRAW) ===
draw_self();

// --- верёвка и ведро (ниже края кладки не рисуются — ушли в колодец) ---
var _by   = bucket_y + round(bucket_dy);
var _rope = min(_by, rim_y);
draw_set_color(make_color_rgb(149, 66, 27));
draw_rectangle(rope_x, rope_y0, rope_x + 1, _rope, false);
draw_set_color(make_color_rgb(221, 135, 63));
draw_rectangle(rope_x, rope_y0, rope_x, _rope, false);

var _spr = bucket_full ? spr_well_bucket_full : spr_well_bucket;
var _vis = rim_y - _by;
if (_vis > 0) {
    draw_sprite_part(_spr, 0, 0, 0, sprite_get_width(_spr), min(sprite_get_height(_spr), _vis), bucket_x, _by);
}

// --- капли и брызги ---
var _n = array_length(drops);
for (var i = 0; i < _n; i++) {
    var _d = drops[i];
    draw_set_color(make_color_rgb(140, 196, 236));
    draw_rectangle(round(_d.x), round(_d.y), round(_d.x) + 1, round(_d.y) + 1, false);
}
draw_set_color(c_white);

// --- реплика Макса (облачко над головой) ---
if (remark_timer > 0 && instance_exists(obj_max)) {
    draw_hint(remark_text, (obj_max.bbox_left + obj_max.bbox_right) * 0.5, obj_max.y, true);
}

// --- подсказка "[E] Набрать воду" над колодцем, пока Макс рядом ---
else if (well_state == "idle" && well_max_near()
&&  (!variable_global_exists("control_locked") || !global.control_locked)) {
    var _cx = (bbox_left + bbox_right) * 0.5;
    var yy  = wl_top - 6;

    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_alpha(0.35);
    draw_set_color(c_black);
    draw_rectangle(_cx - 60, yy - 14, _cx + 60, yy + 2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(_cx, yy, "[E] Набрать воду");
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
