# Тоби — почтальон, день 2: заказ пиццы с колбасой в пекарне (obj_toby), вечером забирает готовую пиццу.
# Объект создаёт obj_day_controller в rm_bakery (visit = "order" | "pickup").
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import gm_res
P=sys.argv[1]
CREATE=r'''// ===== ТОБИ — ДЕРЕВЕНСКИЙ ПОЧТАЛЬОН (CREATE) =====
// Заходит в пекарню по старой привычке. visit задаёт obj_day_controller при создании:
//   "order"  — день 2, после Джастина и Майли: знакомство, заказ пиццы с колбасой, аванс 8 монет;
//   "pickup" — вечером (с 17:00), если пицца готова: забирает её и платит ещё 15 монет.
if (!variable_instance_exists(id, "visit")) visit = "order";
x = 236; y = 788;                                  // у двери пекарни (как Майли и Джастин)
path_in  = [[236, 618], [176, 404]];               // обход стульев -> прилавок
path_out = [[236, 618], [236, 788]];
wp    = 0;
spd   = 2;
face  = 1;                                          // 1 — вправо, -1 — влево
state = "enter";                                    // enter -> talk -> leave -> (note) -> конец
dlg_i = 0;
_click_prev = true;

lines = (visit == "order") ? [
    ["Тоби:", "О, открыто! А Соня сегодня не печёт?"],
    ["Макс:", "Она пока в городе. Я за неё. Ну... стараюсь."],
    ["Тоби:", "Тогда у меня важный вопрос. Пиццу с колбасой ты умеешь?"],
    ["Макс:", "Если рецепт есть в дневнике - разберусь."],
    ["Тоби:", "Отлично. После моей дороги я, кажется, целую съем."],
    ["Тоби:", "Вот аванс - 8 монет. Загляну вечером, после пяти!"],
] : [
    ["Тоби:", "Я вернулся! Ну что, пицца готова?"],
    ["Макс:", "Горячая, с колбасой - как заказывал!"],
    ["Тоби:", "Пахнет потрясающе! Вот остальные 15 монет. Спасибо, Макс!"],
];
// Мысль Макс после ухода Тоби, если колбасы ещё нет
note_line = ["Макс:", "Колбасы нет. Придётся посмотреть, что продаётся у Ивана в мясной лавке."];

// Окно диалога (как у продавцов): 620 шириной, сверху экрана, кнопка справа внизу
dlg_w = 620; dlg_h = 50 + 3 * 24 + 50; dlg_y = 20; dlg_pad = 14; btn_w = 120; btn_h = 30;
'''
STEP=r'''// ===== ТОБИ (STEP) =====
depth = -y;
var _gw  = display_get_gui_width();
var _dx  = (_gw - dlg_w) / 2;
var _bx1 = _dx + dlg_w - btn_w - dlg_pad, _by1 = dlg_y + dlg_h - btn_h - dlg_pad;
var _mx  = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
var _clk = mouse_check_button(mb_left);
var _adv = (!_click_prev && _clk && _mx >= _bx1 && _mx <= _bx1 + btn_w && _my >= _by1 && _my <= _by1 + btn_h)
        || keyboard_check_pressed(vk_return) || keyboard_check_pressed(vk_space);
_click_prev = _clk;

var _walk = function(_pts) {                       // шаг к текущей точке пути; true — путь пройден
    var _t = _pts[wp];
    if (point_distance(x, y, _t[0], _t[1]) > spd) {
        var _d = point_direction(x, y, _t[0], _t[1]);
        x = round(x + lengthdir_x(spd, _d)); y = round(y + lengthdir_y(spd, _d));
        if (abs(lengthdir_x(1, _d)) > 0.2) face = (lengthdir_x(1, _d) < 0) ? -1 : 1;
        return false;
    }
    x = _t[0]; y = _t[1]; wp++;
    return (wp >= array_length(_pts));
};

switch (state) {
    case "enter":
        if (_walk(path_in)) {
            state = "talk"; dlg_i = 0; _click_prev = true;
            global.control_locked = true;
            if (instance_exists(obj_max)) {                       // Макс поворачивается к посетителю
                obj_max.sprite_index = spr_max_idle_up; obj_max.direction_facing = "up";
                obj_max.image_speed = 0; obj_max.image_index = 0;
            }
        }
        break;
    case "talk":
        if (_adv) {
            dlg_i++;
            if (dlg_i >= array_length(lines)) {
                if (visit == "order") {
                    global.toby_order_taken = true;               // задание в дневнике + рецепт пиццы
                    global.coins += 8;                            // аванс на колбасу
                    global.diary_has_new = true; global.diary_was_read = false;
                } else if (inventory_remove(ITEM_PIZZA, 1)) {
                    global.coins += 15;
                    global.toby_pizza_done = true;
                    global.diary_has_new = true; global.diary_was_read = false;
                }
                global.control_locked = false;
                state = "leave"; wp = 0;
            }
        }
        break;
    case "leave":
        if (_walk(path_out)) {
            if (visit == "order" && inventory_get_amount("pepperoni") < 1) {
                state = "note"; _click_prev = true; global.control_locked = true;
            } else instance_destroy();
        }
        break;
    case "note":
        if (_adv) { global.control_locked = false; instance_destroy(); }
        break;
}
'''
DRAW=r'''// ===== ТОБИ (DRAW) — спрайты spr_toby_* 48x48, начало — низ по центру =====
if (state == "note") exit;                                   // уже ушёл — только мысль Макс в GUI
var _spr = spr_toby_idle_down, _fr = ((current_time div 150) mod 24 == 0) ? 1 : 0;
if (state == "enter" || state == "leave") {
    _spr = (face < 0) ? spr_toby_walk_left : spr_toby_walk_right;
    _fr  = (current_time div 110) mod 8;
} else if (state == "talk" && lines[dlg_i][0] == "Тоби:") {
    _spr = spr_toby_talk; _fr = [0, 1, 2, 1][(current_time div 300) mod 4];
}
draw_sprite(_spr, _fr, x, y);
'''
DRAWGUI=r'''// ===== ТОБИ (DRAW GUI) — окно диалога с говорящим портретом =====
var _ln;
if (state == "talk")      _ln = lines[dlg_i];
else if (state == "note") _ln = note_line;
else exit;

var _gw = display_get_gui_width();
var _dx = (_gw - dlg_w) / 2;
var _bx1 = _dx + dlg_w - btn_w - dlg_pad, _by1 = dlg_y + dlg_h - btn_h - dlg_pad;
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
scr_dialog_draw_bg(_dx, dlg_y, dlg_w, dlg_h);
scr_dialog_draw_speaker(_dx, dlg_y, dlg_w, dlg_h, _ln[0]);

var _tx = _dx + 15 * (dlg_w / 580) + 8;
var _ty = scr_dialog_body_top(_dx, dlg_y, dlg_w, dlg_h);
var _ps = 72;
var _talking = ((current_time div 250) mod 2 == 0) ? 0 : 1;
if (_ln[0] == "Тоби:") scr_dialog_draw_portrait(_dx, dlg_y, dlg_w, dlg_h, _by1, spr_toby_portrait_anim, _ps, _talking);
else                   scr_dialog_draw_portrait(_dx, dlg_y, dlg_w, dlg_h, _by1, spr_max_portrait, _ps);
var _tw = (_dx + 565 * (dlg_w / 580) - 8 - _ps) - _tx - 16;

draw_set_font(fnt_ui);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);
draw_text_ext(_tx, _ty, _ln[1], 24, _tw);

var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
var _last = (state == "note") || (dlg_i == array_length(lines) - 1);
scr_dialog_draw_button(_bx1, _by1, _bx1 + btn_w, _by1 + btn_h, _last ? "Хорошо" : "Далее",
                       _mx >= _bx1 && _mx <= _bx1 + btn_w && _my >= _by1 && _my <= _by1 + btn_h);
draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
'''
if not os.path.exists(f'{P}/objects/obj_toby'):
    gm_res.obj(P,'obj_toby',None,None,events={(0,0,'Create_0.gml'):CREATE,(3,0,'Step_0.gml'):STEP,(8,0,'Draw_0.gml'):DRAW,(8,64,'Draw_64.gml'):DRAWGUI},solid=False)
    gm_res.add_to_yyp(P,['obj_toby'])
else:
    for f,c in [('Create_0.gml',CREATE),('Step_0.gml',STEP),('Draw_0.gml',DRAW),('Draw_64.gml',DRAWGUI)]: open(f'{P}/objects/obj_toby/{f}','w').write(c)
print('obj_toby')
