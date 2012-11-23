define ->

    class Constants

        @tileSize: 16
        @tileCrossDistance: Math.sqrt @tileSize * @tileSize * 3
        @unitSphereRadius: 8

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
            unitColor: 0x7fdc50
            activeUnitColor: 0xc9ff5b
