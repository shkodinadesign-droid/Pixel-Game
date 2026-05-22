// Подстилка кота — рисуется за всеми персонажами
if (room != rm_farm) exit;
var _hide = variable_global_exists("kitten_arrived") && !global.kitten_arrived
    && instance_exists(obj_day_controller) && obj_day_controller.day_index >= 2;
if (_hide) exit;

draw_set_color(make_color_rgb(160, 100, 60));
draw_ellipse(x - 18, y + 4, x + 18, y + 12, false);
draw_set_color(make_color_rgb(200, 140, 90));
draw_ellipse(x - 18, y + 4, x + 18, y + 12, true);
draw_set_color(c_white);
