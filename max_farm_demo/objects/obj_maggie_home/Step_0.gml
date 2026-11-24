// ===== МЭГГИ ДОМА (STEP) =====
near_player = false;
if (!instance_exists(obj_max)) exit;
var _p  = instance_find(obj_max, 0);
var _fx = (_p.bbox_left + _p.bbox_right) * 0.5, _fy = _p.bbox_bottom;
near_player = point_distance(x + 20, y + 30, _fx, _fy) < 70;

if (global.control_locked) exit;

// Разговор о тайном знаке. _greet — с приветствием (первый вход), иначе сразу к делу.
// Конец: фотография (maggie_show_photo) -> «Посмотри, что лежит у корней» -> maggie_sign_talk_done.
var _talk = function(_greet) {
    var _pages = [];
    if (_greet) {
        array_push(_pages,
            forest_page("maggie", ["Макс! Заходи, заходи.", "Чайник только что вскипел."]),
            forest_page("max",    ["Мэгги, привет. Прости, что без", "предупреждения..."]),
            forest_page("maggie", ["Садись. По глазам вижу -", "у тебя какой-то вопрос."]));
    }
    array_push(_pages,
        forest_page("max",    ["Да. Только не смейся..."]),
        forest_page("max",    ["Пуддинг, карта, лес... И лягушонок.", "Он разговаривает. По-настоящему."]),
        forest_page("max",    ["Ты сейчас, наверное, скажешь,", "что мне всё приснилось."]),
        forest_page("maggie", ["А он пуддинг доел?"]),
        forest_page("max",    ["Да... Подожди.", "Почему ты спрашиваешь именно это?"]),
        forest_page("maggie", ["Значит, аппетит у него всё тот же."]),
        forest_page("max",    ["Он показал мне знак - спираль с лучами.", "Сказал, бабушка знала, что он значит."]));
    // Знак на двери пекарни: если Макс его уже видела — говорит сама, иначе подсказывает Мэгги
    if (global.door_sign_found) {
        array_push(_pages, forest_page("max", ["Такой же вырезан на запертой двери", "в пекарне. Что за ней?"]));
    } else {
        array_push(_pages, forest_page("maggie", ["Такой же вырезан на запертой двери", "в пекарне. Ты разве не замечала?"]));
    }
    array_push(_pages,
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
        forest_page("maggie", ["Вот, погляди."]));
    dialog_seq_start(_pages, "maggie_show_photo");
};

// Пришла спросить про тайный знак — Мэгги заговаривает сама, как только Макс вошла (один раз)
if (global.frog_talk_done && !global.maggie_sign_talk_done && !global.maggie_home_greeted) {
    if (greet_wait > 0) { greet_wait -= 1; exit; }
    global.maggie_home_greeted = true;
    _talk(true);
    exit;
}

if (!near_player || !keyboard_check_pressed(ord("E"))) exit;

if (!global.frog_talk_done) {
    dialog_seq_start([forest_page("maggie", ["Заходи, Макс. Чаю налить?", "Он с мятой, из моего огорода."])], "");
} else if (!global.maggie_sign_talk_done) {
    _talk(false);   // разговор прервался (например, вышла до фотографии) — начать с рассказа Макс
} else if (!global.secret_cache_found) {
    dialog_seq_start([forest_page("maggie", ["Яблоня и камень у корней.", "Найдёшь - сама всё поймёшь."])], "");
} else if (!global.secret_room_opened) {
    dialog_seq_start([forest_page("maggie", ["Нашла ключ? Ну, иди открывай.", "А мне потом расскажешь, что там."])], "");
} else {
    dialog_seq_start([forest_page("maggie", ["Только не пробуй то, чего не знаешь.", "Соня бы мне этого не простила."])], "");
}
