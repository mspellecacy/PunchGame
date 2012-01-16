-- config.lua for project: PunchGame
-- Copyright 2011 Michael Spellecacy. All Rights Reserved.

application =
   {

   orientation =
      {
      default = "portrait",
      supported =
	 {
	 "portrait",
	 },
      },
      androidPermissions =
	 {
	 "android.permission.INTERNET",
	 "android.permission.ACCESS_NETWORK_STATE"
	 },
	 content =
	    {
	    fps = 60,
	    width = 640,
	    height = 960,
	    scale = "letterBox",
	    xAlign = "center",
	    yAlign = "center",
	    },
   }
