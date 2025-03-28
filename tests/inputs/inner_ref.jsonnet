// https://jsonnet.org/learning/tutorial.html
{
  Martini: {
    local drink = self,
    ingredients: [
      { kind: "Farmer's Gin", qty: 1 },
      {
        kind: 'Dry White Vermouth',
        qty: drink.ingredients[0].qty,
        /* note ability to add
           trailing commas */
      },
    ],
    garnish: 'Olive',
    served: 'Straight Up',
            # The `self` keyword refers to the current
            # object, which is the Martini in this case.
  },
}
