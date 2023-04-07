
//Artifact Quake
//Runes code #21-30
//(C) 1997 Nick "Singe" Bousman
//Give me credit if you modify it. I worked hard on it.
//Modified by Randy Bancroft.  a.k.a. Cannon Fodder


void() FleaThink =
{
        local string fleaflg;
        if ((self.owner.fleaflag == 0)|| (self.owner.runetype == RN_FLEAS)) // if you get to water or flea flag cleared it stops
        {                                                               // flea flag cleared if owner died
                remove(self);
                return;
        }
        T_Damage (self.owner, self, self.fleaowner, 5); // do damage
        sound (self.owner, CHAN_AUTO, "fish/idle.wav", 1, ATTN_NORM);
        self.nextthink = time + 5; 
};      

void(entity flearcvr, entity fleaownr) GetFleas =
{
        local   entity fleas;
        fleas = spawn (); 
        fleas.owner = flearcvr; // flea entity belongs to victim
        fleas.fleaowner = fleaownr; // who fleas came from
        fleas.movetype = MOVETYPE_NONE;
        fleas.solid = SOLID_NOT;
        fleas.classname = "fleas";
        fleas.owner.fleaflag = 1;
                          
        setmodel (fleas, "");
        setsize (fleas, '0 0 0', '0 0 0');             
        setorigin (fleas, '0 0 0');
                          
        fleas.nextthink = time + 1;
        fleas.think = FleaThink;
};

void() Rune_Fleas =
{
   if (self.runetime > time) return;

   self.runetime = time + 0.1;

   local entity head, selected;

   selected = world;
   head = findradius(self.origin, 60);
   while(head)
   {
      if(head.health > 0 && head != self)
      {
         selected = head;

         if (selected != world && selected.solid != SOLID_BSP)
         {
            if ((selected.runetype != RN_FLEAS) || (selected.runetype == RN_INTANG && selected.runevar == 0))// don't have camel flea rune
                                                                                                             // or active rune of intangibility
            {
                if (selected.fleaflag == 0) //not already infested
                {
                        sound (self, CHAN_AUTO, "blob/land1.wav", 1, ATTN_NORM);
                        centerprint(selected,"You have Fleas!\n\nTake a bath!");
                        GetFleas(selected,self);  // give fleas to victim
                }

            }
         }
      }        
      head = head.chain;
   }
};

void () Flea_Button =
{
        centerprint(self,"Thy Fleas Infect\n\nAll Who Touch Thee");
};

void () Intang_Button =
{
        local string timeleft;

        if (self.runevar == 0 && self.runetime < time)
        {
                self.runevar = 1;
                self.runetime = time + 30;
                centerprint(self,"Intangible\n\n30 seconds max.");
                stuffcmd(self,"v_cshift 100 0 100 120\nbf\n");
                self.takedamage = DAMAGE_NO;
		self.hook = self.hook - (self.hook & HOOK_ON);

        }
        else if (self.runevar == 0 && self.runetime > time)
        {
                timeleft = ftos(self.runetime - time);
                sprint(self,PRINT_HIGH, timeleft);
                sprint(self,PRINT_HIGH, " seconds to recharge\n");
        }
        else 
        {
                self.runevar = 0;
                self.runetime = time + 10;
                stuffcmd(self,"v_cshift 0 0 0 1\nbf\n");
                centerprint(self,"Tangible\n\n10 seconds to recharge");
                self.takedamage = DAMAGE_AIM;
        }
};

void () IntangThink =
{
        if (self.runevar == 1 && self.runetime <= time)
        {
                Intang_Button ();
        }
};

void () Neutron_Time =
{
        local string timeleft;
        timeleft = ftos(self.runetime - time);
        sprint(self,PRINT_HIGH, timeleft);
        sprint(self,PRINT_HIGH, " seconds to detonation\n");
        
};

void() Neutron_Blow =
{
        local entity nukee;
        local float dist;
        
        dist = 50000;

        nukee = findradius(self.origin, dist); //Find the victims.
        while(nukee)
        {
                if (nukee.classname == "player" && nukee.waterlevel < 3)
                {
                        if (nukee.runetype != RN_ENVIRO)
                        {
                                T_Damage(nukee, self, self.owner, 5000);
                        }
                }
                nukee = nukee.chain;
        }
        sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
};

void() Neutron_Think =
{
        local float nextneutron;
        local string mytemp;

        if (self.owner.health < 1)
        {
                neutrondonetime = time + nextneutron;
                neutroncount = neutroncount - 1;
                remove(self);
                return;
        }

        setorigin(self, self.owner.origin); // + '0 0 35');

        self.nextthink = time + 0.1;

        self.velocity = self.owner.velocity;

        if (((self.owner.runetime - time) < 10.1) && (self.owner.runevar == 1))
        {
                stuffcmd(self.owner,"say 10 seconds to Neutron detonation!\n");
                self.owner.runevar = 2;
        }

        if (((self.owner.runetime - time) < 5.1) && (self.owner.runevar == 2))
        {
                stuffcmd(self.owner,"say 5 seconds to Neutron detonation!\n");
                self.owner.runevar = 3;
        }

        if (self.owner.runetime <= time)
        {
                Neutron_Blow();
                stuffcmd(self.owner,"v_cshift 0 0 0 1\n");
                self.owner.max_health = 100;
                self.owner.runevar = 0;
                self.owner.runetime = time;
                self.owner.runevector = '0 0 0';
                self.owner.touch = SUB_Null;
                self.owner.runetype = 0;
                centerprint(self.owner,"Neutron Bomb Detonated");
               if (timelimit > 0)
               {
                    nextneutron = (timelimit / neutronflag);
                    if (nextneutron < 60)
                    {
                         nextneutron = 60;
                    }
               }
               else
               {
                    nextneutron = 3600; // drop next neutron rune 1 hour later
               }

                neutrondonetime = time + nextneutron;
                neutroncount = neutroncount - 1;
                remove(self);

        }
};

void() Neutron_Spawn =
{
   local entity temp;
   local string mytemp;

   temp = spawn();
   temp.movetype = MOVETYPE_FLY;
   temp.solid = SOLID_NOT;
   temp.owner = self;
   temp.owner.runetime = time;
   temp.owner.runetime = temp.owner.runetime + 20;
   temp.effects = EF_BRIGHTLIGHT;
   temp.classname = "neutron";
   setorigin(temp, self.origin);
   setsize(temp, '0 0 0', '0 0 0');
   setmodel(temp, "progs/invulner.mdl");
   temp.think = Neutron_Think;
   temp.nextthink = time + 0.1;
   self.runevar = 1;
   stuffcmd(self,"say 20 seconds to Neutron detonation!\n");
   stuffcmd(self,"say Kill me or get underwater!\n");


   mytemp = ftos(temp.owner.runetime - time);
};

void () Myth_Armor =
{
     self.armortype = 0.8;
     self.armorvalue = 200;
     self.items = self.items - (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + IT_ARMOR3;
};

void () Pack_Heal =
{
     if (self.health < 100 && self.runevar > 0)
     {
          self.health = self.health + 25;
          if (self.health > 100)
          {
               self.health = 100;
          }
          self.runevar = self.runevar - 1;
     }
     if (self.runevar == 4)
     {
          centerprint(self, "\n\n4 of 4 med kits in pack\n");
     }
     else
     if (self.runevar == 3)
     {
          centerprint(self, "\n\n3 of 4 med kits in pack\n");
     }
     else
     if (self.runevar == 2)
     {
          centerprint(self, "\n\n2 of 4 med kits in pack\n");
     }
     else
     if (self.runevar == 1)
     {
          centerprint(self, "\n\n1 of 4 med kits in pack\n");
     }
     else
     if (self.runevar == 0)
     {
          centerprint(self, "\n\n0 of 4 med kits in pack\n\nPick up some more!");
     }
};

void () Get_Pack =
{
     self.runevar = 4;
     self.ammo_shells = self.ammo_shells + 100;
     if (self.ammo_shells > 200)
     {
          self.ammo_shells = 200;
     }
     self.ammo_nails = self.ammo_nails + 200;
     if (self.ammo_nails > 400)
     {
          self.ammo_nails = 400;
     }
     self.ammo_rockets = self.ammo_rockets + 100;
     if (self.ammo_rockets > 200)
     {
          self.ammo_rockets = 200;
     }
     self.ammo_cells = self.ammo_cells + 100;
     if (self.ammo_cells > 200)
     {
          self.ammo_cells = 200;
     }
};

/*  not used
void() Thief_Touch =
{
   if (other == world) return;
//   if (other.takedamage != DAMAGE_AIM) return;
   if (other.classname != "player") return;
   if (self.runetime > time) return;

   self.runetime = time + 0.5;

   local entity head, selected;

//   other.flags = other.flags-(other.flags & FL_ONGROUND);
//   other.velocity = other.velocity + '0 0 200' + self.velocity*3;
//   self.velocity = '0 0 0' - self.velocity;
   sound (self, CHAN_AUTO, "zombie/z_miss.wav", 1, ATTN_NORM);
//   self.runevar = 10;
//   T_Damage(other, self, self, (40+random()*10));
//   self.runevar = 0;
};
*/

void() Rune_Thief =
{
//   if (self.velocity == '0 0 0') return;
   if (self.runetime > time) return;

   self.runetime = time + 0.5;

   local entity head, selected;
   local float stolen;

//   selected = world;
   head = findradius(self.origin, 60);
   while(head)
   {
      if(head.health > 0 && head != self)
      {
         selected = head;

         if (selected.classname == "player")
         {
               if ((selected.armortype*selected.armorvalue) > (self.armortype*self.armorvalue))
               {
                    self.armortype = selected.armortype;
                    self.armorvalue = selected.armorvalue;
                    self.items = self.items - (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
                    self.items = self.items + (selected.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
                    selected.items = selected.items - (selected.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
                    selected.armortype = 0;
                    selected.armorvalue = 0;
                    centerprint(selected,"Your armor has been stolen!");
               }
               else
               if ((!(self.items & IT_LIGHTNING)) && (selected.items & IT_LIGHTNING) && (selected.weapon != IT_LIGHTNING))
               {
                    self.items = self.items + (self.items & IT_LIGHTNING);
                    if (selected.ammo_cells > 5)
                    {
                         selected.ammo_cells = selected.ammo_cells - 5;
                         stolen = 5;
                    }
                    else
                    if (selected.ammo_cells < 5)
                    {
                         stolen = selected.ammo_cells;
                         selected.ammo_cells =  0;
                    }
                    self.ammo_cells = self.ammo_cells + stolen;
                    if (self.ammo_cells > 100)
                    {
                         self.ammo_cells = 100;
                    }
                    selected.items = selected.items - (selected.items & IT_LIGHTNING);
                    centerprint(selected,"Your lightning gun has been stolen!");
               }
               else
               if ((!(self.items & IT_ROCKET_LAUNCHER)) && (selected.items & IT_ROCKET_LAUNCHER) && (selected.weapon != IT_ROCKET_LAUNCHER))
               {
                    self.items = self.items + (self.items & IT_ROCKET_LAUNCHER);
                    if (selected.ammo_rockets > 5)
                    {
                         selected.ammo_rockets = selected.ammo_rockets - 5;
                         stolen = 5;
                    }
                    else
                    if (selected.ammo_rockets < 5)
                    {
                         stolen = selected.ammo_rockets;
                         selected.ammo_rockets =  0;
                    }
                    self.ammo_rockets = self.ammo_rockets + stolen;
                    if (self.ammo_rockets > 100)
                    {
                         self.ammo_rockets = 100;
                    }
                    selected.items = selected.items - (selected.items & IT_ROCKET_LAUNCHER);
                    centerprint(selected,"Your rocket launcher has been stolen!");
               }
               else
               if ((!(self.items & IT_GRENADE_LAUNCHER)) && (selected.items & IT_GRENADE_LAUNCHER) && (selected.weapon != IT_GRENADE_LAUNCHER))
               {
                    self.items = self.items + (self.items & IT_GRENADE_LAUNCHER);
                    if (selected.ammo_rockets > 5)
                    {
                         selected.ammo_rockets = selected.ammo_rockets - 5;
                         stolen = 5;
                    }
                    else
                    if (selected.ammo_rockets < 5)
                    {
                         stolen = selected.ammo_rockets;
                         selected.ammo_rockets =  0;
                    }
                    self.ammo_rockets = self.ammo_rockets + stolen;
                    if (self.ammo_rockets > 100)
                    {
                         self.ammo_rockets = 100;
                    }
                    selected.items = selected.items - (selected.items & IT_GRENADE_LAUNCHER);
                    centerprint(selected,"Your grenade launcher has been stolen!");
               }
               else
               if ((!(self.items & IT_SUPER_NAILGUN)) && (selected.items & IT_SUPER_NAILGUN) && (selected.weapon != IT_SUPER_NAILGUN))
               {
                    self.items = self.items + (self.items & IT_SUPER_NAILGUN);
                    if (selected.ammo_nails > 10)
                    {
                         selected.ammo_nails = selected.ammo_nails - 10;
                         stolen = 10;
                    }
                    else
                    if (selected.ammo_nails < 10)
                    {
                         stolen = selected.ammo_nails;
                         selected.ammo_nails =  0;
                    }
                    self.ammo_nails = self.ammo_nails + stolen;
                    if (self.ammo_nails > 200)
                    {
                         self.ammo_nails = 200;
                    }
                    selected.items = selected.items - (selected.items & IT_SUPER_NAILGUN);
                    centerprint(selected,"Your super nailgun has been stolen!");
               }
               else
               if ((!(self.items & IT_NAILGUN)) && (selected.items & IT_NAILGUN) && (selected.weapon != IT_NAILGUN))
               {
                    self.items = self.items + (self.items & IT_NAILGUN);
                    if (selected.ammo_nails > 10)
                    {
                         selected.ammo_nails = selected.ammo_nails - 10;
                         stolen = 10;
                    }
                    else
                    if (selected.ammo_nails < 10)
                    {
                         stolen = selected.ammo_nails;
                         selected.ammo_nails =  0;
                    }
                    self.ammo_nails = self.ammo_nails + stolen;
                    if (self.ammo_nails > 200)
                    {
                         self.ammo_nails = 200;
                    }
                    selected.items = selected.items - (selected.items & IT_NAILGUN);
                    centerprint(selected,"Your nailgun has been stolen!");
               }
               else
               if ((!(self.items & IT_SUPER_SHOTGUN)) && (selected.items & IT_SUPER_SHOTGUN) && (selected.weapon != IT_SUPER_SHOTGUN))
               {
                    self.items = self.items + (self.items & IT_SUPER_SHOTGUN);
                    if (selected.ammo_shells > 5)
                    {
                         selected.ammo_shells = selected.ammo_shells - 5;
                         stolen = 5;
                    }
                    else
                    if (selected.ammo_shells < 5)
                    {
                         stolen = selected.ammo_shells;
                         selected.ammo_shells =  0;
                    }
                    self.ammo_shells = self.ammo_shells + stolen;
                    if (self.ammo_shells > 100)
                    {
                         self.ammo_shells = 100;
                    }
                    selected.items = selected.items - (selected.items & IT_SUPER_SHOTGUN);
                    centerprint(selected,"Your super shotgun has been stolen!");
               }
               else
               if ((self.ammo_cells < 100) && (selected.ammo_cells > 1))
               {
                    stolen = 100 - self.ammo_cells;
                    if (selected.ammo_cells - stolen < 2)
                    {
                         self.ammo_cells = self.ammo_cells + selected.ammo_cells - 1;
                         selected.ammo_cells = 1;
                    }
                    else
                    {
                         self.ammo_cells = self.ammo_cells + stolen;
                         selected.ammo_cells = selected.ammo_cells - stolen;
                    }
                    sprint(selected,PRINT_MEDIUM,"Your cells have been stolen!");
               }
               else
               if ((self.ammo_rockets < 100) && (selected.ammo_rockets > 1))
               {
                    stolen = 100 - self.ammo_rockets;
                    if (selected.ammo_rockets - stolen < 2)
                    {
                         self.ammo_rockets = self.ammo_rockets + selected.ammo_rockets - 1;
                         selected.ammo_rockets = 1;
                    }
                    else
                    {
                         self.ammo_rockets = self.ammo_rockets + stolen;
                         selected.ammo_rockets = selected.ammo_rockets - stolen;
                    }
                    sprint(selected,PRINT_MEDIUM,"Your rockets have been stolen!");
               }
               else
               if ((self.ammo_nails < 200) && (selected.ammo_nails > 1))
               {
                    stolen = 200 - self.ammo_nails;
                    if (selected.ammo_nails - stolen < 2)
                    {
                         self.ammo_nails = self.ammo_nails + selected.ammo_nails - 1;
                         selected.ammo_nails = 1;
                    }
                    else
                    {
                         self.ammo_nails = self.ammo_nails + stolen;
                         selected.ammo_nails = selected.ammo_nails - stolen;
                    }
                    sprint(selected,PRINT_MEDIUM,"Your nails have been stolen!");
               }
               else
               if ((self.ammo_shells < 100) && (selected.ammo_shells > 1))
               {
                    stolen = 100 - self.ammo_shells;
                    if (selected.ammo_shells - stolen < 2)
                    {
                         self.ammo_shells = self.ammo_shells + selected.ammo_shells - 1;
                         selected.ammo_shells = 1;
                    }
                    else
                    {
                         self.ammo_shells = self.ammo_shells + stolen;
                         selected.ammo_shells = selected.ammo_shells - stolen;
                    }
                    sprint(selected,PRINT_MEDIUM,"Your shells have been stolen!");
               }
         }
      }        
      head = head.chain;
   }
};
//KT:  Lets insert the damn shambler already
//predefs for the Shambler Helper
void() sham_stand1;
void() sham_walk1;
void() sham_run1;
void() sham_die;
void() sham_melee;
void() sham_magic1;
void(entity attacker, float damage) sham_pain;
void() walkmonster_start;

void() Rune_ShamblerDie =
{
   spawn_tfog(self.origin);
   remove(self);
};

void() Rune_ShamblerReloc =
{
   spawn_tfog(self.runent.origin);
   setorigin(self.runent, self.origin);
   spawn_tfog(self.runent.origin);
   self.runent.angles = self.angles;
   self.runent.fixangle = 1;
};

void() Rune_ShamblerThink =
{
	//if (self.runent.health < 300 && self.runent.health > 0)	bprint(PRINT_MEDIUM, "Shambler Hungry!  Must eat meat!\n"); 
	// if (self.owner.runetype != RN_SHAMB || self.owner.health < 1)
	
  if (self.owner.health < 1)
   {
      if (self.owner.health < 1)
      {
        self.runent.health = 0;
      //   Killed (self.runent, self.owner);
         remove(self.runent);
      }
      else
      {
         spawn_tfog(self.runent.origin);
         remove(self.runent);
         return;
      }
      remove(self);
      return;
   }

 //The end to passive shamblers
  if (self.runent.enemy == self.runent.owner || self.runent.enemy.health < 1 || self.runent.enemy.classname == "worldspawn")
  
   {
      local entity head, selected;
      local float dist;
   
      dist = 2000;

      selected = world;
      head = findradius(self.runent.origin, dist);
      while(head)
      {
         if((head.health > 0) && (head != self.runent) && (head != self.runent.owner))
         {
            traceline(self.runent.origin,head.origin,TRUE,self.runent);
            if ((trace_fraction >= 1) && (vlen(head.origin - self.runent.origin) < dist) )
            {
               selected = head;

               if ((selected != world) && (selected != self.runent.owner))
               {
               		self.runent.enemy = selected;
               }
            }
         }        
         head = head.chain;
      }

   }

   self.nextthink = time + 0.25;
};

void(vector pos) ShamblerTurd = {

	local   entity new;
	local float f;
	new = spawn();
	
	//new.origin = pos;
	
	f = crandom()*10;
	
	
	if (f < 3)
		setmodel (new, "progs/gib1.mdl");
	else if (f >= 3 || f <6)
		setmodel (new, "progs/gib2.mdl");
	else
			setmodel (new, "progs/gib3.mdl");
	
	f = crandom()*10;
	
	if (f <= 1)
		sound (self, CHAN_VOICE, "frt1.wav", 1, ATTN_NORM);
	else if (f >=2 && f < 4)
		sound (self, CHAN_VOICE, "frt2.wav", 1, ATTN_NORM);
	else if (f >= 4 && f < 6)
		sound (self, CHAN_VOICE, "frt3.wav", 1, ATTN_NORM);
	else if (f >= 6 && f < 8)
		sound (self, CHAN_VOICE, "frt4.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "frt5.wav", 1, ATTN_NORM);
	
	setsize (new, '0 0 0', '0 0 0');
    setorigin(new, self.origin + '0 0 10');
    
    
//	new.velocity = v_forward*crandom()*150 + v_up*crandom()*150 + v_right*crandom()*65

	makevectors(self.runent.angles);
	new.velocity = v_forward*-500 + v_up*crandom()*350 + v_right*crandom();
	//new.velocity = '0 200 0';
	
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	
	//new.classname = "";
	//new.avelocity_x = random()*600;
	//new.avelocity_y = random()*600;
	//new.avelocity_z = random()*600;
	
	new.think = SUB_Remove;
	
	//new.ltime = time;
	
	new.nextthink = time + 10 + random()*10;
	new.frame = 0;
	new.flags = 0;

};
void() ShamblerBowelThink = {

	if (self.runent.health < 0) {
		remove(self);
		return;
	}
	
	local entity temp;	
	setorigin(self, self.runent.origin);
	
	if (self.runent.health > 0) {
		temp = self;
    	self = self.runent;
    	self.think = self.th_run;
    	self.nextthink = time + 0.5; //boobs
    	self = temp;
		ShamblerTurd(self.runent.origin);
    }
    
	self.nextthink = time + 2 + crandom()*10;
};

void() Rune_ShamblerSpawn =
{
	
   local entity sham;
   local entity temp;
   local entity shamctrl;
   local entity shambowelctrl;

   sham = spawn();
   sham.solid = SOLID_SLIDEBOX;
   sham.movetype = MOVETYPE_STEP;
   setmodel (sham, "progs/shambler.mdl");
   setorigin(sham, self.origin);
   setsize (sham, VEC_HULL2_MIN, VEC_HULL2_MAX);
   sham.angles = self.angles;
   sham.fixangle = 1;
   sham.health = 400;
   sham.flags = sham.flags | FL_MONSTER;
   sham.th_stand = sham_stand1;
   sham.th_walk = sham_walk1;
   sham.th_run = sham_run1;
   sham.th_die = sham_die;
   sham.th_melee = sham_melee;
   sham.th_missile = sham_magic1;
   sham.th_pain = sham_pain;
   sham.think = Rune_ShamblerThink;
   sham.nextthink = time + 0.5;
   sham.classname = "shambler_slave";
   self.runent = sham;
   sham.owner = self;

   temp = self;
   self = sham;
   walkmonster_start();
   self = temp;
   spawn_tfog(self.runent.origin);

	
   shamctrl = spawn();
   shamctrl.solid = SOLID_NOT;
   shamctrl.movetype = MOVETYPE_FLY;
   setorigin(shamctrl, self.origin);
   setsize (shamctrl, '0 0 0', '0 0 0');
   shamctrl.classname = "shambler_control";
   shamctrl.owner = self;
   shamctrl.runent = sham;
   shamctrl.nextthink = time + 0.5;
   shamctrl.think = Rune_ShamblerThink;
   
   shambowelctrl = spawn();
   shambowelctrl.solid = SOLID_NOT;
   shambowelctrl.movetype = MOVETYPE_FLY;
   setorigin(shambowelctrl, self.origin);
   setsize (shambowelctrl, '0 0 0', '0 0 0');
   shambowelctrl.classname = "shambler_bowels";
   shambowelctrl.owner = self;
   shambowelctrl.runent = sham;
   shambowelctrl.nextthink = time + 5;
   shambowelctrl.think = ShamblerBowelThink;
   
};