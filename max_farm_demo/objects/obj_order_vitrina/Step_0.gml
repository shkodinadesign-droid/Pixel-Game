 // === СТОЛ ЗАКАЗОВ / ВИТРИНА (STEP) ===                                                                                                                                                    
                                              
  if (!variable_global_exists("justin_bakery_intro_done")) {                                                                                                                                  
      global.justin_bakery_intro_done = false;              
  }                                                                                                                                                                                           
                                                            
  // --- ПЕРВЫЙ РАЗ: запускаем катсцену с Джастином (только если дневник получен) ---                                                                                                         
  var _has_diary = variable_global_exists("has_diary") && global.has_diary;
  if (!global.justin_bakery_intro_done && !global.control_locked && _has_diary) {
      if (instance_exists(obj_max)) {                                                                                                                                                         
          var _dist = point_distance(obj_max.x, obj_max.y, x, y);
                                                                                                                                                                                              
          if (_dist < 160 && keyboard_check_pressed(ord("E"))) {                                                                                                                              
              if (instance_exists(obj_justin)) {
                  global.control_locked = true;                                                                                                                                               
                  obj_max.direction_facing = "down";                                                                                                                                          
                  obj_max.sprite_index = spr_max_idle_up;
                  obj_max.image_speed  = 0;                                                                                                                                                   
                  obj_max.image_index  = 0;                 
                  with (obj_justin) { cscene_step = 1; }
              }                                                                                                                                                                               
          }                                   
      }                                                                                                                                                                                       
  }  