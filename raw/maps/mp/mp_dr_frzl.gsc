main() {
	maps\mp\_load::main();

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	self.trapCount = 8;
	level.trapTriggers = [];
	self.activatedTraps = [];

	thread startPlatform();

	for (id = 0; id < self.trapCount; id++) {
		thread trapData(id);
	}

	createPlatformGame();
	createPasswordGame();
}

trapAnim(target) {
	trapButton = getEnt(target, "targetname");
	trapButton moveZ(-5, 0.5);
}

spinTrapAxis(spinner, axis, time, interval) {
	switch(axis) {
		case "ROLL":
		case "roll":
			spinner rotateRoll(360, time);
			wait(time);
			break;
		case "YAW":
		case "yaw":
			spinner rotateYaw(360, time);
			wait(time);
			break;
		case "PITCH":
		case "pitch":
			spinner rotatePitch(360, time);
			wait(time);
			break;
	}

	if (interval)
		wait(interval);
}

spinTrap(trapId, spinner, axis, time, interval, stopOnActivate, removeCollisionOnActivate) {
	if (stopOnActivate) {
		while (!self.activatedTraps[trapId]) {
			spinTrapAxis(spinner, axis, time, interval);
		}

		if (removeCollisionOnActivate)
			spinner notSolid();
	} else {
		collisionRemoved = false;

		while (true) {
			if (removeCollisionOnActivate && self.activatedTraps[trapId] && !collisionRemoved) {
				spinner notSolid();
			}

			spinTrapAxis(spinner, axis, time, interval);
		}
	}
}

moverTrapAxis(mover, axis, amount, time, interval) {
	switch(axis) {
		case "X":
		case "x":
			mover moveX(amount, time);
			wait(time);
			mover moveX(0 - amount, time);
			wait(time);
			break;
		case "Y":
		case "y":
			mover moveY(amount, time);
			wait(time);
			mover moveY(0 - amount, time);
			wait(time);
			break;
		case "Z":
		case "z":
			mover moveZ(amount, time);
			wait(time);
			mover moveZ(0 - amount, time);
			wait(time);
		case "ROLL":
		case "roll":
			mover rotateRoll(amount, time);
			wait(time);
			mover rotateRoll(0 - amount, time);
			wait(time);
			break;
		case "YAW":
		case "yaw":
			mover rotateYaw(amount, time);
			wait(time);
			mover rotateYaw(0 - amount, time);
			wait(time);
			break;
		case "PITCH":
		case "pitch":
			mover rotatePitch(amount, time);
			wait(time);
			mover rotatePitch(0 - amount, time);
			wait(time);
			break;
	}

	if (interval)
		wait(interval);
}	

moverTrap(trapId, mover, axis, amount, time, interval, stopOnActivate, removeCollisionOnActivate) {
	if (stopOnActivate) {
		while (!self.activatedTraps[trapId]) {
			moverTrapAxis(mover, axis, amount, time, interval);
		}

		if (removeCollisionOnActivate)
			mover notSolid();
	} else {
		collisionRemoved = false;

		while (true) {
			if (removeCollisionOnActivate && self.activatedTraps[trapId] && !collisionRemoved) {
				mover notSolid();
			}

			moverTrapAxis(mover, axis, amount, time, interval);
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
		case 2: //Remove spinner collision trap
		    //Make spinners spin
			trapWire = getEnt("trap_2_wire", "targetname");
			trapWire hide();
			for (i = 0; i < 2; i++) {
				thread spinTrap(id, getEnt("trap_2_spinner_" + i, "targetname"), "yaw", 0.7, false, false, true);
			}
			break;
		case 3:
			//attach hurt trigger to crusher trap
			crusher = getEnt("trap_3_crusher", "targetname");
			crusherTrigger = getEnt("trap_3_crusher_trigger", "targetname");
			crusherTrigger enableLinkTo();
			crusherTrigger linkTo(crusher);
			break;
		case 5: //Small pillars moving up and down
			//Remove collision from fake middle platform
			pillar = getEnt("trap_5_pillar_fake", "targetname");
			pillar notSolid();
			break;
		case 6: //Knock off moving platform
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
		case 4: //Remove 2 Square platforms
			for (row = 0; row < 2; row++) {
				square = getEnt("trap_4_platform_" + row + "_" + randomIntRange(0, 2), "targetname");
				square notSolid();
			}
			break;
		case 5: //Small pillars moving up and down
			break;
		case 6: //Knock off moving platform
			break;
		case 7: //Rotate bounce
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

createPasswordGame() {
	//0 - Blue (Background / Unselected)
	//1 - Red
	//2 - Green

	self.passwordGamePassword = [];
	self.passwordGameInput = [];
	self.passwordGameColumns = 6;
	self.passwordGameRows = 2;
	self.passwordGameColours = 3;
	self.passwordGameButtons = 3;
	self.passwordGameEnabled = true;

	//hide everything but blue
	passwordGameReset(0, self.passwordGameRows, 0);

	//generate password
	for (column = 0; column < self.passwordGameColumns; column++) {
		self.passwordGamePassword[column] = randomIntRange(1, self.passwordGameColours);
		passwordBrush = getEnt("password_game_1_" + column + "_0", "targetname");
		passwordBrush hide(); //hide background
		passwordBrush = getEnt("password_game_1_" + column + "_" + self.passwordGamePassword[column], "targetname");
		passwordBrush show(); //show password character (red/blue)
	}

	for (button = 0; button < self.passwordGameButtons; button++) {
		thread passwordGameListener(button);
	}
}

passwordGameMatch(passwordA, passwordB) {
	if (passwordA.size != passwordB.size)
		return false;

	for (i = 0; i < passwordA.size; i++) {
		if (passwordA[i] != passwordB[i])
			return false;
	}

	return true;
}

passwordGameListener(id) {
	trigger = getEnt("password_game_trigger_" + id, "targetname");

	while(self.passwordGameEnabled) {		
		trigger waittill("trigger", player);

		if (self.passwordGameEnabled) {
			switch(id) {
				case 0:
					if (self.passwordGamePassword.size == self.passwordGameInput.size && passwordGameMatch(self.passwordGamePassword, self.passwordGameInput)) { //check if password matches
						self.passwordGameEnabled = false;
						passwordGameReset(0, self.passwordGameRows, 2); //set all blocks to green to indicate it was a success
						
						iPrintLnBold("^1" + player.name + " ^7has unlocked the checkpoint!");

						door = getEnt("password_game_door", "targetname");
						door moveZ(98, 5); //open the door
					} else {
						self.passwordGameInput = [];
						passwordGameReset(0, self.passwordGameRows - 1, 0); //reset user input
					}
					break;
				case 1:
				case 2:
					if (self.passwordGamePassword.size != self.passwordGameInput.size) {
						passwordBrush = getEnt("password_game_0_" + self.passwordGameInput.size + "_0", "targetname");
						passwordBrush hide(); //hide background
						passwordBrush = getEnt("password_game_0_" + self.passwordGameInput.size + "_" + id, "targetname");
						passwordBrush show(); //show password character (red/blue)
						self.passwordGameInput[self.passwordGameInput.size] = id;
					}
					break;
			}
		}
	}

	trigger delete();
}

passwordGameReset(rowIdx, rowCount, showColourIdx) {
	for (row = rowIdx; row < rowCount; row++) {
		for (column = 0; column < self.passwordGameColumns; column++) {
			for (colour = 0; colour < self.passwordGameColours; colour++) {
				passwordBrush = getEnt("password_game_" + row + "_" + column + "_" + colour, "targetname");
				if (showColourIdx == colour) 
					passwordBrush show();
				else
					passwordBrush hide();
			}
		}
	}
}