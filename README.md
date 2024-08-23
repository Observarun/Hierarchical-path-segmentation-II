# <p align=center> An Information Theory Framework for Movement Path Segmentation and Analysis
<p align=center> Varun Sethi
<br/> (as a member of Getz Lab)
<br/><br/> University of California at Berkeley
<br/>
<br/>
<br/>



## Overview

This repository corresponds to [[1]](#1), where we present an information theoretic framework for hierarchical segmentation of animal movement trajectory to construct behavioural activity modes (BAMs) - e.g., foraging, resting, travelling, et cetera. Here, I give a brief, but more verbose, presentation of the data science problem in this work. Essentially, it involves a bottom-up procedure to construct canonical activity modes (CAMs) starting from a relocation data track, and encoding these raw CAMs using statistical movement elements (StaMEs) pre-extracted from the track.


## CAM coding with StaMEs as a data science problem

&nbsp;
The algorithm for construction of StaMEs from movement track data was explored for the first time in [[2]](#2) and is reviewed in [[1]](#1). The relocation series
```math
\lower{0cm}{
\mathcal{T}^{\rm loc}=\{(t;x_t,y_t)|t=0,\cdots,T\}
}
```
is used to derive speed and turning angle time series. This is then segmented into a base (or symbol) time series
```math
{\mathcal T}^{\rm seg} = \big\{(z;{\rm seg_{z}}) | {\rm seg}_{z} = \big((x_{\mu (z-1)},y_{\mu (z-1)}),\cdots,(x_{\mu z },y_{\mu z})\big), \ z=1,\cdots,N^{\rm seg}=\lfloor T/\mu \rfloor \}
```
such that each segment has $`\mu`$ points. The segmentation can be performed in two ways: to generate a vector (or feature) representation using means, standard deviations, and net displacement[[2]](#2); and as multivariate time-series of $`\mu`$ points. These segments are then categorised using a clustering algorithm into $`n`$ clusters. The cluster centroid, which is a representative segment for a cluster (e.g., mean of all segments belonging to that cluster), is called a StaME:
```math
{\mathcal S}=\{\sigma_i | i=1,\cdots,n \}.
```
These StaMEs can be used to code the series
```math
{\mathcal T}^{\sigma}=\{(z;\sigma_{i_z}) | z=1,\cdots,N^{\rm seg}\},
```
$` \raise{1cm}
{
\rm{which \ essentially \ assigns \ a \ StaME \ to \ each \ base \ segment.}
} `$

&nbsp;
On similar lines, the relocation sequence $`{\mathcal T}^{\rm loc }`$ is segmented into 'word' time series $` {\mathcal T}^{\rm wd} `$, each segment having $` m\mu `$ elements. Given our relocation frequency of $`\frac{1}{4}Hz`$ (i.e., a triangulation every $4\sec$), this segmentation is at a resolution of $`5m\mu\sec`$; this is a coarser resolution than before, hence the terminology 'base' segment. It should also be noted that in the absence of fundamental movement elements (FuMEs, which are mechanical movements like slithering, galloping, flapping wings, etc., and cannot be identified with relocation data alone), we use StaMEs as the most basic building block for hierarchical approach to path segmentation [[2]](#2). The word segments are then classified into $`k`$ clusters (termed CAMs), each having $`N^{\rm wd}_c`$ words ($`c=1,\cdots,k`$). This helps us assign each word to a CAM (called `raw' CAM assignment) using cluster centroids.

&nbsp;
Next, we want to explore CAM construction through StaMEs. Note that a word segment is created out of $`m`$ base segments. Because of this construction, a word can be coded as a string of $`m`$ StaMEs (which are base segment clusters). As an example, consider a scenario where $`\mu=5`$, $`n=4`$, and $`m=3`$; then the base segment is $`5-`$points long and a word is $`15-`$points long. In this case, if the $`3`$ base segments constituting a word form the StaMEs $`3,\ 1,\ 1`$, then the word is coded as $`311`$. We call this CAM coding with StaMEs as the bases. It is obvious that multiple words could have the same coding. It's easy to calculate the total number of word types: $`n^m=64`$; these word types are labelled using a sorting algorithm as explained in Appendix C of [[1]](#1). From here on, we calculate their distribution as the count of each word type by raw CAM. Next, a word type is identified as belonging to a CAM according to which raw CAM it occurs in the most frequently. The misassigned words of this type are then assigned to the correct CAM, thereby rectifying it. The corresponding error can be calculated using the proportion of misassigned words.

&nbsp;
We define a coding scheme as a combination of clustering algorithms to generate StaMEs and CAMs, along with other parameters - $`\mu`$ (base segment size), $`n`$ (number of StaMEs), $`m`$ (number of base segments in a word), $`k`$ (number of CAMs). We use several metrics, including the error associated with the misassignment of words in CAMs, to compare the coding schemes. A coding efficiency at the level of StaME, CAM, and rectified CAM sequences is defined using the Shannon information entropy. The coding efficacy of track segmentation into raw CAMs is measured by Jensen-Shannon divergence, which compares the word distributions before and after CAM clustering. Lastly, I consider various vector and shape clustering algorithms in our coding schemes as described next.


## Clustering approaches

The algorithms I use for clustering our time-series data can be classified as feature-based and shape-based. In feature-based (also termed vector clustering) approaches, a feature vector representation is contructed from the multivariate (speed and turning angle) time-series (base segments or words as explained above). This representation has statistical summary variables (means, standard deviations) and net displacement as in [[1]](#1). I use the following vector clustering approaches.

* Hierarchical agglomerative clustering with Ward's criterion and Euclidean metric used to compute the pairwise dissimilarity matrix (E). I implement this in $`\texttt{R-4.3.2} `$ using same methods as in [[2]](#2).

* Clustering is performed on the data transformed into similarity space as follows. [Graph spectral clustering](https://link.springer.com/article/10.1007/s11222-007-9033-z) (S) first constructs a similarity graph from the data using the affinity matrix: a matrix of point-to-point similarities $` A_{ij} = exp(-\frac{||x_i-x_j||^2}{2 \sigma^2}) `$ (Gaussian kernel with Euclidean metric), where points form the nodes while edges quantify the similarity between the points. Clusters are then found using k-means method in the reduced dimensional representation extracted from the spectral analysis of the normalized graph Laplacian $` L = \mathbb{1} - D^{-1/2}AD^{-1/2} `$, where diagonal node degree matrix $` D_{ii} = \sum_{j=1}^nA_{ij} `$. Summarily, it's a $`k`$-way graph cut problem---the connections between the points with low similarity are severed, while the net weight of the edges between the clusters are minimized. The computational complexity of the algorithm is $`{\mathcal O}(N_{seg}^3)`$. I implement this method in $`\texttt{Python 3.10.10}`$ using a Gaussian radial base function (RBF) kernel.

* Random Forest classifier can be used in an unsupervised way to generate a proximity matrix. The algorithm creates a synthetic dataset with each variable randomly sampled from the univariate distribution of the corresponding variable of the original dataset. The original and new datasets are given class labels $`1`$ and $`2`$, and merged to be used for training the random forest. The proximity matrix, constructed in terms of how often two points end up in the same leaf nodes, is then used for hierarchical clustering with Ward's criterion. We call this algorithm 'F'. Here, I perform distributed execution of the algorithm through using a parallel backend. Essentially, the task is split into multiple cores with each handling a number of trees. 

Shape-based clustering approaches are directly applied to the time-series representation of the segments. I use hierarchical agglomerative clustering with Ward's criterion, and the following two algorithms for computing pairwise dissimilarity (called 'D', 'M') between our segments.

* [Dynamic Time Warping](https://www.cs.ucr.edu/~eamonn/DTW_myths.pdf) (DTW) is a temporal shift-invariant similarity measure that performs one-to-one and one-to-many maps (or temporal alignments) between two time-series to minimize the Euclidean distance between aligned series. The algorithm constructs a local cost matrix (LCM) employing an $`{\rm L}_p`$-norm ($` p \in \{1,2\} `$) between each pair of points in the two time-sequences (lengths $`m,~n`$), with the $` {ij}^{\rm th} `$ element given by $` D(i,j) = d(i,j) + min\{ d(i-1,j);d(i,j-1),d(i-1,j-1) \}`$. Finding an optimal warp path then amounts to minimizing the cost over all admissible paths from $`{\rm LCM}(1,1)`$ to $`{\rm LCM}(n,m)`$ while ensuring that the sequence of index pairs increases monotonically in both $`i`$ and $`j`$. I use the $`\texttt{R}`$ $`\texttt{dtw\_basic}`$ function to help manage the $`{\mathcal O}(N_{seg}^2)`$ computational complexity with its C++ core and memory optimizations.

  I use the slanted band window constraint, which ensures that the warping path remains close to the diagonal. The $`\texttt{stepPattern}`$ employed to traverse through the LCM is $`\texttt{R}`$ $`\texttt{symmetric2}`$, which is commonly used and makes the DTW computation symmetric. The choice of clustering solution selected for different choices of window size within the range $\{1,\ldots,4\}$ and value of $p=1$ or 2 in $L_p$-norm is governed by silhouette coefficient.

* DTW cost is a non-differentiable function, which limits its utility when used as a loss function. Soft-DTW is a differentiable alternative to DTW making use of a soft-min operator.


## Data repository and description of scripts

The methods developed here have been demonstrated on both simulated and empirical relocation data. The former has been generated using a two‐mode step‐selection kernel simulator called Numerus ANIMOVER_1 [[2]](#2). The empirical data is obtained using an ATLAS reverse GPS technology system at a relocation frequency of 0.25 Hz. It corresponds to a female barn owl (Tyto alba) individual, which is part of a population tagged at our study site in the Harod Valley in northeast Israel. The ANIMOV and owl datasets are available in my [Dryad repository](https://doi.org/10.5061/dryad.jm63xsjkv) as files multi-DAR_sim.csv and list-DARsAsDataframes_owl.Rds respectively.

Codes for preparation and clustering of base and word segment data for a barn owl individual and ANIMOV1 are under the [clustering](https://github.com/Observarun/Hierarchical-path-segmentation-II/tree/main/clustering) directory. The directory [raw-CAM-coding](https://github.com/Observarun/Hierarchical-path-segmentation-II/tree/main/rectification-of-CAMs) shows the programs to label the word types, calculate their counts by raw CAMs, evaluate the Jensen-Shannon divergence to measure the entropy loss by word clustering, and identifies a coarse resolution segment corresponding to every word. The codes for calculating rectified CAM statistics, StaMEs' distribution in rectified CAMs, and efficiency and error metrics to compare the coding schemes are presented in the directory [rectification-of-CAMs](https://github.com/Observarun/Hierarchical-path-segmentation-II/tree/main/rectification-of-CAMs). Each script is preceeded by a serial number, and might require one or more of the earlier scripts to be executed beforehand.


## Results

![Comparison_clustering-methods](https://github.com/user-attachments/assets/61ac4bb0-7f09-45fa-944e-ea73c499be17)
<br/>
Table: Comparison of various feature-based (or vector) and shape-based clustering approaches for the 2-mode simulated data. Shown are 3 parameters - mean speed, mean turning angle, and occupancy - for each base segment cluster (StaME), along with the efficiency of each clustering method.

<img width="739" alt="Word-type-distributions_simulated-data" src="https://github.com/user-attachments/assets/5e95f1c8-55e1-4abe-bba7-04c95642b226">
<br/>
Figure: Word type distributions for each word cluster (CAM) with 4 StaMEs (base segment clusters) and m=3 (i.e., 3 base segments constituting a word) obtained using different coding schemes for the case of simulated data. Rectified CAM assignment for each word type is denoted by filled bars. CAMs are ordered in decreasing order of speed with red signifying the fastest CAM.


## References

<a id="1">[1]</a>
Varun Sethi, Orr Spiegel, Richard Salter, Shlomo Cain, Sivan Toledo, Wayne M. Getz (2024).
An Information Theory Framework for Movement Path Segmentation and Analysis.
bioRxiv 2024.08.02.606194, doi: https://doi.org/10.1101/2024.08.02.606194; GitHub repository: https://github.com/Observarun/Hierarchical-path-segmentation-II

<a id="2">[2]</a> 
Wayne M. Getz, Richard Salter, Varun Sethi, Shlomo Cain, Orr Spiegel, Sivan Toledo (2023). 
The Statistical Building Blocks of Animal Movement Simulations.
bioRxiv 2023.12.27.573450, doi: https://doi.org/10.1101/2023.12.27.573450; GitHub repository: https://github.com/Observarun/Hierarchical-path-segmentation-I
