// File: fn_radioInit.sqf
// Author: Infamous
// Description: Sets up the radio system to be used in ground vehicles


player addEventHandler ["GetInMan", {
    params ["_vehicle", "", "_playerEntered"];

	// checks if the radio is on when the player gets in and plays music if so
    if (_playerEntered == vehicle player && (driver vehicle player) == player) then {
        if (vehicle player getVariable ["life_radioIsOn", false] == false) then {
			vehicle player setVariable ["life_radioIsOn", false]
		};
    };
}];

// Event handler for when The current track ends
addMusicEventHandler ["MusicStop", {

	// Checks if player is still in the vehicle and radio is on
	if (Vehicle player isKindOf "Car" && Vehicle player getVariable ["life_radioIsOn", nil] && (driver vehicle player) == player) then {
		// Deletes the last played song to make sure it's not repeated
		life_playlist deleteAt 0;
		// plays next song in queue
		[Vehicle player] call life_fnc_playSongOnRadio;
    };


}];


// Action to turn on the Radio
player addAction
[	
	"<t color='#FF0000'>Turn On Radio</t>",
	{
		params ["_target", "_caller", "_actionId", "_arguments"];

		// turns on the music and shuffles it
		life_playlist = [life_songs] call life_fnc_arrayShufflePlaylist;
		[Vehicle _caller] call life_fnc_playSongOnRadio;
		
		// Event handler on the vehicle itself
		vehicle _caller addEventHandler ["GetOut", {
			params ["_vehicle", "", "_playerExited"];

			// turns off music when player is no longer in car
			if (_playerExited == player) then {
				playMusic "";
			};
		}];

	},
	nil,
	1.5,
	true,
	false,
	"", // Condition that must be met for action to appear
	"Vehicle player isKindOf ""Car"" && (driver vehicle player) == player && (Vehicle player getVariable [""life_radioIsOn"", false]) == false;",
	4,
	false,
	"",
	""
];

player addAction
[
	"<t color='#FF0000'>Turn Off Radio</t>",
	{
		params ["_target", "_caller", "_actionId", "_arguments"];

		// turns off music
		[Vehicle player] call life_fnc_stopSongOnRadio;
	},
	nil,
	1.5,
	true,
	false,
	"", // Condition that must be met for action to appear
	"Vehicle player isKindOf ""Car"" && (driver vehicle player) == player && Vehicle player getVariable [""life_radioIsOn"", true];",
	4,
	false,
	"",
	""
];

// Function to start playing the music // Redundant now since I'm using 3D audio instead!
life_fnc_playMusic = {
	 params ["_life_radioNowPlaying"];


    playMusic "";
    playMusic [_life_radioNowPlaying, 0];
    0 fadeMusic (100 / 100);

	// calls displayTiles
    [_life_radioNowPlaying] call life_fnc_displayTiles;
};

// this tracks down the other information for the song
life_fnc_findTrackConfig = {
	params ["_trackName"];

	// return
	_return = [];

	// foreach Loop that searches to find the corresponding Name and Artist for song
	{
		if (_x select 0 == _trackName) then {
			_return append _x select 1;
			_return append _x select 2;
		};
	} forEach life_songs;
	// returns it to orignal call location
	_return;
};

// Displays the song and artist name
life_fnc_displayTiles = {
    params [["_trackName", ""]];

	// find the needed information
    private _trackConfig = [_trackName] call life_fnc_findTrackConfig;

	// extracts needed information
    private _artist = _trackConfig select 2;
    private _title = _trackConfig select 1;

	// checks if the information is not nil
    if (count _artist == 0 || count _title == 0) exitWith {};

	// tile size
    private _tileSize = linearConversion [100, 10, count (_artist + _title), 1.6, 2.2, true];

	// position of the msg
    private _tilePos = [
    (safezoneX + safezoneW - 21 * (((safezoneW / safezoneH) min 1.2) / 35)),
    (safezoneY + safezoneH - 13 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)),
    20 * (((safezoneW / safezoneH) min 1.2) / 35),
    10 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
    ];

	// Text tiles command that displays it all
    [parseText format ["<t font='PuristaBold' shadow='2' align='right' size='%3'>""%1""</t><br/><t shadow='2' align='right' size='%4'>by %2</t>", _title, _artist, _tileSize, _tileSize - 0.2], _tilePos, nil, 7, 1, 0] spawn BIS_fnc_textTiles;
};

// Shuffle the playlist so it's not always the same 
life_fnc_arrayShufflePlaylist = {
    private ["_arr", "_cnt"];

	// get array and count it's length
	life_playlist = [];
    _arr = _this select 0;
    _cnt = count _arr;

	// shuffle it
    for "_i" from 1 to (_cnt) do {
        _arr pushBack (_arr deleteAt floor random _cnt);
    };

	// return it
    _arr;
};

// Play's the song on the radio
life_fnc_playSongOnRadio = {
    params ["_vehicle"];

    // sets variable
    _vehicle setVariable ["life_radioIsOn", true, true];
	
	life_playlist = [life_songs] call life_fnc_arrayShufflePlaylist;

	// Call's the play music function
    [(life_playlist select 0) select 0, _vehicle] call life_fnc_Music3D;
    
};

life_fnc_Music3D = {
    params ["_track","_vehicle"];

	// Plays the song on the vehicle in 3D

	_source = "land_HelipadEmpty_F" createVehicle position vehicle player;
    _source attachTo [_vehicle,[0,0,0]];


    _source say3D [_track, 15, 1, true, 0];
	

	// I'm doing this so that when the current song is done i'll be able to use the MusicEventHandler to play a song right after // Probably a better way :(
	playMusic _track;
	0 fadeMusic 0.2;

	// sets variable
    _vehicle setVariable ["life_radioIsOn", true, true];
	_vehicle setVariable ["life_radioSource", _source, true];
    

	// calls tiles to showcase the song being played
    [_track] call life_fnc_displayTiles;
    
};

// stops the song
life_fnc_stopSongOnRadio = {
    params ["_vehicle", "_track"];

    // Set the variable that the cars radio is off
	_vehicle setVariable ["life_radioIsOn", false, true];

	// turns off radio
    if (player in crew _vehicle) then {
		// deletes sound source and turns off the radio
		_source = _vehicle getVariable ["life_radioSource", nil];
		deleteVehicle _source;
		 playMusic "";
    };
};


// Makes sure life_radioNowPlaying is not nil
if (isNil "life_radioNowPlaying") then {
    life_radioNowPlaying = "";
};





