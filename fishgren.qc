//newmis grenade..  Yes, I dont have a life.  KT  4/20/2k2

.float fish_time;
.float jump_time;
.float fish_jumped;

void() fish_jump =
{
//   self.movetype = MOVETYPE_BOUNCE;
   self.velocity_x = crandom()*550;
   self.velocity_y = crandom()*400;
   self.velocity_z = 520;
   self.avelocity = '200 200 200';
   self.fish_jumped = 1;
};


void() fish_think =
{
   if (self.fish_time < time)
      remove (self);

   if (self.jump_time < time && self.fish_jumped == 0)
      fish_jump();

   self.think = fish_think;
   self.nextthink = time + 0.01;
};

void() fish_touch =
{
	if (other == self.owner)
		return;         // don't explode on owner
//   if (other.takedamage == DAMAGE_AIM)
//   {
//      starburst_explode();
//      return;
//   }
   sound (self, CHAN_WEAPON, "player/inh2o.wav", 1, ATTN_NORM);  // bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};


void() launch_fish =
{

   local float temp;

   sound (self, CHAN_WEAPON, "player/h2ojump.wav", 1, ATTN_NORM);
	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
   newmis.classname = "fish";
	makevectors (self.v_angle);

   if (self.v_angle_x)  //if your looking up, then..
     newmis.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
   else
   {
      newmis.velocity = aim(self, 10000);
      newmis.velocity = newmis.velocity * 600;
      newmis.velocity_z = 200;
   }
	newmis.avelocity = '300 300 300';
   newmis.angles = vectoangles(newmis.velocity);
   newmis.touch = fish_touch;
   newmis.nextthink = time + 0.01; 
   newmis.think = fish_think;

   newmis.fish_time = time + 12;
   newmis.fish_jumped = 0;
   temp = random();

   if (temp <= 0.33)
      newmis.jump_time = time + 5;
   if (temp > 0.33 && temp <= 0.66)
      newmis.jump_time = time + 8;
   if (temp > 0.66)
      newmis.jump_time = time + 10;
      

   setmodel (newmis, "progs/fish.mdl");
	setsize (newmis, '0 0 0', '0 0 0');             
	setorigin (newmis, self.origin);
};
