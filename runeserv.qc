/******************************\
 *                              *
 * Rune Serv QW main block code *
 *                              *
 \******************************/

//This is Artifact Quake version 2.0 FOR QUAKEWORLD CODE!

//(c) Copyright 1997 By Nick "SiNGE" Bousman
//E-Mail: singe@ix.netcom.com

//If you modify this code, please note that if you include this code in your
//mod, you MUST GIVE ME APPROPRIATE CREDIT for the runes. This is my child.
//I worked hard on it.
//Modified by Randy Bancroft.  a.k.a. Cannon Fodder

//*------------------------------------------------------------*

//Runes # 1-10 in RUNES10.QC
//Runes #11-20 in RUNES20.QC
//Runes #21-30 in RUNES30.QC
//Runes #31-40 in RUNES40.QC
//Runes #41-50 in RUNES50.QC
//Main Code in RUNESERV.QC

//Modified code: DEFS.QC, WORLD.QC, CLIENT.QC, PLAYER.QC, COMBAT.QC,
//               WEAPONS.QC

//*------------------------------------------------------------*

//Artifact Quake
void() REAL_Comments =
{
  //These comments stay, even when decompiled
  bprint(PRINT_MEDIUM," This is Artifact Quake version 1.27 FOR QUAKEWORLD! (AQ 2.0 port");
  bprint(PRINT_MEDIUM," Artifact Quake is (C) Copyright 1997 By Nick 'SiNGE' Bousman ");
  bprint(PRINT_MEDIUM," E-mail: singe@ix.netcom.com                                  ");
  bprint(PRINT_MEDIUM,"");
  bprint(PRINT_MEDIUM," Oh, and if you decompiled this, you're a twit.               ");
};

void() Rune_Think =
{
  if (self.runetype > 0)
  {
    if (self.runetype == RN_REGEN) Rune_Regen(); else
      if (self.runetype == RN_BERSERK) Berserk_Bleed(); else
        if (self.runetype == RN_ZAP) Rune_Zap(); else
          if (self.runetype == RN_CLOAK) Rune_Cloak(); else
            if (self.runetype == RN_BOMB) Rune_Bomb(); else
              if (self.runetype == RN_CAMO) Rune_Camo(); else
                if (self.runetype == RN_JUMP) Rune_Jump(); else
                  if (self.runetype == RN_AMMO) Rune_Ammo(); else
                    if (self.runetype == RN_VAMP) Rune_Vamp();
    if (self.runetype == RN_SHIELD) Shield_On(); else
      if (self.runetype == RN_IMPACT) Rune_Impact(); else //cause QW works better this way
        if (self.runetype == RN_REPEL) Rune_Repel(); else
          if (self.runetype == RN_WEIRD) Rune_Weird(); else
            if (self.runetype == RN_FIREWALK) Rune_Firewalk(); else
              if (self.runetype == RN_DARK) Dark_Think(); else
                if (self.runetype == RN_NOMIS) Rune_Nomis(); else
                  if (self.runetype == RN_ATTRACT) Rune_Attract(); else
                    if (self.runetype == RN_FLEAS) Rune_Fleas(); else
                      if (self.runetype == RN_INTANG) IntangThink(); else
                        if (self.runetype == RN_THIEF) Rune_Thief();
    //                if (self.runetype == RN_FLY) Rune_Fly(); else         // don't work
    //                if (self.runetype == RN_PHASE) Wall_Check(); else     // don't work
  }
  else
  {
    return;
  }
};

void() Rune_Button =
{
  if (!self.runetype) return;
  else if (self.runetype == RN_ENVIRO) Enviro_Jump();
  else if (self.runetype == RN_RECALL) Rune_Recall();
  else if (self.runetype == RN_BOMB) Bomb_Arm();
  else if (self.runetype == RN_DSPOTS) Rune_DSpots();
  else if (self.runetype == RN_SHIELD) Rune_Shield();
  else if (self.runetype == RN_RADIO) Rune_Radio();
  else if (self.runetype == RN_SWITCH) Rune_Switch();
  else if (self.runetype == RN_FREEZE) Rune_Freeze();
  else if (self.runetype == RN_SUCK) Suck_Button();
  else if (self.runetype == RN_DUAL) Rune_Dual();
  else if (self.runetype == RN_WEIRD) Weird_Throw();
  else if (self.runetype == RN_HOLO) Rune_Holo();
  else if (self.runetype == RN_BLINK) Rune_Blink();
  else if (self.runetype == RN_DARK) Rune_Dark();
  else if (self.runetype == RN_AXE && self.runevar == 0) player_tax1();
  else if (self.runetype == RN_PIPE) Detonate();
  else if (self.runetype == RN_VAXE) Vaxe();
  else if (self.runetype == RN_HKSPIKE) HKSpike();
  else if (self.runetype == RN_FBALL) W_FireDisc();
  else if (self.runetype == RN_FLEAS) Flea_Button();
  else if (self.runetype == RN_INTANG) Intang_Button();
  else if (self.runetype == RN_MARMOR)
  {
    centerprint (self,"\n\nYour armor is indestructable!");
  }
  else if (self.runetype == RN_PACK)Pack_Heal();
  else if (self.runetype == RN_TWALK) Rune_Twalk();  // don't work
  else if (self.runetype == RN_NEUTRON) Neutron_Time(); // always last in list
};
void() Rune_Tell =
{
  if (self.runetype == 0)
    centerprint(self,"\n\n\n\n\n\n\n\n\n\n� No Rune �");
  else
  {
    if (self.runetype == RN_REGEN)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Regeneration �\n����������������������");
    else if (self.runetype == RN_RESIST)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Resistance �\n����������������������");
    else if (self.runetype == RN_HASTE)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Haste �\n����������������������");
    else if (self.runetype == RN_ENVIRO)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Environmental Protection �\n����������������������");
    else if (self.runetype == RN_BERSERK)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Berserker Rune �\n����������������������\n");
    else if (self.runetype == RN_RECALL)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Recall �\n����������������������");
    else if (self.runetype == RN_ZAP)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Electric Rune �\n����������������������");
    else if (self.runetype == RN_CLOAK)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Cloaking �\n����������������������");
    else if (self.runetype == RN_BOMB)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Divine Wind �\n����������������������");
    else if (self.runetype == RN_DSPOTS)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Death Spots �\n����������������������");
    else if (self.runetype == RN_ORB)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Orb of Death �\n����������������������");
    else if (self.runetype == RN_CAMO)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Camouflage �\n����������������������");
    else if (self.runetype == RN_JUMP)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Uncontrolable Jumping �\n����������������������");
    else if (self.runetype == RN_AMMO)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Action Movie Arsenal �\n����������������������");
    else if (self.runetype == RN_VAMP)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Vampiric Rune �\n����������������������");
    else if (self.runetype == RN_SHIELD)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Shielding �\n����������������������");
    else if (self.runetype == RN_STRENGTH)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Strength �\n����������������������");
    else if (self.runetype == RN_RADIO)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Radioactivity �\n����������������������");
    else if (self.runetype == RN_SWITCH)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Switch Rune �\n����������������������");
    else if (self.runetype == RN_FREEZE)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Ice Traps �\n����������������������");
    else if (self.runetype == RN_SUCK)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Gravity Rune �\n����������������������");
    else if (self.runetype == RN_IMPACT)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Impact Rune �\n����������������������");
    else if (self.runetype == RN_VENG)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Vengeance �\n����������������������");
    else if (self.runetype == RN_SHUB)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Shub Hat �\n����������������������\n");
    else if (self.runetype == RN_REPEL)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Repulsion �\n����������������������\n");
    else if (self.runetype == RN_DUAL)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Dual Recall �\n����������������������\n");
    else if (self.runetype == RN_WEIRD)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Weirdness �\n����������������������\n");
    else if (self.runetype == RN_PHOENIX)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Phoenix Rune �\n����������������������\n");
    else if (self.runetype == RN_FIREWALK)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Fire Walking �\n����������������������");
    else if (self.runetype == RN_HOLO)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� HoloRune �\n����������������������");
    else if (self.runetype == RN_HEALTH)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Good Health �\n����������������������");
    else if (self.runetype == RN_BLINK)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Blink Rune �\n����������������������");
    //  ****************************************************************************************************************
    else if (self.runetype == RN_DARK)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Darkness �\n����������������������\n");
    else if (self.runetype == RN_NOMIS)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Anti-missile Rune �\n����������������������\n");
    else if (self.runetype == RN_ATTRACT)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� CURSED Rune of Attraction! �\n����������������������\n");
    else if (self.runetype == RN_AXE)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� CURSED Rune of the Axe! �\n����������������������");
    else if (self.runetype == RN_PIPE)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of the Delayed Grenade �\n����������������������\n");
    else if (self.runetype == RN_VAXE)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Vorpal Axe Rune �\n����������������������\n");
    else if (self.runetype == RN_HKSPIKE)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Hell Knight Rune �\n����������������������\n");
    else if (self.runetype == RN_FBALL)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Shooting Star Rune �\n����������������������\n");
    else if (self.runetype == RN_FLEAS)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Camel Fleas �\n����������������������\n");
    else if (self.runetype == RN_INTANG)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Intangibility �\n����������������������\n");
    else if (self.runetype == RN_MARMOR)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Mythril Armor �\n����������������������");
    else if (self.runetype == RN_PACK)
      centerprint(self,"\n\n\n\n\n\n����������������������\n� Back Pack Rune �\n��������������\n� Carry Twice the Ammo �\n� Plus 4 Med Kits �\n����������������������");
    else if (self.runetype == RN_THIEF)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Thief Rune �\n����������������������");
    else if (self.runetype == RN_TWALK)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� The Teleport Shuffle �\n����������������������");
    //  ****************************************************************************************************************
    //          else if (self.runetype == RN_CLOUD)
    //             centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Floating Spiky Death Cloud �\n����������������������\n");
    //          else if (self.runetype == RN_FLY)
    //             centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Rune of Flight �\n����������������������");
    //          else if (self.runetype == RN_PHASE)
    //             centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Phased Rune �\n����������������������\n");
    else if (self.runetype == RN_NEUTRON)
      centerprint(self,"\n\n\n\n\n\n\n\n\n\n����������������������\n� Neutron Bomb Rune �\n����������������������\n");
  }
};

void() Rune_Activate =
{
  stuffcmd(self,"v_cshift 0 0 0 1\n");
  self.max_health = 100;
  self.runevar = 0;
  self.runetime = time;
  self.runevector = '0 0 0';
  self.movetype = MOVETYPE_WALK;
  self.touch = SUB_Null;

  if (self.runetype == RN_REGEN)
  {
    (self.max_health = 200);
    if (self.health > self.max_health) self.health = self.max_health;
  }
  else if (self.runetype == RN_RECALL) self.runevar = 1;
  else if (self.runetype == RN_ZAP) Zap_Spawn();
  else if (self.runetype == RN_CLOAK) Rune_Cloak();
  else if (self.runetype == RN_BOMB) Bomb_Spawn();
  else if (self.runetype == RN_ORB) Orb_Spawn();
  else if (self.runetype == RN_SHIELD) self.runevar = 0;
  else if (self.runetype == RN_VENG) VengHead_Spawn();
  else if (self.runetype == RN_SHUB) ShubHat_Spawn();
  else if (self.runetype == RN_DUAL) self.runevector = self.origin;
  else if (self.runetype == RN_PHOENIX) self.runevar = 3;
  else if (self.runetype == RN_HEALTH)
  {
    self.max_health = 666;
    self.health = self.health + 100;
    if (self.health > self.max_health) self.health = self.max_health;
  }
  else if (self.runetype == RN_BLINK) Dot_Spawn();
  else if (self.runetype == RN_DARK) self.runevar = 0;
  else if (self.runetype == RN_NOMIS) W_SetCurrentAmmo ();
  else if (self.runetype == RN_ATTRACT) (self.curse_time = time + cursetime);
  else if (self.runetype == RN_AXE)
  {
    self.items = self.items - (self.items &
        (IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING | IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
    self.weapon = self.weapon - (self.weapon &
        (IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING) );
    self.weapon = IT_AXE;
    self.weaponmodel = "progs/v_axe.mdl";
    self.curse_time = time + cursetime;
    W_SetCurrentAmmo ();
  }
  else if (self.runetype == RN_PIPE) Pipe();
  else if (self.runetype == RN_MARMOR) Myth_Armor ();
  else if (self.runetype == RN_PACK) Get_Pack ();
  else if (self.runetype == RN_NEUTRON) Neutron_Spawn();
  //        else if (self.runetype == RN_CLOUD) Cloud_Spawn();
  //        else if (self.runetype == RN_FLY) self.movetype = MOVETYPE_FLY;


  Rune_Tell();
};

string() RandMap =
{
  local float rand;
  local string newmap;

  rand = ceil(random()*38);

  if (rand < 11)
  {
    if (rand == 1) newmap = "start";
    else if (rand == 2) newmap = "dm1";
    else if (rand == 3) newmap = "dm2";
    else if (rand == 4) newmap = "dm3";
    else if (rand == 5) newmap = "dm4";
    else if (rand == 6) newmap = "dm5";
    else if (rand == 7) newmap = "dm6";
    else if (rand == 8) newmap = "e1m1";
    else if (rand == 9) newmap = "e1m2";
    else if (rand == 10) newmap = "e1m3";
  }
  else if (rand < 21)
  {
    if (rand == 11) newmap = "e1m4";
    else if (rand == 12) newmap = "e1m5";
    else if (rand == 13) newmap = "e1m6";
    else if (rand == 14) newmap = "e2m1";
    else if (rand == 15) newmap = "e2m2";
    else if (rand == 16) newmap = "e2m3";
    else if (rand == 17) newmap = "e2m4";
    else if (rand == 18) newmap = "e2m5";
    else if (rand == 19) newmap = "e2m6";
    else if (rand == 20) newmap = "e2m7";
  }
  else if (rand < 31)
  {
    if (rand == 21) newmap = "e3m1";
    else if (rand == 22) newmap = "e3m2";
    else if (rand == 23) newmap = "e3m3";
    else if (rand == 24) newmap = "e3m4";
    else if (rand == 25) newmap = "e3m5";
    else if (rand == 26) newmap = "e3m6";
    else if (rand == 27) newmap = "e3m7";
    else if (rand == 28) newmap = "e4m1";
    else if (rand == 29) newmap = "e4m1";
    else if (rand == 30) newmap = "e4m2";
  }
  else
  {
    if (rand == 31) newmap = "e4m3";
    else if (rand == 32) newmap = "e4m4";
    else if (rand == 33) newmap = "e4m5";
    else if (rand == 34) newmap = "e4m6";
    else if (rand == 35) newmap = "e4m7";
    else if (rand == 36) newmap = "e4m8";
    else if (rand == 37) newmap = "e4m8";

    //Removed in non-lan non-QW version due to lag.

    else if (rand == 37) newmap = "e1m7";
    else if (rand == 38) newmap = "end";
  }
  return newmap;
};

void() MOTD =
{
  centerprint(self,"Hampton Road's A������� Q����World  v2.20\n������������������������������\nCollect a rune, get an ability!\n\nIMPULSE ��� MUST BE BOUND.\nIMPULSE �� shows your current rune.\nIMPULSE �� deactivates your rune.\nIMPULSE �� shows this screen.\nIMPULSE �� does a U-turn.\nIMPULSE �� Toggle Grappling hook.\n�������������\nWritten by �������\nModified by: Cannon Fodder\nE-mail: quake@vabch.com\n\n\n������������������������������");
};

entity() SelectRuneSpawnPoint =
{
  local float runec;
  local entity e;

  //runec is to keep them from clustering
  runec = 0;
  while (runec < random()*100+10)
  {
    runespawn = nextent (runespawn);
    runec = runec + 1;
  }

  runec = 0;
  //Now runec checks for HUGE HUGE loops to prevent crashing

  while(((runespawn.classname == "player")
        ||(runespawn.classname == "rune"))
      &&runec<1500)
  {
    runespawn = nextent (runespawn);
    runec = runec + 1;
  }

  return runespawn;
};

void() Rune_Move =
{
  local entity temp;

  temp = SelectRuneSpawnPoint();
  setorigin(self, temp.origin);

  self.nextthink = time + 60 + random()*60;

  self.flags = self.flags-(self.flags & FL_ONGROUND);

  self.velocity_x = crandom()*500;
  self.velocity_y = crandom()*500;
  self.velocity_z = random()*500;
};

void() Rune_Touch =
{
  local entity temp;
  local string temtex1;
  local float rand;
  if (other.classname == "hook")
  {
    self.velocity = other.velocity;
    self.velocity_z = ((crandom()*500) + 200);
    self.flags = self.flags-(self.flags & FL_ONGROUND);

    self.movetype = MOVETYPE_BOUNCE;
    if (infokey(other.owner, "hook") != "hold")
    {
      other.owner.hook = other.owner.hook - (other.owner.hook & 2); // 2 = HOOK_ON
    }


  }

  // **************************************************************************
  // remove electric rune if it lands in water, slime, or lava
  if (self.runetype == RN_ZAP)
  {
    if (pointcontents(self.origin) == CONTENT_WATER
        || pointcontents(self.origin) == CONTENT_SLIME
        || pointcontents(self.origin) == CONTENT_LAVA)
    {
      runecurrent = runecurrent - 1;
      remove(self);
    }
  }
  // **************************************************************************
  if (pointcontents(self.origin) == CONTENT_SOLID
      || pointcontents(self.origin) == CONTENT_LAVA)
  {
    self.nextthink = time;
  }
  if (other == world)
    sound (self, CHAN_WEAPON, "weapons/tink1.wav", 1.0, ATTN_NORM);

  if (other.classname != "player") return;
  if (other.health <= 0) return;

  if (other.runetype != 0) return;

  other.runetype = self.runetype;

  runecurrent = runecurrent - 1;

  remove(self);

  temp = self;
  self = other;

  Rune_Activate();
  self.dropdelay = time + 5;

  sound (self, CHAN_BODY, "buttons/switch21.wav", 1, ATTN_NORM);

  self = temp;
};

void(vector sorigin, float xmax, float ymax, float zmax, float type) Rune_Spawn =
{
  local entity rune;
  local float rnd, counter,neutronmodel;
  local string mytemp;

  rune = spawn();
  setorigin(rune, sorigin);

  setsize (rune, '-16 -16 0', '16 16 50');
  rune.movetype = MOVETYPE_BOUNCE;
  rune.solid = SOLID_TRIGGER;
  rune.flags = FL_ITEM;
  rune.velocity_x = crandom()*xmax;
  rune.velocity_y = crandom()*ymax;
  rune.velocity_z = random()*zmax;
  rune.classname = "rune";

  if (type > 0) setmodel (rune, "progs/end1.mdl");
  if (type > 10) setmodel (rune, "progs/end2.mdl");
  if (type > 20) setmodel (rune, "progs/end3.mdl");
  if (type > 30) setmodel (rune, "progs/end4.mdl");
  if (type > 40) setmodel (rune, "progs/end1.mdl");

  //   if (type == RN_PACK) setmodel (rune, "progs/backpack.mdl");

  rune.runetype = type;

  rune.touch = Rune_Touch;
  rune.think = Rune_Move;
  rune.nextthink = time + 1;

};

void () Next_Rune;
void(float numspawn) Rune_SpawnAll =
{
  local float counter, type;
  local entity temp;

  counter = 0;
  while (counter < numspawn)
  {
    temp = SelectRuneSpawnPoint();

    if (runeselect != 1)
    {
      type = random() * TOTAL_RUNETYPE;
      type = ceil(type);
      Rune_Spawn(temp.origin, 500, 500, 500, type);
    }
    else
    {
      Next_Rune();
      Rune_Spawn(temp.origin, 500, 500, 500, runeparm);
    }
    //      Rune_Spawn(temp.origin, 500, 500, 500, type);
    counter = counter + 1;
  }
  runecurrent = runecurrent + numspawn;
};

void() Uturn =
{
  self.angles_y = self.angles_y - 180;
  self.fixangle = TRUE;
};
void () Welcomemsg = {
  //max number of vertical lines is 14!
  //centerprint(self, "Welcome to\nHampton Road's Artifact Runes\n��������������������������������\nOriginal Artifact Runes\nwritten by:\nNick 'SiNGE' Bousman\nE-Mail: singe@ix.netcom.com\n����������������������\nModified by:\nRandy 'Cannon Fodder' Bancroft\nE-Mail: quake@vabch.com\n��������������������������������\nPress -fire- for next page\n");
  //       |                                                           |
  centerprint(self, "Welcome to KingTurd's Artifact Runes QuakeWorld Server!\nInspired by Nick 'SiNGE' Bousman's original work,\nwith modifications done by KingTurd");
};

/*   kt:  we will replace this, its rather annoying....
     void () Welcomemsg =

     {

     if (self.motd_count == 0)
     {
     centerprint(self, "Welcome to\nHampton Road's Artifact Runes\n��������������������������������\nOriginal Artifact Runes\nwritten by:\nNick 'SiNGE' Bousman\nE-Mail: singe@ix.netcom.com\n����������������������\nModified by:\nRandy 'Cannon Fodder' Bancroft\nE-Mail: quake@vabch.com\n��������������������������������\nPress -fire- for next page\n");
     if (self.attack_state == 1)
     {
     self.motd_count = 1;
     stuffcmd (self, "setinfo runehelp 10\n"); // I have seen the helpscreens don't show anymore
     self.attack_state = 0;
     }
     }
     if (self.motd_count == 1)
     {
     centerprint(self,"List of Impulses\n��������������������������������\nCollect a rune, get an ability!\n��������������������������������\nIMPULSE ��� activates rune             \nif rune requires activation\nIT MUST BE BOUND!          \n����������������������\nIMPULSE ��  shows your current rune    \nIMPULSE ��  drops your rune for another\nIMPULSE ��  shows quick help screen    \nIMPULSE ��  does a U-turn              \nIMPULSE ��  Grappling hook on/off      \nIMPULSE ��� Flashlight on/off          \n����������������������\n\nPress -fire- for next page");
     if (self.attack_state == 1)
     {
     self.motd_count = 2;
     self.attack_state = 0;
     }
     }
     if (self.motd_count == 2)
     {
     centerprint(self,"List of Aliases\n\n��������������������������������\n'ACTIVATE' activates rune              \n'SHOW' shows your current rune \n'DROPRUNE' drops your rune for another \n'RUNEHELP' shows quick help screen     \n'UTURN' does a U-turn            \n'HOOK' Grappling hook on/off   \n'LIGHT' Flashlight on/off        \n����������������������\n\nPress -fire- for next page");
     if (self.attack_state == 1)
     {
     self.motd_count = 3;
     self.attack_state = 0;
     }
     }
     if (self.motd_count == 3)
     {
     centerprint(self,"To see help screens again\n\nPress the F1 key\n\n��������������������������������\n\nFor complete rune list see:\nwww.quake.vabch.com/runehelp.htm\n\n��������������������������������\n\nPress -fire- to enter game");
     if (self.attack_state == 1)
     {
     self.motd_count = 10;
     self.attack_state = 0;
     self.solid = SOLID_SLIDEBOX;
     self.takedamage = DAMAGE_AIM;
     centerprint(self, "");
     self.movetype = MOVETYPE_NOCLIP;
     set_suicide_frame ();
     respawn();
     }
     }
     self.motd_time = time + 1.5;
     };
     */
void() Neutron_Rune_Touch =
{
  local entity temp;
  local string temtex1;
  local float rand;
  if (other.classname == "hook")
  {
    self.velocity = other.velocity;
    self.velocity_z = ((crandom()*500) + 200);
    self.flags = self.flags-(self.flags & FL_ONGROUND);

    self.movetype = MOVETYPE_BOUNCE;
    if (infokey(other.owner, "hook") != "hold")
    {
      other.owner.hook = other.owner.hook - (other.owner.hook & 2); // 2 = HOOK_ON
    }


  }

  if (pointcontents(self.origin) == CONTENT_SOLID
      || pointcontents(self.origin) == CONTENT_LAVA)
  {
    self.nextthink = time;
  }

  if (other == world)
  {
    sound (self, CHAN_WEAPON, "weapons/tink1.wav", 1.0, ATTN_NORM);
  }

  if (other.classname != "player") return;
  if (other.health <= 0) return;

  if (other.runetype != 0) return;

  other.runetype = self.runetype;

  remove(self);

  temp = self;
  self = other;

  Neutron_Spawn();

  sound (self, CHAN_BODY, "doors/baseuse.wav", 1, ATTN_NORM);

  self = temp;
};

void(vector sorigin, float xmax, float ymax, float zmax) Neutron_Rune_Spawn =
{
  local entity rune;
  local float rnd, counter,neutronmodel;
  local string mytemp;

  rune = spawn();
  setorigin(rune, sorigin);

  setsize (rune, '-16 -16 0', '16 16 50');
  rune.movetype = MOVETYPE_BOUNCE;
  rune.solid = SOLID_TRIGGER;
  rune.flags = FL_ITEM;
  rune.velocity_x = crandom()*xmax;
  rune.velocity_y = crandom()*ymax;
  rune.velocity_z = random()*zmax;
  rune.classname = "rune";
  neutronmodel = crandom() * 40;
  if (neutronmodel > 0) setmodel (rune, "progs/end1.mdl");
  if (neutronmodel > 10) setmodel (rune, "progs/end2.mdl");
  if (neutronmodel > 20) setmodel (rune, "progs/end3.mdl");
  if (neutronmodel > 30) setmodel (rune, "progs/end4.mdl");

  rune.runetype = RN_NEUTRON;

  rune.touch = Neutron_Rune_Touch;
  rune.think = Rune_Move;
  rune.nextthink = time + 1;
};

void() Neutron_SpawnAll =
{
  local entity temp;
  if ((neutronflag > 0) && (neutroncount < 1)) // no more than one neutron in a level at a time
  {
    if (neutrondonetime <= time)
    {
      temp = SelectRuneSpawnPoint();
      Neutron_Rune_Spawn(temp.origin, 500, 500, 500);
      neutroncount = neutroncount + 1;
    }
  }
};

void () Next_Rune =
{
  local float nextrunetmp, nextcount;
  runeparm = runeparm + 1;

  if (runeparm < RN_REGEN || runeparm > TOTAL_RUNETYPE)
  {
    runeparm = RN_REGEN;
  }

  nextcount = 0;
  while (nextcount < 2)
  {
    if (runeparm == RN_REGEN)
    {
      nextrunetmp = stof(infokey(world,"regen"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_RESIST;
      }
    }

    if (runeparm == RN_RESIST)
    {
      nextrunetmp = stof(infokey(world,"resist"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_HASTE;
      }
    }

    if (runeparm == RN_HASTE)
    {
      nextrunetmp = stof(infokey(world,"haste"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_ENVIRO;
      }
    }

    if (runeparm == RN_ENVIRO)
    {
      nextrunetmp = stof(infokey(world,"enviro"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_BERSERK;
      }
    }

    if (runeparm == RN_BERSERK)
    {
      nextrunetmp = stof(infokey(world,"berserk"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_RECALL;
      }
    }

    if (runeparm == RN_RECALL)
    {
      nextrunetmp = stof(infokey(world,"recall"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_ZAP;
      }
    }

    if (runeparm == RN_ZAP)
    {
      nextrunetmp = stof(infokey(world,"electric"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_CLOAK;
      }
    }

    if (runeparm == RN_CLOAK)
    {
      nextrunetmp = stof(infokey(world,"cloak"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_BOMB;
      }
    }

    if (runeparm == RN_BOMB)
    {
      nextrunetmp = stof(infokey(world,"dwind"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_DSPOTS;
      }
    }

    if (runeparm == RN_DSPOTS)
    {
      nextrunetmp = stof(infokey(world,"deathspot"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_ORB;
      }
    }

    if (runeparm == RN_ORB)
    {
      nextrunetmp = stof(infokey(world,"orbdeath"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_CAMO;
      }
    }

    if (runeparm == RN_CAMO)
    {
      nextrunetmp = stof(infokey(world,"camo"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_JUMP;
      }
    }

    if (runeparm == RN_JUMP)
    {
      nextrunetmp = stof(infokey(world,"jump"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_AMMO;
      }
    }

    if (runeparm == RN_AMMO)
    {
      nextrunetmp = stof(infokey(world,"amovie"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_VAMP;
      }
    }

    if (runeparm == RN_VAMP)
    {
      nextrunetmp = stof(infokey(world,"vampire"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_SHIELD;
      }
    }

    if (runeparm == RN_SHIELD)
    {
      nextrunetmp = stof(infokey(world,"shield"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_STRENGTH;
      }
    }

    if (runeparm == RN_STRENGTH)
    {
      nextrunetmp = stof(infokey(world,"strength"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_RADIO;
      }
    }

    if (runeparm == RN_RADIO)
    {
      nextrunetmp = stof(infokey(world,"radiation"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_SWITCH;
      }
    }

    if (runeparm == RN_SWITCH)
    {
      nextrunetmp = stof(infokey(world,"switch"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_FREEZE;
      }
    }

    if (runeparm == RN_FREEZE)
    {
      nextrunetmp = stof(infokey(world,"freeze"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_SUCK;
      }
    }

    if (runeparm == RN_SUCK)
    {
      nextrunetmp = stof(infokey(world,"gravity"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_IMPACT;
      }
    }

    if (runeparm == RN_IMPACT)
    {
      nextrunetmp = stof(infokey(world,"impact"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_VENG;
      }
    }

    if (runeparm == RN_VENG)
    {
      nextrunetmp = stof(infokey(world,"vengeance"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_SHUB;
      }
    }

    if (runeparm == RN_SHUB)
    {
      nextrunetmp = stof(infokey(world,"shub"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_REPEL;
      }
    }

    if (runeparm == RN_REPEL)
    {
      nextrunetmp = stof(infokey(world,"repel"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_DUAL;
      }
    }

    if (runeparm == RN_DUAL)
    {
      nextrunetmp = stof(infokey(world,"dualrecall"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_WEIRD;
      }
    }

    if (runeparm == RN_WEIRD)
    {
      nextrunetmp = stof(infokey(world,"weird"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_PHOENIX;
      }
    }

    if (runeparm == RN_PHOENIX)
    {
      nextrunetmp = stof(infokey(world,"phoenix"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_FIREWALK;
      }
    }

    if (runeparm == RN_FIREWALK)
    {
      nextrunetmp = stof(infokey(world,"firewalk"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_HOLO;
      }
    }

    if (runeparm == RN_HOLO)
    {
      nextrunetmp = stof(infokey(world,"hologram"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_HEALTH;
      }
    }

    if (runeparm == RN_HEALTH)
    {
      nextrunetmp = stof(infokey(world,"goodhealth"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_BLINK;
      }
    }

    if (runeparm == RN_BLINK)
    {
      nextrunetmp = stof(infokey(world,"blink"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_DARK;
      }
    }

    if (runeparm == RN_DARK)
    {
      nextrunetmp = stof(infokey(world,"darkness"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_NOMIS;
      }
    }

    if (runeparm == RN_NOMIS)
    {
      nextrunetmp = stof(infokey(world,"antimissile"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_ATTRACT;
      }
    }

    if (runeparm == RN_ATTRACT)
    {
      nextrunetmp = stof(infokey(world,"attract"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_AXE;
      }
    }

    if (runeparm == RN_AXE)
    {
      nextrunetmp = stof(infokey(world,"curseaxe"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_PIPE;
      }
    }

    if (runeparm == RN_PIPE)
    {
      nextrunetmp = stof(infokey(world,"dgrenade"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_VAXE;
      }
    }

    if (runeparm == RN_VAXE)
    {
      nextrunetmp = stof(infokey(world,"vorpalaxe"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_HKSPIKE;
      }
    }

    if (runeparm == RN_HKSPIKE)
    {
      nextrunetmp = stof(infokey(world,"hellknight"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_FBALL;
      }
    }

    if (runeparm == RN_FBALL)
    {
      nextrunetmp = stof(infokey(world,"shootingstar"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_FLEAS;
      }
    }

    if (runeparm == RN_FLEAS)
    {
      nextrunetmp = stof(infokey(world,"fleas"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_INTANG;
      }
    }

    if (runeparm == RN_INTANG)
    {
      nextrunetmp = stof(infokey(world,"intangible"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_MARMOR;
      }
    }

    if (runeparm == RN_MARMOR)
    {
      nextrunetmp = stof(infokey(world,"mythril"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_PACK;
      }
    }

    if (runeparm == RN_PACK)
    {
      nextrunetmp = stof(infokey(world,"backpack"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_THIEF;
      }
    }

    if (runeparm == RN_THIEF)
    {
      nextrunetmp = stof(infokey(world,"thief"));
      if (nextrunetmp == 1)
      {
        return;
      }
      else
      {
        runeparm = RN_REGEN;
      }
    }


    nextcount = nextcount + 1;
  }
  dprint ("Empty rune spawned\n");
  dprint (" localinfo runeselect 1\n");
  dprint (" No Runes enables in runeuse.cfg\n");
};
