
if (!variable_global_exists("control_locked")) global.control_locked = false;


walk_speed = 2;
direction_facing = "down";
state = "idle";
sprite_index = spr_max_idle_up;
image_speed = 0;

hp_max = 100;
hp     = 100;

// --- инструменты и направление ---
selected_tool         = Tool.None;
selected_seed         = "";
selected_shovel       = false;
selected_watering_can = false;
nearest_soil  = noone;            // ближайшая клетка грядки (для хинта)
facing = [0, 1];               // смотрим вниз (x=0, y=1)


// количество морковки теперь в global.player_inventory через inventory_get_amount(ITEM_CARROT)

// === ХОТБАР (листается стрелками/клавишами [ ]) ===
// Инструменты всегда первыми. Остальное добавляется через hotbar_add_item() при первом получении.
hotbar_scroll  = 0;
hotbar_visible = 8;
hotbar_items   = [
    { item: "watering_can", spr: spr_wateringcan, is_seed: false, has_count: false },
    { item: "shovel",       spr: spr_shovel_icon,  is_seed: false, has_count: false },
];

if (!variable_global_exists("input_locked")) global.input_locked = false;

// Уведомление дневника: новое задание
if (!variable_global_exists("diary_has_new"))  global.diary_has_new  = false; // ! появляется только при новом задании
if (!variable_global_exists("diary_was_read")) global.diary_was_read = true;


