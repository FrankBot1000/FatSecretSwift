//
//  File.swift
//  
//
//  Created by Super Grover on 2024-11-25.
//

import Foundation



struct kFSPMockData {
    
    /// For add test Recipe Favorite via the Demo Mode "Add Test Foods" UISwitch button:
    static let fspRecipeFavorites: [FSPSingleRecipe] = [
        FSPSingleRecipe(cooking_time_min: "5",
                        directions: Directions(direction: [
                            Direction(direction_description: "Spread tablespoon of peanut butter onto the middle of tortilla.",
                                      direction_number: "1"),
                            Direction(direction_description: "Put about a third of a cup of the apples in the middle of the tortilla. (Add cinnamon and sugar to taste if you so choose.)",
                                      direction_number: "2"),
                            Direction(direction_description: "Fold the tortilla in and around the apples. Place in the oven if you want to eat it warm, or eat as is.",
                                      direction_number: "3"),
                            Direction(direction_description: "Note: can be eaten plain, topped with sugar and fruit, or with sugared cream cheese (use reduced fat cream cheese and sugar to taste).",
                                      direction_number: "4"),
                        ]),
                        ingredients: Ingredients(ingredient: [
                            Ingredient(food_id: "25054",
                                       food_name: "Organic Peanut Butter",
                                       ingredient_description: "2 tbsp peanut butter",
                                       ingredient_url: URL(string:"https://www.fatsecret.com/calories-nutrition/smuckers/organic-peanut-butter?portionid=0&portionamount=0.500")!,
                                       measurement_description: "serving",
                                       number_of_units: "0.500",
                                       serving_id: "0"),
                            Ingredient(food_id: "88613",
                                       food_name: "Life Balance Whole Wheat Tortillas Plus! (Medium)",
                                       ingredient_description: "1 whole wheat tortilla",
                                       ingredient_url:URL(string: "https://www.fatsecret.com/calories-nutrition/mission/life-balance-whole-wheat-tortillas-plus-(medium)?portionid=0&portionamount=1.000")!,
                                       measurement_description: "serving",
                                       number_of_units: "1.000",
                                       serving_id: "0"),
                            Ingredient(food_id: "75716",
                                       food_name: "Fried Apples",
                                       ingredient_description: "1/2 cup fried apples",
                                       ingredient_url: URL(string: "https://www.fatsecret.com/calories-nutrition/lucks/fried-apples?portionid=0&portionamount=1.000")!,
                                       measurement_description: "serving",
                                       number_of_units: "1.000",
                                       serving_id: "0")
                        ]),
                        number_of_servings: "1",
                        preparation_time_min: "5",
                        rating: "3",
                        recipe_categories: RecipeCategories(recipe_category: [
                            RecipeCategory(recipe_category_name: "Dessert",
                                           recipe_category_url: URL(string:"https://www.fatsecret.com/recipes/collections/meal/dessert/Default.aspx")!),
                            RecipeCategory(recipe_category_name: "Pie Dessert",
                                           recipe_category_url: URL(string:"https://www.fatsecret.com/recipes/collections/meal/dessert/pie/Default.aspx")!),
                            RecipeCategory(recipe_category_name: "Snack",
                                           recipe_category_url: URL(string:"https://www.fatsecret.com/recipes/collections/meal/snack/Default.aspx")!),
                            RecipeCategory(recipe_category_name: "Sweet Snack",
                                           recipe_category_url: URL(string:"https://www.fatsecret.com/recipes/collections/meal/snack/sweet/Default.aspx")!),
                            RecipeCategory(recipe_category_name: "High Fiber",
                                           recipe_category_url: URL(string:"https://www.fatsecret.com/recipes/collections/nutrition/high-fiber/Default.aspx")!),
                            RecipeCategory(recipe_category_name: "Low Cholesterol",
                                           recipe_category_url: URL(string:"https://www.fatsecret.com/recipes/collections/nutrition/low-cholesterol/Default.aspx")!),
                        ]),
                        recipe_description: "Surprisingly delicious apple pie filling and peanut butter wrapped up in a whole wheat tortilla.",
                        recipe_id: "187769",
                        recipe_images: RecipeImage(recipe_image: [URL(string: "https://m.ftscrt.com/static/recipe/57852fa0-eb3a-4abe-8f0f-94016290842b.jpg")!]),
                        recipe_name: "Apple Pie Pockets",
                        recipe_types: RecipeTypes(recipe_type: ["Dessert",
                                                                "Snack"]),
                        recipe_url: URL(string: "https://www.fatsecret.com/recipes/apple-pie-pockets/Default.aspx"),
                        serving_sizes: FSPRecipeServing(serving: FSPRecipeServingInfo(calcium: 0.0,
                                                                                      calories: 345.0,
                                                                                      carbohydrate: 56.0,
                                                                                      cholesterol: 0.0,
                                                                                      fat: 10.5,
                                                                                      fiber: 7.0,
                                                                                      iron: 0.0,
                                                                                      monounsaturated_fat: 0.0,
                                                                                      polyunsaturated_fat: 1.50,
                                                                                      potassium: 0.0,
                                                                                      protein: 8.0,
                                                                                      saturated_fat: 2.25,
                                                                                      serving_size: 1,
                                                                                      sodium: 325.0,
                                                                                      sugar: 22.50,
                                                                                      trans_fat: 0.0,
                                                                                      vitamin_c: 0.0))
                       ),
    ]
    
    
    
}
