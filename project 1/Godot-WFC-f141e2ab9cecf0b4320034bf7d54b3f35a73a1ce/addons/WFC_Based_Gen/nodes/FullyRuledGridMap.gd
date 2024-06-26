tool
extends GridMap
class_name FullyRuledGridMap

##
## Fully Ruled GridMap Generator script
##
## @desc:
##     This Generator uses Data set created using WFC Rule Creator panel.
##     This Generator creates Mesh Library during generation.
##     
##     Generation is WFC Ruled -> adds all xz positions to list then selects
##     randomly tile to set that has lowest possible number of solutions.
##     
##     If allow_above_start_height is true generator will add tile above after
##     item in cell in setted
##     
##     If allow_under_start_height is true generator will add tile above after
##     item in cell in setted
##     
##     Use regen() function to completly regenerate map with recreating MeshLib.
##     
##     Set regen_lock variable to disallow run of regen() function.
##     (It is binded to press_to_regen button)
##     
##     Use generate() function to generate new map.
##     
##     Use save_data() function to retrieve data of current cell placement.
##     Use load_data(data) function to load data of saved cell placement.
##     

export(String) var TilesDataPath
export(int) var map_size = 10
export(int) var map_start_height = 0
export(int) var map_max_height = 3
export(bool) var allow_above_start_height = true
export(bool) var allow_under_start_height = false
export(bool) var regen_lock = true
export(bool) var press_to_regen setget regen


var tiles_list := []
var tiles_data := {}

func save_data():
	var data = {}
	var used = get_used_cells()
	var cell_data : Array = []
	for i in range(used.size()):
		var cell : Vector3 = used[i]
		cell_data.append({"pos":cell,"id":get_cell_item(cell.x,cell.y,cell.z),"orientation":get_cell_item_orientation(cell.x,cell.y,cell.z)})
	data["cell_data"]=cell_data
	return data

func load_data(data):
	clear()
	clear_baked_meshes()
	var used = get_used_cells()
	var cell_data : Array = data["cell_data"]
	for i in range(cell_data.size()):
		var cell_dt : Dictionary = used[i]
		var pos = cell_dt["pos"]
		var id = cell_dt["id"]
		var orientation = cell_dt["orientation"]
		set_cell_item(pos.x,pos.y,pos.z,id,orientation)

func regen(value=true):
	if open_file(TilesDataPath) and !regen_lock:
		self.clear()
		var MeshLib := MeshLibrary.new()
		for i in range(tiles_list.size()):
			MeshLib.create_item(i)
			MeshLib.set_item_name(i,tiles_list[i])
			if tiles_data[tiles_list[i]]["mesh_path"].length()>0:
				var mesh = load(tiles_data[tiles_list[i]]["mesh_path"])
				if mesh!=null:
					MeshLib.set_item_mesh(i,mesh)
					MeshLib.set_item_shapes(i,[mesh.create_trimesh_shape()])
		mesh_library=MeshLib
		generate()

var tiles := []
func generate():
	tiles.clear()
	for x in range(map_size):
		for z in range(map_size):
			tiles.append(Vector3(x,map_start_height,z))
	
	
	while(tiles.size()>0):
		var tile : Vector3 = get_lowest_list_tile_and_remove()
		var x = tile.x
		var y = tile.y
		var z = tile.z
		var list := get_cell_list(x,y,z)
		
		
		randomize()
		#print(str(list)+" "+str(tile))
		if list.size()>0:
			var cell_name:String = list[rand_range(0,list.size())]
			var id = get_cell_id(cell_name)
			if id>=0:
				set_cell_item(x,y,z,id,tiles_data[tiles_list[id]]["orientation"])
		
		
		if abs(y)<map_max_height:
			var y_p = get_cell_item(x,y+1,z)
			if allow_above_start_height and y_p==-1 and !(y<map_start_height):
				tiles.append(Vector3(x,y+1,z))
			
			var y_m = get_cell_item(x,y-1,z)
			if allow_under_start_height and y_m==-1 and !(y>map_start_height):
				tiles.append(Vector3(x,y-1,z))

func get_lowest_list_tile_and_remove() -> Vector3:
	var tile_counts := {}
	
	for i in range(tiles.size()):
		var tl : Vector3 = tiles[i]
		var list := get_cell_list(tl.x,tl.y,tl.z)
		var nm : String = str(list.size())
		
		if tile_counts.has(nm):
			tile_counts[nm].append(tl)
		else:
			tile_counts[nm]=[tl]
	
	var lowest_n : int = 999999999
	for key in tile_counts.keys():
		if int(key)<lowest_n:
			lowest_n=int(key)
	
	randomize()
	var result_list = tile_counts[str(lowest_n)]
	var result_tile : Vector3 = result_list[rand_range(0,result_list.size())]
	
	for i in range(tiles.size()):
		if tiles[i]==result_tile:
			tiles.remove(i)
			break
	
	#tiles.remove(tl_id)
	return result_tile

func get_cell_list(x,y,z) -> Array:
	var x_p = get_cell_item(x+1,y,z)
	var x_m = get_cell_item(x-1,y,z)
	var y_p = get_cell_item(x,y+1,z)
	var y_m = get_cell_item(x,y-1,z)
	var z_p = get_cell_item(x,y,z+1)
	var z_m = get_cell_item(x,y,z-1)
	var list := []
	if (x_m>=0 or y_m>=0 or z_m>=0 or x_p>=0 or y_p>=0 or z_p>=0) or y==map_start_height:
		for key in tiles_data.keys():
			list.append(key)
	list=check_list(list.duplicate(),z_m,"z_plus")
	list=check_list(list.duplicate(),z_p,"z_minus")
	
	list=check_list(list.duplicate(),y_m,"y_plus")
	list=check_list(list.duplicate(),y_p,"y_minus")
	
	list=check_list(list.duplicate(),x_m,"x_plus")
	list=check_list(list.duplicate(),x_p,"x_minus")
	
	if list.size()==0 and y_p==x_p and x_p==z_p and z_p==y_m and y_m==x_m and x_m==z_m and z_m==-1 and y==map_start_height:
		for key in tiles_data.keys():
			list.append(key)
	return list

func check_list(list : Array,n : int,side : String) -> Array:
	var n_list := list.duplicate()
	if n>=0:
		if list.size()>0:
			n_list=compare(tiles_data[tiles_list[n]][side].duplicate(),list.duplicate())
	return n_list

func get_cell_id(cell_name) -> int:
	var id := -1
	for i in range(tiles_list.size()):
		if tiles_list[i]==cell_name:
			id=i
			break
	return id

func compare(array_a:Array,array_b:Array) -> Array:
	var array_c := []
	for i in range(array_a.size()):
		var bl : String = array_a[i]
		for j in range(array_b.size()):
			if array_b[j]==bl:
				array_c.append(bl)
	return array_c

func open_file(path) -> bool:
	var ret := false
	if path.ends_with(".wgts"):
		var file := File.new()
		file.open(path,File.READ)
		while file.get_position() < file.get_len():
			var data = parse_json(file.get_line())
			if data.has("tiles_indexes") and data.has("tiles_data"):
				tiles_list=data["tiles_indexes"].duplicate()
				tiles_data=data["tiles_data"].duplicate()
				ret=true
				break
		file.close()
	return ret
