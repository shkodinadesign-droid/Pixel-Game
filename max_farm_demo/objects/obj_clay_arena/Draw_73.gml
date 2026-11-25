// ===== ПЕРВОЕ ИСПЫТАНИЕ (DRAW END): свет, предупреждения поверх темноты, частицы =====
var _m = max_side;
light_surf = cave_light_begin(light_surf, make_color_rgb(104, 90, 118));     // арена светлее прохода — края видны
if (instance_exists(_m) && global.has_lantern) {
    var _lx = cave_lantern_x(_m), _ly = cave_lantern_y(_m);
    cave_light_circle(_lx, _ly, 200 + sin(flick / 9) * 3, make_color_rgb(200, 164, 118));
    cave_light_circle(_lx, _ly, 80, make_color_rgb(70, 54, 32));
}
if (state == "done") cave_light_circle(944, 120, 90, make_color_rgb(70, 80, 110));   // из открытого выхода тянет прохладой
cave_light_end(light_surf);
side_draw_edges(0.45);

// предупреждения камней: тень на земле + струйка крошки с потолка
for (var i = 0; i < array_length(rocks); i++) {
    var r = rocks[i];
    if (r.st != "warn" && r.st != "fall") continue;
    var _k = (r.st == "warn") ? r.t / r.warn : 1;
    draw_set_color(c_black); draw_set_alpha(0.25 + 0.4 * _k);
    var _hw = ROCK_W * (0.3 + 0.25 * _k);
    draw_ellipse(r.x - _hw, r.gy - 5, r.x + _hw, r.gy + 3, false);
    if (r.st == "warn") {
        draw_set_color(make_color_rgb(210, 190, 170)); draw_set_alpha(0.8);
        for (var k = 0; k < 8; k++) {
            var _py = 24 + ((flick * 5 + k * 47) mod max(1, r.gy - 30));
            draw_point(r.x - 4 + (k mod 3) * 4, _py);
        }
    }
}
draw_set_alpha(1);

// раскрутка шара: дуги движения; оглушён — звёздочки
if (state == "p1") {
    if (sub == "spin") {
        draw_set_color(c_white); draw_set_alpha(0.55);
        for (var k = 0; k < 3; k++) {
            var _a = flick * 18 * -dir + k * 120;
            draw_line(gx + lengthdir_x(gr + 6, _a), F - gr + lengthdir_y(gr + 6, _a), gx + lengthdir_x(gr + 6, _a + 35), F - gr + lengthdir_y(gr + 6, _a + 35));
        }
        draw_set_alpha(1);
    } else if (sub == "stun") {
        draw_set_color(make_color_rgb(255, 230, 120));
        for (var k = 0; k < 3; k++) { var _a = flick * 6 + k * 120; draw_circle(gx + lengthdir_x(16, _a), F - gr * 2 - 8 + lengthdir_y(5, _a), 2, false); }
    }
}
// кромка глины видна всегда
if (clay_y < F) {
    draw_set_color(make_color_rgb(220, 170, 120)); draw_set_alpha(0.6);
    for (var _x = 0; _x < room_width; _x += 8) draw_rectangle(_x, clay_y + sin(_x / 23 + flick / 18) * 2, _x + 7, clay_y + sin(_x / 23 + flick / 18) * 2, false);
    draw_set_alpha(1);
}
// частицы
for (var i = 0; i < array_length(parts); i++) { var p = parts[i]; draw_set_color(p.c); draw_rectangle(p.x, p.y, p.x + 1, p.y + 1, false); }
draw_set_color(c_white);
cave_fx_draw();
