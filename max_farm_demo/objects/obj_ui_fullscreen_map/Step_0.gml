// ===== КАРТА ЛЯГУШОНКА (STEP) =====

anim_t++;

if (closing) {
    if (owns_lock) global.control_locked = false;
    var _first = !global.map_hotkey_hint_shown;
    global.map_hotkey_hint_shown = true;
    instance_destroy();
    // Первый раз подсказываем, что карту можно открыть снова
    if (_first) {
        dialog_seq_start([forest_page("max", ["Теперь понятно, куда идти!", "Карту можно открыть снова клавишей [M]."])], "");
    }
    exit;
}

if (open_delay > 0) { open_delay--; exit; }

if (keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("M"))) {
    closing = true;
    visible = false;
}
