# EdelweissFE Apptainer Container

This repository provides a fully packaged, ready-to-run [Apptainer](https://apptainer.org/) (formerly Singularity) container for the [EdelweissFE](https://edelweiss-numerics.github.io/EdelweissFE/) framework. 

Building EdelweissFE requires compiling several C++ libraries (Eigen, Autodiff, Fastor, Marmot). This container handles all of those dependencies internally using a Debian 13 base and Miniforge, allowing you to run simulations immediately without needing a local C++ build environment or Conda setup.

---

## Prerequisites

To use this container, you only need to have Apptainer installed on your host system (usually a Linux machine or an HPC cluster). 

* [Install Apptainer](https://apptainer.org/docs/admin/main/installation.html)

---

## Getting the Container

You do not need to build the container yourself. The latest compiled `.sif` (Singularity Image Format) file is automatically generated and attached to our releases.

1. Navigate to the **Releases** page of this GitHub repository.
2. Download the latest `edelweissfe-debian-13.sif` file.
3. Place the `.sif` file in your working directory or a central location on your machine.

---

## Usage

Apptainer natively integrates with your host system. By default, it automatically mounts your current working directory, meaning the container can read your input files and write output files exactly where you execute the command.

### Running a Simulation

To run an EdelweissFE simulation, treat the `.sif` file as if it were the `edelweissfe` executable:

```bash
# Basic execution
apptainer run edelweissfe-debian-13.sif my_simulation_input.inp
