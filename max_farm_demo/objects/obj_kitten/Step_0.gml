// ===== КОТИК — STEP =====

if (room != rm_farm && room != rm_house_inside) exit;

var _hour = instance_exists(obj_day_controller) ? obj_day_controller.hour : 6;
depth = -bbox_bottom;

// Инициализация переменной на случай старых сохранений
if (!variable_instance_exists(id, "kitten_room")) kitten_room = rm_farm;

// =================================================================
// ПЕРЕХОДЫ ПО ВРЕМЕНИ (работают независимо от того, где игрок)
// =================================================================

// 18:00 → идём к двери, потом телепортируемся в дом
if (kitten_room == rm_farm && _hour >= 18 && state != "going_home_door") {
    if (state == "wander" || state == "sleeping" || state == "walking_to_bed"
    ||  state == "sit_near" || state == "petting_react") {
        state = "going_home_door";
    }
}

// 6:00 → мгновенный телепорт на ферму (игрок в это время скорее всего спал)
if (kitten_room == rm_house_inside && _hour >= 6 && _hour < 18
&&  state == "sleeping_at_home") {
    x            = farm_return_x;
    y            = farm_return_y;
    kitten_room  = rm_farm;
    state        = "wander";
    sleep_timer  = 400 + irandom(400);
    wander_timer = 30;
    zzz_timer    = 0;
}

// =================================================================
// ВИДИМОСТЬ — скрываем котика когда он "в другой комнате"
// =================================================================

// Если кот логически в другой комнате — скрываем, но продолжаем двигать
// (иначе кот не дойдёт до двери когда Макс уже в доме)
var _wrong_room = (kitten_room != room);
if (_wrong_room) visible = false;

// На День 2 до прихода Мэгги — кот невидим (только на ферме)
var _fd = instance_exists(obj_day_controller) ? obj_day_controller.day_index : 1;
var _hide = (_fd >= 2
    && variable_global_exists("kitten_arrived")
    && !global.kitten_arrived
    && kitten_room == rm_farm
    && state != "follow"
    && state != "sit_near"
    && state != "going_home_door");
if (!_wrong_room) visible = !_hide;
if (_hide && !_wrong_room) exit; // прерываем только если кот виден но скрыт по логике дня

// =================================================================
// ВЗАИМОДЕЙСТВИЕ С МАКСОМ (только на ферме)
// =================================================================

if (heart_alpha > 0) heart_alpha = max(0, heart_alpha - 0.025);

if (kitten_room == rm_farm && instance_exists(obj_max)) {
    var _near = point_distance(x, y, obj_max.x, obj_max.y);
    if (_near < 36 && heart_alpha <= 0 && state != "petting_react") {
        heart_alpha = 1;
    }
    var _free = (state == "wander" || state == "sleeping" || state == "walking_to_bed" || state == "sit_near");
    if (_free && _near < 40 && keyboard_check_pressed(ord("E"))) {
        state     = "petting_react";
        pet_timer = 90;
        heart_alpha = 1;
    }
    // Мягкое столкновение
    var _cd = point_distance(x, y, obj_max.x, obj_max.y);
    if (_cd < 14 && _cd > 0) {
        var _push = point_direction(x, y, obj_max.x, obj_max.y);
        obj_max.x = round(x + lengthdir_x(14, _push));
        obj_max.y = round(y + lengthdir_y(14, _push));
    }
}

// =================================================================
// АВТОМАТ СОСТОЯНИЙ
// =================================================================

switch (state) {

    case "follow":
        if (follow_id == noone || !instance_exists(follow_id)) {
            state = "wander"; wander_timer = 60; break;
        }
        var _mdx  = follow_id.xprevious - follow_id.x;
        var _mdy  = follow_id.yprevious - follow_id.y;
        var _mlen = sqrt(_mdx*_mdx + _mdy*_mdy);
        var _ftx  = follow_id.x + ((_mlen > 0.1) ? (_mdx/_mlen)*34 : 0);
        var _fty  = follow_id.y + ((_mlen > 0.1) ? (_mdy/_mlen)*34 : 0);
        if (point_distance(x, y, _ftx, _fty) > 8) {
            var _fdir = point_direction(x, y, _ftx, _fty);
            x = round(x + lengthdir_x(walk_spd, _fdir));
            y = round(y + lengthdir_y(walk_spd, _fdir));
            image_xscale = (cos(degtorad(_fdir)) < 0) ? -1 : 1;
        }
        break;

    case "sit_near":
        if (sit_target_x < 0) { state = "wander"; break; }
        if (point_distance(x, y, sit_target_x, sit_target_y) > 6) {
            var _sdir = point_direction(x, y, sit_target_x, sit_target_y);
            x = round(x + lengthdir_x(walk_spd * 0.9, _sdir));
            y = round(y + lengthdir_y(walk_spd * 0.9, _sdir));
            image_xscale = (cos(degtorad(_sdir)) < 0) ? -1 : 1;
        }
        break;

    case "walk_to_max":
        if (!instance_exists(obj_max)) { state = "wander"; break; }
        if (point_distance(x, y, obj_max.x, obj_max.y) > 36) {
            var _mdir = point_direction(x, y, obj_max.x, obj_max.y);
            x = round(x + lengthdir_x(walk_spd, _mdir));
            y = round(y + lengthdir_y(walk_spd, _mdir));
            image_xscale = (cos(degtorad(_mdir)) < 0) ? -1 : 1;
        } else {
            heart_alpha = 1; state = "wander"; walk_spd = 0.8; wander_timer = 120;
        }
        break;

    case "wander":
        if (_hour < 18) {
            sleep_timer--;
            if (sleep_timer <= 0) { state = "walking_to_bed"; break; }
        }
        wander_timer--;
        if (wander_timer <= 0) {
            wander_x     = wander_x1 + irandom(wander_x2 - wander_x1);
            wander_y     = wander_y1 + irandom(wander_y2 - wander_y1);
            wander_timer = 120 + irandom(180);
        }
        if (point_distance(x, y, wander_x, wander_y) > 8) {
            var _target_dir = point_direction(x, y, wander_x, wander_y);
            var _diff = angle_difference(_target_dir, wander_dir);
            wander_dir += clamp(_diff, -4, 4);
            x = round(x + lengthdir_x(walk_spd, wander_dir));
            y = round(y + lengthdir_y(walk_spd, wander_dir));
            x = clamp(x, wander_x1, wander_x2);
            y = clamp(y, wander_y1, wander_y2);
            image_xscale = (cos(degtorad(wander_dir)) < 0) ? -1 : 1;
        }
        break;

    case "walking_to_bed":
        if (point_distance(x, y, bed_x, bed_y) > 4) {
            var _bdir = point_direction(x, y, bed_x, bed_y);
            x = round(x + lengthdir_x(walk_spd, _bdir));
            y = round(y + lengthdir_y(walk_spd, _bdir));
            image_xscale = (cos(degtorad(_bdir)) < 0) ? -1 : 1;
        } else {
            x = bed_x; y = bed_y;
            state = "sleeping"; zzz_timer = 0;
        }
        break;

    case "sleeping":
        zzz_timer++;
        if (zzz_timer > 600 + irandom(300)) {
            state = "wander"; sleep_timer = 400 + irandom(400); zzz_timer = 0;
        }
        break;

    case "petting_react":
        pet_timer--;
        if (pet_timer <= 0) { state = "wander"; wander_timer = 60; }
        break;

    // === УХОД ДОМОЙ ===

    case "going_home_door":
        // Идём к двери дома на ферме
        if (point_distance(x, y, farm_door_x, farm_door_y) > 10) {
            var _ghdir = point_direction(x, y, farm_door_x, farm_door_y);
            x = round(x + lengthdir_x(walk_spd * 1.3, _ghdir));
            y = round(y + lengthdir_y(walk_spd * 1.3, _ghdir));
            image_xscale = (cos(degtorad(_ghdir)) < 0) ? -1 : 1;
        } else {
            // Дошли до двери → телепортируемся на кровать в доме
            x           = house_bed_x;
            y           = house_bed_y;
            kitten_room = rm_house_inside;
            state       = "sleeping_at_home";
            zzz_timer   = 0;
        }
        break;

    case "sleeping_at_home":
        zzz_timer++;
        // Просыпается по таймеру в 6:00 (обработано выше, в секции переходов)
        break;
}

// =================================================================
// СПРАЙТ ПО СОСТОЯНИЮ
// =================================================================

switch (state) {
    case "follow":
    case "walk_to_max":
    case "walking_to_bed":
    case "wander":
    case "going_home_door":
        sprite_index = spr_kitten_walk_strip4;
        image_speed  = 0.2;
        break;
    case "sit_near":
    case "petting_react":
        sprite_index = spr_kitten_sit_strip4;
        image_speed  = 0.08;
        break;
    case "sleeping":
    case "sleeping_at_home":
        sprite_index = spr_kitten_sleep_strip4;
        image_speed  = 0.06;
        break;
}
