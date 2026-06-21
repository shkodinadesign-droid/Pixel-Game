// =====================================================
// СИСТЕМА ХРАНЕНИЯ - КАТЕГОРИИ И ПРЕДМЕТЫ
// =====================================================

/// @func storage_init()
/// @desc Инициализация системы хранения (вызывать в начале игры)
function storage_init() {
    // === КАТЕГОРИИ ===
    global.storage_categories = [
        "vegetables",  // Овощи
        "dairy",       // Молочные продукты
        "eggs",        // Яйца
        "fruits",      // Фрукты
        "grains",      // Зерновые
        "honey"        // Мёд
    ];

    // === НАЗВАНИЯ КАТЕГОРИЙ (для UI) ===
    global.category_names = ds_map_create();
    ds_map_add(global.category_names, "vegetables", "Овощи");
    ds_map_add(global.category_names, "dairy", "Молочные");
    ds_map_add(global.category_names, "eggs", "Яйца");
    ds_map_add(global.category_names, "fruits", "Фрукты");
    ds_map_add(global.category_names, "grains", "Зерновые");
    ds_map_add(global.category_names, "honey", "Мёд");

    // === БАЗА ДАННЫХ ПРЕДМЕТОВ ===
    // Каждый предмет: { name, category, sell_price, icon }
    global.item_database = ds_map_create();

    // --- ОВОЩИ ---
    ds_map_add(global.item_database, "carrot", {
        name: "Морковь",
        category: "vegetables",
        grow_days: 3,
        sell_price: 5
    });
    ds_map_add(global.item_database, "potato", {
        name: "Картофель",
        category: "vegetables",
        grow_days: 4,
        sell_price: 5,
        icon: spr_potato_icon,
        icon_scale: 0.75
    });
    ds_map_add(global.item_database, "potato_seed", {
        name: "Семена картофеля",
        category: "vegetables"
    });
    ds_map_add(global.item_database, "tomato_seed", {
        name: "Семена томатов",
        category: "vegetables"
    });
    ds_map_add(global.item_database, "pumpkin_seed", {
        name: "Семена тыквы",
        category: "vegetables"
    });
    ds_map_add(global.item_database, "sunflower_seed", {
        name: "Семена подсолнуха",
        category: "vegetables"
    });
    ds_map_add(global.item_database, "tomato", {
        name: "Помидор",
        category: "vegetables",
        grow_days: 5
    });
    ds_map_add(global.item_database, "cabbage", {
        name: "Капуста",
        category: "vegetables",
        grow_days: 6
    });
    ds_map_add(global.item_database, "onion", {
        name: "Лук",
        category: "vegetables",
        grow_days: 3
    });

    // --- МОЛОЧНЫЕ ---
    ds_map_add(global.item_database, "milk", {
        name: "Молоко",
        category: "dairy",
        source: "cow",
        icon: spr_milk_icon
    });
    ds_map_add(global.item_database, "cheese", {
        name: "Сыр",
        category: "dairy",
        crafted: true
    });
    ds_map_add(global.item_database, "butter", {
        name: "Масло",
        category: "dairy",
        crafted: true
    });

    // --- ЯЙЦА ---
    ds_map_add(global.item_database, "egg", {
        name: "Яйцо",
        category: "eggs",
        source: "chicken",
        icon: spr_egg_icon,
        icon_scale: 0.75
    });
    ds_map_add(global.item_database, "golden_egg", {
        name: "Золотое яйцо",
        category: "eggs",
        rare: true
    });

    // --- ФРУКТЫ ---
    ds_map_add(global.item_database, "apple_sapling", {
        name: "Саженец яблони",
        category: "fruits"
    });
    ds_map_add(global.item_database, "pear_sapling", {
        name: "Саженец груши",
        category: "fruits"
    });
    ds_map_add(global.item_database, "apple", {
        name: "Яблоко",
        category: "fruits",
        source: "tree",
        sell_price: 2,
        icon: asset_get_index("spr_apple_icon")
    });
    ds_map_add(global.item_database, "pear", {
        name: "Груша",
        category: "fruits",
        source: "tree",
        sell_price: 2,
        icon: asset_get_index("spr_pear_icon")
    });
    ds_map_add(global.item_database, "peach", {
        name: "Персик",
        category: "fruits",
        source: "tree",
        icon: asset_get_index("spr_peach_icon")
    });
    ds_map_add(global.item_database, "strawberry", {
        name: "Клубника",
        category: "fruits",
        grow_days: 4,
        sell_price: 5
    });
    ds_map_add(global.item_database, "strawberry_seed", {
        name: "Семена клубники",
        category: "fruits"
    });

    // --- ЗЕРНОВЫЕ ---
    ds_map_add(global.item_database, "wheat", {
        name: "Пшеница",
        category: "grains",
        grow_days: 4
    });
    ds_map_add(global.item_database, "corn", {
        name: "Кукуруза",
        category: "grains",
        grow_days: 5
    });
    ds_map_add(global.item_database, "flour", {
        name: "Мука",
        category: "grains",
        crafted: true,
        icon: spr_flour_icon
    });

    // --- ВЫПЕЧКА (ингредиенты) ---
    ds_map_add(global.item_database, "yeast", {
        name: "Дрожжи",
        category: "grains",
        crafted: false,
        icon: spr_yeast_icon
    });
    ds_map_add(global.item_database, "sugar", {
        name: "Сахар",
        category: "grains",
        crafted: false,
        icon: spr_shugar_icon
    });

    // --- КОФЕ ---
    ds_map_add(global.item_database, "coffee_beans", {
        name: "Зерна кофе",
        category: "grains",
        icon: spr_cofee_icon
    });
    ds_map_add(global.item_database, "water", {
        name: "Вода",
        category: "dairy"
    });
    ds_map_add(global.item_database, "latte", {
        name: "Латте",
        category: "coffee",
        sell_price: 10
    });
    ds_map_add(global.item_database, "americano", {
        name: "Американо",
        category: "coffee",
        sell_price: 10
    });

    // --- МЁД ---
    ds_map_add(global.item_database, "honey", {
        name: "Мёд",
        category: "honey",
        source: "beehive"
    });

    // --- ВЫПЕЧКА ---
    ds_map_add(global.item_database, "potato_pie", {
        name: "Картофельный пирог",
        category: "baked",
        sell_price: 10,
        grow_days: 0,
        icon: spr_potatoes_pie
    });
    ds_map_add(global.item_database, "carrot_pie", {
        name: "Морковный пирог",
        category: "baked",
        sell_price: 10,
        grow_days: 0,
        icon: spr_carrot_pie
    });
    ds_map_add(global.item_database, "carrot_muffin", {
        name: "Морковный маффин",
        category: "baked",
        sell_price: 10,
        grow_days: 0
    });
    ds_map_add(global.item_database, "apple_bun", {
        name: "Булочки с яблоками",
        category: "baked",
        sell_price: 10,
        grow_days: 0,
        icon: asset_get_index("spr_apple_bun_icon")
    });
    ds_map_add(global.item_database, "apple_jam", {
        name: "Варенье яблочное",
        category: "baked",
        sell_price: 10,
        grow_days: 0,
        icon: asset_get_index("spr_apple_jam_icon")
    });
    ds_map_add(global.item_database, "pear_jam", {
        name: "Грушевое варенье",
        category: "baked",
        sell_price: 10,
        grow_days: 0,
        icon: asset_get_index("spr_pear_jam_icon")
    });
    ds_map_add(global.item_database, "pizza", {
        name: "Пицца",
        category: "baked",
        sell_price: 10,
        grow_days: 0,
        icon: asset_get_index("spr_pizza_icon")
    });

    // === ХРАНИЛИЩЕ САРАЯ (по категориям) ===
    global.barn_storage = ds_map_create();
    for (var i = 0; i < array_length(global.storage_categories); i++) {
        var cat = global.storage_categories[i];
        ds_map_add(global.barn_storage, cat, ds_map_create());
    }

    // === ВАЛЮТА ===
    global.coins = 20;

    // === ВИТРИНА ===
    global.vitrina_items  = ds_map_create(); // item_id → {amount, price}
    global.coins_pending  = 0;              // монеты с витрины, ещё не собранные

    // === ИНВЕНТАРЬ ИГРОКА ===
    global.player_inventory = ds_map_create();
    inventory_add(ITEM_SEED,            4);
    inventory_add(ITEM_POTATO_SEED,     5);
    inventory_add(ITEM_STRAWBERRY_SEED, 5);

    // === ХРАНИЛИЩЕ ЯЩИКА ===
    global.chest_inventory = ds_map_create();
    ds_map_set(global.chest_inventory, ITEM_SEED,            4);
    ds_map_set(global.chest_inventory, "potato",             3);
    ds_map_set(global.chest_inventory, "coffee_beans",       3);
    ds_map_set(global.chest_inventory, ITEM_POTATO_SEED,     5);
    ds_map_set(global.chest_inventory, ITEM_STRAWBERRY_SEED, 5);

    // === ХРАНИЛИЩЕ ХОЛОДИЛЬНИКА ===
    global.fridge_storage = ds_map_create();
    ds_map_set(global.fridge_storage, "milk",  2);
    ds_map_set(global.fridge_storage, "egg",   3);
    ds_map_set(global.fridge_storage, "flour", 2);
    ds_map_set(global.fridge_storage, "yeast", 2);
    ds_map_set(global.fridge_storage, "sugar", 2);

    // ТЕСТ: пирог для сцены Джастина День 2 (убрать после теста)
    inventory_add("potato_pie", 1);

    show_debug_message("Storage system initialized!");
}

/// @func storage_add_to_barn(item_id, amount)
/// @desc Добавить предмет в сарай
function storage_add_to_barn(item_id, amount) {
    var item_data = ds_map_find_value(global.item_database, item_id);
    if (item_data == undefined) {
        show_debug_message("ERROR: Item not found: " + item_id);
        return false;
    }

    var category = item_data.category;
    var cat_storage = ds_map_find_value(global.barn_storage, category);

    var current = ds_map_find_value(cat_storage, item_id);
    if (current == undefined) current = 0;

    ds_map_set(cat_storage, item_id, current + amount);
    show_debug_message("Added " + string(amount) + " " + item_id + " to barn (" + category + ")");
    return true;
}

/// @func storage_remove_from_barn(item_id, amount)
/// @desc Забрать предмет из сарая
function storage_remove_from_barn(item_id, amount) {
    var item_data = ds_map_find_value(global.item_database, item_id);
    if (item_data == undefined) return false;

    var category = item_data.category;
    var cat_storage = ds_map_find_value(global.barn_storage, category);

    var current = ds_map_find_value(cat_storage, item_id);
    if (current == undefined || current < amount) return false;

    ds_map_set(cat_storage, item_id, current - amount);
    show_debug_message("Removed " + string(amount) + " " + item_id + " from barn");
    return true;
}

/// @func storage_get_barn_amount(item_id)
/// @desc Получить количество предмета в сарае
function storage_get_barn_amount(item_id) {
    var item_data = ds_map_find_value(global.item_database, item_id);
    if (item_data == undefined) return 0;

    var category = item_data.category;
    var cat_storage = ds_map_find_value(global.barn_storage, category);

    var current = ds_map_find_value(cat_storage, item_id);
    return (current == undefined) ? 0 : current;
}

/// @func storage_get_category_items(category)
/// @desc Получить все предметы категории в сарае (возвращает массив {id, amount})
function storage_get_category_items(category) {
    var result = [];
    var cat_storage = ds_map_find_value(global.barn_storage, category);
    if (cat_storage == undefined) return result;

    var key = ds_map_find_first(cat_storage);
    while (key != undefined) {
        var amount = ds_map_find_value(cat_storage, key);
        if (amount > 0) {
            array_push(result, { item_id: key, amount: amount });
        }
        key = ds_map_find_next(cat_storage, key);
    }
    return result;
}

/// @func storage_get_item_info(item_id)
/// @desc Получить информацию о предмете
function storage_get_item_info(item_id) {
    return ds_map_find_value(global.item_database, item_id);
}

/// @func storage_get_category_name(category)
/// @desc Получить название категории на русском
function storage_get_category_name(category) {
    return ds_map_find_value(global.category_names, category);
}

/// @func inventory_add(item_id, amount)
/// @desc Добавить предмет в инвентарь игрока
function inventory_add(item_id, amount) {
    var current = ds_map_find_value(global.player_inventory, item_id);
    if (current == undefined) current = 0;
    ds_map_set(global.player_inventory, item_id, current + amount);
    return true;
}

/// @func inventory_remove(item_id, amount)
/// @desc Убрать предмет из инвентаря игрока
function inventory_remove(item_id, amount) {
    var current = ds_map_find_value(global.player_inventory, item_id);
    if (current == undefined || current < amount) return false;
    ds_map_set(global.player_inventory, item_id, current - amount);
    return true;
}

/// @func inventory_get_amount(item_id)
/// @desc Получить количество предмета в инвентаре
function inventory_get_amount(item_id) {
    var current = ds_map_find_value(global.player_inventory, item_id);
    return (current == undefined) ? 0 : current;
}

/// @func chest_add(item_id, amount)
function chest_add(item_id, amount) {
    var current = ds_map_find_value(global.chest_inventory, item_id);
    if (current == undefined) current = 0;
    ds_map_set(global.chest_inventory, item_id, current + amount);
    return true;
}

/// @func chest_remove(item_id, amount)
function chest_remove(item_id, amount) {
    var current = ds_map_find_value(global.chest_inventory, item_id);
    if (current == undefined || current < amount) return false;
    ds_map_set(global.chest_inventory, item_id, current - amount);
    return true;
}

/// @func chest_get_amount(item_id)
function chest_get_amount(item_id) {
    var current = ds_map_find_value(global.chest_inventory, item_id);
    return (current == undefined) ? 0 : current;
}

/// @func inventory_transfer_to_barn(item_id, amount)
/// @desc Переложить предмет из инвентаря в сарай
function inventory_transfer_to_barn(item_id, amount) {
    if (inventory_remove(item_id, amount)) {
        storage_add_to_barn(item_id, amount);
        return true;
    }
    return false;
}

// =====================================================
// СИСТЕМА ВИТРИНЫ
// =====================================================

/// @func vitrina_add(item_id, amount)
/// @desc Переместить предмет из инвентаря на витрину
function vitrina_add(item_id, amount) {
    if (!inventory_remove(item_id, amount)) return false;

    var _item_info  = storage_get_item_info(item_id);
    var _price      = (_item_info != undefined && variable_struct_exists(_item_info, "sell_price"))
                      ? _item_info.sell_price : 10;

    var _existing = ds_map_find_value(global.vitrina_items, item_id);
    if (_existing == undefined) {
        ds_map_add(global.vitrina_items, item_id, { amount: amount, price: _price });
    } else {
        _existing.amount += amount;
        ds_map_set(global.vitrina_items, item_id, _existing);
    }
    show_debug_message("Витрина: выставлено " + string(amount) + " " + item_id);
    return true;
}

/// @func vitrina_get_amount(item_id)
/// @desc Получить количество предмета на витрине
function vitrina_get_amount(item_id) {
    var _entry = ds_map_find_value(global.vitrina_items, item_id);
    return (_entry == undefined) ? 0 : _entry.amount;
}

/// @func vitrina_collect_coins()
/// @desc Перенести ожидающие монеты витрины в общий кошелёк
function vitrina_collect_coins() {
    global.coins += global.coins_pending;
    global.coins_pending = 0;
}

/// @func vitrina_sell_all()
/// @desc Конец дня: продать всё с витрины → coins_pending, очистить витрину
function vitrina_sell_all() {
    var _key = ds_map_find_first(global.vitrina_items);
    while (_key != undefined) {
        var _entry = ds_map_find_value(global.vitrina_items, _key);
        global.coins_pending += _entry.amount * _entry.price;
        _key = ds_map_find_next(global.vitrina_items, _key);
    }
    ds_map_clear(global.vitrina_items);
    show_debug_message("Витрина продала всё. Ожидает монет: " + string(global.coins_pending));
}

// =====================================================
// ХОЛОДИЛЬНИК
// =====================================================

/// @func fridge_add(item_id, amount)
function fridge_add(item_id, amount) {
    var current = ds_map_find_value(global.fridge_storage, item_id);
    if (current == undefined) current = 0;
    ds_map_set(global.fridge_storage, item_id, current + amount);
    return true;
}

/// @func fridge_remove(item_id, amount)
function fridge_remove(item_id, amount) {
    var current = ds_map_find_value(global.fridge_storage, item_id);
    if (current == undefined || current < amount) return false;
    ds_map_set(global.fridge_storage, item_id, current - amount);
    return true;
}

/// @func fridge_get_amount(item_id)
function fridge_get_amount(item_id) {
    var current = ds_map_find_value(global.fridge_storage, item_id);
    return (current == undefined) ? 0 : current;
}
