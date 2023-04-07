// prototypes
void () W_WeaponFrame;
void() W_SetCurrentAmmo;
void() player_pain;
void() player_stand1;
void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath;

float   modelindex_eyes, modelindex_player, runeparm;

//RUNE SERV: predefs
string() RandMap;
void () Next_Rune;

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/
        
string nextmap;

float   intermission_running;
float   intermission_exittime;

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void() info_intermission =
{
};



void() SetChangeParms =
{
	if (self.health <= 0)
	{
		SetNewParms ();
		return;
	}
 
// remove items
	self.items = self.items - (self.items & 
	(IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD) );
	
// cap super health
//	if (self.health > 100)
//		self.health = 100;
//	if (self.health < 50)
                self.health = 100; // always start new level at full health
	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;
	if (self.ammo_shells < 25)
		parm4 = 25;
	else
		parm4 = self.ammo_shells;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
	parm8 = self.weapon;
	parm9 = self.armortype * 100;

    parm15 = self.motd_count; // welcome msg flag

//RUNE SERV: Players keep runes across levels;
        parm16 = self.runetype;
};

void() SetNewParms =
{
	parm1 = IT_SHOTGUN | IT_AXE;
	parm2 = 100;
	parm3 = 0;
	parm4 = 25;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = 1;
	parm9 = 0;
        
//RUNE SERV: thingy *******************************************************************
//       parm16 =  0;  // for testing, change to rune# to start with
//  serverinfo sr is used to select starting rune for players
//  zero is no rune, player must pick one up
//  any value above last rune number, rune is ramdomly selected at player spawn
        parm16 = stof(infokey(world, "sr"));
        if (parm16 > TOTAL_RUNETYPE)
        {
                //if (self.motd_count == 10 || infokey(self,"runehelp") == "10")
                        if (runeselect == 0)
                        {
                              parm16 = random() * TOTAL_RUNETYPE;
                              parm16 = ceil(parm16);
                        }
                        if (runeselect == 1)
                        {
                              Next_Rune ();
                              parm16 = runeparm;
                        }
 						else               
                        	parm16 = 0;
                
        }
        if (runeselect == 2)
        {
          parm16 = 0;
        }

        parm15 = self.motd_count;
};

//RUNE SERV: predefs
void(float numspawn) Rune_SpawnAll;
void() Rune_Activate;

void() DecodeLevelParms =
{
// **************************************************************************
// removed so players don't loose everything just because server returned
// to starting map
/*
	if (serverflags)
	{
                if (world.model == "maps/start.bsp")
			SetNewParms ();         // take away all stuff on starting new episode
	}
*/
// **************************************************************************

	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weapon = parm8;
	self.armortype = parm9 * 0.01;
// parms 10 to 16 *************************************
// used to check values of parms for testing
//	local string sparm10, sparm11, sparm12, sparm13, sparm14, sparm15, sparm16;
//	sparm10 = ftos(parm10);
//	sprint(self,PRINT_HIGH, sparm10);
//	sprint(self,PRINT_HIGH, "parm 10\n");
//	sparm11 = ftos(parm11);
//	sprint(self,PRINT_HIGH, sparm11);
//	sprint(self,PRINT_HIGH, "parm 11\n");
//	sparm12 = ftos(parm12);
//	sprint(self,PRINT_HIGH, sparm12);
//	sprint(self,PRINT_HIGH, "parm 12\n");
//	sparm13 = ftos(parm13);
//	sprint(self,PRINT_HIGH, sparm13);
//	sprint(self,PRINT_HIGH, "parm 13\n");
//	sparm14 = ftos(parm14);
//	sprint(self,PRINT_HIGH, sparm14);
//	sprint(self,PRINT_HIGH, "parm 14\n");
//	sparm15 = ftos(parm15);
//	sprint(self,PRINT_HIGH, sparm15);
//	sprint(self,PRINT_HIGH, "parm 15\n");
//	sparm16 = ftos(parm16);
//	sprint(self,PRINT_HIGH, sparm16);
//	sprint(self,PRINT_HIGH, "parm 16\n");
// ***************************************************
        self.impulse = 0;
//RUNE SERV: Get the server variable for maximum runes. Other stuff too.
        if (deathmatch)
        {
           runemax = 50;
           runemax = cvar ("temp1");

           if (runemax <= 0) runemax = 16; //If no temp1 is less than 0, set default rune #.
           if (runemax > 100) runemax = 100; //Can't have more than 100 runes in a level.
        }
        self.runetype = parm16;
        self.motd_count = parm15;
//        parm15 = 0;
        self.deathtype = "";
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity() FindIntermission =
{
	local   entity spot;
	local   float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{       // pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;
	
	objerror ("FindIntermission: no spot");
};


void() GotoNextMap =
{
	local string newmap;

//ZOID: 12-13-96, samelevel is overloaded, only 1 works for same level

	if (cvar("samelevel") == 1)     // if samelevel is set, stay on same level
		changelevel (mapname);
	else {
		// configurable map lists, see if the current map exists as a
		// serverinfo/localinfo var
		newmap = infokey(world, mapname);
		if (newmap != "")
			changelevel (newmap);
		else
			changelevel (nextmap);
	}
};

/*
void() GotoNextMap =
{
//ZOID: 12-13-96, samelevel is overloaded, only 1 works for same level
	if (cvar("samelevel") == 1)     // if samelevel is set, stay on same level
		changelevel (mapname);
	else
		changelevel (nextmap);
};
*/


/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink =
{
      if (time < intermission_exittime)
              return;
	if (!self.button0 && !self.button1 && !self.button2)
		return;
	GotoNextMap ();
};

/*
============
execute_changelevel

The global "nextmap" has been set previously.
Take the players to the intermission spot
============
*/
void() execute_changelevel =
{


        if (nextmap == "end")
        {
                nextmap = "dm1";
        }

	local entity    pos;

	intermission_running = 1;
	
// enforce a wait time before allowing changelevel
	intermission_exittime = time + 5;

	pos = FindIntermission ();

// play intermission music
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);

	WriteByte (MSG_ALL, SVC_INTERMISSION);
	WriteCoord (MSG_ALL, pos.origin_x);
	WriteCoord (MSG_ALL, pos.origin_y);
	WriteCoord (MSG_ALL, pos.origin_z);
	WriteAngle (MSG_ALL, pos.mangle_x);
	WriteAngle (MSG_ALL, pos.mangle_y);
	WriteAngle (MSG_ALL, pos.mangle_z);
	
	other = find (world, classname, "player");
	while (other != world)
	{
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		other = find (other, classname, "player");
	}       

};


void() changelevel_touch =
{
	local entity    pos;

        if ((other.classname != "player") || (other.runetype == RN_INTANG && other.runevar == 1))
		return;

// if "noexit" is set, blow up the player trying to leave
//ZOID, 12-13-96, noexit isn't supported in QW.  Overload samelevel
//      if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
//RUNE SERV: Noexit random level switcher thing. Now samelevel. (9-16-97)
//        if ((cvar("samelevel") == 2) || ((cvar("samelevel") == 3) && (mapname != "start")))
        if ((cvar("samelevel") == 2) || ((cvar("samelevel") == 3) && (mapname != "start")) || (cvar("samelevel") == 4))
	{
		T_Damage (other, self, self, 1); // 50000);
		return;
	}

	bprint (PRINT_HIGH, other.netname);
	bprint (PRINT_HIGH," exited the level\n");
	
	nextmap = self.map;

	SUB_UseTargets ();

	self.touch = SUB_Null;

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() trigger_changelevel =
{
	if (!self.map)
		objerror ("chagnelevel trigger doesn't have map");
	
	InitTrigger ();
	self.touch = changelevel_touch;
};


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void() set_suicide_frame;

//RUNE SERV: Predefs
void() Resurrect;

// called by ClientKill and DeadThink
void() respawn =
{                                             
//RUNE SERV: remove color shifts
        stuffcmd(self,"v_cshift 0 0 0 1\n");

//RUNE SERV: Phoenix rune
        if (self.runetype == RN_PHOENIX && self.runevar > 0)
        {
//  *************************************************************************
//  disable hook before resurrecting
        self.hook = self.hook - (self.hook & HOOK_ON);
//  *************************************************************************
           CopyToBodyQue (self);
           Resurrect();
           return;
        }
	// make a copy of the dead body for appearances sake
	CopyToBodyQue (self);
	// set default spawn parms
	SetNewParms ();

//  ************************************************************************
//                        if ((self.runetype == RN_DARK) && (self.flash_flag == TRUE))
//                        {
//  ************************************************************************
//  mod for flashlight
//  turn off flashlight
//                                flash_off();
//  ************************************************************************
//                        }
//  ************************************************************************
	// respawn              
	PutClientInServer ();
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
        self.butthdcnt = self.butthdcnt + 1;
        if ((self.runetype == RN_AXE) ||(self.runetype == RN_ATTRACT))
        {
                centerprint(self, "Can't suicide while CURSED!");
                return;
        }

        if (self.runetype == RN_NEUTRON)
        {
                centerprint(self, "Can't suicide with Neutron Bomb!\n\nDeath will come to all\nsoon enough");
                return;
        }

/*
        if (self.motd_count != 10)
        {
                return;
        }
 */
 
/*
        if (self.butthdtime > (time - 30))
        {
                if (self.butthdcnt > 9)
                {
                        local string otherplace;
                        if (!(infokey(world, "op")))
                        {
                                stuffcmd(self,"disconnect\nconnect www.fbi.gov\n");
                        }
                        else
                        {
                                stuffcmd(self,"connect ");
                                otherplace = infokey(world, "op");
                                stuffcmd(self, otherplace);
                                stuffcmd(self,"\n");
                        }
                }
                if (self.butthdcnt > 4)
                {
                        stuffcmd(self,"name Ima_Butthead!\n");
                        centerprint(self, "Stop suiciding!\n\nYou're a Butthead!");
                }
        }              
*/
        else
        {
                self.butthdcnt = 1;
                self.butthdtime = time;
        }
        bprint (PRINT_MEDIUM, self.netname);
        bprint (PRINT_MEDIUM, " suicides\n");
        self.movetype = MOVETYPE_NOCLIP;
        set_suicide_frame ();
        self.modelindex = modelindex_player;
        logfrag (self, self);
        self.frags = self.frags - 2;    // extra penalty
//  ************************************************************************
//  Rune of Darkness
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
//  ************************************************************************
        }
//  ************************************************************************

//  *************************************************************************
//  disable hook before resurrecting
        self.hook = self.hook - (self.hook & HOOK_ON);
//  *************************************************************************
        respawn ();
        
};

float(vector v) CheckSpawnPoint =
{
	return FALSE;
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity() SelectSpawnPoint =
{
	local   entity spot, thing;
	local   float   pcount;

// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
		
// choose a info_player_deathmatch point
	spot = lastspawn;
	while (1)
	{
                spot = find(spot, classname, "info_player_deathmatch");
//                spot = find (spot, classname, "info_teleport_destination");
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
	
        spot = find (world, classname, "info_player_start");
//        spot = find (world, classname, "info_teleport_destination");
	if (!spot)
		error ("PutClientInServer: no info_player_start on level");
	
	return spot;
};

void() DecodeLevelParms;
void() PlayerDie;

/*
===========
ValidateUser


============
*/
float(entity e) ValidateUser =
{
/*
	local string    s;
	local string    userclan;
	local float     rank, rankmin, rankmax;

//
// if the server has set "clan1" and "clan2", then it
// is a clan match that will allow only those two clans in
//
	s = serverinfo("clan1");
	if (s)
	{
		userclan = masterinfo(e,"clan");
		if (s == userclan)
			return true;
		s = serverinfo("clan2");
		if (s == userclan)
			return true;
		return false;
	}

//
// if the server has set "rankmin" and/or "rankmax" then
// the users rank must be between those two values
//
	s = masterinfo (e, "rank");
	rank = stof (s);

	s = serverinfo("rankmin");
	if (s)
	{
		rankmin = stof (s);
		if (rank < rankmin)
			return false;
	}
	s = serverinfo("rankmax");
	if (s)
	{
		rankmax = stof (s);
		if (rankmax < rank)
			return false;
	}

	return true;
*/
};


/*
===========
PutClientInServer

called each time a player enters a new level
============
*/
void() PutClientInServer =
{
	local   entity spot;

	self.classname = "player";
	self.health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
   self.max_health = 100;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;                   // initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;
        
//RUNE SERV: Stuff when entering
   self.touch = SUB_Null;
   self.runetime = time;
   self.runevar = 0;
   self.runevector = '0 0 0';
   self.fleatime = time;
   self.fleaflag = 0;
        
	DecodeLevelParms ();
   Rune_Activate ();
   W_SetCurrentAmmo ();

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	
	self.deadflag = DEAD_NO;
// pausetime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;
	
	spot = SelectSpawnPoint ();

	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = TRUE;           // turn this way immediately
   self.runevector = self.origin;

// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';

	player_stand1 ();
	
	makevectors(self.angles);
	spawn_tfog (self.origin + v_forward*20);
 	spawn_tdeath (self.origin, self);
 	
 	//motd stuff
 	//if (self.motd_count != 1)
	//if (self.seen_motd = 1)
	 //self.motd_count = 0;
	 
	 //self.motd_count = 0;
	 
 	if (self.motd_count == 0)
 		self.motd_time = time + 12;
 		
 	else self.motd_count = 1;
 	
 	//set the motd count so it doesn't get counted again
   //self.motd_count = stof(infokey(self, "runehelp")); // setinfo rune 0

// Set Rocket Jump Modifiers
   rj = stof(infokey(world, "rj"));

// Set timer for cursed runes
   cursetime = stof(infokey(world, "cursetime"));

// Set flag for intangible rune to pick up items while intangible - 0 = no pickup
   intangflag = stof(infokey(world, "intangflag"));

// Set flag for cloaking rune to use eyes model - 0 = eyes
   cloakflag = stof(infokey(world, "cloakflag"));

// Set flag for neutron bomb rune use and time to respawn
   neutronflag = stof(infokey(world, "neutronflag"));

// Set flag for rune of darkness to use total darkness or ambient darkness - 0 = ambient
   darkflag = stof(infokey(world, "darkflag"));

// Set flag for grappling hook use - 1 = no use
   grapflag = stof(infokey(world, "grapflag"));

// Set flag for bonus item respawn messages - 0 = no messages
   respawnmsg = stof(infokey(world, "respawnmsg"));

// Set flag for Quad for all before game ends - 0 = no quad ending,
// anythhing else is time in seconds
   finalquad = stof(infokey(world, "finalquad"));

//KT:  For weapon types...
   self.grenade_type = 0;
   self.rocket_type = 0;

};


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start =
{
};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 =
{
};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void() info_player_deathmatch =
{
};

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void() info_player_coop =
{
};

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
*/
void() NextLevel =
{
	local entity o;

	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else if (!(serverflags & 1))
		{
			mapname = "e1m1";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2))
		{
			mapname = "e2m1";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4))
		{
			mapname = "e3m1";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8))
		{
			mapname = "e4m1";
			serverflags = serverflags - 7;
		}
 
		o = spawn();
		o.map = mapname;
               
        }
        else
	{
// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");
		if (!o || mapname == "start")
		{       // go back to same map if no trigger_changelevel
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;

        if (mapname == "dm6")
        {
                nextmap = "start";
        }

//RUNE SERV: If samelevel is 4, level selection is TOTALLY random.
        if (cvar("samelevel") == 4)
                   nextmap = RandMap();

	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}

};

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
void() CheckRules =
{       
	if (timelimit && time >= timelimit)
		NextLevel ();
	
	if (fraglimit && self.frags >= fraglimit)
		NextLevel ();

     if (timelimit && finalquad && (finalquad >= (timelimit - time)) && ((self.super_damage_finished) < (timelimit + 60)))
     {
          self.super_time = 1;
          centerprint(self,"\n\nQuad for all!");
          self.super_damage_finished = timelimit + 120;
          sound (self, CHAN_BODY, "items/damage.wav", 1, ATTN_NORM);
          
     }
};

//============================================================================

void() PlayerDeathThink =
{
	local entity    old_self;
	local float             forward;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else    
			self.velocity = forward * normalize(self.velocity);
	}

// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}
        self.fleaflag = 0;

// wait for any button down
	if (!self.button2 && !self.button1 && !self.button0)
		return;

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	respawn();
};


void() PlayerJump =
{
	local vector start, end;

	if (self.flags & FL_WATERJUMP)
		return;
	
	if (self.waterlevel >= 2)
	{
// play swiming sound
		if (self.swim_flag < time)
		{

//RUNE SERV: cloak rune. No sound
                        if (self.runetype == RN_CLOAK) return;

			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		return;
	}

//RUNE SERV: Rune of Flight does different jumpy things
//     if (self.runetype == RN_FLY)
//     {
//        self.velocity_z = self.velocity_z + 270;
//        return;
//     }

	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;         // don't pogo stick

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);       
	self.button2 = 0;

//RUNE SERV: cloak rune. No sound
     if (self.runetype != RN_CLOAK)

// player jumping sound
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
};


/*
===========
WaterMove

============
*/
.float  dmgtime;

//RUNE SERV: Predefs
void() Rune_Enviro;

void() WaterMove =
{
//RUNE SERV
        local float cells;

//RUNE SERV: Camel Fleas Rune effect deactivated by water (they got washed off)
        if (self.waterlevel >0)
        {
                self.fleaflag = 0;
        }

//RUNE SERV: Electric Rune goes kablammy!
        if (self.runetype == RN_ZAP && self.waterlevel > 1 && self.ammo_cells > 0)
        {
           cells = self.ammo_cells;
           sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
           self.runevar = 20;
           T_RadiusDamage (self, self, 20*cells, world);
           self.runevar = 0;
           self.ammo_cells = 0;
           return;
        }


//dprint (ftos(self.waterlevel));
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health < 0)
		return;

//RUNE SERV: Rune of Environmental Protection ignores enviro damage.
        if (self.runetype == RN_ENVIRO)
        {
           self.pain_finished = time + 1;
           self.dmgtime = time + 1;
           Rune_Enviro();
        }


	if (self.waterlevel != 3)
	{

//RUNE SERV: cloak rune. No sound. Modified loop
             if (self.runetype != RN_CLOAK)
             {

		if (self.air_finished < time)
			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		else if (self.air_finished < time + 9)
			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);

             } //RUNE SERV: end of loop

                self.air_finished = time + 12;
                self.dmg = 2;
	}


	else if (self.air_finished < time)
	{       // drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
                        if (self.runetype == RN_VAMP)
                        {
                                self.dmg = (self.dmg * 2);
                        }
                        T_Damage (self, world, world, self.dmg);
			self.pain_finished = time + 1;
		}
	}
	
	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{       
//RUNE SERV: cloak rune. No sound
                     if (self.runetype != RN_CLOAK)

			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{       // do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;

			T_Damage (self, world, world, 10*self.waterlevel);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{       // do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			T_Damage (self, world, world, 4*self.waterlevel);
		}
	}
	
	if ( !(self.flags & FL_INWATER) )
	{       

// player enter water sound

//RUNE SERV: cloak rune. No sound
             if (self.runetype != RN_CLOAK)
             {

                if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

             } //RUNE SERV: cloak rune.


		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}       
};

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8; 
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{       // solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{       // open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;  // safety net
			return;
		}
	}
};

//RUNE SERV: Predefs
void() Rune_Think;
void() Welcomemsg;
void() Neutron_SpawnAll;

/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void() PlayerPreThink =
{
	local   float   mspeed, aspeed;
        local   float   r, helpflag;

	if (intermission_running)
	{
		IntermissionThink ();   // otherwise a button could be missed between
		return;                                 // the think tics
	}

	if (self.view_ofs == '0 0 0')
		return;         // intermission or finale

	makevectors (self.v_angle);             // is this still used

//  *************************************************************************
//  Welcome/help screen
//        self.motd_count = stof(infokey(self, runehelp)); // setinfo rune 0

		//if (self.motd_time > time && self.motd_count == 0) {
	
		//if (self.motd_time >  time && self.motd_count = 0) {
		if (self.motd_time > time && self.motd_count == 0)
					Welcomemsg(); 
				
/*
        if (self.motd_count < 10) // not finished viewing
        {
                self.solid = SOLID_NOT;
                self.takedamage = DAMAGE_NO;

                if (self.button0)
                {
                        self.attack_state = 1;
                }
                if (self.motd_time < time)
                {
                        Welcomemsg ();
                }
        }

*/     

	CheckRules ();
	WaterMove ();
/*
	if (self.waterlevel == 2)
		CheckWaterJump ();
*/

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}
	
	if (self.deadflag == DEAD_DYING)
		return; // dying, so do nothing

	if (self.button2)
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;

//RUNE SERV: Message when you log onto the server
//        if (self.motd_time)
//          if (self.motd_time < time)
//                        {
//                                if (self.motd_count = 2)
//                                {
//                                        MOTD();
//                                        self.motd_count = 0;
//                                }
//                                self.motd_count = self.motd_count + 1;
//                                if (self.motd_count > 5) (self.motd_count =3);
//                        }

//RUNE SERV: Runes that need thinking
        if (self.runetype > 0) Rune_Think();

//RUNE SERV: Adding some more runes till too much.
        if (runeselect != 2 && runespawntime < time)
           if (runecurrent < runemax)
           {
              Rune_SpawnAll(1);
              runespawntime = time + 1 + random()*15;
           }

//Neutron rune spawning
        if (neutronflag > 0 && neutroncount == 0)
        {
                Neutron_SpawnAll();
        }

// teleporters can force a non-moving pause time
	if (time < self.pausetime)
		self.velocity = '0 0 0';

	if(time > self.attack_finished && self.currentammo == 0 && self.weapon != IT_AXE)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
	}
};
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/
void() CheckPowerups =
{
	if (self.health <= 0)
		return;

// invisibility
	if (self.invisible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{

//RUNE SERV: cloak rune. No sound
                     if (self.runetype != RN_CLOAK)

			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}


		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				sprint (self, PRINT_HIGH, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");

//RUNE SERV: cloak rune. No sound
                     if (self.runetype != RN_CLOAK)

				sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{       // just stopped
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}
		
	// use the eyes
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}
	else

		if (self.classname == "dorkwad")
			self.modelindex = modelindex_none;
		else
		
//RUNE SERV: Cloaky rune thing.
        if (self.runetype == RN_CLOAK && self.runevar == 1)
        {
                if (cloakflag == 0)
                {
                    self.modelindex = modelindex_eyes;    // use eyes
                }
                else
                {
                    self.modelindex = modelindex_none;    // don't use eyes
                }
        }

//RUNE SERV: Camo rune.
        else if (self.runetype == RN_CAMO && self.runevar == 1)
        {
                self.modelindex = modelindex_none;    // don't use eyes
        }

//RUNE SERV: Intangibility rune.
        else if (self.runetype == RN_INTANG && self.runevar == 1)
        {
                self.modelindex = modelindex_none;    // don't use eyes
        }
        /*
        else if (self.motd_count < 10)
        {
                self.modelindex = modelindex_none;
        }
        */
        else
        {
                self.modelindex = modelindex_player;    // don't use eyes
        }

// invincibility
	if (self.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3)
		{
			if (self.invincible_time == 1)
			{
				sprint (self, PRINT_HIGH, "Protection is almost burned out\n");
				stuffcmd (self, "bf\n");

//RUNE SERV: cloak rune. No sound
                     if (self.runetype != RN_CLOAK)

				sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			
			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if (self.invincible_finished < time)
		{       // just stopped
			self.items = self.items - IT_INVULNERABILITY;
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}

// super damage
	if (self.super_damage_finished)
	{

// sound and screen flash when items starts to run out

		if (self.super_damage_finished < time + 3)
		{
			if (self.super_time == 1)
			{
				sprint (self, PRINT_HIGH, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");

//RUNE SERV: cloak rune. No sound
                     if (self.runetype != RN_CLOAK)

				sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}         
			
			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.super_damage_finished < time)
		{       // just stopped
			self.items = self.items - IT_QUAD;
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}       

// suit 
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;          // don't drown

// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint (self, PRINT_HIGH, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");

//RUNE SERV: cloak rune. No sound
                     if (self.runetype != RN_CLOAK)

				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{       // just stopped
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}       

};


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void() PlayerPostThink =
{
	local   float   mspeed, aspeed;
	local   float   r;


	if (self.view_ofs == '0 0 0')
		return;         // intermission or finale
	if (self.deadflag)
	{
		return;
	}

// check to see if player landed and play landing sound 
	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) )
	{
//RUNE SERV: Loop modified to exclude people with cloak runes.
                if (self.watertype == CONTENT_WATER && self.runetype!= RN_CLOAK)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);

//RUNE SERV: Next loop is modified to exclude RN_ENVIRO holders.
                else if (self.jump_flag < -650 && self.runetype != RN_ENVIRO)
		{

//RUNE SERV: cloak rune. No sound
                     if (self.runetype != RN_CLOAK)

			T_Damage (self, world, world, 5);
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
			self.deathtype = "falling";
		}
		else

//RUNE SERV: cloak rune. No sound
                     if (self.runetype != RN_CLOAK)

			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
	}

	self.jump_flag = self.velocity_z;

	CheckPowerups ();

	W_WeaponFrame ();
};


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
	bprint (PRINT_HIGH, self.netname);
	bprint (PRINT_HIGH, " entered the game\n");

        stuffcmd (self, "alias activate impulse 100\n");// activates rune
        stuffcmd (self, "alias show impulse 99\n");     // shows rune you hold
        stuffcmd (self, "alias rune impulse 99\n");     // shows rune you hold
        stuffcmd (self, "alias hook impulse 95\n");     // launch/release hook
        stuffcmd (self, "alias +hook impulse 95\n");    // launch/release hook
        stuffcmd (self, "alias -hook impulse 95\n");    // launch/release hook
        stuffcmd (self, "alias runehelp impulse 97\n"); // help screen
        stuffcmd (self, "alias runes impulse 97\n");    // help screen
        stuffcmd (self, "alias runetype impulse 99\n"); // shows rune you hold
        stuffcmd (self, "alias droprune impulse 98\n"); // drops the rune you hold
        stuffcmd (self, "alias uturn impulse 96\n");    // does a u-turn
        stuffcmd (self, "alias light impulse 101\n");   // toggles flashlight on/off
        stuffcmd (self, "alias welcome impulse 102\n");   // toggles flashlight on/off
        stuffcmd (self, "bind * runes\n");
        stuffcmd (self, "bind f1 welcome\n");


        if (self.runetype > 0) Rune_Activate();

// a client connecting during an intermission can cause problems
	if (intermission_running)
		GotoNextMap ();
};


/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
	// let everyone else know
	bprint (PRINT_HIGH, self.netname);
	bprint (PRINT_HIGH, " left the game with ");
	bprint (PRINT_HIGH, ftos(self.frags));
	bprint (PRINT_HIGH, " frags\n");
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
//  ************************************************************************
//  Rune of Darkness
        if ((self.runetype == RN_DARK) && (self.runevar >0))
        {
//  ************************************************************************
//  turns lights back on
                Lights_on();
//  ************************************************************************

//  ************************************************************************
//  mod for flashlight
//  turn off flashlight
                        self.flash_flag = FALSE;
                        self.flash.think = SUB_Remove;
//  ************************************************************************
        }
//  ************************************************************************
	set_suicide_frame ();
};

/*
===========
ClientObituary

called when a player dies
============
*/
void(entity targ, entity attacker) ClientObituary =
{
	local   float rnum;
	local   string deathstring, deathstring2;
	local   string s;
        local   string  attackerteam, targteam, mytemp;

	rnum = random();

	if (targ.classname == "player")
	{
//  ************************************************************************
                        if (targ.runetype == RN_DARK)
			{
                                Lights_on();
                                if (targ.runevar > 0)
                                {
                                        if (targ.flash_flag == TRUE)

//  ************************************************************************
//  mod for flashlight
//  turn off flashlight
                                        {
                                                flash_off();
                                        }
//  ************************************************************************
                                }
                      }
//  ************************************************************************

//KT
      if (attacker.classname == "starburst")
      {
         if (attacker.owner == self)
         {
            bprint (PRINT_MEDIUM, attacker.owner.netname);
            bprint (PRINT_MEDIUM, " couldn't handle his own starburst!\n");
            attacker.owner.frags = attacker.owner.frags - 1;
            return;
         }
         else

         bprint (PRINT_MEDIUM, targ.netname);
         bprint (PRINT_MEDIUM, " was blown to smitherines by ");
         bprint (PRINT_MEDIUM, attacker.owner.netname);
         bprint (PRINT_MEDIUM, "\n");
         attacker.owner.frags = attacker.owner.frags + 1;
         return;

      }

      if (attacker.classname == "teledeath")
		{
			bprint (PRINT_MEDIUM,targ.netname);
			bprint (PRINT_MEDIUM," was telefragged by ");
			bprint (PRINT_MEDIUM,attacker.owner.netname);
			bprint (PRINT_MEDIUM,"\n");

			attacker.owner.frags = attacker.owner.frags + 1;
			return;
		}

		if (attacker.classname == "teledeath2")
		{
                        bprint (PRINT_MEDIUM,"Pent's power deflects ");
			bprint (PRINT_MEDIUM,targ.netname);
			bprint (PRINT_MEDIUM,"'s telefrag\n");

			targ.frags = targ.frags - 1;
			logfrag (targ, targ);
			return;
		}

		if (attacker.classname == "player")
		{
//ZOID 12-13-96: self.team doesn't work in QW.  Use keys
			attackerteam = infokey(attacker, "team");
			targteam = infokey(targ, "team");

//RUNE SERV: Death messages
                        if (attacker.runetype > 0)
                        {
                           if (targ == attacker)
                           {
                              if (targ.deathtype == "divinewind")
                              {
                                 targ.deathtype == "";
                                 bprint(PRINT_MEDIUM,targ.netname);
                                 bprint(PRINT_MEDIUM," detonated in a blaze of glory\n");
                                 return;
                              }
                              if (targ.deathtype == "waterzap")
                              {
                                 targ.deathtype == "";
                                 bprint(PRINT_MEDIUM,targ.netname);
                                 bprint(PRINT_MEDIUM," jumped into the water, while ELECTRIFIED!\n");
                                 attacker.frags = attacker.frags - 1;
                                 return;
                              }
                              if (targ.deathtype == "hookzapped")
                              {
                                 targ.deathtype == "";
                                 bprint(PRINT_MEDIUM,targ.netname);
                                 bprint(PRINT_MEDIUM," was short circuited by a hook!\n");
                                 attacker.frags = attacker.frags - 1;
                                 return;
                              }
                              if (attacker.runetype == RN_BOMB && attacker.deathtype != "divinewind")
                              {
                                 targ.deathtype == "";
                                 bprint(PRINT_MEDIUM,targ.netname);
                                 bprint(PRINT_MEDIUM," blew up after killing himself.\n");
                                 attacker.frags = attacker.frags - 1;
                                 return;
                              }
                           }
                           if (targ != attacker)
                           {
                              if (attacker.runetype == RN_BOMB && attacker.deathtype == "divinewind")
                              {
                                 targ.deathtype == "";
                                 bprint(PRINT_MEDIUM,targ.netname);
                                 bprint(PRINT_MEDIUM," was taken out in ");
                                 bprint(PRINT_MEDIUM,attacker.netname);
                                 bprint(PRINT_MEDIUM,"'s blast\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (attacker.runetype == RN_BOMB && attacker.deathtype != "divinewind" && attacker.health < 1)
                              {
                                 targ.deathtype == "";
                                 bprint(PRINT_MEDIUM,targ.netname);
                                 bprint(PRINT_MEDIUM," shouldn't have shot at ");
                                 bprint(PRINT_MEDIUM,attacker.netname);
                                 bprint(PRINT_MEDIUM,"\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "zapped")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," was zapped within ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"'s electric field\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "hookzapped")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," was electrocuted while hooking ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "waterzap")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," was zapped when ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM," jumped into the water\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "vengance")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," got a taste of his own medicine from ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "sucker")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," got sucked into ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"'s  Gravity Well\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "fleas")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," was feasted upon by ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"'s  fleas\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                           }
                        }
//RUNE SERV end----------

			if (targ == attacker)
			{
				// killed self
				logfrag (attacker, attacker);
				attacker.frags = attacker.frags - 1;

//RUNE SERV start--------------
                              if (targ.deathtype == "dspot")
                              {
                                 targ.deathtype == "";
                                 bprint(PRINT_MEDIUM,targ.netname);
                                 bprint(PRINT_MEDIUM," gibbed in his own Death Spot!\n");
                                 return;
                              }
                              if (targ.deathtype == "radioactive")
                              {
                                 targ.deathtype == "";
                                 bprint(PRINT_MEDIUM,targ.netname);
                                 bprint(PRINT_MEDIUM," died of his own radioactivity\n");
                                 return;
                              }

// mytemp = inflictor.classname;
// mytemp = mytemp;
// bprint (PRINT_MEDIUM, mytemp);

                              if (targ.deathtype == "sucker")
                              {
                                 targ.deathtype == "";
                                 bprint(PRINT_MEDIUM,targ.netname);
                                 bprint(PRINT_MEDIUM," was sucked into his own Gravity Well!\n");
                                 return;
                              }

                              if (targ.deathtype == "nuke")
                              {
                                 targ.deathtype == "";
                                 bprint(PRINT_MEDIUM,targ.netname);
                                 bprint(PRINT_MEDIUM," nuked himself too!\n");
                                 return;
                              }
//RUNE SERV end----------------

				bprint (PRINT_MEDIUM,targ.netname);
				
				if (targ.weapon == 64 && targ.waterlevel > 1)
				{
					bprint (PRINT_MEDIUM," discharges into the water.\n");
					return;
				}
				if (targ.weapon == 16)
					bprint (PRINT_MEDIUM," tries to put the pin back in\n");
                    else if (rnum < 0.50)
                         bprint (PRINT_MEDIUM," becomes bored with life\n");
				else
					bprint (PRINT_MEDIUM," checks if his weapon is loaded\n");
				return;
			}
			else if ( (teamplay == 2) && (targteam == attackerteam) &&
				(attackerteam != "") )
			{
				if (rnum < 0.25)
					deathstring = " mows down a teammate\n";
				else if (rnum < 0.50)
					deathstring = " checks his glasses\n";
				else if (rnum < 0.75)
					deathstring = " gets a frag for the other team\n";
				else
					deathstring = " loses another friend\n";
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, deathstring);
				attacker.frags = attacker.frags - 1;
				//ZOID 12-13-96:  killing a teammate logs as suicide
				logfrag (attacker, attacker);
				return;
			}
			else
			{
				logfrag (attacker, targ);
				attacker.frags = attacker.frags + 1;

//RUNE SERV start--------------
                              if (targ.deathtype == "dspot")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," gibbed in ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"'s Death Spot\n");
                                 return;
                              }
                              if (targ.deathtype == "radioactive")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," died of ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"'s radioactivity\n");
                                 return;
                              }
                              if (targ.deathtype == "gfire")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM,"'s legs burned off by ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"'s fire\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "deathorb")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," got attacked by ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"'s Death Orb\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "spikeball")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," ate chaff from ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"'s Floating Spiky Death Cloud\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "bodycheck")
                              {
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," was bodychecked by ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "knightspike")
                              {
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," was knighted by ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"'s spikes\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "sucker")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," was crushed in ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"'s Gravity Well\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "hook")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," was guttted by ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"'s  Grappling Hook\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "disc")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," was knocked into orbit by ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"'s  Shooting Star\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "fleas")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," was feasted upon by ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"'s  fleas\n");
                                 attacker.frags = attacker.frags + 1;
                                 return;
                              }
                              if (targ.deathtype == "nuke")
                              {
                                 targ.deathtype == "";
                                 bprint (PRINT_MEDIUM,targ.netname);
                                 bprint (PRINT_MEDIUM," was nuked by ");
                                 bprint (PRINT_MEDIUM,attacker.netname);
                                 bprint (PRINT_MEDIUM,"\n");
                                 return;
                              }
//RUNE SERV end ---------------

				rnum = attacker.weapon;
				if (rnum == IT_AXE)
				{
					deathstring = " was ax-murdered by ";
                                        deathstring2 = "\nHow embarassing!\n";
				}
				if (rnum == IT_SHOTGUN)
				{
					deathstring = " chewed on ";
					deathstring2 = "'s boomstick\n";
				}
				if (rnum == IT_SUPER_SHOTGUN)
				{
					deathstring = " ate 2 loads of ";
					deathstring2 = "'s buckshot\n";
				}
				if (rnum == IT_NAILGUN)
				{
					deathstring = " was nailed by ";
					deathstring2 = "\n";
				}
				if (rnum == IT_SUPER_NAILGUN)
				{
					deathstring = " was punctured by ";
					deathstring2 = "\n";
				}
				if (rnum == IT_GRENADE_LAUNCHER)
				{
               deathstring = " eats ";
					deathstring2 = "'s pineapple\n";
					if (targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s grenade\n";
					}
				}
				if (rnum == IT_ROCKET_LAUNCHER)
				{
					deathstring = " rides ";
					deathstring2 = "'s rocket\n";
					if (targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s rocket\n" ;
					}
				}
				if (rnum == IT_LIGHTNING)
				{
					deathstring = " accepts ";
					if (attacker.waterlevel > 1)
						deathstring2 = "'s discharge\n";
					else
						deathstring2 = "'s shaft\n";
				}
				bprint (PRINT_MEDIUM,targ.netname);
				bprint (PRINT_MEDIUM,deathstring);
				bprint (PRINT_MEDIUM,attacker.netname);
				bprint (PRINT_MEDIUM,deathstring2);
			}
			return;
		}
		else
		{
			logfrag (targ, targ);
			targ.frags = targ.frags - 1;            // killed self
			rnum = targ.watertype;

			bprint (PRINT_MEDIUM,targ.netname);
			if (rnum == -3)
			{
				if (random() < 0.5)
					bprint (PRINT_MEDIUM," sleeps with the fishes\n");
				else
					bprint (PRINT_MEDIUM," sucks it down\n");
				return;
			}
			else if (rnum == -4)
			{
				if (random() < 0.5)
					bprint (PRINT_MEDIUM," gulped a load of slime\n");
				else
					bprint (PRINT_MEDIUM," can't exist on slime alone\n");
				return;
			}
			else if (rnum == -5)
			{
				if (targ.health < -15)
				{
					bprint (PRINT_MEDIUM," burst into flames\n");
					return;
				}
				if (random() < 0.5)
					bprint (PRINT_MEDIUM," turned into hot slag\n");
				else
					bprint (PRINT_MEDIUM," visits the Volcano God\n");
				return;
                        }
			if (attacker.classname == "explo_box")
			{
				bprint (PRINT_MEDIUM," blew up\n");
				return;
			}
			if (attacker.solid == SOLID_BSP && attacker != world)
			{       
				bprint (PRINT_MEDIUM," was squished\n");
				return;
			}
			if (targ.deathtype == "falling")
			{
				targ.deathtype = "";
				bprint (PRINT_MEDIUM," fell to his death\n");
				return;
			}
			if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
			{
				bprint (PRINT_MEDIUM," was spiked\n");
				return;
			}
			if (attacker.classname == "fireball")
			{
				bprint (PRINT_MEDIUM," ate a lavaball\n");
				return;
			}
			if (attacker.classname == "trigger_changelevel")
			{
            bprint (PRINT_MEDIUM," tried to leave too soon\n");
				return;
			}

         bprint (PRINT_MEDIUM," just plain died...\n");
		}
	}
};
