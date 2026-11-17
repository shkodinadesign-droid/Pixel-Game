// ===== ЛЕСНАЯ ТРОПА — ПРАВЫЙ КРАЙ ДЕРЕВНИ — переход шагом вперёд (right) =====
// Зона ног Макс и точка появления — см. scr_doors / tools/village/b33_doors.py
door_init(1570, 390, 1600, 442, "right", rm_forest_entrance, FOREST_SPAWN_X, FOREST_SPAWN_Y, function() {
    if (global.magic_map_taken) return true;
    dialog_seq_start([forest_page("max", ["Не хочу заблудиться.", "Сначала нужно узнать дорогу."])], "");
    return false;
});
