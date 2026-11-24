// Миска на камне у забора огорода: с пуддингом — пока он там стоит; пустая — после ночи, пока Макс не взяла карту.
// Во время ночной сцены миску рисует obj_cutscene_frog_night (кадры spr_pudding_eaten).
if (!variable_global_exists("pudding_bowl_empty")) global.pudding_bowl_empty = false;
visible = !instance_exists(obj_cutscene_frog_night)
       && (global.pudding_on_porch || (global.pudding_bowl_empty && !global.magic_map_taken));
