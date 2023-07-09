extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$LabelCrawl.hide()
	$LabelBuild.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for child in get_parent().get_children():
		if child.name.contains("CrawlingState"):
			$LabelCrawl.show()
		if child.name.contains("BuildingState"):
			$LabelBuild.show()
			
