# Analysis-of-IMDB-Rated-Films

IMDB Dataset Overview


The IMDB dataset includes 4,917 unique films that have been rated by IMDB users. The dataset includes 26 variables, excluding the variables for the movie title and the IMDB website link. There are 14 continuous variables describing film-specific attributes such as budget, gross revenue, duration, IMDB score, number of IMDB reviewers, number of critic reviewers, number of faces in the movie poster, and six different variables for the number of Facebook likes. These six variables include the number of likes that the movie has, the main three actors/actresses, the director, and the total of the entire cast. There are also 13 categorical variables including the year the film was released, its aspect ratio, color, language, country of release, content rating, the names of the main three actors/actresses and the director, plot keywords, and genre keywords.
Source: https://www.kaggle.com/carolzhangdc/imdb-5000-movie-dataset



Research Interests and Methodology

I will be using generalized linear regression to find the relationship between the response variable, IMDB score, and all categorical predictors, color, director and language. To sort the categorical variable such as director, additional variables that represent the level of directors depends on the number of movies they produced will be created. Through a selection, I can choose the final model to perform the analysis.
