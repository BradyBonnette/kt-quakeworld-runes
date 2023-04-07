
//Artifact Quake
//Runes code #11-21
//(C) 1997 Nick "Singe" Bousman
//Give me credit if you modify it. I worked hard on it.
//Modified by Randy Bancroft.  a.k.a. Cannon Fodder

void() Bomb_Think =
{
   if (self.owner.health < 1 || self.owner.runetype != RN_BOMB) { remove(self); return; }

   setorigin(self, self.owner.origin + '0 0 35');

//   self.nextthink = time;
   self.nextthink = time + 0.1;

   self.velocity = self.owner.velocity;
};

void() Rune_Bomb =
{
   local string runetex;

   if (self.runevar == -1 || self.runetime > time) return;

   if (self.runevar > 0)
   {
      sprint(self, PRINT_HIGH, "­Ž");
      runetex = ftos(self.runevar);
      sprint(self, PRINT_HIGH, runetex);
      sprint(self, PRINT_HIGH, "Ž­ ");

      self.runetime = time + 0.5;
      self.runevar = self.runevar - 1;
      sound (self, CHAN_BODY, "buttons/switch04.wav", 1, ATTN_NORM);
      return;
   }

//Prevent the Divine-666 bug
   self.invincible_finished = 0;
   
   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_EXPLOSION);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);

   sprint(self, PRINT_HIGH, "\n");

   self.deathtype = "divinewind";

   T_Damage (self, self, self, 10000);
   T_RadiusDamage (self, self, 10000, self);

//Prevent the Divine-teamplay bug
   if (cvar ("teamplay") != 0)
      T_Damage (self, self, world, 10000);
};

void() Bomb_Arm =
{
   if (self.runevar == -1) self.runevar = 3;
};

void() Bomb_Spawn =
{
   local entity temp;

   temp = spawn();
   temp.movetype = MOVETYPE_FLY;
   temp.solid = SOLID_NOT;
   temp.owner = self;
   setorigin(temp, self.origin);
   setsize(temp, '0 0 0', '0 0 0');
   setmodel(temp, "progs/grenade.mdl");
   temp.avelocity_x = crandom()*360;
   temp.avelocity_y = crandom()*360;
   temp.avelocity_z = crandom()*360;
   temp.think = Bomb_Think;
   temp.nextthink = time + 0.1;
   self.runevar = -1;
};

void() DSpot_Blow =
{
   if (self.owner.runetype == RN_DSPOTS && self.owner.runevar > 0)
      self.owner.runevar = self.owner.runevar - 1;

   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_EXPLOSION);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);

   setmodel(self,"progs/s_bubble.spr");

   T_RadiusDamage (self, self.owner, 200, self);

   remove(self);
};

void() DSpot_Touch =
{
   if (!other.health || other == world) return;

   if (other.runetype == RN_ENVIRO) return;

   if (other.runetype == RN_INTANG && other.runevar == 1) return;

   if (self.owner.runetype == RN_DSPOTS && self.owner.runevar > 0)
      self.owner.runevar = self.owner.runevar - 1;

   T_Damage (other, self, self.owner, 10000);

   sound (self, CHAN_AUTO, "boss2/idle.wav", 1, ATTN_NORM);
   setmodel(self,"");
   self.think = SUB_Remove;
   self.nextthink = time + 1;
};

void() DSpot_Think =
{
   self.nextthink = time + 0.6;

   WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
   WriteByte (MSG_MULTICAST, TE_GUNSHOT);
   WriteByte (MSG_MULTICAST, 3);
   WriteCoord (MSG_MULTICAST, self.origin_x);
   WriteCoord (MSG_MULTICAST, self.origin_y);
   WriteCoord (MSG_MULTICAST, self.origin_z);
   multicast (self.origin, MULTICAST_PVS);

//   particle(self.origin, '0 0 0', 0, 40);

   if (self.runetime < time)
      DSpot_Blow();
};

void() DSpot_Arm =
{
   self.runetime = time + 120;
   self.nextthink = time + 0.01;
   self.think = DSpot_Think;
   self.touch = DSpot_Touch;
   setmodel(self, "");
   sound (self, CHAN_VOICE, "items/inv1.wav", 1, ATTN_NORM);
};

void() Rune_DSpots =
{
   local entity dspot;

   if (self.runevar > 4)
   {
      centerprint(self, "Only 5 Death Spots allowed");
      return;
   }
   self.runevar = self.runevar + 1;

   T_Damage (self, self, self, 20);
   dspot = spawn();
   dspot.movetype = MOVETYPE_FLY;
   dspot.solid = SOLID_TRIGGER;
   dspot.owner = self;
   dspot.classname = "dspot";
   setorigin(dspot, self.origin + '0 0 10');
   setmodel(dspot, "progs/v_spike.mdl");
   setsize(dspot,'0 0 0', '0 0 0');
   dspot.effects = dspot.effects | EF_DIMLIGHT;

   dspot.avelocity_x = crandom()*360;
   dspot.avelocity_y = 100;
   dspot.avelocity_z = crandom()*360;

   dspot.think = DSpot_Arm;
   dspot.nextthink = time + 3;
   sound (dspot, CHAN_WEAPON, "buttons/switch04.wav", 1, ATTN_NORM);

   centerprint(self,"Death Spot created\nRUN!");
};

void() Holo_Think =
{
   if (self.runetime < time)
   {
      if (self.owner.runetype == RN_HOLO && self.owner.runevar > 0)
         self.owner.runevar = self.owner.runevar - 1;
      spawn_tfog (self.origin);
      remove(self);
      return;
   }

   self.angles = self.owner.angles;
   self.angles_y = self.angles_y + self.runevar;
   self.frame = self.owner.frame;

   self.nextthink = time + 0.01;
};

void() Rune_Holo =
{
   local entity hologram;

   if (self.runevar > 4)
   {
      centerprint(self, "Too many fakes!");
      return;
   }
   self.runevar = self.runevar + 1;

   hologram = spawn();
   hologram.movetype = MOVETYPE_NONE;
   hologram.solid = SOLID_NOT;
   hologram.owner = self;
   setmodel(hologram, "progs/player.mdl");
   setorigin(hologram, self.origin);
   setsize(hologram, '0 0 0', '0 0 0');
   hologram.angles = self.angles;
   hologram.colormap = self.colormap;

   hologram.runetime = time + 30;
   hologram.runevar = crandom()*360;

   sound (hologram, CHAN_BODY, "misc/basekey.wav", 1, ATTN_NORM);

   hologram.think = Holo_Think;
   hologram.nextthink = time + 0.1;
};

void() Orb_WanderThink =
{
   if (self.runetime < time)
   {
      WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
      WriteByte (MSG_MULTICAST, TE_TELEPORT);
      WriteCoord (MSG_MULTICAST, self.origin_x);
      WriteCoord (MSG_MULTICAST, self.origin_y);
      WriteCoord (MSG_MULTICAST, self.origin_z);
      multicast (self.origin, MULTICAST_PHS);

      remove(self);
      return;
   }

   self.nextthink = time + 0.5;

//   if (pointcontents(self.origin) == CONTENT_SOLID) setorigin(self, self.owner.origin);

   if (self.flags & FL_ONGROUND)
   {
      self.flags = self.flags - FL_ONGROUND;

      self.avelocity_x = crandom()*360;
      self.avelocity_y = crandom()*360;
      self.avelocity_z = crandom()*360;

      self.velocity_x = crandom()*400;
      self.velocity_y = crandom()*400;
      self.velocity_z = random()*500+100;
   }

   T_RadiusDamage (self, self.owner, 60, self.owner);
};

void() Orb_Think =
{
   if (self.owner.health < 1 || self.owner.runetype != RN_ORB)
   {
      remove(self.runent);

    //Only do bouncies if you get killed with orb. Not dropping runes.
      if (self.owner.health < 1) { self.runetime = time + 20; }

      self.movetype = MOVETYPE_BOUNCE;
      self.nextthink = time + 0.01;
      self.think = Orb_WanderThink;
      self.flags = self.flags-(self.flags & FL_ONGROUND);
      self.velocity = '0 0 1';
      return;
   }

   setorigin(self.runent, self.owner.origin + '0 0 10');
   makevectors(self.runent.angles);

   traceline(self.runent.origin, self.runent.origin + v_forward*120, TRUE, world);

   setorigin(self, trace_endpos-v_forward*10);

   self.nextthink = time + 0.01;

   if (self.runetime > time) return;
   self.runetime = self.runetime + 0.5;

   T_RadiusDamage (self, self.owner, 60, self.owner);
};

void() Orb_Spawn =
{
   local entity axis, orb;

   axis = spawn();
   axis.movetype = MOVETYPE_FLY;
   axis.solid = SOLID_NOT;
   axis.owner = self;
   setorigin(axis, self.origin);
   setsize(axis, '0 0 0', '0 0 0');
   setmodel(axis, "");

   if (random() > 0.5) 
   axis.avelocity_y = 55; else
   axis.avelocity_y = -55;

   orb = spawn();
   orb.movetype = MOVETYPE_FLY;
   orb.solid = SOLID_TRIGGER;
   orb.owner = self;

   orb.flags = orb.flags-(orb.flags&FL_ONGROUND);
   orb.avelocity_x = crandom()*360;
   orb.avelocity_y = crandom()*360;
   orb.avelocity_z = crandom()*360;
//   orb.flags = orb.flags | FL_ONGROUND;

   setorigin(orb, self.origin);
   setsize(orb, '-32 -32 -32', '32 32 32'); //comment this out?

//   setmodel(orb, "progs/s_light.spr");
   setmodel(orb, "progs/teleport.mdl");

   orb.nextthink = time + 0.01;
   orb.think = Orb_Think;
   orb.classname = "deathorb";
   orb.runent = axis;
};

//a predef
entity() SelectRuneSpawnPoint;

entity() SelectBlinkPoint =
{
	local   entity spot, thing;
        local   float   pcount, spottype;
        local   string  blinkspot;

      spottype = random() * 2;
      spottype = ceil(spottype);
//      if (self.runevar == 1)
      if (spottype == 1)
      {
        blinkspot = "info_player_deathmatch";
//        self.runevar = 2;
      }
      else
      {
        blinkspot = "info_teleport_destination";
//        self.runevar = 1;
      }

// choose a info_player_deathmatch point
	spot = lastspawn;
	while (1)
	{
                spot = find(spot, classname, blinkspot);
		if (spot != world)
		{
			if (spot == lastspawn)
				return lastspawn;
			pcount = 0;
			thing = findradius(spot.origin, 50);
			while(thing)
			{
				if (thing.classname == "player")
					pcount = pcount + 1;
				thing = thing.chain;
			}
			if (pcount == 0)
			{
				lastspawn = spot;
				return spot;
			}
		}
	}
	
        spot = find (world, classname, blinkspot);
	if (!spot)
                error ("PutClientInServer: no info_player_start or info_teleport_destination on level");
	
	return spot;
};

void() Rune_Blink =
{
   local entity newent;
   local vector newspot;
   local float loccount;

   if (self.runetime > time) return;
   self.runetime = time + 0.1;

        newent = SelectBlinkPoint ();
        self.origin = newent.origin + '0 0 1';
        self.angles = newent.angles;
	self.fixangle = TRUE;           // turn this way immediately
        self.runevector = self.origin;

//  *************************************************************************
//  disable hook before blinking
        self.hook = self.hook - (self.hook & HOOK_ON);
//  *************************************************************************
        setorigin(self, newent.origin + '0 0 1');

   msg_entity = self;
   WriteByte (MSG_ONE, SVC_SMALLKICK);

   self.velocity = '0 0 0';
};

void() Dot_Think =
{
   if (self.owner.health < 1 || self.owner.runetype != RN_BLINK) { remove(self); return; }

   setorigin(self, self.owner.origin + '0 0 35');

//   self.nextthink = time;
   self.nextthink = time + 0.1;

   self.velocity = self.owner.velocity;
};

void() Dot_Spawn =
{
   local entity dot;

   dot = spawn();
   dot.movetype = MOVETYPE_FLY;
   dot.solid = SOLID_NOT;
   dot.owner = self;
   setorigin(dot, self.origin);
   setsize(dot, '0 0 0', '0 0 0');
   setmodel(dot, "progs/s_bubble.spr");
   dot.think = Dot_Think;
   dot.nextthink = time + 0.01;
};

void() Rune_Camo =
{
   if (self.velocity == '0 0 0' && self.attack_finished < time)
      self.runevar = 1; else self.runevar = 0;
};

void() Rune_Jump =
{
   local entity head, selected;
   local float dist;

   if (self.runetime > time) return;
   self.runetime = self.runetime + 0.2;

   dist = 1000;

   selected = world;
   head = findradius(self.origin, dist);
   while(head)
   {
      if((head.health > 0) && (head != self))
      {
         traceline(self.origin,head.origin,TRUE,self);
         if ( (trace_fraction >= 1) && (vlen(head.origin - self.origin) < dist) )
         {
            selected = head;

            if (selected != world && selected.flags & FL_ONGROUND)
            {
               selected.flags = selected.flags - FL_ONGROUND;
               if (selected.classname == "player")
                  sound (selected, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
               selected.velocity_z = selected.velocity_z + 270;
            }
         }
      }        
      head = head.chain;
   }
};

void() Rune_Ammo =
{
   if (self.runetime > time) return;
   self.runetime = time + 0.6;

   if (self.ammo_shells < 100) self.ammo_shells = self.ammo_shells + 1;
   if (self.ammo_cells < 100) self.ammo_cells = self.ammo_cells + 1;
   if (self.ammo_nails < 200) self.ammo_nails = self.ammo_nails + 2;

   if (self.runevar < time)
   {
      self.runevar = time + 1;
      if (self.ammo_rockets < 100) self.ammo_rockets = self.ammo_rockets + 1;
   }

//   if (self.ammo_nails >= 200)
//   {
//      if (!(self.items & IT_SUPER_NAILGUN))
//      {
//         if (!(self.items & IT_NAILGUN))
            self.items = self.items | IT_NAILGUN;
//         else
            self.items = self.items | IT_SUPER_NAILGUN;
//      }
//      self.ammo_nails = 200;
//   }


//   if (self.ammo_shells >= 100)
//   {
//      if (!(self.items & IT_SUPER_SHOTGUN))
         self.items = self.items | IT_SUPER_SHOTGUN;
//   }

//   if (self.ammo_cells >= 100)
//   {
//      if (!(self.items & IT_LIGHTNING))
         self.items = self.items | IT_LIGHTNING;
//   }

//   if (self.ammo_rockets >= 100)
//   {
//      if (!(self.items & IT_ROCKET_LAUNCHER))
//      {
//         if (!(self.items & IT_GRENADE_LAUNCHER))
            self.items = self.items | IT_GRENADE_LAUNCHER;
//         else
            self.items = self.items | IT_ROCKET_LAUNCHER;
//      }
//   }

   W_SetCurrentAmmo();
};

void() Shield_On =
{
   if (self.runevar > 0)
   {
      if (self.runetime > time) return;
//TEST!
      stuffcmd(self,"v_cshift 0 0 0 0\n");
//      self.effects = self.effects - EF_BRIGHTFIELD;
      self.effects = self.effects - EF_FLAG1;
      self.runevar = 0;
      self.takedamage = DAMAGE_AIM;
      self.runetime = time + 3;
      return;
   }
};

void() Rune_Shield =
{
        local string timeleft;
   if (self.runevar < 1)
   {
      if (self.runetime > time)
      {
         centerprint(self,"Shield Recharging..");
         timeleft = ftos(self.runetime - time);
         sprint(self,PRINT_HIGH, timeleft);
         sprint(self,PRINT_HIGH, " seconds to recharge\n");
         return;
      }
//TEST!
      stuffcmd(self,"v_cshift 256 256 0 70\n");
      sound (self, CHAN_BODY, "items/protect2.wav", 1, ATTN_NORM);
//      self.effects = self.effects | EF_BRIGHTFIELD;
      self.effects = self.effects | EF_FLAG1;
      self.runevar = 1;
      self.takedamage = DAMAGE_NO;
      self.runetime = time + 3;
      return;
   }
};

void () Rune_Vamp =
{
        if (darkcount > 0 && self.runevar == 0)
        {
                self.runevar = 1;
                self.max_health = 200;
                stuffcmd(self,"v_cshift 150 0 0 70\n");
                msg_entity = self;
                WriteShort (MSG_ONE, 12);
                WriteString (MSG_ONE, "h");
        }
        if (darkcount == 0 && self.runevar == 1)
        {
                self.runevar = 0;
                self.max_health = 100;
                stuffcmd(self,"v_cshift 0 0 0 0\n");
                msg_entity = self;
                WriteShort (MSG_ONE, 12);
                WriteString (MSG_ONE, "m");
        }
};
