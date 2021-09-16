#include  <a_samp>
#include  <a_mysql>
#include <streamer>
#define cec_auto 
#include <cec>
#include <easyDialog>
#include <sscanf2>
#include <Pawn.CMD>
#include <progress2>
#include <foreach>

#include 	<YSI_Data\y_iterate>
#include 	<YSI_Coding\y_timers>

//ตั้งค่าการเชื่อมต่อ mysql

#define host_sql "localhost"
#define user_sql "root"
#define password_sql "123"
#define database_sql "gtashop"

//สี
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x00EA00FF
#define COLOR_RED 0xFF0000AA
#define COLOR_LIGHTRED 0xFF6347AA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_LIGHTGREEN 0x9ACD32AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_YELLOW2 0xF5DEB3AA

#define MAX_GPS (100)
#define MAX_AD_CAR (100)
#define MAX_SHOP_FOOD (50)
new MySQL:dbCon;
new pPlayerLogin[MAX_PLAYERS];
new Float:FuleCar[MAX_VEHICLES];
new PlayerText:HUD_SERVER[MAX_PLAYERS][5];
enum E_DATA_INFO
{
    pID,
	pSkinid,
	pCash,
	pHungry,
	pThirsty,
	pInjured,
	Float:pPos[3],
	pInterior,
	pTimeInjured,
	pAdmin,
	pWater,
	pPizza
};
new playerdata[MAX_PLAYERS][E_DATA_INFO];
enum E_DATA_GPS
{
    bool:gExits,
	Float:gPos[3],
	gType,
	gName[128]
	
};
new gpsData[MAX_GPS][E_DATA_GPS];
new CreateCars_Admin[MAX_AD_CAR];
enum E_DATA_SHOP_FOOD
{
    bool:fExits,
    Float:fPos[3],
    fIDPickUp,
    Text3D:fTextID	
};
new shopfooddata[MAX_SHOP_FOOD][E_DATA_SHOP_FOOD];
new VehicleNames[212][] =
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Pereniel", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus","Voodoo", "Pony",
    "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Mr Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",
    "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero",
    "Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer 2", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy",
    "Solair", "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot", "Quad",
    "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR3 50", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick",
    "News Chopper", "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa",
    "RC Goblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropdust",
    "Stunt", "Tanker", "RoadTrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
    "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent", "Bullet",
    "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster A",
    "Monster B", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito", "Freight", "Trailer", "Kart", "Mower",
    "Duneride", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "Newsvan", "Tug", "Trailer A", "Emperor", "Wayfarer", "Euros",
    "Hotdog", "Club", "Trailer B", "Trailer C", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car (LSPD)", "Police Car (SFPD)", "Police Car (LVPD)", "Police Ranger",
    "Picador", "S.W.A.T. Van", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage Trailer A", "Luggage Trailer B", "Stair Trailer", "Boxville", "Farm Plow", "Utility Trailer"
};
GetVehicleName(carid) {

    new string[20];
	new modelid = GetVehicleModel(carid);
    format(string,sizeof(string),"%s",VehicleNames[modelid - 400]);
    return string;
}


main()
{
   printf("GameMode Running: By ZoZenNy");
}
MySQl_Conncect_DB()
{
   dbCon  = mysql_connect(host_sql,user_sql,password_sql,database_sql);
   if(mysql_errno(dbCon)){
   printf("\nMySQL: Connection Failed\n");
   }else{
   printf("MySQL: Connection is Successful\n");
   }
}
ReturnName(playerid)
{
    static nameplayer[MAX_PLAYER_NAME +1];
	GetPlayerName(playerid,nameplayer,sizeof(nameplayer));
	return nameplayer;
}
public OnGameModeInit()
{
    SetGameModeText("ZoZenNy");
	MySQl_Conncect_DB();
	mysql_tquery(dbCon, "SELECT * FROM `gps`", "LoadGPS");
	mysql_tquery(dbCon, "SELECT * FROM `shopfood`", "LoadShopFood");
	for(new i=0;i<MAX_VEHICLES;i++){
	FuleCar[i]=100.0;
	}
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
    return 1;
}
forward MySQLCheckAccount(sqlplayersname[]);
public MySQLCheckAccount(sqlplayersname[])
{
	new query[128];
	new escstr[MAX_PLAYER_NAME];
	mysql_escape_string(sqlplayersname, escstr);
	format(query, sizeof(query), "SELECT id FROM players WHERE LOWER(Name) = LOWER('%s') LIMIT 1", escstr);
	mysql_query(dbCon,query);

	if(cache_num_rows() == 1)
	{
		new intid;
		cache_get_value_index_int(0, 0, intid);
		return intid;
	}
	return 0;
}
forward MySQLCreateAccount(newplayersname[], newpassword[]);
public MySQLCreateAccount(newplayersname[], newpassword[]) 
{
	new query[128];
	new sqlplyname[64];
	new sqlpassword[64];
	mysql_escape_string(newplayersname, sqlplyname);
	mysql_escape_string(newpassword, sqlpassword);
	format(query, sizeof(query), "INSERT INTO players (Name, Password)VALUES ('%s','%s')", sqlplyname, sqlpassword);
	mysql_query(dbCon,query);
	new newplayersid = MySQLCheckAccount(newplayersname);
	if (newplayersid != 0)
	{
		return newplayersid;
	}
	return 0;
}
public OnPlayerConnect(playerid)
{    
    pPlayerLogin[playerid] =false;
	playerdata[playerid][pSkinid]=0;
	playerdata[playerid][pCash]=0;
	playerdata[playerid][pHungry]=0;
	playerdata[playerid][pThirsty]=0;
	playerdata[playerid][pInjured]=0;
	playerdata[playerid][pTimeInjured]=0;
	playerdata[playerid][pAdmin]=0;
	playerdata[playerid][pWater]=0;
	playerdata[playerid][pPizza]=0;
	HUD_SERVER[playerid][0] = CreatePlayerTextDraw(playerid, 513.000000, 137.000000, "100%");
	PlayerTextDrawFont(playerid, HUD_SERVER[playerid][0], 3);
	PlayerTextDrawLetterSize(playerid, HUD_SERVER[playerid][0], 0.445833, 1.250000);
	PlayerTextDrawTextSize(playerid, HUD_SERVER[playerid][0], 553.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, HUD_SERVER[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, HUD_SERVER[playerid][0], 0);
	PlayerTextDrawAlignment(playerid, HUD_SERVER[playerid][0], 1);
	PlayerTextDrawColor(playerid, HUD_SERVER[playerid][0], -1);
	PlayerTextDrawBackgroundColor(playerid, HUD_SERVER[playerid][0], 255);
	PlayerTextDrawBoxColor(playerid, HUD_SERVER[playerid][0], 50);
	PlayerTextDrawUseBox(playerid, HUD_SERVER[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, HUD_SERVER[playerid][0], 1);
	PlayerTextDrawSetSelectable(playerid, HUD_SERVER[playerid][0], 0);

	HUD_SERVER[playerid][1] = CreatePlayerTextDraw(playerid, 513.000000, 160.000000, "100%");
	PlayerTextDrawFont(playerid, HUD_SERVER[playerid][1], 3);
	PlayerTextDrawLetterSize(playerid, HUD_SERVER[playerid][1], 0.445833, 1.250000);
	PlayerTextDrawTextSize(playerid, HUD_SERVER[playerid][1], 553.500000, 17.000000);
	PlayerTextDrawSetOutline(playerid, HUD_SERVER[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, HUD_SERVER[playerid][1], 0);
	PlayerTextDrawAlignment(playerid, HUD_SERVER[playerid][1], 1);
	PlayerTextDrawColor(playerid, HUD_SERVER[playerid][1], -1);
	PlayerTextDrawBackgroundColor(playerid, HUD_SERVER[playerid][1], 255);
	PlayerTextDrawBoxColor(playerid, HUD_SERVER[playerid][1], 50);
	PlayerTextDrawUseBox(playerid, HUD_SERVER[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, HUD_SERVER[playerid][1], 1);
	PlayerTextDrawSetSelectable(playerid, HUD_SERVER[playerid][1], 0);

	HUD_SERVER[playerid][2] = CreatePlayerTextDraw(playerid, 495.000000, 134.000000, "HUD:radar_burgershot");
	PlayerTextDrawFont(playerid, HUD_SERVER[playerid][2], 4);
	PlayerTextDrawLetterSize(playerid, HUD_SERVER[playerid][2], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, HUD_SERVER[playerid][2], 18.500000, 18.500000);
	PlayerTextDrawSetOutline(playerid, HUD_SERVER[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, HUD_SERVER[playerid][2], 0);
	PlayerTextDrawAlignment(playerid, HUD_SERVER[playerid][2], 1);
	PlayerTextDrawColor(playerid, HUD_SERVER[playerid][2], -1);
	PlayerTextDrawBackgroundColor(playerid, HUD_SERVER[playerid][2], 255);
	PlayerTextDrawBoxColor(playerid, HUD_SERVER[playerid][2], 50);
	PlayerTextDrawUseBox(playerid, HUD_SERVER[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, HUD_SERVER[playerid][2], 1);
	PlayerTextDrawSetSelectable(playerid, HUD_SERVER[playerid][2], 0);

	HUD_SERVER[playerid][3] = CreatePlayerTextDraw(playerid, 496.000000, 153.000000, "HUD:radar_diner");
	PlayerTextDrawFont(playerid, HUD_SERVER[playerid][3], 4);
	PlayerTextDrawLetterSize(playerid, HUD_SERVER[playerid][3], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, HUD_SERVER[playerid][3], 19.000000, 21.000000);
	PlayerTextDrawSetOutline(playerid, HUD_SERVER[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, HUD_SERVER[playerid][3], 0);
	PlayerTextDrawAlignment(playerid, HUD_SERVER[playerid][3], 1);
	PlayerTextDrawColor(playerid, HUD_SERVER[playerid][3], -1);
	PlayerTextDrawBackgroundColor(playerid, HUD_SERVER[playerid][3], 255);
	PlayerTextDrawBoxColor(playerid, HUD_SERVER[playerid][3], 50);
	PlayerTextDrawUseBox(playerid, HUD_SERVER[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, HUD_SERVER[playerid][3], 1);
	PlayerTextDrawSetSelectable(playerid, HUD_SERVER[playerid][3], 0);

	HUD_SERVER[playerid][4] = CreatePlayerTextDraw(playerid, 499.000000, 93.000000, "$00000000");
	PlayerTextDrawFont(playerid, HUD_SERVER[playerid][4], 3);
	PlayerTextDrawLetterSize(playerid, HUD_SERVER[playerid][4], 0.554166, 2.199999);
	PlayerTextDrawTextSize(playerid, HUD_SERVER[playerid][4], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, HUD_SERVER[playerid][4], 2);
	PlayerTextDrawSetShadow(playerid, HUD_SERVER[playerid][4], 0);
	PlayerTextDrawAlignment(playerid, HUD_SERVER[playerid][4], 1);
	PlayerTextDrawColor(playerid, HUD_SERVER[playerid][4], -16776961);
	PlayerTextDrawBackgroundColor(playerid, HUD_SERVER[playerid][4], 255);
	PlayerTextDrawBoxColor(playerid, HUD_SERVER[playerid][4], 50);
	PlayerTextDrawUseBox(playerid, HUD_SERVER[playerid][4], 0);
	PlayerTextDrawSetProportional(playerid, HUD_SERVER[playerid][4], 1);
	PlayerTextDrawSetSelectable(playerid, HUD_SERVER[playerid][4], 0);
	
    new sqlid = MySQLCheckAccount(ReturnName(playerid));
	if(sqlid)
    {
	      playerdata[playerid][pID] = sqlid;
	      SendClientMessage(playerid,-1,"{FF0000}o-{FFFFFF} กำลังเชื่อมต่อเซิฟเวอร์");
		  SetTimerEx("dialog_login",3000,false,"i",playerid);
	}else{
	SendClientMessage(playerid,-1,"{FF0000}o- {FFFFFF}กำลังเชื่อมต่อเซิฟเวอร์");
    SetTimerEx("dialog_register",3000,false,"i",playerid);
	}
    return 1;
}
forward dialog_login(playerid);
public dialog_login(playerid)
{
    Dialog_Show(playerid,dialog_login,DIALOG_STYLE_INPUT,"เข้าสู่ระบบ","คุณได้สมัครสมาชิกแล้ว\n\nกรุณาใส่รหัสผ่านเพื่อเข้าสู่ระบบ","เข้าสู่ระบบ","");
	return 1;
}
forward dialog_register(playerid);
public dialog_register(playerid)
{
    Dialog_Show(playerid,dialog_register,DIALOG_STYLE_INPUT,"สมัครสมาชิก","คุณยังไม่ได้สมัครสมาชิก\n\nกรุณาใส่รหัสผ่านเพื่อสมัครสมาชิก","สมัครสมาชิก","");
	return 1;
}
Dialog:dialog_login(playerid,response,listitem,inputtext[])
{
    if(!response || !strlen(inputtext))
    return dialog_login(playerid);
	LoginAccount(playerid,inputtext);
	return 1;
}
Dialog:dialog_register(playerid,response,listitem,inputtext[])
{
    if(!response || !strlen(inputtext))
    return dialog_register(playerid);
	CreateAccount(playerid,inputtext);
	return 1;
}
CreateAccount(playerid,password[])
{
    if(!IsPlayerConnected(playerid))
	   return 0;
	new accountsqlid = MySQLCreateAccount(ReturnName(playerid), password);
	if (accountsqlid != 0)
	{
			playerdata[playerid][pID] = accountsqlid;
			SendClientMessage(playerid, -1, "{FF0000}>>{FFFFFF} คุณได้ลงทะเบียนเรียบร้อยแล้ว...");
			SetTimerEx("dialog_login", 1000, 0, "d", playerid);
			return 1;
	}
	else
	{
			SendClientMessage(playerid, -1, "มีบัญชีนี้ในฐานข้อมูลเซิฟเวอร์แล้ว ไม่สามารถสมัครซ้ำได้");
			SetTimerEx("dialog_login", 1000, 0, "d", playerid);
			return 0;
	}
}
LoginAccount(playerid,password[])
{
    new	query[256];
	format(query,sizeof(query),"SELECT * FROM `players` WHERE `Name` = '%s' AND `Password` = '%s'",ReturnName(playerid),password);
	mysql_tquery(dbCon,query,"PlayerLoad","d",playerid);
}
forward PlayerLoad(playerid);
public PlayerLoad(playerid)
{
    if(!IsPlayerConnected(playerid) || IsPlayerNPC(playerid))
	    return 0;
	new rows;
    cache_get_row_count(rows);
	if(!rows)
	{
		SendClientMessage(playerid,-1,"{FF0000}>>{FFFFFF} รหัสผ่านไม่ถูกต้องโปรดลองใหม่อีกครั้ง");
		SetTimerEx("dialog_login",500,0,"d",playerid);
		return 1;
    }
	new resgister;
	cache_get_value_name_int(0, "ChechPlayer",resgister);
	cache_get_value_name_int(0, "Cash",playerdata[playerid][pCash]);
	cache_get_value_name_int(0, "Skin",playerdata[playerid][pSkinid]);
	cache_get_value_name_int(0, "Hungry",playerdata[playerid][pHungry]);
	cache_get_value_name_int(0, "Thirsty",playerdata[playerid][pThirsty]);
	cache_get_value_name_int(0, "Admin",playerdata[playerid][pAdmin]);
	cache_get_value_name_int(0, "Pizza",playerdata[playerid][pPizza]);
	cache_get_value_name_int(0, "Water",playerdata[playerid][pWater]);
	if(!resgister)
	{
	   playerdata[playerid][pCash] = 500;
	   playerdata[playerid][pSkinid] = 58;
	   playerdata[playerid][pAdmin] =0;
	   playerdata[playerid][pHungry] = 100;
	   playerdata[playerid][pThirsty] = 100;
	   new query[256];
	   format(query,sizeof(query),"UPDATE `players` SET ChechPlayer = 1 WHERE ID='%d'",playerdata[playerid][pID]);
	   mysql_tquery(dbCon, query);
	}
	new str[256];
	format(str,sizeof(str),"{FF0000}>>{FFFFFF} %s ได้เข้าร่วมเซิฟเวอร์",ReturnName(playerid));
	SendClientMessageToAll(-1,str);
    pPlayerLogin[playerid]=true;
	GivePlayerMoney(playerid,playerdata[playerid][pCash]);
	PlayerPlaySound(playerid,1058,0.0,0.0,0.0);
	SetSpawnInfo( playerid, 0, 0, 1958.33, 1343.12, 15.36, 269.15, 0, 0, 0, 0, 0, 0 );
	SpawnPlayer(playerid);
    return 1;
}
public OnPlayerUpdate(playerid)
{
    if(!pPlayerLogin[playerid]) 
	   return 0;
	new string[64];
	format(string,sizeof(string),"%d%",playerdata[playerid][pHungry]);
	PlayerTextDrawSetString(playerid,HUD_SERVER[playerid][0],string);
	
	format(string,sizeof(string),"%d%",playerdata[playerid][pThirsty]);
	PlayerTextDrawSetString(playerid,HUD_SERVER[playerid][1],string);
    UpDatePlayer_SQL(playerid);
    return 1;
}
public OnPlayerSpawn(playerid)
{
    for(new i=0;i<5;i++){PlayerTextDrawShow(playerid,HUD_SERVER[playerid][i]);}
    SetPlayerSkin(playerid,playerdata[playerid][pSkinid]);
	if(playerdata[playerid][pInjured])
	{
	    SetPlayerPos(playerid,playerdata[playerid][pPos][0],playerdata[playerid][pPos][1],playerdata[playerid][pPos][2]);
		SetPlayerInterior(playerid,playerdata[playerid][pInterior]);
		playerdata[playerid][pTimeInjured]=400;
		TogglePlayerControllable(playerid,false);
	    return 1;
	}
    return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_YES)
	{
	   ShowMenuPlayer(playerid);
	}
	if(newkeys & KEY_NO)
	{
	    if(IsPlayerNearShopFood(playerid))
		{
		    Dialog_Show(playerid,DIALOG_SHOP_FOOD,DIALOG_STYLE_TABLIST_HEADERS,"ร้านอาหาร","รายการ\tราคา\nพิซซ่า\t{00EA00}90${FFFFFF}\nน้ำเปล่า\t{00EA00}20${FFFFFF}","ซื้อ","ปิด");
		}
	}
	return 1;
}
ShowMenuPlayer(playerid)
{
    Dialog_Show(playerid,dialog_menu_id,DIALOG_STYLE_LIST,"MENU","ข้อมูลผู้เล่น\nกระเป๋า","ปิด","");
    return 1;
}
UpDatePlayer_SQL(playerid)
{
    if(!IsPlayerConnected(playerid) || !pPlayerLogin[playerid])
	    return 0;
    new query[2048];
	format(query,sizeof(query),"UPDATE `players` SET");
	playerdata[playerid][pCash] = GetPlayerMoney(playerid);
	format(query,sizeof(query),"%s Cash ='%d',",query,playerdata[playerid][pCash]);
	format(query,sizeof(query),"%s Skin ='%d',",query,playerdata[playerid][pSkinid]);
	format(query,sizeof(query),"%s Hungry ='%d',",query,playerdata[playerid][pHungry]);
	format(query,sizeof(query),"%s Thirsty ='%d',",query,playerdata[playerid][pThirsty]);
	format(query,sizeof(query),"%s Admin ='%d',",query,playerdata[playerid][pAdmin]);
	format(query,sizeof(query),"%s Pizza ='%d',",query,playerdata[playerid][pPizza]);
	format(query,sizeof(query),"%s Water ='%d'",query,playerdata[playerid][pWater]);
    format(query,sizeof(query),"%s WHERE `id` ='%d'",query,playerdata[playerid][pID]);
	mysql_tquery(dbCon,query);
    return 1;
}
task TimeLeftHungry[15000]()
{
   foreach(new i: Player)
   {
        new Float:hp;
        if(IsPlayerConnected(i) && pPlayerLogin[i])
		{
		    GetPlayerHealth(i,hp);
		    if(playerdata[i][pHungry] > 0){
			playerdata[i][pHungry]--;
			}
			if(playerdata[i][pHungry] <= 10)
			{
			    SetPlayerHealth(i,hp-5);
				SendClientMessage(i,-1,"{FF0000}F-{FFFFFF} คุณกำลังหิว....");
			}
			if(playerdata[i][pHungry] <=0){
			playerdata[i][pHungry]=0;
			}
		}
   }
   return 1;
}
task TimeLeftThirsty[12000]()
{
   foreach(new i: Player)
   {
        new Float:hp;
        if(IsPlayerConnected(i) && pPlayerLogin[i])
		{
		    GetPlayerHealth(i,hp);
		    if(playerdata[i][pThirsty] > 0){
			playerdata[i][pThirsty]--;
			}
			if(playerdata[i][pThirsty] <= 10)
			{
			    SetPlayerHealth(i,hp-5);
				SendClientMessage(i,-1,"{FF0000}F-{FFFFFF} คุณกำลังกระหายน้ำ....");
			}
			if(playerdata[i][pThirsty] <=0){
			playerdata[i][pThirsty]=0;
			}
		}
   }
   return 1;
}
public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
  if (result == -1)
  {
    SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}ERORR{FFFFFF} ไม่พบคำสั่งดั่งกล่าว");
    return 0;
  }

  return 1;
}
cmd:creategps(playerid, params[]) 
{
  if(!playerdata[playerid][pAdmin])
      return 1;
  new Float:pos[3];
  GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
  for(new i=0;i<MAX_GPS;i++)if(!gpsData[i][gExits])
  {
        gpsData[i][gExits]=true;
		gpsData[i][gPos][0]=pos[0];
		gpsData[i][gPos][1]=pos[1];
		gpsData[i][gPos][2]=pos[2];
		SetPVarInt(playerid,"ID_GPS",i);
		Dialog_Show(playerid,dialog_input_name,DIALOG_STYLE_INPUT,"สร้าง Gps","โปรดตั้งชื่อของ gps ตัวนี้\nชื่อควรมีตัวอักษรไม่เกิน 128","สร้าง","ยกเลิก");
        break;
  }
  return 1;
}
Dialog:dialog_input_name(playerid,response,listitem,inputtext[])
{
    if(!response)
	  return Cancel_Gps(GetPVarInt(playerid,"ID_GPS"));
	if(!strlen(inputtext))
	  return Dialog_Show(playerid,dialog_input_name,DIALOG_STYLE_INPUT,"สร้าง Gps","โปรดตั้งชื่อของ gps ตัวนี้\nชื่อควรมีตัวอักษรไม่เกิน 128","สร้าง","ยกเลิก");
	if(strlen(inputtext) > 128)
	{ 
	   SendClientMessage(playerid,-1,"สามารถตั้งชื่อ gps ได้แค่ 128 ตัวอักษรเท่านั้น");
	   Dialog_Show(playerid,dialog_input_name,DIALOG_STYLE_INPUT,"สร้าง Gps","โปรดตั้งชื่อของ gps ตัวนี้\nชื่อควรมีตัวอักษรไม่เกิน 128","สร้าง","ยกเลิก");
	}
	new id = GetPVarInt(playerid,"ID_GPS");
	format(gpsData[id][gName],128,inputtext);
	PlayerPlaySound(playerid,1053,0.0,0.0,0.0);
	Dialog_Show(playerid,dialog_list_type,DIALOG_STYLE_TABLIST_HEADERS,"เลือกประเภท gps","ลำดับ\tประเภท\n>> 1\tสถานที่\n>> 2\tงานถูกกฎหมาย\n>> 3\tงานผิดกฎหมาย\n{FF0000}>> ยืนยัน{FFFFFF}","ตกลง","ยกเลิก");
    return 1;
}
Dialog:dialog_list_type(playerid,response,listitem,inputtext[])
{
    if(!response)
	   return Cancel_Gps(GetPVarInt(playerid,"ID_GPS"));
	new id = GetPVarInt(playerid,"ID_GPS");
	switch(listitem)
	{
	   case 0:
	   {
	        gpsData[id][gType]=1;
			PlayerPlaySound(playerid,1058,0.0,0.0,0.0);
			SendClientMessage(playerid,-1,"คุณได้เลือกเป็ณประเภทที่ 1");
			Dialog_Show(playerid,dialog_list_type,DIALOG_STYLE_TABLIST_HEADERS,"เลือกประเภท gps","ลำดับ\tประเภท\n>> 1\tสถานที่\n>> 2\tงานถูกกฎหมาย\n>> 3\tงานผิดกฎหมาย\n{FF0000}>> ยืนยัน{FFFFFF}","ตกลง","ยกเลิก");
	   }
	   case 1:
	   {
	        gpsData[id][gType]=2;
			PlayerPlaySound(playerid,1058,0.0,0.0,0.0);
			SendClientMessage(playerid,-1,"คุณได้เลือกเป็ณประเภทที่ 2");
			Dialog_Show(playerid,dialog_list_type,DIALOG_STYLE_TABLIST_HEADERS,"เลือกประเภท gps","ลำดับ\tประเภท\n>> 1\tสถานที่\n>> 2\tงานถูกกฎหมาย\n>> 3\tงานผิดกฎหมาย\n{FF0000}>> ยืนยัน{FFFFFF}","ตกลง","ยกเลิก");
	   }
	   case 2:
	   {
	        gpsData[id][gType]=3;
			PlayerPlaySound(playerid,1058,0.0,0.0,0.0);
			SendClientMessage(playerid,-1,"คุณได้เลือกเป็ณประเภทที่ 3");
			Dialog_Show(playerid,dialog_list_type,DIALOG_STYLE_TABLIST_HEADERS,"เลือกประเภท gps","ลำดับ\tประเภท\n>> 1\tสถานที่\n>> 2\tงานถูกกฎหมาย\n>> 3\tงานผิดกฎหมาย\n{FF0000}>> ยืนยัน{FFFFFF}","ตกลง","ยกเลิก");
	   }
	   case 3:
	   {
	        if(!gpsData[id][gExits])
			{
			    Cancel_Gps(GetPVarInt(playerid,"ID_GPS"));
				SendClientMessage(playerid,-1,"มีข้อผิดพลาดในการสร้าง โปรดลองอีกครั้ง");
			    return 1;
			}
			if(gpsData[id][gType]==0)
			{
			 
			    SendClientMessage(playerid,-1,"กรุณาเลือกประเภทของ gps ด้วย");
				Dialog_Show(playerid,dialog_list_type,DIALOG_STYLE_TABLIST_HEADERS,"เลือกประเภท gps","ลำดับ\tประเภท\n>> 1\tสถานที่\n>> 2\tงานถูกกฎหมาย\n>> 3\tงานผิดกฎหมาย\n{FF0000}>> ยืนยัน{FFFFFF}","ตกลง","ยกเลิก");
			    return 1;
			}
			InsertGps_SQL(id);
			SendClientMessage(playerid,-1,"คุณได้สร้าง gps แล้ว");
	   }
	}
    return 1;
}
cmd:gps(playerid, params[]) 
{
    Dialog_Show(playerid,dialog_gps,DIALOG_STYLE_LIST,"GPS",">> สถานที่\n>> งานถูกกฎหมาย\n>> งานผิดกฎหมาย\n>> ปิด Gps","ตกลง","ปิด");
    return 1;
}
Dialog:dialog_gps(playerid,response,listitem,inputtext[])
{
   if(!response)
     return 1;
   if(listitem == 3)
      return DisablePlayerCheckpoint(playerid);
   Select_Type_Gps(playerid,listitem+1);
   return 1;
}
Select_Type_Gps(playerid,type)
{
   new str[256],str2[256],count,var[32];
   for(new i=0;i<MAX_GPS;i++)if(gpsData[i][gExits] && gpsData[i][gType]==type)
   {
        format(str,sizeof(str),">> %s",gpsData[i][gName]);
		strcat(str2,str);
		format(var,sizeof(var),"lsitid%d",count);
		SetPVarInt(playerid,var,i);
		count++;
   }
   if(!count)
     return SendClientMessage(playerid,-1,"ยังไม่มีข้อมูลใดๆ");
   
   Dialog_Show(playerid,dialog_gps_select,DIALOG_STYLE_LIST,"GPS",str2,"นำทาง","ปิด");
   return 1;
}
cmd:deletegps(playerid, params[])
{
   if(!playerdata[playerid][pAdmin])
      return 1;
   Dialog_Show(playerid,dialog_delete_gps,DIALOG_STYLE_INPUT,"ลบ Gps","กรุณาระบบชื่อ gps ที่ต้องการลบ","ลบ","ยกเลิก");
   return 1;
}
Dialog:dialog_delete_gps(playerid,response,listitem,inputtext[])
{
    if(!response)
       return 1;	
	if(!strlen(inputtext))
	{
	   SendClientMessage(playerid,-1,"กรุณาระบบชื่อ Gps ที่ต้องการลบ");
	   Dialog_Show(playerid,dialog_delete_gps,DIALOG_STYLE_INPUT,"ลบ Gps","กรุณาระบบชื่อ gps ที่ต้องการลบ","ลบ","ยกเลิก");
	   return 1;
	}
	new str[128];
	for(new i=0;i<MAX_GPS;i++)if(gpsData[i][gExits] && !strcmp(gpsData[i][gName],inputtext,true))
	{
		gpsData[i][gExits]=false;
		gpsData[i][gName]=0;
		gpsData[i][gType]=0;
		gpsData[i][gPos][0]=0.0;
		gpsData[i][gPos][1]=0.0;
		gpsData[i][gPos][2]=0.0;
		format(str,sizeof(str),"คุณได้ gps : %s แล้ว",inputtext);
		SendClientMessage(playerid,-1,str);
		new query[64];
	    format(query,sizeof(query),"DELETE FROM gps WHERE ID = '%d'",i);
	    mysql_query(dbCon,query);
		PlayerPlaySound(playerid,1058,0.0,0.0,0.0);
	    return 1;
	}
	SendClientMessage(playerid,-1,"ไม่พบ gps ชื่อดังกล่าว");
    return 1;
}
Dialog:dialog_gps_select(playerid,response,listitem,inputtext[])
{
   if(!response)
      return 1;
   new id,var[32],str[128];
   format(var,sizeof(var),"lsitid%d",listitem);
   id  =	GetPVarInt(playerid,var);
   PlayerPlaySound(playerid,1058,0.0,0.0,0.0);
   SetPlayerCheckpoint(playerid,gpsData[id][gPos][0],gpsData[id][gPos][1],gpsData[id][gPos][2],3.0);
   format(str,sizeof(str),"{FF0000}>>{FFFFFF} คุณได้เปิด gps นำทางไปที่ %s",gpsData[id][gName]);
   SendClientMessage(playerid,-1,str);
   return 1;
}
Cancel_Gps(id)
{
    if(gpsData[id][gExits])
	{
	   gpsData[id][gExits] =false;
	   gpsData[id][gPos][0]=0.0;
	   gpsData[id][gPos][1]=0.0;
	   gpsData[id][gPos][2]=0.0;
	   gpsData[id][gType]=0;
	   return 1;
	}
    return 0;
}
InsertGps_SQL(id)
{
        new query[86];
		format(query,sizeof(query),"INSERT INTO  gps SET ID='%d',xPos='%f',yPos='%f',zPos='%f',gType='%d',gName='%s'",id,gpsData[id][gPos][0],gpsData[id][gPos][1],gpsData[id][gPos][2],gpsData[id][gType],gpsData[id][gName]);
		mysql_tquery(dbCon,query);
}
forward LoadGPS();
public LoadGPS()
{
    new rows = cache_num_rows();
	new id,loaded;
 	if(rows)
  	{
		while(loaded < rows)
		{

		    cache_get_value_name_int(loaded,"ID",id);
		    cache_get_value_name_float(loaded,"xPos",gpsData[id][gPos][0]);
		    cache_get_value_name_float(loaded,"yPos",gpsData[id][gPos][1]);
		    cache_get_value_name_float(loaded,"zPos",gpsData[id][gPos][2]);
            cache_get_value_name_int(loaded,"gType",gpsData[id][gType]);
            cache_get_value_name(loaded,"gName",gpsData[id][gName],128);
		    if(!gpsData[id][gExits])
		    {
		        gpsData[id][gExits] = true;
		    }
		    loaded ++;
		}

	}
	printf("[MYSQL]:LOAD_GPS %d", loaded);
}
public OnPlayerDeath(playerid, killerid, reason)
{
    SendDeathMessage(killerid, playerid, reason); 
 
    if(playerdata[playerid][pInjured]==0 && GetPlayerState(playerid) == PLAYER_STATE_WASTED)
	{
	    GetPlayerPos(playerid,playerdata[playerid][pPos][0],playerdata[playerid][pPos][1],playerdata[playerid][pPos][2]);
		playerdata[playerid][pInterior]=GetPlayerInterior(playerid);
		playerdata[playerid][pInjured]=1;
		playerdata[playerid][pTimeInjured]=400;
	}
    return 1;
}
task playerDeathLeft[1000]()
{
     foreach(new i:Player)
	 {
	    if(IsPlayerConnected(i) && pPlayerLogin[i] && playerdata[i][pInjured])
		{
		    if(playerdata[i][pTimeInjured]>0)
			{
			    playerdata[i][pTimeInjured]--;
				RemovePlayerFromVehicle(i);
				ApplyAnimation(i, "CRACK", "crckidle1",4.0,0,1,1,1,-1);
				new string[256];
				format(string, sizeof(string), "~n~~n~~w~You will be born again in~y~ %d ~w~second",playerdata[i][pTimeInjured]);
				GameTextForPlayer(i, string, 1000, 3);
			}
			if(playerdata[i][pTimeInjured] <=0)
			{
			    playerdata[i][pInjured]=0;
				playerdata[i][pTimeInjured]=0;
				SetPlayerHealth(i,100);
				ClearAnimations(i);
				TogglePlayerControllable(i,true);
				OnPlayerSpawn(i);
				PlayerPlaySound(i,1058,0.0,0.0,0.0);
			}
		}
	 }
}
cmd:sethp(playerid, params[])
{
    if(!playerdata[playerid][pAdmin])
	  return 1;
	new id,amount;
	if(sscanf(params,"ii",id,amount))
	  return SendClientMessage(playerid,-1,"/Sethp [ไอดีผู้เล่น][0-100]");
	if(!IsPlayerConnected(id) || !pPlayerLogin[id] || IsPlayerNPC(id))
	  return SendClientMessage(playerid,-1,"มีข้อผิดพลาด โปรดเช็คว่าผู้เล่นอยู่ในเซิฟเวอร์หรือป่าว");
	new str[256];
	format(str,sizeof(str),">> คุณได้เซ็ตเลือดให้ %s เป็น %d",ReturnName(id),amount);
	SendClientMessage(playerid,-1,str);
	format(str,sizeof(str),">> %s ได้เช็ตเลือดของคุุณเป็น %d",ReturnName(playerid),amount);
	SendClientMessage(id,-1,str);
	SetPlayerHealth(id,amount);
    return 1;
}
cmd:givemoney(playerid, params[])
{
    if(!playerdata[playerid][pAdmin])
	   return 1;
	new id,amountm;
	if(sscanf(params,"ii",id,amountm))
	   return SendClientMessage(playerid,-1,"/Givemoney [ไอดีผู้เล่น][จำนวนเงิน]");
	if(amountm < 0 || amountm > 1000000)//สามารถกำหนดว่าห้ามให้เงินเกินอะไรเท่าไหร่
	   return SendClientMessage(playerid,-1,"{FF0000}>>{FFFFFF} จำนวนเงินควรอยู่ระหว่าง 0-1,000,000");
	if(!IsPlayerConnected(id) || !pPlayerLogin[id] || IsPlayerNPC(id))
	  return SendClientMessage(playerid,-1,"มีข้อผิดพลาด โปรดเช็คว่าผู้เล่นอยู่ในเซิฟเวอร์หรือป่าว");
	new str[256];
	format(str,sizeof(str),">> คุณได้ให้เงิน %s  %d$",ReturnName(id),amountm);
	SendClientMessage(playerid,-1,str);
	format(str,sizeof(str),">> %s ได้ให้เงินคุุณ %d$",ReturnName(playerid),amountm);
	SendClientMessage(id,-1,str);
	GivePlayerMoney(id,amountm);
    return 1;
}
task LeftFuleCar[15000]()
{
    foreach(new i:Player)
	{
	    if(IsPlayerConnected(i) && pPlayerLogin[i] && IsPlayerInAnyVehicle(i) && GetPlayerState(i)== PLAYER_STATE_DRIVER)
		{
		    new carid = GetPlayerVehicleID(i);
			if(FuleCar[carid] > 0)
			{
			   FuleCar[carid]-= 0.1;
			}
			if(FuleCar[carid]<=0)
			{
			   SendClientMessage(i,COLOR_GREY,">>{FFFFFF} รถน้ำมันหมดแล้ว");
			   RemovePlayerFromVehicle(i);
			   PlayerPlaySound(i, 1085, 0.0, 0.0, 0.0);
			   if(IsPlayerInVehicle(i, carid)){
			   new Float:x, Float:y, Float:z;
			   GetPlayerPos(i, x, y, z);
			   SetPlayerPos(i, x, y, z+2);
			   }
			}
			new str[64];
			format(str,sizeof(str),"~y~Fule:%.1f%",FuleCar[carid]);
			GameTextForPlayer(i, str, 5000, 1);
		}
	}
    return 1;
}
cmd:veh(playerid, params[])
{
    if(!playerdata[playerid][pAdmin])
	   return 1;
	new modelid,color1,color2,Float:pos[3];
	if(sscanf(params,"iii",modelid,color1,color2))
	   return SendClientMessage(playerid,COLOR_RED,"<>{FFFFFF} /veh [โมเดลรถ][ไอดีสี][ไอดีสี]");
	GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	for(new i=0;i<MAX_AD_CAR;i++)if(!CreateCars_Admin[i])
	{
	    CreateCars_Admin[i] =  CreateVehicle(modelid, pos[0],pos[1],pos[2], 82.2873, color1,color2, 60);
		PutPlayerInVehicle(playerid,CreateCars_Admin[i],0);
		PlayerPlaySound(playerid,1058,0.0,0.0,0.0);
		new str[256];
		format(str,sizeof(str),">>{FFFFFF} คุณได้สร้างรถ %s แล้ว",GetVehicleName(CreateCars_Admin[i]));
		SendClientMessage(playerid,COLOR_YELLOW,str);
	    return 1;
	}
	SendClientMessage(playerid,COLOR_RED,">>{FFFFFF} คุณได้สร้างรถเกินขีดจำกัดแล้ว");
    return 1;
}
cmd:destroyveh(playerid, params[])
{
    if(!playerdata[playerid][pAdmin])
	   return 1;
	if(!IsPlayerInAnyVehicle(playerid))
	  return SendClientMessage(playerid,COLOR_LIGHTRED,">>{FFFFFF} คุณต้องอยู่บนรถเท่านั้น");
	new str[84];
	format(str,sizeof(str),">>{FFFFFF} คุณได้ลบรถ %s ออกจากเซิฟเวอร์",GetVehicleName(GetPlayerVehicleID(playerid)));
	SendClientMessage(playerid,COLOR_GREY,str);
	for(new i=0;i<MAX_AD_CAR;i++)if(CreateCars_Admin[i] == GetPlayerVehicleID(playerid)){CreateCars_Admin[i]=0;}
	DestroyVehicle(GetPlayerVehicleID(playerid));
    return 1;
}
cmd:createshopfood(playerid, params[])
{
    if(!playerdata[playerid][pAdmin])
	  return 1;
	new Float:pos[3];
	GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	for(new i=0;i<MAX_SHOP_FOOD;i++)if(!shopfooddata[i][fExits]){
	shopfooddata[i][fExits]=true;
	shopfooddata[i][fPos][0] = pos[0];
	shopfooddata[i][fPos][1] = pos[1];
	shopfooddata[i][fPos][2] = pos[2];
	shopfooddata[i][fIDPickUp] = CreatePickup(1274,1,pos[0],pos[1],pos[2]);
	new str[64];
	format(str,sizeof(str),"{FFFF00}[ID:%d]\n[ร้านอาหาร]{FFFFFF}\nกด N",i);
	shopfooddata[i][fTextID] =  Create3DTextLabel(str, -1, pos[0],pos[1],pos[2], 20.0, 0, 0);
	PlayerPlaySound(playerid,1058,0.0,0.0,0.0);
	format(str,sizeof(str),">>{FFFFFF} คุณได้สร้างร้านอาหาร ID: %d",i);
	SendClientMessage(playerid,COLOR_GREY,str);
	new query[128];
	format(query,sizeof(query),"INSERT INTO  shopfood SET ID='%d',xPos='%f',yPos='%f',zPos='%f'",i,pos[0],pos[1],pos[2]);
	mysql_tquery(dbCon,query);
	return 1;
	}
	SendClientMessage(playerid,COLOR_RED,">>{FFFFFF} สามารถสร้างร้านอาหารได้แค่ 50 ร้านเท่านั้น");
    return 1;
}
cmd:deleteshopfood(playerid, params[])
{
   if(!playerdata[playerid][pAdmin])
      return 1;
   new id;
   if(sscanf(params,"i",id))
     return SendClientMessage(playerid,COLOR_GREY,"/deleteshopfood [ไอดีร้านอาหาร]");
   if(shopfooddata[id][fExits])
   {
        shopfooddata[id][fExits]=false;
		shopfooddata[id][fPos][0] =0.0;
		shopfooddata[id][fPos][1] = 0.0;
		shopfooddata[id][fPos][2] = 0.0;
		DestroyPickup(shopfooddata[id][fIDPickUp]);
	    Delete3DTextLabel(shopfooddata[id][fTextID]);
		new str[64];
		format(str,sizeof(str),">>{FFFFFF} คุณได้ลบร้านอาหาร ID: %d แล้ว",id);
		SendClientMessage(playerid,COLOR_GREY,str);
		new query[64];
	    format(query,sizeof(query),"DELETE FROM shopfood WHERE ID = '%d'",id);
	    mysql_query(dbCon,query);
		return 1;
   }
   SendClientMessage(playerid,COLOR_RED,">>{FFFFFF} ไม่พบร้านอาหาร ID ดังกล่าว");
   return 1;
}
IsPlayerNearShopFood(playerid)
{
    for(new i=0;i<MAX_SHOP_FOOD;i++)if(shopfooddata[i][fExits]){
	if (IsPlayerInRangeOfPoint(playerid, 3.0, shopfooddata[i][fPos][0],shopfooddata[i][fPos][1],shopfooddata[i][fPos][2])){
	return 1;
	}
	}
    return 0;
}
Dialog:DIALOG_SHOP_FOOD(playerid,response,listitem,inputtext[])
{
   if(!response)
      return 1;
   switch(listitem){
   case 0:{
   SetPVarInt(playerid,"ID_LIST_SHOP",listitem);
   Dialog_Show(playerid,DIALOG_BUY_FOOD,DIALOG_STYLE_INPUT,"ร้านอาหาร","คุณต้องการซื้อพิซซ่าจำนวนกี่ชิ้น","ซื้อ","ปิด");
   }
   case 1:{
   SetPVarInt(playerid,"ID_LIST_SHOP",listitem);
   Dialog_Show(playerid,DIALOG_BUY_FOOD,DIALOG_STYLE_INPUT,"ร้านอาหาร","คุณต้องการซื้อน้ำเปล่าจำนวนกี่ขวด","ซื้อ","ปิด");
   }
   }
   return 1;
}
Dialog:DIALOG_BUY_FOOD(playerid,response,listitem,inputtext[])
{
   if(!response)
      return 1;
   switch(GetPVarInt(playerid,"ID_LIST_SHOP"))
   {
       case 0:{
	   if(!strlen(inputtext))
	      return SendClientMessage(playerid,COLOR_GREY,">>{FFFFFF} กรุณาระบบจำนวนสินค้าที่คุณต้องการ");
	   if(GetPlayerMoney(playerid) < 90*strval(inputtext))
	      return SendClientMessage(playerid,COLOR_RED,">#<{FFFFFF} เงินไม่เพียงพอ");
	   playerdata[playerid][pPizza]+=strval(inputtext);
	   GivePlayerMoney(playerid,-strval(inputtext)*90);
	   new str[64];
	   format(str,sizeof(str),"<$>{FFFFFF} คุณได้ซื้อพิซซ่าจำนวน %d ในราคา %d$",strval(inputtext),90*strval(inputtext));
	   SendClientMessage(playerid,COLOR_GREEN,str);
	   PlayerPlaySound(playerid,1058,0.0,0.0,0.0);
	   }
	   case 1:{
	   if(!strlen(inputtext))
	      return SendClientMessage(playerid,COLOR_GREY,">>{FFFFFF} กรุณาระบบจำนวนสินค้าที่คุณต้องการ");
	   if(GetPlayerMoney(playerid) < 20*strval(inputtext))
	      return SendClientMessage(playerid,COLOR_RED,">#<{FFFFFF} เงินไม่เพียงพอ");
	   playerdata[playerid][pWater]+=strval(inputtext);
	   GivePlayerMoney(playerid,-strval(inputtext)*20);
	   new str[64];
	   format(str,sizeof(str),"<$>{FFFFFF} คุณได้ซื้อน้ำเปล่าจำนวน %d ในราคา %d$",strval(inputtext),20*strval(inputtext));
	   SendClientMessage(playerid,COLOR_GREEN,str);
	   PlayerPlaySound(playerid,1058,0.0,0.0,0.0);
	   }
   }
   return 1;
}
Dialog:dialog_menu_id(playerid,response,listitem,inputtext[])
{
   if(!response)
       return 1;
   switch(listitem){
  
   case 1: ShowBagPlayer(playerid);//ระบบกระเป๋าไม่ใช่แบบ inventory
   }
   return 1;
}
ShowBagPlayer(playerid)
{
    new str[64];
	format(str,sizeof(str),"พิซซ่า\t[%d]\nน้ำเปล่า\t[%d]\n",playerdata[playerid][pPizza],playerdata[playerid][pWater]);
	Dialog_Show(playerid,dialog_list_bag,DIALOG_STYLE_TABLIST,"กระเป๋า",str,"ใช้","ปิด");
	return 1;
}
Dialog:dialog_list_bag(playerid,response,listitem,inputtext[])
{
   if(!response)
      return 1;
	  
   switch(listitem)
   {
      case 0:{
	  if(playerdata[playerid][pHungry] >=100)
	     return SendClientMessage(playerid,COLOR_GREY,">>{FFFFFF} คุณอิ่มแล้ว");
	  playerdata[playerid][pHungry]+=5;
	  playerdata[playerid][pPizza]-=1;
	  SendClientMessage(playerid,COLOR_GREY,"<!>:{FFFFFF} คุณได้กินพิซซ่าแล้ว");
	  }
	  case 1:{
	  if(playerdata[playerid][pThirsty] >=100)
	     return SendClientMessage(playerid,COLOR_GREY,">>{FFFFFF} คุณอิ่มน้ำแล้ว");
	  playerdata[playerid][pThirsty]+=5;
	  playerdata[playerid][pWater]-=1;
	  SendClientMessage(playerid,COLOR_GREY,"<!>:{FFFFFF} คุณได้กินน้ำเปล่าแล้ว");
	  }
   }
   return 1;
}
forward LoadShopFood();
public LoadShopFood()
{
    new rows = cache_num_rows();
	new id,loaded;
 	if(rows)
  	{
		while(loaded < rows)
		{

		    cache_get_value_name_int(loaded,"ID",id);
		    cache_get_value_name_float(loaded,"xPos",shopfooddata[id][fPos][0]);
		    cache_get_value_name_float(loaded,"yPos",shopfooddata[id][fPos][1]);
		    cache_get_value_name_float(loaded,"zPos",shopfooddata[id][fPos][2]);
			shopfooddata[id][fIDPickUp] = CreatePickup(1274,1,shopfooddata[id][fPos][0],shopfooddata[id][fPos][1],shopfooddata[id][fPos][2]);
			new str[64];
			format(str,sizeof(str),"{FFFF00}[ID:%d]\n[ร้านอาหาร]{FFFFFF}\nกด N",id);
			shopfooddata[id][fTextID] =  Create3DTextLabel(str, -1, shopfooddata[id][fPos][0],shopfooddata[id][fPos][1],shopfooddata[id][fPos][2], 20.0, 0, 0);
		    if(!shopfooddata[id][fExits])
		    {
		        shopfooddata[id][fExits] = true;
		    }
		    loaded ++;
		}

	}
	printf("[MYSQL]:LOAD_SHOPFOOD %d", loaded);
}