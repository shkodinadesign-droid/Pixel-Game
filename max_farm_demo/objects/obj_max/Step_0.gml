
if (global.control_locked) {
    // Остановить анимацию — не ходить на месте
    image_speed = 0;
    image_index = 0;
    switch (direction_facing) {
        case "down":  sprite_index = spr_max_idle_up;    break;
        case "up":    sprite_index = spr_max_idle_down;  break;
        case "left":  sprite_index = spr_max_idle_left;  break;
        case "right": sprite_index = spr_max_idle_right; break;
    }
    exit;
}


// ===============================================================


// ---------- вспомогательные функции ----------
function soil_under_feet() {
    var cx = floor(x / CELL) * CELL + CELL/2;
    var cy = floor(y / CELL) * CELL + CELL/2;
    var _s = instance_position(cx, cy, obj_soil);
    if (_s == noone) _s = collision_circle(x, y, 32, obj_soil, false, true);
    return _s;
}

function soil_in_front() {
    var tx = floor((x + facing[0]*CELL) / CELL) * CELL + CELL/2;
    var ty = floor((y + facing[1]*CELL) / CELL) * CELL + CELL/2;
    return instance_position(tx, ty, obj_soil);
}

// ---------- открытие дневника ----------
if (variable_global_exists("has_diary") && global.has_diary) {
    var _diary_alpha = variable_global_exists("diary_appear_alpha") ? global.diary_appear_alpha : 1;
    if (_diary_alpha >= 1 && mouse_check_button_pressed(mb_left)) {
        var _gui_w   = display_get_gui_width();
        var _gui_h   = display_get_gui_height();
        var _panel_h = 48;
        var _slot_w  = 72;
        var _total   = array_length(hotbar_items);
        var _eff_vis = min(hotbar_visible, _total - hotbar_scroll);
        var _can_l   = hotbar_scroll > 0;
        var _can_r   = hotbar_scroll + hotbar_visible < _total;
        var _panel_w = _slot_w + (_can_l ? 24 : 0) + _slot_w * _eff_vis + (_can_r ? 24 : 0);
        var _panel_x = (_gui_w - _panel_w) / 2;
        var _panel_y = _gui_h - _panel_h - 10;
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        // Дневник теперь в первом слоте (слева)
        if (_mx >= _panel_x && _mx <= _panel_x + _slot_w &&
            _my >= _panel_y && _my <= _panel_y + _panel_h) {
            if (!instance_exists(obj_diary)) {
                instance_create_layer(0, 0, "Instances", obj_diary);
            }
        }
    }
}

// ---------- движение и анимации ----------
var move_x = 0;
var move_y = 0;
state = "idle";

if (keyboard_check(vk_right)) { move_x =  walk_speed; sprite_index = spr_max_walk_right; state = "walk"; image_speed = 0.2; direction_facing = "right"; }
if (keyboard_check(vk_left))  { move_x = -walk_speed; sprite_index = spr_max_walk_left;  state = "walk"; image_speed = 0.2; direction_facing = "left";  }
if (keyboard_check(vk_up))    { move_y = -walk_speed; sprite_index = spr_max_walk_up;    state = "walk"; image_speed = 0.2; direction_facing = "up";    }
if (keyboard_check(vk_down))  { move_y =  walk_speed; sprite_index = spr_max_walk_down;  state = "walk"; image_speed = 0.2; direction_facing = "down";  }

// обновляем направление взгляда (для полива "вперёд")
var dx = keyboard_check(vk_right) - keyboard_check(vk_left);
var dy = keyboard_check(vk_down)  - keyboard_check(vk_up);
if (dx != 0 || dy != 0) {
    facing[0] = sign(dx);
    facing[1] = sign(dy);
}

// ---------- действия (разрешены только когда НЕ заблокирован вход/выход) ----------

// Ищем ближайшую грядку каждый фрейм — как в Stardew:
// радиус 64px = 2 клетки, работает стоя на тайле или рядом
nearest_soil = noone;
var _min_soil_dist = 64;
with (obj_soil) {
    var _d = point_distance(x, y, other.x, other.y);
    if (_d < _min_soil_dist) { _min_soil_dist = _d; other.nearest_soil = id; }
}
var soil_here = (nearest_soil != noone && instance_exists(nearest_soil))
              ? nearest_soil : soil_under_feet();

// Вводный диалог — один раз когда Макс впервые заходит в огород
if (!variable_global_exists("garden_intro_shown")) global.garden_intro_shown = false;
if (!global.garden_intro_shown && nearest_soil != noone) {
    global.garden_intro_shown = true;
    var _dlg_idx = asset_get_index("obj_ui_dialog_garden_intro");
    if (_dlg_idx != -1) {
        var _lyr = layer_get_id("Instances");
        if (_lyr == -1) _lyr = layer;
        instance_create_layer(0, 0, _lyr, _dlg_idx);
    }
}

// Диалог-задание посадки: когда Макс подходит к полю после кофе (День 2)
if (!variable_global_exists("plant_task_shown")) global.plant_task_shown = false;
if (!variable_global_exists("coffee_made"))      global.coffee_made      = false;
if (!global.plant_task_shown && global.coffee_made && nearest_soil != noone) {
    var _ptlyr = layer_get_id("Instances");
    if (_ptlyr == -1) _ptlyr = layer;
    var _ptdlg = asset_get_index("obj_ui_dialog_plant_task");
    if (_ptdlg != -1 && !instance_exists(_ptdlg)) {
        instance_create_layer(0, 0, _ptlyr, _ptdlg);
    }
}

// === ХОТБАР: листание и выбор семян ===
var _total = array_length(hotbar_items);
var _max_scroll = max(0, _total - hotbar_visible);

// Клавиши [ и ] — листание
if (keyboard_check_pressed(ord("["))) hotbar_scroll = max(0, hotbar_scroll - 1);
if (keyboard_check_pressed(ord("]"))) hotbar_scroll = min(_max_scroll, hotbar_scroll + 1);

// Колесо мыши — тоже листает
if (mouse_wheel_up())   hotbar_scroll = max(0, hotbar_scroll - 1);
if (mouse_wheel_down()) hotbar_scroll = min(_max_scroll, hotbar_scroll + 1);

// Клик по панели — стрелки и семена
if (mouse_check_button_pressed(mb_left)) {
    var _gx  = device_mouse_x_to_gui(0);
    var _gy  = device_mouse_y_to_gui(0);
    var _gw  = display_get_gui_width();
    var _gh  = display_get_gui_height();
    var _ph  = 48;
    var _sw  = 72;
    var _arw = 24;
    var _hd  = variable_global_exists("has_diary") && global.has_diary;
    var _doff = _hd ? _sw : 0;
    var _eff_vis   = min(hotbar_visible, _total - hotbar_scroll);
    var _can_left  = hotbar_scroll > 0;
    var _can_right = hotbar_scroll + hotbar_visible < _total;
    var _lpad = _can_left  ? _arw : 0;
    var _rpad = _can_right ? _arw : 0;
    var _pw  = _doff + _lpad + _sw * _eff_vis + _rpad;
    var _px  = (_gw - _pw) / 2;
    var _py  = _gh - _ph - 10;
    var _ix  = _px + _doff + _lpad;

    if (_gy >= _py && _gy <= _py + _ph) {
        // Стрелка влево
        if (_can_left && _gx >= _px + _doff && _gx < _px + _doff + _arw) {
            hotbar_scroll--;
        }
        // Стрелка вправо
        else if (_can_right && _gx >= _ix + _sw * _eff_vis && _gx < _ix + _sw * _eff_vis + _arw) {
            hotbar_scroll++;
        }
        // Слоты предметов
        else {
            var _clicked = false;
            for (var _i = 0; _i < _eff_vis; _i++) {
                var _idx = hotbar_scroll + _i;
                if (_idx >= _total) break;
                var _slot_x = _ix + _sw * _i;
                if (_gx >= _slot_x && _gx < _slot_x + _sw) {
                    var _e = hotbar_items[_idx];
                    if (_e.is_seed) {
                        selected_seed         = (selected_seed == _e.item) ? "" : _e.item;
                        selected_shovel       = false;
                        selected_watering_can = false;
                    } else if (_e.item == "shovel") {
                        selected_shovel       = !selected_shovel;
                        selected_seed         = "";
                        selected_watering_can = false;
                    } else if (_e.item == "watering_can") {
                        selected_watering_can = !selected_watering_can;
                        selected_seed         = "";
                        selected_shovel       = false;
                    } else {
                        selected_seed         = "";
                        selected_shovel       = false;
                        selected_watering_can = false;
                    }
                    _clicked = true;
                    break;
                }
            }
            if (!_clicked) selected_seed = "";
        }
    }
}

// действия на грядке (E / Space)
if ((keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_space)) && soil_here != noone) {
    if (selected_shovel && !soil_here.dug) {
        // Лопата: вскопать
        with (soil_here) dig_cell();
        if (variable_global_exists("tutorial_farm_step") && global.tutorial_farm_step == 2) {
            var _dug_count = 0;
            with (obj_soil) { if (dug) _dug_count++; }
            if (_dug_count >= 5) global.tutorial_farm_step = 3;
        }
    } else if (selected_watering_can && soil_here.dug) {
        // Лейка: полить
        var _was_watered = soil_here.watered;
        with (soil_here) water_cell();
        if (variable_global_exists("tutorial_farm_step") && global.tutorial_farm_step == 6) {
            var _all_w = true; var _has_dug = false;
            with (obj_soil) { if (dug) { _has_dug = true; if (!watered) { _all_w = false; break; } } }
            if (_all_w && _has_dug) {
                global.tutorial_farm_step = 7;
                if (instance_exists(obj_day_controller))
                    obj_day_controller.meggie_diary_timer = room_speed * 5; // 5 секунд
            }
        }
        if (soil_here.watered && !_was_watered) {
            var fx_layer = layer_get_id("layer_soil");
            if (fx_layer == -1) fx_layer = layer_get_id("Instances_3");
            if (fx_layer == -1) fx_layer = layer;
            instance_create_layer(soil_here.x, soil_here.y, fx_layer, obj_water_fx);
        }
    } else if (selected_seed != "" && soil_here.dug && !soil_here.has_seed) {
        // Семя: посадить в вскопанную грядку
        var _seed_type = "";
        var _seed_item = "";
        if (selected_seed == ITEM_SEED && inventory_get_amount(ITEM_SEED) > 0) {
            _seed_type = "carrot";
            _seed_item = ITEM_SEED;
        } else if (selected_seed == ITEM_POTATO_SEED && inventory_get_amount(ITEM_POTATO_SEED) > 0) {
            _seed_type = "potato";
            _seed_item = ITEM_POTATO_SEED;
        } else if (selected_seed == ITEM_STRAWBERRY_SEED && inventory_get_amount(ITEM_STRAWBERRY_SEED) > 0) {
            _seed_type = "strawberry";
            _seed_item = ITEM_STRAWBERRY_SEED;
        }
        if (_seed_type != "") {
            with (soil_here) plant_crop(_seed_type);
            inventory_remove(_seed_item, 1);
            if (variable_global_exists("tutorial_farm_step") && global.tutorial_farm_step == 4) {
                var _rem = inventory_get_amount(ITEM_SEED)
                         + inventory_get_amount(ITEM_POTATO_SEED)
                         + inventory_get_amount(ITEM_STRAWBERRY_SEED);
                if (_rem <= 0) global.tutorial_farm_step = 5;
            }
            var hud = instance_find(obj_ui_inventory, 0);
            if (hud != noone) with (hud) show_carrot_pop("-1");
        }
    }
}


// ---------- перемещение (с коллизиями) ----------
if (!place_meeting(x + move_x, y, obj_solid)) x += move_x;
if (!place_meeting(x, y + move_y, obj_solid)) y += move_y;

if (instance_exists(obj_kitten)) {
    var _kd = point_distance(x, y, obj_kitten.x, obj_kitten.y);
    if (_kd < 14 && _kd > 0) {
        var _kdir = point_direction(obj_kitten.x, obj_kitten.y, x, y);
        x = round(obj_kitten.x + lengthdir_x(14, _kdir));
        y = round(obj_kitten.y + lengthdir_y(14, _kdir));
    }
}

// ---------- idle спрайты ----------
if (state == "idle") {
    switch (direction_facing) {
        case "down":  sprite_index = spr_max_idle_up;    break;
        case "up":    sprite_index = spr_max_idle_down;  break;
        case "left":  sprite_index = spr_max_idle_left;  break;
        case "right": sprite_index = spr_max_idle_right; break;
    }
    image_speed = 0;
    image_index = 0;
}

// ---------- глубина (сортировка по подошве, как в Stardew Valley) ----------
depth = -bbox_bottom;
