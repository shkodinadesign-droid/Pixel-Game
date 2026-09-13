// =====================
// NEIGHBOR (CREATE)
// =====================

// По сценарию персонажа "соседка" не существует — знакомство и передачу
// дневника делает Бабуля Мэгги (obj_grandma_Maggie, срабатывает после полива).
// Объект оставлен в комнате, но отключён.
instance_destroy();
exit;

// Стартуем за левым краем экрана на уровне дороги
x = -150;
y = 288;

visible     = true;
image_blend = c_white;
image_alpha = 1;
can_talk    = true;
move_speed  = 1.5;

sprite_index = spr_magiie_walk_right;
image_speed  = 0.5;

intro_done   = false;
leaving      = false;
approaching  = true;
target_x     = 0;
target_y     = 0;
