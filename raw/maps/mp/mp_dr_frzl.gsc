main() {
	maps\mp\_load::main();

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	self.activatedTraps = [];

	thread startPlatform();
	thread trapOne();
	thread trapTwo();
	thread TrapThree();
}

trapAnim(target) {
	trapButton = getEnt(target, "targetname");
	trapButton moveZ(-5, 0.5);
}

startPlatform() {
	level waittill("round_started");
	startPlatform = getEnt("start_platform", "targetname");

	wait(5);

	iPrintLnBold("^1MEEP");

	while(true) {
		startPlatform moveX(250, 2, 1, 1);

		wait(2.5);

		startPlatform moveZ(-750, 2, 1, 1);

		wait(2.5);

		startPlatform moveX(-250, 2, 1, 1);

		wait(10);

		startPlatform moveX(250, 2, 1, 1);		

		wait(2.5);

		startPlatform moveZ(750, 2, 1, 1);	

		wait(2.5);

		startPlatform moveX(-250, 2, 1, 1);

		wait(5);
	}
}

trapOne() {
	self.activatedTraps[0] = false;
	trapTrigger = getEnt("trap_1_trigger", "targetname");
	trapRandom = randomIntRange(0, 1);
	trapFloor = getEnt("trap_1_" + trapRandom, "targetname");
	trapTrigger waittill("trigger", player);

	self.activatedTraps[0] = true;

	trapFloor delete();
	trapTrigger delete();
	trapAnim("trap_1_button");
}

trapTwo() {
	self.activatedTraps[1] = false;
	trapTrigger = getEnt("trap_2_trigger", "targetname");
	trapRandom = randomIntRange(0, 1);
	trapLadder = getEnt("trap_2_" + trapRandom, "targetname");
	trapTrigger waittill("trigger", player);

	self.activatedTraps[1] = true;

	trapLadder delete();
	trapTrigger delete();
	trapAnim("trap_2_button");
}

trapThree() {
	self.activatedTraps[2] = false;
	trapTrigger = getEnt("trap_3_trigger", "targetname");
	trapSpinnerOne = getEnt("trap_3_spinner_0", "targetname");
	trapSpinnerTwo = getEnt("trap_3_spinner_1", "targetname");
	trapWire = getEnt("trap_3_wire", "targetname");
	trapWire hide();
	thread trapThreeSpinner(trapSpinnerOne);
	thread trapThreeSpinner(trapSpinnerTwo);
	trapTrigger waittill("trigger", player);

	self.activatedTraps[2] = true;

	trapSpinnerOne delete();
	trapSpinnerTwo delete();
	trapWire show();
	trapTrigger delete();
	trapAnim("trap_3_button");
}

trapThreeSpinner(trapSpinner) {
	while (true) {
		if (!self.activatedTraps[2]) {
			trapSpinner rotateYaw(360, 0.7);
			wait 0.7;
		} else {
			break;
		}
	}
}