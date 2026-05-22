// =====================
// NEIGHBOR (ALARM 0)
// =====================
// Показываем приветственный диалог при старте игры

if (!intro_done && !global.intro_neighbor_done) {
    intro_done = true;
    global.intro_neighbor_done = true;

    // Блокируем управление
    if (!variable_global_exists("control_locked")) global.control_locked = false;
    global.control_locked = true;

    // Создаём диалоговое окно соседки
    var _lyr = layer_get_id("letter");
    if (_lyr == -1) _lyr = layer;
    instance_create_layer(0, 0, _lyr, obj_ui_letter_neighbor);
}
