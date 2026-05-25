// ===== UI BAKERY STEP =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var click_now   = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev = click_now;

// --- Анимация питья (если сварили кофейный рецепт) ---
if (drink_phase) {
    drink_timer--;
    if (drink_timer <= 0) {
        if (instance_exists(obj_max)) {
            obj_max.sprite_index = spr_max_idle_up;
            obj_max.image_speed  = 0;
            obj_max.image_index  = 0;
        }
        var _lyr = layer_get_id("GUI");
        if (_lyr == -1) _lyr = layer_get_id("Instances_2");
        if (_lyr == -1) _lyr = layer;
        instance_create_layer(0, 0, _lyr, obj_ui_dialog_coffee_done);
        instance_destroy();
        exit;
    }
    exit;
}

// --- Анимация готовки ---
if (cook_anim > 0) {
    cook_anim--;
    if (cook_anim == 0 && !cook_done) {
        cook_done       = true;
        cook_done_timer = 80; // ~1.3 сек показываем "Готово!", потом авто-закрытие
    }
}

// --- Таймер авто-закрытия после "Готово!" ---
if (cook_done && cook_done_timer > 0) {
    cook_done_timer--;
    if (cook_done_timer == 0) {
        var _r_done = global.recipes[selected_recipe];
        if (_r_done.id == "latte" || _r_done.id == "americano") {
            // Кофейный рецепт — анимация питья
            if (!variable_global_exists("coffee_made")) global.coffee_made = false;
            global.coffee_made = true;
            drink_phase = true;
            drink_timer = 120;
            if (instance_exists(obj_max)) {
                obj_max.sprite_index = spr_max_drink_strip4;
                obj_max.image_speed  = 0.05;
                obj_max.image_index  = 0;
            }
        } else {
            var _dialog_obj = (_r_done.id == "carrot_muffin" || _r_done.id == "apple_bun")
                ? obj_ui_dialog_max_muffin
                : obj_ui_dialog_max_pie;
            instance_create_layer(0, 0, "GUI", _dialog_obj);
            instance_destroy();
            exit;
        }
    }
    exit; // ввод заблокирован пока идёт таймер
}

// --- Обновляем полёт ингредиентов ---
for (var i = array_length(fly_anims) - 1; i >= 0; i--) {
    fly_anims[i].t += 0.055;
    if (fly_anims[i].t >= 1) {
        array_push(bowl_items, fly_anims[i].item_id);
        // Сплеш при попадании в миску
        array_push(splash_anims, {
            x:       bowl_cx,
            y:       bowl_cy + 10,
            item_id: fly_anims[i].item_id,
            t:       0
        });
        array_delete(fly_anims, i, 1);
    }
}

// --- Обновляем сплеши ---
for (var i = array_length(splash_anims) - 1; i >= 0; i--) {
    splash_anims[i].t += 0.07;
    if (splash_anims[i].t >= 1) array_delete(splash_anims, i, 1);
}

// --- Переключение рецепта (стрелки) ---
if (cook_anim == 0 && !cook_done && click_press) {
    var _arr_w = 26;
    var _nav_y = tab_y;
    var _nav_h = tab_h + 4;
    if (my >= _nav_y && my <= _nav_y + _nav_h) {
        var _count = array_length(global.recipes);
        if (mx >= right_x && mx <= right_x + _arr_w) {
            var _prev = (selected_recipe - 1 + _count) mod _count;
            if (_prev != selected_recipe) {
                selected_recipe = _prev;
                bowl_items   = [];
                fly_anims    = [];
                splash_anims = [];
            }
        }
        if (mx >= right_x + right_w - _arr_w && mx <= right_x + right_w) {
            var _next = (selected_recipe + 1) mod _count;
            if (_next != selected_recipe) {
                selected_recipe = _next;
                bowl_items   = [];
                fly_anims    = [];
                splash_anims = [];
            }
        }
    }
}

// --- Закрытие (только пока не началась готовка) ---
if (cook_anim == 0 && !cook_done) {
    if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("E"))) {
        global.control_locked = false;
        instance_destroy();
        exit;
    }

    if (click_press) {
        var _out = (mx < panel_x || mx > panel_x + panel_w ||
                    my < panel_y || my > panel_y + panel_h);
        if (_out) {
            global.control_locked = false;
            instance_destroy();
            exit;
        }
    }
}

// --- Hover и клики по ячейкам ---
hover_cell = -1;
if (cook_anim == 0 && !cook_done) {
    var _r = global.recipes[selected_recipe];
    var _ing_count = array_length(_r.ingredients);

    for (var i = 0; i < _ing_count; i++) {
        var _col = i mod cells_cols;
        var _row = i div cells_cols;
        var _cx  = right_x + _col * (cell_size + cell_gap);
        var _cy  = cell_area_y + _row * (cell_size + cell_gap);

        if (mx >= _cx && mx <= _cx + cell_size &&
            my >= _cy && my <= _cy + cell_size) {
            hover_cell = i;

            if (click_press) {
                var _item_id = _r.ingredients[i].item;
                var _needed  = _r.ingredients[i].amount;

                // Уже в миске?
                var _in_bowl = false;
                for (var j = 0; j < array_length(bowl_items); j++) {
                    if (bowl_items[j] == _item_id) { _in_bowl = true; break; }
                }
                // Уже летит?
                var _in_fly = false;
                for (var j = 0; j < array_length(fly_anims); j++) {
                    if (fly_anims[j].item_id == _item_id) { _in_fly = true; break; }
                }

                if (!_in_bowl && !_in_fly && inventory_get_amount(_item_id) >= _needed) {
                    array_push(fly_anims, {
                        sx:      _cx + cell_size / 2,
                        sy:      _cy + cell_size / 2,
                        t:       0,
                        item_id: _item_id
                    });
                }
            }
        }
    }

    // --- Кнопка Готовить ---
    var _all_added = true;
    for (var i = 0; i < _ing_count; i++) {
        var _id   = _r.ingredients[i].item;
        var _found = false;
        for (var j = 0; j < array_length(bowl_items); j++) {
            if (bowl_items[j] == _id) { _found = true; break; }
        }
        if (!_found) { _all_added = false; break; }
    }

    if (_all_added && click_press) {
        if (mx >= btn_x && mx <= btn_x + btn_w &&
            my >= btn_y && my <= btn_y + btn_h) {
            cook_anim = 90;
        }
    }
}
