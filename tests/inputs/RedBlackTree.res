// a portion of https://github.com/github/linguist/raw/master/samples/ReScript/RedBlackTree.res

/*
Credit to Wikipedia's article on [Red-black
tree](http://en.wikipedia.org/wiki/Red–black_tree)

**Note:** doesn't handle duplicate entries. This is by design.

## Overview example:

```
var rbt = new RedBlackTree([7, 5, 1, 8])
rbt.add(2) // => 2
rbt.add(10) // => 10
rbt.has(5) // => true
rbt.remove(8) // => 8
```

## Properties:

- size: The total number of items.
*/

type nodeColor =
  | Red
  | Black

/*
Property of a red-black tree, taken from Wikipedia:
1. A node is either red or black.
2. Root is black.
3. Leaves are all null and considered black.
4. Both children of a red node are black.
5. Every path from a node to any of its descendent leaves contains the same
number of black nodes.
*/

type rec node<'value> = {
  mutable left: option<node<'value>>,
  mutable right: option<node<'value>>,
  mutable parent: option<node<'value>>,
  mutable sum: float,
  mutable color : nodeColor,
  mutable height: float,
  mutable value: 'value,
}

type t<'value> = {
  mutable size: int,
  mutable root: option<node<'value>>,
  compare: (. 'value, 'value) => int,
}

let createNode = (~color, ~value, ~height) =>
  {left:None, right:None, parent:None, sum:0., height, value, color}

external castNotOption: option<'a> => 'a = "%identity"

let updateSum = (node) => {
  let leftSum = switch node.left {
  | None => 0.
  | Some(left) => left.sum
  }
  let rightSum = switch node.right {
  | None => 0.
  | Some(right) => right.sum
  }
  node.sum = leftSum +. rightSum +. node.height
}

/* Update the sum for the node and parents recursively. */
let rec updateSumRecursive = (rbt, node) => {
  updateSum(node)
  switch node.parent {
  | None => ()
  | Some(parent) =>
    rbt->updateSumRecursive(parent)
  }
}

let grandParentOf = node => {
  switch node.parent {
  | None => None
  | Some(ref_) => ref_.parent
  }
}

let isLeft = node => {
  switch node.parent {
  | None => false
  | Some(parent) => Some(node) === parent.left
  }
}

let leftOrRightSet = (~node, x, value) => {
  isLeft(node) ? x.left=value : x.right=value
}

let siblingOf = node => {
  if isLeft(node) {
    castNotOption(node.parent).right
  } else {
    castNotOption(node.parent).left
  }
}

let uncleOf = node => {
  switch grandParentOf(node) {
  | None => None
  | Some(grandParentOfNode) =>
    if isLeft(castNotOption(node.parent)) {
      grandParentOfNode.right
    } else {
      grandParentOfNode.left
    }
  }
}

let rec findNode = (rbt, node, value) => {
  switch node {
  | None => None
  | Some(node) =>
    let cmp = rbt.compare(. value, node.value)
    if cmp === 0 {
      Some(node)
    } else if cmp < 0 {
      findNode(rbt, node.left, value)
    } else {
      findNode(rbt, node.right, value)
    }
  }
}

let has = (rbt, value) => findNode(rbt, rbt.root, value) !== None

let rec peekMinNode = node => switch node {
  | None => None
  | Some(node) =>
    node.left === None ? Some(node) : node.left->peekMinNode
}

let rec peekMaxNode = node => switch node {
  | None => None
  | Some(node) =>
    node.right === None ? Some(node) : node.right->peekMaxNode
}

let rotateLeft = (rbt, node) => {
  let parent = node.parent
  let right = node.right
  switch parent {
    | Some(parent) =>
      parent->leftOrRightSet(~node, right)
    | None =>
      rbt.root = right
  }
  node.parent = right
  let right = right->castNotOption // precondition
  let rightLeft = right.left
  node.right = rightLeft
  switch rightLeft {
    | Some(rightLeft) =>
      rightLeft.parent = Some(node)
    | None =>
      ()
  }
  right.parent = parent
  right.left = Some(node)
  updateSum(node)
  updateSum(right)
}

// After adding the node, we need to operate on it to preserve the tree's
// properties by filtering it through a series of cases. It'd be easier if
// there's tail recursion in JavaScript, as some cases fix the node but
// restart the cases on the node's ancestor. We'll have to use loops for now.

let rec _addLoop = (rbt, currentNode) => {
  // Case 1: node is root. Violates 1. Paint it black.
  if Some(currentNode) === rbt.root {
    currentNode.color = Black
  }

  // Case 2: parent black. No properties violated. After that, parent is sure
  // to be red.
  else if (currentNode.parent->castNotOption).color === Black {
    ()
  }

  // Case 3: if node's parent and uncle are red, they are painted black.
  // Their parent (node's grandparent) should be painted red, and the
  // grandparent red. Note that node certainly has a grandparent, since at
  // this point, its parent's red, which can't be the root.

  // After the painting, the grandparent might violate 2 or 4.
  else if({
      let uncle = uncleOf(currentNode)
      uncle !== None && (uncle->castNotOption).color === Red
    }) {
    (currentNode.parent->castNotOption).color = Black
    (uncleOf(currentNode)->castNotOption).color = Black
    (grandParentOf(currentNode)->castNotOption).color = Red
    _addLoop(rbt, grandParentOf(currentNode)->castNotOption)
  }
  else {
    // At this point, uncle is either black or doesn't exist.

    // Case 4: parent red, uncle black, node is right child, parent is left
    // child. Do a left rotation. Then, former parent passes through case 5.
    let currentNode =
      if !isLeft(currentNode) && isLeft(currentNode.parent->castNotOption) {
        rotateLeft(rbt, currentNode.parent->castNotOption)
        currentNode.left->castNotOption
      } else if isLeft(currentNode) && !isLeft(currentNode.parent->castNotOption) {
        rotateRight(rbt, currentNode.parent->castNotOption)
        currentNode.right->castNotOption
      } else {
        currentNode
      }

    // Case 5: parent red, uncle black, node is left child, parent is left
    // child. Right rotation. Switch parent and grandparent's color.
    (currentNode.parent->castNotOption).color = Black
    (grandParentOf(currentNode)->castNotOption).color = Red
    if isLeft(currentNode) {
      rotateRight(rbt, grandParentOf(currentNode)->castNotOption)
    } else {
      rotateLeft(rbt, grandParentOf(currentNode)->castNotOption)
    }
  }
}
