// ===== МЭГГИ ДЕНЬ 2 — STEP =====
depth = -bbox_bottom;

// Мэгги активна только на ферме; в других комнатах прячемся
if (room != rm_farm) { visible = false; exit; }

switch (state) {

    case "waiting":
        // Ждём 15-20 сек ПОСЛЕ того как Макс закрыла утренний диалог
        if (instance_exists(obj_max) && wait_timer < 0) {
            var _morning_done = instance_exists(obj_day_controller)
                                ? !obj_day_controller.show_morning_dialog
                                : true;
            if (_morning_done) {
                wait_timer = 60 * 7; // ~7 секунд при 60fps
            }
        }
        if (wait_timer > 0) {
            wait_timer--;
            if (wait_timer == 0) {
                // Мэгги появляется
                visible = true;
                global.control_locked = true;
                if (instance_exists(obj_max)) {
                    obj_max.image_speed = 0;
                    obj_max.state = "idle";
                }
                sprite_index = spr_maggie_walk_down;
                image_speed  = 0.15;

                // Котик — ставим сразу в steady-state позицию (34px позади Мэгги по X)
                // Мэгги входит слева, поэтому "позади" = левее неё
                if (instance_exists(obj_kitten)) {
                    kitten_id = obj_kitten;
                } else {
                    var _lyr = layer_get_id("Instances");
                    if (_lyr == -1) _lyr = layer;
                    kitten_id = instance_create_layer(x - 34, y, _lyr, obj_kitten);
                }
                if (instance_exists(kitten_id)) {
                    kitten_id.x         = x - 34;
                    kitten_id.y         = y;
                    kitten_id.visible   = true;
                    kitten_id.follow_id = id;
                    kitten_id.state     = "follow";
                    kitten_id.walk_spd  = 1.5;
                }

                state = "walking_to_player";
            }
        }
        break;

    case "walking_to_player":
        if (instance_exists(obj_max)) {
            target_x = obj_max.x + 50;
            target_y = obj_max.y;

            var _dist = point_distance(x, y, target_x, target_y);

            if (_dist > 8) {
                var _dir = point_direction(x, y, target_x, target_y);
                x = round(x + lengthdir_x(move_speed, _dir));
                y = round(y + lengthdir_y(move_speed, _dir));

                if (_dir >= 45 && _dir < 135)       sprite_index = spr_maggie_walk_up;
                else if (_dir >= 135 && _dir < 225)  sprite_index = spr_maggie_walk_left;
                else if (_dir >= 225 && _dir < 315)  sprite_index = spr_maggie_walk_down;
                else                                  sprite_index = spr_magiie_walk_right;
                image_speed = 0.15;

                // Макс поворачивается навстречу
                if (_dist < 80 && instance_exists(obj_max)) {
                    obj_max.sprite_index     = spr_max_idle_right;
                    obj_max.direction_facing = "right";
                    obj_max.image_speed      = 0;
                    obj_max.image_index      = 0;
                    obj_max.state            = "idle";
                }
            } else {
                // Дошли — котик садится рядом с Мэгги
                state        = "talking";
                sprite_index = spr_maggie_idle_left;
                image_speed  = 0;
                if (instance_exists(obj_max)) {
                    obj_max.sprite_index     = spr_max_idle_right;
                    obj_max.direction_facing = "right";
                    obj_max.image_speed      = 0;
                }
                // Котик идёт сесть чуть позади и сбоку Мэгги
                if (instance_exists(kitten_id)) {
                    kitten_id.follow_id    = noone;
                    kitten_id.sit_target_x = x - 10;
                    kitten_id.sit_target_y = y - 40;
                    kitten_id.state        = "sit_near";
                }
                var _dlayer = layer_get_id("GUI");
                if (_dlayer == -1) _dlayer = layer_get_id("UI_hp");
                if (_dlayer == -1) _dlayer = layer_get_id("Instances_2");
                if (_dlayer == -1) _dlayer = layer;
                instance_create_layer(0, 0, _dlayer, obj_ui_dialog_maggie_kitten);
            }
        }
        break;

    case "talking":
        image_speed = 0;
        break;

    case "leaving":
        var _lx = -100;
        var _ld = point_distance(x, y, _lx, y);
        if (_ld > 4) {
            x = round(x + lengthdir_x(move_speed, point_direction(x, y, _lx, y)));
            sprite_index = spr_maggie_walk_left;
            image_speed  = 0.15;
        } else {
            // Мэгги ушла — котик идёт к Макс
            global.kitten_arrived = true;
            if (instance_exists(kitten_id) && instance_exists(obj_max)) {
                kitten_id.follow_id = noone;
                kitten_id.state     = "walk_to_max";
                kitten_id.walk_spd  = 1.2;
            }
            instance_destroy();
        }
        break;
}
