#include <stdio.h>

#define SIZE 4
#define INFINITY 100000

// Suppose we are using adjacent graph

int min(int* my_array, int length, int* visited)
{
	int min = 0;
	while (visited[min])
		min++;		// choose a propirate initial value

	for (int i = 0; i < length; ++i)
	{
		if (my_array[i] < my_array[min] && !visited[i])
			min = i;
	}
	return min;
}

void dijkstra(int adj_mat[SIZE*SIZE], int start)
{
	int dis[SIZE];
	int visited[SIZE];

	// Initialization
	for (int i = 0; i < SIZE; ++i)
	{
		if (i != start)
			visited[i] = 0;
		else
			visited[i] = 1;

		dis[i] = adj_mat[start*SIZE + i];
	}
	int num_unvisited = SIZE - 1;

	// Start tracking the shortest path
	while (num_unvisited)
	{
		int current_min = min(dis, SIZE, visited);
		visited[current_min] = 1;
		for (int j = 0; j < SIZE; ++j)
		{
			if ((adj_mat[current_min*SIZE + j] + dis[current_min]) < dis[j])
				dis[j] = adj_mat[current_min*SIZE + j] + dis[current_min];
		}
		num_unvisited --;
	}
	for (size_t k = 0; k < SIZE; k++)
		printf("The distace between starting node (node %d) and node %d is: %d\n", start, k, dis[k]);
}
int int main(int argc, char const *argv[]) {
	int start_node = argv[1];
	int adj_mat[SIZE*SIZE] = {
		{0,1,2,3},
		{1,0,4,5},
		{2,4,0,6},
		{3,5,6,0}
	};
	dijkstra(adj_mat, start_node);
	return 0;
}
