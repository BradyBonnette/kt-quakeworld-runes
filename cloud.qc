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
