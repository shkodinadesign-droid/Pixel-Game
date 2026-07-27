// --- базовые флаги клетки ---
has_seed = false;
watered  = false;
dug      = false;  // false = ещё не вскопано лопатой
covered  = false;
crop_id  = noone;

// --- координаты центра клетки (рум-редактор уже ставит по сетке) ---
cell_cx = x;
cell_cy = y;

// запомним наш слой (на случай, если слой с культурами не найдётся)
my_layer = layer;

// --- визуал земли ---
function soil_update_sprite() {
    visible     = true;
    image_blend = c_white;
    if (!dug) {
        sprite_index = spr_soil_dry;
        image_alpha  = 0.35;
    } else if (watered) {
        sprite_index = spr_soil_wet;
        image_alpha  = 1;
    } else {
        sprite_index = spr_soil_dry;
        image_alpha  = 1;
    }
}
soil_update_sprite();

// --- ВЫКОПАТЬ ЯМКУ ЛОПАТОЙ ---
function dig_cell() {
    if (dug) exit;
    dug     = true;
    covered = true;
    soil_update_sprite();
}

// --- ПОСАДИТЬ РАСТЕНИЕ В ЭТУ КЛЕТКУ ---
function plant_crop(seed_type = "carrot") {
    if (has_seed) exit; // уже посажено
    if (!dug)     exit; // сначала надо выкопать ямку

    // получим ID слоя с растениями; если нет — используем наш слой как запасной вариант
    var lyr = layer_get_id("layer_crops");
    if (lyr == -1) lyr = my_layer;

    crop_id = instance_create_layer(cell_cx, cell_cy, lyr, obj_crop);
    if (crop_id != noone) {
        crop_id.soil_id  = id;
        crop_id.crop_type = seed_type;
        // Настраиваем спрайты и скорость роста для каждой культуры
        // asset_get_index безопасно возвращает -1 если спрайт ещё не создан → fallback spr_seed
        with (crop_id) {
            if (crop_type == "potato") {
                // 3 дня: семя → росток → росток → готов
                spr_stages     = [spr_seed, spr_potato_stage1, spr_potato_stage1, spr_potato_ready];
                days_per_stage = 1;
                set_stage_sprite();
            } else if (crop_type == "strawberry") {
                // 1 день: семя → готова
                spr_stages     = [spr_seed, spr_strawberry_ready];
                days_per_stage = 1;
                set_stage_sprite();
            } else if (crop_type == "carrot") {
                // 2 дня: семя → росток → готова
                spr_stages     = [spr_seed, spr_carrot_stage1, spr_carrot_ready];
                days_per_stage = 1;
                set_stage_sprite();
            }
        }
        has_seed = true;
        covered  = true; // автоматически — шага "закопать" нет
        // Отмечаем посев для задания дневника
        if (seed_type == "potato")     { if (!variable_global_exists("potato_planted"))     global.potato_planted     = false; global.potato_planted     = true; }
        if (seed_type == "strawberry") { if (!variable_global_exists("strawberry_planted")) global.strawberry_planted = false; global.strawberry_planted = true; }
        if (variable_global_exists("potato_planted") && global.potato_planted
        &&  variable_global_exists("strawberry_planted") && global.strawberry_planted) {
            if (!variable_global_exists("plant_quest_done")) global.plant_quest_done = false;
            global.plant_quest_done  = true;
            global.diary_has_new     = true;
            global.diary_was_read    = false;
        }
        show_debug_message("PLANT ✔ at (" + string(cell_cx) + "," + string(cell_cy) + ") crop:" + seed_type);
    } else {
        show_debug_message("PLANT ✖ failed: layer not found");
    }
}

// --- ПОЛИТЬ КЛЕТКУ ---
function water_cell() {
    show_debug_message("[WATER] covered=" + string(covered) + " has_seed=" + string(has_seed) + " dug=" + string(dug) + " at (" + string(cell_cx) + "," + string(cell_cy) + ")");
    if (!covered) { show_debug_message("[WATER] SKIPPED — covered=false"); exit; }
    watered = true;
    soil_update_sprite();
    show_debug_message("[WATER] ✔ at (" + string(cell_cx) + "," + string(cell_cy) + ")");

    // Проверяем, все ли грядки политы (триггер появления Мэгги)
    if (!variable_global_exists("meggi_intro_done")) global.meggi_intro_done = false;

    if (!global.meggi_intro_done && room == rm_farm) {
        // Считаем сколько грядок полито
        var watered_count = 0;
        var total_count = 0;
        with (obj_soil) {
            total_count += 1;
            if (watered) watered_count += 1;
        }

        show_debug_message("Watered: " + string(watered_count) + "/" + string(total_count));

        // Если все 4 грядки политы - вызываем Мэгги
        if (watered_count >= 4 && total_count >= 4) {
            // Создаём Мэгги сверху — из-за дома Макс
            var _lyr = layer_get_id("Max");
            if (_lyr == -1) _lyr = layer;
            // Появляется сверху за экраном, на x дома Макс (~736)
            var _spawn_x = (instance_exists(obj_max)) ? obj_max.x + 40 : 736;
            var _maggie = instance_create_layer(_spawn_x, -50, _lyr, obj_grandma_Maggie);
            show_debug_message("Все грядки политы! Grandma Maggie появилась!");
        }
    }
}

// --- ОЧИСТИТЬ КЛЕТКУ (после сбора) ---
function clear_cell() {
    has_seed = false;
    crop_id  = noone;
}
