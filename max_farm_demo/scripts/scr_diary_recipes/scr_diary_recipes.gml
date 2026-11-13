// ===== ДНЕВНИК: ДАННЫЕ ВКЛАДКИ "РЕЦЕПТЫ" =====

/// @func diary_get_recipe_categories()
/// @desc Вкладки-фильтры над сеткой рецептов
function diary_get_recipe_categories() {
    return [
        {id: "baking", name: "Выпечка"},
        {id: "main",   name: "Блюда"},
        {id: "drinks", name: "Напитки"},
    ];
}

/// @func diary_get_recipe_list()
/// @desc Список рецептов. Каждый: { id, name, category, icon, image, unlocked, ingredients:[{item,icon,name,color}] }
/// ingredient.item — id предмета в инвентаре (для отметки «есть / не хватает» в дневнике).
/// ingredient.amount — количество (по умолчанию 1).
/// icon/image = -1, если спрайта нет — тогда рисуется цветной кружок по полю color.
function diary_get_recipe_list() {
    var _justin_done = variable_global_exists("justin_bakery_intro_done") && global.justin_bakery_intro_done;
    var _coffee_unlocked = variable_global_exists("coffee_letter_read") && global.coffee_letter_read;

    return [
        {
            id: "potato_pie",
            name: "Картофельный пирог",
            category: "baking",
            icon: spr_potatoes_pie,
            image: spr_potato_pie_dish,
            unlocked: _justin_done,
            ingredients: [
                {item: "potato", icon: spr_potato_icon, name: "Картофель", color: make_color_rgb(220,170,50)},
                {item: "milk", icon: spr_milk_icon,   name: "Молоко",    color: make_color_rgb(220,235,255)},
                {item: "egg", icon: spr_egg_icon,    name: "Яйцо",      color: make_color_rgb(255,220,80)},
                {item: "flour", icon: spr_flour_icon,  name: "Мука",      color: make_color_rgb(235,225,205)},
                {item: "yeast", icon: spr_yeast_icon,  name: "Дрожжи",    color: make_color_rgb(160,110,55)},
            ]
        },
        {
            id: "pear_bun",
            name: "Булочки с грушей",
            category: "baking",
            icon: -1,
            image: -1,
            unlocked: _justin_done,
            ingredients: [
                {item: "pear", icon: spr_pear_icon,   name: "Груша",     color: make_color_rgb(180,200,80), amount: 2},
                {item: "sugar", icon: spr_shugar_icon, name: "Сахар",     color: make_color_rgb(250,250,240)},
                {item: "milk", icon: spr_milk_icon,   name: "Молоко",    color: make_color_rgb(220,235,255)},
                {item: "egg", icon: spr_egg_icon,    name: "Яйцо",      color: make_color_rgb(255,220,80)},
                {item: "flour", icon: spr_flour_icon,  name: "Мука",      color: make_color_rgb(235,225,205)},
            ]
        },
        {
            id: "latte",
            name: "Латте",
            category: "drinks",
            icon: -1,
            image: -1,
            unlocked: _coffee_unlocked,
            ingredients: [
                {item: "coffee_beans", icon: -1,            name: "Зёрна кофе", color: make_color_rgb(90,60,40)},
                {item: "milk", icon: spr_milk_icon, name: "Молоко",      color: make_color_rgb(220,235,255)},
                {item: "sugar", icon: -1,            name: "Сахар",       color: make_color_rgb(250,250,240)},
            ]
        },
    ];
}

/// @func diary_recipes_in_category(_all, _cat)
/// @desc Рецепты категории для сетки дневника: сначала открытые, затем закрытые (рисуются с замком).
function diary_recipes_in_category(_all, _cat) {
    var _open = [], _locked = [];
    for (var i = 0; i < array_length(_all); i++) {
        if (_all[i].category != _cat) continue;
        if (_all[i].unlocked) array_push(_open, _all[i]); else array_push(_locked, _all[i]);
    }
    for (var j = 0; j < array_length(_locked); j++) array_push(_open, _locked[j]);
    return _open;
}

/// @func diary_get_plant_list()
/// @desc Растения для вкладки "Растения": { name, icon, stages, grow_text }.
/// Стадии и сроки — как в obj_soil.plant_crop: растение подрастает на стадию за ночь, если в этот день грядка полита.
function diary_get_plant_list() {
    return [
        { name: "Морковь",   icon: spr_seed_carrot_icon,     stages: [spr_seed, spr_carrot_stage1, spr_carrot_ready], grow_text: "Созревает за 2 дня полива" },
        { name: "Картофель", icon: spr_potato_seed_icon,     stages: [spr_seed, spr_potato_stage1, spr_potato_ready], grow_text: "Созревает за 3 дня полива" },
        { name: "Клубника",  icon: spr_strawberry_seed_icon, stages: [spr_seed, spr_strawberry_ready],                grow_text: "Созревает за 1 день полива" },
    ];
}
