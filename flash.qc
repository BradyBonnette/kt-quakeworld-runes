void() W_SetCurrentAmmo;
void() flash_update =
{
// player is dead so turn off flashlight
        if (self.owner.deadflag != DEAD_NO)
        {
                self.effects = 0;
        }

// player is alive so turn on flashlight
        else
        {
                self.effects = EF_DIMLIGHT;
        }

// find out which direction player is facing
        makevectors (self.owner.v_angle);

// check if there is anything in front of flashlight
        traceline (self.owner.origin, (self.owner.origin + (v_forward * 500)), FALSE, self);

// set flashlights position
        setorigin (self, trace_endpos + (v_forward * -5));

// repeat in 0.02 seconds...
        self.nextthink = time + 0.02;
};

void() flash_on =
{
// make a new entity to hold the flashlight
        local entity myflash;

// spawn flash
        myflash = spawn();
        myflash.movetype = MOVETYPE_NONE;
        myflash.solid = SOLID_NOT;

// this uses the s_bubble.spr, if you want it to be completely
// invisible you need to create a one pixel tranceparent spririt
// and use it here...
        setmodel (myflash, "progs/s_bubble.spr");
        setsize (myflash, '0 0 0', '0 0 0');

// wire player and flashlight together
        myflash.owner = self;
        self.flash = myflash;

// give the flash a name and make it glow
        myflash.classname = "flash";
        myflash.effects = EF_DIMLIGHT;

// set start position
        makevectors (self.v_angle);
        traceline (self.origin, (self.origin + (v_forward * 500)), FALSE, self);
        setorigin (myflash, trace_endpos);

// start flashlight update
        myflash.think = flash_update;
        myflash.nextthink = time + 0.02;
};

void() flash_toggle =
{
// activated by impulse 101. see weapons.qc

// if off, turn on
        if (self.flash_flag == FALSE)
        {
                self.flash_flag = TRUE;
                flash_on();
        }

// if on, turn off
        else
        {
                self.flash_flag = FALSE;
                W_SetCurrentAmmo ();
                self.flash.think = SUB_Remove;
                self.flash.nextthink = time + 0.1;
        }
};

void() flash_off =
{
	self.flash_flag = FALSE;
	W_SetCurrentAmmo ();
        self.flash.think = SUB_Remove;
        self.flash.nextthink = time + 0.1;
};

//  *********************************************************************************************
//  Light functions for Rune of Darkness

void () Darkflag_one =
{
     // 0 normal
//     lightstyle(0, "a");
     // 1 FLICKER (first variety)
     lightstyle(1, "a");
     // 2 SLOW STRONG PULSE
     lightstyle(2, "a");
     // 3 CANDLE (first variety)
     lightstyle(3, "a");
     // 4 FAST STROBE
     lightstyle(4, "a");
     // 5 GENTLE PULSE 1
     lightstyle(5,"a");
     // 6 FLICKER (second variety)
     lightstyle(6, "a");
     // 7 CANDLE (second variety)
     lightstyle(7, "a");
     // 8 CANDLE (third variety)
     lightstyle(8, "a");
     // 9 SLOW STROBE (fourth variety)
     lightstyle(9, "a");
     // 10 FLUORESCENT FLICKER
     lightstyle(10, "a");
     // 11 SLOW PULSE NOT FADE TO BLACK
     lightstyle(11, "a");
     // styles 32-62 are assigned by the light program for switchable lights
     // 63 testing
     lightstyle(63, "a");
};

void () Darkflag_zero =
{
     // 0 normal
//     lightstyle(0, "m");
     // 1 FLICKER (first variety)
     lightstyle(1, "mmnmmommommnonmmonqnmmo");
     // 2 SLOW STRONG PULSE
     lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
     // 3 CANDLE (first variety)
     lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
     // 4 FAST STROBE
     lightstyle(4, "mamamamamama");
     // 5 GENTLE PULSE 1
     lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");
     // 6 FLICKER (second variety)
     lightstyle(6, "nmonqnmomnmomomno");
     // 7 CANDLE (second variety)
     lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");
     // 8 CANDLE (third variety)
     lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
     // 9 SLOW STROBE (fourth variety)
     lightstyle(9, "aaaaaaaazzzzzzzz");
     // 10 FLUORESCENT FLICKER
     lightstyle(10, "mmamammmmammamamaaamammma");
     // 11 SLOW PULSE NOT FADE TO BLACK
     lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
};

void () Lights_off =
{
        darkcount = darkcount + 1;
        if (darkcount > 0)
        {
                lightstyle(world.style, "a");
                if (darkflag > 0)
                {
                    Darkflag_one();
                }
                else
                {
                    Darkflag_zero();
                }

        }
};

void () Lights_on =
{
        darkcount = darkcount - 1;
        if (darkcount < 1)
        {
                lightstyle(world.style, "m");
                darkcount = 0;
                Darkflag_zero();
        }
};
