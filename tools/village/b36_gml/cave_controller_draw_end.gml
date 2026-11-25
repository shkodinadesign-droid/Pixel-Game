// ===== СТАРАЯ ПЕЩЕРА (DRAW END) — карта света, умножается на картинку =====
var _w = room_width, _h = room_height;
if (!surface_exists(light_surf)) light_surf = surface_create(_w, _h);
surface_set_target(light_surf);
draw_clear(make_color_rgb(62, 54, 74));                 // темнота (не совсем чёрная)
gpu_set_blendmode(bm_add);
var _day = make_color_rgb(150, 142, 128);               // дневной свет от входа внизу
draw_rectangle_colour(0, _h - 150, _w, _h, c_black, c_black, _day, _day, false);
if (instance_exists(obj_max)) {                         // глаза привыкают — немного видно вокруг Макс
    var _p  = instance_find(obj_max, 0);
    var _mx = (_p.bbox_left + _p.bbox_right) * 0.5, _my = _p.bbox_bottom - 20;
    var _r  = 112 + sin(flick / 23) * 2;
    draw_circle_colour(_mx, _my, _r, make_color_rgb(175, 165, 150), c_black, false);
    draw_circle_colour(_mx, _my, _r * 0.5, make_color_rgb(70, 66, 60), c_black, false);
}
gpu_set_blendmode(bm_normal);
surface_reset_target();
gpu_set_blendmode_ext(bm_zero, bm_src_colour);          // умножение: тёмное темнит, белое не меняет
draw_surface(light_surf, 0, 0);
gpu_set_blendmode(bm_normal);
