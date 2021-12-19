doubledoors_world:
    type: world
    debug: false
    events:
        # Use monitor to allow the event to be cancelled by any other scripts or plugins
        # But use 'on' to make the door move as immediately as possible
        on player right clicks *_door bukkit_priority:monitor:
        # Iron doors aren't opened on click
        - if <context.location.material.name> == iron_door:
            - stop
        - define face <context.location.block_facing>
        # A door faces outward, rotate the outward face opposite the direction of the hinge to get the other door
        - if <context.location.material.hinge> == left:
            # Note: pi/2 is radian equivalent of 90 degrees.
            - define face <[face].rotate_around_y[-<util.pi.div[2]>]>
        - else:
            - define face <[face].rotate_around_y[<util.pi.div[2]>]>
        - define door2 <context.location.add[<[face]>]>
        # Check that the double door *exists*
        - if <[door2].material.name> == <context.location.material.name>:
            - switch <[door2]>