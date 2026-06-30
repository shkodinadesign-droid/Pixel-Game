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

function recipe_craft(idx) {
    if (!recipe_can_craft(idx)) return false;
    var _r = global.recipes[idx];
    for (var i = 0; i < array_length(_r.ingredients); i++)
        inventory_remove(_r.ingredients[i].item, _r.ingredients[i].amount);
    inventory_add(_r.result.item, _r.result.amount);
    return true;
}
