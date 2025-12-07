// http://adventofcode.com/2025/day/4
package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func readInput() string {
	scanner := bufio.NewScanner(os.Stdin)
	var lines []string

	for scanner.Scan() {
		line := scanner.Text()
		lines = append(lines, fmt.Sprintf("%v\n", line))
	}

	if err := scanner.Err(); err != nil {
		fmt.Println("Error:", err)
	}

	return strings.Join(lines, "")
}

func main() {
	input := readInput()
	rows := strings.Split(input, "\n")

	rolls := [][]bool{}
	for _, rowStr := range rows {
		row := []bool{}
		for _, space := range strings.Split(rowStr, "") {
			row = append(row, space == "@")
		}

		if len(row) > 0 {
			rolls = append(rolls, row)
		}
	}

	fmt.Println(input)
	fmt.Printf("Part 1: %v\n", part1(&rolls))
	fmt.Printf("Part 2: %v\n", part2(&rolls))
}

func findAccessibleRowCoordinates(rolls *[][]bool) [][]int {
	accessibleCoordinates := [][]int{}

	maxY := len(*rolls)
	maxX := len((*rolls)[0])

	for y, r := range *rolls {
		for x, s := range r {
			if !s {
				continue
			}

			numNeighborRolls := 0

			for _, i := range [3]int{-1, 0, 1} {
				for _, j := range [3]int{-1, 0, 1} {
					if i == 0 && j == 0 {
						continue
					}

					nY := y + i
					nX := x + j

					if nY < 0 || nY >= maxY || nX < 0 || nX >= maxX {
						continue
					}

					if (*rolls)[nY][nX] {
						numNeighborRolls++
					}
				}
			}

			if numNeighborRolls < 4 {
				accessibleCoordinates = append(accessibleCoordinates, []int{y, x})
			}
		}
	}

	return accessibleCoordinates
}

func part1(rolls *[][]bool) string {
	accessibleRolls := findAccessibleRowCoordinates(rolls)
	return strconv.Itoa(len(accessibleRolls))
}

func part2(rolls *[][]bool) string {
	numRemovedRolls := 0

	for {
		accessibleRollCoords := findAccessibleRowCoordinates(rolls)

		for _, xy := range accessibleRollCoords {
			(*rolls)[xy[0]][xy[1]] = false
			numRemovedRolls++
		}

		if len(accessibleRollCoords) == 0 {
			break
		}
	}

	return strconv.Itoa(numRemovedRolls)
}
