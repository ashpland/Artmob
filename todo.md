# Todo

1. multitouch conflict
2. memory bloat
    - Backsync redraw
3. network resilience
4. testing
5. icon
6. Screenshots / app store description


- add first connect ping

- add buffer for recent instructions
    - if array > 0 then take most recent one
    - set to self.recent
    - broadcast
    - otherwist send self.recent
- fix tests
    - write new tests?


- write tests to try inserting instructions before first instruction
- test insert at 0 
- test insert for correct order
- print index and store.count
- test insert function in playground


## Multipeer Resiliency
- something for when a peer disconnects?
- does sending a message to a peer that doesn't exist anymore cause problems?
