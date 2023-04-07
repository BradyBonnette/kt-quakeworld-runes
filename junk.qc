//Misc. Junk that we just *have* to throw in there *snicker*.. KT

void() lavatrap =
{
   local entity head, selected;

   selected = world;
   head = findradius(self.origin, 9999999);
   while (head) //if we found someone, then continue
   {
      if (head.classname == "player" && head != self)
      {
         head.watertype = CONTENT_LAVA;
         head.waterlevel = 1;
      }
      head = head.chain;  //if head is 1 (found someone), loop back,  If 0,
                          //quit...
   }
   self.think = lavatrap;
   self.nextthink = time + 0.75;

};

void() telefrag_bomb =
{
   local entity head, selected;

   selected = world;
   head = findradius(self.origin, 9999999);
   while (head) //if we found someone, then continue
   {
      if (head.health > 0 && head.classname == "player" && head != self)
      {
         spawn_tdeath (head.origin, self);
      }
      head = head.chain;  //if head is 1 (found someone), loop back,  If 0,
                          //quit...
   }
};

void() squish =
{
   local entity head;

 //  selected = world;
   head = findradius(self.origin, 9999999);
   while (head) //if we found someone, then continue
   {
      if (head.health > 0 && head.classname == "player" && head != self)
      {
         T_Damage(head, self, self.owner, 999999);   
      }
      head = head.chain;  //if head is 1 (found someone), loop back,  If 0,
                          //quit...
   }
};
void() go_invis =
{
   self.modelindex = modelindex_none;
 //  self.nextthink = time + 0.01;
};

void() screen_thing =
{
   local float timer;
   local float number;

   timer = time + 3;  // 3 second display
   number = 0;

   sprint (self, PRINT_HIGH, "Beginning screen_thing...\n");
//   bprint (PRINT_HIGH, timer);
//   bprint (PRINT_HIGH, "seconds\n");


   if (timer < 3)
   {
      sprint(self, PRINT_HIGH, "heh\n");
    //  number = number + 1;
    //  self.nextthink = time + 1;
   }
};
