float () crandom;

void (entity ent) CopyToBodyQue;

void (string gibname, float dm) ThrowGib;

vector (float dm) VelocityForDamage;

void () PlayerDead;


void (vector org, vector vel) SpawnMeatSpray;

void () disc_precache =
{

  precache_model ("progs/lavaball.mdl");
  precache_sound ("player/axhit2.wav");
  precache_sound ("player/drown1.wav");
  precache_sound ("player/slimbrn2.wav");
  precache_sound ("knight/sword1.wav");
  precache_sound ("weapons/ax1.wav");

};

vector (vector sdir, float dist, vector ang) GetFront =
{

  local float deg;

  deg = (180 / dist);
  if ( ((ang_y < 90) && (ang_y > -90)) )
  {

    sdir_y = (sdir_y + (ang_y / deg));

  }
  else
  {

    if ( (ang_y >= 90.000) )
    {

      sdir_y = ((sdir_y + dist) - (ang_y / deg));

    }
    else
    {

      if ( (ang_y <= -90.000) )
      {

        sdir_y = ((sdir_y - dist) - (ang_y / deg));

      }

    }

  }
  if ( (ang_y < 0.000) )
  {

    sdir_x = (sdir_x + (ang_y / deg));

  }
  else
  {

    sdir_x = (sdir_x - (ang_y / deg));

  }
  return ( sdir );

};

void () RemoveDisc =
{

  sound (self.owner,CHAN_WEAPON,"weapons/lock4.wav",1,ATTN_NORM);
  if ( (self.owner.classname == "player") )
  {

    sprint (self.owner,PRINT_HIGH,"Your Shooting Star has burned out\n");

  }
  T_RadiusDamage (self, self.owner, 100, other);


  self.origin = self.origin - 8 * normalize(self.velocity);

  WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
  WriteByte (MSG_MULTICAST, TE_EXPLOSION);
  WriteCoord (MSG_MULTICAST, self.origin_x);
  WriteCoord (MSG_MULTICAST, self.origin_y);
  WriteCoord (MSG_MULTICAST, self.origin_z);
  multicast (self.origin, MULTICAST_PHS);

  self.owner.discfired = FALSE;
  remove (self);

};

void () DiscThink =
{

  if ( ((self.attack_finished < time) || (self.bounced >= 20)) )
  {

    RemoveDisc ();
    return ;

  }
  if ( (self.velocity == '0 0 0') )
  {

    RemoveDisc ();
    return ;

  }
  if ( (self.movetype == MOVETYPE_BOUNCE) )
  {

    self.movetype = MOVETYPE_FLYMISSILE;
    self.angles = vectoangles (self.velocity);

  }
  self.skin = !self.skin;
  if ( (self.flags & FL_ONGROUND) )
  {

    self.flags = (self.flags - FL_ONGROUND);

  }
  self.think = DiscThink;
  //   self.nextthink = .1;  // time;

};

void () DiscTouch =
{

  local float dam;

  if (other == self.owner)
  {
    RemoveDisc ();
    return ;
  }
  if (other.classname == "sucker")
  {
    RemoveDisc ();
    return ;
  }
  if (self.bounced >= 38)
  {

    RemoveDisc ();
    return ;

  }
  if (self.velocity == '0 0 0') 
  {

    RemoveDisc ();
    return ;

  }
  if (self.flags & FL_ONGROUND)
  {

    self.flags = (self.flags - FL_ONGROUND);

  }
  if ( other.takedamage )
  {

    dam = (50 + (fabs ((self.velocity_x * 0.013)) + fabs ((self.velocity_y * 0.013))));
    T_Damage (other,self,self.owner,dam);
    traceline ((self.origin - (v_forward * 8)),(self.origin + (v_forward * 16)),TRUE,self);
    setorigin (self,(trace_endpos - (v_forward * 2)));
    self.movetype = MOVETYPE_BOUNCE;
    self.bounced = (self.bounced + 1);
    self.nextthink = (time + 0.05);
    self.velocity = (self.velocity * 1.38);
    sound (self,CHAN_WEAPON,"weapons/ax1.wav",1,ATTN_NORM);

  }
  else
  {

    traceline ((self.origin - (v_forward * 8)),(self.origin + (v_forward * 16)),TRUE,self);
    setorigin (self,(trace_endpos - (v_forward * 2)));
    self.movetype = MOVETYPE_BOUNCE;
    self.bounced = (self.bounced + 1);
    self.nextthink = (time + 0.05);
    self.velocity = (self.velocity * 1.38);
    if ( (random () < 0.5) )
    {

      sound (self,CHAN_WEAPON,"player/axhit2.wav",1,ATTN_NORM);

    }
    else
    {

      sound (self,CHAN_WEAPON,"weapons/tink1.wav",1,ATTN_NORM);

    }

  }

};

void () W_FireDisc = {

  local entity missile;
  local entity mpuff;
  local vector start;
  local vector finish;
  local vector dir;
  local float speedfactor;

  if ( self.discfired )
  {
    self.mydisc.think = RemoveDisc;
    //      self.mydisc.nextthink = time;
    if ( !self.mydisc.bounced )
    {
      self.mydisc.bounced = TRUE;

    }
    return ;

  }
  sound (self,CHAN_WEAPON,"knight/sword1.wav",1.000,ATTN_NORM);
  speedfactor = self.disccount;
  if ( (speedfactor > 50) )
  {

    speedfactor = 50;

  }
  speedfactor = ((speedfactor / 50) * 1.5);
  missile = spawn ();
  missile.owner = self;
  self.mydisc = missile;
  self.discfired = TRUE;
  self.disccount = 0;
  self.disclanded = FALSE;
  missile.movetype = MOVETYPE_FLYMISSILE;
  missile.bounced = 0.000;
  missile.classname = "disc";
  missile.solid = SOLID_BBOX;
  makevectors (self.v_angle);
  start = (self.origin + '0.000 0.000 16.000');
  finish = (start + (v_forward * 600.000));
  dir = (finish - start);
  if (missile.owner.super_damage_finished > time)
  {
    missile.velocity = ((normalize (dir) * 680) * 4);
  }
  else
  {
    missile.velocity = (normalize (dir) * 680);
  }
  missile.velocity = (missile.velocity * (1 + speedfactor));
  missile.angles = vectoangles (missile.velocity);
  missile.touch = DiscTouch;
  missile.attack_finished = (time + 8);
  missile.nextthink = time;
  missile.think = DiscThink;
  missile.skin = 0;
  setmodel (missile,"progs/lavaball.mdl");
  setsize (missile,'0.000 0.000 0.000','0.000 0.000 0.000');
  setorigin (missile,((self.origin + (v_forward * 8.000)) + '0.000 0.000 16.000'));

};


