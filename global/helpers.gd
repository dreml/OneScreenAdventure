class_name Helpers

static func merge(dictionaries: Array[Dictionary]):
	var result := {}
	
	for dict in dictionaries:
		for key in dict:
			result[key] = dict[key]
	
	return result
