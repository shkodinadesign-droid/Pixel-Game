/// obj_crop → Create  (со спрайтами по стадиям)

persistent = true;

// переменные для day_controller (чтобы не падал)
if (!variable_instance_exists(id, "days"))           days = 0;
if (!variable_instance_exists(id, "days_per_stage")) days_per_stage = 1; // 1 день на стадию для теста
if (!variable_instance_exists(id, "stage"))          stage = 0;          // 0..ready

// Ссылка на почву (устанавливается при посадке через plant_crop)
if (!variable_instance_exists(id, "soil_id")) soil_id = noone;

// Тип растения: "carrot", "potato", "strawberry" — может быть переопределён через plant_crop()
if (!variable_instance_exists(id, "crop_type")) crop_type = "carrot";

// МАССИВ СПРАЙТОВ ПО СТАДИЯМ (0..ready)
// Можно переопределить снаружи через plant_crop() — здесь дефолт для моркови
if (crop_type == "potato") {
    spr_stages = [spr_seed, spr_potato_stage1, spr_potato_ready];
} else if (crop_type == "strawberry") {
    spr_stages = [spr_seed, spr_strawberry_stage1, spr_strawberry_ready];
} else {
    // carrot (по умолчанию)
    spr_stages = [spr_seed, spr_carrot_stage1, spr_carrot_stage2, spr_carrot_ready];
}

// хелперы
function ready_index() {
    return array_length(spr_stages) - 1; // индекс зрелой стадии
}

if (!variable_instance_exists(id, "set_stage_sprite")) {
    function set_stage_sprite() {
        var last = ready_index();
        stage = clamp(stage, 0, last);
        sprite_index = spr_stages[stage];
        image_speed = 0;
        image_index = 0;
    }
}



// применяем спрайт для текущей стадии
set_stage_sprite();

// рост таймерами ВЫКЛЮЧЕН — растём через day_controller
alarm[0] = -1;


// чтобы не прятался под тайлам
depth = -100;
