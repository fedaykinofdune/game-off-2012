define ->

    class Constants

        @tileSize: 16
        @tileCrossDistance: Math.sqrt @tileSize * @tileSize * 3
        @unitSphereRadius: 8

        @events:
            leftClick: 1
            middleClick: 2
            rightClick: 3
            leftArrow: 37
            upArrow: 38
            rightArrow: 39
            downArrow: 40

        # These constants are used in development and debugging. They will go
        # away in the final release.
        @debug:
            unitColor: 0x7fdc50
            activeUnitColor: 0xc9ff5b
