main() {
	maps\mp\_load::main();

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	thread startPlatform();
	thread trapOne();
	thread trapTwo();
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

	while(1) {
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
	trapTrigger = getEnt("trap_1_trigger", "targetname");
	trapRandom = randomIntRange(0, 1);
	trapFloor = getEnt("trap_1_" + trapRandom, "targetname");
	trapTrigger waittill("trigger", player);

	trapFloor delete();
	trapTrigger delete();
	trapAnim("trap_1_button");
}

trapTwo() {
	trapTrigger = getEnt("trap_2_trigger", "targetname");
	trapRandom = randomIntRange(0, 1);
	trapLadder = getEnt("trap_2_" + trapRandom, "targetname");
	trapTrigger waittill("trigger", player);

	trapLadder delete();
	trapTrigger delete();
	trapAnim("trap_2_button");
}