//Guided missile code--a re-attempt and will be made even better.  Thanks to Paul for the debugging process.  3/9/2005

void () fakeTouch = {

};

void () fakeThink = {

  if (self.owner.health < 1 || self.owner.isFake == 0) {
    self.modelindex = modelindex_none;
    self.owner.runetype = self.runetype;
    remove (self);
    return;
  }

  self.angles = self.owner.angles;

  self.frame = self.owner.frame;

  self.nextthink = time + 0.01;
};

void (entity missileOwner) spawnGuidedFakePlayer = {

  local entity fake;

  fake = spawn();
  fake.classname = "guideddude";
  fake.solid = SOLID_SLIDEBOX;
  fake.movetype = MOVETYPE_STEP;
  fake.takedamage = DAMAGE_AIM;

  setmodel(fake, "progs/player.mdl");
  setorigin(fake, missileOwner.origin);
  setsize (fake, VEC_HULL2_MIN, VEC_HULL2_MAX);

  fake.fixangle = 1;
  fake.health = 5;

  fake.owner = missileOwner;
  fake.touch = fakeTouch;
  fake.runetype = missileOwner.runetype;
  missileOwner.runetype = 0;

  fake.angles = missileOwner.angles;
  fake.colormap = missileOwner.colormap;

  fake.think = fakeThink;
  fake.nextthink = time + 0.01;
};

void () guided_touch = {
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

  self.owner.origin = self.owner.ownerOriginalPosition;
  self.owner.velocity = self.owner.velocity*0;
  self.owner.weaponmodel = self.owner.currentWeaponmodel;

  self.owner.classname = "player";
  self.owner.takedamage = DAMAGE_YES;

  self.owner.isFake = 0;
  remove(self);

};

void () guided_think = {

  if (self.owner.health < 0)
  {
    WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte (MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord (MSG_MULTICAST, self.origin_x);
    WriteCoord (MSG_MULTICAST, self.origin_y);
    WriteCoord (MSG_MULTICAST, self.origin_z);
    multicast (self.origin, MULTICAST_PHS);


    remove(self);
    return;
  }
  makevectors (self.owner.v_angle);
  self.velocity = aim(self, 1000);
  self.velocity = self.velocity * 550;


  self.angles = vectoangles(self.velocity);
  //setorigin (self.owner, self.origin + v_forward*8 + '0 0 16');

  setorigin (self.owner, self.origin + v_forward*-20 + v_up*-20 + v_right*0);
  self.owner.velocity = self.velocity;

  self.nextthink = time + 0.001;
};


void () fire_guided = {

  self.ownerOriginalPosition = self.origin;
  self.isFake = 1;

  spawnGuidedFakePlayer(self);

  self.classname = "dorkwad";
  self.takedamage = DAMAGE_NO;

  //	self.fovstr = infokey(self, "fov");
  //stuffcmd(self, "fov 50\n");

  //	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

  //RUNE SERV: cloak rune. No sound
  if (self.runetype != RN_CLOAK)

    sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

  msg_entity = self;
  WriteByte (MSG_ONE, SVC_SMALLKICK);

  newmis = spawn ();
  newmis.owner = self;

  newmis.classname = "guided";

  newmis.movetype = MOVETYPE_FLYMISSILE;
  newmis.solid = SOLID_BBOX;

  //velocity and direction
  makevectors (self.v_angle);
  newmis.velocity = aim(self, 1000);
  newmis.velocity = newmis.velocity * 550;

  newmis.angles = vectoangles(newmis.velocity);

  newmis.touch = guided_touch;
  newmis.nextthink = time + 0.01;
  newmis.think = guided_think;

  setmodel (newmis, "progs/missile.mdl");
  setsize (newmis, '0 0 0', '0 0 0');             
  //setorigin (newmis, self.origin + v_forward*50 + '0 0 16');
  makevectors(self.v_angle);
  //setorigin (newmis, self.origin + v_forward*50 + '0 0 16');
  setorigin (newmis, self.origin + v_forward*50 + v_up*50);
  self.currentWeaponmodel = self.weaponmodel;

  self.weaponmodel = "";


};



