global.control_locked = false;

// Инициализация систем (только один раз)
if (!variable_global_exists("player_inventory")) {
    storage_init();
    recipes_init();
    orders_init();
}
