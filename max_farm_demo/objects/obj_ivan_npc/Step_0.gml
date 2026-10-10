depth = -y;
if (say_timer > 0) say_timer--;

if (!variable_global_exists("ivan_quest_started")) global.ivan_quest_started = false;
if (!variable_global_exists("ivan_quest_done"))    global.ivan_quest_done    = false;

if (!global.control_locked && instance_exists(obj_max)) {
    if (point_distance(x, y, obj_max.x, obj_max.y) < 80
    &&  keyboard_check_pressed(ord("E"))) {
        // Задание с доски объявлений: 5 морковок -> 25 монет
        if (global.ivan_quest_started && !global.ivan_quest_done) {
            if (inventory_get_amount(ITEM_CARROT) >= 5) {
                inventory_remove(ITEM_CARROT, 5);
                global.coins += 25;
                global.ivan_quest_done = true;
                say_msg = "Спасибо! Вот 25 монет.\nРагу будет отличным!";
            } else {
                say_msg = "Принесёшь 5 морковок?\nЖду с нетерпением!";
            }
        } else if (global.ivan_quest_done) {
            say_msg = "Рагу удалось на славу!\nЗаходи, когда лавка откроется.";
        } else {
            say_msg = "Мясная лавка\nоткроется позже!";
        }
        say_timer = 150;
    }
}
