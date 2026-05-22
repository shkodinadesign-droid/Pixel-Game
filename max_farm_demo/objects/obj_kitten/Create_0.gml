// ===== КОТИК — CREATE =====

if (instance_number(obj_kitten) > 1) { instance_destroy(); exit; }

persistent = true;

kitten_name = "Кексик";

// Состояния: "follow", "sit_near", "walk_to_max", "wander", "walking_to_bed", "sleeping", "petting_react"
state    = "wander";
walk_spd = 0.8;

// Блуждание
wander_x     = x;
wander_y     = y;
wander_timer = 0;
wander_dir   = 0;  // текущее направление движения (для плавных поворотов)

// Подстилка — у дома Макса (дверь дома x=496, y=208)
bed_x = 540;
bed_y = 280;

sleep_timer = 400 + irandom(400);

// Гладить
pet_timer   = 0;
heart_alpha = 0;

// Сон
zzz_timer = 0;

// Область блуждания (rm_farm) — только нижняя открытая зона, выше дома/сарая
wander_x1 = 150;
wander_y1 = 400;
wander_x2 = 820;
wander_y2 = 680;

// Сцена с Мэгги — следование и посадка
follow_id    = noone;  // за кем следуем
sit_target_x = -1;
sit_target_y = -1;

// Домашняя рутина — котик НЕ делает room_goto, а телепортируется по координатам
// kitten_room — "логическая" комната котика (независимо от того, где игрок)
kitten_room   = rm_farm;
farm_door_x   = 496;   // дверь дома на ферме (цель ходьбы перед уходом)
farm_door_y   = 240;
house_bed_x   = 31;    // центр кровати в rm_house_inside (obj_bed x=32, y=288, origin bottom-center)
house_bed_y   = 252;
farm_return_x = 540;   // точка появления на ферме утром (у подстилки)
farm_return_y = 280;

_initialized = false;
depth = -bbox_bottom;

// На День 2 до прихода Мэгги — кот невидим с самого создания
var _kday = instance_exists(obj_day_controller) ? obj_day_controller.day_index : 1;
if (_kday >= 2 && variable_global_exists("kitten_arrived") && !global.kitten_arrived) {
    visible = false;
}
