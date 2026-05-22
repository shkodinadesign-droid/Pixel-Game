/// @desc Система дневных заказов

/// @func orders_init()
/// @desc Инициализация системы заказов (вызывается один раз при старте)
function orders_init() {
    if (!variable_global_exists("daily_orders")) {
        global.daily_orders = [];
    }
}

/// @func orders_generate_daily()
/// @desc Создаёт 3 новых заказа на день (вызывается в начале каждого дня)
function orders_generate_daily() {
    global.daily_orders = [];

    var _npcs = ["Миля", "Мэгги", "Сосед"];

    // Собираем список предметов из рецептов (crafted items)
    var _crafted_items = [];
    for (var i = 0; i < array_length(global.recipes); i++) {
        array_push(_crafted_items, global.recipes[i].result.item);
    }

    if (array_length(_crafted_items) == 0) {
        show_debug_message("orders_generate_daily: нет crafted items!");
        return;
    }

    for (var i = 0; i < 3; i++) {
        var _npc     = _npcs[i];
        var _item_id = _crafted_items[irandom(array_length(_crafted_items) - 1)];
        var _amount  = 1 + irandom(2); // 1–3

        var _item_info  = storage_get_item_info(_item_id);
        var _sell_price = (_item_info != undefined && variable_struct_exists(_item_info, "sell_price"))
                          ? _item_info.sell_price : 10;
        var _reward = floor(_sell_price * _amount * 1.5);

        var _order = {
            npc_name:  _npc,
            item_id:   _item_id,
            amount:    _amount,
            reward:    _reward,
            fulfilled: false
        };
        array_push(global.daily_orders, _order);
    }

    show_debug_message("Заказы на день: " + string(array_length(global.daily_orders)));
}

/// @func orders_can_fulfill(idx)
/// @desc Возвращает true, если игрок может выполнить заказ
function orders_can_fulfill(idx) {
    if (idx < 0 || idx >= array_length(global.daily_orders)) return false;
    var _order = global.daily_orders[idx];
    if (_order.fulfilled) return false;
    return inventory_get_amount(_order.item_id) >= _order.amount;
}

/// @func orders_fulfill(idx)
/// @desc Выполняет заказ: снимает предметы из инвентаря, начисляет монеты
function orders_fulfill(idx) {
    if (!orders_can_fulfill(idx)) return false;
    var _order = global.daily_orders[idx];
    inventory_remove(_order.item_id, _order.amount);
    global.coins += _order.reward;
    _order.fulfilled = true;
    global.daily_orders[@ idx] = _order;
    show_debug_message("Заказ выполнен: " + _order.npc_name + " +" + string(_order.reward) + " монет");
    return true;
}
