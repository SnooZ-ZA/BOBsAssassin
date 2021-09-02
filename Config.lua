Config = {
    Locker = {X= -77.79, Y= 363.63, Z= 112.44}, -- Position of the locker
    Uniforms = { -- Work uniforms (Make {} for none)
        Male= {
            tshirt_1 = 31,  tshirt_2 = 0,
			torso_1 = 31,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 27,
			pants_1 = 10,   pants_2 = 0,
			shoes_1 = 10,   shoes_2 = 0,
            helmet_1 = -1,  helmet_2 = 0,
            mask_1 = 0,     emask_2 = 0,
			chain_1 = 19,    chain_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			glasses_1 = 0,		glasses_2 = 0
        },
        FeMale= {
            tshirt_1 = 38,  tshirt_2 = 0,
			torso_1 = 7,   torso_2 = 1,
			decals_1 = 0,   decals_2 = 0,
			arms = 88,
			pants_1 = 37,   pants_2 = 5,
			shoes_1 = 0,   shoes_2 = 0,
            helmet_1 = -1,  helmet_2 = 0,
            mask_1 = 121,     emask_2 = 0,
			chain_1 = 87,    chain_2 = 4,
			ears_1 = -1,     ears_2 = 0
        }
    },

    Garage = {X= -73.45, Y= 359.61, Z= 112.44}, -- Position of the garage
    VehicleSpawn = {X= -73.69, Y= 357.61, Z= 112.44, Heading= 241.70}, -- Position where the vehicle will spawn
    VehicleDelete = {X= -76.42, Y= 352.0, Z= 112.44}, -- Position where the vehicle can despawn

    Vehicles = { -- All vehicles that can be spawned from the menu
        {Name= "Coquette", SpawnName= "coquette"},
        {Name= "Rapid GT", SpawnName= "rapidgt"},
		{Name= "Fugitive", SpawnName= "fugitive"}
    },
    LicensePlate = "HYRDGUN", -- Make "" for random text

    BlipName = "Assassin", -- Name of the marker on the map
    JobBlipName = "Assassin", -- Name of the marker on the map

    MoneyType = false, -- True= Cash | False= Bank
    MoneyAmount = 5000, -- Money you get for completing 1 job

    Translation = "EN", -- Translation to use

    Jobs = { -- Positions of available jobs
        {X= 289.79, Y= 191.27, Z= 104.37},
        {X= 244.47, Y= 163.84, Z= 104.98},
        {X= 353.76, Y= 416.98, Z= 141.73},
        {X= -17.04, Y= 317.75, Z= 113.16},
        {X= -112.99, Y= -150.45, Z= 57.85},
        {X= -324.33, Y= -257.15, Z= 34.39},
        {X= -208.18, Y= -784.29, Z= 30.45},
        {X= -254.32, Y= -978.53, Z= 31.22},
        {X= -167.00, Y= -1179.92, Z= 23.99},
        {X= 228.40, Y= -295.23, Z= 49.65},
        {X= -842.76, Y= -351.14, Z= 38.68},
        {X= -1339.50, Y= -1078.66, Z= 6.94},
        {X= -1858.84, Y= -632.75, Z= 11.23},
        {X= -1974.43, Y= -279.38, Z= 38.10},
        {X= -1626.64, Y= 37.86, Z= 62.54},
		{X= -1484.27, Y= 457.79, Z= 112.39},
		{X= -1305.62, Y= 314.50, Z= 65.49}
    },

    TranslationList = { -- List of all translation which you car choose
        ["EN"] = {
            ["LOCKER_HELP"] = "Press ~INPUT_CONTEXT~ to open the locker!",
            ["LOCKER_MENU"] = "Locker Menu",
            ["WORK_CLOTHES"] = "Work Clothes",
            ["NORMAL_CLOTHES"] = "Normal Clothes",

            ["GARAGE_HELP"] = "Press ~INPUT_CONTEXT~ to open the garage!",
            ["GARAGE_MENU"] = "Garage Menu",
            ["GARAGE_PROBLEM"] = "~r~ Something went wrong while spawning the vehicle. (Stopped to prevent crash!)",
            
            ["DELETE_HELP"] = "Press ~INPUT_CONTEXT~ to delete your vehicle!",

            ["MENU_HELP"] = "Press ~g~PgUp ~w~to open your menu!",
            ["MENU_MENU"] = "Menu",
            ["MENU_NEW"] = "Get new job",
            ["MENU_CREATED"] = "~g~ Succesfully created a new job!",
            ["MENU_CANCEL"] = "Cancel current job",
            ["MENU_CANCELED"] = "~g~ Succesfully canceled your job!",
            ["MENU_ALREADY"] = "~r~ You are already doing a job! You first need to cancel it.",
            ["MENU_NONE"] = "~r~ You have no active job!",

            ["JOB_HELP"] = "Press ~INPUT_CONTEXT~ to take a look!",
            ["JOB_DONE"] = "~g~ ID Confirmed, Job done. You have earned ~b~$5000,-~g~ for it!"
        },
        ["NL"] = {
            ["LOCKER_HELP"] = "Druk op ~INPUT_CONTEXT~ om de kleding kast te openen!",
            ["LOCKER_MENU"] = "Kleding Menu",
            ["WORK_CLOTHES"] = "Werk Kleding",
            ["NORMAL_CLOTHES"] = "Normale Kleding",

            ["GARAGE_HELP"] = "Druk op ~INPUT_CONTEXT~ om de garage te openen!",
            ["GARAGE_MENU"] = "Garage Menu",
            ["GARAGE_PROBLEM"] = "~r~ Er is iets fout gegaan tijdens het spawnen van het voertuig. (Gestopt om een crash te voorkomen!)",
            
            ["DELETE_HELP"] = "Druk op ~INPUT_CONTEXT~ om je voertuig je verwijderen!",

            ["MENU_HELP"] = "Druk op ~INPUT_SELECT_CHARACTER_FRANKLIN~ om je menu te openen!",
            ["MENU_MENU"] = "Menu",
            ["MENU_NEW"] = "Nieuwe opdracht",
            ["MENU_CREATED"] = "~g~ Succesvol een nieuw opdracht gemaakt!",
            ["MENU_CANCEL"] = "Beëindig huidige opdracht",
            ["MENU_CANCELED"] = "~g~ Opdracht succesvol beëindigd!",
            ["MENU_ALREADY"] = "~r~ U bent als bezig met een opdracht! U moet deze eerst beëindigen.",
            ["MENU_NONE"] = "~r~ U heeft geen huidige opdracht!",

            ["JOB_HELP"] = "Druk op ~INPUT_CONTEXT~ om een kijkje te nemen!",
            ["JOB_DONE"] = "~g~ Het probleem is succesvol op gelost. Je hebt er ~b~€100,-~g~ voor gekregen!"
        }
    }
}

--[[
  _____   _                                 _   _   _
 |_   _| (_)  _ __    _   _   ___          | \ | | | |
   | |   | | | '_ \  | | | | / __|         |  \| | | |    
   | |   | | | | | | | |_| | \__ \         | |\  | | |___ 
   |_|   |_| |_| |_|  \__,_| |___/  _____  |_| \_| |_____|
                                   |_____|
]]--
