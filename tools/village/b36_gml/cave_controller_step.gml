// ===== СТАРАЯ ПЕЩЕРА (STEP) =====
flick += 1;
if (first_enter) {
    if (enter_wait > 0) { enter_wait -= 1; exit; }
    if (global.control_locked) exit;
    first_enter = false;
    global.cave_entered   = true;
    global.diary_has_new  = true;
    global.diary_was_read = false;
    forest_on_dialog_finished("cave_first_enter");
}
