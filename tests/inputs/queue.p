// https://github.com/compuphase/pawn/tree/main/examples/queue.p
/* Priority queue (for simple text strings) */
#include <string>

@start()
    {
    var msg[.text{40}, .priority]

    /* insert a few items (read from console input) */
    printf "Please insert a few messages and their priorities; " ...
           "end with an empty string\n"
    for ( ;; )
        {
        printf "Message:  "
        getstring msg.text, .pack = true
        if (strlen(msg.text) == 0)
            break
        printf "Priority: "
        msg.priority = getvalue()
        if (!insert(msg))
            {
            printf "Queue is full, cannot insert more items\n"
            break
            }
        }

    /* now print the messages extracted from the queue */
    printf "\nContents of the queue:\n"
    while (extract(msg))
        printf "[%d] %s\n", msg.priority, msg.text
    }

const queuesize = 10
var queue[queuesize][.text{40}, .priority]
var queueitems = 0

insert(const item[.text{40}, .priority])
    {
    /* check if the queue can hold one more message */
    if (queueitems == queuesize)
        return false            /* queue is full */

    /* find the position to insert it to */
    var pos = queueitems        /* start at the bottom */
    while (pos > 0 && item.priority > queue[pos-1].priority)
        --pos                   /* higher priority: move up a slot */

    /* make place for the item at the insertion spot */
    for (var i = queueitems; i > pos; --i)
        queue[i] = queue[i-1]

    /* add the message to the correct slot */
    queue[pos] = item
    queueitems++

    return true
    }

extract(item[.text{40}, .priority])
    {
    /* check whether the queue has one more message */
    if (queueitems == 0)
        return false
        /* queue is empty */

    /* copy the topmost item */
    item = queue[0]
    --queueitems

    /* move the queue one position up */
    for (var i = 0; i < queueitems; ++i)
        queue[i] = queue[i+1]

    return true
    }
