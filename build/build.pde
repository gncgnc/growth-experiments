ArrayList<Cell> cells; 
ArrayList<Cell> parentCells;

boolean recording = false;

int wait = 7;
int waitCounter = wait;
int cycles = 3;
int cycleCounter = cycles;

boolean hasMargin = false;
int marginType = 1; //0: square; 1: circle
float marginRatio = 0.2;

float branchProb = 0.6; //good from .3
float shrinkRate = 0.90; // affects sim heavily, .99 to .93 interesting, depending on initial size
int tries = 10;// how many times a cell tries to give offspring. (checks for collisions)
float startSize = 30; // this with shrinkRate control length of branches, growth.
float endSize = 2;
int maxFertility = 2; // numFrames to keep fertility (red)

//controls distance b/w cells: 1 for tangent cells. controls character: diffuse, tendrilly, root-like.
//varying this during stages of growth gives compelling results. Can be based on food, population density...
float parentChildOffsetMultiplier = 1; 

int displayMode = 1;//0; //circles

void setup(){
	size(500,500);
	translate(width/2, height/2);
	ellipseMode(CENTER);

	cells = new ArrayList<Cell>(); 
	parentCells = new ArrayList<Cell>();

	initGrowth();
}

void draw(){

	background(255);
	translate(width/2, height/2);

	parentChildOffsetMultiplier = .95;//map(mouseX,0,width,0.5,1.5);
	float displaySize = .66; //map(mouseY, 0, height, 1.7, 0.3);

	branchProb = map(cells.get(cells.size()-1).size, startSize, endSize, .3, .6);//

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

	//when done growing, wait for some frames and regroup
	if(parentCells.size() == 0){
		if(waitCounter > 0){
			waitCounter--;
		} else {
			regroup();
			if(isRegrouped()){
				if(recording) cycleCounter--;

				resetGrowth();
				waitCounter = wait;
			}
		}
	}

	if(recording){
		saveFrame("frames/grw-####.png");

		if(cycleCounter == 0) {
			recording = false;
			cycleCounter = cycles;
		}
	}
}

void keyPressed() {
 	switch (key) {
 		case 's' :
 			save("../captures/grw-"
 				+year()
 				+nf(month(),2)
 				+nf(day(),2)+"_"
 				+nf(hour(),2)
 				+nf(minute(),2)	
 				+nf(second(),2)+".png");
 		break;	

 		case ' ' : { //reset
 			resetGrowth();
	 	} break;	

	 	case 'f' :
	 		recording = !recording;

	 		resetGrowth();
	 	break;	

	 	case 'q':
	 		exit();
	 	break;

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

 void initGrowth(){
 	Cell c = new Cell();
	c.displayMode = displayMode;
	cells.add(c);
	parentCells.add(c);
	c.parent = new Cell();
}

void resetGrowth(){
	cells.clear();
	parentCells.clear();

	initGrowth();
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
	boolean result = false;
	if(hasMargin){
		switch (marginType) {
			case 0 :
				result =  pos.x < -width / 2  * (1 - marginRatio) || 
				pos.x > width / 2   * (1 - marginRatio) || 
				pos.y < -height / 2 * (1 - marginRatio) || 
				pos.y > height / 2  * (1 - marginRatio);
			break;	

			case 1 :
				result = pos.mag() > width/2 * (1 - marginRatio);//sq(pos.x) + sq(pos.y) < sq(width / 2);
			break;	
			
		}
		
	} else {
		result =  pos.x < -width  / 2 || 
				pos.x > width  /  2 || 
				pos.y < -height / 2 || 
				pos.y > height /  2 ;
	}

	return result;
}

void regroup(){
	for(Cell c: cells){
		c.pos.lerp(new PVector(0,0), 0.13);
	}
}

boolean isRegrouped(){
	for(Cell c: cells){
		if(sq(c.pos.x) + sq(c.pos.y) > width*0.03){
			return false;
		}
	}
	return true;
} 