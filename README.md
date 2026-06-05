## **Meta-MIP-with-Machine-Learning**

In the repository, I'll start a project to show how to apply Machine Learning and Meta-MIP algorithms to display the workflow of parametrization.

### **1. Initial Parametrization Scanning**

---

In the initial parameter scanning stage, we used the following formulas to calculate the initial values of each parameter, where $i$ and $j$ refer to the metal atom and other atoms, respectively:

$R_{min,ij}=\frac{R_{min,i}+R_{min,j}}{2}$

$\varepsilon_{ij}=\sqrt{\varepsilon_{i}\times \varepsilon_{j}}$

The corresponding GROMACS calculation files are provided in the directory `1. Initial Parametrization Scanning`. `GenTable.f90` is a Fortran program used to generate the potential function between two atoms, and `Table` is the binary executable of this program. To run this file, five numerical values need to be input: $\varepsilon_{ij}$, $R_{min,ij}$, $C_{4}$, $R_{cutoff}$, and potential type (1=LJ12-6, 2=LJ12-6-4). For example, the following input:

`1.65 0.3 0.50 1.0 2`

This will generate a `table.xvg` file.

This folder also contains the input files for GROMACS calculations, which were used to simulate the trajectory of An<sup>3+</sup> ions in a box containing 800 water molecules. The IOD and CN were calculated from the generated trajectory using the `gmx rdf` command.

### **2. Machine-Learning**

The parameter space scanning from the previous step yielded the data file `train_data.csv`. `ML-IOD.py` and `ML-CN.py` are ML python codes for IOD and CN, respectively, based on a multilayer perceptron (MLP). `valid.csv` is the validation data file used to evaluate the model performance. Here, we selected part of the data from _J. Chem. Theory Comput._ 2021, 17 (4), 2342-2354 as the validation set and output the IOD and CN. To reduce the variability in ML accuracy, the results were averaged over five different `random_state` values for each run. The final results are presented in Tables S3 and S4 in the Supporting Information.

Then, using this ML-accelerated approach, the `prediction_data.csv` file can be obtained. It features a finer division across the entire parameter space, containing approximately 7200 points in total.

### **3. Meta-MIP Algorithm**
