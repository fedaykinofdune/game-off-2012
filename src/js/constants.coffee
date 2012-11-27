define ->

    # TODO: This file should only have global constants used across several
    # classes. A lot of these should be moved into a class. For example mouse
    # and keys constants can go to the Game class.
    class Constants

        @imageDir: 'src/image'

        @tileSize: 16
        @tileCrossDistance: Math.sqrt @tileSize * @tileSize * 3

        @mouse:
            leftClick:   1
            middleClick: 2
            rightClick:  3

        @keys:
            upArrow:     38
            rightArrow:  39
            downArrow:   40
            leftArrow:   37

        # These constants are used in development and debugging. They will go
        # away in the final release.
        @debug:
            unitBodyColor:   0x7fdc50
            unitHeadColor:   0xff1100

            unitBodyRadius: 8
            unitHeadRadius: 2

