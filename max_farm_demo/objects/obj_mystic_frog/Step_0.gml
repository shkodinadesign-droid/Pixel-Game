// ===== ЛЯГУШОНОК В ТАЙНОМ ЛЕСУ (STEP) =====
if (state == "gone" || !instance_exists(obj_max)) exit;
var _p = instance_find(obj_max, 0);
var _fx = (_p.bbox_left + _p.bbox_right) * 0.5, _fy = _p.bbox_bottom;
depth = -(y + 32);
switch (state) {
    case "hidden":
        if (_fx > TRIGGER_X && !global.control_locked) {
            state = "run"; t = 0;
            global.control_locked = true;           // Макс останавливается — к ней кто-то бежит
        }
        break;
    case "run":                                       // прыжками к Макс
        t += 1;
        alpha = min(1, alpha + 0.08);
        var _tx = _fx + ((x + 16 < _fx) ? -44 : 28), _ty = _fy - 30;
        var _d = point_distance(x, y, _tx, _ty);
        if (abs(_ty - y) > abs(_tx - x)) sprite_index = (_ty > y) ? spr_frog_walk_down : spr_frog_walk_up;
        else sprite_index = (_tx < x) ? spr_frog_walk_side_left : spr_frog_walk_side_right;
        if (_d > 3) { var _dir = point_direction(x, y, _tx, _ty); x += lengthdir_x(min(3.2, _d), _dir); y += lengthdir_y(min(3.2, _d), _dir); }
        else {
            sprite_index = spr_frog_happy; state = "talk";      // радостно: «Макс! Подожди!»
            global.control_locked = false;
            dialog_seq_start([
                forest_page("frog", ["Макс! Подожди! Уф...", "Ну как? Есть успехи с мечом?"]),
                forest_page("max",  ["Бабушкина тетрадь привела меня к Джо.", "Они с бабушкой ходили к пещере -", "она в конце этого леса."]),
                forest_page("max",  ["Там хранитель меча.", "И говорят, какие-то испытания."]),
                forest_page("frog", ["Испытания... Звучит серьёзно."]),
                forest_page("frog", ["Тогда держи. Волшебный сироп.", "Капля - и сил прибавится."]),
                forest_page("max",  ["(пробует)", "Ой... Сладкий. И внутри так тепло."])
            ], "frog_syrup");
        }
        break;
    case "syrup":                                     // сердечка появляются над Макс
        t += 1;
        sprite_index = spr_frog_love;
        if (t == 90) {
            state = "talk2"; sprite_index = spr_frog_wave;      // машет: «Удачи, Макс!»
            dialog_seq_start([
                forest_page("frog", ["Вот. Теперь ты крепче.", "Удачи, Макс! Я буду держать лапки."]),
                forest_page("max",  ["Спасибо тебе!", "Я вернусь и всё-всё расскажу."])
            ], "frog_syrup_bye");
        }
        break;
    case "leave":                                     // обратно в кусты
        t += 1;
        sprite_index = (home_x < x) ? spr_frog_walk_side_left : spr_frog_walk_side_right;
        var _d2 = point_distance(x, y, home_x, home_y);
        if (_d2 > 3) { var _dir2 = point_direction(x, y, home_x, home_y); x += lengthdir_x(3.2, _dir2); y += lengthdir_y(3.2, _dir2); }
        if (_d2 < 40 || t > 200) alpha = max(0, alpha - 0.05);
        if (alpha <= 0) { state = "gone"; visible = false; }
        break;
}
