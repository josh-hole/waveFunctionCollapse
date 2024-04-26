extends Node

var tilesData
var themeData

var tilesArray =[]

const tileScn = preload("res://wave_function_tile.tscn")

var traversable = ["plains"]
const validDirs = [
	[1,0,0],
	[-1,0,0],
	[0,1,0],
	[0,-1,0],
	[0,0,1],
	[0,0,-1]
]

const bounds=[24,1,24]
#const bounds=[50,1,38]
#const bounds=[100,1,100]



var time = 0.0
var canDoneAlert = true

# Called when the node enters the scene tree for the first time.
func _ready():
	tilesData = loadData("tiledata.json")
	themeData = loadData("themes.json")
	
	
	
	
	#init 3d tile array
	
	for x in range(bounds[0]):
		var yArr = []
		for y in range(bounds[1]):
			var zArr = []
			for z in range(bounds[2]):
				
				var instance = tileScn.instantiate()
				
				
				
				zArr.append(instance)
				zArr[z].position = Vector3(x,y,z)
				add_child( zArr[z] )
				
				
				#zArr[z].get_node("MeshInstance3D").themes = {"woods":x, "desert":(bounds[0]-x)}
				
				#zArr[z].get_node("MeshInstance3D").themes = {"desert":x, "woods":(bounds[0]-x)}
				#zArr[z].get_node("MeshInstance3D").themes = {"scrub":x, "desert":(bounds[0]-x)}
				
				#
				
				#if x>12:
				#	zArr[z].get_node("MeshInstance3D").themes =  {"woods":x}
				#else:
				#	zArr[z].get_node("MeshInstance3D").themes =  {"scrub":(bounds[0]-x)}
				
				#add wfc data to tile
				
				#loop throught all tiles to see if they can be added
				for tileType in tilesData.keys():	
									
					#make sure they adhere to the theme tho
					var valid = false
					#check if tile is in it's themes					
					#loop throught all themes
					for theme in themeData:						
						# does the tile have that theme???
						
						#print(theme)
						#print(zArr[z].get_node("MeshInstance3D").themes)
						if zArr[z].get_node("MeshInstance3D").themes.has(theme):
							
							#and is the possible tile in said theme
							#print(tileType)
							#print(themeData[theme]["valid_tiles"])
							if tileType in themeData[theme]["valid_tiles"]:
								#then we allow it
								valid = true
								#print("valid tile!")
							
					if valid:
						zArr[z].get_node("MeshInstance3D").possibilities.append(tileType)
						
				#while true:
					#var a = 1
				
				
			yArr.append(zArr)
		tilesArray.append(yArr)
	
	#
	
	const hardCodePath = true
	#make a predefined preset traversable path through the map 
	for x in range(tilesArray.size()):		
		for y in range(tilesArray[x].size()):			
			for z in range(tilesArray[x][y].size()):
				
				#hard coded path				
				if (z == x or z == x+1)and hardCodePath:
					
					var removeList = []
					for p in tilesArray[x][y][z].get_node("MeshInstance3D").possibilities:
						if not(p in traversable):							
							removeList.append(p)
							
						
					for p in tilesArray[x][y][z].get_node("MeshInstance3D").possibilities:
						if p in removeList:
							tilesArray[x][y][z].get_node("MeshInstance3D").possibilities.pop_at(
								tilesArray[x][y][z].get_node("MeshInstance3D").possibilities.find(p)
								)
								
					#do it again, very bad coding, but it works if i do this
					for p in tilesArray[x][y][z].get_node("MeshInstance3D").possibilities:
						if p in removeList:
							tilesArray[x][y][z].get_node("MeshInstance3D").possibilities.pop_at(
								tilesArray[x][y][z].get_node("MeshInstance3D").possibilities.find(p)
								)
					
					#print(tilesArray[x][y][z].get_node("MeshInstance3D").possibilities)
					#force to be plains 
					#tilesArray[x][y][z].get_node("MeshInstance3D").possibilities = ["plains"]
							
					
					
	
	
	
	#loop over wfc to generate the map
	wfc()
	
	

func loadData(filePath):
	
	
	var fileText = FileAccess.get_file_as_string(filePath) 
	var tileDict = JSON.parse_string(fileText) 
	
	
	return tileDict



func wfc():
	#var forestStore = tilesData["forest"]
	
	
		
	#if forestStore != null:
		#var mesh_name = forestStore["mesh_rotation"]

		# Print the result
		#print("rotate:", mesh_name)
		
	#for tileType in tilesData.keys():
	#	print(tilesData[tileType]["mesh_name"])
		
		
	return
	#set meshes,
	for x in tilesArray.size():
		for y in tilesArray[x].size():
			for z in tilesArray[x][y].size():
				var meshInstance = tilesArray[x][y][z].get_node("MeshInstance3D")
				
				var newMesh = preload("res://models/wfc/basic/mountain.obj")
				#var newMesh = preload("res://models/blahaj.obj")#temp model for debug
				
				meshInstance.mesh = newMesh
				
								

func wfc_iterate():
	
	
	##find tile with lowest entropy
	var lowest = 999999999999 # dont have support for 1 trillion tile types untill I un-hard code this...
	var lowestPos = []
	
	#loop over
	for x in tilesArray.size():
		for y in tilesArray[x].size():
			for z in tilesArray[x][y].size():
				
				var lowCheck = tilesArray[x][y][z].get_node("MeshInstance3D").possibilities.size()
				#print("low:",lowCheck)
				if lowCheck<lowest and tilesArray[x][y][z].get_node("MeshInstance3D").nodeType == null:
					lowest = lowCheck
					lowestPos = [x,y,z]
					
	
	#resolve lowest
	if lowestPos == []:
		#this means wfc is complete!
		#we can pass this out the function now
		return true
		#if its not complete we go through it again
	else:
		#get the lowest entropy tile, and collapse it
		var lowestEntropyTile = tilesArray[lowestPos[0]][lowestPos[1]][lowestPos[2]]
		var meshInstance = lowestEntropyTile.get_node("MeshInstance3D")
		
		
		
		#get total weight of all possible tiles
		var totalWeight =0
		for p in meshInstance.possibilities:
			
			#account for theme weighting
			var themeWeight = 0
			for t in themeData:	
				if meshInstance.themes.has(t):
					
					if p in themeData[t]["valid_tiles"]:
						themeWeight += meshInstance.themes[t]
					
					
			totalWeight += tilesData[p]["weight"]*themeWeight
		
		
		# get the index with respect to tile weights
		
		if totalWeight !=0:
			
			var randomIndex = randi()%int(totalWeight)
			#print (randomIndex)
			
			
			var collapsedOutcome = null# = meshInstance.possibilities[randomID]
			var currentPoss = 0
			for p in meshInstance.possibilities:
				
				var themeWeight = 0
				for t in themeData:				
					if meshInstance.themes.has(t):
						themeWeight += meshInstance.themes[t]
				
				randomIndex -= tilesData[p]["weight"]*themeWeight#TODO: multiply weights by the weight of all themes they are in
				if randomIndex < 0:
					collapsedOutcome = p
					#print (p)
					break
					
				
				
				
			if collapsedOutcome == null:
				printerr("null tile generated")
				
			
			
			
			#var collapsedOutcome = meshInstance.possibilities[randomID]
			
			meshInstance.possibilities = [collapsedOutcome]
			
				
			var newMesh = load("res://models/wfc/basic/" + tilesData[collapsedOutcome]["mesh_name"])
			meshInstance.nodeType = collapsedOutcome
		
			#print(meshInstance.nodeType, lowestPos)					
			meshInstance.mesh = newMesh
			
		else : 
			meshInstance.nodeType = "error"
			printerr("encountered an empty possibilities list, and so could not assign a mesh to a tile")
		
		##now that something is collapsed, we need to recalculate the wave function
		
		
		#propegate the wave function
		
		
		
		var stack = []
		stack.append (lowestPos)
		
		while len(stack) >0:
			var currentCoords = stack.pop_back()
			
			
			for dir in validDirs:
				var currentOff = [
					dir[0]+currentCoords[0],
					dir[1]+currentCoords[1],
					dir[2]+currentCoords[2]
					]
				#print ( currentOff )
				
				if (#check tile is in range
					currentOff[0]<0 or
					currentOff[1]<0 or
					currentOff[2]<0 or	
					currentOff[0]>bounds[0]-1 or
					currentOff[1]>bounds[1]-1 or
					currentOff[2]>bounds[2]-1 
					):
					continue
					
				#then get the tile we're working with, edit it's possible neighbours and then add it to the stack when we're done
				var currentOffTile = tilesArray[currentOff[0]][currentOff[1]][currentOff[2]] 
				var currentTile = tilesArray[currentCoords[0]][currentCoords[1]][currentCoords[2]] 
				
				##looping over the possibilities to see if they are all still valid
				
				#fist make a loop to get the valid neighbours for all possibilities of the current tile
				var possibleNeighbours = []
				
				for possi in currentTile.get_node("MeshInstance3D").possibilities:
					for newPoss in tilesData[possi]["valid_neigbours"]:
						
						
						if not(newPoss in possibleNeighbours):#make sure its not in there already; no duplicates!
							possibleNeighbours.append(newPoss)
				
				#print(possibleNeighbours)
				
				#loop proper
				var changed = false
				var changeCalibration = 0
				
				for i in range(len(currentOffTile.get_node("MeshInstance3D").possibilities)):
					if not(currentOffTile.get_node("MeshInstance3D").possibilities[i+changeCalibration] in possibleNeighbours):
						
						#print("deleted " , currentOffTile.get_node("MeshInstance3D").possibilities[i+changeCalibration])
						
						currentOffTile.get_node("MeshInstance3D").possibilities.pop_at(i+changeCalibration)
						changed = true
						changeCalibration -=1 #we need to offset the index if we are changhing the size of the array while looping inside it ¯\_(ツ)_/¯
						
						
				
				
				
				# add to the stack since it changed and needs its neigbours to be checked
				# if it didnt change, the we dont need to wory :)
				if changed:
					#print("---")
					stack.append(currentOff)
					
						
				
		
		
		
		
		
		
		
		return false
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	
	
	
	var wfc_done = false
	#while !wfc_done:
	if !wfc_done:
		wfc_done = wfc_iterate()
	
	
	if wfc_done and canDoneAlert:
		canDoneAlert = false
		print("--- Generation Complete! ---")
		print("time elapsed: ", round(time*1000.0)/1000.0 , "s")
		print("grid size:", bounds[0] ,"x",bounds[1] ,"x",bounds[2] )

