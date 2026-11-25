// ===== СТОЛ С ЗЕЛЁНОЙ ТЕТРАДЬЮ (STEP) =====
near_player = false;
if (!instance_exists(obj_max)) exit;
var _p = instance_find(obj_max, 0);
near_player = point_distance(x, y - 4, (_p.bbox_left + _p.bbox_right) * 0.5, _p.bbox_bottom) < 56;
if (global.control_locked) exit;

// Первый вход: Макс оглядывается
if (!global.secret_room_entered) {
    if (look_wait > 0) { look_wait -= 1; exit; }
    global.secret_room_entered = true;
    dialog_seq_start([
        forest_page("max", ["Ничего себе...", "Это и есть бабушкина тайная комната?"]),
        forest_page("max", ["Маленькая рабочая комната...", "Тетради, засушенные растения,", "баночки с выцветшими этикетками."]),
        forest_page("max", ["Тут что-то растёт прямо в горшках.", "А тут - котелок, как у настоящей ведьмы."]),
        forest_page("max", ["И рисунки... Это лесные существа?"]),
        forest_page("max", ["Бабушка писала начать с зелёной тетради.", "Вот она, на столе."])
    ], "");
    exit;
}

if (near_player && keyboard_check_pressed(ord("E"))) forest_on_dialog_finished("secret_room_open");
