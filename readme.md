# Vehicle Routing Problem

## Folder Structure

This project is subdivided into two modules:

- `Or-tools`: The python implementation of the solver
- `Prolog`: The prolog implementation of the solver

The `data` folder contains the datasets for each problem variation and also a set of test problems with a smaller number of nodes.

The `docs` folder contains the two presentations made for the course.

## Usage

### Or-Tools
#### How to run
```
cd or-tools
python main.py
```

#### Plots and tables
```
cd or-tools
python plot.py
python table.py
```

### Prolog

For the Prolog approach, the following steps should be followed to solve the dataset problems:

1. Consult the *test.pl* file, inside the *prolog* directory:
```prolog
  consult('test.pl').
```

2. Run the `test/0` predicate:
```prolog
  test.
```
3. The results are found inside the *prolog/results* directory.
  
4. By running the *plots.py* file we obtain a graphical visualization of the results achieved (a cost of 0 is equivalent to timeout):
```bash
  python ./results/plot.py
```

## Contributors

João Marinho (up201905952)

Rodrigo Tuna (up201904967)