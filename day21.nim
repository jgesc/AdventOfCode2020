import algorithm
import sequtils
import sets
import strscans
import strutils
import sugar
import tables

# Define types
type
  Ingredient = string
  Allergen = string
  Food = object
    ingredients: HashSet[Ingredient]
    allergens: HashSet[Allergen]

# Parse input
proc parseFoodsFromFile(filename: string): seq[Food] =
  # Food list
  var foods: seq[Food]
  # Iterate file lines
  for line in lines filename:
    # Line substrings
    var ingredientsSubstring, allergensSubstring: string
    discard scanf(line, "$+ (contains $+)",
      ingredientsSubstring, allergensSubstring)
    # Store food entry
    foods.add(
      Food(
        ingredients: ingredientsSubstring.split(" ").toHashSet,
        allergens: allergensSubstring.split(", ").toHashSet
      )
    )

  foods

# Read input
let inputFile = "resources/day21_input.txt"
let foods = parseFoodsFromFile(inputFile)

# Group allergens
let allergens = collect(initHashSet):
  for food in foods:
    for allergen in food.allergens:
      {allergen}

# Group ingredients
let ingredients = collect(initHashSet):
  for food in foods:
    for ingredient in food.ingredients:
      {ingredient}

# Intersect ingredients and allergens
var ingredientsAllergenIntersection = collect(initTable(allergens.len)):
  for allergen in allergens:
    {allergen:
      foods
        .filterIt(
          it.allergens.contains(allergen))
        .foldl(
          a * b.ingredients, ingredients)
    }

# Solve from trivial constraints
var allergenIngredient = initTable[Allergen, Ingredient]()
while ingredientsAllergenIntersection.len > 0:
  for allergen, ingredients in mpairs ingredientsAllergenIntersection:
    if ingredients.len == 1:
      let ingredient = ingredients.pop()
      allergenIngredient[allergen] = ingredient
      ingredientsAllergenIntersection.del(allergen)
      for entry in ingredientsAllergenIntersection.mvalues:
        entry.excl(ingredient)
      break

# Create set of ingredients with allergens
let ingredientsWithAllergens = collect(initHashSet):
  for ingredient in allergenIngredient.values:
    {ingredient}

# Count times ingredients without allergens appear
let ingredientCount =
  foods
    .mapIt(it.ingredients - ingredientsWithAllergens)
    .foldl(a + b.len, 0)

# Print results
echo "--- Part 1 Report ---"
echo "Ingredients without allergen = " & $ingredientCount



## Part 2



let canonical = toSeq(allergenIngredient.pairs).sorted.mapIt(it[1]).join(",")
echo "--- Part 2 Report ---"
echo "Canonical dangerous ingredients = " & canonical
