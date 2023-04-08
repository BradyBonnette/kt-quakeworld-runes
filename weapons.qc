void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
// void(vector org, float damage) SpawnBlood;
void() SuperDamageSound;
void() W_ThrowAxe;

void() Rune_ShamblerSpawn;

// called by worldspawn
void() W_Precache =
{
  precache_sound ("weapons/r_exp3.wav");  // new rocket explosion
  precache_sound ("weapons/rocket1i.wav");        // spike gun
  precache_sound ("weapons/sgun1.wav");
  precache_sound ("weapons/guncock.wav"); // player shotgun
  precache_sound ("weapons/ric1.wav");    // ricochet (used in c code)
  precache_sound ("weapons/ric2.wav");    // ricochet (used in c code)
  precache_sound ("weapons/ric3.wav");    // ricochet (used in c code)
  precache_sound ("weapons/spike2.wav");  // super spikes
  precache_sound ("weapons/tink1.wav");   // spikes tink (used in c code)
  precache_sound ("weapons/grenade.wav"); // grenade launcher
  precache_sound ("weapons/bounce.wav");          // grenade bounce
  precache_sound ("weapons/shotgn2.wav"); // super shotgun

  precache_sound ("shambler/smack.wav");
  precache_sound ("blob/land1.wav");
  //  *************************************************************************
  //  hell knight spikes
  precache_sound ("hknight/attack1.wav"); // sound
  precache_model("progs/k_spike.mdl");    // model
  //  *************************************************************************


};

float() crandom =
{
  return 2*(random() - 0.5);
};

/*
   ================
   W_FireAxe
   ================
   */
void() W_FireAxe =
{
  local   vector  source;
  local   vector  org;

  //  *************************************************************************
  //  if cursed rune of the axe and the axe is in flight don't throw
  if (self.runetype == RN_AXE && self.runevar == 1)
  {
    return;
  }
  //  *************************************************************************

  makevectors (self.v_angle);
  source = self.origin + '0 0 16';
  traceline (source, source + v_forward*64, FALSE, self);
  if (trace_fraction == 1.0)
    return;

  org = trace_endpos - v_forward*4;

  if (trace_ent.takedamage)
  {
    trace_ent.axhitme = 1;
    SpawnBlood (org, '0 0 0', 20);
    //  *************************************************************************
    //  if vorpal axe it's instant kill
    if (self.runetype == RN_VAXE)
    {
      T_Damage (trace_ent, self, self, 50000);
    }
    else
      //  *************************************************************************
    {
      T_Damage (trace_ent, self, self, 20);
    }
  }
  else
  {       // hit wall

    //RUNE SERV: changed CHAN_WEAPON to CHAN_BODY so the haste rune axing can be heard
    if (self.runetype != RN_CLOAK)
      sound (self, CHAN_BODY, "player/axhit2.wav", 1, ATTN_NORM);

    WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte (MSG_MULTICAST, TE_GUNSHOT);
    WriteByte (MSG_MULTICAST, 3);
    WriteCoord (MSG_MULTICAST, org_x);
    WriteCoord (MSG_MULTICAST, org_y);
    WriteCoord (MSG_MULTICAST, org_z);
    multicast (org, MULTICAST_PVS);
  }
};


//============================================================================


vector() wall_velocity =
{
  local vector    vel;

  vel = normalize (self.velocity);
  vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
  vel = vel + 2*trace_plane_normal;
  vel = vel * 200;

  return vel;
};


/*
   ================
   SpawnMeatSpray
   ================
   */
void(vector org, vector vel) SpawnMeatSpray =
{
  local   entity missile;
  local   vector  org;

  missile = spawn ();
  missile.owner = self;
  missile.movetype = MOVETYPE_BOUNCE;
  missile.solid = SOLID_NOT;

  makevectors (self.angles);

  missile.velocity = vel;
  missile.velocity_z = missile.velocity_z + 250 + 50*random();

  missile.avelocity = '3000 1000 2000';

  // set missile duration
  missile.nextthink = time + 1;
  missile.think = SUB_Remove;

  setmodel (missile, "progs/zom_gib.mdl");
  setsize (missile, '0 0 0', '0 0 0');
  setorigin (missile, org);
};

/*
   ================
   SpawnBlood
   ================
   */
void(vector org, vector vel, float damage) SpawnBlood =
{
  WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
  WriteByte (MSG_MULTICAST, TE_BLOOD);
  WriteByte (MSG_MULTICAST, 1);
  WriteCoord (MSG_MULTICAST, org_x);
  WriteCoord (MSG_MULTICAST, org_y);
  WriteCoord (MSG_MULTICAST, org_z);
  multicast (org, MULTICAST_PVS);
};

/*
   ================
   spawn_touchblood
   ================
   */
void(float damage) spawn_touchblood =
{
  local vector    vel;

  vel = wall_velocity () * 0.2;
  SpawnBlood (self.origin + vel*0.01, vel, damage);
};


/*
   ==============================================================================

   MULTI-DAMAGE

   Collects multiple small damages into a single damage

   ==============================================================================
   */

entity  multi_ent;
float   multi_damage;

vector  blood_org;
float   blood_count;

vector  puff_org;
float   puff_count;

void() ClearMultiDamage =
{
  multi_ent = world;
  multi_damage = 0;
  blood_count = 0;
  puff_count = 0;
};

void() ApplyMultiDamage =
{
  if (!multi_ent)
    return;
  T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
  if (!hit)
    return;

  if (hit != multi_ent)
  {
    ApplyMultiDamage ();
    multi_damage = damage;
    multi_ent = hit;
  }
  else
    multi_damage = multi_damage + damage;
};

void() Multi_Finish =
{
  if (puff_count)
  {
    WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte (MSG_MULTICAST, TE_GUNSHOT);
    WriteByte (MSG_MULTICAST, puff_count);
    WriteCoord (MSG_MULTICAST, puff_org_x);
    WriteCoord (MSG_MULTICAST, puff_org_y);
    WriteCoord (MSG_MULTICAST, puff_org_z);
    multicast (puff_org, MULTICAST_PVS);
  }

  if (blood_count)
  {
    WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte (MSG_MULTICAST, TE_BLOOD);
    WriteByte (MSG_MULTICAST, blood_count);
    WriteCoord (MSG_MULTICAST, blood_org_x);
    WriteCoord (MSG_MULTICAST, blood_org_y);
    WriteCoord (MSG_MULTICAST, blood_org_z);
    multicast (puff_org, MULTICAST_PVS);
  }
};

/*
   ==============================================================================

   BULLETS

   ==============================================================================
   */

/*
   ================
   TraceAttack
   ================
   */
void(float damage, vector dir) TraceAttack =
{
  local   vector  vel, org;

  vel = normalize(dir + v_up*crandom() + v_right*crandom());
  vel = vel + 2*trace_plane_normal;
  vel = vel * 200;

  org = trace_endpos - dir*4;

  if (trace_ent.takedamage)
  {
    blood_count = blood_count + 1;
    blood_org = org;
    AddMultiDamage (trace_ent, damage);
  }
  else
  {
    puff_count = puff_count + 1;
  }
};

/*
   ================
   FireBullets

   Used by shotgun, super shotgun, and enemy soldier firing
   Go to the trouble of combining multiple pellets into a single damage call.
   ================
   */
void(float shotcount, vector dir, vector spread) FireBullets =
{
  local   vector direction;
  local   vector  src;

  makevectors(self.v_angle);

  src = self.origin + v_forward*10;
  src_z = self.absmin_z + self.size_z * 0.7;

  ClearMultiDamage ();

  traceline (src, src + dir*2048, FALSE, self);
  puff_org = trace_endpos - dir*4;

  while (shotcount > 0)
  {

    direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;
    traceline (src, src + direction*2048, FALSE, self);
    if (trace_fraction != 1.0)
      TraceAttack (4, direction);

    shotcount = shotcount - 1;
  }
  ApplyMultiDamage ();
  Multi_Finish ();
};

/*
   ================
   W_FireShotgun
   ================
   */
void() W_FireShotgun =
{
  local vector dir;

  //RUNE SERV: cloak rune. No sound
  if (self.runetype != RN_CLOAK)

    sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);

  msg_entity = self;
  WriteByte (MSG_ONE, SVC_SMALLKICK);

  self.currentammo = self.ammo_shells = self.ammo_shells - 1;
  dir = aim (self, 100000);
  FireBullets (6, dir, '0.04 0.04 0');
};


/*
   ================
   W_FireSuperShotgun
   ================
   */
void() W_FireSuperShotgun =
{
  local vector dir;

  if (self.currentammo == 1)
  {
    W_FireShotgun ();
    return;
  }

  sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);

  msg_entity = self;
  WriteByte (MSG_ONE, SVC_BIGKICK);

  self.currentammo = self.ammo_shells = self.ammo_shells - 2;
  dir = aim (self, 100000);
  FireBullets (14, dir, '0.14 0.08 0');
};


/*
   ==============================================================================

   ROCKETS

   ==============================================================================
   */

void() T_MissileTouch =
{
  local float     damg;

  if (other == self.owner)
    return;         // don't explode on owner

  if (pointcontents(self.origin) == CONTENT_SKY)
  {
    remove(self);
    return;
  }

  damg = 100 + random()*20;

  if (other.health)
  {
    T_Damage (other, self, self.owner, damg );
  }

  // don't do radius damage to the other, because all the damage
  // was done in the impact
  T_RadiusDamage (self, self.owner, 120, other);

  //      sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
  self.origin = self.origin - 8 * normalize(self.velocity);

  WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
  WriteByte (MSG_MULTICAST, TE_EXPLOSION);
  WriteCoord (MSG_MULTICAST, self.origin_x);
  WriteCoord (MSG_MULTICAST, self.origin_y);
  WriteCoord (MSG_MULTICAST, self.origin_z);
  multicast (self.origin, MULTICAST_PHS);

  remove(self);
};



/*
   ================
   W_FireRocket
   ================
   */
void() W_FireRocket =
{
  self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

  //RUNE SERV: cloak rune. No sound
  if (self.runetype != RN_CLOAK)

    sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

  msg_entity = self;
  WriteByte (MSG_ONE, SVC_SMALLKICK);

  newmis = spawn ();
  newmis.owner = self;

  //  *************************************************************************
  //  anti-missile rune
  newmis.classname = "rocket";
  //  *************************************************************************

  newmis.movetype = MOVETYPE_FLYMISSILE;
  newmis.solid = SOLID_BBOX;

  // set newmis speed

  makevectors (self.v_angle);
  newmis.velocity = aim(self, 1000);
  newmis.velocity = newmis.velocity * 1000;
  newmis.angles = vectoangles(newmis.velocity);

  newmis.touch = T_MissileTouch;

  // set newmis duration
  newmis.nextthink = time + 5;
  newmis.think = SUB_Remove;

  setmodel (newmis, "progs/missile.mdl");
  setsize (newmis, '0 0 0', '0 0 0');
  setorigin (newmis, self.origin + v_forward*8 + '0 0 16');
};

/*
   ===============================================================================

   LIGHTNING

   ===============================================================================
   */

void(entity from, float damage) LightningHit =
{
  WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
  WriteByte (MSG_MULTICAST, TE_LIGHTNINGBLOOD);
  WriteCoord (MSG_MULTICAST, trace_endpos_x);
  WriteCoord (MSG_MULTICAST, trace_endpos_y);
  WriteCoord (MSG_MULTICAST, trace_endpos_z);
  multicast (trace_endpos, MULTICAST_PVS);

  T_Damage (trace_ent, from, from, damage);
};

/*
   =================
   LightningDamage
   =================
   */
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
  local entity            e1, e2;
  local vector            f;

  f = p2 - p1;
  normalize (f);
  f_x = 0 - f_y;
  f_y = f_x;
  f_z = 0;
  f = f*16;

  e1 = e2 = world;

  traceline (p1, p2, FALSE, self);
  if (trace_ent.takedamage)
  {
    LightningHit (from, damage);
    if (self.classname == "player")
    {
      if (other.classname == "player")
        trace_ent.velocity_z = trace_ent.velocity_z + 400;
    }
  }
  e1 = trace_ent;

  traceline (p1 + f, p2 + f, FALSE, self);
  if (trace_ent != e1 && trace_ent.takedamage)
  {
    LightningHit (from, damage);
  }
  e2 = trace_ent;

  traceline (p1 - f, p2 - f, FALSE, self);
  if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
  {
    LightningHit (from, damage);
  }
};


void() W_FireLightning =
{
  local   vector          org;
  local   float           cells;

  if (self.ammo_cells < 1)
  {
    self.weapon = W_BestWeapon ();
    W_SetCurrentAmmo ();
    return;
  }

  // explode if under water
  if (self.waterlevel > 1)
  {
    cells = self.ammo_cells;
    self.ammo_cells = 0;
    W_SetCurrentAmmo ();
    T_RadiusDamage (self, self, 35*cells, world);
    return;
  }

  if (self.t_width < time)
  {

    //RUNE SERV: cloak rune. No sound
    if (self.runetype != RN_CLOAK)

      sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
    self.t_width = time + 0.6;
  }
  msg_entity = self;
  WriteByte (MSG_ONE, SVC_SMALLKICK);

  self.currentammo = self.ammo_cells = self.ammo_cells - 1;

  org = self.origin + '0 0 16';

  //RUNE SERV: Haste makes lightning fire twices as far
  if (self.runetype == RN_HASTE)
    traceline (org, org + v_forward*1200, TRUE, self);
  else

    traceline (org, org + v_forward*600, TRUE, self);

  WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
  WriteByte (MSG_MULTICAST, TE_LIGHTNING2);
  WriteEntity (MSG_MULTICAST, self);
  WriteCoord (MSG_MULTICAST, org_x);
  WriteCoord (MSG_MULTICAST, org_y);
  WriteCoord (MSG_MULTICAST, org_z);
  WriteCoord (MSG_MULTICAST, trace_endpos_x);
  WriteCoord (MSG_MULTICAST, trace_endpos_y);
  WriteCoord (MSG_MULTICAST, trace_endpos_z);
  multicast (org, MULTICAST_PHS);

  LightningDamage (self.origin, trace_endpos + v_forward*4, self, 30);
};


//=============================================================================

//  *************************************************************************
//  Pipe bomb rune to detonate grenades
void () Detonate =
{
  local entity missile;  //  declares the float missile

  missile = findradius (self.origin, 10000);  //  find everything within a 10000 radius
  while(missile)  //  loops through everything put in missile entity
  {
    if ((missile.classname == "grenade") && (missile.owner == self))  // checks to see if the grenades are yours
    {
      missile.nextthink = time;  //  send message that it is time to react
    }
    missile = missile.chain; //  links every grenade found so they all go BOOM!
  }
};
//  *************************************************************************

void() GrenadeExplode =
{
  T_RadiusDamage (self, self.owner, 120, world);  // original code
  //  *************************************************************************
  //  pipe bomb rune to decrease count of grenades out
  self.owner.pipes = self.owner.pipes - 1;
  if (self.owner.pipes < 0)
  {
    self.owner.pipes = 0;
  }
  //  *************************************************************************
  WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
  WriteByte (MSG_MULTICAST, TE_EXPLOSION);
  WriteCoord (MSG_MULTICAST, self.origin_x);
  WriteCoord (MSG_MULTICAST, self.origin_y);
  WriteCoord (MSG_MULTICAST, self.origin_z);
  multicast (self.origin, MULTICAST_PHS);

  remove (self);
};

void() GrenadeTouch =
{
  if (other == self.owner)
    return;         // don't explode on owner
  if (other.takedamage == DAMAGE_AIM)
  {
    GrenadeExplode();
    return;
  }
  sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);  // bounce sound
  if (self.velocity == '0 0 0')
    self.avelocity = '0 0 0';
};

/*
   ================
   W_FireGrenade
   ================
   */
void() W_FireGrenade =
{
  self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

  //RUNE SERV: cloak rune. No sound
  if (self.runetype != RN_CLOAK)

    sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

  msg_entity = self;
  WriteByte (MSG_ONE, SVC_SMALLKICK);

  newmis = spawn ();
  newmis.owner = self;
  newmis.movetype = MOVETYPE_BOUNCE;
  newmis.solid = SOLID_BBOX;
  newmis.classname = "grenade";

  // set newmis speed

  makevectors (self.v_angle);

  if (self.v_angle_x)
    newmis.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
  else
  {
    newmis.velocity = aim(self, 10000);
    newmis.velocity = newmis.velocity * 600;
    newmis.velocity_z = 200;
  }

  newmis.avelocity = '300 300 300';

  newmis.angles = vectoangles(newmis.velocity);

  newmis.touch = GrenadeTouch;

  // set newmis duration

  //  *************************************************************************
  //  pipe bomb rune
  if (self.runetype == RN_PIPE)  //
  {
    newmis.nextthink = time + 30;
  }
  else
  {
    newmis.nextthink = time + 2.5; // original qw code
  }
  //  *************************************************************************

  newmis.think = GrenadeExplode;

  setmodel (newmis, "progs/grenade.mdl");
  setsize (newmis, '0 0 0', '0 0 0');
  setorigin (newmis, self.origin);
};


//=============================================================================

void() spike_touch;
void() superspike_touch;


/*
   ===============
   launch_spike

   Used for both the player and the ogre
   ===============
   */
void(vector org, vector dir) launch_spike =
{
  newmis = spawn ();
  newmis.owner = self;
  newmis.movetype = MOVETYPE_FLYMISSILE;
  newmis.solid = SOLID_BBOX;

  newmis.angles = vectoangles(dir);

  newmis.touch = spike_touch;
  newmis.classname = "spike";
  newmis.think = SUB_Remove;
  newmis.nextthink = time + 6;
  setmodel (newmis, "progs/spike.mdl");
  setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
  setorigin (newmis, org);

  //RUNE SERV: Haste rune makes them fly faster
  if (self.runetype == RN_HASTE) newmis.velocity = dir * 2000; else

    newmis.velocity = dir * 1000;
};

void() W_FireSuperSpikes =
{
  local vector    dir;
  local entity    old;

  //RUNE SERV: cloak rune. No sound
  if (self.runetype != RN_CLOAK)

    sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
  self.attack_finished = time + 0.2;
  self.currentammo = self.ammo_nails = self.ammo_nails - 2;
  dir = aim (self, 1000);
  launch_spike (self.origin + '0 0 16', dir);
  newmis.touch = superspike_touch;
  setmodel (newmis, "progs/s_spike.mdl");
  setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
  msg_entity = self;
  WriteByte (MSG_ONE, SVC_SMALLKICK);
};

void(float ox) W_FireSpikes =
{
  local vector    dir;
  local entity    old;

  makevectors (self.v_angle);

  if (self.ammo_nails >= 2 && self.weapon == IT_SUPER_NAILGUN)
  {
    W_FireSuperSpikes ();
    return;
  }

  if (self.ammo_nails < 1)
  {
    self.weapon = W_BestWeapon ();
    W_SetCurrentAmmo ();
    return;
  }

  //RUNE SERV: cloak rune. No sound
  if (self.runetype != RN_CLOAK)

    sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
  self.attack_finished = time + 0.2;
  self.currentammo = self.ammo_nails = self.ammo_nails - 1;
  dir = aim (self, 1000);
  launch_spike (self.origin + '0 0 16' + v_right*ox, dir);

  msg_entity = self;
  WriteByte (MSG_ONE, SVC_SMALLKICK);
};



.float hit_z;
void() spike_touch =
{
  local float rand;
  if (other == self.owner)
    return;

  if (other.solid == SOLID_TRIGGER)
    return; // trigger field, do nothing

  if (pointcontents(self.origin) == CONTENT_SKY)
  {
    remove(self);
    return;
  }

  // hit something that bleeds
  if (other.takedamage)
  {
    spawn_touchblood (9);
    T_Damage (other, self, self.owner, 9);
  }
  else
  {
    WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
    if (self.classname == "wizspike")
      WriteByte (MSG_MULTICAST, TE_WIZSPIKE);
    else if (self.classname == "knightspike")
      WriteByte (MSG_MULTICAST, TE_KNIGHTSPIKE);
    else
      WriteByte (MSG_MULTICAST, TE_SPIKE);
    WriteCoord (MSG_MULTICAST, self.origin_x);
    WriteCoord (MSG_MULTICAST, self.origin_y);
    WriteCoord (MSG_MULTICAST, self.origin_z);
    multicast (self.origin, MULTICAST_PHS);
  }

  remove(self);

};

void() superspike_touch =
{
  local float rand;
  if (other == self.owner)
    return;

  if (other.solid == SOLID_TRIGGER)
    return; // trigger field, do nothing

  if (pointcontents(self.origin) == CONTENT_SKY)
  {
    remove(self);
    return;
  }

  // hit something that bleeds
  if (other.takedamage)
  {
    spawn_touchblood (18);
    T_Damage (other, self, self.owner, 18);
  }
  else
  {
    WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte (MSG_MULTICAST, TE_SUPERSPIKE);
    WriteCoord (MSG_MULTICAST, self.origin_x);
    WriteCoord (MSG_MULTICAST, self.origin_y);
    WriteCoord (MSG_MULTICAST, self.origin_z);
    multicast (self.origin, MULTICAST_PHS);
  }

  remove(self);

};


/*
   ===============================================================================

   PLAYER WEAPON USE

   ===============================================================================
   */

void() W_SetCurrentAmmo =
{
  player_run ();          // get out of any weapon firing states

  self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );

  if (self.weapon == IT_AXE)
  {
    self.currentammo = 0;
    if (self.runetype == RN_AXE && self.runevar == 1)
    {
      self.weaponmodel = "";
    }
    else
    {
      self.weaponmodel = "progs/v_axe.mdl";
    }
    self.weaponframe = 0;
  }
  else if (self.weapon == IT_SHOTGUN)
  {
    self.currentammo = self.ammo_shells;
    self.weaponmodel = "progs/v_shot.mdl";
    self.weaponframe = 0;
    self.items = self.items | IT_SHELLS;
  }
  else if (self.weapon == IT_SUPER_SHOTGUN)
  {
    self.currentammo = self.ammo_shells;
    self.weaponmodel = "progs/v_shot2.mdl";
    self.weaponframe = 0;
    self.items = self.items | IT_SHELLS;
  }
  else if (self.weapon == IT_NAILGUN)
  {
    self.currentammo = self.ammo_nails;
    self.weaponmodel = "progs/v_nail.mdl";
    self.weaponframe = 0;
    self.items = self.items | IT_NAILS;
  }
  else if (self.weapon == IT_SUPER_NAILGUN)
  {
    self.currentammo = self.ammo_nails;
    self.weaponmodel = "progs/v_nail2.mdl";
    self.weaponframe = 0;
    self.items = self.items | IT_NAILS;
  }
  else if ((self.weapon == IT_GRENADE_LAUNCHER)  && (self.runetype != RN_NOMIS))
  {
    self.currentammo = self.ammo_rockets;
    self.weaponmodel = "progs/v_rock.mdl";
    self.weaponframe = 0;
    self.items = self.items | IT_ROCKETS;
  }
  else if ((self.weapon == IT_ROCKET_LAUNCHER) && (self.runetype != RN_NOMIS))
  {
    self.currentammo = self.ammo_rockets;
    self.weaponmodel = "progs/v_rock2.mdl";
    self.weaponframe = 0;
    self.items = self.items | IT_ROCKETS;
  }
  else if (self.weapon == IT_LIGHTNING)
  {
    self.currentammo = self.ammo_cells;
    self.weaponmodel = "progs/v_light.mdl";
    self.weaponframe = 0;
    self.items = self.items | IT_CELLS;
  }
  else
  {
    self.currentammo = 0;
    self.weaponmodel = "";
    self.weaponframe = 0;
  }
};

float() W_BestWeapon =
{
  local   float   it;

  it = self.items;

  if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_LIGHTNING) )
    return IT_LIGHTNING;
  else if(self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN) )
    return IT_SUPER_NAILGUN;
  else if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
    return IT_SUPER_SHOTGUN;
  else if(self.ammo_nails >= 1 && (it & IT_NAILGUN) )
    return IT_NAILGUN;
  else if(self.ammo_shells >= 1 && (it & IT_SHOTGUN) )
    return IT_SHOTGUN;

  /*
     if(self.ammo_rockets >= 1 && (it & IT_ROCKET_LAUNCHER) && (self.runetype != RN_NOMIS) )
     return IT_ROCKET_LAUNCHER;
     else if(self.ammo_rockets >= 1 && (it & IT_GRENADE_LAUNCHER) && (self.runetype != RN_NOMIS) )
     return IT_GRENADE_LAUNCHER;

*/

  return IT_AXE;
};

float() W_CheckNoAmmo =
{
  if (self.currentammo > 0)
    return TRUE;

  if (self.weapon == IT_AXE)
    return TRUE;

  self.weapon = W_BestWeapon ();

  W_SetCurrentAmmo ();

  // drop the weapon down
  return FALSE;
};

/*
   ============
   W_Attack

   An attack impulse can be triggered now
   ============
   */
void()  player_axe1;
void()  player_axeb1;
void()  player_axec1;
void()  player_axed1;
void()  player_shot1;
void()  player_nail1;
void()  player_light1;
void()  player_rocket1;

//RUNE SERV: Predefs
void() Haste_Sound;
void() Strength_Sound;

void() W_Attack =
{
  local   float   r;

  if (!W_CheckNoAmmo ())
    return;

  //RUNE SERV: So much stuff here.. prevents lag.
  if (self.runetype != 0)
  {
    if (self.runetype == RN_HASTE) Haste_Sound();

    if (self.runetype == RN_STRENGTH) Strength_Sound();

    if (self.runetype == RN_BERSERK) Strength_Sound();

    if (self.runetype == RN_CLOAK) self.runetime = time + 3;

    //           if (self.runetype == RN_IMPACT)
    //              particle (self.origin, '0 0 10', 96, 250);
  }

  makevectors     (self.v_angle);                 // calculate forward angle for velocity
  //        self.show_hostile = time + 1;   // wake monsters up

  if (self.weapon == IT_AXE)
  {
    //RUNE SERV: Speed weapons fire.
    if (self.runetype == RN_HASTE) self.attack_finished = time + 0.20; else

      self.attack_finished = time + 0.5;

    //RUNE SERV: cloak rune. No sound
    if (self.runetype != RN_CLOAK)

      sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
    r = random();
    if (r < 0.25)
      player_axe1 ();
    else if (r<0.5)
      player_axeb1 ();
    else if (r<0.75)
      player_axec1 ();
    else
      player_axed1 ();
  }
  else if (self.weapon == IT_SHOTGUN)
  {
    player_shot1 ();

    //RUNE SERV: Speed weapons fire.
    if (self.runetype == RN_HASTE) self.attack_finished = time + 0.25; else

      self.attack_finished = time + 0.5;
    W_FireShotgun ();
  }
  else if (self.weapon == IT_SUPER_SHOTGUN)
  {
    player_shot1 ();

    //RUNE SERV: Speed weapons fire.
    if (self.runetype == RN_HASTE) self.attack_finished = time + 0.35; else

      self.attack_finished = time + 0.7;
    W_FireSuperShotgun ();
  }
  else if (self.weapon == IT_NAILGUN)
  {
    player_nail1 ();
  }
  else if (self.weapon == IT_SUPER_NAILGUN)
  {
    player_nail1 ();
  }
  else if (self.weapon == IT_GRENADE_LAUNCHER)
  {
    //KT:  Insert Starburst stuff here..
    if (self.grenade_type == 1)
    {
      fire_starburst();
      if (self.runetype == RN_HASTE) self.attack_finished = time + 0.3;//ouch
      else
        self.attack_finished = time + 1;  //No more burst spamming =)
      return;
    }

    //  *************************************************************************
    //  pipe bomb rune
    if ((self.runetype != RN_PIPE) || ((self.runetype == RN_PIPE) && (self.pipes < 6)))
    {
      player_rocket1();  // original qw code
    }
    //  *************************************************************************

    //RUNE SERV: Speed weapons fire.
    if (self.runetype == RN_HASTE) self.attack_finished = time + 0.3; else

      self.attack_finished = time + 0.6;
    //  *************************************************************************
    //  pipe bomb rune
    if (self.runetype == RN_PIPE)
    {
      if (self.pipes >= 10) // limits max # of pipe bombs out
      {
        centerprint(self,"No more than\n10 Delayed Grenades\nat a time!");
      }
      else
      {
        self.pipes = (self.pipes + 1);
        W_FireGrenade();
      }
    }
    else
    {
      W_FireGrenade();
    }
  }
  else if (self.weapon == IT_ROCKET_LAUNCHER)
  {

    player_rocket1();  //call our model frame usage

    if (self.rocket_type == 0)
    {
      //RUNE SERV: Speed weapons fire.
      if (self.runetype == RN_HASTE) self.attack_finished = time + 0.35;
      else

        self.attack_finished = time + 0.8;

      W_FireRocket();

    }

    if (self.rocket_type == 1)  //we are using guided missile
    {
      //self.attack_finished = time + 9999999;  //so we cant fire again

      fire_guided();

    }

  }
  else if (self.weapon == IT_LIGHTNING)
  {
    self.attack_finished = time + 0.1;

    //RUNE SERV: cloak rune. No sound
    if (self.runetype != RN_CLOAK)

      sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
    player_light1();
  }
};

/*
   ============
   W_ChangeWeapon

   ============
   */
void() W_ChangeWeapon =
{
  local   float   it, am, fl;

  it = self.items;
  am = 0;

  if (self.impulse == 1)
  {
    fl = IT_AXE;
  }
  else if (self.impulse == 2)
  {
    fl = IT_SHOTGUN;
    if (self.ammo_shells < 1)
      am = 1;
  }
  else if (self.impulse == 3)
  {
    fl = IT_SUPER_SHOTGUN;
    if (self.ammo_shells < 2)
      am = 1;
  }
  else if (self.impulse == 4)
  {
    fl = IT_NAILGUN;
    if (self.ammo_nails < 1)
      am = 1;
  }
  else if (self.impulse == 5)
  {
    fl = IT_SUPER_NAILGUN;
    if (self.ammo_nails < 2)
      am = 1;
  }
  else if (self.impulse == 6  && (self.runetype != RN_NOMIS))
  {
    fl = IT_GRENADE_LAUNCHER;
    if (self.ammo_rockets < 1)
      am = 1;
  }
  else if (self.impulse == 7  && (self.runetype != RN_NOMIS))
  {
    fl = IT_ROCKET_LAUNCHER;
    if (self.ammo_rockets < 1)
      am = 1;
  }
  else if (self.impulse == 8)
  {
    fl = IT_LIGHTNING;
    if (self.ammo_cells < 1)
      am = 1;
  }

  self.impulse = 0;

  if (!(self.items & fl))
  {       // don't have the weapon or the ammo
    sprint (self, PRINT_HIGH, "no weapon.\n");
    return;
  }

  if (am)
  {       // don't have the ammo
    sprint (self, PRINT_HIGH, "not enough ammo.\n");
    return;
  }

  //
  // set weapon, set ammo
  //
  self.weapon = fl;
  W_SetCurrentAmmo ();
};

/*
   ============
   CheatCommand
   ============
   */
void() CheatCommand =
{
  //      if (deathmatch || coop)
  return;

  self.ammo_rockets = 100;
  self.ammo_nails = 200;
  self.ammo_shells = 100;
  self.items = self.items |
    IT_AXE |
    IT_SHOTGUN |
    IT_SUPER_SHOTGUN |
    IT_NAILGUN |
    IT_SUPER_NAILGUN |
    IT_GRENADE_LAUNCHER |
    IT_ROCKET_LAUNCHER |
    IT_KEY1 | IT_KEY2;

  self.ammo_cells = 200;
  self.items = self.items | IT_LIGHTNING;

  self.weapon = IT_ROCKET_LAUNCHER;
  self.impulse = 0;
  W_SetCurrentAmmo ();
};

/*
   ============
   CycleWeaponCommand

   Go to the next weapon with ammo
   ============
   */
void() CycleWeaponCommand =
{
  local   float   it, am;

  it = self.items;
  self.impulse = 0;

  while (1)
  {
    am = 0;
    if (self.runetype == RN_AXE)
    {
      return;
    }
    if (self.weapon == IT_LIGHTNING)
    {
      self.weapon = IT_AXE;
    }
    else if (self.weapon == IT_AXE)
    {
      self.weapon = IT_SHOTGUN;
      if (self.ammo_shells < 1)
        am = 1;
    }
    else if (self.weapon == IT_SHOTGUN)
    {
      self.weapon = IT_SUPER_SHOTGUN;
      if (self.ammo_shells < 2)
        am = 1;
    }
    else if (self.weapon == IT_SUPER_SHOTGUN)
    {
      self.weapon = IT_NAILGUN;
      if (self.ammo_nails < 1)
        am = 1;
    }
    else if (self.weapon == IT_NAILGUN)
    {
      self.weapon = IT_SUPER_NAILGUN;
      if (self.ammo_nails < 2)
        am = 1;
    }
    else if (self.weapon == IT_SUPER_NAILGUN  && (self.runetype != RN_NOMIS))
    {
      self.weapon = IT_GRENADE_LAUNCHER;
      if (self.ammo_rockets < 1)
        am = 1;
    }
    else if (self.weapon == IT_SUPER_NAILGUN  && (self.runetype == RN_NOMIS))
    {
      self.weapon = IT_LIGHTNING;
      if (self.ammo_cells < 1)
        am = 1;
    }
    else if (self.weapon == IT_GRENADE_LAUNCHER  && (self.runetype != RN_NOMIS))
    {
      self.weapon = IT_ROCKET_LAUNCHER;
      if (self.ammo_rockets < 1)
        am = 1;
    }
    else if (self.weapon == IT_ROCKET_LAUNCHER)
    {
      self.weapon = IT_LIGHTNING;
      if (self.ammo_cells < 1)
        am = 1;
    }

    if ( (self.items & self.weapon) && am == 0)
    {
      W_SetCurrentAmmo ();
      return;
    }
  }

};


/*
   ============
   CycleWeaponReverseCommand

   Go to the prev weapon with ammo
   ============
   */
void() CycleWeaponReverseCommand =
{
  local   float   it, am;

  it = self.items;
  self.impulse = 0;

  while (1)
  {
    am = 0;

    if (self.runetype == RN_AXE)
    {
      return;
    }

    if (self.weapon == IT_LIGHTNING && (self.runetype != RN_NOMIS))
    {
      self.weapon = IT_ROCKET_LAUNCHER;
      if (self.ammo_rockets < 1)
        am = 1;
    }
    else if (self.weapon == IT_LIGHTNING && (self.runetype == RN_NOMIS))
    {
      self.weapon = IT_SUPER_NAILGUN;
      if (self.ammo_nails < 2)
        am = 1;
    }
    else if (self.weapon == IT_ROCKET_LAUNCHER && (self.runetype != RN_NOMIS))
    {
      self.weapon = IT_GRENADE_LAUNCHER;
      if (self.ammo_rockets < 1)
        am = 1;
    }
    else if (self.weapon == IT_GRENADE_LAUNCHER)
    {
      self.weapon = IT_SUPER_NAILGUN;
      if (self.ammo_nails < 2)
        am = 1;
    }
    else if (self.weapon == IT_SUPER_NAILGUN)
    {
      self.weapon = IT_NAILGUN;
      if (self.ammo_nails < 1)
        am = 1;
    }
    else if (self.weapon == IT_NAILGUN)
    {
      self.weapon = IT_SUPER_SHOTGUN;
      if (self.ammo_shells < 2)
        am = 1;
    }
    else if (self.weapon == IT_SUPER_SHOTGUN)
    {
      self.weapon = IT_SHOTGUN;
      if (self.ammo_shells < 1)
        am = 1;
    }
    else if (self.weapon == IT_SHOTGUN)
    {
      self.weapon = IT_AXE;
    }
    else if (self.weapon == IT_AXE)
    {
      self.weapon = IT_LIGHTNING;
      if (self.ammo_cells < 1)
        am = 1;
    }

    if ( (it & self.weapon) && am == 0)
    {
      W_SetCurrentAmmo ();
      return;
    }
  }

};


//KT:  select_alternative_weapon - name says everything.

void() select_alternative_weapon =
{
  if (self.weapon == IT_AXE)
    sprint (self, PRINT_HIGH, "no alternative weapon for axe just yet.. \n");

  if (self.weapon == IT_SHOTGUN)
    sprint (self, PRINT_HIGH, "no alternative weapon for shotgun just yet.. \n");

  if (self.weapon == IT_SUPER_SHOTGUN)
    sprint (self, PRINT_HIGH, "no alternative weapon for super shotgun just yet.. \n");

  if (self.weapon == IT_NAILGUN)
    sprint (self, PRINT_HIGH, "no alternative weapon for nailgun just yet.. \n");

  if (self.weapon == IT_SUPER_NAILGUN)
    sprint (self, PRINT_HIGH, "no alternative weapon for super nailgun just yet.. \n");

  if (self.weapon == IT_GRENADE_LAUNCHER)
  {
    if (self.grenade_type == 0)
    {
      sprint(self, PRINT_HIGH, "�Starburst�\n");
    }

    if (self.grenade_type == 1 || self.weapon != IT_GRENADE_LAUNCHER)
    {
      sprint(self, PRINT_HIGH, "�Grenade Launcher�\n");
    }

    self.grenade_type = self.grenade_type + 1;

    if (self.grenade_type > 1)
      self.grenade_type = 0;
  }

  if (self.weapon == IT_ROCKET_LAUNCHER)
    sprint (self, PRINT_HIGH, "no alternative weapon for rocket launcher just yet.. \n");

  if (self.weapon == IT_LIGHTNING)
    sprint(self, PRINT_HIGH, "no alternative wepaon for lightning gun just yet..  \n");

};

/*
   ============
   ServerflagsCommand

   Just for development
   ============
   */
void() ServerflagsCommand =
{
  serverflags = serverflags * 2 + 1;
};

//RUNE SERV: Impulse Predefs
void(float numspawn) Rune_SpawnAll;
void() Rune_Button;
void() Rune_Activate;
void() Rune_Tell;
void() MOTD;
void() Uturn;
void(entity flearcvr, entity fleaownr) GetFleas;
void() Welcomemsg;
void() Neutron_Blow;
void() Neutron_Spawn;
/*
   ============
   ImpulseCommands

   ============
   */
void() ImpulseCommands =
{
  if (!(self.classname == "dorkwad"))
  {
    local string timeleft;
    //  *************************************************************************
    //  hook mod
    //  uses impulse 95.  set in hook.qc
    if (self.motd_count == 10 && grapflag == 0)
    {
      CheckGrapHook ();
    }
    //  *************************************************************************
    if (self.impulse >= 1 && self.impulse <= 8)
    {
      if (self.impulse == 6)
      {
        if (self.grenade_type == 0)
        {
          sprint(self, PRINT_HIGH, "�Starburst�\n");
        }

        if (self.grenade_type == 1 || self.weapon != IT_GRENADE_LAUNCHER)
        {
          sprint(self, PRINT_HIGH, "�Grenade Launcher�\n");
        }

        self.grenade_type = self.grenade_type + 1;


        if (self.grenade_type > 1)
          self.grenade_type = 0;
      }

      if (self.impulse == 7)
      {
        if (self.ammo_rockets > 0) {
          if (self.rocket_type == 0)
          {
            sprint(self, PRINT_HIGH, "�Guided Missile�\n");
          }

          else //if (self.grenade_type == 1 || self.weapon != IT_GRENADE_LAUNCHER)
            if (self.rocket_type == 1)
            {

              sprint(self, PRINT_HIGH, "�Rocket Launcher�\n");
            }

          self.rocket_type = self.rocket_type + 1;

          if (self.rocket_type > 1)
            self.rocket_type = 0;
        }
      }

      W_ChangeWeapon ();

    }

    if (self.impulse == 9)
      //                CheatCommand ();
      stuffcmd(self,"kill\n");
    if (self.impulse == 10)
      CycleWeaponCommand ();
    if (self.impulse == 11)
      ServerflagsCommand ();
    if (self.impulse == 12)
      CycleWeaponReverseCommand ();

    /*********************\
     * RUNE SERV: Impulses *
     \*********************/

    // U-Turn
    if (self.impulse == 96) Uturn();

    //Activate ability
    // if (self.impulse == 100 && self.motd_count == 10) Rune_Button();
    if (self.impulse == 100) Rune_Button();

    //What rune do I have?
    //if (self.impulse == 99 && self.motd_count == 10) Rune_Tell();
    if (self.impulse == 99) Rune_Tell();

    //I don't like my rune!
    if (self.impulse == 98 && self.runetype
        && !(self.runetype == RN_SHIELD && self.runevar == 1)) //If you're not currently shielded.
    {
      if ((self.runetype == RN_DARK) && (self.runevar > 0))
      {
        Lights_on();
        if (self.flash_flag == TRUE)

          //  ************************************************************************
          //  mod for flashlight
          //  turn off flashlight
        {
          self.flash_flag = FALSE;
          self.flash.think = SUB_Remove;
        }
      }

      else if (self.runetype == RN_INTANG)
      {
        self.runevar = 0;
        self.runetime = time;
        centerprint(self,"Tangible\n");
        self.takedamage = DAMAGE_AIM;
      }

      else if (self.runetype == RN_VAMP)
      {
        if (darkcount > 0)
        {
          self.runevar = 0;
          stuffcmd(self,"v_cshift 0 0 0 0\n");
          msg_entity = self;
          WriteByte (MSG_ONE, 12);
          WriteByte (MSG_ONE, 0);
          WriteString (MSG_ONE, "a");
        }
        else
        {
          self.runevar = 0;
          stuffcmd(self,"v_cshift 0 0 0 0\n");
          msg_entity = self;
          WriteByte (MSG_ONE, 12);
          WriteByte (MSG_ONE, 0);
          WriteString (MSG_ONE, "m");
        }
      }

      else if (self.runetype == RN_PIPE)
      {
        Detonate();
        self.pipes = 0;
      }
      else if (self.runetype == RN_PACK)
      {
        if (self.ammo_shells > 100)
        {
          self.ammo_shells = 100;
        }
        if (self.ammo_nails > 200)
        {
          self.ammo_nails = 200;
        }
        if (self.ammo_rockets > 100)
        {
          self.ammo_rockets = 100;
        }
        if (self.ammo_cells > 100)
        {
          self.ammo_cells = 100;
        }
      }

      if ((self.runetype == RN_ATTRACT) || (self.runetype == RN_AXE))
      {
        if (cursetime == 0)
        {
          centerprint(self, "Can't drop CURSED Rune!\n");
        }
        else
        {
          if (self.curse_time <= time)
          {
            self.runetype = 0;
            Rune_Activate();
            stuffcmd(self,"v_cshift 0 0 0 0\nbf\n");
            centerprint(self,"Rune Removed");
            if (runecurrent < runemax) Rune_SpawnAll(1);
          }
          else
          {
            centerprint(self, "Can't drop CURSED Rune yet!\n");
            timeleft = ftos(self.curse_time - time);
            sprint(self,PRINT_HIGH, "Must hold for ");
            sprint(self,PRINT_HIGH, timeleft);
            sprint(self,PRINT_HIGH, " more seconds\n");
          }
        }
      }
      else if (self.runetype == RN_SHAMB) {
        // kill self.runent
        spawn_tfog(self.runent.origin);
        remove(self.runent);
        self.runetype = 0;
        Rune_Activate();
        stuffcmd(self,"v_cshift 0 0 0 0\nbf\n");
        centerprint(self,"Rune Removed");
        if (runecurrent < runemax) Rune_SpawnAll(1);
      }
      else if (self.runetype == RN_NEUTRON)
      {
        centerprint(self, "Can't drop Neutron Bomb Rune!\n\nGet underwater before it blows!\n");
      }
      else
      {
        self.runetype = 0;
        Rune_Activate();
        stuffcmd(self,"v_cshift 0 0 0 0\nbf\n");
        centerprint(self,"Rune Removed");
        if (runecurrent < runemax) Rune_SpawnAll(1);
      }
    }

    //What's this server?
    if (self.impulse == 97)
    {
      //           self.motd_time = time;
      //           self.motd_count = 0;
      MOTD();
    }

    //  welcome/helpscreen
    if (self.impulse == 102)
    {
      if (self.runetype == RN_AXE || self.runetype == RN_ATTRACT)
      {
        self.runetype = 0;
      }
      self.butthdcnt = self.butthdcnt - 1;
      stuffcmd (self, "setinfo runehelp 0\nkill\n");
    }

    // for testing various functions
    /*
       if (self.impulse == 103)
       {
       self.ammo_cells = self.ammo_cells + 1;
       if ((pointcontents(self.origin)) == CONTENT_EMPTY)
       {
       sprint(self,PRINT_HIGH, "pointcontents is empty\n");
       }
       if ((pointcontents(self.origin)) == CONTENT_SOLID)
       {
       sprint(self,PRINT_HIGH, "pointcontents is SOLID\n");
       }
       if ((pointcontents(self.origin)) == CONTENT_WATER)
       {
       sprint(self,PRINT_HIGH, "pointcontents is WATER\n");
       }
       if ((pointcontents(self.origin)) == CONTENT_SLIME)
       {
       sprint(self,PRINT_HIGH, "pointcontents is SLIME\n");
       }
       if ((pointcontents(self.origin)) == CONTENT_LAVA)
       {
       sprint(self,PRINT_HIGH, "pointcontents is LAVA\n");
       }
       if ((pointcontents(self.origin)) == CONTENT_SKY)
       {
       sprint(self,PRINT_HIGH, "pointcontents is SKY\n");
       }
       if ((pointcontents(self.origin)) == 0)
       {
       sprint(self,PRINT_HIGH, "pointcontents is 0\n");
       }
       }
       */


    /*************************\
     * RUNE SERV: Impulses end *
     \*************************/

    //  *************************************************************************
    //  for flashlight mod
    //  turns flashlight on and off
    if (self.impulse == 101)
    {
      if (self.runetype == RN_DARK && self.runevar == 1)
      {
        Rune_Button();
      }
      else
      {
        flash_toggle();
      }
    }
    //  *************************************************************************
    if (self.impulse == 105)
      select_alternative_weapon();

    if (self.impulse == 151) {

      makevectors(self.v_angle);
      boobs = vtos(v_up);
      sprint(self,PRINT_HIGH, boobs);

      makevectors(self.v_angle);
      boobs = vtos(v_forward);
      sprint(self,PRINT_HIGH, boobs);

      makevectors(self.v_angle);
      boobs = vtos(v_right);
      sprint(self,PRINT_HIGH, boobs);
      sprint(self,PRINT_HIGH, "\n");
    }
    if (self.impulse == 155)
      fire_starburst();
    if (self.impulse == 162)
    {
      sprint(self, PRINT_HIGH, "hehe!\n");
      launch_fish();
    }
    if (self.impulse == 169)
      telefrag_bomb();
    if (self.impulse == 170)
      squish();
    if (self.impulse == 171)
      lavatrap();
    if (self.impulse == 190)
      screen_thing();
    if (self.impulse == 198)
      Neutron_Spawn();
    if (self.impulse == 199)
      Rune_ShamblerSpawn();
    /*
       if (self.impulse > 103)
       {
       MOTD();
       }
       if ((self.impulse < 90) && (self.impulse > 20))
       {
       MOTD();
       }
       */

    self.impulse = 0;
  }  //end of "not classname dorkwad"
};

/*
   ============
   W_WeaponFrame

   Called every frame so impulse events can be handled as well as possible
   ============
   */
void() W_WeaponFrame =
{
  if (time < self.attack_finished)
    return;

  ImpulseCommands ();

  // check for attack
  //    if ((self.button0) && !((self.runetype == RN_INTANG) && (self.runevar == 1)) && (self.motd_count == 10) && !(self.classname == "dorkwad"))
  if ((self.button0) && !((self.runetype == RN_INTANG) && (self.runevar == 1)) && !(self.classname == "dorkwad"))
  {
    SuperDamageSound ();
    W_Attack ();
  }

};

/*
   ========
   SuperDamageSound

   Plays sound if needed
   ========
   */
void() SuperDamageSound =
{

  //RUNE SERV: cloak rune. No sound
  if (self.runetype == RN_CLOAK) return;

  if (self.super_damage_finished > time)
  {
    if (self.super_sound < time)
    {
      self.super_sound = time + 1;
      sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
    }
  }
  return;
};


