
player addEventHandler ["GetInMan", {
    params ["_vehicle", "", "_playerEntered"];


    if (_playerEntered == vehicle player) then {
        if (vehicle player getVariable ["life_radioIsOn", nil] == true) then {
			life_playlist = [life_songs] call life_fnc_arrayShufflePlus;
			[Vehicle _caller] call life_fnc_playSongOnRadio;
        } else {vehicle player setVariable ["life_radioIsOn", false]};
    };
}];

player addEventHandler ["GetOut", {
    params ["_vehicle", "", "_playerEntered"];

	[Vehicle player] call life_fnc_stopSongOnRadio;

}];

addMusicEventHandler ["MusicStop", {

	if (Vehicle player isKindOf "Car" && Vehicle player getVariable ["life_radioIsOn", false]) then {
		life_playlist deleteAt 0;
		[Vehicle _caller] call life_fnc_playSongOnRadio;
    };


}];



player addAction
[
	"<t color='#FF0000'>Turn On Radio</t>",
	{
		params ["_target", "_caller", "_actionId", "_arguments"];

		life_playlist = [life_songs] call life_fnc_arrayShufflePlus;
		[Vehicle _caller] call life_fnc_playSongOnRadio;
		

		vehicle _caller addEventHandler ["GetOut", {
			params ["_vehicle", "", "_playerExited"];

			if (_playerExited == player) then {
				playMusic "";
			};
		}];

	},
	nil,
	1.5,
	true,
	false,
	"",
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

		[Vehicle _caller] call life_fnc_stopSongOnRadio;
	},
	nil,
	1.5,
	true,
	false,
	"",
	"Vehicle player isKindOf ""Car"" && (driver vehicle player) == player && Vehicle player getVariable [""life_radioIsOn"", true];",
	4,
	false,
	"",
	""
];


life_fnc_playMusic = {
	 params ["_life_radioNowPlaying"];


    playMusic "";
    playMusic [_life_radioNowPlaying, 0];
    0 fadeMusic (100 / 100);

    [_life_radioNowPlaying] call life_fnc_displayTiles;
};

life_fnc_findTrackConfig = {
	params ["_trackName"];

	_return = [];
	{
		if (_x select 0 == _trackName) then {
			_return append _x select 1;
			_return append _x select 2;
		};
	} forEach life_songs;
	_return;
};

life_fnc_displayTiles = {
    params [["_trackName", ""]];

    private _trackConfig = [_trackName] call life_fnc_findTrackConfig;


    private _artist = _trackConfig select 2;
    private _title = _trackConfig select 1;

    if (count _artist == 0 || count _title == 0) exitWith {};

    private _tileSize = linearConversion [100, 10, count (_artist + _title), 1.6, 2.2, true];

    private _tilePos = [
    (safezoneX + safezoneW - 21 * (((safezoneW / safezoneH) min 1.2) / 35)),
    (safezoneY + safezoneH - 13 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)),
    20 * (((safezoneW / safezoneH) min 1.2) / 35),
    10 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
    ];

    [parseText format ["<t font='PuristaBold' shadow='2' align='right' size='%3'>""%1""</t><br/><t shadow='2' align='right' size='%4'>by %2</t>", _title, _artist, _tileSize, _tileSize - 0.2], _tilePos, nil, 7, 1, 0] spawn BIS_fnc_textTiles;
};

life_fnc_arrayShufflePlus = {
    private ["_arr", "_cnt"];

	life_playlist = [];
    _arr = _this select 0;
    _cnt = count _arr;

    for "_i" from 1 to (_cnt) do {
        _arr pushBack (_arr deleteAt floor random _cnt);
    };

    _arr;
};

life_fnc_playSongOnRadio = {
    params ["_vehicle"];

    
    _vehicle setVariable ["life_radioIsOn", true, true];
    
	
    [(life_playlist select 0) select 0] call life_fnc_playMusic;
    
};

life_fnc_stopSongOnRadio = {
    params ["_vehicle"];

    
	_vehicle setVariable ["life_radioIsOn", false, true];


    if (player in crew _vehicle) then {
        playMusic "";
    };
};



if (isNil "life_radioNowPlaying") then {
    life_radioNowPlaying = "";
};





