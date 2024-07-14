// https://github.com/compuphase/pawn/tree/main/examples/hanoi.p

/* The Towers of Hanoi, a game solved through recursion */

@start()
    {
    print "How many disks: "
    var disks = getvalue()
    move 1, 3, 2, disks
    }

move(from, to, spare, numdisks)
    {
    if (numdisks > 1)
        move from, spare, to, numdisks-1
    printf "Move disk from pillar %d to pillar %d\n", from, to
    if (numdisks > 1)
        move spare, to, from, numdisks-1
    }
