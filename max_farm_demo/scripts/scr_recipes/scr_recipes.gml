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
