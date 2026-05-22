 sprite_index = spr_justin_idle_down;                                                                                                                                                        
  image_speed = 0;                                                                                                                                                                            
  image_index = 0;                                                                                                                                                                            
  visible = false;                                                                                                                                                                            
                                                                                                                                                                                              
  if (!variable_global_exists("justin_bakery_intro_done")) {
      global.justin_bakery_intro_done = false;                                                                                                                                                
  }                                                         
  if (global.justin_bakery_intro_done) {                                                                                                                                                      
      instance_destroy();
      exit;                                                                                                                                                                                   
  }                                                         
                                                                                                                                                                                              
  cscene_step = 0;                                          
  if (!variable_global_exists("justin_enter_trigger")) global.justin_enter_trigger = false;                                                                                                   
                                              
  walk_spd    = 1.2;
  entry_timer = -1;                                                                                                                                                                               
                                                            
  counter_justin_x = 160;                                                                                                                                                                     
  counter_justin_y = 356;                 
                                                                                                                                                                                              
  wp1_x = 220; wp1_y = 570; wp1_reached = false;  // обход стула снизу
  wp2_x = 220; wp2_y = 380; wp2_reached = false;  // выше стула → потом к стойке

  leave_wp1_x = 220; leave_wp1_y = 380; leave_wp1_done = false; // уход: сначала вверх
  leave_wp2_x = 220; leave_wp2_y = 570; leave_wp2_done = false; // потом вниз к выходу                                                                                                                                                                      
   
