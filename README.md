# **Meta-MIP-with-Machine-Learning**

In the repository, I'll show how to apply Machine Learning and Meta-MIP algorithms to the workflow of parametrization.

## **1. Initial Parametrization Scanning**

In the initial parameter scanning stage, we used the following formulas to calculate the initial values of each parameter, where $i$ and $j$ refer to the metal atom and other atoms, respectively:

$R_{min,ij}=\frac{R_{min,i}+R_{min,j}}{2}$

$\varepsilon_{ij}=\sqrt{\varepsilon_{i}\times \varepsilon_{j}}$

The Fortran program `GenTable.f90` is used to generate the potential function between two atoms, and `table` is the binary executable of this program. You can run this file by the command:

```bash
chmod +x table
./table
```

Five numerical values need to be input: $\varepsilon_{ij}$, $R_{min,ij}$, $C_{4}$, $R_{cutoff}$, and potential type (1=LJ12-6, 2=LJ12-6-4). For example, the following input:

`1.65 0.3 0.50 1.0 2`

This will generate a `table.xvg` file.

This folder also contains the input files for GROMACS calculations, which were used to simulate the trajectory of An<sup>3+</sup> ions in a box containing 800 water molecules. The IOD and CN were calculated from the generated trajectory using the command

```bash
gmx rdf -f OPC3_MFmd.xtc -n OPC3_MF.ndx -o a1.xvg -cn a2.xvg -bin 0.0005 -b 1000
```

## **2. Machine-Learning**

The parameter space scanning from the previous step yielded the data file `train_data.csv`. `ML-IOD.py` and `ML-CN.py` are ML python codes for IOD and CN, respectively, based on a multilayer perceptron (MLP). `valid.csv` is the validation data file used to evaluate the model performance. Here, we selected part of the data from _J. Chem. Theory Comput._ 2021, 17 (4), 2342-2354 as the validation set and output the IOD and CN. To reduce the variability in ML accuracy, the results were averaged over five different `random_state` values for each run. The final results are presented in Tables S3 and S4 in the Supporting Information.

Then, using this ML-accelerated approach, the `prediction_data.csv` file can be obtained. It features a finer division across the entire parameter space, containing approximately 7200 points in total.

## **3. Meta-MIP Algorithm**

For the detailed working principle of the Meta-MIP algorithm, please refer to _Phys. Chem. Chem. Phys._ 2021, 23 (3), 1956-1966, _Phys. Chem. Chem. Phys._ 2021, 23 (11), 6763-6774, and https://github.com/Forestsene/LHS-BO-MIP/tree/main/lhs_bo_mip. Here, we provide an example of optimizing parameters for the OPC3 water model. Run the following command in the folder:

```bash
chmod +x start.sh
./start.sh
```

The program will then automatically optimize and converge to the optimal parameters.

## **4. Testing the transferability**

Here, we provide the input files for MD simulations, using the simulated trajectory of U<sup>3+</sup> in methanol solution as an example. We used the following formula to calculate the C<sub>4</sub> parameters between U<sup>3+</sup> and other atoms:

$C_4(An-X) = \frac{C_4 (An-OW)}{\alpha(H_2O)} \times \alpha(X)$

The parameter values in the formula can be found in the Supporting Information of the article.

All trajectory files of the AIMD and MD simulations are available at https://doi.org/10.5281/zenodo.20554911

# **Citation**

If you use the package in your research, please cite it:

```
@Misc{,
    author = {Tian, Changyi and Zhao, Jiayao and Song, Junjie and Li, Jun and Hu, Hanshi},
    title = {Development of a New Force Field for Trivalent Actinide Ions with Machine Learning Acceleration under OPC3 and OPC Water Models},
    year = {2026},
    url = " https://github.com/songjunjie2015/Meta-MIP-with-Machine-Learning"
}
```

For Meta-MIP:

```
@article{RN796,
   author = {Song, Junjie and Wan, Mingwei and Yang, Ying and Gao, Lianghui and Fang, Weihai},
   title = {Development of Accurate Coarse-Grained Force Fields for Weakly Polar Groups by an Indirect Parameterization Strategy},
   journal = {Physical Chemistry Chemical Physics},
   volume = {23},
   number = {11},
   pages = {6763-6774},
   DOI = {10.1039/D1CP00032B},
   url = {http://dx.doi.org/10.1039/D1CP00032B},
   year = {2021}
}

@article{RN797,
   author = {Wan, Mingwei and Song, Junjie and Yang, Ying and Gao, Lianghui and Fang, Weihai},
   title = {Development of Coarse-Grained Force Field for Alcohols: an Efficient Meta-Multilinear Interpolation Parameterization Algorithm},
   journal = {Physical Chemistry Chemical Physics},
   volume = {23},
   number = {3},
   pages = {1956-1966},
   DOI = {10.1039/D0CP05503D},
   url = {http://dx.doi.org/10.1039/D0CP05503D},
   year = {2021}
}
@Misc{,
    author = {Dong, Yi and Song, Junjie and Wan, Mingwei and Gao, Lianghui},
    title = {LHS-BO-MIP: A combined global-local optimization workflow for force field parameterization},
    year = {2025},
    url = " https://github.com/Forestsene/LHS-BO-MIP"
}
```
