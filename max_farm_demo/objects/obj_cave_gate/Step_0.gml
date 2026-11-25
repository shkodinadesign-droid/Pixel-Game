// ===== ЗАСЛОН ПРОХОДА В ПЕЩЕРУ: исчезает после разговора с Джо =====
forest_episode_init();
if (global.jack_cave_talk_done) instance_destroy();
