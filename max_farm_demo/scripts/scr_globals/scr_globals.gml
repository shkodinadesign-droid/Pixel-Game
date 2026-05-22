#macro CELL 32

enum CropStage { Seed, S1, S2, S3, Ready }

enum Tool { None = 0, WateringCan = 1, Shovel = 2 }

enum DoorDir { Up, Down, Left, Right }

// ID предметов инвентаря
#macro ITEM_CARROT     "carrot"
#macro ITEM_SEED       "carrot_seed"
#macro ITEM_CARROT_PIE    "carrot_pie"
#macro ITEM_CARROT_MUFFIN "carrot_muffin"
#macro ITEM_POTATO         "potato"
#macro ITEM_STRAWBERRY     "strawberry"
#macro ITEM_POTATO_SEED    "potato_seed"
#macro ITEM_STRAWBERRY_SEED "strawberry_seed"
#macro ITEM_APPLE  "apple"
#macro ITEM_PEAR   "pear"
#macro ITEM_PEACH  "peach"
