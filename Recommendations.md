# Recommendations to improve the R project structure

To be able to add the improvements that we suggest, we need to make some changes to the project structure. The following are the recommendations to improve the R project structure:

1. Use Renv to manage R package dependencies

To manage R package dependencies, we recommend using Renv. Renv is a package manager that allows you to create isolated R environments for your projects. This helps to avoid conflicts between different versions of R packages and ensures that your project is reproducible.

To install Renv, in Rstudio console, run the following command:

```bash
install.packages("renv")
```

After installing Renv, you can create a new R environment for your project by running the following command in the Rstudio console:

```bash
renv::init()
```

This will create a new `.Rprofile` file in your project directory, which contains the list of R packages that are required for your project. When a new user clones your project, they can run the following command to install the required R packages after having installed Renv:

```bash
renv::restore()
```

This will install the required R packages in a new R environment, ensuring that the project is reproducible.


2. Be able to call pass parameters to the R script from the command line

To make the R script more flexible, we recommend adding the ability to pass parameters to the R script from the command line. This allows users to customize the behavior of the R script without having to modify the script itself.

To add this functionality, you can use the `optparse` package. The `optparse` package allows you to define command-line options for your R script and parse them at runtime.

We have provided an example of how to use the `optparse` package in the `main.R` script. You can modify this script to add the command-line options that you need for your project.