On the GoldenBrown Recommendation System
========================
This package contains code and other material used in the paper *On the GoldenBrown Recommendation System*, submitted as a part of the course Computational Intelligence Lab, offered in Spring '14.

### Abstract
 Recommender Systems are tasked with providing users personalized recommendations. These recommendations are often generated using Collaborative Filtering where the past transactions are analyzed to provide a measure of the connections between users and items. In this paper we describe the outline of our solution to the Collaborative Filtering problem posed in the course Computational Intelligence Lab. Our solution combines a few different approaches with significant parameter tuning. In addition we also present our results  on other Collaborative Filtering Datasets (MovieLens100K, Jester). We compare our results with two baselines - SVD and K-means, and show that our algorithm significantly beats both in terms of accuracy.
 
### Contents
 The package contains the following folders:
 
* **sgd-svd**
Implementation of the GoldenBrown SGD-SVD algorithm
* **svd**
Implementation of 1st Baseline - SVD, as taught in CIL course
* **kmeans**
Implementation of 2nd Baseline - K-Means, as taught in CIL course
* **sgd-svd-comp**
A variant of the reported algorithm submitted for competitive scoring
* **helper-scripts**
Contains the graph-factory iPython notebook, which was used to analyze and plot results
* **exp-data**
Data obtained from experiments and used in the results section
* **datasets**
Contains the Collaborative Filtering datasets - CIL, ML100 and JES1 used in the paper

### Requirements
* Matlab (Code was implemented on R2013b)
* Python 2.7 (For results)
* iPython 1.0 (For results)

### Getting Started
* Unzip the contents of the zip folder
* To reproduce results in Figures 1 of the paper, run the script `CollabFilteringEvaluationKFold.m` in each of the implementations, by commenting out the parameters tuned for each dataset. Additionally, set the following parameters in struct `s`:
    * dataset
    * comments
    * SAVE_FILENAME
* To reproduce the results in Figure 2 of the paper, run the script `sgd-svd/ExptRunner.m`. 
* The results from the above are self-contained in a `.mat` file. The iPython notebook for plotting and analyzing these data files are self-explanatory.

### Authors
* Siddarth Sarda (ssarda@student.ethz.ch)
* Hany Abdelrahman (hanya@student.ethz.ch)
* Tribhuvanesh Orekondy (torekond@student.ethz.ch)