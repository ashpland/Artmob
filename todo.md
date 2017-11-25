# Todo

- write tests to try inserting instructions before first instruction
- test insert at 0 
- test insert for correct order
- print index and store.count
- test insert function in playground

## Connecting later
- add function to zero index sync case to batch updates so the screen draws gracefully
- add last instruction ping so refresh on connect happens without needing to draw

## Multipeer Resiliency
- something for when a peer disconnects?
- does sending a message to a peer that doesn't exist anymore cause problems?


## Multipeer error
[ERROR] ICEStopConnectivityCheck:2688 ICEStopConnectivityCheck() found no ICE check with call id (383054229)


## Concurrency
Image display pushes back to main thread
Line drawing pushed to serial queue

make Instruction manager writes threadsafe
make line drawing serial?


