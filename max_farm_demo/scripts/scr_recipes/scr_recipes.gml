/// @desc Система рецептов для пекарни

function recipes_init() {
    global.recipes = [];

    var _r2 = {
        id:          "potato_pie",
        name:        "Картофельный пирог",
        ingredients: [
            { item: "potato", amount: 1 },
            { item: "milk",   amount: 1 },
            { item: "egg",    amount: 1 },
            { item: "flour",  amount: 1 },
            { item: "yeast",  amount: 1 }
        ],
        result: { item: "potato_pie", amount: 1 }
    };
    array_push(global.recipes, _r2);

    var _r3 = {
        id:          "carrot_muffin",
        name:        "Морковный пирог",
        ingredients: [
            { item: ITEM_CARROT, amount: 2 },
            { item: "egg",       amount: 1 },
            { item: "flour",     amount: 1 },
            { item: "sugar",     amount: 1 },
            { item: "milk",      amount: 1 }
        ],
        result: { item: ITEM_CARROT_MUFFIN, amount: 1 }
    };
    array_push(global.recipes, _r3);

    var _r4 = {
        id:          "apple_bun",
        name:        "Булочки с яблоками",
        ingredients: [
            { item: ITEM_APPLE, amount: 2 },
            { item: "sugar",    amount: 1 },
            { item: "milk",     amount: 1 },
            { item: "egg",      amount: 1 },
            { item: "flour",    amount: 1 }
        ],
        result: { item: ITEM_APPLE_BUN, amount: 1 }
    };
    array_push(global.recipes, _r4);

    var _r4b = {
        id:          "pear_bun",
        name:        "Булочки с грушей",
        ingredients: [
            { item: ITEM_PEAR, amount: 2 },
            { item: "sugar",   amount: 1 },
            { item: "milk",    amount: 1 },
            { item: "egg",     amount: 1 },
            { item: "flour",   amount: 1 }
        ],
        result: { item: ITEM_PEAR_BUN, amount: 1 }
    };
    array_push(global.recipes, _r4b);

    // water появится после добавления колодца
    var _r5 = {
        id:          "apple_jam",
        name:        "Варенье яблочное",
        ingredients: [
            { item: ITEM_APPLE, amount: 6 },
            { item: "sugar",    amount: 2 },
            { item: "water",    amount: 1 }
        ],
        result: { item: ITEM_APPLE_JAM, amount: 1 }
    };
    array_push(global.recipes, _r5);

    // pepperoni и tomato появятся позже (мясная лавка)
    var _r6 = {
        id:          "pizza",
        name:        "Пицца",
        ingredients: [
            { item: "flour",     amount: 1 },
            { item: "water",     amount: 1 },
            { item: "egg",       amount: 1 },
            { item: "tomato",    amount: 1 },
            { item: "pepperoni", amount: 1 }
        ],
        result: { item: ITEM_PIZZA, amount: 1 }
    };
    array_push(global.recipes, _r6);

    var _r7 = {
        id:          "pear_jam",
        name:        "Грушевое варенье",
        ingredients: [
            { item: ITEM_PEAR, amount: 3 },
            { item: "water",   amount: 1 },
            { item: "sugar",   amount: 1 }
        ],
        result: { item: ITEM_PEAR_JAM, amount: 1 }
    };
    array_push(global.recipes, _r7);

    var _r8 = {
        id:          "pudding",
        name:        "Пуддинг",
        unlock:      "pudding_quest",
        ingredients: [
            { item: "milk",      amount: 1 },
            { item: "egg",       amount: 1 },
            { item: "sugar",     amount: 1 },
            { item: ITEM_APPLE,  amount: 1 }
        ],
        result: { item: ITEM_PUDDING, amount: 1 }
    };
    array_push(global.recipes, _r8);
}

function recipe_can_craft(idx) {
    var _r = global.recipes[idx];
    for (var i = 0; i < array_length(_r.ingredients); i++) {
        if (inventory_get_amount(_r.ingredients[i].item) < _r.ingredients[i].amount)
            return false;
    }
    return true;
}

/// @func recipe_find_index(_id)
/// @desc Индекс рецепта в global.recipes по его id (-1, если нет)
function recipe_find_index(_id) {
    for (var i = 0; i < array_length(global.recipes); i++) {
        if (global.recipes[i].id == _id) return i;
    }
    return -1;
}

function recipe_craft(idx) {
    if (!recipe_can_craft(idx)) return false;
    var _r = global.recipes[idx];
    for (var i = 0; i < array_length(_r.ingredients); i++)
        inventory_remove(_r.ingredients[i].item, _r.ingredients[i].amount);
    inventory_add(_r.result.item, _r.result.amount);
    return true;
}

/// @func recipe_dish_image(_id)
/// @desc Картинка готового блюда для окна готовки и дневника, иначе -1.
/// Спрайты перечислены явно: в проекте включено «удалять неиспользуемые ресурсы», и найденные только по имени
/// (asset_get_index) спрайты в сборку не попадают.
function recipe_dish_image(_id) {
    switch (_id) {
        case "potato_pie":    return spr_dish_potato_pie;
        case "carrot_pie":    return spr_dish_carrot_pie;
        case "carrot_muffin": return spr_dish_carrot_muffin;
        case "pizza":         return spr_dish_pizza;
        case "apple_bun":     return spr_dish_apple_bun;
        case "pudding":       return spr_dish_pudding;
        case "latte":         return spr_dish_latte;
        case "cappuccino":    return spr_dish_cappuccino;
        case "cocoa":         return spr_dish_cocoa;
        case "tea_aromatic":  return spr_dish_tea_aromatic;
        case "tea_sunny":     return spr_dish_tea_sunny;
        case "tea_grandma":   return spr_dish_tea_grandma;
    }
    return -1;
}

/// @func ingredient_icon(_item_id)
/// @desc Крупная иконка ингредиента (до 40 px) для окна готовки, иначе обычная иконка предмета, иначе -1.
/// Спрайты перечислены явно (см. recipe_dish_image).
function ingredient_icon(_item_id) {
    switch (_item_id) {
        case "egg":          return spr_ingr_egg;
        case "milk":         return spr_ingr_milk;
        case "potato":       return spr_ingr_potato;
        case "sugar":        return spr_ingr_sugar;
        case "flour":        return spr_ingr_flour;
        case "water":        return spr_ingr_water;
        case "carrot":       return spr_ingr_carrot;
        case "strawberry":   return spr_ingr_strawberry;
        case "coffee_beans": return spr_ingr_coffee_beans;
        case "pepperoni":    return spr_ingr_pepperoni;
        case "yeast":        return spr_ingr_yeast;
    }
    var _inf = storage_get_item_info(_item_id);
    if (_inf != undefined && variable_struct_exists(_inf, "icon") && sprite_exists(_inf.icon)) return _inf.icon;
    return -1;
}
