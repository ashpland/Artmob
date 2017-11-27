# Todo

1. clean up rebuilt instruction manager
2. scroll view
3. network resilience
4. testing

### Instruction Manager Cleanup
- add last instruction ping
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
