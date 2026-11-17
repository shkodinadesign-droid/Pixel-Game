// ===== ИВАН — ПРОДАВЕЦ МЯСНОЙ ЛАВКИ (CREATE) =====
// Стоит за прилавком в rm_butcher_shop. Диалог и магазин — как у Майли (родитель obj_joshua_npc):
// при первом входе знакомство, потом по E короткий разговор и магазин (колбаса, молочное).
// Задание с доски объявлений «Морковь для Ивана» (5 морковок -> 25 монет) сдаётся ему здесь.
npc_name        = "Иван";
npc_speaker     = "Иван:";
npc_spr_idle    = spr_ivan_idle_down;
npc_spr_talk    = spr_ivan_talk;
npc_portrait    = spr_ivan_portrait_anim;
first_visit_key = "ivan_first_visit_done";
stock_key       = "ivan_inventory";
shop_title      = "МЯСНАЯ ЛАВКА ИВАНА";
repeat_line     = "Здравствуй! Что возьмёшь сегодня?";
intro_lines = [
    ["Иван:", "Добро пожаловать в мясную лавку!",          "Я Иван. У меня колбасы и свежая молочка."],
    ["Макс:", "Здравствуйте! Я Макс, внучка бабушки Сони.", "Мне как раз нужны продукты для пекарни!"],
    ["Иван:", "Смотри, что есть на прилавке!",             "Для своих - лучшие цены =)"],
];
shop_items = [
    { id: "pepperoni", spr: spr_pepperoni_icon, col: make_color_rgb(190,80,50),   name: "Колбаса",   price: 8 },
    { id: "milk",      spr: spr_milk_icon,      col: make_color_rgb(240,240,240), name: "Молоко",    price: 4 },
    { id: "egg",       spr: spr_egg_icon,       col: make_color_rgb(255,220,80),  name: "Яйца",      price: 3 },
    { id: "cheese",    spr: -1,                 col: make_color_rgb(250,200,70),  name: "Сыр",       price: 7 },
    { id: "butter",    spr: -1,                 col: make_color_rgb(250,235,160), name: "Масло",     price: 6 },
];

// Повторный разговор: сначала задание с морковью, потом магазин
on_talk = function() {
    if (!variable_global_exists("ivan_quest_started")) global.ivan_quest_started = false;
    if (!variable_global_exists("ivan_quest_done"))    global.ivan_quest_done    = false;
    repeat_line = "Здравствуй! Что возьмёшь сегодня?";
    if (global.ivan_quest_started && !global.ivan_quest_done) {
        if (inventory_get_amount(ITEM_CARROT) >= 5) {
            inventory_remove(ITEM_CARROT, 5);
            global.coins += 25;
            global.ivan_quest_done = true;
            repeat_line = "Спасибо за морковь! Вот 25 монет. Рагу будет отличным!";
        } else {
            repeat_line = "Принесёшь 5 морковок для рагу? Жду с нетерпением!";
        }
    } else if (global.ivan_quest_done) {
        repeat_line = "Рагу удалось на славу! Что возьмёшь сегодня?";
    }
};

event_inherited();
