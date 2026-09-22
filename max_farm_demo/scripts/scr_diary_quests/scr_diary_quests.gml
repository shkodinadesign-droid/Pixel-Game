// ===== ДНЕВНИК: ДАННЫЕ И РАСКЛАДКА ВКЛАДКИ "ЗАДАНИЯ" =====

/// @func diary_get_quest_list()
/// @desc Собирает текущий список заданий на основе глобальных флагов прогресса.
/// Каждое задание: { id, text, desc, done, category ("main"/"side") }
function diary_get_quest_list() {
    var _list = [];

    array_push(_list, {
        id: "plant_seeds",
        text: "Посадить зерна",
        desc: "Бабуля доверила мне посадить зерна. Их я могу взять в сарае.\n\nМне нужно вскопать грядку далее посадить и полить.",
        done: variable_global_exists("grain_planted") && global.grain_planted,
        category: "main"
    });

    var _justin_done = variable_global_exists("justin_bakery_intro_done") && global.justin_bakery_intro_done;
    array_push(_list, {
        id: "bakery_intro",
        text: "Изучить пекарню",
        desc: "Джастин показал мне пекарню.\n\nНужно осмотреться и узнать, что где лежит - рабочий стол, холодильник, ингредиенты.",
        done: _justin_done,
        category: "main"
    });

    if (_justin_done) {
        array_push(_list, {
            id: "potato_pie",
            text: "Приготовить картофельный пирог",
            desc: "Любимый пирог Джастина.\n\nНужны картофель, молоко, яйцо, мука и дрожжи.\n\nПриготовить его можно на рабочем столе в пекарне.",
            done: variable_global_exists("potato_pie_done") && global.potato_pie_done,
            category: "main"
        });
    }

    if (_justin_done && variable_global_exists("coffee_letter_read") && global.coffee_letter_read) {
        array_push(_list, {
            id: "coffee",
            text: "Приготовить себе кофе",
            desc: "Бабушка прислала письмо про кофе.\n\nНужно сварить себе чашечку - зёрна, молоко и сахар найдутся на кухне.",
            done: variable_global_exists("coffee_made") && global.coffee_made,
            category: "main"
        });
    }

    if (_justin_done && variable_global_exists("plant_quest_started") && global.plant_quest_started) {
        array_push(_list, {
            id: "plant_quest",
            text: "Посади клубнику и картофель",
            desc: "На грядках ещё есть место.\n\nПора посадить клубнику и картофель - скоро будет новый урожай.",
            done: variable_global_exists("plant_quest_done") && global.plant_quest_done,
            category: "main"
        });
    }

    if (variable_global_exists("fruit_quest_started") && global.fruit_quest_started) {
        array_push(_list, {
            id: "fruit_quest",
            text: "Собери яблоки и груши с деревьев",
            desc: "В саду поспели яблоки и груши.\n\nНужно собрать урожай с деревьев, пока он не осыпался.",
            done: variable_global_exists("fruit_quest_done") && global.fruit_quest_done,
            category: "side"
        });
    }

    if (variable_global_exists("bakery_check_started") && global.bakery_check_started) {
        array_push(_list, {
            id: "bakery_check",
            text: "Проверь пекарню",
            desc: "Джастин просил заглянуть в пекарню и проверить, всё ли в порядке.",
            done: variable_global_exists("bakery_check_done") && global.bakery_check_done,
            category: "side"
        });
    }

    if (variable_global_exists("secret_quest_started") && global.secret_quest_started) {
        var _all_done =
            (variable_global_exists("three_pies_done")       && global.three_pies_done) &&
            (variable_global_exists("all_coffees_done")      && global.all_coffees_done) &&
            (variable_global_exists("pizza_recipe_done")     && global.pizza_recipe_done) &&
            (variable_global_exists("helped_villagers_done") && global.helped_villagers_done) &&
            (variable_global_exists("pear_jam_done")         && global.pear_jam_done);

        array_push(_list, {
            id: "secret_main",
            text: "Узнать где ключ от тайной двери",
            desc: "Где-то в доме бабушки спрятан ключ от загадочной двери.\n\nЧтобы его найти, нужно:\n- испечь три вида пирогов\n- сварить все виды кофе\n- найти рецепт пиццы бабушки\n- помочь жителям деревни\n- приготовить грушевое варенье",
            done: _all_done,
            category: "side"
        });
    }

    return _list;
}

/// @func diary_quest_is_read(_id)
function diary_quest_is_read(_id) {
    if (!variable_global_exists("quests_read")) global.quests_read = ds_map_create();
    return ds_map_exists(global.quests_read, _id) && ds_map_find_value(global.quests_read, _id);
}

/// @func diary_quest_mark_read(_id)
function diary_quest_mark_read(_id) {
    if (!variable_global_exists("quests_read")) global.quests_read = ds_map_create();
    ds_map_set(global.quests_read, _id, true);
}

/// @func diary_quest_build_rows(_content_x, _content_y, _bs)
/// @desc Строит плоский список строк (заголовки секций + задания) с координатами Y
/// для вкладки "Задания": Основные -> Дополнительные -> Выполненные.
/// Каждая строка: { type:"header"/"quest", text, q, y, h }
function diary_quest_build_rows(_content_x, _content_y, _bs) {
    var _list = diary_get_quest_list();

    var _main = [];
    var _side = [];
    var _done = [];

    for (var i = 0; i < array_length(_list); i++) {
        var _q = _list[i];
        if (_q.done) {
            array_push(_done, _q);
        } else if (_q.category == "main") {
            array_push(_main, _q);
        } else {
            array_push(_side, _q);
        }
    }

    var _rows = [];
    var _rh     = round(20 * _bs);
    var _hh     = round(16 * _bs);
    var _gap    = round(8  * _bs);
    var _y      = _content_y;

    var _groups = [
        ["Основные",       _main],
        ["Дополнительные", _side],
        ["Выполненные",    _done],
    ];

    for (var g = 0; g < array_length(_groups); g++) {
        var _gname  = _groups[g][0];
        var _gitems = _groups[g][1];
        if (array_length(_gitems) == 0) continue;

        array_push(_rows, {type: "header", text: _gname, q: undefined, y: _y, h: _hh});
        _y += _hh;

        for (var j = 0; j < array_length(_gitems); j++) {
            array_push(_rows, {type: "quest", text: _gitems[j].text, q: _gitems[j], y: _y, h: _rh});
            _y += _rh;
        }
        _y += _gap;
    }

    return _rows;
}
