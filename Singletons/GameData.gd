extends Node
##GameData.gd.  a singleton. Created by this method: in the godot fileSystem, rt click on the Singleton folder (that we created at the start)
##and select 'new script'.  Rename to 'GameData'.
##go to 'Project Settings/autoload/Singletons/GameData script
##GameData is always loaded while the game is running, so whatever we put in the script is 
##always alailable in the game.

##a dict of dicts containing data on 'damage',rof', 'range' 'category' for each tower type
var tower_data : Dictionary = {
	"GunT1": {"damage": 20,"rof": 1,"range": 350, "category": "Projectile"},
	"MissileT1": {"damage": 100,"rof": 3,"range": 550, "category": "Missile"}}
	
var ground_v1 : TileMapLayer
var astar_grid_v1 : AStarGrid2D

signal tower_placed
signal tower_removed
