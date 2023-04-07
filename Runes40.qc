
//Artifact Quake
//Runes code #31-40
//(C) 1997 Nick "Singe" Bousman
//Give me credit if you modify it. I worked hard on it.
//Modified by Randy Bancroft.  a.k.a. Cannon Fodder

//For the normal balls
void() Ball_Touch =
{
   if (other == self.owner.runent) return;
   if (other.classname == "spikeball") return;

   if ((other.health > 0) && other != self.owner && other.solid != SOLID_BSP)
   {
      T_Damage(other, self, self.owner, 40);
      other.flags = other.flags-(other.flags & FL_ONGROUND);
      other.velocity_z = other.velocity_z + 270;
      sound (other, CHAN_AUTO, "zombie/z_miss.wav", 1, ATTN_NORM);

      self.touch = SUB_Null;
      setmodel(self, "");
   }
};

//For the final balls
void() Ball_Touch2 =
{
   if (pointcontents(self.origin) == CONTENT_LAVA || pointcontents(self.origin) == CONTENT_SOLID) remove(self);

   if (other == self.owner.runent) return;
   if (other.classname == "spikeball") return;

   if ((other.health > 0) && other != self.owner && other.solid != SOLID_BSP)
   {
      T_Damage(other, self, self.owner, 40);
      other.flags = other.flags-(other.flags & FL_ONGROUND);
      other.velocity_z = other.velocity_z + 270;
      sound (other, CHAN_AUTO, "zombie/z_miss.wav", 1, ATTN_NORM);
      remove(self);
   }
};

void() Ball_Move =
{
   if (self.owner.health < 1 || self.owner.runetype != RN_CLOUD) { remove(self); return; }

   self.nextthink = time + 3 + crandom()*0.3;

   setmodel(self, "");
   setorigin(self, self.owner.runent.origin);
   setmodel(self, "progs/v_spike.mdl");

   self.touch = Ball_Touch;
   self.velocity_x = crandom()*200;
   self.velocity_y = crandom()*200;

   self.avelocity_x = crandom()*360;
   self.avelocity_y = crandom()*360;
   self.avelocity_z = crandom()*360;

   self.flags = self.flags-(self.flags & FL_ONGROUND);
};

//For the final balls
void(vector org, entity master) Ball_Spawn =
{
   local entity temp;

   temp = spawn();
   temp.movetype = MOVETYPE_BOUNCE;
   temp.solid = SOLID_TRIGGER;
   temp.owner = master;
   setorigin(temp, self.origin);
   setsize(temp, '-15 -15 -15', '15 15 15');
   setmodel(temp, "progs/v_spike.mdl");
   temp.avelocity_x = crandom()*360;
   temp.avelocity_y = crandom()*360;
   temp.avelocity_z = crandom()*360;
   temp.velocity_x = crandom()*200;
   temp.velocity_y = crandom()*200;
   temp.classname = "spikeball";
   temp.touch = Ball_Touch2;
   temp.think = SUB_Remove;
   temp.nextthink = time + 1 + random()*2;
   if (master.health < 1)
   {
     temp.velocity_z = crandom()*700;
     temp.nextthink = temp.nextthink + 8;
   }
};

//For the normal balls
void() Balls_Spawn =
{
   local entity temp;
   local float n;

   n = 0;
   while (n <= 3)
   {
      n = n + 0.3;

      temp = spawn();
      temp.movetype = MOVETYPE_BOUNCE;
      temp.solid = SOLID_TRIGGER;
      temp.owner = self;
      setorigin(temp, self.runent.origin);
      setsize(temp, '-15 -15 -15', '15 15 15');
      setmodel(temp, "progs/v_spike.mdl");

      temp.flags = temp.flags-(temp.flags & FL_ONGROUND);

      temp.avelocity_x = crandom()*360;
      temp.avelocity_y = crandom()*360;
      temp.avelocity_z = crandom()*360;
      temp.velocity_x = crandom()*200;
      temp.velocity_y = crandom()*200;
      temp.classname = "spikeball";
      temp.touch = Ball_Touch;
      temp.think = Ball_Move;
      temp.nextthink = time + n;
   }
};

void() Cloud_Bye =
{
   local float n;

   n = 0;
   while (n < 15)
   {
      Ball_Spawn(self.origin, self.owner);
      n = n + 1;
   }

   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_TAREXPLOSION);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);

   remove(self);
};

void() Cloud_Think =
{
   if (self.owner.health < 1 || self.owner.runetype != RN_CLOUD)
   {
      self.think = Cloud_Bye;
      self.nextthink = time + 2;
      self.avelocity = '0 0 0';

      if (self.owner.health > 0) remove(self);

      return;
   }

   setorigin(self, self.owner.origin + '0 0 60');
   self.nextthink = time;
};

void() Cloud_Spawn =
{
   local entity temp;

   temp = spawn();
   temp.movetype = MOVETYPE_FLY;
   temp.solid = SOLID_NOT;
   temp.owner = self;
   setorigin(temp, self.origin);
   setsize(temp, '-50 -50 -50', '-50 -50 -50');
   setmodel(temp, "progs/teleport.mdl");
   temp.avelocity_x = crandom()*360;
   temp.avelocity_y = crandom()*360;
   temp.avelocity_z = crandom()*360;
   temp.think = Cloud_Think;
   temp.nextthink = time;
   self.runent = temp;

   Balls_Spawn();
};

void() Rune_Dual =
{
   if (self.runetime > time) return;
   self.runetime = time + 0.1;

   local vector tempv;

   spawn_tfog(self.origin);
   tempv = self.origin;
   spawn_tdeath(self.runevector, self);

//  *************************************************************************
// disable hook before recalling
   self.hook = self.hook - (self.hook & HOOK_ON);
//  *************************************************************************
   setorigin(self, self.runevector);

   self.runevector = tempv;
   spawn_tfog(self.origin);
   self.velocity = '0 0 0';
};

void() Weird_WanderThink =
{
   if (self.runetime < time) {remove(self); return;}

   self.velocity_x = self.velocity_x + crandom()*30;
   self.velocity_y = self.velocity_y + crandom()*30;
   self.velocity_z = self.velocity_z + crandom()*30;

   self.flags = self.flags-(self.flags & FL_ONGROUND);

   self.nextthink = time + 0.5;
};

void() Weird_Think =
{
 //Remove the weirder
   if (self.runent.health < 1 || self.runetime < time || intermission_running)
   {
      if (self.runevar == 1) stuffcmd(self.runent, "v_idlescale 0\n");
      if (self.runevar == 8) stuffcmd(self.runent, "fov 90\n");
      if (self.runevar == 9) stuffcmd(self.runent, "v_cshift 0 0 0 0\n");
      remove(self);
      return;
   }

   self.nextthink = time + 0.1;

//   particle(self.runent.origin + '0 0 25', '0 0 1'*crandom()*500 + '0 1 0'*crandom()*500 + '1 0 0'*crandom()*500, random()*255, 30);

   setorigin(self, self.runent.origin);
   sound(self, CHAN_AUTO, "boss2/idle.wav", 0.3, ATTN_NORM);

 //The weirdness factors
   if (self.runevar == 1)
   {
      if (self.attack_finished > time) return;
      self.attack_finished = time + 0.5;
      stuffcmd(self.runent, "v_idlescale 120\n");
   } else
   if (self.runevar == 2)
   {
      if (self.attack_finished > time) return;
      if (self.runent.flags & FL_ONGROUND)
      {
         self.runent.flags = self.runent.flags - FL_ONGROUND;
         sound (self.runent, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
         self.runent.velocity_z = self.runent.velocity_z + 270;
         self.attack_finished = time + 0.1;
      }
   } else
   if (self.runevar == 3)
   {
      if (self.attack_finished > time) return;
      self.attack_finished = time + 0.5;
      self.runent.angles_y = self.runent.angles_y + crandom()*40;
      self.runent.fixangle = 1;
   } else
   if (self.runevar == 4)
   {
      if (random() > 0.3)
      {
         self.runent.velocity_x = self.runent.velocity_x + crandom()*200;
         self.runent.velocity_y = self.runent.velocity_y + crandom()*200;
         self.runent.velocity_z = self.runent.velocity_z + crandom()*200;

         self.runent.flags = self.runent.flags-(self.runent.flags & FL_ONGROUND);
      }
   } else
   if (self.runevar == 5)
   {
      self.runent.velocity = self.runent.velocity * 2;
   } else
   if (self.runevar == 6)
   {
      self.runent.velocity = self.runent.velocity * -1;
   } else
   if (self.runevar == 7)
   {
      self.runent.attack_finished = time + 0.5;
   } else
   if (self.runevar == 8)
   {
      if (self.attack_finished > time) return;
      self.attack_finished = time + 0.5;
      stuffcmd (self.runent, "fov 160\n");
   }
   if (self.runevar == 9)
   {
      if (self.attack_finished > time) return;
      self.attack_finished = time + 0.5;
      stuffcmd(self.runent, "v_cshift 256 256 256 200\n");
   }
};

void() Weird_Touch =
{
   if (other == world || other.solid == SOLID_BSP)
   {
      self.velocity = self.velocity * -1;
      return;
   }

   if (other.classname == "player" && other.health > 0)
   {
      if (other == self.owner) return;

      self.runent = other;
      self.runetime = time + 15;
      self.touch = SUB_Null;
      self.think = Weird_Think;
      self.nextthink = time + 0.01;
      self.runevar = ceil(random()*9);
      setmodel(self,"");

      sound (self, CHAN_BODY, "boss2/idle.wav", 1, ATTN_NORM);

      if (self.runevar == 1) centerprint(other, " Hit by weirdness! \nžžžžžžžžžžžžžžžžžžžžŸ\nSHROOM MODE!");
      if (self.runevar == 2) centerprint(other, " Hit by weirdness! \nžžžžžžžžžžžžžžžžžžžžŸ\nUNCONTROLLABLE JUMPING!");
      if (self.runevar == 3) centerprint(other, " Hit by weirdness! \nžžžžžžžžžžžžžžžžžžžžŸ\nDRUNKEN WALK!");
      if (self.runevar == 4) centerprint(other, " Hit by weirdness! \nžžžžžžžžžžžžžžžžžžžžŸ\nTWIRLY HEAD!");
      if (self.runevar == 5) centerprint(other, " Hit by weirdness! \nžžžžžžžžžžžžžžžžžžžžŸ\nRANDOM TWITCHING!");
      if (self.runevar == 6) centerprint(other, " Hit by weirdness! \nžžžžžžžžžžžžžžžžžžžžŸ\nTOO MUCH COFFEE!");
      if (self.runevar == 7) centerprint(other, " Hit by weirdness! \nžžžžžžžžžžžžžžžžžžžžŸ\nSTICKY FEET!");
      if (self.runevar == 8) centerprint(other, " Hit by weirdness! \nžžžžžžžžžžžžžžžžžžžžŸ\nHOW DO I SHOOT?!");
      if (self.runevar == 9) centerprint(other, " Hit by weirdness! \nžžžžžžžžžžžžžžžžžžžžŸ\nVERTIGO!");
      if (self.runevar == 10) centerprint(other, " Hit by weirdness! \nžžžžžžžžžžžžžžžžžžžžŸ\nI'M BLIND! I'M BLIND!");
   }
};

void() Spawn_Weird =
{
   local entity temp;

   temp = spawn();
   temp.movetype = MOVETYPE_FLY;
   temp.solid = SOLID_TRIGGER;
   temp.owner = self;
   setorigin(temp, self.origin + '0 0 15');
   setmodel(temp, "progs/s_bubble.spr");
   temp.think = Weird_WanderThink;
   temp.touch = Weird_Touch;
   temp.nextthink = time + 0.01;
   temp.runetime = time + 4 + random()*3;
   self.runent = temp;
};

void() Rune_Weird =
{
   if (self.runetime > time) return;
   self.runetime = time + 2.5;

   Spawn_Weird();

   self.runent.flags = self.runent.flags-(self.runent.flags & FL_ONGROUND);
};

void() Weird_Throw =
{
   if (self.runevar > time) return;
   self.runevar = time + 1;
   self.runetime = time + 2;

   Spawn_Weird();

   makevectors(self.v_angle);
   self.runent.velocity = v_forward*150 + self.velocity;
};

void() Resurrect =
{
   local string num;

   self.runevar = self.runevar - 1;

   self.classname = "player";
   self.max_health = 100;
   self.health = 100;
   self.takedamage = DAMAGE_AIM;
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_WALK;
   self.show_hostile = 0;
   self.flags = FL_CLIENT;
   self.air_finished = time + 12;
   self.dmg = 2;
   self.super_damage_finished = time + 15;
   self.radsuit_finished = 0;
   self.invisible_finished = 0;
   self.invincible_finished = 0;
   self.effects = EF_DIMLIGHT;
   self.invincible_time = 0;
   self.items = self.items | IT_QUAD;
   
   self.weapon = W_BestWeapon();
   W_SetCurrentAmmo ();

sprint(self,PRINT_HIGH, "start \n");
   setorigin(self, self.origin + '0 0 40');
      local entity startent;
      startent = SelectSpawnPoint();
   if (self.watertype == CONTENT_LAVA) setorigin(self, startent.origin);
   if (self.watertype == CONTENT_SLIME) setorigin(self, startent.origin);
   if (self.watertype == CONTENT_WATER) setorigin(self, startent.origin);
   self.attack_finished = time;
   self.th_pain = player_pain;
   self.th_die = PlayerDie;
	
   self.deadflag = DEAD_NO;
   self.pausetime = 0;

   self.modelindex = modelindex_player;

   setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
   self.view_ofs = '0 0 22';

   player_stand1 ();
	
   spawn_tdeath (self.origin, self);

   self.ammo_shells = self.ammo_shells + 25;
   if (self.ammo_shells > 100) self.ammo_shells = 100;

   centerprint(self, "You've risen again!");

   sound (self, CHAN_AUTO, "misc/power.wav", 1, ATTN_NORM);

   ThrowGib("progs/gib1.mdl", (0 - self.health));
   ThrowGib("progs/gib2.mdl", (0 - self.health));
   ThrowGib("progs/gib3.mdl", (0 - self.health));

   sprint(self, PRINT_HIGH, "You got the Quad Damage\n");
   num = ftos(self.runevar);
   sprint(self, PRINT_HIGH, num);
   sprint(self, PRINT_HIGH, " resurrections left.\n");
};

void() Berserk_Bleed =
{
   if (self.runevar > time) return;
   self.runevar = time + 0.2;

   local float r1, r2, r3;
   local vector rvec;

   r1 = crandom()*50;
   r2 = crandom()*50;
   r3 = crandom()*50;

   rvec = '0 0 1'*r1 + '0 1 0'*r2 + '1 0 0'*r3;

   SpawnBlood(self.origin + '0 0 15',(v_right*r1 + v_forward*r2 - '0 0 15'), 30);

};

void() Wall_Check =
{
   if (self.runetime > time) return;
   self.runetime = time + 0.2;

   makevectors(self.v_angle);
   traceline(self.origin, self.origin + v_forward*35, TRUE, self);

   if (trace_fraction == 1) return;

   local float n;
   local vector neworg,oldorg;

   n = 36;
   while (n < 400 && (pointcontents(self.origin + v_forward*n) != CONTENT_EMPTY))
      n = n + 60;

   if (n >= 500) return;

   neworg = self.origin + v_forward*(n + 45);
   oldorg = self.origin;
   
   if (pointcontents(neworg) != CONTENT_EMPTY) return;

   setorigin(self, neworg);
};

//  *********************************************************************************************
//  Extra runes and functions that I added
void () Dark_off =
{
        if ((self.runetype == RN_DARK) && (self.runevar > 0))
        {
//                if (self.runevar > 0)
//                {
//  ************************************************************************
//  turns lights back on
                Lights_on();
//  ************************************************************************

//  ************************************************************************
//  mod for flashlight
//  turn off flashlight
                self.flash_flag = FALSE;
                self.flash.think = SUB_Remove;
//                flash_off();
                centerprint(self, "20 Seconds to Recharge");
//  ************************************************************************
//                }
        }
};

void() Dark_Think =
{
        if (self.runevar > 0)
        {
                if (self.runetime > time) return;
                Dark_off();
                self.runevar = 0;
                self.runetime = time + 20;
                return;
        }
};

void() Rune_Dark =
{
        local string timeleft;
        if (self.runevar > 0)
        {
                if (self.flash_flag == TRUE)

//  ************************************************************************
//  mod for flashlight
//  turn off flashlight
                {
                        self.flash_flag = FALSE;
                        self.flash.think = SUB_Remove;
                }
//  ************************************************************************

                else if (self.flash_flag == FALSE)
                {
//  ************************************************************************
//  mod for flashlight
//  turn on flashlight
                        self.flash_flag = TRUE;
                        flash_on();
//  ************************************************************************

                }
        }
        if (self.runevar < 1)
        {
                if (self.runetime > time)
                {
                        centerprint(self, "Light Absorbers Recharging.");
                        timeleft = ftos(self.runetime - time);
                        sprint(self,PRINT_HIGH, timeleft);
                        sprint(self,PRINT_HIGH, " seconds to recharge\n");
                        return;
                }
                sound (self, CHAN_BODY, "misc/secret.wav", 1, ATTN_NORM);
                self.runevar = 1;
                centerprint (self, "20 Seconds of Darkness");
                self.runetime = time + 20;
//  ************************************************************************
//  turns lights off
                Lights_off();
//  ************************************************************************
                if (self.flash_flag == FALSE)
                {
//  ************************************************************************
//  mod for flashlight
//  turn on flashlight
                self.flash_flag = TRUE;
                flash_on();
//  ************************************************************************
                }
                return;
        }
};

void() Rune_Nomis =
{
   if (self.runetime > time) return;

   self.runetime = self.runetime + 0.1;

   local entity pushee;
   local vector pushdir, pushforce;
   local float pushdist, dist;
   local string pushee_s;

   dist = 800; // 400;

   pushee = findradius(self.origin, dist); //Find the victims.
   while(pushee)
   {
                if ((pushee.classname == "grenade")  || (pushee.classname == "rocket"))
                {
                        pushee.flags = pushee.flags-(pushee.flags & FL_ONGROUND);
                        pushdir = self.origin - pushee.origin;
                        pushdist = vlen (pushdir);
                        pushdir = normalize (pushdir);
                        pushforce = pushdir * 0.45 * (dist - pushdist);
                        pushee.velocity = pushee.velocity - pushforce;
                }
      pushee = pushee.chain;
   }
};
void() Rune_Attract =
{
   if (self.runetime > time && self.runevar == 1) return;

   self.runetime = self.runetime + 0.1;

   local entity pushee;
   local vector pushdir, pushforce;
   local float pushdist, dist;

   dist = 400;

   pushee = findradius(self.origin, dist); //Find the victims.
   while(pushee)
   {
         if (pushee.solid != SOLID_BSP && !self == pushee)
         {
            if (pushee.classname != "player")
               pushee.flags = pushee.flags-(pushee.flags & FL_ONGROUND);
            pushdir = self.origin - pushee.origin;
            pushdist = vlen (pushdir);
            pushdir = normalize (pushdir);
            pushforce = pushdir * 0.45 * (dist - pushdist);
            pushee.velocity = pushee.velocity + pushforce;
         }
      pushee = pushee.chain;
   }
};

void () RemoveAxe =
{
        self.owner.runevar = 0;
        SUB_Remove ();
        self.owner.currentammo = 0;
        self.owner.weaponmodel = "progs/v_axe.mdl";
        self.owner.weaponframe = 0;
};

void () AxeTouch =
{

   if (other == self.owner)
   {
      return ;
   }

   self.avelocity = '300 300 300';
   self.movetype = MOVETYPE_BOUNCE;
   setsize (self,'-1 -2 -3','1 2 3');

        if (other.takedamage)
        {
                spawn_touchblood (40);
                other.axhitme = 1;
                sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
                if (self.owner.runetype == RN_VAXE)
                {
                    T_Damage (other,self,self.owner,5000);
                }
                else
                {
                    T_Damage (other,self,self.owner,40);
                }
                RemoveAxe ();
        }
        else
        {
                sound (self,CHAN_WEAPON,"player/axhit2.wav",TRUE,ATTN_NORM);
                RemoveAxe ();
        }

        if (self.velocity != '0 0 0')
        {
                RemoveAxe ();
        }

};

void () W_ThrowAxe =
{
   local entity missile;

        if (self.runevar != 1)
        {
                sound (self,CHAN_WEAPON,"knight/sword1.wav",1.000,ATTN_NORM);
                missile = spawn ();
                missile.owner = self;
                missile.classname = "runeaxe";
                missile.movetype = MOVETYPE_FLYMISSILE;
                missile.solid = SOLID_TRIGGER;
                makevectors (self.v_angle);
                missile.velocity = aim (self,10000);
                missile.angles = vectoangles (missile.velocity);
               if (missile.owner.super_damage_finished > time)
               {
                    missile.velocity = (missile.velocity * 2400);
               }
               else
               {
                    missile.velocity = (missile.velocity * 600);
               }
                missile.touch = AxeTouch;
                missile.nextthink = (time + 600);
                missile.think = SUB_Remove;
                setmodel (missile,"progs/throwaxe.mdl");
                setsize (missile,'0 0 0','0 0 0');
                setorigin (missile,((self.origin + (v_forward * 2)) + '0 0 16'));
                missile.avelocity = '-500 0 0';
                W_SetCurrentAmmo ();
                missile.owner.weaponmodel = "";
                self.runevar = 1;
        }
};


void () Rune_Axe =
{
	self.items = self.items - (self.items & 
        (IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING | IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
        self.weapon = self.weapon - (self.weapon & 
        (IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING) );
        self.weapon = IT_AXE;
};

void () Pipe =
{
        self.pipes = 0;
        self.items = self.items | IT_GRENADE_LAUNCHER;
        self.ammo_rockets = self.ammo_rockets + 50;
        if (self.ammo_rockets > 100)
        {
                self.ammo_rockets = 100;
        }
        W_SetCurrentAmmo();
        self.impulse = 6;
};
void () Vaxe =
{
//        centerprint(self,"\n\n\n\n\n\n\n\n\n\n Instantly kills your opponents\nwith the axe! ");
        self.impulse = 1;
        W_ChangeWeapon();
        W_ThrowAxe();
};
void() HKSpike =
{
        local vector    org, vec;
        local float             num_shots;
        num_shots = (ceil(random() * 50) /5);  //random amount of shots
                                                //mutiplying by 50 and dividing by five will result in more
                                                //mid-range shots.  Like the dice in D&D
        org = self.origin + self.mins + self.size*0.5 + v_forward * 20; //start just in front
                                                // set missile speed
        vec = normalize (v_forward);
        vec_z = 0 - vec_z + (random() - 0.5)*0.1;
        do      //well this is easy to understand...
        {
                launch_spike (org, vec);        //really is just a spike with a different model
                newmis.classname = "knightspike";
                setmodel (newmis, "progs/k_spike.mdl");
                setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
                newmis.velocity = vec * 1000;    //speed up
                newmis.velocity_x = newmis.velocity_x + ((random() - 0.5) * 128); //random spread
                newmis.velocity_y = newmis.velocity_y + ((random() - 0.5) * 128); //random spread
                newmis.velocity_z = newmis.velocity_z - (2 * newmis.velocity_z); //fixes strange bug*
                sound (self, CHAN_WEAPON, "hknight/attack1.wav", 1, ATTN_NORM);
                num_shots = num_shots - 1;      //hmm...
        }
        while (num_shots > 0);
};


