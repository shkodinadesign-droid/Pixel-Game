// ===== МЭГГИ У СВОЕГО ДОМА (STEP) =====
near_player = false;
if (!instance_exists(obj_max)) exit;
var _p  = instance_find(obj_max, 0);
var _fx = (_p.bbox_left + _p.bbox_right) * 0.5, _fy = _p.bbox_bottom;
near_player = point_distance(x + 16, y + 52, _fx, _fy) < 60;

// пока Макс рядом — Мэгги поворачивается к ней, иначе возится с цветами
if (near_player) sprite_index = (_fx < x + 16) ? spr_maggie_idle_left : spr_maggie_idle_right;
else             sprite_index = spr_maggie_idle_left;

if (!near_player || global.control_locked || !keyboard_check_pressed(ord("E"))) exit;

if (!global.maggie_sign_talk_done) {
    dialog_seq_start([
        forest_page("max",    ["Мэгги, привет! Только не смейся..."]),
        forest_page("max",    ["Пуддинг, карта, лес... И лягушонок.", "Он разговаривает. По-настоящему."]),
        forest_page("max",    ["Ты сейчас, наверное, скажешь,", "что мне всё приснилось."]),
        forest_page("maggie", ["А он пуддинг доел?"]),
        forest_page("max",    ["Да... Подожди.", "Почему ты спрашиваешь именно это?"]),
        forest_page("maggie", ["Значит, аппетит у него всё тот же."]),
        forest_page("max",    ["Он сказал спросить тебя", "про запертую дверь в пекарне."]),
        forest_page("maggie", ["За ней Соня хранила свои особенные рецепты.", "И записи о том, где находила ингредиенты."]),
        forest_page("max",    ["В лесу?"]),
        forest_page("maggie", ["В том числе. Она многое оттуда приносила."]),
        forest_page("maggie", ["Иногда я просила её сначала показать", "находку мне, а уже потом класть в пирог."]),
        forest_page("maggie", ["Только не жди, что я знаю всё.", "Кое-какие записи Соня даже мне не показывала."]),
        forest_page("maggie", ["Перед отъездом она убрала ключ", "в наш старый тайник."]),
        forest_page("maggie", ["И попросила подсказать дорогу,", "если ты сама придёшь спрашивать про комнату."]),
        forest_page("max",    ["Бабушка знала, что я приду?"]),
        forest_page("maggie", ["Надеялась, думаю. Но сначала хотела понять,", "станет ли тебе самой интересно."]),
        forest_page("max",    ["Могла бы просто оставить ключ."]),
        forest_page("maggie", ["Могла. Но твоя бабушка с детства", "любила всё прятать.", "А искать обычно приходилось мне."]),
        forest_page("maggie", ["Вот, погляди."])
    ], "maggie_show_photo");
} else if (!global.secret_cache_found) {
    dialog_seq_start([forest_page("maggie", ["Яблоня и камень у корней.", "Найдёшь - сама всё поймёшь."])], "");
} else if (!global.secret_room_opened) {
    dialog_seq_start([forest_page("maggie", ["Нашла ключ? Ну, иди открывай.", "А мне потом расскажешь, что там."])], "");
} else {
    dialog_seq_start([forest_page("maggie", ["Только не пробуй то, чего не знаешь.", "Соня бы мне этого не простила."])], "");
}
