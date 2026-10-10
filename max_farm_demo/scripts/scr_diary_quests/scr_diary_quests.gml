// ===== ДНЕВНИК: ДАННЫЕ И РАСКЛАДКА ВКЛАДКИ "ЗАДАНИЯ" =====

/// @func diary_get_quest_list()
/// @desc Собирает текущий список заданий на основе глобальных флагов прогресса.
/// Каждое задание: { id, text, desc, done, category ("main"/"side") }
function diary_get_quest_list() {
    var _list = [];

    array_push(_list, {
        id: "plant_seeds",
        text: "Посадить зерна",
        desc: "Бабуля просила посадить зерна.\n\nДля этого надо взять зерна в сарае, раскопать землю в огороде, посадить и полить.",
        done: variable_global_exists("grain_planted") && global.grain_planted,
        category: "main"
    });

    var _justin_done = variable_global_exists("justin_bakery_intro_done") && global.justin_bakery_intro_done;
    array_push(_list, {
        id: "bakery_intro",
        text: "Изучить пекарню",
        desc: "Нужно осмотреться и узнать, что где лежит - рабочий стол, холодильник, ингредиенты.",
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
            desc: "Бабуля просила заглянуть в пекарню и проверить, всё ли в порядке.",
            done: variable_global_exists("bakery_check_done") && global.bakery_check_done,
            category: "side"
        });
    }

    // --- Эпизод "Пуддинг -> лягушонок -> карта" ---
    var _pud_ready  = variable_global_exists("pudding_ready")   && global.pudding_ready;
    var _frog_done  = variable_global_exists("frog_night_done") && global.frog_night_done;
    var _map_taken  = variable_global_exists("magic_map_taken") && global.magic_map_taken;
    if (variable_global_exists("pudding_quest") && global.pudding_quest) {
        array_push(_list, {
            id: "pudding_cook",
            text: "Приготовить пуддинг",
            desc: "Бабуля прислала рецепт пуддинга.\n\nНужны молоко, яйцо, сахар и яблоко.\n\nПриготовить можно на рабочем столе в пекарне.",
            done: _pud_ready,
            category: "main"
        });
    }
    if (_pud_ready) {
        array_push(_list, {
            id: "pudding_leave",
            text: "Оставить пуддинг в огороде",
            desc: "Бабуля просила оставить немного пуддинга в огороде, а самой лечь спать.\n\nУтром меня ждёт сюрприз!",
            done: (variable_global_exists("pudding_on_porch") && global.pudding_on_porch) || _frog_done,
            category: "main"
        });
    }
    if (_frog_done) {
        array_push(_list, {
            id: "find_map",
            text: "Проверить огород",
            desc: "Пуддинга на месте нет... Вместо него в огороде что-то лежит.",
            done: _map_taken,
            category: "main"
        });
    }
    // --- Лесной эпизод: карта -> лесная тропа -> большой камень -> лягушонок (scr_forest_episode) ---
    // Появляется и тогда, когда карта была взята до этого обновления: всё считается от magic_map_taken.
    if (_map_taken) {
        forest_episode_init();
        var _forest_desc;
        if (global.forest_found) {
            _forest_desc = "Я на лесной тропе.\n\nНа развилке тропа ведёт вверх, в тупик, и направо - к большому камню с крестиком.\n\nКарта открывается клавишей [M].";
        } else {
            _forest_desc = "На карте лягушонка отмечен крестик у большого камня в лесу.\n\nДорога: ферма -> деревня (направо) -> указатель \"Лесная тропа\" у правого края деревни.\n\nКарта открывается клавишей [M].";
        }
        array_push(_list, {
            id: "forest_find_stone",
            text: "Найти место с крестиком",
            desc: _forest_desc,
            done: global.forest_glade_found,
            category: "main"
        });
        if (global.forest_glade_found) {
            array_push(_list, {
                id: "forest_frog_talk",
                text: "Поговорить с лягушонком",
                desc: "У большого камня сидит тот самый лягушонок!\n\nНадо узнать, зачем он оставил мне карту.",
                done: global.frog_talk_done,
                category: "main"
            });
        }
        if (global.frog_talk_done) {
            array_push(_list, {
                id: "forest_tell_justin",
                text: "Рассказать Джастину о лягушонке",
                desc: "Лягушонок оставил карту в благодарность за пуддинг и показал мне место у большого камня.\n\nНа камне появился странный светящийся знак.\n\nЛягушонок сказал, что дальше лучше идти не одной. Надо рассказать обо всём Джастину.",
                done: false,
                category: "main"
            });
        }
    }

    if (variable_global_exists("ivan_quest_started") && global.ivan_quest_started) {
        array_push(_list, {
            id: "ivan_carrots",
            text: "Морковь для Ивана",
            desc: "Иван из мясной лавки готовит рагу к открытию, и ему не хватает моркови.\n\nНужно отнести ему 5 морковок в деревню - он заплатит 25 монет.",
            done: variable_global_exists("ivan_quest_done") && global.ivan_quest_done,
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
