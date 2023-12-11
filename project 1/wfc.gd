extends Node

var tilesData
var tilesArray =[]

const tileScn = preload("res://wave_function_tile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	tilesData = loadData()
	
	
	
	
	#init 3d tile array
	
	for x in range(3):
		var yArr = []
		for y in range(1):
			var zArr = []
			for z in range(3):
				
				var instance = tileScn.instantiate()
				
				
				zArr.append(instance)
				zArr[z].position = Vector3(x,y,z)
				add_child( zArr[z] )
				
			yArr.append(zArr)
		tilesArray.append(yArr)
	
	
	wfc()
	
	

func loadData():
	var filePath = "tiledata.json"
		
	
	var fileText = FileAccess.get_file_as_string(filePath)
	var tileDict = JSON.parse_string(fileText) 
	
	
	return tileDict



func wfc():
	var forestStore = tilesData["forest"]
	
	
		
	#if forestStore != null:
		#var mesh_name = forestStore["mesh_rotation"]

		# Print the result
		#print("rotate:", mesh_name)
		
	for tileType in tilesData.keys():
		print(tilesData[tileType]["mesh_name"])
		
		
	
	#set meshes,
	for x in tilesArray.size():
		for y in tilesArray[x].size():
			for z in tilesArray[x][y].size():
				var meshInstance = tilesArray[x][y][z].get_node("MeshInstance3D")
				
				
				
				var newMesh = preload("res://models/wfc/basic/mountain.obj")
				#var newMesh = preload("res://models/blahaj.obj")#temp model for debug
				
				meshInstance.mesh = newMesh
				
								



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
	
