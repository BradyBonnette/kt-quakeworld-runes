
/************\
 * BreakChain *
 \************/

void (entity Head) BreakChain =
{
  local entity link;

  link = Head.goalentity;
  while (link != world)
  {
    Head = link.goalentity;
    remove (link);
    link = Head;
  }
};

/*********\
 * LinkPos *
 \*********/

void () LinkPos =
{
  makevectors (self.enemy.angles);
  setorigin (self, self.owner.origin + ( ( ( self.enemy.origin + 
            (v_up * 16 * (!self.enemy.button2)) + (v_forward * 16) ) - self.owner.origin ) *
        ( self.weapon ) ) );
  self.nextthink = time + 0.01;
};

/***********\
 * MakeChain *
 \***********/

entity (entity head, entity tail, float num) MakeChain =
{
  local entity link, prevlink;
  local float linknum;

  linknum = num;
  num = num + 1;
  prevlink = world;
  while (linknum > 0)
  {
    link = spawn();

    link.goalentity = prevlink;
    prevlink = link;

    link.owner = head;
    link.enemy = tail;
    link.weapon = linknum / num;
    link.movetype = MOVETYPE_NOCLIP;
    link.solid = SOLID_NOT;
    link.angles_z = 51 * linknum;
    link.angles_y = 41 * linknum;
    link.angles_x = 31 * linknum;
    link.avelocity = '310 410 510';
    setmodel (link, "progs/bit.mdl");
    setsize (link, '0 0 0', '0 0 0');
    makevectors (tail.angles);
    setorigin (link, head.origin + ( ( ( tail.origin 
              + (v_up * 16 * (!tail.button2)) + ( v_forward * 16 ) ) - head.origin )
          * ( link.weapon ) ) );
    link.nextthink = time + 0.01;
    link.think = LinkPos;
    linknum = linknum - 1;
  }
  return link;
};


/************\
 * HookVanish *
 \************/

void () HookVanish =
{
  self.owner.hook_out = FALSE;
  if (self.enemy.classname == "player")
    self.enemy.attack_finished = time + 0.1;
  BreakChain (self);
  remove (self);
};

/**********\
 * HookPull *
 \**********/

void () HookPull =
{
  local vector vel, spray;
  local float v;

  if ((!self.owner.button0 && (self.owner.weapon == IT_MORNINGSTAR)) ||
      (self.owner.teleport_time > time ) || self.owner.deadflag )
  {
    if (self.enemy.takedamage && (self.weapon > 0))
    {       self.enemy.nextthink = time + 0.1; }
    HookVanish();
    return;
  }
  else
  {
    if (self.enemy.takedamage)
    {
      sound (self, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);
      T_Damage (self.enemy, self, self.owner, 1);
      makevectors (self.v_angle);
      spray_x = 100 * crandom();
      spray_y = 100 * crandom();
      spray_z = 100 * crandom() + 50;

      //                        SpawnBlood (self.origin, spray, 20); // too many parameters

      SpawnBlood (self.origin, 20);
      if (self.weapon > 0)
      {
        self.enemy.nextthink = time + 9999999;
        if (self.enemy.classname == "player")
          self.enemy.attack_finished = time + 9999999;
      }
      if (self.enemy.health <= 0)
      {
        if (self.weapon > 0)
          self.enemy.nextthink = time + 0.1;
      }
      if (self.enemy.solid == SOLID_SLIDEBOX)
      {
        self.velocity = '0 0 0';
        setorigin (self, self.enemy.origin +
            self.enemy.mins +
            (self.enemy.size * 0.5));
      }
      else
      {
        self.velocity = self.enemy.velocity;
      }
    }
    else
    {
      self.velocity = self.enemy.velocity;
    }
    if (self.enemy.solid == SOLID_NOT)
    {
      HookVanish();
      return;
    }
    makevectors (self.owner.angles);
    vel = self.origin - ( self.owner.origin + (v_up * 16 *
          (!self.owner.button2)) + (v_forward * 16));
    v = vlen (vel);
    if (v <= 100)
      vel = normalize(vel) * v * 10;  
    if ( v > 100 )
      vel = normalize(vel) * 1000;  
    self.owner.velocity = vel;
    self.nextthink = time + 0.1;
  }
};

/**************\
 * T_ChainTouch *
 \**************/

void() T_ChainTouch =
{
  if (other == self.owner)
    return;         // don't attach to owner

  if (pointcontents(self.origin) == CONTENT_SKY)
  {
    HookVanish();
    return;
  }

  if (other.takedamage)
  {
    T_Damage (other, self, self.owner, 10 );
    //                SpawnBlood (self.origin, self.velocity, 10);  // too many parameters
    SpawnBlood (self.origin, 10);
  }
  else
  {
    self.avelocity = '0 0 0';
  }

  sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);

  if (!self.owner.button0)
  {
    HookVanish();
    return;
  }
  else
  {
    if (other.solid == SOLID_SLIDEBOX)
    {
      setorigin (self, other.origin + other.mins +
          (other.size * 0.5));
      self.velocity = '0 0 0';
    }
    else
    {
      self.velocity = other.velocity;
    }
    self.weapon = other.nextthink - time;
    self.enemy = other;
    self.nextthink = time + 0.1;
    self.think = HookPull;
    self.touch = SUB_Null;
  }
};

/*************\
 * W_FireChain *
 \*************/

void() W_FireChain =
{
  local entity hook;

  self.hook_out = TRUE;
  hook = spawn ();
  hook.owner = self;
  hook.movetype = MOVETYPE_FLY;
  hook.solid = SOLID_BBOX;

  // set hook speed 

  makevectors (self.v_angle);
  hook.velocity = aim(self, 1000);
  hook.velocity = hook.velocity * 1000;
  hook.angles = vectoangles(hook.velocity);
  hook.avelocity = '0 0 -500';

  hook.touch = T_ChainTouch;

  // set hook sound
  hook.nextthink = time + 5;
  hook.think = HookVanish;

  setmodel (hook, "progs/star.mdl");
  setsize (hook, '0 0 0', '0 0 0');     
  setorigin (hook, self.origin + (v_forward*16) + '0 0 16' );

  hook.goalentity = MakeChain (hook, self, 8);
};
