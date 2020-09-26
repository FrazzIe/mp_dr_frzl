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
	self.miscCount = 1;

	thread startPlatform();

	for (id = 0; id < self.trapCount; id++) {
		thread trapData(id);
	}

	for (id = 0; id < self.miscCount; id++) {
		thread miscData(id);
	}

	createPlatformGame();
	createPasswordGame();
	asciiGame();
}

trapAnim(target) {
	trapButton = getEnt(target, "targetname");
	trapButton moveZ(-5, 0.5);
}

miscAnim(miscButton, axis, amount, time, resetPosition) {
	waitTime = time;

	if (waitTime < 1)
		waitTime += 0.1;

	switch(axis) {
		case "X":
		case "x":
			miscButton moveX(amount, time);			
			wait(waitTime);
			if (resetPosition)
				miscButton moveX(0 - amount, time);
			break;
		case "Y":
		case "y":
			miscButton moveY(amount, time);			
			wait(waitTime);
			if (resetPosition)
				miscButton moveY(0 - amount, time);
			break;
		case "Z":
		case "z":
			miscButton moveZ(amount, time);			
			wait(waitTime);
			if (resetPosition)
				miscButton moveZ(0 - amount, time);
			break;
		default:
			break;
	}
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
			break;
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

//Start door moving platform
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

//Trap functionality
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
			//Make platform move
			thread moverTrap(id, getEnt("trap_6_platform", "targetname"), "x", 357, 2, false, false, false);
			//attach hurt trigger to knocker trap
			knocker = getEnt("trap_6_knocker", "targetname");
			knockerTrigger = getEnt("trap_6_knocker_trigger", "targetname");
			knockerTrigger enableLinkTo();
			knockerTrigger linkTo(knocker);
			knocker notSolid(); //remove knocker collision so it doesn't get jammed
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
		case 5: //Small pillars, delete 2 rows
			for (row = 0; row < 2; row++) {
				pillars = getEnt("trap_5_pillar_" + randomIntRange(0, 3), "targetname");
				while (!isDefined(pillars)) {
					pillars = getEnt("trap_5_pillar_" + randomIntRange(0, 3), "targetname");
					wait(0.1);
				}
				pillars delete();
			}
			break;
		case 6: //Knock off moving platform
			knocker = getEnt("trap_6_knocker", "targetname");
			knocker moveZ(-114.5, 0.5); //move down
			wait(0.6);
			knocker moveX(219.5, 0.5); //move forward
			wait(0.6);
			knocker moveX(-219.5 + -218.5, 0.5); //move back
			wait(0.6);
			knocker moveX(218.5, 0.5); //move forward to middle
			wait(0.6);
			knocker moveZ(114.5, 0.5); //move up
			wait(0.6);
			break;
		case 7: //Rotate bounce
			thread spinTrap(id, getEnt("trap_7_bounce", "targetname"), "yaw", 2, 2, false, false);
			break;
		default:
			break;
	}

	level.trapTriggers[id] delete();
	trapAnim("trap_" + id + "_button");
}

miscData(id) {
	while (true) {
		miscTrigger = getEnt("misc_" + id + "_trigger", "targetname");
		miscTrigger waittill("trigger", player);

		switch(id) {
			case 0:
				if (isDefined(player.pers["vip"]) && player.pers["vip"]) {
					player suicide();
					miscAnim(getEnt("misc_" + id + "_button", "targetname"), "y", 6, 0.5, true);
				}
				break;
			default:
				break;
		}

		wait(0.1);
	}
}

//trigger_once passive trap, variation of "Tip Toe" from Fall Guys
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

//use-touch trigger color based password system (Map checkpoint, slows down gameplay)
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
						door moveZ(97, 5); //open the door
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

//ASCII Decimal input using damage triggers (supports ASCII Decimal 32-126)
asciiMap() { //Create an array map of ascii characters
	ascii = "! \" # $ % & ' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ \\ ] ^ _ ` a b c d e f g h i j k l m n o p q r s t u v w x y z { | } ~";
	ascii = strTok(ascii, " ");
	asciiMap = [];
	asciiMap["toChar"] = [];
	asciiMap["toNumber"] = [];
	asciiMap["offset"] = 32;

	asciiMap["toChar"][0] = " ";
	asciiMap["toNumber"][" "] = 0;

	for (id = 0; id < ascii.size; id++) {
		asciiMap["toChar"][id + 1] = ascii[id];
		asciiMap["toNumber"][ascii[id]] = id + 1;
	}

	return asciiMap;
}

asciiGame() {
	self.asciiMap = asciiMap();
	self.asciiGamePassword = asciiGameCreatePassword("F R Z L", " ");
	self.asciiGameInput = [];
	self.asciiGameButtons = 12;
	self.asciiGameStatus = 3;
	self.asciiGameEnabled = true;

	for (button = 0; button < self.asciiGameButtons; button++) {
		thread asciiGameListener(button);
	}

	asciiGameStatus(0);
}

asciiGameCreatePassword(str, delim) { //Transform a word into an array of ascii decimals
	password = [];
	chars = strTok(str, delim);

	for (char = 0; char < chars.size; char++) {
		password[char] = [];
		digits = [];
		num = self.asciiMap["toNumber"][chars[char]] + self.asciiMap["offset"];

		while (num > 0) {
			digit = int(num % 10);
			digits[digits.size] = digit;
			num = int(num / 10);
		}

		if (digits.size < 3)
			digits[digits.size] = 0;

		for (i = digits.size - 1; i >= 0; i--) 
			password[char][password[char].size] = digits[i];
	}

	return password;
}

asciiGameListener(id) { //Handle ascii number inputs (0-9) and clear (10) and enter (11)
	trigger = getEnt("ascii_game_trigger_" + id, "targetname");

	while(self.asciiGameEnabled) {
		trigger waittill("trigger", player);

		if (self.asciiGameEnabled) {
			switch(id) {
				case 10:
					self.asciiGameInput = [];
					asciiGameStatus(0);
					iPrintLn("^1>> ^7ASCII Game: ^7The input has been ^1reset");
					break;
				case 11:
					inputStr = asciiGameToString(self.asciiGameInput);
					if (inputStr == "")
						inputStr = "[^1EMPTY^3]";

					if (asciiGameMatch(self.asciiGamePassword, self.asciiGameInput)) {
						self.asciiGameEnabled = false;
						iPrintLn("^1>> ^7ASCII Game: ^3" + inputStr + " ^7was the ^2correct ^7answer!");
						iPrintLnBold("^1" + player.name + " ^7unlocked the secret!");
						door = getEnt("ascii_game_door", "targetname");
						door moveY(64, 5);
						asciiGameStatus(2);
					} else {
						iPrintLn("^1>> ^7ASCII Game: ^3" + inputStr + " ^7was the ^1wrong ^7answer, try again!");
						asciiGameStatus(1);
					}
					break;
				default:
					if (self.asciiGameInput.size == 0) {
						self.asciiGameInput[self.asciiGameInput.size] = [];
						self.asciiGameInput[self.asciiGameInput.size - 1][0] = id;
					} else if (self.asciiGameInput[self.asciiGameInput.size - 1].size < 3) {
						self.asciiGameInput[self.asciiGameInput.size - 1][self.asciiGameInput[self.asciiGameInput.size - 1].size] = id;
					} else {
						self.asciiGameInput[self.asciiGameInput.size] = [];
						self.asciiGameInput[self.asciiGameInput.size - 1][0] = id;
					}
					asciiGameStatus(1);
					break;
			}
		}
	}

	trigger delete();
}

asciiGameStatus(id) { //Set visual status of ascii response
	//0 - Blue (Normal)
	//1 - Red (Wrong)
	//2 - Green (Correct)
	for (i = 0; i < self.asciiGameStatus; i++) {
		statusBrush = getEnt("ascii_game_status_" + id, "targetname");
		if (i != id)
			statusBrush hide();
		else
			statusBrush show();
	}
}

asciiGameToString(chars) { //Tranform array of ascii decimals into a string
	inputStr = "";
	//inputNumStr = "";

	for (char = 0; char < chars.size; char++) {
		if (isDefined(chars[char][2])) {
			num = (chars[char][0] * 100) + (chars[char][1] * 10) + chars[char][2] - self.asciiMap["offset"];

			//inputNumStr += "[ ^1" + num + "^7, (^2" + chars[char][0] + "^7, ^2" + chars[char][1] + "^7, ^2" + chars[char][2] + "^7) ]";

			if (isDefined(self.asciiMap["toChar"][num]))
				inputStr += self.asciiMap["toChar"][num];
			else
				inputStr += "?";
		}
	}

	//iPrintLn("^1>> ^7ASCII Game: " + inputNumStr);
	return inputStr;
}

asciiGameMatch(passwordA, passwordB) { //Check if two ascii decimal arrays match
	if (passwordA.size != passwordB.size)
		return false;
	
	for (i = 0; i < passwordA.size; i++) {
		if (passwordA[i].size != passwordB[i].size)
			return false;
		for (j = 0; j < passwordA[i].size; j++) {
			if (passwordA[i][j] != passwordB[i][j])
				return false;
		}
	}

	return true;
}