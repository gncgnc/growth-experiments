ArrayList<Cell> cells; 
ArrayList<Cell> parentCells;
float branchProb = 0.1; //good from .3
float shrinkRate = 0.99; // affects sim heavily, .99 to .93 interesting, depending on initial size
int tries = 10;// how many times a cell tries to give offspring. (checks for collisions)
float startSize = 20; // this with shrinkRate control length of brances, growth.
float endSize = 4;
int maxFertility = 5; // numFrames to keep fertility (red)

//controls distance b/w cells: 1 for tangent cells. controls character: diffuse, tendrilly, root-like.
//varying this during stages of growth gives compelling results. Can be based on food, population density...
float parentChildOffsetMultiplier = 1; 

int displayMode = 0; //circles

void setup(){
	size(900,700);
	translate(width/2, height/2);
	ellipseMode(CENTER);
	noStroke();

	cells = new ArrayList<Cell>(); 
	parentCells = new ArrayList<Cell>();

	Cell c = new Cell();
	cells.add(c);
	parentCells.add(c);
	c.parent = new Cell();

	//frameRate(1);
}

void draw(){
	// if(frameCount%1 == 0){
	// 	println("cells.size(): "+cells.size());
	// 	println("parentCells.size(): "+parentCells.size());
	// }
	background(255);
	translate(width/2, height/2);

	parentChildOffsetMultiplier = map(mouseX,0,width,0.5,1.5);
	float displaySize = map(mouseY, 0, height, 1.7, 0.3);

	if(displayMode==0){
		noStroke();
	}

	for(Cell c: cells){
		c.display();
		c.displaySize = displaySize;
	}

	for(int i=parentCells.size()-1; i>=0; i--){
		Cell parent = parentCells.get(i);
		if(parent.size < endSize){
			parentCells.remove(parent);
			continue;
		} 

		//try to find non-overlapping position for new cell
		for(int k=0; k<tries; k++){
			float newSize = parent.size * shrinkRate;
			PVector offset = PVector.random2D();
			offset.mult((parent.size + newSize) * 0.5 * parentChildOffsetMultiplier);
			PVector newPos = PVector.add(parent.pos, offset);

			if(isOutside(newPos)) continue;

			//check whether current position is viable with existing cell(not overlapping or outside) 
			boolean overlapping = false;
			for(int j=0; j<cells.size(); j++){
				Cell other = cells.get(j);

				if((isOverlapping(newPos, newSize, other) && other != parent) || isOutside(newPos)){
					overlapping = true;
					break;
				}
			}

			if(!overlapping){
				//add newborn cell
				Cell newCell = new Cell(PVector.add(parent.pos, offset), newSize);
				newCell.parent = parent;
				newCell.displayMode = displayMode;
				cells.add(newCell);

				if(random(1) > branchProb) {
					parentCells.remove(parent);
				}
				parentCells.add(newCell);
				break;
			}
		}
		//give it time to branch, remove from parents once done
		if(parent.fertilityLeft-- < 0){
			parentCells.remove(parent);
		}
	}

	text("displayMode: "+displayMode, -width/2,height/2);

}

boolean isOverlapping(PVector newPos, float newSize, Cell other){
	float dx = newPos.x - other.pos.x;
	float dy = newPos.y - other.pos.y;
	float minDist = (newSize + other.size) / 2;
	if(dx*dx + dy*dy <  minDist*minDist){
		return true;
	}
	return false;
}

boolean isOutside(PVector pos) {
	return  pos.x<-width/2 || 
			pos.x>width/2 || 
			pos.y<-height/2 || 
			pos.y>height/2 ;
}

void keyPressed() {
 	switch (key) {
 		case 's' :
 			//saveFrame("../captures/growth-"+year()+month()+day()+hour()+second());
 			save("../captures/grw-"
 				+year()
 				+nf(month(),2)
 				+nf(day(),2)+"_"
 				+nf(hour(),2)
 				+nf(minute(),2)	
 				+nf(second(),2)+".png");
 		break;	

 		case ' ' : { //reset
 			cells.clear();
			parentCells.clear();

			Cell c = new Cell();
			c.displayMode = displayMode;
			cells.add(c);
			parentCells.add(c);
			c.parent = new Cell();
	 	} break;	

	 	case '0' :{ //circles
	 		noStroke();
	 		displayMode = 0;
	 		for(Cell c: cells){
				c.displayMode = displayMode;
			}
			println("displayMode: "+displayMode);
	 	} break;	

	 	case '1' : {
	 		displayMode = 1;
	 		for(Cell c: cells){
				c.displayMode = displayMode;
			}
			println("displayMode: "+displayMode);
	 	} break;	
 	}
 } 