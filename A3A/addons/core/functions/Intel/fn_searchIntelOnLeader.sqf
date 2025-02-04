params ["_squadLeader", "_caller", "_searchAction"];

/*  Searches a squadleader for small intel
*   Params:
*       _squadLeader : OBJECT : The unit (or body) which holds the intel
*       _caller : OBJECT : The unit which is searching
*       _searchAction : NUMBER : The ID of the action which started this script
*
*   Returns:
*       Nothing
*/


private _timeForSearch = 10 + random 15;
private _side = _squadLeader getVariable "side";

_caller setVariable ["intelSearchTime",time + _timeForSearch];
_caller setVariable ["intelAnimsDone",false];
_caller setVariable ["intelFound",false];
_caller setVariable ["cancelIntelSearch",false];

_squadLeader setVariable ["intelSearchDone", true, true];

_caller playMoveNow selectRandom medicAnims;
private _cancelAction = _caller addAction ["Cancel Search", {(_this select 1) setVariable ["cancelIntelSearch",true]},nil,6,true,true,"","(isPlayer _this)"];

_caller addEventHandler
[
    "AnimDone",
    {
        private _caller = _this select 0;
        if
        (
            ([_caller] call A3A_fnc_canFight) &&                        //Caller is still able to fight
            {(time <= (_caller getVariable ["intelSearchTime",time])) &&     //Time is not yet finished
            {!(_caller getVariable ["cancelIntelSearch",false]) &&           //Search hasn't been cancelled
            {(isNull objectParent _caller)}}}                           //Caller has not entered a vehicle
        ) then
        {
            _caller playMoveNow selectRandom medicAnims;
        }
        else
        {
            _caller removeEventHandler ["AnimDone", _thisEventHandler];
            _caller setVariable ["intelAnimsDone",true];
            if
            (
                ([_caller] call A3A_fnc_canFight) &&                //Can fight
                {!(_caller getVariable ["cancelIntelSearch",false]) &&   //Not cancelled
                {(isNull objectParent _caller)}}                     //Not in vehicle
            ) then
            {
                _caller setVariable ["intelFound",true];
            };
        };
    }
];

waitUntil {sleep 0.5; _caller getVariable ["intelAnimsDone", false]};

_caller setVariable ["intelSearchTime",nil];
_caller setVariable ["intelAnimsDone",nil];
_caller removeAction _cancelAction;

private _wasCancelled = _caller getVariable ["cancelIntelSearch", false];
_caller setVariable ["cancelIntelSearch", nil];

if(_wasCancelled) exitWith
{
    ["Intel", "Search cancelled."] call A3A_fnc_customHint;
    _caller setVariable ["intelFound", nil];
    _squadLeader setVariable ["intelSearchDone", nil, true];
};

if(_caller getVariable ["intelFound", false]) then
{
    private _hasIntel = _squadLeader getVariable ["hasIntel", false];
    if(_hasIntel) then
    {
        ["Intel", "Search completed, intel found!"] call A3A_fnc_customHint;
        ["Small", _side] remoteExec ["A3A_fnc_selectIntel", 2];
        [5, _caller] call A3A_fnc_playerScoreAdd;
    }
    else
    {
        ["Intel", "Search completed, but you found nothing!"] call A3A_fnc_customHint;
    };
}
else
{
    _squadLeader setVariable ["intelSearchDone", nil, true];
};
_caller setVariable ["intelFound", nil];
