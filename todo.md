# Todo

2. memory bloat
3. network resilience
4. testing
5. icon
6. Screenshots / app store description


drawRect Constraints

let origin_x = lowerOf(first.x, second.x) - lineFormatSettings.width
            let origin_y = lowerOf(first.y, second.y) - lineFormatSettings.width
            let width = (higherOf(first.x, second.x) - lowerOf(first.x, second.x)) + (2 * lineFormatSettings.width)
            let height = (higherOf(first.y, second.y) - lowerOf(first.y, second.y)) + (2 * lineFormatSettings.width)

            self.setNeedsDisplay(CGRect(x: origin_x,
                                        y: origin_y,
                                        width: width,
                                        height: height))





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
