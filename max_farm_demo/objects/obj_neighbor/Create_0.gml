// =====================
// NEIGHBOR (CREATE)
// =====================

// чтобы точно рисовалась
visible = true;

// пусть не проигрывает анимацию (если спрайт многокадровый)
image_speed = 0;

// сбрасываем blend на случай если что-то сломалось
image_blend = c_white;
image_alpha = 1;

// на будущее: готовность к диалогу
can_talk = true;

// === INTRO DIALOG ===
// Глобальный флаг: показывали ли уже приветственный диалог соседки
if (!variable_global_exists("intro_neighbor_done")) {
    global.intro_neighbor_done = false;
}

// Локальный флаг: прошёл ли intro для этого инстанса
intro_done = global.intro_neighbor_done;

// Флаг: соседка уходит после диалога
leaving = false;

// Подход: движется справа до точки встречи
approaching = false;
if (!global.intro_neighbor_done && room == rm_farm) {
    approaching = true;
}

// Соседка только на 1-й день, и только если intro ещё не было
var _day = instance_exists(obj_day_controller) ? obj_day_controller.day_index : 1;
if (global.intro_neighbor_done || _day >= 2) {
    instance_destroy();
    exit;
}
