// ===== ЛЕС: ЛЯГУШОНОК У БОЛЬШОГО КАМНЯ (STEP) =====
near_player = false;
if (!instance_exists(obj_max)) exit;

var p = instance_find(obj_max, 0);
var _fx = (p.bbox_left + p.bbox_right) * 0.5;
var _fy = p.bbox_bottom;
near_player = point_distance(x + 16, y + 24, _fx, _fy) < 56;

if (!near_player || global.control_locked) exit;
if (!keyboard_check_pressed(ord("E"))) exit;

forest_mark_progress("forest_glade_found");

if (!global.frog_talk_done) {
    // Первая встреча: лягушонок оставил карту в благодарность за пуддинг
    dialog_seq_start([
        forest_page("max",  ["Так это ты оставил карту?"]),
        forest_page("frog", ["А ты оставила пуддинг.", "По-моему, честный обмен."]),
        forest_page("max",  ["И что здесь такого особенного?"]),
        forest_page("frog", ["Это только начало тропы.", "Дальше лучше идти не одной."]),
        forest_page("max",  ["Ой... на камне какой-то знак!", "Надо рассказать Джастину о тебе и об этом знаке."])
    ], "frog_talk");
} else {
    // Повторная встреча — короткая реплика, первая сцена не повторяется
    dialog_seq_start([
        forest_page("frog", ["Знак никуда не денется.", "Расскажи о нём Джастину, а я посторожу камень."])
    ], "");
}
