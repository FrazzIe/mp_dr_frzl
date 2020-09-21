main() {
	maps\mp\_load::main();

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	self.trapCount = 4;
	level.trapTriggers = [];
	self.activatedTraps = [];

	thread startPlatform();

	for (id = 0; id < self.trapCount; id++) {
		thread trapData(id);
	}

	createPlatformGame();
}

trapAnim(target) {
	trapButton = getEnt(target, "targetname");
	trapButton moveZ(-5, 0.5);
}

spinTrap(trapId, spinner, stopOnActivate, time, removeCollisionOnActivate) {
	if (stopOnActivate) {
		while (!self.activatedTraps[trapId]) {
			spinner rotateYaw(360, time);
			wait(time);
		}

		if (removeCollisionOnActivate)
			spinner notsolid();
	} else {
		collisionRemoved = false;

		while (true) {
			if (removeCollisionOnActivate && self.activatedTraps[trapId] && !collisionRemoved) {
				spinner notsolid();
			}
			spinner rotateYaw(360, time);
			wait(time);
		}
	}
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

trapData(id) {
	self.activatedTraps[id] = false;
	level.trapTriggers[id] = getEnt("trap_" + id + "_trigger", "targetname");

	switch(id) { //before activation functionality
		case 2:
			trapWire = getEnt("trap_2_wire", "targetname");
			trapWire hide();
			for (i = 0; i < 2; i++) {
				thread spinTrap(id, getEnt("trap_2_spinner_" + i, "targetname"), false, 0.7, true);
			}
			break;
		case 3:
			//attach hurt trigger to crusher trap
			crusher = getEnt("trap_3_crusher", "targetname");
			crusherTrigger = getEnt("trap_3_crusher_trigger", "targetname");
			crusherTrigger enableLinkTo();
			crusherTrigger linkTo(crusher);
			break;
		default:
			break;
	}

	level.trapTriggers[id] waittill("trigger", player);
	self.activatedTraps[id] = true;

	switch(id) { //after activation functionality
		case 0: //Floor removal trap
			trapRandom = randomIntRange(0, 2);
			trapFloor = getEnt("trap_0_" + trapRandom, "targetname");
			trapFloor delete();
			break;
		case 1: //Ladder removal trap
			trapRandom = randomIntRange(0, 2);
			trapLadder = getEnt("trap_1_" + trapRandom, "targetname");
			trapLadder delete();
			break;
		case 2: //Remove spinner collision trap
			trapWire = getEnt("trap_2_wire", "targetname");
			trapWire show();			
			break;
		case 3: //Maze crusher
			yOffset = 304;

			//open crusher doors
			for (i = 0; i < 2; i++) {
				door = getEnt("trap_3_h_door_" + i, "targetname");
				door moveY(yOffset, 2);
				yOffset *= -1;
			} //horizontal roof doors

			//close maze doors
			door = getEnt("trap_3_v_door_0", "targetname");
			door moveZ(98, 2); //vertical maze doors
			wait(2);

			crusher = getEnt("trap_3_crusher", "targetname");
			crusher moveZ(-253, 5); //crusher
			wait(5);

			wait(2); //make sure everyone in the maze is dead

			//move crusher back up
			crusher = getEnt("trap_3_crusher", "targetname");
			crusher moveZ(253, 5); //crusher
			wait(5);

			yOffset = -304;

			//open maze doors
			door = getEnt("trap_3_v_door_0", "targetname");
			door moveZ(-98, 2); //vertical maze doors

			//close crusher doors
			for (i = 0; i < 2; i++) {
				door = getEnt("trap_3_h_door_" + i, "targetname");
				door moveY(yOffset, 2);
				yOffset *= -1;
			} //horizontal roof doors
			wait(2);
			break;
		default:
			break;
	}

	level.trapTriggers[id] delete();
	trapAnim("trap_" + id + "_button");
}

createPlatformGame() {
	platformColumns = 3;
	platformRows = 5;
	realPlatforms = [];

	//generate stable platforms
	realPlatforms[0] = randomIntRange(0, platformColumns);

	for (row = 1; row < platformRows; row++) {
		realPlatforms[row] = randomIntRange(0, platformColumns);
	}

	//add dummy platforms
	for (row = 0; row < platformRows; row++) {
		for (column = 0; column < platformColumns; column++) {
			platformIndicatiorOn = getEnt("platform_game_" + row + "_" + column + "_on", "targetname");

			if (realPlatforms[row] != column) {
				thread addDummyPlatform(row, column);
				platformIndicatiorOn hide();
			} else {
				platformIndicatiorOff = getEnt("platform_game_" + row + "_" + column + "_off", "targetname");
				platformIndicatiorOff hide();
			}
		}
	}
}

addDummyPlatform(row, column) {
	platform = getEnt("platform_game_" + row + "_" + column, "targetname");
	platformTrigger = getEnt("platform_game_" + row + "_" + column + "_trigger", "targetname");
	platformTrigger waittill("trigger", player);
	platform moveZ(-75, 0.3);
	wait(0.3);
	platform delete();
}