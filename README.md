# <p align=center> An Information Theory Framework for Movement Path Segmentation and Analysis
<p align=center> Varun Sethi
<br/> (as a member of Getz Lab)
<br/><br/> University of California at Berkeley
<br/>
<br/>
<br/>

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
such that each segment has $`\mu`$ points. The segmentation can be performed in two ways: to generate a vector representation using means, standard deviations, and net displacement[[2]](#2); and as multivariate time-series of $`\mu`$ points. These segments are then categorised using a clustering algorithm into $`n`$ clusters. The cluster centroid, which is a representative segment for a cluster (e.g., mean of all segments belonging to that cluster), is called a StaME:
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
We define a coding scheme as a combination of clustering algorithms to generate StaMEs and CAMs, along with other parameters - $`\mu`$ (base segment size), $`n`$ (number of StaMEs), $`m`$ (number of base segments in a word), $`k`$ (number of CAMs). We use several metrics, including the error associated with the misassignment of words in CAMs, to compare the coding schemes. A coding efficiency at the level of StaME, CAM, and rectified CAM sequences is defined using the Shannon information entropy. The coding efficacy of track segmentation into raw CAMs is measured by Jensen-Shannon divergence, which compares the word distributions before and after CAM clustering. Lastly, we consider various vector and shape clustering algorithms in our coding schemes as described in Appendix B of [[1]](#1).



## Description of scripts

Codes for preparation and clustering of base and word segment data for a barn owl individual and ANIMOV1 are under the [clustering](https://github.com/Observarun/Hierarchical-path-segmentation-II/tree/main/clustering) directory. The directory [raw-CAM-coding](https://github.com/Observarun/Hierarchical-path-segmentation-II/tree/main/rectification-of-CAMs) shows the programs to label the word types, calculate their counts by raw CAMs, evaluate the Jensen-Shannon divergence to measure the entropy loss by word clustering, and identifies a coarse resolution segment corresponding to every word. The codes for calculating rectified CAM statistics, StaMEs' distribution in rectified CAMs, and efficiency and error metrics to compare the coding schemes are presented in the directory [rectification-of-CAMs](https://github.com/Observarun/Hierarchical-path-segmentation-II/tree/main/rectification-of-CAMs). Each script is preceeded by a serial number, and might require one or more of the earlier scripts to be executed beforehand.



## References

<a id="1">[1]</a>
Varun Sethi, Orr Spiegel, Richard Salter, Shlomo Cain, Sivan Toledo, Wayne M. Getz (2024).
An Information Theory Framework for Movement Path Segmentation and Analysis.
bioRxiv 2024.08.xx.xxxxxx, doi: https://doi.org/xx.xxxx/2024.08.xx.xxxxxx; GitHub repository: https://github.com/Observarun/Hierarchical-path-segmentation-II

<a id="2">[2]</a> 
Wayne M. Getz, Richard Salter, Varun Sethi, Shlomo Cain, Orr Spiegel, Sivan Toledo (2023). 
The Statistical Building Blocks of Animal Movement Simulations.
bioRxiv 2023.12.27.573450, doi: https://doi.org/10.1101/2023.12.27.573450; GitHub repository: https://github.com/Observarun/Hierarchical-path-segmentation-I
