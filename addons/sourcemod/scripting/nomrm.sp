
/**
 * vim: set ts=4 :
 * =============================================================================
 * SourceMod Nominations Remover
 * Remove Maps from the nominations list.
 *
 *
 * =============================================================================
 *
 */

#include <sourcemod>
#include <mapchooser>
#include <string>

#pragma semicolon 1

public Plugin:myinfo =
{
	name = "sm_nomrm",
	author = "Billehs",
	version = "0.1",
	description = "Nominations Remover",
	url = "https://github.com/CrimsonTautology/sm_nomrm"
};

#define NOMRM_ADMIN_FLAGS ADMFLAG_KICK
#define NAME_SIZE 32

new Handle:gNominateMaps   = INVALID_HANDLE;
new Handle:gNominateOwners = INVALID_HANDLE;

public OnPluginStart()
{
	LoadTranslations("common.phrases");

	gNominateMaps = CreateArray(ByteCountToCells(NAME_SIZE));
	gNominateOwners = CreateArray(1);

	RegAdminCmd("sm_nomrm", Command_Nomrm, NOMRM_ADMIN_FLAGS);
}

public Action:Command_Nomrm(client, args){
	if(!CanMapChooserStartVote()){
		ReplyToCommand(client, "[SM] Nomination period is over");

	}else{
		if (args == 0) {
			removeNominationMenu(client);
		}else{
			new String:target[128];

			for( new i=1; i<=args; i++ ){
				GetCmdArg(i, target, sizeof(target));
				removeNominationTarget(client, target);
			}
		}

	}
	return Plugin_Handled;
}


public removeNominationTarget(user, String:target[]){
	//First determine if we're doing a user name target
	new targetOwner = FindTarget(user, target, true);
	new owner = -1;


	//go through each map in the last and see if target is a substring of it or
	//if targetOwner owns that map.
	
	decl String:map[NAME_SIZE];
	GetNominatedMapList(gNominateMaps, gNominateOwners);
	new size = GetArraySize(gNominateMaps);

	for (new i=0; i<size; i++){
		GetArrayString(gNominateMaps, i, map, sizeof(map));
		owner = GetArrayCell(gNominateOwners, i);

		if(owner == targetOwner){
			//Target does refer to a person on the server and we just removed his map
			RemoveNominationByOwner(owner);
			ReplyToCommand(user, "[SM] Removed %s", map);
			continue;
		}
		if(StrContains(map, target, false) >= 0){
			RemoveNominationByMap(map);
			ReplyToCommand(user, "[SM] Removed %s", map);
			continue;
		}
	}

}

public removeNominationMenu(client){
	new Handle:menu = CreateMenu(MapRemoveHandler);
	decl String:map[NAME_SIZE];

	GetNominatedMapList(gNominateMaps, INVALID_HANDLE);
	new size = GetArraySize(gNominateMaps);

	for (new i=0; i<size; i++){
		AddMenuItem(menu, map, map);
	}

	SetMenuTitle(menu, "Select Favorite Class");
	DisplayMenu(menu, client, 20);

}
public MapRemoveHandler(Handle:menu, MenuAction:action, user, param){
	if(action == MenuAction_Select){
		new String:sMap[NAME_SIZE];
		new bool:found = GetMenuItem(menu, param, sMap, sizeof(sMap));

		if(found){
			RemoveNominationByMap(sMap);
			ReplyToCommand(user, "[SM] Removed %s", sMap);
		}


	}else if (action == MenuAction_End){
		CloseHandle(menu);
	}

}
