data imdb;
   infile '~/STAT448/data/movie_metadata.csv' dlm=',' firstobs=2 dsd;
   input color $ director_name :$25. num_critic_for_reviews 
         duration director_facebook_likes 
         actor_3_facebook_likes actor_2_name :$25. actor_1_facebook_likes 
         gross genres :$80. actor_1_name :$25. movie_title :$100. num_voted_users 
         cast_total_facebook_likes actor_3_name :$25. facenumber_in_poster 
         plot_keywords :$150. movie_imdb_link :$100. num_user_for_reviews 
         language :$15. country :$20. content_rating $ budget title_year 
         actor_2_facebook_likes imdb_score aspect_ratio movie_facebook_likes;
   keep color movie_title director_name language imdb_score;
   format gross budget dollar15.;
   movie_title=lowcase(movie_title);
run;

proc format;
   value scoref low-<4='Low'
                4-7='Average'
                7-high='High'
                . = 'Missing';
   value $Genre_format
    "Documentary" = "Nonfiction"
    "Biography" = "Nonfiction"
    "News" = "Nonfiction"
    "Animation" = "Family/Animation"
    "Family" = "Family/Animation"
    "Mystery" = "Action/Crime/Drama/Mystery/Thriller"
    "Crime" = "Action/Crime/Drama/Mystery/Thriller"
    "Thriller" = "Action/Crime/Drama/Mystery/Thriller"
    "Action" = "Action/Crime/Drama/Mystery/Thriller"
    "Drama" = "Action/Crime/Drama/Mystery/Thriller"
    "Musical" = "Other"
    "Music" = "Other"
    "Fantasy" = "Fantasy/Scifi"
    "Sci-Fi" = "Fantasy/Scifi"
    "Sport" = "Other"
    "War" = "Other"
    "History" = "Other"
    "Western" = "Other";
run;

data imdb;
	set imdb;
   	if content_rating='GP' then content_rating='PG';
   /* 
   if content_rating in ('G', 'PG', 'PG-13', 'R', 'NC-17','TV-Y', 'TV-Y7', 'TV-G', 'TV-PG', 'TV-14', 'TV-MA');
   attrib Rating format=scoref.; 
   Rating=imdb_score;
   */
  	label 
   	title_year = "Release year"
   	duration = "Movie length (in minutes)"
   	gross = "Gross revenue"
   	genres = "Categorized genres"
   	budget = "Movie budget";
run;



proc sql undo_policy = none;
	create table imdb as
	select imdb_score, color, director_name, language, count(*) as num_dir
	from imdb
	where director_name is not missing
	group by director_name
	order by num_dir desc, director_name asc;
quit;


data imdb;	
	set imdb;
	if num_dir ge 6 then director_name = 'Tier 1';
	if num_dir < 6 & num_dir > 1 then director_name = 'Tier 2';
	if num_dir le 1 then  director_name = 'Tier 3';
run;	

proc print data=imdb (obs=15);
run;
	


data imdb;
	set imdb;
	newlanguage = language;
	if newlanguage not in ("English", "French", "Spanish", "Hindi", "Mandarin", "German" )
	then newlanguage = "Other";
run;

proc print data=imdb (obs=15);
run;

ods text = "Since there are so many unique languages, I defined unique 6 major languages and defined rest of them as others.";
	
proc genmod data=imdb;
   	class color director_name newlanguage /ref=first;
   	model imdb_score = color director_name newlanguage / dist=poisson 
		link=log type1 type3 scale = d;
ods select ModelInfo ModelFit ParameterEstimates Type1 ModelANOVA;
run;


ods text = "After estimating the scale, we can see that all of director name, color and some of newlanguage are significant. The baseline of this model is the first variable because it is the predominant variable in this model.
Color is significantly different from black and white. For director name, Tier 2 and Tier 3 are significantly different from Tier 1.
In newlanguage, French, Spanish, Hindi, German, and other languages are significantly different from English. Mandarin is insignificant.";
ods text = "Type 1 analysis indicates that all predictors are significant.
Type 3 analysis has the same result as Type 1, it indicates that all predictors are significant. 
We are pretty sure that we keep the color variable but we need to see if we keep other variables as well.";



proc genmod data=imdb plots=(stdreschi stdresdev);
   	class color director_name newlanguage/ref=first;
	model imdb_score = color director_name newlanguage/ dist=poisson 
	link=log scale=d type1 type3;
	output out=outp4 pred=predp4 stdreschi=reschi stdresdev=resdev;
	ods select ParameterEstimates;
run;

ods text = "The parameter estimate of color is -0.1147 indicating an increase of one in color, imdb_score is expected to be increasing by e^-0.1147.
and the parameter estimate of tier 2 is -0.0452 indicating an increase of one in tier2, imdb_score is expected to be increasing by e^-0.0452.
and the parameter estimate of tier 3 is -0.1118 indicating an increase of one in tier3, imdb_score is expected to be increasing by e^-0.1118.
the parameter estimate of French in newlanguage is 0.1292 indicating an increase of one in French, imdb_score is expected to be increasing by e^0.1292.
the parameter estimate of Spanish in newlanguage is 0.1179 indicating an increase of one in Spanish, imdb_score is expected to be increasing by e^0.1179.
the parameter estimate of German in newlanguage is 0.1407 indicating an increase of one in German, imdb_score is expected to be increasing by e^0.0.1407.
the parameter estimate of Hindi in newlanguage is 0.0811 indicating an increase of one in Hindi, imdb_score is expected to be increasing by e^0.0811.
the parameter estimate of other in newlanguage is 0.1383 indicating an increase of one in other, imdb_score is expected to be increasing by e^0.1383.
.";

proc sgscatter data=outp4;
	compare y= (reschi resdev) x=predp4; 
run;


ods text = "The scatter plot indicates that the residuals is narrowing as the predicted value increases. It is because first two predicted values have much more observations than last few values.
I assumes this is why it has narrow trend. ";

proc genmod data=imdb plots=(stdreschi stdresdev);
   	class color director_name ;
	model imdb_score = color director_name / dist=poisson 
		link=log scale=d type1 type3;
	ods select ModelInfo DiagnosticPlot;
run;

ods text = "As we look at the diagnostic plot, the residuals are flat enough so the model is fine.";





proc genmod data=imdb;
   	class color director_name newlanguage /ref=first;
   	model imdb_score = color director_name newlanguage / dist=gamma 
		link=log type1 type3 scale = d;
ods select ModelInfo ModelFit ParameterEstimates Type1 ModelANOVA;
run;

ods text = " This time, I tried gamma distribution and the result is really similar to poisson distribution.
After estimating the scale, we can see that all of director name, color and some of newlanguage are significant. The baseline of this model is the first variable because it is the predominant variable in this model.
Color is significantly different from black and white. For director name, Tier 2 and Tier 3 are significantly different from Tier 1.
In newlanguage, French, Spanish, Hindi, German, and other languages are significantly different from English. Only Mandarin is insignificant.";
ods text = "Type 1 analysis indicates that all predictors are significant.
Type 3 analysis has the same result as Type 1, it indicates that all predictors are significant. ";



proc genmod data=imdb plots=(stdreschi stdresdev);
   	class color director_name newlanguage /ref=first;
	model imdb_score = color director_name newlanguage/ dist=gamma 
	link=log scale=d type1 type3;
	output out=gammares pred=presp_n stdreschi=presids
		stdresdev= dresid;
	ods select  ParameterEstimates;
run;

ods text = "The parameter estimate of color is -0.1160 indicating an increase of one in color, imdb_score is expected to be increasing by e^-0.1160.
and the parameter estimate of tier 2 is -0.0453 indicating an increase of one in tier2, imdb_score is expected to be increasing by e^-0.0453.
and the parameter estimate of tier 3 is -0.1122	 indicating an increase of one in tier3, imdb_score is expected to be increasing by -0.1122	.
the parameter estimate of French in newlanguage is 0.1303 indicating an increase of one in French, imdb_score is expected to be increasing by e^0.1303.
the parameter estimate of Spanish in newlanguage is 0.1185 indicating an increase of one in Spanish, imdb_score is expected to be increasing by e^0.1185.
the parameter estimate of German in newlanguage is 0.1402 indicating an increase of one in German, imdb_score is expected to be increasing by e^0.0.1402.
the parameter estimate of Hindi in newlanguage is 0.0808 indicating an increase of one in Hindi, imdb_score is expected to be increasing by e^0.0808.
the parameter estimate of other in newlanguage is 0.1395 indicating an increase of one in other, imdb_score is expected to be increasing by e^0.1395.
.";

proc sgscatter data=gammares;
	compare y= (presids dresid) x=presp_n; 
	run;

ods text = "The scatter plot is also very similar to poisson distribution. it indicates that the residuals is narrowing as the predicted value increases. I
t is because first two predicted values have much more observations than last few values.
I assumes this is why it has narrow trend.";
proc genmod data=imdb plots=(stdreschi stdresdev);
   	class color director_name newlanguage /ref=first;
	model imdb_score = color director_name newlanguage/ dist=gamma 
	link=log scale=d type1 type3;
	ods select ModelInfo DiagnosticPlot;
run;

ods text = "As we look at the diagnostic plot, the residuals are flat enough so the model is fine.";



proc genmod data=imdb plots=cooksd ;
   	class color director_name newlanguage ;
	model imdb_score = color director_name newlanguage / dist=gamma;
	ods exclude ModelInfo ClassLevelInfo ModelFit ParameterEstimates Type1 ModelANOVA;
run;


ods text = "I chose to check if there is any influential points in model with gamma distribution. The reason I chose gamma distribution is because since I use continous variable as response variable, gamma distribution is better than poisson distribution which is appropriate for discret variable.
As I checked cooks distance, there are some high influetial points compared to other points but it is not big enough to remove in terms of rule of thumb. so we can conclude there is no influential points this model.";

