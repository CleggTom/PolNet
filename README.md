# Plant Pollinator Networks

This repository contains the code for **Clegg T and Gross T.** ``*Temporal Structure Mediates the Robustness and Collapse of Plant–Pollinator Networks*''.

## Structure

The code for numerical analysis and simualtions is all in the julia package `PlantPol.jl` in the `code` directory. Notebooks used to generate results and figures are in the 'Notebooks' folder.

### Instructutions
To run the code you need to first instantiate the local julia environment. Start an interactive julia session in the terminal from the repository and then activate the local project by typing `]` and then `activate .`. Once the envrionment is activated you should see the prompt change to `(PolNet) pkg>`. Type the command `instantiate` which will download all the packages do any precompilation. 
