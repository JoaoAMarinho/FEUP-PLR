import matplotlib.pyplot as plt
import numpy as np

def display_results(problem, configurations):
    Times = [0.5, 1, 5, 10, 20]
    # Create the plot
    x = 0
    for label, values in configurations.items():
        lw=10-8*x/len(configurations)
        ls=['-','--','-.',':'][x%4]
        x+=1
        if values is None:
            values = [0, 0, 0, 0, 0]
        plt.plot(Times, values, label=str(label), linestyle=ls, linewidth=lw)

    plt.title(f"Convergence Graph per configuration {problem}")
    plt.xlabel('Time (minutes)')
    plt.ylabel('Cost')
    plt.legend()
    plt.show()
    plt.clf()

# Example usage
problems = {
    'mdvrptw/pr00': {
        'leftmost/step/up': None,
        'leftmost/step/down': None,
        'leftmost/bisect/up': None,
        'leftmost/bisect/down': None,
        'ffc/step/up': None,
        'ffc/step/down': [809, 808, 777, 770, 770],
        'ffc/bisect/up': None,
        'ffc/bisect/down': [809, 808, 777, 770, 770],
    },
    'mdvrp/pr01': {
        'leftmost/step/up': None,
        'leftmost/step/down': None,
        'leftmost/bisect/up': None,
        'leftmost/bisect/down': None,
        'ffc/step/up': None,
        'ffc/step/down': [1267, 1251, 1221, 1212, 1212],
        'ffc/bisect/up': None,
        'ffc/bisect/down': [1267, 1251, 1221, 1212, 1212],
    },
}

if __name__ == "__main__":
    for problem, configurations in problems.items():
        display_results(problem, configurations)
