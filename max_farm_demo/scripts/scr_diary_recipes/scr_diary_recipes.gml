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
/// @desc Список рецептов. Каждый: { id, name, category, icon, image, unlocked, ingredients:[{icon,name,color}] }
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
                {icon: spr_potato_icon, name: "Картофель", color: make_color_rgb(220,170,50)},
                {icon: spr_milk_icon,   name: "Молоко",    color: make_color_rgb(220,235,255)},
                {icon: spr_egg_icon,    name: "Яйцо",      color: make_color_rgb(255,220,80)},
                {icon: spr_flour_icon,  name: "Мука",      color: make_color_rgb(235,225,205)},
                {icon: spr_yeast_icon,  name: "Дрожжи",    color: make_color_rgb(160,110,55)},
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
                {icon: spr_pear_icon,   name: "Груша",     color: make_color_rgb(180,200,80), amount: 2},
                {icon: spr_shugar_icon, name: "Сахар",     color: make_color_rgb(250,250,240)},
                {icon: spr_milk_icon,   name: "Молоко",    color: make_color_rgb(220,235,255)},
                {icon: spr_egg_icon,    name: "Яйцо",      color: make_color_rgb(255,220,80)},
                {icon: spr_flour_icon,  name: "Мука",      color: make_color_rgb(235,225,205)},
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
                {icon: -1,            name: "Зёрна кофе", color: make_color_rgb(90,60,40)},
                {icon: spr_milk_icon, name: "Молоко",      color: make_color_rgb(220,235,255)},
                {icon: -1,            name: "Сахар",       color: make_color_rgb(250,250,240)},
            ]
        },
    ];
}
