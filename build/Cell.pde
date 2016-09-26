class Cell{
	Cell parent;
	int displayMode;
	//Cell[] children; lets see
	PVector pos, vel, acc;
	float size, displaySize;
	int fertilityLeft = maxFertility;

	Cell(){
		pos = new PVector();
		vel = new PVector();
		acc = new PVector();

		size = startSize;//width < height ? width*0.06 : height*0.06;
		this.displayMode = displayMode;
		this.displaySize = 1;
	}

	Cell(PVector pos, float size){
		this.pos = pos;

		this.size = size;
		this.displaySize = 1;

		this.displayMode = displayMode;

	}

	// Cell(float x, float y){
	// 	pos = new PVector(x,y);

	// 	size = width < height ? width*0.01 : height*0.01;
	// }

	void display(){
		switch (this.displayMode) {
			case 0 : //circles
				noStroke();
				if(parentCells.contains(this)){
					fill(255,0,0);
				} else {
					fill(0);
				} 
				ellipse(pos.x, pos.y, size*displaySize, size*displaySize);

			break;	

			case 1 :
				strokeWeight(displaySize*size);
				if(parentCells.contains(this)){
					stroke(255,0,0);
				} else {
					stroke(0);
				} 
				line(parent.pos.x,parent.pos.y,pos.x,pos.y);	
			break;	
		}		
	}

	void update() {
	   vel.add(acc);
	   pos.add(vel);
	   acc.mult(0);
	}

}