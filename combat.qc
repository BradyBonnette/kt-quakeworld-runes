
void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;

/*SERVER
  void() monster_death_use;
  */

//RUNE SERV: Predef
void(vector org) spawn_tfog;
void() Spawn_Weird;

//============================================================================

/*
   ============
   CanDamage

   Returns true if the inflictor can directly damage the target.  Used for
   explosions and melee attacks.
   ============
   */
float(entity targ, entity inflictor) CanDamage =
{
  // bmodels need special checking because their origin is 0,0,0
  if (targ.movetype == MOVETYPE_PUSH)
  {
    traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
    if (trace_fraction == 1)
      return TRUE;
    if (trace_ent == targ)
      return TRUE;
    return FALSE;
  }

  traceline(inflictor.origin, targ.origin, TRUE, self);
  if (trace_fraction == 1)
    return TRUE;
  traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
  if (trace_fraction == 1)
    return TRUE;
  traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
  if (trace_fraction == 1)
    return TRUE;
  traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
  if (trace_fraction == 1)
    return TRUE;
  traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
  if (trace_fraction == 1)
    return TRUE;

  return FALSE;
};


/*
   ============
   Killed
   ============
   */
void(entity targ, entity attacker) Killed =
{
  local entity oself;

  oself = self;
  self = targ;

  if (self.health < -99)
    self.health = -99;              // don't let sbar look bad if a player

  if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
  {       // doors, triggers, etc
    self.th_die ();
    self = oself;
    return;
  }

  self.enemy = attacker;

  // bump the monster counter
  if (self.flags & FL_MONSTER)
  {
    killed_monsters = killed_monsters + 1;
    WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
  }

  ClientObituary(self, attacker);

  self.takedamage = DAMAGE_NO;
  self.touch = SUB_Null;
  self.effects = 0;

  /*SERVER
    monster_death_use();
    */
  self.th_die ();

  self = oself;
};

//RUNE SERV: Predefs
void() Rune_Radio;
float() crandom;

/*
   ============
   T_Damage

   The damage is coming from inflictor, but get mad at attacker
   This should be the only function that ever reduces health.
   ============
   */
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage=
{
  local   vector  dir;
  local   entity  oldself;
  local   float   save;
  local   float   take;
  local   string  s;
  local   string  attackerteam, targteam; // , mytemp;


  if (!targ.takedamage)
    return;
  /*		
                bprint(PRINT_MEDIUM, "T_Damage():  targ = ");
                bprint(PRINT_MEDIUM, targ.classname);
                bprint(PRINT_MEDIUM, "\n");

                bprint(PRINT_MEDIUM, "T_Damage():  inflictor = ");
                bprint(PRINT_MEDIUM, inflictor.classname);
                bprint(PRINT_MEDIUM, "\n");

                bprint(PRINT_MEDIUM, "T_Damage():  attacker = ");
                bprint(PRINT_MEDIUM, attacker.classname);
                bprint(PRINT_MEDIUM, "\n");
                */

  if (targ.classname == "guideddude") {
    targ = targ.owner;
  }
  //
  //
  // used by buttons and triggers to set activator for target firing
  damage_attacker = attacker;

  // check for quad damage powerup on the attacker
  if (attacker.super_damage_finished > time)
    damage = damage * 4;

  //RUNE SERV: Helps lag?
  if (attacker.runetype != 0 || targ.runetype != 0)
  {
    //impact rune does more
    if (attacker.runetype == RN_IMPACT)
      damage = damage * 1.3;

    //Rune of Strength deals twice damage.
    if (attacker.runetype == RN_STRENGTH) damage = damage * 2;

    //The Rune of Resistance cuts damage taken.
    if (targ.runetype == RN_RESIST)
    {
      damage = damage * 0.5;
      sound (targ, CHAN_BODY, "items/protect3.wav", 1, ATTN_NORM);
    }

    //Vampiric Rune gives back.
    if (attacker.runetype == RN_VAMP)
    {
      if (targ.deathtype != "dspot" && attacker.health < attacker.max_health && attacker != targ)
      {
        if (targ.classname == "player")
        {
          //  *************************************************************************
          //  
          if (darkcount > 0)
          {
            attacker.health = attacker.health + (2 * damage);
          }
          else
          {
            attacker.health = attacker.health + (damage);
          }
        }
        else
        {
          if (darkcount > 0)
          {
            attacker.health = attacker.health + (0.4 * damage);
          }
          else
          {
            attacker.health = attacker.health + (0.2 * damage);
          }
        }
        //              attacker.health = attacker.health + (0.2 * damage);
        if (attacker.health > attacker.max_health) attacker.health = attacker.max_health;
        sound (attacker, CHAN_BODY, "wizard/wpain.wav", 1, ATTN_NORM);
      }
    }

    //Uncloak when hurt
    if (targ.runetype == RN_CLOAK) targ.runetime = time + 4;

    //Enviro rune protections
    if (targ.runetype == RN_ENVIRO &&
        ((attacker.solid == SOLID_BSP && attacker != world) ||
         attacker.classname == "trap_shooter" ||
         attacker.classname == "fireball" ||
         inflictor.classname == "deathorb" ||
         inflictor.classname == "gfire" ||
         inflictor.classname == "radioactive" ||
         attacker.classname == "trap_spikeshooter"))
      damage = 0;

    //  Anti-missile rune
    if (targ.runetype == RN_NOMIS &&
        (inflictor.classname == "rocket" ||
         inflictor.classname == "grenade"))
      damage = 0;

    //Vengance Rune does equal damage back
    if (targ.runetype == RN_VENG)
    {
      if (attacker != targ && attacker != world && attacker.runetype != RN_VENG)
      {
        targ.runevar = 10;
        T_Damage(attacker, targ, targ, damage);
        targ.runevar = 0;
      }
    }

    //Berserker rune
    if(targ.runetype == RN_BERSERK)
      damage = damage * 3;
    if(attacker.runetype == RN_BERSERK)
      damage = damage * 6;

    //RUNE SERV: Big rune section end.
  }

  // save damage based on the target's armor level

  if (inflictor.classname != "fleas")
  {
    save = ceil(targ.armortype*damage);
    if (targ.runetype != RN_MARMOR)
    {
      if (save >= targ.armorvalue)
      {
        save = targ.armorvalue;
        targ.armortype = 0;     // lost all armor
        targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
      }
      targ.armorvalue = targ.armorvalue - save;
    }
    take = ceil(damage-save);

  }
  else
  {
    take = damage;
  }

  // add to the damage total for clients, which will be sent as a single
  // message at the end of the frame
  // FIXME: remove after combining shotgun blasts?
  if (targ.flags & FL_CLIENT)
  {
    targ.dmg_take = targ.dmg_take + take;
    targ.dmg_save = targ.dmg_save + save;
    targ.dmg_inflictor = inflictor;
  }

  damage_inflictor = inflictor;        


  // figure momentum add


  if ( (inflictor != world) && (targ.movetype == MOVETYPE_WALK) )
  {
    dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
    dir = normalize(dir);
    // Set kickback for smaller weapons
    // Read: only if it's not yourself doing the damage
    if ( (damage < 60) & ((attacker.classname == "player") & (targ.classname == "player")) & ( attacker.netname != targ.netname)) 

      //RUNE SERV: Impact rune pushes more.
      if (attacker.runetype == RN_IMPACT)
        targ.velocity = targ.velocity + dir*damage*70;
      else

        targ.velocity = targ.velocity + dir * damage * 11;
    else                        
      // Otherwise, these rules apply to rockets and grenades                        
      // for blast velocity
      targ.velocity = targ.velocity + dir * damage * 8;

    // Rocket Jump modifiers
    if ( (rj > 1) & ((attacker.classname == "player") & (targ.classname == "player")) & ( attacker.netname == targ.netname)) 
      targ.velocity = targ.velocity + dir * damage * rj;

  }

  // check for godmode or invincibility
  if (targ.flags & FL_GODMODE)
    return;
  if (targ.invincible_finished >= time)
  {
    if (self.invincible_sound < time)
    {
      sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
      self.invincible_sound = time + 2;
    }
    return;
  }

  // team play damage avoidance
  //ZOID 12-13-96: self.team doesn't work in QW.  Use keys
  attackerteam = infokey(attacker, "team");
  targteam = infokey(targ, "team");

  if ((teamplay == 1) && (targteam == attackerteam) &&
      (attacker.classname == "player") && (attackerteam != ""))
    return;
  if ((teamplay == 3) && (targteam == attackerteam) &&
      (attacker.classname == "player") && (attackerteam != "") &&
      (targ != attacker))
    return;

  // do the damage
  targ.health = targ.health - take;

  if (targ.health <= 0)
  {
    // mytemp = inflictor.classname;
    // mytemp = mytemp;
    // bprint (PRINT_MEDIUM, mytemp);

    //RUNE SERV: Deathtypes
    if (inflictor.classname == "deathorb")
      targ.deathtype = "deathorb";
    else if (inflictor.classname == "gfire")
      targ.deathtype = "gfire";
    else if (inflictor.classname == "fleas")
      targ.deathtype = "fleas";
    else if (inflictor.classname == "knightspike")
      targ.deathtype = "knightspike";
    else if (inflictor.classname == "dspot")
      targ.deathtype = "dspot";
    else if (attacker.runetype == RN_ZAP && attacker.runevar == 10)
      targ.deathtype = "zapped";
    else if (attacker.runetype == RN_ZAP && attacker.runevar == 30)
      targ.deathtype = "hookzapped";
    else if (attacker.runetype == RN_ZAP && attacker.runevar == 20)
      targ.deathtype = "waterzap";
    else if (inflictor.classname == "radioactive")
      targ.deathtype = "radioactive";
    else if (attacker.runetype == RN_VENG && attacker.runevar == 10)
      targ.deathtype = "vengance";
    else if (inflictor.classname == "spikeball")
      targ.deathtype = "spikeball";
    else if (inflictor.runetype == RN_IMPACT && attacker.runevar == 10)
      targ.deathtype = "bodycheck";
    else if (inflictor.classname == "sucker")
      targ.deathtype = "sucker";
    else if (inflictor.classname == "hook")
      targ.deathtype = "hook";
    else if (inflictor.classname == "disc")
      targ.deathtype = "disc";
    else if (inflictor.classname == "neutron")
      targ.deathtype = "nuke";

    if (targ.runetype != 0)
    {
      if (targ.classname == "player")
        stuffcmd (targ,"v_cshift 0 0 0 1\n");

      //RUNE SERV: Radioactive types irradiate when killed
      if (targ.runetype == RN_RADIO)
      {
        local entity stemp;
        stemp = self; self = targ;
        Rune_Radio();
        self = stemp;
      }

      //RUNE SERV: Weird bubbles when killed
      if (targ.runetype == RN_WEIRD)
      {
        self.runevar = 0;
        while (self.runevar < 7)
        {
          self.runevar = self.runevar + 1;
          Spawn_Weird();
          self.runent.nextthink = self.runent.nextthink + 5;
        }
      }
    }

    Killed (targ, attacker);
    return;
  }

  // react to the damage
  oldself = self;
  self = targ;

  /*SERVER
    if ( (self.flags & FL_MONSTER) && attacker != world)
    {
  // get mad unless of the same class (except for soldiers)
  if (self != attacker && attacker != self.enemy)
  {
  if ( (self.classname != attacker.classname) 
  || (self.classname == "monster_army" ) )
  {
  if (self.enemy.classname == "player")
  self.oldenemy = self.enemy;
  self.enemy = attacker;
  FoundTarget ();
  }
  }
  }
  */
  if (self.th_pain)
  {
    self.th_pain (attacker, take);
  }

  self = oldself;
};

/*
   ============
   T_RadiusDamage
   ============
   */
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
  local   float   points;
  local   entity  head;
  local   vector  org;

  head = findradius(inflictor.origin, damage+40);

  while (head)
  {
    if (head != ignore)
    {
      if (head.takedamage)
      {
        org = head.origin + (head.mins + head.maxs)*0.5;
        points = 0.5*vlen (inflictor.origin - org);
        if (points < 0)
          points = 0;
        points = damage - points;
        if (head == attacker)
          points = points * 0.5;
        if (points > 0)
        {
          if (CanDamage (head, inflictor))
          {
            T_Damage (head, inflictor, attacker, points);
          }
        }
      }
    }
    head = head.chain;
  }
};

/*
   ============
   T_BeamDamage
   ============
   */
void(entity attacker, float damage) T_BeamDamage =
{
  local   float   points;
  local   entity  head;

  head = findradius(attacker.origin, damage+40);

  while (head)
  {
    if (head.takedamage)
    {
      points = 0.5*vlen (attacker.origin - head.origin);
      if (points < 0)
        points = 0;
      points = damage - points;
      if (head == attacker)
        points = points * 0.5;
      if (points > 0)
      {
        if (CanDamage (head, attacker))
        {
          T_Damage (head, attacker, attacker, points);
        }
      }
    }
    head = head.chain;
  }
};

