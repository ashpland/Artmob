# Demo Presentation

## Key Points
- Offline / local
- Decentralized
	- Eventual consistency
	- Conflict-free replicated data type
	- Syncing assuming an imperfect network
		- added benefit of joining later
- UI designed to get out of the way
	- focused more on simplicity, stability, smoothness instead of adding more features
- Can draw lines immediately
	- then connect to others in a couple taps
- Emotional start:
	- Sidewalk chalk with brothers and friends
		- Games, mazes, whatever your imagination desires
		- Don't even have to fight over the red chalk
- Testing 

Drawing us together
Social creative canvas

Synergy of in-person and tech connectivity
Best of both worlds

Team building exercise
Draw with your kids

Creative free play
Imagination
Social
Collaborative 

No undo. You gotta commit.
Frees you from uncertainty 

 Eventual consistency - different from Skype / realtime
		- Conflict-free replicated data type

- undo lets you second guess




## Outline

*Start app on blank screen*
### Intro
- Aaron - local coop, favourite colour
- Andrew - drawing together, community building, favourite colour
- Artmob is an app for drawing with your friends

*Andrew starts drawing*
### 1. Focus on ease and simplicity for the user - Aaron
Challenge: made it easy to use and simple
How:
	- can draw immediately, quickly change colours, zoom and scroll, connect in a couple taps
	- photoshop is overwhelming
Learned:
- as developers we intentionally gave the user limited options to keep it simple

*Connect to peers, draw stuff*
### 2. Behind the scenes - Andrew
Challenge: maintain responsive UI
How:
	- smooth drawing with Core Animation
	- syncing, graphics, network constraints
Learned: 
	- calibrating took time, not necessarily an object answer for tradeoffs


### 3. Decentralized - Aaron

Challenge: building around device to device
	- no need to manage who "owns" the drawing
	- join and leave
	- offline

How:
	- MultipeerConnectivity framework
	- Connect directly using bluetooth and wifi
	- designing for the imperfection of networking

### Testing - Andrew 
	- testing network
		- unit tests worked for one device stuff, designing code to be testable independent of network component
		- multipeer much more manual


### 4. Planning - Andrew
How: 
	- Planning!
		- Data structure
		- Architecture
		- UI Design

Learning:
	- prioritizing
	- Started with most important parts, design for future
		- test drawing the whole time
		- Eg colour picking. Not implemented till later, but already set up in data structure
		- Text / emoji already roughed in

*Save image*
### Conclusion - Both
- original intention was to make whiteboard app
- surprised by how Fun, connecting in person
- A lot of us live in busy, structured world
- go download our app, grab your friends 
- Creative, imaginative, unstructured play