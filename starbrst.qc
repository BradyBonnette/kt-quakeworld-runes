//just an idea...  KT

float counter;

//.vector temp_velocity;

void() burst_blow =
{
   T_RadiusDamage (self, self.owner, 120, world);
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

   remove(self);
};

void() starburst_think =
{
   local vector temp_vector;
   local vector temp_origin;
   local vector temp_velocity;

   temp_origin = self.origin;
   temp_velocity = self.velocity;

   remove (self);

   if (self.burst_counter == 1)
   {
      makevectors(temp_velocity);
      temp_vector = temp_velocity + (v_forward*300 + v_up*450 + v_right*0); // forward
      spawn_bursts(temp_origin, temp_vector);
   }
   if (self.burst_counter == 2)
   {
      makevectors(temp_velocity);
      temp_vector = temp_velocity + (v_forward*300 + v_up*450 + v_right*300); //forward + right
      spawn_bursts(temp_origin, temp_vector);
   }
   if (self.burst_counter == 3)
   {
      makevectors(temp_velocity);
      temp_vector = temp_velocity + (v_forward*0 + v_up*450 + v_right*300); //right
      spawn_bursts(temp_origin, temp_vector);
   }
   if (self.burst_counter == 4)
   {
      makevectors(temp_velocity);
      temp_vector = temp_velocity + (v_forward*-300 + v_up*450 + v_right*300); //right + back
      spawn_bursts(temp_origin, temp_vector);
   }
   if (self.burst_counter == 5)
   {
      makevectors(temp_velocity);
      temp_vector = temp_velocity + (v_forward*-300 + v_up*450 + v_right*0); //back
      spawn_bursts(temp_origin, temp_vector);
   }
   if (self.burst_counter == 6)
   {
      makevectors(temp_velocity);
      temp_vector = temp_velocity + (v_forward*-300 + v_up*450 + v_right*-300); //back + left
      spawn_bursts(temp_origin, temp_vector);
   }
   if (self.burst_counter == 7)
   {
      makevectors(temp_velocity);
      temp_vector = temp_velocity + (v_forward*-300 + v_up*450 + v_right*0); //left
      spawn_bursts(temp_origin, temp_vector);
   }
   if (self.burst_counter == 8)
   {
      makevectors(temp_velocity);
      temp_vector = temp_velocity + (v_forward*300 + v_up*450 + v_right*-300); //forward + left
      spawn_bursts(temp_origin, temp_vector);
   }
   remove (self);

};

void(vector new_origin, vector new_velocity) spawn_bursts =
{
   local entity burst;

   burst = spawn ();
   burst.owner = self;
   burst.movetype = MOVETYPE_BOUNCE;
   burst.solid = SOLID_BBOX;
   burst.classname = "grenade";
   burst.angles = vectoangles(burst.velocity);
   burst.avelocity = '300 300 300';
   burst.classname = "starburst";
//    burst.touch = starburst_touch;
   setsize (burst, '0 0 0', '0 0 0');             
   setorigin (burst, new_origin);
   setmodel (burst, "progs/grenade.mdl");
   burst.velocity = new_velocity;

   burst.owner.burst_counter = burst.owner.burst_counter + 1;
   burst.think = burst_blow;
   burst.nextthink = time + 1.15;

};

void() starburst_explode =
{
   T_RadiusDamage (self, self.owner, 120, world);
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

   self.burst_counter = 1;

   self.think = starburst_think;
   self.nextthink = time + 0.01;
};

void() starburst_touch =
{
	if (other == self.owner)
		return;         // don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
      starburst_explode();
		return;
	}
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);  // bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

void() fire_starburst =
{       
//   self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
   newmis.classname = "starburst";
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
   newmis.touch = starburst_touch;
   newmis.nextthink = time + 1.5; 
   newmis.think = starburst_explode;

	setmodel (newmis, "progs/grenade.mdl");
	setsize (newmis, '0 0 0', '0 0 0');             
	setorigin (newmis, self.origin);

   newmis = starburst_entity;
};
